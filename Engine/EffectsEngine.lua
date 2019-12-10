do




    ---@param sfx string
    ---@param target unit
    ---@param point string
    local function PlaySpecialEffect(sfx, target, point, scale)
        if sfx ~= nil then
            local new_effect = AddSpecialEffectTarget(sfx, target, point)
            BlzSetSpecialEffectScale(new_effect, scale)
            DestroyEffect(new_effect)
        end
    end


    ---@param source unit
    ---@param target unit
    ---@param effect_data table
    ---@param lvl integer
    ---@param target_type integer
    local function ModifyBuffsEffect(source, target, effect_data, lvl, target_type)
        if effect_data.level[lvl].applied_buff ~= nil then

            for i = 1, #effect_data.level[lvl].applied_buff do
                if effect_data.level[lvl].applied_buff[i].target_type == target_type then
                    if effect_data.level[lvl].applied_buff[i].modificator == ADD_BUFF then
                        ApplyBuff(source, target, effect_data.level[lvl].applied_buff[i].buff_id, lvl)
                    elseif effect_data.level[lvl].applied_buff[i].modificator == REMOVE_BUFF then
                        RemoveBuff(target, effect_data.level[lvl].applied_buff[i].buff_id)
                    elseif effect_data.level[lvl].applied_buff[i].modificator == INCREASE_BUFF_LEVEL then
                        local l = GetBuffLevel(target, effect_data.level[lvl].applied_buff[i].buff_id)
                        if l == 0 then
                            ApplyBuff(source, target, effect_data.level[lvl].applied_buff[i].buff_id, lvl)
                        else
                            SetBuffLevel(target, effect_data.level[lvl].applied_buff[i].buff_id, l + 1)
                        end
                    elseif effect_data.level[lvl].applied_buff[i].modificator == DECREASE_BUFF_LEVEL then
                        SetBuffLevel(target, effect_data.level[lvl].applied_buff[i].buff_id, GetBuffLevel(target, effect_data.level[lvl].applied_buff[i].buff_id) - 1)
                    elseif effect_data.level[lvl].applied_buff[i].modificator == SET_BUFF_LEVEL then
                        SetBuffLevel(target, effect_data.level[lvl].applied_buff[i].buff_id, effect_data.level[lvl].applied_buff[i].value)
                    elseif effect_data.level[lvl].applied_buff[i].modificator == SET_BUFF_TIME then
                        SetBuffExpirationTime(target, effect_data.level[lvl].applied_buff[i].buff_id, effect_data.level[lvl].applied_buff[i].value)
                    end
                end
            end

        end
    end


    ---@param data table
    ---@param target_type integer
    local function CountBuffEffects(data, target_type)
        local count = 0
            for i = 1, #data do
                if data[i].target_type == target_type then
                    count = count + 1
                end
            end
        return count
    end



    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    ---@param target_type integer
    function ApplyBuffEffect(source, target, data, lvl, target_type)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point, data.level[lvl].SFX_on_unit_scale)
        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].hit_delay, false, function()
            ModifyBuffsEffect(source, target, data, lvl, target_type)
            OnEffectApply(source, target, data)
            DestroyTimer(GetExpiredTimer())
        end)
    end

    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    function ApplyEffectHealing(source, target, data, lvl)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point, data.level[lvl].SFX_on_unit_scale)

        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].hit_delay, false, function()
            if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                local value = GetUnitState(target, UNIT_STATE_LIFE) + data.level[lvl].heal_amount
                SetUnitState(target, value)
                CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
                ModifyBuffsEffect(source, target, data, lvl, ON_ALLY)
                OnEffectApply(source, target, data)
            end
            DestroyTimer(GetExpiredTimer())
        end)
    end

    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    function ApplyEffectDamage(source, target, data, lvl)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point, data.level[lvl].SFX_on_unit_scale)
        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].hit_delay, false, function()
            print("effect damage")
            print(data.level[lvl].attribute)
            print(data.level[lvl].damage_type)
            print(data.level[lvl].attack_type)
            print(data.level[lvl].can_crit)
            print(data.level[lvl].is_direct)
            print("effect damage end")

            DamageUnit(source, target, data.level[lvl].power, data.level[lvl].attribute, data.level[lvl].damage_type, data.level[lvl].attack_type, data.level[lvl].can_crit, data.level[lvl].is_direct
            ,false, { eff = data, l = lvl })

            ModifyBuffsEffect(source, target, data, lvl, ON_ENEMY)


                if data.level[lvl].life_restored_from_hit then
                    if data.level[lvl].life_restored ~= nil and data.level[lvl].life_restored > 0 then
                        SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + data.level[lvl].life_restored)
                        CreateHitnumber(R2I(data.level[lvl].life_restored), source, source, HEAL_STATUS)
                    elseif data.level[lvl].life_percent_restored ~= nil and data.level[lvl].life_percent_restored > 0 then
                        local value = BlzGetUnitMaxHP(source) * data.level[lvl].life_percent_restored
                        SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + value)
                        CreateHitnumber(R2I(value), source, source, HEAL_STATUS)
                    end
                end


                if data.level[lvl].resource_restored_from_hit then
                    if data.level[lvl].resource_restored ~= nil and data.level[lvl].resource_restored > 0 then
                        SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + data.level[lvl].resource_restored)
                        CreateHitnumber(R2I(data.level[lvl].resource_restored), source, source, RESOURCE_STATUS)
                    elseif data.level[lvl].resource_percent_restored ~= nil and data.level[lvl].resource_percent_restored > 0 then
                        local value = BlzGetUnitMaxMana(source) * data.level[lvl].resource_percent_restored
                        SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + value)
                        CreateHitnumber(R2I(value), source, source, RESOURCE_STATUS)
                    end
                end

            OnEffectApply(source, target, data)
            DestroyTimer(GetExpiredTimer())
        end)

    end




    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param effect_id integer
    ---@param lvl integer
    function ApplyEffect(source, target, x, y, effect_id, lvl)
        local data = GetEffectData(effect_id)
        local player_entity = GetOwningPlayer(source)


            if data ~= nil then
                data = MergeTables({}, data)
            else
                return
            end

        data.current_level = lvl

        OnEffectPrecast(source, target, x, y, data)


        if data.remove_after_use then
            data.remove_timer = CreateTimer()
            TimerStart(data.remove_timer, data.level[lvl].delay + data.level[lvl].hit_delay + 1., false, function()
                DestroyTimer(data.remove_timer)
                data = nil
            end)
        end

            if target ~= nil then
                x = GetUnitX(target)
                y = GetUnitY(target)
            end


            if data.level[lvl].SFX_used ~= nil then
                local effect = AddSpecialEffect(data.level[lvl].SFX_used, x, y)
                BlzSetSpecialEffectScale(effect, data.level[lvl].SFX_used_scale)
                DestroyEffect(effect)
                effect = nil
            end


            if data.level[lvl].sound ~= nil then
                AddSound(data.level[lvl].sound, x, y)
            end


            if (data.level[lvl].SFX_on_unit ~= nil and target ~= nil) then
                local effect = AddSpecialEffectTarget(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point)
                BlzSetSpecialEffectScale(effect, data.level[lvl].SFX_on_unit_scale)
                DestroyEffect(effect)
                effect = nil
            end


            if not data.level[lvl].life_restored_from_hit then
                if data.level[lvl].life_restored ~= nil and data.level[lvl].life_restored > 0 then
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + data.level[lvl].life_restored)
                    CreateHitnumber(R2I(data.level[lvl].life_restored), source, target, HEAL_STATUS)
                elseif data.level[lvl].life_percent_restored ~= nil and data.level[lvl].life_percent_restored > 0 then
                    local value = BlzGetUnitMaxHP(target) * data.level[lvl].life_percent_restored
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + value)
                    CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
                end
            end

            if not data.level[lvl].resource_restored_from_hit then
                if data.level[lvl].resource_restored ~= nil and data.level[lvl].resource_restored > 0 then
                    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + data.level[lvl].resource_restored)
                    CreateHitnumber(R2I(data.level[lvl].resource_restored), source, target, RESOURCE_STATUS)
                elseif data.level[lvl].resource_percent_restored ~= nil and data.level[lvl].resource_percent_restored > 0 then
                    local value = BlzGetUnitMaxMana(target) * data.level[lvl].resource_percent_restored
                    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + value)
                    CreateHitnumber(R2I(value), source, target, RESOURCE_STATUS)
                end
            end


            TimerStart(CreateTimer(), data.level[lvl].delay, false, function()
                -- damaging
                if data.level[lvl].power ~= nil then
                    -- multiple target damage
                    if data.level[lvl].area_of_effect ~= nil then
                        local enemy_group = CreateGroup()
                        GroupEnumUnitsInRange(enemy_group, x, y, data.level[lvl].area_of_effect, nil)

                            for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(enemy_group, index)

                                if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045  then
                                    ApplyEffectDamage(source, picked, data, lvl)
                                end

                            end

                        GroupClear(enemy_group)
                        DestroyGroup(enemy_group)
                    else
                        -- single target damage
                        if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and IsUnitEnemy(target, player_entity) then
                            ApplyEffectDamage(source, target, data, lvl)
                        end
                    end

                else
                    -- multiple target debuff
                    if CountBuffEffects(data.level[lvl].applied_buff, ON_ENEMY) > 0 then
                        if data.level[lvl].area_of_effect ~= nil then
                            local enemy_group = CreateGroup()
                            GroupEnumUnitsInRange(enemy_group, x, y, data.level[lvl].area_of_effect, nil)

                                for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(enemy_group, index)

                                    if not (IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045) then
                                        GroupRemoveUnit(enemy_group, picked)
                                    end

                                end

                                ForGroup(enemy_group, function()
                                    ApplyBuffEffect(source, GetEnumUnit(), data, lvl, ON_ENEMY)
                                end)

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        else
                            if IsUnitEnemy(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                                ApplyBuffEffect(source, target, data, lvl, ON_ENEMY)
                            end
                        end
                    end

                end

            -- healing
                if data.level[lvl].heal_amount ~= nil then
                    -- multiple target healing
                    if data.level[lvl].area_of_effect ~= nil then

                        local enemy_group = CreateGroup()
                        GroupEnumUnitsInRange(enemy_group, x, y, data.level[lvl].area_of_effect, nil)

                            for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(enemy_group, index)

                                if IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then
                                    ApplyEffectHealing(source, picked, data, lvl)
                                end

                            end

                        GroupClear(enemy_group)
                        DestroyGroup(enemy_group)

                    else
                        -- single target healing
                        if IsUnitAlly(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                            ApplyEffectHealing(source, target, data, lvl)
                        end

                    end
                else
                    -- positive buffs
                    if CountBuffEffects(data.level[lvl].applied_buff, ON_ALLY) > 0 then
                        if data.level[lvl].area_of_effect ~= nil then
                            local enemy_group = CreateGroup()
                            GroupEnumUnitsInRange(enemy_group, x, y, data.level[lvl].area_of_effect, nil)

                            for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(enemy_group, index)

                                if not (IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045) then
                                    GroupRemoveUnit(enemy_group, picked)
                                end

                            end

                            ForGroup(enemy_group, function()
                                ApplyBuffEffect(source, GetEnumUnit(), data, lvl, ON_ALLY)
                            end)

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        else
                            if IsUnitAlly(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                                ApplyBuffEffect(source, target, data, lvl, ON_ALLY)
                            end
                        end
                    end

                end

                ModifyBuffsEffect(source, source, data, lvl, ON_SELF)

                DestroyTimer(GetExpiredTimer())
            end)


        print("EFFECT END")
        return data
    end

end
