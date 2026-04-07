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

// POST /api/quizzes - Create quiz (teacher only)
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { title, description, course_id, lesson_id, passing_score } = req.body;
        const teacherId = req.user.id;

        // Validate required fields
        if (!title || !course_id) {
            return res.status(400).json({ message: 'Title and course_id are required' });
        }

        // Check if course exists and quizzes are enabled
        const courseResult = await pool.query(
            'SELECT * FROM courses WHERE id = $1 AND created_by = $2',
            [course_id, teacherId]
        );

        if (courseResult.rows.length === 0) {
            return res.status(403).json({ message: 'Course not found or you are not the creator' });
        }

        if (!courseResult.rows[0].enable_quizzes) {
            return res.status(400).json({ 
                message: 'Quizzes are not enabled for this course. Please enable quizzes in course settings.' 
            });
        }

        // Create quiz
        const result = await pool.query(
            `INSERT INTO quizzes (course_id, lesson_id, created_by, title, description, passing_score, created_at)
             VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
             RETURNING *`,
            [course_id, lesson_id || null, teacherId, title, description, passing_score || 50]
        );

        // If lesson_id provided, update lesson with quiz_id
        if (lesson_id) {
            await pool.query(
                'UPDATE lessons SET quiz_id = $1 WHERE id = $2',
                [result.rows[0].id, lesson_id]
            );
        }

        res.status(201).json({
            message: 'Quiz created successfully',
            quiz: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating quiz:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/quizzes/:id - Get specific quiz with questions
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const quizId = req.params.id;
        const userId = req.user.id;

        // Get quiz
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Check if user has access (enrolled or owns course)
        const isEnrolled = await validateEnrollment(quiz.course_id, userId);
        const isOwner = await validateCourseOwnership(quiz.course_id, userId);

        if (!isEnrolled && !isOwner) {
            return res.status(403).json({ message: 'You do not have access to this quiz' });
        }

        // Get all questions for this quiz
        const questionsResult = await pool.query(
            'SELECT * FROM questions WHERE quiz_id = $1 ORDER BY order_index ASC',
            [quizId]
        );

        // Get options for each question
        const questionsWithOptions = await Promise.all(
            questionsResult.rows.map(async (question) => {
                const optionsResult = await pool.query(
                    'SELECT id, option_text, is_correct, order_index FROM question_options WHERE question_id = $1 ORDER BY order_index ASC',
                    [question.id]
                );
                return {
                    ...question,
                    options: optionsResult.rows
                };
            })
        );

        res.json({
            ...quiz,
            questions: questionsWithOptions
        });
    } catch (error) {
        console.error('Error fetching quiz:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/quizzes/lesson/:lessonId - Get all quizzes for a lesson
router.get('/lesson/:lessonId', authenticateToken, async (req, res) => {
    try {
        const lessonId = req.params.lessonId;
        const userId = req.user.id;

        // Get lesson and its course
        const lessonResult = await pool.query('SELECT * FROM lessons WHERE id = $1', [lessonId]);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        const lesson = lessonResult.rows[0];

        // Check if user has access
        const isEnrolled = await validateEnrollment(lesson.course_id, userId);
        const isOwner = await validateCourseOwnership(lesson.course_id, userId);

        if (!isEnrolled && !isOwner) {
            return res.status(403).json({ message: 'You do not have access to this lesson' });
        }

        // Get all quizzes for this lesson
        const result = await pool.query(
            'SELECT * FROM quizzes WHERE lesson_id = $1 ORDER BY created_at ASC',
            [lessonId]
        );

        res.json({
            message: 'Quizzes retrieved successfully',
            quizzes: result.rows
        });
    } catch (error) {
        console.error('Error fetching quizzes:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PUT /api/quizzes/:id - Update a quiz (teachers only)
router.put('/:id', authenticateToken, async (req, res) => {
    try {
        const quizId = req.params.id;
        const userId = req.user.id;
        const { title, description, passingScore, isPublished } = req.body;

        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Verify user owns the course
        const isOwner = await validateCourseOwnership(quiz.course_id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only update quizzes in your own courses' });
        }

        const result = await pool.query(
            `UPDATE quizzes 
             SET title = COALESCE($1, title),
                 description = COALESCE($2, description),
                 passing_score = COALESCE($3, passing_score),
                 is_published = COALESCE($4, is_published),
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $5
             RETURNING *`,
            [title, description, passingScore, isPublished, quizId]
        );

        res.json({
            message: 'Quiz updated successfully',
            quiz: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating quiz:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/quizzes/:id - Delete a quiz (teachers only)
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const quizId = req.params.id;
        const userId = req.user.id;

        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Verify user owns the course
        const isOwner = await validateCourseOwnership(quiz.course_id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only delete quizzes from your own courses' });
        }

        await pool.query('DELETE FROM quizzes WHERE id = $1', [quizId]);

        res.json({ message: 'Quiz deleted successfully' });
    } catch (error) {
        console.error('Error deleting quiz:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;