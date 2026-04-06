const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// ── helpers ──────────────────────────────────────────────────────────────────

/** Return a JWT containing id, role and name */
function signToken(user) {
    return jwt.sign(
        { id: user.id, role: user.role, name: user.name },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
}

/** Format user object for API responses */
function formatUser(user) {
    return {
        id: user.id,
        reg_no: user.reg_no,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profile_image: user.profile_image,
        bio: user.bio,
        is_verified: user.is_verified
    };
}

// ── POST /api/auth/register ──────────────────────────────────────────────────
// Public endpoint: register a new student or teacher account.
router.post('/register', async (req, res) => {
    try {
        const { name, email, phone, reg_no, password, role } = req.body;

        if (!name || !email || !phone || !reg_no || !password) {
            return res.status(400).json({ message: 'name, email, phone, reg_no and password are required' });
        }

        if (password.length < 6) {
            return res.status(400).json({ message: 'Password must be at least 6 characters' });
        }

        const allowedRoles = ['student', 'teacher'];
        if (role && !allowedRoles.includes(role)) {
            return res.status(400).json({ message: 'Role must be student or teacher' });
        }

        // Check for duplicate reg_no
        const existingRegNo = await pool.query('SELECT id FROM users WHERE reg_no = $1', [reg_no]);
        if (existingRegNo.rows.length > 0) {
            return res.status(409).json({ message: 'Registration number already registered' });
        }

        // Check for duplicate email
        const existingEmail = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existingEmail.rows.length > 0) {
            return res.status(409).json({ message: 'Email already registered' });
        }

        const password_hash = await bcrypt.hash(password, 10);

        const result = await pool.query(
            `INSERT INTO users (reg_no, name, email, phone, role, password_hash, is_verified, is_active)
             VALUES ($1, $2, $3, $4, $5, $6, TRUE, TRUE)
             RETURNING id, reg_no, name, email, phone, role`,
            [reg_no, name, email, phone, role || 'student', password_hash]
        );

        res.status(201).json({
            message: 'Registration successful',
            user: result.rows[0]
        });
    } catch (error) {
        console.error('Error in register:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/auth/login ──────────────────────────────────────────────────────
// Accepts { reg_no, password }.  Returns a JWT on success.
router.post('/login', async (req, res) => {
    try {
        const { reg_no, password } = req.body;

        if (!reg_no || !password) {
            return res.status(400).json({ message: 'reg_no and password are required' });
        }

        const userResult = await pool.query('SELECT * FROM users WHERE reg_no = $1', [reg_no]);

        if (userResult.rows.length === 0) {
            return res.status(401).json({ message: 'Invalid registration number or password' });
        }

        const user = userResult.rows[0];

        if (!user.is_active) {
            return res.status(403).json({ message: 'Your account has been suspended.' });
        }

        if (!user.password_hash) {
            return res.status(401).json({ message: 'Account has no password set. Contact administrator.' });
        }

        const passwordValid = await bcrypt.compare(password, user.password_hash);
        if (!passwordValid) {
            return res.status(401).json({ message: 'Invalid registration number or password' });
        }

        const token = signToken(user);

        res.json({
            message: 'Login successful',
            token,
            user: formatUser(user)
        });
    } catch (error) {
        console.error('Error in login:', error);
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

// ── GET /api/auth/me ──────────────────────────────────────────────────────────
router.get('/me', require('../middleware/auth'), async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, reg_no, name, email, phone, role,
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
