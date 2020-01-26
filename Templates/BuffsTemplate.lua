do

    BUFF_DATA = {}
    local MAX_BUFF_LEVEL = 10


    POSITIVE_BUFF = 1
    NEGATIVE_BUFF = 2

    OVER_TIME_DAMAGE = 1
    OVER_TIME_HEAL = 2

    STATE_STUN = 1
    STATE_FREEZE = 2


    ---@param buff_id integer
    ---@param lvl integer
    function GetBuffDataLevel(buff_id, lvl)
        local data = BUFF_DATA[FourCC(buff_id)]
        return data.level[lvl]
    end

    ---@param buff_id integer
    function GetBuffData(buff_id)
        return BUFF_DATA[FourCC(buff_id)]
    end


    local function NewBuffLevelData()
        return {

            rank = 1,
            time = 1,
            negative_state = 0,

            effect = nil,
            effect_delay = 0.,

            buff_sfx = nil,
            buff_sfx_scale = 1.,
            buff_sfx_point = "",

            bonus = { }

        }
    end


    function GenerateBuffLevelData(buff, lvl)

        if lvl == 1 then return end

        if buff.level[lvl] == nil then
            buff.level[lvl] = NewEffectData()
            MergeTables(buff.level[lvl], buff.level[1])
            buff.level[lvl].generated = false
        end


        if buff.level[lvl].generated == nil or not buff.level[lvl].generated then
            buff.level[lvl].generated = true

    
                if buff.effect_delay_delta ~= nil then
                    buff.level[lvl].effect_delay = (buff.level[1].effect_delay or 0.1) + math.floor(lvl / (buff.effect_delay_delta_level or 1.)) * buff.effect_delay_delta
                end
    
                if buff.rank_delta ~= nil then
                    buff.level[lvl].rank = (buff.level[1].rank or 1) + math.floor(lvl / (buff.rank_delta_level or 1.)) * buff.rank_delta
                end
    
    
                if buff.time_delta ~= nil then
                    buff.level[lvl].time = (buff.level[1].time or 0.1) + math.floor(lvl / (buff.time_delta_level or 1.)) * buff.time_delta
                end



                if buff.level[1].bonus ~= nil then

                        for i = 1, #buff.level[lvl].bonus do
                            local origin_param_data = buff.level[1].bonus[i]

                                if origin_param_data.value_delta ~= nil then
                                    local param_data = buff.level[lvl].bonus[i]
                                    param_data.VALUE = origin_param_data.VALUE + math.floor(lvl / origin_param_data.value_delta_level) * origin_param_data.value_delta
                                end

                        end

                end

        end

    end

    ---@param buff_template table
    function NewBuffTemplate(buff_template)
        local new_buff = {

            name = '',
            id = '',
            buff_id = '',

            buff_type = POSITIVE_BUFF,
            buff_replacer = {},

            current_level = 1,
            max_level = 1,
            expiration_time = 0.,
            update_timer = nil,

            level = {}
        }

            for i = 1, MAX_BUFF_LEVEL do
                new_buff.level[i] = NewBuffLevelData()
            end


            MergeTables(new_buff, buff_template)
            BUFF_DATA[FourCC(buff_template.id)] = new_buff

        return new_buff
    end


    function DefineBuffsData()
        --================================================--
        NewBuffTemplate({
            name = "test buff",
            id = 'A002',
            buff_id = 'B000',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,

                    current_level = 1,
                    max_level = 1,

                    effect = 'EFF2',
                    effect_delay = 1.,

                    buff_sfx = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdx",
                    buff_sfx_point = "origin",
                    buff_sfx_scale = 0.7,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 5., METHOD = MULTIPLY_BONUS },
                        { PARAM = ATTACK_SPEED, VALUE = 1.5, METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "frostbolt debuff",
            id = 'A004',
            buff_id = 'B001',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.7, METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "frost nova debuff",
            id = 'A00S',
            buff_id = 'B002',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    negative_state = STATE_FREEZE
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "focus buff",
            id = 'A00T',
            buff_id = 'B003',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 6.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 25, METHOD = STRAIGHT_BONUS },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.25, METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "frost armor buff",
            id = 'A011',
            buff_id = 'B005',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10., METHOD = STRAIGHT_BONUS }
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "elemental mastery buff",
            id = 'A00U',
            buff_id = 'B004',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = FIRE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
                        { PARAM = ICE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
                        { PARAM = ARCANE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
                        { PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "uppercut debuff",
            id = 'A012',
            buff_id = 'B006',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 7,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "berserk buff",
            id = 'A00V',
            buff_id = 'B007',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 7,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
                        { PARAM = CONTROL_REDUCTION, VALUE = 30, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 40, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "crushing strike debuff",
            id = 'A00W',
            buff_id = 'B008',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTRIBUTE, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = ATTACK_SPEED, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "chain stun debuff",
            id = 'A013',
            buff_id = 'B009',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1000.,

                    current_level = 1,
                    max_level = 1,

                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "cutting slash debuff",
            id = 'A014',
            buff_id = 'B00A',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,

                    current_level = 1,
                    max_level = 1,

                    effect = 'ECSP',
                    effect_delay = 1.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "warcry debuff",
            id = 'A00Y',
            buff_id = 'B00B',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "regen buff",
            id = 'A01D',
            buff_id = 'B00C',
            buff_type = POSITIVE_BUFF,
            current_level = 1,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    effect = 'PUPR',
                    effect_delay = 1.,
                }
            }

        })
    end

end