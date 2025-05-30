RegisterServerEvent("URK:getCommunityPotAmount")
AddEventHandler("URK:getCommunityPotAmount", function()
    local source = source
    local user_id = URK.getUserId(source)
    exports['ghmattimysql']:execute("SELECT value FROM urk_community_pot", function(potbalance)
        if potbalance and potbalance[1] and potbalance[1].value then
            TriggerClientEvent('URK:gotCommunityPotAmount', source, tonumber(potbalance[1].value))
        else
            -- Handle the case when potbalance is nil or does not contain the expected data
        end
    end)
end)

RegisterServerEvent("URK:tryDepositCommunityPot")
AddEventHandler("URK:tryDepositCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['ghmattimysql']:execute("SELECT value FROM urk_community_pot", function(potbalance)
            if potbalance and potbalance[1] and potbalance[1].value then
                if URK.tryFullPayment(user_id, amount) then
                    local newpotbalance = tonumber(potbalance[1].value) + amount
                    exports['ghmattimysql']:execute("UPDATE urk_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                    TriggerClientEvent('URK:gotCommunityPotAmount', source, newpotbalance)
                    tURK.sendWebhook('com-pot', 'URK Community Pot Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Deposit**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
                end
            else
                -- Handle the case when potbalance is nil or does not contain the expected data
            end
        end)
    end
end)

RegisterServerEvent("URK:tryWithdrawCommunityPot")
AddEventHandler("URK:tryWithdrawCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['ghmattimysql']:execute("SELECT value FROM urk_community_pot", function(potbalance)
            if potbalance and potbalance[1] and potbalance[1].value then
                if tonumber(potbalance[1].value) >= amount then
                    local newpotbalance = tonumber(potbalance[1].value) - amount
                    exports['ghmattimysql']:execute("UPDATE urk_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                    TriggerClientEvent('URK:gotCommunityPotAmount', source, newpotbalance)
                    URK.giveMoney(user_id, amount)
                    tURK.sendWebhook('com-pot', 'URK Community Pot Logs', "> Admin Name: **"..GetPlayerName(source).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Withdraw**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
                end
            else
                -- Handle the case when potbalance is nil or does not contain the expected data
            end
        end)
    end
end)

RegisterServerEvent("URK:addToCommunityPot")
AddEventHandler("URK:addToCommunityPot", function(amount)
    if source ~= '' then return end
    exports['ghmattimysql']:execute("SELECT value FROM urk_community_pot", function(potbalance)
        if potbalance and potbalance[1] and potbalance[1].value then
            local newpotbalance = tonumber(potbalance[1].value) + amount
            exports['ghmattimysql']:execute("UPDATE urk_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
        else
            -- Handle the case when potbalance is nil or does not contain the expected data
        end
    end)
end)
