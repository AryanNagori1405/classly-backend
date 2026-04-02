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

// Helper: Check if teacher owns the course (via quiz)
async function validateQuizOwnership(quizId, userId) {
    try {
        const result = await pool.query(
            `SELECT q.* FROM quizzes q 
             JOIN courses c ON q.course_id = c.id 
             WHERE q.id = $1 AND c.created_by = $2`,
            [quizId, userId]
        );
        return result.rows.length > 0;
    } catch (error) {
        console.error('Error validating quiz ownership:', error);
        throw error;
    }
}

// POST /api/questions - Add a question to a quiz
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { quizId, questionText, questionType, points, orderIndex, options } = req.body;
        const userId = req.user.id;

        // Validate required fields
        if (!quizId || !questionText) {
            return res.status(400).json({ message: 'quizId and questionText are required' });
        }

        // Check if quiz exists
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
        if (quizResult.rows.length === 0) {
            return res.status(404).json({ message: 'Quiz not found' });
        }

        // Verify user owns the quiz
        const isOwner = await validateQuizOwnership(quizId, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only add questions to your own quizzes' });
        }

        // Insert question
        const questionResult = await pool.query(
            `INSERT INTO questions (quiz_id, question_text, question_type, points, order_index)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING *`,
            [quizId, questionText, questionType || 'multiple_choice', points || 1, orderIndex || 1]
        );

        const question = questionResult.rows[0];

        // Insert options if provided
        let savedOptions = [];
        if (options && Array.isArray(options) && options.length > 0) {
            for (let i = 0; i < options.length; i++) {
                const opt = options[i];
                const optResult = await pool.query(
                    `INSERT INTO question_options (question_id, option_text, is_correct, order_index)
                     VALUES ($1, $2, $3, $4)
                     RETURNING *`,
                    [question.id, opt.optionText, opt.isCorrect || false, opt.orderIndex || i + 1]
                );
                savedOptions.push(optResult.rows[0]);
            }
        }

        res.status(201).json({
            message: 'Question added successfully',
            question: {
                ...question,
                options: savedOptions
            }
        });
    } catch (error) {
        console.error('Error creating question:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/questions/:id - Get a specific question with options
router.get('/:id', authenticateToken, async (req, res) => {
    try {
        const questionId = req.params.id;

        const questionResult = await pool.query('SELECT * FROM questions WHERE id = $1', [questionId]);
        if (questionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Question not found' });
        }

        const question = questionResult.rows[0];

        // Get options for this question
        const optionsResult = await pool.query(
            'SELECT * FROM question_options WHERE question_id = $1 ORDER BY order_index ASC',
            [questionId]
        );

        res.json({
            ...question,
            options: optionsResult.rows
        });
    } catch (error) {
        console.error('Error fetching question:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PUT /api/questions/:id - Update a question
router.put('/:id', authenticateToken, async (req, res) => {
    try {
        const questionId = req.params.id;
        const userId = req.user.id;
        const { questionText, points, orderIndex } = req.body;

        const questionResult = await pool.query('SELECT * FROM questions WHERE id = $1', [questionId]);
        if (questionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Question not found' });
        }

        const question = questionResult.rows[0];

        // Get quiz and verify ownership
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [question.quiz_id]);
        const quiz = quizResult.rows[0];

        const isOwner = await validateQuizOwnership(quiz.id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only update questions in your own quizzes' });
        }

        const result = await pool.query(
            `UPDATE questions 
             SET question_text = COALESCE($1, question_text),
                 points = COALESCE($2, points),
                 order_index = COALESCE($3, order_index),
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $4
             RETURNING *`,
            [questionText, points, orderIndex, questionId]
        );

        res.json({
            message: 'Question updated successfully',
            question: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating question:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/questions/:id - Delete a question
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const questionId = req.params.id;
        const userId = req.user.id;

        const questionResult = await pool.query('SELECT * FROM questions WHERE id = $1', [questionId]);
        if (questionResult.rows.length === 0) {
            return res.status(404).json({ message: 'Question not found' });
        }

        const question = questionResult.rows[0];

        // Get quiz and verify ownership
        const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [question.quiz_id]);
        const quiz = quizResult.rows[0];

        const isOwner = await validateQuizOwnership(quiz.id, userId);
        if (!isOwner) {
            return res.status(403).json({ message: 'You can only delete questions from your own quizzes' });
        }

        await pool.query('DELETE FROM questions WHERE id = $1', [questionId]);

        res.json({ message: 'Question deleted successfully' });
    } catch (error) {
        console.error('Error deleting question:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;