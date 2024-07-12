--// Config //--

local allowListedDivisions = {'cl33iufqn1444491cr1hhdbpaqap','cldvxj4ob000a1hbuc4ook54b', 'clj6449fm00rw1hz502v37u7r', 'cl76lw690338457oj1hm2fhzryf', 'clvu235ip14y48j8b79yqqcl5', 'clwtu4e0b053ruhoz1m7ncnoj', 'clxg1y2bo08spuhozlzj41qfa'}
local gpsActive = false
local config = {blip = nil, zone = nil}
local staffCooldown = nil
--// Vehicle Menu //--
lib.onCache('vehicle', function(value)
    if value then
        lib.addRadialItem({
            id = 'vehicle',
            label = 'Interactions',
            icon = 'car',
            menu = 'vehicleMenu'
        })
        lib.removeRadialItem('interactions')
        lib.removeRadialItem('settings')
    else
        lib.addRadialItem({
            {
                id = 'settings',
                label = 'Settings',
                icon = 'wrench',
                menu = 'settingsMenu'

            },
            {
                id = 'interactions',
                label = 'Interactions',
                icon = 'person-walking',
                menu = 'interactionMenu'
            }
        })

        lib.removeRadialItem('vehicle')
    end
end)



local vehicleManager = function(command) 
    if command == 'fix' then
        local plrVehicle = GetVehiclePedIsIn(cache.ped, false)
        SetVehicleEngineOn(plrVehicle, false, true, true)
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("We're fixing your vehicle for you, Please wait 30 seconds for this to take place.")
        EndTextCommandThefeedPostMessagetext("LBLRP_Textures", "AA_Logo", true, 0, "AA", "Mechanic")

        if lib.progressBar({
            duration = 20000,
            label = 'Repairing Vehicle',
            canCancel = true,
        }) then
            SetVehicleEngineHealth(plrVehicle, 1000)
            SetVehicleEngineOn(plrVehicle, true, false, false)
            SetVehicleFixed(plrVehicle)
            SetVehicleDirtLevel(plrVehicle, 0)
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName("We've fixed your vehicle for you, You can now continue your patrol.")
            EndTextCommandThefeedPostMessagetext("LBLRP_Textures", "AA_Logo", true, 0, "AA", "Mechanic")            
        else
            lib.notify({
                id = 'error',
                title = 'Cancelled',
                description = "You have cancelled the repair..",
                position = 'top',
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                      color = '#909296'
                    }
                },
                icon = 'ban',
                iconColor = '#C53030'
            })
        end
    elseif command == 'paint' then
        local colourMenu = {}
        local plrVehicle = GetVehiclePedIsIn(cache.ped, false)

        for _,colour in ipairs(Configuration.colourOptions) do
            table.insert(colourMenu, {label = colour.colourName, value = colour.hex})
        end

        local input = lib.inputDialog(
            "Colour Menu",
            {
                {type = 'select', label = 'Colour', description = 'Pick a colour to change the vehicle to.', icon = 'spray-can', options = colourMenu}
            }
        )

        if input == nil then return end
        local colour = tonumber(input[1])
        SetVehicleColours(plrVehicle, colour, colour)
    end
end


lib.registerRadial({
    id = 'vehicleMenu',
    items = {
        {
            label = 'Fix Vehicle',
            icon = 'car-burst',
            onSelect = function()
                vehicleManager('fix')
            end
        },
        {
            label = 'Change Vehicle Colour',
            icon = 'spray-can',
            onSelect = function()
                vehicleManager('paint')
            end

        },
        {
            label = 'Chat',
            icon = 'comment',
            menu = 'chatAction'
        },
        {
            id = 'vehicle-menu',
            icon = 'truck-ramp-box',
            label = 'Options',
            menu = "vehicle-menu-options"
        }
    }
})

--// Moderation //--

