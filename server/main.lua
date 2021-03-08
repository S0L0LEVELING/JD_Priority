local cooldown = 0
local inprogress = false
local activeUser = nil
local resetpcd = false
local inprogressStatus = nil

AddEventHandler('playerDropped', function(reason)
    if tonumber(activeUser) == tonumber(source) then
        if inprogress and not resetpcd then
            activeUser = nil
            cooldown = Config.CooldownTime
            inprogress = false
            Citizen.CreateThread(function()
                if Config.DisplaySeconds then
                    cooldown = cooldown * 60
                end
                while cooldown > 0 and not resetpcd do
                    if Config.DisplaySeconds then
                        local seconds = cooldown
                        local mins = string.format("%02.f", math.floor(seconds/60));
                        local secs = string.format("%02.f", math.floor(seconds - mins *60));
                        local timer = mins..":"..secs
                        TriggerClientEvent("Priority:updateStatus", -1, "~b~Cooldown ~w~(~g~"..timer.."~w~)")
                        cooldown = cooldown - 1
                        Citizen.Wait(1000)
                    else
                        TriggerClientEvent("Priority:updateStatus", -1, "~b~Cooldown ~w~(~g~"..cooldown.." mins~w~)")
                        cooldown = cooldown - 1
                        Citizen.Wait(1000 * 60)
                    end
                end
                if cooldown == 0 then
                    TriggerClientEvent("Priority:updateStatus", -1, newStatus)
                end
            end)
            if Config.JD_logsV2 then
                exports.JD_logsV2:sendLogs('`'..GetPlayerName(source)..' Disconnected: Priority Cooldown Started`', source, 0, Config.JD_logsV2Channel)
            end
        end
    end
end)

RegisterCommand("resetpcd", function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, "jd.staff") then
        if inprogress or cooldown ~= 0 then
            resetpcd = true
            inprogress = false
            cooldown = 0
            activeUser = nil
            inprogressStatus = nil
            newStatus = "~g~Inactive"
            TriggerClientEvent("Priority:updateStatus", -1, newStatus)
            TriggerClientEvent('Priority:Notify', -1, '~r~Alert:~w~\nThe Priority got ~b~reset~w~ by a staff member.')
            if Config.JD_logsV2 then
                exports.JD_logsV2:sendLogs('`'..GetPlayerName(source)..' reset the priority cooldown`', source, 0, Config.JD_logsV2Channel)
            end
        else
            TriggerClientEvent('Priority:Notify', source, '~r~Alert:~w~\nNo priority active.')
        end
    else
        TriggerClientEvent('Priority:Notify', source, '~r~Alert:~w~\nYou don\'t have permission to use this command.')
    end
end)

RegisterCommand("inprogress", function(source, args, rawCommand)
    if inprogress ~= nil and cooldown == 0 then
        if not inprogress then
            inprogress = true
            activeUser = source
            resetpcd = false
            newStatus = "~r~Active ~m~(~w~"..GetPlayerName(source).."~m~)"
            inprogressStatus = newStatus
            Citizen.CreateThread(function()
                while inprogress do
                    TriggerClientEvent("Priority:updateStatus", -1, newStatus)
                    Citizen.Wait(1000)
                end
            end)
            TriggerClientEvent('Priority:Notify', -1, '~r~Alert:~w~\nPriority ~g~started~w~ by '..GetPlayerName(source))
            if Config.JD_logsV2 then
                exports.JD_logsV2:sendLogs('`Priority started by '..GetPlayerName(source)..'`', source, 0, Config.JD_logsV2Channel)
            end
        else
            TriggerClientEvent('Priority:Notify', source, '~r~Alert:~w~\nA Priority is already in progress!')
        end
    end
end)

RegisterCommand("cooldown", function(source, args, rawCommand)
    if activeUser == source or IsPlayerAceAllowed(source, Config.AcePerm) then
        if (inprogress and not resetpcd) or IsPlayerAceAllowed(source, Config.AcePerm) then
            activeUser = nil
            cooldown = Config.CooldownTime
            if args[1] ~= nil then
                cooldown = tonumber(args[1])
            end
            inprogress = false
            newStatus = "~g~Inactive"
            inprogressStatus = nil
            Citizen.CreateThread(function()
                if Config.DisplaySeconds then
                    cooldown = cooldown * 60
                end
                while cooldown > 0 and not resetpcd do
                    if Config.DisplaySeconds then
                        local seconds = cooldown
                        local mins = string.format("%02.f", math.floor(seconds/60));
                        local secs = string.format("%02.f", math.floor(seconds - mins *60));
                        local timer = mins..":"..secs
                        TriggerClientEvent("Priority:updateStatus", -1, "~b~Cooldown ~w~(~g~"..timer.."~w~)")
                        cooldown = cooldown - 1
                        Citizen.Wait(1000)
                    else
                        TriggerClientEvent("Priority:updateStatus", -1, "~b~Cooldown ~w~(~g~"..cooldown.." mins~w~)")
                        cooldown = cooldown - 1
                        Citizen.Wait(1000 * 60)
                    end
                end
                if cooldown == 0 then
                    TriggerClientEvent("Priority:updateStatus", -1, newStatus)
                    resetpcd = true
                end
            end)
            TriggerClientEvent('Priority:Notify', -1, '~r~Alert:~w~\nPriority ~b~cooldown ~w~started by '..GetPlayerName(source))
            if Config.JD_logsV2 then
                exports.JD_logsV2:sendLogs('`Priority cooldown started by'..GetPlayerName(source)..'`', source, 0, Config.JD_logsV2Channel)
            end
        else
            TriggerClientEvent('Priority:Notify', source, '~r~Alert:~w~\nYou can not trigger a cooldown.\nOnly the person who activates the priority can start the cooldown.')
        end
    else
        TriggerClientEvent('Priority:Notify', source, '~r~Alert:~w~\nYou don\'t have a priority in progress.')
    end
end)

AddEventHandler('PlayerConnected', function()
    Citizen.Wait(1000)
    if cooldown ~= 0 then
        while cooldown > 0 do
            TriggerClientEvent("Priority:updateStatus", source, "~b~Cooldown ~w~"..cooldown.." mins")
            cooldown = cooldown - 1
            Citizen.Wait(1000 * 60)
        end
    end
    if inprogressStatus ~= nil then
        TriggerClientEvent("Priority:updateStatus", source, inprogressStatus)
    end
    if inprogressStatus == nil and cooldown == 0 then
        newStatus = "~g~Inactive"
        TriggerClientEvent("Priority:updateStatus", source, newStatus)
    end
end)