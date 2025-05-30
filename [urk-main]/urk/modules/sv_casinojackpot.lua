local jackpotChairs = {
    [0] = false,
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
    [15] = false,
}
local currentJackpotTotal = 0
local currentJackpotBets = {}
local numJackpotBets = 0
local currentJackpotInProgress = false

RegisterNetEvent("URK:requestJackpotChairData")
AddEventHandler("URK:requestJackpotChairData", function()   
    local source = source
    TriggerClientEvent('URK:sendJackpotChairData', source, jackpotChairs)
end)

RegisterNetEvent("URK:requestSitAtJackpot")
AddEventHandler("URK:requestSitAtJackpot", function(chair)   
    local source = source
    local user_id = URK.getUserId(source)
    if jackpotChairs[chair] == false then
        jackpotChairs[chair] = user_id
        TriggerClientEvent("URK:sitAtJackpotChair", source, chair)
    end
end)

RegisterNetEvent("URK:leaveJackpotChair")
AddEventHandler("URK:leaveJackpotChair", function()   
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(jackpotChairs) do
        if v == user_id then
            jackpotChairs[k] = false
        end
    end
end)

RegisterNetEvent("URK:setJackpotBet")
AddEventHandler("URK:setJackpotBet", function(betAmount)   
    local source = source
    local user_id = URK.getUserId(source)
    if not currentJackpotInProgress then
        MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
            chips = rows[1].chips
            if chips >= betAmount then
                MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = betAmount})
                currentJackpotBets[user_id] = {user_id = user_id, colour = {r = math.random(0,255), g = math.random(0,255), b = math.random(0,255), a = 255}, betAmount = betAmount, tickets_start = currentJackpotTotal, tickets_end = currentJackpotTotal + betAmount}
                currentJackpotTotal = currentJackpotTotal + betAmount
                numJackpotBets = numJackpotBets + 1
                TriggerClientEvent("URK:updateTotalPot", -1, currentJackpotTotal)
                TriggerClientEvent('URK:successJackpotBet', source)
                TriggerClientEvent('URK:newJackpotBet', -1, currentJackpotBets[user_id])
                TriggerClientEvent('URK:chipsUpdated', source)
                for k,v in pairs(currentJackpotBets) do
                    if URK.getUserSource(k) ~= nil then
                        TriggerClientEvent("URK:updatePlayerWinChance", URK.getUserSource(k), (v.betAmount/currentJackpotTotal)*100)
                    end
                end
            else 
                URKclient.notify(source,{"~r~Not enough chips!"})
            end
        end)
    else
        URKclient.notify(source,{"~r~Please wait for the next Jackpot."})
    end
end)

local winner = nil
local winnerName = nil
local winnerBetPercentage = nil
local winnerTicketsBought = nil
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if numJackpotBets >= 2 and not currentJackpotInProgress then
            TriggerClientEvent('URK:beginJackpot', -1)
            currentJackpotInProgress = true
            Wait(60000)
            local winningTicket = math.random(1, currentJackpotTotal)
            for k,v in pairs(currentJackpotBets) do
                if winningTicket >= v.tickets_start and winningTicket <= v.tickets_end then
                    winner = v.user_id
                    winnerName = GetPlayerName(URK.getUserSource(winner))
                    winnerBetPercentage = (v.betAmount/currentJackpotTotal)*100
                    winnerTicketsBought = v.betAmount
                end
            end
            TriggerClientEvent('URK:rollJackpot', -1, winner, winnerTicketsBought, winnerName, winnerBetPercentage, winner)
        end
    end
end)

RegisterNetEvent("URK:waitingOnWinConfirm")
AddEventHandler("URK:waitingOnWinConfirm", function()   
    local source = source
    local user_id = URK.getUserId(source)
    if user_id == winner then
        MySQL.execute("casinochips/add_chips", {user_id = winner, amount = currentJackpotTotal})
        TriggerClientEvent('URK:chipsUpdated', source)
        Wait(10000)
        TriggerClientEvent("URK:cleanupJackpot", -1)
        currentJackpotTotal = 0
        currentJackpotBets = {}
        winner = nil
        winnerName = nil
        winnerBetPercentage = nil
        winnerTicketsBought = nil
        currentJackpotInProgress = false
    end
end)