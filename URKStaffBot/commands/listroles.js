const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = async (fivemexports, client, message, params) => {
    try {
        // Ensure the command is used in a guild
        if (!message.guild) {
            let embed = {
                "title": "Error",
                "description": "This command can only be used in a server (guild).",
                "color": 0xed4245,
            };
            return message.channel.send({ embed });
        }

        const roles = message.guild.roles.cache;

        if (roles.size === 0) {
            let embed = {
                "title": "No Roles Found",
                "description": "Could not find any roles in this server.",
                "color": settingsjson.settings.botColour,
            };
            return message.channel.send({ embed });
        }

        let roleList = "**Roles in this server:**\n\n";

        roles.forEach(role => {
            roleList += `**${role.name}**: ${role.id}\n`;
        });

        // Send the list, potentially as a DM if it's too long
        if (roleList.length > 2000) {
            // Discord message limit is 2000 characters
            // Split the message or send via DM
            try {
                await message.author.send(roleList, { split: true });
                message.reply('The list of roles has been sent to your DMs.');
            } catch (dmError) {
                console.error('Could not send role list via DM:', dmError);
                message.channel.send('The role list is too long to send here and I could not send it via DM. Please check the console for the full list.');
                console.log(roleList);
            }
        } else {
            message.channel.send(roleList);
        }

    } catch (error) {
        console.error('Error in listroles command:', error);
        let embed = {
            "title": "Error",
            "description": "An error occurred while listing roles",
            "color": 0xed4245,
        };
        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "listroles",
    perm: 4, // You can adjust the permission level as needed
    guild: "1203967504641163304" // Make sure this is your guild ID
}; 