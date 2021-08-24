do



    function WhirlwindDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            AddUnitAnimationProperties(unit, "channel", false)
            AddUnitAnimationProperties(unit, unit_data.animation_tag or "", true)
            PauseTimer(unit_data.action_timer)
            BlzSetSpecialEffectScale(unit_data.whirlwind_sfx, 1.)
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
            unit_data.whirlwind_sfx = AddSpecialEffectTarget("Spell\\whirlwind.mdx", unit, "origin")
            BlzSetSpecialEffectScale(unit_data.whirlwind_sfx, 0.75)

            TimerStart(unit_data.action_timer, 0.33, true, function()
                local mp = GetUnitState(unit, UNIT_STATE_MANA)

                if mp >= 3. then
                    ApplyEffect(unit, nil, GetUnitX(unit), GetUnitY(unit), 'EWHW', 1)
                    SetUnitState(unit, UNIT_STATE_MANA, mp - 3.)
                else
                    WhirlwindDeactivate(unit)
                end

            end)
        end
    end




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