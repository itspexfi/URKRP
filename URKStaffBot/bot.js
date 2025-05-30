const Discord = require('discord.js');
const { SlashCommandBuilder } = require('@discordjs/builders');
const path = require('path');

// Get the resource path, handling both FiveM and standalone environments
let resourcePath;
try {
    resourcePath = global.GetResourcePath ? 
        global.GetResourcePath(global.GetCurrentResourceName()) : 
        __dirname;
} catch (error) {
    resourcePath = __dirname;
}

require('dotenv').config({ path: path.join(resourcePath, '.env') });
console.log('Loaded token:', process.env.TOKEN);
const fs = require('fs');
const settingsjson = require(path.join(resourcePath, 'settings.js'));
var statusLeaderboard = require(path.join(resourcePath, 'statusleaderboard.json'));

const client = new Discord.Client();

// Now it's safe to use client
client.path = resourcePath;
client.ip = settingsjson.settings.ip;

// Validate token before creating client
if (!process.env.TOKEN || process.env.TOKEN === "TOKEN" || process.env.TOKEN === "") {
    console.error('Error: Invalid or missing bot token in .env file');
    process.exit(1);
}

// Add token validation
const tokenRegex = /^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$/;
if (!tokenRegex.test(process.env.TOKEN)) {
    console.error('Error: Invalid token format in .env file');
    process.exit(1);
}

// Add connection retry logic with exponential backoff
let retryCount = 0;
const maxRetries = 5;
const baseDelay = 1000;
let currentDelay = baseDelay;

async function connectWithRetry() {
    try {
        await client.login(process.env.TOKEN);
        console.log('Successfully connected to Discord');
        retryCount = 0;
        currentDelay = baseDelay;
    } catch (error) {
        console.error('Failed to connect:', error.message);
        
        if (retryCount < maxRetries) {
            retryCount++;
            currentDelay = Math.min(currentDelay * 2, 30000); // Exponential backoff with max 30s
            console.log(`Retrying in ${currentDelay/1000} seconds... (Attempt ${retryCount}/${maxRetries})`);
            setTimeout(connectWithRetry, currentDelay);
        } else {
            console.error('Max retries reached. Please check your token and try again.');
            process.exit(1);
        }
    }
}

// Add error handlers
client.on('error', error => {
    console.error('Discord client error:', error.message);
    if (error.code === 'ECONNRESET' || error.code === 'ETIMEDOUT') {
        console.log('Connection error, attempting to reconnect...');
        connectWithRetry();
    }
});

client.on('disconnect', () => {
    console.log('Disconnected from Discord, attempting to reconnect...');
    connectWithRetry();
});

// Add periodic connection check
setInterval(() => {
    if (!client.ws.connection) {
        console.log('Connection check: Not connected, attempting to reconnect...');
        connectWithRetry();
    }
}, 30000);

// Add proper error handling for all Discord API calls
async function safeDiscordCall(callback, ...args) {
    try {
        return await callback(...args);
    } catch (error) {
        console.error('Discord API call failed:', error.message);
        if (error.code === 'ECONNRESET' || error.code === 'ETIMEDOUT') {
            if (retryCount < maxRetries) {
                retryCount++;
                currentDelay = Math.min(currentDelay * 2, 30000);
                console.log(`Retrying in ${currentDelay/1000} seconds... (Attempt ${retryCount}/${maxRetries})`);
                await new Promise(resolve => setTimeout(resolve, currentDelay));
                return safeDiscordCall(callback, ...args);
            }
        }
        throw error;
    }
}

// Add these helper functions at the top of the file after the requires
const isFiveM = typeof global.GetResourcePath === 'function';

function getPlayerCount() {
    if (isFiveM) {
        return GetNumPlayerIndices();
    }
    return 0; // Default value when not in FiveM
}

function getMaxClients() {
    if (isFiveM) {
        return GetConvarInt("sv_maxclients", 128);
    }
    return 128; // Default value when not in FiveM
}

