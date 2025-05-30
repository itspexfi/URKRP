const fs = require('fs');
const path = require('path');

const commandsPath = path.join(__dirname, 'commands');

// Read all command files
fs.readdir(commandsPath, (err, files) => {
    if (err) {
        console.error('Error reading commands directory:', err);
        return;
    }

    files.forEach(file => {
        if (file.endsWith('.js')) {
            const filePath = path.join(commandsPath, file);
            let content = fs.readFileSync(filePath, 'utf8');
            
            // Replace the settings.js path
            content = content.replace(
                /require\(path\.join\(__dirname, '\.\.', 'settings\.js'\)\)/g,
                "require('../settings.js')"
            );
            
            // Write the updated content back
            fs.writeFileSync(filePath, content);
            console.log(`Updated ${file}`);
        }
    });
}); 