spawning = true
local a = {}
local b = false
local c = 0
local d = 300
local e = false
local f = 100
local g = false
local h
local i = GetGameTimer()
local j = 0
local k = 102
local l = 0
WeaponNames = {}
local m = module("URKFirearms", "cfg/weapons")
local n = module("cfg/cfg_respawn")
local o = {}
local p = {}
Citizen.CreateThread(
    function()
        p = m.nativeWeaponModelsToNames
        for q, r in pairs(m.weapons) do
            p[q] = r.name
        end
        for q, s in pairs(p) do
            WeaponNames[GetHashKey(q)] = s
            o[GetHashKey(q)] = q
        end
        local t = module("cfg/cfg_housing")
        for u, v in pairs(t.homes) do
            n.spawnLocations[u] = {
                name = u,
                coords = vector3(v.entry_point[1], v.entry_point[2], v.entry_point[3]),
                permission = {},
                image = v.image or "https://cdn.cmg.city/content/fivem/houses/citysmallhome.png",
                price = 5000
            }
        end
    end
)
local w = -1
RegisterNetEvent(
    "URK:setNHSCallerId",
    function(x)
        w = x
    end
)
AddEventHandler(
    "URK:countdownEnded",
    function()
        e = true
    end
)
Citizen.CreateThread(
    function()
        while true do
            if IsDisabledControlJustPressed(0, 38) then
                if b and not g then
                    local y = GetEntityCoords(GetPlayerPed(-1))
                    if not tURK.isPlayerInRedZone() and not tURK.isPlayerInTurf() then
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                        tURK.notify("~g~NHS have been notified.")
                        TriggerServerEvent("URK:NHSComaCall")
                        TriggerEvent("URK:DEATH_SCREEN_NHS_CALLED")
                    end
                    g = true
                elseif e and b then
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    TriggerEvent("URK:CLOSE_DEATH_SCREEN")
                    tURK.respawnPlayer()
                    g = false
                    if w ~= -1 then
                        TriggerServerEvent("URK:endNHSCall", w)
                    end
                    TriggerEvent("URK:respawnKeyPressed")
                    TriggerServerEvent("URK:SendSpawnMenu")
                end
                Wait(1000)
            end
            Wait(0)
        end
    end
)
local function z()
    local A = tURK.getPlayerCoords()
    for B, C in pairs(GetGamePool("CPed")) do
        if IsEntityDead(C) and not IsPedAPlayer(C) and #(GetEntityCoords(C, true) - A) < 25.0 then
            local D = GetEntityModel(C)
            if D == "mp_m_freemode_01" or D == "mp_f_freemode_01" then
                DeleteEntity(C)
            end
        end
    end
