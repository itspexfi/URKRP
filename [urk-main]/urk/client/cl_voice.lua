RegisterNetEvent("URK:mutePlayers",function(a)
    for b, c in pairs(a) do
        exports["pma-voice"]:mutePlayer(b, true)
    end
end)
RegisterNetEvent("URK:mutePlayer",function(b)
    exports["pma-voice"]:mutePlayer(b, true)
end)
RegisterNetEvent("URK:unmutePlayer",function(b)
    exports["pma-voice"]:mutePlayer(b, false)
end)
