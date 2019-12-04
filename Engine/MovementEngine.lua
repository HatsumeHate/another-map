do

    local PERIOD = 0.025
    local MapArea





    local function DestroyMissile(target, effect, missile, x, y)
        DestroyEffect(effect)
        DestroyTimer(GetExpiredTimer())

        if #missile.sound_on_hit > 0 then
            AddSound(missile.sound_on_hit[GetRandomInt(1, #missile.sound_on_hit)], x, y)
        end

        if missile.effect_on_target ~= nil and target ~= nil then
            local new_effect = AddSpecialEffectTarget(missile.effect_on_target, target, missile.effect_on_target_point)
            DestroyEffect(new_effect)
        end
    end


    local function GetDamageValues(unit_data, weapon, effects, missile)
        local damage_table = { range = 0., damage = 0, attribute = nil, damagetype = nil, targets = 1 }

        if weapon ~= nil then
            damage_table.targets = weapon.MAX_TARGETS
            damage_table.damage = unit_data.equip_point[WEAPON_POINT].DAMAGE
            damage_table.attribute = unit_data.equip_point[WEAPON_POINT].ATTRIBUTE
            damage_table.damagetype = unit_data.equip_point[WEAPON_POINT].DAMAGE_TYPE

            if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then
                damage_table.damage = damage_table.damage + unit_data.stats[PHYSICAL_ATTACK].value
            elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then
                damage_table.damage = damage_table.damage + unit_data.stats[MAGICAL_ATTACK].value
            end

            damage_table.range = weapon.range
        elseif effects ~= nil then
            damage_table.targets = effects.max_targets
            damage_table.damage = effects.power
            damage_table.damagetype = effects.damage_type

            if effects.get_attack_bonus then
                if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then
                    damage_table.damage = damage_table.damage + unit_data.stats[PHYSICAL_ATTACK].value
                elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then
                    damage_table.damage = damage_table.damage + unit_data.stats[MAGICAL_ATTACK].value
                end
            end

            if effects.attack_percent_bonus ~= nil then
                damage_table.damage = damage_table.damage + (unit_data.equip_point[WEAPON_POINT].DAMAGE * effects.attack_percent_bonus)
            end

            damage_table.attribute = effects.attribute
            damage_table.range = effects.area_of_effect ~= nil and effects.area_of_effect or missile.radius
        end

        return damage_table
    end


    function IsMapBounds(x, y)
        return (x > GetRectMaxX(bj_mapInitialPlayableArea) or x < GetRectMinX(bj_mapInitialPlayableArea) or y > GetRectMaxY(bj_mapInitialPlayableArea) or y < GetRectMinY(bj_mapInitialPlayableArea))
    end



    function ThrowMissile(from, target, missile, effects, start_x, start_y, end_x, end_y, angle)
        local unit_data = GetUnitData(from)
        local m = GetMissileData(missile)
        local end_z
        local start_z

        if m ~= nil then
            end_z = GetZ(end_x, end_y) + m.end_z
            start_z = GetZ(start_x, start_y) + m.start_z
        end

        local time = 0.
        local weapon

                if m == nil then
                    weapon = {}
                    MergeTables(weapon, unit_data.equip_point[WEAPON_POINT])
                    m = GetMissileData(unit_data.equip_point[WEAPON_POINT].missile)
                    end_z = GetZ(end_x, end_y) + m.end_z
                    start_z = GetZ(start_x, start_y) + m.start_z
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


        print(angle)

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

        if m.arc > 0. then
            distance2d = DistanceBetweenXY(start_x, start_y, end_x, end_y)
            height = distance2d * m.arc + RMaxBJ(start_z, end_z)
            step = m.speed / (1. / PERIOD)
            start_height = start_z
            end_height = end_z
            time = time * (1. + m.arc)
        end


        local vx = (end_x - start_x) * ((m.speed * PERIOD) / distance)
        local vy = (end_y - start_y) * ((m.speed * PERIOD) / distance)
        local vz = (end_z - start_z) * ((m.speed * PERIOD) / distance)

        local impact = false


        local my_timer = CreateTimer()
        TimerStart(my_timer, PERIOD, true, function()

            if IsMapBounds(start_x, start_y) or time < 0. then
                print("BOUNDS")
                DestroyEffect(missile_effect)
                DestroyTimer(my_timer)
            else
                --TRACKING
                if m.trackable then
                    print("TRACKABLE")
                    if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 or target == nil then
                        -- disable
                        DestroyEffect(missile_effect)
                        DestroyTimer(my_timer)
                    else
                        distance = GetDistance3D(start_x, start_y, start_z, GetUnitX(target), GetUnitY(target), BlzGetLocalUnitZ(target))
                        vx = (GetUnitX(target) - start_x) * ((m.speed * PERIOD) / distance)
                        vy = (GetUnitY(target) - start_y) * ((m.speed * PERIOD) / distance)
                        vz = (BlzGetLocalUnitZ(target) - start_z) * ((m.speed * PERIOD) / distance)
                        BlzSetSpecialEffectYaw(missile_effect, AngleBetweenXY(start_x, start_y, GetUnitX(target), GetUnitY(target)))
                    end
                end

                -- COLLISION
                if BlzGetLocalSpecialEffectZ(missile_effect) <= GetZ(start_x, start_y) and not m.ignore_terrain then
                    DestroyEffect(missile_effect)
                    DestroyTimer(my_timer)
                    impact = true
                    print("collision")
                else

                    start_x = start_x + vx
                    start_y = start_y + vy

                    if m.arc > 0. then
                        local old_z = start_z
                        start_z = GetParabolaZ(start_height, end_height, height, distance2d, length)
                        local zDiff = start_z - old_z
                        local speed_step = m.speed * PERIOD
                        local pitch = zDiff > 0. and math.atan(speed_step / zDiff) - math.pi / 2. or math.atan(-zDiff / speed_step) - math.pi * 2.
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
                        -- aoe damage with splash
                        local enemy_group = CreateGroup()

                        if #m.sound_on_hit > 0 then
                            AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y)
                        end

                        GroupEnumUnitsInRange(enemy_group, start_x, start_y, weapon.radius, nil)

                        -- loop
                        GroupClear(enemy_group)
                        DestroyGroup(enemy_group)

                    else
                        -- aoe damage
                        DestroyEffect(missile_effect)
                        DestroyTimer(my_timer)

                        if #m.sound_on_hit > 0 then
                            AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y)
                        end

                        if weapon ~= nil then
                            local group = CreateGroup()
                            local player_entity = GetOwningPlayer(from)
                            local damage_list = GetDamageValues(unit_data, weapon, effects, m)
                            GroupEnumUnitsInRange(group, start_x, start_y, damage_list.range, nil)

                                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(group, index)

                                    if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then

                                        if m.effect_on_target ~= nil then
                                            local new_effect = AddSpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point)
                                            DestroyEffect(new_effect)
                                        end

                                        DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, false, nil)
                                        damage_list.targets = damage_list.targets - 1
                                        if damage_list.targets <= 0 then break end
                                    end

                                end

                            GroupClear(group)
                            DestroyGroup(group)
                            damage_list = nil
                        else
                            if effects ~= nil then ApplyEffect(from, nil, start_x, start_y, effects.effect, effects.level) end
                        end

                    end
                end
            else
                if m.only_on_target then
                    -- seeking
                    if IsUnitInRangeXY(target, start_x, start_y, m.radius) then

                        print("hit")
                        DestroyMissile(target, missile_effect, m, start_x, start_y)


                        if m.effect_on_target ~= nil then
                            local new_effect = AddSpecialEffectTarget(m.effect_on_target, target, m.effect_on_target_point)
                            DestroyEffect(new_effect)
                        end

                        if weapon ~= nil then
                            local damage_list = GetDamageValues(unit_data, weapon, effects, m)
                            DamageUnit(from, target, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, false, nil)

                            if damage_list.targets > 1 or damage_list.range > 0 then
                                local group = CreateGroup()
                                local player_entity = GetOwningPlayer(from)
                                GroupEnumUnitsInRange(group, start_x, start_y, damage_list.range, nil)
                                GroupRemoveUnit(group, target)

                                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(group, index)

                                        if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then

                                            if m.effect_on_target ~= nil then
                                                local new_effect = AddSpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point)
                                                DestroyEffect(new_effect)
                                            end

                                            DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, false, nil)
                                            damage_list.targets = damage_list.targets - 1
                                            if damage_list.targets <= 0 then break end
                                        end

                                    end

                                GroupClear(group)
                                DestroyGroup(group)
                            end

                            damage_list = nil
                        else
                            if effects ~= nil then ApplyEffect(from, target, start_x, start_y, effects.effect, effects.level) end
                        end

                    end
                else
                    -- first target hit
                    local group = CreateGroup()
                    local player_entity = GetOwningPlayer(from)
                    GroupEnumUnitsInRange(group, start_x, start_y, m.radius, nil)

                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                        local picked = BlzGroupUnitAt(group, index)
                            if not (IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045) then
                                GroupRemoveUnit(group, picked)
                            end
                    end

                    if BlzGroupGetSize(group) > 0 then
                        if m.penetrate ~= nil and not m.penetrate then
                            print("first hit")

                            DestroyEffect(missile_effect)
                            DestroyTimer(my_timer)
                        end

                            if #m.sound_on_hit > 0 then
                                AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y)
                            end

                            if weapon ~= nil then
                                local damage_list = GetDamageValues(unit_data, weapon, effects, m)

                                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(group, index)

                                        if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then

                                            if m.effect_on_target ~= nil then
                                                local new_effect = AddSpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point)
                                                DestroyEffect(new_effect)
                                            end

                                            DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, false, nil)
                                            damage_list.targets = damage_list.targets - 1
                                            if damage_list.targets <= 0 then break end
                                        end

                                    end

                                damage_list = nil
                            else
                                if effects ~= nil then ApplyEffect(from, target, start_x, start_y, effects.effect, effects.level) end
                            end

                        GroupClear(group)
                    end

                    DestroyGroup(group)
                end
            end

        end)

    end


    --function ThrowMissileBySkill(from, target, skill_id, start_x, start_y, end_x, end_y, angle)

    --end



end