MySQL = module("modules/MySQL")

Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
Lang = module("lib/Lang")
Debug = module("lib/Debug")

local config = module("cfg/base")
local version = module("version")


local verify_card = {
    ["type"] = "AdaptiveCard",
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"] = "1.3",
    ["backgroundImage"] = {
        ["url"] = "https://media.discordapp.net/attachments/1073970014081790043/1127055566922072225/image_1_1.png",
    },
    ["body"] = {
        {
            ["type"] = "TextBlock",
            ["text"] = "In order to connect to URK you must be in our discord and verify your account, please follow the instructions below",
            ["wrap"] = true,
            ["weight"] = "Bolder"
        },
        {
            ["type"] = "Container",
            ["items"] = {
                {
                    ["type"] = "TextBlock",
                    ["text"] = "1. Join the URK discord (discord.gg/urkfivemfivem)",
                    ["wrap"] = true,
                },
                {
                    ["type"] = "TextBlock",
                    ["text"] = "2. In the #verify channel, type the following command:",
                    ["wrap"] = true,
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "Attention",
                    ["text"] = "3. !verify NULL",
                    ["wrap"] = true,
                }
            }
        },
        {
            ["type"] = "ActionSet",
            ["actions"] = {
                {
                    ["type"] = "Action.Submit",
                    ["title"] = "Enter URK",
                    ["id"] = "played"
                }
            }
        },
    }
}


Debug.active = config.debug
URK = {}
Proxy.addInterface("URK",URK)

tURK = {}
Tunnel.bindInterface("URK",tURK) -- listening for client tunnel

-- load language 
local dict = module("cfg/lang/"..config.lang) or {}
URK.lang = Lang.new(dict)

-- init
URKclient = Tunnel.getInterface("URK","URK") -- server -> client tunnel

