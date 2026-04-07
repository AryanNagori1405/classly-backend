const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const pool = require('../config/database');
const { sendVerificationEmail } = require('../services/emailService');

exports.register = async (req, res) => {
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    const atIndex = email.indexOf('@');
    const lastDotIndex = email.lastIndexOf('.');
    if (atIndex <= 0 || lastDotIndex <= atIndex + 1 || lastDotIndex >= email.length - 1) {
        return res.status(400).json({ message: 'Invalid email format' });
    }

    try {
        const existingUser = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (existingUser.rows.length > 0) {
            return res.status(400).json({ message: 'User already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const verificationToken = crypto.randomBytes(32).toString('hex');
        const result = await pool.query('INSERT INTO users (email, password, name, verification_token) VALUES ($1, $2, $3, $4) RETURNING id, email, name', [email, hashedPassword, name, verificationToken]);

        const user = result.rows[0];
        await sendVerificationEmail(email, verificationToken);
        return res.status(201).json({ message: 'User registered successfully. Check your email to verify your account.', user });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};

exports.login = async (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userResult.rows[0];
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        if (!user.is_email_verified) {
            return res.status(403).json({ message: 'Please verify your email before logging in' });
        }

        const token = jwt.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1h' });
        return res.status(200).json({ message: 'Login successful', token });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const userResult = await pool.query('SELECT id, email, name, role, profile_picture, bio FROM users WHERE id = $1', [userId]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userResult.rows[0];
        return res.status(200).json({ user });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};

exports.verifyEmail = async (req, res) => {
    const { token } = req.body;
    if (!token) {
        return res.status(400).json({ message: 'Token is required' });
    }

    try {
        const userResult = await pool.query('SELECT * FROM users WHERE verification_token = $1', [token]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'Invalid or expired token' });
        }

        const user = userResult.rows[0];
        await pool.query('UPDATE users SET is_email_verified = true, verification_token = NULL WHERE id = $1', [user.id]);
        return res.status(200).json({ message: 'Email verified successfully! You can now login.' });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};