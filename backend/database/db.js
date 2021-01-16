/**
 * File for setting up connection with database
 * @author Ajob Kustra
 * @author Kaz Schraven
 */

// .ENV configured into process.env
require('dotenv').config()

const { Pool } = require('pg');

// Deconstructing relevant environment variables
const { DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS } = process.env

// Pool connecting directly to test database
const pool = new Pool({
    host: DB_HOST,
    port: DB_PORT,
    database: DB_NAME,
    user: DB_USER,
    password: DB_PASS
});

module.exports = {
    query: (text, params) => pool.query(text, params),
}