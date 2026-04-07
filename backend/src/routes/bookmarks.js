const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

// All bookmark routes require authentication
router.use(auth);

// POST /api/bookmarks/:videoId  - Bookmark a video
router.post('/:videoId', async (req, res) => {
    try {
        const { videoId } = req.params;
        const userId = req.user.id;

        // Ensure the video exists and is not deleted
        const videoCheck = await pool.query(
            'SELECT id FROM videos WHERE id = $1 AND is_deleted = FALSE',
            [videoId]
        );
        if (videoCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        await pool.query(
            `INSERT INTO bookmarks (user_id, video_id) VALUES ($1, $2)
             ON CONFLICT (user_id, video_id) DO NOTHING`,
            [userId, videoId]
        );

        res.status(201).json({ message: 'Video bookmarked successfully' });
    } catch (error) {
        console.error('Error bookmarking video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/bookmarks/:videoId  - Remove a bookmark
router.delete('/:videoId', async (req, res) => {
    try {
        const { videoId } = req.params;
        const userId = req.user.id;

        const result = await pool.query(
            'DELETE FROM bookmarks WHERE user_id = $1 AND video_id = $2 RETURNING id',
            [userId, videoId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Bookmark not found' });
        }

        res.json({ message: 'Bookmark removed successfully' });
    } catch (error) {
        console.error('Error removing bookmark:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/bookmarks  - List all bookmarks for the current user
router.get('/', async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT b.created_at as bookmarked_at,
                    v.id, v.title, v.description, v.subject_category,
                    v.thumbnail_url, v.duration, v.file_url, v.views_count,
                    v.created_at, v.expires_at,
                    u.name as teacher_name
             FROM bookmarks b
             JOIN videos v ON b.video_id = v.id
             JOIN users  u ON v.teacher_id = u.id
             WHERE b.user_id = $1 AND v.is_deleted = FALSE
             ORDER BY b.created_at DESC`,
            [userId]
        );

        res.json({
            message: 'Bookmarks retrieved successfully',
            count: result.rows.length,
            bookmarks: result.rows
        });
    } catch (error) {
        console.error('Error fetching bookmarks:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
