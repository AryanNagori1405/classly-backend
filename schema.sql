-- =========================================================
-- DROP EXISTING TABLES (IF THEY EXIST)
-- =========================================================
DROP TABLE IF EXISTS student_watch_history CASCADE;
DROP TABLE IF EXISTS bookmarks CASCADE;
DROP TABLE IF EXISTS video_downloads CASCADE;
DROP TABLE IF EXISTS video_engagement CASCADE;
DROP TABLE IF EXISTS student_contributions CASCADE;
DROP TABLE IF EXISTS anonymous_feedback CASCADE;
DROP TABLE IF EXISTS community_post_likes CASCADE;
DROP TABLE IF EXISTS community_posts CASCADE;
DROP TABLE IF EXISTS community_members CASCADE;
DROP TABLE IF EXISTS communities CASCADE;
DROP TABLE IF EXISTS timestamp_comments CASCADE;
DROP TABLE IF EXISTS video_timestamps CASCADE;
DROP TABLE IF EXISTS video_notes CASCADE;
DROP TABLE IF EXISTS videos CASCADE;
DROP TABLE IF EXISTS users CASCADE;
-- =========================================================
-- USERS TABLE (NEW SCHEMA)
-- =========================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    reg_no VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'teacher', 'admin')),
    password_hash VARCHAR(255),
    profile_image TEXT,
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_reg_no ON users (reg_no);
CREATE INDEX idx_users_email ON users (email);
CREATE INDEX idx_users_role ON users (role);
-- =========================================================
-- VIDEOS TABLE (WITH 7-DAY EXPIRY)
-- =========================================================
CREATE TABLE videos (
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    subject VARCHAR(255),
    category VARCHAR(255),
    file_url TEXT NOT NULL,
    thumbnail_url TEXT,
    duration INTEGER,
    file_size BIGINT,
    is_public BOOLEAN DEFAULT TRUE,
    is_pinned BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    downloads_count INTEGER DEFAULT 0,
    upvotes INTEGER DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP GENERATED ALWAYS AS (created_at + INTERVAL '7 days') STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_videos_teacher_id ON videos (teacher_id);
CREATE INDEX idx_videos_category ON videos (category);
CREATE INDEX idx_videos_subject ON videos (subject);
CREATE INDEX idx_videos_created_at ON videos (created_at);
CREATE INDEX idx_videos_expires_at ON videos (expires_at);
-- =========================================================
-- VIDEO NOTES TABLE
-- =========================================================
CREATE TABLE video_notes (
    id SERIAL PRIMARY KEY,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    note_title VARCHAR(500) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(20),
    uploaded_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_video_notes_video_id ON video_notes (video_id);
-- =========================================================
-- VIDEO TIMESTAMPS (DOUBTS) TABLE
-- =========================================================
CREATE TABLE video_timestamps (
    id SERIAL PRIMARY KEY,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timestamp_value VARCHAR(20) NOT NULL,
    question_text TEXT NOT NULL,
    is_resolved BOOLEAN DEFAULT FALSE,
    teacher_response TEXT,
    resolved_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_timestamps_video_id ON video_timestamps (video_id);
CREATE INDEX idx_timestamps_student_id ON video_timestamps (student_id);
CREATE INDEX idx_timestamps_is_resolved ON video_timestamps (is_resolved);
-- =========================================================
-- TIMESTAMP COMMENTS TABLE
-- =========================================================
CREATE TABLE timestamp_comments (
    id SERIAL PRIMARY KEY,
    timestamp_id INTEGER NOT NULL REFERENCES video_timestamps(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_ts_comments_timestamp_id ON timestamp_comments (timestamp_id);
CREATE INDEX idx_ts_comments_user_id ON timestamp_comments (user_id);
-- =========================================================
-- COMMUNITIES TABLE
-- =========================================================
CREATE TABLE communities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    image_url TEXT,
    created_by INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_private BOOLEAN DEFAULT FALSE,
    is_disabled BOOLEAN DEFAULT FALSE,
    member_count INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_communities_created_by ON communities (created_by);
CREATE INDEX idx_communities_category ON communities (category);
-- =========================================================
-- COMMUNITY MEMBERS TABLE
-- =========================================================
CREATE TABLE community_members (
    id SERIAL PRIMARY KEY,
    community_id INTEGER NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'moderator', 'member')),
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (community_id, user_id)
);
CREATE INDEX idx_community_members_community_id ON community_members (community_id);
CREATE INDEX idx_community_members_user_id ON community_members (user_id);
-- =========================================================
-- COMMUNITY POSTS TABLE
-- =========================================================
CREATE TABLE community_posts (
    id SERIAL PRIMARY KEY,
    community_id INTEGER NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes INTEGER DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_community_posts_community_id ON community_posts (community_id);
CREATE INDEX idx_community_posts_user_id ON community_posts (user_id);
-- =========================================================
-- COMMUNITY POST LIKES TABLE
-- =========================================================
CREATE TABLE community_post_likes (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id)
);
CREATE INDEX idx_community_post_likes_post_id ON community_post_likes (post_id);
CREATE INDEX idx_community_post_likes_user_id ON community_post_likes (user_id);
-- =========================================================
-- ANONYMOUS FEEDBACK TABLE (WITH ADMIN OVERSIGHT)
-- =========================================================
CREATE TABLE anonymous_feedback (
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50),
    message TEXT NOT NULL,
    ip_address VARCHAR(60),
    device_info TEXT,
    user_agent TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    teacher_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_feedback_teacher_id ON anonymous_feedback (teacher_id);
CREATE INDEX idx_feedback_sender_id ON anonymous_feedback (sender_user_id);
CREATE INDEX idx_feedback_created_at ON anonymous_feedback (created_at);
-- =========================================================
-- STUDENT CONTRIBUTIONS TABLE
-- =========================================================
CREATE TABLE student_contributions (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    related_video_id INTEGER REFERENCES videos(id) ON DELETE
    SET NULL,
        title VARCHAR(500) NOT NULL,
        description TEXT,
        file_url TEXT NOT NULL,
        file_type VARCHAR(20),
        views_count INTEGER DEFAULT 0,
        upvotes INTEGER DEFAULT 0,
        is_approved BOOLEAN DEFAULT TRUE,
        is_deleted BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_contributions_student_id ON student_contributions (student_id);
CREATE INDEX idx_contributions_video_id ON student_contributions (related_video_id);
CREATE INDEX idx_contributions_created_at ON student_contributions (created_at);
-- =========================================================
-- VIDEO ENGAGEMENT TABLE (UPVOTES/RECOMMENDATIONS)
-- =========================================================
CREATE TABLE video_engagement (
    id SERIAL PRIMARY KEY,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (video_id, user_id, type)
);
CREATE INDEX idx_video_engagement_video_id ON video_engagement (video_id);
CREATE INDEX idx_video_engagement_user_id ON video_engagement (user_id);
-- =========================================================
-- VIDEO DOWNLOADS TABLE
-- =========================================================
CREATE TABLE video_downloads (
    id SERIAL PRIMARY KEY,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_video_downloads_video_id ON video_downloads (video_id);
CREATE INDEX idx_video_downloads_user_id ON video_downloads (user_id);
-- =========================================================
-- BOOKMARKS TABLE
-- =========================================================
CREATE TABLE bookmarks (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);
CREATE INDEX idx_bookmarks_user_id ON bookmarks (user_id);
CREATE INDEX idx_bookmarks_video_id ON bookmarks (video_id);
-- =========================================================
-- WATCH HISTORY TABLE
-- =========================================================
CREATE TABLE student_watch_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id INTEGER NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    last_watch_time INTEGER,
    watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);
CREATE INDEX idx_watch_history_user_id ON student_watch_history (user_id);
CREATE INDEX idx_watch_history_video_id ON student_watch_history (video_id);
-- =========================================================
-- SEED TEST DATA
-- =========================================================
INSERT INTO users (
        reg_no,
        name,
        email,
        phone,
        role,
        password_hash,
        is_verified,
        is_active
    )
VALUES (
        'ADMIN001',
        'System Admin',
        'admin@college.edu',
        '9000000001',
        'admin',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36MM4oimu',
        TRUE,
        TRUE
    ),
    (
        'CSE2024001',
        'Test Student',
        'student@college.edu',
        '9876543210',
        'student',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36MM4oimu',
        TRUE,
        TRUE
    ),
    (
        'CSE2024002',
        'Another Student',
        'student2@college.edu',
        '9876543211',
        'student',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36MM4oimu',
        TRUE,
        TRUE
    ),
    (
        'TCH001',
        'Test Teacher',
        'teacher@college.edu',
        '9876543220',
        'teacher',
        '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36MM4oimu',
        TRUE,
        TRUE
    );
-- =========================================================
-- VERIFY SETUP
-- =========================================================
\ dt
SELECT COUNT(*) as total_users
FROM users;
SELECT COUNT(*) as total_tables
FROM information_schema.tables
WHERE table_schema = 'public';