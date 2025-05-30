local a = false
local b = nil
local c = false
local d = nil
local e = false
local f = false
function tURK.isKnockedOut()
    return a
end
function tURK.putInNearestVehicleAsPassenger(j)
    local k = tURK.getClosestVehicle(j)
    if IsEntityAVehicle(k) then
        for l = 1, math.max(GetVehicleMaxNumberOfPassengers(k), 3) do
            if IsVehicleSeatFree(k, l) then
                SetPedIntoVehicle(tURK.getPlayerPed(), k, l)
                return true
            end
        end
    end
    return false
end
function tURK.putInNetVehicleAsPassenger(m)
    local k = tURK.getObjectId(m)
    if IsEntityAVehicle(k) then
        for l = 1, GetVehicleMaxNumberOfPassengers(k) do
            if IsVehicleSeatFree(k, l) then
                SetPedIntoVehicle(tURK.getPlayerPed(), k, l)
                return true
            end
        end
    end
end
function tURK.putInVehiclePositionAsPassenger(n, o, p)
    local k = tURK.getVehicleAtPosition(n, o, p)
    if IsEntityAVehicle(k) then
        for l = 1, GetVehicleMaxNumberOfPassengers(k) do
            if IsVehicleSeatFree(k, l) then
                SetPedIntoVehicle(tURK.getPlayerPed(), k, l)
                return true
            end
        end
    end
