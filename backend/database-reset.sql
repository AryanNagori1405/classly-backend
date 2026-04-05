-- =============================================================================
-- database-reset.sql
-- Drops and fully recreates the classly_db PostgreSQL database from scratch.
--
-- Usage (run as the postgres superuser from the classly/backend directory):
--   psql -U postgres -f database-reset.sql
--
-- Steps performed:
--   1. Drop existing classly_db (if it exists)
--   2. Create fresh classly_db
--   3. Connect to classly_db
--   4. Enable extensions
--   5. Create all tables + indexes
--   6. Insert seed data (admin, test student, test teacher)
-- =============================================================================

-- Step 1 – drop the existing database (cannot be done while connected to it)
DROP DATABASE IF EXISTS classly_db;

-- Step 2 – create a fresh database
CREATE DATABASE classly_db;

-- Step 3 – switch to the new database
\c classly_db

-- Step 4 – enable extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- USERS TABLE
-- Authentication via UID or Registration ID + OTP (no password)
-- =============================================================================
CREATE TABLE users (
    id                  SERIAL PRIMARY KEY,
    uid                 VARCHAR(100) UNIQUE,
    reg_id              VARCHAR(100) UNIQUE,
    name                VARCHAR(255) NOT NULL,
    email               VARCHAR(255),
    phone               VARCHAR(30),
    role                VARCHAR(20)  NOT NULL DEFAULT 'student'
                            CHECK (role IN ('student', 'teacher', 'admin')),
    department          VARCHAR(255),
    semester            VARCHAR(20),
    profile_image       TEXT,
    bio                 TEXT,
    is_verified         BOOLEAN      NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    otp_code            VARCHAR(10),
    otp_expires_at      TIMESTAMP,
    otp_attempts        INTEGER      NOT NULL DEFAULT 0,
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_uid    ON users (uid);
CREATE INDEX idx_users_reg_id ON users (reg_id);
CREATE INDEX idx_users_role   ON users (role);

-- =============================================================================
-- VIDEOS / LECTURES TABLE
-- Auto-deleted after 7 days via scheduled job
-- =============================================================================
CREATE TABLE videos (
    id                  SERIAL PRIMARY KEY,
    teacher_id          INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
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

CREATE INDEX idx_videos_teacher_id  ON videos (teacher_id);
CREATE INDEX idx_videos_is_deleted  ON videos (is_deleted);
CREATE INDEX idx_videos_is_public   ON videos (is_public);
CREATE INDEX idx_videos_created_at  ON videos (created_at);
CREATE INDEX idx_videos_subject     ON videos (subject_category);

-- =============================================================================
-- VIDEO NOTES / DOCUMENTS
-- Teachers attach PDF, DOCX, PPTX, etc. to a video
-- =============================================================================
CREATE TABLE video_notes (
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

CREATE INDEX idx_video_notes_video_id ON video_notes (video_id);

-- =============================================================================
-- VIDEO TIMESTAMP DOUBTS
-- Students ask doubts at specific timestamps in a video
-- =============================================================================
CREATE TABLE video_timestamps (
    id              SERIAL PRIMARY KEY,
    video_id        INTEGER      NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    student_id      INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    timestamp_value VARCHAR(20)  NOT NULL,       -- HH:MM:SS format
    question_text   TEXT         NOT NULL,
    is_resolved     BOOLEAN      NOT NULL DEFAULT FALSE,
    resolved_by     INTEGER      REFERENCES users(id),
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timestamps_video_id   ON video_timestamps (video_id);
CREATE INDEX idx_timestamps_student_id ON video_timestamps (student_id);

-- =============================================================================
-- TIMESTAMP COMMENTS (threaded replies on doubts)
-- =============================================================================
CREATE TABLE timestamp_comments (
    id              SERIAL PRIMARY KEY,
    timestamp_id    INTEGER      NOT NULL REFERENCES video_timestamps(id) ON DELETE CASCADE,
    user_id         INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    comment_text    TEXT         NOT NULL,
    is_anonymous    BOOLEAN      NOT NULL DEFAULT FALSE,
    is_deleted      BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ts_comments_timestamp_id ON timestamp_comments (timestamp_id);

-- =============================================================================
-- VIDEO ENGAGEMENT (upvotes / recommendations)
-- =============================================================================
CREATE TABLE video_engagement (
    id          SERIAL PRIMARY KEY,
    video_id    INTEGER     NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id     INTEGER     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        VARCHAR(30) NOT NULL DEFAULT 'upvote',
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (video_id, user_id, type)
);

-- =============================================================================
-- VIDEO DOWNLOADS
-- =============================================================================
CREATE TABLE video_downloads (
    id              SERIAL PRIMARY KEY,
    video_id        INTEGER   NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    user_id         INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    downloaded_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_video_downloads_video_id ON video_downloads (video_id);
CREATE INDEX idx_video_downloads_user_id  ON video_downloads (user_id);

-- =============================================================================
-- STUDENT WATCH HISTORY
-- =============================================================================
CREATE TABLE student_watch_history (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id    INTEGER   NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    watched_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);

CREATE INDEX idx_watch_history_user_id  ON student_watch_history (user_id);
CREATE INDEX idx_watch_history_video_id ON student_watch_history (video_id);

-- =============================================================================
-- BOOKMARKS
-- =============================================================================
CREATE TABLE bookmarks (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    video_id    INTEGER   NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, video_id)
);

CREATE INDEX idx_bookmarks_user_id  ON bookmarks (user_id);
CREATE INDEX idx_bookmarks_video_id ON bookmarks (video_id);

-- =============================================================================
-- VIDEO AUDIT LOG
-- =============================================================================
CREATE TABLE video_audit_log (
    id          SERIAL PRIMARY KEY,
    video_id    INTEGER     NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
    action      VARCHAR(50) NOT NULL,
    description TEXT,
    created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_log_video_id ON video_audit_log (video_id);

-- =============================================================================
-- COMMUNITIES
-- Students create communities for discussion
-- =============================================================================
CREATE TABLE communities (
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

CREATE INDEX idx_communities_created_by ON communities (created_by);
CREATE INDEX idx_communities_is_private ON communities (is_private);

-- =============================================================================
-- COMMUNITY MEMBERS
-- =============================================================================
CREATE TABLE community_members (
    id              SERIAL PRIMARY KEY,
    community_id    INTEGER     NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id         INTEGER     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role            VARCHAR(20) NOT NULL DEFAULT 'member'
                        CHECK (role IN ('owner', 'moderator', 'member')),
    joined_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (community_id, user_id)
);

CREATE INDEX idx_community_members_community_id ON community_members (community_id);
CREATE INDEX idx_community_members_user_id      ON community_members (user_id);

-- =============================================================================
-- COMMUNITY POSTS
-- =============================================================================
CREATE TABLE community_posts (
    id              SERIAL PRIMARY KEY,
    community_id    INTEGER   NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id         INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content         TEXT      NOT NULL,
    likes           INTEGER   NOT NULL DEFAULT 0,
    reply_count     INTEGER   NOT NULL DEFAULT 0,
    is_deleted      BOOLEAN   NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_community_posts_community_id ON community_posts (community_id);
CREATE INDEX idx_community_posts_user_id      ON community_posts (user_id);

-- =============================================================================
-- COMMUNITY POST LIKES
-- =============================================================================
CREATE TABLE community_post_likes (
    id          SERIAL PRIMARY KEY,
    post_id     INTEGER   NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id     INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id)
);

CREATE INDEX idx_post_likes_post_id ON community_post_likes (post_id);

-- =============================================================================
-- ANONYMOUS FEEDBACK
-- Students send anonymous suggestions to teachers.
-- Admin can see the real sender; teacher cannot.
-- =============================================================================
CREATE TABLE anonymous_feedback (
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

CREATE INDEX idx_feedback_teacher_id ON anonymous_feedback (teacher_id);

-- =============================================================================
-- ADMIN ACTIONS LOG
-- =============================================================================
CREATE TABLE admin_actions_log (
    id              SERIAL PRIMARY KEY,
    admin_id        INTEGER      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type     VARCHAR(100) NOT NULL,
    target_user_id  INTEGER      REFERENCES users(id),
    description     TEXT,
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_admin_log_admin_id ON admin_actions_log (admin_id);

-- =============================================================================
-- COURSES (kept for backward compatibility with existing routes)
-- =============================================================================
CREATE TABLE courses (
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

-- =============================================================================
-- ENROLLMENTS (kept for backward compatibility)
-- =============================================================================
CREATE TABLE enrollments (
    id          SERIAL PRIMARY KEY,
    course_id   INTEGER   NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_id  INTEGER   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, student_id)
);

CREATE INDEX idx_enrollments_course_id  ON enrollments (course_id);
CREATE INDEX idx_enrollments_student_id ON enrollments (student_id);

-- =============================================================================
-- LESSONS (kept for backward compatibility)
-- =============================================================================
CREATE TABLE lessons (
    id          SERIAL PRIMARY KEY,
    course_id   INTEGER      NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(500) NOT NULL,
    content     TEXT,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lessons_course_id ON lessons (course_id);

-- =============================================================================
-- SEED DATA
-- Default users for development / testing.
-- No passwords – auth is UID/RegID + OTP.
-- =============================================================================

-- Admin
INSERT INTO users (uid, reg_id, name, role, is_verified, is_active)
VALUES ('ADMIN001', 'ADMIN-REG-001', 'System Admin', 'admin', TRUE, TRUE);

-- Test Student
INSERT INTO users (uid, reg_id, name, email, role, department, semester, is_verified, is_active)
VALUES ('STU001', '202401001', 'Test Student', 'student@test.com', 'student', 'CSE', '4', TRUE, TRUE);

-- Test Teacher
INSERT INTO users (uid, reg_id, name, email, role, department, is_verified, is_active)
VALUES ('TCH001', '202301001', 'Test Teacher', 'teacher@test.com', 'teacher', 'CSE', TRUE, TRUE);

-- =============================================================================
-- Done! Verify with:
--   \dt                      -- list all tables
--   SELECT id, uid, reg_id, name, role FROM users;
-- =============================================================================
