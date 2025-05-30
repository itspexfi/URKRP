const { resourcePath, settingsjson } = require('./pathHelper');

var AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

let descriptionText = ''

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!gco [spawn code]`',
            "color": 0xed4245,
    }
    return message.channel.send({ embed })
    }
    let count = 0
    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_vehicles` WHERE vehicle = ?", [params[0]], (result) => {
        var owners = []
        for (i = 0; i < result.length; i++) { 
            let user_id = result[i].user_id
            let results =  result.length
            let rented = false
            let locked = false
            if (result[i].rented)  {
                rented = true
            } 
            if (result[i].locked)  {
                descriptionText = '🔒 Vehicle is baller locked'
            }  
            else{
                descriptionText = '🔓 Vehicle is not baller locked'
            }
            fivemexports.ghmattimysql.execute("SELECT * FROM `urk_users` WHERE id = ?", [user_id], (result) => {
                if (result[0].bantime  == 'perm') {
                    if (rented){
                        owners.push(`${result[0].username}(${user_id}) - Rented (Permanently Banned)\n`)
                    }
                    else{
                        owners.push(`${result[0].username}(${user_id}) - (Permanently Banned)\n`)
                    }
                }
                else{
                    if (rented){
                        owners.push(`${result[0].username}(${user_id}) - Rented\n`)
                    }
                    else{
                        owners.push(`${result[0].username}(${user_id})\n`)
                    }
                }
                count ++ 
                if (count == results){
                    let embed = {
                        "title": `All Users that own ${params[0]}:`,
                        "description": descriptionText+'```\n'+owners.join('').replace(',', '')+'```',
                        "color": 0x57f288,
                        "footer": {
                            "text": `URK Studios | urkstudios.co.uk`
                        },
                        "timestamp": new Date()
                    }
                    message.channel.send({ embed }).catch(err => {
                        message.channel.send(`${params[0]} has too many owners to display in an embed.`)
                    })
                }    
            });  
        }
        if (result.length == 0){
            let embed = {
                "description": `No one owns this vehicle`,
                "color": 0xed4245,
            }
            return message.channel.send({ embed })
        }
    });
}

exports.conf = {
    name: "gco",
    perm: 1,
    guild: "1203967504641163304"
}