const db = require('../config/database');

const Course = {
    createCourse: async (courseData) => {
        const query = 'INSERT INTO courses (title, description) VALUES ($1, $2)';
        return db.query(query, [courseData.title, courseData.description]);
    },

    getAllCourses: async () => {
        const query = 'SELECT * FROM courses';
        return db.query(query);
    },

    getCourseById: async (id) => {
        const query = 'SELECT * FROM courses WHERE id = $1';
        return db.query(query, [id]);
    },

    updateCourse: async (id, courseData) => {
        const query = 'UPDATE courses SET title = $1, description = $2 WHERE id = $3';
        return db.query(query, [courseData.title, courseData.description, id]);
    },

    deleteCourse: async (id) => {
        const query = 'DELETE FROM courses WHERE id = $1';
        return db.query(query, [id]);
    },
};

module.exports = { Course };