function TchatGetMessageChannel (channel, cb)
    MySQL.Async.fetchAll("SELECT * FROM phone_app_chat WHERE channel = @channel ORDER BY time DESC LIMIT 100", { 
        ['@channel'] = channel
    }, cb)
end

function TchatAddMessage (channel, message)
  local Query = "INSERT INTO phone_app_chat (`channel`, `message`) VALUES(@channel, @message);"
  local Query2 = 'SELECT * from phone_app_chat WHERE `id` = @id;'
  local Parameters = {
    ['@channel'] = channel,
    ['@message'] = message
  }
  MySQL.Async.insert(Query, Parameters, function (id)
    MySQL.Async.fetchAll(Query2, { ['@id'] = id }, function (reponse)
      TriggerClientEvent('URK:tchat_receive', -1, reponse[1])
    end)
  end)
end


RegisterServerEvent('URK:tchat_channel')
AddEventHandler('URK:tchat_channel', function(channel)
  local sourcePlayer = tonumber(source)
  TchatGetMessageChannel(channel, function (messages)
    TriggerClientEvent('URK:tchat_channel', sourcePlayer, channel, messages)
  end)
end)

RegisterServerEvent('URK:tchat_addMessage')
AddEventHandler('URK:tchat_addMessage', function(channel, message)
  TchatAddMessage(channel, message)
end)