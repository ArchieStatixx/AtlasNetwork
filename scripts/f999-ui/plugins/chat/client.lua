-- DO Chat (Stop gap)
-- Whisper Notification (Chat for mods)
-- Advert (CIV) Notification

local function getUserList()
    local userlist = {}
    for _, value in ipairs(GetActivePlayers()) do
        if value ~= 128 then
            table.insert(userlist, { value = GetPlayerServerId(value), label = GetPlayerName(value) })
        end
    end

    return userlist
end

local function whisper()
    local input = lib.inputDialog("Whisper To Player", {
        { type = 'select',   label = 'Players', description = 'Select a person to Whisper To', icon = 'person', options = getUserList(), required = true },
        { type = 'textarea', label = 'Message', description = 'Message to be sent',            required = true },
    })

    if not input then return end

    TriggerServerEvent("F999:UI:WHISPER", input[1], input[2])
end

local function advert()
    -- TODO: Replace with better version
    if LocalPlayer.state.force ~= "CIV" then
        return lib.notify({
            title = "You can not use this while not on a Civ",
            type = 'error',
        })
    end

    local input = lib.inputDialog("Advert Message", {
        { type = 'color', label = 'Advert Colour', format="hex", required = true},
        { type = 'input', label = 'Advert Type', description = 'Advert Type', required = true },
        { type = 'textarea', label = 'Advert', description = 'Advert Message', required = true },
    })

    if not input then return end

    TriggerServerEvent("F999:UI:ADVERT", input)
end

RegisterNetEvent("F999:UI:WHISPER")
AddEventHandler("F999:UI:WHISPER", function(player, msg)
    lib.notify({
        title = string.format("Message from: %s", GetPlayerName(GetPlayerFromServerId(player))),
        description = msg,
        duration = 5000
    })
end)

if DISCORD.CheckAnyMembership({ "ModerationTeam" }) then
    RegisterNetEvent('F999:UI:MOD:WHISPER')
    AddEventHandler('F999:UI:MOD:WHISPER', function(res, sent, msg)
        TriggerEvent('chat:addMessage', {
            template = '<b style="color:red;">Whisper: </b> <i> {0} </i> -> <i> {1} </i> | {2}',
            args = {
                sent,
                res,
                msg
            },
            multiline = true,
        })
    end)
end

RegisterNetEvent('F999:UI:ADVERT')
AddEventHandler('F999:UI:ADVERT', function(data)
    TriggerEvent('chat:addMessage', {
        template = '<b>SOCIAL: [<span style="color:{0}">{1}</span>]</b> {2}',
        args = data,
        multiline = true,
    })
end)


-- TODO: Replace with a proper event system
local function doCommand()
    local input = lib.inputDialog("Do", {
        { type = 'textarea', label = 'Do', description = 'Do', required = true },
    })
    if not input then return end

    local coords = GetEntityCoords(cache.ped)

    TriggerServerEvent("F999:UI:DO", input[1], coords)
end

RegisterNetEvent('F999:UI:DO')
AddEventHandler('F999:UI:DO', function(msg,name)
    TriggerEvent('chat:addMessage', {
        template = '<b>DO: [{0}]</b>: {1}',
        args = {
            name,
            msg
        },
        multiline = true,
    })
end)

-- End of TODO


local function registerActions()
    lib.registerRadial({
        id = 'chatAction',
        items = {
            {
                label = 'Whisper',
                icon = 'people-arrows',
                onSelect = whisper
            },
            {
                label = 'Advert',
                icon = 'fa-solid fa-billboard',
                onSelect = advert
            },
            {
                label = 'DO',
                icon = 'fa-solid fa-billboard',
                onSelect = doCommand
            }
        }
    })
end


-- don't touch
registerActions()