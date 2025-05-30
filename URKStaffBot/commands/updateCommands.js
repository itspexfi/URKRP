const fs = require('fs');
const path = require('path');

const commandsDir = __dirname;
const files = fs.readdirSync(commandsDir);

files.forEach(file => {
    if (file === 'pathHelper.js' || file === 'updateCommands.js') return;
    
    const filePath = path.join(commandsDir, file);
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Remove any instance of the old path resolution code (robust to whitespace)
    content = content.replace(/const\s+resourcePath\s*=\s*global\.GetResourcePath\s*\?[^;]+;?\s*/gs, '');
    content = content.replace(/const\s+settingsjson\s*=\s*require\([^\)]+\);?\s*/gs, '');
    
    // Add the pathHelper import at the top if not present
    if (!content.includes("require('./pathHelper')")) {
        content = `const { resourcePath, settingsjson } = require('./pathHelper');\n\n${content}`;
    }
    
    // Fix any extra closing braces
    content = content.replace(/}\s*};?\s*$/g, '}');
    
    // Ensure the file is wrapped in exports.runcmd
    if (!content.includes('exports.runcmd')) {
        content = `exports.runcmd = (fivemexports, client, message, params) => {\n${content}\n};\n`;
    }
    
    // Ensure the file has the required exports.conf object
    if (!content.includes('exports.conf')) {
        content += `\nexports.conf = {\n    name: "${file.replace('.js', '')}",\n    perm: 0,\n    guild: "1203967504641163304"\n};\n`;
    }
    
    // Change any existing guild ID to 1203967504641163304
    content = content.replace(/guild:\s*"[^"]+"/g, 'guild: "1203967504641163304"');
    
    // Write the updated content back to the file
    fs.writeFileSync(filePath, content);
    console.log(`Updated ${file}`);
}); 