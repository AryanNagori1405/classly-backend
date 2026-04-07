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

// Teacher dashboard analytics
router.get('/teacher', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Total videos and views
        const videosResult = await pool.query(
            `SELECT COUNT(*) as total_videos, COALESCE(SUM(views_count), 0) as total_views,
                    COALESCE(SUM(upvotes), 0) as total_upvotes
             FROM videos WHERE teacher_id = $1 AND is_deleted = false`,
            [userId]
        );

        // Total downloads from video_downloads table
        const downloadsResult = await pool.query(
            `SELECT COUNT(*) as total_downloads
             FROM video_downloads vd
             JOIN videos v ON vd.video_id = v.id
             WHERE v.teacher_id = $1`,
            [userId]
        );

        // Feedback count
        const feedbackResult = await pool.query(
            `SELECT COUNT(*) as total_feedback
             FROM anonymous_feedback WHERE teacher_id = $1`,
            [userId]
        );

        // Recent videos
        const recentVideosResult = await pool.query(
            `SELECT id, title, views_count, upvotes, created_at
             FROM videos WHERE teacher_id = $1 AND is_deleted = false
             ORDER BY created_at DESC LIMIT 5`,
            [userId]
        );

        res.json({
            message: 'Teacher analytics retrieved',
            summary: {
                total_videos: parseInt(videosResult.rows[0].total_videos),
                total_views: parseInt(videosResult.rows[0].total_views) || 0,
                total_upvotes: parseInt(videosResult.rows[0].total_upvotes) || 0,
                total_downloads: parseInt(downloadsResult.rows[0].total_downloads) || 0,
                total_feedback: parseInt(feedbackResult.rows[0].total_feedback) || 0
            },
            recent_videos: recentVideosResult.rows
        });
    } catch (error) {
        console.error('Error fetching teacher analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Student dashboard analytics
router.get('/student', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Videos watched
        const watchedResult = await pool.query(
            `SELECT COUNT(DISTINCT video_id) as total_watched
             FROM student_watch_history WHERE user_id = $1`,
            [userId]
        );

        // Doubts count
        const doubtsResult = await pool.query(
            `SELECT COUNT(*) as total_doubts
             FROM video_timestamps WHERE student_id = $1`,
            [userId]
        );

        // Communities joined
        const communitiesResult = await pool.query(
            `SELECT COUNT(*) as total_communities
             FROM community_members WHERE user_id = $1`,
            [userId]
        );

        // Downloads count
        const downloadsResult = await pool.query(
            `SELECT COUNT(*) as total_downloads
             FROM video_downloads WHERE user_id = $1`,
            [userId]
        );

        // Recent activity
        const activityResult = await pool.query(
            `SELECT 'watched_video' as activity_type, v.title as details, w.watched_at as timestamp
             FROM student_watch_history w
             JOIN videos v ON w.video_id = v.id
             WHERE w.user_id = $1
             ORDER BY w.watched_at DESC LIMIT 10`,
            [userId]
        );

        res.json({
            message: 'Student analytics retrieved',
            summary: {
                total_videos_watched: parseInt(watchedResult.rows[0].total_watched) || 0,
                total_doubts: parseInt(doubtsResult.rows[0].total_doubts) || 0,
                total_communities: parseInt(communitiesResult.rows[0].total_communities) || 0,
                total_downloads: parseInt(downloadsResult.rows[0].total_downloads) || 0
            },
            recent_activity: activityResult.rows
        });
    } catch (error) {
        console.error('Error fetching student analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Video analytics
router.get('/video/:videoId', authenticateToken, async (req, res) => {
    try {
        const { videoId } = req.params;

        const videoResult = await pool.query(
            'SELECT * FROM videos WHERE id = $1 AND is_deleted = false',
            [videoId]
        );

        if (videoResult.rows.length === 0) {
            return res.status(404).json({ message: 'Video not found' });
        }

        const engagementResult = await pool.query(
            `SELECT 
                COUNT(DISTINCT swh.user_id) as unique_viewers,
                COUNT(swh.user_id) as total_watches,
                COUNT(DISTINCT vd.user_id) as total_downloads,
                COUNT(DISTINCT ve.user_id) as total_upvotes
             FROM videos v
             LEFT JOIN student_watch_history swh ON v.id = swh.video_id
             LEFT JOIN video_downloads vd ON v.id = vd.video_id
             LEFT JOIN video_engagement ve ON v.id = ve.video_id AND ve.type = 'upvote'
             WHERE v.id = $1`,
            [videoId]
        );

        const doubtsResult = await pool.query(
            `SELECT COUNT(*) as total_doubts, 
                    SUM(CASE WHEN is_resolved = true THEN 1 ELSE 0 END) as resolved_doubts
             FROM video_timestamps WHERE video_id = $1`,
            [videoId]
        );

        res.json({
            message: 'Video analytics retrieved',
            video: videoResult.rows[0],
            engagement: engagementResult.rows[0],
            doubts: doubtsResult.rows[0]
        });
    } catch (error) {
        console.error('Error fetching video analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Platform analytics (admin only)
router.get('/admin/platform', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Check if admin
        const userResult = await pool.query(
            'SELECT * FROM users WHERE id = $1 AND role = $2',
            [userId, 'admin']
        );

        if (userResult.rows.length === 0) {
            return res.status(403).json({ message: 'Only admins can access platform analytics' });
        }

        const usersResult = await pool.query(
            `SELECT role, COUNT(*) as count FROM users GROUP BY role`
        );

        const feedbackResult = await pool.query(
            `SELECT COUNT(*) as total_feedback FROM anonymous_feedback`
        );

        const videosResult = await pool.query(
            `SELECT COUNT(*) as total_videos, SUM(views_count) as total_views
             FROM videos WHERE is_deleted = false`
        );

        res.json({
            message: 'Platform analytics retrieved',
            users_by_role: usersResult.rows,
            feedback: feedbackResult.rows[0],
            videos: videosResult.rows[0]
        });
    } catch (error) {
        console.error('Error fetching platform analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;