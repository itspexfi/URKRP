MySQL = module("modules/MySQL")

local Inventory = module("URKVeh", "inventory")
local Housing = module("urk", "cfg/cfg_housing")
local InventorySpamTrack = {}
local LootBagEntities = {}
local InventoryCoolDown = {}
local a = module("URKFirearms", "cfg/weapons")

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if not InventorySpamTrack[source] then
            InventorySpamTrack[source] = true;
            local UserId = URK.getUserId(source) 
            local data = URK.getUserDataTable(UserId)
            if data and data.inventory then
                local FormattedInventoryData = {}
                for i,v in pairs(data.inventory) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                end
                TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(UserId))
                InventorySpamTrack[source] = false;
            else 
                --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
            end
        end
    end
end)

RegisterNetEvent('URK:FetchPersonalInventory')
AddEventHandler('URK:FetchPersonalInventory', function()
    local source = source
    if not InventorySpamTrack[source] then
        InventorySpamTrack[source] = true;
        local UserId = URK.getUserId(source) 
        local data = URK.getUserDataTable(UserId)
        if data and data.inventory then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
            end
            TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(UserId))
            InventorySpamTrack[source] = false;
        else 
            --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
        end
    end
end)


AddEventHandler('URK:RefreshInventory', function(source)
    local UserId = URK.getUserId(source) 
    local data = URK.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
        end
        TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)

RegisterNetEvent('URK:GiveItem')
AddEventHandler('URK:GiveItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if itemLoc == "Plr" then
        URK.RunGiveTask(source, itemId)
        TriggerEvent('URK:RefreshInventory', source)
    else
        URKclient.notify(source, {'~r~You need to have this item on you to give it.'})
    end
end)

RegisterNetEvent('URK:TrashItem')
AddEventHandler('URK:TrashItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if itemLoc == "Plr" then
        URK.RunTrashTask(source, itemId)
        TriggerEvent('URK:RefreshInventory', source)
    else
        URKclient.notify(source, {'~r~You need to have this item on you to drop it.'})
    end
end)

RegisterNetEvent('URK:FetchTrunkInventory')
AddEventHandler('URK:FetchTrunkInventory', function(spawnCode)
    local source = source
    local user_id = URK.getUserId(source)
    if InventoryCoolDown[source] then URKclient.notify(source, {'~r~Please wait before moving more items.'}) return end
    local carformat = "chest:u1veh_" .. spawnCode .. '|' .. user_id
    URK.getSData(carformat, function(cdata)
        local processedChest = {};
        cdata = json.decode(cdata) or {}
        local FormattedInventoryData = {}
        for i, v in pairs(cdata) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
        end
        local maxVehKg = Inventory.vehicle_chest_weights[spawnCode] or Inventory.default_vehicle_chest_weight
        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
        TriggerEvent('URK:RefreshInventory', source)
    end)
end)

local inHouse = {}
RegisterNetEvent('URK:FetchHouseInventory')
AddEventHandler('URK:FetchHouseInventory', function(nameHouse)
    local source = source
    local user_id = URK.getUserId(source)
    getUserByAddress(nameHouse, 1, function(huser_id)
        if huser_id == user_id then
            inHouse[user_id] = nameHouse
            local homeformat = "chest:u" .. user_id .. "home" ..inHouse[user_id]
            URK.getSData(homeformat, function(cdata)
                local processedChest = {};
                cdata = json.decode(cdata) or {}
                local FormattedInventoryData = {}
                for i, v in pairs(cdata) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                end
                local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
            end)
        else
            URKclient.notify(player,{"~r~You do not own this house!"})
        end
    end)
end)

local currentlySearching = {}
RegisterNetEvent('URK:cancelPlayerSearch')
AddEventHandler('URK:cancelPlayerSearch', function()
    local source = source
    local user_id = URK.getUserId(source) 
    if currentlySearching[user_id] ~= nil then
        TriggerClientEvent('URK:cancelPlayerSearch', currentlySearching[user_id])
    end
end)

