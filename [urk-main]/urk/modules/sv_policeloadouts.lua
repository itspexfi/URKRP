loadouts = {
    ['Basic'] = {
        permission = "police.onduty.permission",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK",
        },
    },
    ['SCO-19'] = {
        permission = "police.loadshop2",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK",
            "WEAPON_G36K",
        },
    },
    ['CTSFO'] = {
        permission = "police.maxarmour",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_PDGLOCK",
            "WEAPON_SPAR17",
            "WEAPON_REMINGTON700",
            "WEAPON_FLASHBANG",
        },
    },
    ['MP5 Tazer'] = {
        permission = "police.announce",
        weapons = {
            "WEAPON_NONMP5",
        },
    },
}


RegisterNetEvent('URK:getPoliceLoadouts')
AddEventHandler('URK:getPoliceLoadouts', function()
    local source = source
    local user_id = URK.getUserId(source)
    local loadoutsTable = {}
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        for k,v in pairs(loadouts) do
            v.hasPermission = URK.hasPermission(user_id, v.permission) 
            loadoutsTable[k] = v
        end
        TriggerClientEvent('URK:gotLoadouts', source, loadoutsTable)
    end
end)

RegisterNetEvent('URK:selectLoadout')
AddEventHandler('URK:selectLoadout', function(loadout)
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(loadouts) do
        if k == loadout then
            if URK.hasPermission(user_id, 'police.onduty.permission') and URK.hasPermission(user_id, v.permission) then
                for a,b in pairs(v.weapons) do
                    URKclient.giveWeapons(source, {{[b] = {ammo = 250}}, false})
                end
                URKclient.notify(source, {"~g~Received "..loadout.." loadout."})
            else
                URKclient.notify(source, {"You do not have permission to select this loadout"})
            end
        end
    end
end)