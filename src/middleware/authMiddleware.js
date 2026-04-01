const jwt = require('jsonwebtoken');

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(403).send('A token is required for authentication');
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) return res.status(401).send('Invalid Token');
        req.user = decoded;
        next();
    });
};

// Middleware to check if user is a Teacher
const isTeacher = (req, res, next) => {
    if (req.user.role === 'teacher') {
        next();
    } else {
        return res.status(403).send('Access denied! Not a teacher.');
    }
};

// Middleware to check if user is an Admin
const isAdmin = (req, res, next) => {
    if (req.user.role === 'admin') {
        next();
    } else {
        return res.status(403).send('Access denied! Not an admin.');
    }
};

module.exports = { verifyToken, isTeacher, isAdmin };