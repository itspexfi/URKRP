const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    message.delete()
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!vote [vote contents]`',
            "color": 0xed4245,
    }
    return message.channel.send({ embed })
    }
    let embed = {
        "title": "Community Vote",
        "description": `\n${vote}`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": `Please vote to make an impact on the server.`
        },
        "timestamp": new Date()
    }
    const channel = client.channels.find(channel => channel.name === settingsjson.settings.VoteChannel)
    
    channel.send({embed}).then(function (message) {
        message.react("👍")
        message.react("👎")
    })
    channel.send(`||@everyone||`)
    message.channel.send(`Started community vote in ${channel}`)
}

exports.conf = {
    name: "vote",
    perm: 5,
    guild: "1203967504641163304"
}