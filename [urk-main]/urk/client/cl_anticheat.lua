DecorRegister("URKACVeh", 3)
local function a(b, ...)
    for c, d in pairs(GetGamePool("CVehicle")) do
        b(d, ...)
        Wait(0)
    end
end
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(500)
            a(
                function(d)
                    if DecorGetInt(d, "URKACVeh") ~= 955 then
                        if NetworkHasControlOfEntity(d) then
                            local e = GetEntityModel(d)
                            if not IsThisModelATrain(e) then
                                DeleteEntity(d)
                            end
                        end
                    end
                end
            )
        end
    end
)
local f = false
Citizen.CreateThread(
    function()
        Wait(15000)
        while true do
            local g = tURK.getPlayerPed()
            local h = tURK.getPlayerId()
            local i = tURK.getPlayerVehicle()
            if i == 0 then
                SetWeaponDamageModifier(GetHashKey("WEAPON_RUN_OVER_BY_CAR"), 0.0)
                SetWeaponDamageModifier(GetHashKey("WEAPON_RAMMED_BY_CAR"), 0.0)
                SetWeaponDamageModifier(GetHashKey("VEHICLE_WEAPON_ROTORS"), 0.0)
                SetWeaponDamageModifier(GetHashKey("WEAPON_UNARMED"), 0.5)
                SetWeaponDamageModifier(GetHashKey("WEAPON_SNOWBALL"), 0.0)
                local j = GetSelectedPedWeapon(g)
                if j == GetHashKey("WEAPON_SNOWBALL") then
                    SetPlayerWeaponDamageModifier(h, 0.0)
                else
                    SetPlayerWeaponDamageModifier(h, 1.0)
                    SetWeaponDamageModifier(j, 1.0)
                end
                if not f and GetUsingseethrough() and not tURK.isPlayerInPoliceHeli() and not tURK.isPlayerInDrone() then
                    TriggerServerEvent("URK:acType13")
                    f = true
                end
            end
            SetPedInfiniteAmmoClip(g, false)
            for c, k in pairs(tURK.getWeapons()) do
                SetPedInfiniteAmmo(g, false, k.hash)
            end
            SetEntityInvincible(i, false)
            ToggleUsePickupsForPlayer(h, "PICKUP_HEALTH_SNACK", false)
            ToggleUsePickupsForPlayer(h, "PICKUP_HEALTH_STANDARD", false)
            ToggleUsePickupsForPlayer(h, "PICKUP_WEAPON_PISTOL", false)
            ToggleUsePickupsForPlayer(h, "PICKUP_AMMO_BULLET_MP", false)
            Citizen.InvokeNative(0xdef665962974b74c, 2047, false)
            SetLocalPlayerCanCollectPortablePickups(false)
            SetPlayerHealthRechargeMultiplier(h, 0.0)
            Wait(0)
        end
    end
)
local l = false
local m = false
AddEventHandler(
    "esx:getSharedObject",
    function(n)
        if l == true then
            CancelEvent()
            n(nil)
            return
        end
        TriggerServerEvent("URK:acType4")
        l = true
        n(nil)
    end
)
local o = {
    "ambulancier:selfRespawn",
    "bank:transfer",
    "esx_ambulancejob:revive",
    "esx-qalle-jail:openJailMenu",
    "esx_jailer:wysylandoo",
    "esx_society:openBossMenu",
    "esx:spawnVehicle",
    "esx_status:set",
    "HCheat:TempDisableDetection",
    "UnJP",
    "bank:transfer",
    "esx_skin:openSaveableMenu",
    "esx_society:openBossMenu",
    "esx_status:set",
    "esx_ambulancejob:revive",
    "ambulancier:selfRespawn",
    "esx-qalle-jail:openJailMenu",
    "UnJP",
    "esx_inventoryhud:openPlayerInventory",
    "HCheat:TempDisableDetection",
    "esx_policejob:handcuff",
    "esx:getSharedObject",
    "esx:teleport",
    "esx_spectate:spectate"
}
for p, q in ipairs(o) do
    AddEventHandler(
        q,
        function()
            if m == true then
                CancelEvent()
                return
            end
            TriggerServerEvent("URK:acType4")
            m = true
        end
    )
