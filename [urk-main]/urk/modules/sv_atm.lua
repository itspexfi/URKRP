local lang = URK.lang
RegisterNetEvent('URK:Withdraw')
AddEventHandler('URK:Withdraw', function(amount)
    local source = source
    local amount = parseInt(amount)
    if amount > 0 then
        local user_id = URK.getUserId(source)
        if user_id ~= nil then
            if URK.tryWithdraw(user_id, amount) then
                URKclient.notify(source, {lang.atm.withdraw.withdrawn({amount})})
            else
                URKclient.notify(source, {lang.atm.withdraw.not_enough()})
            end
        end
    else
        URKclient.notify(source, {lang.common.invalid_value()})
    end
end)


RegisterNetEvent('URK:Deposit')
AddEventHandler('URK:Deposit', function(amount)
    local source = source
    local amount = parseInt(amount)
    if amount > 0 then
        local user_id = URK.getUserId(source)
        if user_id ~= nil then
            if URK.tryDeposit(user_id, amount) then
                URKclient.notify(source, {lang.atm.deposit.deposited({amount})})
            else
                URKclient.notify(source, {lang.money.not_enough()})
            end
        end
    else
        URKclient.notify(source, {lang.common.invalid_value()})
    end
end)

RegisterNetEvent('URK:WithdrawAll')
AddEventHandler('URK:WithdrawAll', function()
    local source = source
    local amount = URK.getBankMoney(URK.getUserId(source))
    if amount > 0 then
        local user_id = URK.getUserId(source)
        if user_id ~= nil then
            if URK.tryWithdraw(user_id, amount) then
                URKclient.notify(source, {lang.atm.withdraw.withdrawn({amount})})
            else
                URKclient.notify(source, {lang.atm.withdraw.not_enough()})
            end
        end
    else
        URKclient.notify(source, {lang.common.invalid_value()})
    end
end)


RegisterNetEvent('URK:DepositAll')
AddEventHandler('URK:DepositAll', function()
    local source = source
    local amount = URK.getMoney(URK.getUserId(source))
    if amount > 0 then
        local user_id = URK.getUserId(source)
        if user_id ~= nil then
            if URK.tryDeposit(user_id, amount) then
                URKclient.notify(source, {lang.atm.deposit.deposited({amount})})
            else
                URKclient.notify(source, {lang.money.not_enough()})
            end
        end
    else
        URKclient.notify(source, {lang.common.invalid_value()})
    end
end)