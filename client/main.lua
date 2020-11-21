local Color = 255, 255, 255, 255
local status = "~g~Inactive"

RegisterNetEvent("Priority:updateStatus")
AddEventHandler("Priority:updateStatus", function(newStatus)
    status = newStatus
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        Text(Config.Color.."Priority Status: "..status.."", 4, 0.45, Config.DisplayX, Config.DisplayY)
    end
end)

function Text(content, font, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextProportional(0)
    SetTextColour(255,255,255,255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

RegisterNetEvent("Priority:Notify")
AddEventHandler("Priority:Notify", function(msg)
    notify(msg)
end)

function notify(string)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringKeyboardDisplay(string)
    EndTextCommandThefeedPostTicker(true, true)
end