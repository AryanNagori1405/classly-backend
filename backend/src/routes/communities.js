const express = require('express');
const pool = require('../config/database');
const auth = require('../middleware/auth');
const router = express.Router();

router.use(auth);

// ── POST /api/communities  – create a community ───────────────────────────────
router.post('/', async (req, res) => {
    try {
        const { name, description, category, image_url, is_private } = req.body;
        const createdBy = req.user.id;

        if (!name) {
            return res.status(400).json({ message: 'Community name is required' });
        }

        const result = await pool.query(
            `INSERT INTO communities (name, description, category, image_url, created_by, is_private)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING *`,
            [name, description || null, category || null, image_url || null,
             createdBy, is_private || false]
        );

        const community = result.rows[0];

        // Add creator as owner member
        await pool.query(
            `INSERT INTO community_members (community_id, user_id, role)
             VALUES ($1, $2, 'owner')`,
            [community.id, createdBy]
        );

        res.status(201).json({ message: 'Community created successfully', community });
    } catch (error) {
        console.error('Error creating community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/communities  – list public communities ───────────────────────────
router.get('/', async (req, res) => {
    try {
        const { search, category } = req.query;
        let query = `
            SELECT c.*, u.name as creator_name
            FROM communities c
            JOIN users u ON c.created_by = u.id
            WHERE c.is_disabled = FALSE AND c.is_private = FALSE`;
        const params = [];

        if (search) {
            params.push(`%${search}%`);
            query += ` AND (c.name ILIKE $${params.length} OR c.description ILIKE $${params.length})`;
        }
        if (category) {
            params.push(category);
            query += ` AND c.category = $${params.length}`;
        }
        query += ' ORDER BY c.member_count DESC, c.created_at DESC';

        const result = await pool.query(query, params);
        res.json({ count: result.rows.length, communities: result.rows });
    } catch (error) {
        console.error('Error fetching communities:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/communities/:id  – community detail ──────────────────────────────
router.get('/:communityId', async (req, res) => {
    try {
        const { communityId } = req.params;
        const userId = req.user.id;

        const communityResult = await pool.query(
            'SELECT * FROM communities WHERE id = $1 AND is_disabled = FALSE',
            [communityId]
        );
        if (communityResult.rows.length === 0) {
            return res.status(404).json({ message: 'Community not found' });
        }
        const community = communityResult.rows[0];

        const memberCheck = await pool.query(
            'SELECT role FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );

        if (community.is_private && memberCheck.rows.length === 0) {
            return res.status(403).json({ message: 'This community is private' });
        }

        const membersResult = await pool.query(
            `SELECT cm.user_id, cm.role, cm.joined_at, u.name, u.profile_image
             FROM community_members cm
             JOIN users u ON cm.user_id = u.id
             WHERE cm.community_id = $1
             ORDER BY cm.joined_at ASC`,
            [communityId]
        );

        res.json({
            ...community,
            members: membersResult.rows,
            is_member: memberCheck.rows.length > 0,
            my_role: memberCheck.rows[0]?.role || null
        });
    } catch (error) {
        console.error('Error fetching community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/communities/:id/join ────────────────────────────────────────────
router.post('/:communityId/join', async (req, res) => {
    try {
        const { communityId } = req.params;
        const userId = req.user.id;

        const communityCheck = await pool.query(
            'SELECT id, is_private, is_disabled FROM communities WHERE id = $1',
            [communityId]
        );
        if (communityCheck.rows.length === 0 || communityCheck.rows[0].is_disabled) {
            return res.status(404).json({ message: 'Community not found' });
        }

        const alreadyMember = await pool.query(
            'SELECT id FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );
        if (alreadyMember.rows.length > 0) {
            return res.status(400).json({ message: 'You are already a member' });
        }

        await pool.query(
            `INSERT INTO community_members (community_id, user_id, role) VALUES ($1, $2, 'member')`,
            [communityId, userId]
        );

        await pool.query(
            'UPDATE communities SET member_count = member_count + 1 WHERE id = $1',
            [communityId]
        );

        res.json({ message: 'Joined community successfully' });
    } catch (error) {
        console.error('Error joining community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/communities/:id/leave ──────────────────────────────────────────
router.post('/:communityId/leave', async (req, res) => {
    try {
        const { communityId } = req.params;
        const userId = req.user.id;

        const memberCheck = await pool.query(
            'SELECT role FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );
        if (memberCheck.rows.length === 0) {
            return res.status(400).json({ message: 'You are not a member' });
        }
        if (memberCheck.rows[0].role === 'owner') {
            return res.status(400).json({ message: 'Owner cannot leave the community. Transfer ownership first.' });
        }

        await pool.query(
            'DELETE FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );
        await pool.query(
            'UPDATE communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = $1',
            [communityId]
        );

        res.json({ message: 'Left community successfully' });
    } catch (error) {
        console.error('Error leaving community:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/communities/:id/posts  – create post ───────────────────────────
router.post('/:communityId/posts', async (req, res) => {
    try {
        const { communityId } = req.params;
        const { content } = req.body;
        const userId = req.user.id;

        if (!content) {
            return res.status(400).json({ message: 'Content is required' });
        }

        // Must be a member
        const memberCheck = await pool.query(
            'SELECT id FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, userId]
        );
        if (memberCheck.rows.length === 0) {
            return res.status(403).json({ message: 'You must be a member to post' });
        }

        const result = await pool.query(
            `INSERT INTO community_posts (community_id, user_id, content) VALUES ($1, $2, $3) RETURNING *`,
            [communityId, userId, content]
        );

        res.status(201).json({ message: 'Post created', post: result.rows[0] });
    } catch (error) {
        console.error('Error creating post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── GET /api/communities/:id/posts ────────────────────────────────────────────
router.get('/:communityId/posts', async (req, res) => {
    try {
        const { communityId } = req.params;
        const userId = req.user.id;

        // Check membership for private communities
        const communityCheck = await pool.query(
            'SELECT is_private FROM communities WHERE id = $1 AND is_disabled = FALSE',
            [communityId]
        );
        if (communityCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Community not found' });
        }
        if (communityCheck.rows[0].is_private) {
            const memberCheck = await pool.query(
                'SELECT id FROM community_members WHERE community_id = $1 AND user_id = $2',
                [communityId, userId]
            );
            if (memberCheck.rows.length === 0) {
                return res.status(403).json({ message: 'Join community to view posts' });
            }
        }

        const result = await pool.query(
            `SELECT cp.*, u.name as author_name, u.profile_image as author_image
             FROM community_posts cp
             JOIN users u ON cp.user_id = u.id
             WHERE cp.community_id = $1 AND cp.is_deleted = FALSE
             ORDER BY cp.created_at DESC`,
            [communityId]
        );

        res.json({ count: result.rows.length, posts: result.rows });
    } catch (error) {
        console.error('Error fetching posts:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── POST /api/communities/:id/posts/:postId/like ──────────────────────────────
router.post('/:communityId/posts/:postId/like', async (req, res) => {
    try {
        const { postId } = req.params;
        const userId = req.user.id;

        const existing = await pool.query(
            'SELECT id FROM community_post_likes WHERE post_id = $1 AND user_id = $2',
            [postId, userId]
        );

        if (existing.rows.length > 0) {
            // Unlike
            await pool.query(
                'DELETE FROM community_post_likes WHERE post_id = $1 AND user_id = $2',
                [postId, userId]
            );
            await pool.query('UPDATE community_posts SET likes = GREATEST(likes - 1, 0) WHERE id = $1', [postId]);
            return res.json({ message: 'Post unliked' });
        }

        await pool.query(
            'INSERT INTO community_post_likes (post_id, user_id) VALUES ($1, $2)',
            [postId, userId]
        );
        await pool.query('UPDATE community_posts SET likes = likes + 1 WHERE id = $1', [postId]);
        res.json({ message: 'Post liked' });
    } catch (error) {
        console.error('Error liking post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── DELETE /api/communities/:id/posts/:postId  – delete post ─────────────────
router.delete('/:communityId/posts/:postId', async (req, res) => {
    try {
        const { communityId, postId } = req.params;
        const userId = req.user.id;

        const postCheck = await pool.query(
            'SELECT user_id FROM community_posts WHERE id = $1 AND community_id = $2',
            [postId, communityId]
        );
        if (postCheck.rows.length === 0) {
            return res.status(404).json({ message: 'Post not found' });
        }

        // Owner/mod of community or post author may delete
        const isMod = await pool.query(
            `SELECT role FROM community_members WHERE community_id = $1 AND user_id = $2
             AND role IN ('owner', 'moderator')`,
            [communityId, userId]
        );

        if (
            postCheck.rows[0].user_id !== userId
            && isMod.rows.length === 0
            && req.user.role !== 'admin'
        ) {
            return res.status(403).json({ message: 'Not authorized to delete this post' });
        }

        await pool.query('UPDATE community_posts SET is_deleted = TRUE WHERE id = $1', [postId]);
        res.json({ message: 'Post deleted' });
    } catch (error) {
        console.error('Error deleting post:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// ── DELETE /api/communities/:id/members/:userId  – remove a member ───────────
router.delete('/:communityId/members/:targetUserId', async (req, res) => {
    try {
        const { communityId, targetUserId } = req.params;
        const userId = req.user.id;

        // Requester must be owner/moderator or admin
        const requesterRole = await pool.query(
            `SELECT role FROM community_members WHERE community_id = $1 AND user_id = $2`,
            [communityId, userId]
        );

        const isAdmin = req.user.role === 'admin';
        const isMod = requesterRole.rows.length > 0 &&
            ['owner', 'moderator'].includes(requesterRole.rows[0].role);

        if (!isMod && !isAdmin) {
            return res.status(403).json({ message: 'Only owner, moderator or admin can remove members' });
        }

        // Cannot remove owner
        const targetRole = await pool.query(
            `SELECT role FROM community_members WHERE community_id = $1 AND user_id = $2`,
            [communityId, targetUserId]
        );

        if (targetRole.rows.length === 0) {
            return res.status(404).json({ message: 'User is not a member of this community' });
        }

        if (targetRole.rows[0].role === 'owner') {
            return res.status(400).json({ message: 'Cannot remove the community owner' });
        }

        await pool.query(
            'DELETE FROM community_members WHERE community_id = $1 AND user_id = $2',
            [communityId, targetUserId]
        );
        await pool.query(
            'UPDATE communities SET member_count = GREATEST(member_count - 1, 0) WHERE id = $1',
            [communityId]
        );

        res.json({ message: 'Member removed successfully' });
    } catch (error) {
        console.error('Error removing member:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
