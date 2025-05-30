local lang = URK.lang
local cfg = module("URKVeh", "garages")
local cfg_inventory = module("URKVeh", "inventory")
local vehicle_groups = cfg.garages
local limit = cfg.limit or 100000000
MySQL.createCommand("URK/add_vehicle","INSERT IGNORE INTO urk_user_vehicles(user_id,vehicle,vehicle_plate,locked) VALUES(@user_id,@vehicle,@registration,@locked)")
MySQL.createCommand("URK/remove_vehicle","DELETE FROM urk_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("URK/get_vehicles", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level, impounded FROM urk_user_vehicles WHERE user_id = @user_id")
MySQL.createCommand("URK/get_rented_vehicles_in", "SELECT vehicle, rentedtime, user_id FROM urk_user_vehicles WHERE user_id = @user_id AND rented = 1")
MySQL.createCommand("URK/get_rented_vehicles_out", "SELECT vehicle, rentedtime, user_id FROM urk_user_vehicles WHERE rentedid = @user_id AND rented = 1")
MySQL.createCommand("URK/get_vehicle","SELECT vehicle FROM urk_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("URK/get_vehicle_fuellevel","SELECT fuel_level FROM urk_user_vehicles WHERE vehicle = @vehicle")
MySQL.createCommand("URK/check_rented","SELECT * FROM urk_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND rented = 1")
MySQL.createCommand("URK/sell_vehicle_player","UPDATE urk_user_vehicles SET user_id = @user_id, vehicle_plate = @registration WHERE user_id = @oldUser AND vehicle = @vehicle")
MySQL.createCommand("URK/rentedupdate", "UPDATE urk_user_vehicles SET user_id = @id, rented = @rented, rentedid = @rentedid, rentedtime = @rentedunix WHERE user_id = @user_id AND vehicle = @veh")
MySQL.createCommand("URK/fetch_rented_vehs", "SELECT * FROM urk_user_vehicles WHERE rented = 1")
MySQL.createCommand("URK/get_vehicle_count","SELECT vehicle FROM urk_user_vehicles WHERE vehicle = @vehicle")

RegisterServerEvent("URK:spawnPersonalVehicle")
AddEventHandler('URK:spawnPersonalVehicle', function(vehicle)
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URK/get_vehicles", {user_id = user_id}, function(result)
        if result ~= nil then 
            for k,v in pairs(result) do
                if v.vehicle == vehicle then
                    if v.impounded then
                        URKclient.notify(source, {'~r~This vehicle is currently impounded.'})
                        return
                    else
                        TriggerClientEvent('URK:spawnPersonalVehicle', source, v.vehicle, user_id, false, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                        return
                    end
                end
            end
        end
    end)
end)

valetCooldown = {}
RegisterServerEvent("URK:valetSpawnVehicle")
AddEventHandler('URK:valetSpawnVehicle', function(spawncode)
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.isPlusClub(source,{},function(plusclub)
        URKclient.isPlatClub(source,{},function(platclub)
            if plusclub or platclub then
                if valetCooldown[source] and not (os.time() > valetCooldown[source]) then
                    return URKclient.notify(source,{"~r~Please wait before using this again."})
                else
                    valetCooldown[source] = nil
                end
                MySQL.query("URK/get_vehicles", {user_id = user_id}, function(result)
                    if result ~= nil then 
                        for k,v in pairs(result) do
                            if v.vehicle == spawncode then
                                TriggerClientEvent('URK:spawnPersonalVehicle', source, v.vehicle, user_id, true, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                                valetCooldown[source] = os.time() + 60
                                return
                            end
                        end
                    end
                end)
            else
                URKclient.notify(source, {"~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."})
                URKclient.notify(source, {"~y~Available @ store.urkstudios.uk"})
            end
        end)
    end)
end)

RegisterServerEvent("URK:getVehicleRarity")
AddEventHandler('URK:getVehicleRarity', function(spawncode)
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URK/get_vehicle_count", {vehicle = spawncode}, function(result)
        if result ~= nil then 
            TriggerClientEvent('URK:setVehicleRarity', source, spawncode, #result)
        end
    end)
end)

RegisterServerEvent("URK:displayVehicleBlip")
AddEventHandler('URK:displayVehicleBlip', function(spawncode)
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URKls/get_vehicle_modifications", {user_id = user_id, vehicle = spawncode}, function(rows, affected) 
        if rows ~= nil then 
            if #rows > 0 then
                URKclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
                    if vector3(x,y,z) ~= vector3(0,0,0) then
                        local mods = json.decode(rows[1].modifications) or {}
                        if mods['remoteblips'] == 1 then
                            local position = {}
                            position.x, position.y, position.z = x,y,z
                            if next(position) then
                                TriggerClientEvent('URK:displayVehicleBlip', source, position)
                                URKclient.notify(source, {"~g~Vehicle blip enabled."})
                                return
                            end
                        end
                        URKclient.notify(source, {"~r~This vehicle does not have a remote vehicle blip installed."})
                    else
                        URKclient.notify(source, {"~r~Can not locate vehicle with the plate "..rows[1].vehicle_plate.." in this city."})
                    end
                end)
            end
        end
    end)
end)

