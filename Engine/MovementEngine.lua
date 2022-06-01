do

    local PERIOD = 0.025
    local MapArea = 0
    local FPS = 1. / PERIOD


    local PullList
    local ChargeList
    local PushList
    local MissileList


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

        if missile.sound_on_hit then
            AddSoundVolume(missile.sound_on_hit.pack[GetRandomInt(1, #missile.sound_on_hit.pack)], missile.current_x, missile.current_y, missile.sound_on_hit.volume or 128, missile.sound_on_hit.cutoff or 1600.)
            --AddSound(missile.sound_on_hit[GetRandomInt(1, #missile.sound_on_hit)], x, y)
        end

        if missile.effect_on_target and target then
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

            damage_table.range = weapon.damage_range or 90.
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



    function BezierCurvePow2_xyz_xyz_xyz(x, y, z, x1, y1, z1, x2, y2, z2, time)
        local a1 = x
        local b1 = 2 * (x1 - x)
        local c1 = x - 2 * x1 + x2
        local a2 = y
        local b2 = 2 * (y1 - y)
        local c2 = y - 2 * y1 + y2
        local a3 = z
        local b3 = 2 * (z1 - z)
        local c3 = z - 2 * z1 + z2
        local x = a1 + (b1 + c1 * time) * time
        local y = a2 + (b2 + c2 * time) * time
        local z = a3 + (b3 + c3 * time) * time
        return x, y, z
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


            missile.end_point_x = x + (distance * math.cos(angle * bj_DEGTORAD))
            missile.end_point_y = y + (distance * math.sin(angle * bj_DEGTORAD))
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
            --BlzSetSpecialEffectYaw(missile.missile_effect, AngleBetweenXY(x, y, missile.end_point_x, missile.end_point_y))
            missile.heading_angle = AngleBetweenXY(x, y, missile.end_point_x, missile.end_point_y)
            BlzSetSpecialEffectOrientation(missile.missile_effect, missile.heading_angle * bj_DEGTORAD, missile.last_pitch or 0., 0.)
    end





    ---@param source unit
    ---@param target unit
    ---@param speed number
    ---@param release_range number
    ---@param power number
    ---@param sign string
    function PullUnitToUnit(source, target, speed, release_range, power, sign)
        local pull_data = {}
        local h = source

        if PullList[h] ~= nil then
            if PullList[h].power < power then
                pull_data.target = target
                pull_data.speed = speed
                pull_data.power = power
                pull_data.release_range = release_range
            end
        end

            ResetUnitSpellCast(target)
            PullList[h] = pull_data
            pull_data.target = target
            pull_data.power = power
            pull_data.speed = speed
            pull_data.release_range = release_range
            local velocity = (speed * PERIOD) / DistanceBetweenUnits(source, target)
            pull_data.vx = (RealGetUnitX(target) - RealGetUnitX(source)) * velocity
            pull_data.vy = (RealGetUnitY(target) - RealGetUnitY(source)) * velocity

            local timer = CreateTimer()
            TimerStart(timer, PERIOD, true, function()
                if IsUnitInRange(source, pull_data.target, pull_data.release_range) or GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or GetUnitState(pull_data.target, UNIT_STATE_LIFE) < 0.045 then
                    OnPullRelease(source, pull_data.target, sign)
                    pull_data = nil
                    PullList[h] = nil
                    DestroyTimer(GetExpiredTimer())
                else
                    SetUnitX(source, RealGetUnitX(source) + pull_data.vx)
                    SetUnitY(source, RealGetUnitY(source) + pull_data.vy)
                    velocity = (pull_data.speed * PERIOD) / DistanceBetweenUnits(source, pull_data.target)
                    pull_data.vx = (RealGetUnitX(pull_data.target) - RealGetUnitX(source)) * velocity
                    pull_data.vy = (RealGetUnitY(pull_data.target) - RealGetUnitY(source)) * velocity
                end
            end)

    end





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
        local h = source


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

            local unit_data = GetUnitData(source)
            if unit_data.channeled_destructor then unit_data.channeled_destructor(unit_data.Owner); unit_data.channeled_destructor = nil end
            SafePauseUnit(source, true)


            if sfx then
                charge_data.effect = AddSpecialEffectTarget(sfx.effect, source, sfx.point or "chest")
                BlzSetSpecialEffectScale(charge_data.effect, sfx.scale or 1.)
            end


        --print("a")
            local timer = CreateTimer()
            TimerStart(timer, PERIOD, true, function()
               --print("tick")
                local state = HasAnyDisableState(source)

                if IsUnitInRangeXY(source, charge_data.point_x, charge_data.point_y, 10.) or GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or state or not IsPathable_Ground(GetUnitX(source) + charge_data.vx, GetUnitY(source) + charge_data.vy) then
                    --print("end")
                    SetUnitAnimation(source, "stand")
                    if not (IsUnitStunned(source) or IsUnitFrozen(source)) then SafePauseUnit(source, false) end
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

                                if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                    local endcharge = OnChargeHit(source, picked, sign)
                                    targets_hit = targets_hit + 1
                                    max_targets = max_targets - 1
                                    if max_targets <= 0 or endcharge then
                                        if not (IsUnitStunned(source) or IsUnitFrozen(source)) then SafePauseUnit(source, false) end
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
                    SetUnitX(source, RealGetUnitX(source) + charge_data.vx)
                    SetUnitY(source, RealGetUnitY(source) + charge_data.vy)
                    --charge_data.current_distance  = charge_data.current_distance + velocity

                else
                    SetUnitAnimation(source, animation)
                    SetUnitX(source, RealGetUnitX(source) + charge_data.vx)
                    SetUnitY(source, RealGetUnitY(source) + charge_data.vy)
                    --harge_data.current_distance  = charge_data.current_distance + velocity
                end
            end)

    end




    ---@param target unit
    ---@param angle real
    ---@param x real
    ---@param y real
    ---@param speed real
    ---@param arc real
    ---@param sign string
    ---@param sfx table
    function MakeUnitJump(target, angle, x, y, speed, arc, sign, sfx)
        local unit_x = GetUnitX(target)
        local unit_y = GetUnitY(target)
        local unit_z = GetZ(unit_x, unit_y)
        local endpoint_z = GetZ(x, y)
        local distance = DistanceBetweenXY(unit_x, unit_y, x, y)
        local endpoint_x = unit_x + (distance * math.cos(angle * bj_DEGTORAD))
        local endpoint_y = unit_y + (distance * math.sin(angle * bj_DEGTORAD))

        local start_x = GetUnitX(target)
        local start_y = GetUnitY(target)

        local velocity = (speed * PERIOD) / distance
        local vx = (endpoint_x - unit_x) * velocity
        local vy = (endpoint_y - unit_y) * velocity


        local height = distance * arc + RMaxBJ(unit_z, endpoint_z)
        local length = 0.
        local step = speed / FPS
        local start_height = unit_z
        local end_height = endpoint_z
        local time = (speed / distance) * (1. + arc)
        local safe_time = 0.15

        SetUnitFacing(target, angle)

        UnitAddAbility(target, FourCC('Arav'))
        UnitRemoveAbility(target, FourCC('Arav'))

        local unit_data = GetUnitData(target)
        if unit_data.channeled_destructor then unit_data.channeled_destructor(unit_data.Owner); unit_data.channeled_destructor = nil end
        SafePauseUnit(target, true)

        local effect

        if sfx then
            effect = AddSpecialEffectTarget(sfx.effect, target, sfx.point or "chest")
            BlzSetSpecialEffectScale(effect, sfx.scale or 1.)
        end

        --BlzPauseUnitEx(target, true)
        local timer = CreateTimer()
        TimerStart(timer, PERIOD, true, function ()

            if IsMapBounds(unit_x, unit_y) or time <= 0. then
                --print("total jump distance was "..DistanceBetweenUnitXY(target, start_x, start_y))
                OnJumpExpire(target, sign)
                if not (IsUnitStunned(target) or IsUnitFrozen(target)) then SafePauseUnit(target, false) end
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


    ---@param source unit
    ---@param target unit
    ---@param angle real
    ---@param power real
    ---@param time real
    ---@param sign string
    function PushUnit(source, target, angle, power, time, sign)
        local handle = target
        local unit_data = GetUnitData(target)
        local push_data = { x = RealGetUnitX(target), y = RealGetUnitY(target), vx = 0., vy = 0. }

        power = power * ((100. - unit_data.stats[CONTROL_REDUCTION].value) / 100.)

        if power <= 5. then
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
        local endpoint_x = push_data.x + (power * math.cos(angle * bj_DEGTORAD))
        local endpoint_y = push_data.y + (power * math.sin(angle * bj_DEGTORAD))
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

        ResetUnitSpellCast(target)
        SetUnitAnimation(target, "stand ready")
        SafePauseUnit(target, true)

            TimerStart(push_data.timer, PERIOD, true, function()
                if IsMapBounds(push_data.x, push_data.y) or push_data.time < 0. then
                    DestroyTimer(push_data.timer)
                    if not (IsUnitStunned(unit_data.Owner) or IsUnitFrozen(unit_data.Owner)) then SafePauseUnit(target, false) end
                    OnPushExpire(target, push_data)
                    PushList[handle] = nil
                    --if GetUnitAbilityLevel(target, FourCC("A01M")) > 0 then BlzPauseUnitEx(target, false) end
                    --BlzPauseUnitEx(target, false)
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
                    push_data.x = RealGetUnitX(target)
                    push_data.y = RealGetUnitY(target)

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


    function SetMissileTarget(missile, target)

        missile.target = target
        missile.trackable = true
        local distance = GetDistance3D(missile.current_x, missile.current_y, missile.current_z, GetUnitX(missile.target), GetUnitY(missile.target), missile.end_z + GetUnitZ(missile.target))
        local velocity = (missile.speed * PERIOD) / distance
        missile.vx = (GetUnitX(missile.target) - missile.current_x) * velocity
        missile.vy = (GetUnitY(missile.target) - missile.current_y) * velocity
        missile.vz = (missile.end_z + GetUnitZ(missile.target) - missile.current_z) * velocity
        missile.heading_angle = AngleBetweenXY_DEG(missile.current_x, missile.current_y, GetUnitX(missile.target), GetUnitY(missile.target))
        BlzSetSpecialEffectOrientation(missile.my_missile, missile.heading_angle * bj_DEGTORAD, 0., 0.)

    end


    ---@param m table
    ---@param speed real
    function SetMissileSpeed(m, speed)

        m.speed = speed
        m.time = m.distance / m.speed


        if m.arc and m.arc > 0. then
            m.step = m.speed / FPS
            m.time = m.time * (1. + m.arc)
        end

        local velocity = (m.speed * PERIOD) / m.distance
        m.vx = (m.end_point_x - m.current_x) * velocity
        m.vy = (m.end_point_y - m.current_y) * velocity
        m.vz = (m.end_point_z - m.current_z) * velocity

        if m.lightnings then
            m.lightnings[#m.lightnings].vector_x = m.vx
            m.lightnings[#m.lightnings].vector_y = m.vy
            m.lightnings[#m.lightnings].vector_z = m.vz
        end

    end


    ---@param m table
    ---@param new_x real
    ---@param new_y real
    ---@param bonus_z real
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
            step = m.speed / FPS
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


    function GetMissilesWithinUnit(unit, range)
        local missile_group = {}

            for i = 1, #MissileList do
                if MissileList[i].can_enum and IsUnitInRangeXY(unit, MissileList[i].current_x, MissileList[i].current_y, range) then
                    missile_group[#missile_group+1] = MissileList[i]
                end
            end

        return missile_group
    end

    ---@param from unit
    ---@param target unit
    ---@param missile string
    ---@param effects table
    ---@param start_x real
    ---@param start_y real
    ---@param end_x real
    ---@param end_y real
    ---@param angle real
    ---@param from_unit boolean
    ---@return table
    function ThrowMissile(from, target, missile, effects, start_x, start_y, end_x, end_y, angle, from_unit)
        local unit_data = GetUnitData(from)
        local m
        local end_z
        local start_z = 0.
        local weapon

        if not unit_data then return end

        if angle == 0. then angle = AngleBetweenXY_DEG(start_x, start_y, end_x, end_y)
        elseif target then angle = AngleBetweenUnits(from, target) end

        if from_unit then
            start_x = start_x + Rx(unit_data.missile_eject_range or 0., GetUnitFacing(from) - (unit_data.missile_eject_angle or 0.))
            start_y = start_y + Ry(unit_data.missile_eject_range or 0., GetUnitFacing(from) - (unit_data.missile_eject_angle or 0.))
            start_z = GetUnitFlyHeight(from) + (unit_data.missile_eject_z or 0.)
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
        BlzSetSpecialEffectZ(missile_effect, start_z)
        BlzSetSpecialEffectScale(missile_effect, m.scale or 1.)
        BlzSetSpecialEffectOrientation(missile_effect, angle * bj_DEGTORAD, 0., 0.)

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

        if m.sound_on_launch then
            AddSoundVolume(m.sound_on_launch.pack[GetRandomInt(1, #m.sound_on_launch.pack)], start_x, start_y, m.sound_on_launch.volume or 128, m.sound_on_launch.cutoff or 1600.)
        end

        if m.sound_on_fly then
            m.attached_sound = CreateNew3DSound(m.sound_on_fly.pack[GetRandomInt(1, #m.sound_on_fly.pack)], start_x, start_y, start_z, m.sound_on_fly.volume, m.sound_on_fly.cutoff, m.sound_on_fly.looping or nil)
            StartSound(m.attached_sound)
        end

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
            step = m.speed / FPS
            m.step = step
            start_height = start_z
            end_height = end_z
            m.time = m.time * (1. + m.arc)
        end
--print("a4")

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

        m.hit_group = hit_group

        if m.trackable then
            m.time = m.time * 1.25
        end

        if m.only_on_impact then
            m.time = 999999999999999.
        end


        local current_time = 0.
        local point_start
        local point_mid
        local point_end

        if m.geo_arc then
            distance2d = DistanceBetweenXY(start_x, start_y, end_x, end_y)
            local distance_bezie = 0.

            if m.geo_arc_length then
                distance_bezie = m.geo_arc_length / 2.
                m.total_length = distance2d / m.geo_arc_length
                m.bezie_step = 1. / (m.geo_arc_length / (m.speed * (m.speed_mod or 1.) / FPS))
            else
                distance_bezie = distance2d / 2.
                m.total_length = 1.
                m.bezie_step = 1. / (distance2d / (m.speed * (m.speed_mod or 1.) / FPS))
            end

            local start_angle = m.geo_arc

            if m.geo_arc_randomize_angle then
                if GetRandomInt(1, 2) == 1 then
                    start_angle = m.geo_arc * -1.
                end
            end

                point_start = { x = start_x, y = start_y }
                point_mid = { x = start_x + Rx(distance_bezie, angle - start_angle), y = start_y + Ry(distance_bezie, angle -  start_angle) }
                point_end = { x = start_x + Rx(m.geo_arc_length, angle), y = start_y + Ry(m.geo_arc_length, angle) }
                m.current_length = 0.
                m.current_bezie_angle = start_angle

        end

        m.current_x = start_x
        m.current_y = start_y
        m.current_z = start_z
        m.heading_angle = angle
        m.missile_owner = from
        m.target = target
        --print("aaaaaaa")
        OnMissileLaunch(from, m.target, m)
        local targets = m.max_targets or 1
        --print("aaaaaaa")


        local tag

        if effects and effects.tags then tag = effects.tags end

        MissileList[#MissileList+1] = m

        TimerStart(my_timer, PERIOD, true, function()

            if not m.pause then
                if IsMapBounds(m.current_x, m.current_y) or m.time <= 0. then
                    --print("BOUNDS")

                    if m.sound_on_destroy then
                        AddSoundVolume(m.sound_on_destroy.pack[GetRandomInt(1, #m.sound_on_destroy.pack)], m.current_x, m.current_y, m.sound_on_destroy.volume or 128, m.sound_on_destroy.cutoff or 1600.)
                        --AddSound(m.sound_on_destroy[GetRandomInt(1, #m.sound_on_destroy)], m.current_x, m.current_y)
                    end
                    --if effects and effects.effect then ApplyEffect(from, nil, m.current_x, m.current_y, effects.effect, effects.level) end
                    if m.effect_on_expire then
                        ApplyEffect(from, nil, m.current_x, m.current_y, m.effect_on_expire, 1, tag)
                    end

                    --print(DistanceBetweenXY(m.current_x, m.current_y, start_x, start_y))

                    OnMissileExpire(from, m.target, m)
                    DestroyEffect(missile_effect)
                    DestroyGroup(hit_group)

                    for i = 1, #MissileList do
                        if MissileList[i] == m then
                            table.remove(MissileList, i)
                            break
                        end
                    end

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
                        if GetUnitState(m.target, UNIT_STATE_LIFE) < 0.045 or m.target == nil then
                            m.time = 0.
                        else
                            distance = GetDistance3D(m.current_x, m.current_y, m.current_z, GetUnitX(m.target), GetUnitY(m.target), m.end_z + GetUnitZ(m.target))
                            velocity = (m.speed * PERIOD) / distance
                            m.vx = (GetUnitX(m.target) - m.current_x) * velocity
                            m.vy = (GetUnitY(m.target) - m.current_y) * velocity
                            m.vz = (m.end_z + GetUnitZ(m.target) - m.current_z) * velocity
                            m.heading_angle = AngleBetweenXY_DEG(m.current_x, m.current_y, GetUnitX(m.target), GetUnitY(m.target))
                            BlzSetSpecialEffectOrientation(missile_effect, m.heading_angle * bj_DEGTORAD, 0., 0.)
                        end
                    end

                    -- COLLISION
                    if m.current_z <= GetZ(m.current_x, m.current_y) + 1. and not m.ignore_terrain then
                        m.time = 0.
                        impact = true
                        --print("collision")
                    else

                        if m.geo_arc then
                            local last_x = m.current_x
                            local last_y = m.current_y
                            local bx, by, bz = BezierCurvePow2_xyz_xyz_xyz(point_start.x, point_start.y, 0., point_mid.x, point_mid.y, 0., point_end.x, point_end.y, 0., current_time)
                            m.current_x = bx
                            m.current_y = by

                            if m.geo_arc_change_angle then
                                BlzSetSpecialEffectYaw(m.my_missile, AngleBetweenXY(last_x, last_y, m.current_x, m.current_y))
                            end

                            current_time = current_time + m.bezie_step
                            if current_time > 1. then current_time = 1.; m.change_arc = true end

                            if m.total_length > 0. then
                                m.time = m.time + PERIOD
                                m.total_length = m.total_length - m.bezie_step
                            else
                                m.time = 0.
                            end

                            if m.change_arc then
                                m.change_arc = nil
                                current_time = 0.
                                local distance_bezie = m.geo_arc_length / 2.
                                m.current_bezie_angle = m.current_bezie_angle * -1.
                                point_start = { x = bx, y = by }
                                point_mid = { x = bx + Rx(distance_bezie, m.heading_angle - m.current_bezie_angle), y = by + Ry(distance_bezie, m.heading_angle -  m.current_bezie_angle) }
                                point_end = { x = bx + Rx(m.geo_arc_length, m.heading_angle), y = by + Ry(m.geo_arc_length, m.heading_angle) }
                            end

                        else
                            m.current_x = m.current_x + m.vx
                            m.current_y = m.current_y + m.vy
                        end



                        if m.arc > 0. then
                            local old_z = m.current_z
                            m.current_z = GetParabolaZ(start_height, end_height, height, distance2d, length)
                            local zDiff = m.current_z - old_z
                            local speed_step = m.speed * PERIOD
                            local pitch = zDiff > 0. and math.atan(speed_step / zDiff) - math.pi / 2. or math.atan(-zDiff / speed_step) - math.pi * 2.
                            --BlzSetSpecialEffectPitch(missile_effect, pitch)
                            m.last_pitch = pitch
                            BlzSetSpecialEffectOrientation(missile_effect, angle * bj_DEGTORAD, pitch, 0.)
                            length = length + m.step
                        else
                            m.current_z = m.current_z + m.vz
                        end


                        local bonus_z = 0.
                        if m.ignore_terrain then
                            local current_terrain_z = GetZ(m.current_x, m.current_y)
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
                        -- aoe damage
                        m.time = 0.

                            if m.sound_on_hit then
                                AddSoundVolume(m.sound_on_hit.pack[GetRandomInt(1, #m.sound_on_hit.pack)], m.current_x, m.current_y, m.sound_on_hit.volume or 128, m.sound_on_hit.cutoff or 1600.)
                            end

                            if weapon then
                                local group = CreateGroup()
                                local player_entity = GetOwningPlayer(from)
                                local damage_list = GetDamageValues(weapon, effects, m)
                                GroupEnumUnitsInRange(group, m.current_x, m.current_y, damage_list.range, nil)

                                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(group, index)

                                        if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                            if (m.angle_window and IsPointInAngleWindow(angle, m.angle_window, m.current_x, m.current_y, GetUnitX(picked), GetUnitY(picked))) or not m.angle_window then

                                                ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)
                                                DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                                OnMissileHit(from, picked, m)

                                                damage_list.targets = damage_list.targets - 1
                                                if damage_list.targets <= 0 then break end

                                            end
                                        end

                                    end

                                GroupClear(group)
                                DestroyGroup(group)
                                damage_list = nil
                            else

                                if m.effect_on_impact then ApplyEffect(from, nil, m.current_x, m.current_y, m.effect_on_impact, 1, tag) end
                                if effects and effects.effect then ApplyEffect(from, nil, m.current_x, m.current_y, effects.effect, effects.level, tag) end

                            end

                        --print("?????????")
                        OnMissileImpact(from, m)
                    end
                else
                    --print("why")
                    if m.only_on_target then
                        -- seeking
                        if IsUnitInRangeXY(m.target, m.current_x, m.current_y, m.radius) then

                            --print("hit")
                            DestroyMissile(m.target, missile_effect, m, m.current_x, m.current_y)
                            ApplySpecialEffectTarget(m.effect_on_target, m.target, m.effect_on_target_point, m.effect_on_target_scale)


                            if weapon then

                                local damage_list = GetDamageValues(weapon, effects, m)
                                DamageUnit(from, m.target, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                OnMissileHit(from, m.target, m)

                                    if damage_list.targets > 1 or damage_list.range > 0 then
                                        local group = CreateGroup()
                                        local player_entity = GetOwningPlayer(from)
                                        GroupEnumUnitsInRange(group, m.current_x, m.current_y, damage_list.range, nil)
                                        GroupRemoveUnit(group, m.target)

                                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                                local picked = BlzGroupUnitAt(group, index)

                                                if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                                    if (m.angle_window and IsPointInAngleWindow(angle, m.angle_window, m.current_x, m.current_y, GetUnitX(picked), GetUnitY(picked))) or not m.angle_window then
                                                        ApplySpecialEffectTarget(m.effect_on_target, picked, m.effect_on_target_point, m.effect_on_target_scale)
                                                        DamageUnit(from, picked, damage_list.damage, damage_list.attribute, damage_list.damagetype, RANGE_ATTACK, true, true, false, nil)
                                                        OnMissileHit(from, picked, m)

                                                        damage_list.targets = damage_list.targets - 1
                                                        if damage_list.targets <= 0 then break end
                                                    end

                                                end

                                            end

                                        GroupClear(group)
                                        DestroyGroup(group)
                                    end

                                damage_list = nil
                            else

                                if m.effect_on_hit then ApplyEffect(from, m.target, m.current_x, m.current_y, m.effect_on_hit, 1, tag) end
                                if effects and effects.effect then ApplyEffect(from, m.target, m.current_x, m.current_y, effects.effect, effects.level, tag) end

                                OnMissileHit(from, m.target, m)
                            end

                        end
                    elseif m.time > 0. then
                        -- first target hit
                        local group = CreateGroup()
                        local player_entity = GetOwningPlayer(from)
                        GroupEnumUnitsInRange(group, m.current_x, m.current_y, m.radius, nil)

                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(group, index)
                                    if not (IsUnitEnemy(picked, player_entity) and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and not IsUnitInGroup(picked, hit_group)) then
                                        GroupRemoveUnit(group, picked)
                                    end
                            end


                            if BlzGroupGetSize(group) > 0 then
                                local do_sound = true

                                --print("MISSILE HIT")

                                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(group, index)

                                    if (m.angle_window and IsPointInAngleWindow(angle, m.angle_window, m.current_x, m.current_y, GetUnitX(picked), GetUnitY(picked))) or not m.angle_window then

                                        if do_sound and m.sound_on_hit then
                                            AddSoundVolume(m.sound_on_hit.pack[GetRandomInt(1, #m.sound_on_hit.pack)], m.current_x, m.current_y, m.sound_on_hit.volume or 128, m.sound_on_hit.cutoff or 1600.)
                                            --AddSound(m.sound_on_hit[GetRandomInt(1, #m.sound_on_hit)], m.current_x, m.current_y);
                                            do_sound = false
                                        end

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


                                        if effects and effects.effect then ApplyEffect(from, picked, m.current_x, m.current_y, effects.effect, effects.level, tag) end
                                        if m.effect_on_hit then ApplyEffect(from, picked, m.current_x, m.current_y, m.effect_on_hit, 1, tag) end

                                        OnMissileHit(from, picked, m)

                                            if m.hit_once_in > 0. then
                                                local damaged_unit = picked
                                                GroupAddUnit(hit_group, damaged_unit)
                                                local timer = CreateTimer()
                                                TimerStart(timer, m.hit_once_in, false, function()
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
                            end

                        GroupClear(group)
                        DestroyGroup(group)
                    end
                end

            end

        end)

        return m
    end


    function InitMovementEngine()
        PullList = {}
        ChargeList = {}
        PushList = {}
        MissileList = {}
    end

end