---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 30.03.2020 0:17
---
do


    MONSTER_STATS_RATES = nil
    BONUS_MONSTER_STAT_RATES = nil


    ---@param target unit
    function ScaleMonsterUnit(target, to_level)
        local monster_id = GetUnitTypeId(target)
        local unit_data = GetUnitData(target)

        if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then return end

        if not unit_data.unit_level then
            unit_data.unit_level = 1
            unit_data.scaling_values = {}
        end

        --print("scale - start " .. GetUnitName(target))

            for i = 1, #MONSTER_STATS_RATES do
                local level_modulo = math.floor(to_level / MONSTER_STATS_RATES[i].delta_level)
                local power_modulo = math.floor(unit_data.unit_level / MONSTER_STATS_RATES[i].delta_level)
                local difference = level_modulo - power_modulo
                local bonus_delta = 0
                --print("=========")
                --print(GetParameterName(MONSTER_STATS_RATES[i].stat))
                --print("level scaling " .. level_modulo)
                --print("power scaling " .. power_modulo)

                if BONUS_MONSTER_STAT_RATES[monster_id] and BONUS_MONSTER_STAT_RATES[monster_id][MONSTER_STATS_RATES[i].stat] then
                    bonus_delta = BONUS_MONSTER_STAT_RATES[monster_id][MONSTER_STATS_RATES[i].stat]
                end

                if difference > 0 then
                    local stat = MONSTER_STATS_RATES[i].stat
                    local last_multiplicator = 0.
                    --print("must scale")
                    --print("difference " .. difference)
                    --print( "active " .. ActivePlayers)
                    bonus_delta = MONSTER_STATS_RATES[i].delta + bonus_delta + ((MONSTER_STATS_RATES[i].per_player or 0.) * (ActivePlayers - 1))
                    local delta = bonus_delta
                    --print(R2S(MONSTER_STATS_RATES[i].initial) .. "/" .. R2S(MONSTER_STATS_RATES[i].delta))
                    --print("=====")
                    --print(GetParameterName(stat))
                    if unit_data.scaling_values[stat] and MONSTER_STATS_RATES[i].method == MULTIPLY_BONUS then
                        --[[
                        local scaling_value = unit_data.scaling_values[stat]
                        print("scaling values total " .. #scaling_value)
                        for i = 1, #scaling_value do
                            print("current stored modifier " .. scaling_value[i])

                            mult_summ = mult_summ + (scaling_value[i] - 1.)
                        end]]
                        ModifyStat(target, stat, MONSTER_STATS_RATES[i].initial + unit_data.scaling_values[stat], MULTIPLY_BONUS, false)
                        last_multiplicator = unit_data.scaling_values[stat] -- 0.04
                        --print("last value is ".. unit_data.scaling_values[stat])
                    end

                    bonus_delta = MONSTER_STATS_RATES[i].initial + last_multiplicator + (difference * bonus_delta)
                    if MONSTER_STATS_RATES[i].method ~= MULTIPLY_BONUS then
                        bonus_delta = R2I(bonus_delta)
                    end
                    
                    ModifyStat(target, stat, bonus_delta, MONSTER_STATS_RATES[i].method, true)
                    --print("result modificator is ".. bonus_delta)


                    if MONSTER_STATS_RATES[i].method == MULTIPLY_BONUS then
                        unit_data.scaling_values[stat] = last_multiplicator + delta -- 0 + 0.04
                        --print("new scaling value is " .. unit_data.scaling_values[stat])
                        --[[
                        if unit_data.scaling_values[stat] then
                            unit_data.scaling_values[stat][#unit_data.scaling_values[stat] + 1] = bonus_delta - mult_summ
                            print("insert in ".. (#unit_data.scaling_values[stat]) .. " value " .. (bonus_delta - mult_summ))
                        else


                        end]]
                    end
                    --BONUS_MONSTER_STAT_RATES[monster_id][MONSTER_STATS_RATES[i].stat] or
                end

            end

        -- TODO test scaling
        if BONUS_MONSTER_STAT_RATES[monster_id] and BONUS_MONSTER_STAT_RATES[monster_id].scaling then
            local scaling = BONUS_MONSTER_STAT_RATES[monster_id].scaling
            for i = 1, #scaling do
                local level_modulo = math.floor(to_level / scaling[i].delta_level)
                local power_modulo = math.floor(unit_data.unit_level / scaling[i].delta_level)
                local difference = level_modulo - power_modulo
                local bonus_delta = 0

                if BONUS_MONSTER_STAT_RATES[monster_id] and BONUS_MONSTER_STAT_RATES[monster_id][scaling[i].stat] then
                    bonus_delta = BONUS_MONSTER_STAT_RATES[monster_id][scaling[i].stat]
                end

                if difference > 0 then
                    ModifyStat(target, scaling[i].stat, scaling[i].initial + (difference * (scaling[i].delta + bonus_delta + ((scaling[i].per_player or 0.) * (ActivePlayers - 1)))),
                        scaling[i].method, true)
                end
            end
        end

        unit_data.unit_level = to_level

        --print("scale - end "  .. GetUnitName(target))

    end


    ---@param target_group group
    function ScaleMonsterGroup(target_group, to_level)

        --for i = 0, 5 do if IsPlayerSlotState(Player(i), PLAYER_SLOT_STATE_PLAYING) then ActivePlayers = ActivePlayers + 1 end end

        ForGroup(target_group, function()
            ScaleMonsterUnit(GetEnumUnit(), to_level)
        end)

    end



end