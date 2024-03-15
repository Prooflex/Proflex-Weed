-- Locals
local oxtarget = exports.ox_target
local notify = lib.notify
local FailedSkillCheck = false

local centerCoords = Config.Location
local spawnedProps = {} -- Table to store spawned prop entities

function CountSpawnedProps()
    local propCount = 0
    for _, propEntity in ipairs(spawnedProps) do
        if DoesEntityExist(propEntity) then
            propCount = propCount + 1
        end
    end
    return propCount
end

function CheckDistance(coords, minDistance)
    for _, propEntity in ipairs(spawnedProps) do
        local propCoords = GetEntityCoords(propEntity)
        local distance = #(coords - propCoords)
        if distance < minDistance then
            return false 
        end
    end
    return true
end

function PlaceObjectOnGroundProperly(prop)
    local pos = GetEntityCoords(prop)
    
    for i = 0, 100, 1 do -- Adjust the range or step size as needed
        local foundGround, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + i, 0)

        if foundGround then
            SetEntityCoordsNoOffset(prop, pos.x, pos.y, groundZ, true, true, true) -- Adjust the offset (e.g., 0.5)
            return true
        end
    end
    
    return false
end

function SpawnPropsAroundCenterWithDistanceCheck(centerCoords, propModel, numProps, radius, minDistanceToPlayer, minDistanceBetweenProps)
    local existingProps = CountSpawnedProps()
    local propsToSpawn = numProps - existingProps
    
    if propsToSpawn <= 0 then
        return -- No need to spawn more props
    end
    
    for i = 1, propsToSpawn do
        local tries = 0
        local maxTries = 5 
        
        repeat
            local randomRadius = math.random() * radius 
            local randomAngle = math.random(0, 360) 
            local angleInRadians = math.rad(randomAngle)

            local spawnX = centerCoords.x + randomRadius * math.cos(angleInRadians)
            local spawnY = centerCoords.y + randomRadius * math.sin(angleInRadians)
            local spawnZ = centerCoords.z

            local playerCoords = GetEntityCoords(PlayerPedId())
            local playerDistance = #(vector3(spawnX, spawnY, spawnZ) - playerCoords)

            local isValidSpawn = CheckDistance(vector3(spawnX, spawnY, spawnZ), minDistanceBetweenProps) and (playerDistance > minDistanceToPlayer)

            if isValidSpawn then
                local prop = CreateObject(GetHashKey(propModel), spawnX, spawnY, spawnZ, true, true, true)
                PlaceObjectOnGroundProperly(prop)
                table.insert(spawnedProps, prop)

                local networkId = NetworkGetNetworkIdFromEntity(prop)
                exports.ox_target:addEntity(networkId, {
                    distance = Config.TargetDistance,
                    icon = Config.PickingWeedIcon,
                    label = Config.PickingWeedTargetLang,
                    event = 'proflex-weed:picking:client'
                })
                break
            end

            tries = tries + 1
        until tries >= maxTries
    end
end

function DespawnProps()
    for _, propEntity in ipairs(spawnedProps) do
        if DoesEntityExist(propEntity) then
            DeleteEntity(propEntity)
        end
    end
    spawnedProps = {}
end

local propToSpawn = Config.Prop -- define the prop you want to spawn Config.Prop
local numberOfProps = Config.PropAmount -- Number of props you want spawning Config.PropAmount
local spawnRadius = Config.PropRadius -- Spawn Radius of plants Config.PropRadius
local minimumDistance = 5.0 -- Distance between plants Config.Distance
local circleCenter = Config.Location -- Define the location where you want the props to spawn? -- Config.Location
local circleRadius = Config.ZoneRadius -- Radius for inside zone Config.ZoneRadius

function IsPlayerInsideCircleZone(playerCoords)
    local distance = #(circleCenter - playerCoords)
    return distance <= circleRadius
end

RegisterNetEvent('circleZone:playerEntered')
AddEventHandler('circleZone:playerEntered', function()
    local playerCoords = GetEntityCoords(PlayerPedId())

    if IsPlayerInsideCircleZone(playerCoords) then
        SpawnPropsAroundCenterWithDistanceCheck(circleCenter, propToSpawn, numberOfProps, spawnRadius, 4.0, minimumDistance)
    end
end)

RegisterNetEvent('circleZone:playerLeft')
AddEventHandler('circleZone:playerLeft', function()
    DespawnProps()
end)



