local deathMatch = {}
local deathMatchCount = 0

RegisterCommand('deathmatch', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'tutorial.done') then
        TriggerClientEvent('URK:deathMatchendAll', source, deathMatch)
        TriggerClientEvent('URK:deathMatchOpen', source, URK.hasPermission(user_id, 'tutorial.done'))
        TriggerClientEvent('URK:weaponsOpen', source, URK.hasPermission(user_id, 'tutorial.done'))
    end
end)

RegisterNetEvent("URK:deathMatchCreate")
AddEventHandler("URK:deathMatchCreate", function()
    local source = source
    local user_id = URK.getUserId(source)
    deathMatchCount = deathMatchCount + 1
    URK.prompt(source,"Deathmatch Name:","",function(player,deathmatchname) 
        if string.gsub(deathmatchname, "%s+", "") ~= '' then
            if next(deathMatch) then
                for k,v in pairs(deathMatch) do
                    if v.name == deathmatchname then
                        URKclient.notify(source, {"~r~This deathmatch name already exists."})
                        return
                    elseif v.ownerUserId == user_id then
                        URKclient.notify(source, {"~r~You already have a deathmatch, please delete it first."})
                        return
                    end
                end
            end
            URK.prompt(source,"Deathmatch Password:","",function(player,password) 
                deathMatch[deathMatchCount] = {name = deathmatchname, ownerName = GetPlayerName(source), ownerUserId = user_id, bucket = deathMatchCount, members = {}, password = password}
                table.insert(deathMatch[deathMatchCount].members, user_id)
                tURK.setBucket(source, deathMatchCount)
                TriggerClientEvent('URK:deathMatchend', -1, deathMatchCount, deathMatch[deathMatchCount])
                URKclient.notify(source, {'~g~Deathmatch Deathmatch Created!'})
            end)
        else
            URKclient.notify(source, {"~r~Invalid Deathmatch Name."})
        end
    end)
end)

RegisterNetEvent("URK:deathMatchRemove")
AddEventHandler("URK:deathMatchRemove", function(deathmatch)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.tickets') then
        if deathMatch[deathmatch] ~= nil then
            TriggerClientEvent('URK:deathMatchRemove', -1, deathmatch)
            for k,v in pairs(deathMatch[deathmatch].members) do
                local memberSource = URK.getUserSource(v)
                if memberSource ~= nil then
                    tURK.setBucket(memberSource, 0)
                    URKclient.notify(memberSource, {"~b~The Lobby you were in was deleted, you have been returned to the main dimension."})
                end
            end
            deathMatch[deathmatch] = nil
        end
    end
end)

RegisterNetEvent("URK:deathMatchJoin")
AddEventHandler("URK:deathMatchJoin", function(deathmatch)
    local source = source
    local user_id = URK.getUserId(source)
    URK.prompt(source,"Enter Password:","",function(player,password) 
        if password ~= deathMatch[deathmatch].password then
            URKclient.notify(source, {"~r~Invalid Password."})
            return
        else
            tURK.setBucket(source, deathmatch)
            table.insert(deathMatch[deathmatch].members, user_id)
            URKclient.notify(source, {"~b~You have joined a deathmatch lobby "..deathMatch[deathmatch].name..' owned by '..deathMatch[deathmatch].ownerName..'.'})
        end
    end)
end)

RegisterNetEvent("URK:deathMatchLeave")
AddEventHandler("URK:deathMatchLeave", function()
    local source = source
    local user_id = URK.getUserId(source)
    tURK.setBucket(source, 0)
    URKclient.notify(source, {"~b~You have left the deathmatch lobby."})
end)

