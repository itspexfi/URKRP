function URK.updateCurrentPlayerInfo()
  local currentPlayersInformation = {}
  local playersJobs = {}
  for k,v in pairs(URK.getUsers()) do
    table.insert(playersJobs, {user_id = k, jobs = URK.getUserGroups(k)})
  end
  currentPlayersInformation['currentStaff'] = URK.getUsersByPermission('admin.tickets')
  currentPlayersInformation['jobs'] = playersJobs
  TriggerClientEvent("URK:receiveCurrentPlayerInfo", -1, currentPlayersInformation)
end

AddEventHandler("playerJoining", function()
  URK.updateCurrentPlayerInfo()
end)