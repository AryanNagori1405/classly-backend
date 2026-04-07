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

        // Total students
        const studentsResult = await pool.query(
            `SELECT COUNT(DISTINCT e.student_id) as total_students
             FROM enrollments e
             JOIN courses c ON e.course_id = c.id
             WHERE c.created_by = $1`,
            [userId]
        );

        // Total videos
        const videosResult = await pool.query(
            `SELECT COUNT(*) as total_videos, SUM(views_count) as total_views
             FROM videos WHERE teacher_id = $1 AND is_deleted = false`,
            [userId]
        );

        // Total engagement
        const engagementResult = await pool.query(
            `SELECT COUNT(*) as total_upvotes, SUM(downloads_count) as total_downloads
             FROM videos WHERE teacher_id = $1 AND is_deleted = false`,
            [userId]
        );

        // Courses
        const coursesResult = await pool.query(
            `SELECT c.id, c.title, COUNT(DISTINCT e.student_id) as students,
                    COUNT(DISTINCT v.id) as videos
             FROM courses c
             LEFT JOIN enrollments e ON c.id = e.course_id
             LEFT JOIN videos v ON c.id = v.course_id AND v.is_deleted = false
             WHERE c.created_by = $1
             GROUP BY c.id, c.title`,
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
                total_students: parseInt(studentsResult.rows[0].total_students),
                total_videos: parseInt(videosResult.rows[0].total_videos),
                total_views: parseInt(videosResult.rows[0].total_views) || 0,
                total_upvotes: parseInt(engagementResult.rows[0].total_upvotes) || 0,
                total_downloads: parseInt(engagementResult.rows[0].total_downloads) || 0
            },
            courses: coursesResult.rows,
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

        // Enrolled courses
        const coursesResult = await pool.query(
            `SELECT DISTINCT c.id, c.title, COUNT(DISTINCT v.id) as videos
             FROM enrollments e
             JOIN courses c ON e.course_id = c.id
             LEFT JOIN videos v ON c.id = v.course_id AND v.is_deleted = false
             WHERE e.student_id = $1
             GROUP BY c.id, c.title`,
            [userId]
        );

        // Videos watched
        const watchedResult = await pool.query(
            `SELECT COUNT(DISTINCT video_id) as total_watched, COUNT(*) as watch_count
             FROM student_watch_history WHERE user_id = $1`,
            [userId]
        );

        // Quiz performance
        const quizResult = await pool.query(
            `SELECT COALESCE(AVG(score), 0) as average_score, COUNT(*) as total_attempts
             FROM quiz_submissions WHERE student_id = $1`,
            [userId]
        ).catch((err) => {
            console.warn('[analytics] quiz_submissions query failed (table may not exist):', err.message);
            return { rows: [{ average_score: 0, total_attempts: 0 }] };
        });

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
                enrolled_courses: coursesResult.rows.length,
                total_videos_watched: parseInt(watchedResult.rows[0].total_watched) || 0,
                average_quiz_score: parseFloat(quizResult.rows[0].average_score) || 0,
                total_quiz_attempts: parseInt(quizResult.rows[0].total_attempts) || 0
            },
            courses: coursesResult.rows,
            recent_activity: activityResult.rows
        });
    } catch (error) {
        console.error('Error fetching student analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Course analytics
router.get('/course/:courseId', authenticateToken, async (req, res) => {
    try {
        const { courseId } = req.params;
        const userId = req.user.id;

        const courseResult = await pool.query(
            'SELECT * FROM courses WHERE id = $1 AND created_by = $2',
            [courseId, userId]
        );

        if (courseResult.rows.length === 0) {
            return res.status(404).json({ message: 'Course not found' });
        }

        const statsResult = await pool.query(
            `SELECT 
                COUNT(DISTINCT e.student_id) as total_students,
                COUNT(DISTINCT v.id) as total_videos,
                SUM(v.views_count) as total_views,
                SUM(v.upvotes) as total_upvotes
             FROM courses c
             LEFT JOIN enrollments e ON c.id = e.course_id
             LEFT JOIN videos v ON c.id = v.course_id AND v.is_deleted = false
             WHERE c.id = $1`,
            [courseId]
        );

        const videosResult = await pool.query(
            `SELECT id, title, views_count, upvotes, downloads_count, created_at
             FROM videos WHERE course_id = $1 AND is_deleted = false
             ORDER BY views_count DESC`,
            [courseId]
        );

        res.json({
            message: 'Course analytics retrieved',
            course: courseResult.rows[0],
            stats: statsResult.rows[0],
            videos: videosResult.rows
        });
    } catch (error) {
        console.error('Error fetching course analytics:', error);
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

        const coursesResult = await pool.query(
            `SELECT COUNT(*) as total_courses
             FROM courses`
        );

        const videosResult = await pool.query(
            `SELECT COUNT(*) as total_videos, SUM(views_count) as total_views
             FROM videos WHERE is_deleted = false`
        );

        res.json({
            message: 'Platform analytics retrieved',
            users_by_role: usersResult.rows,
            courses: coursesResult.rows[0],
            videos: videosResult.rows[0]
        });
    } catch (error) {
        console.error('Error fetching platform analytics:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;