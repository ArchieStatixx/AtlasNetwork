-- // Net Events //--
RegisterServerEvent('five999:attachEntity')
RegisterServerEvent('five999:tackle:server')
-- // Event Handling //--

AddEventHandler('five999:attachEntity', function(data, command)

    if command == 'drag' then
        if data.grabbingStatus == "yes" then
            TriggerClientEvent('five999:entityHandle', data.userId, data, 'attach')
        elseif data.grabbingStatus == "no" then
            TriggerClientEvent('five999:entityHandle', data.userId, data, 'de-attach')
        end
    elseif command == 'carry' then
            if data.carryStatus == "yes" then
                TriggerClientEvent('five999:entityHandle', data.userId, data, 'carry') 
            elseif data.carryStatus == "no" then
                TriggerClientEvent('five999:entityHandle', data.userId, data, 'de-attach')
            end
    end
end)

AddEventHandler('five999:tackle:server', function(data)
        TriggerClientEvent('five999:tackle:client', data.playerGettingTackled, data)
end)