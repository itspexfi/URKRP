local forbiddenNames = {
	"%^1",
	"%^2",
	"%^3",
	"%^4",
	"%^5",
	"%^6",
	"%^7",
	"%^8",
	"%^9",
	"%^%*",
	"%^_",
	"%^=",
	"%^%~",
	"admin",
	"nigger",
	"cunt",
	"faggot",
	"fuck",
	"fucker",
	"fucking",
	"anal",
	"stupid",
	"damn",
	"cock",
	"cum",
	"dick",
	"dipshit",
	"dildo",
	"douchbag",
	"douch",
	"kys",
	"jerk",
	"jerkoff",
	"gay",
	"homosexual",
	"lesbian",
	"suicide",
	"mothafucka",
	"negro",
	"pussy",
	"queef",
	"queer",
	"weeb",
	"retard",
	"masterbate",
	"suck",
	"tard",
	"allahu akbar",
	"terrorist",
	"twat",
	"vagina",
	"wank",
	"whore",
	"wanker",
	"n1gger",
	"f4ggot",
	"n0nce",
	"d1ck",
	"h0m0",
	"n1gg3r",
	"h0m0s3xual",
	"free up mandem",
	"nazi",
	"hitler",
	"cheater",
	"cheating",
}

MySQL.createCommand("URK/update_numplate","UPDATE urk_user_vehicles SET vehicle_plate = @registration WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("URK/check_numplate","SELECT * FROM urk_user_vehicles WHERE vehicle_plate = @plate")

RegisterNetEvent('URK:getCars')
AddEventHandler('URK:getCars', function()
    local cars = {}
    local source = source
    local user_id = URK.getUserId(source)
    exports['ghmattimysql']:execute("SELECT * FROM `urk_user_vehicles` WHERE user_id = @user_id", {user_id = user_id}, function(result)
        if result ~= nil then 
            for k,v in pairs(result) do
                if v.user_id == user_id then
                    cars[v.vehicle] = {v.vehicle, v.vehicle_plate}
                end
            end
            TriggerClientEvent('URK:carsTable', source, cars)
        end
    end)
end)

RegisterNetEvent("URK:ChangeNumberPlate")
AddEventHandler("URK:ChangeNumberPlate", function(vehicle)
	local source = source
    local user_id = URK.getUserId(source)
	URK.prompt(source,"Plate Name:","",function(source, plateName)
		if plateName == '' then return end
		exports['ghmattimysql']:execute("SELECT * FROM `urk_user_vehicles` WHERE vehicle_plate = @plate", {plate = plateName}, function(result)
            if next(result) then 
                URKclient.notify(source,{"~r~This plate is already taken."})
                return
			else
				for name in pairs(forbiddenNames) do
					if plateName == forbiddenNames[name] then
						URKclient.notify(source,{"~r~You cannot have this plate."})
						return
					end
				end
				if URK.tryFullPayment(user_id,50000) then
					URKclient.notify(source,{"~g~Changed plate of "..vehicle.." to "..plateName})
					MySQL.execute("URK/update_numplate", {user_id = user_id, registration = plateName, vehicle = vehicle})
					TriggerClientEvent("URK:RecieveNumberPlate", source, plateName)
					TriggerClientEvent("urk:PlaySound", source, "apple")
					TriggerEvent('URK:getCars')
				else
					URKclient.notify(source,{"~r~You don't have enough money!"})
				end
            end
        end)
	end)
end)

RegisterNetEvent("URK:checkPlateAvailability")
AddEventHandler("URK:checkPlateAvailability", function(plate)
	local source = source
    local user_id = URK.getUserId(source)
	MySQL.query("URK/check_numplate", {plate = plate}, function(result)
		if #result > 0 then 
			URKclient.notify(source, {"~r~The plate "..plate.." is already taken."})
		else
			URKclient.notify(source, {"~g~The plate "..plate.." is available."})
		end
	end)
end)
