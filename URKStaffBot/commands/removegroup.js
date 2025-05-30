const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !params[1]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: `!delgroup [permid] [groupname]`",
            "color": 0xed4245
        }
        return message.channel.send({ embed });
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE user_id = ?", [params[0]], (result) => {
        if (!result || result.length === 0) {
            let embed = {
                "title": "An Error Occurred",
                "description": "User not found.",
                "color": 0xed4245
            }
            return message.channel.send({ embed });
        }

        let dvalue = JSON.parse(result[0].dvalue);
        if (!dvalue.groups || !dvalue.groups[params[1]]) {
            let embed = {
                "title": "An Error Occurred",
                "description": "User does not have this group.",
                "color": 0xed4245
            }
            return message.channel.send({ embed });
        }

        delete dvalue.groups[params[1]];
        
        fivemexports.ghmattimysql.execute("UPDATE `urk_user_data` SET dvalue = ? WHERE user_id = ?", [JSON.stringify(dvalue), params[0]], () => {
            let embed = {
                "title": "Removed Group",
                "description": `\nPerm ID: **${params[0]}**\nGroup Name: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
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
    name: "delgroup",
    perm: 6,
    guild: "1203967504641163304"
}