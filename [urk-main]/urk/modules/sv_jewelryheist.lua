local jewelrycfg = module("cfg/cfg_jewelryHeist") 
local facilityEmpty = true 
local userInFacility = nil 

AddEventHandler('URK:playerSpawn', function(user_id, source, first_spawn) 
    if first_spawn then
        TriggerClientEvent('URK:jewelrySyncSetupReady', source, facilityEmpty) 
    end 
end) 

RegisterNetEvent('URK:jewelrySetupHeistStart') 
AddEventHandler('URK:jewelrySetupHeistStart', function() 
    local source = source 
    local user_id = URK.getUserId(source) 
    if userInfacility == nil then 
        userInFacility = user_id 
        facilityEmpty = false 
        TriggerClientEvent('URK:jewelrySyncSetupReady', -1, facilityEmpty) 
        for k,v in pairs(jewelrycfg.aiSpawnLocs) do 
            local pos = v.coords 
            local ped = CreatePed(4, GetHashkey("s_m_y_blackops_03"), pos.x, pos.y, pos.z, v.heading, false, true) 
            GiveWeaponToPed(ped, v.weaponHash, 999, false, true) 
            TriggerClientEvent('URK:jewelryMakePedsAttack', source, NetworkGetNetworkIdFromEntity(ped)) 
        end 
    end 
end) 

RegisterNetEvent('URK:jewelrySetupHeistleave')
AddEventHandler('URK:jewelrySetupHeistLeave', function() 
    local source = source 
    local user_id URK.getUserId(source) 
    if userInFacility == user_id then 
        userInFacility = nil 
        facilityEmpty = true 
        TriggerClientEvent('URK:jewelrySyncSetupReady', -1, facilityEmpty)
        TriggerClientEvent('URK:jewelryRemoveDeviceArea', source) 
    end
end) 