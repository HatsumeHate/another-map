do

    local BUFF_UPDATE = 0.1


    function ApplyBuff(source, target, buff_id, lvl)
        local buff_data = MergeTables({}, GetBuffData(buff_id))
        --local source_data = GetUnitData(source)
        local target_data = GetUnitData(target)
        local expiration_time = buff_data.level[lvl].time

            --TODO replace buff when same applies
            --TODO buff with higher rank replace weaker buffs

            UnitAddAbility(target, FourCC(buff_data.id))
            table.insert(target_data.buff_list, buff_data)


            for i = 1, #buff_data.level[lvl].bonus do
                ModifyStat(target, buff_data.level[lvl].bonus[i].PARAM, buff_data.level[lvl].bonus[i].VALUE, buff_data.level[lvl].bonus[i].METHOD, true)
            end


            TimerStart(CreateTimer(), BUFF_UPDATE, true, function()

                if expiration_time <= 0. or GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then

                    UnitRemoveAbility(target, FourCC(buff_data.buff_id))
                    UnitRemoveAbility(target, FourCC( buff_data.id))

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
                    DestroyTimer(GetExpiredTimer())
                else
                    expiration_time = expiration_time - BUFF_UPDATE
                end

            end)
    end

end




