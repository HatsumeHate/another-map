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


            effect_damage = {},
            effect_hp_value = 0,
            effect_mp_value = 0,
            effect_delay = 0.,

            effect_hp_percent_value = 0,
            effect_mp_percent_value = 0,
            effect_type = 0,

            effect_trigger_sfx = "",
            effect_trigger_sfx_scale = 1.,
            effect_trigger_sfx_point = "",

            effect_sfx = "",
            effect_sfx_scale = 1.,
            effect_sfx_point = "",

            bonus = { }

        }
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

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,

                    current_level = 1,
                    max_level = 1,

                    effect_hp_value = 15,
                    effect_delay = 1.,

                    effect_sfx = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdx",
                    effect_sfx_point = "origin",
                    effect_sfx_scale = 0.7,

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
    end

end