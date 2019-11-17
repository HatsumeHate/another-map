
    ParametersUpdate = {}

    -- parameters types
    PHYSICAL_ATTACK = 1
    PHYSICAL_DEFENCE = 2

    MAGICAL_ATTACK = 3
    MAGICAL_SUPPRESSION = 4

    CRIT_CHANCE = 5
    CRIT_MULTIPLIER = 6

    HP_REGEN = 7
    MP_REGEN = 8

    HP_VALUE = 25
    MP_VALUE = 26

    PHYSICAL_RESIST = 9
    FIRE_RESIST = 10
    ICE_RESIST = 11
    LIGHTNING_RESIST = 12
    POISON_RESIST = 13
    ARCANE_RESIST = 14
    DARKNESS_RESIST = 15
    HOLY_RESIST = 16

    PHYSICAL_BONUS = 17
    FIRE_BONUS = 18
    ICE_BONUS = 19
    LIGHTNING_BONUS = 20
    POISON_BONUS = 21
    ARCANE_BONUS = 22
    DARKNESS_BONUS = 23
    HOLY_BONUS = 24

    STR_STAT = 27
    AGI_STAT = 28
    INT_STAT = 29
    VIT_STAT = 30



    -- attributes
    PHYSICAL = 1
    FIRE = 2
    ICE = 3
    LIGHTNING = 4
    POISON = 5
    ARCANE = 6
    DARKNESS = 7
    HOLY = 8

    -- damage types
    DAMAGE_TYPE_PHYSICAL = 1
    DAMAGE_TYPE_MAGICAL = 2
    DAMAGE_TYPE_NONE = 3



    -- limits
    VALUE_BY_PERCENT_1 = 11
    FIRST_DEF_LIMIT = 350
    VALUE_BY_PERCENT_2 = 15
    SECOND_DEF_LIMIT = 650
    VALUE_BY_PERCENT_3 = 19

    --маг атака
    MA_VALUE_BY_PERCENT_1 = 5
    MA_FIRST_LIMIT = 275
    MA_VALUE_BY_PERCENT_2 = 7
    MA_SECOND_LIMIT = 340
    MA_VALUE_BY_PERCENT_3 = 12


    --защита в процент
    ---@param x integer
    function DefenceToPercent(x)
            if x <= FIRST_DEF_LIMIT then
                return x / VALUE_BY_PERCENT_1
            elseif (x > FIRST_DEF_LIMIT and x <= SECOND_DEF_LIMIT) then
                return (FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1) + ((x - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2)
            elseif (x > SECOND_DEF_LIMIT) then
                return (FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1) + ((SECOND_DEF_LIMIT - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2) + ((x - SECOND_DEF_LIMIT) / VALUE_BY_PERCENT_3)
            end
        return 0.
    end

    --маг атака в процент
    ---@param x integer
    function MagicAttackToPercent(x)
            if x <= MA_FIRST_LIMIT then
                return x / MA_VALUE_BY_PERCENT_1
            elseif (x > MA_FIRST_LIMIT and x <= MA_SECOND_LIMIT) then
                return (MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1) + ((x - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2)
            elseif (x > MA_SECOND_LIMIT) then
                return (MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1) + ((MA_SECOND_LIMIT - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2) + ((x - MA_SECOND_LIMIT) / MA_VALUE_BY_PERCENT_3)
            end
        return 0.
    end




    function NewStat(stat_type)
        local param = {
            stat_type = stat_type,

            value = 0.,
            multiplier = 1.,
            bonus = 0.,

            multiply = function(unit_data, param, value, flag)
                    if flag then
                        param.multiplier = param.multiplier * value
                    else
                        param.multiplier = param.multiplier / value
                    end
                ParametersUpdate[stat_type](unit_data)
            end,

            summ = function(unit_data, param, value, flag)
                    if flag then
                        param.bonus = param.bonus + value
                    else
                        param.bonus = param.bonus - value
                    end
                ParametersUpdate[stat_type](unit_data)
            end
        }

        return param
    end


    function CreateParametersData()
        local parameters = { }

            for i = 1, 32 do
                parameters[i] = NewStat(i)
            end

        return parameters
    end



    function DefineParametersData()
        ParametersUpdate[PHYSICAL_ATTACK] = function(unit_data)
            unit_data[PHYSICAL_ATTACK].value = (unit_data[PHYSICAL_ATTACK].STR_STAT * unit_data[PHYSICAL_ATTACK].multiplier) + unit_data[PHYSICAL_ATTACK].bonus
        end


    end