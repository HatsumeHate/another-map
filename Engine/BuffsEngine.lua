do

    local BUFF_UPDATE = 0.1



    ---@param unit_data table
    ---@param buff_data table
    local function DeleteBuff(unit_data, buff_data)
        for i = 1, #unit_data.buff_list do
            if unit_data.buff_list[i] == buff_data then
                UnitRemoveAbility(unit_data.Owner, FourCC(buff_data.buff_id))
                UnitRemoveAbility(unit_data.Owner, FourCC(buff_data.id))

                if buff_data.level[buff_data.current_level].bonus ~= nil then
                    for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                        ModifyStat(unit_data.Owner, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, false)
                    end
                end

                if buff_data.level[buff_data.current_level].negative_state ~= nil then

                    local state = buff_data.level[buff_data.current_level].negative_state
                    buff_data.level[buff_data.current_level].negative_state = nil

                    if not IsHaveNegativeState(unit_data.Owner, buff_data.level[buff_data.current_level].negative_state) then
                        if state == STATE_FREEZE then
                            SetUnitVertexColor(unit_data.Owner, 255, 255, 255, 255)
                            SetUnitTimeScale(unit_data.Owner, 1.)
                            BlzPauseUnitEx(unit_data.Owner, false)
                        elseif state == STATE_STUN then
                            BlzPauseUnitEx(unit_data.Owner, false)
                        end
                    end

                end

                DestroyTimer(buff_data.update_timer)
                table.remove(unit_data.buff_list, i)
                buff_data = nil
                break
            end
        end
    end


    ---@param target unit
    ---@param buff_id integer
    function GetBuffLevel(target, buff_id)
        local target_data = GetUnitData(target)

        if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
            for i = 1, #target_data.buff_list do
                if target_data.buff_list[i].id == buff_id then
                    return target_data.buff_list[i].current_level
                end
            end
        end

        return 0
    end

    ---@param target unit
    ---@param buff_id integer
    function RemoveBuff(target, buff_id)
        local target_data = GetUnitData(target)
        local buff_data

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #target_data.buff_list do
                    if target_data.buff_list[i].id == buff_id then
                        buff_data = target_data.buff_list[i]
                    end
                end

                DeleteBuff(target_data, buff_data)
                return true
            end

        return false
    end



    ---@param target unit
    ---@param buff_id integer
    ---@param time real
    function SetBuffExpirationTime(target, buff_id, time)
        local unit_data = GetUnitData(target)

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #unit_data.buff_list do
                    if unit_data.buff_list[i].id == buff_id then
                        if time == -1 then
                            unit_data.buff_list[i].expiration_time = unit_data.buff_list[i].level[unit_data.buff_list[i].current_level].time
                        else
                            unit_data.buff_list[i].expiration_time = time
                        end
                        break
                    end
                end
            end

    end


    ---@param target unit
    ---@param buff_id integer
    ---@param lvl integer
    function SetBuffLevel(target, buff_id, lvl)
        local unit_data = GetUnitData(target)


            for i = 1, #unit_data.buff_list do
                if unit_data.buff_list[i].id == buff_id then
                    local buff_data = unit_data.buff_list[i]

                    if lvl > unit_data.buff_list[i].max_level then
                        lvl = unit_data.buff_list[i].max_level
                    elseif lvl <= 0 then
                        RemoveBuff(target, buff_id)
                        return
                    end

                    for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                        ModifyStat(target, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, false)
                    end

                    buff_data.current_level = lvl

                    for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                        ModifyStat(target, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, true)
                    end

                    break
                end
            end

    end


     function IsHaveNegativeState(unit, state)
        local data = GetUnitData(unit)

            for i = 1, #data.buff_list do
                if data.buff_list[i].level[data.buff_list[i].current_level].negative_state ~= nil then
                    if data.buff_list[i].level[data.buff_list[i].current_level].negative_state == state then
                        return true
                    end
                end
            end

        return false
    end

    ---@param target unit
    ---@param buff_id integer
    ---@param lvl integer
    function ApplyBuff(source, target, buff_id, lvl)
        local buff_data = MergeTables({}, GetBuffData(buff_id))
        local target_data = GetUnitData(target)
        local existing_buff

            --TODO buff with higher rank replace weaker buffs


            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #target_data.buff_list do
                    if target_data.buff_list[i].id == buff_id then
                        existing_buff = target_data.buff_list[i]
                            if lvl >= existing_buff.current_level then
                                DeleteBuff(target_data, existing_buff)
                            else
                                buff_data = nil
                                return false
                            end
                        break
                    end
                end
            end


            buff_data.current_level = lvl
            buff_data.expiration_time = buff_data.level[lvl].time


        if buff_data.level[lvl].negative_state ~= nil then

            if buff_data.level[lvl].negative_state == STATE_FREEZE then
                SetUnitVertexColor(target, 57, 57, 255, 255)
                ResetUnitSpellCast(target)
                BlzPauseUnitEx(target, true)
                SetUnitTimeScale(target, 0.)
            elseif buff_data.level[lvl].negative_state == STATE_STUN then
                BlzPauseUnitEx(target, true)
                ResetUnitSpellCast(target)
            end


            buff_data.expiration_time = buff_data.expiration_time * ((100. - target_data.stats[CONTROL_REDUCTION].value) * 0.01)

            if buff_data.expiration_time <= 0. then
                buff_data = nil
                return false
            end

        end

            if buff_data.level[lvl].effect_sfx ~= nil then
                local new_effect
                    if buff_data.level[lvl].effect_sfx_point ~= nil then
                        new_effect = AddSpecialEffectTarget(buff_data.level[lvl].effect_sfx, target, buff_data.level[lvl].effect_sfx_point)
                    else
                        new_effect = AddSpecialEffect(buff_data.level[lvl].effect_sfx, GetUnitX(target), GetUnitY(target))
                    end
                BlzSetSpecialEffectScale(new_effect, buff_data.level[lvl].effect_sfx_scale)
                DestroyEffect(new_effect)
            end

            UnitAddAbility(target, FourCC(buff_data.id))
            table.insert(target_data.buff_list, buff_data)

            --print(#buff_data.level[lvl].bonus)
            if buff_data.level[lvl].bonus ~= nil then
                for i = 1, #buff_data.level[lvl].bonus do
                    ModifyStat(target, buff_data.level[lvl].bonus[i].PARAM, buff_data.level[lvl].bonus[i].VALUE, buff_data.level[lvl].bonus[i].METHOD, true)
                end
            end

            local over_time_effect_delay
            if buff_data.level[lvl].effect_delay ~= nil and buff_data.level[lvl].effect_delay > 0. then
                over_time_effect_delay = buff_data.level[lvl].effect_delay
            end

            buff_data.update_timer = CreateTimer()
            TimerStart(buff_data.update_timer, BUFF_UPDATE, true, function()

                if buff_data.expiration_time <= 0. or GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                    DeleteBuff(target_data, buff_data)
                else

                    if over_time_effect_delay ~= nil then

                        if over_time_effect_delay <= 0 then

                            if buff_data.level[buff_data.current_level].effect_damage ~= nil then
                                DamageUnit(source, target, buff_data.level[buff_data.current_level].effect_damage.damage,
                                        buff_data.level[buff_data.current_level].effect_damage.attribute,
                                        buff_data.level[buff_data.current_level].effect_damage.damage_type,
                                        buff_data.level[buff_data.current_level].effect_damage.attack_type,
                                        buff_data.level[buff_data.current_level].effect_damage.can_crit, false, false, nil)
                            end

                                if buff_data.level[buff_data.current_level].effect_hp_value ~= nil then
                                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + buff_data.level[buff_data.current_level].effect_hp_value)
                                    CreateHitnumber(R2I(buff_data.level[buff_data.current_level].effect_hp_value), source, target, HEAL_STATUS)
                                end

                                if buff_data.level[buff_data.current_level].effect_mp_value ~= nil then
                                    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + buff_data.level[buff_data.current_level].effect_mp_value)
                                    CreateHitnumber(R2I(buff_data.level[buff_data.current_level].effect_mp_value), source, target, RESOURCE_STATUS)
                                end

                            if buff_data.level[buff_data.current_level].effect_hp_percent_value ~= nil then
                                local value = BlzGetUnitMaxHP(target) * buff_data.level[buff_data.current_level].effect_hp_percent_value
                                    if buff_data.level[buff_data.current_level].effect_type == OVER_TIME_DAMAGE then
                                        UnitDamageTarget(source, target, value, false, false, nil, nil, nil)
                                        CreateHitnumber(R2I(value), source, target, ATTACK_STATUS_USUAL)
                                    else
                                        SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + value)
                                        CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
                                    end
                            end

                            if buff_data.level[buff_data.current_level].effect_mp_percent_value ~= nil then
                                local value = BlzGetUnitMaxMana(target) * buff_data.level[buff_data.current_level].effect_mp_percent_value
                                    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + value)
                                    CreateHitnumber(R2I(value), source, target, RESOURCE_STATUS)
                            end

                            over_time_effect_delay = buff_data.level[buff_data.current_level].effect_delay

                            if buff_data.level[buff_data.current_level].effect_trigger_sfx ~= nil then
                                local new_effect = AddSpecialEffectTarget(buff_data.level[buff_data.current_level].effect_trigger_sfx, target, buff_data.level[buff_data.current_level].effect_trigger_sfx_point)
                                BlzSetSpecialEffectScale(new_effect, buff_data.level[buff_data.current_level].effect_trigger_sfx_scale)
                                DestroyEffect(new_effect)
                            end

                        else
                            over_time_effect_delay = over_time_effect_delay - BUFF_UPDATE
                        end

                    end

                    buff_data.expiration_time = buff_data.expiration_time - BUFF_UPDATE
                end

            end)

        return true
    end

end