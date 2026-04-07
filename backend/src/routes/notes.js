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

// Helper: Validate file type
function validateFileType(fileName) {
    const allowedTypes = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt'];
    const fileExtension = fileName.split('.').pop().toLowerCase();
    return allowedTypes.includes(fileExtension);
}

// POST /api/videos/:videoId/notes - Teacher uploads note
router.post('/video/:videoId/notes', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const { note_title, file_url, file_type } = req.body;
        const uploadedBy = req.user.id;

        // Validate required fields
        if (!note_title || !file_url) {
            return res.status(400).json({ message: 'Note title and file_url are required' });
        }

        // Check if video exists
        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        const video = videoResult.rows[0];

        // Check if user is the teacher
        if (video.teacher_id !== uploadedBy) {
            return res.status(403).json({ message: 'Only the teacher can upload notes for this video' });
        }

        // Insert note
        const result = await pool.query(
            `INSERT INTO video_notes (video_id, note_title, file_url, file_type, uploaded_by, created_at)
             VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
             RETURNING *`,
            [videoId, note_title, file_url, file_type || 'pdf', uploadedBy]
        );

        res.status(201).json({
            message: 'Note uploaded successfully',
            note: result.rows[0]
        });
    } catch (error) {
        console.error('Error uploading note:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/:videoId/notes - Get all notes for video
router.get('/video/:videoId/notes', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const { filter } = req.query;

        // Check if video exists
        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        let query = `
            SELECT vn.*, u.name as uploaded_by_name, u.email
            FROM video_notes vn
            JOIN users u ON vn.uploaded_by = u.id
            WHERE vn.video_id = $1
        `;

        let params = [videoId];

        query += ` ORDER BY vn.created_at DESC`;

        const result = await pool.query(query, params);

        res.json({
            message: 'Notes retrieved successfully',
            count: result.rows.length,
            notes: result.rows
        });
    } catch (error) {
        console.error('Error fetching notes:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/notes/:noteId - Get specific note details
router.get('/:noteId', authenticateToken, async (req, res) => {
    try {
        const { noteId } = req.params;

        const result = await pool.query(
            `SELECT vn.*, u.name as uploaded_by_name, u.email, v.title as video_title
             FROM video_notes vn
             JOIN users u ON vn.uploaded_by = u.id
             JOIN videos v ON vn.video_id = v.id
             WHERE vn.id = $1`,
            [noteId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Note not found' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching note:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/notes/:noteId/suggest - Student suggests note
router.post('/:noteId/suggest', authenticateToken, async (req, res) => {
    try {
        const { noteId } = req.params;
        const { note_title, file_url, file_type, description } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!note_title || !file_url) {
            return res.status(400).json({ message: 'Note title and file_url are required' });
        }

        // Get original note to find video
        const originalNoteResult = await pool.query(
            'SELECT * FROM video_notes WHERE id = $1',
            [noteId]
        );

        if (originalNoteResult.rows.length === 0) {
            return res.status(404).json({ message: 'Original note not found' });
        }

        const videoId = originalNoteResult.rows[0].video_id;

        // Insert suggested note
        const result = await pool.query(
            `INSERT INTO video_notes (video_id, note_title, file_url, file_type, uploaded_by, created_at)
             VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
             RETURNING *`,
            [videoId, note_title, file_url, file_type || 'pdf', userId]
        );

        res.status(201).json({
            message: 'Note uploaded successfully.',
            note: result.rows[0]
        });
    } catch (error) {
        console.error('Error suggesting note:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/notes/:noteId - Delete note (teacher only)
router.delete('/:noteId', authenticateToken, async (req, res) => {
    try {
        const { noteId } = req.params;
        const userId = req.user.id;

        // Get note
        const noteResult = await pool.query(
            `SELECT vn.*, v.teacher_id
             FROM video_notes vn
             JOIN videos v ON vn.video_id = v.id
             WHERE vn.id = $1`,
            [noteId]
        );

        if (noteResult.rows.length === 0) {
            return res.status(404).json({ message: 'Note not found' });
        }

        const note = noteResult.rows[0];

        // Check if user is teacher
        if (note.teacher_id !== userId) {
            return res.status(403).json({ message: 'Only the teacher can delete notes' });
        }

        // Delete note
        await pool.query(
            'DELETE FROM video_notes WHERE id = $1',
            [noteId]
        );

        res.json({ message: 'Note deleted successfully' });
    } catch (error) {
        console.error('Error deleting note:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;