RegisterCommand('sw', function(player, args)
    local user_id = URK.getUserId(player)
    local permID =  tonumber(args[1])
    if permID ~= nil then
        if URK.hasPermission(user_id,"admin.tickets") then
			urkwarningstables = geturkWarnings(permID,player)
			a = exports['ghmattimysql']:executeSync("SELECT * FROM urk_bans_offenses WHERE UserID = @uid", {uid = permID})
			for k,v in pairs(a) do
				if v.UserID == permID then
					TriggerClientEvent("urk:showWarningsOfUser",player,urkwarningstables,v.points)
				end
			end
        end
    end
end)
	
function geturkWarnings(user_id,source) 
	urkwarningstables = exports['ghmattimysql']:executeSync("SELECT * FROM urk_warnings WHERE user_id = @uid", {uid = user_id})
	for warningID,warningTable in pairs(urkwarningstables) do
		date = warningTable["warning_date"]
		newdate = tonumber(date) / 1000
		newdate = os.date('%Y-%m-%d', newdate)
		warningTable["warning_date"] = newdate
	end
	return urkwarningstables
end

RegisterServerEvent("urk:refreshWarningSystem")
AddEventHandler("urk:refreshWarningSystem",function()
	local source = source
	local user_id = URK.getUserId(source)	
	urkwarningstables = geturkWarnings(user_id,source)
	a = exports['ghmattimysql']:executeSync("SELECT * FROM urk_bans_offenses WHERE UserID = @uid", {uid = user_id})
	for k,v in pairs(a) do
		if v.UserID == user_id then
			TriggerClientEvent("urk:recievedRefreshedWarningData",source,urkwarningstables,v.points)
		end
	end
end)

function f10Ban(target_id,adminName,warningReason,warning_duration)
	if warning_duration == -1 then
		warning_duration = 0
	end
	warning = "Ban"
	exports['ghmattimysql']:execute("INSERT INTO urk_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (@user_id, @warning_type, @duration, @admin, @warning_date,@reason);", {user_id = target_id, warning_type = "Ban", admin = adminName, duration = warning_duration, warning_date = os.date("%Y/%m/%d"), reason = warningReason}, function() end)
end
