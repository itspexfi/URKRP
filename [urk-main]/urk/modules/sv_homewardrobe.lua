local outfitCodes = {}

RegisterNetEvent("URK:saveWardrobeOutfit")
AddEventHandler("URK:saveWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = URK.getUserId(source)
    URK.getUData(user_id, "URK:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        URKclient.getCustomization(source,{},function(custom)
            sets[outfitName] = custom
            URK.setUData(user_id,"URK:home:wardrobe",json.encode(sets))
            URKclient.notify(source,{"~g~Saved outfit "..outfitName.." to wardrobe!"})
            TriggerClientEvent("URK:refreshOutfitMenu", source, sets)
        end)
    end)
end)

RegisterNetEvent("URK:deleteWardrobeOutfit")
AddEventHandler("URK:deleteWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = URK.getUserId(source)
    URK.getUData(user_id, "URK:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        sets[outfitName] = nil
        URK.setUData(user_id,"URK:home:wardrobe",json.encode(sets))
        URKclient.notify(source,{"~r~Remove outfit "..outfitName.." from wardrobe!"})
        TriggerClientEvent("URK:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("URK:equipWardrobeOutfit")
AddEventHandler("URK:equipWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = URK.getUserId(source)
    URK.getUData(user_id, "URK:home:wardrobe", function(data)
        local sets = json.decode(data)
        URKclient.setCustomization(source, {sets[outfitName]})
        URKclient.getHairAndTats(source, {})
    end)
end)

RegisterNetEvent("URK:initWardrobe")
AddEventHandler("URK:initWardrobe", function()
    local source = source
    local user_id = URK.getUserId(source)
    URK.getUData(user_id, "URK:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        TriggerClientEvent("URK:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("URK:getCurrentOutfitCode")
AddEventHandler("URK:getCurrentOutfitCode", function()
    local source = source
    local user_id = URK.getUserId(source)
    URKclient.getCustomization(source,{},function(custom)
        URKclient.generateUUID(source, {"outfitcode", 5, "alphanumeric"}, function(uuid)
            local uuid = string.upper(uuid)
            outfitCodes[uuid] = custom
            URKclient.CopyToClipBoard(source, {uuid})
            URKclient.notify(source, {"~g~Outfit code copied to clipboard."})
            URKclient.notify(source, {"The code ~y~"..uuid.."~w~ will persist until restart."})
        end)
    end)
end)

RegisterNetEvent("URK:applyOutfitCode")
AddEventHandler("URK:applyOutfitCode", function(outfitCode)
    local source = source
    local user_id = URK.getUserId(source)
    if outfitCodes[outfitCode] ~= nil then
        URKclient.setCustomization(source, {outfitCodes[outfitCode]})
        URKclient.notify(source, {"~g~Outfit code applied."})
        URKclient.getHairAndTats(source, {})
    else
        URKclient.notify(source, {"~r~Outfit code not found."})
    end
end)

RegisterCommand('wardrobe', function(source)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Founder') then
        TriggerClientEvent("URK:openOutfitMenu", source)
    end
end)

RegisterCommand('copyfit', function(source, args)
    local source = source
    local user_id = URK.getUserId(source)
    local permid = tonumber(args[1])
    if URK.hasGroup(user_id, 'Founder') then
        URKclient.getCustomization(URK.getUserSource(permid),{},function(custom)
            URKclient.setCustomization(source, {custom})
        end)
    end
end)