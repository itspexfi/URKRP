const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (params[1] == "-1") {
        let newval = fivemexports.urk.urkbot('banDiscord', [params[0], "perm", `${reason}`, `${adminname} via Discord.`])
    }
    else {
        let newval = fivemexports.urk.urkbot('banDiscord', [params[0], params[1], `${reason}`, `${adminname} via Discord.`])
    }
    let embed = {
        "title": "Banned User",
        "description": `\nPerm ID: **${params[0]}**\nTime: **${params[1]} hours**\nReason: **${reason}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ``
        },
        "timestamp": new Date()
    }
    message.channel.send({embed})
};

exports.conf = {
    name: "ban",
    perm: 3,
    guild: "1203967504641163304"
}
