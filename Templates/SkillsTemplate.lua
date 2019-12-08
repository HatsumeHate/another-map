    SkillsData           = {}
    SkillList            = {}
    local MaxSkillLevels = 10

    -- target types
    SELF_CAST            = 1
    TARGET_CAST          = 2
    POINT_CAST           = 3

    SKILL_PHYSICAL = 1
    SKILL_MAGICAL = 2



    function GetSkillData(id)
        return SkillsData[id]
    end




    local function NewSkillDataLevel()
        return {

            cooldown                = 0.,

            required_hp             = 0.,
            required_mp             = 0.,
            given_hp                = 0.,
            given_mp                = 0.,

            missile                 = nil,
            effect                  = nil,

            required_buff           = 0,

            lightning               = '',

            effect_on_cast_point    = '',
            effect_on_caster        = '',
            effect_on_caster_point  = '',
            effect_on_caster_scale  = 1.,

            EffectOnCast            = '',
            EffectOnCastPoint       = '',

            animation               = 0,
            animation_point         = 0.,
            animation_backswing     = 0.,
            animation_scale         = 0.,
        }
    end

    ---@param skillId integer
    ---@param data table
     function NewSkillData(skillId, data)
        local my_new_skill = {
            Id                      = skillId,
            name = "",
            skill_type              = nil,
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
            name            = "test skill",
            target_type     = TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    missile             = 'M001',
                    effect              = 'EFF1',
                    cooldown            = 5.,
                    animation           = 3,
                    animation_point     = 1.5,
                    animation_backswing = 0.1666,
                    animation_scale     = 0.5,
                }
            }

        })
        --============================================--
        NewSkillData('A003', {
            name            = "frostbolt skill",
            target_type     = TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    missile             = 'MFRB',
                    effect              = 'EFRB',
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.5,
                    animation_backswing = 0.1666,
                    animation_scale     = 0.5,
                }
            }

        })
        --============================================--
        NewSkillData('A001', {
            name            = "frost nova skill",
            target_type     = SELF_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    effect              = 'EFRN',
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.1666,
                    animation_scale     = 0.5,
                }
            }

        })
        --============================================--
        NewSkillData('A00D', {
            name            = "fireball skill",
            target_type     = TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    missile             = 'MGFB',
                    effect              = 'EGFB',
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.1666,
                    animation_scale     = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('A005', {
            name            = "frost orb skill",
            target_type     = TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    missile             = 'MFRO',
                    effect              = 'EFOA',
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.,
                    animation_backswing = 1.,
                    animation_scale     = 0.5,
                }
            }
        })

    end