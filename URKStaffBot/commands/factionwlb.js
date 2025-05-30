const { resourcePath, settingsjson } = require('./pathHelper');
const AsciiTable = require('ascii-table');

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE dkey = 'URK:police_weekly_hours' ORDER BY weekly_hours DESC LIMIT 10", [], (result) => {
        const policeHoursLB = [];
        for (let i = 0; i < result.length; i++) {
            policeHoursLB.push(`\n${i+1}. ${result[i].username}(${result[i].user_id}) - ${result[i].weekly_hours.toFixed(2)} hours`);
        }
        let embed = {
            "title": `Met Police Weekly Leaderboard`,
            "description": '```' + policeHoursLB.join('').replace(',', '') + '```',
            "color": 0x3498db,
        };
        message.channel.send({ embed });
    });
};

exports.conf = {
    name: "wlb",
    perm: 0,
    guild: "1203967504641163304"
}