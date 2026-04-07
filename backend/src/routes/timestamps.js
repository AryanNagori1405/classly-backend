const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const router = express.Router();

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
}

// Helper: Validate timestamp format (MM:SS)
function validateTimestampFormat(timestamp) {
    const regex = /^(\d{1,2}):(\d{2})$/;
    return regex.test(timestamp);
}

// POST /api/videos/:videoId/timestamps - Add doubt at timestamp
router.post('/video/:videoId/timestamps', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const { timestamp_value, question_text } = req.body;
        const studentId = req.user.id;

        // Validate required fields
        if (!timestamp_value || !question_text) {
            return res.status(400).json({ message: 'Timestamp and question are required' });
        }

        // Validate timestamp format
        if (!validateTimestampFormat(timestamp_value)) {
            return res.status(400).json({ message: 'Invalid timestamp format. Use MM:SS' });
        }

        // Check if video exists
        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        // Insert timestamp doubt
        const result = await pool.query(
            `INSERT INTO video_timestamps (video_id, student_id, timestamp_value, question_text, is_resolved, created_at)
             VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
             RETURNING *`,
            [videoId, studentId, timestamp_value, question_text, false]
        );

        res.status(201).json({
            message: 'Doubt added successfully',
            timestamp: result.rows[0]
        });
    } catch (error) {
        console.error('Error adding doubt:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/:videoId/timestamps - Get all doubts for video
router.get('/video/:videoId/timestamps', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const { sortBy } = req.query;

        // Check if video exists
        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        let query = `
            SELECT vt.*, u.name as student_name, u.email,
                   COUNT(tc.id) as comment_count
            FROM video_timestamps vt
            JOIN users u ON vt.student_id = u.id
            LEFT JOIN timestamp_comments tc ON vt.id = tc.timestamp_id AND tc.is_deleted = false
            WHERE vt.video_id = $1
            GROUP BY vt.id, u.id
        `;

        // Sort by
        if (sortBy === 'newest') {
            query += ` ORDER BY vt.created_at DESC`;
        } else if (sortBy === 'oldest') {
            query += ` ORDER BY vt.created_at ASC`;
        } else if (sortBy === 'most_commented') {
            query += ` ORDER BY comment_count DESC`;
        } else if (sortBy === 'unresolved') {
            query += ` AND vt.is_resolved = false ORDER BY vt.created_at DESC`;
        } else {
            query += ` ORDER BY vt.created_at DESC`;
        }

        const result = await pool.query(query, [videoId]);

        res.json({
            message: 'Timestamps retrieved successfully',
            count: result.rows.length,
            timestamps: result.rows
        });
    } catch (error) {
        console.error('Error fetching timestamps:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/timestamps/:timestampId - Get specific timestamp with comments
router.get('/:timestampId', authenticateToken, async (req, res) => {
    try {
        const { timestampId } = req.params;

        // Get timestamp
        const timestampResult = await pool.query(
            `SELECT vt.*, u.name as student_name, u.email, v.title as video_title
             FROM video_timestamps vt
             JOIN users u ON vt.student_id = u.id
             JOIN videos v ON vt.video_id = v.id
             WHERE vt.id = $1`,
            [timestampId]
        );

        if (timestampResult.rows.length === 0) {
            return res.status(404).json({ message: 'Timestamp not found' });
        }

        const timestamp = timestampResult.rows[0];

        // Get all comments for this timestamp
        const commentsResult = await pool.query(
            `SELECT tc.*, u.name, u.email
             FROM timestamp_comments tc
             JOIN users u ON tc.user_id = u.id
             WHERE tc.timestamp_id = $1 AND tc.is_deleted = false
             ORDER BY tc.created_at ASC`,
            [timestampId]
        );

        res.json({
            ...timestamp,
            comments: commentsResult.rows
        });
    } catch (error) {
        console.error('Error fetching timestamp:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/timestamps/:timestampId/comments - Add comment to doubt
router.post('/:timestampId/comments', authenticateToken, async (req, res) => {
    try {
        const { timestampId } = req.params;
        const { comment_text, is_anonymous } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!comment_text) {
            return res.status(400).json({ message: 'Comment text is required' });
        }

        // Check if timestamp exists
        const timestampResult = await pool.query(
            'SELECT * FROM video_timestamps WHERE id = $1',
            [timestampId]
        );

        if (timestampResult.rows.length === 0) {
            return res.status(404).json({ message: 'Timestamp not found' });
        }

        // Insert comment
        const result = await pool.query(
            `INSERT INTO timestamp_comments (timestamp_id, user_id, comment_text, is_deleted, created_at)
             VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
             RETURNING *`,
            [timestampId, userId, comment_text, false]
        );

        res.status(201).json({
            message: 'Comment added successfully',
            comment: result.rows[0]
        });
    } catch (error) {
        console.error('Error adding comment:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/timestamps/:timestampId/comments - Get comments for timestamp
router.get('/:timestampId/comments', authenticateToken, async (req, res) => {
    try {
        const { timestampId } = req.params;

        const result = await pool.query(
            `SELECT tc.*, u.name as user_name, u.email as user_email
             FROM timestamp_comments tc
             LEFT JOIN users u ON tc.user_id = u.id
             WHERE tc.timestamp_id = $1 AND tc.is_deleted = false
             ORDER BY tc.created_at ASC`,
            [timestampId]
        );

        res.json({
            message: 'Comments retrieved successfully',
            count: result.rows.length,
            comments: result.rows
        });
    } catch (error) {
        console.error('Error fetching comments:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/timestamps/:timestampId/resolve - Mark doubt as resolved (teacher only)
router.patch('/:timestampId/resolve', authenticateToken, async (req, res) => {
    try {
        const { timestampId } = req.params;
        const userId = req.user.id;

        // Get timestamp
        const timestampResult = await pool.query(
            `SELECT vt.*, v.teacher_id
             FROM video_timestamps vt
             JOIN videos v ON vt.video_id = v.id
             WHERE vt.id = $1`,
            [timestampId]
        );

        if (timestampResult.rows.length === 0) {
            return res.status(404).json({ message: 'Timestamp not found' });
        }

        // Check if user is teacher
        if (timestampResult.rows[0].teacher_id !== userId) {
            return res.status(403).json({ message: 'Only teacher can mark doubts as resolved' });
        }

        // Update resolved status
        const result = await pool.query(
            `UPDATE video_timestamps 
             SET is_resolved = NOT is_resolved, updated_at = CURRENT_TIMESTAMP
             WHERE id = $1
             RETURNING *`,
            [timestampId]
        );

        res.json({
            message: `Doubt ${result.rows[0].is_resolved ? 'marked as resolved' : 'marked as unresolved'}`,
            timestamp: result.rows[0]
        });
    } catch (error) {
        console.error('Error resolving doubt:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/timestamps/:timestampId/comments/:commentId - Delete comment
router.delete('/:timestampId/comments/:commentId', authenticateToken, async (req, res) => {
    try {
        const { commentId } = req.params;
        const userId = req.user.id;

        // Get comment
        const commentResult = await pool.query(
            'SELECT * FROM timestamp_comments WHERE id = $1',
            [commentId]
        );

        if (commentResult.rows.length === 0) {
            return res.status(404).json({ message: 'Comment not found' });
        }

        // Check if user is comment author
        if (commentResult.rows[0].user_id !== userId) {
            return res.status(403).json({ message: 'You can only delete your own comments' });
        }

        // Soft delete comment
        await pool.query(
            'UPDATE timestamp_comments SET is_deleted = true WHERE id = $1',
            [commentId]
        );

        res.json({ message: 'Comment deleted successfully' });
    } catch (error) {
        console.error('Error deleting comment:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/:videoId/faq - Auto-compiled FAQ
router.get('/video/:videoId/faq', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;

        // Get most common questions (resolved with multiple comments)
        const result = await pool.query(
            `SELECT vt.id, vt.timestamp_value, vt.question_text,
                    COUNT(tc.id) as comment_count,
                    array_agg(tc.comment_text) as answers
             FROM video_timestamps vt
             LEFT JOIN timestamp_comments tc ON vt.id = tc.timestamp_id AND tc.is_deleted = false
             WHERE vt.video_id = $1 AND vt.is_resolved = true
             GROUP BY vt.id
             HAVING COUNT(tc.id) > 0
             ORDER BY comment_count DESC
             LIMIT 10`,
            [videoId]
        );

        res.json({
            message: 'FAQ generated successfully',
            count: result.rows.length,
            faq: result.rows
        });
    } catch (error) {
        console.error('Error generating FAQ:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PUT /api/timestamps/:timestampId/response - Teacher adds official response to a doubt
router.put('/:timestampId/response', authenticateToken, async (req, res) => {
    try {
        const { timestampId } = req.params;
        const { teacher_response } = req.body;
        const userId = req.user.id;

        if (!teacher_response) {
            return res.status(400).json({ message: 'teacher_response is required' });
        }

        const timestampResult = await pool.query(
            `SELECT vt.*, v.teacher_id
             FROM video_timestamps vt
             JOIN videos v ON vt.video_id = v.id
             WHERE vt.id = $1`,
            [timestampId]
        );

        if (timestampResult.rows.length === 0) {
            return res.status(404).json({ message: 'Timestamp not found' });
        }

        if (timestampResult.rows[0].teacher_id !== userId) {
            return res.status(403).json({ message: 'Only the teacher of this video can respond' });
        }

        const result = await pool.query(
            `UPDATE video_timestamps
             SET teacher_response = $1, is_resolved = TRUE,
                 resolved_by = $2, updated_at = CURRENT_TIMESTAMP
             WHERE id = $3
             RETURNING *`,
            [teacher_response, userId, timestampId]
        );

        res.json({ message: 'Teacher response saved', timestamp: result.rows[0] });
    } catch (error) {
        console.error('Error saving teacher response:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;