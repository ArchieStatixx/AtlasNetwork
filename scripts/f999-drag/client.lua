local dragging = false
local carrying = false
local forcesAllowed = {'ckxjndhqo6328s41hoz23suew', 'cl549mv3q14740915n1htfucdzbz', 'ckxjndtbg6357s41hg98ty38w'}

-- // Keybinds //--

local tackleKeybind = lib.addKeybind({
    name = 'tackle',
    description = 'Tackle the closest ped...',
    defaultKey = 'X',
    onReleased = function()
        if IsControlPressed(0, 21) then
            local _,ped,_ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 1, false)
            if ped then
                local data = {["officerId"] = cache.serverId,["playerGettingTackled"] =  GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))}
                TriggerServerEvent('five999:tackle:server', data)
                lib.entity.animation(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_goon', {blendInSpeed = 8.0, blendOutSpeed = -8.0, duration = 3000, flag = 0, playbackRate = 0})        
            end
        end
    end
})


local keybind = lib.addKeybind({
    name = 'grabControl',
    description = 'E to stop grabbing',
    defaultKey = 'E',
    onReleased = function(self)
        if dragging then
            local data = {["userId"] = dragging, ["grabbingStatus"] = "no"}
            TriggerServerEvent('five999:attachEntity', data, "drag")
            lib.hideTextUI()
            dragging = false
            ClearPedTasks(cache.ped)
            tackleKeybind:disable(false)

        elseif carrying then
            local data = {["userId"] = carrying, ["carryStatus"] = "no"}
            TriggerServerEvent('five999:attachEntity', data, "carry")
            lib.hideTextUI()
            carrying = false 
            ClearPedTasks(cache.ped)
            tackleKeybind:disable(false)

        end
    end
})


--// Tackle Functions //--

RegisterNetEvent('five999:tackle:client')
AddEventHandler('five999:tackle:client', function(data)
        lib.entity.animation(cache.ped, 'missmic2ig_11', 'mic_2_ig_11_intro_p_one', {blendInSpeed = 8.0, blendOutSpeed = -8.0, duration = 3000, flag = 0, playbackRate = 0})        
        AttachEntityToEntity(cache.ped, GetPlayerPed(GetPlayerFromServerId(data.officerId)), 11816, 0.25, 0.5, 0.0, 0.5, 0.5, 180.0, false, false, false, false, 2, false) 
        tackleKeybind:disable(true)
        Citizen.Wait(3000)
        DetachEntity(cache.ped)
        tackleKeybind:disable(false)
end)



-- // Event Handling //--
RegisterNetEvent('five999:grab')
AddEventHandler('five999:grab', function(data)
        local formattedData = {["officerId"] = cache.serverId, ["userId"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), ["grabbingStatus"] = "yes"}
        TriggerServerEvent('five999:attachEntity', formattedData, 'drag')
        dragging = formattedData["userId"]
        lib.showTextUI('[E] - Stop Dragging')
        lib.entity.animation(cache.ped, "amb@world_human_drinking@coffee@male@base", "base", {blendInSpeed = 8.0, blendOutSpeed = -8.0, duration = -1, flag = 51, playbackRate = 0})        
        tackleKeybind:disable(true)
    end)



RegisterNetEvent('five999:carry')
AddEventHandler('five999:carry', function(data)
        local data = {
            ["officerId"] = cache.serverId,
            ["userId"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)),
            ["carryStatus"] = "yes"
        }
        TriggerServerEvent('five999:attachEntity', data, 'carry')

        carrying = data["userId"]
        lib.showTextUI('[E] - Stop Carrying')
        lib.entity.animation(cache.ped, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", {blendInSpeed = 8.0, blendOutSpeed = -8.0, duration = 100000, flag = 49, playbackRate = 0})        
        tackleKeybind:disable(true)
    end)


RegisterNetEvent('five999:entityHandle')
AddEventHandler('five999:entityHandle', function(data, value)
    if value == 'attach' then 
        local officer = GetPlayerPed(GetPlayerFromServerId(data.officerId))
        if DoesEntityExist(officer) then
            AttachEntityToEntity(cache.ped, officer, 11816, 0.2, 0.4, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true) -- TODO: Bug report to be resolved.
            tackleKeybind:disable(true)
        end
        elseif value == 'de-attach' then
        DetachEntity(cache.ped, false, true)
        ClearPedTasks(cache.ped)
        tackleKeybind:disable(false)
    elseif value == 'carry' then
            lib.entity.animation(cache.ped, "nm", "firemans_carry", {blendInSpeed = 8.0, blendOutSpeed = -8.0, duration = 100000, flag = 33, playbackRate = 0})        
            AttachEntityToEntity(cache.ped, GetPlayerPed(GetPlayerFromServerId(data.officerId)), 0, 0.27, 0.15, 0.63, 0.5, 0.5, 180, false, false, false, false, 2, false)
            tackleKeybind:disable(true)

        end
end)





--// Handlers //-- 

local interaction = function()
    if SNAILY.CheckAnyDepartment(forcesAllowed) and not dragging and not carrying then
        return true
    end
    return false
end






-- // ox_target //--
exports.ox_target:addGlobalPlayer({
    {name = 'Grab', event = 'five999:grab', label = 'Grab User', icon = 'fa-solid fa-male', canInteract = interaction()},
    {name = 'Carry', event = 'five999:carry', label = 'Carry User',icon = 'fa-solid fa-male',canInteract = interaction()}
})



