// lessons.js

const express = require('express');
const jwt = require('jsonwebtoken');
const router = express.Router();

// Mock Database
let lessons = [];

// Middleware to verify JWT
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
}

// Create a new lesson
router.post('/', authenticateToken, (req, res) => {
    const lesson = { id: lessons.length + 1, ...req.body };
    lessons.push(lesson);
    res.status(201).json(lesson);
});

// Get all lessons
router.get('/', authenticateToken, (req, res) => {
    res.json(lessons);
});

// Get a lesson by ID
router.get('/:id', authenticateToken, (req, res) => {
    const lesson = lessons.find(l => l.id === parseInt(req.params.id));
    if (!lesson) return res.sendStatus(404);
    res.json(lesson);
});

// Update a lesson by ID
router.put('/:id', authenticateToken, (req, res) => {
    const lessonIndex = lessons.findIndex(l => l.id === parseInt(req.params.id));
    if (lessonIndex === -1) return res.sendStatus(404);
    lessons[lessonIndex] = { id: lessons[lessonIndex].id, ...req.body };
    res.json(lessons[lessonIndex]);
});

// Delete a lesson by ID
router.delete('/:id', authenticateToken, (req, res) => {
    const lessonIndex = lessons.findIndex(l => l.id === parseInt(req.params.id));
    if (lessonIndex === -1) return res.sendStatus(404);
    lessons.splice(lessonIndex, 1);
    res.sendStatus(204);
});

module.exports = router;