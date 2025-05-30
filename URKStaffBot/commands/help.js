exports.runcmd = (fivemexports, client, message, params) => {
const { resourcePath, settingsjson } = require('./pathHelper');

const embed = {
        "title": " URK Droid Help",
        "description": "" + '**Public Commands:**\n!bid\n!boost\n!bugs\n!carreport\n!ch\n!getroles\n!help\n!hmc\n!ip\n!locklist\n!staffapp\n!stats\n!leaderboard\n!store\n!support\n!verify\n\n**Staff Commands:**\n!addbaninfo\n!checkban\n!ban\n!checkrented\n!groups\n!notes\n!profile\n\n**Management Commands:**\n!addgroup\n!auction\n!clear\n!clearwarnings\n!delcar\n!embed\n!punishments\n!delgroup\n!reverify\n!rulechange\n!serverstats\n!vote' + " ",
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed });
}


// "description": `Here is a list of available commands:\n${commandList}`,

exports.conf = {
    name: "help",
    guild: "1203967504641163304"
}