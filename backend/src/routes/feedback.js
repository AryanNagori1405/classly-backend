const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

router.use(auth);

// ── POST /api/feedback  – student sends anonymous feedback to teacher ─────────
router.post('/', async (req, res) => {
    try {
        const { teacher_id, category, message } = req.body;
        const senderUserId = req.user.id;

        if (!teacher_id || !message) {
            return res.status(400).json({ message: 'teacher_id and message are required' });
        }

        const validCategories = ['suggestion', 'bug', 'improvement', 'other'];
        const cat = category && validCategories.includes(category) ? category : 'suggestion';

        // Verify teacher exists
        const teacherCheck = await pool.query(
            "SELECT id FROM users WHERE id = $1 AND role = 'teacher' AND is_active = TRUE",
            [teacher_id]
        );
        if (teacherCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Teacher not found' });
        }

        // Capture IP and user-agent for admin fraud-detection
        const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress || null;
        const deviceInfo = req.headers['user-agent'] || null;

        const result = await pool.query(
            `INSERT INTO anonymous_feedback
             (teacher_id, sender_user_id, category, message, ip_address, device_info)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, teacher_id, category, message, created_at`,
            [teacher_id, senderUserId, cat, message, ipAddress, deviceInfo]
        );

        res.status(201).json({
            message: 'Feedback sent anonymously',
            feedback: result.rows[0]
        });
    } catch (error) {
        console.error('Error submitting feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/feedback/received  – teacher views their feedback (no sender) ───
router.get('/received', async (req, res) => {
    try {
        const userId = req.user.id;

        if (req.user.role !== 'teacher') {
            return res.status(403).json({ message: 'Only teachers can access this endpoint' });
        }

        const result = await pool.query(
            `SELECT id, category, message, is_read, teacher_response, created_at
             FROM anonymous_feedback
             WHERE teacher_id = $1
             ORDER BY created_at DESC`,
            [userId]
        );

        // Mark all as read
        await pool.query(
            'UPDATE anonymous_feedback SET is_read = TRUE WHERE teacher_id = $1 AND is_read = FALSE',
            [userId]
        );

        res.json({
            message: 'Feedback retrieved',
            count: result.rows.length,
            feedback: result.rows
        });
    } catch (error) {
        console.error('Error fetching feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/feedback/all  – admin views all feedback WITH real senders ───────
router.get('/all', async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ message: 'Admin access required' });
        }

        const result = await pool.query(
            `SELECT af.id, af.category, af.message, af.ip_address, af.device_info,
                    af.is_read, af.teacher_response, af.created_at,
                    teacher.id   as teacher_id,   teacher.name as teacher_name,
                    sender.id    as sender_id,    sender.name  as sender_name,
                    sender.reg_no as sender_reg_no
             FROM anonymous_feedback af
             JOIN users teacher ON af.teacher_id     = teacher.id
             JOIN users sender  ON af.sender_user_id = sender.id
             ORDER BY af.created_at DESC`
        );

        res.json({
            message: 'All feedback retrieved (admin view with sender info)',
            count: result.rows.length,
            feedback: result.rows
        });
    } catch (error) {
        console.error('Error fetching all feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── PUT /api/feedback/:id/response  – teacher responds to feedback ────────────
router.put('/:id/response', async (req, res) => {
    try {
        const { id } = req.params;
        const { response } = req.body;
        const userId = req.user.id;

        if (req.user.role !== 'teacher') {
            return res.status(403).json({ message: 'Only teachers can respond to feedback' });
        }

        if (!response) {
            return res.status(400).json({ message: 'response is required' });
        }

        const result = await pool.query(
            `UPDATE anonymous_feedback
             SET teacher_response = $1, updated_at = NOW()
             WHERE id = $2 AND teacher_id = $3
             RETURNING id, category, message, teacher_response`,
            [response, id, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Feedback not found or not yours' });
        }

        res.json({ message: 'Response saved', feedback: result.rows[0] });
    } catch (error) {
        console.error('Error responding to feedback:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/feedback/analytics  – teacher analytics ─────────────────────────
router.get('/analytics', async (req, res) => {
    try {
        const userId = req.user.id;

        if (req.user.role !== 'teacher') {
            return res.status(403).json({ message: 'Only teachers can access analytics' });
        }

        const result = await pool.query(
            `SELECT
                COUNT(*)                                        as total,
                COUNT(*) FILTER (WHERE is_read = FALSE)        as unread,
                COUNT(*) FILTER (WHERE category = 'suggestion') as suggestions,
                COUNT(*) FILTER (WHERE category = 'bug')        as bugs,
                COUNT(*) FILTER (WHERE category = 'improvement') as improvements,
                COUNT(*) FILTER (WHERE teacher_response IS NOT NULL) as responded
             FROM anonymous_feedback WHERE teacher_id = $1`,
            [userId]
        );

        res.json({ analytics: result.rows[0] });
    } catch (error) {
        console.error('Error fetching analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
