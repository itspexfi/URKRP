RegisterNetEvent('URK:purchaseHighRollersMembership')
AddEventHandler('URK:purchaseHighRollersMembership', function()
    local source = source
    local user_id = URK.getUserId(source)
    if not URK.hasGroup(user_id, 'Highroller') then
        if URK.tryFullPayment(user_id,10000000) then
            URK.addUserGroup(user_id, 'Highroller')
            URKclient.notify(source, {'~g~You have purchased the ~b~High Rollers ~g~membership.'})
            tURK.sendWebhook('purchase-highrollers',"URK Purchased Highrollers Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
        else
            URKclient.notify(source, {'~r~You do not have enough money to purchase this membership.'})
        end
    else
        URKclient.notify(source, {"~r~You already have High Roller's License."})
    end
end)

RegisterNetEvent('URK:removeHighRollersMembership')
AddEventHandler('URK:removeHighRollersMembership', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Highroller') then
        URK.removeUserGroup(user_id, 'Highroller')
    else
        URKclient.notify(source, {"~r~You do not have High Roller's License."})
    end
end)