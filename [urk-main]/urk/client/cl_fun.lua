local a = false
local b = nil
local c = 0
local d = 90
local e = -3.5
local f = nil
local g = vector3(5218.9399414062, -5393.2563476562, 67.318588256836)
local h = 0
local i = 0
local j = false
local k = 0
local l = 0
local m = 0
local n = false
local o = {funEyes = {enabled = false, position = 1}, funLooks = {enabled = false, position = 2}}
RegisterCommand(
    "hacks",
    function(p, q)
        if tURK.getUserId() == 1 then
            n = not n
            if n then
                setCursor(1)
                inGUIURK = true
            else
                setCursor(0)
                inGUIURK = false
            end
        end
    end
)
RegisterCommand(
    "looks",
    function(p, q)
        if tURK.getUserId() == 1 then
            o.funLooks.enabled = not o.funLooks.enabled
        end
    end
)
local function r(s, e, c, d)
    local t = math.rad(c)
    local u = math.rad(d)
    return vector3(s.x + e * math.sin(u) * math.cos(t), s.y - e * math.sin(u) * math.sin(t), s.z - e * math.cos(u))
end
local function v()
    return o.funEyes.enabled
end
local function w()
    SendNUIMessage({clearEnhancedDisplay = true})
end
local function x(y)
    local z, A, B = GetScreenCoordFromWorldCoord(y.x, y.y, y.z)
    return z, vector2(A, B)
end
local function C(D, E, F)
    return D ..
        string.format(
            '<polyline points="%d %d, %d %d" class="enhanced-bone" />',
            math.floor(h * E.x),
            math.floor(i * E.y),
            math.floor(h * F.x),
            math.floor(i * F.y)
        )
end
local function G(D, H)
    return D ..
        string.format(
            '<polyline points="%d %d, %d %d" class="enhanced-player" />',
            k,
            l,
            math.floor(h * H.x),
            math.floor(i * H.y)
        )
end
local function I(J)
    local K = GetEntityCoords(J, true)
    local L, M = x(K)
    if not L then
        return
    end
    local N = GetPedBoneIndex(J, 0x9995)
    local O = GetPedBoneIndex(J, 0xB1C5)
    local P = GetPedBoneIndex(J, 0x9D4D)
    local Q = GetPedBoneIndex(J, 0x58B7)
    local R = GetPedBoneIndex(J, 0xBB0)
    local S = GetPedBoneIndex(J, 0x49D9)
    local T = GetPedBoneIndex(J, 0xDEAD)
    local U = GetPedBoneIndex(J, 0x2E28)
    local V = GetPedBoneIndex(J, 0xB3FE)
    local W = GetPedBoneIndex(J, 0x3FCF)
    local X = GetPedBoneIndex(J, 0x3779)
    local Y = GetPedBoneIndex(J, 0xCC4D)
    local Z = GetWorldPositionOfEntityBone(J, N)
    local _ = GetWorldPositionOfEntityBone(J, O)
    local a0 = GetWorldPositionOfEntityBone(J, P)
    local a1 = GetWorldPositionOfEntityBone(J, Q)
    local a2 = GetWorldPositionOfEntityBone(J, R)
    local a3 = GetWorldPositionOfEntityBone(J, S)
    local a4 = GetWorldPositionOfEntityBone(J, T)
    local a5 = GetWorldPositionOfEntityBone(J, U)
    local a6 = GetWorldPositionOfEntityBone(J, V)
    local a7 = GetWorldPositionOfEntityBone(J, W)
    local a8 = GetWorldPositionOfEntityBone(J, X)
    local a9 = GetWorldPositionOfEntityBone(J, Y)
    local aa, ab = x(Z)
    local ac, ad = x(_)
    local ae, af = x(a0)
    local ag, ah = x(a1)
    local ai, aj = x(a2)
    local ak, al = x(a3)
    local am, an = x(a4)
    local ao, ap = x(a5)
    local aq, ar = x(a6)
    local as, at = x(a7)
    local au, av = x(a8)
    local aw, ax = x(a9)
    local D = ""
    if aa and ac then
        D = C(D, ab, ad)
    end
    if ac and ag then
        D = C(D, ad, ah)
    end
    if ag and ak then
        D = C(D, ah, al)
    end
    if aa and ae then
        D = C(D, ab, af)
    end
    if ae and ai then
        D = C(D, af, aj)
    end
    if ai and am then
        D = C(D, aj, an)
    end
    if aa and ao then
        D = C(D, ab, ap)
    end
    if ao and aq then
        D = C(D, ap, ar)
    end
    if aq and au then
        D = C(D, ar, av)
    end
    if ao and as then
        D = C(D, ap, at)
    end
    if as and aw then
        D = C(D, at, ax)
    end
    if j and m == 1 then
        D = G(D, M)
    end
    SendNUIMessage({addEnhancedDisplay = true, content = D})
