RegisterNetEvent('URK:checkTutorial')
AddEventHandler('URK:checkTutorial', function()
    local source = source
    local user_id = URK.getUserId(source)
    local discord_id = "Il fetch discord id later"
    if not URK.hasGroup(user_id, 'TutorialDone') then
        TriggerClientEvent('URK:playTutorial', source)
        tURK.setBucket(source, user_id)
        TriggerClientEvent('URK:setBucket', source, user_id)
        tURK.sendWebhook('tutorial', 'URK Tutorial Logs', "> Player Name: **"..GetPlayerName(source).."**\n> Player Discord: **"..discord_id.."**\n> Player PermID: **"..user_id.."**\n> Info: **Started the Tutorial**")
    end
end)

RegisterNetEvent('URK:setCompletedTutorial')
AddEventHandler('URK:setCompletedTutorial', function()
    local source = source
    local user_id = URK.getUserId(source)
    if not URK.hasGroup(user_id, 'TutorialDone') then
        URK.addUserGroup(user_id, 'TutorialDone')
        tURK.setBucket(source, 0)
        TriggerClientEvent('URK:setBucket', source, 0)
    end
end)