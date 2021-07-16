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


    local function GetDamageValues(weapon, effects, missile)
        local damage_table = { range = 0., damage = 0, attribute = nil, damagetype = nil, targets = 1 }

        if weapon then
            damage_table.targets = weapon.MAX_TARGETS or 1
            damage_table.damage = weapon.DAMAGE or 0
            damage_table.attribute = weapon.ATTRIBUTE or PHYSICAL_ATTRIBUTE
            damage_table.damagetype = weapon.DAMAGE_TYPE or nil

            if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then damage_table.damage = weapon.bonus_phys_attack end
            --elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then damage_table.damage = damage_table.damage + unit_data.stats[MAGICAL_ATTACK].value end

            damage_table.range = weapon.range or 90.
        elseif effects then
            damage_table.targets = effects.max_targets or 1
            damage_table.damage = effects.power or 0
            damage_table.damagetype = effects.damage_type or nil

            if effects.get_attack_bonus then
                if damage_table.damagetype == DAMAGE_TYPE_PHYSICAL then damage_table.damage = damage_table.damage + weapon.bonus_phys_attack
                elseif damage_table.damagetype == DAMAGE_TYPE_MAGICAL then damage_table.damage = damage_table.damage + weapon.bonus_mag_attack end
            end

            if effects.attack_percent_bonus and effects.attack_percent_bonus > 0. then
                damage_table.damage = damage_table.damage + (weapon.DAMAGE * effects.attack_percent_bonus)
            end

            damage_table.attribute = effects.attribute or PHYSICAL_ATTRIBUTE
            damage_table.range = effects.area_of_effect and effects.area_of_effect or missile.radius
        end

        return damage_table
    end


    local function IsMapBounds(x, y)
        return (x > GetRectMaxX(bj_mapInitialPlayableArea) or x < GetRectMinX(bj_mapInitialPlayableArea) or y > GetRectMaxY(bj_mapInitialPlayableArea) or y < GetRectMinY(bj_mapInitialPlayableArea))
    end



    ---@param missile table
    ---@param angle real
    function RedirectMissile_Deg(missile, angle)

        if not (missile.time > 0.) then
            return
        end

        local x = missile.current_x
        local y = missile.current_y
        local z = missile.current_z
        local distance = GetDistance3D(x, y, z, missile.end_point_x, missile.end_point_y, missile.end_point_z)

        --AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl", x, y)


            missile.end_point_x = x + (distance * Cos(angle * bj_DEGTORAD))
            missile.end_point_y = y + (distance * Sin(angle * bj_DEGTORAD))
            missile.end_point_z = GetZ(missile.end_point_x, missile.end_point_y) + missile.end_z

            if missile.lightning_id then
                missile.lightnings[#missile.lightnings].increment = false
                missile.lightnings[#missile.lightnings].time = missile.lightnings[#missile.lightnings].length / missile.speed

                missile.lightnings[#missile.lightnings + 1] = {
                    sprite = AddLightningEx(missile.lightning_id, true, x, y, z, x, y, z),
                    head_x = x,
                    head_y = y,
                    head_z = z,
                    tail_x = x,
                    tail_y = y,
                    tail_z = z,
                    time = distance / missile.speed,
                    increment = true,
                    length = 0.
                }

            end

            missile.distance = distance

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



    local PullList = {}

    ---@param source unit
    ---@param target unit
    ---@param speed number
    ---@param release_range number
    ---@param power number
    ---@param sign string
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


    local ChargeList = {}


    ---@param source unit
    ---@param speed number
    ---@param distance number
    ---@param angle number
    ---@param max_targets number
    ---@param radius number
    ---@param animation string
    ---@param sign string
    function ChargeUnit(source, speed, distance, angle, max_targets, radius, animation, sign, sfx)
        local charge_data = {}
        local h = GetHandleId(source)


        if ChargeList[h] then
            local velocity = (speed * PERIOD) / distance

                charge_data.point_x = GetUnitX(source) + Rx(distance, angle)
                charge_data.point_y = GetUnitY(source) + Ry(distance, angle)
                ChargeList[h].vx = (charge_data.point_x - GetUnitX(source)) * velocity
                ChargeList[h].vy = (charge_data.point_y - GetUnitY(source)) * velocity
                charge_data = nil

            return
        end

            ChargeList[h] = charge_data
            local velocity = (speed * PERIOD) / distance
            charge_data.point_x = GetUnitX(source) + Rx(distance, angle)
            charge_data.point_y = GetUnitY(source) + Ry(distance, angle)
            charge_data.vx = (charge_data.point_x - GetUnitX(source)) * velocity
            charge_data.vy = (charge_data.point_y - GetUnitY(source)) * velocity
            local targets_hit = 0
            local enemy_group = CreateGroup()
            local player_entity = GetOwningPlayer(source)
            SafePauseUnit(source, true)


            if sfx then
                charge_data.effect = AddSpecialEffectTarget(sfx.effect, source, sfx.point or "chest")
                BlzSetSpecialEffectScale(charge_data.effect, sfx.scale or 1.)
            end


        --print("a")

            TimerStart(CreateTimer(), PERIOD, true, function()
               -- print("atick")
                local state = HasAnyDisableState(source)
                if IsUnitInRangeXY(source, charge_data.point_x, charge_data.point_y, 10.) or GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or state or not IsPathable_Ground(GetUnitX(source) + charge_data.vx, GetUnitY(source) + charge_data.vy) then
                    --print("end")
                    SetUnitAnimation(source, "stand")
                    SafePauseUnit(source, false)
                    OnChargeEnd(source, targets_hit, sign, state)
                    DestroyEffect(charge_data.effect)
                    charge_data = nil
                    ChargeList[h] = nil
                    DestroyTimer(GetExpiredTimer())
                    DestroyGroup(enemy_group)
                elseif max_targets and GetUnitState(source, UNIT_STATE_LIFE) > 0.045 and not state then
                    GroupEnumUnitsInRange(enemy_group, GetUnitX(source), GetUnitY(source), radius, nil)

                        for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                            local picked = BlzGroupUnitAt(enemy_group, index)

                                if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then
                                    local endcharge = OnChargeHit(source, picked, sign)
                                    targets_hit = targets_hit + 1
                                    max_targets = max_targets - 1
                                    if max_targets <= 0 or endcharge then
                                        SafePauseUnit(source, false)
                                        OnChargeEnd(source, targets_hit, sign, state)
                                        DestroyEffect(charge_data.effect)
                                        charge_data = nil
                                        ChargeList[h] = nil
                                        DestroyTimer(GetExpiredTimer())
                                        DestroyGroup(enemy_group)
                                        break
                                    end
                                end

                        end

                    SetUnitAnimation(source, animation)
                    SetUnitX(source, GetUnitX(source) + charge_data.vx)
                    SetUnitY(source, GetUnitY(source) + charge_data.vy)
                    --charge_data.current_distance  = charge_data.current_distance + velocity

                else
                    SetUnitAnimation(source, animation)
                    SetUnitX(source, GetUnitX(source) + charge_data.vx)
                    SetUnitY(source, GetUnitY(source) + charge_data.vy)
                    --harge_data.current_distance  = charge_data.current_distance + velocity
                end
            end)

    end



    function MakeUnitJump(target, angle, x, y, speed, arc, sign, sfx)
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

        SafePauseUnit(target, true)

        local effect

        if sfx then
            effect = AddSpecialEffectTarget(sfx.effect, target, sfx.point or "chest")
            BlzSetSpecialEffectScale(effect, sfx.scale or 1.)
        end

        --BlzPauseUnitEx(target, true)

        TimerStart(CreateTimer(), PERIOD, true, function ()

            if IsMapBounds(unit_x, unit_y) or time <= 0. then
                --print("total jump distance was "..DistanceBetweenUnitXY(target, start_x, start_y))
                OnJumpExpire(target, sign)
                SafePauseUnit(target, false)
                --if GetUnitAbilityLevel(target, FourCC("A01M")) > 0 then BlzPauseUnitEx(target, false) end
                --BlzPauseUnitEx(target, false)
                SetUnitFlyHeight(target, 0., 0.)
                DestroyTimer(GetExpiredTimer())
                if effect then
                    DestroyEffect(effect)
                end
            else
                -- COLLISION

                local current_z = GetZ(unit_x, unit_y)

                if current_z + GetUnitFlyHeight(target) <= current_z + 1. and safe_time < 0. then
                    time = 0.
                else

                    if IsPathable_Air(unit_x + vx, unit_y + vy) then
                        unit_x = unit_x + vx
                        unit_y = unit_y + vy
                        SetUnitX(target, unit_x)
                        SetUnitY(target, unit_y)
                    end

                    unit_z = GetParabolaZ(start_height, end_height, height, distance, length)
                    length = length + step

                    SetUnitFlyHeight(target, unit_z - current_z, 0.)


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

        SafePauseUnit(target, true)

            TimerStart(push_data.timer, PERIOD, true, function()
                if IsMapBounds(push_data.x, push_data.y) or push_data.time < 0. then
                    SafePauseUnit(target, false)
                    OnPushExpire(target, push_data)
                    PushList[handle] = nil
                    --if GetUnitAbilityLevel(target, FourCC("A01M")) > 0 then BlzPauseUnitEx(target, false) end
                    --BlzPauseUnitEx(target, false)
                    DestroyTimer(push_data.timer)
                else
                    --BlzPauseUnitEx(target, true)
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







    function MoveMyLightning(m, target_x, target_y, target_z)
        --print("num of l " .. #m.lightnings)
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
                --print("increment")
            end

            if not m.lightnings[i].increment and i == 1 then
                m.lightnings[i].tail_x = m.lightnings[i].tail_x + m.lightnings[i].vector_x
                m.lightnings[i].tail_y = m.lightnings[i].tail_y + m.lightnings[i].vector_y
                m.lightnings[i].tail_z = m.lightnings[i].tail_z + m.lightnings[i].vector_z
                m.lightnings[i].time = m.lightnings[i].time - PERIOD
                --print("not increment")
            end

            MoveLightningEx(m.lightnings[i].sprite, true, m.lightnings[i].head_x, m.lightnings[i].head_y, m.lightnings[i].head_z, m.lightnings[i].tail_x, m.lightnings[i].tail_y, m.lightnings[i].tail_z)

        end


        for i = 1, #m.lightnings do
            if m.lightnings[i] and m.lightnings[i].time <= 0. and not m.lightnings[i].increment then
                DestroyLightning(m.lightnings[i].sprite)
                table.remove(m.lightnings, i)

                --for t = 1, #m.lightnings do
                    --if m.lightnings[t] == m.lightnings[i] then
                        --table.remove(m.lightnings, t)
                    --end
                --end

            end
        end

    end


    function RepositionMissile(m, new_x, new_y, bonus_z)

        m.current_x = new_x
        m.current_y = new_y
        m.current_z = GetZ(new_x, new_y) + m.start_z + bonus_z

        BlzSetSpecialEffectPosition(m.my_missile,  m.current_x, m.current_y, m.current_z)
        if m.attached_sound then SetSoundPosition(m.attached_sound, m.current_x, m.current_y, m.current_z) end


        local distance = SquareRoot((m.end_point_x-m.current_x)*(m.end_point_x-m.current_x) + (m.end_point_y-m.current_y)*(m.end_point_y-m.current_y) + (m.end_point_z - m.current_z)*(m.end_point_z - m.current_z))
        m.distance = distance
        m.time = distance / m.speed

        --GetZ(m.current_x, m.current_y) + m.start_z
        BlzSetSpecialEffectZ(m.my_missile, m.current_z)


        local distance2d
        local height
        local length = 0.
        local step
        local start_height
        local end_height


        if m.arc and m.arc > 0. then
            distance2d = DistanceBetweenXY(m.current_x, m.current_y, m.end_point_x, m.end_point_y)
            height = distance2d * m.arc + RMaxBJ(m.current_z, m.end_point_z)
            step = m.speed / (1. / PERIOD)
            start_height = m.current_z
            end_height = m.end_point_z
            m.time = m.time * (1. + m.arc)
        end

        local velocity = (m.speed * PERIOD) / distance
        m.vx = (m.end_point_x - m.current_x) * velocity
        m.vy = (m.end_point_y - m.current_y) * velocity
        m.vz = (m.end_point_z - m.current_z) * velocity

        if m.lightnings then
            m.lightnings[#m.lightnings].vector_x = m.vx
            m.lightnings[#m.lightnings].vector_y = m.vy
            m.lightnings[#m.lightnings].vector_z = m.vz
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
    function ThrowMissile(from, target, missile, effects, start_x, start_y, end_x, end_y, angle, from_unit)
        local unit_data = GetUnitData(from)
        local m
        local end_z
        local start_z = 0.
        local weapon

        if not unit_data then return end

        if angle == 0. then angle = AngleBetweenXY_DEG(start_x, start_y, end_x, end_y)
        elseif target then angle = AngleBetweenUnits(from, target) end

        if from_unit and unit_data.missile_eject_range then
            start_x = start_x + Rx(unit_data.missile_eject_range, GetUnitFacing(from) - (unit_data.missile_eject_angle or 0.))
            start_y = start_y + Ry(unit_data.missile_eject_range, GetUnitFacing(from) - (unit_data.missile_eject_angle or 0.))
            start_z = GetUnitFlyHeight(from)
        end

            if missile then
                m = GetMissileData(missile)
                end_z = GetZ(end_x, end_y) + m.end_z
                start_z = start_z + GetZ(start_x, start_y) + m.start_z
                m = MergeTables({}, m)
            elseif unit_data.equip_point[WEAPON_POINT] and unit_data.equip_point[WEAPON_POINT].missile then
                weapon = MergeTables({}, unit_data.equip_point[WEAPON_POINT])
                weapon.bonus_phys_attack = unit_data.stats[PHYSICAL_ATTACK].value
                weapon.bonus_mag_attack = unit_data.stats[MAGICAL_ATTACK].value
                m = MergeTables({}, GetMissileData(unit_data.equip_point[WEAPON_POINT].missile))
                end_z = GetZ(end_x, end_y) + m.end_z
                start_z = start_z + GetZ(start_x, start_y) + m.start_z
            else
                return
            end


        m.time = 0.
--print("a000")


            if (target and not m.full_distance) then
                end_x = GetUnitX(target)
                end_y = GetUnitY(target)
                end_z = GetZ(end_x, end_y) + m.end_z
                angle = AngleBetweenUnits(from, target)
            elseif m.full_distance then
                end_x = start_x + Rx(m.max_distance, angle)
                end_y = start_y + Ry(m.max_distance, angle)
                end_z = GetZ(end_x, end_y) + m.end_z
            end

--print("a00")
        m.end_point_x = end_x
        m.end_point_y = end_y
        m.end_point_z = end_z

        local distance = SquareRoot((end_x-start_x)*(end_x-start_x) + (end_y-start_y)*(end_y-start_y) + (end_z - start_z)*(end_z - start_z))
        m.distance = distance
        m.time = distance / m.speed
--print("a0")
        local missile_effect = AddSpecialEffect(m.model, start_x, start_y)
        m.my_missile = missile_effect
        --BlzSetSpecialEffectHeight(missile_effect, start_z)
        BlzSetSpecialEffectZ(missile_effect, start_z)
        BlzSetSpecialEffectScale(missile_effect, m.scale or 1.)
        BlzSetSpecialEffectYaw(missile_effect, angle * bj_DEGTORAD)

        if m.lightning_id then
            m.lightnings = {}
            m.lightnings[1] = {
                sprite = AddLightningEx(m.lightning_id, true, start_x, start_y, start_z, start_x, start_y, start_z),
                head_x = start_x,
                head_y = start_y,
                head_z = start_z,
                tail_x = start_x,
                tail_y = start_y,
                tail_z = start_z,
                time = m.time,
                increment = true,
                length = 0.
            }
        end
        --print("a1")

        if m.sound_on_launch and #m.sound_on_launch > 0 then
            AddSound(m.sound_on_launch[GetRandomInt(1, #m.sound_on_launch)], start_x, start_y)
        end

--print("a2")
        if m.sound_on_fly then
            m.attached_sound = CreateNew3DSound(m.sound_on_fly.pack[GetRandomInt(1, #m.sound_on_fly.pack)], start_x, start_y, start_z, m.sound_on_fly.volume, m.sound_on_fly.cutoff, m.sound_on_fly.looping or nil)
            StartSound(m.attached_sound)
        end
        --[[AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl", start_x, start_y)
        AddSpecialEffect("Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl", end_x, end_y)
        CreateUnit(Player(0), FourCC("hpea"), start_x, start_y, angle)]]
--print("a3")
        local distance2d
        local height
        local length = 0.
        local step
        local start_height
        local end_height

        if m.arc and m.arc > 0. then
            distance2d = DistanceBetweenXY(start_x, start_y, end_x, end_y)
            height = distance2d * m.arc + RMaxBJ(start_z, end_z)
            step = m.speed / (1. / PERIOD)
            start_height = start_z
            end_height = end_z
            m.time = m.time * (1. + m.arc)
        end
--print("a4")
        local targets = m.max_targets or 1

        local velocity = (m.speed * PERIOD) / distance
        m.vx = (end_x - start_x) * velocity
        m.vy = (end_y - start_y) * velocity
        m.vz = (end_z - start_z) * velocity
--print("a5")
        if m.lightnings then
            m.lightnings[1].vector_x = m.vx
            m.lightnings[1].vector_y = m.vy
            m.lightnings[1].vector_z = m.vz
        end

        local impact = false
        local hit_group = CreateGroup()
        local my_timer = CreateTimer()

        if m.trackable then
            m.time = m.time * 1.25
        end

        --print("aaaaaaa")
        OnMissileLaunch(from, target, m)
        --print("aaaaaaa")

        m.current_x = start_x
        m.current_y = start_y
        m.current_z = start_z

        TimerStart(my_timer, PERIOD, true, function()

            if not m.pause then
                if IsMapBounds(m.current_x, m.current_y) or m.time <= 0. then
                    --print("BOUNDS")

                    if m.sound_on_destroy and #m.sound_on_destroy > 0 then AddSound(m.sound_on_destroy[GetRandomInt(1, #m.sound_on_destroy)], m.current_x, m.current_y) end
                    if m.effect_on_expire then ApplyEffect(from, nil, m.current_x, m.current_y, m.effect_on_expire, 1) end


                    OnMissileExpire(from, target, m)
                    DestroyEffect(missile_effect)
                    DestroyGroup(hit_group)

                    if m.lightnings then
                        TimerStart(my_timer, PERIOD, true, function ()
                            if m.lightnings == nil or #m.lightnings == 0 then
                                if m.attached_sound then StopSound(m.attached_sound, true, true) end
                                DestroyTimer(my_timer)
                                m = nil
                            else
                                --print("remove")
                                m.lightnings[#m.lightnings].increment = false
                                MoveMyLightning(m, m.current_x, m.current_y, m.current_z)
                            end
                        end)
                    else
                        if m.attached_sound then StopSound(m.attached_sound, true, true) end
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
                            distance = GetDistance3D(m.current_x, m.current_y, m.current_z, GetUnitX(target), GetUnitY(target), m.end_z + GetUnitZ(target))
                            velocity = (m.speed * PERIOD) / distance
                            m.vx = (GetUnitX(target) - m.current_x) * velocity
                            m.vy = (GetUnitY(target) - m.current_y) * velocity
                            m.vz = (m.end_z + GetUnitZ(target) - m.current_z) * velocity
                            BlzSetSpecialEffectYaw(missile_effect, AngleBetweenXY(m.current_x, m.current_y, GetUnitX(target), GetUnitY(target)))
                        end
                    end

                    -- COLLISION
                    if m.current_z <= GetZ(m.current_x, m.current_y) + 1. and not m.ignore_terrain then
                        m.time = 0.
                        impact = true
                        --print("collision")
                    else
                        --print(BlzGetLocalSpecialEffectZ(missile_effect))

                        m.current_x = m.current_x + m.vx
                        m.current_y = m.current_y + m.vy

                        if m.arc > 0. then
                            local old_z = m.current_z
                            m.current_z = GetParabolaZ(start_height, end_height, height, distance2d, length)
                            local zDiff = m.current_z - old_z
                            local speed_step = m.speed * PERIOD
                            local pitch = zDiff > 0. and math.atan(speed_step / zDiff) - math.pi / 2. or math.atan(-zDiff / speed_step) - math.pi * 2.
                            BlzSetSpecialEffectPitch(missile_effect, pitch)
                            length = length + step
                        else
                            m.current_z = m.current_z + m.vz
                        end

                        --m.current_x = m.current_x
                        --m.current_y = m.current_y
                        --m.current_z = m.current_z

                        local bonus_z = 0.
                        if m.ignore_terrain then
                            local current_terrain_z = GetZ(m.current_x, m.current_y)
                            --print("current terrain " .. current_terrain_z)
                            --print("current z " .. BlzGetLocalSpecialEffectZ(missile_effect))
                            --print("z from calc " .. m.current_z)
                            --print("----")
                            if current_terrain_z > m.current_z then
                                bonus_z = current_terrain_z - m.current_z
                            end
                        end

                        BlzSetSpecialEffectPosition(missile_effect,  m.current_x, m.current_y, m.current_z + bonus_z)
                        if m.attached_sound then SetSoundPosition(m.attached_sound, m.current_x, m.current_y, m.current_z) end
                        if m.lightnings then
                            MoveMyLightning(m, m.current_x, m.current_y, m.current_z)
                        end

                        m.time = m.time - PERIOD
                    end
                end
                -- movement end

                --print("a")
                -- DAMAGE
                if m.only_on_impact then
                    if impact then
                        --print("eh?????")
                        -- aoe damage
                        m.time = 0.

                            if m.sound_on_hit and #m.sound_on_hit > 0 then AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], m.current_x, m.current_y) end

                            if weapon then
                                local group = CreateGroup()
                                local player_entity = GetOwningPlayer(from)
                                local damage_list = GetDamageValues(weapon, effects, m)
                                GroupEnumUnitsInRange(group, m.current_x, m.current_y, damage_list.range, nil)

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

                                if m.effect_on_impact then ApplyEffect(from, nil, m.current_x, m.current_y, m.effect_on_impact, 1) end
                                if effects and effects.effect then ApplyEffect(from, nil, m.current_x, m.current_y, effects.effect, effects.level) end

                            end

                        --print("?????????")
                        OnMissileImpact(from, m)
                    end
                else
                    --print("why")
                    if m.only_on_target then
                        -- seeking
                        if IsUnitInRangeXY(target, m.current_x, m.current_y, m.radius) then

                            --print("hit")
                            DestroyMissile(target, missile_effect, m, m.current_x, m.current_y)
                            ApplySpecialEffectTarget(m.effect_on_target, target, m.effect_on_target_point, m.effect_on_target_scale)


                            if weapon then

                                local damage_list = GetDamageValues(weapon, effects, m)
                                DamageUnit(from, target, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                OnMissileHit(from, target, m)

                                    if damage_list.targets > 1 or damage_list.range > 0 then
                                        local group = CreateGroup()
                                        local player_entity = GetOwningPlayer(from)
                                        GroupEnumUnitsInRange(group, m.current_x, m.current_y, damage_list.range, nil)
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

                                if m.effect_on_hit then ApplyEffect(from, target, m.current_x, m.current_y, m.effect_on_hit, 1) end
                                if effects and effects.effect then ApplyEffect(from, target, m.current_x, m.current_y, effects.effect, effects.level) end

                                OnMissileHit(from, target, m)
                            end

                        end
                    elseif m.time > 0. then
                        -- first target hit
                        local group = CreateGroup()
                        local player_entity = GetOwningPlayer(from)
                        GroupEnumUnitsInRange(group, m.current_x, m.current_y, m.radius, nil)

                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(group, index)
                                    if not (IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and not IsUnitInGroup(picked, hit_group)) then
                                        GroupRemoveUnit(group, picked)
                                    end
                            end


                            if BlzGroupGetSize(group) > 0 then

                                --print("MISSILE HIT")

                                    if #m.sound_on_hit > 0 then AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], m.current_x, m.current_y) end

                                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(group, index)

                                        targets = targets - 1
                                        ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)


                                        if weapon then
                                            local damage_list = GetDamageValues(weapon, effects, m)
                                            --print("do damage from a weapon "  .. GetUnitName(from))
                                            DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                            --print("do damage from a  - ok")
                                            damage_list.targets = damage_list.targets - 1

                                                if damage_list.targets <= 0 then
                                                    m.time = 0.
                                                    break
                                                end

                                        end

                                        if effects and effects.effect then ApplyEffect(from, picked, m.current_x, m.current_y, effects.effect, effects.level) end
                                        if m.effect_on_hit then
                                            --print("do damage from an effect " .. GetUnitName(from))
                                            ApplyEffect(from, picked, m.current_x, m.current_y, m.effect_on_hit, 1)
                                            --print("do damage from an effect - ok")
                                        end

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

            end

        end)

        return m
    end


    --function ThrowMissileBySkill(from, target, skill_id, start_x, start_y, end_x, end_y, angle)

    --end



end