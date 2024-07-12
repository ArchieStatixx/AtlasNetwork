SetInterval(function()
    local playerLocations = {}
    for _, player in ipairs(GetPlayers()) do
        local blipFormat = GlobalState.division[Player(player).state.divisionName].extraFields.blipFormat or GlobalState.department[Player(player).state.departmentName].extraFields.blipFormat
        local ped = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local bucket = GetPlayerRoutingBucket(player)
        local name = GetPlayerName(player)
        local hidden = Player(player).state.hidden or false
        local civ = exports['crToolkit']:SNAILYgetSnailyTable(player, "Citizen") or false
        local unit = exports['crToolkit']:SNAILYgetSnailyTable(player, "Units") or false
        if civ then
            name = string.format("%s %s", civ.name, civ.surname)
        end
        if unit then
            local callsign = string.format("%s%s", unit.callsign, unit.callsign2)
            name = string.format("[%s] %s", callsign, name)
        end
        playerLocations[player] = {coords = coords, bucket = bucket, name = name, visible = hidden, blipFormat = blipFormat }
    end
    TriggerClientEvent('crLib:setLocalState', -1, 'playerLocations', playerLocations, false)
end, math.random(3, 5) * 500)