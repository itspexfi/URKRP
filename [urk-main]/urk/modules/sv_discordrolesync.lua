local cfg = module("cfg/discordroles")

-- Discord API request function
local function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    if jsondata then
        data = json.encode(jsondata)
    end
    local headers = {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. cfg.Bot_Token
    }
    print("^2[DEBUG] Making Discord API request to: " .. endpoint)
    print("^2[DEBUG] Using token: " .. string.sub(cfg.Bot_Token, 1, 10) .. "...")
    
    local p = promise.new()
    
    PerformHttpRequest('https://discord.com/api/v10/' .. endpoint, function(err, text, headers)
        if err then
            print("^1[ERROR] Discord API request failed: " .. tostring(err))
            p:resolve({code = err, data = text})
        else
            print("^2[DEBUG] Discord API response code: " .. tostring(headers['status']))
            p:resolve({code = headers['status'], data = text})
        end
    end, method, data, headers)
    
    return Citizen.Await(p)
end

-- Store pending role changes
local pendingRoleChanges = {}

-- Function to get user's Discord ID from their FiveM ID
local function GetDiscordIdFromUserId(user_id)
    local result = exports['ghmattimysql']:executeSync("SELECT discord_id FROM `urk_verification` WHERE user_id = @user_id", {user_id = user_id})
    if result and result[1] then
        return result[1].discord_id
    end
    return nil
end

-- Function to get user's FiveM ID from their Discord ID
local function GetUserIdFromDiscordId(discord_id)
    local result = exports['ghmattimysql']:executeSync("SELECT user_id FROM `urk_verification` WHERE discord_id = @discord_id", {discord_id = discord_id})
    if result and result[1] then
        return result[1].user_id
    end
    return nil
end

-- Function to save groups to database
local function SaveGroupsToDatabase(user_id, groups)
    local result = exports['ghmattimysql']:executeSync("SELECT * FROM `urk_user_data` WHERE user_id = ? AND dkey = 'URK:datatable'", {user_id = user_id})
    if result and result[1] then
        local data = json.decode(result[1].dvalue)
        data.groups = groups
        exports['ghmattimysql']:execute("UPDATE `urk_user_data` SET dvalue = ? WHERE user_id = ? AND dkey = 'URK:datatable'", {json.encode(data), user_id})
    end
end

-- Function to get all Discord roles for a guild
local function GetAllDiscordRoles(guild_id)
    local endpoint = ("guilds/%s/roles"):format(guild_id)
    local roles = DiscordRequest("GET", endpoint, {})
    if roles.code == 200 then
        return json.decode(roles.data)
    end
    return {}
end

-- Function to sync roles from Discord to FiveM
local function SyncDiscordRoles(discord_id)
    print("^2[DEBUG] Starting role sync for Discord ID: " .. discord_id)
    
    local user_id = GetUserIdFromDiscordId(discord_id)
    if not user_id then 
        print("^1[ERROR] Could not find FiveM user ID for Discord ID: " .. discord_id)
        return 
    end
    print("^2[DEBUG] Found FiveM user ID: " .. user_id)

    -- Get Discord roles for the user
    local endpoint = ("guilds/%s/members/%s"):format(cfg.Guild_ID, discord_id)
    local member = DiscordRequest("GET", endpoint, {})
    
    if member.code == 200 then
        local data = json.decode(member.data)
        local roles = data.roles
        print("^2[DEBUG] Found Discord roles: " .. json.encode(roles))

        -- Store the roles for this user
        pendingRoleChanges[user_id] = roles

        -- If the user is online, apply the changes immediately
        local source = URK.getUserSource(user_id)
        if source then
            ApplyRoleChanges(user_id, roles)
        end
    else
        print("^1[ERROR] Failed to get Discord member data. Code: " .. member.code)
    end
end

