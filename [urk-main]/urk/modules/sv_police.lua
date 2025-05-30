
-- this module define some police tools and functions
local lang = URK.lang
local a = module("URKFirearms", "cfg/weapons")

local isStoring = {}
local choice_store_weapons = function(player, choice)
    local user_id = URK.getUserId(player)
    local data = URK.getUserDataTable(user_id)
    URKclient.getWeapons(player,{},function(weapons)
      if not isStoring[player] then
        tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
          if cb then
            local maxWeight = 30
            if plathours > 0 then
              maxWeight = 50
            elseif plushours > 0 then
              maxWeight = 40
            end
            if URK.getInventoryWeight(user_id) <= maxWeight then
              isStoring[player] = true
              URKclient.giveWeapons(player,{{},true}, function(removedwep)
                for k,v in pairs(weapons) do
                  if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                    URK.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                    if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                      for i,c in pairs(a.weapons) do
                        if i == k and c.class ~= 'Melee' then
                          if v.ammo > 250 then
                            v.ammo = 250
                          end
                          URK.giveInventoryItem(user_id, c.ammo, v.ammo, true)
                        end   
                      end
                    end
                  end
                end
                URKclient.notify(player,{"~g~Weapons Stored"})
                TriggerEvent('URK:RefreshInventory', player)
                URKclient.ClearWeapons(player,{})
                data.weapons = {}
                SetTimeout(3000,function()
                    isStoring[player] = nil 
                end)
              end)
            else
              URKclient.notify(player,{'~r~You do not have enough Weight to store Weapons.'})
            end
          end
        end)
      end 
    end)
end

RegisterServerEvent("URK:forceStoreSingleWeapon")
AddEventHandler("URK:forceStoreSingleWeapon",function(model)
    local source = source
    local user_id = URK.getUserId(source)
    if model ~= nil then
      URKclient.getWeapons(source,{},function(weapons)
        for k,v in pairs(weapons) do
          if k == model then
            local new_weight = URK.getInventoryWeight(user_id)+URK.getItemWeight(model)
            if new_weight <= URK.getInventoryMaxWeight(user_id) then
              RemoveWeaponFromPed(GetPlayerPed(source), k)
              URKclient.removeWeapon(source,{k})
              URK.giveInventoryItem(user_id, "wbody|"..k, 1, true)
              if v.ammo > 0 then
                for i,c in pairs(a.weapons) do
                  if i == model and c.class ~= 'Melee' then
                    URK.giveInventoryItem(user_id, c.ammo, v.ammo, true)
                  end   
                end
              end
            end
          end
        end
      end)
    end
end)

RegisterCommand('storeallweapons', function(source)
  choice_store_weapons(source)
end)


RegisterCommand('shield', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') then
    TriggerClientEvent('URK:toggleShieldMenu', source)
  end
end)

