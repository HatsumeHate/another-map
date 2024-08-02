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
    STATE_BLIND = 4
    STATE_ROOT = 5
    STATE_SLOW = 6


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

                if buff.endurance_delta then
                    local delta_max = math.floor(lvl / (buff.endurance_delta_level or 1))

                        if buff.endurance_delta_level_max and delta_max > buff.endurance_delta_level_max then
                            delta_max = buff.endurance_delta_level_max
                        end

                    buff.level[lvl].endurance = (buff.level[1].endurance or 1) + delta_max * buff.endurance_delta
                end

                if buff.endurance_hp_delta then
                    local delta_max = math.floor(lvl / (buff.endurance_hp_delta_level or 1))

                        if buff.endurance_hp_delta_level_max and delta_max > buff.endurance_hp_delta_level_max then
                            delta_max = buff.endurance_hp_delta_level_max
                        end

                    buff.level[lvl].endurance_hp = (buff.level[1].endurance_hp or 0.1) + delta_max * buff.endurance_hp_delta
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
            expiration_time = 0,
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
            tags = { "skill" },
            sfx = {
                { path = "Effect\\WaterSlow.mdx", point = "origin" },
            },

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.8, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 25 }
                    },
                    negative_state = STATE_SLOW
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
            tags = { "skill" },
            sfx = { { path = "Effect\\FreezeEffect.mdx", point = "origin" }, },

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,
                    negative_state = STATE_FREEZE
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "permafrost debuff",
            id = 'A037',
            buff_id = 'B05K',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            time_delta = 0.02,
            time_delta_level = 1,
            tags = { "skill" },
            sfx = { { path = "Effect\\FreezeEffect.mdx", point = "origin" }, },

            level = {
                [1] = {
                    rank = 10,
                    time = 2.25,

                    negative_state = STATE_FREEZE
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_FOCUS,
            --description = LOCALE_LIST[my_locale].BUFF_FOCUS_DESC,
            id = 'A00T',
            buff_id = 'B003',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            sfx = { { path = "Effect\\Energy_Shield_Re_edit_002.mdx", point = "origin" }, },
            icon = "Spell\\BTN_ArcaneProtection.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 8.,

                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 40 },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate {
            name = LOCALE_LIST[my_locale].BUFF_FROST_ARMOR,
            id = 'A011',
            buff_id = 'B005',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            tags = { "skill", "barrier" },
            sfx = { { path = "Effect\\Energy_Shield_Re_edit_002.mdx", point = "origin" } },
            icon = "Spell\\BTNCloakOfFrost.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 6.,

                    endurance_hp = 0.25,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.15, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 2, value_delta_level_max = 40 },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10., METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 15 },
                        { PARAM = REFLECT_MELEE_DAMAGE, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 5, value_delta_level = 1, value_delta_level_max = 40 }
                    }
                }
            }
        }
        --================================================--
        NewBuffTemplate({
            name = "blizzard debuff",
            id = 'ABBZ',
            buff_id = 'B015',
            attribute = ICE_ATTRIBUTE,
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 8,
            tags = { "skill" },
            sfx = {
                { path = "Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdx", point = "origin" }
            },

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -4, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1 },
                        { PARAM = CAST_SPEED, VALUE = -4, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1 },
                        { PARAM = MOVING_SPEED, VALUE = -8, METHOD = STRAIGHT_BONUS, value_delta = -8, value_delta_level = 1 },
                    },
                    negative_state = STATE_SLOW
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_ELEM_MASTERY,
            id = 'A00U',
            buff_id = 'B004',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            sfx = {
                { path = "Abilities\\Spells\\Orc\\SpiritLink\\SpiritLinkTarget.mdx", point = "chest" }
            },
            icon = "Spell\\BTN_cr_Dark Arts.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 7.,

                    bonus = {
                        { PARAM = FIRE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = ICE_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = LIGHTNING_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_HYDRA,
            id = 'HDAU',
            buff_id = 'B039',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            sfx = {
                { path = "Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdx", point = "overhead" }
            },
            icon = "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp",
            statusbar_dont_show_time = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = FIRE_BONUS, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SURGE,
            id = 'ABSU',
            buff_id = 'B03T',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = LIGHTNING_ATTRIBUTE,
            tags = { "skill" },
            sound = { loop_pack = { "Sounds\\Spells\\Surge_Loop_1.wav", "Sounds\\Spells\\Surge_Loop_2.wav", "Sounds\\Spells\\Surge_Loop_3.wav", "Sounds\\Spells\\Surge_Loop_4.wav", "Sounds\\Spells\\Surge_Loop_5.wav" },
                      volume = 160, cutoff = 1400., fadein = 0, fadeout = 100, delay = -0.14 },
            sfx = {
                { path = "Buffs\\ThunderAuraMod.mdx", point = "origin" }
            },
            icon = "Spell\\BTNElectricStrike.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 3, value_delta_level_max = 15 },
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 3, value_delta_level_max = 15 },
                        { PARAM = MOVING_SPEED, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 1, value_delta_level_max = 50 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "static field debuff",
            id = 'A029',
            buff_id = 'B04M',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = LIGHTNING_ATTRIBUTE,
            tags = { "skill" },
            sfx = {
                { path = "Buffs\\shandian-buff.mdx", point = "chest" }
            },

            level = {
                [1] = {
                    rank = 10,
                    time = 6.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -45, METHOD = STRAIGHT_BONUS, value_delta = -3, value_delta_level = 1, value_delta_level_max = 75 },
                    },
                    negative_state = STATE_SLOW
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "lightning spear debuff",
            id = 'A035',
            buff_id = 'B05I',
            buff_type = NEGATIVE_BUFF,
            attribute = LIGHTNING_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            time_delta = 0.1,
            time_delta_level = 3,
            time_delta_level_max = 20,

            level = {
                [1] = {
                    rank = 5,
                    time = 2.25,
                    negative_state = STATE_STUN
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_FIRE_SHROUD,
            id = 'ABFS',
            buff_id = 'B03U',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = FIRE_ATTRIBUTE,
            tags = { "skill" },
            sound = { loop_pack = { "Sounds\\Spells\\FlameShield_Loop_1.wav" }, volume = 140, cutoff = 1400. },
            sfx = {
                { path = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedTarget.mdx", point = "chest" }
            },
            icon = "Spell\\BTNFlameCloak.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    effect = 'effect_flame_shroud_damage',
                    effect_delay = 0.33,

                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 1 },
                        { PARAM = MP_REGEN, VALUE = 3, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 3, value_delta_level_max = 10 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_ENFLAME,
            id = 'ABEF',
            buff_id = 'B05O',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = FIRE_ATTRIBUTE,
            tags = { "skill" },
            icon = "Spell\\BTNSw_FireSword3.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 8.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "enflame debuff",
            id = 'A03E',
            buff_id = 'B05P',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 25,
            attribute = FIRE_ATTRIBUTE,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 10,
                    time = 6.,
                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = -1, METHOD = STRAIGHT_BONUS, value_delta = -1 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "enflame stun debuff",
            id = 'A03F',
            buff_id = 'B05Q',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            attribute = FIRE_ATTRIBUTE,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 10,
                    time = 1.,
                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "fire wall debuff",
            id = 'A00D',
            buff_id = 'B045',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = FIRE_ATTRIBUTE,
            tags = { "skill", "burning" },


            level = {
                [1] = {
                    rank = 10,
                    time = 2.,

                    effect = 'fire_wall_damage_effect',
                    effect_delay = 0.33,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_ARCANE_RIFT,
            id = 'A036',
            buff_id = 'B05J',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = ARCANE_ATTRIBUTE,
            tags = { "skill" },
            icon = "Spell\\BTNrunes-magenta-2.blp",
            statusbar_dont_show_time = true,

            level = {
                [1] = {
                    rank = 10,
                    time = 1.,

                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = CAST_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 20 },
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
            name = LOCALE_LIST[my_locale].BUFF_RITUAL,
            id = 'A01S',
            buff_id = 'B00O',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 15,
            icon = "Weapons\\BTNBlack Navaja.blp",
            statusbar_show_level = true,

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
            name = "chain after debuff",
            id = 'ACHA',
            buff_id = 'B033',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            time_delta = 0.1,
            time_delta_level = 5,
            time_delta_level_max = 10,

            level = {
                [1] = {
                    rank = 7,
                    time = 3.,
                    current_level = 1,
                    max_level = 1,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = -50, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = MOVING_SPEED, VALUE = -25, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = ATTACK_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -3, value_delta_level = 5, value_delta_level_max = 10 },
                        { PARAM = CAST_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -3, value_delta_level = 5, value_delta_level_max = 10 },
                    },
                    negative_state = STATE_SLOW
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
            tags = { "skill" },

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
            tags = { "skill" },

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
            name = LOCALE_LIST[my_locale].BUFF_JUMP,
            id = 'A02D',
            buff_id = 'B04Q',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTN_cr_CarA2.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,
                    attack_status = { status = ATTACK_STATUS_CRITICAL, amount = 1 },
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_BERSERK,
            id = 'A00V',
            buff_id = 'B007',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTN_cr_CarA10.blp",

            level = {
                [1] = {
                    rank = 7,
                    time = 7.,

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
            name = LOCALE_LIST[my_locale].BUFF_EXECUTION,
            id = 'ANRD',
            buff_id = 'B014',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            level_penalty = 9,
            tags = { "skill" },
            icon = "Spell\\BTNHearbreak.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_BLOOD_RUSH,
            id = 'A01N',
            buff_id = 'B00K',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            breakpoints = { 10 },
            tags = { "skill" },
            endurance_hp_delta = 0.01,
            endurance_hp_delta_level = 3,
            icon = "Spell\\BTNBlood (6).blp",


            level = {
                [1] = {
                    rank = 7,
                    time = 10.,

                    endurance_hp = 0.1,

                    effect = 'EFAA',
                    effect_delay = 1.,
                    bonus = {
                        { PARAM = HP_PER_HIT, VALUE = 3, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 25 },
                    }
                },
                [10] = {
                    rank = 7,
                    time = 10.,

                    endurance_hp = 0.1,

                    effect = 'EFAA',
                    effect_delay = 1.,

                    bonus = {
                        { PARAM = HP_PER_HIT, VALUE = 3, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 25 },
                        { PARAM = POISON_RESIST, VALUE = 2, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 4, value_delta_level_max = 10 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_REINFORCE,
            id = 'A009',
            buff_id = 'B043',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 2,
            tags = { "talent" },
            icon = "Talents\\BTNability_warrior_unrelentingassault.blp",

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,
                    endurance_hp = 0.07,
                },
                [2] = {
                    rank = 7,
                    time = 5.,
                    endurance_hp = 0.14,
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
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,
                    bonus = {
                        { PARAM = PHYSICAL_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = ATTACK_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 35 },
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
            infinite = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 1000.,
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
            tags = { "skill", "bleeding", "dot" },

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
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
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.85, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.85, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = ATTACK_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 50 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_RALLYING_CRY,
            id = 'BBRC',
            buff_id = 'B03E',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            tags = { "skill" },
            icon = "Spell\\BTNrallying cry.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.05, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = CONTROL_REDUCTION, VALUE = 15, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 25 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "tremble debuff",
            id = 'ABTR',
            buff_id = 'B03Q',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            max_level = 1,
            tags = { "skill" },

            time_delta_level = 3,
            time_delta = 0.1,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.75,
                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "grounder debuff",
            id = 'A02A',
            buff_id = 'B04N',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 7,
                    time = 1.5,
                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].ITEM_NAME_NIGHTWALKERS,
            id = 'A03C',
            buff_id = 'B05N',
            buff_type = POSITIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "item", "legendary" },
            icon = "Armor\\BTNMShoesoftheMagi.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_REGEN,
            id = 'A01D',
            buff_id = 'B00C',
            buff_type = POSITIVE_BUFF,
            current_level = 1,
            max_level = 3,
            inherit_level = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNGreaterRejuvScroll.blp",

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
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill", "curse" },

            time_delta_level = 2,
            time_delta = 0.1,
            time_delta_level_max = 75,

            static_sfx = {
                path = "Effect\\Bone Prison.mdx",
                autoscaling = true,
                random_angle = true
            },

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,
                    negative_state = STATE_ROOT
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
            tags = { "skill" },

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
            name = LOCALE_LIST[my_locale].BUFF_DEVOUR,
            id = 'ABDV',
            buff_id = 'B029',
            buff_type = POSITIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,
            tags = { "skill" },
            icon = "Spell\\BTNDevour.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 35 },
                        { PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 35 },
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
            tags = { "skill", "curse" },

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 2, value_delta_level_max = 50 },
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
            tags = { "skill", "curse" },

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = CAST_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = MOVING_SPEED, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 60 },
                    },
                    negative_state = STATE_SLOW
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "torture debuff",
            id = 'ABTT',
            buff_id = 'B049',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 75,
            inherit_level = true,
            tags = { "skill", "curse" },

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
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
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 0.5,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.8, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 1, value_delta_level_max = 50 },
                        { PARAM = ICE_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                        { PARAM = DARKNESS_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                        { PARAM = POISON_RESIST, VALUE = -10, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 3, value_delta_level_max = 60 },
                    },
                    negative_state = STATE_SLOW
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_UNDEAD_LAND,
            id = 'AULB',
            buff_id = 'B02F',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            tags = { "skill" },
            icon = "Spell\\BTNNecroGrip2.blp",

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
            tags = { "skill" },

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
            name = LOCALE_LIST[my_locale].BUFF_BONE_RIP,
            id = 'ANBR',
            buff_id = 'B02D',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            tags = { "skill" },
            icon = "Spell\\BTNGalvanize.blp",

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
            tags = { "skill" },

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
            name = LOCALE_LIST[my_locale].BUFF_GROW_SPIKES,
            id = 'ABGS',
            buff_id = 'B02G',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            tags = { "skill" },
            icon = "Spell\\BTNCR_Spiked_Armor.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_DARK_REIGN,
            id = 'ANDR',
            buff_id = 'B02H',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            icon = "Spell\\BTNReanimate66.blp",
            statusbar_dont_show = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
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
            name = LOCALE_LIST[my_locale].BUFF_UNHOLY_COMMAND,
            id = 'ANUC',
            buff_id = 'B02I',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            icon = "Spell\\BTNSkeletal_Hand.blp",
            statusbar_dont_show = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
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
            name = LOCALE_LIST[my_locale].BUFF_SKELETON_SUMMON,
            id = 'A00H',
            buff_id = 'B04A',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,
            icon = "Spell\\BTNDullahan1.blp",
            statusbar_dont_show = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    effect = "skele_heal_effect",
                    effect_initial_delay = 0.,
                    effect_delay = 1.,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.15, METHOD = MULTIPLY_BONUS},
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_LICH_SUMMON,
            id = 'A00I',
            buff_id = 'B04B',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,
            icon = "Spell\\BTNEArthLich.blp",
            statusbar_dont_show = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    effect = "skele_heal_effect",
                    effect_initial_delay = 0.,
                    effect_delay = 1.,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.25, METHOD = MULTIPLY_BONUS},
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_LICH_AURA,
            id = 'NRLA',
            buff_id = 'B03A',
            buff_type = POSITIVE_BUFF,
            max_level = 75,
            inherit_level = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBrilliance.blp",
            statusbar_dont_show_time = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 1., METHOD = STRAIGHT_BONUS, value_delta = 0.25, value_delta_level = 5, value_delta_level_max = 14 },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "forced decay debuff",
            id = 'ABFD',
            buff_id = 'B048',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 20,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.98, METHOD = MULTIPLY_BONUS, value_delta = -0.02 },
                    },
                    negative_state = STATE_SLOW
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_TENACITY_OF_THE_UNDEAD,
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
            name = LOCALE_LIST[my_locale].BUFF_LIFE_STEAL,
            id = 'ANLS',
            buff_id = 'B02L',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,
            icon = "Talents\\BTNLifeSteal.blp",
            statusbar_show_level = true,

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
            tags = { "dot", "poisoning" },

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
            name = LOCALE_LIST[my_locale].BUFF_RITUAL_TALENT,
            id = 'ARTL',
            buff_id = 'B02N',
            buff_type = POSITIVE_BUFF,
            max_level = 2,
            inherit_level = true,
            icon = "Talents\\BTNNecromancy1.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_ABYSS,
            id = 'AABS',
            buff_id = 'B02O',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,
            icon = "Talents\\BTN_EyeOfShadows.blp",
            statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_CHEAT_DEATH,
            id = 'ACHD',
            buff_id = 'B02P',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,
            icon = "Talents\\BTNTaint.blp",

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
                    time = 1.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = POISON_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = DARKNESS_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                        { PARAM = PHYSICAL_RESIST, VALUE = -5, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = POISON_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = DARKNESS_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                        { PARAM = PHYSICAL_RESIST, VALUE = -7, METHOD = STRAIGHT_BONUS },
                    }
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_DEATH_MARCH,
            id = 'ADEM',
            buff_id = 'B02R',
            buff_type = POSITIVE_BUFF,
            max_level = 3,
            inherit_level = true,
            icon = "Talents\\BTNAgi.blp",

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
                    time = 1.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 5,
                    time = 1.,
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
                    time = 1.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                },
                [3] = {
                    rank = 5,
                    time = 1.,
                    effect = "effect_insanity",
                    effect_delay = 0.5
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "venom bite debuff",
            id = 'ABVP',
            buff_id = 'B03F',
            buff_type = NEGATIVE_BUFF,
            attribute = POISON_ATTRIBUTE,
            tags = { "skill", "poisoning", "dot" },
            inherit_level = true,
            max_level = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -40, METHOD = STRAIGHT_BONUS, value_delta = -5, value_delta_level = 5, value_delta_level_max = 25 },
                    },
                    effect = 'effect_viper_bite_periodic',
                    effect_delay = 1.,
                    negative_state = STATE_SLOW
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "target locked debuff",
            id = 'ADTL',
            buff_id = 'B03G',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 8.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_TARGET_LOCKED,
            id = 'ABTL',
            buff_id = 'B03H',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNtarget locked.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = MOVING_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = COOLDOWN_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_LOCKED_AND_LOADED,
            id = 'ABLL',
            buff_id = 'B03H',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNlocked and loaded.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 75 },
                        { PARAM = PHYSICAL_ATTACK, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 3, value_delta_level = 1, value_delta_level_max = 75 },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_NIGHT_SHROUD,
            id = 'ABNS',
            buff_id = 'B03I',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNDarkMantle.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = DODGE_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 75 },
                        { PARAM = MOVING_SPEED, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = CONTROL_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 2, value_delta_level_max = 50 },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_SHADOWSTEP,
            id = 'ABST',
            buff_id = 'B03J',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            time_delta = 0.2,
            time_delta_level = 2,
            time_delta_level_max = 25,
            tags = { "skill" },
            icon = "Spell\\BTNshadowstep.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "cursed hit debuff",
            id = 'ABCA',
            buff_id = 'B03K',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = -12, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = MAGICAL_ATTACK, VALUE = -9, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 75 },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "incendiary grenade debuff",
            id = 'ABID',
            buff_id = 'B03L',
            buff_type = NEGATIVE_BUFF,
            attribute = FIRE_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill", "dot", "burning" },

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    effect = "incendiary_grenade_peroidic_effect",
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = -25, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1, value_delta_level_max = 75 },
                    },
                    effect_delay = 1.
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "caltrops debuff",
            id = 'ABCT',
            buff_id = 'B03M',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = VULNERABILITY, VALUE = 10, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 10, value_delta_level_max = 8 },
                    },
                    negative_state = STATE_SLOW
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "shocking trap debuff",
            id = 'AAST',
            buff_id = 'B03O',
            buff_type = NEGATIVE_BUFF,
            attribute = LIGHTNING_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,
                    negative_state = STATE_STUN
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "smoke bomb debuff",
            id = 'ABSB',
            buff_id = 'B03O',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 7,
                    time = 5.,
                    negative_state = STATE_BLIND,
                    bonus = {
                        { PARAM = CAST_SPEED, VALUE = -7, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 1, value_delta_level_max = 65 },
                    },
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "twilight debuff",
            id = 'ABTW',
            buff_id = 'B03S',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -25, METHOD = STRAIGHT_BONUS, value_delta = -2, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = ATTACK_SPEED, VALUE = -11, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 2, value_delta_level_max = 50 },
                        { PARAM = CAST_SPEED, VALUE = -11, METHOD = STRAIGHT_BONUS, value_delta = -1, value_delta_level = 2, value_delta_level_max = 50 },
                    },
                    negative_state = STATE_SLOW
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_TWILIGHT,
            id = 'ABTH',
            buff_id = 'B03R',
            buff_type = POSITIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNtwilight.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 25, METHOD = STRAIGHT_BONUS, value_delta = 2, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = DARKNESS_BONUS, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 1, value_delta_level = 1, value_delta_level_max = 75 },
                        { PARAM = MOVING_SPEED, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.01, value_delta_level = 2, value_delta_level_max = 50 },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_FROST_ARROWS,
            id = 'A02F',
            buff_id = 'B04S',
            buff_type = POSITIVE_BUFF,
            attribute = ICE_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNIcyArrows.blp",
            buff_replacer = { "A02E" },
            time_delta = 0.1,
            time_delta_level = 1,
            time_delta_level_max = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "frost arrows debuff",
            id = 'A02I',
            buff_id = 'B04V',
            buff_type = NEGATIVE_BUFF,
            attribute = ICE_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.9, METHOD = MULTIPLY_BONUS, value_delta = -0.01, value_delta_level = 2, value_delta_level_max = 50 },
                    },
                    negative_state = STATE_SLOW
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_POISON_ARROWS,
            id = 'A02E',
            buff_id = 'B04R',
            buff_type = POSITIVE_BUFF,
            attribute = POISON_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNPoisonsArrow.blp",
            buff_replacer = { "A02F" },
            time_delta = 0.1,
            time_delta_level = 1,
            time_delta_level_max = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "poison arrows debuff",
            id = 'A02H',
            buff_id = 'B04U',
            buff_type = NEGATIVE_BUFF,
            attribute = POISON_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    effect = "poison_arrow_periodic_effect",
                    effect_delay = 1.
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "expose debuff",
            id = 'A02G',
            buff_id = 'B04T',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "charged shot debuff",
            id = 'A02J',
            buff_id = 'B04W',
            buff_type = NEGATIVE_BUFF,
            attribute = LIGHTNING_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            time_delta = 0.1,
            time_delta_level = 2,
            time_delta_level_max = 75,

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_STUN
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SKILL_MULTISHOT,
            id = 'A02K',
            buff_id = 'B04X',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 75,
            tags = { "skill" },
            icon = "Spell\\BTNIchaival.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 8.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_counterattack"].name,
            id = 'A02L',
            buff_id = 'B04Y',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 2,
            tags = { "talent" },
            icon = "Talents\\BTNOS1.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 1.07, METHOD = MULTIPLY_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 1.14, METHOD = MULTIPLY_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_relentless"].name,
            id = 'A02M',
            buff_id = 'B04Z',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 3,
            tags = { "talent" },
            icon = "Talents\\BTNMeditation.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 4, METHOD = STRAIGHT_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 12, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_bloodthirsty"].name,
            id = 'A02N',
            buff_id = 'B050',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 3,
            tags = { "talent" },
            icon = "Talents\\BTNbloodthirsty.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = HP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = HP_PER_HIT, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = HP_PER_HIT, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_ambush"].name,
            id = 'A02O',
            buff_id = 'B051',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "talent" },
            icon = "Talents\\BTNicons_4602_pas.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "ambush debuff",
            id = 'A02P',
            buff_id = 'B052',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "talent" },
            icon = "Talents\\BTNicons_4602_pas.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    negative_state = STATE_STUN
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_unmatched_technique"].name,
            id = 'A02Q',
            buff_id = 'B053',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 5,
            tags = { "talent" },
            icon = "Talents\\BTNSlaugther Saber.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 7.,
                },
                [2] = {
                    rank = 5,
                    time = 7.,
                },
                [3] = {
                    rank = 5,
                    time = 7.,
                },
                [4] = {
                    rank = 5,
                    time = 7.,
                },
                [5] = {
                    rank = 5,
                    time = 7.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_clear_sight"].name,
            id = 'A02R',
            buff_id = 'B054',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 2,
            tags = { "talent" },
            icon = "Talents\\BTNAccuracy.blp",
            infinite = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    bonus = {
                        { PARAM = DAMAGE_BOOST, VALUE = 15, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "trauma debuff",
            id = 'A02S',
            buff_id = 'B055',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 3,
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.4, METHOD = MULTIPLY_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 1.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.3, METHOD = MULTIPLY_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_tactician"].name,
            id = 'A02T',
            buff_id = 'B056',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 3,
            buff_replacer = { "A02U" },
            icon = "Talents\\BTNFadeStrike.blp",
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.2, METHOD = MULTIPLY_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_tactician"].name,
            id = 'A02U',
            buff_id = 'B057',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 3,
            buff_replacer = { "A02T" },
            icon = "Talents\\BTNFadeStrike.blp",
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.07, METHOD = MULTIPLY_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 2.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.12, METHOD = MULTIPLY_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_fast_reload"].name,
            id = 'A02V',
            buff_id = 'B058',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 9,
            icon = "Talents\\BTNRapid Fire.blp",
            --statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 4, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 12, METHOD = STRAIGHT_BONUS },
                    }
                },
                [4] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 7, METHOD = STRAIGHT_BONUS },
                    }
                },
                [5] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    }
                },
                [6] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 21, METHOD = STRAIGHT_BONUS },
                    }
                },
                [7] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                },
                [8] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                },
                [9] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 30, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_penetrate"].name,
            id = 'A02W',
            buff_id = 'B059',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 2,
            icon = "Talents\\BTNCriticalWound.blp",
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                },
                [2] = {
                    rank = 5,
                    time = 10.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "enchanter frost debuff",
            id = 'A02X',
            buff_id = 'B05A',
            buff_type = NEGATIVE_BUFF,
            attribute = ICE_ATTRIBUTE,
            inherit_level = true,
            max_level = 2,
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    negative_state = STATE_FREEZE
                },
                [2] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_FREEZE
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_unremarkable_marksman"].name,
            id = 'A02Y',
            buff_id = 'B05B',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 2,
            icon = "Talents\\BTNAimForBlood.blp",
            tags = { "talent" },

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                    attack_status = { status = ATTACK_STATUS_CRITICAL, amount = 1 },
                },
                [2] = {
                    rank = 5,
                    time = 10.,
                    attack_status = { status = ATTACK_STATUS_CRITICAL, amount = 2 },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "exhausing venom debuff",
            id = 'A030',
            buff_id = 'B05D',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            tags = { "talent" },
            inherit_level = true,
            max_level = 3,

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.9, METHOD = MULTIPLY_BONUS },
                    },
                },
                [2] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.87, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.87, METHOD = MULTIPLY_BONUS },
                    },
                },
                [3] = {
                    rank = 5,
                    time = 6.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.84, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.84, METHOD = MULTIPLY_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_vampiric_mark"].name,
            id = 'A031',
            buff_id = 'B05E',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            tags = { "talent" },
            inherit_level = true,
            max_level = 1,
            icon = "Talents\\BTN_CR_Blood-Tap.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].TALENTS["talent_deeping_darkness"].name,
            id = 'A032',
            buff_id = 'B05F',
            buff_type = POSITIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            tags = { "talent" },
            inherit_level = true,
            max_level = 2,
            icon = "Talents\\BTNShadowDisguise.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = DARKNESS_BONUS, VALUE = 7, METHOD = STRAIGHT_BONUS },
                    },
                },
                [1] = {
                    rank = 5,
                    time = 5.,
                    bonus = {
                        { PARAM = DARKNESS_BONUS, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    },
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "shackles",
            id = 'A033',
            buff_id = 'B05G',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            tags = { "talent" },
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_ROOT,
                },
                [1] = {
                    rank = 5,
                    time = 3.,
                    negative_state = STATE_ROOT,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "in the dark",
            id = 'A034',
            buff_id = 'B05H',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            tags = { "talent" },
            inherit_level = true,
            max_level = 2,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,
                    negative_state = STATE_BLIND,
                },
                [1] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_BLIND,
                },
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "sprint",
            id = 'A02Z',
            buff_id = 'B05C',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            statusbar_dont_show = true,
            infinite = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 10.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.5, METHOD = MULTIPLY_BONUS }
                    }
                },
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
                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -10, METHOD = STRAIGHT_BONUS }
                    },
                    negative_state = STATE_SLOW
                },
                [2] = {
                    rank = 5,
                    time = 4.,
                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -20, METHOD = STRAIGHT_BONUS }
                    },
                    negative_state = STATE_SLOW
                },
                [3] = {
                    rank = 5,
                    time = 4.,
                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -30, METHOD = STRAIGHT_BONUS }
                    },
                    negative_state = STATE_SLOW
                },
                [4] = {
                    rank = 5,
                    time = 4.,
                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = -40, METHOD = STRAIGHT_BONUS }
                    },
                    negative_state = STATE_SLOW
                },
                [5] = {
                    rank = 5,
                    time = 3.,
                    buff_sfx = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdx",
                    buff_sfx_point = "chest",
                    negative_state = STATE_FREEZE,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_COWARD,
            id = 'A01Q',
            buff_id = 'B00M',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 8,
            icon = "Armor\\BTNbt.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.03, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.06, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.09, METHOD = MULTIPLY_BONUS }
                    }
                },
                [4] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.12, METHOD = MULTIPLY_BONUS }
                    }
                },
                [5] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.15, METHOD = MULTIPLY_BONUS }
                    }

                },
                [6] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.18, METHOD = MULTIPLY_BONUS }
                    }

                },
                [7] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.21, METHOD = MULTIPLY_BONUS }
                    }

                },
                [8] = {
                    rank = 5,
                    time = 3.,
                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS }
                    }

                }
            }

        })
         --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_WITCH,
            id = 'A01R',
            buff_id = 'B00N',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 100,
            icon = "Weapons\\BTN_CW_Red_Scepter.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 10.,

                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.1, METHOD = MULTIPLY_BONUS, value_delta = 0.1, value_delta_level = 1 },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "rot debuff",
            id = 'A00E',
            buff_id = 'B046',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            attribute = POISON_ATTRIBUTE,
            tags = { "poisoning" },

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,

                    effect = 'rot_damage_effect',
                    effect_delay = 0.33,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "living horrors debuff",
            id = 'A00F',
            buff_id = 'B047',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            max_level = 1,
            tags = { "skill" },

            level = {
                [1] = {
                    rank = 5,
                    time = 2.,
                    negative_state = STATE_FEAR,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_FLURRY_ALTAR,
            id = 'A01G',
            buff_id = 'B00G',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNControlMagic.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_POWER_ALTAR,
            id = 'A01L',
            buff_id = 'B00J',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBloodLust.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_ELEMENTAL_ALTAR,
            id = 'A01K',
            buff_id = 'B00I',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNLightningShield.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_ENDURANCE_ALTAR,
            id = 'A01J',
            buff_id = 'B00H',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNAntiMagicShell.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_EXP_ALTAR,
            id = 'ALEX',
            buff_id = 'B026',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNSentryWard.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_WEB,
            id = 'A01T',
            buff_id = 'B00P',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNWeb.blp",

            level = {
                [1] = {
                    rank = 7,
                    time = 3.,
                    negative_state = STATE_ROOT
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SPIDER_POISON,
            id = 'A006',
            buff_id = 'B042',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            icon = "ReplaceableTextures\\CommandButtons\\BTNEnvenomedSpear.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,

                    effect = 'spider_poison_dot',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SPIDER_POISON,
            id = 'A01U',
            buff_id = 'B00Q',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            icon = "ReplaceableTextures\\CommandButtons\\BTNEnvenomedSpear.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_SPIDER_BITE,
            id = 'A01V',
            buff_id = 'B00R',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_SPIDER_BITE,
            id = 'ACLS',
            buff_id = 'B00R',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_BOSS_CURSE,
            id = 'ASCB',
            buff_id = 'B00U',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNPossession.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 5.25,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -50, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -50, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = -125, METHOD = STRAIGHT_BONUS },
                    },
                    negative_state = STATE_SLOW
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].POTION_ANTIDOTE_TEXT,
            id = 'AANT',
            buff_id = 'B00V',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall.blp",

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
            name = LOCALE_LIST[my_locale].POTION_ADRENALINE_TEXT,
            id = 'AADR',
            buff_id = 'B00W',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "GUI\\BTNYellowBottle.blp",

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
            name = LOCALE_LIST[my_locale].SCROLL_OF_PROTECTION_NAME,
            id = 'ASOP',
            buff_id = 'B00X',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNScrollOfProtection.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 25.,
                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].SCROLL_OF_PETRIFICATION_NAME,
            id = 'ASPT',
            buff_id = 'B03B',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNScrollOfTownPortal.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 25.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.75, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.75, METHOD = MULTIPLY_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = -45, METHOD = STRAIGHT_BONUS },
                    },
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].INNOCENCE_ELIXIR,
            id = 'APEI',
            buff_id = 'B03V',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "GUI\\BTN_InvisPot.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 360.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].FOOD_TEXT,
            id = 'AIFD',
            buff_id = 'B03C',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            icon = "GUI\\BTNRpgFood.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 1.05, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = HP_REGEN, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].DRINKS_TEXT,
            id = 'AIDR',
            buff_id = 'B03D',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            icon = "GUI\\BTNRpgDrink.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 1.05, METHOD = MULTIPLY_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 600.,
                    bonus = {
                        { PARAM = MP_REGEN, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                },
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
            name = LOCALE_LIST[my_locale].BUFF_HORROR,
            id = 'AHRF',
            buff_id = 'B00Z',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = false,
            max_level = 5,
            icon = "ReplaceableTextures\\CommandButtons\\BTNCurse.blp",
            statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_STUN,
            id = 'ABRS',
            buff_id = 'B010',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_STUN,
            id = 'AGHB',
            buff_id = 'B011',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_ANTIMAGIC,
            id = 'AHBB',
            buff_id = 'B012',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBanish.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_SNARE,
            id = 'A005',
            buff_id = 'B02V',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNEnsnare.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 3.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.75, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_ROOT
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "hguard buff",
            id = 'A02B',
            buff_id = 'B04O',
            buff_type = POSITIVE_BUFF,
            inherit_level = false,
            max_level = 1,

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_PRISON,
            id = 'A02C',
            buff_id = 'B04P',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNVampiricAura.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 6.,
                    effect = "demoness_prison_damage_effect",
                    effect_delay = 1.,
                    effect_initial_delay = 0.
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_CHILL,
            id = 'ATCH',
            buff_id = 'B017',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNFreezingBreath.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_SKELE_CURSE,
            id = 'ASKD',
            buff_id = 'B018',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNCripple.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_STRUCK,
            id = 'A027',
            buff_id = 'B04K',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNPurge.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 7.,
                    bonus = {
                        { PARAM = LIGHTNING_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_CONFLAGRATE,
            id = 'ACND',
            buff_id = 'B019',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 50,
            icon = "Spell\\BTNEruption.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_WEAKNESS,
            id = 'ACWK',
            buff_id = 'B01A',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            infinite = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNDevotion.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_INDECISIVENESS,
            id = 'ACIN',
            buff_id = 'B01B',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            infinite = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNTrueShot.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = -20, METHOD = STRAIGHT_BONUS },
                        { PARAM = CRIT_MULTIPLIER, VALUE = -0.3, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_VULNERABILITY,
            id = 'ACVN',
            buff_id = 'B01C',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            infinite = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNMaskOfDeath.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = -20, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_WITHERING,
            id = 'ACWT',
            buff_id = 'B01D',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            infinite = true,
            icon = "ReplaceableTextures\\CommandButtons\\BTNSpiritOfVengeance.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
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
            tags = { "talent", "burning" },

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
            name = LOCALE_LIST[my_locale].BUFF_INCINERATE,
            id = 'ATIN',
            buff_id = 'B01G',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            icon = "Talents\\BTNFireSpell3.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_VOLTAGE,
            id = 'ATAD',
            buff_id = 'B01I',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 2,
            icon = "Talents\\BTNLightningSpell7.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_INDUCTION,
            id = 'ATID',
            buff_id = 'B01J',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 4,
            icon = "Talents\\BTNLightningSpell17.blp",
            statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_EXTRA_CHARGE,
            id = 'ATEE',
            buff_id = 'B01L',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            infinite = true,
            icon = "Talents\\BTNLightningSpell1.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 1.2, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 15,
                    time = 1.,
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
            max_level = 3,

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
                [3] = {
                    rank = 15,
                    time = 4.,
                    bonus = {
                        { PARAM = ICE_RESIST, VALUE = -15, METHOD = STRAIGHT_BONUS }
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_GLACIATION,
            id = 'ATGL',
            buff_id = 'B01O',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            infinite = true,
            icon = "Talents\\BTNFrozenShield.blp",
            statusbar_show_level = true,

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
                    }
                },
                [2] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 1.2, METHOD = MULTIPLY_BONUS }
                    }
                },
                [3] = {
                    rank = 15,
                    time = 1.,
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
            name = LOCALE_LIST[my_locale].BUFF_HEAT_TRANSFER,
            id = 'ATHE',
            buff_id = 'B01Q',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            icon = "Talents\\BTN_CR_BloodTapRED.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_RAGE,
            id = 'ATRG',
            buff_id = 'B01S',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 9,
            icon = "Talents\\BTNEssenceOfCelerity.blp",
            --statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_PAIN_KILLER,
            id = 'ATPK',
            buff_id = 'B01U',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            infinite = true,
            icon = "Talents\\BTN_cr_VeeR8.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 6, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 6, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_CARNAGE,
            id = 'ATCR',
            buff_id = 'B01V',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 7,
            icon = "Talents\\BTN_cr_CarA1.blp",
            statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_SHARPENED_BLADE,
            id = 'ATSB',
            buff_id = 'B01W',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            infinite = true,
            icon = "Talents\\BTNDER_Weapon_Forge.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_DISADVANTAGE,
            id = 'ATDA',
            buff_id = 'B01X',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            infinite = true,
            icon = "Talents\\BTN_cr_CarA3.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 8, METHOD = STRAIGHT_BONUS },
                    }
                },
                [2] = {
                    rank = 15,
                    time = 1.,
                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 14, METHOD = STRAIGHT_BONUS },
                    }
                },
                [3] = {
                    rank = 15,
                    time = 1.,
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
                    },
                    negative_state = STATE_SLOW
                },
                [2] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -15, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.85, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_SLOW
                },
                [3] = {
                    rank = 15,
                    time = 6.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = -21, METHOD = STRAIGHT_BONUS },
                        { PARAM = CAST_SPEED, VALUE = -21, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 0.79, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_SLOW
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
            tags = { "dot", "bleeding" },

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
            name = LOCALE_LIST[my_locale].BUFF_IMPULSE_OF_ANGER,
            id = 'ATRI',
            buff_id = 'B020',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 3,
            icon = "Talents\\BTNCR_Human_Bloodlust.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_PRESSURE_POINT,
            id = 'ATPP',
            buff_id = 'B022',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 4,
            icon = "Talents\\BTN_cr_CarA8.blp",
            statusbar_show_level = true,

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
            name = LOCALE_LIST[my_locale].BUFF_ADRENALINE,
            id = 'ATAR',
            buff_id = 'B024',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 2,
            icon = "Talents\\BTNAdrenalin.blp",

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
            name = LOCALE_LIST[my_locale].BUFF_SECOND_WIND,
            id = 'ATSW',
            buff_id = 'B025',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            icon = "Talents\\BTN_cr_Warp6.blp",

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
        NewBuffTemplate({
            name = "weapon poison physical debuff",
            id = 'AWPP',
            buff_id = 'B02W',
            buff_type = NEGATIVE_BUFF,
            attribute = POISON_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "dot", "poisoning" },

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,

                    effect = 'poison_physical_weapon_effect',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "weapon poison magical debuff",
            id = 'AWPM',
            buff_id = 'B02X',
            buff_type = NEGATIVE_BUFF,
            attribute = POISON_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "dot", "poisoning" },

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,

                    effect = 'poison_magical_weapon_effect',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "weapon fire magical debuff",
            id = 'AWFM',
            buff_id = 'B02Y',
            buff_type = NEGATIVE_BUFF,
            attribute = FIRE_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "dot", "burning" },

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,

                    effect = 'fire_magical_weapon_effect',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "weapon bleed physical debuff",
            id = 'AWBP',
            buff_id = 'B02Z',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            tags = { "dot", "bleeding" },

            level = {
                [1] = {
                    rank = 5,
                    time = 6.,

                    effect = 'bleed_physical_weapon_effect',
                    effect_delay = 2.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_ITEM_FORTIFY,
            id = 'AIFT',
            buff_id = 'B030',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBarkskin.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 3.,

                    bonus = {
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS },
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_ITEM_ENRAGE,
            id = 'AIEN',
            buff_id = 'B031',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBloodLust.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_ITEM_CONDUCTION,
            id = 'AICN',
            buff_id = 'B032',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNBrilliance.blp",

            level = {
                [1] = {
                    rank = 5,
                    time = 4.,

                    bonus = {
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_BLACK_DEATH,
            id = 'A019',
            buff_id = 'B04I',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNRegenerationAura.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,

                    bonus = {
                        { PARAM = HEALING_BONUS, VALUE = -10000, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "werewolf buff",
            id = 'ABWO',
            buff_id = 'B041',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    bonus = {
                        { PARAM = CRIT_CHANCE, VALUE = 20, METHOD = STRAIGHT_BONUS },
                        { PARAM = ATTACK_SPEED, VALUE = 35, METHOD = STRAIGHT_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SKELE_MAGE_FIRE_BURNING,
            id = 'A039',
            buff_id = 'B05L',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = FIRE_ATTRIBUTE,
            tags = { "burning" },
            icon = "ReplaceableTextures\\CommandButtons\\BTNWallOfFire.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    effect = 'fire_skeleton_periodic_effect',
                    effect_delay = 1.,
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SKELE_MAGE_COLD_SLOW,
            id = 'A03B',
            buff_id = 'B05M',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 75,
            attribute = ICE_ATTRIBUTE,
            icon = "ReplaceableTextures\\PassiveButtons\\PASBTNFrost.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.8, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_SLOW
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "satyr rally buff",
            id = 'ABSR',
            buff_id = 'B034',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 7.,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
                        { PARAM = MAGICAL_ATTACK, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
                        { PARAM = MOVING_SPEED, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
                        { PARAM = ALL_RESIST, VALUE = 15, METHOD = STRAIGHT_BONUS }
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_ICE_BLAST,
            id = 'AIBL',
            buff_id = 'B035',
            buff_type = NEGATIVE_BUFF,
            attribute = ICE_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNFrost.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 4.,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_SLOW
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SUCCUBUS_DEFENCE,
            id = 'A00N',
            buff_id = 'B04F',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    bonus = {
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SUCCUBUS_BLOOD,
            id = 'A00Z',
            buff_id = 'B04G',
            buff_type = NEGATIVE_BUFF,
            attribute = DARKNESS_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNSilence.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "demon assassin buff",
            id = 'A010',
            buff_id = 'B04H',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,

            level = {
                [1] = {
                    rank = 10,
                    time = 3.,

                    bonus = {
                        { PARAM = DODGE_CHANCE, VALUE = 33, METHOD = STRAIGHT_BONUS },
                        { PARAM = MAGICAL_SUPPRESSION, VALUE = 300, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_CRIPPLE,
            id = 'ABCR',
            buff_id = 'B036',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNSlow.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    bonus = {
                        { PARAM = MOVING_SPEED, VALUE = 0.5, METHOD = MULTIPLY_BONUS },
                        { PARAM = PHYSICAL_DEFENCE, VALUE = 0.75, METHOD = MULTIPLY_BONUS },
                    },
                    negative_state = STATE_SLOW
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_STUN,
            id = 'A00M',
            buff_id = 'B04E',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 2.,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_RAVEN_AMPLIFY,
            id = 'A00J',
            buff_id = 'B04C',
            buff_type = NEGATIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNDoom.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    bonus = {
                        { PARAM = VULNERABILITY, VALUE = 35, METHOD = STRAIGHT_BONUS },
                    }
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_SPIDER_POISON,
            id = 'A00K',
            buff_id = 'B04D',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            attribute = POISON_ATTRIBUTE,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNOrbOfVenom.blp",

            level = {
                [1] = {
                    rank = 10,
                    time = 5.,

                    effect = "andariel_poison_effect",
                    effect_delay = 1.,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_STUN,
            id = 'AFCS',
            buff_id = 'B037',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 2.35,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = LOCALE_LIST[my_locale].BUFF_STUN,
            id = 'ADIC',
            buff_id = 'B038',
            buff_type = NEGATIVE_BUFF,
            inherit_level = false,
            max_level = 1,
            icon = "ReplaceableTextures\\CommandButtons\\BTNStun.blp",

            level = {
                [1] = {
                    rank = 15,
                    time = 3.45,
                    negative_state = STATE_STUN,
                }
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "physical buff aura",
            id = 'MPHA',
            buff_id = 'B03W',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = PHYSICAL_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                        { PARAM = HOLY_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "primal buff aura",
            id = 'MPRA',
            buff_id = 'B03X',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = FIRE_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                        { PARAM = LIGHTNING_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                        { PARAM = ICE_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "shadow buff aura",
            id = 'MSHA',
            buff_id = 'B03Y',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = DARKNESS_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                        { PARAM = POISON_RESIST, VALUE = 50, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "universal buff aura",
            id = 'MUNA',
            buff_id = 'B03Z',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = ALL_RESIST, VALUE = 25, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "sturdy buff aura",
            id = 'MSTA',
            buff_id = 'B040',
            buff_type = POSITIVE_BUFF,
            max_level = 1,
            inherit_level = true,

            level = {
                [1] = {
                    rank = 5,
                    time = 1.,

                    bonus = {
                        { PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
                        { PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
                    }
                }
            }
        })
        --================================================--
        NewBuffTemplate({
            name = "hearth of ghor berserk buff",
            id = 'A00A',
            buff_id = 'B044',
            buff_type = POSITIVE_BUFF,
            inherit_level = true,
            max_level = 4,

            level = {
                [1] = {
                    rank = 15,
                    time = 7.,
                    bonus = {
                        { PARAM = ATTACK_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 5 },
                        { PARAM = CAST_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS, value_delta = 5 },
                        { PARAM = MOVING_SPEED, VALUE = 1.05, METHOD = MULTIPLY_BONUS, value_delta = 0.05 }
                    }
                }
            },

        })
        --================================================--
        NewBuffTemplate({
            name = "skinripper debuff",
            id = 'A028',
            buff_id = 'B04L',
            buff_type = NEGATIVE_BUFF,
            inherit_level = true,
            max_level = 1,
            tags = { "dot", "bleeding" },

            level = {
                [1] = {
                    rank = 15,
                    time = 5.,
                    effect = "skinripper_effect",
                    effect_delay = 1.,
                    effect_initial_delay = 0.
                },
            }

        })
        --================================================--
        NewBuffTemplate({
            name = "cc diminishing",
            id = 'ACCR',
            buff_id = 'B03N',
            buff_type = POSITIVE_BUFF,
            attribute = PHYSICAL_ATTRIBUTE,
            inherit_level = true,
            max_level = 5,
            statusbar_dont_show = true,

            level = {
                [1] = {
                    rank = 10,
                    time = 4.,
                    bonus = {
                        { PARAM = CONTROL_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS, value_delta = 20 },
                    }
                }
            }
        })

        DefineSkillOverlaysData()

        RegisterTestCommand("av", function()
            ApplyBuff(PlayerHero[1], PlayerHero[1], "ACVN", 1)
        end)

        RegisterTestCommand("rv", function()
            RemoveBuff(PlayerHero[1], "ACVN")
        end)

        RegisterTestCommand("car", function()
            ApplyBuff(PlayerHero[1], PlayerHero[1], "ACVN", 1)
        end)

    end

end