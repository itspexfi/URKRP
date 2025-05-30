grindBoost = 2.0

local defaultPrices = {
    ["Weed"] = math.floor(1500*grindBoost),
    ["Cocaine"] = math.floor(2500*grindBoost),
    ["Meth"] = math.floor(3000*grindBoost),
    ["Heroin"] = math.floor(10000*grindBoost),
    ["LSDNorth"] = math.floor(18000*grindBoost),
    ["LSDSouth"] = math.floor(18000*grindBoost),
    ["Copper"] = math.floor(1000*grindBoost),
    ["Limestone"] = math.floor(2000*grindBoost),
    ["Gold"] = math.floor(4000*grindBoost),
    ["Diamond"] = math.floor(7000*grindBoost),
}

function URK.getCommissionPrice(drugtype)
    for k,v in pairs(turfData) do
        if v.name == drugtype then
            if v.commission == nil then
                v.commission = 0
            end
            if v.commission == 0 then
                return defaultPrices[drugtype]
            else
                return defaultPrices[drugtype]-defaultPrices[drugtype]*v.commission/100
            end
        end
    end
end

function URK.getCommission(drugtype)
    for k,v in pairs(turfData) do
        if v.name == drugtype then
            return v.commission
        end
    end
end

function URK.updateTraderInfo()
    TriggerClientEvent('URK:updateTraderCommissions', -1, 
    URK.getCommission('Weed'),
    URK.getCommission('Cocaine'),
    URK.getCommission('Meth'),
    URK.getCommission('Heroin'),
    URK.getCommission('LargeArms'),
    URK.getCommission('LSDNorth'),
    URK.getCommission('LSDSouth'))
    TriggerClientEvent('URK:updateTraderPrices', -1, 
    URK.getCommissionPrice('Weed'), 
    URK.getCommissionPrice('Cocaine'),
    URK.getCommissionPrice('Meth'),
    URK.getCommissionPrice('Heroin'),
    URK.getCommissionPrice('LSDNorth'),
    URK.getCommissionPrice('LSDSouth'),
    defaultPrices['Copper'],
    defaultPrices['Limestone'],
    defaultPrices['Gold'],
    defaultPrices['Diamond'])
end

RegisterNetEvent('URK:requestDrugPriceUpdate')
AddEventHandler('URK:requestDrugPriceUpdate', function()
    local source = source
	local user_id = URK.getUserId(source)
    URK.updateTraderInfo()
end)

local function checkTraderBucket(source)
    if GetPlayerRoutingBucket(source) ~= 0 then
        URKclient.notify(source, {'~r~You cannot sell drugs in this dimension.'})
        return false
    end
    return true
end

RegisterNetEvent('URK:sellCopper')
AddEventHandler('URK:sellCopper', function()
    local source = source
	local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Copper') > 0 then
            URK.tryGetInventoryItem(user_id, 'Copper', 1, false)
            URKclient.notify(source, {'~g~Sold Copper for £'..getMoneyStringFormatted(defaultPrices['Copper'])})
            URK.giveBankMoney(user_id, defaultPrices['Copper'])
        else
            URKclient.notify(source, {'~r~You do not have Copper.'})
        end
    end
end)

RegisterNetEvent('URK:sellLimestone')
AddEventHandler('URK:sellLimestone', function()
    local source = source
	local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Limestone') > 0 then
            URK.tryGetInventoryItem(user_id, 'Limestone', 1, false)
            URKclient.notify(source, {'~g~Sold Limestone for £'..getMoneyStringFormatted(defaultPrices['Limestone'])})
            URK.giveBankMoney(user_id, defaultPrices['Limestone'])
        else
            URKclient.notify(source, {'~r~You do not have Limestone.'})
        end
    end
end)

RegisterNetEvent('URK:sellGold')
AddEventHandler('URK:sellGold', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Gold') > 0 then
            URK.tryGetInventoryItem(user_id, 'Gold', 1, false)
            URKclient.notify(source, {'~g~Sold Gold for £'..getMoneyStringFormatted(defaultPrices['Gold'])})
            URK.giveBankMoney(user_id, defaultPrices['Gold'])
        else
            URKclient.notify(source, {'~r~You do not have Gold.'})
        end
    end
end)

RegisterNetEvent('URK:sellDiamond')
AddEventHandler('URK:sellDiamond', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Processed Diamond') > 0 then
            URK.tryGetInventoryItem(user_id, 'Processed Diamond', 1, false)
            URKclient.notify(source, {'~g~Sold Processed Diamond for £'..getMoneyStringFormatted(defaultPrices['Diamond'])})
            URK.giveBankMoney(user_id, defaultPrices['Diamond'])
        else
            URKclient.notify(source, {'~r~You do not have Diamond.'})
        end
    end
end)

