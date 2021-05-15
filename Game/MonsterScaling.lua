---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 30.03.2020 0:17
---
do


    MONSTER_STATS_RATES = {
        { stat = PHYSICAL_ATTACK,       initial = 0,      delta = 3,     delta_level = 1, method = STRAIGHT_BONUS },
        { stat = MAGICAL_ATTACK,        initial = 0,      delta = 2,     delta_level = 1, method = STRAIGHT_BONUS },
        { stat = PHYSICAL_DEFENCE,      initial = 0,      delta = 3,     delta_level = 1, method = STRAIGHT_BONUS },
        { stat = MAGICAL_SUPPRESSION,   initial = 0,      delta = 2,     delta_level = 1, method = STRAIGHT_BONUS },
        { stat = PHYSICAL_ATTACK,       initial = 0.98,   delta = 0.02,  delta_level = 1, method = MULTIPLY_BONUS },
        { stat = PHYSICAL_DEFENCE,      initial = 0.99,   delta = 0.01,  delta_level = 1, method = MULTIPLY_BONUS },
        { stat = MAGICAL_ATTACK,        initial = 0.98,   delta = 0.02,  delta_level = 1, method = MULTIPLY_BONUS },
        { stat = MAGICAL_SUPPRESSION,   initial = 0.99,   delta = 0.01,  delta_level = 1, method = MULTIPLY_BONUS },
        { stat = CRIT_CHANCE,           initial = 0,      delta = 1.,    delta_level = 5, method = STRAIGHT_BONUS },
        { stat = ALL_RESIST,            initial = 0,      delta = 1,     delta_level = 5, method = STRAIGHT_BONUS },
        { stat = PHYSICAL_BONUS,        initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = ICE_BONUS,             initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = LIGHTNING_BONUS,       initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = FIRE_BONUS,            initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = DARKNESS_BONUS,        initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = HOLY_BONUS,            initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = POISON_BONUS,          initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = ARCANE_BONUS,          initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
        { stat = HP_VALUE,              initial = 0,      delta = 15,    delta_level = 1, method = STRAIGHT_BONUS },
        { stat = HP_VALUE,              initial = 0.96,   delta = 0.04,  delta_level = 1, method = MULTIPLY_BONUS },
    }

    BONUS_MONSTER_STAT_RATES = {
        [FourCC("abcd")] = {
            [PHYSICAL_ATTACK] = 0.
        }
    }


    ---@param target unit
    function ScaleMonsterUnit(target)
        local monster_id = GetUnitTypeId(target)

            for i = 1, #MONSTER_STATS_RATES do
                ModifyStat(target, MONSTER_STATS_RATES[i].stat, MONSTER_STATS_RATES[i].initial +
                        math.floor(Current_Wave / MONSTER_STATS_RATES[i].delta_level) *
                        (MONSTER_STATS_RATES[i].delta + BONUS_MONSTER_STAT_RATES[monster_id][MONSTER_STATS_RATES[i].stat] or 0.),
                         MONSTER_STATS_RATES[i].method, true)
            end

    end


    ---@param target_group group
    function ScaleMonsterGroup(target_group)
        ForGroup(target_group, function()
            ScaleMonsterUnit(GetEnumUnit())
        end)
    end



end