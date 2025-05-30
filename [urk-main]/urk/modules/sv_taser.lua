RegisterServerEvent('URK:playTaserSound')
AddEventHandler('URK:playTaserSound', function(coords, sound)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
        TriggerClientEvent('playTaserSoundClient', -1, coords, sound)
    end
end)

RegisterServerEvent('URK:reactivatePed')
AddEventHandler('URK:reactivatePed', function(id)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
      TriggerClientEvent('URK:receiveActivation', id)
      TriggerClientEvent('TriggerTazer', id)
    end
end)

RegisterServerEvent('URK:arcTaser')
AddEventHandler('URK:arcTaser', function()
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
      URKclient.getNearestPlayer(source, {3}, function(nplayer)
        local nuser_id = URK.getUserId(nplayer)
        if nuser_id ~= nil then
            TriggerClientEvent('URK:receiveBarbs', nplayer, source)
            TriggerClientEvent('TriggerTazer', id)
        end
      end)
    end
end)

RegisterServerEvent('URK:barbsNoLongerServer')
AddEventHandler('URK:barbsNoLongerServer', function(id)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
      TriggerClientEvent('URK:barbsNoLonger', id)
    end
end)

RegisterServerEvent('URK:barbsRippedOutServer')
AddEventHandler('URK:barbsRippedOutServer', function(id)
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:barbsRippedOut', id)
end)

RegisterCommand('rt', function(source, args)
  local source = source
  local user_id = URK.getUserId(source)
  if URK.hasPermission(user_id, 'police.onduty.permission') or URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
      TriggerClientEvent('URK:reloadTaser', source)
  end
end)