RegisterNetEvent('URK:sellWeed')
AddEventHandler('URK:sellWeed', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Weed') > 0 then
            URK.tryGetInventoryItem(user_id, 'Weed', 1, false)
            URKclient.notify(source, {'~g~Sold Weed for £'..getMoneyStringFormatted(URK.getCommissionPrice('Weed'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('Weed'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('Weed'), 'Weed')
        else
            URKclient.notify(source, {'~r~You do not have Weed.'})
        end
    end
end)

RegisterNetEvent('URK:sellCocaine')
AddEventHandler('URK:sellCocaine', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Cocaine') > 0 then
            URK.tryGetInventoryItem(user_id, 'Cocaine', 1, false)
            URKclient.notify(source, {'~g~Sold Cocaine for £'..getMoneyStringFormatted(URK.getCommissionPrice('Cocaine'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('Cocaine'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('Cocaine'), 'Cocaine')
        else
            URKclient.notify(source, {'~r~You do not have Cocaine.'})
        end
    end
end)

RegisterNetEvent('URK:sellMeth')
AddEventHandler('URK:sellMeth', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Meth') > 0 then
            URK.tryGetInventoryItem(user_id, 'Meth', 1, false)
            URKclient.notify(source, {'~g~Sold Meth for £'..getMoneyStringFormatted(URK.getCommissionPrice('Meth'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('Meth'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('Meth'), 'Meth')
        else
            URKclient.notify(source, {'~r~You do not have Meth.'})
        end
    end
end)

RegisterNetEvent('URK:sellHeroin')
AddEventHandler('URK:sellHeroin', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'Heroin') > 0 then
            URK.tryGetInventoryItem(user_id, 'Heroin', 1, false)
            URKclient.notify(source, {'~g~Sold Heroin for £'..getMoneyStringFormatted(URK.getCommissionPrice('Heroin'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('Heroin'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('Heroin'), 'Heroin')
        else
            URKclient.notify(source, {'~r~You do not have Heroin.'})
        end
    end
end)

RegisterNetEvent('URK:sellLSDNorth')
AddEventHandler('URK:sellLSDNorth', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'LSD') > 0 then
            URK.tryGetInventoryItem(user_id, 'LSD', 1, false)
            URKclient.notify(source, {'~g~Sold LSD for £'..getMoneyStringFormatted(URK.getCommissionPrice('LSDNorth'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('LSDNorth'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('LSDNorth'), 'LSDNorth')
        else
            URKclient.notify(source, {'~r~You do not have LSD.'})
        end
    end
end)

RegisterNetEvent('URK:sellLSDSouth')
AddEventHandler('URK:sellLSDSouth', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        if URK.getInventoryItemAmount(user_id, 'LSD') > 0 then
            URK.tryGetInventoryItem(user_id, 'LSD', 1, false)
            URKclient.notify(source, {'~g~Sold LSD for £'..getMoneyStringFormatted(URK.getCommissionPrice('LSDSouth'))})
            URK.giveMoney(user_id, URK.getCommissionPrice('LSDSouth'))
            URK.turfSaleToGangFunds(URK.getCommissionPrice('LSDSouth'), 'LSDSouth')
        else
            URKclient.notify(source, {'~r~You do not have LSD.'})
        end
    end
end)

RegisterNetEvent('URK:sellAll')
AddEventHandler('URK:sellAll', function()
    local source = source
    local user_id = URK.getUserId(source)
    if checkTraderBucket(source) then
        for k,v in pairs(defaultPrices) do
            if k == 'Copper' or k == 'Limestone' or k == 'Gold' then
                if URK.getInventoryItemAmount(user_id, k) > 0 then
                    local amount = URK.getInventoryItemAmount(user_id, k)
                    URK.tryGetInventoryItem(user_id, k, amount, false)
                    URKclient.notify(source, {'~g~Sold '..k..' for £'..getMoneyStringFormatted(defaultPrices[k]*amount)})
                    URK.giveBankMoney(user_id, defaultPrices[k]*amount)
                end
            elseif k == 'Diamond' then
                if URK.getInventoryItemAmount(user_id, 'Processed Diamond') > 0 then
                    local amount = URK.getInventoryItemAmount(user_id, 'Processed Diamond')
                    URK.tryGetInventoryItem(user_id, 'Processed Diamond', amount, false)
                    URKclient.notify(source, {'~g~Sold '..'Processed Diamond'..' for £'..getMoneyStringFormatted(defaultPrices[k]*amount)})
                    URK.giveBankMoney(user_id, defaultPrices[k]*amount)
                end
            end
        end
    end
end)

RegisterCommand('testitem', function(source,args)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Founder') then
        URK.giveInventoryItem(user_id, args[1], 1, true)
    end
end)