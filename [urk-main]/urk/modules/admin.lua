local htmlEntities = module("lib/htmlEntities")
local Tools = module("lib/Tools")

RegisterServerEvent('URK:OpenSettings')
AddEventHandler('URK:OpenSettings', function()
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        if URK.hasPermission(user_id, "admin.tickets") then
            TriggerClientEvent("URK:OpenAdminMenu", source, true)
        else
            TriggerClientEvent("URK:OpenSettingsMenu", source, false)
        end
    end
end)

RegisterCommand("gethours", function(source, args)
    local v = source
    local UID = URK.getUserId(v)
    local D = math.ceil(URK.getUserDataTable(UID).PlayerTime/60) or 0
    if UID then
        if D > 5000 then
            DropPlayer(v, "[URK] You were permanently banned\nReason: Not Touching Grass\nYour ID: "..UID.."\nIf you believe this was a false ban, appeal @ www.idonttouchgrass.com")
        elseif D > 4000 then
            URKclient.notify(v,{"~g~You currently have ~b~"..D.." ~g~hours. Almost as bad as Jamo."})
        elseif D > 3000 then
            URKclient.notify(v,{"~g~You currently have ~b~"..D.." ~g~hours. Touch some fucking grass."})
        elseif D > 2000 then
            URKclient.notify(v,{"~g~You currently have ~b~"..D.." ~g~hours. Seriously, go outside."})
        elseif D > 1000 then
            URKclient.notify(v,{"~g~You currently have ~b~"..D.." ~g~hours. Go outside."})
        else
            URKclient.notify(v,{"~g~You currently have ~b~"..D.." ~g~hours."})
        end
    end
end)

RegisterCommand("sethours", function(source, args) 
    if source == 0 then 
        local data = URK.getUserDataTable(tonumber(args[1]))
        data.PlayerTime = tonumber(args[2])*60
        print(GetPlayerName(URK.getUserSource(tonumber(args[1]))).."'s hours have been set to: "..tonumber(args[2]))
    end  
end)


RegisterNetEvent("URK:GetNearbyPlayers")
AddEventHandler("URK:GetNearbyPlayers", function(coords, dist)
    local source = source
    local user_id = URK.getUserId(source)
    local plrTable = {}
    if URK.hasPermission(user_id, 'admin.tickets') then
        URKclient.getNearestPlayersFromPosition(source, {coords, dist}, function(nearbyPlayers)
            for k, v in pairs(nearbyPlayers) do
                data = URK.getUserDataTable(URK.getUserId(k))
                playtime = data.PlayerTime or 0
                PlayerTimeInHours = playtime/60
                if PlayerTimeInHours < 1 then
                    PlayerTimeInHours = 0
                end
                plrTable[URK.getUserId(k)] = {GetPlayerName(k), k, URK.getUserId(k), math.ceil(PlayerTimeInHours)}
            end
            plrTable[user_id] = {GetPlayerName(source), source, URK.getUserId(source), math.ceil((URK.getUserDataTable(user_id).PlayerTime/60)) or 0}
            TriggerClientEvent("URK:ReturnNearbyPlayers", source, plrTable)
        end)
    end
end)

RegisterServerEvent("URK:requestAccountInfosv")
AddEventHandler("URK:requestAccountInfosv",function(permid)
    adminrequest = source
    adminrequest_id = URK.getUserId(adminrequest)
    requesteduser = permid
    requestedusersource = URK.getUserSource(requesteduser)
    if URK.hasPermission(adminrequest_id, 'group.remove') then
        TriggerClientEvent('URK:requestAccountInfo', URK.getUserSource(permid))
    end
end)

RegisterServerEvent("URK:receivedAccountInfo")
AddEventHandler("URK:receivedAccountInfo", function(gpu,cpu,userAgent)
    if URK.hasPermission(adminrequest_id, 'group.remove') then
        URK.prompt(adminrequest,"Account Info","GPU: " .. gpu.." \n\nCPU: "..cpu.." \n\nUser Agent: "..userAgent,function(player,K)
        end)
    end
end)

RegisterServerEvent("URK:GetGroups")
AddEventHandler("URK:GetGroups",function(perm)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("URK:GotGroups", source, URK.getUserGroups(perm))
    end
end)

RegisterServerEvent("URK:CheckPov")
AddEventHandler("URK:CheckPov",function(userperm)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.tickets") then
        if URK.hasPermission(userperm, 'pov.list') then
            TriggerClientEvent('URK:ReturnPov', source, true)
        else
            TriggerClientEvent('URK:ReturnPov', source, false)
        end
    end
end)


RegisterServerEvent("wk:fixVehicle")
AddEventHandler("wk:fixVehicle",function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent('wk:fixVehicle', source)
    end
end)

