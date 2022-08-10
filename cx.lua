
ESX = nil
local aikaaselata = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

--//-- ASEKAAPPI --\\--

local teksti
AddEventHandler('otaase:hasEnteredMarker', function(station, part, partNum)
	if part == 'Armory2' then
		CurrentAction     = 'menu_Armory2'
		teksti = "Paina ~b~[~w~E~b~]~w~ avataksesi asekaappi"
		CurrentActionData = {station = station}
	end
end)

AddEventHandler('otaase:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local isInMarker, hasExited, letSleep = false, false, true
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.neekeri) do

				for i=1, #v.Armories2, 1 do
					local distance = #(playerCoords - v.Armories2[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType, v.Armories2[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.7, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						letSleep = false

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory2', i
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('otaase:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('otaase:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('otaase:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end

			if letSleep then
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction then

			local pc = GetEntityCoords(PlayerPedId())
			Draw3DText(GetEntityCoords(PlayerPedId()), 'Paine [E] avataksesi asekaapin', 0.35)

			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then

				if CurrentAction == 'menu_Armory2' then
					aseidenselaus()
				end

				CurrentAction = nil
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		if aikaaselata > 0 then
			aikaaselata = aikaaselata - 1
			ESX.ShowNotification("Sinulla on " .. aikaaselata .. " minuuttia aikaa ottaa aseita!")
		end
		Citizen.Wait(60000)
	end
end)
local asekaappi22 = vector3(484.93002319336, -999.09857177734, 29.709800262451)
function aseidenselaus()
	
	aikaaselata = 2
	ESX.ShowNotification("/asekaappi - Valitse aseet jotka otat.")
	ESX.ShowNotification("Sinulla on " .. aikaaselata .. " minuuttia aikaa ottaa aseita!")

	Citizen.CreateThread(function()
		while aikaaselata > 0 do
			Citizen.Wait(0)
			local pelaajanposi = GetEntityCoords(PlayerPedId())
			local distance = #(pelaajanposi - asekaappi22)
			if distance < 7 then
				teksti = "[~b~/asekaappi~w~]~w~"
				ESX.Text3D(485.41763305664, -995.24633789062, 31.209800262451, "Carbine Rifle\n~b~Numero: 1")
				ESX.Text3D(482.57699584961, -995.18756103516, 31.289800262451, "Pistooli\n~b~Numero: 2")
				ESX.Text3D(482.87744140625, -995.19848632812, 30.8098021698, "Teiseri\n~b~Numero: 3")
				ESX.Text3D(482.5576171875, -995.26531982422, 30.1298021698, "Haulikko\n~b~Numero: 4")
				ESX.Text3D(480.54626464844, -995.23004150391, 30.7098021698, "Taskulamppu\n~b~Numero: 5")
				ESX.Text3D(481.45413208008, -995.25738525391, 30.7098021698, "SMG\n~b~Numero: 6")
			end

			if distance > 10 then
				aikaaselata = 0
			end
		end
	end)
end

function Kirjoitus(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

RegisterCommand("asekaappi", function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
		if aikaaselata > 0 then
			local nekru = Kirjoitus("Mikä on aseen tunnusluku?", "", 1)
			local ase22
			if nekru == nil then
				ESX.ShowNotification("Tämä ase ei ole saatavilla!")
			elseif nekru == "1" then
				ase22 = "WEAPON_CARBINERIFLE"
			elseif nekru == "2" then
				ase22 = "WEAPON_COMBATPISTOL"
			elseif nekru == "3" then
				ase22 = "WEAPON_STUNGUN"
			elseif nekru == "4" then
				ase22 = "WEAPON_PUMPSHOTGUN"
			elseif nekru == "5" then
				ase22 = "WEAPON_FLASHLIGHT"
			elseif nekru == "6" then
				ase22 = "WEAPON_SMG"
			end
			TriggerServerEvent('kaapistatykki', ase22)
		else
			ESX.ShowNotification("Et voi ottaa aseita nyt!", 'error')
		end
	else
		ESX.ShowNotification("Et ole poliisi!", 'error')
	end
end)

--//-- LOPPU --\\--

--//-- ASEEN TÄYTTÖ --\\--

local aseentaytto = {
	{pos = vector3(487.31903076172, -996.99639892578, 29.709807891846), heading = 268.99}
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _,v in pairs(aseentaytto) do
			local pelaaja = PlayerPedId()
			local pc = GetEntityCoords(pelaaja)
			local distance = #(pc - v.pos)
			if distance < 20.0 then
				DrawMarker(Config.MarkerType, v.pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.3, 1.3, 0.7, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
			end

			if distance < 1.3 then
				ESX.Text3D(pc.x, pc.y, pc.z - 0.25, "Paina ~b~[~w~E~b~]~w~ täyttääksesi ase")
				if IsControlJustPressed(0, ESX.Keys["E"]) then
					ExecuteCommand('e uncuff')
					ped = GetPlayerPed(-1)
					if IsPedArmed(ped, 4) then
					  ukonase = GetSelectedPedWeapon(ped)
					  if ukonase ~= nil then
						SetEntityHeading(pelaaja, v.heading)
						TriggerEvent("mythic_progbar:client:progress", {
							name = "unique_action_name",
							duration = 6000,
							label = "Täytetään asetta...",
							command = "e dj",
							useWhileDead = false,
							canCancel = false,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							}
						}, function(status)
							if not status then	
								AddAmmoToPed(GetPlayerPed(-1), ukonase, 900)
								ESX.ShowNotification("Aseesi on täytetty")
							end
						end)
					  else
						ESX.ShowNotification("Ota ase käteen täyttääksesi", 'error')
					  end
					else
					  ESX.ShowNotification("Ethän sä tätä voi täyttää!", 'error')
					end
				end
			end
		end
	end
end)

--//-- LOPPU --\\--

--//-- RIKOSILMOITUS --\\--

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local pc = GetEntityCoords(PlayerPedId())
		local painae = vector3(441.31042480469, -981.79205322266, 29.709563751221)
		local matka = #(pc - painae)
		if matka < 3 then
			DrawMarker(27, painae.x, painae.y, painae.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.7, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
		end
		if matka < 1.3 then
			Draw3DText(GetEntityCoords(PlayerPedId()), 'Paina [E] tehdäksesi rikosilmoituksen', 0.35)
			if IsControlJustReleased(0, ESX.Keys["E"]) then
				local nimi = Kirjoitus("Rikosilmoitus", "Kirjoittajan nimi: ", 50)
				local paivamaara  = Kirjoitus("Rikosilmoitus", "Päivämäärä: ", 50)
				local syy  = Kirjoitus("Rikosilmoitus", "Miksi teet rikosilmoituksen: ", 950)
				TriggerServerEvent('rikosilmoitus', nimi, paivamaara, syy)
				ESX.ShowNotification("Kiitos ilmoituksesta!")
			end
		end
	end
end)



function Kirjoitus(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry("FMMC_KEY_TIP1", TextEntry .. ":")
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

--//-- LOPPU --\\--

--//-- KAHVI AUTOMAATIT ASEMALLA --\\--

local kahvikoneet = {
	{pos = vector3(439.42797851562, -978.63842773438, 29.709584732056), heading = 2.44},
	{pos = vector3(446.89633178711, -973.65393066406, 33.990294952393), heading = 358.79},
	{pos = vector3(460.1799621582, -982.31280517578, 29.709872741699), heading = 181.58},
	{pos = vector3(469.57583618164, -996.73675537109, 25.293677825928), heading = 270.84},
	{pos = vector3(-1433.8208007812, -450.15060424805, 34.929698486328), heading = 120.46} -- LISÄÄ JOS HALUAT
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		for _,v in pairs(kahvikoneet) do
			local pelaaja = PlayerPedId()
			local pc = GetEntityCoords(pelaaja)
			local distance = #(pc - v.pos)

			if distance < 1.3 then
				Draw3DText(GetEntityCoords(PlayerPedId()), 'Paina [E] ottaaksesi kahvia', 0.35)
				if IsControlJustPressed(0, ESX.Keys["E"]) then
					ExecuteCommand('e pickup')
					SetEntityCoords(pelaaja, v.pos)
					SetEntityHeading(pelaaja, v.heading)
					TriggerEvent("mythic_progbar:client:progress", {
						name = "unique_action_name",
						duration = 1100,
						label = "Otetaan kahvia...",
						command = "e pickup",
						useWhileDead = false,
						canCancel = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						}
					}, function(status)
						if not status then	
							ExecuteCommand("e coffee")
						end
					end)
				end
			end
		end
	end
end)

--//-- 3D Texti --\\--

function Draw3DText(coords, text, scale)
	local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z+0.5)
    SetTextScale(0.35, 0.35)
    SetTextOutline()
    SetTextDropShadow()
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry('STRING')
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
	DrawText(x, y)
	local factor = (string.len(text)) / 400
	DrawRect(x, y+0.012, 0.015+ factor, 0.03, 41, 11, 41, 68)
  end
  

--//-- LOPPU KAIKKI --\\--

