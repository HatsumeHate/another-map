do









    local SkillCastTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(SkillCastTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(SkillCastTrigger, function()
        local skill = GetSkillData(GetSpellAbilityId())

        if skill ~= nil then
            local id = GetSpellAbilityId()
            local unit_data = GetUnitData(GetTriggerUnit())
            local ability_level = GetUnitAbilityLevel(unit_data.Owner, id)

            BlzSetUnitAbilityCooldown(unit_data.Owner, id, ability_level-1, skill.level[ability_level].cooldown)
            SetUnitTimeScale(unit_data.Owner, skill.level[ability_level].animation_scale)



            SetUnitAnimationByIndex(unit_data.Owner, skill.level[ability_level].animation)
            local target = GetSpellTargetUnit()
            local spell_x = GetSpellTargetX()
            local spell_y = GetSpellTargetX()

                TimerStart(unit_data.action_timer, skill.level[ability_level].animation_point * skill.level[ability_level].animation_scale, false, function()


                    if skill.level[ability_level].missile ~= nil then

                        if target ~= nil then
                            print("target")
                            ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target),
                                    AngleBetweenUnits(unit_data.Owner, target))
                        else
                            print("no target")
                            ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), spell_x, spell_y,
                                    AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y))
                        end

                    else
                        if target ~= nil then
                            ApplyEffect(unit_data.Owner, target, 0.,0., skill.level[ability_level].effect, ability_level)
                        else
                            ApplyEffect(unit_data.Owner, nil, spell_x, spell_y, skill.level[ability_level].effect, ability_level)
                        end
                    end

                    SetUnitTimeScale(unit_data.Owner, 1.)
                    print("cast")
                end)

        end

    end)

end