end
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)
            local h = PlayerId()
            local i = GetVehiclePedIsIn(PlayerPedId(), false)
            local r = GetPlayerWeaponDamageModifier(h)
            local s = GetPlayerWeaponDefenseModifier(h)
            local t = GetPlayerWeaponDefenseModifier_2(h)
            local u = GetPlayerVehicleDamageModifier(h)
            local v = GetPlayerVehicleDefenseModifier(h)
            local w = GetPlayerMeleeWeaponDefenseModifier(h)
            if i ~= 0 then
                local x = GetVehicleTopSpeedModifier(i)
                if x > 1.0 then
                    return
                end
            end
            local y = GetWeaponDamageModifier(GetCurrentPedWeapon(h, 0, false))
            local z = GetPlayerMeleeWeaponDamageModifier(PlayerId())
            if r > 1.0 then
                TriggerServerEvent("URK:acType8", "PlayerWeaponDamageModifier", r)
                return
            end
            if s > 1.0 then
                TriggerServerEvent("URK:acType8", "PlayerWeaponDefenseModifier", s)
                return
            end
            if t > 1.0 then
                TriggerServerEvent("URK:acType8", "PlayerWeaponDefenseModifier_2", t)
                return
            end
            if u > 1.0 then
                TriggerServerEvent("URK:acType8", "PlayerVehicleDamageModifier", u)
                return
            end
            if v > 1.0 then
                TriggerServerEvent("URK:acType8", "PlayerVehicleDefenseModifier", v)
                return
            end
            if y > 1.0 then
                TriggerServerEvent("URK:acType8", "GetWeaponDamageModifier", y)
                return
            end
            if z > 1.0 then
                TriggerServerEvent("URK:acType8", "GetPlayerMeleeWeaponDamageModifier", z)
                return
            end
            RemoveAllPickupsOfType("PICKUP_HEALTH_SNACK")
            RemoveAllPickupsOfType("PICKUP_HEALTH_STANDARD")
        end
    end
)
function tURK.isPlayerAboveGround()
    local A = tURK.getPlayerCoords()
    local B, C = GetGroundZFor_3dCoord(A.x, A.y, A.z)
    return B, C
end
local D = 0
local E = 0
local F = 0
local G = 0
local function H(d)
    local I = GetVehicleNumberOfWheels(d)
    local J = 0.0
    for p = 0, I - 1 do
        local K = GetVehicleWheelSpeed(d, p)
        if K > J then
            J = K
        end
    end
    return J
end
local function L()
    local g = PlayerPedId()
    for c, M in pairs(GetGamePool("CObject")) do
        if GetEntityAttachedTo(M) == g then
            DeleteEntity(M)
        end
    end
