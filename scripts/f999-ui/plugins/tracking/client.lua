if not lib then return end

local Tracking = {}

Tracking.PlayerBlips = {}
function Tracking.ClearBlip(serverId)
    if DoesBlipExist(Tracking.PlayerBlips[serverId].blipId) then
        RemoveBlip(Tracking.PlayerBlips[serverId].blipId)
    end
    Tracking.PlayerBlips[serverId] = nil
end

function Tracking.CreateBlip(serverId, details)
    -- Don't create blips if the local player is running as civilian.
    if LocalPlayer.state.force == "CIV" then return false end
    -- If the player has visibility disabled then do not apply or create unless the activeModerator state is set to true
    if details.visible and not LocalPlayer.state.activeModerator then return false end
    -- Return false if the user is the source
    if tonumber(cache.serverId) == tonumber(serverId) then return false end
    -- If the player is not in the same bucket as the source do not apply blips
    if tonumber(details.bucket) ~= tonumber(LocalPlayer.state.playerLocations[tostring(cache.serverId)].bucket) then return false end
    if not details.blipFormat then details.blipFormat = {} end
    -- We pass the blipFormat through without the other details so we need map the name of the user to the title of the blip and set its category
    details.blipFormat.title = details.name
    details.blipFormat.category = 7
    -- If there is an existing blip for this player, update it
    if Tracking.PlayerBlips[serverId] then
        if DoesBlipExist(Tracking.PlayerBlips[serverId].blipId) then
            SetBlipCoords(Tracking.PlayerBlips[serverId].blipId, details.coords.x, details.coords.y, details.coords.z)
            UX.FormatBlip(Tracking.PlayerBlips[serverId].blipId, details.blipFormat)
            return true
        end
    end
    -- Create a new blip for the player
    local blip = AddBlipForCoord(details.coords.x, details.coords.y, details.coords.z)
    UX.FormatBlip(blip, details.blipFormat)
    Tracking.PlayerBlips[serverId] = { blipId = blip }
    return true
end

function Tracking.UpdateRadial()
    local items = {}
    if DISCORD.CheckAnyMembership({"ModerationTeam"}) then
        items =
        {
            {
                label = LocalPlayer.state.hidden and "Show" or "Hide",
                icon = 'user-shield',
                onSelect = function()
                    LocalPlayer.state:set("activeModerator", not LocalPlayer.state.activeModerator, true)
                    LocalPlayer.state:set("hidden", not LocalPlayer.state.hidden, true)
                    lib.notify({
                        description = string.format('You are now set to %s.', LocalPlayer.state.hidden and "hidden" or "visible"),
                        type = LocalPlayer.state.hidden and "success" or "warning"
                    })
                    Tracking.UpdateRadial()
                end
            }
        }
    end
    lib.registerRadial({
        id = 'settingsMenu',
        items = items
    })
end

Tracking.UpdateRadial()

-- Check through all player locations and create a blip if the conditions are met, if not remove any blip from the table.
Citizen.CreateThread(function()
    while true do
        for serverId, details in pairs(LocalPlayer.state.playerLocations) do
            if not Tracking.CreateBlip(serverId, details) then
                Tracking.ClearBlip(serverId)
            end
        end
        Citizen.Wait(1000)
    end
end)

-- Remove blips from the localised table if the player no longer exists in the location table.
Citizen.CreateThread(function()
    while true do
        for serverId, _ in pairs(Tracking.PlayerBlips) do
            if not LocalPlayer.state.playerLocations[serverId] then
                Tracking.ClearBlip(serverId)
            end
        end
        Citizen.Wait(500)
    end
end)

-- When tracking is enabled, set the route every 1 second to account for positional changes.
Citizen.CreateThread(function()
    while true do
        if LocalPlayer.state.trackingId then
            SetBlipRoute(Tracking.PlayerBlips[LocalPlayer.state.trackingId].blipId, true)
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('f999:ui:tracking')
AddEventHandler('f999:ui:tracking', function()
    local options = {}
    for serverId, details in pairs(LocalPlayer.state.playerLocations) do
        if not details.visible and tonumber(cache.serverId) ~= tonumber(serverId) then
            table.insert(options, { value = serverId, label = details.name })
        end
    end
    if not LocalPlayer.state.trackingId then
        if #options > 0 then
            local serverId = lib.inputDialog('Vehicle & Radio Tracking', {
                { type = 'select', label = 'Units', description = 'Select a unit to track', icon = 'person', options = options },
            })[1]
            if serverId == nil then return end
            if Tracking.PlayerBlips[serverId] and DoesBlipExist(Tracking.PlayerBlips[serverId].blipId) then
                SetBlipRoute(Tracking.PlayerBlips[serverId].blipId, true)
                LocalPlayer.state:set("trackingId", serverId, true)
            else
                lib.notify({
                    title = 'An error occured',
                    description = 'This unit is unavaliable to track at this time, please try again later.',
                    type = 'error'
                })
            end
        else
            lib.notify({
                title = 'No-one is avaliable to track',
                description = 'There is no-one avaliable to track at this time, please try again later.',
                type = 'error'
            })
        end
    else
        ClearAllBlipRoutes()
        LocalPlayer.state:set("trackingId", false, true)
        lib.notify({
            title = 'Route Cleared',
            description = 'We disabled your active tracking route.',
            type = 'success'
        })
    end
end)


AddEventHandler('ProjectHyde:Global:Client:PlayerSpawned', function()

    LocalPlayer.state:set("hidden", LocalPlayer.state.force == "CIV" and true or false, true)

end)


return Tracking