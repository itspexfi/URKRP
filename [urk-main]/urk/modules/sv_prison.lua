MySQL.createCommand("URK/get_prison_time","SELECT prison_time FROM urk_prison WHERE user_id = @user_id")
MySQL.createCommand("URK/set_prison_time","UPDATE urk_prison SET prison_time = @prison_time WHERE user_id = @user_id")
MySQL.createCommand("URK/add_prisoner", "INSERT IGNORE INTO urk_prison SET user_id = @user_id")
MySQL.createCommand("URK/get_current_prisoners", "SELECT * FROM urk_prison WHERE prison_time > 0")

local cfg = module("cfg/cfg_prison")
local prisonItems = {"toothbrush", "blade", "rope", "metal_rod", "spring"}

local lastCellUsed = 0

AddEventHandler("playerJoining", function()
    local user_id = URK.getUserId(source)
    MySQL.execute("URK/add_prisoner", {user_id = user_id})
end)

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        MySQL.query("URK/get_prison_time", {user_id = user_id}, function(prisontime)
            if prisontime ~= nil then 
                if prisontime[1].prison_time > 0 then
                    if lastCellUsed == 27 then
                        lastCellUsed = 0
                    end
                    TriggerClientEvent('URK:putInPrisonOnSpawn', source, lastCellUsed+1)
                    TriggerClientEvent('URK:forcePlayerInPrison', source, true)
                    TriggerClientEvent('URK:prisonCreateBreakOutAreas', source)
                    TriggerClientEvent('URK:prisonUpdateClientTimer', source, prisontime[1].prison_time)
                    local prisonItemsTable = {}
                    for k,v in pairs(cfg.prisonItems) do
                        local item = math.random(1, #prisonItems)
                        prisonItemsTable[prisonItems[item]] = v
                    end
                    TriggerClientEvent('URK:prisonCreateItemAreas', source, prisonItemsTable)
                end
            end
        end)
    end
end)

RegisterNetEvent("URK:getNumOfNHSOnline")
AddEventHandler("URK:getNumOfNHSOnline", function()
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URK/get_prison_time", {user_id = user_id}, function(prisontime)
        if prisontime ~= nil then 
            if prisontime[1].prison_time > 0 then
                TriggerClientEvent('URK:prisonSpawnInMedicalBay', source)
                URKclient.RevivePlayer(source, {})
            else
                TriggerClientEvent('URK:getNumberOfDocsOnline', source, #URK.getUsersByPermission('nhs.onduty.permission'))
            end
        end
    end)
end)

RegisterServerEvent("URK:prisonArrivedForJail")
AddEventHandler("URK:prisonArrivedForJail", function()
    local source = source
    local user_id = URK.getUserId(source)
    MySQL.query("URK/get_prison_time", {user_id = user_id}, function(prisontime)
        if prisontime ~= nil then 
            if prisontime[1].prison_time > 0 then
                tURK.setBucket(source, 0)
                TriggerClientEvent('URK:forcePlayerInPrison', source, true)
                TriggerClientEvent('URK:prisonCreateBreakOutAreas', source)
                TriggerClientEvent('URK:prisonUpdateClientTimer', source, prisontime[1].prison_time)
            end
        end
    end)
end)

local prisonPlayerJobs = {}

RegisterServerEvent("URK:prisonStartJob")
AddEventHandler("URK:prisonStartJob", function(job)
    local source = source
    local user_id = URK.getUserId(source)
    prisonPlayerJobs[user_id] = job
end)

RegisterServerEvent("URK:prisonEndJob")
AddEventHandler("URK:prisonEndJob", function(job)
    local source = source
    local user_id = URK.getUserId(source)
    if prisonPlayerJobs[user_id] == job then
        prisonPlayerJobs[user_id] = nil
        MySQL.query("URK/get_prison_time", {user_id = user_id}, function(prisontime)
            if prisontime ~= nil then 
                if prisontime[1].prison_time > 21 then
                    MySQL.execute("URK/set_prison_time", {user_id = user_id, prison_time = prisontime[1].prison_time - 20})
                    TriggerClientEvent('URK:prisonUpdateClientTimer', source, prisontime[1].prison_time - 20)
                    URKclient.notify(source, {"~g~Prison time reduced by 20s."})
                end
            end
        end)
    end
end)

