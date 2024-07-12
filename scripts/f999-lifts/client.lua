local function openLiftMenu(name, currentFloor, config)
    local options = {}

    for floor, floorConfig in ipairs(config.floors) do
        local canUse = true
        if floorConfig.deparments and not SNAILY.CheckAnyDepartment(floorConfig.deparments) then canUse = false end
        if floorConfig.divisions and not SNAILY.CheckAnyDivision(floorConfig.divisions) then canUse = false end
        if floorConfig.roles and not DISCORD.CheckAnyMembership(floorConfig.roles) then canUse = false end

        if canUse and floor ~= currentFloor then
            table.insert(options, {
                title = floorConfig.name,
                icon = floorConfig.icon and floorConfig.icon or nil,
                onSelect = function()
                    DoScreenFadeOut(500)
                    Citizen.Wait(500)
                    lib.common.movePlayer(vector4(floorConfig.position.x, floorConfig.position.y, floorConfig.position.z,
                        floorConfig.position.w))
                    Citizen.Wait(500)
                    DoScreenFadeIn(500)
                    lib.notify({
                        id = 'lift',
                        title = string.format('Traveled to %s', floorConfig.name),
                        type = 'success'
                    })
                end
            })
        end
    end

    if #options == 0 then
        return lib.notify({
            id = 'lift',
            title = 'You do not have access to use this lift!',
            type = 'error'
        })
    end

    lib.registerContext({
        id = 'lift',
        title = name,
        options = options
    })

    lib.showContext('lift')
end

local data = lib.loadJson('config')

for liftName, liftConfig in pairs(data.locations) do
    for floor, floorConfig in ipairs(liftConfig.floors) do
        exports.ox_target:addSphereZone({
            coords = vector3(floorConfig.interaction.x, floorConfig.interaction.y, floorConfig.interaction.z),
            drawSprite = true,
            debug = false,
            options = {
                {
                    label = 'Use lift',
                    icon = 'elevator',
                    canInteract = function()
                        if floorConfig.deparments and not SNAILY.CheckAnyDepartment(floorConfig.deparments) then return false end
                        if floorConfig.divisions and not SNAILY.CheckAnyDivision(floorConfig.divisions) then return false end
                        if floorConfig.roles and not DISCORD.CheckAnyMembership(floorConfig.roles) then return false end

                        return true
                    end,
                    onSelect = function()
                        openLiftMenu(liftName, floor, liftConfig)
                    end
                }
            }
        })
    end
end
