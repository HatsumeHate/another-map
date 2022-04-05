do

    BUFF_DATA = 0
    local MAX_BUFF_LEVEL = 10


    POSITIVE_BUFF = 1
    NEGATIVE_BUFF = 2

    OVER_TIME_DAMAGE = 1
    OVER_TIME_HEAL = 2

    STATE_STUN = 1
    STATE_FREEZE = 2
    STATE_FEAR = 3


    ---@param buff_id string
    ---@param lvl integer
    function GetBuffDataLevel(buff_id, lvl)
        local data = BUFF_DATA[FourCC(buff_id)]
        return data.level[lvl]
    end

    ---@param buff_id string
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

            bonus = { },
            effects = { }

        }
    end


    ---@param buff table
    ---@param lvl integer
    function GenerateBuffLevelData(buff, lvl)

        if lvl == 1 then return end

        if buff.level[lvl] == nil then
            buff.level[lvl] = NewBuffLevelData()
            MergeTables(buff.level[lvl], buff.level[1])
            buff.level[lvl].generated = false
        end


        if buff.level[lvl].generated == nil or not buff.level[lvl].generated then
            buff.level[lvl].generated = true
            --print("generated1")
    
                if buff.effect_delay_delta then
                    buff.level[lvl].effect_delay = (buff.level[1].effect_delay or 0.1) + math.floor(lvl / (buff.effect_delay_delta_level or 1.)) * buff.effect_delay_delta
                end
            --print("generated2")
                if buff.rank_delta then
                    buff.level[lvl].rank = (buff.level[1].rank or 1) + math.floor(lvl / (buff.rank_delta_level or 1.)) * buff.rank_delta
                end
    
            --print("generated3")
                if buff.time_delta then
                    buff.level[lvl].time = (buff.level[1].time or 0.1) + math.floor(lvl / (buff.time_delta_level or 1.)) * buff.time_delta
                end

            --print("generated4")

                if buff.level[1].bonus then

                        for i = 1, #buff.level[1].bonus do
                            local origin_param_data = buff.level[1].bonus[i]

                                if origin_param_data.value_delta then
                                    local delta_max = math.floor((lvl - 1) / (origin_param_data.value_delta_level or 1))

                                    if origin_param_data.value_delta_level_max and delta_max > origin_param_data.value_delta_level_max then
                                        delta_max = origin_param_data.value_delta_level_max
                                    end


                                    buff.level[lvl].bonus[i] = { PARAM = origin_param_data.PARAM, VALUE = origin_param_data.VALUE + delta_max * origin_param_data.value_delta, METHOD = origin_param_data.METHOD }
                                elseif not buff.level[lvl].bonus[i] then
                                    buff.level[lvl].bonus[i] = { PARAM = origin_param_data.PARAM, VALUE = origin_param_data.VALUE, METHOD = origin_param_data.METHOD }
                                    --param_data.VALUE = origin_param_data.VALUE + delta_max * origin_param_data.value_delta
                                end

                        end

                end
            --print("generated done")
            if buff.breakpoints then
                for point = 1, #buff.breakpoints do
                    local current = buff.breakpoints[point]
                    if lvl > current then

                        for i = 1, #buff.level[current].bonus do
                            local param_number = #buff.level[lvl].bonus + 1
                            local origin_param_data = buff.level[current].bonus[i]

                                if origin_param_data.value_delta then
                                    local delta_max = math.floor((lvl - current) / (origin_param_data.value_delta_level or 1))

                                    if origin_param_data.value_delta_level_max and delta_max > origin_param_data.value_delta_level_max then
                                        delta_max = origin_param_data.value_delta_level_max
                                    end


                                    buff.level[lvl].bonus[param_number] = { PARAM = origin_param_data.PARAM, VALUE = origin_param_data.VALUE + delta_max * origin_param_data.value_delta, METHOD = origin_param_data.METHOD }
                                elseif not buff.level[lvl].bonus[i] then
                                    buff.level[lvl].bonus[param_number] = { PARAM = origin_param_data.PARAM, VALUE = origin_param_data.VALUE, METHOD = origin_param_data.METHOD }
                                    --param_data.VALUE = origin_param_data.VALUE + delta_max * origin_param_data.value_delta
                                end

                        end

                        for i = 1, #buff.level[current].effects do
                            buff.level[lvl].effects[#buff.level[lvl].effects + 1] = buff.level[current].effects[i]
                        end

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
            attribute = 0,

            buff_type = POSITIVE_BUFF,
            buff_replacer = {},

            current_level = 1,
            max_level = 1,
            expiration_time = 0.,
            update_timer = nil,

            level = {}
        }

        MergeTables(new_buff, buff_template)

            for i = 2, (buff_template.max_level or MAX_BUFF_LEVEL) do
                if buff_template.level[i] then
                    new_buff.level[i] = NewBuffLevelData()
                    new_buff.level[i] = MergeTables(new_buff.level[i], buff_template.level[i])
                    GenerateBuffLevelData(new_buff, i)
                else
                    GenerateBuffLevelData(new_buff, i)
                end
            end

        BUFF_DATA[FourCC(buff_template.id)] = new_buff

        return new_buff
    end



    -- inherit_level: перенимает ли баф уровни и скейлинг. нет - значит у бафа только 1 уровень


    function DefineBuffsData()

        BUFF_DATA = {}
        --================================================--
        NewBuffTemplate({
            name = "test buff",
            id = 'A002',
            buff_id = 'B000',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 75,

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
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.7, METHOD = MULTIPLY_BONUS, value_delta = -0.05, value_delta_level = 5, value_delta_level_max = 5 }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "frost nova debuff",
            id = 'A00S',
            buff_id = 'B002',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            time_delta = 0.25,
            time_delta_level = 3,

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
            max_level = 75,

            level = {
                [1] = {
                    rank = 10,
                    time = 12.,

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
            max_level = 75,

            level = {
                [1] = {
                    rank = 10,
                    time = 15.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.15, METHOD = MULTIPLY_BONUS, value_delta = 0.05, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10., METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = REFLECT_MELEE_DAMAGE, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 5, value_delta_level = 1, value_delta_level_max = 40 }
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "blizzard debuff",
            id = 'ABBZ',
            buff_id = 'B015',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 8,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -4, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1 },
                        { PARAM = CAST_SPEED, VALUE = -4, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1 },
                        { PARAM = MOVING_SPEED, VALUE = -8, METHOD = STRAIGHT_BONUS, value_delta = -8, value_delta_level = 1 },
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
            max_level = 75,

            level = {
                [1] = {
                    rank = 10,
                    time = 15.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = FIRE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = ICE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = LIGHTNING_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = ARCANE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "elemental mastery orb debuff",
            id = 'A01B',
            buff_id = 'B00D',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }

                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "elemental mastery orb debuff",
            id = 'A01C',
            buff_id = 'B00E',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }

                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "elemental mastery orb debuff",
            id = 'A01F',
            buff_id = 'B00F',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,
                    current_level = 1,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,
                    current_level = 1,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,
                    current_level = 1,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = FIRE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }

                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "ritual buff",
            id = 'A01S',
            buff_id = 'B00O',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 15,

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,

                    buff_sfx = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdx",
                    buff_sfx_point = "origin",

                    current_level = 1,
                    max_level = 1,

                },
                [15] = {
                    rank = 5,
                    time = 10.,

                    buff_sfx = "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdx",
                    buff_sfx_point = "origin",

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.65, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.65, METHOD = MULTIPLY_BONUS },
                        { PARAM = ATTACK_SPEED, VALUE = 55, METHOD = STRAIGHT_BONUS },
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
            max_level = 75,

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
            name = "shatter debuff",
            id = 'ASHS',
            buff_id = 'B016',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            time_delta = 0.1,
            time_delta_level = 1,

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
            max_level = 75,

            level = {
                [1] = {
                    rank = 7,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.3, METHOD = MULTIPLY_BONUS, value_delta = 0.03, value_delta_level = 3, value_delta_level_max = 15 },
                        { PARAM = CONTROL_REDUCTION, VALUE = 30, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = MOVING_SPEED, VALUE = 40, METHOD = STRAIGHT_BONUS, value_delta = 4, value_delta_level = 5, value_delta_level_max = 15 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "smell of death buff",
            id = 'ANRD',
            buff_id = 'B014',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            level_penalty = 9,

            level = {
                [1] = {
                    rank = 10,
                    time = 7.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = HP_PER_HIT, VALUE = 3, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "first aid buff",
            id = 'A01N',
            buff_id = 'B00K',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            breakpoints = { 10 },

            level = {
                [1] = {
                    rank = 7,
                    time = 10.,

                    effect = 'EFAA',
                    effect_delay = 1.,
                },
                [10] = {
                    rank = 7,
                    time = 10.,

                    effect = 'EFAA',
                    effect_delay = 1.,

                    bonus = {
                        { PARAM = POISON_RESIST, VALUE = 2, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 4, value_delta_level_max = 10 }
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
            max_level = 75,

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = ATTACK_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS, value_delta = -3, value_delta_level = 3, value_delta_level_max = 16 },
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
            name = "charge stun debuff",
            id = 'ABCB',
            buff_id = 'B00S',
            buff_type = NEGATIVE_BUFF,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,

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
            max_level = 75,

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
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS, value_delta = -0.05, value_delta_level = 5, value_delta_level_max = 5 },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS, value_delta = -0.05, value_delta_level = 5, value_delta_level_max = 5 },
                        { PARAM = ATTACK_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 5, value_delta_level_max = 5 },
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
            max_level = 3,
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
        --================================================--
        NewBuffTemplate({
            name = "bone prison debuff",
            id = 'A0PB',
            buff_id = 'B027',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,

            time_delta_level = 1,
            time_delta = 0.1,

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "bone barrage debuff",
            id = 'ABBB',
            buff_id = 'B028',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 1,

            time_delta_level = 3,
            time_delta = 0.1,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,

                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "devour buff",
            id = 'ABDV',
            buff_id = 'B029',
            buff_type = POSITIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = CAST_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = MOVING_SPEED, VALUE = 20, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "weaken debuff",
            id = 'ABWK',
            buff_id = 'B02A',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "decrepify debuff",
            id = 'ABDC',
            buff_id = 'B02B',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = CAST_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                        { PARAM = MOVING_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "undead land debuff",
            id = 'AULD',
            buff_id = 'B02E',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 0.5,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.8, METHOD = MULTIPLY_BONUS, value_delta = -0.02, value_delta_level = 3, value_delta_level_max = 50 },
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                        { PARAM = DARKNESS_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                        { PARAM = POISON_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "undead land buff",
            id = 'AULB',
            buff_id = 'B02F',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 0.5,
                    bonus = {
                        { PARAM = DARKNESS_RESIST, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 75 },
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 75, METHOD = STRAIGHT_BONUS, value_delta = 3, value_delta_level = 1, value_delta_level_max = 75 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "horrify debuff",
            id = 'ABHR',
            buff_id = 'B02C',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    negative_state = STATE_FEAR,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "bone rip buff",
            id = 'ANBR',
            buff_id = 'B02D',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.2, METHOD = MULTIPLY_BONUS, value_delta = 0.02, value_delta_level = 3, value_delta_level_max = 25 },
                        { PARAM = ALL_RESIST, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 3, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "bone rip debuff",
            id = 'ABRD',
            buff_id = 'B02D',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,
            time_delta = 0.25,
            time_delta_level = 10,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.25,
                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "grow spikes buff",
            id = 'ABGS',
            buff_id = 'B02G',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                    bonus = {
                        { PARAM = REFLECT_MELEE_DAMAGE, VALUE = 50, METHOD = STRAIGHT_BONUS, value_delta = 4, value_delta_level = 1, value_delta_level_max = 75 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "dark reign buff",
            id = 'ANDR',
            buff_id = 'B02H',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 9.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 10., METHOD = STRAIGHT_BONUS, value_delta = 1., value_delta_level = 2, value_delta_level_max = 75 },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 70 },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 70 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "unholy command buff",
            id = 'ANUC',
            buff_id = 'B02I',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 8.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 60 },
                        { PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 3, value_delta_level_max = 70 },
                        { PARAM = MOVING_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 70 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "tenacity of the undead buff",
            id = 'ATOD',
            buff_id = 'B02K',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 25, METHOD = STRAIGHT_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 45, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 45, METHOD = STRAIGHT_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 85, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 65, METHOD = STRAIGHT_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 125, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "life steal buff",
            id = 'ANLS',
            buff_id = 'B02L',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "lesion debuff",
            id = 'ATLS',
            buff_id = 'B02M',
            buff_type = NEGATIVE_BUFF,
            attribute = POISON_ATTRIBUTE,

            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    effect = 'lesion_effect',
                    effect_delay = 1.,
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    effect = 'lesion_effect',
                    effect_delay = 1.,
                },
                [3] = {
                    rank = 5,
                    time = 4.,
                    effect = 'lesion_effect',
                    effect_delay = 1.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "ritual buff",
            id = 'ARTL',
            buff_id = 'B02N',
            buff_type = POSITIVE_BUFF,
            max_level = 2,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = MANACOST, VALUE = 0.75, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = MANACOST, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                    }
                }
            }
        })
         --================================================--
        NewBuffTemplate({
            name = "abyss buff",
            id = 'AABS',
            buff_id = 'B02O',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 50, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 100, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 150, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "cheat death buff",
            id = 'ACHD',
            buff_id = 'B02P',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "frailty debuff",
            id = 'AFRL',
            buff_id = 'B02Q',
            buff_type = NEGATIVE_BUFF,
            max_level = 2,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 999999.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = POISON_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = DARKNESS_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 999999.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = POISON_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = DARKNESS_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                    }
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "death march buff",
            id = 'ADEM',
            buff_id = 'B02R',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 35, METHOD = STRAIGHT_BONUS },
                    }
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "amplify damage debuff",
            id = 'AAMD',
            buff_id = 'B02S',
            buff_type = NEGATIVE_BUFF,
            max_level = 3,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 99999.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 99999.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 99999.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "face of death debuff",
            id = 'AFOD',
            buff_id = 'B02T',
            buff_type = NEGATIVE_BUFF,
            max_level = 2,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_FEAR
                },
                [2] = {
                    rank = 5,
                    time = 3.,
                    negative_state = STATE_FEAR
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "insanity debuff",
            id = 'AINS',
            buff_id = 'B02U',
            buff_type = NEGATIVE_BUFF,
            max_level = 2,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 999999.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                },
                [2] = {
                    rank = 5,
                    time = 999999.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                },
                [3] = {
                    rank = 5,
                    time = 999999.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "crystallize debuff",
            id = 'A01P',
            buff_id = 'B00L',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 5,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS }
                    }
                },
                [2] = {
                    rank = 5,
                    time = 4.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS }
                    }
                },
                [3] = {
                    rank = 5,
                    time = 4.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -30, METHOD = STRAIGHT_BONUS }
                    }
                },
                [4] = {
                    rank = 5,
                    time = 4.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -40, METHOD = STRAIGHT_BONUS }
                    }
                },
                [5] = {
                    rank = 5,
                    time = 3.,

                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",

                    current_level = 1,
                    max_level = 1,
                    negative_state = STATE_FREEZE,

                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "coward buff",
            id = 'A01Q',
            buff_id = 'B00M',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 8,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.03, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.06, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.09, METHOD = MULTIPLY_BONUS }
                    }
                },
                [4] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.12, METHOD = MULTIPLY_BONUS }
                    }
                },
                [5] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.15, METHOD = MULTIPLY_BONUS }
                    }

                },
                [6] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.18, METHOD = MULTIPLY_BONUS }
                    }

                },
                [7] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.21, METHOD = MULTIPLY_BONUS }
                    }

                },
                [8] = {
                    rank = 5,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS }
                    }

                }
            }

        })
         --================================================--
        NewBuffTemplate({
            name = "witch buff",
            id = 'A01R',
            buff_id = 'B00N',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 75,

            level = {
                [1] = {
                    rank = 15,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.1, value_delta_level = 1 },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "flurry altar buff",
            id = 'A01G',
            buff_id = 'B00G',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIam\\AIamTarget.mdx",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 35, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = 35, METHOD = STRAIGHT_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "power altar buff",
            id = 'A01L',
            buff_id = 'B00J',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.35, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.35, METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "elemental altar buff",
            id = 'A01K',
            buff_id = 'B00I',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 45, METHOD = STRAIGHT_BONUS }
                    }
                }
            }

        })
        --================================================--
        -- not implemented
        --[[
        NewBuffTemplate({
            name = "spike altar buff",
            id = 'A01G',
            buff_id = 'B00G',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = REFLECT_DAMAGE, VALUE = 1.35, METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })]]
        --================================================--
        NewBuffTemplate({
            name = "endurance altar buff",
            id = 'A01J',
            buff_id = 'B00H',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdx",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 35, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 35, METHOD = STRAIGHT_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "exp altar buff",
            id = 'ALEX',
            buff_id = 'B026',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 45.,

                    current_level = 1,
                    max_level = 1,

                    buff_sfx = "Abilities\\Spells\\Items\\AIre\\AIreTarget.mdx",
                    buff_sfx_scale = 1.,
                    buff_sfx_point = "origin",

                    bonus = {
                        { PARAM = EXP_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "web debuff",
            id = 'A01T',
            buff_id = 'B00P',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 7,
                    time = 3.,

                    current_level = 1,
                    max_level = 1,

                }
            }
        })
         --================================================--
        NewBuffTemplate({
            name = "spider queen bile debuff",
            id = 'A01U',
            buff_id = 'B00Q',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 12.,

                    effect = 'ESQB',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "spider bite debuff",
            id = 'A01V',
            buff_id = 'B00R',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 2.25,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "bandit boldness buff",
            id = 'ABBS',
            buff_id = 'B00T',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 7,

            level = {
                [1] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
                [5] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                },
                [6] = {
                    rank = 5,
                    time = 2.35,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 35, METHOD = STRAIGHT_BONUS },
                    }
                },
                [7] = {
                    rank = 5,
                    time = 5.,

                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 50, METHOD = STRAIGHT_BONUS },
                        { PARAM = CRIT_CHANCE, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "arachno bite debuff",
            id = 'ACLS',
            buff_id = 'B00R',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.25,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse debuff",
            id = 'ASCB',
            buff_id = 'B00U',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.25,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -50, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -50, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = -125, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "antidote buff",
            id = 'AANT',
            buff_id = 'B00V',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 15.,
                    bonus = {
                        { PARAM = POISON_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "adrenaline buff",
            id = 'AADR',
            buff_id = 'B00W',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 11.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.35, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "scroll of protection buff",
            id = 'ASOP',
            buff_id = 'B00X',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 25.,
                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "bone guard buff",
            id = 'ACBG',
            buff_id = 'B00Y',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.45, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.45, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "horror debuff",
            id = 'AHRF',
            buff_id = 'B00Z',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = false,
            max_level = 5,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS, value_delta = -10, value_delta_level = 1 },
                        { PARAM = CAST_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS, value_delta = -10, value_delta_level = 1 },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "boar stun debuff",
            id = 'ABRS',
            buff_id = 'B010',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.25,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "wolf rage buff",
            id = 'AWRB',
            buff_id = 'B013',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 40, METHOD = STRAIGHT_BONUS },
                        { PARAM = CRIT_CHANCE, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "ghoul stun debuff",
            id = 'AGHB',
            buff_id = 'B011',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.25,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "antimagic debuff",
            id = 'AHBB',
            buff_id = 'B012',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "chill freeze debuff",
            id = 'ATCH',
            buff_id = 'B017',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 2.25,
                    negative_state = STATE_FREEZE,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse debuff",
            id = 'ASKD',
            buff_id = 'B018',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "conflagrate debuff",
            id = 'ACND',
            buff_id = 'B019',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 4.,
                    effect = 'conflagrate_effect_periodic',
                    effect_delay = 1.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = -75, METHOD = STRAIGHT_BONUS, value_delta = 3, value_delta_level = 1 },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse weakness debuff",
            id = 'ACWK',
            buff_id = 'B01A',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 999999999999.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse indecisiveness debuff",
            id = 'ACIN',
            buff_id = 'B01B',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 999999999999.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = -20, METHOD = STRAIGHT_BONUS },
                        { PARAM = CRIT_MULTIPLIER, VALUE = -0.3, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse vulnerability debuff",
            id = 'ACVN',
            buff_id = 'B01C',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 999999999999.,
                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = -20, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "curse withering debuff",
            id = 'ACWT',
            buff_id = 'B01D',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 999999999999.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                        { PARAM = MP_REGEN, VALUE = 0.7, METHOD = MULTIPLY_BONUS },
                        { PARAM = HP_PER_HIT, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = MP_PER_HIT, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "ignite debuff",
            id = 'ATIG',
            buff_id = 'B01E',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    effect = 'ignite_effect_periodic',
                    effect_delay = 1.,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "heat debuff",
            id = 'ATHT',
            buff_id = 'B01F',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.93, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.86, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.79, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "incinerate debuff",
            id = 'ATIN',
            buff_id = 'B01G',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 8.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 4, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 6, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 12.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "negative charge debuff",
            id = 'ATNC',
            buff_id = 'B01H',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 4,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = -25, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = -35, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = -45, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "voltage buff",
            id = 'ATAD',
            buff_id = 'B01I',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "induction buff",
            id = 'ATID',
            buff_id = 'B01J',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 4,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "extra charge stun debuff",
            id = 'ATEC',
            buff_id = 'B01K',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.25,
                    negative_state = STATE_STUN
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "extra charge buff",
            id = 'ATEE',
            buff_id = 'B01L',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.2, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.3, METHOD = MULTIPLY_BONUS }
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "shock stun debuff",
            id = 'ATSH',
            buff_id = 'B01M',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    negative_state = STATE_STUN
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "remorseless debuff",
            id = 'ATRM',
            buff_id = 'B01N',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS }
                    }
                },
                [2] = {
                    rank = 15,
                    time = 4.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS }
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "glaciation buff",
            id = 'ATGL',
            buff_id = 'B01O',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.2, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 15,
                    time = 9999999999999999.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.3, METHOD = MULTIPLY_BONUS }
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "breath of frost freeze debuff",
            id = 'ATBF',
            buff_id = 'B01P',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 0.5,
                    negative_state = STATE_FREEZE
                },
                [2] = {
                    rank = 15,
                    time = 0.75,
                    negative_state = STATE_FREEZE
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "heat transfer buff",
            id = 'ATHE',
            buff_id = 'B01Q',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 6, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 12, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 18, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "ice enduring debuff",
            id = 'ATIE',
            buff_id = 'B01R',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    negative_state = STATE_FREEZE
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "rage buff",
            id = 'ATRG',
            buff_id = 'B01S',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 7, METHOD = STRAIGHT_BONUS },
                    }
                },
                [5] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    }
                },
                [6] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 21, METHOD = STRAIGHT_BONUS },
                    }
                },
                [7] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 9, METHOD = STRAIGHT_BONUS },
                    }
                },
                [8] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 18, METHOD = STRAIGHT_BONUS },
                    }
                },
                [9] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 27, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "breaking defence debuff",
            id = 'ATBD',
            buff_id = 'B01T',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.93, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.86, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.79, METHOD = MULTIPLY_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "pain killer buff",
            id = 'ATPK',
            buff_id = 'B01U',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 6, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 6, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "carnage buff",
            id = 'ATCR',
            buff_id = 'B01V',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 7,

            level = {
                [1] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
                [5] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                },
                [6] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 30, METHOD = STRAIGHT_BONUS },
                    }
                },
                [7] = {
                    rank = 15,
                    time = 10.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 35, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "sharpened blade buff",
            id = 'ATSB',
            buff_id = 'B01W',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 9999999999999.,
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "disadvantage buff",
            id = 'ATDA',
            buff_id = 'B01X',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 9999999999999.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "disorientation debuff",
            id = 'ATDS',
            buff_id = 'B01Y',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.93, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.85, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -21, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -21, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.79, METHOD = MULTIPLY_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "fracture debuff",
            id = 'ATFR',
            buff_id = 'B01Z',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    effect = "fracture_talent_effect",
                    effect_delay = 1.,
                },
                [2] = {
                    rank = 15,
                    time = 3.,
                    effect = "fracture_talent_effect",
                    effect_delay = 1.,
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "impulse of anger buff",
            id = 'ATRI',
            buff_id = 'B020',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.2, METHOD = MULTIPLY_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "vulnerability debuff",
            id = 'ATVL',
            buff_id = 'B021',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = PHYSICAL_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = PHYSICAL_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "pressure point buff",
            id = 'ATPP',
            buff_id = 'B022',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 4,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_MULTIPLIER, VALUE = 0.1, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_MULTIPLIER, VALUE = 0.2, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_MULTIPLIER, VALUE = 0.3, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 5.,
                    bonus = {
                        { PARAM = CRIT_MULTIPLIER, VALUE = 0.4, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "intimidation debuff",
            id = 'ATIT',
            buff_id = 'B023',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 2.,
                    negative_state = STATE_FEAR
                },
                [2] = {
                    rank = 15,
                    time = 3.,
                    negative_state = STATE_FEAR
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "adrenaline buff",
            id = 'ATAR',
            buff_id = 'B024',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    effect = "adrenaline_talent_effect",
                    effect_delay = 1.
                },
                [2] = {
                    rank = 15,
                    time = 5.,
                    effect = "adrenaline_talent_effect",
                    effect_delay = 1.
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "second wind buff",
            id = 'ATSW',
            buff_id = 'B025',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 15.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                        { PARAM = ATTACK_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--


        RegisterTestCommand("buffme", function()
            ApplyBuff(PlayerHero[1], PlayerHero[1], "A01K", 1)
        end)

        RegisterTestCommand("buffbug1", function()
            ApplyBuff(PlayerHero[1], PlayerHero[1], "ATCH", 1)
            --ApplyBuff(PlayerHero[1], PlayerHero[1], "ATCH", 1)
        end)

        RegisterTestCommand("buffbug2", function()
            ApplyBuff(PlayerHero[1], PlayerHero[1], "ATCH", 1)
            ApplyBuff(PlayerHero[1], PlayerHero[1], "ACLS", 1)
        end)
        --ACLS


    end

end