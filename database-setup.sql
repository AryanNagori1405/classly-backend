-- database-setup.sql
-- Run this script in PostgreSQL to initialise the classly_db database schema.

-- Create database (run manually if it does not already exist)
-- CREATE DATABASE classly_db;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    username    VARCHAR(255) UNIQUE NOT NULL,
    password    VARCHAR(255) NOT NULL,
    role        VARCHAR(50)  NOT NULL DEFAULT 'student',
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Optional: index on username for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- Lessons table
CREATE TABLE IF NOT EXISTS lessons (
    id          SERIAL PRIMARY KEY,
    course_id   INTEGER      NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    content     TEXT,
    video_url   VARCHAR(500),
    duration    INTEGER,
    order_index INTEGER      NOT NULL DEFAULT 0,
    is_published BOOLEAN     NOT NULL DEFAULT false,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons (course_id);
