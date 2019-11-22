do

    local BUFF_UPDATE = 0.1



    local function DeleteBuff(unit_data, buff_data)
        for i = 1, #unit_data.buff_list do
            if unit_data.buff_list[i] == buff_data then
                UnitRemoveAbility(target, FourCC(buff_data.buff_id))
                UnitRemoveAbility(target, FourCC(buff_data.id))

                for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                    ModifyStat(target, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, false)
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

        --[[
        for i = 1, #buff_data.buff_replacer do
            if GetUnitAbilityLevel(target, FourCC(buff_data.buff_replacer[i].buff_id)) > 0 then

                for i2 = 1, #target_data.buff_list do
                    if target_data.buff_list[i2].id == buff_data.buff_replacer[i].buff_id then
                        existing_buff = target_data.buff_list[i2]

                        if buff_data.level[lvl].rank >= existing_buff.level[existing_buff.current_level].rank then
                            DeleteBuff(target_data, existing_buff)
                        end

                    end
                end

            end
        end]]

            buff_data.current_level = lvl
            buff_data.expiration_time = buff_data.level[lvl].time

            UnitAddAbility(target, FourCC(buff_data.id))
            table.insert(target_data.buff_list, buff_data)

            for i = 1, #buff_data.level[lvl].bonus do
                ModifyStat(target, buff_data.level[lvl].bonus[i].PARAM, buff_data.level[lvl].bonus[i].VALUE, buff_data.level[lvl].bonus[i].METHOD, true)
            end

            buff_data.update_timer = CreateTimer()
            TimerStart(buff_data.update_timer, BUFF_UPDATE, true, function()

                if buff_data.expiration_time <= 0. or GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                    DeleteBuff(target_data, buff_data)
                else
                    buff_data.expiration_time = buff_data.expiration_time - BUFF_UPDATE
                end

            end)

        return true
    end

end


--[[
                    UnitRemoveAbility(target, FourCC(buff_data.buff_id))
                    UnitRemoveAbility(target, FourCC(buff_data.id))

                    for i = 1, #buff_data.level[lvl].bonus do
                        ModifyStat(target, buff_data.level[lvl].bonus[i].PARAM, buff_data.level[lvl].bonus[i].VALUE, buff_data.level[lvl].bonus[i].METHOD, false)
                    end

                    for i = 1, #target_data.buff_list do
                        if target_data.buff_list[i] == buff_data then
                            table.remove(target_data.buff_list, i)
                            break
                        end
                    end

                    buff_data = nil
                    ]]

