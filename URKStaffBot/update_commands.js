const fs = require('fs');
const path = require('path');

// Simple command template (no database access needed)
const simpleCommandTemplate = `const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = async (fivemexports, client, message, params) => {
    try {
        // Command logic here
        
        // Example embed response
        let embed = {
            "title": "Command Title",
            "description": "Command description",
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        
        await message.channel.send({ embed });
    } catch (error) {
        console.error('Error in command:', error);
        let errorEmbed = {
            "title": "Error",
            "description": "An error occurred while processing the command",
            "color": 0xed4245,
        }
        message.channel.send({ embed: errorEmbed }).catch(console.error);
    }
}

exports.conf = {
    name: "commandname",
    perm: 0,
    guild: "1203967504641163304"
}`;

// Database command template
const dbCommandTemplate = `const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')
const { pool } = require('../database.js')

exports.runcmd = async (fivemexports, client, message, params) => {
    try {
        // Command logic here
        
        // Example database query
        const [result] = await pool.query("SELECT * FROM table WHERE field = ?", [params[0]]);
        
        if (result.length > 0) {
            let embed = {
                "title": "Command Title",
                "description": "Command description",
                "color": settingsjson.settings.botColour,
                "fields": [
                    {
                        name: 'Field Name',
                        value: 'Field Value',
                        inline: true,
                    }
                ],
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
        } else {
            message.reply('No data found.');
        }
    } catch (error) {
        console.error('Error in command:', error);
        let embed = {
            "title": "Error",
            "description": "An error occurred while processing the command",
            "color": 0xed4245,
        }
        message.channel.send({ embed });
    }
}

exports.conf = {
    name: "commandname",
    perm: 0,
    guild: "1203967504641163304"
}`;

// List of commands that need database access
const dbCommands = [
    'profile.js',
    'groups.js',
    'checkhours.js',
    'ban.js',
    'unban.js',
    'addcar.js',
    'delcar.js',
    'garage.js',
    'getroles.js',
    'notes.js',
    'serverstats.js',
    'verify.js',
    'reverify.js',
    'checkban.js',
    'checkrented.js',
    'checkweapons.js',
    'changeid.js',
    'addgroup.js',
    'removegroup.js',
    'clearwarnings.js',
    'clearbans.js',
    'cleargarage.js',
    'clearvehicleowners.js',
    'addweaponwhitelists.js',
    'bootwipe.js',
    'auction.js',
    'auctionhouses.js',
    'bid.js',
    'factioninfo.js',
    'factionlb.js',
    'factionwlb.js',
    'getcurrentowners.js',
    'hmc.js',
    'p2d.js',
    'd2p.js',
    'showwarnings.js',
    'statusleaderboard.js',
    'statusleaderboardadmin.js',
    'top10.js',
    'ticketlb.js',
    'weapons.js'
];

// Update all command files
const commandsDir = path.join(__dirname, 'commands');
const files = fs.readdirSync(commandsDir);

files.forEach(file => {
    if (file.endsWith('.js')) {
        const filePath = path.join(commandsDir, file);
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Skip if file already has the new format
        if (content.includes('const { pool } = require') || content.includes('async (fivemexports')) {
            console.log(`Skipping ${file} - already updated`);
            return;
        }
        
        // Determine which template to use
        const template = dbCommands.includes(file) ? dbCommandTemplate : simpleCommandTemplate;
        
        // Extract command name and permission from existing file
        const nameMatch = content.match(/name:\s*"([^"]+)"/);
        const permMatch = content.match(/perm:\s*(\d+)/);
        
        // Replace placeholders in template
        let newContent = template
            .replace('commandname', nameMatch ? nameMatch[1] : file.replace('.js', ''))
            .replace('perm: 0', `perm: ${permMatch ? permMatch[1] : '0'}`);
        
        // Write the new content
        fs.writeFileSync(filePath, newContent);
        console.log(`Updated ${file}`);
    }
});

console.log('All commands have been updated!'); 