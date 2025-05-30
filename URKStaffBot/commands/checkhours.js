const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        message.channel.send('Please provide a user ID to check hours for.');
        return;
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE user_id = ?", [params[0]], (result) => {
        if (result.length > 0) {
            message.reply(`you have **${(JSON.parse(result[0].dvalue).PlayerTime/60).toFixed(2)}** hours`);
        } else {
            message.channel.send('No hours for this user.');
        }
    });
};

exports.conf = {
    name: "ch",
    perm: 0,
    guild: "1203967504641163304"
}