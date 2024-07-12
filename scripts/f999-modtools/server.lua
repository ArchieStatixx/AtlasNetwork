RegisterServerEvent('f999:mod:server:deleteObject')

AddEventHandler('f999:mod:server:deleteObject', function(entity)
    DeleteEntity(entity)
end)