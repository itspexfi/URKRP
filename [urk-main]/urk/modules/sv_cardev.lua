RegisterServerEvent('URK:setCarDevMode')
AddEventHandler('URK:setCarDevMode', function(status)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil and URK.hasPermission(user_id, "cardev.menu") then 
      if status then
        tURK.setBucket(source, 333)
      else
        tURK.setBucket(source, 0)
      end
    else
      TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Attempted to Teleport to Car Dev Universe')
    end
end)