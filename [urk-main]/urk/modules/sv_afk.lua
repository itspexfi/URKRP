function getPlayerFaction(user_id)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        return 'pd'
    elseif URK.hasPermission(user_id, 'nhs.onduty.permission') then
        return 'nhs'
    elseif URK.hasPermission(user_id, 'hmp.onduty.permission') then
        return 'hmp'
    elseif URK.hasPermission(user_id, 'lfb.onduty.permission') then
        return 'lfb'
    end
    return nil
end


RegisterServerEvent('URK:factionAfkAlert')
AddEventHandler('URK:factionAfkAlert', function(text)
    local source = source
    local user_id = URK.getUserId(source)
    if getPlayerFaction(user_id) ~= nil then
        tURK.sendWebhook(getPlayerFaction(user_id)..'-afk', 'URK AFK Logs', "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Info: **"..text.."**")
    end
end)

RegisterServerEvent('URK:setNoLongerAFK')
AddEventHandler('URK:setNoLongerAFK', function()
    local source = source
    local user_id = URK.getUserId(source)
    if getPlayerFaction(user_id) ~= nil then
        tURK.sendWebhook(getPlayerFaction(user_id)..'-afk', 'URK AFK Logs', "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Info: **"..text.."**")
    end
end)

RegisterServerEvent('kick:AFK')
AddEventHandler('kick:AFK', function()
    local source = source
    local user_id = URK.getUserId(source)
    if not URK.hasPermission(user_id, 'group.add') then
        DropPlayer(source, 'You have been kicked for being AFK for too long.')
    end
end)