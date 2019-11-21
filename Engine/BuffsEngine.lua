do

    local BUFF_UPDATE = 0.1


    function ApplyBuff(source, target, buff_id, level)
        local buff_data = MergeTables({}, GetBuffDataLevel(buff_id, level))
        --local source_data = GetUnitData(source)
        local target_data = GetUnitData(target)


            --TODO replace buff when same applies
            --TODO buff with higher rank replace weaker buffs
            --TODO stats +-

            UnitAddAbility(target, buff_data.buff_id)
            table.insert(target_data.buff_list, buff_data)

            TimerStart(CreateTimer(), BUFF_UPDATE, true, function()

                if buff_data.time <= 0. then

                    --TODO stats +-

                    for i = 1, #target_data.buff_list do
                        if target_data.buff_list[i] == buff_data then
                            table.remove(target_data.buff_list, i)
                            break
                        end
                    end
                    DestroyTimer(GetExpiredTimer())
                else
                    buff_data.time = buff_data.time - BUFF_UPDATE
                end

            end)
    end

end




