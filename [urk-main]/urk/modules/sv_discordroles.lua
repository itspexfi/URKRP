local cfg = module("cfg/discordroles")
local FormattedToken = "Bot " .. cfg.Bot_Token
local Discord_Sources = {} -- Discord ID: (User Source, User ID)

local error_codes_defined = {
	[200] = 'OK - The request was completed successfully..!',
	[400] = "Error - The request was improperly formatted, or the server couldn't understand it..!",
	[401] = 'Error - The Authorization header was missing or invalid..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[403] = 'Error - The Authorization token you passed did not have permission to the resource..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[404] = "Error - The resource at the location specified doesn't exist.",
	[429] = 'Error - Too many requests, you hit the Discord rate limit. https://discord.com/developers/docs/topics/rate-limits',
	[502] = 'Error - Discord API may be down?...'
}

local connectionStatus = {
    isConnected = false,
    lastCheck = 0,
    retryCount = 0,
    maxRetries = 3,
    lastRoles = {} -- Ensure this is initialized
}

local function CheckDiscordConnection()
    if not cfg.Bot_Token or cfg.Bot_Token == "" then
        print("[Discord API] No bot token configured")
        return false
    end

    local success, result = pcall(function()
        local headers = {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = 'Bot ' .. cfg.Bot_Token
        }
        
        local response = PerformHttpRequest('https://discord.com/api/v10/users/@me', function(err, text, headers)
            if err == 200 then
                connectionStatus.isConnected = true
                connectionStatus.lastCheck = os.time()
                connectionStatus.retryCount = 0
                print("[Discord API] Connection test successful")
            else
                connectionStatus.isConnected = false
                connectionStatus.retryCount = connectionStatus.retryCount + 1
                print("[Discord API] Connection test failed: " .. tostring(err))
            end
        end, 'GET', '', headers)
    end)

    if not success then
        print("[Discord API] Error checking connection: " .. tostring(result))
        connectionStatus.isConnected = false
        return false
    end

    return connectionStatus.isConnected
end

local function DiscordRequest(method, endpoint, jsondata)
    if not connectionStatus.isConnected then
        if not CheckDiscordConnection() then
            print("[Discord API] Not connected to Discord, skipping request")
            return nil
        end
    end

    local data = nil
    local retries = 5
    local retryDelay = 2000
    local maxTimeout = 20000
    local isRequestComplete = false

    local function makeRequest()
        if isRequestComplete then return end
        
        local startTime = GetGameTimer()
        
        PerformHttpRequest("https://discord.com/api/v10/" .. endpoint, function(errorCode, resultData, resultHeaders)
            if isRequestComplete then return end
            if GetGameTimer() - startTime > maxTimeout then
                isRequestComplete = true
                return
            end

            if errorCode == 200 then
                data = {data = resultData, code = errorCode, headers = resultHeaders}
                isRequestComplete = true
            elseif errorCode == 429 then -- Rate limit
                local retryAfter = tonumber(resultHeaders["Retry-After"]) or 5
                print("[Discord API] Rate limited, retrying after " .. retryAfter .. " seconds")
                Citizen.Wait(retryAfter * 1000)
                if not isRequestComplete then
                    makeRequest()
                end
            elseif errorCode == 404 then -- Not found
                print("[Discord API] Resource not found (404). Please check your guild ID and bot permissions.")
                data = {data = nil, code = errorCode, headers = resultHeaders}
                isRequestComplete = true
            elseif errorCode == 403 then -- Forbidden
                print("[Discord API] Bot lacks permissions (403). Please check bot permissions.")
                data = {data = nil, code = errorCode, headers = resultHeaders}
                isRequestComplete = true
            elseif errorCode == 502 or errorCode == 503 or errorCode == 504 then -- Server errors
                if retries > 0 then
                    retries = retries - 1
                    print("[Discord API] Server error, retrying... (" .. retries .. " attempts left)")
                    Citizen.Wait(retryDelay)
                    if not isRequestComplete then
                        makeRequest()
                    end
                else
                    print("[Discord API] Max retries reached, using fallback behavior")
                    data = {data = nil, code = errorCode, headers = resultHeaders}
                    isRequestComplete = true
                end
            else
                print("[Discord API] Error: " .. errorCode)
                data = {data = nil, code = errorCode, headers = resultHeaders}
                isRequestComplete = true
            end
        end, method, #jsondata > 0 and jsondata or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})
    end

    makeRequest()

    local startTime = GetGameTimer()
    while not isRequestComplete and GetGameTimer() - startTime < maxTimeout do
        Citizen.Wait(100)
    end
    
    if not isRequestComplete then
        print("[Discord API] Request timed out, using fallback behavior")
        isRequestComplete = true
        return {data = nil, code = 408, headers = {}}
    end
    
    return data
end

local function GetIdentifier(source, id_type)
    if type(id_type) ~= "string" then
		return print('Invalid usage')
	end

    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, id_type) then
            return identifier
        end
    end
    return nil
