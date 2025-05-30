tURK = tURK or {}

function tURK.getFactionGroups(source)
    local user_id = URK.getUserId(source)
    if not user_id then
        print("[tURK] No user_id found for source:", source)
        return
    end

    -- Get Discord ID from user_id
    local result = exports['ghmattimysql']:executeSync("SELECT discord_id FROM `urk_verification` WHERE user_id = @user_id", {user_id = user_id})
    if result and result[1] and result[1].discord_id then
        local discord_id = result[1].discord_id
        print("[tURK] Syncing Discord roles for user_id: " .. user_id .. " (Discord: " .. discord_id .. ")")
        -- Call the exported sync function from the urk resource
        exports['urk']:SyncDiscordRoles(discord_id)
    else
        print("[tURK] No Discord ID found for user_id: " .. tostring(user_id))
    end
end

local cfg = module("cfg/player_state")
local a = module("URKFirearms", "cfg/weapons")
local lang = URK.lang

baseplayers = {}

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    print("[DEBUG] URK:playerSpawn event triggered for user_id:", user_id, "source:", source, "first_spawn:", first_spawn)
    Debug.pbegin("playerSpawned_player_state")
    local player = source
    tURK.getFactionGroups(source)
    local data = URK.getUserDataTable(user_id)
    local tmpdata = URK.getUserTmpTable(user_id)
    local playername = GetPlayerName(player)

    if not data then
        print("[ERROR] No user data found for user_id:", user_id)
        return
    end

    if first_spawn then -- first spawn
        if data.customization == nil then
            data.customization = cfg.default_customization
        end
        if data.invcap == nil then
            data.invcap = 30
        end
        tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                if plathours > 0 and data.invcap < 50 then
                    data.invcap = 50
                elseif plushours > 0 and data.invcap < 40 then
                    data.invcap = 40
                else
                    data.invcap = 30
                end
            end
        end)  
        if data.position == nil and cfg.spawn_enabled then
            local x = cfg.spawn_position[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local y = cfg.spawn_position[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local z = cfg.spawn_position[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            data.position = {
                x = x,
                y = y,
                z = z
            }
        end
        if data.position then
            URKclient.teleport(source, {data.position.x, data.position.y, data.position.z})
        end
        if data.weapons then
            URKclient.giveWeapons(source, {data.weapons, true})
        end
        if data.health then
            URKclient.setHealth(source, {data.health})
        end
        URKclient.setUserID(source, {user_id})
        URKclient.spawnAnim(source, {data.position})

        if URK.hasGroup(user_id, 'Founder') or URK.hasGroup(user_id, 'Developer') then
            URKclient.setDev(source, {})
        end
        if URK.hasPermission(user_id, 'cardev.menu') then
            TriggerClientEvent('URK:setCarDev', source)
        end
        if URK.hasPermission(user_id, 'police.onduty.permission') then
            URKclient.setPolice(source, {true})
            TriggerClientEvent('URKUI5:globalOnPoliceDuty', source, true)
        end
        if URK.hasPermission(user_id, 'nhs.onduty.permission') then
            URKclient.setNHS(source, {true})
            TriggerClientEvent('URKUI5:globalOnNHSDuty', source, true)
        end
        if URK.hasPermission(user_id, 'prisonguard.onduty.permission') then
            URKclient.setHMP(source, {true})
            TriggerClientEvent('URKUI5:globalOnPrisonDuty', source, true)
        end
        if URK.hasGroup(user_id, 'Taco Seller') then
            TriggerClientEvent('URK:toggleTacoJob', source, true)
        end
        if URK.hasGroup(user_id, 'Police Horse Trained') then
            URKclient.setglobalHorseTrained(source, {})
        end
            
        local adminlevel = 0
        print("[DEBUG] Checking staff groups for user_id:", user_id)
        if URK.hasGroup(user_id,"Founder") then
            print("[DEBUG] User has group: Founder")
            adminlevel = 13
        elseif URK.hasGroup(user_id,"Developer") then
            print("[DEBUG] User has group: Developer")
            adminlevel = 12
        elseif URK.hasGroup(user_id,"Community Manager") then
            print("[DEBUG] User has group: Community Manager")
            adminlevel = 11
        elseif URK.hasGroup(user_id,"Staff Manager") then    
            print("[DEBUG] User has group: Staff Manager")
            adminlevel = 9
        elseif URK.hasGroup(user_id,"Head Admin") then
            print("[DEBUG] User has group: Head Admin")
            adminlevel = 8
        elseif URK.hasGroup(user_id,"Senior Admin") then
            print("[DEBUG] User has group: Senior Admin")
            adminlevel = 7
        elseif URK.hasGroup(user_id,"Admin") then
            print("[DEBUG] User has group: Admin")
            adminlevel = 6
        elseif URK.hasGroup(user_id,"Senior Moderator") then
            print("[DEBUG] User has group: Senior Moderator")
            adminlevel = 5
        elseif URK.hasGroup(user_id,"Moderator") then
            print("[DEBUG] User has group: Moderator")
            adminlevel = 4
        elseif URK.hasGroup(user_id,"Support Team") then
            print("[DEBUG] User has group: Support Team")
            adminlevel = 3
        elseif URK.hasGroup(user_id,"Trial Staff") then
            print("[DEBUG] User has group: Trial Staff")
            adminlevel = 2
        else
            print("[DEBUG] User has no staff group")
        end
        print("[DEBUG] Setting staff level to:", adminlevel)
        URKclient.setStaffLevel(source, {adminlevel})
        URKclient.tunnelTest(source, {"Hello from server!"})

        TriggerClientEvent('URK:sendGarageSettings', source)
        players = URK.getUsers({})
        for k,v in pairs(players) do
            baseplayers[v] = URK.getUserId(v)
        end
        URKclient.setBasePlayers(source, {baseplayers})

    else -- not first spawn (player died), don't load weapons, empty wallet, empty inventory
        URK.clearInventory(user_id) 
        URK.setMoney(user_id, 0)
        URKclient.setHandcuffed(player, {false})

        if cfg.spawn_enabled then -- respawn (CREATED SPAWN_DEATH)
            local x = cfg.spawn_death[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local y = cfg.spawn_death[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local z = cfg.spawn_death[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            data.position = {
                x = x,
                y = y,
                z = z
            }
            URKclient.teleport(source, {x, y, z})
            URKclient.setPlayerState(source, {
                health = 200,
                armour = 0,
                position = data.position,
                weapons = {}
            })
        end
    end
    Debug.pend()
end)

function tURK.updateWeapons(weapons)
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        local data = URK.getUserDataTable(user_id)
        if data ~= nil then
            data.weapons = weapons
        end
    end
end

function tURK.UpdatePlayTime()
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        local data = URK.getUserDataTable(user_id)
        if data ~= nil then
            if data.PlayerTime ~= nil then
                data.PlayerTime = tonumber(data.PlayerTime) + 1
            else
                data.PlayerTime = 1
            end
        end
        if URK.hasPermission(user_id, 'police.onduty.permission') then
            local lastClockedRank = string.gsub(getGroupInGroups(user_id, 'Police'), ' Clocked', '')
            exports['ghmattimysql']:execute("INSERT INTO urk_police_hours (user_id, username, weekly_hours, total_hours, last_clocked_rank, last_clocked_date, total_players_fined, total_players_jailed) VALUES (@user_id, @username, @weekly_hours, @total_hours, @last_clocked_rank, @last_clocked_date, @total_players_fined, @total_players_jailed) ON DUPLICATE KEY UPDATE weekly_hours = weekly_hours + 1/60, total_hours = total_hours + 1/60, username = @username, last_clocked_rank = @last_clocked_rank, last_clocked_date = @last_clocked_date, total_players_fined = @total_players_fined, total_players_jailed = @total_players_jailed", {user_id = user_id, username = GetPlayerName(source), weekly_hours = 1/60, total_hours = 1/60, last_clocked_rank = lastClockedRank, last_clocked_date = os.date("%d/%m/%Y"), total_players_fined = 0, total_players_jailed = 0})
        end
    end
end

function URK.updateInvCap(user_id, invcap)
    if user_id ~= nil then
        local data = URK.getUserDataTable(user_id)
        if data ~= nil then
            if data.invcap ~= nil then
                data.invcap = invcap
            else
                data.invcap = 30
            end
        end
    end
end

function tURK.setBucket(source, bucket)
    local source = source
    local user_id = URK.getUserId(source)
    SetPlayerRoutingBucket(source, bucket)
    TriggerClientEvent('URK:setBucket', source, bucket)
end

local isStoring = {}
AddEventHandler('URK:StoreWeaponsRequest', function(source)
    local player = source 
    local user_id = URK.getUserId(player)
	URKclient.getWeapons(player,{},function(weapons)
        if not isStoring[player] then
            isStoring[player] = true
            URKclient.giveWeapons(player,{{},true}, function(removedwep)
                for k,v in pairs(weapons) do
                    if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                        if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                            for i,c in pairs(a.weapons) do
                                if i == k then
                                    URK.giveInventoryItem(user_id, "wbody|"..k, 1, true)
                                end   
                            end
                        end
                    end
                end
                URKclient.notify(player,{"~g~Weapons Stored"})
                SetTimeout(3000,function()
                      isStoring[player] = nil 
                end)
            end)
        else
            URKclient.notify(player,{"~o~Your weapons are already being stored hmm..."})
        end
    end)
end)

RegisterNetEvent('URK:forceStoreWeapons')
AddEventHandler('URK:forceStoreWeapons', function()
    local source = source 
    local user_id = URK.getUserId(source)
    local data = URK.getUserDataTable(user_id)
    Wait(3000)
    if data ~= nil then
        data.inventory = {}
    end
    tURK.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            local invcap = 30
            if plathours > 0 then
                invcap = invcap + 20
            elseif plushours > 0 then
                invcap = invcap + 10
            end
            if invcap == 30 then
            return
            end
            if data.invcap - 15 == invcap then
            URK.giveInventoryItem(user_id, "offwhitebag", 1, false)
            elseif data.invcap - 20 == invcap then
            URK.giveInventoryItem(user_id, "guccibag", 1, false)
            elseif data.invcap - 30 == invcap  then
            URK.giveInventoryItem(user_id, "nikebag", 1, false)
            elseif data.invcap - 35 == invcap  then
            URK.giveInventoryItem(user_id, "huntingbackpack", 1, false)
            elseif data.invcap - 40 == invcap  then
            URK.giveInventoryItem(user_id, "greenhikingbackpack", 1, false)
            elseif data.invcap - 70 == invcap  then
            URK.giveInventoryItem(user_id, "rebelbackpack", 1, false)
            end
            URK.updateInvCap(user_id, invcap)
        end
    end)
end)

AddEventHandler('playerSpawned', function()
    local source = source
    local user_id = URK.getUserId(source)
    if user_id then
        local data = URK.getUserDataTable(user_id)
        if not data then
            print("[ERROR] No user data found for user_id:", user_id)
            return
        end

        if data.position then
            URKclient.teleport(source, {data.position.x, data.position.y, data.position.z})
        end

        if data.weapons then
            URKclient.giveWeapons(source, {data.weapons, true})
        end

        if data.health then
            URKclient.setHealth(source, {data.health})
        end

        -- Handle staff groups
        local adminlevel = 0
        if URK.hasGroup(user_id, "Founder") then
            adminlevel = 13
        elseif URK.hasGroup(user_id, "Developer") then
            adminlevel = 12
        elseif URK.hasGroup(user_id, "Community Manager") then
            adminlevel = 11
        elseif URK.hasGroup(user_id, "Staff Manager") then
            adminlevel = 9
        elseif URK.hasGroup(user_id, "Head Admin") then
            adminlevel = 8
        elseif URK.hasGroup(user_id, "Senior Admin") then
            adminlevel = 7
        elseif URK.hasGroup(user_id, "Admin") then
            adminlevel = 6
        elseif URK.hasGroup(user_id, "Senior Moderator") then
            adminlevel = 5
        elseif URK.hasGroup(user_id, "Moderator") then
            adminlevel = 4
        elseif URK.hasGroup(user_id, "Support Team") then
            adminlevel = 3
        elseif URK.hasGroup(user_id, "Trial Staff") then
            adminlevel = 2
        end

        URKclient.setStaffLevel(source, {adminlevel})
        URKclient.tunnelTest(source, {"Hello from server!"})

        -- Handle other player data
        if data.inventory then
            URKclient.setInventory(source, {data.inventory})
        end

        if data.money then
            URKclient.setMoney(source, {data.money})
        end

        -- Set player state
        URKclient.setPlayerState(source, {
            health = data.health or 200,
            armour = data.armour or 0,
            position = data.position,
            weapons = data.weapons
        })
    end
end)

local function spawnPlayer(source, first_spawn)
    local user_id = URK.getUserId(source)
    if not user_id then return end

    local user_data = URK.getUserDataTable(user_id)
    if not user_data then 
        print("[URK] No user data found for user_id:", user_id)
        return 
    end

    -- Get the player's current position
    local ped = GetPlayerPed(source)
    local currentPos = GetEntityCoords(ped)
    local currentHeading = GetEntityHeading(ped)

    -- If this is first spawn, use the saved position or default spawn
    if first_spawn then
        if user_data.position and user_data.position.x and user_data.position.y and user_data.position.z then
            currentPos = vector3(user_data.position.x, user_data.position.y, user_data.position.z)
            currentHeading = user_data.position.heading or 0.0
        else
            -- Default spawn location if no saved position
            currentPos = vector3(195.17, -933.77, 30.69)
            currentHeading = 144.5
        end
    end

    -- Set player position
    SetEntityCoords(ped, currentPos.x, currentPos.y, currentPos.z)
    SetEntityHeading(ped, currentHeading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetCanAttackFriendly(ped, true, false)
    NetworkSetFriendlyFireOption(true)

    -- Give weapons if they exist
    if user_data.weapons then
        for k,v in pairs(user_data.weapons) do
            URK.giveWeapon(source, v.weapon_id, v.ammo, true)
        end
    end

    -- Set health and armor
    local health = user_data.health or 200
    local armor = user_data.armor or 0
    SetEntityHealth(ped, health)
    SetPedArmour(ped, armor)

    -- Set player state
    URK.setPlayerState(source, {
        health = health,
        armor = armor,
        position = {
            x = currentPos.x,
            y = currentPos.y,
            z = currentPos.z,
            heading = currentHeading
        },
        weapons = user_data.weapons or {}
    })

    -- Unfreeze after a short delay
    Citizen.SetTimeout(1000, function()
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
    end)

    -- Check staff groups
    print("[DEBUG] Checking staff groups for user_id:", user_id)
    local staff_level = 0
    if URK.hasGroup(user_id, "Founder") then
        print("[DEBUG] User has group: Founder")
        staff_level = 13
    elseif URK.hasGroup(user_id, "Head Admin") then
        print("[DEBUG] User has group: Head Admin")
        staff_level = 12
    elseif URK.hasGroup(user_id, "Senior Admin") then
        print("[DEBUG] User has group: Senior Admin")
        staff_level = 11
    elseif URK.hasGroup(user_id, "Admin") then
        print("[DEBUG] User has group: Admin")
        staff_level = 10
    elseif URK.hasGroup(user_id, "Senior Mod") then
        print("[DEBUG] User has group: Senior Mod")
        staff_level = 9
    elseif URK.hasGroup(user_id, "Moderator") then
        print("[DEBUG] User has group: Moderator")
        staff_level = 8
    elseif URK.hasGroup(user_id, "Senior Support") then
        print("[DEBUG] User has group: Senior Support")
        staff_level = 7
    elseif URK.hasGroup(user_id, "Support") then
        print("[DEBUG] User has group: Support")
        staff_level = 6
    elseif URK.hasGroup(user_id, "Senior Helper") then
        print("[DEBUG] User has group: Senior Helper")
        staff_level = 5
    elseif URK.hasGroup(user_id, "Helper") then
        print("[DEBUG] User has group: Helper")
        staff_level = 4
    elseif URK.hasGroup(user_id, "Senior Trial") then
        print("[DEBUG] User has group: Senior Trial")
        staff_level = 3
    elseif URK.hasGroup(user_id, "Trial Staff") then
        print("[DEBUG] User has group: Trial Staff")
        staff_level = 2
    end
    print("[DEBUG] Setting staff level to:", staff_level)
    URK.setStaffLevel(source, staff_level)
end

-- Add a spawn lock to prevent multiple spawns
local spawnLock = {}
AddEventHandler('URK:playerSpawn', function(first_spawn)
    local source = source
    local user_id = URK.getUserId(source)
    
    print("[DEBUG] URK:playerSpawn event triggered for user_id:", user_id, "source:", source, "first_spawn:", first_spawn)
    
    -- Check if already spawning
    if spawnLock[source] then
        print("[DEBUG] Spawn already in progress for source:", source)
        return
    end
    
    spawnLock[source] = true
    
    -- Spawn the player
    spawnPlayer(source, first_spawn)
    
    -- Clear spawn lock after a delay
    Citizen.SetTimeout(2000, function()
        spawnLock[source] = nil
    end)
end)
