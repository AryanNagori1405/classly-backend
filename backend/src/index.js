require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const pool = require('./config/database');
const authRoutes = require('./routes/auth');
const courseRoutes = require('./routes/courses');
const enrollmentRoutes = require('./routes/enrollments');
const lessonRoutes = require('./routes/lessons');
const quizRoutes = require('./routes/quizzes');
const questionRoutes = require('./routes/questions');
const submissionRoutes = require('./routes/submissions');
const videosRoutes = require('./routes/videos');
const communitiesRoutes = require('./routes/communities');
const timestampsRoutes = require('./routes/timestamps');
const notesRoutes = require('./routes/notes');
const feedbackRoutes = require('./routes/feedback');
const bookmarksRoutes = require('./routes/bookmarks');
const usersRoutes = require('./routes/users');
const { startCleanupSchedule } = require('./jobs/videoCleanupJob');
const analyticsRoutes = require('./routes/analytics');
const adminRoutes = require('./routes/admin');
const notificationsRoutes = require('./routes/notifications');

const app = express();
const PORT = process.env.PORT || 5000;

// ── CORS ─────────────────────────────────────────────────────────────────────
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '')
    .split(',')
    .map(o => o.trim())
    .filter(Boolean);

app.use(cors({
    origin: (origin, callback) => {
        // Allow requests with no origin (mobile apps, Postman, etc.)
        if (!origin) return callback(null, true);
        if (allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
            return callback(null, true);
        }
        callback(new Error('Not allowed by CORS'));
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
}));

// ── Rate limiting ─────────────────────────────────────────────────────────────
// Strict limiter for auth endpoints (OTP / login)
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 20,
    standardHeaders: true,
    legacyHeaders: false,
    message: { message: 'Too many requests. Please try again later.' },
});

// General API limiter
const apiLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 120,
    standardHeaders: true,
    legacyHeaders: false,
    message: { message: 'Rate limit exceeded. Please slow down.' },
});

// General API limiter (applied first, more broad)
app.use('/api/', apiLimiter);
// Stricter limiter applied specifically to auth routes (overrides general for /api/auth)
app.use('/api/auth', authLimiter);

// ── Body parsers ──────────────────────────────────────────────────────────────
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── Database health check ─────────────────────────────────────────────────────
pool.query('SELECT NOW()', (err) => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('✅ Connected to PostgreSQL Database successfully!');
    }
});

// Start video cleanup scheduled job
startCleanupSchedule();

// ── Routes ────────────────────────────────────────────────────────────────────
app.get('/', (_req, res) => {
    res.json({ message: 'Welcome to Classly Backend API', version: '2.0.0' });
});

app.use('/api/auth',          authRoutes);
app.use('/api/courses',       courseRoutes);
app.use('/api/enrollments',   enrollmentRoutes);
app.use('/api/lessons',       lessonRoutes);
app.use('/api/quizzes',       quizRoutes);
app.use('/api/questions',     questionRoutes);
app.use('/api/submissions',   submissionRoutes);
app.use('/api/videos',        videosRoutes);
app.use('/api/communities',   communitiesRoutes);
app.use('/api/timestamps',    timestampsRoutes);
app.use('/api/notes',         notesRoutes);
app.use('/api/feedback',      feedbackRoutes);
app.use('/api/bookmarks',     bookmarksRoutes);
app.use('/api/users',         usersRoutes);
app.use('/api/analytics',     analyticsRoutes);
app.use('/api/admin',         adminRoutes);
app.use('/api/notifications', notificationsRoutes);

// ── Error handler ─────────────────────────────────────────────────────────────
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal Server Error', error: err.message });
});

app.listen(PORT, () => {
    console.log(`✅ Server is running on port ${PORT}`);
});