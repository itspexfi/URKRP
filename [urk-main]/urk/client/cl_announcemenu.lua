RMenu.Add("urkannouncements","main",RageUI.CreateMenu("","~r~Announcement Menu",tURK.getRageUIMenuWidth(),tURK.getRageUIMenuHeight(),"banners","urk_announceui"))
local a = {}
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('urkannouncements', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for b, c in pairs(a) do
                RageUI.Button(c.name, string.format("%s Price: £%s", c.desc, getMoneyStringFormatted(c.price)), {RightLabel = "→→→"}, true, function(d, e, f)
                    if f then
                        TriggerServerEvent("URK:serviceAnnounce", c.name)
                    end
                end)
            end
        end)
    end
end)

RegisterNetEvent("URK:serviceAnnounceCl",function(h, i)
    tURK.announce(h, i)
end)

RegisterNetEvent("URK:buildAnnounceMenu",function(g)
    a = g
    RageUI.Visible(RMenu:Get("urkannouncements", "main"), not RageUI.Visible(RMenu:Get("urkannouncements", "main")))
end)

RegisterCommand("announcemenu",function()
    TriggerServerEvent('URK:getAnnounceMenu')
end)