local fireManager = function(command)
    if DISCORD.CheckAnyMembership({"ModerationTeam"}) then
        if command == "stopFire" then
            ExecuteCommand("stopallfires")
    
            lib.notify({
                title = 'Success!',
                description = 'All fires have been stopped.',
                type = 'success'
            })
        elseif command == "stopSmoke" then
            ExecuteCommand("stopallsmoke")
            lib.notify({
                title = 'Success!',
                description = 'All smoke have been stopped.',
                type = 'success'
            })
        elseif command == "triggerFire" then
            ExecuteCommand("triggerautofire")
            lib.notify({
                title = 'Success!',
                description = 'Autofire Triggered .',
                type = 'success'
            })
        end
    else
        lib.notify({
            id = 'error',
            title = 'Error Occured',
            description = "You cannot run this command.",
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                  color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
        end
    end


function removeModerationBlip()
    LocalPlayer.state:set("activeModerator", not LocalPlayer.state.activeModerator, true)
    LocalPlayer.state:set("hidden", not LocalPlayer.state.hidden, true)
    lib.notify({
            description = string.format('You are now set to %s.', LocalPlayer.state.hidden and "hidden" or "visible"),
            type = LocalPlayer.state.hidden and "success" or "warning"
    })    
end


local devToolManager = function(command)
    if command == 'changeBucket' then
        local input = lib.inputDialog(
            "Bucket",
            {
                {type = 'number', label = 'Bucket', description = 'What bucket do you want to go to?', icon = 'bucket'}
            }
        )

        if input then
            local bucket  = input[1]

            TriggerServerEvent('LBLDEV:SERVER:SETBUCKET')

            lib.notify({
                id = "dev-routing-bucket",
                title = "Changed Bucket",
                description = string.format("Change to bucket: %d", bucket),
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
            })

        end

    elseif command == 'inventoryAdd' then
        local input = lib.inputDialog(
            "Add Item",
            {
                {type = 'input', label = 'Item Name', description = 'Name of Item', icon = 'shelves'},
                {type = 'number', label = 'Quantity', description = 'Quantity', icon = 'tally'},
            }
        )

        if input then
            local item = input[1]
            local count = input[2]

            TriggerServerEvent("LBLDEV:SERVER:IVENTORY:ADD", item, count)

            lib.notify({
                id = "dev-iventory-add",
                title = "Added Item",
                description = string.format("Add Item: %s", item),
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
            })
        end

    end -- Can add more commands before this section.
end

--// Moderation Radial //--

if DISCORD.CheckAnyMembership({"ModerationTeam", "CivStaff"}) then

    lib.addRadialItem({
        {
            id = 'moderation',
            label = 'Moderation',
            icon = 'user-shield',
            menu = 'moderationMenu'
        }
    })

    local options = {
        {
            label = "Toggle Visibility",
            icon = 'user-shield',
            onSelect = function() removeModerationBlip() end 
        }
    }

    if DISCORD.CheckAnyMembership({"ModerationTeam"}) then
        table.insert(options, {label = 'Fire Manager', icon = 'fire', menu = 'fireMenu'})
        table.insert(options, {label = 'Dev Tools', icon = 'code', menu = 'devTools'})
    end

    lib.registerRadial({
        id = 'moderationMenu',
        items = options
    })
end


--// Moderation Sub - Fire Manager //--

lib.registerRadial({
    id = 'fireMenu',
    items = {
        {
            label = 'Stop all Fires',
            icon = 'fire',
            onSelect = function()
                fireManager('stopFire')
            end
        },
        {
            label = 'Stop all smoke',
            icon = 'smoke',
            onSelect = function()
                fireManager('stopSmoke')
            end
        },
        {
            label = 'Trigger Autofire',
            icon = 'fire',
            onSelect = function()
                fireManager('triggerFire')
            end
        }
    }
})

--// Dev tools //--

lib.registerRadial({
    id = 'devTools',
    items = {
        {
            label = 'Set Bucket',
            icon = 'bucket',
            onSelect = function()
                devToolManager('changeBucket')
            end

        },
        {
            label = 'Add item to Inventory',
            icon = 'shelves',
            onSelect = function()
                devToolManager('inventoryAdd')
            end
        }
    }
})


--// Settings //--



local returnToStation = function ()
    if IsPedInAnyVehicle(cache.ped, false) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        SetEntityAsMissionEntity(vehicle, false, true)
        DeleteVehicle(vehicle)
    end

    DoScreenFadeOut(500)
    Citizen.Wait(500)
    local location = LocalPlayer.state.spawnedLocation
    DoScreenFadeOut(100)
    Wait(100)
    lib.common.movePlayer(location)
    DoScreenFadeIn(500)
end


local spawnSelect = function()
    if IsEntityDead(cache.ped) then
        TriggerEvent('PHSpawn:Client:Events:Respawn')
    else
            TriggerServerEvent("PHSpawn:Server:Events:ClockOffCiv")
            TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:SetStatus',  cache.serverId, "State 11")
            TriggerEvent('PHSpawn:Client:Events:Spawn')
    end
end

local changeAppearence = function()
    local config = {
        ped = true,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = true
    }

    if LocalPlayer.state.force == "CIV" or SNAILY.CheckAnyDivision(allowListedDivisions) or DISCORD.CheckAnyMembership({"ModerationTeam"}) then
        exports['fivem-appearance']:startPlayerCustomization(function (appearance)
            if (appearance) then
                local civ = LocalPlayer.state.civ
                TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:UpdateCitizenAppearance', civ.id or false, json.encode(appearance))
            end
        end, config)
    else
        local Serviceconfig = {
            ped = false,
            headBlend = true,
            faceFeatures = true,
            headOverlays = true,
            components = false,
            props = false,
            tattoos = true
        }
        exports['fivem-appearance']:startPlayerCustomization(function (appearance)
            if (appearance) then
                local civ = LocalPlayer.state.civ
                TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:UpdateCitizenAppearance', civ.id or false, json.encode(appearance))
            end
        end, Serviceconfig)
    end
end


local nametagToggle = function()
    exports['f999-nametags']:ToggleNametags()
    lib.notify({
        description = string.format('Nametags have been toggled'),
        type = "success"
})   
end

local staffRequest = function()
    print(staffCooldown)
    if staffCooldown == nil then
        local input = lib.inputDialog("Request Staff",
        {
            {type = 'input', label = 'Reason', description = 'Reason for request.', icon = 'fa-message', required = true}
        })
    
        if input == nil then return end
        local data = {
            firstName = LocalPlayer.state.civ.name,
            surname = LocalPlayer.state.civ.surname,
            discordId = LocalPlayer.state.civ.user.discordId,
            playerName = GetPlayerName(cache.playerId),
            reason = input[1]
        }
    
        TriggerServerEvent('mod:requestStaff', data)
    
        staffCooldown = lib.timer(300000, function()
            staffCooldown = nil
        end, true)

        lib.notify({
            title = 'Success!',
            description = 'Moderation team have been alerted.',
            type = 'success'
        })    
    else
        local minutesLeft = staffCooldown:getTimeLeft('m')

        lib.notify({
            tile = "Error!",
            description = string.format('You still have %s minutes before you can make another request...', minutesLeft),
            type = 'warning'
        })
    end
end

local saveEUP = function()
    local input = lib.inputDialog("Save Uniform",
    {   
        {type = 'input', label = 'Uniform Name', description = 'What do you want to call the uniform', required = true},
        {type = 'input', label = 'Role', description = 'Do you want to lock it to a role?', required = false},
        {type = 'input', label = 'subGroup', description = 'Do you want it to be a subgroup', required = false, default = 'nil'},
        {type = 'input', label = 'icon', description = 'Do you want it to have a custom icon', required = false, default = 'fa-shirt'},
    })
    
    if input == nil then print("No data submitted") end
    
    
    
    local map = {
        [0] = "hats",
        [1] = "mask",
        [2] = "hair",
        [3] = "hands",
        [4] = "lowerBod",
        [5] = "bags",
        [6] = "shoes",
        [7] = "chains",
        [8] = "shirt",
        [9] = "armour",
        [10] = "decals",
        [11] = "jackets"
    }

    local format = {
            displayName = input[1],
            role = nil,
            subGroup = input[3],
            icon = input[4],
            hats = {draw = 0, txt = 0},
            mask = {draw = 0, txt = 0},
            hair = {draw = 0, txt = 0},
            hands = {draw = 0, txt = 0},
            lowerBod = {draw = 0, txt = 0},
            bags = {draw = 0, txt = 0},
            shoes = {draw = 0, txt = 0},
            chains = {draw = 0, txt = 0},
            shirt = {draw = 0, txt = 0},
            armour = {draw = 0, txt = 0},
            decals = {draw = 0, txt = 0},
            jackets = {draw = 0, txt = 0},
    }
    if input[2] == "" then format.role = {} else format.role = {input[2]} end
    
    local currentAttire = exports['fivem-appearance']:getPedComponents(cache.ped)
    for _, v in pairs(currentAttire) do
        local component_name = map[v.component_id]
        format[component_name].draw = v.drawable
        format[component_name].txt = v.texture
    end
    TriggerServerEvent('eup:save', format, GetPlayerName(cache.playerId))
end

--// Settings Radial //--

local settingsOptions = {{label = 'Respawn', icon = 'arrows-rotate', onSelect = function() spawnSelect() end}, {label = 'Return to Station', icon = 'building', onSelect = function() returnToStation() end}, {label = 'Appearance', icon = 'fa-shirt', onSelect = function() changeAppearence() end}, {label = 'Hide Names', icon = 'fa-tag', onSelect = function() nametagToggle() end}, {label = 'Request Staff', icon = 'user-shield', onSelect = function() staffRequest() end}}

if SNAILY.CheckAnyDivision(allowListedDivisions) then
    table.insert(settingsOptions, {label = 'Save EUP', icon = 'fa-shirt', onSelect = function() saveEUP()  end})
end

lib.registerRadial({
    id = 'settingsMenu',
    items = settingsOptions
})

--// MDT Radial //--


local mdt = function(command)
    if command == 'panic' then
        TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:Panic', cache.serverId)
    elseif command == 'setStatus' then
        local options = {}
        for name,state in pairs(GlobalState["codes_10"]) do
            if state.type == "STATUS_CODE" then
                table.insert(options, {value = name, label = name})
            end
        end
        local input = lib.inputDialog("Set Status",
    {
        {type = 'select', label = 'Status', description = 'Set a Status', icon = 'map=pin', options = options}
    })
    if input == nil then return end
    TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:SetStatus',  cache.serverId, input[1])

    if input[1] == 'State 0' then
        TriggerServerEvent('crToolkit:Server:Events:SnailyCAD:Panic', cache.serverId)
    end

    lib.notify({
        id = 'mdt-set-status',
        title = 'Updated Status',
        description = string.format("Status set to %s", input[1]),
        style = {
            backgroundColor = '#141517',
            color = '#C1C2C5',
            ['.description'] = {
                color = '#909296'
            }
        }
    })
elseif command == 'track' then
    TriggerEvent('f999:ui:tracking')
elseif command == 'rBackup' then
        local options = {}

        for name,department in pairs(GlobalState.department) do
            table.insert(options, {value = department.id, label = name})
        end

        local input = lib.inputDialog("Select a service",
    {
        {type = 'select', label = 'Service', description = 'Set a Status', icon = 'circle-exclamation', options = options},
    })

    if input == nil then return end
    local postal = CoordsToPostal(GetEntityCoords(cache.ped))
    local coord = GetEntityCoords(cache.ped)

    local streetCoord = GetStreetNameAtCoord(coord.x, coord.y, coord.z)
    local streetName = GetStreetNameFromHashKey(streetCoord)

    TriggerServerEvent('mdt:backup', input[1], postal, GetEntityCoords(cache.ped), streetName)
    end
end


local removeZone = function()
    local zone = config.zone

    zone:remove()
    lib.removeBlip(config.blip)
    ClearAllBlipRoutes()
    gpsActive = false
end


local gps = function()
    if not gpsActive then
        gpsActive = true 
        local input = lib.inputDialog('GPS', {
            {type = 'number', label = 'GPS', description = 'Please enter a postal to navigate to..', icon = 'location-dot'}
        })

        if input == nil then lib.notify({id = 'error', title = 'No valid postal was provided...', position = 'top', icon = 'ban', iconColor = '#C53030', style = {backgroundColor = '#141517', color = '#C1C2C5',['.description'] = {color = '#909296'}}}) end
        local coords = PostalToCoords(input[1])

        local blip = lib.createBlip({
            style = "coord",
            x = coords.x,
            y = coords.y,
            z = 0,
            group = 'tracking',
            route = true,
            routeColour = 5
        })

        local zone = lib.zones.sphere({
            coords = vector3(coords.x, coords.y, 0),
            radius = 75,
            onEnter = function()
                removeZone()
            end
        })

        config = {blip = blip.id, zone = zone}

    else
        removeZone()
    end
end



lib.registerRadial({
    id = 'mdtMenu',
    items = {
        {
            label = "Status",
            icon = "tablet",
            onSelect = function()
                mdt('setStatus')
            end
        },
        {
            label = "Panic",
            icon = "circle-exclamation",
            onSelect = function()
                mdt('panic')
            end
        },
        {
            label = 'Tracking',
            icon = 'map-location-dot',
            onSelect = function()
                mdt('track')
            end
        },
        {
            label = 'GPS',
            icon = 'location-dot',
            onSelect = function()
                gps()
            end
        },
        {
            label = 'Request Backup',
            icon = 'tablet',
            onSelect = function()
                mdt('rBackup')
            end
        }
    }
})



--// Interactions Menu //--


local interactions = function()
    if not lib.getOpenMenu() and GetVehiclePedIsIn(cache.ped, false) == 0 then
      TriggerEvent("F999:TRAFFIC:REGISTERMENU")
    else
        lib.notify({
            id = 'error',
            title = 'Error Occured',
            description = "You cannot run this command while in a vehicle.",
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                  color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
    end
end

--// Teleportation //--

local teleportation = function(data)
    if lib.progressBar({
        duration = 5000,
        label = 'Teleporting...',
        useWhileDead = false,
        canCancel = true
    }) then
        DoScreenFadeOut(100)
        Wait(100)
        lib.common.movePlayer(data)
        DoScreenFadeIn(500)
    else
        lib.notify({
            id = 'error',
            title = 'Cancelled',
            description = "You have cancelled the teleportation...",
            position = 'top-right',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                  color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
    end
end

local locationInput = function()
    if DISCORD.CheckMembership("DonatorAdvanced") then
        local division = LocalPlayer.state.department
        local items = {}
    
        if division == false then
            division = "civFastTravel"
        end
    
        for key, location in ipairs(Configuration[division].locations) do
            if location then
                table.insert(items, {value = key, label = location.name})
            end
        end
    
        local input =  lib.inputDialog("Fast Travel",
        {
            {type = 'select', label = 'Location', description = 'Inititate a teleport to the following location...', icon = 'map-pin', options = items}
        }
    )
        if input == nil then return end
        teleportation(Configuration[division].locations[input[1]].coords)
    else
        lib.notify({
            id = 'error',
            title = 'Access Denied',
            description = "You do not have access to teleport..",
            position = 'top',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                  color = '#909296'
                }
            },
            icon = 'ban',
            iconColor = '#C53030'
        })
    end
end







--// Radial Registration //--
lib.registerRadial({
    id = 'interactionMenu',
    items = {
        {
            label = 'Chat',
            icon = 'comment',
            menu = 'chatAction'
        },

        {
            label = 'Traffic Menu',
            icon = 'traffic-light',
            onSelect = function()
                interactions()
            end
        },
        {
            label = 'Teleport',
            icon = 'shuttle-space',
            onSelect = function()
                locationInput()
            end
        },
    }
})




--// Radial Registering //--
lib.addRadialItem({
    {
        id = 'settings',
        label = 'Settings',
        icon = 'wrench',
        menu = 'settingsMenu'

    },
    {
        id = 'interactions',
        label = 'Interactions',
        icon = 'person-walking',
        menu = 'interactionMenu'
    },
    {
        id = 'mdt',
        label = 'MDT',
        icon = 'tablet',
        menu = 'mdtMenu'
    }
})