client.on('ready', () => {
    console.log(`Logged in as ${client.user.tag}! Players: ${getPlayerCount()}`);
    console.log(`Your Prefix Is ${process.env.PREFIX}`)
    client.user.setActivity(`${getPlayerCount()}/${getMaxClients()} players`, { type: 'WATCHING' });
    init()
});

let onlinePD = 0
let onlineStaff = 0
let onlineNHS = 0
let serverStatus = ""
let memberCount = 0;
let currentFooterEmoji = '⚪';

setInterval(() => {
    if (currentFooterEmoji === "⚪") {
        currentFooterEmoji = "⚫";
    } else {
        currentFooterEmoji = "⚪";
    }
}, 300);

if (settingsjson.settings.StatusEnabled) {
    setInterval(async () => {
        try {
            if (!client.guilds.get(settingsjson.settings.GuildID)) {
                console.log(`Status is enabled but not configured correctly and will not work as intended.`);
                return;
            }

            let guild = client.guilds.get(settingsjson.settings.GuildID);
            memberCount = guild.memberCount;

            let settingsjsons = require(resourcePath + '/params.json');
            let totalSeconds = (client.uptime / 1000);
            totalSeconds %= 5000;
            client.user.setActivity(`${getPlayerCount()}/${getMaxClients()} players`, { type: 'WATCHING' });

            // Only execute database queries if in FiveM environment
            if (isFiveM) {
                exports.ghmattimysql.execute("SELECT * FROM `urk_users`", (result) => {
                    playersSinceRelease = result.length;
                });

                exports.urk.urkbot('getUsersByPermission', ['police.onduty.permission'], function(result) {
                    if (!result.length)
                        onlinePD = 0;
                    else
                        onlinePD = result.length;
                });

                exports.urk.urkbot('getUsersByPermission', ['admin.tickets'], function(result) {
                    if (!result.length)
                        onlineStaff = 0;
                    else
                        onlineStaff = result.length;
                });

                exports.urk.urkbot('getUsersByPermission', ['nhs.onduty.permission'], function(result) {
                    if (!result.length)
                        onlineNHS = 0;
                    else
                        onlineNHS = result.length;
                });

                exports.ghmattimysql.execute("SELECT * FROM urk_users WHERE banned = 1", (result) => {
                    bannedPlayers = result.length;
                });
            } else {
                // Default values for standalone mode
                onlinePD = 0;
                onlineStaff = 0;
                onlineNHS = 0;
                bannedPlayers = 0;
                playersSinceRelease = 0;
            }

            let botPing = Math.round(client.ws.ping);

            let status = {
                "color": settingsjson.settings.botColour,
                "fields": [{
                    "name": "Server Status",
                    "value": `✅ Online`,
                    "inline": true
                },
                {
                    "name": "Average Player Ping",
                    "value": `${MathRandomised(8, 27)}ms`,
                    "inline": true
                },
                {
                    "name": "Police",
                    "value": `${onlinePD}`,
                    "inline": true
                },
                {
                    "name": "NHS",
                    "value": `${onlineNHS}`,
                    "inline": true
                },
                {
                    "name": "💂‍♂️ Staff",
                    "value": `${onlineStaff}`,
                    "inline": true
                },
                {
                    "name": "👫 Players",
                    "value": `${getPlayerCount()}/${getMaxClients()}`,
                    "inline": true
                },
                {
                    "name": "<:discord:1125889313880686633> Members",
                    "value": `${memberCount}`,
                    "inline": true
                },
                {
                    "name": "",
                    "value": ``,
                    "inline": true
                },
                {
                    "name": "How do I direct connect?",
                    "value": '``F8 -> connect s1.urkstudios.co.uk``',
                    "inline": true
                },
                {
                    "name": "",
                    "value": ``,
                    "inline": true
                }],
                "author": {
                    "name": "URK Server #1 Status",
                    "icon_url": "https://cdn.discordapp.com/attachments/1073970014081790043/1127283719334527016/276565361_1_13.png"
                },
                "footer": {
                    "text": `${currentFooterEmoji} URK`
                },
                "timestamp": new Date()
            };

            await safeDiscordCall(async () => {
                const channelid = guild.channels.find(r => r.name === settingsjson.settings.StatusChannel);
                if (!channelid) {
                    console.log(`Status channel is not available / cannot be found.`);
                    return;
                }

                const msg = await channelid.fetchMessage(settingsjsons.messageid);
                await msg.edit({ embed: status });
            });
        } catch (error) {
            console.error('Error updating status:', error);
        }
    }, 7000);
}

