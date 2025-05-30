MySQL.createCommand("casinochips/add_id", "INSERT IGNORE INTO urk_casino_chips SET user_id = @user_id")
MySQL.createCommand("casinochips/get_chips","SELECT * FROM urk_casino_chips WHERE user_id = @user_id")
MySQL.createCommand("casinochips/add_chips", "UPDATE urk_casino_chips SET chips = (chips + @amount) WHERE user_id = @user_id")
MySQL.createCommand("casinochips/remove_chips", "UPDATE urk_casino_chips SET chips = CASE WHEN ((chips - @amount)>0) THEN (chips - @amount) ELSE 0 END WHERE user_id = @user_id")


AddEventHandler("playerJoining", function()
    local user_id = URK.getUserId(source)
    MySQL.execute("casinochips/add_id", {user_id = user_id})
end)

RegisterNetEvent("URK:enterDiamondCasino")
AddEventHandler("URK:enterDiamondCasino", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.setBucket(source, 777)
    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            TriggerClientEvent('URK:setDisplayChips', source, rows[1].chips)
            return
        end
    end)
end)

RegisterNetEvent("URK:exitDiamondCasino")
AddEventHandler("URK:exitDiamondCasino", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.setBucket(source, 0)
end)

RegisterNetEvent("URK:getChips")
AddEventHandler("URK:getChips", function()
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            TriggerClientEvent('URK:setDisplayChips', source, rows[1].chips)
            return
        end
    end)
end)

RegisterNetEvent("URK:buyChips")
AddEventHandler("URK:buyChips", function(amount)
    local source = source
    local user_id = URK.getUserId(source)
    if not amount then amount = URK.getMoney(user_id) end
    if URK.tryPayment(user_id, amount) then
        MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = amount})
        TriggerClientEvent('URK:chipsUpdated', source)
        tURK.sendWebhook('purchase-chips',"URK Chip Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(amount).."**")
        return
    else
        URKclient.notify(source,{"~r~You don't have enough money."})
        return
    end
end)

local sellingChips = {}
RegisterNetEvent("URK:sellChips")
AddEventHandler("URK:sellChips", function(amount)
    local source = source
    local user_id = URK.getUserId(source)
    local chips = nil
    if not sellingChips[source] then
        sellingChips[source] = true
        MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                if not amount then amount = chips end
                if amount > 0 and chips > 0 and chips >= amount then
                    MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = amount})
                    TriggerClientEvent('URK:chipsUpdated', source)
                    tURK.sendWebhook('sell-chips',"URK Chip Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(amount).."**")
                    URK.giveMoney(user_id, amount)
                else
                    URKclient.notify(source,{"~r~You don't have enough chips."})
                end
                sellingChips[source] = nil
            end
        end)
    end
end)