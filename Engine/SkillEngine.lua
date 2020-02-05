do


    KEY_Q = 1
    KEY_W = 2
    KEY_E = 3
    KEY_R = 4
    KEY_F = 5
    KEY_D = 6


    KEYBIND_LIST = {
        [KEY_Q] =  {
            ability = FourCC('A016'),
            name_string = " (|cffffcc00Q|r)",
            bind_name = "[Q]",
            player_skill_bind = {}
        },
        [KEY_W] =  {
            ability = FourCC('A01A'),
            name_string = " (|cffffcc00W|r)",
            bind_name = "[W]",
            player_skill_bind = {}
        },
        [KEY_E] =  {
            ability = FourCC('A01E'),
            name_string = " (|cffffcc00E|r)",
            bind_name = "[E]",
            player_skill_bind = {}
        },
        [KEY_R] =  {
            ability = FourCC('A01I'),
            name_string = " (|cffffcc00R|r)",
            bind_name = "[R]",
            player_skill_bind = {}
        },
        [KEY_F] =  {
            ability = FourCC('A018'),
            name_string = " (|cffffcc00F|r)",
            bind_name = "[F]",
            player_skill_bind = {}
        },
        [KEY_D] =  {
            ability = FourCC('A017'),
            name_string = " (|cffffcc00D|r)",
            bind_name = "[D]",
            player_skill_bind = {}
        }
    }


    function UnbindAbilityKey(unit, id)
        local player = GetPlayerId(GetOwningPlayer(unit))

            for i = KEY_Q, KEY_D do
                if KEYBIND_LIST[i].player_skill_bind[player] == FourCC(id) then
                    UnitRemoveAbility(unit, KEYBIND_LIST[i].ability)
                    KEYBIND_LIST[i].player_skill_bind[player] = 0
                    break
                end
            end

    end


    function GetStringEnding(string, from)

        for i = from, StringLength(string) do
            if SubString(string, i, i + 1) == "#" then
                return i + 1
            end
        end

        return StringLength(string)
    end


    function ParseString(str, tag, lvl)
        local value_str = SubString(str, 8, GetStringEnding(str, 8)-1)
        local id = SubString(str, 3,  7)

            if tag == "e" then
                local effect = GetEffectData(id)

                 GenerateEffectLevelData(effect, lvl)

                    if value_str == "pwr" then return (effect.level[lvl].power or 0)
                    elseif value_str == "dmg" then return (effect.level[lvl].power or 0) .. " + " .. S2I(R2S((effect.level[lvl].attack_percent_bonus or 1.) * 100.)) .. "%% " .. LOCALE_LIST[my_locale].GENERATED_TOOLTIP
                    elseif value_str == "atr" then return GetItemAttributeName(effect.level[lvl].attribute)
                    elseif value_str == "ap" then return math.floor((effect.level[lvl].attack_percent_bonus or 1.) * 100.)
                    elseif value_str == "ab" then return effect.level[lvl].attribute_bonus or 0
                    elseif value_str == "wdpb" then return math.floor((effect.level[lvl].weapon_damage_percent_bonus or 1.) * 100.)
                    elseif value_str == "aoe" then return R2I(effect.level[lvl].area_of_effect or 0.)
                    elseif value_str == "bcc" then return R2I(effect.level[lvl].bonus_crit_chance or 0.) .. "%%"
                    elseif value_str == "bcm" then return effect.level[lvl].bonus_crit_multiplier or 0.
                    end
            elseif tag == "s" then
                local skill = GetSkillData(FourCC(id))
                    if value_str == "rc" then return R2I(skill.level[lvl].resource_cost or 0.)
                    elseif value_str == "cld" then return skill.level[lvl].cooldown or 0.1
                    elseif value_str == "rng" then return R2I(skill.level[lvl].range or 0.)
                    end
            elseif tag == "b" then
                local buff = GetBuffData(id)

                    GenerateBuffLevelData(buff, lvl)

                    if value_str == "time" then return buff.level[lvl].time or 0.1
                    elseif SubString(value_str, 0,  2) == "va" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return GetCorrectParamText(param.PARAM, param.VALUE, param.METHOD)
                    elseif SubString(value_str, 0,  2) == "pa" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return param.PARAM
                    end

            end

        return ""
    end




    function ParseLocalizationSkillTooltipString(str, level)
        local last_sector = 0
        local result_string = ""
        local my_string_table = {}
        local ending_number = 0

        for i = 0, StringLength(str) do

            if SubString(str, i, i+1) == "@" then
                ending_number = GetStringEnding(str, i)
                local value_string = SubString(str, i, ending_number)
                my_string_table[#my_string_table+1] = SubString(str, last_sector, i) .. ParseString(value_string, SubString(str, i+1, i+2), level)
                i = ending_number
                last_sector = i
            end


        end

        my_string_table[#my_string_table+1] = SubString(str, last_sector, StringLength(str))


        for i = 1, #my_string_table do
            result_string = result_string .. my_string_table[i]
        end

        return result_string
    end



    RegisterTestCommand("parse", function()
        print(ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][FourCC("A007")].bind, 1))
    end)

    ---@param unit unit
    ---@param id string
    ---@param player number
    function SetAbilityExtendedTooltip(unit, id, player)
        local true_id = FourCC(id)
        local ability = GetKeybindKeyAbility(true_id, player)

            if ability == 0 then return end
            local lvl = UnitGetAbilityLevel(unit, id)

            if GetLocalPlayer() == Player(player) then
                if LOCALE_LIST[my_locale][true_id] ~= nil then
                    BlzSetAbilityExtendedTooltip(ability, ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id].bind, lvl), 0)
                end
            end

    end

    ---@param unit unit
    ---@param id string
    ---@param key integer
    function BindAbilityKey(unit, id, key)
        local skill = GetSkillData(FourCC(id))
        local ability_id = KEYBIND_LIST[key].ability
        local ability


            if GetUnitAbilityLevel(unit, ability_id) == 0 then
                UnitAddAbility(unit, ability_id)
            end

            ability = BlzGetUnitAbility(unit, ability_id)

            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[skill.current_level].range or 0.)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[skill.current_level].radius or 0.)
            BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)
            BlzSetUnitAbilityManaCost(unit, ability_id, 0, skill.level[skill.current_level].resource_cost or 0.)

                if GetLocalPlayer() == GetOwningPlayer(unit) then
                    BlzSetAbilityTooltip(ability_id, skill.name .. KEYBIND_LIST[key].name_string, 0)
                    BlzSetAbilityIcon(ability_id, skill.icon)
                end


        KEYBIND_LIST[key].player_skill_bind[GetPlayerId(GetOwningPlayer(unit))] = FourCC(id)
        SetAbilityExtendedTooltip(unit, id, GetPlayerId(GetOwningPlayer(unit)))
    end


    ---@param id integer
    ---@param player integer
    function IsAbilityKeybinded(id, player)

        for key = KEY_Q, KEY_D do
            if KEYBIND_LIST[key].player_skill_bind[player] == id then
                return true
            end
        end

        return false
    end

    ---@param id integer
    ---@param player integer
    function GetKeybindKeyAbility(id, player)

        for key = KEY_Q, KEY_D do
            if KEYBIND_LIST[key].player_skill_bind[player] == id then
                return KEYBIND_LIST[key].ability
            end
        end

        return 0
    end

    ---@param id integer
    ---@param player integer
    function GetKeybindAbility(id, player)

        for key = KEY_Q, KEY_D do
            if KEYBIND_LIST[key].ability == id then
                return KEYBIND_LIST[key].player_skill_bind[player]
            end
        end

        return 0
    end




    ---@param unit unit
    ---@param id string
    ---@param amount integer
    function UnitAddAbilityLevel(unit, id, amount)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    unit_data.skill_list[i].current_level = unit_data.skill_list[i].current_level + amount
                    return true
                end
            end

        return false
    end


    ---@param unit unit
    ---@param id string
    ---@param lvl integer
    function UnitSetAbilityLevel(unit, id, lvl)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    unit_data.skill_list[i].current_level = lvl
                    print("set unit ability level " .. unit_data.skill_list[i].current_level)
                    return true
                end
            end

        return false
    end

    ---@param unit unit
    ---@param id string
    function UnitGetAbilityLevel(unit, id)
        local unit_data = GetUnitData(unit)
        local ability_level = 0
        local skill

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    ability_level = unit_data.skill_list[i].current_level
                    skill = unit_data.skill_list[i]
                    break
                end
            end

            for i = WEAPON_POINT, NECKLACE_POINT do
                if unit_data.equip_point[i] ~= nil and unit_data.equip_point[i].SKILL_BONUS ~= nil then
                    for skill_bonus = 1, #unit_data.equip_point[i].SKILL_BONUS do
                        if (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id ~= nil and unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id == id) or
                                (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category ~= nil and skill.category == unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category) then
                            ability_level = ability_level + unit_data.equip_point[i].SKILL_BONUS[skill_bonus].bonus_levels
                        end
                    end
                end
            end

        if skill[ability_level] == nil then
            GenerateSkillLevelData(skill, ability_level)
        end

        return ability_level
    end


    ---@param unit unit
    ---@param id integer
    function UnitAddMyAbility(unit, id)
        local unit_data = GetUnitData(unit)
        local skill_data = GetSkillData(FourCC(id))

        if unit_data == nil or skill_data == nil then return end

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    return false
                end
            end

            unit_data.skill_list[#unit_data.skill_list + 1] = MergeTables({}, skill_data)

        return true
    end


    ---@param unit unit
    function ResetUnitSpellCast(unit)
        local unit_data = GetUnitData(unit)

            BlzPauseUnitEx(unit, false)
            IssueImmediateOrderById(unit, order_stop)
            SetUnitTimeScale(unit, 1.)
            DestroyEffect(unit_data.cast_effect)

                if unit_data.castsound ~= nil then
                    StopSound(unit_data.castsound, true, true)
                end

                if unit_data.cast_skill > 0 then
                    BlzEndUnitAbilityCooldown(unit, unit_data.cast_skill)
                    SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + BlzGetUnitAbilityManaCost(unit_data.Owner, unit_data.cast_skill, unit_data.cast_skill_level - 1))
                end

            unit_data.cast_skill = 0
    end


    ---@param unit unit
    function SpellBackswing(unit)
        BlzPauseUnitEx(unit, false)
        IssueImmediateOrderById(unit, order_stop)
        SetUnitAnimation(unit, "Stand Ready")
        SetUnitTimeScale(unit, 1.)
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


        if skill ~= nil then
            local unit_data = GetUnitData(GetTriggerUnit())
            skill = GetUnitSkillData(unit_data.Owner, skill.Id)

            if skill == nil then return end

            local ability_level = UnitGetAbilityLevel(unit_data.Owner, skill.Id)
            GenerateSkillLevelData(skill, ability_level)


            local time_reduction = skill.level[ability_level].animation_scale or 1.
            print("basic reduction "..time_reduction)

                if skill.type == SKILL_PHYSICAL then
                    time_reduction = time_reduction * (1. - unit_data.stats[ATTACK_SPEED].bonus * 0.01)
                elseif skill.type == SKILL_MAGICAL then
                    time_reduction = time_reduction * (1. - unit_data.stats[CAST_SPEED].value * 0.01)
                end

                if time_reduction <= 0. then time_reduction = 0. end

            SetUnitAnimationByIndex(unit_data.Owner, 0)
            print("after bonus reduction "..time_reduction)

            if skill.level[ability_level].animation_scale ~= nil then
                SetUnitTimeScale(unit_data.Owner, 1. + (1. - skill.level[ability_level].animation_scale))
                print("timescale is " .. (1. + (1. - skill.level[ability_level].animation_scale)))
            end

            print("result cast time is " .. (skill.level[ability_level].animation_point or 0.) * time_reduction)

            BlzSetUnitAbilityCooldown(unit_data.Owner, id, ability_level - 1, (skill.level[ability_level].cooldown or 0.1) + (skill.level[ability_level].animation_point * time_reduction))
            BlzSetUnitAbilityManaCost(unit_data.Owner, id, ability_level - 1, skill.level[ability_level].resource_cost or 0)


            local target = GetSpellTargetUnit()
            local spell_x = GetSpellTargetX()
            local spell_y = GetSpellTargetY()


            unit_data.cast_skill = id
            unit_data.cast_skill_level = ability_level

            BlzPauseUnitEx(unit_data.Owner, true)
            SetUnitAnimationByIndex(unit_data.Owner, skill.level[ability_level].animation or 0)

                if skill.level[ability_level].effect_on_caster ~= nil then
                    unit_data.cast_effect = AddSpecialEffectTarget(skill.level[ability_level].effect_on_caster, unit_data.Owner, skill.level[ability_level].effect_on_caster_point)
                    BlzSetSpecialEffectScale(unit_data.cast_effect, skill.level[ability_level].effect_on_caster_scale or 1.)
                end

                if skill.level[ability_level].start_effect_on_cast_point ~= nil then
                    bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].start_effect_on_cast_point, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner))
                    BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].start_effect_on_cast_point_scale or 1.)
                    DestroyEffect(bj_lastCreatedEffect)
                end

                if skill.sound ~= nil then
                    if skill.sound ~= nil then
                        unit_data.castsound = AddSoundVolumeZ(skill.sound.pack[GetRandomInt(1, #skill.sound.pack)], GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), 35., skill.sound.volume, skill.sound.cutoff)
                        --AddSound(myeffect.sound, x, y)
                    end
                end


            OnSkillCast(unit_data.Owner, target, spell_x, spell_y, skill)

                TimerStart(unit_data.action_timer, (skill.level[ability_level].animation_point or 0.) * time_reduction, false, function()
                    unit_data.cast_skill = 0
                    DestroyEffect(unit_data.cast_effect)

                    if skill.level[ability_level].end_effect_on_cast_point ~= nil then
                        bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].end_effect_on_cast_point, spell_x, spell_y)
                        BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].end_effect_on_cast_point_scale or 1.)
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