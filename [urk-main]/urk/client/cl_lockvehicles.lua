local function a()
    local b = tURK.getPlayerPed()
    if GetEntityHealth(b) > 102 then
        local c, d = tURK.getNearestOwnedVehicle(8)
        if d ~= nil then
            if c then
                tURK.vc_toggleLock(d)
                tURK.playSound("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING")
                Citizen.Wait(1000)
            else
                Citizen.Wait(1000)
            end
        else
            tURK.notify("~r~No owned vehicle found nearby to lock/unlock")
        end
    else
        tURK.notify("~r~You may not lock/unlock your vehicle whilst dead.")
    end
end
Citizen.CreateThread(function()
    while true do
        if IsDisabledControlPressed(0, 82) then
            a()
        end
        Wait(0)
    end
end)
AddEventHandler("URK:lockNearestVehicle",function()
    a()
end)
