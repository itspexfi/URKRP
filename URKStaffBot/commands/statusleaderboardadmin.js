exports.runcmd = (fivemexports, client, message, params) => {
const { resourcePath, settingsjson } = require('./pathHelper');

for (i = 0; i < Object.keys(statusLeaderboard['leaderboard']).length; i++) {
        if (i < 10) {
            promoters.push(`${Object.keys(sortable)[i]} - ${(Object.values(sortable)[i]/60).toFixed(2)} hours promoted\n`)
        }
    }
    let embed = {
        "title": `Promotion Leaderboard`,
        "description": 'To take part in the competition for **1x Lockslot**, place `discord.gg/urkfivem` in your status.'+descriptionText+'```\n'+promoters.join('').replace(',', '')+'```',
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "leaderboardadmin",
    perm: 10,
    guild: "1203967504641163304"
}