URK.users = {} -- will store logged users (id) by first identifier
URK.rusers = {} -- store the opposite of users
URK.user_tables = {} -- user data tables (logger storage, saved to database)
URK.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
URK.user_sources = {} -- user sources 
-- queries
Citizen.CreateThread(function()
    Wait(1000) -- Wait for GHMatti to Initialize
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_users(
    id INTEGER AUTO_INCREMENT,
    last_login VARCHAR(100),
    username VARCHAR(100),
    whitelisted BOOLEAN,
    banned BOOLEAN,
    bantime VARCHAR(100) NOT NULL DEFAULT "",
    banreason VARCHAR(1000) NOT NULL DEFAULT "",
    banadmin VARCHAR(100) NOT NULL DEFAULT "",
    baninfo VARCHAR(2000) NOT NULL DEFAULT "",
    CONSTRAINT pk_user PRIMARY KEY(id)
    );
    ]])
    MySQL.SingleQuery([[
    ALTER TABLE urk_users
    ADD COLUMN IF NOT EXISTS username VARCHAR(100);
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_ids (
    identifier VARCHAR(100) NOT NULL,
    user_id INTEGER,
    banned BOOLEAN,
    CONSTRAINT pk_user_ids PRIMARY KEY(identifier)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_tokens (
    token VARCHAR(200),
    user_id INTEGER,
    banned BOOLEAN  NOT NULL DEFAULT 0,
    CONSTRAINT pk_user_tokens PRIMARY KEY(token)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_data(
    user_id INTEGER,
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
    CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES urk_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_moneys(
    user_id INTEGER,
    wallet bigint,
    bank bigint,
    CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
    CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES urk_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_srv_data(
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_srv_data PRIMARY KEY(dkey)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_vehicles(
    user_id INTEGER,
    vehicle VARCHAR(100),
    vehicle_plate varchar(255) NOT NULL,
    rented BOOLEAN NOT NULL DEFAULT 0,
    rentedid varchar(200) NOT NULL DEFAULT '',
    rentedtime varchar(2048) NOT NULL DEFAULT '',
    locked BOOLEAN NOT NULL DEFAULT 0,
    fuel_level FLOAT NOT NULL DEFAULT 100,
    impounded BOOLEAN NOT NULL DEFAULT 0,
    impound_info varchar(2048) NOT NULL DEFAULT '',
    impound_time VARCHAR(100) NOT NULL DEFAULT '',
    CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
    CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES urk_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_identities(
    user_id INTEGER,
    registration VARCHAR(100),
    phone VARCHAR(100),
    firstname VARCHAR(100),
    name VARCHAR(100),
    age INTEGER,
    CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
    CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES urk_users(id) ON DELETE CASCADE,
    INDEX(registration),
    INDEX(phone)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE INDEX IF NOT EXISTS idx_phone ON urk_user_identities(phone);
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_warnings (
    warning_id INT AUTO_INCREMENT,
    user_id INT,
    warning_type VARCHAR(25),
    duration INT,
    admin VARCHAR(100),
    warning_date DATE,
    reason VARCHAR(2000),
    PRIMARY KEY (warning_id)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_gangs (
    gangname VARCHAR(255) NULL DEFAULT NULL,
    gangmembers VARCHAR(3000) NULL DEFAULT NULL,
    funds BIGINT NULL DEFAULT NULL,
    logs VARCHAR(3000) NULL DEFAULT NULL,
    PRIMARY KEY (gangname)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_notes (
    user_id INT,
    info VARCHAR(500) NULL DEFAULT NULL,
    PRIMARY KEY (user_id)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_user_homes(
    user_id INTEGER,
    home VARCHAR(100),
    number INTEGER,
    rented BOOLEAN NOT NULL DEFAULT 0,
    rentedid varchar(200) NOT NULL DEFAULT '',
    rentedtime varchar(2048) NOT NULL DEFAULT '',
    CONSTRAINT pk_user_homes PRIMARY KEY(home),
    CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES urk_users(id) ON DELETE CASCADE,
    UNIQUE(home,number)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_bans_offenses(
    UserID INTEGER AUTO_INCREMENT,
    Rules TEXT NULL DEFAULT NULL,
    points INT(10) NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(UserID)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_dvsa(
    user_id INT(11),
    licence VARCHAR(100) NULL DEFAULT NULL,
    testsaves VARCHAR(1000) NULL DEFAULT NULL,
    points VARCHAR(500) NULL DEFAULT NULL,
    id VARCHAR(500) NULL DEFAULT NULL,
    datelicence VARCHAR(500) NULL DEFAULT NULL,
    penalties VARCHAR(500) NULL DEFAULT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_subscriptions(
    user_id INT(11),
    plathours FLOAT(10) NULL DEFAULT NULL,
    plushours FLOAT(10) NULL DEFAULT NULL,
    last_used VARCHAR(100) NOT NULL DEFAULT "",
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_casino_chips(
    user_id INT(11),
    chips bigint NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_verification(
    user_id INT(11),
    code VARCHAR(100) NULL DEFAULT NULL,
    discord_id VARCHAR(100) NULL DEFAULT NULL,
    verified TINYINT NULL DEFAULT NULL,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_users_contacts (
    id int(11) NOT NULL AUTO_INCREMENT,
    identifier varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
    number varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
    display varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '-1',
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_messages (
    id int(11) NOT NULL AUTO_INCREMENT,
    transmitter varchar(10) NOT NULL,
    receiver varchar(10) NOT NULL,
    message varchar(255) NOT NULL DEFAULT '0',
    time timestamp NOT NULL DEFAULT current_timestamp(),
    isRead int(11) NOT NULL DEFAULT 0,
    owner int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_calls (
    id int(11) NOT NULL AUTO_INCREMENT,
    owner varchar(10) NOT NULL COMMENT 'Num such owner',
    num varchar(10) NOT NULL COMMENT 'Reference number of the contact',
    incoming int(11) NOT NULL COMMENT 'Defined if we are at the origin of the calls',
    time timestamp NOT NULL DEFAULT current_timestamp(),
    accepts int(11) NOT NULL COMMENT 'Calls accept or not',
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_app_chat (
    id int(11) NOT NULL AUTO_INCREMENT,
    channel varchar(20) NOT NULL,
    message varchar(255) NOT NULL,
    time timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS twitter_tweets (
    id int(11) NOT NULL AUTO_INCREMENT,
    authorId int(11) NOT NULL,
    realUser varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    message varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
    time timestamp NOT NULL DEFAULT current_timestamp(),
    likes int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY FK_twitter_tweets_twitter_accounts (authorId),
    CONSTRAINT FK_twitter_tweets_twitter_accounts FOREIGN KEY (authorId) REFERENCES twitter_accounts (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS twitter_likes (
    id int(11) NOT NULL AUTO_INCREMENT,
    authorId int(11) DEFAULT NULL,
    tweetId int(11) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY FK_twitter_likes_twitter_accounts (authorId),
    KEY FK_twitter_likes_twitter_tweets (tweetId),
    CONSTRAINT FK_twitter_likes_twitter_accounts FOREIGN KEY (authorId) REFERENCES twitter_accounts (id),
    CONSTRAINT FK_twitter_likes_twitter_tweets FOREIGN KEY (tweetId) REFERENCES twitter_tweets (id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS twitter_accounts (
    id int(11) NOT NULL AUTO_INCREMENT,
    username varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
    password varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
    avatar_url varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY username (username)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_community_pot (
    urk VARCHAR(65) NOT NULL,
    value BIGINT(11) NOT NULL,
    PRIMARY KEY (urk)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_quests (
    user_id INT(11),
    quests_completed INT(11) NOT NULL DEFAULT 0,
    reward_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_weapon_whitelists (
    user_id INT(11),
    weapon_info varchar(2048) DEFAULT '{}',
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_weapon_codes (
    user_id INT(11),
    spawncode varchar(2048) NOT NULL DEFAULT '',
    weapon_code int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (weapon_code)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_prison (
    user_id INT(11),
    prison_time INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_staff_tickets (
    user_id INT(11),
    ticket_count INT(11) NOT NULL DEFAULT 0,
    username VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_daily_rewards (
    user_id INT(11),
    last_reward INT(11) NOT NULL DEFAULT 0,
    streak INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS urk_police_hours (
    user_id INT(11),
    weekly_hours FLOAT(10) NOT NULL DEFAULT 0,
    total_hours FLOAT(10) NOT NULL DEFAULT 0,
    username VARCHAR(100) NOT NULL,
    last_clocked_date VARCHAR(100) NOT NULL,
    last_clocked_rank VARCHAR(100) NOT NULL,
    total_players_fined INT(11) NOT NULL DEFAULT 0,
    total_players_jailed INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery("ALTER TABLE urk_users ADD IF NOT EXISTS last_login varchar(100);")
    MySQL.SingleQuery("ALTER TABLE urk_users ADD IF NOT EXISTS bantime varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE urk_users ADD IF NOT EXISTS banreason varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE urk_users ADD IF NOT EXISTS banadmin varchar(100) NOT NULL DEFAULT ''; ")
    MySQL.SingleQuery("ALTER TABLE urk_user_vehicles ADD IF NOT EXISTS rented BOOLEAN NOT NULL DEFAULT 0;")
    MySQL.SingleQuery("ALTER TABLE urk_user_vehicles ADD IF NOT EXISTS rentedid varchar(200) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE urk_user_vehicles ADD IF NOT EXISTS rentedtime varchar(2048) NOT NULL DEFAULT '';")
    MySQL.createCommand("URKls/create_modifications_column", "alter table urk_user_vehicles add if not exists modifications text not null")
	MySQL.createCommand("URKls/update_vehicle_modifications", "update urk_user_vehicles set modifications = @modifications where user_id = @user_id and vehicle = @vehicle")
	MySQL.createCommand("URKls/get_vehicle_modifications", "select modifications, vehicle_plate from urk_user_vehicles where user_id = @user_id and vehicle = @vehicle")
	MySQL.execute("URKls/create_modifications_column")
    print("[URK] ^2Base tables initialised.^0")
end)

MySQL.createCommand("URK/create_user","INSERT INTO urk_users(whitelisted,banned) VALUES(false,false)")
MySQL.createCommand("URK/add_identifier","INSERT INTO urk_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
MySQL.createCommand("URK/userid_byidentifier","SELECT user_id FROM urk_user_ids WHERE identifier = @identifier")
MySQL.createCommand("URK/identifier_all","SELECT * FROM urk_user_ids WHERE identifier = @identifier")
MySQL.createCommand("URK/select_identifier_byid_all","SELECT * FROM urk_user_ids WHERE user_id = @id")

MySQL.createCommand("URK/set_userdata","REPLACE INTO urk_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
MySQL.createCommand("URK/get_userdata","SELECT dvalue FROM urk_user_data WHERE user_id = @user_id AND dkey = @key")

MySQL.createCommand("URK/set_srvdata","REPLACE INTO URK_srv_data(dkey,dvalue) VALUES(@key,@value)")
MySQL.createCommand("URK/get_srvdata","SELECT dvalue FROM URK_srv_data WHERE dkey = @key")

MySQL.createCommand("URK/get_banned","SELECT banned FROM urk_users WHERE id = @user_id")
MySQL.createCommand("URK/set_banned","UPDATE urk_users SET banned = @banned, bantime = @bantime,  banreason = @banreason,  banadmin = @banadmin, baninfo = @baninfo WHERE id = @user_id")
MySQL.createCommand("URK/set_identifierbanned","UPDATE urk_user_ids SET banned = @banned WHERE identifier = @iden")
MySQL.createCommand("URK/getbanreasontime", "SELECT * FROM urk_users WHERE id = @user_id")

MySQL.createCommand("URK/get_whitelisted","SELECT whitelisted FROM urk_users WHERE id = @user_id")
MySQL.createCommand("URK/set_whitelisted","UPDATE urk_users SET whitelisted = @whitelisted WHERE id = @user_id")
MySQL.createCommand("URK/set_last_login","UPDATE urk_users SET last_login = @last_login WHERE id = @user_id")
MySQL.createCommand("URK/get_last_login","SELECT last_login FROM urk_users WHERE id = @user_id")

--Token Banning 
MySQL.createCommand("URK/add_token","INSERT INTO urk_user_tokens(token,user_id) VALUES(@token,@user_id)")
MySQL.createCommand("URK/check_token","SELECT user_id, banned FROM urk_user_tokens WHERE token = @token")
MySQL.createCommand("URK/check_token_userid","SELECT token FROM urk_user_tokens WHERE user_id = @id")
MySQL.createCommand("URK/ban_token","UPDATE urk_user_tokens SET banned = @banned WHERE token = @token")
--Token Banning

-- removing anticheat ban entry
MySQL.createCommand("ac/delete_ban","DELETE FROM urk_anticheat WHERE @user_id = user_id")


-- init tables


-- identification system

function URK.getUserIdByIdentifiers(ids, cbr)
    local task = Task(cbr)
    if ids ~= nil and #ids then
        local i = 0
        local function search()
            i = i+1
            if i <= #ids then
                if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
                    MySQL.query("URK/userid_byidentifier", {identifier = ids[i]}, function(rows, affected)
                        if #rows > 0 then  -- found
                            task({rows[1].user_id})
                        else -- not found
                            search()
                        end
                    end)
                else
                    search()
                end
            else -- no ids found, create user
                MySQL.query("URK/create_user", {}, function(rows, affected)
                    if rows.affectedRows > 0 then
                        local user_id = rows.insertId
                        -- add identifiers
                        for l,w in pairs(ids) do
                            if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
                                MySQL.execute("URK/add_identifier", {user_id = user_id, identifier = w})
                            end
                        end
                        for k,v in pairs(URK.getUsers()) do
                            URKclient.notify(v, {'~g~You have received £10,000 as someone new has joined the server.'})
                            URK.giveBankMoney(k, 10000)
                        end
                        task({user_id})
                    else
                        task()
                    end
                end)
            end
        end
        search()
    else
        task()
    end
end

-- return identification string for the source (used for non URK identifications, for rejected players)
function URK.getSourceIdKey(source)
    local ids = GetPlayerIdentifiers(source)
    local idk = "idk_"
    for k,v in pairs(ids) do
        idk = idk..v
    end
    return idk
end

function URK.getPlayerIP(player)
    return GetPlayerEP(player) or "0.0.0.0"
end

function URK.getPlayerName(player)
    return GetPlayerName(player) or "unknown"
end

--- sql

function URK.ReLoadChar(source)
    local name = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source)
    URK.getUserIdByIdentifiers(ids, function(user_id)
        if user_id ~= nil then  
            URK.StoreTokens(source, user_id) 
            if URK.rusers[user_id] == nil then -- not present on the server, init
                URK.users[ids[1]] = user_id
                URK.rusers[user_id] = ids[1]
                URK.user_tables[user_id] = {}
                URK.user_tmp_tables[user_id] = {}
                URK.user_sources[user_id] = source
                URK.getUData(user_id, "URK:datatable", function(sdata)
                    local data = json.decode(sdata)
                    if type(data) == "table" then URK.user_tables[user_id] = data end
                    local tmpdata = URK.getUserTmpTable(user_id)
                    URK.getLastLogin(user_id, function(last_login)
                        tmpdata.last_login = last_login or ""
                        tmpdata.spawns = 0
                        local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                        MySQL.execute("URK/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                        print("[URK] "..name.." ("..GetPlayerName(source)..") joined (Perm ID = "..user_id..")")
                        TriggerEvent("URK:playerJoin", user_id, source, name, tmpdata.last_login)
                        TriggerClientEvent("URK:CheckIdRegister", source)
                    end)
                end)
            else -- already connected
                print("[URK] "..name.." ("..GetPlayerName(source)..") re-joined (Perm ID = "..user_id..")")
                TriggerEvent("URK:playerRejoin", user_id, source, name)
                TriggerClientEvent("URK:CheckIdRegister", source)
                local tmpdata = URK.getUserTmpTable(user_id)
                tmpdata.spawns = 0
            end
        end
    end)
end

exports("urkbot", function(method_name, params, cb)
    if cb then 
        cb(URK[method_name](table.unpack(params)))
    else 
        return URK[method_name](table.unpack(params))
    end
end)

RegisterNetEvent("URK:CheckID")
AddEventHandler("URK:CheckID", function()
    local source = source
    local user_id = URK.getUserId(source)
    if not user_id then
        URK.ReLoadChar(source)
    end
end)

function URK.isBanned(user_id, cbr)
    local task = Task(cbr, {false})
    MySQL.query("URK/get_banned", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].banned})
        else
            task()
        end
    end)
end

function URK.isWhitelisted(user_id, cbr)
    local task = Task(cbr, {false})
    MySQL.query("URK/get_whitelisted", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].whitelisted})
        else
            task()
        end
    end)
end

function URK.setWhitelisted(user_id,whitelisted)
    MySQL.execute("URK/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

function URK.getLastLogin(user_id, cbr)
    local task = Task(cbr,{""})
    MySQL.query("URK/get_last_login", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].last_login})
        else
            task()
        end
    end)
end

function URK.fetchBanReasonTime(user_id,cbr)
    MySQL.query("URK/getbanreasontime", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then 
            cbr(rows[1].bantime, rows[1].banreason, rows[1].banadmin)
        end
    end)
end

function URK.setUData(user_id,key,value)
    MySQL.execute("URK/set_userdata", {user_id = user_id, key = key, value = value})
end

function URK.getUData(user_id,key,cbr)
    local task = Task(cbr,{""})
    MySQL.query("URK/get_userdata", {user_id = user_id, key = key}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

function URK.setSData(key,value)
    MySQL.execute("URK/set_srvdata", {key = key, value = value})
end

function URK.getSData(key, cbr)
    local task = Task(cbr,{""})
    MySQL.query("URK/get_srvdata", {key = key}, function(rows, affected)
        if rows and #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

-- return user data table for URK internal persistant connected user storage
function URK.getUserDataTable(user_id)
    return URK.user_tables[user_id]
end

function URK.getUserTmpTable(user_id)
    return URK.user_tmp_tables[user_id]
end

function URK.isConnected(user_id)
    return URK.rusers[user_id] ~= nil
end

function URK.isFirstSpawn(user_id)
    local tmp = URK.getUserTmpTable(user_id)
    return tmp and tmp.spawns == 1
end

function URK.getUserId(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return URK.users[ids[1]]
        end
    end
    return nil
end

-- return map of user_id -> player source
function URK.getUsers()
    local users = {}
    for k,v in pairs(URK.user_sources) do
        users[k] = v
    end
    return users
end

-- return source or nil
function URK.getUserSource(user_id)
    return URK.user_sources[user_id]
end

function URK.IdentifierBanCheck(source,user_id,cb)
    for i,v in pairs(GetPlayerIdentifiers(source)) do 
        MySQL.query('URK/identifier_all', {identifier = v}, function(rows)
            for i = 1,#rows do 
                if rows[i].banned then 
                    if user_id ~= rows[i].user_id then 
                        cb(true, rows[i].user_id)
                    end 
                end
            end
        end)
    end
end

function URK.BanIdentifiers(user_id, value)
    MySQL.query('URK/select_identifier_byid_all', {id = user_id}, function(rows)
        for i = 1, #rows do 
            MySQL.execute("URK/set_identifierbanned", {banned = value, iden = rows[i].identifier })
        end
    end)
end

function calculateTimeRemaining(expireTime)
    local datetime = ''
    local expiry = os.date("%d/%m/%Y at %H:%M", tonumber(expireTime))
    local hoursLeft = ((tonumber(expireTime)-os.time()))/3600
    local minutesLeft = nil
    if hoursLeft < 1 then
        minutesLeft = hoursLeft * 60
        minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
        datetime = minutesLeft .. " mins" 
        return datetime
    else
        hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
        datetime = hoursLeft .. " hours" 
        return datetime
    end
    return datetime
end

function URK.setBanned(user_id,banned,time,reason,admin,baninfo)
    if banned then 
        MySQL.execute("URK/set_banned", {user_id = user_id, banned = banned, bantime = time, banreason = reason, banadmin = admin, baninfo = baninfo})
        URK.BanIdentifiers(user_id, true)
        URK.BanTokens(user_id, true) 
    else 
        MySQL.execute("URK/set_banned", {user_id = user_id, banned = banned, bantime = "", banreason =  "", banadmin =  "", baninfo = ""})
        URK.BanIdentifiers(user_id, false)
        URK.BanTokens(user_id, false) 
        MySQL.execute("ac/delete_ban", {user_id = user_id})
    end 
end

function URK.ban(adminsource,permid,time,reason,baninfo)
    local adminPermID = URK.getUserId(adminsource)
    local getBannedPlayerSrc = URK.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then 
        if tonumber(time) then
            URK.setBanned(permid,true,time,reason,GetPlayerName(adminsource),baninfo)
            URK.kick(getBannedPlayerSrc,"[URK] Ban expires in: "..calculateTimeRemaining(time).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ discord.gg/urkfivem") 
        else
            URK.setBanned(permid,true,"perm",reason,GetPlayerName(adminsource),baninfo)
            URK.kick(getBannedPlayerSrc,"[URK] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ discord.gg/urkfivem") 
        end
        URKclient.notify(adminsource,{"~g~Success banned! User PermID: " .. permid})
    else 
        if tonumber(time) then 
            URK.setBanned(permid,true,time,reason,GetPlayerName(adminsource),baninfo)
        else 
            URK.setBanned(permid,true,"perm",reason,GetPlayerName(adminsource),baninfo)
        end
        URKclient.notify(adminsource,{"~g~Success banned! User PermID: " .. permid})
    end
end

function URK.banConsole(permid,time,reason)
    local adminPermID = "URK"
    local getBannedPlayerSrc = URK.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            URK.setBanned(permid,true,banTime,reason, adminPermID)
            URK.kick(getBannedPlayerSrc,"[URK] Ban expires in "..calculateTimeRemaining(banTime).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nBanned by URK \nAppeal @ discord.gg/urkfivem") 
        else 
            URK.setBanned(permid,true,"perm",reason, adminPermID)
            URK.kick(getBannedPlayerSrc,"[URK] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nBanned by URK \nAppeal @ discord.gg/urkfivem") 
        end
        print("Successfully banned Perm ID: " .. permid)
    else 
        if tonumber(time) then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            URK.setBanned(permid,true,banTime,reason, adminPermID)
        else 
            URK.setBanned(permid,true,"perm",reason, adminPermID)
        end
        print("Successfully banned Perm ID: " .. permid)
    end
end

function URK.banDiscord(permid,time,reason,adminPermID)
    local getBannedPlayerSrc = URK.getUserSource(tonumber(permid))
    if tonumber(time) then 
        local banTime = os.time()
        banTime = banTime  + (60 * 60 * tonumber(time))  
        URK.setBanned(permid,true,banTime,reason, adminPermID)
        if getBannedPlayerSrc then 
            URK.kick(getBannedPlayerSrc,"[URK] Ban expires in "..calculateTimeRemaining(banTime).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ discord.gg/urkfivem") 
        end
    else 
        URK.setBanned(permid,true,"perm",reason,  adminPermID)
        if getBannedPlayerSrc then 
            URK.kick(getBannedPlayerSrc,"[URK] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ discord.gg/urkfivem") 
        end
    end
end

-- To use token banning you need the latest artifacts.
function URK.StoreTokens(source, user_id) 
    if GetNumPlayerTokens then 
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            MySQL.query("URK/check_token", {token = token}, function(rows)
                if token and rows and #rows <= 0 then 
                    MySQL.execute("URK/add_token", {token = token, user_id = user_id})
                end        
            end)
        end
    end
end


function URK.CheckTokens(source, user_id) 
    if GetNumPlayerTokens then 
        local banned = false;
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            local rows = MySQL.asyncQuery("URK/check_token", {token = token, user_id = user_id})
                if #rows > 0 then 
                if rows[1].banned then 
                    return rows[1].banned, rows[1].user_id
                end
            end
        end
    else 
        return false; 
    end
end

function URK.BanTokens(user_id, banned) 
    if GetNumPlayerTokens then 
        MySQL.query("URK/check_token_userid", {id = user_id}, function(id)
            for i = 1, #id do 
                MySQL.execute("URK/ban_token", {token = id[i].token, banned = banned})
            end
        end)
    end
end


function URK.kick(source,reason)
    DropPlayer(source,reason)
end

-- tasks

function task_save_datatables()
    TriggerEvent("URK:save")
    Debug.pbegin("URK save datatables")
    for k,v in pairs(URK.user_tables) do
        URK.setUData(k,"URK:datatable",json.encode(v))
    end
    Debug.pend()
    SetTimeout(config.save_interval*1000, task_save_datatables)
end
task_save_datatables()

-- handlers

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
    deferrals.defer()
    local source = source
    Debug.pbegin("playerConnecting")
    local ids = GetPlayerIdentifiers(source)
    if ids ~= nil and #ids > 0 then
        deferrals.update("[URK] Checking identifiers...")
        URK.getUserIdByIdentifiers(ids, function(user_id) -- get permanent user_id
            local numtokens = GetNumPlayerTokens(source)
            if numtokens == 0 then
                deferrals.done("[URK]: You are banned from this server, please do not try to evade your ban. If you believe this was an error quote your ID which is: " .. user_id)
                tURK.sendWebhook('ban-evaders', 'URK Ban Evade Logs', "> Player Name: **"..name.."**\n> Player Current Perm ID: **"..user_id.."**\n> Player Token Amount: **"..numtokens.."**")
                return 
            end
            URK.IdentifierBanCheck(source, user_id, function(status, id, bannedIdentifier) -- check for identifier bans
                if status then
                    deferrals.done("[URK]: You are banned from this server, please do not try to evade your ban. If you believe this was an error quote your ID which is: " .. id)
                    tURK.sendWebhook('ban-evaders', 'URK Ban Evade Logs', "> Player Name: **"..name.."**\n> Player Current Perm ID: **"..user_id.."**\n> Player Banned PermID: **"..id.."**\n> Player Banned Identifier: **"..bannedIdentifier.."**")
                    return 
                end
            end)
            if user_id ~= nil then -- check user validity 
                deferrals.update("[URK] Fetching Tokens...")
                URK.StoreTokens(source, user_id) 
                deferrals.update("[URK] Checking banned...")
                URK.isBanned(user_id, function(banned) -- check urk banned
                    if not banned then -- if not banned
                        deferrals.update("[URK] Checking whitelisted...")
                        URK.isWhitelisted(user_id, function(whitelisted) -- check urk whitelist
                            if not config.whitelist or whitelisted then -- if no whitelist is needed or the user is whitelisted
                                Debug.pbegin("playerConnecting_delayed")
                                if URK.rusers[user_id] == nil then -- not present on the server, init

                                    print("[DEBUG] --- Verification Check Started ---")
                                    print("[DEBUG] Checking user_id: " .. user_id)

                                    -- Check verification status from database
                                    print("[DEBUG] Querying urk_verification for user_id: " .. user_id)
                                    local verified_data = exports["ghmattimysql"]:executeSync("SELECT verified FROM urk_verification WHERE user_id = @user_id", {user_id = user_id})
                                    local is_verified = false
                                    
                                    print("[DEBUG] Initial Query Result for verified:", json.encode(verified_data))

                                    if verified_data and #verified_data > 0 then
                                         print("[DEBUG] Initial 'verified' column value:", verified_data[1]["verified"])
                                        if verified_data[1]["verified"] == 1 then
                                            is_verified = true
                                        end
                                    else
                                         print("[DEBUG] No entry found in urk_verification for this user_id. Inserting new entry...")
                                         -- Insert new entry with verified = 0 if not found
                                         exports["ghmattimysql"]:executeSync("INSERT IGNORE INTO urk_verification(user_id, verified) VALUES(@user_id, 0)", {user_id = user_id})
                                         print("[DEBUG] New entry inserted for user_id: " .. user_id .. " with verified = 0")
                                         
                                         -- Add a small wait after insert before re-checking (optional, for sync)
                                         print("[DEBUG] Waiting 500ms before re-query...")
                                         Wait(500) -- Wait for 500ms

                                         -- Re-query to get the possibly newly inserted/updated data
                                         print("[DEBUG] Re-querying urk_verification for user_id: " .. user_id .. " (after insert/wait)")
                                         verified_data = exports["ghmattimysql"]:executeSync("SELECT verified FROM urk_verification WHERE user_id = @user_id", {user_id = user_id})
                                         print("[DEBUG] Re-query Result for verified (after insert/wait):", json.encode(verified_data))
                                          if verified_data and #verified_data > 0 then
                                             print("[DEBUG] Re-query 'verified' column value:", verified_data[1]["verified"])
                                            if verified_data[1]["verified"] == 1 then
                                                is_verified = true
                                            end
                                        end
                                    end

                                    print("[DEBUG] Final is_verified status: ", is_verified)

                                    if is_verified then
                                        print("[DEBUG] User is verified. Proceeding with loading.")
                                        -- User is verified, proceed with loading
                                        deferrals.update("[URK] Verification confirmed. Loading player...")
                                        if URK.CheckTokens(source, user_id) then 
                                            deferrals.done("[URK]: You are banned from this server, please do not try to evade your ban.")
                                        end
                                        URK.users[ids[1]] = user_id
                                        URK.rusers[user_id] = ids[1]
                                        URK.user_tables[user_id] = {}
                                        URK.user_tmp_tables[user_id] = {}
                                        URK.user_sources[user_id] = source
                                        URK.getUData(user_id, "URK:datatable", function(sdata) -- get user datatable
                                            local data = json.decode(sdata)
                                            if type(data) == "table" then URK.user_tables[user_id] = data end
                                            local tmpdata = URK.getUserTmpTable(user_id)
                                            URK.getLastLogin(user_id, function(last_login) -- get last login
                                                tmpdata.last_login = last_login or ""
                                                tmpdata.spawns = 0
                                                local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                MySQL.execute("URK/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                print("[URK] "..name.." Joined | PermID: "..user_id..")")
                                                TriggerEvent("URK:playerJoin", user_id, source, name, tmpdata.last_login)
                                                Wait(500)
                                                deferrals.done()
                                            end) -- end getLastLogin
                                        end) -- end getUData
                                    else
                                        print("[DEBUG] User is NOT verified. Initiating verification process.")
                                        -- User is not verified, initiate verification process
                                        deferrals.update("[URK] Account not verified. Initiating verification...")

                                        -- Fetch or generate verification code
                                        local code = nil
                                        local data_code = exports["ghmattimysql"]:executeSync("SELECT code FROM urk_verification WHERE user_id = @user_id", {user_id = user_id})
                                        if data_code and #data_code > 0 and data_code[1]["code"] ~= nil then
                                            code = data_code[1]["code"]
                                        else -- Generate and store a new code if none exists
                                            code = math.random(100000, 999999)
                                            -- Ensure code is unique (optional, but good practice)
                                            local checkCode;
                                            repeat
                                                checkCode = exports["ghmattimysql"]:executeSync("SELECT user_id FROM urk_verification WHERE code = @code", {code = code});
                                                if checkCode and #checkCode > 0 then
                                                     code = math.random(100000, 999999);
                                                end
                                            until not checkCode or #checkCode == 0

                                            exports["ghmattimysql"]:executeSync("UPDATE urk_verification SET code = @code WHERE user_id = @user_id", {user_id = user_id, code = code})
                                        end

                                        local function show_auth_card(code, deferrals, callback)
                                            verify_card["body"][2]["items"][3]["text"] = "3. !verify "..code
                                            deferrals.presentCard(verify_card, callback)
                                        end

                                        local function check_verified_callback()
                                            print("[DEBUG] check_verified_callback triggered.")
                                             -- Re-query the database to check the updated verified status
                                            local data_verified = exports["ghmattimysql"]:executeSync("SELECT verified FROM urk_verification WHERE user_id = @user_id", {user_id = user_id})
                                            local is_now_verified = false
                                            print("[DEBUG] Callback Re-query Result for verified:", json.encode(data_verified))
                                            if data_verified and #data_verified > 0 then
                                                print("[DEBUG] Callback 'verified' column value:", data_verified[1]["verified"])
                                                if data_verified[1]["verified"] == 1 then
                                                    is_now_verified = true
                                                end
                                            end
                                            print("[DEBUG] Callback is_now_verified status:", is_now_verified)

                                            if is_now_verified then
                                                print("[DEBUG] User is now verified after callback. Proceeding with loading.")
                                                -- User is now verified, allow connection
                                                 if URK.CheckTokens(source, user_id) then 
                                                    deferrals.done("[URK]: You are banned from this server, please do not try to evade your ban.")
                                                end
                                                URK.users[ids[1]] = user_id
                                                URK.rusers[user_id] = ids[1]
                                                URK.user_tables[user_id] = {}
                                                URK.user_tmp_tables[user_id] = {}
                                                URK.user_sources[user_id] = source
                                                URK.getUData(user_id, "URK:datatable", function(sdata) -- get user datatable
                                                    local data = json.decode(sdata)
                                                    if type(data) == "table" then URK.user_tables[user_id] = data end
                                                    local tmpdata = URK.getUserTmpTable(user_id)
                                                    URK.getLastLogin(user_id, function(last_login) -- get last login
                                                        tmpdata.last_login = last_login or ""
                                                        tmpdata.spawns = 0
                                                        local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                        MySQL.execute("URK/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                        print("[URK] "..name.." Joined | PermID: "..user_id..")")
                                                        TriggerEvent("URK:playerJoin", user_id, source, name, tmpdata.last_login)
                                                        Wait(500)
                                                        deferrals.done()
                                                    end) -- end getLastLogin
                                                end) -- end getUData
                                            else
                                                print("[DEBUG] User is still NOT verified after callback. Showing card again.")
                                                -- Still not verified, show card again
                                                show_auth_card(code, deferrals, check_verified_callback)
                                            end
                                        end -- end check_verified_callback

                                        -- Show the initial verification card
                                        show_auth_card(code, deferrals, check_verified_callback)
                                    end
                                else -- already connected
                                    if URK.CheckTokens(source, user_id) then 
                                        deferrals.done("[URK]: You are banned from this server, please do not try to evade your ban.")
                                    end
                                    print("[URK] "..name.." Reconnected | PermID: "..user_id)
                                    TriggerEvent("URK:playerRejoin", user_id, source, name)
                                    Wait(500)
                                    deferrals.done()
                                    
                                    -- reset first spawn
                                    local tmpdata = URK.getUserTmpTable(user_id)
                                    tmpdata.spawns = 0
                                end
                                Debug.pend()
                            else -- not whitelisted
                                print("[URK] "..name.." ("..GetPlayerName(source)..") rejected: not whitelisted (Perm ID = "..user_id..")")
                                deferrals.done("[URK] Not whitelisted (Perm ID = "..user_id..").")
                            end
                        end) -- end isWhitelisted
                    else -- banned
                        deferrals.update("[URK] Fetching Tokens...")
                        URK.StoreTokens(source, user_id) 
                        URK.fetchBanReasonTime(user_id,function(bantime, banreason, banadmin) -- fetch ban details
                            if tonumber(bantime) then -- temp ban
                                local timern = os.time()
                                if timern > tonumber(bantime) then -- ban expired
                                    URK.setBanned(user_id,false) -- unban
                                    if URK.rusers[user_id] == nil then -- not present on the server, init
                                        URK.users[ids[1]] = user_id
                                        URK.rusers[user_id] = ids[1]
                                        URK.user_tables[user_id] = {}
                                        URK.user_tmp_tables[user_id] = {}
                                        URK.user_sources[user_id] = source
                                        deferrals.update("[URK] Loading datatable...")
                                        URK.getUData(user_id, "URK:datatable", function(sdata) -- get user datatable
                                            local data = json.decode(sdata)
                                            if type(data) == "table" then URK.user_tables[user_id] = data end
                                            local tmpdata = URK.getUserTmpTable(user_id)
                                            deferrals.update("[URK] Getting last login...")
                                            URK.getLastLogin(user_id, function(last_login) -- get last login
                                                tmpdata.last_login = last_login or ""
                                                tmpdata.spawns = 0
                                                local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                MySQL.execute("URK/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                print("[URK] "..name.." ("..GetPlayerName(source)..") joined after his ban expired. (Perm ID = "..user_id..")")
                                                TriggerEvent("URK:playerJoin", user_id, source, name, tmpdata.last_login)
                                                deferrals.done() -- done loading
                                            end) -- end getLastLogin
                                        end) -- end getUData
                                    else -- already connected
                                        print("[URK] "..name.." ("..GetPlayerName(source)..") re-joined after his ban expired.  (Perm ID = "..user_id..")")
                                        TriggerEvent("URK:playerRejoin", user_id, source, name)
                                        deferrals.done() -- done loading
                                        local tmpdata = URK.getUserTmpTable(user_id)
                                        tmpdata.spawns = 0
                                    end
                                    return 
                                else -- temp ban still active
                                    print("[URK] "..name.." ("..GetPlayerName(source)..") rejected: banned (Perm ID = "..user_id..")")
                                    deferrals.done("\n[URK] Ban expires in "..calculateTimeRemaining(bantime).."\nYour ID: "..user_id.."\nReason: "..banreason.."\nAppeal @ discord.gg/urkfivem")
                                end
                            else -- perm ban
                                print("[URK] "..name.." ("..GetPlayerName(source)..") rejected: banned (Perm ID = "..user_id..")")
                                deferrals.done("\n[URK] Permanent Ban\nYour ID: "..user_id.."\nReason: "..banreason.."\nAppeal @ discord.gg/urkfivem")
                            end
                        end) -- end fetchBanReasonTime
                    end
                end) -- end isBanned
            else -- user_id is nil (identification error)
                print("[URK] "..name.." ("..GetPlayerName(source)..") rejected: identification error")
                deferrals.done("[URK] Identification error.")
            end
        end) -- end getUserIdByIdentifiers callback
    else -- missing identifiers
        print("[URK] "..name.." ("..GetPlayerName(source)..") rejected: missing identifiers")
        deferrals.done("[URK] Missing identifiers.")
    end
    Debug.pend()
end) -- end playerConnecting event handler

AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = URK.getUserId(source)
    local playerHex = GetPlayerIdentifier(source)
    if user_id ~= nil then
        TriggerEvent("URK:save") -- save user data
        -- save user data table
        URK.setUData(user_id,"URK:datatable",json.encode(URK.getUserDataTable(user_id))) -- save user datatable
        print("[URK] "..GetPlayerName(source).." disconnected (Perm ID = "..user_id..")")
        URK.users[URK.rusers[user_id]] = nil
        URK.rusers[user_id] = nil
        URK.user_tables[user_id] = nil
        URK.user_tmp_tables[user_id] = nil
        URK.user_sources[user_id] = nil
        print('[URK] Player Leaving Save:  Saved data for: ' .. GetPlayerName(source))
        tURK.sendWebhook('leave', GetPlayerName(source).." PermID: "..user_id.." Temp ID: "..source.."  Steam Hex: "..playerHex.." disconnected", reason) -- send discord webhook
    else 
        print('[URK] SEVERE ERROR: Failed to save data for: ' .. GetPlayerName(source) .. ' Rollback expected!')
    end
    URKclient.removeBasePlayer(-1,{source}) -- remove base player
    URKclient.removePlayer(-1,{source}) -- remove player
end) -- end playerDropped event handler


MySQL.createCommand("URK/setusername","UPDATE urk_users SET username = @username WHERE id = @user_id")

RegisterServerEvent("URKcli:playerSpawned")
AddEventHandler("URKcli:playerSpawned", function() -- on player spawned
    Debug.pbegin("playerSpawned")
    -- register user sources and then set first spawn to false
    local source = source
    local playerHex = GetPlayerIdentifier(source)
    local user_id = URK.getUserId(source)
    local player = source
    URKclient.addBasePlayer(-1, {player, user_id}) -- add base player
    if user_id ~= nil then -- check user validity
        URK.user_sources[user_id] = source
        local tmp = URK.getUserTmpTable(user_id)
        tmp.spawns = tmp.spawns+1
        local first_spawn = (tmp.spawns == 1)
        tURK.sendWebhook('join', GetPlayerName(source).." TempID: "..source.." PermID: "..user_id.." PermID: "..playerHex.." connected", "") -- send discord webhook
        if first_spawn then -- if first spawn
            for k,v in pairs(URK.user_sources) do -- add all players to this player (for syncing)
                URKclient.addPlayer(source,{v})
            end
            URKclient.addPlayer(-1,{source}) -- add player to base player
            MySQL.execute("URK/setusername", {user_id = user_id, username = GetPlayerName(source)}) -- set username
        end
        TriggerEvent("URK:playerSpawn",user_id,player,first_spawn) -- trigger player spawn event
        TriggerClientEvent("URK:onClientSpawn",player,user_id,first_spawn) -- trigger client spawn event
    end
    Debug.pend()
end) -- end playerSpawned event handler
RegisterServerEvent("URK:playerRespawned")
AddEventHandler("URK:playerRespawned", function() -- on player respawned
    local source = source
    TriggerClientEvent('URK:onClientSpawn', source) -- trigger client spawn event
end) -- end playerRespawned event handler


exports("getServerStatus", function(params, cb) -- export getServerStatus
    if staffWhitelist then
        cb("🛑 Whitelisted")
    else
        cb("✅ Online")
    end
end) -- end getServerStatus export

exports("getConnected", function(params, cb) -- export getConnected
    if URK.getUserSource(params[1]) then
        cb('connected')
    else
        cb('not connected')
    end
end) -- end getConnected export