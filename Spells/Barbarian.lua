do



    function WhirlwindDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            AddUnitAnimationProperties(unit, "alternate", false)
            PauseTimer(unit_data.action_timer)
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil

    end


    function WhirlwindActivate(unit)
        local unit_data = GetUnitData(unit)

        if unit_data.channeled_destructor ~= nil then
            unit_data.channeled_destructor(unit)
        else

            unit_data.channeled_destructor = WhirlwindDeactivate

            ResetUnitSpellCast(unit)
            AddUnitAnimationProperties(unit, "alternate", true)
            UnitAddAbility(unit, FourCC('Abun'))

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

        TimerStart(CreateTimer(), 0.025, true, function()

            if GetUnitState(caster, UNIT_STATE_LIFE) < 0.045 or (target ~= nil and IsUnitInRange(caster, target, 125.)) then

                for i = 1, 25 do
                    DestroyEffect(unit_data.chain.element[i])
                end

                DestroyGroup(unit_data.chain.group)
                unit_data.chain = nil
                DestroyTimer(GetExpiredTimer())

            end


           if missile ~= nil and missile.time <= 0. then
                if BlzGroupGetSize(unit_data.chain.group) > 0 then
                    ForGroup(unit_data.chain.group, function()
                        PullUnitToUnit(GetEnumUnit(), caster, 700., 125., 15, "EBCH")
                    end)
                    target = BlzGroupUnitAt(unit_data.chain.group, BlzGroupGetSize(unit_data.chain.group) - 1)
                    print(GetUnitName(target))
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

                if target ~= nil then
                    distance = DistanceBetweenUnits(caster, target) / 25
                    angle = AngleBetweenXY(x, y, GetUnitX(target), GetUnitY(target))
                    BlzSetSpecialEffectX(unit_data.chain.element[25], GetUnitX(target))
                    BlzSetSpecialEffectY(unit_data.chain.element[25], GetUnitY(target))
                    BlzSetSpecialEffectZ(unit_data.chain.element[25], BlzGetLocalUnitZ(target) + z)
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
                        BlzSetSpecialEffectYaw(unit_data.chain.element[i], angle)
                    end

                BlzSetSpecialEffectYaw(unit_data.chain.element[25], angle)


        end)

    end


end