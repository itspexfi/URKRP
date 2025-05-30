insideDiamondCasino = false
AddEventHandler("URK:onClientSpawn",function(a, b)
    if b then
        local c = vector3(1121.7922363281, 239.42251586914, -50.440742492676)
        local d = function(e)
            insideDiamondCasino = true
            tURK.setCanAnim(false)
            tURK.overrideTime(12, 0, 0)
            TriggerEvent("URK:enteredDiamondCasino")
            TriggerServerEvent('URK:getChips')
        end
        local f = function(e)
            insideDiamondCasino = false
            tURK.setCanAnim(true)
            tURK.cancelOverrideTimeWeather()
            TriggerEvent("URK:exitedDiamondCasino")
        end
        local g = function(e)
        end
        tURK.createArea("diamondcasino", c, 100.0, 20, d, f, g, {})
    end
end)