end

local function Get_Client_Discord_ID(source)
    if not source then return nil end
    local result = exports['ghmattimysql']:executeSync("SELECT discord_id FROM `urk_verification` WHERE user_id = @user_id", {user_id = URK.getUserId(source)})
    if result and result[1] then
        return result[1].discord_id
    end
    return nil
end

local function Client_Has_Role(roles_table, role_id)
	for _, table_role_id in pairs(roles_table) do
		if tostring(table_role_id) == tostring(role_id) or tostring(_) == tostring(role_id) then
			return true
		end
	end
	return false
end

local function Get_Client_Has_Roles(guild_roles, client_roles)
    if not guild_roles or not client_roles then
        print("[Discord API] Invalid role data in Get_Client_Has_Roles")
        return {}, {}
    end

    local has_roles = {}
    local does_not_have_roles = {}

    for role_name, guild_role_id in pairs(guild_roles) do
        local found_role = false
        for _, client_role_id in pairs(client_roles) do
            if tostring(guild_role_id) == tostring(client_role_id) then
                found_role = true
                table.insert(has_roles, guild_role_id)
                break
            end
        end
        
        if not found_role then
            table.insert(does_not_have_roles, guild_role_id)
        end
    end

    return has_roles, does_not_have_roles
end

local recent_role_cache = {}
local function GetDiscordRoles(guild_id, user_discord_id)
    if not guild_id or not user_discord_id then
        print("[Discord API] Invalid parameters for GetDiscordRoles")
        return {}
    end

    -- Check cache first
    if cfg.CacheDiscordRoles and recent_role_cache[user_discord_id] and recent_role_cache[user_discord_id][guild_id] then
        return recent_role_cache[user_discord_id][guild_id]
    end

    -- Check connection status cache
    if connectionStatus.lastRoles[user_discord_id] and connectionStatus.lastRoles[user_discord_id][guild_id] then
        local cacheTime = GetGameTimer() - connectionStatus.lastRoles[user_discord_id].timestamp
        if cacheTime < 300000 then -- 5 minutes cache
            return connectionStatus.lastRoles[user_discord_id].roles
        end
    end

    -- Try to get roles from Discord with proper error handling
    local success, result = pcall(function()
        local endpoint = ("guilds/%s/members/%s"):format(guild_id, user_discord_id)
        return DiscordRequest("GET", endpoint, {})
    end)
    
    if not success then
        print("[Discord API] Error getting roles:", result)
        return {}
    end
    
    if result.code == 200 then
        local success, data = pcall(json.decode, result.data)
        if success and data and data.roles then
            -- Update connection status cache
            connectionStatus.lastRoles[user_discord_id] = {
                roles = data.roles,
                timestamp = GetGameTimer()
            }
            
            if cfg.CacheDiscordRoles then
                recent_role_cache[user_discord_id] = recent_role_cache[user_discord_id] or {}
                recent_role_cache[user_discord_id][guild_id] = data.roles
                Citizen.SetTimeout(((cfg.CacheDiscordRolesTime or 60) * 1000), function()
                    if recent_role_cache[user_discord_id] then
                        recent_role_cache[user_discord_id][guild_id] = nil 
                    end
                end)
            end
            return data.roles
        end
    end
    
    -- Fallback: Check database for cached roles
    local success, cached_roles = pcall(function()
        local result = exports['ghmattimysql']:executeSync("SELECT roles FROM `urk_discord_roles` WHERE discord_id = @discord_id AND guild_id = @guild_id", {
            discord_id = user_discord_id,
            guild_id = guild_id
        })
        if result and result[1] and result[1].roles then
            return json.decode(result[1].roles)
        end
        return nil
    end)
    
    if success and cached_roles then
        print("[Discord API] Using cached roles from database for user:", user_discord_id)
        return cached_roles
    end
    
    -- Final fallback: Return empty roles if Discord is unavailable
    print("[Discord API] Using fallback roles for user:", user_discord_id)
    return {}
