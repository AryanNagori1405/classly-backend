// src/config/database.js

// Importing the required modules
const { Pool } = require('pg'); // Pool allows you to connect to your PostgreSQL database

// Creating a new pool instance for psql connection. 
// It allows you to manage multiple client connections to the database.
const pool = new Pool({
    user: 'yourUsername', // Database user ID
    host: 'localhost', // Database host (usually a server address)
    database: 'yourDatabase', // Name of the database you want to connect to
    password: 'yourPassword', // Password for the database user
    port: 5432, // Port number for PostgreSQL (default is 5432)
});

// Exporting the pool so it can be imported in other files
module.exports = {
    query: (text, params) => pool.query(text, params), // Function to perform queries on the database
    pool, // Exporting the pool instance for other uses
};

// Usage:
// First, you need to import the module where you need to use the database connection:
// const db = require('./src/config/database');
// Then you can make queries as follows:
// db.query('SELECT * FROM yourTable', (err, res) => { ... });