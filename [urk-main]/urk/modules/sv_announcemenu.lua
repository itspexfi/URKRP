local announceTables = {
    {permission = 'admin.managecommunitypot', info = {name = "Server Announcement", desc = "Announce something to the server", price = 0}, image = 'https://i.imgur.com/FZMys0F.png'},
    {permission = 'police.announce', info = {name = "PD Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/I7c5LsN.png'},
    {permission = 'nhs.announce', info = {name = "NHS Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/SypLbMo.png'},
    {permission = 'lfb.announce', info = {name = "LFB Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/AFqPgYk.png'},
    {permission = 'hmp.announce', info = {name = "HMP Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/rPF5FgQ.png'},
}

RegisterServerEvent("URK:getAnnounceMenu")
AddEventHandler("URK:getAnnounceMenu", function()
    local source = source
    local user_id = URK.getUserId(source)
    local hasPermsFor = {}
    for k,v in pairs(announceTables) do
        if URK.hasPermission(user_id, v.permission) or URK.hasGroup(user_id, 'Founder') then
            table.insert(hasPermsFor, v.info)
        end
    end
    if #hasPermsFor > 0 then
        TriggerClientEvent("URK:buildAnnounceMenu", source, hasPermsFor)
    end
end)

RegisterServerEvent("URK:serviceAnnounce")
AddEventHandler("URK:serviceAnnounce", function(announceType)
    local source = source
    local user_id = URK.getUserId(source)
    for k,v in pairs(announceTables) do
        if v.info.name == announceType then
            if URK.hasPermission(user_id, v.permission) or URK.hasGroup(user_id, 'Founder') then
                if URK.tryFullPayment(user_id, v.info.price) then
                    URK.prompt(source,"Input text to announce","",function(source,data) 
                        TriggerClientEvent('URK:serviceAnnounceCl', -1, v.image, data)
                        if v.info.price > 0 then
                            URKclient.notify(source, {"~g~Purchased a "..v.info.name.." for £"..v.info.price.." with content ~b~"..data})
                        else
                            URKclient.notify(source, {"~g~Sending a "..v.info.name.." with content ~b~"..data})
                        end
                    end)
                else
                    URKclient.notify(source, {"~r~You do not have enough money to do this."})
                end
            else
                TriggerEvent("URK:acBan", user_id, 11, GetPlayerName(source), source, 'Attempted to Trigger an announcement')
            end
        end
    end
end)