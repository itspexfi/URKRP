MySQL.createCommand("subscription/set_plushours","UPDATE urk_subscriptions SET plushours = @plushours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_plathours","UPDATE urk_subscriptions SET plathours = @plathours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_lastused","UPDATE urk_subscriptions SET last_used = @last_used WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_subscription","SELECT * FROM urk_subscriptions WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_all_subscriptions","SELECT * FROM urk_subscriptions")
MySQL.createCommand("subscription/add_id", "INSERT IGNORE INTO urk_subscriptions SET user_id = @user_id, plushours = 0, plathours = 0, last_used = ''")

AddEventHandler("playerJoining", function()
    local user_id = URK.getUserId(source)
    MySQL.execute("subscription/add_id", {user_id = user_id})
end)

function tURK.getSubscriptions(user_id,cb)
    MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
           cb(true, rows[1].plushours, rows[1].plathours, rows[1].last_used)
        else
            cb(false)
        end
    end)
end

RegisterNetEvent("URK:setPlayerSubscription")
AddEventHandler("URK:setPlayerSubscription", function(playerid, subtype)
    local user_id = URK.getUserId(source)
    local player = URK.getUserSource(user_id)
    if URK.hasGroup(user_id, 'Founder') then
        URK.prompt(player,"Number of days ","",function(player, hours)
            if tonumber(hours) and tonumber(hours) >= 0 then
                hours = hours * 24
                if subtype == "Plus" then
                    MySQL.execute("subscription/set_plushours", {user_id = playerid, plushours = hours})
                elseif subtype == "Platinum" then
                    MySQL.execute("subscription/set_plathours", {user_id = playerid, plathours = hours})
                end
                TriggerClientEvent('URK:userSubscriptionUpdated', player)
            else
                URKclient.notify(player,{"~r~Number of days must be a number."})
            end
        end)
    else
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(player), player, 'Trigger Set Player Subscription')
    end
end)

RegisterNetEvent("URK:getPlayerSubscription")
AddEventHandler("URK:getPlayerSubscription", function(playerid)
    local user_id = URK.getUserId(source)
    local player = URK.getUserSource(user_id)
    if playerid ~= nil then
        tURK.getSubscriptions(playerid, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('URK:getUsersSubscription', player, playerid, plushours, plathours)
            else
                URKclient.notify(player, {"~r~Player not found."})
            end
        end)
    else
        tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('URK:setVIPClubData', player, plushours, plathours)
            end
        end)
    end
end)

RegisterNetEvent("URK:beginSellSubscriptionToPlayer")
AddEventHandler("URK:beginSellSubscriptionToPlayer", function(subtype)
    local user_id = URK.getUserId(source)
    local player = URK.getUserSource(user_id)
    URKclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
        usrList = ""
        for k, v in pairs(nplayers) do
            usrList = usrList .. "[" .. URK.getUserId(k) .. "]" .. GetPlayerName(k) .. " | " --add ids to usrList
        end
        if usrList ~= "" then
            URK.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                target_id = target_id
                if target_id ~= nil and target_id ~= "" then --validation
                    local target = URK.getUserSource(tonumber(target_id)) --get source of the new owner id
                    if target ~= nil then
                        URK.prompt(player,"Number of days ","",function(player, hours) -- ask for number of hours
                            if tonumber(hours) and tonumber(hours) > 0 then
                                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                                    sellerplushours = rows[1].plushours
                                    sellerplathours = rows[1].plathours
                                    if (subtype == 'Plus' and sellerplushours >= tonumber(hours)*24) or (subtype == 'Platinum' and sellerplathours >= tonumber(hours)*24) then
                                        URK.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                            if tonumber(amount) and tonumber(amount) > 0 then
                                                URK.request(target,GetPlayerName(player).." wants to sell: " ..hours.. " days of "..subtype.." subscription for £"..getMoneyStringFormatted(amount), 30, function(target,ok) --request player if they want to buy sub
                                                    if ok then --bought
                                                        MySQL.query("subscription/get_subscription", {user_id = URK.getUserId(target)}, function(rows, affected)
                                                            if subtype == "Plus" then
                                                                if URK.tryFullPayment(URK.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plushours", {user_id = URK.getUserId(target), plushours = rows[1].plushours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = sellerplushours - tonumber(hours)*24})
                                                                    URKclient.notify(player,{'~g~You have sold '..hours..' days of '..subtype..' subscription to '..GetPlayerName(target)..' for £'..amount})
                                                                    URKclient.notify(target, {'~g~'..GetPlayerName(player)..' has sold '..hours..' days of '..subtype..' subscription to you for £'..amount})
                                                                    URK.giveBankMoney(user_id,tonumber(amount))
                                                                    URK.updateInvCap(URK.getUserId(target), 40)
                                                                else
                                                                    URKclient.notify(player,{"~r~".. GetPlayerName(target).." doesn't have enough money!"}) --notify original owner
                                                                    URKclient.notify(target,{"~r~You don't have enough money!"}) --notify new owner
                                                                end
                                                            elseif subtype == "Platinum" then
                                                                if URK.tryFullPayment(URK.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plathours", {user_id = URK.getUserId(target), plathours = rows[1].plathours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = sellerplathours - tonumber(hours)*24})
                                                                    URKclient.notify(player,{'~g~You have sold '..hours..' days of '..subtype..' subscription to '..GetPlayerName(target)..' for £'..amount})
                                                                    URKclient.notify(target, {'~g~'..GetPlayerName(player)..' has sold '..hours..' days of '..subtype..' subscription to you for £'..amount})
                                                                    URK.giveBankMoney(user_id,tonumber(amount))
                                                                    URK.updateInvCap(URK.getUserId(target), 50)
                                                                    TriggerClientEvent('URK:refreshGunStorePermissions', target)
                                                                else
                                                                    URKclient.notify(player,{"~r~".. GetPlayerName(target).." doesn't have enough money!"}) --notify original owner
                                                                    URKclient.notify(target,{"~r~You don't have enough money!"}) --notify new owner
                                                                end
                                                            end
                                                        end)
                                                    else
                                                        URKclient.notify(player,{"~r~"..GetPlayerName(target).." has refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount}) --notify owner that refused
                                                        URKclient.notify(target,{"~r~You have refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount}) --notify new owner that refused
                                                    end
                                                end)
                                            else
                                                URKclient.notify(player,{"~r~Price of subscription must be a number."})
                                            end
                                        end)
                                    else
                                        URKclient.notify(player,{"~r~You do not have "..hours.." days of "..subtype.."."})
                                    end
                                end)
                            else
                                URKclient.notify(player,{"~r~Number of days must be a number."})
                            end
                        end)
                    else
                        URKclient.notify(player,{"~r~That Perm ID seems to be invalid!"}) --couldnt find perm id
                    end
                else
                    URKclient.notify(player,{"~r~No Perm ID selected!"}) --no perm id selected
                end
            end)
        else
            URKclient.notify(player,{"~r~No players nearby!"}) --no players nearby
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        MySQL.query("subscription/get_all_subscriptions", {}, function(rows, affected)
            if #rows > 0 then
                for k,v in pairs(rows) do
                    local plushours = v.plushours
                    local plathours = v.plathours
                    local user_id = v.user_id
                    local user = URK.getUserSource(user_id)
                    if plushours >= 1/60 then
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = plushours-1/60})
                    else
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = 0})
                    end
                    if plathours >= 1/60 then
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = plathours-1/60})
                    else
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = 0})
                    end
                    if user ~= nil then
                        TriggerClientEvent('URK:setVIPClubData', user, plushours, plathours)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("URK:claimWeeklyKit") -- need to add a thing for restricting the kit to actually being weekly
