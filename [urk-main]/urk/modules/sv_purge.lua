local purgeLB = {[1] = {"urk", 10}}

RegisterServerEvent('URK:getTopFraggers')
AddEventHandler('URK:getTopFraggers', function()
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:gotTopFraggers', source, purgeLB)
end)

RegisterCommand('addkill', function()
    TriggerClientEvent('URK:incrementPurgeKills', -1)
end)

RegisterCommand('purgespawn', function()
    TriggerClientEvent('URK:purgeSpawnClient', -1)
end)