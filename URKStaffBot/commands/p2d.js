const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        message.channel.send('Please provide a user ID to check.');
        return;
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE user_id = ?", [params[0]], (result) => {
        if (result.length > 0) {
            let embed = {
                "title": "Discord Account for " + params[0] + "",
                "description": `\n\n Linked Discords: \n<@${result[0].discord_id}> \n\nVerified Discord: \nNon Found`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": 'URK Droid'
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed });
        } else {
            message.channel.send('No linked Discord account found for this user ID.');
        }
    });
};

exports.conf = {
    name: "p2d",
    perm: 1,
    guild: "1203967504641163304",
    support: true,
}