local a = {
    serialNumber = tostring("X" .. math.random(21202574, 49202574)),
    batteryStatus = tostring(math.random(95, 99)),
    cartridges = 2,
    reactivate1 = {active = false, ped = 0, serverId = 0},
    reactivate2 = {active = false, ped = 0, serverId = 0},
    hash = "WEAPON_STUNGUN"
}
local b = true
local c = false
local d = nil
TriggerEvent("chat:addSuggestion", "/rt", "Reload your Taser")
RegisterNetEvent("URK:receiveBarbs",function(e)
    c = true
    d = e
end)
RegisterNetEvent("URK:receiveActivation",function()
    if not tURK.isStaffedOn() then
        displayTaserNotification("You are currently being ~b~activated~w~.")
        SetPedToRagdoll(tURK.getPlayerPed(), 5000, 5000, 0, 0, 0, 0)
    end
end)
RegisterNetEvent("URK:arcSuccessful",function()
    if a.cartridges == 2 then
        displayTaserNotification("~r~MODE: ~w~ARC\n\n~y~|25|     |25|\n\n")
    elseif a.cartridges == 1 then
        displayTaserNotification("~r~MODE: ~w~ARC\n\n~y~|25|         \n\n")
    else
        displayTaserNotification("~r~MODE: ~w~ARC\n\n~y~             \n\n")
    end
    TriggerServerEvent("URK:playTaserSound", GetEntityCoords(tURK.getPlayerPed()), "arcsound")
    b = false
    SetTimeout(4000,function()
        b = true
    end)
end)
RegisterNetEvent("playTaserSoundClient",function(f, g)
    local h = GetEntityCoords(tURK.getPlayerPed(), true)
    local i = #(h - f)
    if i <= 15 then
        SendNUIMessage({transactionType = g})
    end
end)
RegisterNetEvent("URK:barbsNoLonger",function()
    c = false
    d = 0
    displayTaserNotification("Your taser ~b~barbs ~w~have been ~b~disconnected~w~.")
end)
RegisterNetEvent("URK:barbsRippedOut",function(e)
    if a.reactivate1.serverId == e then
        a.reactivate1 = {active = false, ped = 0, serverId = 0}
        drawNativeNotification("Barbs Ripped Out - ~b~Cartridge 1")
    elseif a.reactivate2.serverId == e then
        a.reactivate2 = {active = false, ped = 0, serverId = 0}
        drawNativeNotification("Barbs Ripped Out - ~b~Cartridge 2")
    end
end)
RegisterNetEvent("URK:reloadTaser",function(j)
    if GetSelectedPedWeapon(tURK.getPlayerPed()) == GetHashKey(a.hash) then
        MakePedReload(tURK.getPlayerPed())
        if a.cartridges == 0 then
            a.cartridges = 2
            if a.reactivate1.active then
                TriggerServerEvent("URK:barbsNoLongerServer", a.reactivate1.serverId)
            end
            if a.reactivate2.active then
                TriggerServerEvent("URK:barbsNoLongerServer", a.reactivate2.serverId)
            end
            a.reactivate1 = {active = false, ped = 0, serverId = 0}
            a.reactivate2 = {active = false, ped = 0, serverId = 0}
            drawNativeNotification("Taser reload successful")
            displayTaserNotification("~r~MODE: ~w~MANUAL\n\n~y~|25|     |25|\n\n")
        elseif a.cartridges == 1 then
            a.cartridges = 2
            a.reactivate1 = {active = false, ped = 0, serverId = 0}
            drawNativeNotification("Taser reload successful")
            displayTaserNotification("~r~MODE: ~w~ARC\n\n~y~|25|     |25|\n\n")
        end
    else
        displayTaserNotification("~r~Error! ~w~You are not holding a taser.")
    end
end)
function func_taserHandler(k)
    if k.vehicle == 0 or k.vehicle == nil then
        if a.reactivate1.active then
            local f = GetEntityCoords(a.reactivate1.ped)
            if #(f - k.playerCoords) > 30.0 then
                TriggerServerEvent("URK:barbsNoLongerServer", a.reactivate1.serverId)
                a.reactivate1 = {active = false, ped = 0, serverId = 0}
                drawNativeNotification("Barbs Disconnected - ~b~Cartridge 1")
            end
        elseif a.reactivate2.active then
            local f = GetEntityCoords(a.reactivate2.ped)
            if #(f - k.playerCoords) > 30.0 then
                TriggerServerEvent("URK:barbsNoLongerServer", a.reactivate2.serverId)
                a.reactivate2 = {active = false, ped = 0, serverId = 0}
                drawNativeNotification("Barbs Disconnected - ~b~Cartridge 2")
            end
        end
        if k.weapon == GetHashKey(a.hash) then
            if IsControlJustPressed(1, 308) then
                if a.reactivate1.active == true then
                    drawNativeNotification("Reactivated cartridge: ~INPUT_SELECT_WEAPON_UNARMED~")
                    TriggerServerEvent("URK:playTaserSound", k.playerCoords, "reactivate")
                    TriggerServerEvent("URK:reactivatePed", a.reactivate1.serverId)
                end
            elseif IsControlJustPressed(1, 307) then
                if a.reactivate2.active == true then
                    drawNativeNotification("Reactivated cartridge: 	~INPUT_SELECT_WEAPON_MELEE~")
                    TriggerServerEvent("URK:playTaserSound", k.playerCoords, "reactivate")
                    TriggerServerEvent("URK:reactivatePed", a.reactivate2.serverId)
                end
            elseif IsControlJustPressed(1, 121) and b then
                TriggerServerEvent("URK:arcTaser")
            end
            if a.cartridges < 1 then
                SetPlayerCanDoDriveBy(k.playerPed, false)
                DisablePlayerFiring(k.playerPed, true)
            else
                if IsPedShooting(k.playerPed) then
                    TriggerServerEvent("URK:playTaserSound", k.playerCoords, "taser")
                    a.cartridges = a.cartridges - 1
                    local l, m = GetEntityPlayerIsFreeAimingAt(k.playerId)
                    if l and IsEntityAPed(k.playerPed) then
                        local n = tURK.getPedServerId(m)
                        TriggerServerEvent("URK:receiveBarbsServer", n)
                        if n ~= nil then
                            if a.cartridges == 1 then
                                drawNativeNotification("Press ~INPUT_REPLAY_BACK~ to Reactivate")
                                displayTaserNotification("~r~MODE: ~w~MANUAL\n\n~y~|25|         \n\n")
                                if not a.reactivate1.active then
                                    a.reactivate1.active = true
                                    a.reactivate1.ped = m
                                    a.reactivate1.serverId = n
                                end
                            else
                                drawNativeNotification("Press ~INPUT_REPLAY_ADVANCE~ to Reactivate")
                                displayTaserNotification("~r~MODE: ~w~MANUAL\n\nReload Required")
                                if not a.reactivate2.active then
                                    a.reactivate2.active = true
                                    a.reactivate2.ped = m
                                    a.reactivate2.serverId = n
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
tURK.createThreadOnTick(func_taserHandler)
function displayTaserNotification(o)
    RequestStreamedTextureDict("CHAR_ANDREAS", true)
    while not HasStreamedTextureDictLoaded("CHAR_ANDREAS") do
        Wait(0)
    end
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(o)
    EndTextCommandThefeedPostMessagetext("CHAR_ANDREAS", "CHAR_ANDREAS", false, 1, "Taser X2", "CID")
    EndTextCommandThefeedPostTicker(false, false)
