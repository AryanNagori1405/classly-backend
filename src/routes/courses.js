const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Course = require('../models/courseModel');

// Middleware for JWT authentication and teacher role verification
const authenticateJWT = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.sendStatus(403);

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
};

// Create a new course
router.post('/', authenticateJWT, (req, res) => {
    const courseData = req.body;
    if (req.user.role !== 'teacher') return res.status(403).send('Unauthorized');
    Course.create(courseData).
    then(course => res.status(201).json(course)).
    catch(err => res.status(500).send(err.message));
});

// Retrieve all courses
router.get('/', (req, res) => {
    Course.findAll().
    then(courses => res.json(courses)).
    catch(err => res.status(500).send(err.message));
});

// Update a course
router.put('/:id', authenticateJWT, (req, res) => {
    const { id } = req.params;
    if (req.user.role !== 'teacher') return res.status(403).send('Unauthorized');
    Course.update(id, req.body).
    then(course => res.json(course)).
    catch(err => res.status(500).send(err.message));
});

// Delete a course
router.delete('/:id', authenticateJWT, (req, res) => {
    const { id } = req.params;
    if (req.user.role !== 'teacher') return res.status(403).send('Unauthorized');
    Course.delete(id).
    then(() => res.status(204).send()).
    catch(err => res.status(500).send(err.message));
});

// Enroll in a course
router.post('/:id/enroll', authenticateJWT, (req, res) => {
    const { id } = req.params;
    Course.enroll(req.user.id, id).
    then(() => res.status(200).send('Enrolled')).
    catch(err => res.status(500).send(err.message));
});

// Manage lessons
router.post('/:courseId/lessons', authenticateJWT, (req, res) => {
    const { courseId } = req.params;
    if (req.user.role !== 'teacher') return res.status(403).send('Unauthorized');
    Course.addLesson(courseId, req.body).
    then(lesson => res.status(201).json(lesson)).
    catch(err => res.status(500).send(err.message));
});

module.exports = router;