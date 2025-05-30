RMenu.Add('vipclubmenu','mainmenu',RageUI.CreateMenu("","~b~URK Club",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
RMenu.Add('vipclubmenu','managesubscription',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','mainmenu'),"","~b~URK Club",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
RMenu.Add('vipclubmenu','manageusersubscription',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','mainmenu'),"","~b~URK Club Manage",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
RMenu.Add('vipclubmenu','manageperks',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','mainmenu'),"","~b~URK Club Perks",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
RMenu.Add('vipclubmenu','deathsounds',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','manageperks'),"","~b~Manage Death Sounds",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
RMenu.Add('vipclubmenu','vehicleextras',RageUI.CreateSubMenu(RMenu:Get('vipclubmenu','manageperks'),"","~b~Vehicle Extras",tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners", "urk_club"))
local a={hoursOfPlus=0,hoursOfPlatinum=0}
local z={}

function tURK.isPlusClub()
    if a.hoursOfPlus>0 then 
        return true 
    else 
        return false 
    end 
end

function tURK.isPlatClub()
    if a.hoursOfPlatinum>0 then 
        return true 
    else 
        return false 
    end 
end

RegisterCommand("urkclub",function()
    TriggerServerEvent('URK:getPlayerSubscription')
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get('vipclubmenu','mainmenu'),not RageUI.Visible(RMenu:Get('vipclubmenu','mainmenu')))
end)

local c = {
    ["Default"] = {checked = true, soundId = "playDead"},
    ["Fortnite"] = {checked = false, soundId = "fortnite_death"},
    ["Roblox"] = {checked = false, soundId = "roblox_death"},
    ["Minecraft"] = {checked = false, soundId = "minecraft_death"},
    ["Pac-Man"] = {checked = false, soundId = "pacman_death"},
    ["Mario"] = {checked = false, soundId = "mario_death"},
    ["CS:GO"] = {checked = false, soundId = "csgo_death"}
}
local d = false
local e = false
local f = false
local g = false
local h = {"Red", "Blue", "Green", "Pink", "Yellow", "Orange", "Purple"}
local i = tonumber(GetResourceKvpString("urk_damageindicatorcolour")) or 1
Citizen.CreateThread(function()
    local l = GetResourceKvpString("urk_codhitmarkersounds") or "false"
    if l == "false" then
        d = false
        TriggerEvent("URK:codHMSoundsOff")
    else
        d = true
        TriggerEvent("URK:codHMSoundsOn")
    end
    local m = GetResourceKvpString("urk_killlistsetting") or "false"
    if m == "false" then
        e = false
    else
        e = true
    end
    local n = GetResourceKvpString("urk_oldkillfeed") or "false"
    if n == "false" then
        f = false
    else
        f = true
    end
    local o = GetResourceKvpString("urk_damageindicator") or "false"
    if o == "false" then
        g = false
    else
        g = true
    end
    Wait(5000)
end)

AddEventHandler("URK:onClientSpawn",function(f, g)
    if g then
        TriggerServerEvent('URK:getPlayerSubscription')
        Wait(5000)
        local u=tURK.getDeathSound()
        local j="playDead"
        for k,l in pairs(c)do 
            if l.soundId==u then 
                j=k 
            end 
        end
        for k,m in pairs(c)do 
            if j~=k then 
                m.checked=false 
            else 
                m.checked=true 
            end 
        end 
    end
end)


function tURK.setDeathSound(u)
    if tURK.isPlusClub() or tURK.isPlatClub() then 
        SetResourceKvp("urk_deathsound",u)
    else 
        tURK.notify("~r~Cannot change deathsound, not a valid URK Plus or Platinum subscriber.")
    end 
end
function tURK.getDeathSound()
    if tURK.isPlusClub() or tURK.isPlatClub() then 
        local k=GetResourceKvpString("urk_deathsound")
        if type(k) == "string" and k~="" then 
            return k 
        else 
            return "playDead"
        end 
    else 
        return "playDead"
    end 
end

local function m(h)
    SendNUIMessage({transactionType = h})
end

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('vipclubmenu', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if tURK.isPlusClub() or tURK.isPlatClub() then
                RageUI.ButtonWithStyle("Manage Subscription","",{RightLabel="→→→"},true,function(o,p,q)
                end,RMenu:Get("vipclubmenu","managesubscription"))
                RageUI.ButtonWithStyle("Manage Perks","",{RightLabel="→→→"},true,function(o,p,q)
                end,RMenu:Get("vipclubmenu","manageperks"))
            else
                RageUI.ButtonWithStyle("Purchase Subscription","",{RightLabel="→→→"},true,function(o,p,q)
                    if q then
                        tURK.OpenUrl("https://store.urkstudios.uk")
                        SendNUIMessage({act="openurl",url="https://store.urkstudios.uk"})
                    end
                end)
            end
            if tURK.isDev() or tURK.getStaffLevel() >= 10 then
                RageUI.ButtonWithStyle("Manage User's Subscription","",{RightLabel="→→→"},true,function(o,p,q)
                end,RMenu:Get("vipclubmenu","manageusersubscription"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('vipclubmenu', 'managesubscription')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            colourCode = getColourCode(a.hoursOfPlus)
            RageUI.Separator("Days remaining of Plus Subscription: "..colourCode..math.floor(a.hoursOfPlus/24*100)/100 .." days.")
            colourCode = getColourCode(a.hoursOfPlatinum)
            RageUI.Separator("Days remaining of Platinum Subscription: "..colourCode..math.floor(a.hoursOfPlatinum/24*100)/100 .." days.")
            RageUI.Separator()
            RageUI.ButtonWithStyle("Sell Plus Subscription days.","~r~If you have already claimed your weekly kit, you may not sell days until the week is over.",{RightLabel = "→→→"},true,function(o, p, q)
                if q then
                    if isInGreenzone then
                        TriggerServerEvent("URK:beginSellSubscriptionToPlayer", "Plus")
                    else
                        notify("~r~You must be in a greenzone to sell.")
                    end
                end
            end)
            RageUI.ButtonWithStyle("Sell Platinum Subscription days.","~r~If you have already claimed your weekly kit, you may not sell days until the week is over.",{RightLabel = "→→→"},true,function(o, p, q)
                if q then
                    if isInGreenzone then
                        TriggerServerEvent("URK:beginSellSubscriptionToPlayer", "Platinum")
                    else
                        notify("~r~You must be in a greenzone to sell.")
                    end
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('vipclubmenu', 'manageusersubscription')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if tURK.isDev() then
                if next(z) then
                    RageUI.Separator('Perm ID: '..z.userid)
                    colourCode = getColourCode(z.hoursOfPlus)
                    RageUI.Separator('Days of Plus Remaining: '..colourCode..math.floor(z.hoursOfPlus/24*100)/100)
                    colourCode = getColourCode(z.hoursOfPlatinum)
                    RageUI.Separator('Days of Platinum Remaining: '..colourCode..math.floor(z.hoursOfPlatinum/24*100)/100)
                    RageUI.ButtonWithStyle("Set Plus Days","",{RightLabel="→→→"},true,function(o,p,q)
                        if q then
                            TriggerServerEvent("URK:setPlayerSubscription", z.userid, "Plus")
                        end
                    end)
                    RageUI.ButtonWithStyle("Set Platinum Days","",{RightLabel="→→→"},true,function(o,p,q)
                        if q then
                            TriggerServerEvent("URK:setPlayerSubscription", z.userid, "Platinum")
                        end
                    end)    
                else
                    RageUI.Separator('Please select a Perm ID')
                end
                RageUI.ButtonWithStyle("Select Perm ID", nil, { RightLabel = "→→→" }, true, function(Hovered, Active, Selected)
                    if Selected then
                        permID = tURK.KeyboardInput("Enter Perm ID", "", 10)
                        if permID == nil then 
                            tURK.notify('Invalid Perm ID')
                            return
                        end
                        TriggerServerEvent('URK:getPlayerSubscription', permID)
                    end
                end, RMenu:Get("vipclubmenu", 'manageusersubscription'))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('vipclubmenu', 'manageperks')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.ButtonWithStyle(
                        "Custom Death Sounds",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(o, p, q)
                        end,
                        RMenu:Get("vipclubmenu", "deathsounds")
                    )
                    RageUI.ButtonWithStyle(
                        "Vehicle Extras",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(o, p, q)
                        end,
                        RMenu:Get("vipclubmenu", "vehicleextras")
                    )
                    RageUI.ButtonWithStyle(
                        "Claim Weekly Kit",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(o, p, q)
                            if q then
                                if not globalInPrison and not tURK.isHandcuffed() then
                                    TriggerServerEvent("URK:claimWeeklyKit")
                                else
                                    notify("~r~You can not redeem a kit whilst in custody.")
                                end
                            end
                        end
                    )
                    local function q()
                        TriggerEvent("URK:codHMSoundsOn")
                        d = true
                        tURK.setCODHitMarkerSetting(d)
                        tURK.notify("~y~COD Hitmarkers now set to " .. tostring(d))
                    end
                    local function r()
                        TriggerEvent("URK:codHMSoundsOff")
                        d = false
                        tURK.setCODHitMarkerSetting(d)
                        tURK.notify("~y~COD Hitmarkers now set to " .. tostring(d))
                    end
                    RageUI.Checkbox(
                        "Enable COD Hitmarkers",
                        "~g~This adds 'hit marker' sound and image when shooting another player.",
                        d,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(n, p, o, s)
                        end,
                        q,
                        r
                    )
                    RageUI.Checkbox(
                        "Enable Kill List",
                        "~g~This adds a kill list below your crosshair when you kill a player.",
                        e,
                        {Style = RageUI.CheckboxStyle.Car},
                        function()
                        end,
                        function()
                            e = true
                            tURK.setKillListSetting(e)
                            tURK.notify("~y~Kill List now set to " .. tostring(e))
                        end,
                        function()
                            e = false
                            tURK.setKillListSetting(e)
                            tURK.notify("~y~Kill List now set to " .. tostring(e))
                        end
                    )
                    RageUI.Checkbox(
                        "Enable Old Kilfeed",
                        "~g~This toggles the old killfeed that notifies above minimap.",
                        f,
                        {Style = RageUI.CheckboxStyle.Car},
                        function()
                        end,
                        function()
                            f = true
                            tURK.setOldKillfeed(f)
                            tURK.notify("~y~Old killfeed now set to " .. tostring(f))
                        end,
                        function()
                            f = false
                            tURK.setOldKillfeed(f)
                            tURK.notify("~y~Old killfeed now set to " .. tostring(f))
                        end
                    )
                    RageUI.Checkbox(
                        "Enable Damage Indicator",
                        "~g~This toggles the display of damage indicator.",
                        g,
                        {Style = RageUI.CheckboxStyle.Car},
                        function()
                        end,
                        function()
                            g = true
                            tURK.setDamageIndicator(g)
                            tURK.notify("~y~Damage Indicator now set to " .. tostring(g))
                        end,
                        function()
                            g = false
                            tURK.setDamageIndicator(g)
                            tURK.notify("~y~Damage Indicator now set to " .. tostring(g))
                        end
                    )
                    if g then
                        RageUI.List(
                            "Damage Colour",
                            h,
                            i,
                            "~g~Change the displayed colour of damage",
                            {},
                            true,
                            function(A, B, C, D)
                                i = D
                                tURK.setDamageIndicatorColour(i)
                            end,
                            function()
                            end,
                            nil
                        )
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("vipclubmenu", "deathsounds")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    for t, k in pairs(c) do
                        RageUI.Checkbox(
                            t,
                            "",
                            k.checked,
                            {},
                            function()
                            end,
                            function()
                                for u, l in pairs(c) do
                                    l.checked = false
                                end
                                k.checked = true
                                m(k.soundId)
                                tURK.setDeathSound(k.soundId)
                            end,
                            function()
                            end
                        )
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("vipclubmenu", "vehicleextras")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    local w = tURK.getPlayerVehicle()
                    if w and w ~= 0 and DoesEntityExist(w) then
                        SetVehicleAutoRepairDisabled(w, true)
                    end
                    for x = 1, 99, 1 do
                        if DoesExtraExist(w, x) then
                            RageUI.Checkbox(
                                "Extra " .. x,
                                "",
                                IsVehicleExtraTurnedOn(w, x),
                                {},
                                function()
                                end,
                                function()
                                    SetVehicleExtra(w, x, 0)
                                end,
                                function()
                                    SetVehicleExtra(w, x, 1)
                                end
                            )
                        end
                    end
                end
            )
        end
    end
)

RegisterNetEvent("URK:setVIPClubData",function(y,z)
    a.hoursOfPlus=y
    a.hoursOfPlatinum=z 
end)

RegisterNetEvent("URK:getUsersSubscription",function(userid, plussub, platsub)
    z.userid = userid
    z.hoursOfPlus=plussub
    z.hoursOfPlatinum=platsub
    RMenu:Get("vipclubmenu", 'manageusersubscription')
end)

RegisterNetEvent("URK:userSubscriptionUpdated",function()
    TriggerServerEvent('URK:getPlayerSubscription', permID)
end)

Citizen.CreateThread(function()
    while true do 
        if tURK.isPlatClub()then 
            if not HasPedGotWeapon(PlayerPedId(),'GADGET_PARACHUTE',false) then 
                tURK.allowWeapon("GADGET_PARACHUTE")
                GiveWeaponToPed(PlayerPedId(),'GADGET_PARACHUTE')
                SetPlayerHasReserveParachute(PlayerId())
            end 
        end
        if tURK.isPlusClub() or tURK.isPlatClub()then 
            SetVehicleDirtLevel(tURK.getPlayerVehicle(),0.0)
        end
        Wait(500)
    end 
end)

function getColourCode(a)
    if a>=10 then 
        colourCode="~g~"
    elseif a<10 and a>3 then 
        colourCode="~y~"
    else 
        colourCode="~r~"
    end
    return colourCode
end
local C = {}
local function D()
    for y, E in pairs(C) do
        DrawAdvancedTextNoOutline(
            0.6,
            0.5 + 0.025 * y,
            0.005,
            0.0028,
            0.45,
            "Killed " .. E.name,
            255,
            255,
            255,
            255,
            tURK.getFontId("Akrobat-Regular"),
            1
        )
    end
end
tURK.createThreadOnTick(D)
RegisterNetEvent(
    "URK:onPlayerKilledPed",
    function(F)
        if e and (tURK.isPlatClub() or tURK.isPlusClub()) and IsPedAPlayer(F) then
            local G = NetworkGetPlayerIndexFromPed(F)
            if G >= 0 then
                local H = GetPlayerServerId(G)
                if H >= 0 then
                    local I = tURK.getPlayerName(G)
                    table.insert(C, {name = I, source = H})
                    SetTimeout(
                        2000,
                        function()
                            for y, E in pairs(C) do
                                if H == E.source then
                                    table.remove(C, y)
                                end
                            end
                        end
                    )
                end
            end
        end
    end
)