end
Citizen.CreateThread(
    function()
        Wait(30000)
        local N = GetEntityCoords(PlayerPedId())
        while true do
            local g = PlayerPedId()
            local O = GetEntityCoords(g)
            local P = #(N - O)
            N = O
            if
                P > 0.4 and not IsPedFalling(g) and tURK.getStaffLevel() < 2 and not IsPedInParachuteFreeFall(g) and
                    not carryingBackInProgress and
                    not piggyBackInProgress and
                    not tURK.takeHostageInProgress() and
                    GetPedParachuteState(g) <= 0 and
                    not IsPedRagdoll(g) and
                    not IsPedRunning(g) and
                    not tURK.isPlayerRappeling() and
                    not tURK.isPlayerAboveGround() and
                    not tURK.isPlayerHidingInBoot() and
                    not tURK.isSpectatingEvent() and
                    not noclipActive
             then
                if not IsPedInAnyVehicle(g, 1) then
                    D = D + 1
                    if D > 100 then
                        TriggerServerEvent("URK:acType1", false)
                        D = 0
                    end
                end
            end
            local d, Q = tURK.getPlayerVehicle()
            if DoesEntityExist(d) and Q and P > 0.2 and tURK.getStaffLevel() < 2 then
                if F ~= d then
                    E = 0
                    F = d
                end
                local J = H(d)
                local R = GetEntitySpeed(d)
                if J < 5.0 and R < 2.5 then
                    E = E + 1
                    L()
                    if E > 100 and GetGameTimer() - G > 4000 then
                        TriggerServerEvent("URK:acType1", true)
                        E = 0
                        G = GetGameTimer()
                    end
                end
            end
            if NetworkIsInSpectatorMode() and not tURK.inSpectate() then
                TriggerServerEvent("URK:acType21")
                return
            end
            if GetCamFov(GetRenderingCam()) == 50.0 then
                TriggerServerEvent("URK:acType24")
                Wait(60000)
            end
            Wait(0)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            D = 0
            Wait(60000)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if GetLabelText("notification_buffer") ~= "NULL" then
                TriggerServerEvent("URK:acType7")
            end
            if GetLabelText("text_buffer") ~= "NULL" then
                TriggerServerEvent("URK:acType7")
            end
            if GetLabelText("preview_text_buffer") ~= "NULL" then
                TriggerServerEvent("URK:acType7")
            end
            Wait(10000)
        end
    end
)
WeaponBL = {
    "WEAPON_POOLCUE",
    "WEAPON_DAGGER",
    "WEAPON_KNIFE",
    "WEAPON_KNUCKLE",
    "WEAPON_HAMMER",
    "WEAPON_GOLFCLUB",
    "WEAPON_BOTTLE",
    "WEAPON_HATCHET",
    "WEAPON_PROXMINE",
    "WEAPON_BZGAS",
    "WEAPON_HAZARDCAN",
    "WEAPON_FLARE",
    "WEAPON_BALL",
    "WEAPON_PIPEWRENCH",
    "WEAPON_PISTOL",
    "WEAPON_PISTOL_MK2",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL",
    "WEAPON_SNSPISTOL",
    "WEAPON_HEAVYPISTOL",
    "WEAPON_VINTAGEPISTOL",
    "WEAPON_FLAREGUN",
    "WEAPON_MARKSMANPISTOL",
    "WEAPON_MICROSMG",
    "WEAPON_MINISMG",
    "WEAPON_SMG",
    "WEAPON_SMG_MK2",
    "WEAPON_ASSAULTSMG",
    "WEAPON_MG",
    "WEAPON_COMBATMG",
    "WEAPON_COMBATMG_MK2",
    "WEAPON_COMBATPDW",
    "WEAPON_GUSENBERG",
    "WEAPON_MACHINEPISTOL",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_ASSAULTRIFLE_MK2",
    "WEAPON_CARBINERIFLE",
    "WEAPON_CARBINERIFLE_MK2",
    "WEAPON_ADVANCEDRIFLE",
    "WEAPON_SPECIALCARBINE",
    "WEAPON_BULLPUPRIFLE",
    "WEAPON_COMPACTRIFLE",
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_SWEEPERSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    "WEAPON_ASSAULTSHOTGUN",
    "WEAPON_HEAVYSHOTGUN",
    "WEAPON_DBSHOTGUN",
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_HEAVYSNIPER_MK2",
    "WEAPON_MARKSMANRIFLE",
    "WEAPON_GRENADELAUNCHER",
    "WEAPON_GRENADELAUNCHER_SMOKE",
    "WEAPON_RPG",
    "WEAPON_MINIGUN",
    "WEAPON_FIREWORK",
    "WEAPON_RAILGUN",
    "WEAPON_HOMINGLAUNCHER",
    "WEAPON_GRENADE",
    "WEAPON_STICKYBOMB",
    "WEAPON_COMPACTLAUNCHER",
    "WEAPON_SNSPISTOL_MK2",
    "WEAPON_REVOLVER_MK2",
    "WEAPON_DOUBLEACTION",
    "WEAPON_SPECIALCARBINE_MK2",
    "WEAPON_BULLPUPRIFLE_MK2",
    "WEAPON_PUMPSHOTGUN_MK2",
    "WEAPON_MARKSMANRIFLE_MK2",
    "WEAPON_RAYPISTOL",
    "WEAPON_RAYCARBINE",
    "WEAPON_RAYMINIGUN",
    "WEAPON_DIGISCANNER",
    "WEAPON_NAVYREVOLVER",
    "WEAPON_CERAMICPISTOL",
    "WEAPON_STONE_HATCHET",
    "WEAPON_PIPEBOMB",
    "WEAPON_PASSENGER_ROCKET",
    "WEAPON_MUSKET"
}
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(500)
            for S, T in ipairs(WeaponBL) do
                Wait(1)
                if HasPedGotWeapon(PlayerPedId(), GetHashKey(T), false) == 1 then
                    RemoveAllPedWeapons(PlayerPedId(), false)
                    TriggerServerEvent("URK:acType2", T)
                    return
                end
            end
            local S, r = StatGetInt(GetHashKey("mp0_shooting_ability"), true)
            if r > 100 then
                TriggerServerEvent("URK:acType18")
                return
            end
        end
    end
)
Citizen.CreateThread(
    function()
        Wait(60000)
        local S = 0
        while true do
            if S >= 100 and not tURK.isInComa() then
                TriggerServerEvent("URK:acType6")
                return
            end
            if
                not tURK.isStaffedOn() and GetEntityHealth(PlayerPedId()) > 102 and not spawning and
                    not tURK.isPedScriptGuidChanging()
             then
                local h = PlayerId()
                local g = PlayerPedId()
                local U = GetEntityHealth(g)
                SetPlayerHealthRechargeMultiplier(h, 0.0)
                if g ~= 0 then
                    tURK.setHealth(U - 2)
                    Citizen.Wait(50)
                    if GetEntityHealth(g) > U - 2 then
                        S = S + 1
                    elseif S > 0 then
                        S = S - 1
                    end
                    tURK.setHealth(GetEntityHealth(g) + 2)
                end
            else
                Citizen.Wait(1000)
            end
        end
    end
)
local V = {GetHashKey("WEAPON_UNARMED"), GetHashKey("WEAPON_PETROLCAN"), GetHashKey("WEAPON_SNOWBALL")}
CreateThread(
    function()
        while true do
            local f = tURK.getPlayerPed()
            local i = GetSelectedPedWeapon(f)
            if IsPedShooting(f) and not table.has(V, i) then
                local Q, R = GetAmmoInClip(f, i)
                if R == GetMaxAmmoInClip(f, i) then
                    TriggerServerEvent("URK:acType8")
                    Wait(60000)
                end
            end
            Wait(0)
        end
    end
)
local W = vector3(0.0, 0.0, 0.0)
local X = 0
local Y = nil
local Z = 0
local _ = 0
local a0 = vector3(0.0, 0.0, 0.0)
local a1 = 0
local a2 = 0
local function a3(a4, a5, a6)
    if type(a4) == "vector3" then
        a0 = a4
    else
        a0 = vector3(a4, a5, a6)
    end
    a1 = GetGameTimer()
