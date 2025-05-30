const { resourcePath, settingsjson } = require('./pathHelper');

exports.runcmd = async(fivemexports, client, message, params) => {
    let rolesCount = 0;
    let rolesOwned = [];
    let descriptionText = ':white_check_mark: You have received your discord roles:';
    fivemexports.ghmattimysql.execute("SELECT user_id FROM `urk_verification` WHERE discord_id = ?", [message.author.id], (error, result) => {
        if (error) {
            console.error('Error executing first SQL query:', error);
            return;
        }

        if (result && result.length > 0) {
            let user_id = result[0].user_id;
            fivemexports.ghmattimysql.execute("SELECT * FROM `urk_user_data` WHERE user_id = ? AND dkey = 'URK:datatable'", [user_id], (error, data) => {
                if (error) {
                    console.error('Error executing second SQL query:', error);
                    return;
                }

                if (data && data[0]) {
                    try {
                        let groupsdata = JSON.parse(Object.values(data[0])).groups;
                        for (const [key, value] of Object.entries(groupsdata)) {
                            for (let j = 0; j < groups.length; j++) {
                                if (groups[j] === key) {
                                    let role = message.guild.roles.cache.find(r => r.name === `${groups[j]}`);
                                    if (role) {
                                        rolesCount += 1;
                                        rolesOwned.push(`\n${key}`);
                                        message.member.roles.add(role.id).catch(console.error);
                                    }
                                }
                            }
                        }
                        if (rolesCount > 0 ) {
                            let embed = {
                                "title": "Roles",
                                "description": descriptionText+'```\n'+rolesOwned.join('').replace(',', '')+'```',
                                "color": settingsjson.settings.botColour,
                                "footer": {
                                    "text": ""
                                },
                                "timestamp": new Date()
                            }
                            message.channel.send({ embed });
                        }
                    } catch (error) {
                        console.error('Error parsing JSON:', error);
                    }
                } else {
                    console.error('Invalid data received from database');
                }
            });
        } else {
            console.error('No results returned from first SQL query');
        }
    });
};


// You have no missing roles that need adding --needs adding eventually

exports.conf = {
    name: "getroles",
    perm: 0,
    guild: "1203967504641163304"
}
