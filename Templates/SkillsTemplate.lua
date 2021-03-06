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
            --print("GenerateSkillLevelData - level nil")
            skill.level[lvl] = NewSkillDataLevel()
            MergeTables(skill.level[lvl], skill.level[1])
            skill.level[lvl].generated = false
            --print("GenerateSkillLevelData - ready for generate")
        end


        if skill.level[lvl].generated == nil or not skill.level[lvl].generated then
            --print("GenerateSkillLevelData - gen start")

            if skill.cooldown_delta then
                --print("GenerateSkillLevelData - cooldown_delta")
                skill.level[lvl].cooldown = (skill.level[1].cooldown or 0.1) + math.floor(lvl / (skill.cooldown_delta_level or 1.)) * skill.cooldown_delta
                if skill.level[lvl].cooldown < 0.1 then skill.level[lvl].cooldown = 0.1 end
               -- print("GenerateSkillLevelData - cooldown_delta end")
            end

            if skill.resource_cost_delta then
                --print("GenerateSkillLevelData - resource_cost_delta")
                skill.level[lvl].resource_cost = (skill.level[1].resource_cost or 0) + math.floor(lvl / (skill.resource_cost_delta_level or 1.)) * skill.resource_cost_delta
                if skill.level[lvl].resource_cost < 0 then skill.level[lvl].resource_cost = 0 end
                --print("GenerateSkillLevelData - resource_cost_delta end")
            end

            if skill.range_delta then
                --print("GenerateSkillLevelData - range_delta")
                skill.level[lvl].range = (skill.level[1].range or 0.) + math.floor(lvl / (skill.range_delta_level or 1.)) * skill.range_delta
                if skill.level[lvl].range < 0. then skill.level[lvl].range = 0. end
                --print("GenerateSkillLevelData - range_delta done")
            end

            skill.level[lvl].generated = true
            --print("GenerateSkillLevelData - gen done")
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
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.1,
                    animation_backswing = 0.3,
                    animation_scale     = 0.6,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "origin" },
                            { effect = "Spell\\Ice Low.mdx", point = 'hand right' }
                        }
                    },
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
                    sfx_pack = {
                        on_caster = {
                            { effect = "war3mapImported\\FrostNova.MDX", point = "origin" },
                            { effect = "Spell\\Ice Low.mdx", point = 'hand right' }
                        }
                    },
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
            sound = { pack = { "Sounds\\Spells\\fire_light_launch_1.wav", "Sounds\\Spells\\fire_light_launch_2.wav", "Sounds\\Spells\\fire_light_launch_3.wav" }, volume = 117, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MGFB',
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.1,
                    animation_backswing = 0.3,
                    animation_scale     = 0.6,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Fire_Small.mdx", point = "weapon" },
                            { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('AMLT', {
            name            = LOCALE_LIST[my_locale].SKILL_MELTDOWN,
            icon            = "Spell\\BTNFireBreaker.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            sound = { pack = { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav" }, volume = 117, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    --missile             = 'MGFB',
                    --from_unit           = true,
                    resource_cost       = 20.,
                    cooldown            = 6.,
                    animation           = 3,
                    animation_point     = 2.3,
                    animation_backswing = 0.433,
                    animation_scale     = 0.25,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon" },
                            { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                        }
                    },
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
                    from_unit           = true,
                    resource_cost       = 14.,
                    cooldown            = 0.3,
                    animation           = 3,
                    animation_point     = 2.1,
                    animation_backswing = 0.633,
                    animation_scale     = 0.35,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon" },
                            { effect = "Spell\\Ice High.mdx", point = 'hand right' }
                        }
                    },
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
                    resource_cost       = 24.,
                    cooldown            = 0.3,
                    animation           = 2,
                    animation_point     = 1.1,
                    animation_backswing = 0.3,
                    animation_scale     = 0.7,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon" },
                            { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                        }
                    },
                    --effect_on_caster        = "Spell\\Storm Cast.mdx",
                    --effect_on_caster_point  = 'hand right',
                    --effect_on_caster_scale  = 1.,
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
                    range = 300.,

                    start_effect_on_cast_point = 'Spell\\Blink Blue Caster.mdx',
                    start_effect_on_cast_point_scale = 1.,

                    --end_effect_on_cast_point = 'Spell\\Blink Blue Target.mdx',
                    --end_effect_on_cast_point_scale = 1.,

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
            sound = { pack = { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav" }, volume = 117, cutoff = 1500.},

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

                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon" },
                            { effect = "Spell\\Fire Uber.mdx", point = 'hand right' }
                        }
                    },
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
                    animation_scale     = 0.6,

                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon" },
                            { effect = "Spell\\Storm Cast.mdx", point = 'hand right', scale = 0.8 }
                        }
                    },
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
                    resource_cost       = 13.,
                    cooldown            = 3.,
                    animation           = 2,
                    animation_point     = 1.3,
                    animation_backswing = 0.3,
                    animation_scale     = 0.6,
                    --effect_on_caster        = "Spell\\Storm Cast.mdx",
                    --effect_on_caster_point  = 'hand right',
                    --effect_on_caster_scale  = 1.,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" },
                            { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                        }
                    },
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
                    from_unit           = true,
                    cooldown            = 11.,
                    animation           = 3,
                    animation_point     = 2.1,
                    animation_backswing = 0.633,
                    animation_scale     = 0.5,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" },
                            { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                        }
                    },
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
            sound = { pack = { "Sounds\\Spell\\focus_cast_1.wav", "Sounds\\Spell\\focus_cast_2.wav", "Sounds\\Spell\\focus_cast_3.wav" }, volume = 120, cutoff = 1500.},
            --

            level = {
                [1] = {
                    effect             = 'EFCS',
                    resource_cost       = 5.,
                    cooldown            = 25.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdx", point = "origin", scale = 0.4 }
                        }
                    }
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
            sound = { pack = { "Sounds\\Spells\\frost_armor_launch_2.wav" }, volume = 110, cutoff = 1500.},

            level = {
                [1] = {
                    effect             = 'EFAR',
                    resource_cost       = 5.,
                    cooldown            = 20.,
                    animation           = 3,
                    animation_point     = 0.3,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\ShivasEnchantment.mdx", point = "origin", duration = 1.233 },
                            { effect = "Spell\\ColdRitual.mdx", point = "origin" }
                        }
                    }
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
                    animation_point     = 0.15,
                    animation_backswing = 0.15,
                    animation_scale     = 0.6,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdx", point = "origin", duration = 1.233 }
                        }
                    }
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
                    end_effect_on_cast_point = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdx",
                    end_effect_on_cast_point_scale = 0.7,
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
                    from_unit           = true,
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
                    range               = 135.,
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
            channel = true,

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
                    range               = 135.,
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
                    range               = 135.,
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
                    from_unit           = true,
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
                    range               = 135.,
                    effect              = 'ECSL',
                    cooldown            = 7.3,
                    resource_cost       = 5.,
                    animation           = 6,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.7,
                    effect_on_caster        = "Spell\\Sweep_Blood_Medium.mdx",
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
        --============================================--
        NewSkillData('ASQB', {
            name            = "spider queen bile",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_UNIQUE,
            sound = { pack = { "Units\\Creeps\\Spider\\SpiderYes1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 0.,
                    cooldown            = 7.3,
                    animation           = 3,
                    animation_point     = 0.7,
                    animation_backswing = 0.3,
                    animation_scale     = 2.,
                    missile             = "MSQB",
                    effect_on_caster        = "Spell\\Sweep_Acid_Small.mdx",
                    effect_on_caster_point  = 'weapon',
                    effect_on_caster_scale  = 2.2,
                }
            }
        })
        --============================================--
        NewSkillData('ASQC', {
            name            = "spider queen bite",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\Spider\\SpiderYesAttack1.wav", "Units\\Creeps\\Spider\\SpiderYesAttack2.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 200.,
                    resource_cost       = 0.,
                    cooldown            = 5.3,
                    animation           = 4,
                    animation_point     = 0.7,
                    animation_backswing = 0.3,
                    animation_scale     = 1.8,
                    effect              = "ECSC",
                    effect_on_caster        = "Spell\\Sweep_Chaos_Small.mdx",
                    effect_on_caster_point  = 'weapon',
                    effect_on_caster_scale  = 2.2,
                }
            }
        })
        --============================================--
        NewSkillData('ASQT', {
            name            = "spider queen trap",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 12.,
                    animation           = 6,
                    animation_point     = 0.4,
                    animation_backswing = 0.3,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('ASQS', {
            name            = "spider queen brood",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            sound = { pack = { "Units\\Creeps\\Spider\\SpiderYes2.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 6.,
                    animation           = 6,
                    animation_point     = 0.4,
                    animation_backswing = 0.3,
                    animation_scale     = 1.2,
                }
            }
        })
        --============================================--
        NewSkillData('ABCH', {
            name            = "bandit charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 5.3,
                    resource_cost       = 0.,
                    animation           = 4,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    animation_scale     = 0.9,
                }
            }
        })
        --============================================--
        NewSkillData('AACL', {
            name            = "arachno bite",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 215.,
                    resource_cost       = 0.,
                    cooldown            = 5.3,
                    animation           = 2,
                    animation_point     = 0.566,
                    animation_backswing = 0.35,
                    animation_scale     = 1.75,
                    effect              = "EACL",
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand right", scale = 1.5 },
                            { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", scale = 1.5 }
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('AAPN', {
            name            = "arachno poison nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav" }, volume = 128, cutoff = 1500.},

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 8.,
                    animation           = 2,
                    animation_point     = 0.667,
                    animation_backswing = 0.4,
                    animation_scale     = 1.9,
                    effect              = "EACL",
                    effect_on_caster        = "Spell\\Sweep_Acid_Small.mdx",
                    effect_on_caster_point  = 'weapon',
                    effect_on_caster_scale  = 2.25,
                }
            }
        })
        --============================================--
        NewSkillData('AACH', {
            name            = "arachno charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            --sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 9.,
                    resource_cost       = 0.,
                    animation           = 4,
                    animation_point     = 0.6,
                    animation_backswing = 0.1,
                    animation_scale     = 0.9,
                }
            }
        })
        --============================================--
        NewSkillData('ASSM', {
            name            = "summon skele",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                    animation           = 4,
                    animation_point     = 0.5,
                    animation_backswing = 0.45,
                    animation_scale     = 1.2,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "hand right", scale = 1.25 },
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('ASBN', {
            name            = "chasing curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Abilities\\Spells\\Undead\\Possession\\PossessionMissileLaunch1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 550.,
                    resource_cost       = 0.,
                    cooldown            = 5.,
                    animation           = 4,
                    animation_point     = 0.5,
                    animation_backswing = 0.45,
                    animation_scale     = 1.65,
                    missile             = "MSCN",
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Soul_Medium.mdx", point = "hand right", scale = 1.25 },
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('AMLN', {
            name            = "meph nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 5.,
                    resource_cost       = 0.,
                    animation           = 8,
                    animation_point     = 0.445,
                    animation_backswing = 0.555,
                    animation_scale     = 1.25,
                }
            }
        })
        --============================================--
        NewSkillData('AQBC', {
            name            = "boar charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\QuillBeast\\QuillBoarYes1.wav", "Units\\Creeps\\QuillBeast\\QuillBoarYes2.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 0.,
                    animation           = 3,
                    animation_point     = 0.35,
                    animation_backswing = 0.01,
                    animation_scale     = 1.15,
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "weapon", scale = 1.25 },
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('AWRG', {
            name            = "wolf rage",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 17.,
                    resource_cost       = 0.,
                    animation           = 3,
                    animation_point     = 0.933,
                    animation_backswing = 0.734,
                    animation_scale     = 0.8,
                }
            }
        })
        --============================================--
        NewSkillData('AGHS', {
            name            = "ghoul cut",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 9.,
                    resource_cost       = 0.,
                    animation           = 3,
                    animation_point     = 0.466,
                    animation_backswing = 0.367,
                    animation_scale     = 1.1,
                    effect = "EGHC",
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", scale = 1.25 },
                        }
                    },
                }
            }
        })
        --============================================--
        NewSkillData('AHBA', {
            name            = "hell beast antimagic",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                    animation           = 3,
                    animation_point     = 0.6,
                    animation_backswing = 0.4,
                    animation_scale     = 1.15,
                    effect = "EHBA",
                    sfx_pack = {
                        on_caster = {
                            { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", scale = 1.25 },
                            { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.25 },
                        }
                    },
                }
            }
        })
         --============================================--
        NewSkillData('AABS', {
            name            = "abo slam",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 0.,
                    animation           = 8,
                    animation_point     = 0.01,
                    animation_backswing = 0.01,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('ANRA', {
            name            = "necro reanim",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 0.,
                    animation           = 8,
                    animation_point     = 0.01,
                    animation_backswing = 0.01,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('ABLB', {
            name            = "vampire bite",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 0.,
                    animation           = 8,
                    animation_point     = 0.01,
                    animation_backswing = 0.01,
                    animation_scale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('ASKB', {
            name            = "ske mage blast",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 0.,
                    animation           = 8,
                    animation_point     = 0.01,
                    animation_backswing = 0.01,
                    animation_scale     = 1.,
                }
            }
        })
    end