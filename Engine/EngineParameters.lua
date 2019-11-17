    ParametersUpdate      = {}

    -- parameters types
    PHYSICAL_ATTACK       = 1
    PHYSICAL_DEFENCE      = 2

    MAGICAL_ATTACK        = 3
    MAGICAL_SUPPRESSION   = 4

    CRIT_CHANCE           = 5
    CRIT_MULTIPLIER       = 6

    HP_REGEN              = 7
    MP_REGEN              = 8

    HP_VALUE              = 25
    MP_VALUE              = 26

    PHYSICAL_RESIST       = 9
    FIRE_RESIST           = 10
    ICE_RESIST            = 11
    LIGHTNING_RESIST      = 12
    POISON_RESIST         = 13
    ARCANE_RESIST         = 14
    DARKNESS_RESIST       = 15
    HOLY_RESIST           = 16

    PHYSICAL_BONUS        = 17
    FIRE_BONUS            = 18
    ICE_BONUS             = 19
    LIGHTNING_BONUS       = 20
    POISON_BONUS          = 21
    ARCANE_BONUS          = 22
    DARKNESS_BONUS        = 23
    HOLY_BONUS            = 24

    STR_STAT              = 27
    AGI_STAT              = 28
    INT_STAT              = 29
    VIT_STAT              = 30

    MELEE_DAMAGE_REDUCTION = 31
    RANGE_DAMAGE_REDUCTION = 32


    -- attributes
    PHYSICAL_ATTRIBUTE     = 1
    FIRE_ATTRIBUTE         = 2
    ICE_ATTRIBUTE          = 3
    LIGHTNING_ATTRIBUTE    = 4
    POISON_ATTRIBUTE       = 5
    ARCANE_ATTRIBUTE       = 6
    DARKNESS_ATTRIBUTE     = 7
    HOLY_ATTRIBUTE         = 8

    -- damage types
    DAMAGE_TYPE_PHYSICAL  = 1
    DAMAGE_TYPE_MAGICAL   = 2
    DAMAGE_TYPE_NONE      = 3


    -- calculate methods
    STRAIGHT_BONUS = 1
    MULTIPLY_BONUS = 2

    -- limits
    VALUE_BY_PERCENT_1    = 11
    FIRST_DEF_LIMIT       = 350
    VALUE_BY_PERCENT_2    = 15
    SECOND_DEF_LIMIT      = 650
    VALUE_BY_PERCENT_3    = 19

    --маг атака
    MA_VALUE_BY_PERCENT_1 = 5
    MA_FIRST_LIMIT        = 275
    MA_VALUE_BY_PERCENT_2 = 7
    MA_SECOND_LIMIT       = 340
    MA_VALUE_BY_PERCENT_3 = 12


    --защита в процент
    ---@param x integer
    function DefenceToPercent(x)
        if x <= FIRST_DEF_LIMIT then
            return x / VALUE_BY_PERCENT_1
        elseif x > FIRST_DEF_LIMIT and x <= SECOND_DEF_LIMIT then
            return FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1 + (x - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2
        elseif x > SECOND_DEF_LIMIT then
            return FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1 + (SECOND_DEF_LIMIT - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2 + (x - SECOND_DEF_LIMIT) / VALUE_BY_PERCENT_3
        end
        return 0
    end

    --маг атака в процент
    ---@param x integer
    function MagicAttackToPercent(x)
        if x <= MA_FIRST_LIMIT then
            return x / MA_VALUE_BY_PERCENT_1
        elseif x > MA_FIRST_LIMIT and x <= MA_SECOND_LIMIT then
            return MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1 + (x - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2
        elseif x > MA_SECOND_LIMIT then
            return MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1 + (MA_SECOND_LIMIT - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2 + (x - MA_SECOND_LIMIT) / MA_VALUE_BY_PERCENT_3
        end
        return 0
    end



    local ParameterName = { }


    ---@param parameter integer
    function GetParameterName(parameter_type)
        return ParameterName[parameter_type]
    end


    function NewStat(stat_type)
        return {
            stat_type  = stat_type,

            value      = 0,
            multiplier = 1,
            bonus      = 0,


            ---@param data any
            ---@param param any
            ---@param value any
            ---@param flag boolean
            multiply   = function(data, param, value, flag)
                param.multiplier = flag and param.multiplier * value or param.multiplier / value
                ParametersUpdate[stat_type](data)
            end,

            ---@param data any
            ---@param param any
            ---@param value any
            ---@param flag boolean
            summ       = function(data, param, value, flag)
                param.bonus = flag and param.bonus + value or param.bonus - value
                ParametersUpdate[stat_type](data)
            end
        }

    end

    function CreateParametersData()
        local parameters = { }

        for i = 1, 32 do
            parameters[i] = NewStat(i)
        end

        return parameters
    end

    function DefineParametersData()

        ---@param data table
        ParametersUpdate[PHYSICAL_ATTACK] = function(data)
            data.stats[PHYSICAL_ATTACK].value = (data[PHYSICAL_ATTACK].STR_STAT * data[PHYSICAL_ATTACK].multiplier) + data[PHYSICAL_ATTACK].bonus
        end

        ---@param data table
        ParametersUpdate[PHYSICAL_DEFENCE] = function(data)
            local defence = 0

                data.stats[PHYSICAL_DEFENCE].value = (defence * data[PHYSICAL_DEFENCE].multiplier) + data[PHYSICAL_DEFENCE].bonus
        end



        ParameterName[PHYSICAL_ATTACK]   = 'Физическая атака'
        ParameterName[PHYSICAL_DEFENCE]  = 'Физическая защита'
        ParameterName[MAGICAL_ATTACK]   = 'Магическая атака'
        ParameterName[MAGICAL_SUPPRESSION] = 'Подавление магии'
        
        ParameterName[CRIT_CHANCE] = 'Физическая атака'
        ParameterName[CRIT_MULTIPLIER] = 'Физическая атака'
        
        ParameterName[PHYSICAL_BONUS] = 'Физический урон'
        ParameterName[ICE_BONUS] = 'Урон от льда'
        ParameterName[FIRE_BONUS] = 'Урон от огня'
        ParameterName[LIGHTNING_BONUS] = 'Урон от молнии'
        ParameterName[POISON_BONUS] = 'Урон от яда'
        ParameterName[ARCANE_RESIST] = 'Урон от тайной магии'
        ParameterName[DARKNESS_BONUS] = 'Урон от тьмы'
        ParameterName[HOLY_BONUS] = 'Урон от святости'

        ParameterName[PHYSICAL_RESIST] = 'Сопротивление физ атакам'
        ParameterName[ICE_RESIST] = 'Сопротивление холоду'
        ParameterName[FIRE_RESIST] = 'Сщпротивление огню'
        ParameterName[LIGHTNING_RESIST] = 'Сопротивление молнии'
        ParameterName[POISON_RESIST] = 'Сопротивление ядам'
        ParameterName[ARCANE_RESIST] = 'Сопротивление тайной магии'
        ParameterName[DARKNESS_RESIST] = 'Сопротивление тьме'
        ParameterName[HOLY_RESIST] = 'Сопротивление святости'

        ParameterName[HP_REGEN] = 'Восстановление здоровья'
        ParameterName[MP_REGEN] = 'Восстановление ресурса'

        ParameterName[HP_VALUE] = 'Здоровье'
        ParameterName[MP_VALUE] = 'Ресурс'

        ParameterName[STR_STAT] = 'Сила'
        ParameterName[AGI_STAT] = 'Ловкость'
        ParameterName[INT_STAT] = 'Интеллект'
        ParameterName[VIT_STAT] = 'Выносливость'

    end
