const { resourcePath, settingsjson } = require('./pathHelper');
const AsciiTable = require('ascii-table');

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.ghmattimysql.execute("SELECT u.user_id, u.bank, v.username FROM urk_user_moneys u JOIN urk_users v ON u.user_id = v.id ORDER BY u.bank DESC LIMIT 10", [], (result) => {
        if (!result || result.length === 0) {
            let embed = {
                "title": "Top 10 Richest Players",
                "description": "No players found.",
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            return message.channel.send({ embed });
        }

        var table = new AsciiTable();
        table.setHeading('Rank', 'Username', 'Bank Balance');
        
        for (let i = 0; i < result.length; i++) {
            if (i < 10) {
                table.addRow(i + 1, result[i].username, `£${result[i].bank.toLocaleString()}`);
            }
        }

        message.channel.send('```ascii\n' + table.toString() + '```');
    });
}

exports.conf = {
    name: "top10",
    perm: 0,
    guild: "1203967504641163304"
}