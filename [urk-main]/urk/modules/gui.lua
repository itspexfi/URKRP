local Tools = module("lib/Tools")

local cfg = module("cfg/gui")

-- MENU

local menu_ids = Tools.newIDGenerator()
local client_menus = {}
local rclient_menus = {}

-- open dynamic menu to client
-- menudef: .name and choices as key/{callback,description} (optional element html description) 
-- menudef optional: .css{ .top, .header_color }
function URK.openMenu(source,menudef)
  local menudata = {}
  menudata.choices = {}

  -- send menudata to client
  -- choices
  for k,v in pairs(menudef) do
    if k ~= "name" and k ~= "onclose" and k ~= "css" then
      table.insert(menudata.choices,{k,v[2]})
    end
  end

  -- sort choices per entry name
  table.sort(menudata.choices, function(a,b)
    return string.upper(a[1]) < string.upper(b[1])
  end)
  
  -- name
  menudata.name = menudef.name or "Menu"
  menudata.css = menudef.css or {}

  -- set new id
  menudata.id = menu_ids:gen() 

  -- add client menu
  client_menus[menudata.id] = {def = menudef, source = source}
  rclient_menus[source] = menudata.id

  -- openmenu
  URKclient.openMenuData(source,{menudata})
end

-- force close player menu
function URK.closeMenu(source)
  URKclient.closeMenu(source,{})
end

-- PROMPT

local prompts = {}

-- prompt textual (and multiline) information from player
function URK.prompt(source,title,default_text,cb_result)
  prompts[source] = cb_result

  URKclient.prompt(source,{title,default_text})
end

-- REQUEST

local request_ids = Tools.newIDGenerator()
local requests = {}

-- ask something to a player with a limited amount of time to answer (yes|no request)
-- time: request duration in seconds
-- cb_ok: function(player,ok)
function URK.request(source,text,time,cb_ok)
  local id = request_ids:gen()
  local request = {source = source, cb_ok = cb_ok, done = false}
  requests[id] = request

  URKclient.request(source,{id,text,time}) -- send request to client

  -- end request with a timeout if not already ended
  SetTimeout(time*1000,function()
    if not request.done then
      request.cb_ok(source,false) -- negative response
      request_ids:free(id)
      requests[id] = nil
    end
  end)
end


-- GENERIC MENU BUILDER

local menu_builders = {}

-- register a menu builder function
--- name: menu type name
--- builder(add_choices, data) (callback, with custom data table)
---- add_choices(choices) (callback to call once to add the built choices to the menu)
function URK.registerMenuBuilder(name, builder)
  local mbuilders = menu_builders[name]
  if not mbuilders then
    mbuilders = {}
    menu_builders[name] = mbuilders
  end

  table.insert(mbuilders, builder)
end

-- build a menu
--- name: menu name type
--- data: custom data table
-- cbreturn built choices
function URK.buildMenu(name, data, cbr)
  -- the task will return the built choices even if they aren't complete
  local choices = {}
  local task = Task(cbr, {choices})

  local mbuilders = menu_builders[name]
  if mbuilders then
    local count = #mbuilders

    for k,v in pairs(mbuilders) do -- trigger builders
      -- get back the built choices
      local done = false
      local function add_choices(bchoices)
        if not done then -- prevent a builder to add things more than once
          done = true

          if bchoices then
            for k,v in pairs(bchoices) do
              choices[k] = v
            end
          end

          count = count-1
          if count == 0 then -- end of build
            task({choices})
          end
        end
      end

      v(add_choices, data) -- trigger
    end
  else
    task()
  end
end

-- MAIN MENU

-- open the player main menu
function URK.openMainMenu(source)
  URK.buildMenu("main", {player = source}, function(menudata)
    menudata.name = "Main menu"
    menudata.css = {top="75px",header_color="rgba(0,125,255,0.75)"}
    URK.openMenu(source,menudata) -- open the generated menu
  end)
end

-- SERVER TUNNEL API

function tURK.closeMenu(id)
  local menu = client_menus[id]
  if menu and menu.source == source then

    -- call callback
    if menu.def.onclose then
      menu.def.onclose(source)
    end

    menu_ids:free(id)
    client_menus[id] = nil
    rclient_menus[source] = nil
  end
end

function tURK.validMenuChoice(id,choice,mod)
  local menu = client_menus[id]
  if menu and menu.source == source then
    -- call choice callback
    local ch = menu.def[choice]
    if ch then
      local cb = ch[1]
      if cb then
        cb(source,choice,mod)
      end
    end
  end
end

-- receive prompt result
function tURK.promptResult(text)
  if text == nil then
    text = ""
  end

  local prompt = prompts[source]
  if prompt ~= nil then
    prompts[source] = nil
    prompt(source,text)
  end
end

-- receive request result
function tURK.requestResult(id,ok)
  local request = requests[id]
  if request and request.source == source then -- end request
    request.done = true -- set done, the timeout will not call the callback a second time
    request.cb_ok(source,not not ok) -- callback
    request_ids:free(id)
    requests[id] = nil
  end
end

-- open the general player menu
function tURK.openMainMenu()
  URK.openMainMenu(source)
end


-- STATIC MENUS
local static_menu_choices = {}

-- define choices to a static menu by name
function URK.addStaticMenuChoices(name, choices)
  local mchoices = static_menu_choices[name]
  if mchoices == nil then
    static_menu_choices[name] = {}
    mchoices = static_menu_choices[name]
  end

  for k,v in pairs(choices) do
    mchoices[k] = v
  end
end

-- build static menus
local static_menus = {}
SetTimeout(10000,function() -- wait for URK.addStaticMenuChoices calls
  for k,v in pairs(cfg.static_menu_types) do
    local menu = {name=v.title, css={top="75px",header_color="rgba(255,226,0,0.75)"}}
    local choices = static_menu_choices[k] or {}

    for l,w in pairs(choices) do
      menu[l] = w
    end

    static_menus[k] = menu
  end
end)

local function build_client_static_menus(source)

end

-- events
AddEventHandler("URK:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    -- load additional css using the div api
    URKclient.setDiv(source,{"additional_css",".div_additional_css{ display: none; }\n\n"..cfg.css,""})

    -- load static menus
    build_client_static_menus(source)
  end
end)

AddEventHandler("URK:playerLeave", function(user_id, source)
  -- force close opened menu on leave
  local id = rclient_menus[source]
  if id ~= nil then
    local menu = client_menus[id]
    if menu and menu.source == source then
      -- call callback
      if menu.def.onclose then
        menu.def.onclose(source)
      end

      menu_ids:free(id)
      client_menus[id] = nil
      rclient_menus[source] = nil
    end
  end
end)
