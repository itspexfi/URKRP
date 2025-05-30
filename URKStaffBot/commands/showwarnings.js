const { resourcePath, settingsjson } = require('./pathHelper');
const AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: `!sw [permid]`",
            "color": 0xed4245
        }
        return message.channel.send({ embed });
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM urk_warnings WHERE user_id = ?", [params[0]], (result) => {
        if (!result || result.length === 0) {
            return message.reply(`Perm ID ${params[0]} has no warnings!`);
        }

        var table = new AsciiTable();
        table.setHeading('ID', 'Type', 'Duration', 'Reason', 'Admin', 'Date');
        
        for (let i = 0; i < result.length; i++) {
            var date = new Date(+result[i].warning_date);
            table.addRow(result[i].warning_id, result[i].warning_type, result[i].duration, result[i].reason, result[i].admin, date.toDateString());
        }

        message.channel.send('```ascii\n' + table.toString() + '```').catch(err => {
            fs.writeFile(`${client.path}/warnings_${params[0]}.txt`, table.toString(), function(err) {
                message.channel.send(`This F10 is too large for Discord, ${message.author}`, { files: [`${client.path}/warnings_${params[0]}.txt`] }).then(ss => {
                    fs.unlinkSync(`${client.path}/warnings_${params[0]}.txt`);
                });
            });
        });
    });
}

exports.conf = {
    name: "sw",
    perm: 1,
    guild: "1203967504641163304",
    support: true
}