local tacoDrivers = {}

RegisterNetEvent('URK:addTacoSeller')
AddEventHandler('URK:addTacoSeller', function(coords, price)
    local source = source
    local user_id = URK.getUserId(source)
    tacoDrivers[user_id] = {position = coords, amount = price}
    TriggerClientEvent('URK:sendClientTacoData', -1, tacoDrivers)
end)

RegisterNetEvent('URK:RemoveMeFromTacoPositions')
AddEventHandler('URK:RemoveMeFromTacoPositions', function()
    local source = source
    local user_id = URK.getUserId(source)
    tacoDrivers[user_id] = nil
    TriggerClientEvent('URK:removeTacoSeller', -1, user_id)
end)

RegisterNetEvent('URK:payTacoSeller')
AddEventHandler('URK:payTacoSeller', function(id)
    local source = source
    local user_id = URK.getUserId(source)
    if tacoDrivers[id] then
        if URK.getInventoryWeight(user_id)+1 <= URK.getInventoryMaxWeight(user_id) then
            if URK.tryFullPayment(user_id,15000) then
                URK.giveInventoryItem(user_id, 'Taco', 1)
                URK.giveBankMoney(id, 15000)
                TriggerClientEvent("urk:PlaySound", source, "money")
            else
                URKclient.notify(source, {'~r~You do not have enough money.'})
            end
        else
            URKclient.notify(source, {'~r~Not enough inventory space.'})
        end
    end
end)