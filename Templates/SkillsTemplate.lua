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
    SKILL_UNIQUE = 3


    SKILL_CATEGORY_LIGHTNING = 1
    SKILL_CATEGORY_ICE = 2
    SKILL_CATEGORY_FIRE = 3
    SKILL_CATEGORY_ARCANE = 4

    SKILL_CATEGORY_FIGHTING_MASTERY = 5
    SKILL_CATEGORY_BATTLE_ADVANTAGE = 6
    SKILL_CATEGORY_INNER_STRENGTH = 7


    SKILL_CATEGORY_NAME = {

    }

    SKILL_CATEGORY_ICON = {
        [SKILL_CATEGORY_LIGHTNING] = "GUI\\BTNLightning Mastery.blp",
        [SKILL_CATEGORY_FIRE] = "GUI\\BTNFireMastery.blp",
        [SKILL_CATEGORY_ICE] = "GUI\\BTNWaterMastery.blp",
        [SKILL_CATEGORY_ARCANE] = "GUI\\BTNAstral Blessing.blp",
        [SKILL_CATEGORY_FIGHTING_MASTERY] = "GUI\\BTN_CR_HOLDINGGROUND.blp",
        [SKILL_CATEGORY_BATTLE_ADVANTAGE] = "GUI\\BTN_cr_Warp3.blp",
        [SKILL_CATEGORY_INNER_STRENGTH] = "GUI\\BTN_cr_HOLYllllcharge.blp",
    }

    CLASS_SKILL_CATEGORY = {
        [BARBARIAN_CLASS] = {
            SKILL_CATEGORY_FIGHTING_MASTERY,
            SKILL_CATEGORY_BATTLE_ADVANTAGE,
            SKILL_CATEGORY_INNER_STRENGTH
        },
        [SORCERESS_CLASS] = {
            SKILL_CATEGORY_FIRE,
            SKILL_CATEGORY_LIGHTNING,
            SKILL_CATEGORY_ICE,
            SKILL_CATEGORY_ARCANE
        }
    }


    function GetSkillName(id)
        local skill = SkillsData[FourCC(id)]
        if skill == nil then return "unnamed skill" end
        return skill.name
    end

    function GetSkillCategoryName(category)
        return SKILL_CATEGORY_NAME[category] or "unnamed category"
    end


    function GetUnitSkillData(unit, id)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    local skill = unit_data.skill_list[i]

                        if skill.level[skill.current_level] == nil then
                            GenerateSkillLevelData(skill, skill.current_level)
                        end

                    return skill
                end
            end

        return nil
    end


    ---@param id integer
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


    function GenerateSkillLevelData(skill, lvl)

        if lvl == 1 then return end

        if skill.level[lvl] == nil then
            skill.level[lvl] = NewSkillDataLevel()
            MergeTables(skill.level[lvl], skill.level[1])
            skill.level[lvl].generated = false
        end


        if skill.level[lvl].generated == nil or not skill.level[lvl].generated then

            if skill.cooldown_delta ~= nil then
                skill.level[lvl].cooldown = (skill.level[1].cooldown or 0.1) + math.floor(lvl / (skill.cooldown_delta_level or 1.)) * skill.cooldown_delta
                if skill.level[lvl].cooldown < 0.1 then skill.level[lvl].cooldown = 0.1 end
            end

            if skill.resource_cost_delta ~= nil then
                skill.level[lvl].resource_cost = (skill.level[1].resource_cost or 0) + math.floor(lvl / (skill.resource_cost_delta_level or 1.)) * skill.resource_cost_delta
                if skill.level[lvl].resource_cost < 0 then skill.level[lvl].resource_cost = 0 end
            end

            if skill.range_delta ~= nil then
                skill.level[lvl].range = (skill.level[1].range or 0.) + math.floor(lvl / (skill.range_delta_level or 1.)) * skill.range_delta
                if skill.level[lvl].range < 0. then skill.level[lvl].range = 0. end
            end

            skill.level[lvl].generated = true
        end
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

        my_new_skill.level[1] = NewSkillDataLevel()
        MergeTables(my_new_skill, data)

        for i = 2, MaxSkillLevels do
            GenerateSkillLevelData(my_new_skill, i)
        end


        my_new_skill.current_level = 1

            for i = 1, MaxSkillLevels do
                if  my_new_skill.level[i] ~= nil then

                    if my_new_skill.level[i].autotrigger == nil then
                        my_new_skill.level[i].autotrigger = false
                    end

                end
            end

        SkillsData[FourCC(skillId)] = my_new_skill
        return my_new_skill
    end



    function DefineSkillsData()

        SKILL_CATEGORY_NAME = {
            [SKILL_CATEGORY_LIGHTNING] = LOCALE_LIST[my_locale].SKILL_CATEGORY_LIGHTNING_ADVANCED,
            [SKILL_CATEGORY_FIRE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_FIRE_ADVANCED,
            [SKILL_CATEGORY_ICE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_ICE_ADVANCED,
            [SKILL_CATEGORY_ARCANE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_ARCANE_ADVANCED,
            [SKILL_CATEGORY_FIGHTING_MASTERY] = LOCALE_LIST[my_locale].SKILL_CATEGORY_FIGHTING_MASTERY_ADVANCED,
            [SKILL_CATEGORY_BATTLE_ADVANTAGE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_BATTLE_ADVANTAGE_ADVANCED,
            [SKILL_CATEGORY_INNER_STRENGTH] = LOCALE_LIST[my_locale].SKILL_CATEGORY_INNER_STRENGTH_ADVANCED,
        }
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
                },
                [7] = {
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
            name            = LOCALE_LIST[my_locale].SKILL_FROSTBOLT,
            icon            = "Spell\\BTNice-sky-1.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,


            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MFRB',
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Ice Low.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                },
            }

        })
        --============================================--
        NewSkillData('A001', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTNOVA,
            icon            = "Spell\\BTNCRFrostShock.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,

            level = {
                [1] = {
                    effect              = 'EFRN',
                    resource_cost       = 10.,
                    cooldown            = 10.,
                    animation           = 3,
                    animation_point     = 2.1,
                    animation_backswing = 0.633,
                    animation_scale     = 0.3,
                    effect_on_caster        = "Spell\\Ice Low.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }

        })
        --============================================--
        NewSkillData('A00D', {
            name            = LOCALE_LIST[my_locale].SKILL_FIREBALL,
            icon            = "Spell\\BTNFlameLance.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            sound = { pack = { "Sounds\\Spells\\fire_light_launch_1.wav", "Sounds\\Spells\\fire_light_launch_2.wav", "Sounds\\Spells\\fire_light_launch_3.wav" }, volume = 110, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MGFB',
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Fire Low.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A005', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTORB,
            icon            = "Spell\\BTNOrbOfFrost2.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            sound = { pack = { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav" }, volume = 110, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MFRO',
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 3,
                    animation_point     = 2.1,
                    animation_backswing = 0.633,
                    animation_scale     = 0.35,
                    effect_on_caster        = "Spell\\Ice High.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00M', {
            name            = LOCALE_LIST[my_locale].SKILL_LIGHTNINGSTRIKE,
            icon            = "Spell\\BTNLightningSpell8.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            sound = { pack = { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav" }, volume = 110, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 800.,
                    effect              = 'ELST',
                    resource_cost       = 17.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Storm Cast.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00L', {
            name            = LOCALE_LIST[my_locale].SKILL_TELEPORT,
            icon            = "Spell\\BTNBlink_V2.blp",
            activation_type = POINT_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_ARCANE,
            range_delta = 5.,
            range_delta_level = 1,

            level = {
                [1] = {
                    range = 400.,

                    start_effect_on_cast_point = 'Spell\\Blink Blue Caster.mdx',
                    start_effect_on_cast_point_scale = 1.,

                    end_effect_on_cast_point = 'Spell\\Blink Blue Target.mdx',
                    end_effect_on_cast_point_scale = 1.,

                    resource_cost       = 5.,
                    cooldown            = 5.,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 0.3,
                }
            }
        })
        --============================================--
        NewSkillData('A00F', {
            name            = LOCALE_LIST[my_locale].SKILL_METEOR,
            icon            = "Spell\\BTNInferno.BLP",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,

            level = {
                [1] = {
                    range               = 1000.,
                    effect              = 'EMTR',
                    resource_cost       = 20.,
                    cooldown            = 7.,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                }
            }
        })
        --============================================--
        NewSkillData('A00J', {
            name            = LOCALE_LIST[my_locale].SKILL_DISCHARGE,
            icon            = "Spell\\BTNLightningSpell16.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            sound = { pack = { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Storm Cast.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 0.8,
                }
            }
        })
        --============================================--
        NewSkillData('A019', {
            name            = LOCALE_LIST[my_locale].SKILL_CHAIN_LIGHTNING,
            icon            = "Spell\\BTNChainLightning2.blp",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            sound = { pack = { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 870.,
                    resource_cost       = 16.,
                    cooldown            = 3.,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Storm Cast.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00K', {
            name            = LOCALE_LIST[my_locale].SKILL_LIGHTNINGBALL,
            icon            = "Spell\\BTNLightningSpell9.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            sound = { pack = { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 900.,
                    resource_cost       = 25.,
                    missile             = 'MBLB',
                    cooldown            = 11.,
                    animation           = 3,
                    animation_point     = 2.1,
                    animation_backswing = 0.633,
                    animation_scale     = 0.5,
                    effect_on_caster        = "Spell\\Storm Cast.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00N', {
            name            = LOCALE_LIST[my_locale].SKILL_FOCUS,
            icon            = "Spell\\BTN_ArcaneProtection.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ARCANE,

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
        NewSkillData('A00E', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTARMOR,
            icon            = "Spell\\BTNCloakOfFrost.blp",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_ICE,

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
            name            = LOCALE_LIST[my_locale].SKILL_ELEMENTALMASTERY,
            icon            = "Spell\\BTN_cr_Dark Arts.blp",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_ARCANE,

            level = {
                [1] = {
                    effect             = 'EEMA',
                    resource_cost       = 5.,
                    cooldown            = 20.,
                    animation           = 3,
                    animation_point     = 0.1,
                    animation_backswing = 0.1,
                    animation_scale     = 0.3,
                }
            }
        })
        --============================================--
        NewSkillData('A00I', {
            name            = LOCALE_LIST[my_locale].SKILL_SUMMONHYDRA,
            icon            = "Spell\\BTNPyro.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            autotrigger = false,

            level = {
                [1] = {
                    range               = 600.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.4,
                    effect_on_caster        = "Spell\\Fire Low.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00O', {
            name            = LOCALE_LIST[my_locale].SKILL_JUMP,
            icon            = "Spell\\BTN_cr_CarA2.blp",
            activation_type = POINT_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,

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
            name            = LOCALE_LIST[my_locale].SKILL_THROWKNIFE,
            icon            = "Spell\\BTN_cr_VeeR1.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,


            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MTHK',
                    resource_cost       = 5.,
                    cooldown            = 12.,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.2666,
                    animation_scale     = 0.3
                }
            }
        })
        --============================================--
        NewSkillData('A00B', {
            name            = LOCALE_LIST[my_locale].SKILL_UPPERCUT,
            icon            = "Spell\\BTNContusing Punch.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 128, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 75.,
                    effect              = 'EUPP',
                    cooldown            = 12.,
                    animation           = 5,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.7,
                }
            }
        })
        --============================================--
        NewSkillData('A00Q', {
            name            = LOCALE_LIST[my_locale].SKILL_BERSERK,
            icon            = "Spell\\BTN_cr_CarA10.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,

            level = {
                [1] = {
                    effect              = 'EBRS',
                    resource_cost       = 10.,
                    cooldown            = 22.,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.2666,
                    animation_scale     = 0.5
                }
            }
        })
        --============================================--
        NewSkillData('A010', {
            name            = LOCALE_LIST[my_locale].SKILL_WHIRLWIND,
            icon            = "Spell\\BTNHot Wirlwind.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,

            level = {
                [1] = {
                    cooldown            = 0.3,
                    animation           = 3,
                    animation_point     = 0.001,
                    animation_backswing = 0.001,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A007', {
            name            = LOCALE_LIST[my_locale].SKILL_CRUSHINGBLOW,
            icon            = "Spell\\BTNBreakingSmash.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 128, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 75.,
                    effect              = 'ECRH',
                    cooldown            = 2.3,
                    resource_cost = 5.,
                    animation           = 4,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.9,
                    effect_on_caster        = "Spell\\Sweep_Fire_Medium.mdx",
                    effect_on_caster_point  = 'weapon left',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A020', {
            name            = LOCALE_LIST[my_locale].SKILL_EXECUTION,
            icon            = "Spell\\BTNHearbreak.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 128, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 75.,
                    effect              = 'EEXC',
                    cooldown            = 5.,
                    resource_cost = 5.,
                    animation           = 6,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.9,
                    effect_on_caster        = "Spell\\Sweep_Fire_Medium.mdx",
                    effect_on_caster_point  = 'weapon right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00A', {
            name            = LOCALE_LIST[my_locale].SKILL_HARPOON,
            icon            = "Spell\\BTNHook.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,

            level = {
                [1] = {
                    range               = 600.,
                    missile             = 'MBCH',
                    resource_cost       = 6,
                    cooldown            = 2.3,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.2666,
                    animation_scale     = 0.4
                }
            }
        })
        --============================================--
        NewSkillData('A006', {
            name            = LOCALE_LIST[my_locale].SKILL_CUTTINGSLASH,
            icon            = "Spell\\BTNGlaiveCrit.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 100.,
                    effect              = 'ECSL',
                    cooldown            = 3.3,
                    resource_cost = 5.,
                    animation           = 6,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.7,
                    effect_on_caster        = "Spell\\Sweep_TeamColor_Medium.mdx",
                    effect_on_caster_point  = 'weapon right',
                    effect_on_caster_scale  = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('A00C', {
            name            = LOCALE_LIST[my_locale].SKILL_WARCRY,
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,


            level = {
                [1] = {
                    effect              = 'EWCR',
                    resource_cost       = 5,
                    cooldown            = 22.,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.2666,
                    animation_scale     = 0.5
                }
            }
        })
        --============================================--
        NewSkillData('ABFA', {
            name            = LOCALE_LIST[my_locale].SKILL_FIRSTAID,
            icon            = "Spell\\BTNNatureRestore.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,

            level = {
                [1] = {
                    effect              = 'EBFA',
                    resource_cost       = 3.,
                    cooldown            = 30.,
                    animation           = 3,
                    animation_point     = 1.4,
                    animation_backswing = 0.2666,
                    animation_scale     = 0.5
                }
            }
        })
    end