AddEventHandler("URK:claimWeeklyKit", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.getSubscriptions(user_id, function(cb, plushours, plathours, last_used)
        if cb then
            if plathours >= 168 or plushours >= 168 then
                if last_used == '' or (os.time() >= tonumber(last_used+24*60*60*7)) then
                    if plathours >= 168 then
                        URK.giveInventoryItem(user_id, "Morphine", 5, true)
                        URK.giveInventoryItem(user_id, "Taco", 5, true)
                        URKclient.giveWeapons(source, {{['WEAPON_M1911'] = {ammo = 250}}, false})
                        URKclient.giveWeapons(source, {{['WEAPON_OLYMPIA'] = {ammo = 250}}, false})
                        URKclient.giveWeapons(source, {{['WEAPON_UMP45'] = {ammo = 250}}, false})
                        URKclient.giveWeapons(source, {{['WEAPON_AK200'] = {ammo = 250}}, false})
                        URKclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    elseif plushours >= 168 then
                        URK.giveInventoryItem(user_id, "Morphine", 5, true)
                        URK.giveInventoryItem(user_id, "Taco", 5, true)
                        URKclient.giveWeapons(source, {{['WEAPON_M1911'] = {ammo = 250}}, false})
                        URKclient.giveWeapons(source, {{['WEAPON_UMP45'] = {ammo = 250}}, false})
                        URKclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    else
                        URKclient.notify(source,{"~r~You need at least 1 week of subscription to redeem the kit."})
                    end
                else
                    URKclient.notify(source,{"~r~You can only claim your weekly kit once a week."})
                end
            else
                URKclient.notify(source,{"~r~You require at least 1 week of a subscription to claim a kit."})
            end
        end
    end)
end)

RegisterNetEvent("URK:fuelAllVehicles")
AddEventHandler("URK:fuelAllVehicles", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            if plushours > 0 or plathours > 0 then
                if URK.tryFullPayment(user_id,25000) then
                    exports["ghmattimysql"]:execute("UPDATE urk_user_vehicles SET fuel_level = 100 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    TriggerClientEvent("urk:PlaySound", source, "money")
                    URKclient.notify(source,{"~g~Vehicles Refueled."})
                end
            end
        end
    end)
end)

RegisterCommand('redeem', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if tURK.checkForRole(user_id, '1100047438619873380') then
        MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                local redeemed = rows[1].redeemed
                if not redeemed then
                    exports["ghmattimysql"]:execute("UPDATE urk_subscriptions SET redeemed = 1 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    URK.giveBankMoney(user_id, 150000)
                    URKclient.notify(source, {'~g~You have redeemed your perks of £150,000 and 1 Week of Platinum Subscription.'})
                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = rows[1].plathours + 168})
                else
                    URKclient.notify(source, {'~r~You have already redeemed your subscription.'})
                end
            end
        end)
    end
end)