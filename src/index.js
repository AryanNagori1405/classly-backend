require('dotenv').config();
const express = require('express');
const pool = require('./config/database');
const authRoutes = require('./routes/auth');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

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

// ===== JWT VERIFICATION MIDDLEWARE =====
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

// ===== EMAIL SETUP =====
const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: false,
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD
    }
});

const sendVerificationEmail = async (email, token) => {
    const verificationUrl = `${process.env.CLIENT_URL}/verify-email?token=${token}`;
    
    const mailOptions = {
        from: process.env.SMTP_FROM,
        to: email,
        subject: 'Verify your Classly email',
        html: `
            <h2>Welcome to Classly!</h2>
            <p>Please verify your email by clicking the link below:</p>
            <a href="${verificationUrl}" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">
                Verify Email
            </a>
            <p>Or paste this link in your browser:</p>
            <p>${verificationUrl}</p>
            <p>This link expires in 24 hours.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Verification email sent to ${email}`);
        return true;
    } catch (error) {
        console.error('❌ Error sending email:', error);
        return false;
    }
};

// ===== ROUTES =====
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

// Update user profile
app.put('/api/user/profile', verifyToken, (req, res) => {
    res.json({
        message: "User profile updated",
        user: req.user
    });
});

// Delete user account
app.delete('/api/user/account', verifyToken, (req, res) => {
    res.json({
        message: "User account deleted successfully",
        user: req.user
    });
});

// ===== ERROR HANDLING MIDDLEWARE =====
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal Server Error', error: err.message });
});

app.listen(PORT, () => {
    console.log(`✅ Server is running on port ${PORT}`);
});

module.exports = { sendVerificationEmail };