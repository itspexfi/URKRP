const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !parseInt(params[0]) || !params[1]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!addgroup [permid] [group name]`',
           "color": 0xed4245,
        }
    return message.channel.send({ embed })
    }
    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE user_id = ?", [params[0]], (result) => {
        if (result.length > 0) {
            let dvalue = JSON.parse(result[0].dvalue)
            let groups = dvalue.groups
            groups[params[1]] = true;
            fivemexports.ghmattimysql.execute("UPDATE `urk_user_data` SET dvalue = ? WHERE user_id = ?", [JSON.stringify(dvalue), params[0]])
        }
    })
    let embed = {
        "title": "Added Group",
        "description": `\nPerm ID: **${params[0]}**\nGroup Name: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "addgroup",
    perm: 5,
    guild: "1203967504641163304"
}