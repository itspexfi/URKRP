RegisterServerEvent('URK:saveTattoos')
AddEventHandler('URK:saveTattoos', function(tattooData, price)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.tryFullPayment(user_id, price) then
        URK.setUData(user_id, "URK:Tattoo:Data", json.encode(tattooData))
    end
end)

RegisterServerEvent('URK:getPlayerTattoos')
AddEventHandler('URK:getPlayerTattoos', function()
    local source = source
    local user_id = URK.getUserId(source)
    URK.getUData(user_id, "URK:Tattoo:Data", function(data)
        if data ~= nil then
            TriggerClientEvent('URK:setTattoos', source, json.decode(data))
        end
    end)
end)
