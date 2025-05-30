const { resourcePath, settingsjson } = require('./pathHelper');
const Discord = require('discord.js');
const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        message.channel.send('Please provide a weapon spawncode to check.');
        return;
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_weapons` WHERE weapon = ?", [params[0]], (result) => {
        const owners = [];
        const descriptionText = `Here are all the users that own ${params[0]}:`;

        for (let i = 0; i < result.length; i++) {
            owners.push(`(${result[i].permid})\n`);
        }

        if (result.length > 0) {
            let embed = {
                "title": `All Users that own ${params[0]}:`,
                "description": descriptionText + '\n```' + owners.join('').replace(',', '') + '```',
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": `Requested by ${message.author.username}`
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed }).catch(err => {
                message.channel.send(`${params[0]} has too many owners to display in an embed.`);
            });
        } else {
            message.reply(`No one owns this weapon.`);
        }
    });
};

exports.conf = {
    name: "checkweapons",
    perm: 2,
    guild: "1203967504641163304"
}