const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: false,
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD
    }
});

const sendOTPEmail = async (email, otp, name) => {
    if (!process.env.SMTP_USER || !process.env.SMTP_PASSWORD) {
        console.warn('[emailService] SMTP not configured – skipping OTP email send.');
        return false;
    }

    const mailOptions = {
        from: process.env.SMTP_FROM || process.env.SMTP_USER,
        to: email,
        subject: 'Your Classly OTP Code',
        html: `
            <h2>Hello, ${name || 'User'}!</h2>
            <p>Your One-Time Password (OTP) for Classly login is:</p>
            <h1 style="letter-spacing: 8px; color: #0056b3;">${otp}</h1>
            <p>This OTP is valid for <strong>10 minutes</strong>. Do not share it with anyone.</p>
            <p>If you did not request this OTP, please ignore this email.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ OTP email sent to ${email}`);
        return true;
    } catch (error) {
        console.error('❌ Error sending OTP email:', error);
        return false;
    }
};

const sendVerificationEmail = async (email, token) => {
    const verificationUrl = `${process.env.CLIENT_URL}/verify-email?token=${token}`;
    
    const mailOptions = {
        from: process.env.SMTP_FROM,
        to: email,
        subject: 'Verify your Classly email',
        html: `
            <h2>Welcome to Classly!</h2>
            <p>Please verify your email by clicking the link below:</p>
            <a href="${verificationUrl}" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">
                Verify Email
            </a>
            <p>Or paste this link in your browser:</p>
            <p>${verificationUrl}</p>
            <p>This link expires in 24 hours.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Verification email sent to ${email}`);
        return true;
    } catch (error) {
        console.error('❌ Error sending email:', error);
        return false;
    }
};

const sendPasswordResetEmail = async (email, token) => {
    const resetUrl = `${process.env.CLIENT_URL}/reset-password?token=${token}`;
    const mailOptions = {
        from: process.env.SMTP_FROM,
        to: email,
        subject: 'Reset your Classly password',
        html: `<h2>Password Reset Request</h2><p>Click the link below to reset your password:</p><a href="${resetUrl}" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">Reset Password</a><p>Or paste this link in your browser:</p><p>${resetUrl}</p><p>This link expires in 1 hour.</p><p>If you didn't request this, please ignore this email.</p>`
    };
    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ Password reset email sent to ${email}`);
        return true;
    } catch (error) {
        console.error('❌ Error sending email:', error);
        return false;
    }
};

module.exports = { sendOTPEmail, sendVerificationEmail, sendPasswordResetEmail };