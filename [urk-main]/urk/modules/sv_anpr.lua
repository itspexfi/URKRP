local flaggedVehicles = {}

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if URK.hasPermission(user_id, 'police.onduty.permission') then
            TriggerClientEvent('URK:setFlagVehicles', source, flaggedVehicles)
        end
    end
end)

RegisterServerEvent("URK:flagVehicleAnpr")
AddEventHandler("URK:flagVehicleAnpr", function(plate, reason)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        flaggedVehicles[plate] = reason
        TriggerClientEvent('URK:setFlagVehicles', -1, flaggedVehicles)
    end
end)