RegisterServerEvent("URK:viewRemoteDashcam")
AddEventHandler('URK:viewRemoteDashcam', function(spawncode)
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URKls/get_vehicle_modifications", {user_id = user_id, vehicle = spawncode}, function(rows, affected) 
        if rows ~= nil then 
            if #rows > 0 then
                URKclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
                    if vector3(x,y,z) ~= vector3(0,0,0) then
                        local mods = json.decode(rows[1].modifications) or {}
                        if mods['dashcam'] == 1 then
                            if next(table.pack(x,y,z)) then
                                for k,v in pairs(netObjects) do
                                    if math.floor(vector3(x,y,z)) == math.floor(GetEntityCoords(NetworkGetEntityFromNetworkId(k))) then
                                        TriggerClientEvent('URK:viewRemoteDashcam', source, table.pack(x,y,z), k)
                                        return
                                    end
                                end
                            end
                        end
                        URKclient.notify(source, {"~r~This vehicle does not have a remote dashcam installed."})
                    else
                        URKclient.notify(source, {"~r~Can not locate vehicle with the plate "..rows[1].vehicle_plate.." in this city."})
                    end
                end)
            end
        end
    end)
end)

RegisterServerEvent("URK:updateFuel")
AddEventHandler('URK:updateFuel', function(vehicle, fuel_level)
    local source = source
    local user_id = URK.getUserId(source)
    exports["ghmattimysql"]:execute("UPDATE urk_user_vehicles SET fuel_level = @fuel_level WHERE user_id = @user_id AND vehicle = @vehicle", {fuel_level = fuel_level, user_id = user_id, vehicle = vehicle}, function() end)
end)

RegisterServerEvent("URK:getCustomFolders")
AddEventHandler('URK:getCustomFolders', function()
    local source = source
    local user_id = URK.getUserId(source)
    exports["ghmattimysql"]:execute("SELECT * from `urk_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            TriggerClientEvent("URK:sendFolders", source, json.decode(Result[1].folder))
        end
    end)
end)


