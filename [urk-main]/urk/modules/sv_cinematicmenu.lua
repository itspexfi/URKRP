RegisterCommand('cinematicmenu', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Cinematic') then
        TriggerClientEvent('URK:openCinematicMenu', source)
    end
end)