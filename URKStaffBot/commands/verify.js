const { resourcePath, settingsjson } = require('./pathHelper');
const { Webhook, MessageBuilder } = require('discord-webhook-node');

function daysBetween(dateString) {
    var d1 = new Date(dateString);
    var d2 = new Date();
    return Math.round((d2 - d1) / (1000 * 3600 * 24));
}

exports.runcmd = async(fivemexports, client, message, params) => {
    // Delete the user's message immediately
    try {
        await message.delete();
    } catch (error) {
        console.error('Error deleting message:', error);
    }

    if (!params[0] || !parseInt(params[0])) {
        let embed = {
            "title": "Verify",
            "description": `:x: Invalid command usage \`${process.env.PREFIX}verify [code]\``,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        let msg = await message.channel.send({ embed });
        setTimeout(() => msg.delete().catch(console.error), 10000);
        return;
    }

    fivemexports.ghmattimysql.execute("SELECT * FROM `urk_verification` WHERE code = ?", [params[0]], async (code) => {
        if (!code || code.length === 0) {
            let embed = {
                "title": "Verify",
                "description": `:x: That code does not exist.`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            let msg = await message.channel.send({ embed });
            setTimeout(() => msg.delete().catch(console.error), 10000);
            return;
        }

        if (code[0].discord_id !== null) {
            let embed = {
                "title": "Verify",
                "description": `:x: A discord account is already linked to this Perm ID, please contact Management to reverify.`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            let msg = await message.channel.send({ embed });
            setTimeout(() => msg.delete().catch(console.error), 10000);
            return;
        }

        try {
            await fivemexports.ghmattimysql.execute("UPDATE `urk_verification` SET discord_id = ?, verified = 1 WHERE code = ?", [message.author.id, params[0]]);
            
            let embed = {
                "title": "Verify",
                "description": `:white_check_mark: Success you're verified, head back in game and press connect. Have Fun!`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            let msg = await message.channel.send({ embed });
            setTimeout(() => msg.delete().catch(console.error), 10000);

            try {
                await message.member.addRole("1108703825528881205");
            } catch (error) {
                console.error('Error adding role:', error);
            }

            // Send verification log
            try {
                let hook = new Webhook(settingsjson.settings.verifyLogWebhook);
                let verifyLog = new MessageBuilder()
                    .setTitle('Verify Log')
                    .addField('Perm ID:', `${code[0].user_id}`)
                    .addField('Code:', `${params[0]}`)
                    .addField('Discord:', `${message.author}`)
                    .addField('Discord ID:', `${message.author.id}`)
                    .addField('Created At:', `${message.author.createdAt}`)
                    .addField('Account Age:', `${daysBetween(message.author.createdAt)} days`)
                    .setColor(settingsjson.settings.botColour)
                    .setFooter('URK')
                    .setTimestamp();
                await hook.send(verifyLog);
            } catch (error) {
                console.error('Error sending verification log:', error);
            }
        } catch (error) {
            console.error('Error during verification:', error);
            let embed = {
                "title": "Verify",
                "description": `:x: An error occurred during verification. Please try again or contact staff.`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            let msg = await message.channel.send({ embed });
            setTimeout(() => msg.delete().catch(console.error), 10000);
        }
    });
}

exports.conf = {
    name: "verify",
    perm: 0,
    guild: "1203967504641163304"
}