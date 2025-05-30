netObjects = {}

RegisterServerEvent("URK:spawnVehicleCallback")
AddEventHandler('URK:spawnVehicleCallback', function(a, b)
    netObjects[b] = {source = URK.getUserSource(a), id = a, name = GetPlayerName(URK.getUserSource(a))}
end)

RegisterServerEvent("URK:delGunDelete")
AddEventHandler("URK:delGunDelete", function(object)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("URK:deletePropClient", -1, object)
        if netObjects[object] then
            TriggerClientEvent("URK:returnObjectDeleted", source, 'This object was created by ~b~'..netObjects[object].name..'~w~. Temp ID: ~b~'..netObjects[object].source..'~w~.\nPerm ID: ~b~'..netObjects[object].id..'~w~.')
        end
    end
end)