local spectatingPositions = {}
RegisterServerEvent("URK:spectatePlayer")
AddEventHandler("URK:spectatePlayer", function(id)
    local playerssource = URK.getUserSource(id)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.spectate") then
        if playerssource ~= nil then
            spectatingPositions[user_id] = {coords = GetEntityCoords(GetPlayerPed(source)), bucket = GetPlayerRoutingBucket(source)}
            tURK.setBucket(source, GetPlayerRoutingBucket(playerssource))
            TriggerClientEvent("URK:spectatePlayer",source, playerssource, GetEntityCoords(GetPlayerPed(playerssource)))
            tURK.sendWebhook('spectate',"URK Spectate Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(playerssource).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..playerssource.."**")
        else
            URKclient.notify(source, {"~r~You can't spectate an offline player."})
        end
    end
end)

RegisterServerEvent("URK:stopSpectatePlayer")
AddEventHandler("URK:stopSpectatePlayer", function()
    local source = source
    if URK.hasPermission(URK.getUserId(source), "admin.spectate") then
        TriggerClientEvent("URK:stopSpectatePlayer",source)
        for k,v in pairs(spectatingPositions) do
            if k == URK.getUserId(source) then
                TriggerClientEvent("URK:stopSpectatePlayer",source,v.coords,v.bucket)
                SetEntityCoords(GetPlayerPed(source),v.coords)
                tURK.setBucket(source, v.bucket)
                spectatingPositions[k] = nil
            end
        end
    end
end)

RegisterServerEvent("URK:Giveweapon")
AddEventHandler("URK:Giveweapon",function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "dev.menu") then
        URK.prompt(source,"Weapon Name:","",function(source,hash) 
            URKclient.giveWeapons(source, {{['WEAPON_'..string.upper(hash)] = {ammo = 250}}, false})
            URKclient.notify(source,{"~g~Successfully spawned ~b~"..hash})
        end)
    end
end)

RegisterServerEvent("URK:GiveWeaponToPlayer")
AddEventHandler("URK:GiveWeaponToPlayer",function()
    local source = source
    local admin = source
    local admin_id = URK.getUserId(admin)
    local admin_name = GetPlayerName(admin)
    local source = source
    local userid = URK.getUserId(source)
    if URK.hasPermission(userid, "dev.menu") then
        URK.prompt(source,"Perm ID:","",function(source,permid) 
            local permid = tonumber(permid)
            local permsource = URK.getUserSource(permid)
            if permsource ~= nil then
                URK.prompt(source,"Weapon Name:","",function(source,hash) 
                    URKclient.giveWeapons(permsource, {{['WEAPON_'..string.upper(hash)] = {ammo = 250}}, false})
                    URKclient.notify(source,{"~g~Successfully gave ~b~"..hash..' ~g~to '..GetPlayerName(permsource)})
                end)
            end
        end)
    end
end)