-- Function to apply role changes
local function ApplyRoleChanges(user_id, roles)
    print("^2[DEBUG] Applying role changes for user: " .. user_id)
    
    -- Get current groups
    local user_groups = URK.getUserGroups(user_id)
    
    -- Get all Discord roles for the guild
    local all_roles = GetAllDiscordRoles(cfg.Guild_ID)
    local role_map = {}
    
    -- Create a map of role IDs to role names
    for _, role in ipairs(all_roles) do
        role_map[role.id] = role.name
    end

    -- First, handle configured role mappings
    for guild_name, guild_roles in pairs(cfg.Guild_Roles) do
        print("^2[DEBUG] Checking configured guild: " .. guild_name)
        for group_name, role_id in pairs(guild_roles) do
            local has_role = false
            for _, user_role in pairs(roles) do
                if tostring(user_role) == tostring(role_id) then
                    has_role = true
                    print("^2[DEBUG] Found matching configured role: " .. group_name .. " (ID: " .. role_id .. ")")
                    break
                end
            end

            -- Add or remove group based on Discord role
            if has_role and not URK.hasGroup(user_id, group_name) then
                print("^2[DEBUG] Adding configured group: " .. group_name .. " to user: " .. user_id)
                URK.addUserGroup(user_id, group_name)
                user_groups[group_name] = true
            elseif not has_role and URK.hasGroup(user_id, group_name) then
                print("^2[DEBUG] Removing configured group: " .. group_name .. " from user: " .. user_id)
                URK.removeUserGroup(user_id, group_name)
                user_groups[group_name] = nil
            end
        end
    end

    -- Then, handle all other Discord roles
    for _, role_id in pairs(roles) do
        local role_name = role_map[role_id]
        if role_name then
            -- Skip roles that are already handled by the config
            local is_configured = false
            for _, guild_roles in pairs(cfg.Guild_Roles) do
                for _, configured_role_id in pairs(guild_roles) do
                    if tostring(role_id) == tostring(configured_role_id) then
                        is_configured = true
                        break
                    end
                end
                if is_configured then break end
            end

            if not is_configured then
                -- Add the role as a group if it's not already handled
                if not URK.hasGroup(user_id, role_name) then
                    print("^2[DEBUG] Adding unconfigured group: " .. role_name .. " to user: " .. user_id)
                    URK.addUserGroup(user_id, role_name)
                    user_groups[role_name] = true
                end
            end
        end
    end

    -- Remove groups that don't correspond to any Discord roles
    for group_name, _ in pairs(user_groups) do
        local has_corresponding_role = false
        
        -- Check if it's a configured group
        for _, guild_roles in pairs(cfg.Guild_Roles) do
            for configured_group, role_id in pairs(guild_roles) do
                if configured_group == group_name then
                    for _, user_role in pairs(roles) do
                        if tostring(user_role) == tostring(role_id) then
                            has_corresponding_role = true
                            break
                        end
                    end
                end
                if has_corresponding_role then break end
            end
            if has_corresponding_role then break end
        end

        -- Check if it's an unconfigured group
        if not has_corresponding_role then
            for _, role_id in pairs(roles) do
                if role_map[role_id] == group_name then
                    has_corresponding_role = true
                    break
                end
            end
        end

        -- Remove the group if it doesn't have a corresponding role
        if not has_corresponding_role then
            print("^2[DEBUG] Removing group without Discord role: " .. group_name .. " from user: " .. user_id)
            URK.removeUserGroup(user_id, group_name)
            user_groups[group_name] = nil
        end
    end

    -- Save updated groups to database
    SaveGroupsToDatabase(user_id, user_groups)

    -- In ApplyRoleChanges, after creating role_map, add:
    for _, role_id in pairs(roles) do
        if tostring(role_id) == '1203967504687566874' then -- Lead Developer Discord role ID
            if not URK.hasGroup(user_id, 'Developer') then
                print("[DEBUG] Mapping Lead Developer Discord role to Developer group for user:", user_id)
                URK.addUserGroup(user_id, 'Developer')
            end
        end
    end
end

-- Event handler for when a user joins the server
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id then
        local discord_id = GetDiscordIdFromUserId(user_id)
        if discord_id then
            -- If we have pending role changes, apply them
            if pendingRoleChanges[user_id] then
                ApplyRoleChanges(user_id, pendingRoleChanges[user_id])
                pendingRoleChanges[user_id] = nil
            else
                -- Otherwise, sync from Discord
                SyncDiscordRoles(discord_id)
            end
        end
    end
end)

-- Export the sync function for external use
exports('SyncDiscordRoles', SyncDiscordRoles) 

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    -- Replace with your actual function to get user_id from source
    local user_id = URK.getUserId(source)
    if not user_id then
        print("[URK] Could not get user_id for source: " .. tostring(source))
        return
    end

    -- Get Discord ID from user_id
    local result = exports['ghmattimysql']:executeSync("SELECT discord_id FROM `urk_verification` WHERE user_id = @user_id", {user_id = user_id})
    if result and result[1] and result[1].discord_id then
        local discord_id = result[1].discord_id
        print("[URK] Syncing Discord roles for user_id: " .. user_id .. " (Discord: " .. discord_id .. ")")
        -- Call the sync function (make sure it's globally accessible or use exports if needed)
        SyncDiscordRoles(discord_id)
    else
        print("[URK] No Discord ID found for user_id: " .. tostring(user_id))
    end
end)