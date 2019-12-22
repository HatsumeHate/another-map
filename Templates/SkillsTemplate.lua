    SkillsData           = {}
    SkillList            = {}
    local MaxSkillLevels = 10

    -- target types
    SELF_CAST               = 0
    TARGET_CAST             = 1
    POINT_CAST              = 2
    POINT_AND_TARGET_CAST   = 3

    SKILL_PHYSICAL = 1
    SKILL_MAGICAL = 2


    function GetUnitSkillData(unit, id)
        local unit_data = GetUnitData(unit)

        for i = 1, #unit_data.skill_list do
            if unit_data.skill_list[i].Id == id then
                return unit_data.skill_list[i]
            end
        end

        return nil
    end


    function GetSkillData(id)
        return SkillsData[id]
    end




    local function NewSkillDataLevel()
        return {

            cooldown                = 0.,

            health_cost             = 0.,
            resource_cost           = 0.,

            range = 0.,
            radius = 0.,

            missile                 = nil,
            effect                  = nil,

            required_buff           = 0,

            start_effect_on_cast_point    = nil,
            start_effect_on_cast_point_scale  = 1.,

            end_effect_on_cast_point    = nil,
            end_effect_on_cast_point_scale  = 1.,

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
            current_level           = 1,
            name                    = "",
            icon                    = "",
            skill_type              = nil,
            autotrigger             = true,
            order                   = 0,
            activation_type         = SELF_CAST,
            channeling              = false,
            channel_tick            = 0.,
            level = {}
        }

        for i = 1, MaxSkillLevels do
            my_new_skill.level[i] = NewSkillDataLevel()
        end

        MergeTables(my_new_skill, data)

        my_new_skill.current_level = 1

        for i = 1, MaxSkillLevels do
            if  my_new_skill.level[i] ~= nil then

                if my_new_skill.level[i].autotrigger == nil then
                    my_new_skill.level[i].autotrigger = false
                end

                if my_new_skill.level[i].animation_scale == nil then
                    my_new_skill.level[i].animation_scale = 1.
                end

                if my_new_skill.level[i].animation == nil then
                    my_new_skill.level[i].animation = 0
                end

                if my_new_skill.level[i].cooldown == nil then
                    my_new_skill.level[i].cooldown = 0.1
                end

                if my_new_skill.level[i].resource_cost == nil then
                    my_new_skill.level[i].resource_cost = 0.
                end

                if my_new_skill.level[i].range == nil then
                    my_new_skill.level[i].range = 0.
                end

                if my_new_skill.level[i].radius == nil then
                    my_new_skill.level[i].radius = 0.
                end

            end
        end

        SkillsData[FourCC(skillId)] = my_new_skill
        return my_new_skill
    end



    function DefineSkillsData()

        -- defined skills
        NewSkillData('A000', {
            name            = "test skill",
            activation_type = TARGET_CAST,
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
            icon            = "Spell\\BTNice-sky-1.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MFRB',
                    resource_cost       = 10.,
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
            icon            = "Spell\\BTNCRFrostShock.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    effect              = 'EFRN',
                    resource_cost       = 10.,
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
            icon            = "Spell\\BTNFlameLance.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MGFB',
                    resource_cost       = 10.,
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
            icon            = "Spell\\BTNOrbOfFrost2.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MFRO',
                    resource_cost       = 10.,
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.,
                    animation_backswing = 1.,
                    animation_scale     = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('A00M', {
            name            = "lightning strike skill",
            icon            = "Spell\\BTNThunderStorm.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 800.,
                    effect              = 'ELST',
                    resource_cost       = 10.,
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 1.,
                    animation_backswing = 1.,
                    animation_scale     = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('A00L', {
            name            = "sorceress teleport skill",
            icon            = "Spell\\BTNBlink_V2.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range = 500.,

                    start_effect_on_cast_point = 'Spell\\Blink Blue Caster.mdx',
                    start_effect_on_cast_point_scale = 1.,

                    end_effect_on_cast_point = 'Spell\\Blink Blue Target.mdx',
                    end_effect_on_cast_point_scale = 1.,

                    resource_cost       = 5.,
                    cooldown            = 3.,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 1.,
                    animation_scale     = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('A00F', {
            name            = "meteor skill",
            icon            = "Spell\\BTNInferno.BLP",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 1000.,
                    effect              = 'EMTR',
                    resource_cost       = 20.,
                    cooldown            = 7.,
                    animation           = 3,
                    animation_point     = 0.5,
                    animation_backswing = 1.,
                    animation_scale     = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('A00J', {
            name            = "discharge skill",
            icon            = "Spell\\BTNSparkFlare.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 10.,
                    cooldown            = 0.1,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00K', {
            name            = "lightning ball skill",
            icon            = "Spell\\BTNLightningOrb.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 900.,
                    resource_cost       = 15.,
                    missile             = 'MBLB',
                    cooldown            = 7.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00N', {
            name            = "focus skill",
            icon            = "Spell\\BTN_ArcaneProtection.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    effect             = 'EFCS',
                    resource_cost       = 5.,
                    cooldown            = 25.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00N', {
            name            = "frost armor skill",
            icon            = "Spell\\BTNCloakOfFrost.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    effect             = 'EFAR',
                    resource_cost       = 5.,
                    cooldown            = 20.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00H', {
            name            = "elemental mastery skill",
            icon            = "Spell\\BTN_cr_Dark Arts.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    effect             = 'EEMA',
                    resource_cost       = 5.,
                    cooldown            = 20.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00I', {
            name            = "hydra skill",
            icon            = "Spell\\BTNGlaiveCrit.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,

            level = {
                [1] = {
                    range               = 600.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00O', {
            name            = "barbarian jump skill",
            icon            = "Spell\\BTN_cr_CarA2.blp",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 500.,
                    cooldown            = 12.,
                    resource_cost       = 5.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00Z', {
            name            = "throwing knife skill",
            icon            = "Spell\\BTN_cr_VeeR1.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MTHK',
                    resource_cost       = 5.,
                    cooldown            = 12.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00B', {
            name            = "uppercut skill",
            icon            = "Spell\\BTNContusing Punch.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 100.,
                    effect              = 'EUPP',
                    cooldown            = 12.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00Q', {
            name            = "berserk skill",
            icon            = "Spell\\BTN_cr_CarA10.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    effect              = 'EBRS',
                    resource_cost       = 10.,
                    cooldown            = 22.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A010', {
            name            = "whirlwind skill",
            icon            = "Spell\\BTNHot Wirlwind.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    cooldown            = 0.3,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 1.,

                }
            }
        })
        --============================================--
        NewSkillData('A007', {
            name            = "crushing strike skill",
            icon            = "Spell\\BTNBreakingSmash.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 100.,
                    effect              = 'ECRH',
                    cooldown            = 2.3,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00A', {
            name            = "chain skill",
            icon            = "Spell\\BTNHook.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 600.,
                    missile             = 'MBCH',
                    resource_cost       = 6.,
                    cooldown            = 2.3,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A006', {
            name            = "cutting slash skill",
            icon            = "Spell\\BTNGlaiveCrit.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    range               = 100.,
                    effect              = 'ECSL',
                    cooldown            = 3.3,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00C', {
            name            = "warcry skill",
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,

            level = {
                [1] = {
                    effect              = 'EWCR',
                    resource_cost       = 5.,
                    cooldown            = 22.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
    end