end
local q = {{"switch@franklin@bed", "sleep_loop"}, {"switch@trevor@bed", "bed_sleep_floyd"}}
local function r()
    return q[math.random(1, #q)]
end
RegisterNetEvent("URK:knockOut",function()
    if not a and not tURK.isPurge() then
        tURK.setCanAnim(false)
        a = true
        b = r()
    end
end)
RegisterNetEvent("URK:knockOutDisable",function()
    if a then
        local s = PlayerPedId()
        SetEntityCollision(s, true, true)
        FreezeEntityPosition(s, false)
        StopAnimTask(s, b[1], b[2], 1.0)
        tURK.setCanAnim(true)
        a = false
        b = nil
    end
end)
RegisterNetEvent("URK:drag")
AddEventHandler("URK:drag",function(t)
    d = t
    e = not e
end)
RegisterNetEvent("URK:undrag")
AddEventHandler("URK:undrag",function(t)
    e = false
end)
RegisterNetEvent("URK:clearPoliceStuff",function()
    stopAutoClosingInventory = false
    SetTimeout(10000,function()
        stopAutoClosingInventory = true
    end)
    while not stopAutoClosingInventory do
        drawInventoryUI = false
        Wait(0)
    end
end)

TriggerEvent("chat:addSuggestion","/s60","Authorise a new Section 60 order",{{name = "Radius", help = "In metres"}, {name = "Duration", help = "In Minutes"}})
local u = {}
RegisterNetEvent("URK:addS60",function(v, w, x)
    local y = AddBlipForCoord(v.x, v.y, v.z)
    local z = AddBlipForRadius(v.x, v.y, v.z, w + .0)
    local A = 61
    SetBlipSprite(y, 526)
    SetBlipColour(y, A)
    SetBlipScale(y, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Section 60")
    EndTextCommandSetBlipName(y)
    SetBlipAlpha(z, 80)
    SetBlipColour(z, A)
    u[x] = {z, y}
    local B = GetStreetNameAtCoord(v.x, v.y, v.z)
    local C = GetStreetNameFromHashKey(B)
    TriggerEvent("URK:showNotification",
    {
        text = "Metropolitan Police: <br/>A Section 60 has been authorised for the area of " .. C .. ".<br/><br/>This gives officers the power to search any person or vehicle in the area, without any grounds. <br/><br/>This has been authorised in line with legislation.",
        height = "auto",
        width = "auto",
        colour = "#FFF",
        background = "#3287cd",
        pos = "bottom-right",
        icon = "success"
    },
    100000)
end)

RegisterNetEvent("URK:removeS60",function(x)
    if u[t] == nil then
        return
    else
        local D = u[x]
        local y = D[2]
        local w = D[1]
        RemoveBlip(y)
        RemoveBlip(w)
    end
end)

Citizen.CreateThread(function()
    while true do
        if e and d ~= nil then
            DisableControlAction(0, 21, true)
            local E = GetPlayerPed(GetPlayerFromServerId(d))
            local F = tURK.getPlayerPed()
            AttachEntityToEntity(F, E, 4103, 11816, 0.48, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2)
            f = true
        else
            if f then
                DetachEntity(tURK.getPlayerPed(), true, false)
                f = false
            end
        end
        if IsControlPressed(0, 323) or IsControlPressed(0, 27) and not IsUsingKeyboard(2) then
            if not globalSurrenderring and not tURK.isInComa() and not tURK.isHandcuffed() and (tURK.canAnim() or tURK.isTazedByRevive()) then
                DisablePlayerFiring(tURK.getPlayerPed(), true)
                DisableControlAction(0, 22, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 154, true)
                if not IsEntityDead(tURK.getPlayerPed()) then
                    if not c and not GetIsTaskActive(tURK.getPlayerPed(), 298) then
                        c = true
                        tURK.loadAnimDict("missminuteman_1ig_2")    
                        TaskPlayAnim(tURK.getPlayerPed(),"missminuteman_1ig_2","handsup_enter",7.0,1.0,-1,50,0,false,false,false)
                        RemoveAnimDict("missminuteman_1ig_2")
                    end
                end
            end
        end
        if (IsControlJustReleased(1, 323) or IsControlJustReleased(1, 27)) and not globalSurrenderring and c and not tURK.isInComa() and not tURK.isHandcuffed() and tURK.canAnim() then
            c = false
            CreateThread(function()
                local G = false
                CreateThread(function()
                    Wait(1000)
                    G = true
                end)
                while not G do
                    DisablePlayerFiring(tURK.getPlayerPed(), true)
                    Wait(1)
                end
            end)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 137, true)
            ClearPedTasks(tURK.getPlayerPed())
        end
        if a then
            if tURK.isStaffedOn() then
                TriggerEvent("URK:knockOutDisable")
            elseif not tURK.isInComa() then
                local s = PlayerPedId()
                if not IsEntityPlayingAnim(s, b[1], b[2], 3) then
                    tURK.loadAnimDict(b[1])
                    local v = GetEntityCoords(s, true)
                    SetEntityCollision(s, false, false)
                    FreezeEntityPosition(s, true)
                    local H, I = GetGroundZFor_3dCoord(v.x, v.y, v.z)
                    if H then
                        v = vector3(v.x, v.y, I + 0.3)
                    end
                    TaskPlayAnimAdvanced(s, b[1], b[2], v.x, v.y, v.z, 0.0, 0.0, 0.0, 3.0, 1.0, -1, 1, 0.0, 0, 0)
                    RemoveAnimDict(b[1])
                end
                tURK.notify("~r~You have been knocked out!")
            end
        end
        Wait(0)
    end
end)

RMenu.Add("policehandbook","main",RageUI.CreateMenu("Police Handbook", "~r~Officer Handbook", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight()))
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('policehandbook', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.Button("Arrest",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "The time now is ___. <br/>You are currently under arrest on suspision of ___. <br/>You do not have to say anything. But, it may harm your defence if you do not mention when questioned something which you later rely on in court. <br/>Anything you do say may be given in evidence. <br/>Do you understand?. <br/>The necessities for your arrest are to ___.",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Search - GOWISELY",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "Before you stop and search someone you must remember GO-WISELY. <br/>You do not have to use this after arrest. <br/>Grounds: for the search. <br/>Object: of the search. <br/>Warrant card: If not in uniform. <br/>Identity: I am PC ___. <br/>Station: attached to ___ Police Station. <br/>Entitlement: Entitled to a copy of this search up to ___ months. <br/>Legal power: Searching under s1 PACE (1984) / s23 MODA (1971). <br/>You: You are currently detained for the purpose of a search.",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("PACE - Key Legislation",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "Police and Criminal Evidence Act 1984  - PACE.<br/> Section 1 - Stop and search (Stolen property, prohibited articles, weapons, articles used to commit an offence.<br/>Section 17 - Entry for the purpose of life and arrest<br/> Section 18 - Entry to search after an arrest <br/>Section 19 - Power of seizure<br/> Section 24 - Power of arrest <br/> Section 32 - Search after an arrest",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Identify Codes",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "IC1:~s~ White - North European. <br/>IC2: White - South European. <br/>IC3: Black. <br/>IC4: Asian. <br/>IC5: Chinese, Japanese or other South East Asian. <br/>IC6: Arabic or North African. <br/>IC9: Unknown",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Traffic Offence Report",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "I am reporting you for consideration of the question of prosecuting you for the offence(s) of ___. <br/><br/>You do not have to say anything but it may harm your defence if you do not mention NOW something which you may later rely on in court. Anything you do say may be given in evidence. <br/><br/>You are not under arrest - you are entitled to legal advice and you are not obliged to remain with me.",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Initial Phase Pursuit",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "VEHICLE DESCRIPTION: MAKE/MODEL/VRM. <br/>LOCATION & DIRECTION: ___. <br/>SPEED: ___. <br/>VEHICLE DENSITY: LOW/MED/HIGH. <br/>PEDESTRIAN DENSITY: LOW/MED/HIGH. <br/>ROAD CONDITIONS: WET/DRY/DIRT. <br/>WEATHER: CLEAR/LIGHT/DARK. <br/>VISIBILITY: CLEAR/MED/LOW. <br/>DRIVER CLASSIFICATION: IPP/ADV/TPAC. <br/>POLICE VEHICLE: MARKED/UNMARKED",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Warning Markers",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "FI: FIREARMS. <br/>WE: WEAPONS. <br/>XP: EXPLOSIVES. <br/>VI: VIOLENT. <br/>CO: CONTAGIOUS. <br/>ES: ESCAPER. <br/>AG: ALLEGES. <br/>AT: AILMENT. <br/>SU: SUICIDAL. <br/>MH: MENTAL HEALTH. <br/>DR: DRUGS. <br/>IM: MALE IMPERSONATOR. <br/>IF: FEMALE IMPERSONATOR",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("s136 - Mental Healt Act",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "A constable may take a person to (or keep at) a place of a safety. <br/>This can be done without a warrant if: The individual appears to have a mental disorder, and they are in any place other than a house, flat or room where a person is living, or garden or garage that only one household has access to, and they are in need of immediate care or control. <br/><br/>A registered medical practitioner/healthcare professional must be consulted if practicable to do so.",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
            RageUI.Button("Arrest Necessities",nil,{},true,function(J, K, L)
                if L then
                    TriggerEvent("URK:showNotification",
                    {
                        text = "You require at least two of the following necessities to arrest a suspect: <br/><br/>Investigation: conduct a prompt and effective. <br/>Disappearance: prevent the prosecution being hindered. <br/>Child or Vulnerable person: to protect a. <br/>Obstruction: of the highway unlawfully (preventing). <br/>Physical Injury: prevent to themselves or other person. <br/>Public Decency: prevent an offence being committed against. <br/>Loss or Damage: prevent to property. <br/>Address: enable to be ascertained (not readily available). <br/>Name: enable to be ascertained (not readily available).",
                        height = "auto",
                        width = "auto",
                        colour = "#FFF",
                        background = "#3287cd",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    100000)
                end
            end)
        end)
    end
end)
TriggerEvent("chat:addSuggestion", "/handbook", "Toggle the Police Handbook")
RegisterNetEvent("URK:toggleHandbook",function()
    RageUI.Visible(RMenu:Get("policehandbook", "main"), true)
end)
RegisterNetEvent("playBreathalyserSound",function(v)
    Citizen.SetTimeout(10000,function()
        local h = tURK.getPlayerCoords()
        local i = #(h - v)
        if i <= 15 then
            SendNUIMessage({transactionType = "breathalyser"})
        end
    end)
end)
TriggerEvent("chat:addSuggestion", "/breathalyse", "Breathalyse the nearest person")
RegisterNetEvent("URK:breathTestResult",function(M,N)
    local O = N
    RequestAnimDict("weapons@first_person@aim_rng@generic@projectile@shared@core")
    while not HasAnimDictLoaded("weapons@first_person@aim_rng@generic@projectile@shared@core") do
        Wait(0)
    end
    TaskPlayAnim(tURK.getPlayerPed(),"weapons@first_person@aim_rng@generic@projectile@shared@core","idlerng_med",1.0,-1,10000,50,0,false,false,false)
    RageUI.Text({message = "~w~You are now ~b~breathalysing ~b~" .. I .. "~w~, please wait for the results."})
    Citizen.SetTimeout(10000,function()
        if M < 36 then
            RageUI.Text({message = "~w~The suspect has provided a legal breathalyser sample of ~b~" ..M .. " ~w~µg/100ml."})
        else
            RageUI.Text({message = "~w~The suspect has provided an illegal breathalyser sample of ~b~" ..M .. " ~w~µg/100ml."})
        end
    end)
end)
RegisterNetEvent("URK:beingBreathalysed",function()
    RageUI.Text({message = "~w~You are currently being ~b~breathalysed ~w~by a police officer."})
end)
RegisterNetEvent("URK:breathalyserCommand",function()
    local E = tURK.getPlayerPed()
    if not IsPedInAnyVehicle(E, true) then
        local v = GetEntityCoords(E)
        local P = GetActivePlayers()
        for Q, R in pairs(P) do
            if GetPlayerPed(R) ~= E then
                local S = GetEntityCoords(GetPlayerPed(R))
                local T = #(v - S)
                if T < 3.0 then
                    local U = GetPlayerServerId(R)
                    TriggerServerEvent("URK:breathalyserRequest", U)
                    break
                end
            end
        end
    end
end)
TriggerEvent("chat:addSuggestion", "/wc", "Flash your police warrant card.")
TriggerEvent("chat:addSuggestion", "/wca", "Flash your police warrant card anonymously.")
RegisterNetEvent("URK:flashWarrantCard",function()
    local E = PlayerPedId()
    local V = tURK.loadModel("prop_fib_badge")
    local W = CreateObject(V, 0, 0, 0, true, true, true)
    while not DoesEntityExist(W) do
        Wait(0)
    end
    SetModelAsNoLongerNeeded(V)
    FreezeEntityPosition(W)
    AttachEntityToEntity(W,E,GetPedBoneIndex(E, 58866),0.03,-0.05,-0.044,0.0,90.0,25.0,true,true,false,true,1,true)
    Wait(3000)
    DeleteObject(W)
end)

RegisterNetEvent("URK:startSearchingSuspect",function()
    tURK.setCanAnim(false)
    tURK.loadAnimDict("custom@police")
    TaskPlayAnim(PlayerPedId(), "custom@police", "police", 8.0, 8.0, -1, 0, 0.0, false, false, false)
    RemoveAnimDict("custom@police")
    local a3 = GetGameTimer()
    while GetGameTimer() - a3 < 10000 do
        if IsDisabledControlJustPressed(0, 73) then
            TriggerServerEvent("URK:cancelPlayerSearch")
            return
        end
        Citizen.Wait(0)
    end
    tURK.setCanAnim(true)
end)
local a4 = false
RegisterNetEvent("URK:startBeingSearching",function(a5)
    local a6 = GetPlayerFromServerId(a5)
    if a6 == -1 then
        return
    end
    local a7 = GetPlayerPed(a6)
    if a7 == 0 then
        return
    end
    a4 = true
    tURK.setCanAnim(false)
    tURK.loadAnimDict("custom@suspect")
    local s = tURK.getPlayerPed()
    AttachEntityToEntity(s, a7, -1, -0.05, 0.5, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, false)
    TaskPlayAnim(s, "custom@suspect", "suspect", 8.0, 8.0, -1, 2, 0.0, false, false, false)
    RemoveAnimDict("custom@suspect")
    local a3 = GetGameTimer()
    while GetGameTimer() - a3 < 10000 do
        if not a4 then
            return
        end
        Citizen.Wait(0)
    end
    a4 = false
    tURK.setCanAnim(true)
    DetachEntity(s)
    ClearPedTasks(s)
end)
RegisterNetEvent("URK:cancelPlayerSearch",function()
    a4 = false
    tURK.setCanAnim(true)
    local s = tURK.getPlayerPed()
    DetachEntity(s)
    ClearPedTasks(s)
end)
local a8 = ""
local a9 = ""
local aa = ""
local ab = false
local ac = ""
local ad = ""
local ae = ""
local af = false
RegisterNetEvent("URK:receivePoliceCallsign",function(ag, ah, ai)
    a8 = ah
    a9 = ag
    aa = ai
    ab = true
    print("Your PD rank is: " .. a8 .. "\nYour callsign is: " .. a9)
end)
RegisterNetEvent("URK:receiveHmpCallsign",function(ag, ah, ai)
    ac = ah
    ad = ag
    ae = ai
    af = true
    print("Your HMP rank is: " .. ae .. "\nYour callsign is: " .. ad)
end)
function tURK.getPoliceCallsign()
    return a9
end
function tURK.getPoliceRank()
    return a8
end
function tURK.getPoliceName()
    return aa
end
function tURK.hasPoliceCallsign()
    return ab
end
function tURK.getHmpCallsign()
    return ad
end
function tURK.getHmpRank()
    return ac
end
function tURK.getHmpName()
    return ae
end
function tURK.hasHmpCallsign()
    return af
end
function func_drawCallsign()
    if a9 ~= "" and globalOnPoliceDuty then
        DrawAdvancedText(1.064, 0.972, 0.005, 0.0028, 0.4, a9, 255, 255, 255, 255, 0, 0)
    end
    if ad ~= "" and globalOnPrisonDuty then
        DrawAdvancedText(1.064, 0.972, 0.005, 0.0028, 0.4, ad, 255, 255, 255, 255, 0, 0)
    end
end
tURK.createThreadOnTick(func_drawCallsign)
local aj = 0
local function ak()
    local s = tURK.getPlayerPed()
    if IsPedShooting(s) then
        local al = GetSelectedPedWeapon(s)
        local am, an = GetMaxAmmo(s, al)
        local ao = GetWeapontypeGroup(al)
        if an >= 1 and ao ~= GetHashKey("GROUP_MELEE") and ao ~= GetHashKey("GROUP_THROWN") then
            aj = GetGameTimer()
        end
    end
end
tURK.createThreadOnTick(ak)
function tURK.hasRecentlyShotGun()
    return aj ~= 0 and GetGameTimer() - aj < 600000
end

AddEventHandler("URK:onClientSpawn",function()
    aj = 0
end)

RMenu.Add("trainingWorlds","mainmenu",RageUI.CreateMenu("Training Worlds", "Main Menu", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight()))
local ap = {}
local aq = false
RegisterNetEvent("URK:trainingWorldOpen",function(ar)
    aq = ar
    RageUI.Visible(RMenu:Get("trainingWorlds", "mainmenu"), true)
end)
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('trainingWorlds', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            local as = false
            for x, at in pairs(ap) do
                local au = string.format("Created by %s (%s) - Bucket %s", at.ownerName, at.ownerUserId, at.bucket)
                local av = at.bucket == tURK.getPlayerBucket()
                local aw = av and {RightLabel = "(Joined)"} or {}
                RageUI.ButtonWithStyle(at.name,au,aw,true,function(J, K, L)
                    if K and aq then
                        drawNativeNotification("Press ~INPUT_FRONTEND_DELETE~ to delete this world")
                        if IsControlJustPressed(0, 214) then
                            TriggerServerEvent("URK:trainingWorldRemove", x)
                        end
                    end
                    if L then
                        TriggerServerEvent("URK:trainingWorldJoin", x)
                    end
                end)
                if av then
                    as = av
                end
            end
            if as then
                RageUI.ButtonWithStyle("~r~Leave Training World",nil,{},true,function(J, K, L)
                    if L then
                        TriggerServerEvent("URK:trainingWorldLeave")
                    end
                end)
            end
            if aq then
                RageUI.ButtonWithStyle("~r~Create Training World",nil,{},true,function(J, K, L)
                    if L then
                        TriggerServerEvent("URK:trainingWorldCreate")
                    end
                end)
            end
        end)
    end
end)

RegisterNetEvent("URK:trainingWorldSend",function(x, ax)
    ap[x] = ax
end)
RegisterNetEvent("URK:trainingWorldSendAll",function(ax)
    ap = ax
end)
RegisterNetEvent("URK:trainingWorldRemove",function(x)
    ap[x] = nil
end)
