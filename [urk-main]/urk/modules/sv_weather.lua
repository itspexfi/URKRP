voteCooldown = 1800
currentWeather = "CLEAR"

weatherVoterCooldown = voteCooldown

RegisterServerEvent("URK:vote") 
AddEventHandler("URK:vote", function(weatherType)
    TriggerClientEvent("URK:voteStateChange",-1,weatherType)
end)

RegisterServerEvent("URK:tryStartWeatherVote") 
AddEventHandler("URK:tryStartWeatherVote", function()
	local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.managecommunitypot') then
        if weatherVoterCooldown >= voteCooldown then
            TriggerClientEvent("URK:startWeatherVote", -1)
            weatherVoterCooldown = 0
        else
            TriggerClientEvent("chatMessage", source, "Another vote can be started in " .. tostring(voteCooldown-weatherVoterCooldown) .. " seconds!", {255, 0, 0})
        end
    else
        URKclient.notify(source, {'~r~You do not have permission for this.'})
    end
end)

RegisterServerEvent("URK:getCurrentWeather") 
AddEventHandler("URK:getCurrentWeather", function()
    local source = source
    TriggerClientEvent("URK:voteFinished",source,currentWeather)
end)

RegisterServerEvent("URK:setCurrentWeather")
AddEventHandler("URK:setCurrentWeather", function(newWeather)
	currentWeather = newWeather
end)

Citizen.CreateThread(function()
	while true do
		weatherVoterCooldown = weatherVoterCooldown + 1
		Citizen.Wait(1000)
	end
end)