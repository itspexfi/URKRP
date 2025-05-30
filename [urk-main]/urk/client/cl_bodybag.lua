RegisterCommand("bodybag",function()
    local a = tURK.getNearestPlayer(3)
    if a then
        TriggerServerEvent("URK:requestBodyBag", a)
    else
        tURK.notify("No one dead nearby")
    end
end)

RegisterNetEvent("URK:removeIfOwned",function(b)
    local c = tURK.getObjectId(b, "bodybag_removeIfOwned")
    if c then
        if DoesEntityExist(c) then
            if NetworkHasControlOfEntity(c) then
                DeleteEntity(c)
            end
        end
    end
end)

RegisterNetEvent("URK:placeBodyBag",function()
    local d = tURK.getPlayerPed()
    local e = GetEntityCoords(d)
    local f = GetEntityHeading(d)
    SetEntityVisible(d, false, 0)
    local g = tURK.loadModel("xm_prop_body_bag")
    local h = CreateObject(g, e.x, e.y, e.z, true, true, true)
    DecorSetInt(h, "URKACVeh", 955)
    PlaceObjectOnGroundProperly(h)
    SetModelAsNoLongerNeeded(g)
    local b = ObjToNet(h)
    TriggerServerEvent("URK:removeBodybag", b)
    while GetEntityHealth(tURK.getPlayerPed()) <= 102 do
        Wait(0)
    end
    DeleteEntity(h)
    SetEntityVisible(d, true, 0)
end)