end
local a7 = SetEntityCoords
SetEntityCoords = function(a8, a9, aa, ab, ac, ad, ae, af)
    if a8 == X or a8 == Z then
        a3(a9, aa, ab)
    end
    a7(a8, a9, aa, ab, ac, ad, ae, af)
end
local ag = SetEntityCoordsNoOffset
SetEntityCoordsNoOffset = function(a8, a9, aa, ab, ac, ad, ae)
    if a8 == X or a8 == Z then
        a3(a9, aa, ab)
    end
    ag(a8, a9, aa, ab, ac, ad, ae)
end
local ah = NetworkResurrectLocalPlayer
NetworkResurrectLocalPlayer = function(a4, a5, a6, ai, aj, ak)
    a3(a4, a5, a6)
    ah(a4, a5, a6, ai, aj, ak)
end
local al = StartPlayerTeleport
StartPlayerTeleport = function(am, a4, a5, a6, ai, an, ao, ap)
    a3(a4, a5, a6)
    al(am, a4, a5, a6, ai, an, ao, ap)
end
local function aq(ar, as)
    if math.abs(ar.x) > as or math.abs(ar.y) > as or math.abs(ar.z) > as then
        return true
    else
        return false
    end
end
local function at()
    local g = PlayerPedId()
    if g == nil or g == 0 then
        return
    end
    X = g
    local au = GetGameTimer()
    local i = GetVehiclePedIsUsing(g)
    if Z ~= i then
        _ = au
    end
    Z = i
    local av = false
    if i ~= 0 then
        av = GetPedInVehicleSeat(i, -1) ~= g
    end
    local aw = Y
    Y = GetEntityCoords(g, true)
    if not aw then
        return
    end
    local ax = #(aw - Y)
    if
        ax < 50.0 or av or carryingBackInProgress or piggyBackInProgress or tURK.isPlayerHidingInBoot() or
            GetEntityAttachedTo(g) ~= 0
     then
        return
    end
    if au - _ < 2000 or au - a1 < 5000 then
        return
    end
    if #(Y - a0) < 15.0 or #(Y - W) < 50.0 or #(aw - W) < 50.0 then
        return
    end
    local ay = #(aw.xy - Y.xy)
    if aw.z < -180.0 and ay < 2500.0 then
        return
    end
    if Y.z >= -52.0 and Y.z <= -48.0 and ay < 10.0 then
        return
    end
    local az = GetEntityVelocity(g)
    local aA = (Y - aw) / GetFrameTime()
    local aB = az - aA
    if aq(aB, 100.0) then
        if au - a2 > 5000 then
            TriggerServerEvent("URK:sendVelocityLimit", aw, Y)
            a2 = au
        end
    end
