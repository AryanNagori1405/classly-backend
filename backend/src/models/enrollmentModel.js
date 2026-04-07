const pool = require('../config/database');

class Enrollment {
    static async enrollStudent(studentId, courseId) {
        const query = `
            INSERT INTO enrollments (student_id, course_id, created_at)
            VALUES ($1, $2, NOW())
            RETURNING id, student_id, course_id, created_at
        `;
        return await pool.query(query, [studentId, courseId]);
    }

    static async getStudentEnrollments(studentId) {
        const query = `
            SELECT 
                e.id,
                e.student_id,
                c.id as course_id,
                c.title as course_name,
                c.description,
                e.created_at as enrolled_at
            FROM enrollments e
            JOIN courses c ON e.course_id = c.id
            WHERE e.student_id = $1
            ORDER BY e.created_at DESC
        `;
        return await pool.query(query, [studentId]);
    }

    static async getCourseEnrollments(courseId) {
        const query = `
            SELECT 
                e.id,
                e.student_id,
                c.id as course_id,
                c.title as course_name,
                e.created_at as enrolled_at
            FROM enrollments e
            JOIN courses c ON e.course_id = c.id
            WHERE e.course_id = $1
            ORDER BY e.created_at DESC
        `;
        return await pool.query(query, [courseId]);
    }

    static async unenrollStudent(studentId, courseId) {
        const query = `
            DELETE FROM enrollments
            WHERE student_id = $1 AND course_id = $2
            RETURNING id
        `;
        return await pool.query(query, [studentId, courseId]);
    }

    static async isEnrolled(studentId, courseId) {
        const query = `
            SELECT id FROM enrollments
            WHERE student_id = $1 AND course_id = $2
            LIMIT 1
        `;
        const result = await pool.query(query, [studentId, courseId]);
        return result.rows.length > 0;
    }

    static async getEnrollmentStats(courseId) {
        const query = `
            SELECT 
                c.id as course_id,
                c.title as course_name,
                COUNT(e.id) as total_students,
                MAX(e.created_at) as latest_enrollment
            FROM courses c
            LEFT JOIN enrollments e ON c.id = e.course_id
            WHERE c.id = $1
            GROUP BY c.id, c.title
        `;
        return await pool.query(query, [courseId]);
    }
}

module.exports = Enrollment;