RegisterServerEvent("URK:ForceClockOff")
AddEventHandler("URK:ForceClockOff", function(player_temp)
    local source = source
    local user_id = URK.getUserId(source)
    local name = GetPlayerName(source)
    local player_perm = URK.getUserId(player_temp)
    if URK.hasPermission(user_id,"admin.tp2waypoint") then
        URK.removeAllJobs(player_perm)
        URKclient.notify(source,{'~g~User clocked off'})
        URKclient.notify(player_temp,{'~r~You have been force clocked off.'})
        tURK.sendWebhook('force-clock-off',"URK Faction Logs", "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GetPlayerName(player_temp).."**\n> Players TempID: **"..player_temp.."**\n> Players PermID: **"..player_perm.."**")
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Force Clock Off')
    end
end)

RegisterServerEvent("URK:AddGroup")
AddEventHandler("URK:AddGroup",function(perm, selgroup)
    local source = source
    local admin_temp = source
    local user_id = URK.getUserId(source)
    local permsource = URK.getUserSource(perm)
    local playerName = GetPlayerName(source)
    local povName = GetPlayerName(permsource)
    if URK.hasPermission(user_id, "group.add") then
        if selgroup == "Founder" and not URK.hasPermission(user_id, "group.add.founder") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
            elseif selgroup == "Lead Developer" and not URK.hasPermission(user_id, "group.add.leaddeveloper") then
                URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
            elseif selgroup == "Lead Developer" and not URK.hasPermission(user_id, "group.add.developer") then
                URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Staff Manager" and not URK.hasPermission(user_id, "group.add.staffmanager") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Community Manager" and not URK.hasPermission(user_id, "group.add.commanager") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Head Admin" and not URK.hasPermission(user_id, "group.add.headadmin") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Senior Admin" and not URK.hasPermission(user_id, "group.add.senioradmin") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Admin" and not URK.hasPermission(user_id, "group.add.administrator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Senior Moderator" and not URK.hasPermission(user_id, "group.add.srmoderator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Moderator" and not URK.hasPermission(user_id, "group.add.moderator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Support Team" and not URK.hasPermission(user_id, "group.add.supportteam") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Trial Staff" and not URK.hasPermission(user_id, "group.add.trial") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "pov" and not URK.hasPermission(user_id, "group.add.pov") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        else
            URK.addUserGroup(perm, selgroup)
            local user_groups = URK.getUserGroups(perm)
            TriggerClientEvent("URK:GotGroups", source, user_groups)
            tURK.sendWebhook('group',"URK Group Logs", "> Admin Name: **"..playerName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GetPlayerName(permsource).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Added**")
        end
    end
end)

RegisterServerEvent("URK:RemoveGroup")
AddEventHandler("URK:RemoveGroup",function(perm, selgroup)
    local source = source
    local user_id = URK.getUserId(source)
    local admin_temp = source
    local permsource = URK.getUserSource(perm)
    local playerName = GetPlayerName(source)
    local povName = GetPlayerName(permsource)
    if URK.hasPermission(user_id, "group.remove") then
        if selgroup == "Founder" and not URK.hasPermission(user_id, "group.remove.founder") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
            elseif selgroup == "Developer" and not URK.hasPermission(user_id, "group.remove.developer") then
                URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Staff Manager" and not URK.hasPermission(user_id, "group.remove.staffmanager") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Community Manager" and not URK.hasPermission(user_id, "group.remove.commanager") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Head Admin" and not URK.hasPermission(user_id, "group.remove.headadmin") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"}) 
        elseif selgroup == "Senior Admin" and not URK.hasPermission(user_id, "group.remove.senioradmin") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Admin" and not URK.hasPermission(user_id, "group.remove.administrator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Senior Moderator" and not URK.hasPermission(user_id, "group.remove.srmoderator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Moderator" and not URK.hasPermission(user_id, "group.remove.moderator") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Support Team" and not URK.hasPermission(user_id, "group.remove.supportteam") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "Trial Staff" and not URK.hasPermission(user_id, "group.remove.trial") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        elseif selgroup == "pov" and not URK.hasPermission(user_id, "group.remove.pov") then
            URKclient.notify(admin_temp, {"~r~You don't have permission to do that"})
        else
            URK.removeUserGroup(perm, selgroup)
            local user_groups = URK.getUserGroups(perm)
            TriggerClientEvent("URK:GotGroups", source, user_groups)
            tURK.sendWebhook('group',"URK Group Logs", "> Admin Name: **"..playerName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..GetPlayerName(permsource).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Removed**")
        end
    end
end)

local bans = {
    {id = "trolling",name = "1.0 Trolling",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "trollingminor",name = "1.0 Trolling (Minor)",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "metagaming",name = "1.1 Metagaming",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "powergaming",name = "1.2 Power Gaming ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "failrp",name = "1.3 Fail RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rdm", name = "1.4 RDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massrdm",name = "1.4.1 Mass RDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "nrti",name = "1.5 No Reason to Initiate (NRTI) ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "vdm", name = "1.6 VDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massvdm",name = "1.6.1 Mass VDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "offlanguageminor",name = "1.7 Offensive Language/Toxicity (Minor)",durations = {2,24,72},bandescription = "1st Offense: 2hr\n2nd Offense: 24hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "offlanguagestandard",name = "1.7 Offensive Language/Toxicity (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "offlanguagesevere",name = "1.7 Offensive Language/Toxicity (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "breakrp",name = "1.8 Breaking Character",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "combatlog",name = "1.9 Combat logging",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatstore",name = "1.10 Combat storing",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "exploitingstandard",name = "1.11 Exploiting (Standard)",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "exploitingsevere",name = "1.11 Exploiting (Severe)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "oogt",name = "1.12 Out of game transactions (OOGT)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "spitereport",name = "1.13 Spite Reporting",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "scamming",name = "1.14 Scamming",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "loans",name = "1.15 Loans",durations = {48,168,-1},bandescription = "1st Offense: 48hr\n2nd Offense: 168hr\n3rd Offense: Permanent",itemchecked = false},
    {id = "wastingadmintime",name = "1.16 Wasting Admin Time",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "ftvl",name = "2.1 Value of Life",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "sexualrp",name = "2.2 Sexual RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "terrorrp",name = "2.3 Terrorist RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "impwhitelisted",name = "2.4 Impersonation of Whitelisted Factions",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gtadriving",name = "2.5 GTA Online Driving",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "nlr", name = "2.6 NLR",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "badrp",name = "2.7 Bad RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "kidnapping",name = "2.8 Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "stealingems",name = "3.0 Theft of Emergency Vehicles",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "whitelistabusestandard",name = "3.1 Whitelist Abuse",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "whitelistabusesevere",name = "3.1 Whitelist Abuse",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "copbaiting",name = "3.2 Cop Baiting",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "pdkidnapping",name = "3.3 PD Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "unrealisticrevival",name = "3.4 Unrealistic Revival",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "interjectingrp",name = "3.5 Interjection of RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatrev",name = "3.6 Combat Reviving",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gangcap",name = "3.7 Gang Cap",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "maxgang",name = "3.8 Max Gang Numbers",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "gangalliance",name = "3.9 Gang Alliance",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "impgang",name = "3.10 Impersonation of Gangs",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzstealing",name = "4.1 Stealing Vehicles in Greenzone",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "gzillegal",name = "4.2 Selling Illegal Items in Greenzone",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzretretreating",name = "4.3 Greenzone Retreating ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzhostage",name = "4.5 Taking Hostage into Redzone",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzretreating",name = "4.6 Redzone Retreating",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "advert",name = "1.1 Advertising",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "bullying",name = "1.2 Bullying",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "impersonationrule",name = "1.3 Impersonation",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "language",name = "1.4 Language",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discrim",name = "1.5 Discrimination ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "attacks",name = "1.6 Malicious Attacks ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "PIIstandard",name = "1.7 PII (Personally Identifiable Information)(Standard)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "PIIsevere",name = "1.7 PII (Personally Identifiable Information)(Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "chargeback",name = "1.8 Chargeback",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discretion",name = "1.9 Staff Discretion",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "cheating",name = "1.10 Cheating",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "banevading",name = "1.11 Ban Evading",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "fivemcheats",name = "1.12 Withholding/Storing FiveM Cheats",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "altaccount",name = "1.13 Multi-Accounting",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "association",name = "1.14 Association with External Modifications",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "pov",name = "1.15 Failure to provide POV ",durations = {2,-1,-1},bandescription = "1st Offense: 2hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false    },
    {id = "withholdinginfostandard",name = "1.16 Withholding Information From Staff (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "withholdinginfosevere",name = "1.16 Withholding Information From Staff (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "blackmail",name = "1.17 Blackmailing",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false}
}
    
   

local PlayerOffenses = {}
local PlayerBanCachedDuration = {}
local defaultBans = {}

RegisterServerEvent("URK:GenerateBan")
AddEventHandler("URK:GenerateBan", function(PlayerID, RulesBroken)
    local source = source
    local PlayerCacheBanMessage = {}
    local PermOffense = false
    local separatormsg = {}
    local points = 0
    PlayerBanCachedDuration[PlayerID] = 0
    PlayerOffenses[PlayerID] = {}
    if URK.hasPermission(URK.getUserId(source), "admin.tickets") then
        exports['ghmattimysql']:execute("SELECT * FROM urk_bans_offenses WHERE UserID = @UserID", {UserID = PlayerID}, function(result)
            if #result > 0 then
                points = result[1].points
                PlayerOffenses[PlayerID] = json.decode(result[1].Rules)
                for k,v in pairs(RulesBroken) do
                    for a,b in pairs(bans) do
                        if b.id == k then
                            PlayerOffenses[PlayerID][k] = PlayerOffenses[PlayerID][k] + 1
                            if PlayerOffenses[PlayerID][k] > 3 then
                                PlayerOffenses[PlayerID][k] = 3
                            end
                            PlayerBanCachedDuration[PlayerID] = PlayerBanCachedDuration[PlayerID] + bans[a].durations[PlayerOffenses[PlayerID][k]]
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] ~= -1 then
                                points = points + bans[a].durations[PlayerOffenses[PlayerID][k]]/24
                            end
                            table.insert(PlayerCacheBanMessage, bans[a].name)
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] == -1 then
                                PlayerBanCachedDuration[PlayerID] = -1
                                PermOffense = true
                            end
                            if PlayerOffenses[PlayerID][k] == 1 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~1st Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] == 2 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~2nd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] >= 3 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~3rd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            end
                        end
                    end
                end
                if PermOffense then 
                    PlayerBanCachedDuration[PlayerID] = -1
                end
                Wait(100)
                TriggerClientEvent("URK:RecieveBanPlayerData", source, PlayerBanCachedDuration[PlayerID], table.concat(PlayerCacheBanMessage, ", "), separatormsg, math.floor(points))
            end
        end)
    end
end)

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(bans) do
        defaultBans[v.id] = 0
    end
    exports["ghmattimysql"]:executeSync("INSERT IGNORE INTO urk_bans_offenses(UserID,Rules) VALUES(@UserID, @Rules)", {UserID = user_id, Rules = json.encode(defaultBans)})
    exports["ghmattimysql"]:executeSync("INSERT IGNORE INTO urk_user_notes(user_id) VALUES(@user_id)", {user_id = user_id})
