const fs = require('fs');
const path = require('path');
const { pool } = require('./database.js');

async function createGroupsTable() {
    try {
        // First, let's check if we can connect to the database
        const connection = await pool.getConnection();
        console.log('Successfully connected to database');
        
        // Check if the database exists
        const [databases] = await connection.query('SHOW DATABASES');
        console.log('Available databases:', databases.map(db => db.Database));
        
        // Use the urk database
        await connection.query('USE urk');
        console.log('Using database: urk');
        
        // Read and execute the SQL
        const sqlPath = path.join(__dirname, 'sql', 'create_groups_table.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8');
        console.log('Executing SQL:', sql);
        
        await connection.query(sql);
        console.log('Successfully created urk_groups table');
        
        // Verify the table was created
        const [tables] = await connection.query('SHOW TABLES');
        console.log('Tables in database:', tables);
        
        connection.release();
        process.exit(0);
    } catch (error) {
        console.error('Error creating urk_groups table:', error);
        process.exit(1);
    }
}

createGroupsTable(); 