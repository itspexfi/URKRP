RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

local blockedWords = {"nigger", "nigga", "wog", "coon", "paki"}

local cooldown = {}

AddEventHandler('_chat:messageEntered', function(author, color, message)
    local name = GetPlayerName(source)
    if not message or not author then
        return
    end

    if not WasEventCanceled() then
        if cooldown[source] and not (os.time() > cooldown[source]) then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"URK", "You are being rate limited."},
                type = "alert"
            })
            return
        else
            cooldown[source] = nil
        end

        for k,v in pairs(blockedWords) do
            if string.match(message:lower(), v) then
                CancelEvent()
                return
            end
        end
        cooldown[source] = os.time() + 2

        -- Twitter style if message starts with /twt or /twitter
        if message:sub(1, 4) == "/twt" or message:sub(1, 8) == "/twitter" then
            TriggerClientEvent('chat:addMessage', -1, {
                color = {29, 161, 242},
                multiline = true,
                args = {"Twitter @"..author..":", message:gsub("^/twt ?", ""):gsub("^/twitter ?", "")},
                type = "twt"
            })
        -- OOC style if message starts with /ooc
        elseif message:sub(1, 4) == "/ooc" then
            TriggerClientEvent('chat:addMessage', -1, {
                color = {255, 255, 255},
                multiline = true,
                args = {"OOC | "..author..":", message:gsub("^/ooc ?", "")},
                type = "ooc"
            })
        -- Staff alert if message starts with /staff
        elseif message:sub(1, 6) == "/staff" then
            TriggerClientEvent('chat:addMessage', -1, {
                color = {103, 1, 199},
                multiline = true,
                args = {"STAFF | "..author..":", message:gsub("^/staff ?", "")},
                type = "staff"
            })
        -- Default message
        else
            TriggerClientEvent('chat:addMessage', -1, {
                color = {255, 255, 255},
                multiline = true,
                args = {author..":", message},
                type = "ooc"
            })
        end
        TriggerEvent("chat:TwitterLogs", message, name, source)
    end
end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
    TriggerClientEvent('chat:addMessage', -1, {
        color = {255, 255, 255},
        multiline = true,
        args = {name, '/' .. command},
        type = "ooc"
    })
    CancelEvent()
end)

-- command suggestions for clients
local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()
        local suggestions = {}
        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end
        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)
    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)