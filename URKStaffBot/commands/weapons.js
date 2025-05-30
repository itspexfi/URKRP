const { resourcePath, settingsjson } = require('./pathHelper');
const AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: `!weapons [permid]`",
            "color": 0xed4245
        }
        return message.channel.send({ embed });
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM urk_user_weapons WHERE user_id = ?", [params[0]], (result) => {
        if (!result || result.length === 0) {
            return message.reply(`${params[0]} has no weapons!`);
        }

        var table = new AsciiTable();
        table.setHeading('Weapon Name', 'Hash', 'Price', 'Category');
        
        for (let i = 0; i < result.length; i++) {
            table.addRow(result[i].name, result[i].gunhash, result[i].price, result[i].category);
        }

        message.channel.send('```ascii\n' + table.toString() + '```').catch(err => {
            fs.writeFile(`${client.path}/weapons_${params[0]}.txt`, table.toString(), function(err) {
                message.channel.send(`Perm ID ${params[0]}'s weapons is too big!, ${message.author}`, { files: [`${client.path}/weapons_${params[0]}.txt`] }).then(ss => {
                    fs.unlinkSync(`${client.path}/weapons_${params[0]}.txt`);
                });
            });
        });
    });
}

exports.conf = {
    name: "weapons",
    perm: 7,
    guild: "1203967504641163304"
}