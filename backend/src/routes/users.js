const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

// ── GET /api/users/profile  – own profile ─────────────────────────────────────
router.get('/profile', auth, async (req, res) => {
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

// ── PUT /api/users/profile  – update own profile ──────────────────────────────
router.put('/profile', auth, async (req, res) => {
    try {
        const { name, email, phone, bio, profile_image } = req.body;
        const userId = req.user.id;

        const result = await pool.query(
            `UPDATE users
             SET name          = COALESCE($1, name),
                 email         = COALESCE($2, email),
                 phone         = COALESCE($3, phone),
                 bio           = COALESCE($4, bio),
                 profile_image = COALESCE($5, profile_image),
                 updated_at    = NOW()
             WHERE id = $6
             RETURNING id, reg_no, name, email, phone, role,
                       profile_image, bio, is_verified`,
            [name, email, phone, bio, profile_image, userId]
        );

        res.json({ message: 'Profile updated successfully', user: result.rows[0] });
    } catch (error) {
        console.error('Error updating profile:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/users/teachers  – list all teachers ─────────────────────────────
router.get('/teachers', auth, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, name, email, profile_image, bio
             FROM users WHERE role = 'teacher' AND is_active = TRUE
             ORDER BY name ASC`
        );

        res.json({ teachers: result.rows });
    } catch (error) {
        console.error('Error fetching teachers:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/users/:id  – public profile ─────────────────────────────────────
router.get('/:id', auth, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT id, name, role, profile_image, bio, created_at
             FROM users WHERE id = $1 AND is_active = TRUE`,
            [req.params.id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({ user: result.rows[0] });
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
