
globalIsInDeathmatchLobby = false

RMenu.Add("deathmatch", "mainmenu", RageUI.CreateMenu("Deathmatch", "Main Menu", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight()))
RMenu.Add("deathmatch", "weapons", RageUI.CreateSubMenu(RMenu:Get("deathmatch", "mainmenu"), "Deathmatch Weapons", "~r~URK Deathmatch Weapons", 1350, 10, tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight()))


function tURK.isPlayerInDeathmatch()
    return globalIsInDeathmatchLobby
end

local ap = {}
local aq = false

RegisterNetEvent("URK:deathMatchOpen", function(ar)
    aq = ar
    RageUI.Visible(RMenu:Get("deathmatch", "mainmenu"), true)
end)

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('deathmatch', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false }, function()
            local as = false
            for x, at in pairs(ap) do
                local au = string.format("Created by %s (%s) - Bucket %s", at.ownerName, at.ownerUserId, at.bucket)
                local av = at.bucket == tURK.getPlayerBucket()
                local aw = av and { RightLabel = "(Joined)" } or {}
                RageUI.ButtonWithStyle(at.name, au, aw, true, function(J, K, L)
                    if K and aq then
                        drawNativeNotification("Press ~INPUT_FRONTEND_DELETE~ to delete this deathmatch")
                        if IsControlJustPressed(0, 214) then
                            TriggerServerEvent("URK:deathMatchRemove", x)
                        end
                    end
                    if tURK.isHandcuffed() or tURK.isTazed() 
                then                         
                    notify("~r~You can not create lobby whilst in handcuffs/tazed.")
                    
                elseif tURK.getPlayerCombatTimer() > 0 then
                        notify("~r~You can not join a lobby in combat.")
                    else
                        if L then
                            TriggerServerEvent("URK:deathMatchJoin", x)
                            globalIsInDeathmatchLobby = true 
                        end
                    end
                end)
                if av then
                    as = av
                end
            end
            if as then
                RageUI.ButtonWithStyle("~r~Leave lobby", nil, {}, true, function(J, K, L)
                    if L then
                        TriggerServerEvent("URK:deathMatchLeave")
                        globalIsInDeathmatchLobby = false  
                    end
                end)
            end
            if aq then
                RageUI.ButtonWithStyle("~r~Create lobby", nil, {}, true, function(J, K, L)
                    if tURK.isHandcuffed() or tURK.isTazed() 
                then                         
                    notify("~r~You can not create lobby whilst in handcuffs/tazed.")

                elseif tURK.getPlayerCombatTimer() > 0 then
                        notify("~r~You can not create lobby in combat.")
                    else
                        if L then
                            TriggerServerEvent("URK:deathMatchCreate")
                        end
                    end
                end)
            end
        end)
    end
end)


RegisterNetEvent("URK:deathMatchend",function(x, ax)
    ap[x] = ax
end)
RegisterNetEvent("URK:deathMatchendAll",function(ax)
    ap = ax
end)
RegisterNetEvent("URK:deathMatchRemove",function(x)
    ap[x] = nil
end)