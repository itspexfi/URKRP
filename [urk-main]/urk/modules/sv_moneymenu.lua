RegisterServerEvent("URK:getUserinformation")
AddEventHandler("URK:getUserinformation",function(id)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.moneymenu') then
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('URK:receivedUserInformation', source, URK.getUserSource(id), GetPlayerName(URK.getUserSource(id)), math.floor(URK.getBankMoney(id)), math.floor(URK.getMoney(id)), chips)
            end
        end)
    end
end)

RegisterServerEvent("URK:ManagePlayerBank")
AddEventHandler("URK:ManagePlayerBank",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = URK.getUserId(source)
    local userstemp = URK.getUserSource(id)
    if URK.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            URK.giveBankMoney(id, amount)
            URKclient.notify(source, {'~g~Added £'..getMoneyStringFormatted(amount)..' to players Bank Balance.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            URK.tryBankPayment(id, amount)
            URKclient.notify(source, {'~r~Removed £'..getMoneyStringFormatted(amount)..' from players Bank Balance.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('URK:receivedUserInformation', source, URK.getUserSource(id), GetPlayerName(URK.getUserSource(id)), math.floor(URK.getBankMoney(id)), math.floor(URK.getMoney(id)), chips)
            end
        end)
    end
end)

RegisterServerEvent("URK:ManagePlayerCash")
AddEventHandler("URK:ManagePlayerCash",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = URK.getUserId(source)
    local userstemp = URK.getUserSource(id)
    if URK.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            URK.giveMoney(id, amount)
            URKclient.notify(source, {'~g~Added £'..getMoneyStringFormatted(amount)..' to players Cash Balance.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Cash**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            URK.tryPayment(id, amount)
            URKclient.notify(source, {'~r~Removed £'..getMoneyStringFormatted(amount)..' from players Cash Balance.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Cash**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('URK:receivedUserInformation', source, URK.getUserSource(id), GetPlayerName(URK.getUserSource(id)), math.floor(URK.getBankMoney(id)), math.floor(URK.getMoney(id)), chips)
            end
        end)
    end
end)

RegisterServerEvent("URK:ManagePlayerChips")
AddEventHandler("URK:ManagePlayerChips",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = URK.getUserId(source)
    local userstemp = URK.getUserSource(id)
    if URK.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            MySQL.execute("casinochips/add_chips", {user_id = id, amount = amount})
            URKclient.notify(source, {'~g~Added '..getMoneyStringFormatted(amount)..' to players Casino Chips.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('URK:receivedUserInformation', source, URK.getUserSource(id), GetPlayerName(URK.getUserSource(id)), math.floor(URK.getBankMoney(id)), math.floor(URK.getMoney(id)), chips)
                end
            end)
        elseif cashtype == 'Decrease' then
            MySQL.execute("casinochips/remove_chips", {user_id = id, amount = amount})
            URKclient.notify(source, {'~r~Removed '..getMoneyStringFormatted(amount)..' from players Casino Chips.'})
            tURK.sendWebhook('manage-balance',"URK Money Menu Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(userstemp).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('URK:receivedUserInformation', source, URK.getUserSource(id), GetPlayerName(URK.getUserSource(id)), math.floor(URK.getBankMoney(id)), math.floor(URK.getMoney(id)), chips)
                end
            end)
        end
    end
end)