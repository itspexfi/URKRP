inMenu = true
local bank = 0
function setBankBalance (value)
    bank = value
    SendNUIMessage({event = 'updateBankbalance', banking = bank})
end

RegisterNetEvent("URK:initMoney")
AddEventHandler("URK:initMoney", function(walletMoney, bankMoney)
    local bank = bankMoney
end)

RegisterNetEvent("URK:setDisplayBankMoney", function(value)
    setBankBalance(value)
end)

RegisterNUICallback("bank_transfer", function(data) 
    TriggerServerEvent("URK:bankTransfer", data.user_id, data.amount)
end)