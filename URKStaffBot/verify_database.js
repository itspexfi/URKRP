const mysql = require('mysql2/promise');

async function verifyDatabase() {
    let connection;
    try {
        // Create a direct connection
        connection = await mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: '',
            database: 'urk'
        });

        console.log('Connected to MySQL server');

        // List all databases
        const [databases] = await connection.query('SHOW DATABASES');
        console.log('\nAvailable databases:');
        databases.forEach(db => console.log(`- ${db.Database}`));

        // Use the urk database
        await connection.query('USE urk');
        console.log('\nUsing database: urk');

        // List all tables
        const [tables] = await connection.query('SHOW TABLES');
        console.log('\nTables in urk database:');
        tables.forEach(table => console.log(`- ${Object.values(table)[0]}`));

        // Check if urk_groups exists
        const [groupsTable] = await connection.query('SHOW TABLES LIKE "urk_groups"');
        if (groupsTable.length === 0) {
            console.log('\nurk_groups table does not exist. Creating it now...');
            
            // Create the table
            await connection.query(`
                CREATE TABLE IF NOT EXISTS \`urk_groups\` (
                    \`id\` INT AUTO_INCREMENT PRIMARY KEY,
                    \`user_id\` VARCHAR(50) NOT NULL,
                    \`group_name\` VARCHAR(50) NOT NULL,
                    \`added_by\` VARCHAR(50) NOT NULL,
                    \`added_date\` DATETIME NOT NULL,
                    INDEX \`idx_user_id\` (\`user_id\`),
                    INDEX \`idx_group_name\` (\`group_name\`),
                    UNIQUE KEY \`unique_user_group\` (\`user_id\`, \`group_name\`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            `);
            
            console.log('urk_groups table created successfully');
        } else {
            console.log('\nurk_groups table already exists');
        }

        // Show table structure
        const [columns] = await connection.query('DESCRIBE urk_groups');
        console.log('\nurk_groups table structure:');
        columns.forEach(column => {
            console.log(`- ${column.Field}: ${column.Type} ${column.Null === 'NO' ? 'NOT NULL' : ''} ${column.Key === 'PRI' ? 'PRIMARY KEY' : ''}`);
        });

    } catch (error) {
        console.error('\nError:', error.message);
        if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            console.error('Access denied. Please check your database credentials.');
        } else if (error.code === 'ECONNREFUSED') {
            console.error('Could not connect to MySQL server. Please check if MySQL is running.');
        }
    } finally {
        if (connection) {
            await connection.end();
            console.log('\nDatabase connection closed');
        }
    }
}

verifyDatabase(); 