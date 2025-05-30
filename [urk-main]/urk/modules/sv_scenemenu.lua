local spikes = 0
local speedzones = 0

RegisterNetEvent("URK:placeSpike")
AddEventHandler("URK:placeSpike", function(heading, coords)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        TriggerClientEvent('URK:addSpike', -1, coords, heading)
    end
end)

RegisterNetEvent("URK:removeSpike")
AddEventHandler("URK:removeSpike", function(entity)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        TriggerClientEvent('URK:deleteSpike', -1, entity)
        TriggerClientEvent("URK:deletePropClient", -1, entity)
    end
end)

RegisterNetEvent("URK:requestSceneObjectDelete")
AddEventHandler("URK:requestSceneObjectDelete", function(prop)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
        TriggerClientEvent("URK:deletePropClient", -1, prop)
    end
end)

RegisterNetEvent("URK:createSpeedZone")
AddEventHandler("URK:createSpeedZone", function(coords, radius, speed)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
        speedzones = speedzones + 1
        TriggerClientEvent('URK:createSpeedZone', -1, speedzones, coords, radius, speed)
    end
end)

RegisterNetEvent("URK:deleteSpeedZone")
AddEventHandler("URK:deleteSpeedZone", function(speedzone)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
        TriggerClientEvent('URK:deleteSpeedZone', -1, speedzones, coords, radius, speed)
    end
end)

