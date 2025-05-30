
local state_ready = false

AddEventHandler("playerSpawned",function() -- delay state recording
  state_ready = false
  Citizen.CreateThread(function()
    Citizen.Wait(2000)
    state_ready = true
  end)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(3000)
    if IsPlayerPlaying(PlayerId()) and state_ready then
      URKserver.updateWeapons({tURK.getWeapons()})
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(60000)
    URKserver.UpdatePlayTime()
  end
end)

print("[Tutorial] Checking completed state")

local userdata = {}
Citizen.CreateThread(function()
    print("[URK] Loading cached user data.")
    userdata = json.decode(GetResourceKvpString("urk_userdata") or "{}")
    if type(userdata) ~= "table" then
      userdata = {}
        print("[URK] Loading cached user data - failed to load setting to default.")
    else
        print("[URK] Loading cached user data - loaded.")
    end
end)
function tURK.updateCustomization(b)
    local c = tURK.getCustomization()
    if c.modelhash ~= 0 and IsModelValid(c.modelhash) then
      userdata.customisation = c
      if b then
        SetResourceKvp("urk_userdata", json.encode(userdata))
      end
    end
end
function tURK.updateHealth(b)
  userdata.health = GetEntityHealth(PlayerPedId())
  if b then
      SetResourceKvp("urk_userdata", json.encode(userdata))
  end
end
function tURK.updateArmour(b)
  userdata.armour = GetPedArmour(PlayerPedId())
  if b then
      SetResourceKvp("urk_userdata", json.encode(userdata))
  end
end
local d = vector3(0.0, 0.0, 0.0)
function tURK.updatePos(b)
    local e = GetEntityCoords(PlayerPedId())
    if e.z > -150.0 and #(e - d) > 15.0 then
        userdata.position = e
        if b then
            SetResourceKvp("urk_userdata", json.encode(userdata))
        end
    end
end
Citizen.CreateThread(function()
    Wait(30000)
    while true do
        Wait(5000)
        if not tURK.isInHouse() and not inOrganHeist and not tURK.isPlayerInRedZone() and not tURK.isInSpectate() then
          tURK.updatePos()
        end
        if not tURK.isStaffedOn() and not customizationSaveDisabled and not spawning and not tURK.isPlayerInAnimalForm() then
            tURK.updateCustomization()
        end
        tURK.updateHealth()
        tURK.updateArmour()
        SetResourceKvp("urk_userdata", json.encode(userdata))
    end
end)

function tURK.checkCustomization()
    local c = userdata.customisation
    if c == nil or c.modelhash == 0 or not IsModelValid(c.modelhash) then
        tURK.setCustomization(getDefaultCustomization(), true, true)
    else
        tURK.setCustomization(c, true, true)
    end
end

function getDefaultCustomization()
  local s = {}
  s = {}
  s.model = "mp_m_freemode_01"
  for t = 0, 19 do
      s[t] = {0, 0}
  end
  s[0] = {0, 0}
  s[1] = {0, 0}
  s[2] = {47, 0}
  s[3] = {5, 0}
  s[4] = {4, 0}
  s[5] = {0, 0}
  s[6] = {7, 0}
  s[7] = {51, 0}
  s[8] = {0, 240}
  s[9] = {0, 1}
  s[10] = {0, 0}
  s[11] = {5, 0}
  s[12] = {4, 0}
  s[15] = {0, 2}
  return s
end

