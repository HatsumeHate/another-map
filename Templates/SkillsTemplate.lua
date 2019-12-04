    SkillsData           = {}
    SkillList            = {}
    local MaxSkillLevels = 10

    -- target types
    SELF_CAST            = 1
    TARGET_CAST          = 2
    POINT_CAST           = 3


    function GetSkillData(id)
        return SkillsData[id]
    end




    local function NewSkillDataLevel()
        return {

            range                   = 0.,
            cooldown                = 0.,

            required_hp             = 0.,
            required_mp             = 0.,
            given_hp                = 0.,
            given_mp                = 0.,

            missile                 = 0,
            effect                  = 0,

            required_buff          = 0,

            lightning               = '',

            effect_on_cast_point    = '',
            effect_on_caster        = '',
            effect_on_caster_point  = '',

            EffectOnCast            = '',
            EffectOnCastPoint       = '',

            animation               = "",
            animation_point         = 0.,
            animation_scale         = 0.,
        }
    end

    ---@param skillId integer
    ---@param data table
    local function NewSkillData(skillId, data)
        local my_new_skill = {
            Id                      = skillId,
            name = "",
            autotrigger             = true,
            order                   = 0,
            target_type             = SELF_CAST,
            channeling              = false,
            channel_tick            = 0.,
            level = {}
        }

        for i = 1, MaxSkillLevels do
            my_new_skill.level[i] = NewSkillDataLevel()
        end

        MergeTables(my_new_skill, data)
        SkillsData[FourCC(skillId)] = my_new_skill
        return my_new_skill
    end



    function DefineSkillsData()

        -- defined skills
        NewSkillData('A000', {
            name = "test skill",
            target_type = TARGET_CAST,
            level = {
                [1] = {
                    missile             = 'M001',
                    effect              = 'EFF1',
                    cooldown            = 5.,
                    animation           = 2,
                    animation_point     = 0.7,
                    animation_scale     = 1.,
                }
            }
        })
    end