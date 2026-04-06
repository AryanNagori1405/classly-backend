const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

router.use(auth);

// ── POST /api/contributions  – student uploads a contribution ─────────────────
router.post('/', async (req, res) => {
    try {
        const { title, description, file_url, file_type, related_video_id } = req.body;
        const studentId = req.user.id;

        if (!title || !file_url) {
            return res.status(400).json({ message: 'title and file_url are required' });
        }

        // Verify the related video exists (if provided)
        if (related_video_id) {
            const videoCheck = await pool.query(
                'SELECT id FROM videos WHERE id = $1 AND is_deleted = FALSE',
                [related_video_id]
            );
            if (videoCheck.rows.length === 0) {
                return res.status(404).json({ message: 'Related video not found' });
            }
        }

        const result = await pool.query(
            `INSERT INTO student_contributions
             (student_id, related_video_id, title, description, file_url, file_type)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING *`,
            [studentId, related_video_id || null, title, description || null,
             file_url, file_type || 'video']
        );

        res.status(201).json({
            message: 'Contribution uploaded successfully',
            contribution: result.rows[0]
        });
    } catch (error) {
        console.error('Error uploading contribution:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/contributions  – browse approved contributions ──────────────────
router.get('/', async (req, res) => {
    try {
        const { related_video_id, search } = req.query;
        let query = `
            SELECT sc.*, u.name as student_name, u.profile_image as student_image,
                   v.title as related_video_title
            FROM student_contributions sc
            JOIN users u ON sc.student_id = u.id
            LEFT JOIN videos v ON sc.related_video_id = v.id
            WHERE sc.is_deleted = FALSE AND sc.is_approved = TRUE`;
        const params = [];

        if (related_video_id) {
            params.push(related_video_id);
            query += ` AND sc.related_video_id = $${params.length}`;
        }
        if (search) {
            params.push(`%${search}%`);
            query += ` AND (sc.title ILIKE $${params.length} OR sc.description ILIKE $${params.length})`;
        }
        query += ' ORDER BY sc.created_at DESC';

        const result = await pool.query(query, params);
        res.json({ count: result.rows.length, contributions: result.rows });
    } catch (error) {
        console.error('Error fetching contributions:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/contributions/my  – current user's own contributions ────────────
router.get('/my', async (req, res) => {
    try {
        const studentId = req.user.id;
        const result = await pool.query(
            `SELECT sc.*, v.title as related_video_title
             FROM student_contributions sc
             LEFT JOIN videos v ON sc.related_video_id = v.id
             WHERE sc.student_id = $1 AND sc.is_deleted = FALSE
             ORDER BY sc.created_at DESC`,
            [studentId]
        );
        res.json({ count: result.rows.length, contributions: result.rows });
    } catch (error) {
        console.error('Error fetching my contributions:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/contributions/:id  – contribution detail ────────────────────────
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            `SELECT sc.*, u.name as student_name, u.profile_image as student_image,
                    v.title as related_video_title
             FROM student_contributions sc
             JOIN users u ON sc.student_id = u.id
             LEFT JOIN videos v ON sc.related_video_id = v.id
             WHERE sc.id = $1 AND sc.is_deleted = FALSE`,
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Contribution not found' });
        }

        // Increment view count
        await pool.query(
            'UPDATE student_contributions SET views_count = views_count + 1 WHERE id = $1',
            [id]
        );

        res.json({ contribution: result.rows[0] });
    } catch (error) {
        console.error('Error fetching contribution:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/contributions/:id/upvote  – upvote a contribution ──────────────
router.post('/:id/upvote', async (req, res) => {
    try {
        const { id } = req.params;

        const check = await pool.query(
            'SELECT id FROM student_contributions WHERE id = $1 AND is_deleted = FALSE',
            [id]
        );
        if (check.rows.length === 0) {
            return res.status(404).json({ message: 'Contribution not found' });
        }

        await pool.query(
            'UPDATE student_contributions SET upvotes = upvotes + 1 WHERE id = $1',
            [id]
        );

        res.json({ message: 'Upvoted successfully' });
    } catch (error) {
        console.error('Error upvoting contribution:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── DELETE /api/contributions/:id  – delete own contribution ─────────────────
router.delete('/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const check = await pool.query(
            'SELECT student_id FROM student_contributions WHERE id = $1 AND is_deleted = FALSE',
            [id]
        );
        if (check.rows.length === 0) {
            return res.status(404).json({ message: 'Contribution not found' });
        }

        const isOwner = check.rows[0].student_id === userId;
        const isAdmin = req.user.role === 'admin';
        if (!isOwner && !isAdmin) {
            return res.status(403).json({ message: 'Not authorized to delete this contribution' });
        }

        await pool.query(
            `UPDATE student_contributions SET is_deleted = TRUE, updated_at = CURRENT_TIMESTAMP
             WHERE id = $1`,
            [id]
        );

        res.json({ message: 'Contribution deleted successfully' });
    } catch (error) {
        console.error('Error deleting contribution:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── PUT /api/contributions/:id/approve  – admin/teacher moderates ─────────────
router.put('/:id/approve', async (req, res) => {
    try {
        const { id } = req.params;
        const { is_approved } = req.body;

        if (req.user.role !== 'admin' && req.user.role !== 'teacher') {
            return res.status(403).json({ message: 'Only admins and teachers can moderate contributions' });
        }

        await pool.query(
            `UPDATE student_contributions SET is_approved = $1, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2`,
            [is_approved !== false, id]
        );

        res.json({ message: `Contribution ${is_approved !== false ? 'approved' : 'rejected'}` });
    } catch (error) {
        console.error('Error moderating contribution:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
