const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: `!reverify [permid]`",
            "color": 0xed4245
        }
        return message.channel.send({ embed });
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_verification` WHERE user_id = ?", [params[0]], (result) => {
        if (!result || result.length === 0) {
            let embed = {
                "title": "An Error Occurred",
                "description": "User is not verified.",
                "color": 0xed4245
            }
            return message.channel.send({ embed });
        }

        fivemexports.ghmattimysql.execute("UPDATE `urk_verification` SET verified = 0 WHERE user_id = ?", [params[0]], () => {
            let embed = {
                "title": "User Unverified",
                "description": `\nPerm ID: **${params[0]}**\n\nAdmin: <@${message.author.id}>`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
        });
    });
}

exports.conf = {
    name: "reverify",
    perm: 5,
    guild: "1203967504641163304"
}