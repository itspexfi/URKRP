local trainingWorlds = {}
local trainingWorldsCount = 0
RegisterCommand('trainingworlds', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        TriggerClientEvent('URK:trainingWorldSendAll', source, trainingWorlds)
        TriggerClientEvent('URK:trainingWorldOpen', source, URK.hasPermission(user_id, 'police.announce'))
    end
end)

RegisterNetEvent("URK:trainingWorldCreate")
AddEventHandler("URK:trainingWorldCreate", function()
    local source = source
    local user_id = URK.getUserId(source)
    trainingWorldsCount = trainingWorldsCount + 1
    URK.prompt(source,"World Name:","",function(player,worldname) 
        if string.gsub(worldname, "%s+", "") ~= '' then
            if next(trainingWorlds) then
                for k,v in pairs(trainingWorlds) do
                    if v.name == worldname then
                        URKclient.notify(source, {"~r~This world name already exists."})
                        return
                    elseif v.ownerUserId == user_id then
                        URKclient.notify(source, {"~r~You already have a world, please delete it first."})
                        return
                    end
                end
            end
            URK.prompt(source,"World Password:","",function(player,password) 
                trainingWorlds[trainingWorldsCount] = {name = worldname, ownerName = GetPlayerName(source), ownerUserId = user_id, bucket = trainingWorldsCount, members = {}, password = password}
                table.insert(trainingWorlds[trainingWorldsCount].members, user_id)
                tURK.setBucket(source, trainingWorldsCount)
                TriggerClientEvent('URK:trainingWorldSend', -1, trainingWorldsCount, trainingWorlds[trainingWorldsCount])
                URKclient.notify(source, {'~g~Training World Created!'})
            end)
        else
            URKclient.notify(source, {"~r~Invalid World Name."})
        end
    end)
end)

RegisterNetEvent("URK:trainingWorldRemove")
AddEventHandler("URK:trainingWorldRemove", function(world)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.announce') then
        if trainingWorlds[world] ~= nil then
            TriggerClientEvent('URK:trainingWorldRemove', -1, world)
            for k,v in pairs(trainingWorlds[world].members) do
                local memberSource = URK.getUserSource(v)
                if memberSource ~= nil then
                    tURK.setBucket(memberSource, 0)
                    URKclient.notify(memberSource, {"~b~The training world you were in was deleted, you have been returned to the main dimension."})
                end
            end
            trainingWorlds[world] = nil
        end
    end
end)

RegisterNetEvent("URK:trainingWorldJoin")
AddEventHandler("URK:trainingWorldJoin", function(world)
    local source = source
    local user_id = URK.getUserId(source)
    URK.prompt(source,"Enter Password:","",function(player,password) 
        if password ~= trainingWorlds[world].password then
            URKclient.notify(source, {"~r~Invalid Password."})
            return
        else
            tURK.setBucket(source, world)
            table.insert(trainingWorlds[world].members, user_id)
            URKclient.notify(source, {"~b~You have joined training world "..trainingWorlds[world].name..' owned by '..trainingWorlds[world].ownerName..'.'})
        end
    end)
end)

RegisterNetEvent("URK:trainingWorldLeave")
AddEventHandler("URK:trainingWorldLeave", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.setBucket(source, 0)
    URKclient.notify(source, {"~b~You have left the training world."})
end)

