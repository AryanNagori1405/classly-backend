const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Enrollment = require('../models/enrollmentModel');

// Middleware for JWT authentication
const authenticateJWT = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(403).json({ message: 'No token provided' });

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ message: 'Invalid or expired token' });
        req.user = user;
        next();
    });
};

// ===== ENROLL A STUDENT IN A COURSE =====
router.post('/enroll', authenticateJWT, async (req, res) => {
    try {
        const { courseId } = req.body;
        const studentId = req.user.id; // Get from JWT token

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        // Check if student already enrolled
        const isAlreadyEnrolled = await Enrollment.isEnrolled(studentId, courseId);
        if (isAlreadyEnrolled) {
            return res.status(400).json({ message: 'You are already enrolled in this course' });
        }

        // Enroll student
        const result = await Enrollment.enrollStudent(studentId, courseId);
        
        res.status(201).json({
            message: 'Enrolled successfully',
            enrollment: result.rows[0]
        });
    } catch (error) {
        console.error('Error enrolling student:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET MY COURSES (logged-in student) =====
router.get('/my-courses', authenticateJWT, async (req, res) => {
    try {
        const studentId = req.user.id;

        const result = await Enrollment.getStudentEnrollments(studentId);

        res.status(200).json({
            message: 'Your courses retrieved successfully',
            courses: result.rows
        });
    } catch (error) {
        console.error('Error fetching student enrollments:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ALL STUDENTS IN A COURSE =====
router.get('/course/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        const result = await Enrollment.getCourseEnrollments(courseId);

        res.status(200).json({
            message: 'Course students retrieved successfully',
            students: result.rows
        });
    } catch (error) {
        console.error('Error fetching course enrollments:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== UNENROLL FROM COURSE =====
router.delete('/unenroll/:courseId', authenticateJWT, async (req, res) => {
    try {
        const { courseId } = req.params;
        const studentId = req.user.id;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        // Check if student is enrolled
        const isEnrolled = await Enrollment.isEnrolled(studentId, courseId);
        if (!isEnrolled) {
            return res.status(400).json({ message: 'You are not enrolled in this course' });
        }

        // Unenroll student
        const result = await Enrollment.unenrollStudent(studentId, courseId);

        res.status(200).json({
            message: 'Unenrolled successfully'
        });
    } catch (error) {
        console.error('Error unenrolling student:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== CHECK IF I'M ENROLLED IN A COURSE =====
router.get('/check/:courseId', authenticateJWT, async (req, res) => {
    try {
        const { courseId } = req.params;
        const studentId = req.user.id;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        const isEnrolled = await Enrollment.isEnrolled(studentId, courseId);

        res.status(200).json({
            message: 'Enrollment status retrieved',
            isEnrolled: isEnrolled
        });
    } catch (error) {
        console.error('Error checking enrollment:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ENROLLMENT STATISTICS =====
router.get('/stats/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }

        const result = await Enrollment.getEnrollmentStats(courseId);

        res.status(200).json({
            message: 'Enrollment statistics retrieved',
            stats: result.rows[0]
        });
    } catch (error) {
        console.error('Error fetching enrollment stats:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

module.exports = router;