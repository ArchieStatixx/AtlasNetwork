--// Division Whitelist //--
local forcesAllowed = {'ckxjndhqo6328s41hoz23suew', 'cl549mv3q14740915n1htfucdzbz', 'ckxjndtbg6357s41hg98ty38w'}

--// Variables //--
local cuffing = false
local cuffed = false
local detaining = false
local detained = false
--// Force Check //--

local checkPermission = function()
    if SNAILY.CheckAnyDepartment(forcesAllowed) and not cuffing and not cuffed then
        return true
    end
    return false
end


--// Detain //--

RegisterNetEvent('f999:officer:detain')
AddEventHandler('f999:officer:detain', function(data)
    if not cuffing and not cuffed and not detaining and not detained then
        local formattedData = {["officerId"] = GetPlayerServerId(cache.playerId), ["suspect"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))}
        TriggerServerEvent('five999:sendRequest', formattedData, 'detainSuspect')
        detaining = true
        detained = formattedData.suspect
    elseif not cuffing and not cuffed and detaining and not detained then
        local formattedData = {["officerId"] = GetPlayerServerId(cache.playerId), ["suspect"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))}
        TriggerServerEvent('five999:sendRequest', formattedData, 'undetainSuspect')
        detaining = false
        detained = false
    end
end)

RegisterNetEvent('f999:suspect:detain')
AddEventHandler('f999:suspect:detain', function(command)
    if command == 'detain' then
        if not detained and not cuffed then
            lib.requestAnimDict('mp_arrest_paired')
            SetEnableHandcuffs(cache.ped, true)
            TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false) 
            exports.ox_target:disableTargeting(true)
            detained = true
        end
    elseif command == 'undetain' then
        if detained and not cuffed then
            ClearPedTasks(cache.ped)
            exports.ox_target:disableTargeting(false)
            SetEnableHandcuffs(cache.ped, false)
            detained = false
        end
    end
end)

--// Cuff //--

RegisterNetEvent('f999:officer:cuff')
AddEventHandler('f999:officer:cuff', function(data)
    if not cuffing and not cuffed and not detained then
        cuffing = true
        local formattedData = {["officerId"] = GetPlayerServerId(cache.playerId), ["suspect"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))}
        TriggerServerEvent('five999:sendRequest', formattedData, 'cuffSuspect')
        cuffed = formattedData.suspect
        lib.requestAnimDict("mp_arrest_paired")
        lib.requestAnimDict("mp_arresting")
        TaskPlayAnim(cache.ped, "mp_arrest_paired", "cop_p2_back_right", 8.0, -8.0, 3750, 2, 0, 0, 0, 0)
    elseif cuffing and not cuffed and not detained then
        cuffing = false
        cuffed = false
        local formattedData = {["officerId"] = GetPlayerServerId(cache.playerId), ["suspect"] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))}
        TriggerServerEvent('five999:sendRequest', formattedData, 'uncuffSuspect')
    end
end)

--// ox_target //--
exports.ox_target:addGlobalPlayer({
    {name = 'Detain', event = 'five999:detain:officer', label = 'Detain Ped',icon = 'fa-solid fa-handcuffs'}
})
