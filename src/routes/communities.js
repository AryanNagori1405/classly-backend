const express = require('express');
const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const router = express.Router();

// Middleware to verify JWT token
function authenticateToken(req, res, next) {
    const token = req.headers['authorization'] && req.headers['authorization'].split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ message: 'No token provided' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ message: 'Invalid or expired token' });
        }
        req.user = user;
        next();
    });
}

// POST /api/communities - Create community
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { name, description, course_id, is_private } = req.body;
        const createdBy = req.user.id;

        if (!name || !course_id) {
            return res.status(400).json({ message: 'Name and course_id are required' });
        }

        // Check if course exists and communities are enabled
        const courseResult = await pool.query(
            'SELECT * FROM courses WHERE id = $1',
            [course_id]
        );

        if (courseResult.rows.length === 0) {
            return res.status(404).json({ message: 'Course not found' });
        }

        if (!courseResult.rows[0].enable_communities) {
            return res.status(400).json({ 
                message: 'Communities are not enabled for this course' 
            });
        }

        const result = await pool.query(
            `INSERT INTO communities (name, description, created_by, course_id, is_private, created_at)
             VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)
             RETURNING *`,
            [name, description, createdBy, course_id, is_private || false]
        );

        // Add creator as owner
        await pool.query(
            `INSERT INTO community_members (community_id, user_id, role, joined_at)
             VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
            [result.rows[0].id, createdBy, 'owner']
        );

        res.status(201).json({
            message: 'Community created successfully',
            community: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/communities - List all communities
router.get('/', authenticateToken, async (req, res) => {
    try {
        const { course_id } = req.query;
        let query = 'SELECT * FROM communities WHERE is_private = false';
        let params = [];

        if (course_id) {
            query += ` AND course_id = $${params.length + 1}`;
            params.push(course_id);
        }

        query += ' ORDER BY created_at DESC';

        const result = await pool.query(query, params);

        res.json({
            message: 'Communities retrieved successfully',
            count: result.rows.length,
            communities: result.rows
        });
    } catch (error) {
        console.error('Error fetching communities:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/communities/:id - Get community details
router.get('/:communityId', authenticateToken, async (req, res) => {
    try {
        const communityId = req.params.communityId;
        const userId = req.user.id;

        const communityResult = await pool.query(
            'SELECT * FROM communities WHERE id = $1',
            [communityId]
        );

        if (communityResult.rows.length === 0) {
            return res.status(404).json({ message: 'Community not found' });
        }

        const community = communityResult.rows[0];

        // Check membership
        const memberResult = await pool.query(
            'SELECT * FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );

        if (community.is_private && memberResult.rows.length === 0) {
            return res.status(403).json({ message: 'You do not have access to this community' });
        }

        // Get members
        const membersResult = await pool.query(
            `SELECT cm.user_id, u.name, u.email, cm.role, cm.joined_at
             FROM community_members cm
             JOIN users u ON cm.user_id = u.id
             WHERE cm.community_id = $1`,
            [communityId]
        );

        res.json({
            ...community,
            members: membersResult.rows,
            is_member: memberResult.rows.length > 0
        });
    } catch (error) {
        console.error('Error fetching community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/communities/:id/join - Join community
router.post('/:communityId/join', authenticateToken, async (req, res) => {
    try {
        const communityId = req.params.communityId;
        const userId = req.user.id;

        // Check if community exists
        const communityResult = await pool.query(
            'SELECT * FROM communities WHERE id = $1',
            [communityId]
        );

        if (communityResult.rows.length === 0) {
            return res.status(404).json({ message: 'Community not found' });
        }

        // Check if already member
        const memberResult = await pool.query(
            'SELECT * FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );

        if (memberResult.rows.length > 0) {
            return res.status(400).json({ message: 'You are already a member of this community' });
        }

        // Add member
        await pool.query(
            `INSERT INTO community_members (community_id, user_id, role, joined_at)
             VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
            [communityId, userId, 'member']
        );

        res.json({ message: 'Joined community successfully' });
    } catch (error) {
        console.error('Error joining community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/communities/:id/posts - Create post
router.post('/:communityId/posts', authenticateToken, async (req, res) => {
    try {
        const communityId = req.params.communityId;
        const userId = req.user.id;
        const { content, attachments } = req.body;

        if (!content) {
            return res.status(400).json({ message: 'Content is required' });
        }

        // Check if member
        const memberResult = await pool.query(
            'SELECT * FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );

        if (memberResult.rows.length === 0) {
            return res.status(403).json({ message: 'You must be a member to post' });
        }

        const result = await pool.query(
            `INSERT INTO community_posts (community_id, user_id, content, attachments, created_at)
             VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)
             RETURNING *`,
            [communityId, userId, content, attachments || null]
        );

        res.status(201).json({
            message: 'Post created successfully',
            post: result.rows[0]
        });
    } catch (error) {
        console.error('Error creating post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// GET /api/communities/:id/posts - Get community posts
router.get('/:communityId/posts', authenticateToken, async (req, res) => {
    try {
        const communityId = req.params.communityId;

        const result = await pool.query(
            `SELECT cp.*, u.name, u.email, COUNT(cpu.id) as upvote_count
             FROM community_posts cp
             JOIN users u ON cp.user_id = u.id
             LEFT JOIN community_post_upvotes cpu ON cp.id = cpu.post_id
             WHERE cp.community_id = $1 AND cp.is_deleted = false
             GROUP BY cp.id, u.id
             ORDER BY cp.is_pinned DESC, cp.created_at DESC`,
            [communityId]
        );

        res.json({
            message: 'Posts retrieved successfully',
            count: result.rows.length,
            posts: result.rows
        });
    } catch (error) {
        console.error('Error fetching posts:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// POST /api/communities/:id/posts/:postId/upvote - Upvote post
router.post('/:communityId/posts/:postId/upvote', authenticateToken, async (req, res) => {
    try {
        const postId = req.params.postId;
        const userId = req.user.id;

        // Check if already upvoted
        const checkResult = await pool.query(
            'SELECT * FROM community_post_upvotes WHERE post_id = $1 AND user_id = $2',
            [postId, userId]
        );

        if (checkResult.rows.length > 0) {
            // Remove upvote
            await pool.query(
                'DELETE FROM community_post_upvotes WHERE post_id = $1 AND user_id = $2',
                [postId, userId]
            );

            await pool.query(
                'UPDATE community_posts SET upvotes = upvotes - 1 WHERE id = $1',
                [postId]
            );

            return res.json({ message: 'Upvote removed' });
        }

        // Add upvote
        await pool.query(
            `INSERT INTO community_post_upvotes (post_id, user_id, created_at)
             VALUES ($1, $2, CURRENT_TIMESTAMP)`,
            [postId, userId]
        );

        await pool.query(
            'UPDATE community_posts SET upvotes = upvotes + 1 WHERE id = $1',
            [postId]
        );

        res.json({ message: 'Post upvoted successfully' });
    } catch (error) {
        console.error('Error upvoting post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// DELETE /api/communities/:id/posts/:postId - Delete post
router.delete('/:communityId/posts/:postId', authenticateToken, async (req, res) => {
    try {
        const postId = req.params.postId;
        const userId = req.user.id;

        const postResult = await pool.query(
            'SELECT * FROM community_posts WHERE id = $1',
            [postId]
        );

        if (postResult.rows.length === 0) {
            return res.status(404).json({ message: 'Post not found' });
        }

        if (postResult.rows[0].user_id !== userId) {
            return res.status(403).json({ message: 'You can only delete your own posts' });
        }

        await pool.query(
            'UPDATE community_posts SET is_deleted = true WHERE id = $1',
            [postId]
        );

        res.json({ message: 'Post deleted successfully' });
    } catch (error) {
        console.error('Error deleting post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;