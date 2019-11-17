    SkillsData           = {}
    local MaxSkillLevels = 10

    -- target types
    SELF_CAST            = 1
    TARGET_CAST          = 2
    POINT_CAST           = 3

    ---@param skillId integer
    local function NewSkillData(skillId)
        return {
            Id                     = skillId,

            SkillTargetType        = 1,
            Range                  = 0.,
            Cooldown               = 0.,
            IsChanneling           = false,
            ChannelTick            = 0.,
            UseHpAmount            = 0.,
            UseMpAmount            = 0.,

            UsedMissile            = 0,
            UsedEffect             = 0,

            AutoTrigger            = true,
            Order                  = 0,

            BuffCondition          = 0,

            GivedHpAmount          = 0.,
            GivedMpAmount          = 0.,

            Effect_Lightning       = '',

            EffectOnCastLocation   = '',
            EffectOnCastStart      = '',
            EffectOnCastStartPoint = '',

            EffectOnCast           = '',
            EffectOnCastPoint      = '',

            SkillAnimation         = "",
            SkillAnimationPoint    = 0.,
            SkillAnimationScale    = 0.,
        }
    end

    ---@param skillId integer
    local function NewSkillDataLevel(skillId)
        local my_new_skill = { level = {} }

        for i = 1, MaxSkillLevels do
            my_new_skill.level[i] = NewSkillData(skillId)
        end

        return my_new_skill
    end

    function DefineSkillsData()
        for i = 1, 5 do
            SkillsData[i] = NewSkillDataLevel(i)
        end
        -- defined skills
    end