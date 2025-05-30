const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !params[1]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!changeid [oldpermid] [newpermid]`',
            "color": 0xed4245,
        }
        return message.channel.send({ embed })
    }

    fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_ids WHERE user_id = ?", [parseInt(params[0])], (change) => {
        fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_ids WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
            for (let i = 0; i < change.length; i++) {
                fivemexports['ghmattimysql'].execute('UPDATE urk_user_ids SET user_id = ? WHERE identifier = ?', [parseInt(params[1]), change[i].identifier])
            }
            for (let i = 0; i < changeto.length; i++) {
                fivemexports['ghmattimysql'].execute('UPDATE urk_user_ids SET user_id = ? WHERE identifier = ?', [parseInt(params[0]), changeto[i].identifier])
            }
            fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_data WHERE user_id = ?", [parseInt(params[0])], async(change) => {
                fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_data WHERE user_id = ?", [parseInt(params[1])], async(changeto) => {
                    //Change USER DATA
                    await fivemexports['ghmattimysql'].execute("DELETE FROM urk_user_data WHERE user_id = ?", [parseInt(params[0])])
                    await fivemexports['ghmattimysql'].execute("DELETE FROM urk_user_data WHERE user_id = ?", [parseInt(params[1])])
                    for (let i = 0; i < change.length; i++) {
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "URK:datatable", change[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "URK:Face:Data", change[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "URK:home:wardrobe", change[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "URK:police_records", change[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[1]), "URK:jail:time", change[i].dvalue])
                    }
                    for (let i = 0; i < changeto.length; i++) {
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "URK:datatable", changeto[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "URK:Face:Data", changeto[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "URK:home:wardrobe", changeto[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "URK:police_records", changeto[i].dvalue])
                        fivemexports['ghmattimysql'].execute('INSERT INTO urk_user_data (user_id, dkey, dvalue) VALUES(?,?,?)', [parseInt(params[0]), "URK:jail:time", changeto[i].dvalue])
                    }
                })
            })
            fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_moneys WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_moneys WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (let i = 0; i < change.length; i++) {
                        fivemexports['ghmattimysql'].execute('UPDATE urk_user_moneys SET user_id = ? WHERE user_id = ?', [parseInt(params[1]), change[i].vehicle])
                    }
                    for (let i = 0; i < changeto.length; i++) {
                        fivemexports['ghmattimysql'].execute('UPDATE urk_user_moneys SET user_id = ? WHERE user_id = ?', [parseInt(params[0]), changeto[i].vehicle])
                    }
                })
            })
            fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_vehicles WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_vehicles WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (let i = 0; i < change.length; i++) {
                        setInterval(() => {
                            fivemexports['ghmattimysql'].execute('UPDATE urk_user_vehicles SET user_id = ? WHERE vehicle = ?', [parseInt(params[1]), change[i].vehicle])
                        }, 2000);
                    }
                    for (let i = 0; i < changeto.length; i++) {
                        setInterval(() => {
                            fivemexports['ghmattimysql'].execute('UPDATE urk_user_vehicles SET user_id = ? WHERE vehicle = ?', [parseInt(params[0]), changeto[i].vehicle])
                        }, 2000);
                    }
                })
            })
            fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_homes WHERE user_id = ?", [parseInt(params[0])], (change) => {
                fivemexports['ghmattimysql'].execute("SELECT * FROM urk_user_homes WHERE user_id = ?", [parseInt(params[1])], (changeto) => {
                    for (let i = 0; i < change.length; i++) {
                        fivemexports['ghmattimysql'].execute('UPDATE urk_user_homes SET user_id = ? WHERE home = ?', [parseInt(params[1]), change[i].home])
                    }
                    for (let i = 0; i < changeto.length; i++) {
                        fivemexports['ghmattimysql'].execute('UPDATE urk_user_homes SET user_id = ? WHERE home = ?', [parseInt(params[0]), changeto[i].home])
                    }
                })
            })                
        })
    })
    let embed = {
        "title": "Change Perm ID",
        "description": `\nOld Perm ID: **${params[0]}**\nNew Perm ID: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
};

exports.conf = {
    name: "changeid",
    perm: 5,
    guild: "1203967504641163304"
}