RegisterNetEvent('URK:searchPlayer')
AddEventHandler('URK:searchPlayer', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source) 
    local data = URK.getUserDataTable(user_id)
    local their_id = URK.getUserId(playersrc) 
    local their_data = URK.getUserDataTable(their_id)
    if data and data.inventory and not currentlySearching[user_id] then
        currentlySearching[user_id] = playersrc
        TriggerClientEvent('URK:startSearchingSuspect', source)
        TriggerClientEvent('URK:startBeingSearching', playersrc, source)
        URKclient.notify(playersrc, {'~b~You are being searched.'})
        Wait(10000)
        if currentlySearching[user_id] then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
            end
            exports['ghmattimysql']:execute("SELECT * FROM urk_subscriptions WHERE user_id = @user_id", {user_id = user_id}, function(vipClubData)
                if #vipClubData > 0 then
                    if their_data and their_data.inventory then
                        local FormattedSecondaryInventoryData = {}
                        for i,v in pairs(their_data.inventory) do
                            FormattedSecondaryInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        if URK.getMoney(their_id) > 0 then
                            FormattedSecondaryInventoryData['cash'] = {amount = URK.getMoney(their_id), ItemName = 'Cash', Weight = 0.00}
                        end
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedSecondaryInventoryData, URK.computeItemsWeight(their_data.inventory), 200)
                    end
                    if vipClubData[1].plathours > 0 then
                        TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(user_id)+20)
                    elseif vipClubData[1].plushours > 0 then
                        TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(user_id)+10)
                    else
                        TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(user_id))
                    end
                    TriggerClientEvent('URK:InventoryOpen', source, true)
                    currentlySearching[user_id] = nil
                end
            end)
        end
    end
end)

local currentlyRobbing = {}
-- rob player where it gives you their inventory
RegisterNetEvent('URK:robPlayer')
AddEventHandler('URK:robPlayer', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.isPlayerSurrenderedNoProgressBar(playersrc, {}, function(is_surrendering_no_progress_bar) 
        if is_surrendering_no_progress_bar and not currentlyRobbing[user_id] then
            TriggerClientEvent('URK:startRobbingPlayer', playersrc)
            currentlyRobbing[user_id] = playersrc
            Wait(500)
            URKclient.isPlayerSurrendered(playersrc, {}, function(is_surrendering)
                if is_surrendering then
                    TriggerClientEvent('URK:endRobbingPlayer', playersrc)
                    if not InventorySpamTrack[source] then
                        InventorySpamTrack[source] = true;
                        local data = URK.getUserDataTable(user_id)
                        local their_id = URK.getUserId(playersrc) 
                        local their_data = URK.getUserDataTable(their_id)
                        if data and data.inventory then
                            local FormattedInventoryData = {}
                            for i,v in pairs(data.inventory) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                            end
                            if their_data and their_data.inventory then
                                local FormattedSecondaryInventoryData = {}
                                for i,v in pairs(their_data.inventory) do
                                    URK.giveInventoryItem(user_id, i, v.amount)
                                    URK.tryGetInventoryItem(their_id, i, v.amount)
                                end
                            end
                            if URK.getMoney(their_id) > 0 then
                                URK.giveMoney(user_id, URK.getMoney(their_id))
                                URK.tryPayment(their_id, URK.getMoney(their_id))
                            end
                            TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(user_id))
                            TriggerClientEvent('URK:InventoryOpen', source, true)
                            InventorySpamTrack[source] = false;
                            currentlyRobbing[user_id] = nil
                        end
                    end
                end
            end)
        end
    end)