RegisterNetEvent('proflex-weed:picking:client', function(weedpicking)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local hasItem = lib.callback.await('Proflex:hasItem', false, Config.ScissorsName)

    -- Check if scissors are enabled in the configuration
    if Config.EnabledScissors then
        -- Check if the player has the required amount of scissors
        if hasItem >= Config.AmountOfScissors then   
            if FailedSkillCheck then
                Wait(100)
                local success = lib.skillCheck({'easy'}, {'w'})
                if success then
                    FailedSkillCheck = false
                else
                    notify({ description = Config.notifyFail, })
                    return
                end
            end

            if Config.SkillCheck then
                -- Perform a skill check based on a defined chance
                local chance = math.random(1, 100)
                if chance <= Config.SkillCheckChance then
                    print(chance)
                    Wait(100)
                    local success = lib.skillCheck({'easy'}, {'w'})
                    if not success then
                        FailedSkillCheck = true
                        notify({ description = Config.notifyFail, })
                        return
                    end
                end
            end

            -- Perform weed picking action with progress circle
            if lib.progressCircle({
                duration = Config.PickingDuration,
                label = Config.PickingLangauge,
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true,
                },
                anim = {
                dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                clip = 'machinic_loop_mechandplayer'
                },
                prop = {
                    model = `v_ret_gc_scissors`,
                    pos = vec3(0.06, 0.10, 0.04),
                    rot = vec3(0.0, 0.0, -1.5)
                },
            }) then
                -- Notify about successful weed picking
                lib.callback.await('proflex:server:weeditem')
                notify({ description = Config.PickingWeedNotifyLang })

                -- Remove picked props near the player
                local propEntitiesToRemove = {}
                for index, propEntity in ipairs(spawnedProps) do
                    local distance = #(playerCoords - GetEntityCoords(propEntity))
                    if distance < 2.5 then
                        exports.ox_target:removeEntity(NetworkGetNetworkIdFromEntity(propEntity))
                        DeleteEntity(propEntity)
                        table.insert(propEntitiesToRemove, index)
                    end
                end

                -- Remove the removed props from the spawnedProps table
                for i = #propEntitiesToRemove, 1, -1 do
                    table.remove(spawnedProps, propEntitiesToRemove[i])
                end

                -- Respawn new props after picking
                local centerCoords = Config.Location
                local propToSpawn = Config.Prop
                local numberOfProps = 8
                local spawnRadius = 10
                local minimumDistance = 4.0

                SpawnPropsAroundCenterWithDistanceCheck(centerCoords, propToSpawn, 1, spawnRadius, 4.0, minimumDistance)
            end
        else    
            notify({ description = Config.ScissorsNotFound, })
        end
    else -- EVENT WITHOUT SCISSORS ENABLED

        if FailedSkillCheck then
            Wait(100)
            local success = lib.skillCheck({'easy'}, {'w'})
            if success then
                FailedSkillCheck = false
            else
                notify({ description = Config.notifyFail, })
                return
            end
        end

        if Config.SkillCheck then
            -- Perform a skill check based on a defined chance
            local chance = math.random(1, 100)
            if chance <= Config.SkillCheckChance then
                print(chance)
                Wait(100)
                local success = lib.skillCheck({'easy'}, {'w'})
                if not success then
                    FailedSkillCheck = true
                    notify({ description = Config.notifyFail, })
                    return
                end
            end
        end

                    -- Perform weed picking action with progress circle
                    if lib.progressCircle({
                        duration = Config.PickingDuration,
                        label = Config.PickingLangauge,
                        useWhileDead = false,
                        canCancel = true,
                        disable = {
                            car = true,
                            move = true,
                            combat = true,
                        },
                        anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
                    }) then
                        -- Notify about successful weed picking
                        lib.callback.await('proflex:server:weeditem')
                        notify({ description = Config.PickingWeedNotifyLang })
        
                        -- Remove picked props near the player
                        local propEntitiesToRemove = {}
                        for index, propEntity in ipairs(spawnedProps) do
                            local distance = #(playerCoords - GetEntityCoords(propEntity))
                            if distance < 2.5 then
                                exports.ox_target:removeEntity(NetworkGetNetworkIdFromEntity(propEntity))
                                DeleteEntity(propEntity)
                                table.insert(propEntitiesToRemove, index)
                            end
                        end
        
                        -- Remove the removed props from the spawnedProps table
                        for i = #propEntitiesToRemove, 1, -1 do
                            table.remove(spawnedProps, propEntitiesToRemove[i])
                        end
        
                        -- Respawn new props after picking
                        local centerCoords = Config.Location
                        local propToSpawn = Config.Prop
                        local numberOfProps = 8
                        local spawnRadius = 10
                        local minimumDistance = 4.0
        
                        SpawnPropsAroundCenterWithDistanceCheck(centerCoords, propToSpawn, 1, spawnRadius, 4.0, minimumDistance)
                    end
        -- EVENT WITHOUT SCISSORS ENABLED
    end
end)



