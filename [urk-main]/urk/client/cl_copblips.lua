local a = false
local b = {}
local c = {}
local function d()
    for e, f in pairs(b) do
        if DoesBlipExist(f) then
            RemoveBlip(f)
        end
    end
    b = {}
end
local function g()
    for e, f in pairs(c) do
        if DoesBlipExist(f) then
            RemoveBlip(f)
        end
    end
    c = {}
end
local function h(i, j, k)
    if not DoesBlipExist(i) then
        local l = AddBlipForEntity(j)
        table.insert(b, l)
        SetBlipSprite(l, 1)
        SetBlipScale(i, 0.85)
        SetBlipAlpha(i, 255)
        SetBlipColour(i, k)
        ShowHeadingIndicatorOnBlip(i, true)
    else
        if GetEntityHealth(j) > 102 then
            SetBlipSprite(i, 1)
        else
            SetBlipSprite(i, 274)
        end
        SetBlipScale(i, 0.85)
        SetBlipAlpha(i, 255)
        SetBlipColour(i, k)
        ShowHeadingIndicatorOnBlip(i, true)
    end
end
local function m(n, o)
    return IsEntityVisible(n) or not tURK.clientGetPlayerIsStaff(o)
end
local function p(n, o, k)
    local l = AddBlipForCoord(n.x, n.y, n.z)
    table.insert(c, l)
    if o == 0 then
        SetBlipSprite(l, 1)
    else
        SetBlipSprite(l, 274)
    end
    SetBlipScale(l, 0.85)
    SetBlipAlpha(l, 255)
    SetBlipColour(l, k)
end
RegisterCommand(
    "blipson",
    function()
        if tURK.globalOnPoliceDuty() or tURK.globalNHSOnDuty() then
            tURK.notify("~g~Emergency blips enabled.")
            a = true
        end
    end,
    false
)
RegisterCommand(
    "blipsoff",
    function()
        if tURK.globalOnPoliceDuty() or tURK.globalNHSOnDuty() then
            tURK.notify("~r~Emergency blips disabled.")
            a = false
            d()
            g()
        end
    end,
    false
)
RegisterNetEvent(
    "URK:disableFactionBlips",
    function()
        a = false
        tURK.setPolice(false)
        tURK.setHMP(false)
        tURK.setNHS(false)
        d()
        g()
    end
)
function tURK.copBlips()
    return a
end
Citizen.CreateThread(
    function()
        while true do
            if a or tURK.isInComa() or tURK.hasGangBlipsEnabled() then
                local q = tURK.getPlayerPed()
                for e, f in ipairs(GetActivePlayers()) do
                    local j = GetPlayerPed(f)
                    if j ~= q then
                        local i = GetBlipFromEntity(j)
                        local r = GetPlayerServerId(f)
                        if r ~= -1 then
                            local s = tURK.clientGetUserIdFromSource(r)
                            local t = tURK.getJobType(s)
                            if s ~= tURK.getUserId() then
                                local u = false
                                if m(j, s) then
                                    if a then
                                        if t == "metpd" then
                                            h(i, j, 3)
                                            u = true
                                        elseif t == "cid" then
                                            h(i, j, 27)
                                            u = true
                                        elseif t == "npas" then
                                            h(i, j, 5)
                                            u = true
                                        elseif t == "hmp" then
                                            h(i, j, 29)
                                            u = true
                                        elseif t == "lfb" then
                                            h(i, j, 1)
                                            u = true
                                        elseif t == "hems" then
                                            h(i, j, 44)
                                            u = true
                                        elseif t == "nhs" then
                                            h(i, j, 2)
                                            u = true
                                        end
                                    elseif tURK.isInComa() then
                                        if t == "nhs" then
                                            h(i, j, 2)
                                        end
                                    elseif tURK.hasGangBlipsEnabled() and not tURK.isEmergencyService() then
                                        local v, w = tURK.isPlayerInSelectedGang(r)
                                        for k, x in pairs(URKGangMembers) do
                                            if s == x[2] and t == "" then
                                                h(i, j, w.blip)
                                                u = true
                                            end
                                        end
                                    end
                                end
                                if not u and not tURK.hasStaffBlips() then
                                    local y = GetBlipFromEntity(j)
                                    if y ~= 0 then
                                        RemoveBlip(y)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            Wait(100)
        end
    end
)
local z = true
local x = GetPlayerServerId(PlayerId())
CreateThread(
    function()
        Wait(20000)
        z = false
    end
)
RegisterNetEvent(
    "URK:sendFarBlips",
    function(y)
        if not z and (a or tURK.hasGangBlipsEnabled()) then
            g()
            for e, A in pairs(y) do
                if A.source ~= x and GetPlayerFromServerId(A.source) == -1 and A.bucket == tURK.getPlayerBucket() then
                    p(A.position, A.dead, A.colour)
                end
            end
        end
    end
)
RegisterNetEvent(
    "URK:Revive",
    function()
        if not a then
            Citizen.Wait(1000)
            d()
        end
    end
)