RegisterServerEvent("URK:updateFolders")
AddEventHandler('URK:updateFolders', function(FolderUpdated)
    local source = source
    local user_id = URK.getUserId(source)
    exports["ghmattimysql"]:execute("SELECT * from `urk_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            exports['ghmattimysql']:execute("UPDATE urk_custom_garages SET folder = @folder WHERE user_id = @user_id", {folder = json.encode(FolderUpdated), user_id = user_id}, function() end)
        else
            exports['ghmattimysql']:execute("INSERT INTO urk_custom_garages (`user_id`, `folder`) VALUES (@user_id, @folder);", {user_id = user_id, folder = json.encode(FolderUpdated)}, function() end)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        MySQL.query('URK/fetch_rented_vehs', {}, function(pvehicles)
            for i,v in pairs(pvehicles) do 
               if os.time() > tonumber(v.rentedtime) then
                  MySQL.execute('URK/rentedupdate', {id = v.rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = v.user_id, veh = v.vehicle})
                  if URK.getUserSource(v.rentedid) ~= nil then
                    URKclient.notify(URK.getUserSource(v.rentedid), {"~r~Your rented vehicle has been returned."})
                  end
               end
            end
        end)
    end
end)

RegisterNetEvent('URK:FetchCars')
AddEventHandler('URK:FetchCars', function(type)
    local source = source
    local user_id = URK.getUserId(source)
    local returned_table = {}
    local fuellevels = {}
    if user_id then
        MySQL.query("URK/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local perms = false
                    local config = vehicle_groups[i]._config
                    if config.type == vehicle_groups[type]._config.type then 
                        local perm = config.permissions or nil
                        if next(perm) then
                            for i, v in pairs(perm) do
                                if URK.hasPermission(user_id, v) then
                                    perms = true
                                end
                            end
                        else
                            perms = true
                        end
                        if perms then 
                            for a, z in pairs(v) do
                                if a ~= "_config" and veh.vehicle == a then
                                    if not returned_table[i] then 
                                        returned_table[i] = {["_config"] = config}
                                    end
                                    if not returned_table[i].vehicles then 
                                        returned_table[i].vehicles = {}
                                    end
                                    returned_table[i].vehicles[a] = {z[1], z[2], veh.vehicle_plate, veh.fuel_level}
                                    fuellevels[a] = veh.fuel_level
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('URK:ReturnFetchedCars', source, returned_table, fuellevels)
        end)
    end
end)

RegisterNetEvent('URK:CrushVehicle')
AddEventHandler('URK:CrushVehicle', function(vehicle)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id then 
        MySQL.query("URK/check_rented", {user_id = user_id, vehicle = vehicle}, function(pvehicles)
            MySQL.query("URK/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pveh)
                if #pveh < 0 then 
                    URKclient.notify(source,{"~r~You cannot destroy a vehicle you do not own"})
                    return
                end
                if #pvehicles > 0 then 
                    URKclient.notify(source,{"~r~You cannot destroy a rented vehicle!"})
                    return
                end
                MySQL.execute('URK/remove_vehicle', {user_id = user_id, vehicle = vehicle})
                tURK.sendWebhook('crush-vehicle', "URK Crush Vehicle Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Vehicle: **"..vehicle.."**")
                TriggerClientEvent('URK:CloseGarage', source)
            end)
        end)
    end
end)

RegisterNetEvent('URK:SellVehicle')
AddEventHandler('URK:SellVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = URK.getUserId(source)
    if playerID ~= nil then
		URKclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. URK.getUserId(k) .. "]" .. GetPlayerName(k) .. " | "
			end
			if usrList ~= "" then
				URK.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id ~= nil and user_id ~= "" then 
						local target = URK.getUserSource(tonumber(user_id))
						if target ~= nil then
							URK.prompt(player,"Price £: ","",function(player,amount)
								if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
									MySQL.query("URK/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
										if #pvehicle > 0 then
											URKclient.notify(player,{"~r~The player already has this vehicle type."})
										else
											local tmpdata = URK.getUserTmpTable(playerID)
											MySQL.query("URK/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                if #pvehicles > 0 then 
                                                    URKclient.notify(player,{"~r~You cannot sell a rented vehicle!"})
                                                    return
                                                else
                                                    URK.request(target,GetPlayerName(player).." wants to sell: " ..name.. " Price: £"..getMoneyStringFormatted(amount), 10, function(target,ok)
                                                        if ok then
                                                            local pID = URK.getUserId(target)
                                                            amount = tonumber(amount)
                                                            if URK.tryFullPayment(pID,amount) then
                                                                URKclient.despawnGarageVehicle(player,{'car',15}) 
                                                                URK.getUserIdentity(pID, function(identity)
                                                                    MySQL.execute("URK/sell_vehicle_player", {user_id = user_id, registration = "P "..identity.registration, oldUser = playerID, vehicle = name}) 
                                                                end)
                                                                URK.giveBankMoney(playerID, amount)
                                                                URKclient.notify(player,{"~g~You have successfully sold the vehicle to ".. GetPlayerName(target).." for £"..getMoneyStringFormatted(amount).."!"})
                                                                URKclient.notify(target,{"~g~"..GetPlayerName(player).." has successfully sold you the car for £"..getMoneyStringFormatted(amount).."!"})
                                                                tURK.sendWebhook('sell-vehicle', "URK Sell Vehicle Logs", "> Seller Name: **"..GetPlayerName(player).."**\n> Seller TempID: **"..player.."**\n> Seller PermID: **"..playerID.."**\n> Buyer Name: **"..GetPlayerName(target).."**\n> Buyer TempID: **"..target.."**\n> Buyer PermID: **"..user_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Vehicle: **"..vehicle.."**")
                                                                TriggerClientEvent('URK:CloseGarage', player)
                                                            else
                                                                URKclient.notify(player,{"~r~".. GetPlayerName(target).." doesn't have enough money!"})
                                                                URKclient.notify(target,{"~r~You don't have enough money!"})
                                                            end
                                                        else
                                                            URKclient.notify(player,{"~r~"..GetPlayerName(target).." has refused to buy the car."})
                                                            URKclient.notify(target,{"~r~You have refused to buy "..GetPlayerName(player).."'s car."})
                                                        end
                                                    end)
                                                end
                                            end)
										end
									end) 
								else
									URKclient.notify(player,{"~r~The price of the car has to be a number."})
								end
							end)
						else
							URKclient.notify(player,{"~r~That ID seems invalid."})
						end
					else
						URKclient.notify(player,{"~r~No player ID selected."})
					end
				end)
			else
				URKclient.notify(player,{"~r~No players nearby."})
			end
		end)
    end
end)


