// Updated code in src/routes/courses.js

const token = req.headers.authorization?.split(' ')[1];

// ... some code ...

jwt.verify(token, process.env.JWT_SECRET, (err, user) => {