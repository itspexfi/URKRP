const { resourcePath, settingsjson } = require('./pathHelper');

var AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !parseInt(params[0])) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!garage [permid]`',
            "color": 0xed4245,
        }
        return message.channel.send({ embed })
    }
    let count = 0
    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_vehicles` WHERE user_id = ?", [params[0]], (result) => {
        var vehicles = []
        for (i = 0; i < result.length; i++) {
            let results =  result.length
            let vehicle = result[i]; // get the current vehicle
            fivemexports.ghmattimysql.execute("SELECT * FROM urk_user_vehicles WHERE vehicle = ?", [vehicle.vehicle.toLowerCase()], (res) => {
                let carcount = result.length;
                if (vehicle.rented){
                    vehicles.push(`${vehicle.vehicle} - Rented\n`)
                }
                else{
                    vehicles.push(`${vehicle.vehicle} ${vehicle.locked ? "🔒" : ""}\n`)
                }                
                count ++
                if (count == results){
                    let embed = {
                        "title": `ID ${params[0]}'s Garage:`,
                        "description": '```\n'+vehicles.join('').replace(',', '')+'```',
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": `Requested by ${message.author.username}`
                        },
                        "timestamp": new Date()
                    }
                    message.channel.send({ embed }).catch(err => {
                        fs.writeFile(`${client.path}/garage_${params[0]}.txt`, vehicles.toString(), function(err) {
                            message.channel.send(`Perm ID ${params[0]}'s garage is too big!, ${message.author}`, { files: [`${client.path}/garage_${params[0]}.txt`] }).then(ss => {
                                fs.unlinkSync(`${client.path}/garage_${params[0]}.txt`)
                            })
                        });
                    })
                } 
            })
        }
        if (result.length == 0){
            return message.reply(`${params[0]} has no vehicles!`)
        }
    });
}

exports.conf = {
    name: "garage",
    perm: 3,
    guild: "1203967504641163304"
}