end
Citizen.CreateThread(function()
    SetPedMinGroundTimeForStungun(tURK.getPlayerPed(), 15000)
    while true do
        if IsPedBeingStunned(tURK.getPlayerPed()) then
            stunGun()
        end
        Wait(100)
    end
end)
local p = false
function stunGun()
    local q = tURK.getPlayerPed()
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Citizen.Wait(0)
    end
    SetPedMovementClipset(q, "move_m@drunk@verydrunk", true)
    RemoveAnimSet("move_m@drunk@verydrunk")
    SetTimecycleModifier("spectator5")
    SetPedIsDrunk(q, true)
    local r = GetGameTimer()
    while GetGameTimer() - r < 15000 and not p do
        Citizen.Wait()
    end
    SetPedMotionBlur(q, true)
    Citizen.CreateThread(function()
        if c then
            while c do
                DisableControlAction(0, 140, true)
                if IsControlJustPressed(1, 38) then
                    c = false
                    if d and d > 0 then
                        TriggerServerEvent("URK:barbsRippedOutServer", d)
                    end
                    d = 0
                    displayTaserNotification("Your ~b~barbs ~w~have now been ~b~ripped out~w~.")
                end
                Wait(0)
            end
        end
    end)
    local s = GetGameTimer()
    while GetGameTimer() - s < 60000 and not p do
        Citizen.Wait()
    end
    ClearTimecycleModifier()
    ResetScenarioTypesEnabled()
    ResetPedMovementClipset(q, 0)
    SetPedIsDrunk(q, false)
    SetPedMotionBlur(q, false)
    p = false
end
function tURK.setStunExitsEarly()
    p = true
end
