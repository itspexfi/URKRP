local a = nil
local b = {}
local c = ""
local function checkOutfits()
    if next(b) then
        return true
    end
    return false
end
RMenu.Add("urkwardrobe","mainmenu",RageUI.CreateMenu("", "", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(), "banners", "urk_wardrobeui"))
RMenu:Get("urkwardrobe", "mainmenu"):SetSubtitle("~r~HOME")
RMenu.Add("urkwardrobe","listoutfits",RageUI.CreateSubMenu(RMenu:Get("urkwardrobe", "mainmenu"),"","~r~Wardrobe",tURK.getRageUIMenuWidth(),tURK.getRageUIMenuHeight()))
RMenu.Add("urkwardrobe","equip",RageUI.CreateSubMenu(RMenu:Get("urkwardrobe", "listoutfits"),"","~r~Wardrobe",tURK.getRageUIMenuWidth(),tURK.getRageUIMenuHeight()))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('urkwardrobe', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("List Outfits","",{RightLabel = "→→→"},checkOutfits(),function(d, e, f)
            end,RMenu:Get("urkwardrobe", "listoutfits"))
            RageUI.Button("Save Outfit","",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    c = getGenericTextInput("outfit name:")
                    if c then
                        if not tURK.isPlayerInAnimalForm() then
                            TriggerServerEvent("URK:saveWardrobeOutfit", c)
                        else
                            tURK.notify("~r~Cannot save animal in wardrobe.")
                        end
                    else
                        tURK.notify("~r~Invalid outfit name")
                    end
                end
            end)
            RageUI.Button("Get Outfit Code","Gets a code for your current outfit which can be shared with other players.",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    if tURK.isPlusClub() or tURK.isPlatClub() then
                        TriggerServerEvent("URK:getCurrentOutfitCode")
                    else
                        tURK.notify("~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature.")
                        tURK.notify("~y~Available @ store.urkstudios.uk")
                    end
                end
            end,nil)
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('urkwardrobe', 'listoutfits')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            if b ~= {} then
                for g, h in pairs(b) do
                    RageUI.Button(g,"",{RightLabel = "→→→"},true,function(d, e, f)
                        if f then
                            c = g
                        end
                    end,RMenu:Get("urkwardrobe", "equip"))
                end
            else
                RageUI.Button("~r~No outfits saved","",{RightLabel = "→→→"},true,function(d, e, f)
                end,RMenu:Get("urkwardrobe", "mainmenu"))
            end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('urkwardrobe', 'equip')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Equip Outfit","",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    TriggerServerEvent("URK:equipWardrobeOutfit", c)
                end
            end,RMenu:Get("urkwardrobe", "listoutfits"))
            RageUI.Button("Delete Outfit","",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    TriggerServerEvent("URK:deleteWardrobeOutfit", c)
                end
            end,RMenu:Get("urkwardrobe", "listoutfits"))
        end, function()
        end)
    end
end)

local function i()
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get('urkwardrobe', 'mainmenu'), true)
end
local function j()
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get("urkwardrobe", "mainmenu"), false)
end
RegisterNetEvent("URK:openOutfitMenu",function(k)
    if k then
        b = k
    else
        TriggerServerEvent("URK:initWardrobe")
    end
    i()
end)
RegisterNetEvent("URK:refreshOutfitMenu",function(k)
    b = k
end)
RegisterNetEvent("URK:closeOutfitMenu",function()
    j()
end)