end)
RegisterNetEvent('URK:UseItem')
AddEventHandler('URK:UseItem', function(itemId, itemLoc)
    local source = source
    local user_id = URK.getUserId(source) 
    local data = URK.getUserDataTable(user_id)
    if not itemId then URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if itemLoc == "Plr" then
        tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                local invcap = 30
                if plathours > 0 then
                    invcap = 50
                elseif plushours > 0 then
                    invcap = 40
                end
                if URK.getInventoryMaxWeight(user_id) ~= nil then
                    if URK.getInventoryMaxWeight(user_id) > invcap then
                        return
                    end
                end
                if itemId == "offwhitebag" then
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+15)
                    TriggerClientEvent('URK:boughtBackpack', source, 5, 92, 0,40000,15, 'Off White Bag (+15kg)')
                elseif itemId == "guccibag" then 
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+20)
                    TriggerClientEvent('URK:boughtBackpack', source, 5, 94, 0,60000,20, 'Gucci Bag (+20kg)')
                elseif itemId == "nikebag" then 
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+30)
                elseif itemId == "huntingbackpack" then 
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+35)
                    TriggerClientEvent('URK:boughtBackpack', source, 5, 91, 0,100000,35, 'Hunting Backpack (+35kg)')
                elseif itemId == "greenhikingbackpack" then 
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+40)
                elseif itemId == "rebelbackpack" then 
                    URK.tryGetInventoryItem(user_id, itemId, 1, true)
                    URK.updateInvCap(user_id, invcap+70)
                    TriggerClientEvent('URK:boughtBackpack', source, 5, 90, 0,250000,70, 'Rebel Backpack (+70kg)')
                elseif itemId == "Shaver" then 
                    URK.ShaveHead(source)
                elseif itemId == "handcuffkeys" then 
                    URK.handcuffKeys(source)
                end
                TriggerEvent('URK:RefreshInventory', source)
            end
        end)  
    end
    if itemLoc == "Plr" then
        URK.RunInventoryTask(source, itemId)
        TriggerEvent('URK:RefreshInventory', source)
    else
        URKclient.notify(source, {'~r~You need to have this item on you to use it.'})
    end
end)

RegisterNetEvent('URK:UseAllItem')
AddEventHandler('URK:UseAllItem', function(itemId, itemLoc)
    local source = source
    local user_id = URK.getUserId(source) 
    if not itemId then URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if itemLoc == "Plr" then
        URK.LoadAllTask(source, itemId)
        TriggerEvent('URK:RefreshInventory', source)
    else
        URKclient.notify(source, {'~r~You need to have this item on you to use it.'})
    end
end)


