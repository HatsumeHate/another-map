    ParametersUpdate      = {}

    -- parameters types
    PHYSICAL_ATTACK       = 27
    PHYSICAL_DEFENCE      = 28

    MAGICAL_ATTACK        = 29
    MAGICAL_SUPPRESSION   = 30

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

    STR_STAT              = 1
    AGI_STAT              = 2
    INT_STAT              = 3
    VIT_STAT              = 4

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


    ---@param value real
    function GetBonus_STR(value) return 0.9 + (value * 0.02) end

    ---@param value real
    function GetBonus_AGI(value) return 1. + (value * 0.01) end

    ---@param value real
    function GetBonus_INT(value) return 0.8 + (value * 0.04) end

    ---@param value real
    function GetBonus_VIT(value) return 0.9 + (value * 0.03) end





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


            ---@param data table
            ---@param param integer
            ---@param value real
            ---@param flag boolean
            multiply   = function(data, param, value, flag)
                param.multiplier = flag and param.multiplier * value or param.multiplier / value
                ParametersUpdate[stat_type](data)
            end,

            ---@param data table
            ---@param param integer
            ---@param value real
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
            local total_damage = data.equip_point[WEAPON_POINT].damage

                if data.equip_point[OFFHAND_POINT] ~= nil then
                    if data.equip_point[OFFHAND_POINT].item_type == ITEM_TYPE_WEAPON then
                        total_damage = total_damage + (data.equip_point[OFFHAND_POINT].damage * 0.5)
                    end
                end

            data.stats[PHYSICAL_ATTACK].value = (total_damage * GetBonus_STR(data.stats[STR_STAT].value) + data[PHYSICAL_ATTACK].bonus) * data[PHYSICAL_ATTACK].multiplier
        end


        ---@param data table
        ParametersUpdate[PHYSICAL_DEFENCE] = function(data)
            local defence = 0

                for i = 2, 6 do
                    if data.equip_slot[i] ~= nil then
                        defence = defence + data.equip_slot[i].DEFENCE
                    end
                end

                data.stats[PHYSICAL_DEFENCE].value = (defence + data[PHYSICAL_DEFENCE].bonus) * data[PHYSICAL_DEFENCE].multiplier
        end

        ---@param data table
        ParametersUpdate[CRIT_CHANCE] = function(data)
            data.stats[CRIT_CHANCE].value = (data.equip_slot[WEAPON_POINT].critical_chance + data[CRIT_CHANCE].bonus) * data[CRIT_CHANCE].multiplier
        end

        ---@param data table
        ParametersUpdate[CRIT_MULTIPLIER] = function(data)
            data.stats[CRIT_MULTIPLIER].value = (data.equip_slot[CRIT_MULTIPLIER].critical_multiplier + data[CRIT_MULTIPLIER].bonus) * data[CRIT_MULTIPLIER].multiplier
        end


        ---@param data table
        ParametersUpdate[HP_REGEN] = function(data)
            data.stats[HP_REGEN].value = (data.base_stats.hp_regen + data[HP_REGEN].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data[HP_REGEN].multiplier
        end

        ---@param data table
        ParametersUpdate[MP_REGEN] = function(data)
            data.stats[MP_REGEN].value = (data.base_stats.mp_regen + data[MP_REGEN].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data[MP_REGEN].multiplier
        end

        ---@param data table
        ParametersUpdate[HP_VALUE] = function(data)
            data.stats[HP_VALUE].value = (data.base_stats.HP + data[HP_VALUE].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data[HP_VALUE].multiplier
        end

        ---@param data table
        ParametersUpdate[MP_VALUE] = function(data)
            data.stats[MP_VALUE].value = (data.base_stats.MP + data[MP_VALUE].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data[MP_VALUE].multiplier
        end

        ---@param data table
        ParametersUpdate[PHYSICAL_RESIST] = function(data)
            data.stats[PHYSICAL_RESIST].value = data[PHYSICAL_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[FIRE_RESIST] = function(data)
            data.stats[FIRE_RESIST].value = data[FIRE_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[ICE_RESIST] = function(data)
            data.stats[ICE_RESIST].value = data[ICE_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[LIGHTNING_RESIST] = function(data)
            data.stats[LIGHTNING_RESIST].value = data[LIGHTNING_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[POISON_RESIST] = function(data)
            data.stats[POISON_RESIST].value = data[POISON_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[ARCANE_RESIST] = function(data)
            data.stats[ARCANE_RESIST].value = data[ARCANE_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[DARKNESS_RESIST] = function(data)
            data.stats[DARKNESS_RESIST].value = data[DARKNESS_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[HOLY_RESIST] = function(data)
            data.stats[HOLY_RESIST].value = data[HOLY_RESIST].bonus
        end

        ---@param data table
        ParametersUpdate[PHYSICAL_BONUS] = function(data)
            data.stats[PHYSICAL_BONUS].value = data[PHYSICAL_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[FIRE_BONUS] = function(data)
            data.stats[FIRE_BONUS].value = data[FIRE_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[ICE_BONUS] = function(data)
            data.stats[ICE_BONUS].value = data[ICE_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[LIGHTNING_BONUS] = function(data)
            data.stats[LIGHTNING_BONUS].value = data[LIGHTNING_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[POISON_BONUS] = function(data)
            data.stats[POISON_BONUS].value = data[POISON_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[ARCANE_BONUS] = function(data)
            data.stats[ARCANE_BONUS].value = data[ARCANE_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[DARKNESS_BONUS] = function(data)
            data.stats[DARKNESS_BONUS].value = data[DARKNESS_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[HOLY_BONUS] = function(data)
            data.stats[HOLY_BONUS].value = data[HOLY_BONUS].bonus
        end

        ---@param data table
        ParametersUpdate[STR_STAT] = function(data)
            data.stats[STR_STAT].value = data.base_stats.STR  + data[STR_STAT].bonus
        end

        ---@param data table
        ParametersUpdate[VIT_STAT] = function(data)
            data.stats[VIT_STAT].value = data.base_stats.VIT + data[VIT_STAT].bonus
        end

        ---@param data table
        ParametersUpdate[AGI_STAT] = function(data)
            data.stats[AGI_STAT].value = data.base_stats.AGI + data[AGI_STAT].bonus
        end

        ---@param data table
        ParametersUpdate[INT_STAT] = function(data)
            data.stats[INT_STAT].value = data.base_stats.INT + data[INT_STAT].bonus
        end

        ---@param data table
        ParametersUpdate[MELEE_DAMAGE_REDUCTION] = function(data)
            data.stats[MELEE_DAMAGE_REDUCTION].value = data[MELEE_DAMAGE_REDUCTION].bonus
        end

        ---@param data table
        ParametersUpdate[RANGE_DAMAGE_REDUCTION] = function(data)
            data.stats[RANGE_DAMAGE_REDUCTION].value = data[RANGE_DAMAGE_REDUCTION].bonus
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
        ParameterName[INT_STAT] = 'Разум'
        ParameterName[VIT_STAT] = 'Выносливость'

    end
