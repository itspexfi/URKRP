local bodyBags = {}

RegisterServerEvent("URK:requestBodyBag")
AddEventHandler('URK:requestBodyBag', function(playerToBodyBag)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:placeBodyBag', playerToBodyBag)
    end
end)

RegisterServerEvent("URK:removeBodybag")
AddEventHandler('URK:removeBodybag', function(bodybagObject)
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:removeIfOwned', -1, NetworkGetEntityFromNetworkId(bodybagObject))
end)

RegisterServerEvent("URK:playNhsSound")
AddEventHandler('URK:playNhsSound', function(sound)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:clientPlayNhsSound', -1, GetEntityCoords(GetPlayerPed(source)), sound)
    else
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Trigger Play NHS Sound')
    end
end)


-- a = coma
-- c = userid
-- b = permid
-- 4th ready to revive
-- name

local lifePaksConnected = {}

RegisterServerEvent("URK:attachLifepakServer")
AddEventHandler('URK:attachLifepakServer', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        URKclient.getNearestPlayer(source, {3}, function(nplayer)
            local nuser_id = URK.getUserId(nplayer)
            if nuser_id ~= nil then
                URKclient.isInComa(nplayer, {}, function(in_coma)
                    TriggerClientEvent('URK:attachLifepak', source, in_coma, nuser_id, nplayer, GetPlayerName(nplayer))
                    lifePaksConnected[user_id] = {permid = nuser_id} 
                end)
            else
                URKclient.notify(source, {"~r~There is no player nearby"})
            end
        end)
    else
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Trigger Attack Lifepak')
    end
end)


RegisterServerEvent("URK:finishRevive")
AddEventHandler('URK:finishRevive', function(permid)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then 
        for k,v in pairs(lifePaksConnected) do
            if k == user_id and v.permid == permid then
                TriggerClientEvent('URK:returnRevive', source)
                URK.giveBankMoney(user_id, 5000)
                URKclient.notify(source, {"~g~You have been paid £5,000 for reviving this person."})
                lifePaksConnected[k] = nil
                Wait(15000)
                URKclient.RevivePlayer(URK.getUserSource(permid), {})
            end
        end
    else
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Trigger Finish Revive')
    end
end)


RegisterServerEvent("URK:nhsRevive") -- nhs radial revive
AddEventHandler('URK:nhsRevive', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        URKclient.isInComa(playersrc, {}, function(in_coma)
            if in_coma then
                TriggerClientEvent('URK:beginRevive', source, in_coma, URK.getUserId(playersrc), playersrc, GetPlayerName(playersrc))
                lifePaksConnected[user_id] = {permid = URK.getUserId(playersrc)} 
            end
        end)
    else
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Trigger NHS Revive')
    end
end)

local playersInCPR = {}
RegisterServerEvent("URK:attemptCPR")
AddEventHandler('URK:attemptCPR', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.getNearestPlayers(source,{15},function(nplayers)
        if nplayers[playersrc] then
            if GetEntityHealth(GetPlayerPed(playersrc)) > 102 then
                URKclient.notify(source, {"~r~This person already healthy."})
            else
                playersInCPR[user_id] = true
                TriggerClientEvent('URK:attemptCPR', source)
                Wait(15000)
                if playersInCPR[user_id] then
                    local cprChance = math.random(1,5)
                    if cprChance == 1 then
                        URKclient.RevivePlayer(playersrc, {})
                        URKclient.notify(playersrc, {"~b~Your life has been saved."})
                        URKclient.notify(source, {"~b~You have saved this Person's Life."})
                    else
                        URKclient.notify(source, {'~r~Failed to CPR.'})
                    end
                    playersInCPR[user_id] = nil
                    TriggerClientEvent('URK:cancelCPRAttempt', source)
                end
            end
        else
            URKclient.notify(source, {"~r~Player not found."})
        end
    end)
end)

RegisterServerEvent("URK:cancelCPRAttempt")
AddEventHandler('URK:cancelCPRAttempt', function()
    local source = source
    local user_id = URK.getUserId(source)
    if playersInCPR[user_id] then
        playersInCPR[user_id] = nil
        TriggerClientEvent('URK:cancelCPRAttempt', source)
    end
end)

RegisterServerEvent("URK:syncWheelchairPosition")
AddEventHandler('URK:syncWheelchairPosition', function(netid, coords, heading)
    local source = source
    local user_id = URK.getUserId(source)
    entity = NetworkGetEntityFromNetworkId(netid)
    SetEntityCoords(entity, coords.x, coords.y, coords.z)
    SetEntityHeading(entity, heading)
end)

RegisterServerEvent("URK:wheelchairAttachPlayer")
AddEventHandler('URK:wheelchairAttachPlayer', function(entity)
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:wheelchairAttachPlayer', -1, entity, source)
end)