local cfg = module("cfg/cfg_stores")

RMenu.Add('URKStores', 'main', RageUI.CreateMenu("", "~r~Shop", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(), 'banners', 'urk_toreui'))
RMenu.Add("URKStores", "confirm", RageUI.CreateSubMenu(RMenu:Get('URKStores', 'main',  tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight())))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("URKStores", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(cfg.shopItems) do
                RageUI.Button(v.name, nil, {RightLabel = "~g~£".. getMoneyStringFormatted(v.price)}, true, function(Hovered, Active, Selected)
                    if Selected then
                        cPrice = v.price
                        cHash = v.itemID
                        cName = v.name
                    end
                end, RMenu:Get("URKStores", "confirm"))
            end
        end)
    end
end)

local ShopAMT = {
    '1','2','3','4','5','6','7','8','9','10'
}

local Index = 1
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("URKStores", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("Item Name: " .. cName, function() end)
            RageUI.Separator("Item Price: £" .. getMoneyStringFormatted(cPrice * Index), function() end)
            RageUI.List(cName, ShopAMT, Index, nil, {}, true, function(Hovered, Active, Selected, AIndex)
                Index = AIndex
            end)
            RageUI.Button("Confirm Purchase" , nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("URK:BuyStoreItem", cHash, tonumber(Index))
                end
            end, RMenu:Get("URKStores", "main")) 
        end) 
    end
end)


local inMenu = false
local currentShop = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(cfg.shops) do
            if isInArea(v, 100.0) then
                DrawMarker(29, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 14, 212, 0, 250, true, true, false, false, nil, nil, false)
            end
            if isInArea(v, 1.0) and inMenu == false then
                alert('Press ~INPUT_VEH_HORN~ to open the Store')
                if IsControlJustPressed(0, 51) then 
                    inMenu = true
                    currentShop = k
                    PlaySound(-1,"Hit","RESPAWN_SOUNDSET",0,0,1)
                    RageUI.Visible(RMenu:Get("URKStores", "main"), true)
                    cLoaction = v
                end
            end
            if isInArea(v, 1.0) == false and inMenu and k == currentShop then
                inMenu = false
                currentShop = nil
                RageUI.ActuallyCloseAll()
            end
        end
    end
end)