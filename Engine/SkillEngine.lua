do


    KEY_Q = 1
    KEY_W = 2
    KEY_E = 3
    KEY_R = 4
    KEY_F = 5
    KEY_D = 6


    local KEYBIND_LIST = {
        [KEY_Q] =  {
            [SELF_CAST] = FourCC('A016'),
            [POINT_CAST] = FourCC('A018'),
            [TARGET_CAST] = FourCC('A017'),
            [POINT_AND_TARGET_CAST] = FourCC('A019'),
            name_string = " (|cffffcc00Q|r)",
            player_skill_bind = {}
        },
        [KEY_W] =  {
            [SELF_CAST] = FourCC('A01A'),
            [POINT_CAST] = FourCC('A01B'),
            [TARGET_CAST] = FourCC('A01C'),
            [POINT_AND_TARGET_CAST] = FourCC('A01D'),
            name_string = " (|cffffcc00W|r)",
            player_skill_bind = {}
        },
        [KEY_E] =  {
            [SELF_CAST] = FourCC('A01E'),
            [POINT_CAST] = FourCC('A01F'),
            [TARGET_CAST] = FourCC('A01G'),
            [POINT_AND_TARGET_CAST] = FourCC('A01H'),
            name_string = " (|cffffcc00E|r)",
            player_skill_bind = {}
        },
        [KEY_R] =  {
            [SELF_CAST] = FourCC('A01I'),
            [POINT_CAST] = FourCC('A01K'),
            [TARGET_CAST] = FourCC('A01J'),
            [POINT_AND_TARGET_CAST] = FourCC('A01L'),
            name_string = " (|cffffcc00R|r)",
            player_skill_bind = {}
        }
    }



    function BindAbilityKey(unit, id, key)
        local skill = GetSkillData(FourCC(id))
        local ability_id = KEYBIND_LIST[key][skill.activation_type]
        local ability

            UnitAddAbility(unit, ability_id)
            ability = BlzGetUnitAbility(unit, ability_id)

            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[skill.current_level].range)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[skill.current_level].radius)
            BlzSetUnitAbilityManaCost(unit, ability_id, 0, skill.level[skill.current_level].resource_cost)

                if GetLocalPlayer() == GetOwningPlayer(unit) then
                    BlzSetAbilityTooltip(ability_id, skill.name .. KEYBIND_LIST[key].name_string, 0)
                    BlzSetAbilityIcon(ability_id, skill.icon)
                end

        KEYBIND_LIST[key].player_skill_bind[GetPlayerId(GetOwningPlayer(unit))] = FourCC(id)
    end


    function GetKeybindAbility(id, player)

        for key = KEY_Q, KEY_D do
            for cast_type = SELF_CAST, POINT_AND_TARGET_CAST do
                if KEYBIND_LIST[key][cast_type] == id then
                    return KEYBIND_LIST[key].player_skill_bind[player]
                end
            end
        end

        return 0
    end


    function UnitAddMyAbility(unit, id)
        local unit_data = GetUnitData(unit)
        local skill_data = GetSkillData(FourCC(id))

        if skill_data == nil or unit_data == nil then return end

            unit_data.skill_list[#unit_data.skill_list + 1] = MergeTables({}, skill_data)
    end


    function ResetUnitSpellCast(unit)
        local unit_data = GetUnitData(unit)

            BlzPauseUnitEx(unit, false)
            IssueImmediateOrderById(unit, order_stop)
            SetUnitTimeScale(unit, 1.)
            DestroyEffect(unit_data.cast_effect)

                if unit_data.cast_skill > 0 then
                    BlzEndUnitAbilityCooldown(unit, unit_data.cast_skill)
                    SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + BlzGetUnitAbilityManaCost(unit_data.Owner, unit_data.cast_skill, unit_data.cast_skill_level - 1))
                end

            unit_data.cast_skill = 0
    end


    function SpellBackswing(unit)
        BlzPauseUnitEx(unit, false)
        IssueImmediateOrderById(unit, order_stop)
        SetUnitAnimation(unit, "Stand Ready")
        SetUnitTimeScale(unit, 1.)
        print("spell backswing")
    end




    local SkillCastTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(SkillCastTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(SkillCastTrigger, function()
        local id = GetSpellAbilityId()
        local skill = GetKeybindAbility(id, GetPlayerId(GetOwningPlayer(GetTriggerUnit())))


        if skill == 0 then
            skill = GetSkillData(GetSpellAbilityId())
        else
            skill = GetSkillData(skill)
        end

        --TODO fix this shit
        if skill ~= nil then
            local unit_data = GetUnitData(GetTriggerUnit())

            skill = GetUnitSkillData(unit_data.Owner, id)
            print(skill.name)
            if skill == nil then return end

            local ability_level = skill.current_level
            local time_reduction = skill.level[ability_level].animation_scale

            print("AAAAAA")

                if skill.type == SKILL_PHYSICAL then
                    time_reduction = time_reduction * (1. - unit_data.stats[ATTACK_SPEED].bonus * 0.01)
                elseif skill.type == SKILL_MAGICAL then
                    time_reduction = time_reduction * (1. - unit_data.stats[CAST_SPEED].value * 0.01)
                end

                if time_reduction <= 0. then time_reduction = 0. end

            SetUnitTimeScale(unit_data.Owner, 1. + (1. - skill.level[ability_level].animation_scale))
            BlzSetUnitAbilityCooldown(unit_data.Owner, id, ability_level - 1, skill.level[ability_level].cooldown + (skill.level[ability_level].animation_point * time_reduction))
            BlzSetUnitAbilityManaCost(unit_data.Owner, id, ability_level - 1, skill.level[ability_level].resource_cost)


            local target = GetSpellTargetUnit()
            local spell_x = GetSpellTargetX()
            local spell_y = GetSpellTargetY()


            unit_data.cast_skill = id
            unit_data.cast_skill_level = ability_level

            BlzPauseUnitEx(unit_data.Owner, true)
            SetUnitAnimationByIndex(unit_data.Owner, skill.level[ability_level].animation)


                if skill.level[ability_level].effect_on_caster ~= nil then
                    unit_data.cast_effect = AddSpecialEffectTarget(unit_data.Owner, skill.level[ability_level].effect_on_caster, skill.level[ability_level].effect_on_caster_point)
                    BlzSetSpecialEffectScale(unit_data.cast_effect, skill.level[ability_level].effect_on_caster_scale)
                end

                if skill.level[ability_level].start_effect_on_cast_point ~= nil then
                    bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].start_effect_on_cast_point, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner))
                    BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].start_effect_on_cast_point_scale)
                    DestroyEffect(bj_lastCreatedEffect)
                end

            OnSkillCast(unit_data.Owner, target, spell_x, spell_y, skill)

                TimerStart(unit_data.action_timer, skill.level[ability_level].animation_point * time_reduction, false, function()
                    unit_data.cast_skill = 0
                    DestroyEffect(unit_data.cast_effect)

                    if skill.level[ability_level].end_effect_on_cast_point ~= nil then
                        bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].end_effect_on_cast_point, spell_x, spell_y)
                        BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].end_effect_on_cast_point_scale)
                        DestroyEffect(bj_lastCreatedEffect)
                    end
                    
                        if skill.autotrigger then
                            if skill.level[ability_level].missile ~= nil then
                                if target ~= nil then
                                    local angle = AngleBetweenUnits(unit_data.Owner, target)
                                    SetUnitFacing(unit_data.Owner, angle)
                                    ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                            GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target), angle)
                                else
                                    ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                            GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), spell_x, spell_y, AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y))
                                end

                            elseif skill.level[ability_level].effect ~= nil then
                                if target ~= nil and target ~= unit_data.Owner then
                                    SetUnitFacing(unit_data.Owner, AngleBetweenUnits(unit_data.Owner, target))
                                    ApplyEffect(unit_data.Owner, target, 0.,0., skill.level[ability_level].effect, ability_level)
                                elseif target ~= nil and target == unit_data.Owner then
                                    ApplyEffect(unit_data.Owner, nil, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), skill.level[ability_level].effect, ability_level)
                                else
                                    ApplyEffect(unit_data.Owner, nil, spell_x, spell_y, skill.level[ability_level].effect, ability_level)
                                end
                            end
                        end

                    TimerStart(unit_data.action_timer, skill.level[ability_level].animation_backswing * time_reduction, false, function ()
                        SpellBackswing(unit_data.Owner)
                    end)

                    OnSkillCastEnd(unit_data.Owner, target, spell_x, spell_y, skill)

                    print("cast")
                end)

        end

    end)

end