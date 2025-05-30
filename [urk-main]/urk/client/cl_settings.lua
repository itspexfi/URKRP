RMenu.Add(
    "SettingsMenu",
    "MainMenu",
    RageUI.CreateMenu(
        "",
        "~r~Settings Menu",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "graphicpresets",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Graphics Presets",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "changediscord",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Link Discord",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "killeffects",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Kill Effects",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "bloodeffects",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Rlood Effects",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "uisettings",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~UI Related Settings",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "weaponsettings",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Weapon Related Settings",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "weaponswhitelist",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "weaponsettings"),
        "",
        "~r~Custom Weapons Owned",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "generateaccesscode",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "weaponswhitelist"),
        "",
        "~r~Generate Access Code",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "viewwhitelisted",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "generateaccesscode"),
        "",
        "~r~View Whilelisted Users",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "gangsettings",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Gang Related Settings",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
RMenu.Add(
    "SettingsMenu",
    "miscsettings",
    RageUI.CreateSubMenu(
        RMenu:Get("SettingsMenu", "MainMenu"),
        "",
        "~r~Miscellaneous Settings",
        tURK.getRageUIMenuWidth(),
        tURK.getRageUIMenuHeight(),
        "banners",
        "urk_settingsui"
    )
)
local a = module("cfg/cfg_settings")
local b = 0
local c = 0
local d = 0
local e = false
local g = false
local h = false
local i = false
local j = 1
local k = {30.0, 45.0, 60.0, 75.0, 90.0, 500.0}
local l = {"30m", "45m", "60m", "75m", "90m", "500m"}
local m = false
local n = 3
Citizen.CreateThread(
    function()
        local o = GetResourceKvpString("urk_diagonalweapons") or "false"
        if o == "false" then
            b = false
            TriggerEvent("URK:setVerticalWeapons")
        else
            b = true
            TriggerEvent("URK:setDiagonalWeapons")
        end
        local p = GetResourceKvpString("urk_frontars") or "false"
        if p == "false" then
            c = false
            TriggerEvent("URK:setBackAR")
        else
            c = true
            TriggerEvent("URK:setFrontAR")
        end
        local q = GetResourceKvpString("urk_hitmarkersounds") or "false"
        if q == "false" then
            d = false
            TriggerEvent("URK:hsSoundsOff")
        else
            d = true
            TriggerEvent("URK:hsSoundsOn")
        end
        local r = GetResourceKvpString("urk_reducedchatopacity") or "false"
        if r == "false" then
            f = false
            TriggerEvent("URK:chatReduceOpacity", false)
        else
            f = true
            TriggerEvent("URK:chatReduceOpacity", true)
        end
        local s = GetResourceKvpString("urk_hideeventannouncement") or "false"
        if s == "false" then
            g = false
        else
            g = true
        end
        local t = GetResourceKvpString("urk_healthpercentage") or "false"
        if t == "false" then
            h = false
        else
            h = true
        end
        local u = GetResourceKvpString("urk_flashlightnotaiming") or "false"
        if u == "false" then
            i = false
        else
            i = true
            SetFlashLightKeepOnWhileMoving(true)
        end
        local v = GetResourceKvpInt("urk_gang_name_distance")
        if v > 0 then
            j = v
            if k[j] then
                TriggerEvent("URK:setGangNameDistance", k[j])
            end
        end
        local w = GetResourceKvpString("urk_gang_ping_sound") or "false"
        if w == "false" then
            m = false
        else
            m = true
        end
        local x = GetResourceKvpInt("urk_gang_ping_marker")
        if x > 0 then
            n = x
        end
    end
)
function tURK.setDiagonalWeaponSetting(i)
    SetResourceKvp("urk_diagonalweapons", tostring(i))
end
function tURK.setFrontARSetting(i)
    SetResourceKvp("urk_frontars", tostring(i))
end
function tURK.setHitMarkerSetting(i)
    SetResourceKvp("urk_hitmarkersounds", tostring(i))
end
function tURK.setCODHitMarkerSetting(i)
    SetResourceKvp("urk_codhitmarkersounds", tostring(i))
end
function tURK.setKillListSetting(w)
    SetResourceKvp("urk_killlistsetting", tostring(w))
end
function tURK.setOldKillfeed(w)
    SetResourceKvp("urk_oldkillfeed", tostring(w))
end
function tURK.setDamageIndicator(w)
    SetResourceKvp("urk_damageindicator", tostring(w))
end
function tURK.setDamageIndicatorColour(w)
    SetResourceKvp("urk_damageindicatorcolour", tostring(w))
end
function tURK.setReducedChatOpacity(q)
    SetResourceKvp("urk_reducedchatopacity", tostring(q))
end
function tURK.setHideEventAnnouncementFlag(q)
    SetResourceKvp("urk_hideeventannouncement", tostring(q))
end
function tURK.getHideEventAnnouncementFlag()
    return g
end
function tURK.setShowHealthPercentageFlag(q)
    SetResourceKvp("urk_healthpercentage", tostring(q))
