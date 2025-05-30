local htmlEntities = module("lib/htmlEntities")

local cfg = module("cfg/cfg_identity")
local lang = URK.lang

local sanitizes = module("cfg/sanitizes")

-- this module describe the identity system

-- init sql


MySQL.createCommand("URK/get_user_identity","SELECT * FROM urk_user_identities WHERE user_id = @user_id")
MySQL.createCommand("URK/init_user_identity","INSERT IGNORE INTO urk_user_identities(user_id,registration,phone,firstname,name,age) VALUES(@user_id,@registration,@phone,@firstname,@name,@age)")
MySQL.createCommand("URK/update_user_identity","UPDATE urk_user_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE user_id = @user_id")
MySQL.createCommand("URK/get_userbyreg","SELECT user_id FROM urk_user_identities WHERE registration = @registration")
MySQL.createCommand("URK/get_userbyphone","SELECT user_id FROM urk_user_identities WHERE phone = @phone")
MySQL.createCommand("URK/update_user_phone","UPDATE urk_user_identities SET phone = @phone WHERE user_id = @user_id")



-- api

-- cbreturn user identity
function URK.getUserIdentity(user_id, cbr)
    local task = Task(cbr)
    if cbr then 
        MySQL.query("URK/get_user_identity", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then 
              task({rows[1]})
            else 
               task({})
            end
        end)
    else 
        print('Mis usage detected! CBR Does not exist')
    end
end

-- cbreturn user_id by registration or nil
function URK.getUserByRegistration(registration, cbr)
  local task = Task(cbr)

  MySQL.query("URK/get_userbyreg", {registration = registration or ""}, function(rows, affected)
    if #rows > 0 then
      task({rows[1].user_id})
    else
      task()
    end
  end)
end

-- cbreturn user_id by phone or nil
function URK.getUserByPhone(phone, cbr)
  local task = Task(cbr)

  MySQL.query("URK/get_userbyphone", {phone = phone or ""}, function(rows, affected)
    if #rows > 0 then
      task({rows[1].user_id})
    else
      task()
    end
  end)
end

function URK.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- cbreturn a unique registration number
function URK.generateRegistrationNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate registration number
    local registration = URK.generateStringNumber("DDDLLL")
    URK.getUserByRegistration(registration, function(user_id)
      if user_id ~= nil then
        search() -- continue generation
      else
        task({registration})
      end
    end)
  end

  search()
end

-- cbreturn a unique phone number (0DDDDD, D => digit)
function URK.generatePhoneNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate phone number
    local phone = URK.generateStringNumber(cfg.phone_format)
    URK.getUserByPhone(phone, function(user_id)
      if user_id ~= nil then
        search() -- continue generation
      else
        task({phone})
      end
    end)
  end

  search()
end

-- events, init user identity at connection
AddEventHandler("URK:playerJoin",function(user_id,source,name,last_login)
  URK.getUserIdentity(user_id, function(identity)
    if identity == nil then
      URK.generateRegistrationNumber(function(registration)
        URK.generatePhoneNumber(function(phone)
          MySQL.execute("URK/init_user_identity", {
            user_id = user_id,
            registration = registration,
            phone = phone,
            firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)],
            name = cfg.random_last_names[math.random(1,#cfg.random_last_names)],
            age = math.random(25,40)
          })
        end)
      end)
    end
  end)
end)

RegisterNetEvent("URK:getIdentity")
AddEventHandler("URK:getIdentity", function()
  local source = source
  local user_id = URK.getUserId(source)
  if user_id ~= nil then
    URK.getUserIdentity(user_id, function(identity)
      TriggerClientEvent('URK:gotCurrentIdentity', source, identity['firstname'], identity['name'], identity['age'])
    end)
  end
end)

RegisterNetEvent("URK:getNewIdentity")
AddEventHandler("URK:getNewIdentity", function()
  local source = source
  local user_id = URK.getUserId(source)
  if user_id ~= nil then
    URK.prompt(source, 'First Name:', '', function(source,firstname)
      if firstname == '' then return end
      if string.len(firstname) >= 2 and string.len(firstname) < 50 then
        local firstname = sanitizeString(firstname, sanitizes.name[1], sanitizes.name[2])
       URK.prompt(source, 'Last Name:', '', function(source, lastname)
          if lastname == '' then return end
          if string.len(lastname) >= 2 and string.len(lastname) < 50 then
            local lastname = sanitizeString(lastname, sanitizes.name[1], sanitizes.name[2])
            URK.prompt(source, 'Age:', '', function(source,age)
              if age == '' then return end
              age = parseInt(age)
              if age >= 18 and age <= 150 then
                TriggerClientEvent('URK:gotNewIdentity', source, firstname, lastname, age)
              else
                URKclient.notify(source, {'~r~Invalid age'})
              end
            end)
          else
            URKclient.notify(source, {'~r~Invalid Last Name'})
          end
        end)
      else
        URKclient.notify(source, {'~r~Invalid First Name'})
      end
    end)
  end
end)

MySQL.createCommand("URK/set_identity","UPDATE urk_user_identities SET firstname = @firstname, name = @name, age = @age WHERE user_id = @user_id")


RegisterNetEvent("URK:ChangeIdentity")
AddEventHandler("URK:ChangeIdentity", function(first, second, age)
    local source = source
    local user_id = URK.getUserId(source)
    if user_id ~= nil then
        if URK.tryBankPayment(user_id,5000) then
            MySQL.execute("URK/set_identity", {user_id = user_id, firstname = first, name = second, age = age})
            URKclient.notifyPicture(source,{"CHAR_FACEBOOK",1,"GOV.UK",false,"You have purchased a new identity!"})
            TriggerClientEvent("urk:PlaySound", source, 1)
        else
            URKclient.notify(source,{"~r~You don't have enough money!"})
        end
    end
end)


RegisterServerEvent("URK:askId")
AddEventHandler("URK:askId", function(nplayer)
  local player = source
  local nuser_id = URK.getUserId(nplayer)
  if nuser_id ~= nil then
    URKclient.notify(player,{'~g~Request sent.'})
    URK.request(nplayer,"Do you want to give your ID card ?",15,function(nplayer,ok)
      if ok then
        URK.getUserIdentity(nuser_id, function(identity)
          if identity then
            TriggerClientEvent('URK:showIdentity', player, nplayer, true, identity.firstname, identity.name, '19/01/1990', identity.phone, '10/02/2015', '10/02/2025', {})
            TriggerClientEvent('URK:setNameFields', player, identity.name, identity.firstname)
            URK.request(player, "Hide the ID card.", 1000, function(player,ok)
              TriggerClientEvent('URK:hideIdentity', player)
            end)
          end
        end)
      else
        URKclient.notify(player,{"~r~Request refused."})
      end
    end)
  else
    URKclient.notify(player,{"~r~No player near you."})
  end
end)