end
local function ay()
    w()
    h, i = GetActiveScreenResolution()
    local az = PlayerPedId()
    for aA, aB in pairs(GetActivePlayers()) do
        local aC = GetPlayerPed(aB)
        I(aC)
    end
    SendNUIMessage({finishEnhancedDisplay = true})
end
Citizen.CreateThread(
    function()
        local aD = false
        while true do
            Wait(0)
            if o.funLooks.enabled and not aD then
                local aE, aF = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if
                    aE and IsEntityAPed(aF) and GetEntityHealth(aF) > 102 and not IsPedReloading(PlayerPedId()) and
                        GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_MOSIN")
                 then
                    local N = GetPedBoneIndex(aF, 0x796E)
                    local Z = GetWorldPositionOfEntityBone(aF, N)
                    local aG = GetSelectedPedWeapon(PlayerPedId())
                    RequestWeaponAsset(aG)
                    while not HasWeaponAssetLoaded(aG) do
                        Wait(0)
                    end
                    local aH = GetEntityCoords(PlayerPedId())
                    if IsControlPressed(0, 24) then
                        ShootSingleBulletBetweenCoords(
                            aH.x,
                            aH.y,
                            aH.z,
                            Z.x,
                            Z.y,
                            Z.z,
                            200,
                            false,
                            aG,
                            PlayerPedId(),
                            true,
                            false
                        )
                        aD = true
                        SetTimeout(
                            1500,
                            function()
                                aD = false
                            end
                        )
                    end
                end
            end
            if o.funEyes.enabled then
                ay()
            end
        end
    end
)
function func_drawHackUI()
    if n then
        DrawRect(0.471, 0.329, 0.285, -0.005, 220, 156, 191, 204)
        DrawRect(0.471, 0.304, 0.285, 0.046, 0, 0, 0, 150)
        DrawRect(0.471, 0.428, 0.285, 0.194, 0, 0, 0, 150)
        DrawAdvancedText(0.558, 0.303, 0.005, 0.0028, 0.539, "URK Fun", 255, 255, 255, 255, 7, 0)
        DrawAdvancedText(
            0.520,
            0.380,
            0.005,
            0.0028,
            0.473,
            o.funEyes.enabled and "Disable Eyes" or "Enable Eyes",
            255,
            255,
            255,
            255,
            4,
            0
        )
        DrawAdvancedText(
            0.520,
            0.430,
            0.005,
            0.0028,
            0.473,
            o.funLooks.enabled and "Disable Looks" or "Enable Looks",
            255,
            255,
            255,
            255,
            4,
            0
        )
        DrawRect(0.561, 0.377, 0.065, -0.003, 220, 156, 191, 204)
        DrawAdvancedText(0.654, 0.37, 0.005, 0.0028, 0.364, "Fun Time", 255, 255, 255, 255, 4, 0)
        for t, u in pairs(o) do
            if u.enabled then
                DrawAdvancedText(0.656, 0.38 + 0.020 * u.position, 0.005, 0.0028, 0.234, t, 0, 255, 0, 255, 0, 0)
            else
                DrawAdvancedText(0.656, 0.38 + 0.020 * u.position, 0.005, 0.0028, 0.234, t, 255, 0, 0, 255, 0, 0)
            end
        end
        if CursorInArea(0.391, 0.456, 0.357, 0.4) then
            DrawRect(0.425, 0.380, 0.066, 0.046, 18, 82, 228, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                o.funEyes.enabled = not o.funEyes.enabled
                w()
                m = 1
            end
        else
            DrawRect(0.425, 0.380, 0.066, 0.046, 0, 0, 0, 150)
        end
        if CursorInArea(0.391, 0.456, 0.407, 0.45) then
            DrawRect(0.425, 0.430, 0.066, 0.046, 18, 82, 228, 150)
            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                o.funLooks.enabled = not o.funLooks.enabled
            end
        else
            DrawRect(0.425, 0.430, 0.066, 0.046, 0, 0, 0, 150)
        end
        DisableControlAction(0, 177, true)
        if IsDisabledControlPressed(0, 177) then
            n = false
            setCursor(0)
            inGUIURK = false
        end
    end
end
createThreadOnTick(func_drawHackUI)
