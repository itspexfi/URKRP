exports.runcmd = (fivemexports, client, message, params) => {
const { resourcePath, settingsjson } = require('./pathHelper');

let newval = fivemexports.urk.urkbot('setBanned', [params[0], false])
    let embed = {
        "title": "Unbanned User",
        "description": `\nPerm ID: **${params[0]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "unban",
    perm: 5,
    guild: "1203967504641163304",
    support: true,
}