client.commands = new Discord.Collection();

const init = async() => {
  console.log('Starting command initialization...');
  fs.readdir(resourcePath + '/commands/', (err, files) => {
    if (err) {
      console.error('Error reading commands directory:', err);
      return;
    }
    console.log('Found files:', files);
    files = files.filter(f => f !== 'pathHelper.js' && f !== 'updateCommands.js');
    console.log(`Loading a total of ${files.length} commands.`);
    
    let loadedCommands = 0;
    files.forEach(f => {
      try {
        console.log(`Loading command: ${f}`);
        let command = require(`${resourcePath}/commands/${f}`);
        if (!command.conf || !command.conf.name) {
          console.error(`Command file ${f} is missing exports.conf or name property.`);
        } else {
          client.commands.set(command.conf.name, command);
          loadedCommands++;
        }
      } catch (error) {
        console.error(`Error loading command ${f}:`, error);
      }
    });
    console.log(`Successfully loaded ${loadedCommands} commands.`);

    if (!statusLeaderboard['leaderboard']) {
      statusLeaderboard['leaderboard'] = {};
    } else {
      statusLeaderboard['leaderboard'] = statusLeaderboard['leaderboard'];
    }
    console.log('Command initialization complete.');
  });
}

setInterval(function(){
  promotionDetection();
}, 60*1000);

function promotionDetection(){
  client.users.forEach(user =>{ //iterate over each user
    if(user.presence.status == "online" || user.presence.status == 'dnd' || user.presence.status == 'idle' && !user.bot){ //check if user is online and is not a bot
      if(!statusLeaderboard['leaderboard'][user.id]){ // if user hasn't  created a profile before
        var userProfile = {}; // create new profile
        statusLeaderboard['leaderboard'][user.id] = userProfile; //set profile to object literal
        statusLeaderboard['leaderboard'][user.id] = 0; //set minutes to 0
      }
      if(Object.entries(user.presence.activities).length > 0 && typeof(user.presence.activities[0].state) === 'string' && user.presence.activities[0].state.includes('discord.gg/urkfivem') ){ //check if they have a status
        statusLeaderboard['leaderboard'][user.id] += 1;
        fs.writeFileSync(`${resourcePath}/statusleaderboard.json`, JSON.stringify(statusLeaderboard), function(err) {});
      }
      else {
        // remove user from leaderboard if their status no longer includes "12345"
        delete statusLeaderboard['leaderboard'][user.id];
        fs.writeFileSync(`${resourcePath}/statusleaderboard.json`, JSON.stringify(statusLeaderboard), function(err) {});
      }
    }
  })
}