function tURK.spawnAnim(a)
  if a ~= nil then
    DoScreenFadeOut(250)
    ExecuteCommand("hideui")
    local g = userdata.position or vector3(178.5132598877, -1007.5575561523, 29.329647064209)
    Wait(500)
    TriggerScreenblurFadeIn(100.0)
    RequestCollisionAtCoord(g.x, g.y, g.z)
    NewLoadSceneStartSphere(g.x, g.y, g.z, 100.0, 2)
    SetEntityCoordsNoOffset(PlayerPedId(), g.x, g.y, g.z, true, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    local h = GetGameTimer()
    while (not HaveAllStreamingRequestsCompleted(PlayerPedId()) or GetNumberOfStreamingRequests() > 0) and
        GetGameTimer() - h < 10000 do
        Wait(0)
        print("[URK] Waiting for streaming requests to complete!")
    end
    NewLoadSceneStop()
    tURK.checkCustomization()
    TriggerServerEvent('URK:changeHairstyle')
    TriggerServerEvent('URK:getPlayerTattoos')
    TriggerEvent("URK:playGTAIntro")
    DoScreenFadeIn(1000)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    if not tURK.isDev() then
      SetFocusPosAndVel(g.x, g.y, g.z+1000)
      local spawnCam3 = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", g.x, g.y, g.z+1000, 0.0, 0.0, 0.0, 65.0, 0, 2)
      SetCamActive(spawnCam3, true)
      RenderScriptCams(true, true, 0, 1, 0)
      local spawnCam4 = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", g.x, g.y, g.z, 0.0, 0.0, 0.0, 65.0, 0, 2)
      SetCamActiveWithInterp(spawnCam4, spawnCam3, 5000, 0, 0)
      Wait(2500)
      ClearFocus()
      TriggerScreenblurFadeOut(2000.0)
      Wait(2000)
      DestroyCam(spawnCam3)
      DestroyCam(spawnCam4)
      RenderScriptCams(false, true, 2000, 0, 0)
    else
      TriggerScreenblurFadeOut(500.0)
    end
    print("[URK] cachedUserData.health", userdata.health)
    print("[URK] cachedUserData.armour", userdata.armour)
    SetEntityHealth(PlayerPedId(), userdata.health or 200)
    tURK.setArmour(userdata.armour)
    SetEntityVisible(PlayerPedId(), true, false)
    FreezeEntityPosition(PlayerPedId(), false)
    if not tURK.isDev() then
      Citizen.Wait(2000)
    end
    ExecuteCommand("showui")
  end
  spawning = false
end


AddEventHandler("URK:playGTAIntro",function()
  if not tURK.isDev() then
    TriggerEvent("urk:PlaySound", "gtaloadin")
  end
end)

RegisterNetEvent("URK:setHairstyle")
AddEventHandler("URK:setHairstyle",function(q)
  if q then
    dad = q["dad"] or 0
    mum = q["mum"] or 0
    skin = q["skin"] or 0
    dadmumpercent = q["dadmumpercent"] or 0
    eyecolor = q["eyecolor"] or 0
    acne = q["acne"] or 0
    skinproblem = q["skinproblem"] or 0
    freckle = q["freckle"] or 0
    wrinkle = q["wrinkle"] or 0
    wrinkleopacity = q["wrinkleopacity"] or 0
    hair = q["hair"] or 0
    haircolor = q["haircolor"] or 0
    eyebrow = q["eyebrow"] or 0
    eyebrowopacity = q["eyebrowopacity"] or 0
    beard = q["beard"] or 0
    beardopacity = q["beardopacity"] or 0
    beardcolor = q["beardcolor"] or 0
    eyeshadow = q["eyeshadow"] or 0
    lipstick = q["lipstick"] or 0
    eyeshadowcolour = q["eyeshadowcolour"] or 0
    lipstickcolour = q["lipstickcolour"] or 0
    facepaints = q["facepaints"] or 0
    facepaintscolour = q["facepaintscolour"] or 0
    SetPedHeadBlendData(GetPlayerPed(-1),dad,mum,0,skin,skin,skin,dadmumpercent,dadmumpercent,0.0,false)
    SetPedEyeColor(GetPlayerPed(-1), eyecolor)
    if acne == 0 then
        SetPedHeadOverlay(GetPlayerPed(-1), 0, acne, 0.0)
    else
        SetPedHeadOverlay(GetPlayerPed(-1), 0, acne, 1.0)
    end
    SetPedHeadOverlay(GetPlayerPed(-1), 6, skinproblem, 1.0)
    if freckle == 0 then
        SetPedHeadOverlay(GetPlayerPed(-1), 9, freckle, 0.0)
    else
        SetPedHeadOverlay(GetPlayerPed(-1), 9, freckle, 1.0)
    end
    SetPedHeadOverlay(GetPlayerPed(-1), 3, wrinkle, wrinkleopacity * 0.1)
    SetPedComponentVariation(GetPlayerPed(-1), 2, hair, 0, 2)
    SetPedHairColor(GetPlayerPed(-1), haircolor, haircolor)
    SetPedHeadOverlay(GetPlayerPed(-1), 2, eyebrow, eyebrowopacity * 0.1)
    SetPedHeadOverlay(GetPlayerPed(-1), 1, beard, beardopacity * 0.1)
    SetPedHeadOverlayColor(GetPlayerPed(-1), 1, 1, beardcolor, beardcolor)
    SetPedHeadOverlayColor(GetPlayerPed(-1), 2, 1, beardcolor, beardcolor)
    eyeShadowOpacity = 1.0
    if eyeshadow == 0 then
        eyeShadowOpacity = 0.0
    end
    lipstickOpacity = 1.0
    if lipstick == 0 then
        lipstickOpacity = 0.0
    end
    SetPedHeadOverlay(GetPlayerPed(-1), 4, eyeshadow, eyeShadowOpacity)
    SetPedHeadOverlay(GetPlayerPed(-1), 8, lipstick, lipstickOpacity)
    SetPedHeadOverlayColor(GetPlayerPed(-1), 4, 1, eyeshadowcolour, eyeshadowcolour)
    SetPedHeadOverlayColor(GetPlayerPed(-1), 8, 1, lipstickcolour, lipstickcolour)
    SetPedHeadOverlay(GetPlayerPed(-1), 4, facepaints, 1.0)
    SetPedHeadOverlayColor(GetPlayerPed(-1), 4, 1, facepaintscolour, 0)
  end
end)
