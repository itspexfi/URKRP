isDebugModeEnabled = false
function tURK.toggleDebugMode()
    isDebugModeEnabled = not isDebugModeEnabled
    local a = isDebugModeEnabled and "enabled" or "disabled"
    print("[URK] debug mode " .. a)
end
function tURK.debugLog(...)
    if isDebugModeEnabled then
        print("[URK DEBUG] ", ...)
    end
end
function tURK.debugLog_export(b, ...)
    if isDebugModeEnabled then
        local c = string.format("[URK DEBUG : %s]", b)
        print(c, ...)
    end
end
RegisterCommand(
    "debugmode",
    function()
        tURK.toggleDebugMode()
    end,
    false
)
exports(
    "debugLog",
    function(...)
        local b = GetInvokingResource()
        tURK.debugLog_export(b, ...)
    end
)
