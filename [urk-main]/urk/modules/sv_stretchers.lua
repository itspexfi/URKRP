RegisterServerEvent("URK:stretcherAttachPlayer")
AddEventHandler('URK:stretcherAttachPlayer', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:stretcherAttachPlayer', source, playersrc)
    end
end)

RegisterServerEvent("URK:toggleAmbulanceDoors")
AddEventHandler('URK:toggleAmbulanceDoors', function(stretcherNetid)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:toggleAmbulanceDoorStatus', -1, stretcherNetid)
    end
end)

RegisterServerEvent("URK:updateHasStretcherInsideDecor")
AddEventHandler('URK:updateHasStretcherInsideDecor', function(stretcherNetid, status)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:setHasStretcherInsideDecor', -1, stretcherNetid, status)
    end
end)

RegisterServerEvent("URK:updateStretcherLocation")
AddEventHandler('URK:updateStretcherLocation', function(a,b)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:URK:setStretcherInside', -1, a,b)
    end
end)

RegisterServerEvent("URK:removeStretcher")
AddEventHandler('URK:removeStretcher', function(stretcher)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:deletePropClient', -1, stretcher)
    end
end)

RegisterServerEvent("URK:forcePlayerOnToStretcher")
AddEventHandler('URK:forcePlayerOnToStretcher', function(id, stretcher)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'nhs.onduty.permission') then
        TriggerClientEvent('URK:forcePlayerOnToStretcher', id, stretcher)
    end
end)