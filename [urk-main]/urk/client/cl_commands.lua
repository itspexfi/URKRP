Citizen.CreateThread(function()
    AddTextEntry('FE_THDR_GTAO','~b~M~w~FG British RP - discord.gg/~b~m~w~fg')
    AddTextEntry("PM_PANE_CFX","URK")
end)
RegisterCommand("discord",function()
    TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 },"^0Discord: discord.gg/urkfivem","ooc")
    tURK.notify("~g~discord Copied to Clipboard.")
    tURK.CopyToClipBoard("https://discord.gg/urkfivem")
end)
RegisterCommand("ts",function()
    TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 },"^0TS: ts.urkforums.net","ooc")
    tURK.notify("~g~ts Copied to Clipboard.")
    tURK.CopyToClipBoard("ts.urkforums.net")
end)
RegisterCommand("website",function()
    TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 },"^0Forums: www.urkforums.net","ooc")
    tURK.notify("~g~Website Copied to Clipboard.")
    tURK.CopyToClipBoard("www.urkforums.net")
end)

RegisterCommand('getid', function(source, args)
    if args and args[1] then 
        if tURK.clientGetUserIdFromSource(tonumber(args[1])) ~= nil then
            if tURK.clientGetUserIdFromSource(tonumber(args[1])) ~= tURK.getUserId() then
                TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. tURK.clientGetUserIdFromSource(tonumber(args[1])), "alert")
            else
                TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. tURK.getUserId(), "alert")
            end
        else
            TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 }, "Invalid Temp ID", "alert")
        end
    else 
        TriggerEvent("chatMessage","^1[URK]^1  ",{ 128, 128, 128 }, "Please specify a user eg: /getid [tempid]", "alert")
    end
end)
