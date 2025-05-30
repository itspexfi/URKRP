local Housing = module("cfg/cfg_housing")
local isInMenu = false
local isInLeaveMenu = false
local isInWardrobeMenu = false
local currentHome = nil
local currentOutfit = nil
local currentHousePrice = 0
local owned = false
wardrobe = {}
ownedHouses = {}

RMenu.Add("URKHousing", "main", RageUI.CreateMenu("", "", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners","urk_homesui"))
RMenu.Add("URKHousing", "leave", RageUI.CreateMenu("", "", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight(),"banners","urk_homesui"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('URKHousing', 'main')) then
        maxKG = Housing.chestsize[currentHome] or 500
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator('Price: ~g~£'..getMoneyStringFormatted(currentHousePrice))
            RageUI.Separator('Storage: ~g~'..maxKG..'kg')
            RageUI.Button("Enter Home/Doorbell", nil, {RightLabel = ">>>"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("URKHousing:Enter", currentHome)
                end
            end)
            if owned ~= true then
                RageUI.Button("Buy Home", nil, {RightLabel = ">>>"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("URKHousing:Buy", currentHome)
                    end
                end)
            end
            RageUI.Button("Sell Home", nil, {RightLabel = ">>>"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("URKHousing:Sell", currentHome)
                end
            end)
            RageUI.Button("Rent Home", nil, {RightLabel = ">>>"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("URKHousing:Rent", currentHome)
                end
            end)
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('URKHousing', 'leave')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Leave Home", nil, {RightLabel = ">>>"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("URKHousing:Leave", currentHome)
                end
            end)
        end, function()
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not HasStreamedTextureDictLoaded("clothing") then
            RequestStreamedTextureDict("clothing", true)
            while not HasStreamedTextureDictLoaded("clothing") do
                Wait(1)
            end
        end
        for k, v in pairs(cfghomes.homes) do
            if isInArea(v.entry_point, 100) then
                DrawMarker(20, v.entry_point, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 25, 100, false, true, 2, false)
            end
            if isInArea(v.entry_point, 0.8) and isInMenu == false then 
                currentHome = k
                currentHousePrice = v.buy_price
                RMenu:Get("URKHousing", "main"):SetSubtitle("~r~" .. currentHome)
                RageUI.Visible(RMenu:Get("URKHousing", "main"), true)
                isInMenu = true
            end
            if isInArea(v.entry_point, 0.8) == false and isInMenu and currentHome == k then
                RageUI.Visible(RMenu:Get("URKHousing", "main"), false)
                isInMenu = false
            end
            if currentHome == k then
                -- Storage
                if tURK.isInHouse() then
                    DrawMarker(9, v.chest_point, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 0.8, 0.8, 0.8, 224, 224, 244, 1.0, false, false, 2, true, "dp_clothing", "bag", false)
                end
                if isInArea(v.chest_point, 0.8) and tURK.isInHouse() then
                    TriggerServerEvent('URK:FetchPersonalInventory')
                    inventoryType = 'Housing'
                    TriggerServerEvent('URK:FetchHouseInventory', currentHome)
                elseif isInArea(v.chest_point, 0.8) == false and tURK.isInHouse() then
                    -- Close the inventory when player walks away
                    if inventoryType == 'Housing' then
                        TriggerServerEvent('URK:CloseInventory')
                        inventoryType = ''
                    end
                end
                -- Wardrobe
                if tURK.isInHouse() then
                    --tURK.addMarker(v.wardrobe_point.x,v.wardrobe_point.y,v.wardrobe_point.z,0.6,0.6,0.6,10,255,81,170,50,9,false,false,true,"dp_clothing","top",90.0,90.0,0.0)
                    DrawMarker(9, v.wardrobe_point, 0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 0, 255, 60, false, true, 2, false, "clothing", "clothing", false)
                end
                if isInArea(v.wardrobe_point, 0.8) and isInWardrobeMenu == false and tURK.isInHouse() then
                    currentHome = k
                    TriggerEvent('URK:openOutfitMenu')
                    isInWardrobeMenu = true
                end
                if isInArea(v.wardrobe_point, 0.8) == false and isInWardrobeMenu and currentHome == k and tURK.isInHouse() then
                    TriggerEvent('URK:closeOutfitMenu')
                    isInWardrobeMenu = false
                end
                -- Leave House
                if tURK.isInHouse() then
                    DrawMarker(20, v.leave_point, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 25, 100, false, true, 2, false)
                end
                if isInArea(v.leave_point, 0.8) and isInLeaveMenu == false and tURK.isInHouse() then
                    currentHome = k
                    RMenu:Get("URKHousing", "leave"):SetSubtitle("~r~" .. currentHome)
                    RageUI.Visible(RMenu:Get("URKHousing", "leave"), true)
                    isInLeaveMenu = true
                end
                if isInArea(v.leave_point, 0.8) == false and isInLeaveMenu and currentHome == k and tURK.isInHouse() then
                    RageUI.Visible(RMenu:Get("URKHousing", "leave"), false)
                    isInLeaveMenu = false
                end
            end
        end
    end
end)

function isInArea(coords, distance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return Vdist2(playerCoords.x, playerCoords.y, playerCoords.z, coords.x, coords.y, coords.z) <= distance * distance
end



Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if tURK.isInHouse() then
        NetworkConcealPlayer(GetPlayerPed(-1), true, false)
    else 
        NetworkConcealPlayer(GetPlayerPed(-1), false, false)
    end
   end
end)


function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function getMoneyStringFormatted(cashString)
	local i, j, minus, int, fraction = tostring(cashString):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction 
end

function isInArea(v, dis) 
    if #(GetEntityCoords(PlayerPedId()) - v) <= dis then  
        return true
    else 
        return false
    end
end