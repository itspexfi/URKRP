licensecentre = module("cfg/cfg_licensecentre")

RMenu.Add('LicenseCentre', 'main', RageUI.CreateMenu("", "~r~" .. "Job Centre", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(), "banners", "jobcentre"))
RMenu.Add("LicenseCentre", "confirm", RageUI.CreateSubMenu(RMenu:Get('LicenseCentre', 'main',  tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight())))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('LicenseCentre', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for i , p in pairs(licensecentre.licenses) do 
                RageUI.Button(p.name..' (£'..tostring(getMoneyStringFormatted(p.price))..')', nil, p.notOwned and {RightLabel = "→→→"} or {RightLabel = ""}, p.notOwned, function(Hovered, Active, Selected)
                    if Selected then
                        cGroup = p.group
                        cName = p.name
                    end
                end, RMenu:Get("LicenseCentre", "confirm"))
            end
        end) 
    end
    if RageUI.Visible(RMenu:Get("LicenseCentre", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RMenu:Get("LicenseCentre", "confirm"):SetSubtitle("Are you sure?")
            for k,v in pairs(licensecentre.licenses) do
                if v.group == cGroup then
                    RageUI.Separator(v.name.." Price: £"..getMoneyStringFormatted(v.price))
                    if v.info ~= nil then
                        for a,b in pairs(v.info) do
                            RageUI.Separator(b)
                        end
                    end
                    RageUI.ButtonWithStyle("Confirm" , nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent('LicenseCentre:BuyGroup', cGroup, cName)
                        end
                    end, RMenu:Get("LicenseCentre", "main"))
                    RageUI.ButtonWithStyle("Decline" , nil, {RightLabel = ""}, true, function(Hovered, Active, Selected) end, RMenu:Get("LicenseCentre", "main"))
                end
            end
        end) 
    end
end)

AddEventHandler("URK:onClientSpawn",function(p, q)
    if q then
        local r = function(s)
        end
        local t = function(s)
            RageUI.Visible(RMenu:Get("LicenseCentre", "main"), false)
            RageUI.Visible(RMenu:Get("LicenseCentre", "confirm"), false)
            RageUI.ActuallyCloseAll()
        end
        local u = function(s)
            if IsControlJustPressed(1, 38) then
                TriggerServerEvent('URK:getOwnedLicenses')
                Wait(500)
                RageUI.Visible(RMenu:Get("LicenseCentre", "main"), not RageUI.Visible(RMenu:Get("LicenseCentre", "main")))
            end
            local v, w, x = table.unpack(GetFinalRenderedCamCoord())
            DrawText3D(licensecentre.location.x, licensecentre.location.y, licensecentre.location.z,"Press [E] to open License Centre",v,w,x)
            tURK.addMarker(licensecentre.location.x, licensecentre.location.y,licensecentre.location.z-0.98,0.7,0.7,0.5,255, 255,255,250,50,27,false,false)
        end
        tURK.createArea("licensecentre", licensecentre.location, 1.5, 6, r, t, u, {})
        tURK.addBlip(licensecentre.location.x, licensecentre.location.y, licensecentre.location.z, 457, 2, "Job Centre", 0.6, true)
    end
end)

local a = false
local b = {}
local c = 0.033
local d = 0.033
local e = 0
local f = 0.306
function func_licenseMenuControl()
    if IsControlJustPressed(0, 167) then
        if a then
            a = false
        else
            TriggerServerEvent("URK:GetLicenses")
        end
    end
    if a then
        if tURK.isNewPlayer() then
            drawNativeNotification("Press ~INPUT_SELECT_CHARACTER_FRANKLIN~ to toggle the License Menu.")
        end
        DrawRect(0.50, 0.222, 0.223, 0.075, 0, 0, 0, 255)
        DrawAdvancedText(0.595, 0.213, 0.005, 0.0028, 1.0, "~b~M~w~FG Licenses", 255, 255, 255, 255, 1, 0)
        DrawAdvancedText(0.595, 0.275, 0.005, 0.0028, 0.4, "Licenses Owned", 0, 255, 50, 255, 6, 0)
        DrawRect(0.50, 0.272, 0.223, 0.026, 0, 0, 0, 222)
        for g, h in pairs(b) do
            DrawAdvancedText(0.595, f + e * c, 0.005, 0.0028, 0.4, tostring(h), 255, 255, 255, 255, 6, 0)
            DrawRect(0.50, 0.301 + c * e, 0.223, 0.033, 0, 0, 0, 120)
            e = e + 1
        end
        e = 0
    end
end
if not tURK.isPurge() then
    tURK.createThreadOnTick(func_licenseMenuControl)
end
RegisterNetEvent("URK:RecievedLicenses",function(i)
    b = i
    a = true
end)
RegisterNetEvent("URK:gotOwnedLicenses",function(i)
    for k,v in pairs(licensecentre.licenses) do
        v.notOwned = true
        for a,b in pairs(i) do
            if v.name == b then
                v.notOwned = false
            end
        end
    end
end)