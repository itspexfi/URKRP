const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!message.mentions.users.size) {
        message.channel.send('You need to mention someone!');
        return;
    }
    // Add your command logic here, e.g., do something with the mentioned user
    const mentionedUser = message.mentions.users.first();
    message.channel.send(`You mentioned: <@${mentionedUser.id}>`);
};

exports.conf = {
    name: "d2p",
    perm: 1,
    guild: "1203967504641163304",
    support: true,
}