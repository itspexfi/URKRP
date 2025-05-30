const mysql = require('mysql2/promise');

// Create a connection pool
const pool = mysql.createPool({
    host: 'localhost',     // Your MySQL host
    user: 'root',         // Your MySQL username
    password: '',         // Your MySQL password
    database: 'urk',      // Your database name
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test the connection
async function testConnection() {
    try {
        const connection = await pool.getConnection();
        console.log('Database connection successful!');
        connection.release();
    } catch (error) {
        console.error('Error connecting to the database:', error);
        process.exit(1);
    }
}

// Execute a query
async function executeQuery(sql, params) {
    try {
        const [results] = await pool.execute(sql, params);
        return results;
    } catch (error) {
        console.error('Error executing query:', error);
        throw error;
    }
}

module.exports = {
    pool,
    testConnection,
    executeQuery
}; 