end)

RegisterCommand('removepoints', function(source, args) -- for removing points each month
    local source = source
    if URK.getUserId(source) == 1 or 2 or 3 then
        removePoints = tonumber(args[1])
        exports['ghmattimysql']:execute("UPDATE urk_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE points > 0", {removepoints = removePoints}, function() end)
        URKclient.notify(source, {'~g~Removed '..removePoints..' points from all users.'})
    end
end)

RegisterServerEvent("URK:BanPlayer")
AddEventHandler("URK:BanPlayer", function(PlayerID, Duration, BanMessage, BanPoints)
    local source = source
    local AdminPermID = URK.getUserId(source)
    local AdminName = GetPlayerName(source)
    local CurrentTime = os.time()
    local PlayerDiscordID = 0
    URK.prompt(source, "Extra Ban Information (Hidden)","",function(player, Evidence)
        if URK.hasPermission(AdminPermID, "admin.tickets") then
            if Evidence == "" then
                URKclient.notify(source, {"~r~Evidence field was left empty, please fill this in via Discord."})
            end
            if Duration == -1 then
                banDuration = "perm"
                BanPoints = 0
            else
                banDuration = CurrentTime + (60 * 60 * tonumber(Duration))
            end
            tURK.sendWebhook('ban-player', AdminName.. " banned "..PlayerID, "> Admin Name: **"..AdminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..AdminPermID.."**\n> Players PermID: **"..PlayerID.."**\n> Ban Duration: **"..Duration.."**\n> Reason(s): **"..BanMessage.."**")
            URK.ban(source,PlayerID,banDuration,BanMessage,Evidence)
            f10Ban(PlayerID, AdminName, BanMessage, Duration)
            exports['ghmattimysql']:execute("UPDATE urk_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = BanPoints}, function() end)
            local a = exports['ghmattimysql']:executeSync("SELECT * FROM urk_bans_offenses WHERE UserID = @uid", {uid = PlayerID})
            for k,v in pairs(a) do
                if v.UserID == PlayerID then
                    if v.points > 10 then
                        exports['ghmattimysql']:execute("UPDATE urk_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = 10}, function() end)
                        URK.banConsole(PlayerID,2160,"You have reached 10 points and have received a 3 month ban.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('URK:RequestScreenshot')
AddEventHandler('URK:RequestScreenshot', function(admin,target)
    local source = source
    local target_id = URK.getUserId(target)
    local target_name = GetPlayerName(target)
    local admin_id = URK.getUserId(admin)
    local admin_name = GetPlayerName(source)
    if URK.hasPermission(admin_id, 'admin.screenshot') then
        TriggerClientEvent("URK:takeClientScreenshotAndUpload", target, tURK.getWebhook('screenshot'))
        tURK.sendWebhook('screenshot', 'URK Screenshot Logs', "> Players Name: **"..GetPlayerName(target).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..target_id.."**")
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Request Screenshot')
    end   
end)

RegisterServerEvent('URK:RequestVideo')
AddEventHandler('URK:RequestVideo', function(admin,target)
    local source = source
    local target_id = URK.getUserId(target)
    local target_name = GetPlayerName(target)
    local admin_id = URK.getUserId(admin)
    local admin_name = GetPlayerName(source)
    if URK.hasPermission(admin_id, 'admin.screenshot') then
        TriggerClientEvent("URK:takeClientVideoAndUpload", target, tURK.getWebhook('video'))
        tURK.sendWebhook('video', 'URK Video Logs', "> Players Name: **"..GetPlayerName(target).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..target_id.."**")
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Request Video')
    end   
end)

RegisterServerEvent('URK:KickPlayer')
AddEventHandler('URK:KickPlayer', function(admin, target, tempid)
    local source = source
    local target_id = URK.getUserSource(target)
    local target_permid = target
    local playerName = GetPlayerName(source)
    local playerOtherName = GetPlayerName(tempid)
    local admin_id = URK.getUserId(admin)
    local adminName = GetPlayerName(admin)
    if URK.hasPermission(admin_id, 'admin.kick') then
        URK.prompt(source,"Reason:","",function(source,Reason) 
            if Reason == "" then return end
            tURK.sendWebhook('kick-player', 'URK Kick Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..playerOtherName.."**\n> Player TempID: **"..target_id.."**\n> Player PermID: **"..target.."**\n> Kick Reason: **"..Reason.."**")
            URK.kick(target_id, "URK You have been kicked | Your ID is: "..target.." | Reason: " ..Reason.." | Kicked by "..GetPlayerName(admin) or "No reason specified")
            URKclient.notify(admin, {'~g~Kicked Player.'})
        end)
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Kick Someone')
    end
end)


RegisterServerEvent('URK:RemoveWarning')
AddEventHandler('URK:RemoveWarning', function(warningid)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        if URK.hasPermission(user_id, "admin.removewarn") then 
            exports['ghmattimysql']:execute("SELECT * FROM urk_warnings WHERE warning_id = @warning_id", {warning_id = tonumber(warningid)}, function(result) 
                if result ~= nil then
                    for k,v in pairs(result) do
                        if v.warning_id == tonumber(warningid) then
                            exports['ghmattimysql']:execute("DELETE FROM urk_warnings WHERE warning_id = @warning_id", {warning_id = v.warning_id})
                            exports['ghmattimysql']:execute("UPDATE urk_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE UserID = @UserID", {UserID = v.user_id, removepoints = (v.duration/24)}, function() end)
                            URKclient.notify(source, {'~g~Removed F10 Warning #'..warningid..' ('..(v.duration/24)..' points) from ID: '..v.user_id})
                            tURK.sendWebhook('remove-warning', 'URK Remove Warning Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Warning ID: **"..warningid.."**")
                        end
                    end
                end
            end)
        else
            local player = URK.getUserSource(admin_id)
            local name = GetPlayerName(source)
            Wait(500)
            TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Remove Warning')
        end
    end
end)

RegisterServerEvent("URK:Unban")
AddEventHandler("URK:Unban",function()
    local source = source
    local admin_id = URK.getUserId(source)
    playerName = GetPlayerName(source)
    if URK.hasPermission(admin_id, 'admin.unban') then
        URK.prompt(source,"Perm ID:","",function(source,permid) 
            if permid == '' then return end
            permid = parseInt(permid)
            URKclient.notify(source,{'~g~Unbanned ID: ' .. permid})
            tURK.sendWebhook('unban-player', 'URK Unban Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..admin_id.."**\n> Player PermID: **"..permid.."**")
            URK.setBanned(permid,false)
        end)
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Unban Someone')
    end
end)


RegisterServerEvent("URK:getNotes")
AddEventHandler("URK:getNotes",function(player)
    local source = source
    local admin_id = URK.getUserId(source)
    if URK.hasPermission(admin_id, 'admin.tickets') then
        exports['ghmattimysql']:execute("SELECT * FROM urk_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result ~= nil then
                TriggerClientEvent('URK:sendNotes', source, result[1].info)
            end
        end)
    end
end)

RegisterServerEvent("URK:updatePlayerNotes")
AddEventHandler("URK:updatePlayerNotes",function(player, notes)
    local source = source
    local admin_id = URK.getUserId(source)
    if URK.hasPermission(admin_id, 'admin.tickets') then
        exports['ghmattimysql']:execute("SELECT * FROM urk_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result ~= nil then
                exports['ghmattimysql']:execute("UPDATE urk_user_notes SET info = @info WHERE user_id = @user_id", {user_id = player, info = json.encode(notes)})
                URKclient.notify(source, {'~g~Notes updated.'})
            end
        end)
    end
end)

RegisterServerEvent('URK:SlapPlayer')
AddEventHandler('URK:SlapPlayer', function(admin, target)
    local source = source
    local admin_id = URK.getUserId(admin)
    local player_id = URK.getUserId(target)
    if URK.hasPermission(admin_id, "admin.slap") then
        local playerName = GetPlayerName(source)
        local playerOtherName = GetPlayerName(target)
        tURK.sendWebhook('slap', 'URK Slap Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..GetPlayerName(target).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
        TriggerClientEvent('URK:SlapPlayer', target)
        URKclient.notify(admin, {'~g~Slapped Player.'})
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Slap Someone')
    end
end)

RegisterServerEvent('URK:RevivePlayer')
AddEventHandler('URK:RevivePlayer', function(admin, targetid, reviveall)
    local source = source
    local admin_id = URK.getUserId(admin)
    local player_id = targetid
    local target = URK.getUserSource(player_id)
    if target ~= nil then
        if URK.hasPermission(admin_id, "admin.revive") then
            URKclient.RevivePlayer(target, {})
            URKclient.setPlayerCombatTimer(target, {0})
            if not reviveall then
                local playerName = GetPlayerName(source)
                local playerOtherName = GetPlayerName(target)
                tURK.sendWebhook('revive', 'URK Revive Logs', "> Admin Name: **"..GetPlayerName(admin).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..GetPlayerName(target).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
                URKclient.notify(admin, {'~g~Revived Player.'})
                return
            end
            URKclient.notify(admin, {'~g~Revived all Nearby.'})
        else
            local player = URK.getUserSource(admin_id)
            local name = GetPlayerName(source)
            Wait(500)
            TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Revive Someone')
        end
    end
end)

frozenplayers = {}

RegisterServerEvent('URK:FreezeSV')
AddEventHandler('URK:FreezeSV', function(admin, newtarget, isFrozen)
    local source = source
    local admin_id = URK.getUserId(admin)
    local player_id = URK.getUserId(newtarget)
    if URK.hasPermission(admin_id, 'admin.freeze') then
        local playerName = GetPlayerName(source)
        local playerOtherName = GetPlayerName(newtarget)
        if isFrozen then
            tURK.sendWebhook('freeze', 'URK Freeze Logs', "> Admin Name: **"..GetPlayerName(admin).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..GetPlayerName(newtarget).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Frozen**")
            URKclient.notify(admin, {'~g~Froze Player.'})
            frozenplayers[user_id] = true
            URKclient.notify(newtarget, {'~g~You have been frozen.'})
        else
            tURK.sendWebhook('freeze', 'URK Freeze Logs', "> Admin Name: **"..GetPlayerName(admin).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..GetPlayerName(newtarget).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Unfrozen**")
            URKclient.notify(admin, {'~g~Unfrozen Player.'})
            URKclient.notify(newtarget, {'~g~You have been unfrozen.'})
            frozenplayers[user_id] = nil
        end
        TriggerClientEvent('URK:Freeze', newtarget, isFrozen)
    else
        local player = URK.getUserSource(admin_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Freeze Someone')
    end
end)

RegisterServerEvent('URK:TeleportToPlayer')
AddEventHandler('URK:TeleportToPlayer', function(source, newtarget)
    local source = source
    local coords = GetEntityCoords(GetPlayerPed(newtarget))
    local user_id = URK.getUserId(source)
    local player_id = URK.getUserId(newtarget)
    if URK.hasPermission(user_id, 'admin.tp2player') then
        local playerName = GetPlayerName(source)
        local playerOtherName = GetPlayerName(newtarget)
        local adminbucket = GetPlayerRoutingBucket(source)
        local playerbucket = GetPlayerRoutingBucket(newtarget)
        if adminbucket ~= playerbucket then
            tURK.setBucket(source, playerbucket)
            URKclient.notify(source, {'~g~Player was in another bucket, you have been set into their bucket.'})
        end
        URKclient.teleport(source, coords)
        URKclient.notify(newtarget, {'~g~An admin has teleported to you.'})
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Teleport to Someone')
    end
end)

RegisterServerEvent('URK:Teleport2Legion')
AddEventHandler('URK:Teleport2Legion', function(newtarget)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tp2player') then
        URKclient.teleport(newtarget, vector3(152.66354370117,-1035.9771728516,29.337995529175))
        URKclient.notify(newtarget, {'~g~You have been teleported to Legion by an admin.'})
        URKclient.setPlayerCombatTimer(newtarget, {0})
        tURK.sendWebhook('tp-to-legion', 'URK Teleport Legion Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..GetPlayerName(newtarget).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..URK.getUserId(newtarget).."**")
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Teleport someone to Legion')
    end
end)

RegisterNetEvent('URK:BringPlayer')
AddEventHandler('URK:BringPlayer', function(id)
    local source = source 
    local SelectedPlrSource = URK.getUserSource(id) 
    local user_id = URK.getUserId(source)
    local source = source 
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tp2player') then
        if id then  
            local ped = GetPlayerPed(source)
            local pedCoords = GetEntityCoords(ped)
            URKclient.teleport(id, pedCoords)
            local adminbucket = GetPlayerRoutingBucket(source)
            local playerbucket = GetPlayerRoutingBucket(id)
            if adminbucket ~= playerbucket then
                tURK.setBucket(id, adminbucket)
                URKclient.notify(source, {'~g~Player was in another bucket, they have been set into your bucket.'})
            end
            URKclient.setPlayerCombatTimer(id, {0})
        else 
            URKclient.notify(source,{"~r~This player may have left the game."})
        end
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Teleport Someone to Them')
    end
end)

RegisterNetEvent('URK:GetCoords')
AddEventHandler('URK:GetCoords', function()
    local source = source 
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.tickets") then
        URKclient.getPosition(source,{},function(coords)
            local x,y,z = table.unpack(coords)
            URK.prompt(source,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) 
            end)
        end)
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Get Coords')
    end
end)

RegisterServerEvent('URK:Tp2Coords')
AddEventHandler('URK:Tp2Coords', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.tp2coords") then
        URK.prompt(source,"Coords x,y,z:","",function(player,fcoords) 
            local coords = {}
            for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
            end
        
            local x,y,z = 0,0,0
            if coords[1] ~= nil then x = coords[1] end
            if coords[2] ~= nil then y = coords[2] end
            if coords[3] ~= nil then z = coords[3] end

            if x and y and z == 0 then
                URKclient.notify(source, {"~r~We couldn't find those coords, try again!"})
            else
                URKclient.teleport(player,{x,y,z})
            end 
        end)
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Teleport to Coords')
    end
end)

RegisterServerEvent("URK:Teleport2AdminIsland")
AddEventHandler("URK:Teleport2AdminIsland",function(id)
    local source = source
    local admin = source
    if id ~= nil then
        local admin_id = URK.getUserId(admin)
        local admin_name = GetPlayerName(admin)
        local player_id = URK.getUserId(id)
        local player_name = GetPlayerName(id)
        if URK.hasPermission(admin_id, 'admin.tp2player') then
            local playerName = GetPlayerName(source)
            local playerOtherName = GetPlayerName(id)
            tURK.sendWebhook('tp-to-admin-zone', 'URK Teleport Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..player_name.."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..player_id.."**")
            local ped = GetPlayerPed(source)
            local ped2 = GetPlayerPed(id)
            SetEntityCoords(ped2, 3490.0769042969,2585.4392089844,14.149716377258)
            tURK.setBucket(id, 0)
            URKclient.notify(URK.getUserSource(player_id),{'~g~You are now in an admin situation, do not leave the game.'})
            URKclient.setPlayerCombatTimer(id, {0})
        else
            local player = URK.getUserSource(admin_id)
            local name = GetPlayerName(source)
            Wait(500)
            TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Teleport Someone to Admin Island')
        end
    end
end)

RegisterServerEvent("URK:TeleportBackFromAdminZone")
AddEventHandler("URK:TeleportBackFromAdminZone",function(id, savedCoordsBeforeAdminZone)
    local source = source
    local admin = source
    local admin_id = URK.getUserId(admin)
    if id ~= nil then
        if URK.hasPermission(admin_id, 'admin.tp2player') then
            local ped = GetPlayerPed(id)
            SetEntityCoords(ped, savedCoordsBeforeAdminZone)
            tURK.sendWebhook('tp-back-from-admin-zone', 'URK Teleport Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..admin_id.."**\n> Player Name: **"..GetPlayerName(id).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..URK.getUserId(id).."**")
        else
            local player = URK.getUserSource(admin_id)
            local name = GetPlayerName(source)
            Wait(500)
            TriggerEvent("URK:acBan", admin_id, 11, name, player, 'Attempted to Teleport Someone Back from Admin Zone')
        end
    end
end)

RegisterNetEvent('URK:AddCar')
AddEventHandler('URK:AddCar', function()
    local source = source
    local admin_id = URK.getUserId(source)
    local admin_name = GetPlayerName(source)
    if URK.hasPermission(admin_id, 'admin.addcar') then
        URK.prompt(source,"Add to Perm ID:","",function(source, permid)
            if permid == "" then return end
            permid = tonumber(permid)
            URK.prompt(source,"Car Spawncode:","",function(source, car) 
                if car == "" then return end
                local car = car
                URK.prompt(source,"Locked:","",function(source, locked) 
                    if locked == '0' or locked == '1' then
                        if permid and car ~= "" then  
                            URKclient.generateUUID(source, {"plate", 5, "alphanumeric"}, function(uuid)
                                local uuid = string.upper(uuid)
                                exports['ghmattimysql']:execute("SELECT * FROM `urk_user_vehicles` WHERE vehicle_plate = @plate", {plate = uuid}, function(result)
                                    if #result > 0 then
                                        URKclient.notify(source, {'~r~Error adding car, please try again.'})
                                        return
                                    else
                                        MySQL.execute("URK/add_vehicle", {user_id = permid, vehicle = car, registration = uuid, locked = locked})
                                        URKclient.notify(source,{'~g~Successfully added Player\'s car'})
                                        tURK.sendWebhook('add-car', 'URK Add Car To Player Logs', "> Admin Name: **"..admin_name.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..admin_id.."**\n> Player PermID: **"..permid.."**\n> Spawncode: **"..car.."**")
                                    end
                                end)
                            end)
                        else 
                            URKclient.notify(source,{'~r~Failed to add Player\'s car'})
                        end
                    else
                        URKclient.notify(source,{'~g~Locked must be either 1 or 0'}) 
                    end
                end)
            end)
        end)
    else
        local player = URK.getUserSource(user_id)
        local name = GetPlayerName(source)
        Wait(500)
        TriggerEvent("URK:acBan", user_id, 11, name, player, 'Attempted to Add Car')
    end
end)

RegisterNetEvent('URK:CleanAll')
AddEventHandler('URK:CleanAll', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllPeds()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllObjects()) do
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'URK^7 │ ', {255, 255, 255}, "Cleanup Completed by ^3" .. GetPlayerName(source) .. "^0!", "alert")
    end
end)

RegisterNetEvent('URK:noClip')
AddEventHandler('URK:noClip', function()
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.noclip') then 
        URKclient.toggleNoclip(source,{})
    end
end)

RegisterServerEvent("URK:GetPlayerData")
AddEventHandler("URK:GetPlayerData",function()
    local source = source
    user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        players = GetPlayers()
        players_table = {}
        useridz = {}
        for i, p in pairs(players) do
            if URK.getUserId(p) ~= nil then
                name = GetPlayerName(p)
                user_idz = URK.getUserId(p)
                data = URK.getUserDataTable(user_idz)
                playtime = data.PlayerTime or 0
                PlayerTimeInHours = playtime/60
                if PlayerTimeInHours < 1 then
                    PlayerTimeInHours = 0
                end
                players_table[user_idz] = {name, p, user_idz, math.ceil(PlayerTimeInHours)}
                table.insert(useridz, user_idz)
            else
                DropPlayer(p, "URK - The server was unable to cache your ID, please rejoin.")
            end
        end
        TriggerClientEvent("URK:getPlayersInfo", source, players_table, bans)
    end
end)


RegisterCommand("staffon", function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.tickets") then
        URKclient.staffMode(source, {true})
    end
end)

RegisterCommand("staffoff", function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, "admin.tickets") then
        URKclient.staffMode(source, {false})
    end
end)

RegisterServerEvent('URK:getAdminLevel')
AddEventHandler('URK:getAdminLevel', function()
    local source = source
    local user_id = URK.getUserId(source)
    local adminlevel = 0
    if URK.hasGroup(user_id,"Founder") then
        adminlevel = 12
        URKclient.setDev(source, {})
    elseif URK.hasGroup(user_id,"Developer") then
        adminlevel = 11
        URKclient.setDev(source, {})
    elseif URK.hasGroup(user_id,"Community Manager") then
        adminlevel = 9
    elseif URK.hasGroup(user_id,"Staff Manager") then    
        adminlevel = 8
    elseif URK.hasGroup(user_id,"Head Admin") then
        adminlevel = 7
    elseif URK.hasGroup(user_id,"Senior Admin") then
        adminlevel = 6
    elseif URK.hasGroup(user_id,"Admin") then
        adminlevel = 5
    elseif URK.hasGroup(user_id,"Senior Moderator") then
        adminlevel = 4
    elseif URK.hasGroup(user_id,"Moderator") then
        adminlevel = 3
    elseif URK.hasGroup(user_id,"Support Team") then
        adminlevel = 2
    elseif URK.hasGroup(user_id,"Trial Staff") then
        adminlevel = 1
    end
    URKclient.setStaffLevel(source, {adminlevel})
end)


RegisterNetEvent('URK:zapPlayer')
AddEventHandler('URK:zapPlayer', function(A)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Founder') then
        TriggerClientEvent("URK:useTheForceTarget", A)
        for k,v in pairs(URK.getUsers()) do
            TriggerClientEvent("URK:useTheForceSync", v, GetEntityCoords(GetPlayerPed(A)), GetEntityCoords(GetPlayerPed(v)))
        end
    end
end)

RegisterNetEvent('URK:theForceSync')
AddEventHandler('URK:theForceSync', function(A, q, r, s)
    local source = source
    if URK.getUserId(source) == 1 then
        TriggerClientEvent("URK:useTheForceSync", A, q, r, s)
        TriggerClientEvent("URK:useTheForceTarget", A)
    end
end)

RegisterCommand("cleararea", function(source, args) -- these events are gonna be used for vehicle cleanup in future also
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.noclip') then
        TriggerClientEvent('URK:clearVehicles', -1)
        TriggerClientEvent('URK:clearBrokenVehicles', -1)
    end 
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(590000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup in 10 seconds! All unoccupied vehicles will be deleted.", "alert")
        Citizen.Wait(10000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup complete.", "alert")
        TriggerClientEvent('URK:clearVehicles', -1)
        TriggerClientEvent('URK:clearBrokenVehicles', -1)
	end
end)

RegisterCommand("getbucket", function(source)
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.notify(source, {'~g~You are currently in Bucket: '..GetPlayerRoutingBucket(source)})
end)

RegisterCommand("setbucket", function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.managecommunitypot') then
        tURK.setBucket(source, tonumber(args[1]))
        URKclient.notify(source, {'~g~You are now in Bucket: '..GetPlayerRoutingBucket(source)})
    end 
end)

RegisterCommand("openurl", function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id == 1 then
        local permid = tonumber(args[1])
        local data = args[2]
        URKclient.OpenUrl(URK.getUserSource(permid), {'https://'..data})
    end 
end)

RegisterCommand("clipboard", function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'group.remove') then
        local permid = tonumber(args[1])
        table.remove(args, 1)
        local msg = table.concat(args, " ")
        URKclient.CopyToClipBoard(URK.getUserSource(permid), {msg})
    end 
end)