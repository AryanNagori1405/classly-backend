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

function checkAdmin(req, res, next) {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Admin access required' });
    }
    next();
}

// GET /api/admin/users - List all users
router.get('/users', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { role, status } = req.query;
        let query = 'SELECT id, name, email, role, is_active, created_at FROM users';
        let params = [];

        if (role) {
            query += ` WHERE role = $${params.length + 1}`;
            params.push(role);
        }

        query += ' ORDER BY created_at DESC';

        const result = await pool.query(query, params);
        res.json({
            message: 'Users retrieved',
            count: result.rows.length,
            users: result.rows
        });
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/admin/users/:userId - Suspend/ban user
router.patch('/users/:userId', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { userId } = req.params;
        const { is_active, reason } = req.body;

        const result = await pool.query(
            `UPDATE users SET is_active = $1, updated_at = CURRENT_TIMESTAMP
             WHERE id = $2 RETURNING *`,
            [is_active, userId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Log action
        await pool.query(
            `INSERT INTO admin_actions_log (admin_id, action_type, target_user_id, description, created_at)
             VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)`,
            [req.user.id, is_active ? 'user_activated' : 'user_suspended', userId, reason || 'No reason provided']
        );

        res.json({
            message: `User ${is_active ? 'activated' : 'suspended'}`,
            user: result.rows[0]
        });
    } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/admin/courses - List all courses
router.get('/courses', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT c.*, u.name as creator_name, COUNT(DISTINCT e.student_id) as enrolled_students
             FROM courses c
             JOIN users u ON c.created_by = u.id
             LEFT JOIN enrollments e ON c.id = e.course_id
             GROUP BY c.id, u.name
             ORDER BY c.created_at DESC`
        );

        res.json({
            message: 'Courses retrieved',
            count: result.rows.length,
            courses: result.rows
        });
    } catch (error) {
        console.error('Error fetching courses:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/admin/courses/:courseId - Delete course
router.delete('/courses/:courseId', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { courseId } = req.params;

        // Delete course and related data
        await pool.query('DELETE FROM courses WHERE id = $1', [courseId]);

        // Log action
        await pool.query(
            `INSERT INTO admin_actions_log (admin_id, action_type, description, created_at)
             VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
            [req.user.id, 'course_deleted', `Course ${courseId} deleted`]
        );

        res.json({ message: 'Course deleted successfully' });
    } catch (error) {
        console.error('Error deleting course:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/admin/content - List flagged/inappropriate content
router.get('/content', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM content_moderation
             WHERE is_resolved = false
             ORDER BY created_at DESC`
        );

        res.json({
            message: 'Flagged content retrieved',
            count: result.rows.length,
            content: result.rows
        });
    } catch (error) {
        console.error('Error fetching flagged content:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// PATCH /api/admin/content/:contentId - Moderate content
router.patch('/content/:contentId', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const { contentId } = req.params;
        const { action, reason } = req.body;

        const result = await pool.query(
            `UPDATE content_moderation
             SET is_resolved = true, moderation_action = $1, reason = $2, updated_at = CURRENT_TIMESTAMP
             WHERE id = $3 RETURNING *`,
            [action, reason, contentId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Content not found' });
        }

        res.json({
            message: 'Content moderated successfully',
            moderation: result.rows[0]
        });
    } catch (error) {
        console.error('Error moderating content:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/admin/reports - Platform reports
router.get('/reports', authenticateToken, checkAdmin, async (req, res) => {
    try {
        const usersReport = await pool.query(
            `SELECT role, COUNT(*) as count FROM users GROUP BY role`
        );

        const coursesReport = await pool.query(
            `SELECT COUNT(*) as total, SUM(students_enrolled) as enrollments FROM courses`
        );

        const videosReport = await pool.query(
            `SELECT COUNT(*) as total, SUM(views_count) as views FROM videos WHERE is_deleted = false`
        );

        const actionsLog = await pool.query(
            `SELECT * FROM admin_actions_log ORDER BY created_at DESC LIMIT 20`
        );

        res.json({
            message: 'Reports generated',
            users_by_role: usersReport.rows,
            courses: coursesReport.rows[0],
            videos: videosReport.rows[0],
            recent_actions: actionsLog.rows
        });
    } catch (error) {
        console.error('Error generating reports:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;