client.getPerms = function(msg) {

    let settings = settingsjson.settings
    let lvl1 = msg.guild.roles.find(r => r.name === settings.Level1Perm);
    let lvl2 = msg.guild.roles.find(r => r.name === settings.Level2Perm);
    let lvl3 = msg.guild.roles.find(r => r.name === settings.Level3Perm);
    let lvl4 = msg.guild.roles.find(r => r.name === settings.Level4Perm);
    let lvl5 = msg.guild.roles.find(r => r.name === settings.Level5Perm);
    let lvl6 = msg.guild.roles.find(r => r.name === settings.Level6Perm);
    let lvl7 = msg.guild.roles.find(r => r.name === settings.Level7Perm);
    let lvl8 = msg.guild.roles.find(r => r.name === settings.Level8Perm);
    let lvl9 = msg.guild.roles.find(r => r.name === settings.Level9Perm);
    let lvl10 = msg.guild.roles.find(r => r.name === settings.Level10Perm);
    let lvl11 = msg.guild.roles.find(r => r.name === settings.Level11Perm);
    if (!lvl1 || !lvl2 || !lvl3 || !lvl4 || !lvl5 || !lvl6 || !lvl7 || !lvl8 || !lvl9 || !lvl10 || !lvl11) {
        console.log(`Your permissions are not setup correctly and the bot will not function as intended.\nStatus: Please check permission levels are setup correctly.`)
    }

    // hot fix for Discord role caching 
    const guild = client.guilds.get(msg.guild.id);
    if (guild.members.has(msg.author.id)) {
        guild.members.delete(msg.author.id);
    }
    const member = guild.members.get(msg.author.id);
    // hot fix for Discord role caching 

    let level = 0;
    if (msg.member.roles.has(lvl11.id)) {
        level = 11;
    } else if (msg.member.roles.has(lvl10.id)) {
        level = 10;
    } else if (msg.member.roles.has(lvl9.id)) {
        level = 9;
    } else if (msg.member.roles.has(lvl8.id)) {
        level = 8;
    } else if (msg.member.roles.has(lvl7.id)) {
        level = 7;
    } else if (msg.member.roles.has(lvl6.id)) {
        level = 6;
    } else if (msg.member.roles.has(lvl5.id)) {
        level = 5;
    } else if (msg.member.roles.has(lvl4.id)) {
        level = 4;
    } else if (msg.member.roles.has(lvl3.id)) {
        level = 3;
    } else if (msg.member.roles.has(lvl2.id)) {
        level = 2;
    } else if (msg.member.roles.has(lvl1.id)) {
        level = 1;
    }
    return level
}
client.on('message', (message) => {
    if (!message.author.bot){
        if (message.channel.name.includes('auction-')){
            if (message.channel.name == '・auction-room'){
                return
            }
            else{
                if (!message.content.includes(`${process.env.PREFIX}bid`)){
                    if (!message.content.includes(`${process.env.PREFIX}auction`) && !message.content.includes(`${process.env.PREFIX}houseauction`) && !message.content.includes(`${process.env.PREFIX}embed`)){
                        message.delete()
                        return
                    }
                }
            }
        }else if (message.channel.name.includes('verify')){
            if (!message.content.includes(`${process.env.PREFIX}verify `)){
                message.delete()
                return
            }
        }
    }
    let client = message.client;
    if (message.author.bot) return;
    if (!message.content.startsWith(process.env.PREFIX)) return;
    let command = message.content.split(' ')[0].slice(process.env.PREFIX.length).toLowerCase();
    let params = message.content.split(' ').slice(1);
    let cmd;
    let permissions = 0
    if (message.guild.id === settingsjson.settings.GuildID) {
        permissions = client.getPerms(message)
    }
    if (client.commands.has(command)) {
        cmd = client.commands.get(command);
    }
    if (cmd) {
        if (message.guild.id === cmd.conf.guild) {
            if (!message.channel.name.includes('verify') && cmd.conf.name === 'verify'){
                message.delete()
                message.reply('Please use #verify for this command.').then(msg => {
                    msg.delete(5000)
                })
                return
            }else if (!message.channel.name.includes('bot') && !message.channel.name.includes('verify') && !cmd.name === 'embed') {
                message.delete()
                message.reply('Please use bot commands for this command.').then(msg => {
                    msg.delete(5000)
                })
            }
            else {
                if (permissions < cmd.conf.perm) return;
                try {
                    cmd.runcmd(exports, client, message, params, permissions);
                    if (cmd.conf.perm > 0 && params) { // being above 0 means won't log commands meant for anyone that isn't staff
                        params = params.join('\n ');
                        if (params != '') {
                            let { Webhook, MessageBuilder } = require('discord-webhook-node');
                            let hook = new Webhook(settingsjson.settings.botLogWebhook);
                            let embed = new MessageBuilder()
                            .setTitle('Bot Command Log')
                            .addField('Command Used:', `${cmd.conf.name}`)
                            .addField('Parameters:', `${params}`)
                            .addField('Admin:', `${message.author.username} - <@${message.author.id}>`)
                            .setColor(settingsjson.settings.botColour)
                            .setFooter('URK')
                            .setTimestamp();
                            hook.send(embed);
                        }
                    }
                } catch (err) {
                    let embed = {
                        "title": "Error Occured!",
                        "description": "\nAn error occured. Contact <@881944946381324318> about the issue:\n\n```" + err.message + "\n```",
                        "color": settingsjson.settings.botColour,
                    }
                    message.channel.send({ embed })
                }
            }
        } else {
            if (cmd.conf.support && message.guild.id === "1377405630066856058"){
                if (message.member.roles.has("1108703825528881205")){
                    cmd.runcmd(exports, client, message, params, permissions);
                }
            } else {
                message.reply('This command is expected to be used within another guild.').then(msg => {
                    msg.delete(5000)
                })
                return;
            }
        }
    }
});

