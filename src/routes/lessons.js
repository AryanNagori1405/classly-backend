const express = require('express');
const router = express.Router();
const Lesson = require('../models/lessonModel');
const auth = require('../middleware/auth');

// ===== ROLE GUARD: TEACHERS ONLY =====
const requireTeacher = (req, res, next) => {
    if (req.user.role !== 'teacher') {
        return res.status(403).json({ message: 'Access denied. Teachers only.' });
    }
    next();
};

// ===== CREATE LESSON (Teacher only) =====
// POST /api/lessons
router.post('/', auth, requireTeacher, async (req, res) => {
    try {
        const { courseId, title, description, content, video_url, duration, order_index } = req.body;

        if (!courseId) {
            return res.status(400).json({ message: 'courseId is required' });
        }
        if (!title || title.trim().length < 3) {
            return res.status(400).json({ message: 'title is required and must be at least 3 characters' });
        }
        if (duration !== undefined && (isNaN(duration) || Number(duration) <= 0)) {
            return res.status(400).json({ message: 'duration must be a positive number' });
        }
        if (video_url && !/^https?:\/\/.+/.test(video_url)) {
            return res.status(400).json({ message: 'video_url must be a valid URL' });
        }

        // Check course exists
        const exists = await Lesson.courseExists(courseId);
        if (!exists) {
            return res.status(404).json({ message: 'Course not found' });
        }

        // Validate teacher owns the course
        const instructorId = await Lesson.getCourseInstructor(courseId);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const result = await Lesson.createLesson(courseId, { title: title.trim(), description, content, video_url, duration, order_index });

        res.status(201).json({
            message: 'Lesson created successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error creating lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET ALL LESSONS IN A COURSE =====
// GET /api/lessons/course/:courseId
router.get('/course/:courseId', async (req, res) => {
    try {
        const { courseId } = req.params;

        const exists = await Lesson.courseExists(courseId);
        if (!exists) {
            return res.status(404).json({ message: 'Course not found' });
        }

        const result = await Lesson.getCourseLessons(courseId);

        res.status(200).json({
            message: 'Lessons retrieved successfully',
            lessons: result.rows,
        });
    } catch (error) {
        console.error('Error fetching lessons:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== GET SINGLE LESSON =====
// GET /api/lessons/:id
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await Lesson.getLessonById(id);
        if (result.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        const lesson = result.rows[0];

        // Only return unpublished lessons to authenticated teachers who own the course
        if (!lesson.is_published) {
            const token = req.headers.authorization?.split(' ')[1];
            if (!token) {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            const jwt = require('jsonwebtoken');
            let decoded;
            try {
                decoded = jwt.verify(token, process.env.JWT_SECRET);
            } catch {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            if (decoded.role !== 'teacher') {
                return res.status(404).json({ message: 'Lesson not found' });
            }
            const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
            if (instructorId !== null && instructorId !== decoded.id) {
                return res.status(404).json({ message: 'Lesson not found' });
            }
        }

        res.status(200).json({
            message: 'Lesson retrieved successfully',
            lesson,
        });
    } catch (error) {
        console.error('Error fetching lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== UPDATE LESSON (Teacher only) =====
// PUT /api/lessons/:id
router.put('/:id', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;
        const { title, duration, video_url } = req.body;

        if (title !== undefined && title.trim().length < 3) {
            return res.status(400).json({ message: 'title must be at least 3 characters' });
        }
        if (duration !== undefined && (isNaN(duration) || Number(duration) <= 0)) {
            return res.status(400).json({ message: 'duration must be a positive number' });
        }
        if (video_url !== undefined && video_url !== null && video_url !== '' && !/^https?:\/\/.+/.test(video_url)) {
            return res.status(400).json({ message: 'video_url must be a valid URL' });
        }

        // Check lesson exists
        const lessonResult = await Lesson.getLessonById(id);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const updateData = { ...req.body };
        if (title !== undefined) updateData.title = title.trim();

        const result = await Lesson.updateLesson(id, updateData);

        res.status(200).json({
            message: 'Lesson updated successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error updating lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== DELETE LESSON (Teacher only) =====
// DELETE /api/lessons/:id
router.delete('/:id', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;

        const lessonResult = await Lesson.getLessonById(id);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        await Lesson.deleteLesson(id);

        res.status(200).json({ message: 'Lesson deleted successfully' });
    } catch (error) {
        console.error('Error deleting lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

// ===== PUBLISH / UNPUBLISH LESSON (Teacher only) =====
// PATCH /api/lessons/:id/publish
router.patch('/:id/publish', auth, requireTeacher, async (req, res) => {
    try {
        const { id } = req.params;

        const lessonResult = await Lesson.getLessonById(id);
        if (lessonResult.rows.length === 0) {
            return res.status(404).json({ message: 'Lesson not found' });
        }

        // Validate teacher owns the course
        const lesson = lessonResult.rows[0];
        const instructorId = await Lesson.getCourseInstructor(lesson.course_id);
        if (instructorId !== null && instructorId !== req.user.id) {
            return res.status(403).json({ message: 'You are not the instructor of this course' });
        }

        const result = await Lesson.publishLesson(id);

        res.status(200).json({
            message: result.rows[0].is_published ? 'Lesson published successfully' : 'Lesson unpublished successfully',
            lesson: result.rows[0],
        });
    } catch (error) {
        console.error('Error publishing lesson:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

module.exports = router;
