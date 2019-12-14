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

end