require('dotenv').config();
const express = require('express');
const pool = require('./config/database');
const authRoutes = require('./routes/auth');
const jwt = require('jsonwebtoken'); // Add this line

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('✅ Connected to PostgreSQL Database successfully!');
    }
});

// ===== VERIFY TOKEN MIDDLEWARE =====
const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ message: "No token provided" });
    }
    
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: "Invalid or expired token" });
        }
        req.user = decoded;
        next();
    });
};

// Routes
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to Classly Backend API' });
});

// Auth Routes
app.use('/api/auth', authRoutes);

// ===== PROTECTED ROUTES =====
// Get user profile
app.get('/api/user/profile', verifyToken, (req, res) => {
    res.json({
        message: "User profile retrieved",
        user: {
            id: req.user.id,
            email: req.user.email
        }
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal Server Error', error: err.message });
});

app.listen(PORT, () => {
    console.log(`✅ Server is running on port ${PORT}`);
});