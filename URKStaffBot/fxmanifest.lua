fx_version 'cerulean'
games { 'gta5' }
author ''
description 'This is a discord bot made by URKStudios.'

server_only 'yes'

dependency 'yarn'

server_scripts {
    "@urk/lib/utils.lua",
    "bot.js"
}

server_exports {
    'dmUser',
}