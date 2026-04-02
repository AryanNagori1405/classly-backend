const db = require('../config/database');

const Enrollment = {
    // Enroll a student in a course
    enrollStudent: async (studentId, courseId) => {
        try {
            const query = `
                INSERT INTO enrollments (student_id, course_id)
                VALUES ($1, $2)
                RETURNING *
            `;
            return await db.query(query, [studentId, courseId]);
        } catch (error) {
            console.error('Error enrolling student:', error);
            throw error;
        }
    },

    // Get all courses a student is enrolled in
    getStudentEnrollments: async (studentId) => {
        try {
            const query = `
                SELECT e.id, e.student_id, e.course_id, e.created_at, e.updated_at,
                       c.name AS course_name, c.description AS course_description
                FROM enrollments e
                JOIN courses c ON e.course_id = c.id
                WHERE e.student_id = $1
                ORDER BY e.created_at DESC
            `;
            return await db.query(query, [studentId]);
        } catch (error) {
            console.error('Error fetching student enrollments:', error);
            throw error;
        }
    },

    // Get all students enrolled in a course
    getCourseEnrollments: async (courseId) => {
        try {
            const query = `
                SELECT e.id, e.student_id, e.course_id, e.created_at, e.updated_at,
                       u.username, u.email
                FROM enrollments e
                JOIN users u ON e.student_id = u.id
                WHERE e.course_id = $1
                ORDER BY e.created_at DESC
            `;
            return await db.query(query, [courseId]);
        } catch (error) {
            console.error('Error fetching course enrollments:', error);
            throw error;
        }
    },

    // Remove a student from a course
    unenrollStudent: async (studentId, courseId) => {
        try {
            const query = `
                DELETE FROM enrollments
                WHERE student_id = $1 AND course_id = $2
                RETURNING *
            `;
            return await db.query(query, [studentId, courseId]);
        } catch (error) {
            console.error('Error unenrolling student:', error);
            throw error;
        }
    },

    // Check if a student is enrolled in a course
    isEnrolled: async (studentId, courseId) => {
        try {
            const query = `
                SELECT id FROM enrollments
                WHERE student_id = $1 AND course_id = $2
            `;
            const result = await db.query(query, [studentId, courseId]);
            return result.rows.length > 0;
        } catch (error) {
            console.error('Error checking enrollment status:', error);
            throw error;
        }
    },

    // Get total number of students enrolled in a course
    getEnrollmentStats: async (courseId) => {
        try {
            const query = `
                SELECT COUNT(*) AS total_students
                FROM enrollments
                WHERE course_id = $1
            `;
            return await db.query(query, [courseId]);
        } catch (error) {
            console.error('Error fetching enrollment stats:', error);
            throw error;
        }
    },
};

module.exports = Enrollment;
