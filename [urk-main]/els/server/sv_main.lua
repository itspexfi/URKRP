RegisterNetEvent("URKELS:changeStage", function(stage)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('URKELS:changeStage', -1, vehicleNetId, stage)
end)

RegisterNetEvent("URKELS:toggleSiren", function(tone)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('URKELS:toggleSiren', -1, vehicleNetId, tone)
end)

RegisterNetEvent("URKELS:toggleBullhorn", function(enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('URKELS:toggleBullhorn', -1, vehicleNetId, enabled)
end)

RegisterNetEvent("URKELS:patternChange", function(patternIndex, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('URKELS:patternChange', -1, vehicleNetId, patternIndex, enabled)
end)

RegisterNetEvent("URKELS:vehicleRemoved", function(stage)
	TriggerClientEvent('URKELS:vehicleRemoved', -1, stage)
end)

RegisterNetEvent("URKELS:indicatorChange", function(indicator, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('URKELS:indicatorChange', -1, vehicleNetId, indicator, enabled)
end)