RegisterNetEvent('URK:MoveItem')
AddEventHandler('URK:MoveItem', function(inventoryType, itemId, inventoryInfo, Lootbag)
    local source = source
    local UserId = URK.getUserId(source) 
    local data = URK.getUserDataTable(UserId)
    if InventoryCoolDown[source] then URKclient.notify(source, {'~r~Please wait before moving more items.'}) return end
    if not itemId then URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. UserId
            URK.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = URK.getInventoryWeight(UserId)+URK.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('URK:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        URK.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = false;
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                else 
                    InventoryCoolDown[source] = false;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end)
        elseif inventoryType == "LootBag" then  
            if itemId ~= nil then  
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = URK.getInventoryWeight(UserId)+URK.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > 1 then
                            LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - 1 
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        end
                        local FormattedInventoryData = {}
                        for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        local maxVehKg = 200
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                        TriggerEvent('URK:RefreshInventory', source)
                        InventoryCoolDown[source] = false
                        if not next(LootBagEntities[inventoryInfo].Items) then
                            CloseInv(source)
                        end
                    else 
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                end
            end
        elseif inventoryType == "Housing" then
            InventoryCoolDown[source] = true
            local homeformat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
            URK.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = URK.getInventoryWeight(UserId)+URK.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            URK.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('URK:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                    else 
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                else 
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "home" then --start of housing intergration (moveitem)
                        local homeFormat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
                        URK.getSData(homeFormat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = URK.computeItemsWeight(cdata)+URK.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                if weightCalculation <= maxVehKg then
                                    if URK.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                        cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                    TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('URK:RefreshInventory', source)
                                    URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                                else 
                                    URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end) --end of housing intergration (moveitem)
                    else
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. UserId
                        URK.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = URK.computeItemsWeight(cdata)+URK.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if URK.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                        cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('URK:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    URK.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)



RegisterNetEvent('URK:MoveItemX')
AddEventHandler('URK:MoveItemX', function(inventoryType, itemId, inventoryInfo, Lootbag, Quantity)
    local source = source
    local UserId = URK.getUserId(source) 
    local data = URK.getUserDataTable(UserId)
    if InventoryCoolDown[source] then URKclient.notify(source, {'~r~Please wait before moving more items.'}) return end
    if not itemId then  URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            if Quantity >= 1 then
                local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. UserId
                URK.getSData(carformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = URK.getInventoryWeight(UserId)+(URK.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                            end
                            local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                            TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('URK:RefreshInventory', source)
                            InventoryCoolDown[source] = nil;
                            URK.setSData(carformat, json.encode(cdata))
                        else 
                            InventoryCoolDown[source] = nil;
                            URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                        end
                    else 
                        InventoryCoolDown[source] = nil;
                        URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                    end
                end)
            else
                InventoryCoolDown[source] = nil;
                URKclient.notify(source, {'~r~Invalid Amount!'})
            end
        elseif inventoryType == "LootBag" then    
            if LootBagEntities[inventoryInfo].Items[itemId] then 
                Quantity = parseInt(Quantity)
                if Quantity then
                    local weightCalculation = URK.getInventoryWeight(UserId)+(URK.getItemWeight(itemId) * Quantity)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        if Quantity <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > Quantity then
                                LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - Quantity
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                LootBagEntities[inventoryInfo].Items[itemId] = nil;
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            end
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('URK:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                            end
                        else 
                            URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                        end 
                    else 
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                else 
                    URKclient.notify(source, {'~r~Invalid input!'})
                end
            end
        elseif inventoryType == "Housing" then
            Quantity = parseInt(Quantity)
            if Quantity then
                local homeformat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
                URK.getSData(homeformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = URK.getInventoryWeight(UserId)+(URK.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                URK.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                            end
                            local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                            TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('URK:RefreshInventory', source)
                            URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                        else 
                            URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                        end
                    else 
                        URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                    end
                end)
            else 
                URKclient.notify(source, {'~r~Invalid input!'})
            end
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "home" then --start of housing intergration (moveitemx)
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local homeFormat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
                            URK.getSData(homeFormat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = URK.computeItemsWeight(cdata)+(URK.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                    if weightCalculation <= maxVehKg then
                                        if URK.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                        end
                                        local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('URK:RefreshInventory', source)
                                        URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                                    else 
                                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                    end
                                else 
                                    URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                                end
                            end)
                        else 
                            URKclient.notify(source, {'~r~Invalid input!'})
                        end
                    else
                        InventoryCoolDown[source] = true;
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. UserId
                            URK.getSData(carformat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = URK.computeItemsWeight(cdata)+(URK.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    if weightCalculation <= maxVehKg then
                                        if URK.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                        end
                                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('URK:RefreshInventory', source)
                                        InventoryCoolDown[source] = nil;
                                        URK.setSData(carformat, json.encode(cdata))
                                    else 
                                        InventoryCoolDown[source] = nil;
                                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                    end
                                else 
                                    InventoryCoolDown[source] = nil;
                                    URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                                end
                            end)
                        else 
                            URKclient.notify(source, {'~r~Invalid input!'})
                        end
                    end
                else
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


RegisterNetEvent('URK:MoveItemAll')
AddEventHandler('URK:MoveItemAll', function(inventoryType, itemId, inventoryInfo, vehid)
    local source = source
    local UserId = URK.getUserId(source) 
    local data = URK.getUserDataTable(UserId)
    if not itemId then URKclient.notify(source, {'~r~You need to select an item, first!'}) return end
    if InventoryCoolDown[source] then URKclient.notify(source, {'~r~Please wait before moving more items.'}) return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local idz = NetworkGetEntityFromNetworkId(vehid)
            local user_id = URK.getUserId(NetworkGetEntityOwner(idz))
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. user_id
            URK.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = URK.getInventoryWeight(user_id)+(URK.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    local amount = cdata[itemId].amount
                    if weightCalculation > URK.getInventoryMaxWeight(user_id) and URK.getInventoryWeight(user_id) ~= URK.getInventoryMaxWeight(user_id) then
                        amount = math.floor((URK.getInventoryMaxWeight(user_id)-URK.getInventoryWeight(user_id)) / URK.getItemWeight(itemId))
                    end
                    if math.floor(amount) > 0 or (weightCalculation <= URK.getInventoryMaxWeight(user_id)) then
                        URK.giveInventoryItem(user_id, itemId, amount, true)
                        local FormattedInventoryData = {}
                        if (cdata[itemId].amount - amount) > 0 then
                            cdata[itemId].amount = cdata[itemId].amount - amount
                        else
                            cdata[itemId] = nil
                        end
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('URK:RefreshInventory', source)
                        InventoryCoolDown[source] = nil;
                        URK.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = nil;
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                else 
                    InventoryCoolDown[source] = nil;
                    URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                end
            end)
        elseif inventoryType == "LootBag" then
            if itemId ~= nil then    
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = URK.getInventoryWeight(UserId)+(URK.getItemWeight(itemId) *  LootBagEntities[inventoryInfo].Items[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        if  LootBagEntities[inventoryInfo].Items[itemId].amount <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            URK.giveInventoryItem(UserId, itemId, LootBagEntities[inventoryInfo].Items[itemId].amount, true)
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('URK:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                            end
                        else 
                            URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                        end 
                    else 
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                end
            end
        elseif inventoryType == "Housing" then
            local homeformat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
            URK.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = URK.getInventoryWeight(UserId)+(URK.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= URK.getInventoryMaxWeight(UserId) then
                        URK.giveInventoryItem(UserId, itemId, cdata[itemId].amount, true)
                        cdata[itemId] = nil;
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                        TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('URK:RefreshInventory', source)
                        URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                    else 
                        URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                    end
                else 
                    URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "home" then
                        local homeFormat = "chest:u" .. UserId .. "home" ..inHouse[user_id]
                        URK.getSData(homeFormat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = URK.computeItemsWeight(cdata)+(URK.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                if weightCalculation <= maxVehKg then
                                    if URK.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end 
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                                    TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('URK:RefreshInventory', source)
                                    URK.setSData("chest:u" .. UserId .. "home" ..inHouse[user_id], json.encode(cdata))
                                else 
                                    URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                end
                            else 
                                URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                            end
                        end) --end of housing intergration (moveitemall)
                    else 
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. UserId
                        URK.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = URK.computeItemsWeight(cdata)+(URK.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if URK.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('URK:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    URK.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    URKclient.notify(source, {'~r~You do not have enough inventory space.'})
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                URKclient.notify(source, {'~r~You are trying to move more then there actually is!'})
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


-- LOOTBAGS CODE BELOW HERE 

RegisterNetEvent('URK:InComa')
AddEventHandler('URK:InComa', function()
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.isInComa(source, {}, function(in_coma) 
        if in_coma then
            Wait(1500)
            local weight = URK.getInventoryWeight(user_id)
            if weight == 0 then return end
            local model = GetHashKey('xs_prop_arena_bag_01')
            local name1 = GetPlayerName(source)
            local lootbag = CreateObjectNoOffset(model, GetEntityCoords(GetPlayerPed(source)) + 0.2, true, true, false)
            local lootbagnetid = NetworkGetNetworkIdFromEntity(lootbag)
            SetEntityRoutingBucket(lootbag, GetPlayerRoutingBucket(source))
            local ndata = URK.getUserDataTable(user_id)
            local stored_inventory = nil;
            TriggerEvent('URK:StoreWeaponsRequest', source)
            LootBagEntities[lootbagnetid] = {lootbag, lootbag, false, source}
            LootBagEntities[lootbagnetid].Items = {}
            LootBagEntities[lootbagnetid].name = name1 
            if ndata ~= nil then
                if ndata.inventory ~= nil then
                    stored_inventory = ndata.inventory
                    URK.clearInventory(user_id)
                    for k, v in pairs(stored_inventory) do
                        LootBagEntities[lootbagnetid].Items[k] = {}
                        LootBagEntities[lootbagnetid].Items[k].amount = v.amount
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('URK:LootBag')
AddEventHandler('URK:LootBag', function(netid)
    local source = source
    URKclient.isInComa(source, {}, function(in_coma) 
        if not in_coma and not tURK.createCamera then
            if LootBagEntities[netid] then
                LootBagEntities[netid][3] = true;
                local user_id = URK.getUserId(source)
                if user_id ~= nil then
                    TriggerClientEvent("urk:PlaySound", source, "zipper")
                    LootBagEntities[netid][5] = source
                    if URK.hasPermission(user_id, "police.armoury") then
                        URKclient.startCircularProgressBar(source, {"", 3000, nil})
                        Wait(3000)
                        local bagData = LootBagEntities[netid].Items
                        if bagData == nil then return end
                        for a,b in pairs(bagData) do
                            if string.find(a, 'wbody|') then
                                c = a:gsub('wbody|', '')
                                bagData[c] = b
                                bagData[a] = nil
                            end
                        end
                        for k,v in pairs(a.weapons) do
                            if bagData[k] ~= nil then
                                if not v.policeWeapon then
                                    URKclient.notify(source, {'~r~Seized '..v.name..' x'..bagData[k].amount..'.'})
                                    bagData[k] = nil
                                end
                            end
                        end
                        for c,d in pairs(bagData) do
                            if seizeBullets[c] then
                                URKclient.notify(source, {'~r~Seized '..c..' x'..d.amount..'.'})
                                bagData[c] = nil
                            end
                        end
                        LootBagEntities[netid].Items = bagData
                        URKclient.notify(source,{"~r~You have seized " .. LootBagEntities[netid].name .. "'s items"})
                        if #LootBagEntities[netid].Items > 0 then
                            OpenInv(source, netid, LootBagEntities[netid].Items)
                        end
                    else
                        OpenInv(source, netid, LootBagEntities[netid].Items)
                    end  
                end
            else
                URKclient.notify(source, {'~r~This loot bag is unavailable.'})
            end
        else 
            URKclient.notify(source, {'~r~You cannot open this while dead silly.'})
        end
    end)
end)

Citizen.CreateThread(function()
    while true do 
        Wait(250)
        for i,v in pairs(LootBagEntities) do 
            if v[5] then 
                local coords = GetEntityCoords(GetPlayerPed(v[5]))
                local objectcoords = GetEntityCoords(v[1])
                if #(objectcoords - coords) > 5.0 then
                    CloseInv(v[5])
                    Wait(3000)
                    v[3] = false; 
                    v[5] = nil;
                end
            end
        end
    end
end)

RegisterNetEvent('URK:CloseLootbag')
AddEventHandler('URK:CloseLootbag', function()
    local source = source
    for i,v in pairs(LootBagEntities) do 
        if v[5] and v[5] == source then 
            CloseInv(v[5])
            Wait(3000)
            v[3] = false; 
            v[5] = nil;
        end
    end
end)

function CloseInv(source)
    TriggerClientEvent('URK:InventoryOpen', source, false, false)
end

function OpenInv(source, netid, LootBagItems)
    local UserId = URK.getUserId(source)
    local data = URK.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
        end
        TriggerClientEvent('URK:FetchPersonalInventory', source, FormattedInventoryData, URK.computeItemsWeight(data.inventory), URK.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
    TriggerClientEvent('URK:InventoryOpen', source, true, true, netid)
    local FormattedInventoryData = {}
    for i, v in pairs(LootBagItems) do
        FormattedInventoryData[i] = {amount = v.amount, ItemName = URK.getItemName(i), Weight = URK.getItemWeight(i)}
    end
    local maxVehKg = 200
    TriggerClientEvent('URK:SendSecondaryInventoryData', source, FormattedInventoryData, URK.computeItemsWeight(LootBagItems), maxVehKg)
end


-- Garabge collector for empty lootbags.
Citizen.CreateThread(function()
    while true do 
        Wait(500)
        for i,v in pairs(LootBagEntities) do 
            local itemCount = 0;
            for i,v in pairs(v.Items) do
                itemCount = itemCount + 1
            end
            if itemCount == 0 then
                if DoesEntityExist(v[1]) then 
                    DeleteEntity(v[1])
                    LootBagEntities[i] = nil;
                end
            end
        end
    end
end)


local useing = {}

RegisterNetEvent('URK:attemptLockpick')
AddEventHandler('URK:attemptLockpick', function(veh, netveh)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.tryGetInventoryItem(user_id, 'Lockpick', 1, true) then
        local chance = math.random(1,8)
        if chance == 1 then
            TriggerClientEvent('URK:lockpickClient', source, veh, true)
        else
            TriggerClientEvent('URK:lockpickClient', source, veh, false)
        end
    end
end)

RegisterNetEvent('URK:lockpickVehicle')
AddEventHandler('URK:lockpickVehicle', function(spawncode, ownerid)
    local source = source
    local user_id = URK.getUserId(source)
    
end)

RegisterNetEvent('URK:setVehicleLock')
AddEventHandler('URK:setVehicleLock', function(netid)
    local source = source
    local user_id = URK.getUserId(source)
    if usersLockpicking[user_id] then
        SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(netid), false)
    end
end)