end
Citizen.CreateThread(
    function()
        Wait(500)
        SetPlayerControl(PlayerId(), true, false)
        while true do
            Wait(0)
            local C = GetPlayerPed(-1)
            if not DoesEntityExist(C) then
                Wait(1000)
                goto continue
            end
            
            local E = GetEntityHealth(C)
            if IsEntityDead(C) and not b then
                pbCounter = 100
                local F = GetEntityCoords(C, true)
                if currentBackpack then
                    TriggerEvent("URK:removeBackpack")
                end
                if not tURK.isPurge() then
                    TriggerServerEvent("URK:forceStoreWeapons")
                end
                tURK.ejectVehicle()
                b = true
                h = F
                TriggerServerEvent("URK:getNumOfNHSOnline")
                tURK.setArmour(0)
                tURK.updateHealth(true)
                Wait(250)
            end
            
            if f <= 0 and b then
                f = 100
                local G = GetEntityHealth(C)
                if G <= 100 then
                    local H = tURK.getPosition()
                    tURK.setHealth(102)
                    SetEntityInvincible(C, true)
                    a = getRandomComaAnimation()
                    if a and a.dict then
                        tURK.loadAnimDict(a.dict)
                        TaskPlayAnim(C, a.dict, a.anim, 3.0, 1.0, -1, 1, 0, 0, 0, 0)
                        RemoveAnimDict(a.dict)
                    end
                    z()
                end
            end
            
            if E > k and b then
                if IsEntityDead(C) then
                    local H = tURK.getPosition()
                    tURK.setHealth(200)
                    NetworkResurrectLocalPlayer(H.x, H.y, H.z, GetEntityHeading(C), true, true)
                    Wait(0)
                end
                TriggerEvent("URK:CLOSE_DEATH_SCREEN")
                c = 0
                pbCounter = 100
                e = false
                tURK.disableComa()
                f = 100
                SetEntityInvincible(C, false)
                ClearPedSecondaryTask(C)
                Citizen.CreateThread(
                    function()
                        Wait(500)
                        ClearPedSecondaryTask(C)
                        ClearPedTasks(C)
                    end
                )
            end
            
            if E <= k and not b then
                tURK.setHealth(0)
            end
            
            ::continue::
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if b then
                local I = PlayerPedId()
                if not DoesEntityExist(I) then
                    Wait(1000)
                    goto continue
                end
                
                if not IsEntityDead(I) then
                    if a and a.dict then
                        if not IsEntityPlayingAnim(I, a.dict, a.anim, 3) and not tURK.isUsingStretcher() then
                            tURK.loadAnimDict(a.dict)
                            TaskPlayAnim(I, a.dict, a.anim, 3.0, 1.0, -1, 1, 0, 0, 0, 0)
                            RemoveAnimDict(a.dict)
                        end
                    end
                end
                
                if GetEntityHealth(I) > k then
                    tURK.disableComa()
                    if IsEntityDead(I) then
                        local H = tURK.getPosition()
                        tURK.setHealth(200)
                        NetworkResurrectLocalPlayer(H.x, H.y, H.z, GetEntityHeading(I), true, true)
                        Wait(0)
                    end
                    c = 0
                    pbCounter = 100
                    tURK.disableComa()
                    f = 100
                    SetEntityInvincible(I, false)
                    ClearPedSecondaryTask(I)
                end
            end
            Wait(0)
            ::continue::
        end
    end
)
function tURK.RevivePlayer()
    local C = GetPlayerPed(-1)
    if IsEntityDead(C) then
        local H = tURK.getPosition()
        local I = PlayerPedId()
        tURK.setHealth(200)
        NetworkResurrectLocalPlayer(H.x, H.y, H.z, GetEntityHeading(GetPlayerPed(-1)), true, true)
        DeleteEntity(I)
        Citizen.Wait(0)
    end
    local K = PlayerId()
    SetPlayerControl(K, true, false)
    if not IsEntityVisible(C) then
        SetEntityVisible(C, true)
    end
    if not IsPedInAnyVehicle(C) then
        SetEntityCollision(C, true)
    end
    FreezeEntityPosition(C, false)
    SetPlayerInvincible(K, false)
    tURK.setHealth(200)
    tURK.disableComa()
    f = 100
    local C = GetPlayerPed(-1)
    SetEntityInvincible(C, false)
    ClearPedSecondaryTask(GetPlayerPed(-1))
    Citizen.CreateThread(
        function()
            Wait(500)
            ClearPedSecondaryTask(GetPlayerPed(-1))
            ClearPedTasks(GetPlayerPed(-1))
        end
    )
    TriggerEvent("URK:CLOSE_DEATH_SCREEN")
    if w ~= -1 then
        TriggerServerEvent("URK:endNHSCall", w)
    end
