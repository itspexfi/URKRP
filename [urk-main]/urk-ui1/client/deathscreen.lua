local countdown = 0
local isUIActive = false

-- Function to safely send NUI messages
local function safeSendNUIMessage(data)
    if not data then return end
    
    Citizen.CreateThread(function()
        local success = pcall(function()
            SendNUIMessage(data)
        end)
        
        if not success then
            print("Failed to send NUI message")
            -- Attempt to recover UI state
            if isUIActive then
                Wait(1000)
                safeSendNUIMessage(data)
            end
        end
    end)
end

RegisterNetEvent("URK:CLOSE_DEATH_SCREEN", function()
    safeSendNUIMessage({
        app = "",
        type = "APP_TOGGLE",
    })
    SetNuiFocus(false, false)
    countdown = 0
    isUIActive = false
end)

RegisterNetEvent("URK:respawnKeyPressed", function()
    safeSendNUIMessage({
        page = "deathscreen",
        type = "RESPAWN_KEY_PRESSED",
    })
end)

RegisterNetEvent("URK:SHOW_DEATH_SCREEN", function(timer, killer, killerPermId, killedByWeapon, suicide)
    isUIActive = true
    safeSendNUIMessage({
        page = "deathscreen",
        type = "SHOW_DEATH_SCREEN",
        info = {
            timer = timer,
            killer = killer or "Unknown",
            killerPermId = killerPermId or "Unknown",
            killedByWeapon = killedByWeapon or "Unknown",
            suicide = suicide or false,
        }
    })
    countdown = math.floor(timer)
end)

RegisterNetEvent("URK:DEATH_SCREEN_NHS_CALLED", function()
    safeSendNUIMessage({
        page = "deathscreen",
        type = "DEATH_SCREEN_NHS_CALLED",
    })
end)

-- Add NUI callback for error handling
RegisterNUICallback("error", function(data, cb)
    print("UI Error: " .. tostring(data.message))
    cb("ok")
end)

Citizen.CreateThread(function()
    while true do
        if countdown > 0 then
            countdown = countdown - 1
            if countdown == 0 then
                TriggerEvent("URK:countdownEnded")
            end
        end
        Citizen.Wait(1000)
    end
end)

-- Add cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if isUIActive then
        SetNuiFocus(false, false)
        safeSendNUIMessage({
            app = "",
            type = "APP_TOGGLE",
        })
    end
end)