end

local function Modify_Client_Roles(guild_name, discord_id, user_id)
    if not guild_name or not discord_id or not user_id then 
        print("[Discord API] Invalid parameters for Modify_Client_Roles")
        return 
    end

    if not cfg.Guilds[guild_name] then
        print("[Discord API] Invalid guild name:", guild_name)
        return
    end

    if not cfg.Guild_Roles[guild_name] then
        print("[Discord API] No roles configured for guild:", guild_name)
        return
    end
    
    local discord_roles = GetDiscordRoles(cfg.Guilds[guild_name], discord_id)
    if not discord_roles then
        print("[Discord API] Failed to get roles for user:", discord_id)
        return
    end

    -- Cache roles in database for fallback
    pcall(function()
        exports['ghmattimysql']:execute("INSERT INTO `urk_discord_roles` (discord_id, guild_id, roles) VALUES (@discord_id, @guild_id, @roles) ON DUPLICATE KEY UPDATE roles = @roles", {
            discord_id = discord_id,
            guild_id = cfg.Guilds[guild_name],
            roles = json.encode(discord_roles)
        })
    end)

    local has_roles, does_not_have_roles = Get_Client_Has_Roles(cfg.Guild_Roles[guild_name], discord_roles)
    
    -- Remove roles that player no longer has
    for _, role_id in pairs(does_not_have_roles) do
        for k,v in pairs(cfg.Guild_Roles[guild_name]) do
            if v == role_id and URK.hasGroup(user_id, k) then
                URK.removeUserGroup(user_id, k)
            end
        end
    end

    -- Add roles that player should have
    for _, role_id in pairs(has_roles) do
        for k,v in pairs(cfg.Guild_Roles[guild_name]) do
            if v == role_id and not URK.hasGroup(user_id, k) then
                URK.addUserGroup(user_id, k)
            end
        end
    end
    
    local user_source = URK.getUserSource(user_id)
    if user_source then
        URK.getJobSelectors(user_source)
    end
end

local tracked = {}
RegisterNetEvent('URK:getFactionWhitelistedGroups')
AddEventHandler('URK:getFactionWhitelistedGroups', function()
	local source = source
	tURK.getFactionGroups(source)
end)

-- Add proper error handling for all Discord API calls
local function SafeDiscordCall(callback, ...)
    local success, result = pcall(callback, ...)
    if not success then
        print("[Discord API] Error in Discord call:", result)
        return nil
    end
    return result
end

-- Function to update connection status
local function UpdateConnectionStatus(success)
    connectionStatus.lastCheck = GetGameTimer()
    connectionStatus.isConnected = success
    if success then
        connectionStatus.retryCount = 0
    else
        connectionStatus.retryCount = connectionStatus.retryCount + 1
    end
end

-- Check connection on resource start with proper error handling
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds before checking
    local success, result = pcall(function()
        return CheckDiscordConnection()
    end)
    
    if not success then
        print("[Discord API] WARNING: Discord API connection check failed:", result)
    elseif not result then
        print("[Discord API] WARNING: Discord API connection failed. Some features may be limited.")
    end
end)

-- Add periodic connection monitoring with exponential backoff
Citizen.CreateThread(function()
    while true do
        if not connectionStatus.isConnected then
            CheckDiscordConnection()
        end
        Citizen.Wait(300000) -- Check every 5 minutes
    end
end)

-- Add connection status getter
function tURK.getDiscordConnectionStatus()
    return connectionStatus.isConnected
end

-- Add role cache cleanup
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3600000) -- Clean up every hour
        local currentTime = GetGameTimer()
        for discord_id, guild_data in pairs(connectionStatus.lastRoles) do
            if currentTime - guild_data.timestamp > 3600000 then -- Remove entries older than 1 hour
                connectionStatus.lastRoles[discord_id] = nil
            end
        end
    end
end)

