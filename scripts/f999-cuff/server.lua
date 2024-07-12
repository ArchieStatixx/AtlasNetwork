--// Net Events //--
RegisterServerEvent('five999:sendRequest')

--// Event Handling //--

AddEventHandler('five999:sendRequest', function (data,command)
    if command == 'detainSuspect' then
        TriggerClientEvent('five999:cuff:suspect', data.suspect, 'detain')
    elseif command == 'undetainSuspect' then
        TriggerClientEvent('five999:cuff:suspect', data.suspect, 'undetain')
    end
end)