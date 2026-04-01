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
