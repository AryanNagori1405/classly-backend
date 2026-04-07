const pool = require('../config/database');
const nodemailer = require('nodemailer');

// Email transporter setup
const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: false,
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD
    }
});

// Send notification email
const sendExpiryNotification = async (studentEmail, videoTitle, hoursRemaining) => {
    const mailOptions = {
        from: process.env.SMTP_FROM,
        to: studentEmail,
        subject: `⏰ Video "${videoTitle}" expires in ${hoursRemaining} hours`,
        html: `
            <h2>Video Expiring Soon!</h2>
            <p>The video "<strong>${videoTitle}</strong>" will be deleted in <strong>${hoursRemaining} hours</strong>.</p>
            <p>Please download or save any important notes before it expires.</p>
            <p>This is an automated notification from Classly.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Notification sent to ${studentEmail}`);
        return true;
    } catch (error) {
        console.error(`❌ Error sending notification to ${studentEmail}:`, error);
        return false;
    }
};

// Send deletion confirmation email
const sendDeletionConfirmation = async (teacherEmail, videoTitle, deletionDate) => {
    const mailOptions = {
        from: process.env.SMTP_FROM,
        to: teacherEmail,
        subject: `✅ Video "${videoTitle}" has been auto-deleted`,
        html: `
            <h2>Video Auto-Deletion Confirmation</h2>
            <p>Your video "<strong>${videoTitle}</strong>" has been automatically deleted on <strong>${deletionDate}</strong>.</p>
            <p>This is because it exceeded the 7-day retention period.</p>
            <p>If you need to re-upload this video or need more information, please contact support.</p>
            <p>Classly Team</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Deletion confirmation sent to ${teacherEmail}`);
        return true;
    } catch (error) {
        console.error(`❌ Error sending confirmation to ${teacherEmail}:`, error);
        return false;
    }
};

// Main cleanup job
const runVideoCleanup = async () => {
    try {
        console.log('🔄 Starting video cleanup job...');

        // Get videos expiring in 48 hours (5 days old)
        const expiringVideos = await pool.query(
            `SELECT v.*, u.email as teacher_email, u.name as teacher_name
             FROM videos v
             JOIN users u ON v.teacher_id = u.id
             WHERE v.created_at <= NOW() - INTERVAL '5 days'
             AND v.created_at > NOW() - INTERVAL '5 days 1 hour'
             AND v.is_deleted = false`,
        );

        console.log(`⏰ Found ${expiringVideos.rows.length} videos expiring soon`);

        // Send expiry notifications
        for (const video of expiringVideos.rows) {
            const students = await pool.query(
                `SELECT DISTINCT u.email, u.id
                 FROM users u
                 JOIN enrollments e ON u.id = e.student_id
                 JOIN courses c ON e.course_id = c.id
                 WHERE c.id = $1`,
                [video.course_id]
            );

            for (const student of students.rows) {
                await sendExpiryNotification(student.email, video.title, 48);
            }

            // Log expiry notification
            await pool.query(
                `INSERT INTO video_audit_log (video_id, action, description, created_at)
                 VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
                [video.id, 'expiry_notification_sent', `Expiry notification sent to ${students.rows.length} students`]
            );
        }

        // Get videos to delete (older than 7 days)
        const videosToDelete = await pool.query(
            `SELECT v.*, u.email as teacher_email, u.name as teacher_name
             FROM videos v
             JOIN users u ON v.teacher_id = u.id
             WHERE v.created_at <= NOW() - INTERVAL '7 days'
             AND v.is_deleted = false`,
        );

        console.log(`🗑️  Found ${videosToDelete.rows.length} videos to delete`);

        // Delete videos and send confirmations
        for (const video of videosToDelete.rows) {
            try {
                // Soft delete video
                await pool.query(
                    `UPDATE videos 
                     SET is_deleted = true, deleted_at = CURRENT_TIMESTAMP
                     WHERE id = $1`,
                    [video.id]
                );

                // Delete video file (if you have file storage)
                console.log(`🗑️  Deleted video: ${video.title} (ID: ${video.id})`);

                // Send deletion confirmation to teacher
                await sendDeletionConfirmation(
                    video.teacher_email,
                    video.title,
                    new Date().toLocaleDateString()
                );

                // Log deletion in audit trail
                await pool.query(
                    `INSERT INTO video_audit_log (video_id, action, description, created_at)
                     VALUES ($1, $2, $3, CURRENT_TIMESTAMP)`,
                    [video.id, 'auto_deleted', 'Video auto-deleted after 7-day retention period']
                );

                // Update course video count
                await pool.query(
                    `UPDATE courses 
                     SET videos_count = (SELECT COUNT(*) FROM videos WHERE course_id = $1 AND is_deleted = false)
                     WHERE id = $2`,
                    [video.course_id, video.course_id]
                );

            } catch (error) {
                console.error(`❌ Error deleting video ${video.id}:`, error);
            }
        }

        console.log('✅ Video cleanup job completed');

    } catch (error) {
        console.error('❌ Error in video cleanup job:', error);
    }
};

// Run cleanup job every day at 2 AM
const schedule = require('node-schedule');

const startCleanupSchedule = () => {
    // Run at 2:00 AM every day
    schedule.scheduleJob('0 2 * * *', () => {
        console.log('⏰ Running scheduled video cleanup...');
        runVideoCleanup();
    });

    console.log('✅ Video cleanup scheduler started (runs daily at 2:00 AM)');
};

module.exports = {
    runVideoCleanup,
    startCleanupSchedule
};