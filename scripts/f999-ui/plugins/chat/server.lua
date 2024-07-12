RegisterNetEvent("F999:UI:WHISPER")
AddEventHandler("F999:UI:WHISPER", function (user, message)

    local src = source

    TriggerClientEvent("F999:UI:WHISPER", user, source, message)
    TriggerClientEvent("F999:UI:MOD:WHISPER", -1, GetPlayerName(user), GetPlayerName(src), message)
end)

RegisterNetEvent("F999:UI:ADVERT")
AddEventHandler("F999:UI:ADVERT", function (data)
    TriggerClientEvent("F999:UI:ADVERT", -1, data)
end)

-- TODO: Replace with a proper event system
local maxDistance = 50
RegisterNetEvent("F999:UI:DO")
AddEventHandler("F999:UI:DO", function (msg, coords)
    local players = lib.getNearbyPlayers(coords, maxDistance)
    local src = source
    for _, player in ipairs(players) do
        TriggerClientEvent("F999:UI:DO", player.id, msg, GetPlayerName(src))
    end
end)