local lookup = {
    ["URKELS:changeStage"] = "URKELS:1",
    ["URKELS:toggleSiren"] = "URKELS:2",
    ["URKELS:toggleBullhorn"] = "URKELS:3",
    ["URKELS:patternChange"] = "URKELS:4",
    ["URKELS:vehicleRemoved"] = "URKELS:5",
    ["URKELS:indicatorChange"] = "URKELS:6"
}

local origRegisterNetEvent = RegisterNetEvent
RegisterNetEvent = function(name, callback)
    origRegisterNetEvent(lookup[name], callback)
end

if IsDuplicityVersion() then
    local origTriggerClientEvent = TriggerClientEvent
    TriggerClientEvent = function(name, target, ...)
        origTriggerClientEvent(lookup[name], target, ...)
    end

    TriggerClientScopeEvent = function(name, target, ...)
        exports["urk"]:TriggerClientScopeEvent(lookup[name], target, ...)
    end
else
    local origTriggerServerEvent = TriggerServerEvent
    TriggerServerEvent = function(name, ...)
        origTriggerServerEvent(lookup[name], ...)
    end
end