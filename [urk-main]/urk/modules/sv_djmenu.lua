local c = {}
RegisterCommand("djmenu", function(source, args, rawCommand)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id,"DJ") then
        TriggerClientEvent('URK:toggleDjMenu', source)
    end
end)
RegisterCommand("djadmin", function(source, args, rawCommand)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id,"admin.noclip") then
        TriggerClientEvent('URK:toggleDjAdminMenu', source, c)
    end
end)
RegisterCommand("play",function(source,args,rawCommand)
    local source = source
    local user_id = URK.getUserId(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local name = GetPlayerName(source)
    if URK.hasGroup(user_id,"DJ") then
        if #args > 0 then
            TriggerClientEvent('URK:finaliseSong', source,args[1])
        end
    end
end)
RegisterServerEvent("URK:adminStopSong")
AddEventHandler("URK:adminStopSong", function(PARAM)
    local source = source
    for k,v in pairs(c) do
        if v[1] == PARAM then
            TriggerClientEvent('URK:stopSong', -1,v[2])
            c[tostring(k)] = nil
            TriggerClientEvent('URK:toggleDjAdminMenu', source, c)
        end
    end
end)
RegisterServerEvent("URK:playDjSongServer")
AddEventHandler("URK:playDjSongServer", function(PARAM,coords)
    local source = source
    local user_id = URK.getUserId(source)
    local name = GetPlayerName(source)
    c[tostring(source)] = {PARAM,coords,user_id,name,"true"}
    TriggerClientEvent('URK:playDjSong', -1,PARAM,coords,user_id,name)
end)
RegisterServerEvent("URK:skipServer")
AddEventHandler("URK:skipServer", function(coords,param)
    local source = source
    TriggerClientEvent('URK:skipDj', -1,coords,param)
end)
RegisterServerEvent("URK:stopSongServer")
AddEventHandler("URK:stopSongServer", function(coords)
    local source = source
    c[tostring(source)] = nil
    TriggerClientEvent('URK:stopSong', -1,coords)
end)
RegisterServerEvent("URK:updateVolumeServer")
AddEventHandler("URK:updateVolumeServer", function(coords,volume)
    local source = source
    TriggerClientEvent('URK:updateDjVolume', -1,coords,volume)
end)


RegisterServerEvent("URK:requestCurrentProgressServer") -- doing this will fix the issue of the song not playing when you leave and re enter the area
AddEventHandler("URK:requestCurrentProgressServer", function(a,b)
    TriggerClientEvent('URK:requestCurrentProgress', -1, a, b)
end)

RegisterServerEvent("URK:returnProgressServer") -- doing this will fix the issue of the song not playing when you leave and re enter the area
AddEventHandler("URK:returnProgressServer", function(x,y,z)
    for k,v in pairs(c) do
        if tonumber(k) == URK.getUserSource(x) then
            TriggerClientEvent('URK:returnProgress', -1, x, y, z, v[1])
        end
    end
end)
