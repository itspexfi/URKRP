RegisterNetEvent('URK:sendSharedEmoteRequest')
AddEventHandler('URK:sendSharedEmoteRequest', function(playersrc, emote)
    local source = source
    TriggerClientEvent('URK:sendSharedEmoteRequest', playersrc, source, emote)
end)

RegisterNetEvent('URK:receiveSharedEmoteRequest')
AddEventHandler('URK:receiveSharedEmoteRequest', function(i, a)
    local source = source
    TriggerClientEvent('URK:receiveSharedEmoteRequestSource', i)
    TriggerClientEvent('URK:receiveSharedEmoteRequest', source, a)
end)

local shavedPlayers = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for k,v in pairs(shavedPlayers) do
            if shavedPlayers[k] then
                if shavedPlayers[k].cooldown > 0 then
                    shavedPlayers[k].cooldown = shavedPlayers[k].cooldown - 1
                else
                    shavedPlayers[k] = nil
                end
            end
        end
    end
end)

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    SetTimeout(1000, function() 
        local source = source
        local user_id = URK.getUserId(source)
        if first_spawn and shavedPlayers[user_id] then
            TriggerClientEvent('URK:setAsShaved', source, (shavedPlayers[user_id].cooldown*60*1000))
        end
    end)
end)

function URK.ShaveHead(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.getInventoryItemAmount(user_id, 'Shaver') >= 1 then
        URKclient.getNearestPlayer(source,{4},function(nplayer)
            if nplayer then
                URKclient.globalSurrenderring(nplayer,{},function(surrendering)
                    if surrendering then
                        URK.tryGetInventoryItem(user_id, 'Shaver', 1)
                        TriggerClientEvent('URK:startShavingPlayer', source, nplayer)
                        TriggerClientEvent('URK:startBeingShaved', nplayer, source)
                        TriggerClientEvent('URK:playDelayedShave', -1, source)
                        shavedPlayers[URK.getUserId(nplayer)] = {
                            cooldown = 30,
                        }
                    else
                        URKclient.notify(source,{'~r~This player is not on their knees.'})
                    end
                end)
            else
                URKclient.notify(source, {"~r~No one nearby."})
            end
        end)
    end
end
