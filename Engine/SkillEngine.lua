do






    function ResetUnitSpellCast(unit)
        local unit_data = GetUnitData(unit)

            BlzPauseUnitEx(unit, false)
            IssueImmediateOrderById(unit, order_stop)
            SetUnitTimeScale(unit, 1.)
            DestroyEffect(unit_data.cast_effect)

                if unit_data.cast_skill > 0 then
                    BlzEndUnitAbilityCooldown(unit, unit_data.cast_skill)
                    --SetUnitState(unit_data.Owner, UNIT_STATE_MANA, GetUnitState(unit_data.Owner, UNIT_STATE_MANA) + BlzGetUnitAbilityManaCost(unit_data.Owner, unit_data.cast_skill, unit_data.cast_skill_level-1))
                end

            unit_data.cast_skill = 0
    end


    local function CastSpell()

    end




    local SkillCastTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(SkillCastTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(SkillCastTrigger, function()
        local skill = GetSkillData(GetSpellAbilityId())


        if skill ~= nil then
            local id = GetSpellAbilityId()
            local unit_data = GetUnitData(GetTriggerUnit())
            local ability_level = GetUnitAbilityLevel(unit_data.Owner, id)
            local time_reduction = skill.level[ability_level].animation_scale



            if skill.type == SKILL_PHYSICAL then
                time_reduction = time_reduction / unit_data.stats[ATTACK_SPEED].multiplier
            elseif skill.type == SKILL_MAGICAL then
                time_reduction = time_reduction / ((100. + unit_data.stats[CAST_SPEED].value) * 0.01)
            end

            if time_reduction <= 0. then time_reduction = 0.01 end

            SetUnitTimeScale(unit_data.Owner, 1. + (1. - skill.level[ability_level].animation_scale))
            BlzSetUnitAbilityCooldown(unit_data.Owner, id, ability_level - 1, skill.level[ability_level].cooldown + (skill.level[ability_level].animation_point * time_reduction))

            local target = GetSpellTargetUnit()
            local spell_x = GetSpellTargetX()
            local spell_y = GetSpellTargetY()


            --print(spell_x)
            --AddSpecialEffect("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdx", spell_x, spell_y)

            unit_data.cast_skill = id
            unit_data.cast_skill_level = ability_level

            BlzPauseUnitEx(unit_data.Owner, true)
            SetUnitAnimationByIndex(unit_data.Owner, skill.level[ability_level].animation)

            if skill.level[ability_level].effect_on_caster ~= nil then
                unit_data.cast_effect = AddSpecialEffectTarget(unit_data.Owner, skill.level[ability_level].effect_on_caster, skill.level[ability_level].effect_on_caster_point)
                BlzSetSpecialEffectScale(unit_data.cast_effect, skill.level[ability_level].effect_on_caster_scale)
            end

                TimerStart(unit_data.action_timer, skill.level[ability_level].animation_point * time_reduction, false, function()
                    unit_data.cast_skill = 0
                    DestroyEffect(unit_data.cast_effect)

                        if  skill.autotrigger then
                            if skill.level[ability_level].missile ~= nil then

                                if target ~= nil then
                                    print("target")
                                    local angle = AngleBetweenUnits(unit_data.Owner, target)
                                    SetUnitFacing(unit_data.Owner, angle)
                                    ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                            GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target), angle)
                                else
                                    print("no target")
                                    ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                        GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), spell_x, spell_y, AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y))
                                end

                            else
                                if target ~= nil then
                                    SetUnitFacing(unit_data.Owner, AngleBetweenUnits(unit_data.Owner, target))
                                    ApplyEffect(unit_data.Owner, target, 0.,0., skill.level[ability_level].effect, ability_level)
                                elseif spell_x < 0. or spell_x > 0. then
                                    ApplyEffect(unit_data.Owner, nil, spell_x, spell_y, skill.level[ability_level].effect, ability_level)
                                else
                                    ApplyEffect(unit_data.Owner, nil, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), skill.level[ability_level].effect, ability_level)
                                end
                            end
                        end

                    TimerStart(unit_data.action_timer, skill.level[ability_level].animation_backswing * time_reduction, false, function()
                        SetUnitAnimation(unit_data.Owner, "Stand Ready")
                        BlzPauseUnitEx(unit_data.Owner, false)
                        SetUnitTimeScale(unit_data.Owner, 1.)
                    end)


                    print("cast")
                end)

        end

    end)

end