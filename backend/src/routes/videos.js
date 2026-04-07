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

// Helper: Check if teacher owns the video
async function validateVideoOwnership(videoId, userId) {
    try {
        const result = await pool.query(
            'SELECT * FROM videos WHERE id = $1 AND teacher_id = $2',
            [videoId, userId]
        );
        return result.rows.length > 0;
    } catch (error) {
        console.error('Error validating video ownership:', error);
        throw error;
    }
}

// POST /api/videos - Teacher uploads video
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { title, description, file_url, thumbnail_url, duration,
                file_size, subject, category } = req.body;
        const teacherId = req.user.id;

        // Validate required fields
        if (!title || !file_url) {
            return res.status(400).json({ message: 'Title and file_url are required' });
        }

        // Insert video
        const result = await pool.query(
            `INSERT INTO videos (teacher_id, title, description, file_url,
                thumbnail_url, duration, file_size, subject, category,
                is_public, is_deleted, created_at, updated_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
                     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
             RETURNING *`,
            [teacherId, title, description || null, file_url,
             thumbnail_url || null, duration || null, file_size || null,
             subject || null, category || null, true, false]
        );

        res.status(201).json({
            message: 'Video uploaded successfully',
            video: result.rows[0]
        });
    } catch (error) {
        console.error('Error uploading video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos - List all videos with filters
router.get('/', authenticateToken, async (req, res) => {
    try {
        const { subject, category, teacher, search, sortBy } = req.query;
        let query = `SELECT * FROM videos WHERE is_public = true AND is_deleted = false AND created_at > NOW() - INTERVAL '7 days'`;
        let params = [];

        // Filter by category
        if (category || subject) {
            query += ` AND category = $${params.length + 1}`;
            params.push(category || subject);
        }

        // Filter by teacher
        if (teacher) {
            query += ` AND teacher_id = $${params.length + 1}`;
            params.push(teacher);
        }

        // Search by title or description
        if (search) {
            query += ` AND (title ILIKE $${params.length + 1} OR description ILIKE $${params.length + 1})`;
            params.push(`%${search}%`);
        }

        // Sort by
        if (sortBy === 'newest') {
            query += ` ORDER BY created_at DESC`;
        } else if (sortBy === 'views') {
            query += ` ORDER BY views_count DESC`;
        } else if (sortBy === 'trending') {
            query += ` ORDER BY upvotes DESC`;
        } else {
            query += ` ORDER BY created_at DESC`;
        }

        const result = await pool.query(query, params);

        res.json({
            message: 'Videos retrieved successfully',
            count: result.rows.length,
            videos: result.rows
        });
    } catch (error) {
        console.error('Error fetching videos:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/:videoId - Get video details
router.get('/:videoId', authenticateToken, async (req, res) => {
    try {
        const videoId = req.params.videoId;
        const userId = req.user.id;

        const result = await pool.query(
            'SELECT * FROM videos WHERE id = $1 AND is_deleted = false',
            [videoId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        // Update views count
        await pool.query(
            'UPDATE videos SET views_count = views_count + 1 WHERE id = $1',
            [videoId]
        );

        // Track watch history
        await pool.query(
            `INSERT INTO student_watch_history (user_id, video_id, watched_at)
             VALUES ($1, $2, CURRENT_TIMESTAMP)
             ON CONFLICT DO NOTHING`,
            [userId, videoId]
        );

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/videos/:videoId - Update video metadata
router.patch('/:videoId', authenticateToken, async (req, res) => {
    try {
        const videoId = req.params.videoId;
        const userId = req.user.id;
        const { title, description, thumbnail_url } = req.body;

        // Verify ownership
        const isOwner = await validateVideoOwnership(videoId, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only update your own videos' });
        }

        const result = await pool.query(
            `UPDATE videos 
             SET title = COALESCE($1, title), 
                 description = COALESCE($2, description),
                 thumbnail_url = COALESCE($3, thumbnail_url),
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $4
             RETURNING *`,
            [title, description, thumbnail_url, videoId]
        );

        res.json({
            message: 'Video updated successfully',
            video: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/videos/:videoId/download - Download video
router.post('/:videoId/download', authenticateToken, async (req, res) => {
    try {
        const videoId = req.params.videoId;
        const userId = req.user.id;

        // Check if video exists
        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1 AND is_deleted = false',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        // Track download
        await pool.query(
            `INSERT INTO video_downloads (video_id, user_id, downloaded_at)
             VALUES ($1, $2, CURRENT_TIMESTAMP)`,
            [videoId, userId]
        );

        // Increment download count
        await pool.query(
            'UPDATE videos SET downloads_count = downloads_count + 1 WHERE id = $1',
            [videoId]
        );

        res.json({
            message: 'Download tracked successfully',
            download_link: videoResult.rows[0].file_url
        });
    } catch (error) {
        console.error('Error tracking download:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/videos/:videoId/pin - Pin video (teacher only)
router.post('/:videoId/pin', authenticateToken, async (req, res) => {
    try {
        const videoId = req.params.videoId;
        const userId = req.user.id;

        // Verify ownership
        const isOwner = await validateVideoOwnership(videoId, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only pin your own videos' });
        }

        const result = await pool.query(
            `UPDATE videos SET is_pinned = NOT is_pinned WHERE id = $1 RETURNING *`,
            [videoId]
        );

        res.json({
            message: `Video ${result.rows[0].is_pinned ? 'pinned' : 'unpinned'} successfully`,
            video: result.rows[0]
        });
    } catch (error) {
        console.error('Error pinning video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/expiring/soon - Videos expiring in 48 hours
router.get('/expiring/soon', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM videos 
             WHERE is_public = true 
             AND is_deleted = false
             AND created_at <= NOW() - INTERVAL '5 days'
             AND created_at > NOW() - INTERVAL '7 days'
             ORDER BY created_at ASC`
        );

        res.json({
            message: 'Videos expiring soon',
            count: result.rows.length,
            videos: result.rows
        });
    } catch (error) {
        console.error('Error fetching expiring videos:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/videos/:videoId/upvote - Upvote video
router.post('/:videoId/upvote', authenticateToken, async (req, res) => {
    try {
        const videoId = req.params.videoId;

        // Check if already upvoted
        const checkResult = await pool.query(
            'SELECT * FROM video_engagement WHERE video_id = $1 AND user_id = $2 AND type = $3',
            [videoId, req.user.id, 'upvote']
        );

        if (checkResult.rows.length > 0) {
            return res.status(400).json({ message: 'You already upvoted this video' });
        }

        // Insert upvote
        await pool.query(
            `INSERT INTO video_engagement (video_id, user_id, type, created_at)
             VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
            [videoId, req.user.id, 'upvote']
        );

        // Update upvotes count
        await pool.query(
            'UPDATE videos SET upvotes = upvotes + 1 WHERE id = $1',
            [videoId]
        );

        res.json({ message: 'Video upvoted successfully' });
    } catch (error) {
        console.error('Error upvoting video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/videos/:videoId - Soft-delete a video (teacher only)
router.delete('/:videoId', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const userId = req.user.id;

        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1 AND is_deleted = FALSE',
            [videoId]
        );
        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        const video = videoResult.rows[0];
        const isOwner = video.teacher_id === userId;
        const isAdmin = req.user.role === 'admin';
        if (!isOwner && !isAdmin) {
            return res.status(403).json({ message: 'You can only delete your own videos' });
        }

        await pool.query(
            `UPDATE videos SET is_deleted = TRUE,
             updated_at = CURRENT_TIMESTAMP WHERE id = $1`,
            [videoId]
        );

        res.json({ message: 'Video deleted successfully' });
    } catch (error) {
        console.error('Error deleting video:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PUT /api/videos/:videoId/watch-progress - Update watch position (resume support)
router.put('/:videoId/watch-progress', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;
        const { last_watch_time } = req.body;
        const userId = req.user.id;

        if (last_watch_time === undefined || last_watch_time === null) {
            return res.status(400).json({ message: 'last_watch_time is required' });
        }

        await pool.query(
            `INSERT INTO student_watch_history (user_id, video_id, last_watch_time, watched_at)
             VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
             ON CONFLICT (user_id, video_id)
             DO UPDATE SET last_watch_time = $3, watched_at = CURRENT_TIMESTAMP`,
            [userId, videoId, last_watch_time]
        );

        res.json({ message: 'Watch progress saved' });
    } catch (error) {
        console.error('Error saving watch progress:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/videos/watch-history/me - Get current user's watch history
router.get('/watch-history/me', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const result = await pool.query(
            `SELECT swh.*, v.title, v.thumbnail_url, v.duration, v.expires_at,
                    u.name as teacher_name
             FROM student_watch_history swh
             JOIN videos v ON swh.video_id = v.id
             JOIN users u ON v.teacher_id = u.id
             WHERE swh.user_id = $1 AND v.is_deleted = FALSE
             ORDER BY swh.watched_at DESC`,
            [userId]
        );

        res.json({ count: result.rows.length, history: result.rows });
    } catch (error) {
        console.error('Error fetching watch history:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;