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

// POST /api/notifications - Send notification
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { recipient_id, type, title, message, related_id } = req.body;

        if (!recipient_id || !title || !message) {
            return res.status(400).json({ message: 'recipient_id, title, message are required' });
        }

        const result = await pool.query(
            `INSERT INTO notifications (recipient_id, type, title, message, related_id, is_read, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
             RETURNING *`,
            [recipient_id, type || 'general', title, message, related_id || null, false]
        );

        res.status(201).json({
            message: 'Notification sent',
            notification: result.rows[0]
        });
    } catch (error) {
        console.error('Error sending notification:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/notifications - Get user notifications
router.get('/', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;
        const { limit = 20, offset = 0 } = req.query;

        const result = await pool.query(
            `SELECT * FROM notifications WHERE recipient_id = $1
             ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
            [userId, limit, offset]
        );

        const countResult = await pool.query(
            `SELECT COUNT(*) as total FROM notifications WHERE recipient_id = $1`,
            [userId]
        );

        res.json({
            message: 'Notifications retrieved',
            count: result.rows.length,
            total: parseInt(countResult.rows[0].total),
            notifications: result.rows
        });
    } catch (error) {
        console.error('Error fetching notifications:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/notifications/unread-count
router.get('/unread-count', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT COUNT(*) as unread_count FROM notifications
             WHERE recipient_id = $1 AND is_read = false`,
            [userId]
        );

        res.json({
            unread_count: parseInt(result.rows[0].unread_count)
        });
    } catch (error) {
        console.error('Error fetching unread count:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/notifications/:id/read - Mark as read
router.patch('/:id/read', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const result = await pool.query(
            `UPDATE notifications SET is_read = true, read_at = CURRENT_TIMESTAMP
             WHERE id = $1 AND recipient_id = $2 RETURNING *`,
            [id, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        res.json({
            message: 'Notification marked as read',
            notification: result.rows[0]
        });
    } catch (error) {
        console.error('Error marking notification as read:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/notifications/:id - Delete notification
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        await pool.query(
            'DELETE FROM notifications WHERE id = $1 AND recipient_id = $2',
            [id, userId]
        );

        res.json({ message: 'Notification deleted' });
    } catch (error) {
        console.error('Error deleting notification:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;