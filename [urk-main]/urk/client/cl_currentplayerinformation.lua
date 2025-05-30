local currentPlayerInfo = {}

RegisterNetEvent("URK:receiveCurrentPlayerInfo")
AddEventHandler("URK:receiveCurrentPlayerInfo",function(playerInfo)
    currentPlayerInfo = playerInfo
end)

function tURK.getCurrentPlayerInfo(z)
    for k,v in pairs(currentPlayerInfo) do
        if k == z then
            return v
        end
    end
end