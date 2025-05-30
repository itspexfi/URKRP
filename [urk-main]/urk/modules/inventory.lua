local lang = URK.lang
local cfg = module("URKVeh", "inventory")

-- this module define the player inventory (lost after respawn, as wallet)

URK.items = {}

function URK.defInventoryItem(idname,name,description,choices,weight)
  if weight == nil then
    weight = 0
  end

  local item = {name=name,description=description,choices=choices,weight=weight}
  URK.items[idname] = item

  -- build give action
  item.ch_give = function(player,choice)
  end

  -- build trash action
  item.ch_trash = function(player,choice)
    local user_id = URK.getUserId(player)
    if user_id ~= nil then
      -- prompt number
      URK.prompt(player,lang.inventory.trash.prompt({URK.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
        local amount = parseInt(amount)
        if URK.tryGetInventoryItem(user_id,idname,amount,false) then
          URKclient.notify(player,{lang.inventory.trash.done({URK.getItemName(idname),amount})})
          URKclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
        else
          URKclient.notify(player,{lang.common.invalid_value()})
        end
      end)
    end
  end
end

-- give action
function ch_give(idname, player, choice)
  local user_id = URK.getUserId(player)
  if user_id ~= nil then
    URKclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
      usrList = ""
      for k, v in pairs(nplayers) do
          usrList = usrList .. "[" .. k .. "]" .. GetPlayerName(k) .. " | " --add ids to usrList
      end
      if usrList ~= "" then
        URK.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, nplayer) --ask for id
          nplayer = nplayer
          if nplayer ~= nil and nplayer ~= "" then
            if nplayers[tonumber(nplayer)] then
              local nuser_id = URK.getUserId(nplayer)
              if nuser_id ~= nil then
                URK.prompt(player,lang.inventory.give.prompt({URK.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
                  local amount = parseInt(amount)
                  -- weight check
                  local new_weight = URK.getInventoryWeight(nuser_id)+URK.getItemWeight(idname)*amount
                  if new_weight <= URK.getInventoryMaxWeight(nuser_id) then
                    if URK.tryGetInventoryItem(user_id,idname,amount,true) then
                      URK.giveInventoryItem(nuser_id,idname,amount,true)
                      TriggerEvent('URK:RefreshInventory', player)
                      TriggerEvent('URK:RefreshInventory', nplayer)
                      URKclient.playAnim(player,{true,{{"mp_common","givetake1_a",1}},false})
                      URKclient.playAnim(nplayer,{true,{{"mp_common","givetake2_a",1}},false})
                    else
                      URKclient.notify(player,{lang.common.invalid_value()})
                    end
                  else
                    URKclient.notify(player,{lang.inventory.full()})
                  end
                end)
              else
                  URKclient.notify(player,{'~r~Invalid Temp ID.'})
              end
            else
                URKclient.notify(player,{'~r~Invalid Temp ID.'})
            end
          else
            URKclient.notify(player,{lang.common.no_player_near()})
          end
        end)
      else
        URKclient.notify(player,{"~r~No players nearby!"}) --no players nearby
      end
    end)
  end
end

-- trash action
function ch_trash(idname, player, choice)
  local user_id = URK.getUserId(player)
  if user_id ~= nil then
    -- prompt number
    if URK.getInventoryItemAmount(user_id,idname) > 1 then 
      URK.prompt(player,lang.inventory.trash.prompt({URK.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
        local amount = parseInt(amount)
        if URK.tryGetInventoryItem(user_id,idname,amount,false) then
          TriggerEvent('URK:RefreshInventory', player)
          URKclient.notify(player,{lang.inventory.trash.done({URK.getItemName(idname),amount})})
          URKclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
        else
          URKclient.notify(player,{lang.common.invalid_value()})
        end
      end)
    else
      if URK.tryGetInventoryItem(user_id,idname,1,false) then
        TriggerEvent('URK:RefreshInventory', player)
        URKclient.notify(player,{lang.inventory.trash.done({URK.getItemName(idname),1})})
        URKclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
      else
        URKclient.notify(player,{lang.common.invalid_value()})
      end
    end
  end
end

function URK.computeItemName(item,args)
  if type(item.name) == "string" then return item.name
  else return item.name(args) end
end

function URK.computeItemDescription(item,args)
  if type(item.description) == "string" then return item.description
  else return item.description(args) end
end

function URK.computeItemChoices(item,args)
  if item.choices ~= nil then
    return item.choices(args)
  else
    return {}
  end
end

function URK.computeItemWeight(item,args)
  if type(item.weight) == "number" then return item.weight
  else return item.weight(args) end
end


function URK.parseItem(idname)
  return splitString(idname,"|")
end

-- return name, description, weight
function URK.getItemDefinition(idname)
  local args = URK.parseItem(idname)
  local item = URK.items[args[1]]
  if item ~= nil then
    return URK.computeItemName(item,args), URK.computeItemDescription(item,args), URK.computeItemWeight(item,args)
  end

  return nil,nil,nil
end

function URK.getItemName(idname)
  local args = URK.parseItem(idname)
  local item = URK.items[args[1]]
  if item ~= nil then return URK.computeItemName(item,args) end
  return args[1]
end

function URK.getItemDescription(idname)
  local args = URK.parseItem(idname)
  local item = URK.items[args[1]]
  if item ~= nil then return URK.computeItemDescription(item,args) end
  return ""
end

function URK.getItemChoices(idname)
  local args = URK.parseItem(idname)
  local item = URK.items[args[1]]
  local choices = {}
  if item ~= nil then
    -- compute choices
    local cchoices = URK.computeItemChoices(item,args)
    if cchoices then -- copy computed choices
      for k,v in pairs(cchoices) do
        choices[k] = v
      end
    end

    -- add give/trash choices
    choices[lang.inventory.give.title()] = {function(player,choice) ch_give(idname, player, choice) end, lang.inventory.give.description()}
    choices[lang.inventory.trash.title()] = {function(player, choice) ch_trash(idname, player, choice) end, lang.inventory.trash.description()}
  end

  return choices
end

function URK.getItemWeight(idname)
  local args = URK.parseItem(idname)
  local item = URK.items[args[1]]
  if item ~= nil then return URK.computeItemWeight(item,args) end
  return 1
end

-- compute weight of a list of items (in inventory/chest format)
function URK.computeItemsWeight(items)
  local weight = 0

  for k,v in pairs(items) do
    local iweight = URK.getItemWeight(k)
    if iweight ~= nil then
      weight = weight+iweight*v.amount
    end
  end

  return weight
end

-- add item to a connected user inventory
function URK.giveInventoryItem(user_id,idname,amount,notify)
  local player = URK.getUserSource(user_id)
  if notify == nil then notify = true end -- notify by default

  local data = URK.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then -- add to entry
      entry.amount = entry.amount+amount
    else -- new entry
      data.inventory[idname] = {amount=amount}
    end

    -- notify
    if notify then
      local player = URK.getUserSource(user_id)
      if player ~= nil then
        URKclient.notify(player,{lang.inventory.give.received({URK.getItemName(idname),amount})})
      end
    end
  end
  TriggerEvent('URK:RefreshInventory', player)
end


function URK.RunTrashTask(source, itemName)
    local choices = URK.getItemChoices(itemName)
    if choices['Trash'] then
        choices['Trash'][1](source)
    else 
        local user_id = URK.getUserId(source)
        local data = URK.getUserDataTable(user_id)
        data.inventory[itemName] = nil;
    end
    TriggerEvent('URK:RefreshInventory', source)
end


function URK.RunGiveTask(source, itemName)
    local choices = URK.getItemChoices(itemName)
    if choices['Give'] then
        choices['Give'][1](source)
    end
    TriggerEvent('URK:RefreshInventory', source)
end

function URK.RunInventoryTask(source, itemName)
    local choices = URK.getItemChoices(itemName)
    if choices['Use'] then 
        choices['Use'][1](source)
    elseif choices['Drink'] then
        choices['Drink'][1](source)
    elseif choices['Load'] then
        choices['Load'][1](source)
    elseif choices['Eat'] then
        choices['Eat'][1](source)
    elseif choices['Equip'] then 
        choices['Equip'][1](source)
    elseif choices['Take'] then 
        choices['Take'][1](source)
    end
    TriggerEvent('URK:RefreshInventory', source)
end

function URK.LoadAllTask(source, itemName)
  local choices = URK.getItemChoices(itemName)
  choices['LoadAll'][1](source)
  TriggerEvent('URK:RefreshInventory', source)
end

-- try to get item from a connected user inventory
function URK.tryGetInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default
  local player = URK.getUserSource(user_id)

  local data = URK.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry and entry.amount >= amount then -- add to entry
      entry.amount = entry.amount-amount

      -- remove entry if <= 0
      if entry.amount <= 0 then
        data.inventory[idname] = nil 
      end

      -- notify
      if notify then
        local player = URK.getUserSource(user_id)
        if player ~= nil then
          URKclient.notify(player,{lang.inventory.give.given({URK.getItemName(idname),amount})})
      
        end
      end
      TriggerEvent('URK:RefreshInventory', player)
      return true
    else
      -- notify
      if notify then
        local player = URK.getUserSource(user_id)
        if player ~= nil then
          local entry_amount = 0
          if entry then entry_amount = entry.amount end
          URKclient.notify(player,{lang.inventory.missing({URK.getItemName(idname),amount-entry_amount})})
        end
      end
    end
  end

  return false
end

-- get user inventory amount of item
function URK.getInventoryItemAmount(user_id,idname)
  local data = URK.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

-- return user inventory total weight
function URK.getInventoryWeight(user_id)
  local data = URK.getUserDataTable(user_id)
  if data and data.inventory then
    return URK.computeItemsWeight(data.inventory)
  end
  return 0
end

function URK.getInventoryMaxWeight(user_id)
  local data = URK.getUserDataTable(user_id)
  if data.invcap ~= nil then
    return data.invcap
  end
  return 30
end


-- clear connected user inventory
function URK.clearInventory(user_id)
  local data = URK.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end


AddEventHandler("URK:playerJoin", function(user_id,source,name,last_login)
  local data = URK.getUserDataTable(user_id)
  if data.inventory == nil then
    data.inventory = {}
  end
end)


RegisterCommand("storebackpack", function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  local data = URK.getUserDataTable(user_id)
  tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
    if cb then
      local invcap = 30
      if plathours > 0 then
          invcap = invcap + 20
      elseif plushours > 0 then
          invcap = invcap + 10
      end
      if invcap == 30 then
        URKclient.notify(source,{"~r~You do not have a backpack equipped."})
        return
      end
      if data.invcap - 15 == invcap then
        URK.giveInventoryItem(user_id, "offwhitebag", 1, false)
      elseif data.invcap - 20 == invcap then
        URK.giveInventoryItem(user_id, "guccibag", 1, false)
      elseif data.invcap - 30 == invcap  then
        URK.giveInventoryItem(user_id, "nikebag", 1, false)
      elseif data.invcap - 35 == invcap  then
        URK.giveInventoryItem(user_id, "huntingbackpack", 1, false)
      elseif data.invcap - 40 == invcap  then
        URK.giveInventoryItem(user_id, "greenhikingbackpack", 1, false)
      elseif data.invcap - 70 == invcap  then
        URK.giveInventoryItem(user_id, "rebelbackpack", 1, false)
      end
      URK.updateInvCap(user_id, invcap)
      URKclient.notify(source,{"~g~Backpack Stored"})
      TriggerClientEvent('URK:removeBackpack', source)
    else
      if URK.getInventoryWeight(user_id) + 5 > URK.getInventoryMaxWeight(user_id) then
        URKclient.notify(source,{"~r~You do not have enough room to store your backpack"})
      end
    end
  end)
end)