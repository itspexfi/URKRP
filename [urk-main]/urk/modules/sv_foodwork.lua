local a = {
    ["burger"] = {
        [1] = 'bun',
        [2] = 'lettuce',
        [3] = 'tomato',
        [4] = 'onion',
        [5] = 'cheese',
        [6] = 'beef_patty',
        [7] = 'bbq',
    }
}

local cookingStages = {}
RegisterNetEvent('URK:requestStartCooking')
AddEventHandler('URK:requestStartCooking', function(recipe)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Burger Shot Cook') then
        for k,v in pairs(a) do
            if k == recipe then
                cookingStages[user_id] = 1
                TriggerClientEvent('URK:beginCooking', source, recipe)
                TriggerClientEvent('URK:cookingInstruction', source, v[cookingStages[user_id]])
            end
        end
    else
        URKclient.notify(source, {"~r~You aren't clocked on as a Burger Shot Cook, head to cityhall to sign up."})
    end
end)

RegisterNetEvent('URK:pickupCookingIngredient')
AddEventHandler('URK:pickupCookingIngredient', function(recipe, ingredient)
    local source = source
    local user_id = URK.getUserId(source)
    if URK.hasGroup(user_id, 'Burger Shot Cook') then
        if ingredient == 'bbq' and cookingStages[user_id] == 7 then
            cookingStages[user_id] = nil
            TriggerClientEvent('URK:finishedCooking', source)
            URK.giveBankMoney(user_id, grindBoost*4000)
        else
            for k,v in pairs(a) do
                if k == recipe then
                    cookingStages[user_id] = cookingStages[user_id] + 1
                    TriggerClientEvent('URK:cookingInstruction', source, v[cookingStages[user_id]])
                end
            end
        end
    else
        URKclient.notify(source, {"~r~You aren't clocked on as a Burger Shot Cook, head to cityhall to sign up."})
    end
end)