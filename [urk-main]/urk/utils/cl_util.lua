function tURK.loadClipSet(u)
    if not HasClipSetLoaded(u) then
        RequestClipSet(u)
        while not HasClipSetLoaded(u) do
            Wait(0)
        end
    end
end
function tURK.loadPtfx(u)
    if not HasNamedPtfxAssetLoaded(u) then
        RequestNamedPtfxAsset(u)
        while not HasNamedPtfxAssetLoaded(u) do
            Wait(0)
        end
    end
    UseParticleFxAsset(u)
end
function tURK.getStreetNameAtCoord(v, w, H)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(v, w, H))
end
Citizen.CreateThread(
    function()
        if not HasStreamedTextureDictLoaded("timerbars") then
            RequestStreamedTextureDict("timerbars")
            while not HasStreamedTextureDictLoaded("timerbars") do
                Wait(0)
            end
        end
    end
)
function DrawGTAText(A, v, w, aa, ab, ac)
    SetTextFont(0)
    SetTextScale(aa, aa)
    SetTextColour(254, 254, 254, 255)
    if ab then
        SetTextWrap(v - ac, v)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(A)
    EndTextCommandDisplayText(v, w)
end
function DrawGTATimerBar(ad, A, ae)
    local ac = 0.17
    local af = -0.01
    local ag = 0.038
    local ah = 0.008
    local ai = 0.005
    local aj = 0.32
    local ak = -0.04
    local al = 0.014
    local am = GetSafeZoneSize()
    local an = al + am - ac + ac / 2
    local ao = ak + am - ag + ag / 2 - (ae - 1) * (ag + ai)
    DrawSprite("timerbars", "all_black_bg", an, ao, ac, 0.038, 0, 0, 0, 0, 128)
    DrawGTAText(ad, am - ac + 0.06, ao - ah, aj)
    DrawGTAText(string.upper(A), am - af, ao - 0.0175, 0.5, true, ac / 2)
end
function GetPlayers()
    local a7 = {}
    for o, j in ipairs(GetActivePlayers()) do
        table.insert(a7, j)
    end
    return a7
end
function GetClosestPlayer(ap)
    local a7 = GetPlayers()
    local aq = -1
    local ar = -1
    local as = PlayerPedId()
    local at = GetEntityCoords(as, 0)
    for o, c in ipairs(a7) do
        local au = GetPlayerPed(c)
        if au ~= as then
            local av = GetEntityCoords(GetPlayerPed(c), 0)
            local aw = #(av - at)
            if aq == -1 or aq > aw then
                ar = c
                aq = aw
            end
        end
    end
    if aq <= ap then
        return ar
    else
        return nil
    end
end
function tURK.randomNum(d, e)
    math.randomseed(GetGameTimer() * math.random() * 2)
    return math.random(d, e)
end
soundEventCode = 0
TriggerServerEvent("URK:soundCodeServer")
RegisterNetEvent("URK:soundCode",function(aH)
    soundEventCode = aH
end)
RegisterNetEvent("URK:playClientNuiSound",function(aI, aJ, ap) -- use for cuffing and other sounds in areas
    local ax = tURK.getPlayerCoords()
    if #(ax - aI) <= ap then
        SendNUIMessage({transactionType = aJ})
    end
end)
function tURK.getNetId(aW, aX)
    if aX == nil then
        aX = ""
    end
    local aY = 0
    local aZ = DoesEntityExist(aW)
    if not aZ then
        tURK.debugLog(string.format("no such entity %s", aX))
    else
        aY = NetworkGetNetworkIdFromEntity(aW)
        if aY == aW then
            tURK.debugLog(string.format("no such networked entity %s", aX))
        end
    end
    return aY
end
function tURK.getObjectId(a_, aX)
    if aX == nil then
        aX = ""
    end
    local aL = 0
    local b0 = NetworkDoesNetworkIdExist(a_)
    if not b0 then
        tURK.debugLog(string.format("no object by ID %s\n%s", a_, aX))
    else
        local b1 = NetworkGetEntityFromNetworkId(a_)
        aL = b1
    end
    return aL
  end
  local aT = {}
  local aU = {}
  Citizen.CreateThread(function()
    local a = module("URKVeh", "garages")
    for aV, J in pairs(a.garages) do
        for aW, aX in pairs(J) do
            if aV ~= "_config" then
                local aY = aX[1]
                local aZ = string.lower(aW)
                if not aT[aZ] then
                    aT[aZ] = {name = aY, garageType = aV}
                    aU[GetHashKey(aZ)] = aZ
                end
            end
        end
    end
end)
function tURK.getVehicleNameFromId(aZ)
    if aT[string.lower(aZ)] then
        return aT[string.lower(aZ)].name
    end
    return ""
end
function tURK.getGarageNameFromId(aZ)
    return aT[string.lower(aZ)].garageType
end
function tURK.getVehicleIdFromModel(s)
    return aU[s]
end
local a_ = math.rad
local b0 = math.cos
local b1 = math.sin
local b2 = math.abs
function tURK.rotationToDirection(b3)
    local B = a_(b3.x)
    local D = a_(b3.z)
    return vector3(-b1(D) * b2(b0(B)), b0(D) * b2(b0(B)), b1(B))
end
  