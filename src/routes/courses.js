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

// POST /api/courses - Create course (teacher only)
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { title, description, enable_quizzes, enable_videos, enable_communities } = req.body;
        const teacherId = req.user.id;

        // Validate required fields
        if (!title) {
            return res.status(400).json({ message: 'Course title is required' });
        }

        // Determine course type
        let courseType = 'video_only';
        if (enable_quizzes && enable_videos) courseType = 'hybrid';
        if (enable_quizzes && !enable_videos) courseType = 'quiz_focused';

        const result = await pool.query(
            `INSERT INTO courses 
             (title, description, created_by, course_type, enable_quizzes, enable_videos, enable_communities, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
             RETURNING *`,
            [
                title, 
                description, 
                teacherId, 
                courseType,
                enable_quizzes || false,
                enable_videos !== false ? true : false,
                enable_communities !== false ? true : false
            ]
        );

        res.status(201).json({
            message: 'Course created successfully',
            course: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating course:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/courses - List all courses with course type info
router.get('/', authenticateToken, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT c.*, 
                    COUNT(DISTINCT e.id) as enrolled_students,
                    COUNT(DISTINCT l.id) as total_lessons,
                    COUNT(DISTINCT q.id) as total_quizzes,
                    COUNT(DISTINCT cm.id) as total_communities
             FROM courses c
             LEFT JOIN enrollments e ON c.id = e.course_id
             LEFT JOIN lessons l ON c.id = l.course_id
             LEFT JOIN quizzes q ON c.id = q.course_id
             LEFT JOIN communities cm ON c.id = cm.course_id
             GROUP BY c.id
             ORDER BY c.created_at DESC`
        );

        res.json({
            message: 'Courses retrieved successfully',
            count: result.rows.length,
            courses: result.rows
        });
    } catch (error) {
        console.error('Error fetching courses:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/courses/:id - Get course details with all content
router.get('/:courseId', authenticateToken, async (req, res) => {
    try {
        const courseId = req.params.courseId;

        // Get course
        const courseResult = await pool.query(
            'SELECT * FROM courses WHERE id = $1',
            [courseId]
        );

        if (courseResult.rows.length === 0) {
            return res.status(404).json({ message: 'Course not found' });
        }

        const course = courseResult.rows[0];

        // Get lessons with associated videos
        const lessonsResult = await pool.query(
            `SELECT l.*, v.id as video_id, v.title as video_title, v.duration, v.views_count
             FROM lessons l
             LEFT JOIN videos v ON l.id = v.lesson_id
             WHERE l.course_id = $1
             ORDER BY l.order_index`,
            [courseId]
        );

        // Get quizzes (only if enabled)
        let quizzesResult = { rows: [] };
        if (course.enable_quizzes) {
            quizzesResult = await pool.query(
                'SELECT * FROM quizzes WHERE course_id = $1 ORDER BY created_at DESC',
                [courseId]
            );
        }

        // Get videos (only if enabled)
        let videosResult = { rows: [] };
        if (course.enable_videos) {
            videosResult = await pool.query(
                'SELECT * FROM videos WHERE course_id = $1 AND is_public = true ORDER BY created_at DESC',
                [courseId]
            );
        }

        // Get communities (only if enabled)
        let communitiesResult = { rows: [] };
        if (course.enable_communities) {
            communitiesResult = await pool.query(
                'SELECT * FROM communities WHERE course_id = $1 ORDER BY created_at DESC',
                [courseId]
            );
        }

        res.json({
            course: {
                ...course,
                content: {
                    lessons: lessonsResult.rows,
                    quizzes: course.enable_quizzes ? quizzesResult.rows : [],
                    videos: course.enable_videos ? videosResult.rows : [],
                    communities: course.enable_communities ? communitiesResult.rows : []
                },
                features: {
                    videos_enabled: course.enable_videos,
                    quizzes_enabled: course.enable_quizzes,
                    communities_enabled: course.enable_communities
                }
            }
        });
    } catch (error) {
        console.error('Error fetching course:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/courses/:id - Update course settings
router.patch('/:courseId', authenticateToken, async (req, res) => {
    try {
        const courseId = req.params.courseId;
        const userId = req.user.id;
        const { title, description, enable_quizzes, enable_videos, enable_communities } = req.body;

        // Verify ownership
        const courseResult = await pool.query(
            'SELECT * FROM courses WHERE id = $1 AND created_by = $2',
            [courseId, userId]
        );

        if (courseResult.rows.length === 0) {
            return res.status(403).json({ message: 'You can only update your own courses' });
        }

        // Determine course type
        let courseType = 'video_only';
        if (enable_quizzes && enable_videos) courseType = 'hybrid';
        if (enable_quizzes && !enable_videos) courseType = 'quiz_focused';

        const result = await pool.query(
            `UPDATE courses 
             SET title = COALESCE($1, title),
                 description = COALESCE($2, description),
                 enable_quizzes = COALESCE($3, enable_quizzes),
                 enable_videos = COALESCE($4, enable_videos),
                 enable_communities = COALESCE($5, enable_communities),
                 course_type = $6
             WHERE id = $7
             RETURNING *`,
            [title, description, enable_quizzes, enable_videos, enable_communities, courseType, courseId]
        );

        res.json({
            message: 'Course updated successfully',
            course: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating course:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;