end
function tURK.setFlashlightNotAimingFlag(x)
    SetFlashLightKeepOnWhileMoving(x)
    i = x
    SetResourceKvp("urk_flashlightnotaiming", tostring(x))
end
function tURK.getShowHealthPercentageFlag()
    return h
end
function tURK.setGangPingSoundEnabled(q)
    SetResourceKvp("urk_gang_ping_sound", tostring(q))
end
function tURK.getGangPingSoundEnabled()
    return m
end
function tURK.getGangPingMarkerIndex()
    return n
end
local function y(j)
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get("SettingsMenu", "settings"), j)
end
local z = {
    {"50%", 0.5},
    {"60%", 0.6},
    {"70%", 0.7},
    {"80%", 0.8},
    {"90%", 0.9},
    {"100%", 1.0},
    {"150%", 1.5},
    {"200%", 2.0},
    {"1000%", 10.0}
}
local A = {"50%", "60%", "70%", "80%", "90%", "100%", "150%", "200%", "1000%"}
local o = 6
local p = {}
local q
local r
local s
local t
RegisterNetEvent(
    "URK:gotCustomWeaponsOwned",
    function(u)
        print("gotCustomWeaponsOwned", dump(u))
        p = u
    end
)
RegisterNetEvent(
    "URK:generatedAccessCode",
    function(B)
        print("got accessCode", B)
        s = B
    end
)
RegisterNetEvent(
    "URK:getWhitelistedUsers",
    function(v)
        t = v
    end
)
local w = {}
local function x(C, D)
    return w[C.name .. D.name]
end
local function E(C)
    local F = false
    for G, D in pairs(C.presets) do
        if w[C.name .. D.name] then
            F = true
            w[C.name .. D.name] = nil
        end
    end
    if F then
        for H, I in pairs(C.default) do
            SetVisualSettingFloat(H, I)
        end
    end
end
local function J(D)
    for H, I in pairs(D.values) do
        SetVisualSettingFloat(H, I)
    end
end
local function K(C, D, L)
    E(C)
    if L then
        w[C.name .. D.name] = true
        J(D)
    end
    local M = json.encode(w)
    SetResourceKvp("urk_graphic_presets", M)
end
local N = {
    "0%",
    "5%",
    "10%",
    "15%",
    "20%",
    "25%",
    "30%",
    "35%",
    "40%",
    "45%",
    "50%",
    "55%",
    "60%",
    "65%",
    "70%",
    "75%",
    "80%",
    "85%",
    "90%",
    "95%",
    "100%"
}
local O = {
    0.0,
    0.05,
    0.1,
    0.15,
    0.2,
    0.25,
    0.3,
    0.35,
    0.4,
    0.45,
    0.5,
    0.55,
    0.6,
    0.65,
    0.7,
    0.75,
    0.8,
    0.85,
    0.9,
    0.95,
    1.0
}
local P = {
    "25%",
    "50%",
    "75%",
    "100%",
    "125%",
    "150%",
    "175%",
    "200%",
    "250%",
    "300%",
    "350%",
    "400%",
    "450%",
    "500%",
    "750%",
    "1000%"
}
local Q = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 7.5, 10.0}
local R = {
    "0.1s",
    "0.2s",
    "0.3s",
    "0.4s",
    "0.5s",
    "0.6s",
    "0.7s",
    "0.8s",
    "0.9s",
    "1s",
    "1.25s",
    "1.5s",
    "1.75s",
    "2.0s"
}
local S = {100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1250, 1500, 1750, 2000}
local T = {
    "Disabled",
    "Fireworks",
    "Celebration",
    "Firework Burst",
    "Water Explosion",
    "Ramp Explosion",
    "Gas Explosion",
    "Electrical Spark",
    "Electrical Explosion",
    "Concrete Impact",
    "EMP 1",
    "EMP 2",
    "EMP 3",
    "Spike Mine",
    "Kinetic Mine",
    "Tar Mine",
    "Short Burst",
    "Fog Sphere",
    "Glass Smash",
    "Glass Drop",
    "Falling Leaves",
    "Wood Smash",
    "Train Smoke",
    "Money",
    "Confetti",
    "Marbles",
    "Sparkles"
}
local U = {
    {"DISABLED", "DISABLED", 1.0},
    {"scr_indep_fireworks", "scr_indep_firework_shotburst", 0.2},
    {"scr_xs_celebration", "scr_xs_confetti_burst", 1.2},
    {"scr_rcpaparazzo1", "scr_mich4_firework_burst_spawn", 1.0},
    {"particle cut_finale1", "cs_finale1_car_explosion_surge_spawn", 1.0},
    {"des_fib_floor", "ent_ray_fbi5a_ramp_explosion", 1.0},
    {"des_gas_station", "ent_ray_paleto_gas_explosion", 0.5},
    {"core", "ent_dst_electrical", 1.0},
    {"core", "ent_sht_electrical_box", 1.0},
    {"des_vaultdoor", "ent_ray_pro1_concrete_impacts", 1.0},
    {"scr_xs_dr", "scr_xs_dr_emp", 1.0},
    {"scr_xs_props", "scr_xs_exp_mine_sf", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_emp", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_spike", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_kinetic", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_tar", 1.0},
    {"scr_stunts", "scr_stunts_shotburst", 1.0},
    {"scr_tplaces", "scr_tplaces_team_swap", 1.0},
    {"des_fib_glass", "ent_ray_fbi2_window_break", 1.0},
    {"des_fib_glass", "ent_ray_fbi2_glass_drop", 2.5},
    {"des_stilthouse", "ent_ray_fam3_falling_leaves", 1.0},
    {"des_stilthouse", "ent_ray_fam3_wood_frags", 1.0},
    {"des_train_crash", "ent_ray_train_smoke", 1.0},
    {"core", "ent_brk_banknotes", 2.0},
    {"core", "ent_dst_inflate_ball_clr", 1.0},
    {"core", "ent_dst_gen_gobstop", 1.0},
    {"core", "ent_sht_telegraph_pole", 1.0}
}
local V = {
    "Disabled",
    "BikerFilter",
    "CAMERA_BW",
    "drug_drive_blend01",
    "glasses_blue",
    "glasses_brown",
    "glasses_Darkblue",
    "glasses_green",
    "glasses_purple",
    "glasses_red",
    "helicamfirst",
    "hud_def_Trevor",
    "Kifflom",
    "LectroDark",
    "MP_corona_tournament_DOF",
    "MP_heli_cam",
    "mugShot",
    "NG_filmic02",
    "REDMIST_blend",
    "trevorspliff",
    "ufo",
    "underwater",
    "WATER_LAB",
    "WATER_militaryPOOP",
    "WATER_river",
    "WATER_salton"
}
local W = {
    lightning = false,
    pedFlash = false,
    pedFlashRGB = {11, 11, 11},
    pedFlashIntensity = 4,
    pedFlashTime = 1,
    screenFlash = false,
    screenFlashRGB = {11, 11, 11},
    screenFlashIntensity = 4,
    screenFlashTime = 1,
    particle = 1,
    timecycle = 1,
    timecycleTime = 1
}
local X = 0
local function Y()
    local Z = json.encode(W)
    SetResourceKvp("urk_kill_effects", Z)
