const db = require('../config/db'); // Assuming there's a db config

const Course = {
    // Function to create a new course
    createCourse: async (courseData) => {
        const query = 'INSERT INTO courses (name, description) VALUES (?, ?)';
        return db.query(query, [courseData.name, courseData.description]);
    },

    // Function to get all courses
    getAllCourses: async () => {
        const query = 'SELECT * FROM courses';
        return db.query(query);
    },

    // Function to get a course by ID
    getCourseById: async (id) => {
        const query = 'SELECT * FROM courses WHERE id = ?';
        return db.query(query, [id]);
    },

    // Function to update a course
    updateCourse: async (id, courseData) => {
        const query = 'UPDATE courses SET name = ?, description = ? WHERE id = ?';
        return db.query(query, [courseData.name, courseData.description, id]);
    },

    // Function to delete a course
    deleteCourse: async (id) => {
        const query = 'DELETE FROM courses WHERE id = ?';
        return db.query(query, [id]);
    },
};

const Enrollment = {
    // Function to enroll a student in a course
    enrollStudent: async (courseId, studentId) => {
        const query = 'INSERT INTO enrollments (course_id, student_id) VALUES (?, ?)';
        return db.query(query, [courseId, studentId]);
    },

    // Function to get all enrollments for a course
    getEnrollmentsByCourseId: async (courseId) => {
        const query = 'SELECT * FROM enrollments WHERE course_id = ?';
        return db.query(query, [courseId]);
    },

    // Function to get all courses a student is enrolled in
    getCoursesByStudentId: async (studentId) => {
        const query = 'SELECT * FROM enrollments WHERE student_id = ?';
        return db.query(query, [studentId]);
    },
};

const Lesson = {
    // Function to create a new lesson
    createLesson: async (lessonData) => {
        const query = 'INSERT INTO lessons (course_id, title, content) VALUES (?, ?, ?)';
        return db.query(query, [lessonData.course_id, lessonData.title, lessonData.content]);
    },

    // Function to get all lessons for a course
    getLessonsByCourseId: async (courseId) => {
        const query = 'SELECT * FROM lessons WHERE course_id = ?';
        return db.query(query, [courseId]);
    },

    // Function to update a lesson
    updateLesson: async (id, lessonData) => {
        const query = 'UPDATE lessons SET title = ?, content = ? WHERE id = ?';
        return db.query(query, [lessonData.title, lessonData.content, id]);
    },

    // Function to delete a lesson
    deleteLesson: async (id) => {
        const query = 'DELETE FROM lessons WHERE id = ?';
        return db.query(query, [id]);
    },
};

module.exports = { Course, Enrollment, Lesson };