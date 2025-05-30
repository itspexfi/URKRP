RegisterNetEvent("URK:getArmour")
AddEventHandler("URK:getArmour",function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "police.armoury") then
        if URK.hasPermission(user_id, "police.maxarmour") then
            URKclient.setArmour(source, {100, true})
        elseif URK.hasGroup(user_id, "Inspector Clocked") then
            URKclient.setArmour(source, {75, true})
        elseif URK.hasGroup(user_id, "Senior Constable Clocked") or URK.hasGroup(user_id, "Sergeant Clocked") then
            URKclient.setArmour(source, {50, true})
        elseif URK.hasGroup(user_id, "PCSO Clocked") or URK.hasGroup(user_id, "PC Clocked") then
            URKclient.setArmour(source, {25, true})
        end
        TriggerClientEvent("urk:PlaySound", source, 1)
        URKclient.notify(source, {"~g~You have received your armour."})
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to use pd armour trigger')
    end
end)