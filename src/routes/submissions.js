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

// POST /api/submissions - Submit a quiz (students)
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { quizId, answers } = req.body;
        const studentId = req.user.id;

        // Validate required fields
        if (!quizId || !answers || !Array.isArray(answers)) {
            return res.status(400).json({ message: 'quizId and answers array are required' });
        }

        // Get quiz and course info
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Check if student is enrolled in the course
        const isEnrolled = await validateEnrollment(quiz.course_id, studentId);
        
        if (!isEnrolled) {
            return res.status(403).json({ message: 'You are not enrolled in this course' });
        }

        // Create quiz submission record
        const submissionResult = await pool.query(
            `INSERT INTO quiz_submissions (quiz_id, student_id, submitted_at)
             VALUES ($1, $2, CURRENT_TIMESTAMP)
             RETURNING *`,
            [quizId, studentId]
        );

        const submission = submissionResult.rows[0];
        let totalScore = 0;
        let maxScore = 0;

        // Get all questions for the quiz
        const questionsResult = await pool.query(
            'SELECT * FROM questions WHERE quiz_id = $1',
            [quizId]
        );

        // Process each student answer
        for (const answer of answers) {
            const { questionId, selectedOptionId } = answer;

            // Find the question
            const question = questionsResult.rows.find(q => q.id === questionId);
            if (!question) continue;

            maxScore += question.points;

            // Get the correct answer for this question
            const correctOptionResult = await pool.query(
                'SELECT * FROM question_options WHERE question_id = $1 AND is_correct = true',
                [questionId]
            );

            const isCorrect = correctOptionResult.rows.length > 0 && 
                             correctOptionResult.rows[0].id === selectedOptionId;

            const pointsEarned = isCorrect ? question.points : 0;
            if (isCorrect) totalScore += pointsEarned;

            // Save student's answer
            await pool.query(
                `INSERT INTO student_answers (submission_id, question_id, selected_option_id, is_correct, points_earned)
                 VALUES ($1, $2, $3, $4, $5)`,
                [submission.id, questionId, selectedOptionId || null, isCorrect, pointsEarned]
            );
        }

        // Calculate score percentage and check if passed
        const scorePercentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0;
        const passed = scorePercentage >= quiz.passing_score;

        // Update submission with final score
        const updatedSubmission = await pool.query(
            `UPDATE quiz_submissions 
             SET score = $1, passed = $2
             WHERE id = $3
             RETURNING *`,
            [scorePercentage, passed, submission.id]
        );

        res.status(201).json({
            message: 'Quiz submitted successfully',
            submission: updatedSubmission.rows[0],
            details: {
                score: scorePercentage,
                totalPoints: totalScore,
                maxPoints: maxScore,
                passed: passed
            }
        });
    } catch (error) {
        console.error('Error submitting quiz:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/submissions/:submissionId - Get submission details with answers
router.get('/:submissionId', authenticateToken, async (req, res) => {
    try {
        const submissionId = req.params.submissionId;
        const userId = req.user.id;

        // Fetch the submission
        const submissionResult = await pool.query(
            'SELECT * FROM quiz_submissions WHERE id = $1',
            [submissionId]
        );

        if (submissionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Submission not found' });
        }

        const submission = submissionResult.rows[0];

        // Verify access: user must be the student or the course teacher
        if (submission.student_id !== userId) {
            const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [submission.quiz_id]);
            const quiz = quizResult.rows[0];

            const isOwner = await validateCourseOwnership(quiz.course_id, userId);
            if (!isOwner) {
                return res.status(403).json({ message: 'You do not have access to this submission' });
            }
        }

        // Fetch all student answers with question details
        const answersResult = await pool.query(
            `SELECT sa.*, q.question_text, q.points, qo.option_text, qo.is_correct
             FROM student_answers sa
             JOIN questions q ON sa.question_id = q.id
             LEFT JOIN question_options qo ON sa.selected_option_id = qo.id
             WHERE sa.submission_id = $1
             ORDER BY q.order_index`,
            [submissionId]
        );

        res.json({
            ...submission,
            answers: answersResult.rows
        });
    } catch (error) {
        console.error('Error fetching submission:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/submissions/quiz/:quizId - Get all submissions for a quiz (teacher only)
router.get('/quiz/:quizId', authenticateToken, async (req, res) => {
    try {
        const quizId = req.params.quizId;
        const userId = req.user.id;

        // Fetch the quiz
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Verify the teacher owns this course
        const isOwner = await validateCourseOwnership(quiz.course_id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only view submissions for your own quizzes' });
        }

        // Fetch all submissions for the quiz with student info
        const result = await pool.query(
            `SELECT qs.*, u.email, u.name
             FROM quiz_submissions qs
             JOIN users u ON qs.student_id = u.id
             WHERE qs.quiz_id = $1
             ORDER BY qs.submitted_at DESC`,
            [quizId]
        );

        res.json({
            message: 'Submissions retrieved successfully',
            submissions: result.rows
        });
    } catch (error) {
        console.error('Error fetching submissions:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/submissions/student/:studentId/quiz/:quizId - Get student's submission for a specific quiz
router.get('/student/:studentId/quiz/:quizId', authenticateToken, async (req, res) => {
    try {
        const { studentId, quizId } = req.params;
        const userId = req.user.id;

        // Fetch the quiz
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        const quiz = quizResult.rows[0];

        // Verify access: user must be the student or the course teacher
        const isOwner = await validateCourseOwnership(quiz.course_id, userId);
        const isStudent = userId == studentId;

        if (!isOwner && !isStudent) {
            return res.status(403).json({ message: 'You do not have access to this submission' });
        }

        // Fetch the student's submission for this quiz
        const result = await pool.query(
            'SELECT * FROM quiz_submissions WHERE quiz_id = $1 AND student_id = $2 ORDER BY submitted_at DESC LIMIT 1',
            [quizId, studentId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'No submission found' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Error fetching submission:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;