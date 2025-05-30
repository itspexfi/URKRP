local a = GetGameTimer()
RegisterNetEvent("URK:spawnNitroBMX",function()
    if not tURK.isInComa() and not tURK.isHandcuffed() and not insideDiamondCasino then --and not isPlayerNearPrison() then
        if GetTimeDifference(GetGameTimer(), a) > 10000 then
            a = GetGameTimer()
            tURK.notify("~g~Crafting a BMX")
            local b = tURK.getPlayerPed()
            TaskStartScenarioInPlace(b, "WORLD_HUMAN_HAMMERING", 0, true)
            Wait(5000)
            ClearPedTasksImmediately(b)
            local c = GetEntityCoords(b)
            tURK.spawnVehicle("bmx", c.x, c.y, c.z, GetEntityHeading(b), true, true, true)
        else
            tURK.notify("~r~Nitro BMX cooldown, please wait.")
        end
    else
        tURK.notify("~r~Cannot craft a BMX right now.")
    end
end)
RegisterNetEvent("URK:spawnMoped",function()
    if not tURK.isInComa() and not tURK.isHandcuffed() and not insideDiamondCasino then --and not isPlayerNearPrison() then
        if GetTimeDifference(GetGameTimer(), a) > 10000 then
            a = GetGameTimer()
            tURK.notify("~g~Crafting a Moped")
            local b = tURK.getPlayerPed()
            TaskStartScenarioInPlace(b, "WORLD_HUMAN_HAMMERING", 0, true)
            Wait(5000)
            ClearPedTasksImmediately(b)
            local c = GetEntityCoords(b)
            tURK.spawnVehicle("faggio", c.x, c.y, c.z, GetEntityHeading(b), true, true, true)
        else
            tURK.notify("~r~Nitro BMX cooldown, please wait.")
        end
    else
        tURK.notify("~r~Cannot craft a Moped right now.")
    end
end)
