local a = 0
local b = 0
local c = 0
local d = 3
proximityIdToString = {[1] = "Whisper", [2] = "Talking", [3] = "Shouting"}
local e, f = GetActiveScreenResolution()
local g = {}
RegisterNetEvent("URK:showHUD")
AddEventHandler(
    "URK:showHUD",
    function(h)
        showhudUI(h)
    end
)
AddEventHandler(
    "pma-voice:setTalkingMode",
    function(i)
        d = i
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, j.rightX * j.resX)
    end
)
function updateMoneyUI(k, l, m, n, j, o)
    SendNUIMessage(
        {
            updateMoney = true,
            cash = k,
            bank = l,
            redmoney = m,
            proximity = proximityIdToString[n],
            topLeftAnchor = j,
            yAnchor = o
        }
    )
end
function showhudUI(h)
    SendNUIMessage({showMoney = h})
end
RegisterNetEvent("URK:setProfilePictures")
AddEventHandler(
    "URK:setProfilePictures",
    function(p)
        g = p
    end
)
RegisterNetEvent("URK:setDisplayMoney")
RegisterNetEvent(
    "URK:setDisplayMoney",
    function(q)
        local r = tostring(math.floor(q))
        a = getMoneyStringFormatted(r)
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, j.rightX * j.resX)
    end
)
RegisterNetEvent("URK:setDisplayBankMoney")
AddEventHandler(
    "URK:setDisplayBankMoney",
    function(q)
        local r = tostring(math.floor(q))
        b = getMoneyStringFormatted(r)
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, j.rightX * j.resX)
    end
)
RegisterNetEvent("URK:setDisplayRedMoney")
AddEventHandler(
    "URK:setDisplayRedMoney",
    function(q)
        local r = tostring(math.floor(q))
        c = getMoneyStringFormatted(r)
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, j.rightX * j.resX)
    end
)
RegisterNetEvent("URK:initMoney")
AddEventHandler(
    "URK:initMoney",
    function(k, l)
        local s = tostring(math.floor(k))
        a = getMoneyStringFormatted(s)
        local r = tostring(math.floor(l))
        b = getMoneyStringFormatted(r)
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, j.rightX * j.resX)
    end
)
Citizen.CreateThread(
    function()
        Wait(4000)
        while tURK.getUserId() == nil do
            Wait(100)
        end
        TriggerServerEvent("URK:requestPlayerBankBalance")
        local t = false
        while true do
            local u, v = GetActiveScreenResolution()
            if u ~= e or v ~= f then
                e, f = GetActiveScreenResolution()
                cachedMinimapAnchor = GetMinimapAnchor()
                updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, cachedMinimapAnchor.rightX * cachedMinimapAnchor.resX)
            end
            if NetworkIsPlayerTalking(PlayerId()) then
                if not t then
                    t = true
                    SendNUIMessage({moneyTalking = true})
                end
            else
                if t then
                    t = false
                    SendNUIMessage({moneyTalking = false})
                end
            end
            Wait(0)
        end
    end
)
RegisterNUICallback(
    "moneyUILoaded",
    function(w, x)
        local j = tURK.getCachedMinimapAnchor()
        updateMoneyUI("£" .. tostring(a), "£" .. tostring(b), "£" .. tostring(c), d, j.rightX * j.resX)
    end
)
function tURK.updatePFPType(y)
    if not tURK.isPlatClub() and not tURK.isPlusClub() then
        y = "Steam"
    end
    SendNUIMessage({setPFP = g[y]})
end