end
RegisterNetEvent(
    "URK:getNumberOfDocsOnline",
    function(L)
        if not tURK.isPurge() then
            if tURK.isPlayerInRedZone() or tURK.isPlayerInTurf() then
                bleedoutDuration = 50000
            elseif L >= 3 and L <= 5 and not globalNHSOnDuty then
                bleedoutDuration = 170000
            elseif L >= 3 and not globalNHSOnDuty then
                bleedoutDuration = 290000
            else
                bleedoutDuration = 50000
            end
            c = bleedoutDuration + 10000
        else
            c = 3000
        end
        d = c / 1000
        f = 10
        i = GetGameTimer()
        j = c
        local M = false
        if not tURK.isPurge() then
            if GetVehiclePedIsIn(PlayerPedId(), false) ~= 0 then
                M = true
            else
                TriggerEvent("URK:IsInMoneyComa", true)
                ExecuteCommand("storeallweapons")
                if not tURK.globalOnPoliceDuty() then
                    TriggerServerEvent("URK:InComa")
                end
                URKserver.MoneyDrop()
            end
        end
        CreateThread(
            function()
                local N = GetGameTimer()
                while tURK.getKillerInfo().ready == nil do
                    Wait(0)
                end
                local O = tURK.getKillerInfo()
                local P = false
                if O.name == nil then
                    P = true
                end
                e = false
                TriggerEvent("URK:SHOW_DEATH_SCREEN", d, O.name or "N/A", O.user_id or "N/A", O.weapon or "N/A", P)
            end
        )
        if not tURK.isPurge() then
            while f <= 10 and f >= 0 do
                Wait(1000)
                f = f - 1
            end
            if M then
                TriggerEvent("URK:IsInMoneyComa", true)
                ExecuteCommand("storeallweapons")
                if not tURK.globalOnPoliceDuty() then
                    TriggerServerEvent("URK:InComa")
                end
                URKserver.MoneyDrop()
            end
        end
    end
)
local Q = 0
RegisterNetEvent(
    "URK:OpenSpawnMenu",
    function(R)
        DoScreenFadeIn(1000)
        TriggerScreenblurFadeIn(100.0)
        ExecuteCommand("hideui")
        SetPlayerControl(PlayerId(), false, 0)
        local I = PlayerPedId()
        local S = tURK.getPlayerCoords()
        FreezeEntityPosition(I, true)
        SetEntityCoordsNoOffset(I, S.x, S.y, -100.0, false, false, false)
        TriggerEvent("URK:removeBackpack")
        Q =
            CreateCameraWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            675.57568359375,
            1107.1724853516,
            375.29666137695,
            0.0,
            0.0,
            0.0,
            65.0,
            0,
            2
        )
        SetCamActive(Q, true)
        RenderScriptCams(true, true, 0, true, false)
        SetCamParams(Q, -1024.6506347656, -2712.0234375, 79.889106750488, 0.0, 0.0, 0.0, 65.0, 250000, 0, 0, 2)
        local T = {}
        for B, u in pairs(R) do
            if n.spawnLocations[u] then
                table.insert(T, n.spawnLocations[u])
            end
        end
        TriggerEvent("URKDEATHUI:openSpawnMenu", T)
    end
)
AddEventHandler(
    "URK:respawnButtonClicked",
    function(U, V)
        if V and V > 0 then
            TriggerServerEvent("URK:takeAmount", V)
        end
        local W = n.spawnLocations[U].coords
        TriggerEvent("URK:playGTAIntro")
        allowedWeapons = {}
        if tURK.isHandcuffed() then
            TriggerEvent("URK:toggleHandcuffs", false)
        end
        SetEntityCoords(PlayerPedId(), W)
        SetEntityVisible(PlayerPedId(), true, 0)
        SetPlayerControl(PlayerId(), true, 0)
        SetFocusPosAndVel(W.x, W.y, W.z + 1000)
        DestroyCam(Q)
        local X = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", W.x, W.y, W.z + 1000.0, 0.0, 0.0, 0.0, 65.0, 0, 2)
        SetCamActive(X, true)
        RenderScriptCams(true, true, 0, true, false)
        SetCamParams(X, W.x, W.y, W.z, 0.0, 0.0, 0.0, 65.0, 5000, 0, 0, 2)
        Wait(2500)
        ClearFocus()
        Wait(2000)
        FreezeEntityPosition(PlayerPedId(), false)
        DestroyCam(X)
        RenderScriptCams(false, true, 2000, false, false)
        TriggerScreenblurFadeOut(2000.0)
        ExecuteCommand("showui")
        ClearFocus()
    end
)
function tURK.respawnPlayer()
    DoScreenFadeOut(1000)
    c = 0
    pbCounter = 100
    e = false
    SetEntityInvincible(PlayerPedId(), false)
    Wait(1000)
    local I = PlayerPedId()
    local y = GetEntityCoords(I)
    SetEntityCoordsNoOffset(I, y.x, y.y, y.z, false, false, false)
    tURK.setHealth(200)
    NetworkResurrectLocalPlayer(y.x, y.y, y.z, 0.0, true, true)
    DeleteEntity(I)
    ClearPedTasksImmediately(I)
    RemoveAllPedWeapons(I)
    TriggerServerEvent("URK:playerRespawned")
    MumbleSetActive(true)
    if GetConvar("voice_externalAddress", "") ~= "" and GetConvarInt("voice_externalPort", 0) ~= 0 then
        MumbleSetServerAddress(GetConvar("voice_externalAddress", ""), GetConvarInt("voice_externalPort", 0))
        while not MumbleIsConnected() do
            Wait(250)
        end
    end
end
function tURK.disableComa()
    b = false
    g = false
end
function tURK.isInComa()
    return b
end
local Y = false
function tURK.isTazed(Z)
    return Y or IsPedBeingStunned(PlayerPedId(), 0) or tURK.isPedBeingTackled() or
        isInGreenzone and not globalOnPoliceDuty and not Z
end
function tURK.isTazedByRevive()
    return Y
