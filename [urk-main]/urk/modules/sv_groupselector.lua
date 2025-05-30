local cfg=module("cfg/cfg_groupselector")

function URK.getJobSelectors(source)
    local source=source
    local jobSelectors={}
    local user_id = URK.getUserId(source)
    for k,v in pairs(cfg.selectors) do
        for i,j in pairs(cfg.selectorTypes) do
            if v.type == i then
                if j._config.permissions[1]~=nil then
                    if URK.hasPermission(URK.getUserId(source),j._config.permissions[1])then
                        v['_config'] = j._config
                        v['jobs'] = {}
                        for a,b in pairs(j.jobs) do
                            if URK.hasGroup(user_id, b[1]) then
                                table.insert(v['jobs'], b)
                            end
                        end
                        jobSelectors[k] = v
                    end
                else
                    v['_config'] = j._config
                    v['jobs'] = j.jobs
                    jobSelectors[k] = v
                end
            end
        end
    end
    TriggerClientEvent("URK:gotJobSelectors",source,jobSelectors)
end

RegisterNetEvent("URK:getJobSelectors")
AddEventHandler("URK:getJobSelectors",function()
    local source = source
    URK.getJobSelectors(source)
end)

function URK.removeAllJobs(user_id)
    local source = URK.getUserSource(user_id)
    for i,j in pairs(cfg.selectorTypes) do
        for k,v in pairs(j.jobs)do
            if i == 'default' and URK.hasGroup(user_id, v[1]) then
                URK.removeUserGroup(user_id, v[1])
            elseif i ~= 'default' and URK.hasGroup(user_id, v[1]..' Clocked') then
                URK.removeUserGroup(user_id, v[1]..' Clocked')
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                URKclient.setArmour(source, {0})
                TriggerEvent('URK:clockedOffRemoveRadio', source)
            end
        end
    end
    -- remove all faction ranks
    URKclient.setPolice(source, {false})
    TriggerClientEvent('URKUI5:globalOnPoliceDuty', source, false)
    URKclient.setNHS(source, {false})
    TriggerClientEvent('URKUI5:globalOnNHSDuty', source, false)
    URKclient.setHMP(source, {false})
    TriggerClientEvent('URKUI5:globalOnPrisonDuty', source, false)
    URKclient.setLFB(source, {false})
    TriggerClientEvent('URK:disableFactionBlips', source)
    TriggerClientEvent('URK:radiosClearAll', source)
    -- toggle all main jobs to false
    TriggerClientEvent('URK:toggleTacoJob', source, false)
end

RegisterNetEvent("URK:jobSelector")
AddEventHandler("URK:jobSelector",function(a,b)
    local source = source
    local user_id = URK.getUserId(source)
    if #(GetEntityCoords(GetPlayerPed(source)) - cfg.selectors[a].position) > 20 then
        TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Triggering job selections from too far away')
        return
    end
    if b == "Unemployed" then
        URK.removeAllJobs(user_id)
        URKclient.notify(source, {"~g~You are now unemployed."})
    else
        if cfg.selectors[a].type == 'police' then
            if URK.hasGroup(user_id, b) then
                URK.removeAllJobs(user_id)
                URK.addUserGroup(user_id,b..' Clocked')
                URKclient.setPolice(source, {true})
                TriggerClientEvent('URKUI5:globalOnPoliceDuty', source, true)
                URKclient.notify(source, {"~g~Clocked on as "..b.."."})
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                tURK.sendWebhook('pd-clock', 'URK Police Clock On Logs',"> Officer Name: **"..GetPlayerName(source).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
            else
                URKclient.notify(source, {"~r~You do not have permission to clock on as "..b.."."})
            end
        elseif cfg.selectors[a].type == 'nhs' then
            if URK.hasGroup(user_id, b) then
                URK.removeAllJobs(user_id)
                URK.addUserGroup(user_id,b..' Clocked')
                URKclient.setNHS(source, {true})
                TriggerClientEvent('URKUI5:globalOnNHSDuty', source, true)
                URKclient.notify(source, {"~g~Clocked on as "..b.."."})
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                tURK.sendWebhook('nhs-clock', 'URK NHS Clock On Logs',"> Medic Name: **"..GetPlayerName(source).."**\n> Medic TempID: **"..source.."**\n> Medic PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
            else
                URKclient.notify(source, {"~r~You do not have permission to clock on as "..b.."."})
            end
        elseif cfg.selectors[a].type == 'lfb' then
            if URK.hasGroup(user_id, b) then
                URK.removeAllJobs(user_id)
                URK.addUserGroup(user_id,b..' Clocked')
                URKclient.setLFB(source, {true})
                URKclient.notify(source, {"~g~Clocked on as "..b.."."})
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                tURK.sendWebhook('lfb-clock', 'URK LFB Clock On Logs',"> Firefighter Name: **"..GetPlayerName(source).."**\n> Firefighter TempID: **"..source.."**\n> Firefighter PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
            else
                URKclient.notify(source, {"~r~You do not have permission to clock on as "..b.."."})
            end
        elseif cfg.selectors[a].type == 'hmp' then
            if URK.hasGroup(user_id, b) then
                URK.removeAllJobs(user_id)
                URK.addUserGroup(user_id,b..' Clocked')
                URKclient.setHMP(source, {true})
                TriggerClientEvent('URKUI5:globalOnPrisonDuty', source, true)
                URKclient.notify(source, {"~g~Clocked on as "..b.."."})
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                tURK.sendWebhook('hmp-clock', 'URK HMP Clock On Logs',"> Prison Officer Name: **"..GetPlayerName(source).."**\n> Prison Officer TempID: **"..source.."**\n> Prison Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
            else
                URKclient.notify(source, {"~r~You do not have permission to clock on as "..b.."."})
            end
        else
            URK.removeAllJobs(user_id)
            URK.addUserGroup(user_id,b)
            URKclient.notify(source, {"~g~Employed as "..b.."."})
            TriggerClientEvent('URK:jobInstructions',source,b)
            if b == 'Taco Seller' then
                TriggerClientEvent('URK:toggleTacoJob', source, true)
            end
        end
        TriggerEvent('URK:clockedOnCreateRadio', source)
        TriggerClientEvent('URK:radiosClearAll', source)
        TriggerClientEvent('URK:refreshGunStorePermissions', source)
        URK.updateCurrentPlayerInfo()
    end
end)