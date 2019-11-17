

    -- parameters types
    PHYSICAL_ATTACK = 1
    PHYSICAL_DEFENCE = 2

    MAGICAL_ATTACK = 3
    MAGICAL_SUPPRESSION = 4

    CRIT_CHANCE = 5
    CRIT_MULTIPLIER = 6

    HP_REGEN = 7
    MP_REGEN = 8


    -- attributes
    PHYSICAL = 1
    FIRE = 2
    ICE = 3
    LIGHTNING = 4
    POISON = 5
    ARCANE = 6
    DARKNESS = 7
    HOLY = 8



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