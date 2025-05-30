local cfg = module("cfg/cfg_stores")


RegisterNetEvent("URK:BuyStoreItem")
AddEventHandler("URK:BuyStoreItem", function(item, amount)
    local user_id = URK.getUserId(source)
    local ped = GetPlayerPed(source)
    for k,v in pairs(cfg.shopItems) do
        if item == v.itemID then
            if URK.getInventoryWeight(user_id) <= 25 then
                if URK.tryPayment(user_id,v.price*amount) then
                    URK.giveInventoryItem(user_id, item, amount, false)
                    URKclient.notify(source, {"~g~Paid ".. '£' ..getMoneyStringFormatted(v.price*amount)..'.'})
                    TriggerClientEvent("urk:PlaySound", source, 1)
                else
                    URKclient.notify(source, {"~r~Not enough money."})
                    TriggerClientEvent("urk:PlaySound", source, 2)
                end
            else
                URKclient.notify(source,{'~r~Not enough inventory space.'})
                TriggerClientEvent("urk:PlaySound", source, 2)
            end
        end
    end
end)