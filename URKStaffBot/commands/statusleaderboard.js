exports.runcmd = (fivemexports, client, message, params) => {
const { resourcePath, settingsjson } = require('./pathHelper');

let foundInLeaderboard = false;
    for (i = 0; i < Object.keys(statusLeaderboard['leaderboard']).length; i++) {
        if (Object.keys(sortable)[i] == message.author.id) {
            foundInLeaderboard = true;
            let embed = {
                "title": `Leaderboard Info`,
                "description": 'To take part in the competition for **1x Lockslot**, place `discord.gg/urkfivem` in your status.'+'```\nYou are currently '+(i+1)+'/'+Object.keys(statusLeaderboard['leaderboard']).length+' on the leaderboard.```<@'+message.author.id+'>',
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
            break;
        }
    }

    if(!foundInLeaderboard) {
        let embed = {
            "title": `Leaderboard Info`,
            "description": 'You need to have `discord.gg/urkfivem` in your status to participate in the leaderboard competition for **1x Lockslot**.'+'```\nYou are currently not on the leaderboard due to the missing status.```<@'+message.author.id+'>',
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed });
    }
}

exports.conf = {
    name: "leaderboard",
    perm: 0,
    guild: "1203967504641163304"
}