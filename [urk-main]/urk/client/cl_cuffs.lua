local a = false
local b = false
local c = 0
local d = false
local e = 0
local f = false
local g = 0
local h = 0
local i = false
local DisableControlAction = DisableControlAction
function tURK.isHandcuffed()
    return a
end
exports("isHandcuffed", tURK.isHandcuffed)
TriggerEvent("chat:addSuggestion", "/cuff", "Cuff the nearest player")
TriggerEvent("chat:addSuggestion", "/frontcuff", "Frontcuff the nearest player")
RegisterKeyMapping("cuff", "Handcuff", "keyboard", "F11")
RegisterNetEvent(
    "URK:arrestCriminal",
    function(j)
        local k = tURK.getPlayerPed()
        tURK.setWeapon(k, "WEAPON_PDGLOCK", true)
        local l = GetEntityCoords(k)
        local m = GetPlayerPed(GetPlayerFromServerId(j))
        f = true
        tURK.loadAnimDict("mp_arrest_paired")
        AttachEntityToEntity(k, m, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
        TaskPlayAnim(k, "mp_arrest_paired", "crook_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)
        RemoveAnimDict("mp_arrest_paired")
        Citizen.Wait(950)
        DetachEntity(k, true, false)
        f = false
    end
)
RegisterNetEvent(
    "URK:arrestFromPolice",
    function()
        local k = tURK.getPlayerPed()
        tURK.loadAnimDict("mp_arrest_paired")
        TaskPlayAnim(k, "mp_arrest_paired", "cop_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)
        RemoveAnimDict("mp_arrest_paired")
    end
)
RegisterNetEvent(
    "URK:toggleHandcuffs",
    function(n)
        f = true
        a = not a
        if a then
            g = 0
            h = GetGameTimer() + math.random(5000, 45000)
            i = false
            TriggerEvent("URK:startCombatTimer", false)
        end
        b = n
        processCuffModel(not a)
        if n and a then
            tURK.playAnim(true, {{"anim@move_m@prisoner_cuffed", "idle", 1}}, true)
        end
        if a and not n then
            Wait(3000)
            continueCuffs(false)
            Citizen.CreateThread(
                function()
                    Wait(1000)
                    if n then
                        tURK.playAnim(true, {{"anim@move_m@prisoner_cuffed", "idle", 1}}, true)
                    else
                        tURK.playAnim(true, {{"mp_arresting", "idle", 1}}, true)
                    end
                end
            )
        else
            tURK.stopAnim(true)
            continueCuffs(true)
            ClearPedTasks(tURK.getPlayerPed())
            UncuffPed(tURK.getPlayerPed())
        end
        f = false
    end
)
RegisterNetEvent(
    "URK:unHandcuff",
    function(n)
        f = true
        a = false
        b = n
        processCuffModel(not a)
        if n and a then
            tURK.playAnim(true, {{"anim@move_m@prisoner_cuffed", "idle", 1}}, true)
        end
        local o = GetEntityAttachedTo(PlayerPedId())
        if o ~= 0 and IsPedAPlayer(o) then
            TriggerEvent("URK:undrag")
        end
        tURK.stopAnim(true)
        continueCuffs(true)
        ClearPedTasks(tURK.getPlayerPed())
        UncuffPed(tURK.getPlayerPed())
        f = false
    end
)
function processCuffModel(p)
    if p then
        SetEntityVisible(c, false)
        DetachEntity(c, true, true)
        DeleteEntity(c)
    else
        local q = tURK.loadModel("p_cs_cuffs_02_s")
        local r = GetEntityCoords(tURK.getPlayerPed(), true)
        e = CreateObject(q, r.x, r.y, r.z, true, true, true)
        SetModelAsNoLongerNeeded(q)
        d = true
        local s = ObjToNet(e)
        tURK.syncNetworkId(ObjToNet(e))
        if b then
            AttachEntityToEntity(
                e,
                tURK.getPlayerPed(),
                GetPedBoneIndex(tURK.getPlayerPed(), 60309),
                -0.058,
                0.005,
                0.090,
                290.0,
                95.0,
                120.0,
                1,
                0,
                0,
                0,
                0,
                1
            )
        else
            AttachEntityToEntity(
                e,
                tURK.getPlayerPed(),
                GetPedBoneIndex(tURK.getPlayerPed(), 60309),
                -0.055,
                0.06,
                0.04,
                265.0,
                155.0,
                80.0,
                true,
                false,
                false,
                false,
                0,
                true
            )
        end
        c = e
    end
end
function continueCuffs(p)
    local t = tURK.getPlayerPed()
    SetEnableHandcuffs(tURK.getPlayerPed(), a)
    SetPedCanPlayGestureAnims(t, p)
    SetPedPathCanUseLadders(t, p)
    ClearPedTasks(tURK.getPlayerPed())
end
local function u()
    local v = false
    local w = true
    tURK.minigameCircularProgressBar(
        {
            Difficulty = "VeryHard",
            Timeout = 10000,
            onComplete = function(x)
                v = x
                w = false
            end,
            onTimeout = function()
                v = false
                w = false
                notify("~r~You have failed to break out in time.")
            end
        }
    )
    tURK.loadAnimDict("misschinese2_crystalmazemcs1_cs")
    while w do
        if not IsEntityPlayingAnim(PlayerPedId(), "misschinese2_crystalmazemcs1_cs", "dance_loop_tao", 3) then
            TaskPlayAnim(
                PlayerPedId(),
                "misschinese2_crystalmazemcs1_cs",
                "dance_loop_tao",
                8.0,
                -8.0,
                -1,
                1,
                1.0,
                false,
                false,
                false
            )
        end
        Citizen.Wait(0)
    end
    RemoveAnimDict("misschinese2_crystalmazemcs1_cs")
    ClearPedTasks(PlayerPedId())
    if v then
        TriggerEvent("URK:toggleHandcuffs", false)
    end
    g = g + 1
    h = GetGameTimer() + math.random(15000, 45000)
    i = false
end
local function y()
    if a then
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 47, true)
        DisableControlAction(0, 58, true)
        DisableControlAction(0, 23, true)
        DisableControlAction(0, 263, true)
        DisableControlAction(0, 264, true)
        DisableControlAction(0, 257, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
        DisableControlAction(0, 143, true)
        DisableControlAction(0, 75, true)
        DisableControlAction(27, 75, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 268, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 269, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 270, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 271, true)
        DisableControlAction(0, 170, true)
        SetPedStealthMovement(tURK.getPlayerPed(), true, "")
        for z = 12, 17 do
            DisableControlAction(0, z, true)
        end
        if not f then
            if b then
                if not IsEntityPlayingAnim(tURK.getPlayerPed(), "anim@move_m@prisoner_cuffed", "idle", true) then
                    tURK.loadAnimDict("anim@move_m@prisoner_cuffed")
                    tURK.playAnim(true, {{"anim@move_m@prisoner_cuffed", "idle", 1}}, true)
                    RemoveAnimDict("anim@move_m@prisoner_cuffed")
                end
            else
                if not IsEntityPlayingAnim(tURK.getPlayerPed(), "mp_arresting", "idle", true) then
                    tURK.loadAnimDict("mp_arresting")
                    tURK.playAnim(true, {{"mp_arresting", "idle", 1}}, true)
                    RemoveAnimDict("mp_arresting")
                end
            end
        end
        if tURK.getPlayerVehicle() ~= 0 then
            if d then
                SetEntityVisible(e, false, false)
                d = false
            end
        else
            if not d then
                SetEntityVisible(e, true, false)
                d = true
            end
        end
        if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED") then
            tURK.setWeapon(PlayerPedId(), "WEAPON_UNARMED", true)
        end
        local k = PlayerPedId()
        if not i and g < 20 and GetGameTimer() > h and IsPedStill(k) and GetEntityAttachedTo(k) == 0 then
            drawNativeNotification("Press ~INPUT_VEH_DUCK~ to attempt breaking out of cuffs")
            if IsControlJustPressed(0, 73) then
                i = true
                Citizen.CreateThread(u)
            end
        end
    end
end
tURK.createThreadOnTick(y)
RegisterNetEvent(
    "URK:uncuffAnim",
    function(A, n)
        tURK.loadAnimDict("mp_arresting")
        tURK.playAnim(false, {{"mp_arresting", "a_uncuff", 1}}, false)
        local l = GetEntityCoords(tURK.getPlayerPed())
        local t = GetPlayerPed(GetPlayerFromServerId(A))
        if t ~= 0 then
            if n then
                AttachEntityToEntity(
                    tURK.getPlayerPed(),
                    t,
                    11816,
                    0.0,
                    0.6,
                    0.0,
                    0.0,
                    0.0,
                    180.0,
                    0.0,
                    false,
                    false,
                    false,
                    false,
                    2
                )
            else
                AttachEntityToEntity(
                    tURK.getPlayerPed(),
                    t,
                    11816,
                    0.0,
                    -0.75,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    false,
                    false,
                    false,
                    false,
                    2
                )
            end
            Wait(5000)
            DetachEntity(tURK.getPlayerPed(), true, false)
        end
    end
)
RegisterCommand(
    "uncuffme",
    function()
        if tURK.getUserId() == 1 then
            TriggerEvent("URK:toggleHandcuffs", false)
        end
    end
)
RegisterNetEvent(
    "URK:playHandcuffSound",
    function(B)
        local l = GetEntityCoords(tURK.getPlayerPed())
        local C = #(l - B)
        if C <= 15 then
            SendNUIMessage({transactionType = "playHandcuff"})
        end
    end
)
