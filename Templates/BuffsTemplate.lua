do

    BUFF_DATA = {}
    local MAX_BUFF_LEVEL = 10


    POSITIVE_BUFF = 1
    NEGATIVE_BUFF = 2



    local function NewBuffLevelData()
        return {

            rank = 1,
            time = 1,
            negative_state = 0,

            effect_hp_value = 0,
            effect_mp_value = 0,
            effect_hp_percent_value = 0,
            effect_mp_percent_value = 0,
            effect_polarity = 0,

            effect_delay = 0,
            effect_type = 0,
            effect_sfx = "",

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

            level = {}
        }

            for i = 1, MAX_BUFF_LEVEL do
                new_buff.level[i] = NewBuffLevelData()
            end

            MergeTables(new_buff, buff_template)
            BUFF_DATA[FourCC(id)] = new_buff

        return new_buff
    end


    function DefineBuffsData()
        --TODO test
        --================================================--
        NewBuffTemplate({
            name = "test buff",
            id = 'A002',
            buff_id = 'B000',

            level = {
                [1] = {
                    rank = 5,
                    time = 5.,

                    bonus = {
                        { PARAM = PHYSICAL_ATTACK, VALUE = 2., METHOD = MULTIPLY_BONUS }
                    }
                }
            }

        })
        --================================================--

    end

end