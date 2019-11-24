do

    local PERIOD = 0.025
    local step_offset = 2.5







    function IsMapBounds(x, y)
        return (x > GetRectMaxX(bj_mapInitialPlayableArea) or
        x < GetRectMinX(bj_mapInitialPlayableArea) or
        y > GetRectMaxY(bj_mapInitialPlayableArea) or
        y < GetRectMinY(bj_mapInitialPlayableArea))
    end



    function ThrowMissile(from, target, missile, start_x, start_y, end_x, end_y, angle)
        local m = GetMissileData(missile)
        local end_z
        local start_z = GetZ(start_x, start_y) + GetUnitFlyHeight(from) + m.start_z
        local time = 0.

            print(1)
            end_z = GetZ(end_x, end_y) + m.start_z + m.end_z

            if angle == 0. then angle = AngleBetweenXY_DEG(start_x, start_y, end_x, end_y) end

            print(2)
            if (target ~= nil and not m.full_distance) then
                end_x = GetUnitX(target)
                end_y = GetUnitY(target)
                end_z = GetZ(end_x, end_y) + GetUnitFlyHeight(target) + m.start_z + m.end_z
                angle = AngleBetweenUnits(from, target)
            elseif m.full_distance then
                end_x = start_x + Rx(m.max_distance, angle)
                end_y = start_y + Ry(m.max_distance, angle)

            end

        time = TimeBetweenXY(start_x, start_y, end_x, end_y, m.speed)
        print(3)
        local distance = SquareRoot((end_x-start_x)*(end_x-start_x) + (end_y-start_y)*(end_y-start_y) + (end_z - start_z)*(end_z - start_z))
        local target_height = m.start_z + m.end_z

        print(4)
        local missile_effect = AddSpecialEffect(m.model, start_x, start_y)
        BlzSetSpecialEffectHeight(missile_effect, start_z)
        BlzSetSpecialEffectScale(missile_effect, m.scale)
        BlzSetSpecialEffectYaw(missile_effect, angle * bj_DEGTORAD)
        print(5)

        if #m.sound_on_launch > 0 then
            print("before")
            AddSound(m.sound_on_launch[GetRandomInt(1, #m.sound_on_launch)], start_x, start_y)
            print("after")
        end

        print(6)
        local z_buffer
        local start_step_z
        local step = 0.

        if m.arc ~= nil then
            z_buffer = (m.start_z-end_z) / ( (DistanceBetweenXY(start_x, start_y, end_x, end_y) / m.speed) / PERIOD )
            start_step_z = z_buffer
        end
        print(7)


        local vx = (end_x - start_x) * ((m.speed * PERIOD) / distance)
        local vy = (end_y - start_y) * ((m.speed * PERIOD) / distance)
        local vz = (end_z - start_z) * ((m.speed * PERIOD) / distance)

        print(8)

        TimerStart(CreateTimer(), PERIOD, true, function()

            if IsMapBounds(start_x, start_y) then
                DestroyEffect(missile_effect)
                --BlzPlaySpecialEffect(missile_effect, ANIM_TYPE_DEATH)
                DestroyTimer(GetExpiredTimer())
                print("BOUNDS")
            else
                local z = BlzGetLocalSpecialEffectZ(missile_effect) + GetZ(start_x, start_y)
                --print(z)
                --TRACKING
                if m.trackable ~= nil and m.trackable then
                    if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 or target == nil then
                        -- disable
                        DestroyEffect(missile_effect)
                        DestroyTimer(GetExpiredTimer())
                    else
                        distance = GetDistance3D(start_x, start_y, start_z, GetUnitX(target), GetUnitY(target), GetUnitZ(target))
                        vx = (GetUnitX(target) - start_x) * ((m.speed * PERIOD) / distance)
                        vy = (GetUnitY(target) - start_y) * ((m.speed * PERIOD) / distance)
                        vz = ((GetUnitZ(target) + target_height) - z) * ((m.speed * PERIOD) / distance)
                    end
                end

                -- Z ARC
                if m.arc ~= nil then
                    z = ParabolaZ(m.arc, distance / 10., step) + ((start_z-z_buffer) - GetZ(start_x, start_y))
                    z_buffer = z_buffer + start_step_z
                    step = step + step_offset
                end

                -- COLLISION
                if z <= 0. and not m.ignore_terrain then
                    DestroyEffect(missile_effect)
                    DestroyTimer(GetExpiredTimer())
                else
                    start_x = start_x + vx
                    start_y = start_y + vy
                    BlzSetSpecialEffectPosition(missile_effect,  start_x, start_y, z + vz)

                    time = time - PERIOD

                    if time < 0. then
                        DestroyEffect(missile_effect)
                        DestroyTimer(GetExpiredTimer())
                    end

                    --Z MOVEMENT
                    if  m.arc ~= nil then
                        BlzSetSpecialEffectHeight(missile_effect, z)
                    end

                end


            end


        end)

    end


    function ThrowMissileBySkill(from, target, skill_id, start_x, start_y, end_x, end_y, angle)

    end



end