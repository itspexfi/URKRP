local cfg=module("cfg/cfg_respawn")


RegisterNetEvent("URK:SendSpawnMenu")
AddEventHandler("URK:SendSpawnMenu",function()
    local source = source
    local user_id = URK.getUserId(source)
    local spawnTable={}
    for k,v in pairs(cfg.spawnLocations)do
        if v.permission[1] ~= nil then
            if URK.hasPermission(URK.getUserId(source),v.permission[1])then
                table.insert(spawnTable, k)
            end
        else
            table.insert(spawnTable, k)
        end
    end
    exports['ghmattimysql']:execute("SELECT * FROM `urk_user_homes` WHERE user_id = @user_id", {user_id = user_id}, function(result)
        if result ~= nil then 
            for a,b in pairs(result) do
                table.insert(spawnTable, b.home)
            end
            TriggerClientEvent("URK:OpenSpawnMenu",source,spawnTable)
            URK.clearInventory(user_id) 
            URKclient.setPlayerCombatTimer(source, {0})
        end
    end)
end)