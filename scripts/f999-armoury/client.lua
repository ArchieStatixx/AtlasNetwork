local menu = false


for _, service in pairs(Configuration.armourySettings) do
    for _, locations in pairs(service.locations) do
        local _, zCord = GetGroundZAndNormalFor3dCoord(locations.x, locations.y, locations.z, 0)
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
            end
        end
    end
end