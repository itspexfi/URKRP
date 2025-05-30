const { resourcePath, settingsjson } = require('./pathHelper');

const { time } = require('console');
const Discord = require('discord.js');
const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send({embed})
    prevbids.prevbid = 0
    fs.writeFile(`${resourcePath}/prevbid.json`, JSON.stringify(prevbids), function(err) {});
    const role = message.guild.roles.find(r => r.name === "@everyone");

    message.channel.overwritePermissions(role, { SEND_MESSAGES: false })
    if (!params[0] || !params[1] || !params[2] || !params[3] || !params[4]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!houseauction [imagelink] [house-kg] [ends-at] [housename]`',
            "color": 0xed4245,
        }
        return message.channel.send({ embed })
    }
    else {
        imagelink = params[0]
        houseKG = params[1]
        endsat = params[2]
        houseName = `${params.join(' ').replace(params[0], '').replace(params[1], '').replace(params[2], '')}`
        message.guild.createChannel(`auction-${houseName}`, 'text')
        .then(channel => {
            let category = message.guild.channels.find(c => c.name == "🚗 [AUCTIONS]" && c.type == "category");
            channel.setParent(category.id);
            let embed = {
                "title": `Auction`,
                "fields": [
                    {
                        "name": '**Item**',
                        "value": houseName,
                        "inline": true,
                    },
                    {
                        "name": '**Info**',
                        "value": `Storage: ${houseKG}KG`,
                        "inline": true,
                    },
                    {
                        "name": '**Bidding Ends**',
                        "value": endsat,
                        "inline": true,
                    },
                ],
                "color": settingsjson.settings.botColour,
                "timestamp": new Date(),
                "footer": {
                    "text": "!bid [amount] to place a bid"
                },
                "image": {
                    "url": imagelink,
                },
            }
            channel.send({embed})
        }).catch(console.error);
        let embed = {
            "title": `Created Auction`,
            "description": `**Name:** ${houseName}\n**House KG:** ${houseKG}\n**Ends At:** ${endsat}\n\n**Created By:** ${message.author}`,
            "color": settingsjson.settings.botColour,
            "timestamp": new Date(),
            "image": {
                "url": imagelink,
            },
        }
        message.channel.send({embed})
    }
}

exports.conf = {
    name: "houseauction",
    perm: 5,
    guild: "1203967504641163304"
}