function MathRandomised(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min) + min); //The maximum is exclusive and the minimum is inclusive
}

client.on("guildMemberAdd", function (member) {
    if (member.guild.id === settingsjson.settings.GuildID){
        try {
            exports.ghmattimysql.execute("SELECT * FROM `urk_verification` WHERE discord_id = ? AND verified = 1", [member.id], (result) => {
                if (result.length > 0){
                    let role = member.guild.roles.find(r => r.name === '| Verified');
                    member.addRole(role);
                }
            });
        
        } catch (error) {}
    }
});

// Handle both FiveM and standalone environments
if (typeof exports === 'function') {
    // FiveM environment
    exports('dmUser', (source, args) => {
        let discordid = args[0].trim()
        let verifycode = args[1]
        let permid = args[2]
        const guild = client.guilds.get(settingsjson.settings.GuildID);
        const member = guild.members.get(discordid);
        try {
            let embed = {
                "title": `Discord Account Link Request`,
                "description": `User ID ${permid} has requested to link this Discord account.\n\nThe code to link is **${verifycode}**\nThis code will expire in 5 minutes.\n\nIf you have not requested this then you can safely ignore the message. Do **NOT** share this message or code with anyone else.`,
                "color": settingsjson.settings.botColour,
                "thumbnail": {
                    "url": "https://cdn.discordapp.com/icons/995069542852202557/719d25a3f8b4852159905244bfed520b.webp?size=2048",
                },
            }
            member.send({embed})
        } catch (error) {}
    });
} else {
    // Standalone environment
    module.exports = {
        dmUser: (source, args) => {
            let discordid = args[0].trim()
            let verifycode = args[1]
            let permid = args[2]
            const guild = client.guilds.get(settingsjson.settings.GuildID);
            const member = guild.members.get(discordid);
            try {
                let embed = {
                    "title": `Discord Account Link Request`,
                    "description": `User ID ${permid} has requested to link this Discord account.\n\nThe code to link is **${verifycode}**\nThis code will expire in 5 minutes.\n\nIf you have not requested this then you can safely ignore the message. Do **NOT** share this message or code with anyone else.`,
                    "color": settingsjson.settings.botColour,
                    "thumbnail": {
                        "url": "https://cdn.discordapp.com/icons/995069542852202557/719d25a3f8b4852159905244bfed520b.webp?size=2048",
                    },
                }
                member.send({embed})
            } catch (error) {}
        }
    };
}

// Replace the client.login() call with connectWithRetry()
connectWithRetry();