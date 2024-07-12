--// Config //--
local menu = false
local applyUniform = {}
local   map = {
    ["hats"] = 0,
    ["mask"] = 1,
    ["hair"] = 2,
    ["hands"] = 3,
    ["lowerBod"] = 4,
    ["bags"] = 5,
    ["shoes"] = 6,
    ["chains"] = 7,
    ["shirt"] = 8,
    ["armour"] = 9,
    ["decals"] = 10,
    ["jackets"] = 11,   
}
--// Functions //--

function ApplyKit(args, command)
    if command == 'new' then
        for componentType,component in pairs(args) do
            if componentType ~= 'role' and componentType ~= 'displayName' and componentType ~= 'subGroup' then
                    table.insert(applyUniform, {drawable = component.draw, texture = component.txt, component_id = map[componentType]})
                end
            end
            
            exports['fivem-appearance']:setPedComponents(cache.ped, applyUniform)
        end

end

local subMenuFunction = function(subgroup, options)
    lib.registerContext({
        id = 'subMenu',
        title = string.format('Locker Room - %s', subgroup),
        options = options,
        onExit = function()
            menu = false
        end,
        onBack = function()
            loadMenu()
            lib.hideContext(true)
        end
    })

    lib.showContext('subMenu')
end


function loadMenu()
    local uniformOptions = {}
    local subOptions = {}
    local playerDiv = LocalPlayer.state.division

    for _, uniforms in pairs(Configuration.Uniforms[playerDiv]) do
        if next(uniforms.role) ~= nil then
            if DISCORD.CheckAnyMembership(uniforms.role) then
                if uniforms.subGroup ~= nil then
                    if not subOptions[uniforms.subGroup] then
                        subOptions[uniforms.subGroup] = {}
                    end
                    table.insert(subOptions[uniforms.subGroup], {title = uniforms.displayName, description = 'Press to equip this uniform.', icon = uniforms.icon,  onSelect = function() ApplyKit(uniforms, 'new') menu = false end})
                    table.insert(uniformOptions, {title = uniforms.subGroup, description = 'Subgroup of locker', icon = uniforms.icon,  arrow = true ,onSelect = function() subMenuFunction(uniforms.subGroup, subOptions[uniforms.subGroup]) end})
                else
                    table.insert(uniformOptions, {title = uniforms.displayName, description = 'Press to equip this uniform.', icon = 'fa-shirt',  onSelect = function() ApplyKit(uniforms, 'new') menu = false end})
                end
            end
        else
            table.insert(uniformOptions, {title = uniforms.displayName, description = 'Press to equip this uniform.', icon = 'fa-shirt',  onSelect = function() ApplyKit(uniforms, 'new') menu = false end})
        end
    end

    lib.registerContext({
        id = 'uniformMenu',
        title = 'Locker Room',
        options = uniformOptions,
        onExit = function()
            menu = false
        end
    })
    lib.showContext('uniformMenu')
end

for _,service in pairs(Configuration.locations) do
    for _, locations in pairs(service.locations) do
        local _, zCord =  GetGroundZAndNormalFor3dCoord(locations.x, locations.y, locations.z, 0)
        local newPoint = lib.points.new({
            coords = {x = locations.x, y = locations.y, z = locations.z},
            distance = 2
        })

        local newMarker = lib.marker.new({
            type = 23,
            coords = {x = locations.x, y = locations.y, z = zCord}
        })

        function newPoint:onEnter()
            newMarker:draw()
            if menu == false then
                menu = true
                loadMenu()
            end
        end
    end
end
