RegisterNetEvent('f999:mod:deleteObject')
AddEventHandler('f999:mod:deleteObject', function(data)
    if not IsEntityAPed(data.entity) then
        TriggerServerEvent('f999:mod:server:deleteObject', data.entity)
    end
    print(json.encode(data, {indent = true}))
end)

local isPermitted = function()
    if DISCORD.CheckMembership({"ModerationTeam"}) then
        return true
    end
    return false
end


exports.ox_target:addGlobalObject({
    {name = 'Delete Object', label = 'MOD: Delete Object', event = 'f999:mod:deleteObject', icon = 'fa-shield', canInteract = isPermitted()}
})