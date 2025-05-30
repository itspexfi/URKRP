local rpZones = {}
local numRP = 0
RegisterServerEvent("URK:createRPZone")
AddEventHandler("URK:createRPZone", function(a)
	local source = source
	local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'group.remove') then
        numRP = numRP + 1
        a['uuid'] = numRP
        rpZones[numRP] = a
        TriggerClientEvent('URK:createRPZone', -1, a)
    end
end)

RegisterServerEvent("URK:removeRPZone")
AddEventHandler("URK:removeRPZone", function(b)
	local source = source
	local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'group.remove') then
        if next(rpZones) then
            for k,v in pairs(rpZones) do
                if v.uuid == b then
                    rpZones[k] = nil
                    TriggerClientEvent('URK:removeRPZone', -1, b)
                end
            end
        end
    end
end)

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        for k,v in pairs(rpZones) do
            TriggerClientEvent('URK:createRPZone', source, rpZones)
        end
    end
end)
