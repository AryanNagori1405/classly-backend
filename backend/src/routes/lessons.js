const express = require('express');
<<<<<<< HEAD:src/routes/lessons.js
const router = express.Router();
const Lesson = require('../models/lessonModel');
const auth = require('../middleware/auth');

// ===== ROLE GUARD: TEACHERS ONLY =====
const requireTeacher = (req, res, next) => {
    if (req.user.role !== 'teacher') {
        return res.status(403).json({ message: 'Access denied. Teachers only.' });
    }
    next();
};

// ===== CREATE LESSON (Teacher only) =====
// POST /api/lessons
router.post('/', auth, requireTeacher, async (req, res) => {
    try {
        const { courseId, title, description, content, video_url, duration, order_index } = req.body;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }
        if (!title || title.trim().length < 3) {
            return res.status(400).json({ message: 'title is required and must be at least 3 characters' });
        }
        if (duration !== undefined && (isNaN(duration) || Number(duration) <= 0)) {
            return res.status(400).json({ message: 'duration must be a positive number' });
        }
        if (video_url && !/^https?:\/\/.+/.test(video_url)) {
            return res.status(400).json({ message: 'video_url must be a valid URL' });
        }

        // Check course exists
        const exists = await Lesson.courseExists(courseId);
        if (!exists) {
            return res.status(404).json({ message: 'Course not found' });
        }

        // Validate teacher owns the course
        const instructorId = await Lesson.getCourseInstructor(courseId);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const result = await Lesson.createLesson(courseId, { title: title.trim(), description, content, video_url, duration, order_index });

        res.status(201).json({
            message: 'Lesson created successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error creating lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ALL LESSONS IN A COURSE =====
// GET /api/lessons/course/:courseId
router.get('/course/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        const exists = await Lesson.courseExists(courseId);
        if (!exists) {
            return res.status(404).json({ message: 'Course not found' });
        }

        const result = await Lesson.getCourseLessons(courseId);

        res.status(200).json({
            message: 'Lessons retrieved successfully',
            lessons: result.rows,
        });
    } catch (error) {
        console.error('Error fetching lessons:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET SINGLE LESSON =====
// GET /api/lessons/:id
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await Lesson.getLessonById(id);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        const lesson = result.rows[0];

        // Only return unpublished lessons to authenticated teachers who own the course
        if (!lesson.is_published) {
            const token = req.headers.authorization?.split(' ')[1];
            if (!token) {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            const jwt = require('jsonwebtoken');
            let decoded;
            try {
                decoded = jwt.verify(token, process.env.JWT_SECRET);
            } catch {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            if (decoded.role !== 'teacher') {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
            if (instructorId !== null && instructorId !== decoded.id) {
                return res.status(404).json({ message: 'Lesson not found' });
            }
        }

        res.status(200).json({
            message: 'Lesson retrieved successfully',
            lesson,
        });
    } catch (error) {
        console.error('Error fetching lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== UPDATE LESSON (Teacher only) =====
// PUT /api/lessons/:id
router.put('/:id', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;
        const { title, duration, video_url } = req.body;

        if (title !== undefined && title.trim().length < 3) {
            return res.status(400).json({ message: 'title must be at least 3 characters' });
        }
        if (duration !== undefined && (isNaN(duration) || Number(duration) <= 0)) {
            return res.status(400).json({ message: 'duration must be a positive number' });
        }
        if (video_url !== undefined && video_url !== null && video_url !== '' && !/^https?:\/\/.+/.test(video_url)) {
            return res.status(400).json({ message: 'video_url must be a valid URL' });
        }

        // Check lesson exists
        const lessonResult = await Lesson.getLessonById(id);
=======
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const router = express.Router();

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    // Verify token using JWT_SECRET from environment
    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
}

// Helper: Check if teacher owns the course
async function validateCourseOwnership(courseId, userId) {
    try {
        const result = await pool.query(
            'SELECT * FROM courses WHERE id = $1 AND created_by = $2',
            [courseId, userId]
        );
        return result.rows.length > 0;
    } catch (error) {
        console.error('Error validating course ownership:', error);
        throw error;
    }
}

// Helper: Check if student is enrolled in course
async function validateEnrollment(courseId, userId) {
    try {
        const result = await pool.query(
            'SELECT * FROM enrollments WHERE course_id = $1 AND student_id = $2',
            [courseId, userId]
        );
        return result.rows.length > 0;
    } catch (error) {
        console.error('Error validating enrollment:', error);
        throw error;
    }
}

// POST /api/lessons - Create a new lesson (teachers only)
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { courseId, title, content } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!courseId || !title || !content) {
            return res.status(400).json({ message: 'courseId, title, and content are required' });
        }

        // Check course exists
        const courseResult = await pool.query('SELECT * FROM courses WHERE id = $1', [courseId]);
        if (courseResult.rows.length === 0) {
            return res.status(404).json({ message: 'Course not found' });
        }

        // Verify user owns this course before creating a lesson
        const isOwner = await validateCourseOwnership(courseId, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only create lessons in your own courses' });
        }

        // Insert lesson into database
        const result = await pool.query(
            `INSERT INTO lessons (course_id, title, content)
             VALUES ($1, $2, $3)
             RETURNING *`,
            [courseId, title, content]
        );

        res.status(201).json({
            message: 'Lesson created successfully',
            lesson: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating lesson:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/lessons/course/:courseId - Get all lessons in a course (BEFORE /:id)
router.get('/course/:courseId', authenticateToken, async (req, res) => {
    try {
        const courseId = req.params.courseId;
        const userId = req.user.id;

        // Check if course exists
        const courseResult = await pool.query('SELECT * FROM courses WHERE id = $1', [courseId]);
        if (courseResult.rows.length === 0) {
            return res.status(404).json({ message: 'Course not found' });
        }

        // Check if user has access to this course (enrolled or owns it)
        const isEnrolled = await validateEnrollment(courseId, userId);
        const isOwner = await validateCourseOwnership(courseId, userId);

        if (!isEnrolled && !isOwner) {
            return res.status(403).json({ message: 'You do not have access to this course' });
        }

        // Retrieve all lessons for this course ordered by creation date
        const result = await pool.query(
            'SELECT * FROM lessons WHERE course_id = $1 ORDER BY created_at ASC',
            [courseId]
        );

        res.json({
            message: 'Lessons retrieved successfully',
            lessons: result.rows
        });
    } catch (error) {
        console.error('Error fetching lessons:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/lessons/:id - Get a specific lesson by ID (AFTER /course/:courseId)
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const lessonId = req.params.id;
        const userId = req.user.id;

        // Fetch the lesson from database
        const lessonResult = await pool.query('SELECT * FROM lessons WHERE id = $1', [lessonId]);
>>>>>>> main:backend/src/routes/lessons.js
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

<<<<<<< HEAD:src/routes/lessons.js
        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const updateData = { ...req.body };
        if (title !== undefined) updateData.title = title.trim();

        const result = await Lesson.updateLesson(id, updateData);

        res.status(200).json({
            message: 'Lesson updated successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error updating lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== DELETE LESSON (Teacher only) =====
// DELETE /api/lessons/:id
router.delete('/:id', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;

        const lessonResult = await Lesson.getLessonById(id);
=======
        const lesson = lessonResult.rows[0];

        // Check if user has access (enrolled in course or owns the course)
        const isEnrolled = await validateEnrollment(lesson.course_id, userId);
        const isOwner = await validateCourseOwnership(lesson.course_id, userId);

        if (!isEnrolled && !isOwner) {
            return res.status(403).json({ message: 'You do not have access to this lesson' });
        }

        res.json(lesson);
    } catch (error) {
        console.error('Error fetching lesson:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PUT /api/lessons/:id - Update a lesson (teachers only)
router.put('/:id', authenticateToken, async (req, res) => {
    try {
        const lessonId = req.params.id;
        const userId = req.user.id;
        const { title, content } = req.body;

        // Fetch lesson to verify ownership
        const lessonResult = await pool.query('SELECT * FROM lessons WHERE id = $1', [lessonId]);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        const lesson = lessonResult.rows[0];

        // Verify user owns the course before allowing update
        const isOwner = await validateCourseOwnership(lesson.course_id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only update lessons in your own courses' });
        }

        // Update the lesson with new values
        const result = await pool.query(
            `UPDATE lessons 
             SET title = COALESCE($1, title),
                 content = COALESCE($2, content),
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $3
             RETURNING *`,
            [title, content, lessonId]
        );

        res.json({
            message: 'Lesson updated successfully',
            lesson: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating lesson:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/lessons/:id - Delete a lesson (teachers only)
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const lessonId = req.params.id;
        const userId = req.user.id;

        // Fetch lesson to verify ownership
        const lessonResult = await pool.query('SELECT * FROM lessons WHERE id = $1', [lessonId]);
>>>>>>> main:backend/src/routes/lessons.js
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

<<<<<<< HEAD:src/routes/lessons.js
        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        await Lesson.deleteLesson(id);

        res.status(200).json({ message: 'Lesson deleted successfully' });
    } catch (error) {
        console.error('Error deleting lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== PUBLISH / UNPUBLISH LESSON (Teacher only) =====
// PATCH /api/lessons/:id/publish
router.patch('/:id/publish', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;

        const lessonResult = await Lesson.getLessonById(id);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const result = await Lesson.publishLesson(id);

        res.status(200).json({
            message: result.rows[0].is_published ? 'Lesson published successfully' : 'Lesson unpublished successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error publishing lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

module.exports = router;
=======
        const lesson = lessonResult.rows[0];

        // Verify user owns the course before allowing deletion
        const isOwner = await validateCourseOwnership(lesson.course_id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only delete lessons from your own courses' });
        }

        // Delete the lesson from the database
        await pool.query('DELETE FROM lessons WHERE id = $1', [lessonId]);

        res.json({ message: 'Lesson deleted successfully' });
    } catch (error) {
        console.error('Error deleting lesson:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
>>>>>>> main:backend/src/routes/lessons.js
