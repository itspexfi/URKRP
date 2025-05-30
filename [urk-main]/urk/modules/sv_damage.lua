RegisterNetEvent("URK:syncEntityDamage")
AddEventHandler("URK:syncEntityDamage",function(u, v, t, s, m, n)
    local source=source
    local user_id=URK.getUserId(source)
    TriggerClientEvent('URK:onEntityHealthChange', t, GetPlayerPed(source), u, v, s)
end)