function func_recoilHandler(a)
    if IsPedArmed(a.playerPed, 6) then
        DisableControlAction(1, 140, true)
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)
    end
    DisplayAmmoThisFrame(false)
end
tURK.createThreadOnTick(func_recoilHandler)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if IsPedShooting(tURK.getPlayerPed()) then
            if GetVehiclePedIsIn(tURK.getPlayerPed(), false) == 0 then
                local b, c = GetCurrentPedWeapon(tURK.getPlayerPed())
                b, cAmmo = GetAmmoInClip(tURK.getPlayerPed(), c)
                tv = 0
                repeat
                    Wait(0)
                    p = GetGameplayCamRelativePitch()
                    if GetFollowPedCamViewMode() ~= 4 then
                        SetGameplayCamRelativePitch(p + 0.1, 0.2)
                    end
                    tv = tv + 0.1
                until tv >= 0.15
            end
        end
    end
end)
