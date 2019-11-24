do




    local function PlaySpecialEffect(sfx, target, point)
        if sfx ~= nil then
            local new_effect = AddSpecialEffectTarget(sfx, target, point)
            DestroyEffect(new_effect)
        end
    end


    local function ModifyBuffsEffect(source, target, effect_data, lvl, target_type)
        print("zzzzzzzz")
        print(effect_data.level[lvl].applied_buff[1].modificator)

        for i = 1, #effect_data.level[lvl].applied_buff do
            if effect_data.level[lvl].applied_buff[i].target_type == target_type then
                print("target type ok")
                if effect_data.level[lvl].applied_buff[i].modificator == ADD_BUFF then
                    print("target type ok")
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
        print("bbbbbb")
    end


    local function CountBuffEffects(data, target_type)
        local count = 0
            for i = 1, #data do
                if data[i].target_type == target_type then
                    count = count + 1
                end
            end
        return count
    end



    function ApplyBuffEffect(source, target, data, lvl, target_type)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point)
        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].delay, false, function()
            ModifyBuffsEffect(source, target, data, lvl, target_type)
            DestroyTimer(GetExpiredTimer())
        end)
    end

    function ApplyEffectHealing(source, target, data, lvl)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point)

        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].delay, false, function()
            if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                local value = GetUnitState(target, UNIT_STATE_LIFE) + data.level[lvl].heal_amount
                SetUnitState(target, value)
                CreateHitnumber(value, source, target, HEAL_STATUS)
                ModifyBuffsEffect(source, target, data, lvl, ON_ALLY)
            end
            DestroyTimer(GetExpiredTimer())
        end)
    end

    function ApplyEffectDamage(source, target, data, lvl)
        PlaySpecialEffect(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point)
        -- delay for effect animation
        TimerStart(CreateTimer(), data.level[lvl].delay, false, function()
            if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                print("final, damage")
                DamageUnit(source, target, data.level[lvl].power, data.level[lvl].attribute, data.level[lvl].damage_type, data.level[lvl].attack_type, data.level[lvl].can_crit, false, { eff = data, l = lvl })
                ModifyBuffsEffect(source, target, data, lvl, ON_ENEMY)
                print("final, debuffs")
            end
            DestroyTimer(GetExpiredTimer())
        end)
    end



    function ApplyEffect(source, target, x, y, effect_id, lvl)
        local unit_data = GetUnitData(source)
        local data = GetEffectData(effect_id)
        local player_entity = GetOwningPlayer(source)


            if data == nil then return end

            if target ~= nil then
                x = GetUnitX(target)
                y = GetUnitY(target)
            end


            if data.level[lvl].SFX_used ~= nil then
                bj_lastCreatedEffect = AddSpecialEffect(data.level[lvl].SFX_used, x, y)
                DestroyEffect(bj_lastCreatedEffect)
            end


            if data.level[lvl].sound ~= nil then
                AddSound(data.level[lvl].sound, x, y)
            end


            if (data.level[lvl].SFX_on_unit ~= nil and target ~= nil) then
                bj_lastCreatedEffect = AddSpecialEffectTarget(data.level[lvl].SFX_on_unit, target, data.level[lvl].SFX_on_unit_point)
                DestroyEffect(bj_lastCreatedEffect)
            end


                -- damaging
        if data.level[lvl].power ~= nil then
            print("power")
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
                print("single")
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

        print("ccccccccccccc")
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


        print("aaaaaa")
        ModifyBuffsEffect(source, source, data, lvl, ON_SELF)


    end

end


--[[
elseif data.level[lvl].applied_buff[i].target_type == ON_ALLY then
                            if data.level[lvl].area_of_effect ~= nil then
                                local enemy_group = CreateGroup()
                                GroupEnumUnitsInRange(enemy_group, x, y, data.level[lvl].area_of_effect, nil)

                                for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(enemy_group, index)

                                    if IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 then
                                        ApplyBuff(source, picked, data.level[lvl].applied_buff[i].buff_id, lvl)
                                    end

                                end

                                GroupClear(enemy_group)
                                DestroyGroup(enemy_group)
                            else
                                ApplyBuff(source, target, data.level[lvl].applied_buff[i].buff_id, lvl)
                            end
]]