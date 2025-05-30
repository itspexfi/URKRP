local tURK = Proxy.getInterface("URK")
local cfg = module("cfg/cfg_deathmatch")
local inLocation = false
local locationCoords = nil
local teleportCooldown = 0
local mosinList = {}
local weaponIndex = 1
local defaultMosin = 'WEAPON_MOSIN'
local stopTeleport = false

RMenu.Add("urkdeathmatch", "mainmenu", RageUI.CreateMenu("Deathmatch", "Main Menu", tURK.getRageUIMenuWidth(), tURK.getRageUIMenuHeight()))

RegisterNetEvent("URK:urkdeathmatchopen", function()
    RageUI.Visible(RMenu:Get("urkdeathmatch", "mainmenu"), true)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        RageUI.IsVisible(RMenu:Get('urkdeathmatch', 'mainmenu'), function()
            if not stopTeleport then
                for k, v in pairs(cfg.Teleport) do
                    if v.enabled then
                        RageUI.Button(v.name, nil, "", { RightBadge = RageUI.BadgeStyle.Tick }, function(Hovered, Active, Selected)
                            if Selected then
                                if teleportCooldown > 0 then
                                    notify('~r~You must wait ' .. teleportCooldown .. ' seconds before teleporting again.')
                                else
                                    notify('~g~Teleported to ' .. v.name)
                                    SetEntityCoords(PlayerPedId(), v.location)
                                    GiveWeaponToPed(PlayerPedId(), defaultMosin, 250, false, true)
                                    GiveWeaponToPed(PlayerPedId(), defaultWeapon, 250, false, false) -- cl_settings.lua option
                                    inLocation = true
                                    locationCoords = v.location
                                    teleportCooldown = 5
                                end
                            end
                        end)
                    end
                end

                if inLocation then
                    RageUI.Button("~r~Reset Spawn Location", nil, "", { RightBadge = RageUI.BadgeStyle.Tick }, function(Hovered, Active, Selected)
                        if Selected then
                            inLocation = false
                            locationCoords = nil
                        end
                    end)
                end

                RageUI.List("Default Mosin", mosinList, weaponIndex, "~r~Change your Selected Mosin", {}, true, function(Hovered, Active, Selected, Index)
                    weaponIndex = Index
                    defaultMosin = mosinList[weaponIndex]
                end)
            else
                RageUI.Separator("You cannot use this currently.")
            end
        end)
    end
end)

AddEventHandler("playerSpawned", function()
    if locationCoords then
        SetEntityCoords(PlayerPedId(), locationCoords)
        GiveWeaponToPed(PlayerPedId(), defaultMosin, 250, false, true)
        GiveWeaponToPed(PlayerPedId(), defaultWeapon, 250, false, false) -- cl_settings.lua option
        SetEntityInvincible(PlayerPedId(), true)
        SetPlayerInvincible(PlayerId(), true)
        Citizen.InvokeNative(0x5FFE9B4144F9712F, true)

        Citizen.Wait(3000) -- Use Citizen.Wait instead of Wait

        SetEntityInvincible(PlayerPedId(), false)
        SetPlayerInvincible(PlayerId(), false)
        Citizen.InvokeNative(0x5FFE9B4144F9712F, false)
    end
end)

RegisterKeyMapping("deathmatchmenu", "Opens Teleport Menu", "keyboard", "F7")

RegisterCommand("deathmatchmenu", function(source)
    RageUI.Visible(RMenu:Get("urkdeathmatch", "mainmenu"), true)
end)