RegisterCommand('cuff', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  URKclient.isHandcuffed(source,{},function(handcuffed)
    if handcuffed then
      return
    else
      URKclient.isStaffedOn(source, {}, function(staffedOn) 
        if (staffedOn and URK.hasPermission(user_id, 'admin.tickets')) or URK.hasPermission(user_id, 'police.onduty.permission') then
          URKclient.getNearestPlayer(source,{5},function(nplayer)
            if nplayer ~= nil then
              local nplayer_id = URK.getUserId(nplayer)
              if (not URK.hasPermission(nplayer_id, 'police.onduty.permission') or URK.hasPermission(nplayer_id, 'police.undercover')) then
                URKclient.isHandcuffed(nplayer,{},function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('URK:uncuffAnim', source, nplayer, false)
                    TriggerClientEvent('URK:unHandcuff', source, false)
                  else
                    TriggerClientEvent('URK:arrestCriminal', nplayer, source)
                    TriggerClientEvent('URK:arrestFromPolice', source)
                  end
                  TriggerClientEvent('URK:toggleHandcuffs', nplayer, false)
                  TriggerClientEvent('URK:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              URKclient.notify(source,{lang.common.no_player_near()})
            end
          end)
        end
      end)
    end
  end)
end)

RegisterCommand('frontcuff', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  URKclient.isHandcuffed(source,{},function(handcuffed)
    if handcuffed then
      return
    else
      URKclient.isStaffedOn(source, {}, function(staffedOn) 
        if (staffedOn and URK.hasPermission(user_id, 'admin.tickets')) or URK.hasPermission(user_id, 'police.onduty.permission') then
          URKclient.getNearestPlayer(source,{5},function(nplayer)
            if nplayer ~= nil then
              local nplayer_id = URK.getUserId(nplayer)
              if (not URK.hasPermission(nplayer_id, 'police.onduty.permission') or URK.hasPermission(nplayer_id, 'police.undercover')) then
                URKclient.isHandcuffed(nplayer,{},function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('URK:uncuffAnim', source, nplayer, true)
                    TriggerClientEvent('URK:unHandcuff', source, true)
                  else
                    TriggerClientEvent('URK:arrestCriminal', nplayer, source)
                    TriggerClientEvent('URK:arrestFromPolice', source)
                  end
                  TriggerClientEvent('URK:toggleHandcuffs', nplayer, true)
                  TriggerClientEvent('URK:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              URKclient.notify(source,{lang.common.no_player_near()})
            end
          end)
        end
      end)
    end
  end)
end)

function URK.handcuffKeys(source)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.getInventoryItemAmount(user_id, 'handcuffkeys') >= 1 then
    URKclient.getNearestPlayer(source,{5},function(nplayer)
      if nplayer ~= nil then
        local nplayer_id = URK.getUserId(nplayer)
        URKclient.isHandcuffed(nplayer,{},function(handcuffed)
          if handcuffed then
            URK.tryGetInventoryItem(user_id, 'handcuffkeys', 1)
            TriggerClientEvent('URK:uncuffAnim', source, nplayer, false)
            TriggerClientEvent('URK:unHandcuff', source, false)
            TriggerClientEvent('URK:toggleHandcuffs', nplayer, false)
            TriggerClientEvent('URK:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
          end
        end)
      else
        URKclient.notify(source,{lang.common.no_player_near()})
      end
    end)
  end
end

local section60s = {}
RegisterCommand('s60', function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.announce') then
        if args[1] ~= nil and args[2] ~= nil then
            local radius = tonumber(args[1])
            local duration = tonumber(args[2])*60
            local section60UUID = #section60s+1
            section60s[section60UUID] = {radius = radius, duration = duration, uuid = section60UUID}
            TriggerClientEvent("URK:addS60", -1, GetEntityCoords(GetPlayerPed(source)), radius, section60UUID)
        else
            URKclient.notify(source,{'~r~Invalid Arguments.'})
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(section60s) do
            if section60s[k].duration > 0 then
                section60s[k].duration = section60s[k].duration-1 
            else
                TriggerClientEvent('URK:removeS60', -1, section60s[k].uuid)
            end
        end
        Citizen.Wait(1000)
    end
end)

RegisterCommand('handbook', function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
      TriggerClientEvent('URK:toggleHandbook', source)
    end
end)

local draggingPlayers = {}

RegisterServerEvent('URK:dragPlayer')
AddEventHandler('URK:dragPlayer', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil and (URK.hasPermission(user_id, "police.onduty.permission") or URK.hasPermission(user_id, "prisonguard.onduty.permission")) then
      if playersrc ~= nil then
        local nuser_id = URK.getUserId(playersrc)
          if nuser_id ~= nil then
            URKclient.isHandcuffed(playersrc,{},function(handcuffed)
                if handcuffed then
                    if draggingPlayers[user_id] then
                      TriggerClientEvent("URK:undrag", playersrc, source)
                      draggingPlayers[user_id] = nil
                    else
                      TriggerClientEvent("URK:drag", playersrc, source)
                      draggingPlayers[user_id] = playersrc
                    end
                else
                    URKclient.notify(source,{"~r~Player is not handcuffed."})
                end
            end)
          else
              URKclient.notify(source,{"~r~There is no player nearby"})
          end
      else
          URKclient.notify(source,{"~r~There is no player nearby"})
      end
    end
end)

RegisterServerEvent('URK:putInVehicle')
AddEventHandler('URK:putInVehicle', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil and URK.hasPermission(user_id, "police.onduty.permission") then
      if playersrc ~= nil then
        URKclient.isHandcuffed(playersrc,{}, function(handcuffed)  -- check handcuffed
          if handcuffed then
            URKclient.putInNearestVehicleAsPassenger(playersrc, {10})
          else
            URKclient.notify(source,{lang.police.not_handcuffed()})
          end
        end)
      end
    end
end)

RegisterServerEvent('URK:ejectFromVehicle')
AddEventHandler('URK:ejectFromVehicle', function()
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil and URK.hasPermission(user_id, "police.onduty.permission") then
      URKclient.getNearestPlayer(source,{10},function(nplayer)
        local nuser_id = URK.getUserId(nplayer)
        if nuser_id ~= nil then
          URKclient.isHandcuffed(nplayer,{}, function(handcuffed)  -- check handcuffed
            if handcuffed then
              URKclient.ejectVehicle(nplayer, {})
            else
              URKclient.notify(source,{lang.police.not_handcuffed()})
            end
          end)
        else
          URKclient.notify(source,{lang.common.no_player_near()})
        end
      end)
    end
end)


RegisterServerEvent("URK:Knockout")
AddEventHandler('URK:Knockout', function()
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.getNearestPlayer(source, {2}, function(nplayer)
        local nuser_id = URK.getUserId(nplayer)
        if nuser_id ~= nil then
            TriggerClientEvent('URK:knockOut', nplayer)
            SetTimeout(30000, function()
                TriggerClientEvent('URK:knockOutDisable', nplayer)
            end)
        end
    end)
end)

RegisterServerEvent("URK:KnockoutNoAnim")
AddEventHandler('URK:KnockoutNoAnim', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Founder') then
      URKclient.getNearestPlayer(source, {2}, function(nplayer)
          local nuser_id = URK.getUserId(nplayer)
          if nuser_id ~= nil then
              TriggerClientEvent('URK:knockOut', nplayer)
              SetTimeout(30000, function()
                  TriggerClientEvent('URK:knockOutDisable', nplayer)
              end)
          end
      end)
    end
end)

RegisterServerEvent("URK:requestPlaceBagOnHead")
AddEventHandler('URK:requestPlaceBagOnHead', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.getInventoryItemAmount(user_id, 'Headbag') >= 1 then
      URKclient.getNearestPlayer(source, {10}, function(nplayer)
          local nuser_id = URK.getUserId(nplayer)
          if nuser_id ~= nil then
              URK.tryGetInventoryItem(user_id, 'Headbag', 1, true)
              TriggerClientEvent('URK:placeHeadBag', nplayer)
          end
      end)
    end
end)

RegisterServerEvent('URK:gunshotTest')
AddEventHandler('URK:gunshotTest', function(playersrc)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil and URK.hasPermission(user_id, "police.onduty.permission") then
      if playersrc ~= nil then
        URKclient.hasRecentlyShotGun(playersrc,{}, function(shotagun)
          if shotagun then
            URKclient.notify(source, {"~r~Player has recently shot a gun."})
          else
            URKclient.notify(source, {"~r~Player has no gunshot residue on fingers."})
          end
        end)
      end
    end
end)

RegisterServerEvent('URK:tryTackle')
AddEventHandler('URK:tryTackle', function(id)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') or URK.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent('URK:playTackle', source)
        TriggerClientEvent('URK:getTackled', id, source)
    end
end)

RegisterCommand('drone', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasGroup(user_id, 'Drone Trained') then
      TriggerClientEvent('toggleDrone', source)
  end
end)

RegisterCommand('trafficmenu', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
      TriggerClientEvent('URK:toggleTrafficMenu', source)
  end
end)

RegisterServerEvent('URK:startThrowSmokeGrenade')
AddEventHandler('URK:startThrowSmokeGrenade', function(name)
    local source = source
    TriggerClientEvent('URK:displaySmokeGrenade', -1, name, GetEntityCoords(GetPlayerPed(source)))
end)

RegisterCommand('breathalyse', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') then
      TriggerClientEvent('URK:breathalyserCommand', source)
  end
end)

RegisterServerEvent('URK:breathalyserRequest')
AddEventHandler('URK:breathalyserRequest', function(temp)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
      TriggerClientEvent('URK:beingBreathalysed', temp)
      TriggerClientEvent('URK:breathTestResult', source, math.random(0, 100), GetPlayerName(temp))
    end
end)

seizeBullets = {
  ['9mm Bullets'] = true,
  ['7.62mm Bullets'] = true,
  ['.357 Bullets'] = true,
  ['12 Gauge Bullets'] = true,
  ['.308 Sniper Rounds'] = true,
  ['5.56mm NATO'] = true,
}

RegisterServerEvent('URK:seizeWeapons')
AddEventHandler('URK:seizeWeapons', function(playerSrc)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
      URKclient.isHandcuffed(playerSrc,{},function(handcuffed)
        if handcuffed then
          RemoveAllPedWeapons(GetPlayerPed(playerSrc), true)
          local player_id = URK.getUserId(playerSrc)
          local cdata = URK.getUserDataTable(player_id)
          for a,b in pairs(cdata.inventory) do
              if string.find(a, 'wbody|') then
                  c = a:gsub('wbody|', '')
                  cdata.inventory[c] = b
                  cdata.inventory[a] = nil
              end
          end
          for k,v in pairs(a.weapons) do
              if cdata.inventory[k] ~= nil then
                  if not v.policeWeapon then
                    cdata.inventory[k] = nil
                  end
              end
          end
          for c,d in pairs(cdata.inventory) do
              if seizeBullets[c] then
                cdata.inventory[c] = nil
              end
          end
          TriggerEvent('URK:RefreshInventory', playerSrc)
          URKclient.notify(source, {'~r~Seized weapons.'})
          URKclient.notify(playerSrc, {'~r~Your weapons have been seized.'})
        end
      end)
    end
end)

seizeDrugs = {
  ['Weed leaf'] = true,
  ['Weed'] = true,
  ['Coca leaf'] = true,
  ['Cocaine'] = true,
  ['Opium Poppy'] = true,
  ['Heroin'] = true,
  ['Ephedra'] = true,
  ['Meth'] = true,
  ['Frogs legs'] = true,
  ['Lysergic Acid Amide'] = true,
  ['LSD'] = true,
}
RegisterServerEvent('URK:seizeIllegals')
AddEventHandler('URK:seizeIllegals', function(playerSrc)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
      local player_id = URK.getUserId(playerSrc)
      local cdata = URK.getUserDataTable(player_id)
      for a,b in pairs(cdata.inventory) do
          for c,d in pairs(seizeDrugs) do
              if a == c then
                cdata.inventory[a] = nil
              end
          end
      end
      TriggerEvent('URK:RefreshInventory', playerSrc)
      URKclient.notify(source, {'~r~Seized illegals.'})
      URKclient.notify(playerSrc, {'~r~Your illegals have been seized.'})
    end
end)

RegisterServerEvent("URK:newPanic")
AddEventHandler("URK:newPanic", function(a,b)
	local source = source
	local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') or URK.hasPermission(user_id, 'nhs.onduty.permission') or URK.hasPermission(user_id, 'lfb.onduty.permission') then
        TriggerClientEvent("URK:returnPanic", -1, nil, a, b)
        tURK.sendWebhook(getPlayerFaction(user_id)..'-panic', 'URK Panic Logs', "> Player Name: **"..GetPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Location: **"..a.Location.."**")
    end
end)

RegisterNetEvent("URK:flashbangThrown")
AddEventHandler("URK:flashbangThrown", function(coords)   
    TriggerClientEvent("URK:flashbangExplode", -1, coords)
end)

RegisterNetEvent("URK:updateSpotlight")
AddEventHandler("URK:updateSpotlight", function(a)  
  local source = source 
  TriggerClientEvent("URK:updateSpotlight", -1, source, a)
end)

RegisterCommand('wc', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') then
    URKclient.getNearestPlayer(source, {2}, function(nplayer)
      if nplayer ~= nil then
        URKclient.getPoliceCallsign(source, {}, function(callsign)
          URKclient.getPoliceRank(source, {}, function(rank)
            URKclient.playAnim(source,{true,{{'paper_1_rcm_alt1-9', 'player_one_dual-9', 1}},false})
            URKclient.notifyPicture(nplayer, {"polnotification","notification","~b~Callsign: ~w~"..callsign.."\n~b~Rank: ~w~"..rank.."\n~b~Name: ~w~"..GetPlayerName(source),"Metropolitan Police","Warrant Card",false,nil})
            TriggerClientEvent('URK:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)

RegisterCommand('wca', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') then
    URKclient.getNearestPlayer(source, {2}, function(nplayer)
      if nplayer ~= nil then
        URKclient.getPoliceCallsign(source, {}, function(callsign)
          URKclient.getPoliceRank(source, {}, function(rank)
            URKclient.playAnim(source,{true,{{'paper_1_rcm_alt1-9', 'player_one_dual-9', 1}},false})
            URKclient.notifyPicture(nplayer, {"polnotification","notification","~b~Callsign: ~w~"..callsign.."\n~b~Rank: ~w~"..rank,"Metropolitan Police","Warrant Card",false,nil})
            TriggerClientEvent('URK:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)