end
RegisterNetEvent(
    "TriggerTazer",
    function()
        Y = true
        tURK.setCanAnim(false)
        local I = PlayerPedId()
        tURK.loadClipSet("move_m@drunk@verydrunk")
        SetPedMinGroundTimeForStungun(I, 15000)
        SetPedMovementClipset(I, "move_m@drunk@verydrunk", 1.0)
        RemoveClipSet("move_m@drunk@verydrunk")
        SetTimecycleModifier("spectator5")
        SetPedIsDrunk(I, true)
        Wait(15000)
        Y = false
        tURK.setCanAnim(true)
        SetPedMotionBlur(I, true)
        Wait(60000)
        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(I, 0)
        SetPedIsDrunk(I, false)
        SetPedMotionBlur(I, false)
    end
)
function getRandomComaAnimation()
    local _ = {
        {"combat@damage@writheidle_a", "writhe_idle_a"},
        {"combat@damage@writheidle_a", "writhe_idle_b"},
        {"combat@damage@writheidle_a", "writhe_idle_c"},
        {"combat@damage@writheidle_b", "writhe_idle_d"},
        {"combat@damage@writheidle_b", "writhe_idle_e"},
        {"combat@damage@writheidle_b", "writhe_idle_f"},
        {"combat@damage@writheidle_c", "writhe_idle_g"},
        {"combat@damage@rb_writhe", "rb_writhe_loop"},
        {"combat@damage@writhe", "writhe_loop"}
    }
    local a0 = {}
    local a1, a2 = table.unpack(_[math.random(1, #_)])
    a0["dict"] = a1
    a0["anim"] = a2
    return a0
end
local O = {}
function tURK.getKillerInfo()
    return O
end
Citizen.CreateThread(
    function()
        Wait(10000)
        local a3, a4, a5, a6, q
        while true do
            Citizen.Wait(0)
            if IsEntityDead(PlayerPedId()) and not tURK.isPedScriptGuidChanging() then
                Citizen.Wait(500)
                local a7 = GetPedSourceOfDeath(PlayerPedId())
                a5 = GetPedCauseOfDeath(PlayerPedId())
                a6 = WeaponNames[a5]
                q = o[a5]
                if IsEntityAPed(a7) and IsPedAPlayer(a7) then
                    a4 = NetworkGetPlayerIndexFromPed(a7)
                elseif
                    IsEntityAVehicle(a7) and IsEntityAPed(GetPedInVehicleSeat(a7, -1)) and
                        IsPedAPlayer(GetPedInVehicleSeat(a7, -1))
                 then
                    a4 = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(a7, -1))
                end
                local a8 = tURK.getPedServerId(a7)
                if inOrganHeist then
                    TriggerServerEvent("URK:diedInOrganHeist", a8)
                    tURK.setDeathInOrganHeist()
                end
                local a9 = false
                local aa = 0
                if a4 == PlayerId() or a4 == nil then
                    a9 = true
                else
                    local ab = tURK.getPlayerName(a4)
                    O.name = ab
                    aa = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(a7))
                end
                O.source = a8
                O.user_id = tURK.getUserId(a8)
                O.weapon = tostring(a6)
                O.ready = true
                if GetGameTimer() < i + 10000 then
                    local a8 = tURK.getPedServerId(a7)
                    TriggerServerEvent("URK:onPlayerKilled", "killed", a8, a6, a9, aa)
                    l = 0
                elseif GetGameTimer() < i + j then
                    local a8 = tURK.getPedServerId(a7)
                    j = 0
                    TriggerServerEvent("URK:onPlayerKilled", "finished off", a8, a6)
                    l = 0
                end
                a4 = nil
                a3 = nil
                a5 = nil
                a6 = nil
            end
            while IsEntityDead(PlayerPedId()) do
                Citizen.Wait(0)
            end
            O = {}
        end
    end
)
function tURK.varyHealth(ac)
    local C = PlayerPedId()
    local ad = math.floor(GetEntityHealth(C) + ac)
    tURK.setHealth(ad)
end
function tURK.setFriendlyFire(ae)
    NetworkSetFriendlyFireOption(ae)
    SetCanAttackFriendly(GetPlayerPed(-1), ae, ae)
end
AddEventHandler(
    "URK:onClientSpawn",
    function(af, ag)
        if ag then
            local K = PlayerId()
            SetPoliceIgnorePlayer(K, true)
            SetDispatchCopsForPlayer(K, false)
            tURK.setFriendlyFire(true)
        end
    end
)

-- Add this new function to handle death state cleanup
function tURK.cleanupDeathState()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        SetEntityInvincible(ped, false)
        ClearPedSecondaryTask(ped)
        ClearPedTasks(ped)
        tURK.setHealth(200)
        b = false
        g = false
        f = 100
        c = 0
        pbCounter = 100
        e = false
    end
end

-- Add event handler for resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    tURK.cleanupDeathState()
end)