end
RegisterNetEvent(
    "URK:settingPlayerIntoVehicle",
    function()
        a1 = GetGameTimer()
    end
)
local aC = 0
local aD = 0
local aE = 0
local aF = 0
local aG = 0
local aH = 0
local aI = 0
local aJ = SetVehicleFixed
SetVehicleFixed = function(d)
    if d == aH then
        aG = GetGameTimer()
    end
    aJ(d)
end
local aK = SetVehicleBodyHealth
SetVehicleBodyHealth = function(d, aL)
    if d == aH then
        aC = math.floor(aL)
    end
    aK(d, aL)
end
local aM = SetVehicleEngineHealth
SetVehicleEngineHealth = function(d, U)
    if d == aH then
        aD = math.floor(U)
    end
    aM(d, U)
end
local aN = SetVehiclePetrolTankHealth
SetVehiclePetrolTankHealth = function(d, U)
    if d == aH then
        aE = math.floor(U)
    end
    aN(d, U)
end
local aO = SetEntityHealth
SetEntityHealth = function(a8, U)
    if a8 == aH then
        aD = math.floor(U)
    end
    aO(a8, U)
end
local function aP(d)
    local aQ = {}
    local e = GetEntityModel(d)
    local aR = GetVehicleModelNumberOfSeats(e) - 1
    for aS = 0, aR do
        local aT = GetPedInVehicleSeat(d, aS)
        if aT ~= 0 and IsPedAPlayer(aT) then
            local aU = NetworkGetPlayerIndexFromPed(aT)
            if aU ~= -1 then
                local aV = GetPlayerServerId(aU)
                table.insert(aQ, {aS, aV})
            end
        end
    end
    return aQ
