local lang = URK.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

MySQL.createCommand("URK/money_init_user","INSERT IGNORE INTO urk_user_moneys(user_id,wallet,bank) VALUES(@user_id,@wallet,@bank)")
MySQL.createCommand("URK/get_money","SELECT wallet,bank FROM urk_user_moneys WHERE user_id = @user_id")
MySQL.createCommand("URK/set_money","UPDATE urk_user_moneys SET wallet = @wallet, bank = @bank WHERE user_id = @user_id")

-- get money
-- cbreturn nil if error
function URK.getMoney(user_id)
  local tmp = URK.getUserTmpTable(user_id)
  if tmp then
    return tmp.wallet or 0
  else
    return 0
  end
end

-- set money
function URK.setMoney(user_id,value)
  local tmp = URK.getUserTmpTable(user_id)
  if tmp then
    tmp.wallet = value
  end

  -- update client display
  local source = URK.getUserSource(user_id)
  if source ~= nil then
    URKclient.setDivContent(source,{"money",lang.money.display({Comma(URK.getMoney(user_id))})})
    TriggerClientEvent('URK:initMoney', source, URK.getMoney(user_id), URK.getBankMoney(user_id))
  end
end

-- try a payment
-- return true or false (debited if true)
function URK.tryPayment(user_id,amount)
  local money = URK.getMoney(user_id)
  if amount >= 0 and money >= amount then
    URK.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

function URK.tryBankPayment(user_id,amount)
  local bank = URK.getBankMoney(user_id)
  if amount >= 0 and bank >= amount then
    URK.setBankMoney(user_id,bank-amount)
    return true
  else
    return false
  end
end

-- give money
function URK.giveMoney(user_id,amount)
  local money = URK.getMoney(user_id)
  URK.setMoney(user_id,money+amount)
end

-- get bank money
function URK.getBankMoney(user_id)
  local tmp = URK.getUserTmpTable(user_id)
  if tmp then
    return tmp.bank or 0
  else
    return 0
  end
end

-- set bank money
function URK.setBankMoney(user_id,value)
  local tmp = URK.getUserTmpTable(user_id)
  if tmp then
    tmp.bank = value
  end
  local source = URK.getUserSource(user_id)
  if source ~= nil then
    URKclient.setDivContent(source,{"bmoney",lang.money.bdisplay({Comma(URK.getBankMoney(user_id))})})
    TriggerClientEvent('URK:initMoney', source, URK.getMoney(user_id), URK.getBankMoney(user_id))
  end
end

-- give bank money
function URK.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = URK.getBankMoney(user_id)
    URK.setBankMoney(user_id,money+amount)
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function URK.tryWithdraw(user_id,amount)
  local money = URK.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    URK.setBankMoney(user_id,money-amount)
    URK.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function URK.tryDeposit(user_id,amount)
  if amount > 0 and URK.tryPayment(user_id,amount) then
    URK.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function URK.tryFullPayment(user_id,amount)
  local money = URK.getMoney(user_id)
  if money >= amount then -- enough, simple payment
    return URK.tryPayment(user_id, amount)
  else  -- not enough, withdraw -> payment
    if URK.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
      return URK.tryPayment(user_id, amount)
    end
  end

  return false
end

local startingCash = 50000
local startingBank = 250000

-- events, init user account if doesn't exist at connection
AddEventHandler("URK:playerJoin",function(user_id,source,name,last_login)
  MySQL.query("URK/money_init_user", {user_id = user_id, wallet = startingCash, bank = startingBank}, function(affected)
    local tmp = URK.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("URK/get_money", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
          tmp.bank = rows[1].bank
          tmp.wallet = rows[1].wallet
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("URK:playerLeave",function(user_id,source)
  -- (wallet,bank)
  local tmp = URK.getUserTmpTable(user_id)
  if tmp and tmp.wallet ~= nil and tmp.bank ~= nil then
    MySQL.execute("URK/set_money", {user_id = user_id, wallet = tmp.wallet, bank = tmp.bank})
  end
end)

-- save money (at same time that save datatables)
AddEventHandler("URK:save", function()
  for k,v in pairs(URK.user_tmp_tables) do
    if v.wallet ~= nil and v.bank ~= nil then
      MySQL.execute("URK/set_money", {user_id = k, wallet = v.wallet, bank = v.bank})
    end
  end
end)

RegisterNetEvent('URK:giveCashToPlayer')
AddEventHandler('URK:giveCashToPlayer', function(nplayer)
  local source = source
  local user_id = URK.getUserId(source)
  if user_id ~= nil then
    if nplayer ~= nil then
      local nuser_id = URK.getUserId(nplayer)
      if nuser_id ~= nil then
        URK.prompt(source,lang.money.give.prompt(),"",function(source,amount)
          local amount = parseInt(amount)
          if amount > 0 and URK.tryPayment(user_id,amount) then
            URK.giveMoney(nuser_id,amount)
            URKclient.notify(source,{lang.money.given({getMoneyStringFormatted(math.floor(amount))})})
            URKclient.notify(nplayer,{lang.money.received({getMoneyStringFormatted(math.floor(amount))})})
            tURK.sendWebhook('give-cash', "URK Give Cash Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..GetPlayerName(nplayer).."**\n> Target PermID: **"..nuser_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**")
          else
            URKclient.notify(source,{lang.money.not_enough()})
          end
        end)
      else
        URKclient.notify(source,{lang.common.no_player_near()})
      end
    else
      URKclient.notify(source,{lang.common.no_player_near()})
    end
  end
end)


function Comma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

RegisterServerEvent("URK:takeAmount")
AddEventHandler("URK:takeAmount", function(amount)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.tryFullPayment(user_id,amount) then
      URKclient.notify(source,{'~g~Paid £'..getMoneyStringFormatted(amount)..'.'})
      return
    end
end)

RegisterServerEvent("URK:bankTransfer")
AddEventHandler("URK:bankTransfer", function(id, amount)
    local source = source
    local user_id = URK.getUserId(source)
    local id = tonumber(id)
    local amount = tonumber(amount)
    if URK.getUserSource(id) then
      if URK.tryBankPayment(user_id,amount) then
        URKclient.notify(source,{'~g~Transferred £'..getMoneyStringFormatted(amount)..' to ID: '..id})
        URKclient.notify(URK.getUserSource(id),{'~g~Received £'..getMoneyStringFormatted(amount)..' from ID: '..user_id})
        TriggerClientEvent("urk:PlaySound", source, "apple")
        TriggerClientEvent("urk:PlaySound", URK.getUserSource(id), "apple")
        URK.giveBankMoney(id, amount)
        tURK.sendWebhook('bank-transfer', "URK Bank Transfer Logs", "> Player Name: **"..GetPlayerName(source).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..GetPlayerName(URK.getUserSource(id)).."**\n> Target PermID: **"..id.."**\n> Amount: **£"..amount.."**")
      else
        URKclient.notify(source,{'~r~You do not have enough money.'})
      end
    else
      URKclient.notify(source,{'~r~Player is not online'})
    end
end)

RegisterServerEvent('URK:requestPlayerBankBalance')
AddEventHandler('URK:requestPlayerBankBalance', function()
    local user_id = URK.getUserId(source)
    local bank = URK.getBankMoney(user_id)
    local wallet = URK.getMoney(user_id)
    TriggerClientEvent('URK:setDisplayMoney', source, wallet)
    TriggerClientEvent('URK:setDisplayBankMoney', source, bank)
    TriggerClientEvent('URK:initMoney', source, wallet, bank)
end)