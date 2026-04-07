const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const router = express.Router();

function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    if (!token) return res.status(401).json({ message: 'No token provided' });
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ message: 'Invalid token' });
        req.user = user;
        next();
    });
}

function checkAdmin(req, res, next) {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Admin access required' });
    }
    next();
}

// GET /api/admin/users - List all users
router.get('/users', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { role, status } = req.query;
        let query = 'SELECT id, name, email, role, is_active, created_at FROM users';
        let params = [];

        if (role) {
            query += ` WHERE role = $${params.length + 1}`;
            params.push(role);
        }

        query += ' ORDER BY created_at DESC';

        const result = await pool.query(query, params);
        res.json({
            message: 'Users retrieved',
            count: result.rows.length,
            users: result.rows
        });
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/admin/users/:userId - Suspend/ban user
router.patch('/users/:userId', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { is_active, reason } = req.body;

        const result = await pool.query(
            `UPDATE users SET is_active = $1, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2 RETURNING id, name, email, role, is_active`,
            [is_active, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.json({
            message: `User ${is_active ? 'activated' : 'suspended'}`,
            user: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/admin/videos - List all videos
router.get('/videos', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT v.*, u.name as teacher_name
             FROM videos v
             JOIN users u ON v.teacher_id = u.id
             WHERE v.is_deleted = FALSE
             ORDER BY v.created_at DESC`
        );

        res.json({
            message: 'Videos retrieved',
            count: result.rows.length,
            videos: result.rows
        });
    } catch (error) {
        console.error('Error fetching videos:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/admin/reports - Platform reports
router.get('/reports', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const usersReport = await pool.query(
            `SELECT role, COUNT(*) as count FROM users GROUP BY role`
        );

        const videosReport = await pool.query(
            `SELECT COUNT(*) as total, COALESCE(SUM(views_count), 0) as views
             FROM videos WHERE is_deleted = false`
        );

        const feedbackReport = await pool.query(
            `SELECT COUNT(*) as total FROM anonymous_feedback`
        );

        const communitiesReport = await pool.query(
            `SELECT COUNT(*) as total FROM communities WHERE is_disabled = FALSE`
        );

        res.json({
            message: 'Reports generated',
            users_by_role: usersReport.rows,
            videos: videosReport.rows[0],
            feedback: feedbackReport.rows[0],
            communities: communitiesReport.rows[0]
        });
    } catch (error) {
        console.error('Error generating reports:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;