function tURK.getFactionGroups(source)
    if not source then 
        print("[Discord API] Invalid source in getFactionGroups")
        return 
    end
    
    local fivem_license = GetIdentifier(source, 'license')
    if not fivem_license then 
        print("[Discord API] No license found for source:", source)
        return 
    end
    
    if not tracked[fivem_license] then 
        tracked[fivem_license] = true
    end

    local user_id = URK.getUserId(source)
    if not user_id then 
        print("[Discord API] No user ID found for source:", source)
        return 
    end
    
    local discord_id = Get_Client_Discord_ID(source)
    if discord_id then
        Discord_Sources[discord_id] = {user_source = source, user_id = user_id}
        
        -- Try each guild in sequence, with error handling
        local guilds = {'Main', 'Police', 'NHS'}
        for _, guild in ipairs(guilds) do
            if cfg.Guilds[guild] and cfg.Guild_Roles[guild] then
                SafeDiscordCall(Modify_Client_Roles, guild, discord_id, user_id)
            end
        end
    end
end

local function Get_Guild_Nickname(guild_id, discord_id)
	local endpoint = ("guilds/%s/members/%s"):format(guild_id, discord_id)
	local member = DiscordRequest("GET", endpoint, {})
	if member.code == 200 then
		local data = json.decode(member.data)
		local nickname = data.nick
		return nickname
	else
		return nil
	end
end

exports('Get_Client_Discord_ID', function(source)
	return Get_Client_Discord_ID(source)
end)

exports('Get_Guild_Nickname', function(guild_id, discord_id)
	return Get_Guild_Nickname(guild_id, discord_id)
end)

exports('Get_Guilds', function()
	return cfg.Guilds
end)

exports('Get_User_Source', function(user_discord_id)
	return Discord_Sources[user_discord_id]
end)

-- Add guild verification
local function VerifyGuild(guild_id)
    if not guild_id then return false end
    
    local success, result = pcall(function()
        return DiscordRequest("GET", "guilds/" .. guild_id, {})
    end)
    
    if not success then
        print("[Discord API] Error verifying guild:", result)
        return false
    end
    
    if result.code == 200 then
        local success, data = pcall(json.decode, result.data)
        if success and data then
            print("[Discord API] Successfully verified guild: " .. data.name .. " (" .. data.id .. ")")
            return true
        end
    elseif result.code == 404 then
        print("[Discord API] Guild not found. Please check your guild ID.")
        return false
    elseif result.code == 403 then
        print("[Discord API] Bot lacks permissions to access guild. Please check bot permissions.")
        return false
    end
    
    return false
end

-- Modify the guild status check
local function Get_Guild_Status(guild)
    if guild.code == 200 then
        local success, data = pcall(json.decode, guild.data)
        if success and data then
            print(("Successful connection to Guild: %s (%s)"):format(data.name, data.id))
            return true
        end
    else
        local error_msg = "Unknown error"
        if guild.data then
            local success, error_data = pcall(json.decode, guild.data)
            if success and error_data and error_data.message then
                error_msg = error_data.message
            end
        end
        print(("An error occurred while connecting to guild. Error: %s (Code: %s)"):format(error_msg, guild.code))
        return false
    end
    return false
end

-- Add periodic guild verification
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- Check every 5 minutes
        if cfg.Multiguild then 
            for guild_name, guildID in pairs(cfg.Guilds) do
                if not VerifyGuild(guildID) then
                    print("[Discord API] Warning: Failed to verify guild " .. guild_name)
                end
            end
        else
            if not VerifyGuild(cfg.Guild_ID) then
                print("[Discord API] Warning: Failed to verify main guild")
            end
        end
    end
end)

-- Modify the initial guild check
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds before checking
    if cfg.Multiguild then 
        for guild_name, guildID in pairs(cfg.Guilds) do
            local guild = DiscordRequest("GET", "guilds/" .. guildID, {})
            if not Get_Guild_Status(guild) then
                print("[Discord API] Warning: Failed to connect to guild " .. guild_name)
            end
        end
    else
        local guild = DiscordRequest("GET", "guilds/" .. cfg.Guild_ID, {})
        if not Get_Guild_Status(guild) then
            print("[Discord API] Warning: Failed to connect to main guild")
        end
    end
end)

-- Add proper error handling for role checks
function tURK.checkForRole(user_id, role_id)
    local success, result = pcall(function()
        local discord_id = exports['ghmattimysql']:executeSync("SELECT discord_id FROM `urk_verification` WHERE user_id = @user_id", {user_id = user_id})[1].discord_id
        if not discord_id then
            return false
        end
        local endpoint = ("guilds/%s/members/%s"):format(cfg.Guild_ID, discord_id)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data then
                local has_role = Client_Has_Role(data.roles, role_id)
                return has_role
            end
        end
        return false
    end)
    
    if not success then
        print("[Discord API] Error checking role:", result)
        return false
    end
    
    return result
end