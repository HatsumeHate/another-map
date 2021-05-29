do

    BUFF_DATA = {}
    local MAX_BUFF_LEVEL = 10


    POSITIVE_BUFF = 1
    NEGATIVE_BUFF = 2

    OVER_TIME_DAMAGE = 1
    OVER_TIME_HEAL = 2

    STATE_STUN = 1
    STATE_FREEZE = 2


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

            bonus = { }

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

    
                if buff.effect_delay_delta then
                    buff.level[lvl].effect_delay = (buff.level[1].effect_delay or 0.1) + math.floor(lvl / (buff.effect_delay_delta_level or 1.)) * buff.effect_delay_delta
                end
    
                if buff.rank_delta then
                    buff.level[lvl].rank = (buff.level[1].rank or 1) + math.floor(lvl / (buff.rank_delta_level or 1.)) * buff.rank_delta
                end
    
    
                if buff.time_delta then
                    buff.level[lvl].time = (buff.level[1].time or 0.1) + math.floor(lvl / (buff.time_delta_level or 1.)) * buff.time_delta
                end



                if buff.level[1].bonus then

                        for i = 1, #buff.level[lvl].bonus do
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
            max_level = 75,

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
            max_level = 75,

            level = {
                [1] = {
                    rank = 10,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.15, METHOD = MULTIPLY_BONUS, value_delta = 0.05, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10., METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 }
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
                    time = 10.,

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
                        { PARAM = FIRE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
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
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,

                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
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
                        { PARAM = LIGHTNING_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }

                },
                [2] = {
                    rank = 10,
                    time = 10.,
                    current_level = 1,

                    bonus = {
                        { PARAM = LIGHTNING_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS },
                    }

                },
                [3] = {
                    rank = 10,
                    time = 10.,
                    current_level = 1,

                    bonus = {
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
            name = "first aid buff",
            id = 'A01N',
            buff_id = 'B00K',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,

            level = {
                [1] = {
                    rank = 7,
                    time = 10.,

                    current_level = 1,
                    max_level = 1,

                    effect = 'EFAA',
                    effect_delay = 1.,
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
                        { PARAM = PHYSICAL_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = ATTACK_SPEED, VALUE = -25, METHOD = STRAIGHT_BONUS, value_delta = -3, value_delta_level = 3, value_delta_level_max = 16 },
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
            name = "crystallize debuff",
            id = 'A01P',
            buff_id = 'B00L',
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
    end

end