const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!boot [permid]`',
            "color": 0xed4245,
        }
        return message.channel.send({ embed })
    }
    
    fivemexports.urk.urkbot('boot', [params[0]]);
    let embed = {
        "title": "Booted User",
        "description": `\nPerm ID: **${params[0]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
};

exports.conf = {
    name: "boot",
    perm: 6,
    guild: "1203967504641163304"
}