RegisterNetEvent('proflex-weed:drying:client', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local hasItem = lib.callback.await('Proflex:hasItem', false, Config.WeedItem)

    if hasItem >= Config.DryingWeedAmmount then
    if FailedSkillCheck then
        Wait(100)
        local success = lib.skillCheck({'easy'}, {'w'})
        if success then
            FailedSkillCheck = false
        else
        notify({ description = 'You failed',})
            return
        end
    end
    if Config.SkillCheck then
        local chance = math.random(1, 100)
        if chance <= Config.SkillCheckChance then
            if Config.Debug then print(chance)
            Wait(100)
            local success = lib.skillCheck({'easy'}, {'w'})
            if not success then
                FailedSkillCheck = true
                notify({ description = 'You failed',})
                return
            end 
        end
    end
    if lib.progressCircle({
        duration = Config.DryingDuration,
        label = Config.DryingLangauge,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car     = true,
            move    = true,
            combat  = true,
        },
        anim = {dict = 'amb@medic@standing@tendtodead@idle_a',  clip = 'idle_a'},
    })
    then
        lib.callback.await('proflex:server:dryweeditem')
        notify({ description = Config.DryingWeedNotifyLang, })
                end
            end
        else
    notify({ description = Config.ItemNotFound, })
    end
end)

RegisterNetEvent('proflex-weed:cutting:client', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local hasItem = lib.callback.await('Proflex:hasItem', false, Config.Dryingitem)

    if hasItem >= Config.CuttingWeedAmmount then
    if FailedSkillCheck then
        Wait(100)
        local success = lib.skillCheck({'easy'}, {'w'})
        if success then
            FailedSkillCheck = false
        else
        notify({ description = 'You failed',})
            return
        end
    end
    if Config.SkillCheck then
        local chance = math.random(1, 100)
        if chance <= Config.SkillCheckChance then
            print(chance)
            Wait(100)
            local success = lib.skillCheck({'easy'}, {'w'})
            if not success then
                FailedSkillCheck = true
                notify({ description = 'You failed',})
                return
            end
        end
    end
    if lib.progressCircle({
        duration = Config.CuttingUpDuration,
        label = Config.CuttingUpLangauge,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car     = true,
            move    = true,
            combat  = true,
        },
        anim = {dict = 'amb@world_human_gardener_plant@male@enter',  clip = 'enter'},
    })
    then
        lib.callback.await('proflex:server:cutupweeditem')
        notify({ description = Config.CutupWeedNotifyLang, })
                end
            else
        notify({ description = Config.ItemNotFound, })
    end
end)

RegisterNetEvent('proflex-weed:bagging:client', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local hasItem = lib.callback.await('Proflex:hasItem', false, Config.CuttingUpitem)

    if hasItem >= Config.BaggingWeedAmmount then
    if FailedSkillCheck then
        Wait(100)
        local success = lib.skillCheck({'easy'}, {'w'})
        if success then
            FailedSkillCheck = false
        else
        notify({ description = 'You failed',})
            return
        end
    end
    if Config.SkillCheck then
        local chance = math.random(1, 100)
        if chance <= Config.SkillCheckChance then
            print(chance)
            Wait(100)
            local success = lib.skillCheck({'easy'}, {'w'})
            if not success then
                FailedSkillCheck = true
                notify({ description = Config.BaggedWeedNotifyLang,})
                return
            end
        end
    end
    if lib.progressCircle({
        duration = Config.BaggingDuration,
        label = Config.BaggingLangauge,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car     = true,
            move    = true,
            combat  = true,
        },
        anim = {dict = 'amb@world_human_gardener_plant@male@enter',  clip = 'enter'},
    })
    then
        lib.callback.await('proflex:server:baggedweeditem')
        notify({ description = Config.BaggedWeedNotifyLang, })
                end
            else
        notify({ description = Config.ItemNotFound, })
    end
end)

-- SphereZones

oxtarget:addSphereZone({
    coords = vector3(89.55, 3745.51, 40.65),
    radius = 1.0,
    debug = Config.Debug, -- Turn this on for testing
    options = {
        {
            icon = Config.DryingWeedIcon,
            label = Config.DryingWeedTargetLang,
            event = 'proflex-weed:drying:client'
        },
    },
})

oxtarget:addSphereZone({
    coords = vector3(1556.24, 3805.91, 33.44),
    radius = 1.0,
    debug = Config.Debug, -- Turn this on for testing
    options = {
        {
            icon = Config.CuttingUpWeedIcon,
            label = Config.CuttingUpWeedTargetLang,
            event = 'proflex-weed:cutting:client'
        },
    },
})

oxtarget:addSphereZone({
    coords = vector3(1552.97, 3804.46, 33.44),
    radius = 1.0,
    debug = Config.Debug, -- Turn this on for testing
    options = {
        {
            icon = Config.BaggedWeedTargetIcon,
            label = Config.BaggedWeedTargetLang,
            event = 'proflex-weed:bagging:client'
        },
    },
})


-- Event Handler's

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, prop in ipairs(spawnedProps) do
            DeleteEntity(prop)
        end
    end
end)


CreateThread(function()
    while true do
        Wait(1000) 

        local playerCoords = GetEntityCoords(PlayerPedId())

        if IsPlayerInsideCircleZone(playerCoords) then
            TriggerEvent('circleZone:playerEntered')
        else
            TriggerEvent('circleZone:playerLeft')
        end
    end
end)



