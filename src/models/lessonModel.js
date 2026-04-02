const pool = require('../config/database');

class Lesson {
    // ===== CREATE LESSON =====
    static async createLesson(courseId, lessonData) {
        const { title, description, content, video_url, duration, order_index } = lessonData;
        const query = `
            INSERT INTO lessons (course_id, title, description, content, video_url, duration, order_index, is_published, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, false, NOW(), NOW())
            RETURNING *
        `;
        return await pool.query(query, [
            courseId,
            title,
            description || null,
            content || null,
            video_url || null,
            duration || null,
            order_index !== undefined ? order_index : 0,
        ]);
    }

    // ===== GET LESSON BY ID =====
    static async getLessonById(lessonId) {
        const query = `SELECT * FROM lessons WHERE id = $1`;
        return await pool.query(query, [lessonId]);
    }

    // ===== GET ALL LESSONS IN A COURSE (for teachers – all lessons) =====
    static async getLessonsByCourse(courseId) {
        const query = `
            SELECT * FROM lessons
            WHERE course_id = $1
            ORDER BY order_index ASC, created_at ASC
        `;
        return await pool.query(query, [courseId]);
    }

    // ===== GET PUBLISHED LESSONS IN A COURSE (for enrolled students) =====
    static async getCourseLessons(courseId) {
        const query = `
            SELECT * FROM lessons
            WHERE course_id = $1 AND is_published = true
            ORDER BY order_index ASC, created_at ASC
        `;
        return await pool.query(query, [courseId]);
    }

    // ===== UPDATE LESSON =====
    static async updateLesson(lessonId, lessonData) {
        const fields = [];
        const values = [];
        let paramIndex = 1;

        const allowedFields = ['title', 'description', 'content', 'video_url', 'duration', 'order_index'];
        for (const field of allowedFields) {
            if (lessonData[field] !== undefined) {
                fields.push(`${field} = $${paramIndex}`);
                values.push(lessonData[field]);
                paramIndex++;
            }
        }

        if (fields.length === 0) {
            return await pool.query('SELECT * FROM lessons WHERE id = $1', [lessonId]);
        }

        fields.push(`updated_at = NOW()`);
        values.push(lessonId);

        const query = `
            UPDATE lessons
            SET ${fields.join(', ')}
            WHERE id = $${paramIndex}
            RETURNING *
        `;
        return await pool.query(query, values);
    }

    // ===== DELETE LESSON =====
    static async deleteLesson(lessonId) {
        const query = `DELETE FROM lessons WHERE id = $1 RETURNING id`;
        return await pool.query(query, [lessonId]);
    }

    // ===== PUBLISH / UNPUBLISH LESSON =====
    static async publishLesson(lessonId) {
        const query = `
            UPDATE lessons
            SET is_published = NOT is_published, updated_at = NOW()
            WHERE id = $1
            RETURNING *
        `;
        return await pool.query(query, [lessonId]);
    }

    // ===== CHECK COURSE EXISTS =====
    static async courseExists(courseId) {
        const query = `SELECT id FROM courses WHERE id = $1 LIMIT 1`;
        const result = await pool.query(query, [courseId]);
        return result.rows.length > 0;
    }

    // ===== GET COURSE INSTRUCTOR =====
    static async getCourseInstructor(courseId) {
        const query = `SELECT instructor_id FROM courses WHERE id = $1 LIMIT 1`;
        const result = await pool.query(query, [courseId]);
        return result.rows.length > 0 ? result.rows[0].instructor_id : null;
    }
}

module.exports = Lesson;
