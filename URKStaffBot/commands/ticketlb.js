const { resourcePath, settingsjson } = require('./pathHelper');
const AsciiTable = require('ascii-table');

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.ghmattimysql.execute("SELECT user_id, username, COUNT(*) as ticket_count FROM urk_tickets GROUP BY user_id ORDER BY ticket_count DESC LIMIT 10", [], (result) => {
        if (!result || result.length === 0) {
            let embed = {
                "title": "Ticket Leaderboard",
                "description": "No tickets have been created yet.",
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            return message.channel.send({ embed });
        }

        let tickets = [];
        for (let i = 0; i < result.length; i++) {
            tickets.push(`\n${result[i].username}(${result[i].user_id}) - ${result[i].ticket_count}`);
        }

        let embed = {
            "title": `Ticket Leaderboard`,
            "description": '```' + tickets.join('').replace(',', '') + '```',
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed });
    });
}

exports.conf = {
    name: "ticketlb",
    perm: 6,
    guild: "1203967504641163304"
}