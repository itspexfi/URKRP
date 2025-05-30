local coinflipTables = {
    [1] = false,
    [2] = false,
    [5] = false,
    [6] = false,
}

local linkedTables = {
    [1] = 2,
    [2] = 1,
    [5] = 6,
    [6] = 5,
}

local coinflipGameInProgress = {}
local coinflipGameData = {}

local betId = 0

function giveChips(source,amount)
    local user_id = URK.getUserId(source)
    MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = amount})
    TriggerClientEvent('URK:chipsUpdated', source)
end

AddEventHandler('playerDropped', function (reason)
    local source = source
    for k,v in pairs(coinflipTables) do
        if v == source then
            coinflipTables[k] = false
            coinflipGameData[k] = nil
        end
    end
end)

RegisterNetEvent("URK:requestCoinflipTableData")
AddEventHandler("URK:requestCoinflipTableData", function()   
    local source = source
    TriggerClientEvent("URK:sendCoinflipTableData",source,coinflipTables)
end)

RegisterNetEvent("URK:requestSitAtCoinflipTable")
AddEventHandler("URK:requestSitAtCoinflipTable", function(chairId)
    local source = source
    if source ~= nil then
        for k,v in pairs(coinflipTables) do
            if v == source then
                coinflipTables[k] = false
                return
            end
        end
        coinflipTables[chairId] = source
        local currentBetForThatTable = coinflipGameData[chairId]
        TriggerClientEvent("URK:sendCoinflipTableData",-1,coinflipTables)
        TriggerClientEvent("URK:sitAtCoinflipTable",source,chairId,currentBetForThatTable)
    end
end)

RegisterNetEvent("URK:leaveCoinflipTable")
AddEventHandler("URK:leaveCoinflipTable", function(chairId)
    local source = source
    if source ~= nil then 
        for k,v in pairs(coinflipTables) do 
            if v == source then 
                coinflipTables[k] = false
                coinflipGameData[k] = nil
            end
        end
        TriggerClientEvent("URK:sendCoinflipTableData",-1,coinflipTables)
    end
end)

RegisterNetEvent("URK:proposeCoinflip")
AddEventHandler("URK:proposeCoinflip",function(betAmount)
    local source = source
    local user_id = URK.getUserId(source)
    betId = betId+1
    if betAmount ~= nil then 
        if coinflipGameData[betId] == nil then
            coinflipGameData[betId] = {}
        end
        if not coinflipGameInProgress[betId] then
            if tonumber(betAmount) then
                betAmount = tonumber(betAmount)
                if betAmount >= 100000 then
                    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
                        chips = rows[1].chips
                        if chips >= betAmount then
                            TriggerClientEvent('URK:chipsUpdated', source)
                            if coinflipGameData[betId][source] == nil then
                                coinflipGameData[betId][source] = {}
                            end
                            coinflipGameData[betId] = {betId = betId, betAmount = betAmount, user_id = user_id}
                            for k,v in pairs(coinflipTables) do
                                if v == source then
                                    TriggerClientEvent('URK:addCoinflipProposal', source, betId, {betId = betId, betAmount = betAmount, user_id = user_id})
                                    if coinflipTables[linkedTables[k]] then
                                        TriggerClientEvent('URK:addCoinflipProposal', coinflipTables[linkedTables[k]], betId, {betId = betId, betAmount = betAmount, user_id = user_id})
                                    end
                                end
                            end
                            URKclient.notify(source,{"~g~Bet placed: " .. getMoneyStringFormatted(betAmount) .. " chips."})
                        else 
                            URKclient.notify(source,{"~r~Not enough chips!"})
                        end
                    end)
                else
                    URKclient.notify(source,{'~r~Minimum bet at this table is £100,000.'})
                    return
                end
            end
        end
    else
       URKclient.notify(source,{"~r~Error betting!"})
    end
end)

RegisterNetEvent("URK:requestCoinflipTableData")
AddEventHandler("URK:requestCoinflipTableData", function()   
    local source = source
    TriggerClientEvent("URK:sendCoinflipTableData",source,coinflipTables)
end)

RegisterNetEvent("URK:cancelCoinflip")
AddEventHandler("URK:cancelCoinflip", function()   
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(coinflipGameData) do
        if v.user_id == user_id then
            coinflipGameData[k] = nil
            TriggerClientEvent("URK:cancelCoinflipBet",-1,k)
        end
    end
end)

RegisterNetEvent("URK:acceptCoinflip")
AddEventHandler("URK:acceptCoinflip", function(gameid)   
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(coinflipGameData) do
        if v.betId == gameid then
            MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
                chips = rows[1].chips
                if chips >= v.betAmount then
                    MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = v.betAmount})
                    TriggerClientEvent('URK:chipsUpdated', source)
                    MySQL.execute("casinochips/remove_chips", {user_id = v.user_id, amount = v.betAmount})
                    TriggerClientEvent('URK:chipsUpdated', URK.getUserSource(v.user_id))
                    local coinFlipOutcome = math.random(0,1)
                    if coinFlipOutcome == 0 then
                        local game = {amount = v.betAmount, winner = GetPlayerName(source), loser = GetPlayerName(URK.getUserSource(v.user_id))}
                        TriggerClientEvent('URK:coinflipOutcome', source, true, game)
                        TriggerClientEvent('URK:coinflipOutcome', URK.getUserSource(v.user_id), false, game)
                        Wait(10000)
                        MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = v.betAmount*2})
                        TriggerClientEvent('URK:chipsUpdated', source)
                        tURK.sendWebhook('coinflip-bet',"URK Coinflip Logs", "> Winner Name: **"..GetPlayerName(source).."**\n> Winner TempID: **"..source.."**\n> Winner PermID: **"..user_id.."**\n> Loser Name: **"..GetPlayerName(URK.getUserSource(v.user_id)).."**\n> Loser TempID: **"..URK.getUserSource(v.user_id).."**\n> Loser PermID: **"..v.user_id.."**\n> Amount: **"..getMoneyStringFormatted(v.betAmount).."**")
                    else
                        local game = {amount = v.betAmount, winner = GetPlayerName(URK.getUserSource(v.user_id)), loser = GetPlayerName(source)}
                        TriggerClientEvent('URK:coinflipOutcome', source, false, game)
                        TriggerClientEvent('URK:coinflipOutcome', URK.getUserSource(v.user_id), true, game)
                        Wait(10000)
                        MySQL.execute("casinochips/add_chips", {user_id = v.user_id, amount = v.betAmount*2})
                        TriggerClientEvent('URK:chipsUpdated', URK.getUserSource(v.user_id))
                        tURK.sendWebhook('coinflip-bet',"URK Coinflip Logs", "> Winner Name: **"..GetPlayerName(URK.getUserSource(v.user_id)).."**\n> Winner TempID: **"..URK.getUserSource(v.user_id).."**\n> Winner PermID: **"..v.user_id.."**\n> Loser Name: **"..GetPlayerName(source).."**\n> Loser TempID: **"..source.."**\n> Loser PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(v.betAmount).."**")
                    end
                else 
                    URKclient.notify(source,{"~r~Not enough chips!"})
                end
            end)
        end
    end
end)

RegisterCommand('tables', function(source)
    print(json.encode(coinflipTables))
end)