RegisterServerEvent("URK:jailPlayer")
AddEventHandler("URK:jailPlayer", function(player)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'police.onduty.permission') then
        URKclient.getNearestPlayers(source,{15},function(nplayers)
            if nplayers[player] then
                URKclient.isHandcuffed(player,{}, function(handcuffed)  -- check handcuffed
                    if handcuffed then
                        -- check for gc in cfg 
                        MySQL.query("URK/get_prison_time", {user_id = URK.getUserId(player)}, function(prisontime)
                            if prisontime ~= nil then 
                                if prisontime[1].prison_time == 0 then
                                    URK.prompt(source,"Jail Time (in minutes):","",function(source,jailtime) 
                                        local jailtime = math.floor(tonumber(jailtime) * 60)
                                        if jailtime > 0 and jailtime <= cfg.maxTimeNotGc then
                                            -- check if gc then compare jailtime to 
                                            -- maxTimeGc = 7200,
                                            MySQL.execute("URK/set_prison_time", {user_id = URK.getUserId(player), prison_time = jailtime})
                                            if lastCellUsed == 27 then
                                                lastCellUsed = 0
                                            end
                                            TriggerClientEvent('URK:prisonTransportWithBus', player, lastCellUsed+1)
                                            tURK.setBucket(player, lastCellUsed+1)
                                            local prisonItemsTable = {}
                                            for k,v in pairs(cfg.prisonItems) do
                                                local item = math.random(1, #prisonItems)
                                                prisonItemsTable[prisonItems[item]] = v
                                            end
                                            TriggerClientEvent('URK:prisonCreateItemAreas', player, prisonItemsTable)
                                            URKclient.notify(source, {"~g~Jailed Player."})
                                            tURK.sendWebhook('jail-player', 'URK Jail Logs',"> Officer Name: **"..GetPlayerName(source).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Criminal Name: **"..GetPlayerName(player).."**\n> Criminal PermID: **"..URK.getUserId(player).."**\n> Criminal TempID: **"..player.."**\n> Duration: **"..math.floor(jailtime/60).." minutes**")
                                        else
                                            URKclient.notify(source, {"~r~Invalid time."})
                                        end
                                    end)
                                else
                                    URKclient.notify(source, {"~r~Player is already in prison."})
                                end
                            end
                        end)
                    else
                        URKclient.notify(source, {"~r~You must have the player handcuffed."})
                    end
                end)
            else
                URKclient.notify(source, {"~r~Player not found."})
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        MySQL.query("URK/get_current_prisoners", {}, function(currentPrisoners)
            if #currentPrisoners > 0 then 
                for k,v in pairs(currentPrisoners) do
                    MySQL.execute("URK/set_prison_time", {user_id = v.user_id, prison_time = v.prison_time-1})
                    if v.prison_time-1 == 0 and URK.getUserSource(v.user_id) ~= nil then
                        TriggerClientEvent('URK:prisonStopClientTimer', URK.getUserSource(v.user_id))
                        TriggerClientEvent('URK:prisonReleased', URK.getUserSource(v.user_id))
                        TriggerClientEvent('URK:forcePlayerInPrison', URK.getUserSource(v.user_id), false)
                        URKclient.setHandcuffed(URK.getUserSource(v.user_id), {false})
                    end
                end
            end
        end)
        Citizen.Wait(1000)
    end
end)

RegisterCommand('unjail', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'admin.noclip') then
        URK.prompt(source,"Enter Temp ID:","",function(source, player) 
            local player = tonumber(player)
            if player ~= nil then
                MySQL.execute("URK/set_prison_time", {user_id = URK.getUserId(player), prison_time = 0})
                TriggerClientEvent('URK:prisonStopClientTimer', player)
                TriggerClientEvent('URK:prisonReleased', player)
                TriggerClientEvent('URK:forcePlayerInPrison', player, false)
                URKclient.setHandcuffed(player, {false})
                URKclient.notify(source, {"~g~Target will be released soon."})
            else
                URKclient.notify(source, {"~r~Invalid ID."})
            end
        end)
    end
end)


AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent('URK:prisonUpdateGuardNumber', -1, #URK.getUsersByPermission('prisonguard.onduty.permission'))
    end
end)

local currentLockdown = false
RegisterServerEvent("URK:prisonToggleLockdown")
AddEventHandler("URK:prisonToggleLockdown", function(lockdownState)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasPermission(user_id, 'dev.menu') then -- change this to the hmp hq permission
        currentLockdown = lockdownState
        if currentLockdown then
            TriggerClientEvent('URK:prisonSetAllDoorStates', -1, 1)
        else
            TriggerClientEvent('URK:prisonSetAllDoorStates', -1)
        end
    end
end)

RegisterServerEvent("URK:prisonSetDoorState")
AddEventHandler("URK:prisonSetDoorState", function(doorHash, state)
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:prisonSyncDoor', -1, doorHash, state)
end)

RegisterServerEvent("URK:enterPrisonAreaSyncDoors")
AddEventHandler("URK:enterPrisonAreaSyncDoors", function()
    local source = source
    local user_id = URK.getUserId(source)
    TriggerClientEvent('URK:prisonAreaSyncDoors', source, doors)
end)

-- on pickup 
-- URK:prisonRemoveItemAreas(item)

-- hmp should be able to see all prisoners
-- URK:requestPrisonerData