RegisterNetEvent('URK:RentVehicle')
AddEventHandler('URK:RentVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = URK.getUserId(source)
    if playerID ~= nil then
		URKclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. URK.getUserId(k) .. "]" .. GetPlayerName(k) .. " | "
			end
			if usrList ~= "" then
				URK.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id ~= nil and user_id ~= "" then 
						local target = URK.getUserSource(tonumber(user_id))
						if target ~= nil then
							URK.prompt(player,"Price £: ","",function(player,amount)
                                URK.prompt(player,"Rent time (in hours): ","",function(player,rent)
                                    if tonumber(rent) and tonumber(rent) >  0 then 
                                        if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
                                            MySQL.query("URK/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
                                                if #pvehicle > 0 then
                                                    URKclient.notify(player,{"~r~The player already has this vehicle."})
                                                else
                                                    local tmpdata = URK.getUserTmpTable(playerID)
                                                    MySQL.query("URK/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                        if #pvehicles > 0 then 
                                                            return
                                                        else
                                                            URK.prompt(player, "Please replace text with YES or NO to confirm", "Rent Details:\nVehicle: "..name.."\nRent Cost: "..getMoneyStringFormatted(amount).."\nDuration: "..rent.." hours\nRenting to player: "..GetPlayerName(target).."("..URK.getUserId(target)..")",function(player,details)
                                                                if string.upper(details) == 'YES' then
                                                                    URKclient.notify(player, {'~g~Rent offer sent!'})
                                                                    URK.request(target,GetPlayerName(player).." wants to rent: " ..name.. " Price: £"..getMoneyStringFormatted(amount) .. ' | for: ' .. rent .. 'hours', 10, function(target,ok)
                                                                        if ok then
                                                                            local pID = URK.getUserId(target)
                                                                            amount = tonumber(amount)
                                                                            if URK.tryFullPayment(pID,amount) then
                                                                                URKclient.despawnGarageVehicle(player,{'car',15}) 
                                                                                URK.getUserIdentity(pID, function(identity)
                                                                                    local rentedTime = os.time()
                                                                                    rentedTime = rentedTime  + (60 * 60 * tonumber(rent)) 
                                                                                    MySQL.execute("URK/rentedupdate", {user_id = playerID, veh = name, id = pID, rented = 1, rentedid = playerID, rentedunix =  rentedTime }) 
                                                                                end)
                                                                                URK.giveBankMoney(playerID, amount)
                                                                                URKclient.notify(player,{"~g~You have successfully rented the vehicle to "..GetPlayerName(target).." for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours'})
                                                                                URKclient.notify(target,{"~g~"..GetPlayerName(player).." has successfully rented you the car for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours'})
                                                                                tURK.sendWebhook('rent-vehicle', "URK Rent Vehicle Logs", "> Renter Name: **"..GetPlayerName(player).."**\n> Renter TempID: **"..player.."**\n> Renter PermID: **"..playerID.."**\n> Rentee Name: **"..GetPlayerName(target).."**\n> Rentee TempID: **"..target.."**\n> Rentee PermID: **"..pID.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Duration: **"..rent.." hours**\n> Vehicle: **"..veh.."**")
                                                                                --TriggerClientEvent('URK:CloseGarage', player)
                                                                            else
                                                                                URKclient.notify(player,{"~r~".. GetPlayerName(target).." doesn't have enough money!"})
                                                                                URKclient.notify(target,{"~r~You don't have enough money!"})
                                                                            end
                                                                        else
                                                                            URKclient.notify(player,{"~r~"..GetPlayerName(target).." has refused to rent the car."})
                                                                            URKclient.notify(target,{"~r~You have refused to rent "..GetPlayerName(player).."'s car."})
                                                                        end
                                                                    end)
                                                                else
                                                                    URKclient.notify(player, {'~r~Rent offer cancelled!'})
                                                                end
                                                            end)
                                                        end
                                                    end)
                                                end
                                            end) 
                                        else
                                            URKclient.notify(player,{"~r~The price of the car has to be a number."})
                                        end
                                    else 
                                        URKclient.notify(player,{"~r~The rent time of the car has to be in hours and a number."})
                                    end
                                end)
							end)
						else
							URKclient.notify(player,{"~r~That ID seems invalid."})
						end
					else
						URKclient.notify(player,{"~r~No player ID selected."})
					end
				end)
			else
				URKclient.notify(player,{"~r~No players nearby."})
			end
		end)
    end
end)



RegisterNetEvent('URK:FetchRented')
AddEventHandler('URK:FetchRented', function()
    local rentedin = {}
    local rentedout = {}
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URK/get_rented_vehicles_in", {user_id = user_id}, function(pvehicles, affected)
        for _, veh in pairs(pvehicles) do
            for i, v in pairs(vehicle_groups) do
                local config = vehicle_groups[i]._config
                local perm = config.permissions or nil
                if perm then
                    for i, v in pairs(perm) do
                        if not URK.hasPermission(user_id, v) then
                            break
                        end
                    end
                end
                for a, z in pairs(v) do
                    if a ~= "_config" and veh.vehicle == a then
                        if not rentedin.vehicles then 
                            rentedin.vehicles = {}
                        end
                        local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                        local minutesLeft = nil
                        if hoursLeft < 1 then
                            minutesLeft = hoursLeft * 60
                            minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                            datetime = minutesLeft .. " mins" 
                        else
                            hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                            datetime = hoursLeft .. " hours" 
                        end
                        rentedin.vehicles[a] = {z[1], datetime, veh.user_id, a}
                    end
                end
            end
        end
        MySQL.query("URK/get_rented_vehicles_out", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local config = vehicle_groups[i]._config
                    local perm = config.permissions or nil
                    if perm then
                        for i, v in pairs(perm) do
                            if not URK.hasPermission(user_id, v) then
                                break
                            end
                        end
                    end
                    for a, z in pairs(v) do
                        if a ~= "_config" and veh.vehicle == a then
                            if not rentedout.vehicles then 
                                rentedout.vehicles = {}
                            end
                            local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                            local minutesLeft = nil
                            if hoursLeft < 1 then
                                minutesLeft = hoursLeft * 60
                                minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                                datetime = minutesLeft .. " mins" 
                            else
                                hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                                datetime = hoursLeft .. " hours" 
                            end
                            rentedout.vehicles[a] = {z[1], datetime, veh.user_id, a}
                        end
                    end
                end
            end
            TriggerClientEvent('URK:ReturnedRentedCars', source, rentedin, rentedout)
        end)
    end)
end)

RegisterNetEvent('URK:CancelRent')
AddEventHandler('URK:CancelRent', function(spawncode, VehicleName, a)
    local source = source
    local user_id = URK.getUserId(source)
    if a == 'owner' then
        exports['ghmattimysql']:execute("SELECT * FROM urk_user_vehicles WHERE rentedid = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local target = URK.getUserSource(result[i].user_id)
                        if target ~= nil then
                            URK.request(target,GetPlayerName(source).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.execute('URK/rentedupdate', {id = user_id, rented = 0, rentedid = "", rentedunix = "", user_id = result[i].user_id, veh = spawncode})
                                    URKclient.notify(target, {"~r~" ..VehicleName.." has been returned to the vehicle owner."})
                                    URKclient.notify(source, {"~r~" ..VehicleName.." has been returned to your garage."})
                                else
                                    URKclient.notify(source, {"~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName})
                                end
                            end)
                        else
                            URKclient.notify(source, {"~r~The player is not online."})
                        end
                    end
                end
            end
        end)
    elseif a == 'renter' then
        exports['ghmattimysql']:execute("SELECT * FROM urk_user_vehicles WHERE user_id = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local rentedid = tonumber(result[i].rentedid)
                        local target = URK.getUserSource(rentedid)
                        if target ~= nil then
                            URK.request(target,GetPlayerName(source).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.execute('URK/rentedupdate', {id = rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = user_id, veh = spawncode})
                                    URKclient.notify(source, {"~r~" ..VehicleName.." has been returned to the vehicle owner."})
                                    URKclient.notify(target, {"~r~" ..VehicleName.." has been returned to your garage."})
                                else
                                    URKclient.notify(source, {"~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName})
                                end
                            end)
                        else
                            URKclient.notify(source, {"~r~The player is not online."})
                        end
                    end
                end
            end
        end)
    end
end)

-- repair nearest vehicle
local function ch_repair(player,choice)
  local user_id = URK.getUserId(player)
  if user_id ~= nil then
    -- anim and repair
    if URK.tryGetInventoryItem(user_id,"repairkit",1,true) then
      URKclient.playAnim(player,{false,{task="WORLD_HUMAN_WELDING"},false})
      SetTimeout(15000, function()
        URKclient.fixeNearestVehicle(player,{7})
        URKclient.stopAnim(player,{false})
      end)
    end
  end
end

RegisterNetEvent("URK:PayVehicleTax")
AddEventHandler("URK:PayVehicleTax", function()
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        local bank = URK.getBankMoney(user_id)
        local payment = bank / 10000
        if URK.tryBankPayment(user_id, payment) then
            URKclient.notify(source,{"~g~Paid £"..getMoneyStringFormatted(math.floor(payment)).." vehicle tax."})
            TriggerEvent('URK:addToCommunityPot', math.floor(payment))
        else
            URKclient.notify(source,{"~r~Its fine... Tax payers will pay your vehicle tax instead."})
        end
    end
end)

RegisterNetEvent("URK:refreshGaragePermissions")
AddEventHandler("URK:refreshGaragePermissions",function()
    local source=source
    local garageTable={}
    local user_id = URK.getUserId(source)
    for k,v in pairs(cfg.garages) do
        for a,b in pairs(v) do
            if a == "_config" then
                if json.encode(b.permissions) ~= '[""]' then
                    local hasPermissions = 0
                    for c,d in pairs(b.permissions) do
                        if URK.hasPermission(user_id, d) then
                            hasPermissions = hasPermissions + 1
                        end
                    end
                    if hasPermissions == #b.permissions then
                        table.insert(garageTable, k)
                    end
                else
                    table.insert(garageTable, k)
                end
            end
        end
    end
    local ownedVehicles = {}
    if user_id then
        MySQL.query("URK/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for k,v in pairs(pvehicles) do
                table.insert(ownedVehicles, v.vehicle)
            end
            TriggerClientEvent('URK:updateOwnedVehicles', source, ownedVehicles)
        end)
    end
    TriggerClientEvent("URK:recieveRefreshedGaragePermissions",source,garageTable)
end)


RegisterNetEvent("URK:getGarageFolders")
AddEventHandler("URK:getGarageFolders",function()
    local source = source
    local user_id = URK.getUserId(source)
    local garageFolders = {}
    local addedFolders = {}
    MySQL.query("URK/get_vehicles", {user_id = user_id}, function(result)
        if result ~= nil then 
            for k,v in pairs(result) do
                local spawncode = v.vehicle 
                for a,b in pairs(vehicle_groups) do
                    local hasPerm = true
                    if next(b._config.permissions) then
                        if not URK.hasPermission(user_id, b._config.permissions[1]) then
                            hasPerm = false
                        end
                    end
                    if hasPerm then
                        for c,d in pairs(b) do
                            if c == spawncode and not v.impounded then
                                if not addedFolders[a] then
                                    table.insert(garageFolders, {display = a})
                                    addedFolders[a] = true
                                end
                                for e,f in pairs (garageFolders) do
                                    if f.display == a then
                                        if f.vehicles == nil then
                                            f.vehicles = {}
                                        end
                                        table.insert(f.vehicles, {display = d[1], spawncode = spawncode})
                                    end
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('URK:setVehicleFolders', source, garageFolders)
        end
    end)
end)

local cfg_weapons = module("URKFirearms", "cfg/weapons")

RegisterServerEvent("URK:searchVehicle")
AddEventHandler('URK:searchVehicle', function(entity, permid)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        if URK.getUserSource(permid) ~= nil then
            URKclient.getNetworkedVehicleInfos(URK.getUserSource(permid), {entity}, function(owner, spawncode)
                if spawncode and owner == permid then
                    local vehformat = 'chest:u1veh_'..spawncode..'|'..permid
                    URK.getSData(vehformat, function(cdata)
                        if cdata ~= nil then
                            cdata = json.decode(cdata)
                            if next(cdata) then
                                for a,b in pairs(cdata) do
                                    if string.find(a, 'wbody|') then
                                        c = a:gsub('wbody|', '')
                                        cdata[c] = b
                                        cdata[a] = nil
                                    end
                                end
                                for k,v in pairs(cfg_weapons.weapons) do
                                    if cdata[k] ~= nil then
                                        if not v.policeWeapon then
                                            URKclient.notify(source, {'~r~Seized '..v.name..' x'..cdata[k].amount..'.'})
                                            cdata[k] = nil
                                        end
                                    end
                                end
                                for c,d in pairs(cdata) do
                                    if seizeBullets[c] then
                                        URKclient.notify(source, {'~r~Seized '..c..' x'..d.amount..'.'})
                                        cdata[c] = nil
                                    end
                                    if seizeDrugs[c] then
                                        URKclient.notify(source, {'~r~Seized '..c..' x'..d.amount..'.'})
                                        cdata[c] = nil
                                    end
                                end
                                URK.setSData(vehformat, json.encode(cdata))
                                tURK.sendWebhook('seize-boot', 'URK Seize Boot Logs', "> Officer Name: **"..GetPlayerName(source).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Vehicle: **"..spawncode.."**\n> Owner ID: **"..permid.."**")
                            else
                                URKclient.notify(source, {'~r~This vehicle is empty.'})
                            end
                        else
                            URKclient.notify(source, {'~r~This vehicle is empty.'})
                        end
                    end)
                end
            end)
        end
    end
end)


Citizen.CreateThread(function()
    Wait(1500)
    exports['ghmattimysql']:execute([[
        CREATE TABLE IF NOT EXISTS `urk_custom_garages` (
            `user_id` INT(11) NOT NULL AUTO_INCREMENT,
            `folder` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
            PRIMARY KEY (`user_id`) USING BTREE
        );
    ]])
end)
