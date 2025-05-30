const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE dkey = 'URK:banned'", [], (result) => {
        if (result.length > 0) {
            for (let i = 0; i < result.length; i++) {
                let newval = fivemexports.urk.urkbot('setBanned', [parseInt(result[i].id), false]);
            }
            
            let embed = {
                "title": "Ban Database Cleared",
                "description": `Number of Bans removed: ${result.length}\n\nAdmin: <@${message.author.id}>`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed });
        } else {
            message.channel.send('No bans found in the database.');
        }
    });
};

exports.conf = {
    name: "clearbans",
    perm: 7,
    guild: "1203967504641163304"
}