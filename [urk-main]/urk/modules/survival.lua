local cfg = module("cfg/survival")
local lang = URK.lang


-- handlers

-- init values
AddEventHandler("URK:playerJoin", function(user_id, source, name, last_login)
    local data = URK.getUserDataTable(user_id)
end)


---- revive
local revive_seq = {{"amb@medic@standing@kneel@enter", "enter", 1}, {"amb@medic@standing@kneel@idle_a", "idle_a", 1},
                    {"amb@medic@standing@kneel@exit", "exit", 1}}

local choice_revive = {function(player, choice)
    local user_id = URK.getUserId(player)
    if user_id ~= nil then
        URKclient.getNearestPlayer(player, {10}, function(nplayer)
            local nuser_id = URK.getUserId(nplayer)
            if nuser_id ~= nil then
                URKclient.isInComa(nplayer, {}, function(in_coma)
                    if in_coma then
                        if URK.tryGetInventoryItem(user_id, "medkit", 1, true) then
                            URKclient.playAnim(player, {false, revive_seq, false}) -- anim
                            SetTimeout(15000, function()
                                URKclient.varyHealth(nplayer, {50}) -- heal 50
                            end)
                        end
                    else
                        URKclient.notify(player, {lang.emergency.menu.revive.not_in_coma()})
                    end
                end)
            else
                URKclient.notify(player, {lang.common.no_player_near()})
            end
        end)
    end
end, lang.emergency.menu.revive.description()}

RegisterNetEvent('URK:SearchForPlayer')
AddEventHandler('URK:SearchForPlayer', function()
    TriggerClientEvent('URK:ReceiveSearch', -1, source)
end)


