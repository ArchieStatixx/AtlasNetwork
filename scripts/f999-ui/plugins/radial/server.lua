--// Net Events //-- 
RegisterServerEvent('mdt:backup')
RegisterServerEvent('mod:requestStaff')
RegisterServerEvent('eup:save')
--// Event Handling //--

AddEventHandler('mdt:backup', function(department, postal, coords, streetName)
    SNAILY.CreateCall({
        gtaMapPosition = {x = coords.x, y = coords.y, z = coords.z, heading = 0.0},
        location = streetName,
        name = "Control",
        description = "Backup has been requested, Grade I response is required.",
        postal = tostring(postal),
        departments = {department},
        division = {}
    })
end)

AddEventHandler('eup:save', function(data, player)
    local formattedData = "{\n"
    local formatOrder = {"displayName", "role", "subGroup", "icon", "hats", "mask", "hair", "hands", "lowerBod", "bags", "shoes", "chains", "shirt", "armour", "decals", "jackets"}
    
    for i, key in ipairs(formatOrder) do
        if key == "role" then
            if next(data[key]) ~= nil then 
                local roleString = table.concat(data[key], ", ")
                formattedData = formattedData .. string.format("%s = {'%s'}", key, roleString)
            else
                formattedData = formattedData .. string.format("%s = {}", key)
            end
        elseif key == "displayName" or key == "subGroup" or key == "icon" then
            if data[key] ~= 'nil' then
                formattedData = formattedData .. string.format("%s = '%s'", key, data[key])
            else
                formattedData = formattedData .. string.format("%s = ''", key)                 
            end
        else
            local lastItem = (i == #formatOrder)
            formattedData = formattedData .. string.format("%s = { draw = %d, txt = %d }", key, data[key].draw or 0, data[key].txt or 0)
        end
        
        if i < #formatOrder then
            formattedData = formattedData .. ",\n"
        else
            formattedData = formattedData .. "\n"
        end
    end

    formattedData = formattedData .. "}"
    
    local content = string.format("%s has saved the following uniform:\n\n```lua\n%s\n```", player, formattedData)

DISCORD.Hook("webhooks/1060957723887419463/5CXBZ-baArUPxJHHavOz9ocLZnwOyfspnO5oc1XXR0HFg5b0a3zTh1zOBD9FeqSMLpX9", 16753920, "Lockers", "New Uniform Saved", content, "", "This uniform save event was generated on "..os.date('%Y-%m-%d %H:%M:%S').." by crToolkit.")
end)

AddEventHandler('mod:requestStaff', function(data)

    ---/// '<@&1148567948768858253>'  - Ping for moderators --///
    ---/// TODO: Update how Webhook is sent (use DISCORD.Hook)
    local content = {
        {
            ["color"] =  "16711680",
            ["title"] = "Moderation Request",
            ["description"] = string.format('A moderator has been requested by %s (<@%s>) for: %s', data.playerName, data.discordId, data.reason),
            ["fields"] = {
                { name = 'CAD Name', value = string.format('%s %s', data.firstName, data.surname), inline = true},
                { name = 'FiveM Name', value = data.playerName, inline = true},
                { name = 'Discord', value = string.format('<@%s>', data.discordId), inline = true}
            }
        }
    }


    PerformHttpRequest('https://discord.com/api/webhooks/1236782517042810990/RxKl3Z4UlZNLU6vAJdTnf9Xm42nQRHSQpT2aKt77yxTucQp57ohpfXS5lffnEkwXFDPr', function(err, text, headers)
        if err then
            print("Error:", err)
        else
            print("Request sent successfully.")
            if text ~= "" then
                print("Response:", text)
            end
        end
    end, 'POST', json.encode({content = '<@&1148567948768858253>', embeds = content}), { ['Content-Type'] = 'application/json' })
end)
