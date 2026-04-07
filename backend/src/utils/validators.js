// src/utils/validators.js

// Email Validation
function validateEmail(email) {
    const re = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return re.test(String(email).toLowerCase());
}

// Password Validation
function validatePassword(password) {
    // At least 6 characters, 1 uppercase, 1 lowercase, 1 number
    const re = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{6,}$/;
    return re.test(password);
}

// Name Validation
function validateName(name) {
    // Only letters and spaces, 2 to 30 characters
    const re = /^[A-Za-z ]{2,30}$/;
    return re.test(name);
}

// Role Validation
function validateRole(role) {
    const validRoles = ['admin', 'user', 'moderator'];
    return validRoles.includes(role);
}

// Registration Validation
function validateRegistration(email, password, name, role) {
    return (validateEmail(email) && validatePassword(password) && validateName(name) && validateRole(role));
}

module.exports = { validateEmail, validatePassword, validateName, validateRole, validateRegistration };