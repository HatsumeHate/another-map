do

    local PERIOD = 0.025
    local MapArea = bj_mapInitialPlayableArea







    function IsMapBounds(x, y)
        return (x > GetRectMaxX(bj_mapInitialPlayableArea) or
        x < GetRectMinX(bj_mapInitialPlayableArea) or
        y > GetRectMaxY(bj_mapInitialPlayableArea) or
        y < GetRectMinY(bj_mapInitialPlayableArea))
    end



    function ThrowMissile(from, target, missile, effects, start_x, start_y, end_x, end_y, angle)
        local unit_data = GetUnitData(from)
        local m = GetMissileData(missile)
        local end_z = GetZ(end_x, end_y) + m.end_z
        local start_z = GetZ(start_x, start_y) + m.start_z
        local time = 0.
        local weapon

                if m == nil then
                    MergeTables(weapon, unit_data.equip_point[WEAPON_POINT])
                    m = GetMissileData(unit_data.equip_point[WEAPON_POINT].missile)
                end

            if angle == 0. then angle = AngleBetweenXY_DEG(start_x, start_y, end_x, end_y) end

            if (target ~= nil and not m.full_distance) then
                end_x = GetUnitX(target)
                end_y = GetUnitY(target)
                end_z = GetZ(end_x, end_y) + m.end_z
                angle = AngleBetweenUnits(from, target)
            elseif m.full_distance then
                end_x = start_x + Rx(m.max_distance, angle)
                end_y = start_y + Ry(m.max_distance, angle)
                end_z = GetZ(end_x, end_y) + m.end_z
            end

        local distance = SquareRoot((end_x-start_x)*(end_x-start_x) + (end_y-start_y)*(end_y-start_y) + (end_z - start_z)*(end_z - start_z))
        time = distance / m.speed

        local missile_effect = AddSpecialEffect(m.model, start_x, start_y)
        BlzSetSpecialEffectHeight(missile_effect, start_z)
        BlzSetSpecialEffectScale(missile_effect, m.scale)
        --BlzSetSpecialEffectOrientation(missile_effect, angle * bj_DEGTORAD, 0., 0.)
        BlzSetSpecialEffectYaw(missile_effect, angle * bj_DEGTORAD)

        if #m.sound_on_launch > 0 then
            AddSound(m.sound_on_launch[GetRandomInt(1, #m.sound_on_launch)], start_x, start_y)
        end

        local distance2d
        local height
        local length = 0.
        local step
        local start_height
        local end_height

        if m.arc ~= nil then
            distance2d = DistanceBetweenXY(start_x, start_y, end_x, end_y)
            height = distance2d * m.arc + RMaxBJ(start_z, end_z)
            step = m.speed / (1. / PERIOD)
            start_height = start_z
            end_height = end_z
            time = time * (1. + m.arc)
        end


        --print(height)


        local vx = (end_x - start_x) * ((m.speed * PERIOD) / distance)
        local vy = (end_y - start_y) * ((m.speed * PERIOD) / distance)
        local vz = (end_z - start_z) * ((m.speed * PERIOD) / distance)




        local impact = false

        TimerStart(CreateTimer(), PERIOD, true, function()

            if IsMapBounds(start_x, start_y) or time < 0. then
                DestroyEffect(missile_effect)
                DestroyTimer(GetExpiredTimer())
                print("BOUNDS")
            else
                --TRACKING
                if m.trackable ~= nil and m.trackable then
                    if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 or target == nil then
                        -- disable
                        DestroyEffect(missile_effect)
                        DestroyTimer(GetExpiredTimer())
                    else
                        distance = GetDistance3D(start_x, start_y, start_z, GetUnitX(target), GetUnitY(target), BlzGetLocalUnitZ(target))
                        vx = (GetUnitX(target) - start_x) * ((m.speed * PERIOD) / distance)
                        vy = (GetUnitY(target) - start_y) * ((m.speed * PERIOD) / distance)
                        vz = (BlzGetLocalUnitZ(target) - start_z) * ((m.speed * PERIOD) / distance)
                        BlzSetSpecialEffectYaw(missile_effect, AngleBetweenXY(start_x, start_y, end_x, end_y) * bj_DEGTORAD)
                    end
                end

                -- COLLISION
                if BlzGetLocalSpecialEffectZ(missile_effect) <= GetZ(start_x, start_y) and not m.ignore_terrain then
                    DestroyEffect(missile_effect)
                    DestroyTimer(GetExpiredTimer())
                    impact = true
                else

                    start_x = start_x + vx
                    start_y = start_y + vy

                    if m.arc ~= nil then
                        local old_z = start_z
                        start_z = GetParabolaZ(start_height, end_height, height, distance2d, length)
                        local zDiff = start_z - old_z
                        local speed_step = m.speed * PERIOD
                        local pitch = zDiff > 0 and math.atan(speed_step / zDiff) - math.pi / 2 or math.atan(-zDiff / speed_step) - math.pi * 2
                        BlzSetSpecialEffectPitch(missile_effect, pitch)
                        length = length + step
                    else
                        start_z = start_z + vz
                    end

                    BlzSetSpecialEffectPosition(missile_effect,  start_x, start_y, start_z)

                    time = time - PERIOD
                end
            end
            -- movement end

            if m.only_on_impact then
                if impact then
                    if weapon.splash then
                        local enemy_group = CreateGroup()

                        GroupEnumUnitsInRange(enemy_group, start_x, start_y, weapon.radius, nil)

                        -- loop
                        GroupClear(enemy_group)
                        DestroyGroup(enemy_group)
                        -- aoe damage with splash
                    else
                        -- just aoe damage
                    end
                end
            else
                if m.only_on_target then
                    if IsUnitInRangeXY(target, start_x, start_y, m.radius) then

                        if #m.sound_on_hit > 0 then
                            AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y)
                        end
                        -- damage
                    end
                else
                    -- damage
                    if m.penetrate ~= nil and not m.penetrate then

                    end
                end
            end


        end)

    end


    function ThrowMissileBySkill(from, target, skill_id, start_x, start_y, end_x, end_y, angle)

    end



end