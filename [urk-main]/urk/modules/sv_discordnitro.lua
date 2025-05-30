RegisterCommand('craftbmx', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("URK:spawnNitroBMX", source)
    else
        if tURK.checkForRole(user_id, '1110165650741141514') then
            TriggerClientEvent("URK:spawnNitroBMX", source)
        end
    end
end)

RegisterCommand('craftmoped', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.isPlatClub(source, {}, function(isPlatClub)
        if isPlatClub then
            TriggerClientEvent("URK:spawnMoped", source)
        end
    end)
end)