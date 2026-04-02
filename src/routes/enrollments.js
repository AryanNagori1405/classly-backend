// Enrollment API Endpoints

const express = require('express');
const router = express.Router();

// Enroll a student
router.post('/enroll', (req, res) => {
    const { studentId, courseId } = req.body;
    // Logic to enroll student
    res.status(201).json({ message: 'Student enrolled successfully', studentId, courseId });
});

// Get enrollment by student ID
router.get('/enrollments/:studentId', (req, res) => {
    const { studentId } = req.params;
    // Logic to get enrollments for the student
    res.status(200).json({ message: 'Enrollments retrieved successfully', studentId });
});

// Cancel enrollment
router.delete('/enrollments/:enrollmentId', (req, res) => {
    const { enrollmentId } = req.params;
    // Logic to cancel enrollment
    res.status(200).json({ message: 'Enrollment cancelled successfully', enrollmentId });
});

module.exports = router;