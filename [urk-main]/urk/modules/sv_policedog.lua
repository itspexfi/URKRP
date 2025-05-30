RegisterCommand('k9', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('URK:policeDogMenu', source)
    end
end)

RegisterCommand('k9attack', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('URK:policeDogAttack', source)
    end
end)

RegisterNetEvent("URK:serverDogAttack")
AddEventHandler("URK:serverDogAttack", function(player)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('URK:sendClientRagdoll', player)
    end
end)

RegisterNetEvent("URK:policeDogSniffPlayer")
AddEventHandler("URK:policeDogSniffPlayer", function(playerSrc)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'K9 Trained') then
       -- check for drugs
        local player_id = URK.getUserId(playerSrc)
        local cdata = URK.getUserDataTable(player_id)
        for a,b in pairs(cdata.inventory) do
            for c,d in pairs(seizeDrugs) do
                if a == c then
                    TriggerClientEvent('URK:policeDogIndicate', source, playerSrc)
                end
            end
        end
    end
end)

RegisterNetEvent("URK:performDogLog")
AddEventHandler("URK:performDogLog", function(text)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'K9 Trained') then
        tURK.sendWebhook('police-k9', 'URK Police Dog Logs',"> Officer Name: **"..GetPlayerName(source).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Info: **"..text.."**")
    end
end)