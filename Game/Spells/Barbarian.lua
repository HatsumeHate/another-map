do



    function WhirlwindDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            AddUnitAnimationProperties(unit, "channel", false)
            AddUnitAnimationProperties(unit, unit_data.animation_tag or "", true)
            PauseTimer(unit_data.action_timer)
            DestroyTimer(unit_data.whirlwind_effect_timer)
            --BlzSetSpecialEffectScale(unit_data.whirlwind_sfx, 1.)
            DestroyEffect(unit_data.whirlwind_sfx)
            DestroyLoopingSound(unit_data.looping_sound, 0.2)
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil

    end


    function WhirlwindActivate(unit)
        local unit_data = GetUnitData(unit)

        if unit_data.channeled_destructor ~= nil then
            unit_data.channeled_destructor(unit)
        else

            ResetUnitSpellCast(unit)

            unit_data.channeled_destructor = WhirlwindDeactivate
            unit_data.channeled_ability = "A010"

            AddUnitAnimationProperties(unit, unit_data.animation_tag, false)
            AddUnitAnimationProperties(unit, "channel", true)
            UnitAddAbility(unit, FourCC('Abun'))

            unit_data.looping_sound = AddLoopingSoundOnUnit({"Sounds\\Spell\\whirlwind_1.wav", "Sounds\\Spell\\whirlwind_2.wav", "Sounds\\Spell\\whirlwind_3.wav", "Sounds\\Spell\\whirlwind_4.wav"}, unit, 200, 200, -0.15, 110, 1700.)
            unit_data.whirlwind_effect_timer = CreateTimer()
            TimerStart(unit_data.whirlwind_effect_timer, 0.05, true, function()
                local whirlwind_sfx = AddSpecialEffect("Effect\\Ephemeral Slash Orange.mdx", GetUnitX(unit), GetUnitY(unit))
                local effect_move_timer = CreateTimer()
                local bonus_z = 120. + GetRandomReal(-15., 15.)
                local timescale = GetRandomReal(0.8, 1.2)
                local duration = 1. * timescale

                BlzSetSpecialEffectZ(whirlwind_sfx, GetUnitZ(unit) + bonus_z)
                BlzSetSpecialEffectYaw(whirlwind_sfx, GetRandomReal(0., 359.) * bj_DEGTORAD)
                BlzSetSpecialEffectRoll(whirlwind_sfx, 180. * bj_DEGTORAD)
                BlzSetSpecialEffectTimeScale(whirlwind_sfx, timescale)
                BlzSetSpecialEffectScale(whirlwind_sfx, 0.9)

                    TimerStart(effect_move_timer, 0.025, true, function()
                        if duration <= 0. then
                            DestroyEffect(whirlwind_sfx)
                            DestroyTimer(effect_move_timer)
                        else
                            BlzSetSpecialEffectPosition(whirlwind_sfx, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit) + bonus_z)
                            duration = duration - 0.025
                        end
                    end)

            end)

            --local attack_speed_bonus = (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01)

            --print((1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01))
            local function WhirlwindEffect()
                local mp = GetUnitState(unit, UNIT_STATE_MANA)
                local manacost = (9. + math.ceil(UnitGetAbilityLevel(unit, "A010") / 5)) / 3.

                    if mp >= manacost then
                        ApplyEffect(unit, nil, GetUnitX(unit), GetUnitY(unit), 'EWHW', 1)
                        SetUnitState(unit, UNIT_STATE_MANA, mp - manacost)
                        TimerStart(unit_data.action_timer, 0.33 * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01), false, function() WhirlwindEffect() end)
                    else
                        WhirlwindDeactivate(unit)
                        Feedback_NoResource(GetPlayerId(GetOwningPlayer(unit))+1)
                    end
            end

            TimerStart(unit_data.action_timer, 0.33 * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01), false, function()
                WhirlwindEffect()
                --TimerStart(unit_data.action_timer, 0.33 * attack_speed_bonus, false, WhirlwindEffect)
            end)
        end
    end



    ---@param unit_from unit
    ---@param unit_to unit
    ---@param distance real
    ---@return table
    function BuildVisualChain(unit_from, bonus_start_z, unit_to, bonus_end_z, distance)
        local chain = {}
        local offset = 35.
        local elements = distance / offset
        local x, y = GetUnitX(unit_from), GetUnitY(unit_from)
        local z = GetZ(x, y) + bonus_start_z
        local end_z = GetZ(GetUnitX(unit_to), GetUnitY(unit_to)) + bonus_end_z

            for i = 1, elements do
                chain[i] = { element = AddSpecialEffect("Spell\\ChainElement.mdx", x, y) }
            end


            chain.update_timer = CreateTimer()

            TimerStart(chain.update_timer, 0.025, true, function()
                x, y = GetUnitX(unit_from), GetUnitY(unit_from)
                z = GetZ(x, y) + bonus_start_z
                end_z = GetZ(GetUnitX(unit_to), GetUnitY(unit_to)) + bonus_end_z
                local dist = DistanceBetweenUnits(unit_from, unit_to)
                local current_distance = dist / elements
                local angle = math.rad(AngleBetweenUnits(unit_from, unit_to))
                local height_angle = AngleBetweenXY_DEG(z, 0., end_z, dist) - 90.
                --print(height_angle)

                for i = 1, elements do
                    local effect_x = x + (current_distance * i) * math.cos(angle)
                    local effect_y = y + (current_distance * i) * math.sin(angle)
                    local effect_z = GetZ(effect_x, effect_y) + bonus_start_z + ((end_z - z) *  (i / elements))
                    --local z_offset = (end_z - z) * (1. + (i / elements))
                    --print(i .. " " .. effect_z)

                        BlzSetSpecialEffectX(chain[i].element, effect_x)
                        BlzSetSpecialEffectY(chain[i].element, effect_y)
                        BlzSetSpecialEffectZ(chain[i].element, effect_z)
                        --BlzSetSpecialEffectYaw(unit_data.chain.element[i], angle)
                        BlzSetSpecialEffectOrientation(chain[i].element, angle, math.rad(height_angle), 0.)
                end
            end)

        return chain
    end


    --[[RegisterTestCommand("chain", function()
        local unit = CreateUnit(Player(0), FourCC("hgyr"), GetUnitX(PlayerHero[1]) - 500., GetUnitY(PlayerHero[1]), 270.)

            BuildVisualChain(PlayerHero[1], 65., unit, GetUnitFlyHeight(unit), DistanceBetweenUnits(PlayerHero[1], unit))

    end)]]


    function BuildChain(caster, missile)
        local unit_data = GetUnitData(caster)
        local target
        unit_data.chain = { element = {} }
        local x, y, z = GetUnitX(caster), GetUnitY(caster), missile.end_z

        unit_data.chain.group = CreateGroup()

        for i = 1, 25 do
            if i == 25 then
                unit_data.chain.element[i] = AddSpecialEffect("Spell\\TimberChainHead.mdx", x, y)
            else
                unit_data.chain.element[i] = AddSpecialEffect("Spell\\ChainElement.mdx", x, y)
            end
        end

        local timer = CreateTimer()
        TimerStart(timer, 0.025, true, function()

            if GetUnitState(caster, UNIT_STATE_LIFE) < 0.045 or (target ~= nil and IsUnitInRange(caster, target, 125.)) then

                for i = 1, 25 do
                    DestroyEffect(unit_data.chain.element[i])
                end

                DestroyGroup(unit_data.chain.group)
                unit_data.chain = nil
                DestroyTimer(GetExpiredTimer())

            end


           if missile and missile.time <= 0. then
                if BlzGroupGetSize(unit_data.chain.group) > 0 then
                    ForGroup(unit_data.chain.group, function()
                        PullUnitToUnit(GetEnumUnit(), caster, 1000., 125., 15, "EBCH")
                    end)
                    target = BlzGroupUnitAt(unit_data.chain.group, BlzGroupGetSize(unit_data.chain.group) - 1)
                    missile = nil
                else
                    for i = 1, 25 do
                        DestroyEffect(unit_data.chain.element[i])
                    end

                    DestroyGroup(unit_data.chain.group)
                    unit_data.chain = nil
                    DestroyTimer(GetExpiredTimer())
                end
            end

            x, y = GetUnitX(caster), GetUnitY(caster)
            local distance
            local angle

                if target then
                    distance = DistanceBetweenUnits(caster, target) / 25
                    angle = AngleBetweenXY(x, y, GetUnitX(target), GetUnitY(target))
                    BlzSetSpecialEffectX(unit_data.chain.element[25], GetUnitX(target))
                    BlzSetSpecialEffectY(unit_data.chain.element[25], GetUnitY(target))
                    BlzSetSpecialEffectZ(unit_data.chain.element[25], GetUnitZ(target) + z)
                else
                    distance = DistanceBetweenUnitXY(caster, missile.current_x, missile.current_y) / 25
                    angle = AngleBetweenXY(x, y, missile.current_x, missile.current_y)
                    BlzSetSpecialEffectX(unit_data.chain.element[25], missile.current_x)
                    BlzSetSpecialEffectY(unit_data.chain.element[25], missile.current_y)
                    BlzSetSpecialEffectZ(unit_data.chain.element[25], missile.current_z)
                end

                    for i = 1, 24 do
                        local effect_x = x + (distance * i) * Cos(angle)
                        local effect_y = y + (distance * i) * Sin(angle)
                        local effect_z = GetZ(effect_x, effect_y) + z

                        BlzSetSpecialEffectX(unit_data.chain.element[i], effect_x)
                        BlzSetSpecialEffectY(unit_data.chain.element[i], effect_y)
                        BlzSetSpecialEffectZ(unit_data.chain.element[i], effect_z)
                        --BlzSetSpecialEffectYaw(unit_data.chain.element[i], angle)
                        BlzSetSpecialEffectOrientation(unit_data.chain.element[i], angle, 0., 0.)
                    end

                --BlzSetSpecialEffectYaw(unit_data.chain.element[25], angle)
                BlzSetSpecialEffectOrientation(unit_data.chain.element[25], angle, 0., 0.)


        end)

    end


    function CastShatterGround(source, missile)
        local timer = CreateTimer()
        local max = 400.
        local delta_radius = (max - 100.) / (missile.time / 0.025)
        local effect = AddSpecialEffect("Spell\\arc_fire.mdx", GetUnitX(source), GetUnitY(source))

            BlzSetSpecialEffectScale(effect, 0.7)
            BlzSetSpecialEffectYaw(effect, GetUnitFacing(source) * bj_DEGTORAD)
            ShakeByCoords(GetUnitX(source), GetUnitY(source), 1.6, missile.time, 1450.)


            TimerStart(timer, 0.025, true, function()
                if missile and missile.time > 0. then
                    if missile.radius < max then missile.radius = missile.radius + delta_radius end
                else
                    DestroyTimer(timer)
                end
            end)

    end


end