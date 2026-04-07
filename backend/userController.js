const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');

// Register User Function
exports.register = async (req, res) => {
    const { username, password } = req.body;

    // Validate input
    if (!username || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        // Check if user already exists
        const userExists = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
        if (userExists.rows.length > 0) {
            return res.status(400).json({ message: 'User already exists' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user in database
        const newUser = await pool.query(
            'INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id, username',
            [username, hashedPassword]
        );

        return res.status(201).json({
            message: 'User registered successfully',
            user: newUser.rows[0]
        });
    } catch (error) {
        console.error('Registration error:', error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};

// Login User Function
exports.login = async (req, res) => {
    const { username, password } = req.body;

    // Validate input
    if (!username || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    try {
        // Find user
        const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
        const user = result.rows[0];

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Compare password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Generate token
        const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });

        return res.status(200).json({
            message: 'Login successful',
            token,
            user: { id: user.id, username: user.username }
        });
    } catch (error) {
        console.error('Login error:', error);
        return res.status(500).json({ message: 'Internal Server Error', error: error.message });
    }
};