end
local _ = {head = 1, body = 1, arms = 1, legs = 1}
local function a0()
    local a1 = json.encode(_)
    SetResourceKvp("urk_blood_effects", a1)
end
Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        local M = GetResourceKvpString("urk_graphic_presets")
        if M and M ~= "" then
            w = json.decode(M) or {}
        end
        for G, C in pairs(a.presets) do
            for G, D in pairs(C.presets) do
                if x(C, D) then
                    J(D)
                end
            end
        end
        local Z = GetResourceKvpString("urk_kill_effects")
        if Z and Z ~= "" then
            local a2 = json.decode(Z)
            for a3, L in pairs(a2) do
                if W[a3] then
                    W[a3] = L
                end
            end
        end
        local a1 = GetResourceKvpString("urk_blood_effects")
        if a1 and a1 ~= "" then
            local a2 = json.decode(a1)
            for a3, L in pairs(a2) do
                if _[a3] then
                    _[a3] = L
                end
            end
        end
    end
)
RageUI.CreateWhile(
    1.0,
    true,
    function()
        if RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.List(
                        "Render Distance Modifier",
                        A,
                        o,
                        "~r~Lowering this will increase your FPS!",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            o = a7
                        end,
                        function()
                        end,
                        nil
                    )
                    RageUI.ButtonWithStyle(
                        "UI Settings",
                        "UI related settings.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                        end,
                        RMenu:Get("SettingsMenu", "uisettings")
                    )
                    RageUI.ButtonWithStyle(
                        "Weapon Settings",
                        "Weapon related settings.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                        end,
                        RMenu:Get("SettingsMenu", "weaponsettings")
                    )
                    if PlayerIsInGang then
                        RageUI.ButtonWithStyle(
                            "Gang Settings",
                            "Gang related settings.",
                            {RightLabel = "→→→"},
                            true,
                            function(a4, a5, a6)
                            end,
                            RMenu:Get("SettingsMenu", "gangsettings")
                        )
                    end
                    RageUI.ButtonWithStyle(
                        "Misc Settings",
                        "Miscellaneous settings.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                        end,
                        RMenu:Get("SettingsMenu", "miscsettings")
                    )
                    RageUI.ButtonWithStyle(
                        "Graphic Presets",
                        "View a list of preconfigured graphic settings.",
                        {RightLabel = "→→→"},
                        true,
                        function()
                        end,
                        RMenu:Get("SettingsMenu", "graphicpresets")
                    )
                    RageUI.ButtonWithStyle(
                        "Kill Effects",
                        "Toggle effects that occur on killing a player.",
                        {RightLabel = "→→→"},
                        true,
                        function()
                        end,
                        RMenu:Get("SettingsMenu", "killeffects")
                    )
                    RageUI.ButtonWithStyle(
                        "Blood Effects",
                        "Toggle effects that occur when damaging a player.",
                        {RightLabel = "→→→"},
                        true,
                        function()
                        end,
                        RMenu:Get("SettingsMenu", "bloodeffects")
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "uisettings")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Checkbox(
                        "Streetnames",
                        "",
                        tURK.isStreetnamesEnabled(),
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        function()
                            tURK.setStreetnamesEnabled(true)
                        end,
                        function()
                            tURK.setStreetnamesEnabled(false)
                        end
                    )
                    RageUI.Checkbox(
                        "Compass",
                        "",
                        tURK.isCompassEnabled(),
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        function()
                            tURK.setCompassEnabled(true)
                        end,
                        function()
                            tURK.setCompassEnabled(false)
                        end
                    )
                    local function a9()
                        tURK.hideUI()
                        hideUI = true
                    end
                    local function aa()
                        tURK.showUI()
                        hideUI = false
                    end
                    RageUI.Checkbox(
                        "Hide UI",
                        "",
                        hideUI,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        a9,
                        aa
                    )
                    local function a9()
                        tURK.toggleBlackBars()
                        e = true
                    end
                    local function aa()
                        tURK.toggleBlackBars()
                        e = false
                    end
                    RageUI.Checkbox(
                        "Cinematic Black Bars",
                        "",
                        e,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        a9,
                        aa
                    )
                    RageUI.Checkbox(
                        "Reduce Chat Opacity",
                        "",
                        f,
                        {},
                        function()
                        end,
                        function()
                            f = true
                            tURK.setReducedChatOpacity(true)
                            TriggerEvent("URK:chatReduceOpacity", true)
                        end,
                        function()
                            f = false
                            tURK.setReducedChatOpacity(false)
                            TriggerEvent("URK:chatReduceOpacity", false)
                        end
                    )
                    RageUI.Checkbox(
                        "Show Health Percentage",
                        "Displays the health and armour percentage on the bars.",
                        h,
                        {},
                        function()
                        end,
                        function()
                            h = true
                            tURK.setShowHealthPercentageFlag(true)
                        end,
                        function()
                            h = false
                            tURK.setShowHealthPercentageFlag(false)
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Crosshair",
                        "Create a custom built-in crosshair here.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                        end,
                        RMenu:Get("crosshair", "main")
                    )
                    RageUI.ButtonWithStyle(
                        "Scope Settings",
                        "Add a toggleable range finder when using sniper scopes.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                        end,
                        RMenu:Get("scope", "main")
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "weaponsettings")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    local function a9()
                        TriggerEvent("URK:setDiagonalWeapons")
                        b = true
                        tURK.setDiagonalWeaponSetting(b)
                    end
                    local function aa()
                        TriggerEvent("URK:setVerticalWeapons")
                        b = false
                        tURK.setDiagonalWeaponSetting(b)
                    end
                    RageUI.Checkbox(
                        "Enable Diagonal Weapons",
                        "~r~This changes the way weapons look on your back from vertical to diagonal.",
                        b,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        a9,
                        aa
                    )
                    RageUI.Checkbox(
                        "Enable Front Assault Rifles",
                        "~r~This changes the positioning of Assault Rifles from back to front.",
                        c,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function()
                        end,
                        function()
                            TriggerEvent("URK:setFrontAR")
                            c = true
                            tURK.setFrontARSetting(c)
                        end,
                        function()
                            TriggerEvent("URK:setBackAR")
                            c = false
                            tURK.setFrontARSetting(c)
                        end
                    )
                    local function a9()
                        TriggerEvent("URK:hsSoundsOn")
                        d = true
                        tURK.setHitMarkerSetting(d)
                        tURK.notify("~y~Experimental Headshot sounds now set to " .. tostring(d))
                    end
                    local function aa()
                        TriggerEvent("URK:hsSoundsOff")
                        d = false
                        tURK.setHitMarkerSetting(d)
                        tURK.notify("~y~Experimental Headshot sounds now set to " .. tostring(d))
                    end
                    RageUI.Checkbox(
                        "Enable Experimental Hit Marker Sounds",
                        "~r~This adds 'hit marker' sounds when shooting another player, however it can be unreliable.",
                        d,
                        {RightBadge = RageUI.CheckboxStyle.Car},
                        function(a4, a6, a5, a8)
                        end,
                        a9,
                        aa
                    )
                    RageUI.ButtonWithStyle(
                        "Weapon Whitelists",
                        "Sell your custom weapon whitelists here.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                            if a6 then
                                s = nil
                                q = nil
                                r = nil
                                t = nil
                                TriggerServerEvent("URK:getCustomWeaponsOwned")
                            end
                        end,
                        RMenu:Get("SettingsMenu", "weaponswhitelist")
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "gangsettings")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.List(
                        "Gang Ping Marker ",
                        {"Only Text", "Marker", "Icon"},
                        n,
                        "Max distance to display gang member names.",
                        {},
                        true,
                        function(ab, ac, ad, ae)
                            if ae ~= n then
                                n = ae
                                SetResourceKvpInt("urk_gang_ping_marker", ae)
                            end
                        end
                    )
                    RageUI.Checkbox(
                        "Gang Ping Sound",
                        "Play a sound when a gang member pings.",
                        m,
                        {},
                        function()
                        end,
                        function()
                            m = true
                            tURK.setGangPingSoundEnabled(true)
                        end,
                        function()
                            m = false
                            tURK.setGangPingSoundEnabled(false)
                        end
                    )
                    RageUI.List(
                        "Gang Name Distance",
                        l,
                        j,
                        "Max distance to display gang member names.",
                        {},
                        true,
                        function(ab, ac, ad, ae)
                            if ae ~= j then
                                j = ae
                                SetResourceKvpInt("urk_gang_name_distance", ae)
                                TriggerEvent("URK:setGangNameDistance", k[ae])
                            end
                        end
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "miscsettings")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Checkbox(
                        "Keep Flashlight On Whilst Moving",
                        "Makes weapon flashlight beams stay visible while moving.",
                        i,
                        {},
                        function()
                        end,
                        function()
                            tURK.setFlashlightNotAimingFlag(true)
                        end,
                        function()
                            tURK.setFlashlightNotAimingFlag(false)
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Change Linked Discord",
                        "Begins the process of changing your linked Discord. Your linked discord is used to sync roles with the server.",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                            if a6 then
                                TriggerServerEvent("URK:changeLinkedDiscord")
                            end
                        end
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "changediscord")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Separator("~r~A code has been messaged to the Discord account")
                    RageUI.Separator("-----")
                    RageUI.Separator("~y~If you have not received a message verify:")
                    RageUI.Separator("~y~1. Your direct messages are open.")
                    RageUI.Separator("~y~2. The account you provided was correct.")
                    RageUI.Separator("-----")
                    RageUI.ButtonWithStyle(
                        "Enter Code",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                            if a6 then
                                TriggerServerEvent("URK:enterDiscordCode")
                            end
                        end
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "weaponswhitelist")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    for af, ag in pairs(p) do
                        RageUI.ButtonWithStyle(
                            ag,
                            "",
                            {RightLabel = "→→→"},
                            true,
                            function(a4, a5, a6)
                                if a6 then
                                    q = ag
                                    r = af
                                    t = nil
                                end
                            end,
                            RMenu:Get("SettingsMenu", "generateaccesscode")
                        )
                    end
                    RageUI.Separator("~y~If you do not see your custom weapon here.")
                    RageUI.Separator("~y~Please open a ticket on our support discord.")
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "generateaccesscode")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Separator("~r~Weapon Whitelist for " .. q)
                    RageUI.Separator("How it works:")
                    RageUI.Separator("You generate an access code for the player who wishes")
                    RageUI.Separator("to purchase your custom weapon whitelist, which they ")
                    RageUI.Separator("then enter on the store to receive their automated")
                    RageUI.Separator("weapon whitelist.")
                    RageUI.ButtonWithStyle(
                        "Create access code",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                            if a6 then
                                local ah = getGenericTextInput("User ID of player purchasing your weapon whitelist.")
                                if tonumber(ah) then
                                    ah = tonumber(ah)
                                    if ah > 0 then
                                        print("selling", r, "to", ah)
                                        TriggerServerEvent("URK:generateWeaponAccessCode", r, ah)
                                    end
                                end
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "View whitelisted users",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(a4, a5, a6)
                            if a6 then
                                TriggerServerEvent("URK:requestWhitelistedUsers", r)
                            end
                        end,
                        RMenu:Get("SettingsMenu", "viewwhitelisted")
                    )
                    if s then
                        RageUI.Separator("~r~Access code generated: " .. s)
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "viewwhitelisted")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Separator("~r~Whitelisted users for " .. q)
                    if t == nil then
                        RageUI.Separator("~r~Requesting whitelisted users...")
                    else
                        for ai, aj in pairs(t) do
                            RageUI.ButtonWithStyle(
                                "ID: " .. tostring(ai),
                                "",
                                {RightLabel = aj},
                                true,
                                function()
                                end
                            )
                        end
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "graphicpresets")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    for G, C in pairs(a.presets) do
                        RageUI.Separator(C.name)
                        for G, D in pairs(C.presets) do
                            local ak = x(C, D)
                            RageUI.Checkbox(
                                D.name,
                                nil,
                                ak,
                                {},
                                function(a4, a6, a5, a8)
                                    if a8 ~= ak then
                                        K(C, D, a8)
                                    end
                                end,
                                function()
                                end,
                                function()
                                end
                            )
                        end
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "killeffects")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Checkbox(
                        "Create Lightning",
                        "",
                        W.lightning,
                        {},
                        function(a4, a6, a5, a8)
                            if a6 then
                                W.lightning = a8
                                Y()
                            end
                        end
                    )
                    RageUI.Checkbox(
                        "Ped Flash",
                        "",
                        W.pedFlash,
                        {},
                        function(a4, a6, a5, a8)
                            if a6 then
                                W.pedFlash = a8
                                Y()
                            end
                        end
                    )
                    if W.pedFlash then
                        RageUI.List(
                            "Ped Flash Red",
                            N,
                            W.pedFlashRGB[1],
                            "",
                            {},
                            W.pedFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.pedFlashRGB[1] ~= a7 then
                                    W.pedFlashRGB[1] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Ped Flash Green",
                            N,
                            W.pedFlashRGB[2],
                            "",
                            {},
                            W.pedFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.pedFlashRGB[2] ~= a7 then
                                    W.pedFlashRGB[2] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Ped Flash Blue",
                            N,
                            W.pedFlashRGB[3],
                            "",
                            {},
                            W.pedFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.pedFlashRGB[3] ~= a7 then
                                    W.pedFlashRGB[3] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Ped Flash Intensity",
                            P,
                            W.pedFlashIntensity,
                            "",
                            {},
                            W.pedFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.pedFlashIntensity ~= a7 then
                                    W.pedFlashIntensity = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Ped Flash Time",
                            R,
                            W.pedFlashTime,
                            "",
                            {},
                            W.pedFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.pedFlashTime ~= a7 then
                                    W.pedFlashTime = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                    end
                    RageUI.Checkbox(
                        "Screen Flash",
                        "",
                        W.screenFlash,
                        {},
                        function(a4, a6, a5, a8)
                            if a6 then
                                W.screenFlash = a8
                                Y()
                            end
                        end
                    )
                    if W.screenFlash then
                        RageUI.List(
                            "Screen Flash Red",
                            N,
                            W.screenFlashRGB[1],
                            "",
                            {},
                            W.screenFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.screenFlashRGB[1] ~= a7 then
                                    W.screenFlashRGB[1] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Screen Flash Green",
                            N,
                            W.screenFlashRGB[2],
                            "",
                            {},
                            W.screenFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.screenFlashRGB[2] ~= a7 then
                                    W.screenFlashRGB[2] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Screen Flash Blue",
                            N,
                            W.screenFlashRGB[3],
                            "",
                            {},
                            W.screenFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.screenFlashRGB[3] ~= a7 then
                                    W.screenFlashRGB[3] = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Screen Flash Intensity",
                            P,
                            W.screenFlashIntensity,
                            "",
                            {},
                            W.screenFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.screenFlashIntensity ~= a7 then
                                    W.screenFlashIntensity = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                        RageUI.List(
                            "Screen Flash Time",
                            R,
                            W.screenFlashTime,
                            "",
                            {},
                            W.screenFlash,
                            function(a4, a5, a6, a7)
                                if a5 and W.screenFlashTime ~= a7 then
                                    W.screenFlashTime = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                    end
                    RageUI.List(
                        "Timecycle Flash",
                        V,
                        W.timecycle,
                        "",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if a5 and W.timecycle ~= a7 then
                                W.timecycle = a7
                                Y()
                            end
                        end,
                        function()
                        end
                    )
                    if W.timecycle ~= 1 then
                        RageUI.List(
                            "Timecycle Flash Time",
                            R,
                            W.timecycleTime,
                            "",
                            {},
                            true,
                            function(a4, a5, a6, a7)
                                if a5 and W.timecycleTime ~= a7 then
                                    W.timecycleTime = a7
                                    Y()
                                end
                            end,
                            function()
                            end
                        )
                    end
                    RageUI.List(
                        "~y~Particles~w~",
                        T,
                        W.particle,
                        "",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if a5 and W.particle ~= a7 then
                                if not tURK.isPlusClub() and not tURK.isPlatClub() then
                                    notify(
                                        "~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."
                                    )
                                    notify("~y~Available @ store.urkstudios.uk")
                                end
                                W.particle = a7
                                Y()
                            end
                        end,
                        function()
                        end
                    )
                    local al = 0
                    if W.lightning then
                        al = math.max(al, 1000)
                    end
                    if W.pedFlash then
                        al = math.max(al, S[W.pedFlashTime])
                    end
                    if W.screenFlash then
                        al = math.max(al, S[W.screenFlashTime])
                    end
                    if W.timecycleTime ~= 1 then
                        al = math.max(al, O[W.timecycleTime])
                    end
                    if W.particle ~= 1 then
                        al = math.max(al, 1000)
                    end
                    if GetGameTimer() - X > al + 1000 then
                        tURK.addKillEffect(PlayerPedId(), true)
                        X = GetGameTimer()
                    end
                    DrawAdvancedTextNoOutline(0.59, 0.9, 0.005, 0.0028, 1.5, "PREVIEW", 255, 0, 0, 255, 2, 0)
                end
            )
        end
        if RageUI.Visible(RMenu:Get("SettingsMenu", "bloodeffects")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.List(
                        "~y~Head",
                        T,
                        _.head,
                        "Effect that displays when you hit the head.",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if _.head ~= a7 then
                                if not tURK.isPlusClub() and not tURK.isPlatClub() then
                                    notify(
                                        "~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."
                                    )
                                    notify("~y~Available @ store.urkstudios.uk")
                                end
                                _.head = a7
                                a0()
                            end
                            if a6 then
                                tURK.addBloodEffect("head", 0x796E, PlayerPedId())
                            end
                        end
                    )
                    RageUI.List(
                        "~y~Rody",
                        T,
                        _.body,
                        "Effect that displays when you hit the body.",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if _.body ~= a7 then
                                if not tURK.isPlusClub() and not tURK.isPlatClub() then
                                    notify(
                                        "~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."
                                    )
                                    notify("~y~Available @ store.urkstudios.uk")
                                end
                                _.body = a7
                                a0()
                            end
                            if a6 then
                                tURK.addBloodEffect("body", 0x0, PlayerPedId())
                            end
                        end
                    )
                    RageUI.List(
                        "~y~Arms",
                        T,
                        _.arms,
                        "Effect that displays when you hit the arms.",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if _.arms ~= a7 then
                                if not tURK.isPlusClub() and not tURK.isPlatClub() then
                                    notify(
                                        "~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."
                                    )
                                    notify("~y~Available @ store.urkstudios.uk")
                                end
                                _.arms = a7
                                a0()
                            end
                            if a6 then
                                tURK.addBloodEffect("arms", 0xBB0, PlayerPedId())
                                tURK.addBloodEffect("arms", 0x58B7, PlayerPedId())
                            end
                        end
                    )
                    RageUI.List(
                        "~y~Legs",
                        T,
                        _.legs,
                        "Effect that displays when you hit the legs.",
                        {},
                        true,
                        function(a4, a5, a6, a7)
                            if _.legs ~= a7 then
                                if not tURK.isPlusClub() and not tURK.isPlatClub() then
                                    notify(
                                        "~y~You need to be a subscriber of URK Plus or URK Platinum to use this feature."
                                    )
                                    notify("~y~Available @ store.urkstudios.uk")
                                end
                                _.legs = a7
                                a0()
                            end
                            if a6 then
                                tURK.addBloodEffect("legs", 0x3FCF, PlayerPedId())
                                tURK.addBloodEffect("legs", 0xB3FE, PlayerPedId())
                            end
                        end
                    )
                end
            )
        end
    end
)
RegisterNetEvent("URK:OpenSettingsMenu")
AddEventHandler(
    "URK:OpenSettingsMenu",
    function(am)
        if not am then
            RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu"), true)
        end
    end
)
RegisterCommand(
    "opensettingsmenu",
    function()
        TriggerServerEvent("URK:OpenSettings")
    end
)
RegisterKeyMapping("opensettingsmenu", "Opens the Settings menu", "keyboard", "F2")
Citizen.CreateThread(
    function()
        while true do
            OverrideLodscaleThisFrame(z[o][2])
            if IsUsingKeyboard(2) and IsControlJustPressed(1, 289) then
                if tURK.getStaffLevel() > 0 then
                    -- Staff members should use the admin menu instead
                    return
                end
                RageUI.Visible(
                    RMenu:Get("SettingsMenu", "MainMenu"),
                    not RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu"))
                )
            end
            Wait(0)
        end
    end
)
AddEventHandler(
    "URK:enteredCity",
    function()
    end
)
AddEventHandler(
    "URK:leftCity",
    function()
    end
)
local function ac(ad)
    local ae = GetEntityCoords(ad, true)
    local an = GetGameTimer()
    local ao = math.floor(O[W.pedFlashRGB[1]] * 255)
    local ap = math.floor(O[W.pedFlashRGB[2]] * 255)
    local aq = math.floor(O[W.pedFlashRGB[3]] * 255)
    local ar = Q[W.pedFlashIntensity]
    local as = S[W.pedFlashTime]
    while GetGameTimer() - an < as do
        local at = (as - (GetGameTimer() - an)) / as
        local au = ar * 25.0 * at
        DrawLightWithRange(ae.x, ae.y, ae.z + 1.0, ao, ap, aq, 50.0, au)
        Citizen.Wait(0)
    end
end
local function av()
    local an = GetGameTimer()
    local ao = math.floor(O[W.screenFlashRGB[1]] * 255)
    local ap = math.floor(O[W.screenFlashRGB[2]] * 255)
    local aq = math.floor(O[W.screenFlashRGB[3]] * 255)
    local ar = Q[W.screenFlashIntensity]
    local as = S[W.screenFlashTime]
    while GetGameTimer() - an < as do
        local at = (as - (GetGameTimer() - an)) / as
        local au = math.floor(25.5 * ar * at)
        DrawRect(0.0, 0.0, 2.0, 2.0, ao, ap, aq, au)
        Citizen.Wait(0)
    end
end
local function aw(ad)
    local ae = GetEntityCoords(ad, true)
    local ax = U[W.particle]
    tURK.loadPtfx(ax[1])
    UseParticleFxAsset(ax[1])
    StartParticleFxNonLoopedAtCoord(ax[2], ae.x, ae.y, ae.z, 0.0, 0.0, 0.0, ax[3], false, false, false)
    RemoveNamedPtfxAsset(ax[1])
end
local function ay()
    local an = GetGameTimer()
    local as = S[W.timecycleTime]
    SetTimecycleModifier(V[W.timecycle])
    while GetGameTimer() - an < as do
        local at = (as - (GetGameTimer() - an)) / as
        SetTimecycleModifierStrength(1.0 * at)
        Citizen.Wait(0)
    end
    ClearTimecycleModifier()
end
function tURK.addKillEffect(az, aA)
    if W.lightning then
        ForceLightningFlash()
    end
    if W.pedFlash then
        Citizen.CreateThreadNow(
            function()
                ac(az)
            end
        )
    end
    if W.screenFlash then
        Citizen.CreateThreadNow(
            function()
                av()
            end
        )
    end
    if W.particle ~= 1 and (tURK.isPlatClub() or aA) then
        Citizen.CreateThreadNow(
            function()
                aw(az)
            end
        )
    end
    if W.timecycle ~= 1 then
        Citizen.CreateThreadNow(
            function()
                ay()
            end
        )
    end
end
function tURK.addBloodEffect(aB, aC, ad)
    local aD = _[aB]
    if aD > 1 then
        local ax = U[aD]
        tURK.loadPtfx(ax[1])
        UseParticleFxAsset(ax[1])
        StartParticleFxNonLoopedOnPedBone(ax[2], ad, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, aC, ax[3], false, false, false)
        RemoveNamedPtfxAsset(ax[1])
    end
end
AddEventHandler(
    "URK:onPlayerKilledPed",
    function(aE)
        tURK.addKillEffect(aE, false)
    end
)
local aF = {
    [0x0] = "body",
    [0x2E28] = "body",
    [0xE39F] = "legs",
    [0xF9BB] = "legs",
    [0x3779] = "legs",
    [0x83C] = "legs",
    [0xCA72] = "legs",
    [0x9000] = "legs",
    [0xCC4D] = "legs",
    [0x512D] = "legs",
    [0xE0FD] = "body",
    [0x5C01] = "body",
    [0x60F0] = "body",
    [0x60F1] = "body",
    [0x60F2] = "body",
    [0xFCD9] = "body",
    [0xB1C5] = "arms",
    [0xEEEB] = "arms",
    [0x49D9] = "arms",
    [0x67F2] = "arms",
    [0xFF9] = "arms",
    [0xFFA] = "arms",
    [0x67F3] = "arms",
    [0x1049] = "arms",
    [0x104A] = "arms",
    [0x67F4] = "arms",
    [0x1059] = "arms",
    [0x105A] = "arms",
    [0x67F5] = "arms",
    [0x1029] = "arms",
    [0x102A] = "arms",
    [0x67F6] = "arms",
    [0x1039] = "arms",
    [0x103A] = "arms",
    [0x29D2] = "arms",
    [0x9D4D] = "arms",
    [0x6E5C] = "arms",
    [0xDEAD] = "arms",
    [0xE5F2] = "arms",
    [0xFA10] = "arms",
    [0xFA11] = "arms",
    [0xE5F3] = "arms",
    [0xFA60] = "arms",
    [0xFA61] = "arms",
    [0xE5F4] = "arms",
    [0xFA70] = "arms",
    [0xFA71] = "arms",
    [0xE5F5] = "arms",
    [0xFA40] = "arms",
    [0xFA41] = "arms",
    [0xE5F6] = "arms",
    [0xFA50] = "arms",
    [0xFA51] = "arms",
    [0x9995] = "head",
    [0x796E] = "head",
    [0x5FD4] = "head",
    [0xD003] = "body",
    [0x45FC] = "body",
    [0x1D6B] = "legs",
    [0xB23F] = "legs"
}
AddEventHandler(
    "URK:onPlayerDamagePed",
    function(aE)
        if not tURK.isPlusClub() and not tURK.isPlatClub() then
            return
        end
        local aG, aC = GetPedLastDamageBone(aE, 0)
        if aG then
            local aH = GetPedBoneIndex(aE, aC)
            local aI = GetWorldPositionOfEntityBone(aE, aH)
            local aJ = aF[aC]
            if not aJ then
                local aK = GetWorldPositionOfEntityBone(aE, GetPedBoneIndex(aE, 0x9995))
                local aL = GetWorldPositionOfEntityBone(aE, GetPedBoneIndex(aE, 0x2E28))
                if aI.z >= aK.z - 0.01 then
                    aJ = "head"
                elseif aI.z < aL.z then
                    aJ = "legs"
                else
                    local aM = GetEntityCoords(aE, true)
                    local aN = #(aM.xy - aI.xy)
                    if aN > 0.075 then
                        aJ = "arms"
                    else
                        aJ = "body"
                    end
                end
            end
            tURK.addBloodEffect(aJ, aC, aE)
        end
    end
)
RegisterNetEvent("URK:gotDiscord")
AddEventHandler(
    "URK:gotDiscord",
    function()
        RageUI.Visible(RMenu:Get("SettingsMenu", "changediscord"), true)
    end
)
