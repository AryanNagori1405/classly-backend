-- database-setup.sql
-- Run this script in PostgreSQL to initialise the classly_db database schema.
-- Usage: psql -U postgres -d classly_db -f database-setup.sql

-- Create database (run manually if it does not already exist)
-- CREATE DATABASE classly_db;

-- Enable uuid extension (optional, for uuid generation)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================================
-- USERS TABLE
-- Authentication via Registration Number + Password
-- =====================================================================
CREATE TABLE IF NOT EXISTS users (
    id                  SERIAL PRIMARY KEY,
    reg_no              VARCHAR(100) UNIQUE NOT NULL,
    name                VARCHAR(255) NOT NULL,
    email               VARCHAR(255) UNIQUE NOT NULL,
    phone               VARCHAR(20)  NOT NULL,
    role                VARCHAR(20)  NOT NULL DEFAULT 'student'
                            CHECK (role IN ('student', 'teacher', 'admin')),
    password_hash       VARCHAR(255),
    profile_image       TEXT,
    bio                 TEXT,
    is_verified         BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_reg_no ON users (reg_no);
CREATE INDEX IF NOT EXISTS idx_users_email  ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_role   ON users (role);

-- =====================================================================
-- COURSES (defined before videos so the FK can reference it)
-- =====================================================================
CREATE TABLE IF NOT EXISTS courses (
    id                  SERIAL PRIMARY KEY,
    title               VARCHAR(500) NOT NULL,
    description         TEXT,
    created_by          INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enable_videos       BOOLEAN      NOT NULL DEFAULT TRUE,
    enable_communities  BOOLEAN      NOT NULL DEFAULT TRUE,
    videos_count        INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- ENROLLMENTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS enrollments (
    id          SERIAL PRIMARY KEY,
    course_id   INTEGER  NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_id  INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_course_id   ON enrollments (course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id  ON enrollments (student_id);

-- =====================================================================
-- LESSONS (kept for backward compatibility)
-- =====================================================================
CREATE TABLE IF NOT EXISTS lessons (
    id          SERIAL PRIMARY KEY,
    course_id   INTEGER  NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(500) NOT NULL,
    content     TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- VIDEOS / LECTURES TABLE
-- Auto-deleted after 7 days via scheduled job
-- =====================================================================
CREATE TABLE IF NOT EXISTS videos (
    id                  SERIAL PRIMARY KEY,
    teacher_id          INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id           INTEGER      REFERENCES courses(id) ON DELETE SET NULL,
    title               VARCHAR(500) NOT NULL,
    description         TEXT,
    subject             VARCHAR(255),
    department          VARCHAR(255),
    file_url            TEXT         NOT NULL,
    thumbnail_url       TEXT,
    duration            INTEGER,                 -- seconds
    file_size           BIGINT,                  -- bytes
    subject_category    VARCHAR(255),
    is_public           BOOLEAN      NOT NULL DEFAULT TRUE,
    is_deleted          BOOLEAN      NOT NULL DEFAULT FALSE,
    is_pinned           BOOLEAN      NOT NULL DEFAULT FALSE,
    views_count         INTEGER      NOT NULL DEFAULT 0,
    downloads_count     INTEGER      NOT NULL DEFAULT 0,
    upvotes             INTEGER      NOT NULL DEFAULT 0,
    deleted_at          TIMESTAMP,
    expires_at          TIMESTAMP    GENERATED ALWAYS AS
                            (created_at + INTERVAL '7 days') STORED,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_videos_teacher_id  ON videos (teacher_id);
CREATE INDEX IF NOT EXISTS idx_videos_is_deleted  ON videos (is_deleted);
CREATE INDEX IF NOT EXISTS idx_videos_created_at  ON videos (created_at);
CREATE INDEX IF NOT EXISTS idx_videos_subject     ON videos (subject_category);

-- =====================================================================
-- VIDEO NOTES / DOCUMENTS
-- Teachers attach PDF, DOCX, PPTX, etc. to a video
-- =====================================================================
CREATE TABLE IF NOT EXISTS video_notes (
    id              SERIAL PRIMARY KEY,
    video_id        INTEGER      NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    note_title      VARCHAR(500) NOT NULL,
    file_url        TEXT         NOT NULL,
    file_type       VARCHAR(20)  DEFAULT 'pdf',
    uploaded_by     INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_official     BOOLEAN      NOT NULL DEFAULT TRUE,
    is_approved     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_video_notes_video_id ON video_notes (video_id);

-- =====================================================================
-- VIDEO TIMESTAMP DOUBTS
-- Students ask doubts at specific timestamps in a video
-- =====================================================================
CREATE TABLE IF NOT EXISTS video_timestamps (
    id               SERIAL PRIMARY KEY,
    video_id         INTEGER      NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    student_id       INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timestamp_value  VARCHAR(20)  NOT NULL,       -- HH:MM:SS format
    question_text    TEXT         NOT NULL,
    is_resolved      BOOLEAN      NOT NULL DEFAULT FALSE,
    teacher_response TEXT,
    resolved_by      INTEGER      REFERENCES users(id),
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_timestamps_video_id ON video_timestamps (video_id);

-- =====================================================================
-- TIMESTAMP COMMENTS (threaded replies on doubts)
-- =====================================================================
CREATE TABLE IF NOT EXISTS timestamp_comments (
    id              SERIAL PRIMARY KEY,
    timestamp_id    INTEGER      NOT NULL REFERENCES video_timestamps(id) ON DELETE CASCADE,
    user_id         INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment_text    TEXT         NOT NULL,
    is_anonymous    BOOLEAN      NOT NULL DEFAULT FALSE,
    is_deleted      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ts_comments_timestamp_id ON timestamp_comments (timestamp_id);

-- =====================================================================
-- VIDEO ENGAGEMENT (upvotes / recommendations)
-- =====================================================================
CREATE TABLE IF NOT EXISTS video_engagement (
    id          SERIAL PRIMARY KEY,
    video_id    INTEGER  NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id     INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(30) NOT NULL DEFAULT 'upvote',
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (video_id, user_id, type)
);

-- =====================================================================
-- VIDEO DOWNLOADS
-- =====================================================================
CREATE TABLE IF NOT EXISTS video_downloads (
    id              SERIAL PRIMARY KEY,
    video_id        INTEGER  NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id         INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    downloaded_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- STUDENT WATCH HISTORY
-- Tracks resume position for each video per user
-- =====================================================================
CREATE TABLE IF NOT EXISTS student_watch_history (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id        INTEGER  NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    last_watch_time INTEGER  NOT NULL DEFAULT 0,  -- seconds from start
    watched_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);

-- =====================================================================
-- VIDEO AUDIT LOG
-- =====================================================================
CREATE TABLE IF NOT EXISTS video_audit_log (
    id          SERIAL PRIMARY KEY,
    video_id    INTEGER  NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    action      VARCHAR(50) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- BOOKMARKS
-- =====================================================================
CREATE TABLE IF NOT EXISTS bookmarks (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id    INTEGER  NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);

-- =====================================================================
-- STUDENT CONTRIBUTIONS
-- Students upload supplementary videos to help peers
-- =====================================================================
CREATE TABLE IF NOT EXISTS student_contributions (
    id               SERIAL PRIMARY KEY,
    student_id       INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    related_video_id INTEGER      REFERENCES videos(id) ON DELETE SET NULL,
    title            VARCHAR(500) NOT NULL,
    description      TEXT,
    file_url         TEXT         NOT NULL,
    file_type        VARCHAR(20)  DEFAULT 'video',
    views_count      INTEGER      NOT NULL DEFAULT 0,
    upvotes          INTEGER      NOT NULL DEFAULT 0,
    is_approved      BOOLEAN      NOT NULL DEFAULT TRUE,
    is_deleted       BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_contributions_student_id  ON student_contributions (student_id);
CREATE INDEX IF NOT EXISTS idx_contributions_video_id    ON student_contributions (related_video_id);

-- =====================================================================
-- COMMUNITIES
-- Students create communities for discussion
-- =====================================================================
CREATE TABLE IF NOT EXISTS communities (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(500) NOT NULL,
    description     TEXT,
    category        VARCHAR(255),
    image_url       TEXT,
    created_by      INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_private      BOOLEAN      NOT NULL DEFAULT FALSE,
    is_disabled     BOOLEAN      NOT NULL DEFAULT FALSE,
    member_count    INTEGER      NOT NULL DEFAULT 1,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_communities_created_by ON communities (created_by);

-- =====================================================================
-- COMMUNITY MEMBERS
-- =====================================================================
CREATE TABLE IF NOT EXISTS community_members (
    id              SERIAL PRIMARY KEY,
    community_id    INTEGER  NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id         INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL DEFAULT 'member'
                        CHECK (role IN ('owner', 'moderator', 'member')),
    joined_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (community_id, user_id)
);

-- =====================================================================
-- COMMUNITY POSTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS community_posts (
    id              SERIAL PRIMARY KEY,
    community_id    INTEGER  NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id         INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content         TEXT     NOT NULL,
    likes           INTEGER  NOT NULL DEFAULT 0,
    reply_count     INTEGER  NOT NULL DEFAULT 0,
    is_deleted      BOOLEAN  NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_community_posts_community_id ON community_posts (community_id);

-- =====================================================================
-- COMMUNITY POST LIKES
-- =====================================================================
CREATE TABLE IF NOT EXISTS community_post_likes (
    id          SERIAL PRIMARY KEY,
    post_id     INTEGER  NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id     INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id)
);

-- =====================================================================
-- ANONYMOUS FEEDBACK
-- Students send anonymous suggestions to teachers.
-- Admin can see the real sender; teacher cannot.
-- =====================================================================
CREATE TABLE IF NOT EXISTS anonymous_feedback (
    id                  SERIAL PRIMARY KEY,
    teacher_id          INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sender_user_id      INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category            VARCHAR(50)  NOT NULL DEFAULT 'suggestion'
                            CHECK (category IN ('suggestion', 'bug', 'improvement', 'other')),
    message             TEXT         NOT NULL,
    ip_address          VARCHAR(60),
    device_info         TEXT,
    is_read             BOOLEAN      NOT NULL DEFAULT FALSE,
    teacher_response    TEXT,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_feedback_teacher_id ON anonymous_feedback (teacher_id);

-- =====================================================================
-- ADMIN ACTIONS LOG
-- =====================================================================
CREATE TABLE IF NOT EXISTS admin_actions_log (
    id              SERIAL PRIMARY KEY,
    admin_id        INTEGER  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type     VARCHAR(100) NOT NULL,
    target_user_id  INTEGER  REFERENCES users(id),
    description     TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- SEED: Default admin user (password: Admin@123)
-- =====================================================================
INSERT INTO users (reg_no, name, email, phone, role, password_hash, is_verified, is_active)
VALUES ('ADMIN001', 'System Admin', 'admin@college.edu', '9000000001', 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeUxWdeS86E36MM4oimu', TRUE, TRUE)
ON CONFLICT (reg_no) DO NOTHING;
