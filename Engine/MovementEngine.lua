do

    local PERIOD = 0.025
    local MapArea




    local function ApplySpecialEffectTarget(effect, target, point, scale)
        if effect ~= nil then
            local new_effect = AddSpecialEffectTarget(effect, target, point)
            BlzSetSpecialEffectScale(new_effect, scale or 1.)
            DestroyEffect(new_effect)
        end
    end


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
            damage_table.targets = weapon.MAX_TARGETS or 1
            damage_table.damage = unit_data.equip_point[WEAPON_POINT].DAMAGE or 1
            damage_table.attribute = unit_data.equip_point[WEAPON_POINT].ATTRIBUTE or PHYSICAL_ATTRIBUTE
            damage_table.damagetype = unit_data.equip_point[WEAPON_POINT].DAMAGE_TYPE or nil

            if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then damage_table.damage = damage_table.damage + unit_data.stats[PHYSICAL_ATTACK].value end
            --elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then damage_table.damage = damage_table.damage + unit_data.stats[MAGICAL_ATTACK].value end

            damage_table.range = weapon.range or 90.
        elseif effects ~= nil then
            damage_table.targets = effects.max_targets or 1
            damage_table.damage = effects.power or 0
            damage_table.damagetype = effects.damage_type or nil

            if effects.get_attack_bonus then
                if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then damage_table.damage = damage_table.damage + unit_data.stats[PHYSICAL_ATTACK].value
                elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then damage_table.damage = damage_table.damage + unit_data.stats[MAGICAL_ATTACK].value end
            end

            if effects.attack_percent_bonus ~= nil then
                damage_table.damage = damage_table.damage + (unit_data.equip_point[WEAPON_POINT].DAMAGE * effects.attack_percent_bonus)
            end

            damage_table.attribute = effects.attribute or PHYSICAL_ATTRIBUTE
            damage_table.range = effects.area_of_effect ~= nil and effects.area_of_effect or missile.radius
        end

        return damage_table
    end


    local function IsMapBounds(x, y)
        return (x > GetRectMaxX(bj_mapInitialPlayableArea) or x < GetRectMinX(bj_mapInitialPlayableArea) or y > GetRectMaxY(bj_mapInitialPlayableArea) or y < GetRectMinY(bj_mapInitialPlayableArea))
    end



    ---@param missile table
    ---@param angle real
    function RedirectMissile_Deg(missile, angle)
        local x = missile.current_x
        local y = missile.current_y
        local z = missile.current_z
        local distance = GetDistance3D(x, y, z, missile.end_point_x, missile.end_point_y, missile.end_point_z)

        --AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl", x, y)


            missile.end_point_x = x + (distance * Cos(angle * bj_DEGTORAD))
            missile.end_point_y = y + (distance * Sin(angle * bj_DEGTORAD))
            missile.end_point_z = GetZ(missile.end_point_x, missile.end_point_y) + missile.end_z

            if missile.lightning_id ~= nil then
                missile.lightnings[#missile.lightnings].increment = false
                missile.lightnings[#missile.lightnings + 1] = {
                    sprite = AddLightningEx(missile.lightning_id, true, x, y, z, x, y, z),
                    head_x = x,
                    head_y = y,
                    head_z = z,
                    tail_x = x,
                    tail_y = y,
                    tail_z = z,
                    increment = true,
                    length = 0.
                }

            end

            local velocity = (missile.speed * PERIOD) / distance

            missile.vx = (missile.end_point_x - x) * velocity
            missile.vy = (missile.end_point_y - y) * velocity
            missile.vz = (missile.end_point_z - z) * velocity

            if missile.lightning_id ~= nil then
                missile.lightnings[#missile.lightnings].vector_x = missile.vx
                missile.lightnings[#missile.lightnings].vector_y = missile.vy
                missile.lightnings[#missile.lightnings].vector_z = missile.vz
            end

            --AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl", missile.end_point_x, missile.end_point_y)
            BlzSetSpecialEffectYaw(missile.missile_effect, AngleBetweenXY(x, y, missile.end_point_x, missile.end_point_y))

    end


     --TODO pull
    local PullList = {}

    function PullUnitToUnit(source, target, speed, release_range, power, sign)
        local pull_data = {}
        local h = GetHandleId(source)

        if PullList[h] ~= nil then
            if PullList[h].power < power then
                pull_data.target = target
                pull_data.speed = speed
                pull_data.power = power
                pull_data.release_range = release_range
            end
        end

            PullList[h] = pull_data
            pull_data.target = target
            pull_data.power = power
            pull_data.speed = speed
            pull_data.release_range = release_range
            local velocity = (speed * PERIOD) / DistanceBetweenUnits(source, target)
            pull_data.vx = (GetUnitX(target) - GetUnitX(source)) * velocity
            pull_data.vy = (GetUnitY(target) - GetUnitY(source)) * velocity


            TimerStart(CreateTimer(), PERIOD, true, function()
                if IsUnitInRange(source, pull_data.target, pull_data.release_range) or GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or GetUnitState(pull_data.target, UNIT_STATE_LIFE) < 0.045 then
                    print("break")
                    OnPullRelease(source, pull_data.target, sign)
                    pull_data = nil
                    PullList[h] = nil
                    DestroyTimer(GetExpiredTimer())
                else
                    SetUnitX(source, GetUnitX(source) + pull_data.vx)
                    SetUnitY(source, GetUnitY(source) + pull_data.vy)
                    velocity = (pull_data.speed * PERIOD) / DistanceBetweenUnits(source, pull_data.target)
                    pull_data.vx = (GetUnitX(pull_data.target) - GetUnitX(source)) * velocity
                    pull_data.vy = (GetUnitY(pull_data.target) - GetUnitY(source)) * velocity
                end
            end)

    end


    function MakeUnitJump(target, angle, x, y, speed, arc, sign)
        local unit_x = GetUnitX(target)
        local unit_y = GetUnitY(target)
        local unit_z = GetZ(unit_x, unit_y)
        local endpoint_z = GetZ(x, y)
        local distance = DistanceBetweenXY(unit_x, unit_y, x, y)
        local endpoint_x = unit_x + (distance * Cos(angle * bj_DEGTORAD))
        local endpoint_y = unit_y + (distance * Sin(angle * bj_DEGTORAD))

        local start_x = GetUnitX(target)
        local start_y = GetUnitY(target)

        local velocity = (speed * PERIOD) / distance
        local vx = (endpoint_x - unit_x) * velocity
        local vy = (endpoint_y - unit_y) * velocity


        local height = distance * arc + RMaxBJ(unit_z, endpoint_z)
        local length = 0.
        local step = speed / (1. / PERIOD)
        local start_height = unit_z
        local end_height = endpoint_z
        local time = (speed / distance) * (1. + arc)
        local safe_time = 0.15

        SetUnitFacing(target, angle)

        UnitAddAbility(target, FourCC('Arav'))
        UnitRemoveAbility(target, FourCC('Arav'))

        BlzPauseUnitEx(target, true)

        TimerStart(CreateTimer(), PERIOD, true, function ()

            if IsMapBounds(unit_x, unit_y) or time <= 0. then
                print("total jump distance was "..DistanceBetweenUnitXY(target, start_x, start_y))
                OnJumpExpire(target, sign)
                BlzPauseUnitEx(target, false)
                SetUnitFlyHeight(target, 0., 0.)
                DestroyTimer(GetExpiredTimer())
            else
                -- COLLISION

                local current_z = GetZ(unit_x, unit_y)

                if current_z + GetUnitFlyHeight(target) <= current_z + 1. and safe_time < 0. then
                    time = 0.
                else

                    unit_x = unit_x + vx
                    unit_y = unit_y + vy
                    unit_z = GetParabolaZ(start_height, end_height, height, distance, length)
                    length = length + step

                    SetUnitFlyHeight(target, unit_z - current_z, 0.)
                    SetUnitX(target, unit_x)
                    SetUnitY(target, unit_y)

                    time = time - PERIOD
                    safe_time = safe_time - PERIOD
                end

            end
        end)

    end


    local PushList = {}

    function PushUnit(source, target, angle, power, time, sign)
        local handle = GetHandleId(target)
        local push_data = { x = GetUnitX(target), y = GetUnitY(target), vx = 0., vy = 0. }


        if power <= 0. then
            push_data = nil
            return
        end

        if PushList[handle] ~= nil then
            if PushList[handle].power < power then
                DestroyTimer(push_data.timer)
                PushList[handle] = nil
            else
                push_data = nil
                return
            end
        end

        power = power * 2.

        push_data.source = source
        push_data.sign = sign
        push_data.power = power
        local endpoint_x = push_data.x + (power * Cos(angle * bj_DEGTORAD))
        local endpoint_y = push_data.y + (power * Sin(angle * bj_DEGTORAD))
        local speed = power / time
        push_data.time = time


        local total_time = time
        local penalty = 0.0007
        local multiplicator = 1.03

        local velocity = (speed * PERIOD) / power
        push_data.vx = (endpoint_x - push_data.x) * velocity
        push_data.vy = (endpoint_y - push_data.y) * velocity


        PushList[handle] = push_data
        push_data.timer = CreateTimer()

            TimerStart(push_data.timer, PERIOD, true, function()
                if IsMapBounds(push_data.x, push_data.y) or push_data.time < 0. then
                    OnPushExpire(target, push_data)
                    PushList[handle] = nil
                    BlzPauseUnitEx(target, false)
                    DestroyTimer(push_data.timer)
                else
                    BlzPauseUnitEx(target, true)
                    SetUnitPositionSmooth(target, push_data.x + push_data.vx, push_data.y + push_data.vy)
                    local faderate = 0.1 + (push_data.time / total_time) - penalty

                    penalty = penalty * multiplicator
                    multiplicator = multiplicator + 0.01

                    if faderate < 0.01 then
                        faderate = 0.01
                        push_data.time = 0.
                    end

                    if penalty < 0. then penalty = 0. end

                    push_data.power = push_data.power * faderate
                    push_data.vx = push_data.vx * faderate
                    push_data.vy = push_data.vy * faderate
                    push_data.x = GetUnitX(target)
                    push_data.y = GetUnitY(target)

                    push_data.time = push_data.time - PERIOD
                end
            end)

        return push_data
    end







    function MoveLightning(m, target_x, target_y, target_z)
        for i = 1, #m.lightnings do

            if i == #m.lightnings then
                m.lightnings[i].head_x = target_x
                m.lightnings[i].head_y = target_y
                m.lightnings[i].head_z = target_z
            else
                m.lightnings[i].head_x = m.lightnings[i+1].tail_x
                m.lightnings[i].head_y = m.lightnings[i+1].tail_y
                m.lightnings[i].head_z = m.lightnings[i+1].tail_z
            end

            m.lightnings[i].length = GetDistance3D(m.lightnings[i].head_x, m.lightnings[i].head_y, m.lightnings[i].head_z, m.lightnings[i].tail_x, m.lightnings[i].tail_y, m.lightnings[i].tail_z)

            if m.lightnings[i].increment and m.lightnings[i].length >= m.lightning_length then
                m.lightnings[i].tail_x = m.lightnings[i].tail_x + m.lightnings[i].vector_x
                m.lightnings[i].tail_y = m.lightnings[i].tail_y + m.lightnings[i].vector_y
                m.lightnings[i].tail_z = m.lightnings[i].tail_z + m.lightnings[i].vector_z
            end

            if not m.lightnings[i].increment and i == 1 then
                m.lightnings[i].tail_x = m.lightnings[i].tail_x + m.lightnings[i].vector_x
                m.lightnings[i].tail_y = m.lightnings[i].tail_y + m.lightnings[i].vector_y
                m.lightnings[i].tail_z = m.lightnings[i].tail_z + m.lightnings[i].vector_z
            end

            MoveLightningEx(m.lightnings[i].sprite, true, m.lightnings[i].head_x, m.lightnings[i].head_y, m.lightnings[i].head_z, m.lightnings[i].tail_x, m.lightnings[i].tail_y, m.lightnings[i].tail_z)
        end


        for i = 1, #m.lightnings do
            if m.lightnings[i].length <= 1. and not m.lightnings[i].increment then
                DestroyLightning(m.lightnings[i].sprite)

                for t = 1, #m.lightnings do
                    if m.lightnings[t] == m.lightnings[i] then
                        table.remove(m.lightnings, t)
                    end
                end

            end
        end

    end




    ---@param from unit
    ---@param target unit
    ---@param missile integer
    ---@param effects table
    ---@param start_x real
    ---@param start_y real
    ---@param end_x real
    ---@param end_y real
    ---@param angle real
    function ThrowMissile(from, target, missile, effects, start_x, start_y, end_x, end_y, angle)
        local unit_data = GetUnitData(from)
        local m = GetMissileData(missile or "0000")
        local end_z
        local start_z

        if m ~= nil then
            end_z = GetZ(end_x, end_y) + m.end_z
            start_z = GetZ(start_x, start_y) + m.start_z
        end

        local weapon

            if m == nil then
                if unit_data.equip_point[WEAPON_POINT].missile ~= nil then
                    weapon = MergeTables({}, unit_data.equip_point[WEAPON_POINT])
                    m = MergeTables({}, GetMissileData(unit_data.equip_point[WEAPON_POINT].missile))
                    end_z = GetZ(end_x, end_y) + m.end_z
                    start_z = GetZ(start_x, start_y) + m.start_z
                else
                    return
                end
            else
                m = MergeTables({}, m)
            end

        m.time = 0.

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


        m.end_point_x = end_x
        m.end_point_y = end_y
        m.end_point_z = end_z

        local distance = SquareRoot((end_x-start_x)*(end_x-start_x) + (end_y-start_y)*(end_y-start_y) + (end_z - start_z)*(end_z - start_z))
        m.time = distance / m.speed

        local missile_effect = AddSpecialEffect(m.model, start_x, start_y)
        --BlzSetSpecialEffectHeight(missile_effect, start_z)
        BlzSetSpecialEffectZ(missile_effect, start_z)
        BlzSetSpecialEffectScale(missile_effect, m.scale)
        BlzSetSpecialEffectYaw(missile_effect, angle * bj_DEGTORAD)

        if m.lightning_id ~= nil then
            m.lightnings = {}
            m.lightnings[1] = {
                sprite = AddLightningEx(m.lightning_id, true, start_x, start_y, start_z, start_x, start_y, start_z),
                head_x = start_x,
                head_y = start_y,
                head_z = start_z,
                tail_x = start_x,
                tail_y = start_y,
                tail_z = start_z,
                increment = true,
                length = 0.
            }
        end


        if #m.sound_on_launch > 0 then
            AddSound(m.sound_on_launch[GetRandomInt(1, #m.sound_on_launch)], start_x, start_y)
        end


        if m.sound_on_fly ~= nil then
            m.attached_sound = CreateNew3DSound(m.sound_on_fly.pack[GetRandomInt(1, #m.sound_on_fly.pack)], start_x, start_y, start_z, m.sound_on_fly.volume, m.sound_on_fly.cutoff, m.sound_on_fly.looping or nil)
            StartSound(m.attached_sound)
        end
        --[[AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl", start_x, start_y)
        AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl", end_x, end_y)
        CreateUnit(Player(0), FourCC("hpea"), start_x, start_y, angle)]]

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
            m.time = m.time * (1. + m.arc)
        end

        local targets = m.max_targets

        local velocity = (m.speed * PERIOD) / distance
        m.vx = (end_x - start_x) * velocity
        m.vy = (end_y - start_y) * velocity
        m.vz = (end_z - start_z) * velocity

        if m.lightnings ~= nil then
            m.lightnings[1].vector_x = m.vx
            m.lightnings[1].vector_y = m.vy
            m.lightnings[1].vector_z = m.vz
        end

        local impact = false
        local hit_group = CreateGroup()
        local my_timer = CreateTimer()


        OnMissileLaunch(from, target, m)


        TimerStart(my_timer, PERIOD, true, function()

            if IsMapBounds(start_x, start_y) or m.time <= 0. then
                print("BOUNDS")

                if #m.sound_on_destroy > 0 then AddSound(m.sound_on_destroy[GetRandomInt(1, #m.sound_on_destroy)], start_x, start_y) end
                if m.effect_on_expire ~= nil then ApplyEffect(from, nil, start_x, start_y, m.effect_on_expire, 1) end
                if m.attached_sound ~= nil then StopSound(m.attached_sound, true, true) end

                OnMissileExpire(from, target, m)
                DestroyEffect(missile_effect)
                DestroyGroup(hit_group)

                if m.lightnings ~= nil then
                        TimerStart(my_timer, PERIOD, true, function ()
                            m.lightnings[#m.lightnings].increment = false
                            MoveLightning(m, start_x, start_y, start_z)
                                if #m.lightnings == nil then
                                    DestroyTimer(my_timer)
                                    m = nil
                                end
                        end)
                    else
                        DestroyTimer(my_timer)
                        m = nil
                    end

            else
                --TRACKING
                if m.trackable then
                    --print("TRACKABLE")
                    if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 or target == nil then
                        m.time = 0.
                    else
                        distance = GetDistance3D(start_x, start_y, start_z, GetUnitX(target), GetUnitY(target), BlzGetLocalUnitZ(target))
                        velocity = (m.speed * PERIOD) / distance
                        m.vx = (GetUnitX(target) - start_x) * velocity
                        m.vy = (GetUnitY(target) - start_y) * velocity
                        m.vz = (BlzGetLocalUnitZ(target) - start_z) * velocity
                        BlzSetSpecialEffectYaw(missile_effect, AngleBetweenXY(start_x, start_y, GetUnitX(target), GetUnitY(target)))
                    end
                end

                -- COLLISION
                if BlzGetLocalSpecialEffectZ(missile_effect) <= GetZ(start_x, start_y) + 1. and not m.ignore_terrain then
                    m.time = 0.
                    impact = true
                    --print("collision")
                else

                    start_x = start_x + m.vx
                    start_y = start_y + m.vy

                    if m.arc > 0. then
                        local old_z = start_z
                        start_z = GetParabolaZ(start_height, end_height, height, distance2d, length)
                        local zDiff = start_z - old_z
                        local speed_step = m.speed * PERIOD
                        local pitch = zDiff > 0. and math.atan(speed_step / zDiff) - math.pi / 2. or math.atan(-zDiff / speed_step) - math.pi * 2.
                        BlzSetSpecialEffectPitch(missile_effect, pitch)
                        length = length + step
                    else
                        start_z = start_z + m.vz
                    end

                    m.current_x = start_x
                    m.current_y = start_y
                    m.current_z = start_z

                    BlzSetSpecialEffectPosition(missile_effect,  start_x, start_y, start_z)
                    if m.attached_sound ~= nil then SetSoundPosition(m.attached_sound, start_x, start_y, start_z) end
                    if m.lightnings ~= nil then MoveLightning(m, start_x, start_y, start_z) end

                    m.time = m.time - PERIOD
                end
            end
            -- movement end


            -- DAMAGE
            if m.only_on_impact then
                if impact then
                    -- aoe damage
                    m.time = 0.

                        if #m.sound_on_hit > 0 then AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y) end

                        if weapon ~= nil then
                            local group = CreateGroup()
                            local player_entity = GetOwningPlayer(from)
                            local damage_list = GetDamageValues(unit_data, weapon, effects, m)
                            GroupEnumUnitsInRange(group, start_x, start_y, damage_list.range, nil)

                                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(group, index)

                                    if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then

                                        ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)
                                        DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                        OnMissileHit(from, target, m)

                                        damage_list.targets = damage_list.targets - 1
                                        if damage_list.targets <= 0 then break end
                                    end

                                end

                            GroupClear(group)
                            DestroyGroup(group)
                            damage_list = nil
                        else

                            if m.effect_on_impact ~= nil then ApplyEffect(from, nil, start_x, start_y, m.effect_on_impact, 1) end
                            if effects ~= nil and effects.effect ~= nil then ApplyEffect(from, nil, start_x, start_y, effects.effect, effects.level) end

                        end

                    OnMissileImpact(from, m)
                end
            else
                if m.only_on_target then
                    -- seeking
                    if IsUnitInRangeXY(target, start_x, start_y, m.radius) then

                        --print("hit")
                        DestroyMissile(target, missile_effect, m, start_x, start_y)
                        ApplySpecialEffectTarget(m.effect_on_target, target, m.effect_on_target_point, m.effect_on_target_scale)


                        if weapon ~= nil then

                            local damage_list = GetDamageValues(unit_data, weapon, effects, m)
                            DamageUnit(from, target, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                            OnMissileHit(from, target, m)

                                if damage_list.targets > 1 or damage_list.range > 0 then
                                    local group = CreateGroup()
                                    local player_entity = GetOwningPlayer(from)
                                    GroupEnumUnitsInRange(group, start_x, start_y, damage_list.range, nil)
                                    GroupRemoveUnit(group, target)

                                        for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                            local picked = BlzGroupUnitAt(group, index)

                                            if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then

                                                ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)
                                                DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                                OnMissileHit(from, target, m)

                                                damage_list.targets = damage_list.targets - 1
                                                if damage_list.targets <= 0 then break end
                                            end

                                        end

                                    GroupClear(group)
                                    DestroyGroup(group)
                                end

                            damage_list = nil
                        else

                            if m.effect_on_hit ~= nil then ApplyEffect(from, target, start_x, start_y, m.effect_on_hit, 1) end
                            if effects ~= nil and effects.effect ~= nil then ApplyEffect(from, target, start_x, start_y, effects.effect, effects.level) end

                        end

                    end
                elseif m.time > 0. then
                    -- first target hit
                    local group = CreateGroup()
                    local player_entity = GetOwningPlayer(from)
                    GroupEnumUnitsInRange(group, start_x, start_y, m.radius, nil)

                        for index = BlzGroupGetSize(group) - 1, 0, -1 do
                            local picked = BlzGroupUnitAt(group, index)
                                if not (IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and not IsUnitInGroup(picked, hit_group)) then
                                    GroupRemoveUnit(group, picked)
                                end
                        end


                        if BlzGroupGetSize(group) > 0 then

                            print("MISSILE HIT")

                                if #m.sound_on_hit > 0 then AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], start_x, start_y) end

                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(group, index)

                                    targets = targets - 1
                                    ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)


                                    if weapon ~= nil then
                                        local damage_list = GetDamageValues(unit_data, weapon, effects, m)
                                        DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                        damage_list.targets = damage_list.targets - 1

                                            if damage_list.targets <= 0 then
                                                m.time = 0.
                                                break
                                            end

                                    end

                                    if effects ~= nil and effects.effect ~= nil then ApplyEffect(from, picked, start_x, start_y, effects.effect, effects.level) end
                                    if m.effect_on_hit ~= nil then ApplyEffect(from, picked, start_x, start_y, m.effect_on_hit, 1) end

                                    OnMissileHit(from, picked, m)

                                        if m.hit_once_in > 0. then
                                            local damaged_unit = picked
                                            GroupAddUnit(hit_group, damaged_unit)
                                            TimerStart(CreateTimer(), m.hit_once_in, false, function()
                                                GroupRemoveUnit(hit_group, damaged_unit)
                                                DestroyTimer(GetExpiredTimer())
                                            end)
                                        end

                                        if targets <= 0 or not m.penetrate then
                                            m.time = 0.
                                            break
                                        end

                            end
                        end

                    GroupClear(group)
                    DestroyGroup(group)
                end
            end

        end)

        return m
    end


    --function ThrowMissileBySkill(from, target, skill_id, start_x, start_y, end_x, end_y, angle)

    --end



end