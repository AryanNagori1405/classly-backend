const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

// ── helpers ──────────────────────────────────────────────────────────────────

/** Generate a 6-digit numeric OTP */
function generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

/** Return a JWT containing id, role and name */
function signToken(user) {
    return jwt.sign(
        { id: user.id, role: user.role, name: user.name },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
}

// ── POST /api/auth/verify-uid ────────────────────────────────────────────────
// Accepts { uid } or { reg_id }.  Looks up the user and sends back a
// simulated OTP (in production you would send SMS / email).
router.post('/verify-uid', async (req, res) => {
    try {
        const { uid, reg_id } = req.body;

        if (!uid && !reg_id) {
            return res.status(400).json({ message: 'UID or Registration ID is required' });
        }

        let userResult;
        if (uid) {
            userResult = await pool.query('SELECT * FROM users WHERE uid = $1', [uid]);
        } else {
            userResult = await pool.query('SELECT * FROM users WHERE reg_id = $1', [reg_id]);
        }

        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'User not found. Contact your administrator.' });
        }

        const user = userResult.rows[0];

        if (!user.is_active) {
            return res.status(403).json({ message: 'Your account has been suspended.' });
        }

        // Enforce OTP rate-limit: max 5 requests per window.
        // Check expiry FIRST so a new window resets the counter correctly.
        const otpWindowExpired = !user.otp_expires_at ||
            new Date(user.otp_expires_at) <= new Date();

        if (!otpWindowExpired && user.otp_attempts >= 5) {
            return res.status(429).json({
                message: 'Too many OTP requests. Please wait before retrying.'
            });
        }

        // Generate OTP and set 10-minute expiry
        const otp = generateOTP();
        const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

        // Reset counter on new window; increment within the same window
        const newAttempts = otpWindowExpired ? 1 : user.otp_attempts + 1;
        await pool.query(
            `UPDATE users SET otp_code = $1, otp_expires_at = $2,
             otp_attempts = $3, updated_at = NOW() WHERE id = $4`,
            [otp, otpExpiry, newAttempts, user.id]
        );

        // In production: send OTP via SMS / email.
        // In development only: log OTP server-side for testing.
        if (process.env.NODE_ENV !== 'production') {
            console.log(`[DEV] OTP for user ${user.id}: ${otp}`);
        }

        res.json({
            message: 'OTP sent successfully',
            user_id: user.id,
            name: user.name,
            role: user.role,
        });
    } catch (error) {
        console.error('Error in verify-uid:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/auth/verify-otp ────────────────────────────────────────────────
// Accepts { user_id, otp }.  Validates OTP and returns a JWT.
router.post('/verify-otp', async (req, res) => {
    try {
        const { user_id, otp } = req.body;

        if (!user_id || !otp) {
            return res.status(400).json({ message: 'user_id and otp are required' });
        }

        const userResult = await pool.query('SELECT * FROM users WHERE id = $1', [user_id]);

        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userResult.rows[0];

        if (!user.otp_code || !user.otp_expires_at) {
            return res.status(400).json({ message: 'No OTP requested. Call /verify-uid first.' });
        }

        if (new Date(user.otp_expires_at) < new Date()) {
            return res.status(400).json({ message: 'OTP has expired. Please request a new one.' });
        }

        if (user.otp_code !== otp.toString()) {
            return res.status(400).json({ message: 'Invalid OTP' });
        }

        // Clear OTP after successful verification
        await pool.query(
            `UPDATE users SET otp_code = NULL, otp_expires_at = NULL,
             otp_attempts = 0, is_verified = TRUE, updated_at = NOW() WHERE id = $1`,
            [user.id]
        );

        const token = signToken(user);

        res.json({
            message: 'Login successful',
            token,
            user: {
                id: user.id,
                uid: user.uid,
                reg_id: user.reg_id,
                name: user.name,
                email: user.email,
                role: user.role,
                department: user.department,
                semester: user.semester,
                profile_image: user.profile_image,
                bio: user.bio,
                is_verified: user.is_verified
            }
        });
    } catch (error) {
        console.error('Error in verify-otp:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/auth/refresh-token ─────────────────────────────────────────────
router.post('/refresh-token', async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) return res.status(400).json({ message: 'Token is required' });

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const userResult = await pool.query(
            'SELECT id, role, name, is_active FROM users WHERE id = $1',
            [decoded.id]
        );

        if (userResult.rows.length === 0 || !userResult.rows[0].is_active) {
            return res.status(401).json({ message: 'User not found or suspended' });
        }

        const newToken = signToken(userResult.rows[0]);
        res.json({ token: newToken });
    } catch (error) {
        res.status(401).json({ message: 'Invalid or expired token' });
    }
});

// ── POST /api/auth/logout ─────────────────────────────────────────────────────
router.post('/logout', (req, res) => {
    // JWT is stateless; client must discard the token.
    res.json({ message: 'Logged out successfully' });
});

// ── POST /api/auth/register ──────────────────────────────────────────────────
// Admin-only endpoint to pre-register users with UID / RegId.
// In production this would be seeded from the college database.
router.post('/register', async (req, res) => {
    try {
        const { uid, reg_id, name, role, department, semester, email, phone } = req.body;

        if (!name || (!uid && !reg_id)) {
            return res.status(400).json({ message: 'name and either uid or reg_id are required' });
        }

        if (role && !['student', 'teacher', 'admin'].includes(role)) {
            return res.status(400).json({ message: 'Invalid role' });
        }

        // Check for duplicates
        if (uid) {
            const existing = await pool.query('SELECT id FROM users WHERE uid = $1', [uid]);
            if (existing.rows.length > 0) {
                return res.status(409).json({ message: 'UID already registered' });
            }
        }
        if (reg_id) {
            const existing = await pool.query('SELECT id FROM users WHERE reg_id = $1', [reg_id]);
            if (existing.rows.length > 0) {
                return res.status(409).json({ message: 'Registration ID already registered' });
            }
        }

        const result = await pool.query(
            `INSERT INTO users (uid, reg_id, name, role, department, semester, email, phone)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             RETURNING id, uid, reg_id, name, role, department, email`,
            [uid || null, reg_id || null, name, role || 'student', department || null,
             semester || null, email || null, phone || null]
        );

        res.status(201).json({
            message: 'User registered successfully',
            user: result.rows[0]
        });
    } catch (error) {
        console.error('Error registering user:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/auth/me ──────────────────────────────────────────────────────────
router.get('/me', require('../middleware/auth'), async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, uid, reg_id, name, email, phone, role, department, semester,
                    profile_image, bio, is_verified, is_active, created_at
             FROM users WHERE id = $1`,
            [req.user.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({ user: result.rows[0] });
    } catch (error) {
        console.error('Error fetching profile:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
