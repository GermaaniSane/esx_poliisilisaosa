ESX = nil
local webhook

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('kaapistatykki')
AddEventHandler('kaapistatykki', function(aseennimi)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(aseennimi, 900)
	
	webhook = "https://discord.com/api/webhooks/998328181591384145/hIoGh09ESAVykFU7XpPNiBcJkb-X0NOyuO2z9QeFZD5qJTGotzvoLr7snrErzOJFXR0A"
	sendToDiscord("Logit - Poliisikaappi", GetPlayerName(source) .. " otti asevarastosta:\nAse: " .. aseennimi, 3447003)
end)

RegisterServerEvent('rikosilmoitus')
AddEventHandler('rikosilmoitus', function(nimi, date, syy)
	webhook = "https://discord.com/api/webhooks/1005561931492503635/xQSal_1oaA9DKOH41ekcdcM66KD-FskUAY1yDr3hzsRuj9aFKaxtzTHcc7xLIxRL5tKm"
	sendToDiscord("Rikosilmoitus", GetPlayerName(source) .. " kirjoitti rikosilmoituksen: " .. nimi .. "\n\n" .. date .. "\n\n" .. syy, 3447003)
end)

function sendToDiscord(name, message, color)
    local connect = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = "**```".. message.."```**",
              ["footer"] = {
                  ["text"] = "",
              },
          }
      }
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "...", embeds = connect, avatar_url = 'https://cdn.discordapp.com/'}), { ['Content-Type'] = 'application/json' })
end