end
local function aW(aX, aY)
    if aX == 0 or aX < 0 and aY < 0 then
        return false
    end
    local aZ = math.abs(aY - aX)
    if aZ <= 4 then
        return false
    end
    if aZ <= 50 and aX ~= 1000 then
        return false
    end
    return aX > aY
end
local function a_()
    local d, Q = tURK.getPlayerVehicle()
    if
        d == 0 or not DoesEntityExist(d) or not Q or not NetworkGetEntityIsNetworked(d) or
            GetIsTaskActive(PlayerPedId(), 165) or
            GetEntityType(GetEntityAttachedTo(d)) == 2
     then
        aH = 0
        aC = 1000
        aD = 1000
        aE = 1000
        aF = 1000
        return
    end
    local b0 = math.floor(GetVehicleBodyHealth(d))
    local b1 = math.floor(GetVehicleEngineHealth(d))
    local b2 = math.floor(GetVehiclePetrolTankHealth(d))
    local b3 = math.floor(GetEntityHealth(d))
    if aW(b0, aC) or aW(b1, aD) or aW(b2, aE) or aW(b3, aF) then
        local au = GetGameTimer()
        if
            GetGameTimer() - aG > 1000 and d == aH and au - aI > 5000 and GetEntityHealth(PlayerPedId()) > 102 and
                au - globalLastSpawnedVehicleTime > 5000
         then
            local aQ = aP(d)
            local b4 = tURK.getVehicleIdFromHash(GetEntityModel(d)) or "N/A"
            TriggerServerEvent("URK:sendVehicleStats", b0, aC, b1, aD, b2, aE, b3, aF, aQ, b4)
            aI = au
        end
    end
    aC = b0
    aD = b1
    aE = b2
    aF = b3
    aH = d
end
AddEventHandler(
    "URK:onClientSpawn",
    function(b5, b6)
        if b6 then
            Citizen.Wait(15000)
            while true do
                at()
                a_()
                Citizen.Wait(0)
            end
        end
    end
)

Citizen.CreateThread(
    function()
        Wait(10000)
        while true do
            if
                GetPlayerInvincible(PlayerId()) and not isInGreenzone and not tURK.isInsideLsCustoms() and
                    not tURK.isStaffedOn() and
                    not noclipActive and
                    not tURK.isInComa() and
                    not tURK.isInSpectate() and
                    not tURK.getInRPZone() and
                    not tURK.isInTutorial()
             then
                TriggerServerEvent("URK:acType15")
                Citizen.Wait(60000)
            end
            if
                GetPlayerInvincible_2(PlayerId()) and not isInGreenzone and not tURK.isInsideLsCustoms() and
                    not tURK.isStaffedOn() and
                    not noclipActive and
                    not tURK.isInComa() and
                    not tURK.isInSpectate() and
                    not tURK.getInRPZone() and
                    not tURK.isInTutorial()
             then
                TriggerServerEvent("URK:acType15")
                Citizen.Wait(60000)
            end
            if
                not IsEntityVisible(PlayerPedId()) and not tURK.isInsideLsCustoms() and not noclipActive and
                    not tURK.isInSpectate() and
                    not tURK.isInTutorial() and
                    not tURK.inEvent() and
                    not tURK.isPlayerInDrone() and
                    not tURK.isSpectatingEvent() and
                    not spawning and
                    tURK.getStaffLevel() < 3 and
                    not tURK.isInBodybag()
             then
                TriggerServerEvent("URK:acType25")
                Citizen.Wait(60000)
            end
            Citizen.Wait(1000)
        end
    end
)
RegisterNUICallback(
    "NuiDevTool",
    function()
        TriggerServerEvent("URK:acType22")
    end
)
AddEventHandler(
    "onClientResourceStop",
    function(b8)
        TriggerServerEvent("URK:acType23")
    end
)
AddEventHandler(
    "onResourceStop",
    function(b8)
        TriggerServerEvent("URK:acType23", b8)
    end
)
print("[URK] - Anti-Cheat initialised")
