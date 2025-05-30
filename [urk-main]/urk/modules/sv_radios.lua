local cfg = module("cfg/cfg_radios")

local function getRadioType(user_id)
    if URK.hasPermission(user_id, "police.onduty.permission") then
        return "Police"
    elseif URK.hasPermission(user_id, "nhs.onduty.permission") then
        return "NHS"
    elseif URK.hasPermission(user_id, "prisonguard.onduty.permission") then
        return "HMP"
    elseif URK.hasPermission(user_id, "lfb.onduty.permission") then
        return "LFB"
    end
    return false
end

local radioChannels = {
    ['Police'] = {
        name = 'Police',
        players = {},
        channel = 1,
        callsign = true,
    },
    ['NHS'] = {
        name = 'NHS',
        players = {},
        channel = 2,
    },
    ['HMP'] = {
        name = 'HMP',
        players = {},
        channel = 3,
    },
    ['LFB'] = {
        name = 'LFB',
        players = {},
        channel = 4,
    },
}


local function createRadio(source)
    local user_id = URK.getUserId(source)
    local radioType = getRadioType(user_id)
    if radioType then
        Wait(1000)
        for k,v in pairs(cfg.sortOrder[radioType]) do
            if URK.hasPermission(user_id, v) then
                local sortOrder = k
                local name = GetPlayerName(source)
                if radioChannels[radioType].callsign then
                    name = name .. " [" .. getCallsign(radioType, source, user_id, radioType) .. "]"
                end
                radioChannels[radioType]['players'][source] = { name = name, sortOrder = sortOrder }
                TriggerClientEvent('URK:radiosCreateChannel', source, radioChannels[radioType].channel, radioChannels[radioType].name, radioChannels[radioType].players, true)
                TriggerClientEvent('URK:radiosAddPlayer', -1, radioChannels[radioType].channel, source, { name = name, sortOrder = sortOrder })
            end
        end
    end
end

local function removeRadio(source)
    for a, b in pairs(radioChannels) do
        if next(radioChannels[a]['players']) then
            for k, v in pairs(radioChannels[a]['players']) do
                if k == source then
                    TriggerClientEvent('URK:radiosRemovePlayer', -1, radioChannels[a].channel, k)
                    radioChannels[a]['players'][source] = nil
                end
            end
        end
    end
end

RegisterServerEvent("URK:clockedOnCreateRadio")
AddEventHandler("URK:clockedOnCreateRadio", function(source)
    createRadio(source)
end)

RegisterServerEvent("URK:clockedOffRemoveRadio")
AddEventHandler("URK:clockedOffRemoveRadio", function(source)
    removeRadio(source)
end)

AddEventHandler("URK:playerSpawn", function(user_id, source, first_spawn)
    createRadio(source)
end)

AddEventHandler('playerDropped', function(reason)
    removeRadio(source)
end)

RegisterServerEvent("URK:radiosSetIsMuted")
AddEventHandler("URK:radiosSetIsMuted", function(mutedState)
    local source = source
    local user_id = URK.getUserId(source)
    local radioType = getRadioType(user_id)
    if radioType then
        for k, v in pairs(radioChannels[radioType]['players']) do
            if k == source then
                TriggerClientEvent('URK:radiosSetPlayerIsMuted', -1, radioChannels[radioType].channel, k, mutedState)
            end
        end
    end
end)
