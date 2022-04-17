do


    SkillsData           = 0
    SkillList            = 0
    local MaxSkillLevels = 10

    -- target types
    SELF_CAST               = 0
    TARGET_CAST             = 1
    POINT_CAST              = 2
    POINT_AND_TARGET_CAST   = 3

    SKILL_PHYSICAL = 1
    SKILL_MAGICAL = 2
    SKILL_UNIQUE = 3

    SKILL_CLASS_ATTACK = 1
    SKILL_CLASS_SUPPORT = 2
    SKILL_CLASS_UTILITY = 3


    SKILL_CATEGORY_LIGHTNING = 1
    SKILL_CATEGORY_ICE = 2
    SKILL_CATEGORY_FIRE = 3
    SKILL_CATEGORY_ARCANE = 4

    SKILL_CATEGORY_FIGHTING_MASTERY = 5
    SKILL_CATEGORY_BATTLE_ADVANTAGE = 6
    SKILL_CATEGORY_INNER_STRENGTH = 7

    SKILL_CATEGORY_DARK_ART = 8
    SKILL_CATEGORY_CURSES = 9
    SKILL_CATEGORY_SUMMONING = 10

    SKILL_CATEGORY_NAME = 0
    SKILL_CATEGORY_ICON = 0
    CLASS_SKILL_CATEGORY = 0


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
            timescale         = 0.,
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

            if skill.charges_delta then
                skill.level[lvl].charges = (skill.level[1].charges or 0) + math.floor(lvl / (skill.charges_delta_level or 1.)) * skill.charges_delta
                if skill.level[lvl].charges < 0 then skill.level[lvl].charges = 0 end
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
            classification          = SKILL_CLASS_ATTACK,
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

        DefineAnimationData()

        SkillsData           = {}
        SkillList            = {}


        SKILL_CATEGORY_ICON = {
            [SKILL_CATEGORY_LIGHTNING] = "GUI\\BTNLightning Mastery.blp",
            [SKILL_CATEGORY_FIRE] = "GUI\\BTNFireMastery.blp",
            [SKILL_CATEGORY_ICE] = "GUI\\BTNWaterMastery.blp",
            [SKILL_CATEGORY_ARCANE] = "GUI\\BTNAstral Blessing.blp",
            [SKILL_CATEGORY_FIGHTING_MASTERY] = "GUI\\BTN_CR_HOLDINGGROUND.blp",
            [SKILL_CATEGORY_BATTLE_ADVANTAGE] = "GUI\\BTN_cr_Warp3.blp",
            [SKILL_CATEGORY_INNER_STRENGTH] = "GUI\\BTN_cr_HOLYllllcharge.blp",
            [SKILL_CATEGORY_DARK_ART] = "GUI\\BTNNecromancy.blp",
            [SKILL_CATEGORY_CURSES] = "GUI\\BTNFhtagn2.blp",
            [SKILL_CATEGORY_SUMMONING] = "GUI\\BTNNecromancy2.blp",
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
            },
            [NECROMANCER_CLASS] = {
                SKILL_CATEGORY_DARK_ART,
                SKILL_CATEGORY_CURSES,
                SKILL_CATEGORY_SUMMONING
            }
        }

        SKILL_CATEGORY_NAME = {
            [SKILL_CATEGORY_LIGHTNING] = LOCALE_LIST[my_locale].SKILL_CATEGORY_LIGHTNING_ADVANCED,
            [SKILL_CATEGORY_FIRE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_FIRE_ADVANCED,
            [SKILL_CATEGORY_ICE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_ICE_ADVANCED,
            [SKILL_CATEGORY_ARCANE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_ARCANE_ADVANCED,
            [SKILL_CATEGORY_FIGHTING_MASTERY] = LOCALE_LIST[my_locale].SKILL_CATEGORY_FIGHTING_MASTERY_ADVANCED,
            [SKILL_CATEGORY_BATTLE_ADVANTAGE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_BATTLE_ADVANTAGE_ADVANCED,
            [SKILL_CATEGORY_INNER_STRENGTH] = LOCALE_LIST[my_locale].SKILL_CATEGORY_INNER_STRENGTH_ADVANCED,
            [SKILL_CATEGORY_DARK_ART] = LOCALE_LIST[my_locale].SKILL_CATEGORY_DARK_ART_ADVANCED,
            [SKILL_CATEGORY_CURSES] = LOCALE_LIST[my_locale].SKILL_CATEGORY_CURSES_ADVANCED,
            [SKILL_CATEGORY_SUMMONING] = LOCALE_LIST[my_locale].SKILL_CATEGORY_SUMMONING_ADVANCED,
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
                    timescale     = 0.5,
                },
                [7] = {
                    missile             = 'M001',
                    effect              = 'EFF1',
                    cooldown            = 5.,
                    animation           = 3,
                    animation_point     = 1.5,
                    animation_backswing = 0.1666,
                    timescale     = 0.5,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.25,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MFRB',
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'EFRN',
                    resource_cost       = 10.,
                    cooldown            = 10.,
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
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.25, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MGFB',
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.85,
            },
            sfx_pack = {
                on_caster = {
                    --{ effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon" },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 20.,
                    cooldown            = 6.,
                }
            }
        })
        --============================================--
        NewSkillData('ABLZ', {
            name            = LOCALE_LIST[my_locale].SKILL_BLIZZARD,
            icon            = "Spell\\BTNFreezeField.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            sound = { pack = { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav" }, volume = 117, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.85,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 18.,
                    cooldown            = 10.,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.9,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice High.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice High.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MFRO',
                    from_unit           = true,
                    resource_cost       = 14.,
                    cooldown            = 0.3,
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
            animation = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 1.35, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    effect              = 'ELST',
                    resource_cost       = 24.,
                    cooldown            = 0.3,
                    --animation           = 2,
                    --animation_point     = 1.1,
                    --animation_backswing = 0.3,
                    --timescale     = 0.7,
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
            sound = { pack = { "Sounds\\Spells\\teleport.wav" }, volume = 112, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_blink"), timescale = 0.33,
            },
            range_delta = 5.,
            range_delta_level = 1,
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    range = 300.,

                    start_effect_on_cast_point = 'Spell\\Blink Blue Caster.mdx',
                    start_effect_on_cast_point_scale = 1.,

                    resource_cost       = 5.,
                    cooldown            = 5.,

                }
            }
        })
        --============================================--
        NewSkillData('AFRW', {
            name            = LOCALE_LIST[my_locale].SKILL_FIRE_WAVE,
            icon            = "Spell\\BTNFirewall.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            sound = { pack = { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav" }, volume = 117, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 1.4,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 14.,
                    cooldown            = 5.,
                }
            }
        })
        --============================================--
        NewSkillData('A00F', {
            name            = LOCALE_LIST[my_locale].SKILL_METEOR,
            icon            = "Spell\\BTNRainOfFire.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            sound = { pack = { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav" }, volume = 117, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.8,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Uber.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 1000.,
                    effect              = 'EMTR',
                    resource_cost       = 20.,
                    cooldown            = 7.,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.48,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon" }, { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    --animation           = 2,
                    --animation_point     = 1.3,
                    --animation_backswing = 0.3,
                    --timescale     = 0.6,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    --{ effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = {  } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 870.,
                    resource_cost       = 13.,
                    cooldown            = 3.,
                    --animation           = 2,
                    --animation_point     = 1.3,
                    --animation_backswing = 0.3,
                    --timescale     = 0.6,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" }, { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }, { effect = "Spell\\Storm Cast.mdx", point = 'hand left' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 900.,
                    resource_cost       = 25.,
                    missile             = 'MBLB',
                    from_unit           = true,
                    cooldown            = 11.,
                    --animation           = 3,
                    --animation_point     = 2.1,
                    --animation_backswing = 0.633,
                    --timescale     = 0.5,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdx", point = "origin", scale = 0.4, permanent = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect             = 'EFCS',
                    resource_cost       = 5.,
                    cooldown            = 25.,
                    --animation           = 3,
                    --animation_point     = 0.3,
                    --animation_backswing = 0.3,
                    --timescale     = 1.,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\ShivasEnchantment.mdx", point = "origin", duration = 1.233 }, { effect = "Spell\\ColdRitual.mdx", point = "origin", permanent = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect             = 'EFAR',
                    resource_cost       = 5.,
                    cooldown            = 20.,
                }
            }
        })
        --============================================--
        NewSkillData('A00H', {
            name            = LOCALE_LIST[my_locale].SKILL_ELEMENTALMASTERY,
            icon            = "Spell\\BTN_cr_Dark Arts.blp",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            category        = SKILL_CATEGORY_ARCANE,
            animation       = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.95, },
            sfx_pack = {
                on_caster = {
                    { effect = "Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdx", point = "origin", duration = 1.233 }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect             = 'EEMA',
                    resource_cost       = 5.,
                    cooldown            = 20.,
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
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.45,
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 600.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
                    effect_on_caster        = "Spell\\Fire Low.mdx",
                    effect_on_caster_point  = 'hand right',
                    effect_on_caster_scale  = 1.,
                    end_effect_on_cast_point = "Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeTarget.mdx",
                    end_effect_on_cast_point_scale = 0.5,
                }
            }
        })
        --============================================--
        NewSkillData('ASIR', {
            name            = LOCALE_LIST[my_locale].SKILL_ICICLERAIN,
            icon            = "Spell\\BTNRainFall.BLP",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_ICE,
            sound = { pack = { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav" }, volume = 110, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.43,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Ice High.mdx", point = 'hand right' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 750.,
                    resource_cost       = 21.,
                    cooldown            = 12.,
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
            classification = SKILL_CLASS_UTILITY,
            range_delta = 3.,
            range_delta_level = 1,
            animation = { sequence  = GetAnimationSequence("barb_jump"), timescale = 1., },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    range               = 300.,
                    cooldown            = 12.,
                    resource_cost       = 5.,
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
            animation = { sequence = GetAnimationSequence("barb_spell_throw"), timescale = 1.1 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MTHK',
                    from_unit           = true,
                    resource_cost       = 5.,
                    cooldown            = 12.,
                    charges = 2,
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
            animation = {
                sequence = GetAnimationSequence("barb_spell_punch"), timescale = 1.1
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EUPP',
                    cooldown            = 12.,
                    animation           = 5,
                    animation_point     = 0.6,
                    animation_backswing = 0.3,
                    timescale     = 0.7,
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
            classification = SKILL_CLASS_SUPPORT,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.8
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'EBRS',
                    resource_cost       = 10.,
                    cooldown            = 22.,
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
            animation = {
                sequence  = GetAnimationSequence("barb_whirlwind"), timescale = 1.,
            },

            level = {
                [1] = {
                    cooldown = 0.3,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON, FIST_WEAPON },
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
            sound = { pack = { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = {
                sequence = GetAnimationSequence("barb_swing_1"), timescale = 1.2
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Spell\\TrueStrike.mdx", plane_offset = 70., height = 80., roll = 45., appear_delay = 0.61, animation_time_influence = true, scale = 2.2,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Spell\\TrueStrike.mdx", plane_offset = 60., height = 75., roll = -225., appear_delay = 0.57, animation_time_influence = true, scale = 2.,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Spell\\TrueStrike.mdx", plane_offset = 60., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 1.8,
                    conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECRH',
                    cooldown            = 5.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON, FIST_WEAPON },
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
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 128, cutoff = 1500., delay = 0.3},
            animation = { sequence = GetAnimationSequence("barb_swing_1"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Spell\\BasicStrike_Red.mdx", plane_offset = 70., height = 80., roll = 225., appear_delay = 0.61, animation_time_influence = true, scale = 1.4,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Spell\\BasicStrike_Red.mdx", plane_offset = 60., height = 75., roll = -45., appear_delay = 0.57, animation_time_influence = true, scale = 1.2,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Spell\\BasicStrike_Red.mdx", plane_offset = 60., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 1.,
                    conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EEXC',
                    cooldown            = 6.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON, FIST_WEAPON },
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
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("barb_spell_throw"), timescale = 0.8 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 600.,
                    missile             = 'MBCH',
                    from_unit           = true,
                    resource_cost       = 6,
                    cooldown            = 2.3,
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
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 120, cutoff = 1500., delay = 0.3 },
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1.1 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Blood_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECSL',
                    cooldown            = 7.3,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
                }
            }
        })
        --============================================--
        NewSkillData('ASHG', {
            name            = LOCALE_LIST[my_locale].SKILL_SHATTERGROUND,
            icon            = "Spell\\BTN_cr_VeeR9.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            sound = { pack = { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 120, cutoff = 1500.},
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1.25 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 400.,
                    missile             = "MSHG",
                    cooldown            = 14.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
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
            classification = SKILL_CLASS_SUPPORT,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.9
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    effect              = 'EWCR',
                    resource_cost       = 5,
                    cooldown            = 22.,
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
            classification = SKILL_CLASS_SUPPORT,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.6
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'EBFA',
                    resource_cost       = 3.,
                    cooldown            = 30.,
                }
            }
        })
        --============================================--
        NewSkillData('ANRD', {
            name            = LOCALE_LIST[my_locale].SKILL_RAISE_DEAD,
            icon            = "Spell\\BTNDullahan1.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_SUMMONING,
            sound = { pack = { "Sounds\\Spells\\revivecast.wav" }, volume = 115, cutoff = 1500., delay = 0.35 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.75,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            custom_condition = function(caster)
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            classification = SKILL_CLASS_UTILITY,
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 14.,
                    cooldown            = 1.,
                }
            }
        })

        --============================================--
        NewSkillData('ANLR', {
            name            = LOCALE_LIST[my_locale].SKILL_LICH_RITUAL,
            icon            = "Spell\\BTNEArthLich.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_SUMMONING,
            sound = { pack = { "Sounds\\Spells\\revivecast.wav" }, volume = 115, cutoff = 1500., delay = 0.35 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.75,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            custom_condition = function(caster)
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 2 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            classification = SKILL_CLASS_UTILITY,
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 14.,
                    cooldown            = 6.,
                }
            }
        })

        --============================================--
        NewSkillData('ANBR', {
            name            = LOCALE_LIST[my_locale].SKILL_RIP_BONES,
            icon            = "Spell\\BTNGalvanize.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav" }, volume = 128, cutoff = 1500., delay = 0.2 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.5,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                },
                on_terrain = {
                    { effect = "Spell\\model (467).mdx", scale = 0.6, appear_delay = 0.15, animation_time_influence = true, random_orientation_angle = true  }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 14.,
                    cooldown            = 12.,
                }
            }
        })

        --============================================--
        NewSkillData('ANBP', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_PRISON,
            icon            = "Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\bonecast.wav" }, volume = 115, cutoff = 1500., delay = 0.35 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.63,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'ENBP',
                    resource_cost       = 10.,
                    cooldown            = 11.,
                    range               = 600.,
                }
            }
        })

        --============================================--
        NewSkillData('ANBS', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_SPEAR,
            icon            = "Spell\\BTN_Bonespear.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\bonespear1.wav", "Sounds\\Spells\\bonespear2.wav", "Sounds\\Spells\\bonespear3.wav" }, volume = 125, cutoff = 1500., delay = 0.45 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    missile             = 'MNBS',
                    resource_cost       = 7.,
                    cooldown            = 0.3,
                    range               = 800.,
                }
            }
        })

        --============================================--
        NewSkillData('ANTS', {
            name            = LOCALE_LIST[my_locale].SKILL_TOXIC_SPIT,
            icon            = "Spell\\BTNPoisonTouch.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_DARK_ART,
            classification  = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\poison_cast_1.wav", "Sounds\\Spells\\poison_cast_2.wav", "Sounds\\Spells\\poison_cast_3.wav" }, volume = 125, cutoff = 1500., delay = 0.23 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 0.9,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    missile             = 'MNPS',
                    resource_cost       = 5.,
                    cooldown            = 0.3,
                    range               = 800.,
                }
            }
        })

        --============================================--
        NewSkillData('ANBB', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_BARRAGE,
            icon            = "Spell\\BTNImpale2.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\teethlaunch1.wav", "Sounds\\Spells\\teethlaunch2.wav", "Sounds\\Spells\\teethlaunch3.wav" }, volume = 121, cutoff = 1500., delay = 0.21 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 9.,
                    range               = 800.,
                }
            }
        })

        --============================================--
        NewSkillData('ANPB', {
            name            = LOCALE_LIST[my_locale].SKILL_POISON_BLAST,
            icon            = "Spell\\BTN_PlagueNova.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\poisonnova.wav" }, volume = 121, cutoff = 1500. },
            animation = {
                sequence = GetAnimationSequence("necro_spell_throw"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = 'right hand' },
                },
                on_terrain = {
                    { effect = "Effect\\Nether Blast IV.mdx", animation_time_influence = true, timescale = 1.11 },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 20.,
                    cooldown            = 14.,
                }
            }
        })

        --============================================--
        NewSkillData('ANDV', {
            name            = LOCALE_LIST[my_locale].SKILL_DEVOUR,
            icon            = "Spell\\BTNDevour.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_SUMMONING,
            classification = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav" }, volume = 130, cutoff = 1500., delay = 0.15 },
            animation = {
                sequence = GetAnimationSequence("necro_spell_slam"), timescale = 0.8,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Medium.mdx", point = 'right hand' },
                }
            },
            custom_condition = function(caster)
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 20.,
                    cooldown            = 15.,
                }
            }
        })

        --============================================--
        NewSkillData('ANCE', {
            name            = LOCALE_LIST[my_locale].SKILL_CORPSE_EXPLOSION,
            icon            = "Spell\\BTN_BShrapnel.BLP",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\corpseexplodecast.wav" }, volume = 117, cutoff = 1500., delay = 0.45 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 0.8,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            custom_condition = function(caster, x, y)
                if CountNearbyCorpses(x, y, GetOwningPlayer(caster), 300.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 25.,
                    cooldown            = 10.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANUL', {
            name            = LOCALE_LIST[my_locale].SKILL_UNDEAD_LAND,
            icon            = "Spell\\BTNNecroGrip2.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_CURSES,
            classification = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\necro_cast_sharp_1.wav", "Sounds\\Spells\\necro_cast_sharp_2.wav", "Sounds\\Spells\\necro_cast_sharp_3.wav", "Sounds\\Spells\\necro_cast_sharp_4.wav" }, volume = 120, cutoff = 1500., delay = 0.15 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 15.,
                    cooldown            = 25.,
                }
            }
        })

        --============================================--
        NewSkillData('ANWK', {
            name            = LOCALE_LIST[my_locale].SKILL_WEAKEN,
            icon            = "Spell\\BTNBloody Stab.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\cursecast.wav" }, volume = 120, cutoff = 1500., delay = 0.4 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'ENWK',
                    resource_cost       = 15.,
                    cooldown            = 15.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANDF', {
            name            = LOCALE_LIST[my_locale].SKILL_DECREPIFY,
            icon            = "Spell\\BTNBreathOfTheDying.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\cursecast.wav" }, volume = 120, cutoff = 1500., delay = 0.4 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'ENDC',
                    resource_cost       = 15.,
                    cooldown            = 15.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANFR', {
            name            = LOCALE_LIST[my_locale].SKILL_HORRIFY,
            icon            = "Spell\\BTNDread.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\cursecast.wav" }, volume = 120, cutoff = 1500., delay = 0.4 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.82,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = "ENHF",
                    resource_cost       = 25.,
                    cooldown            = 24.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANGS', {
            name            = LOCALE_LIST[my_locale].SKILL_GROW_SPIKES,
            icon            = "Spell\\BTNCR_Spiked_Armor.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_DARK_ART,
            classification  = SKILL_CLASS_SUPPORT,
            sound = { pack = { "Sounds\\Spells\\bonearmor2.wav" }, volume = 120, cutoff = 1500., delay = 0.2 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.5,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 15.,
                    cooldown            = 17.,
                }
            }
        })

        --============================================--
        NewSkillData('ANUC', {
            name            = LOCALE_LIST[my_locale].SKILL_UNHOLY_COMMAND,
            icon            = "Spell\\BTNSkeletal_Hand.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\necro_cast_sharp_1.wav", "Sounds\\Spells\\necro_cast_sharp_2.wav", "Sounds\\Spells\\necro_cast_sharp_3.wav", "Sounds\\Spells\\necro_cast_sharp_4.wav" }, volume = 120, cutoff = 1500., delay = 0.15 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 12.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANDR', {
            name            = LOCALE_LIST[my_locale].SKILL_DARK_REIGN,
            icon            = "Spell\\BTNReanimate66.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_UTILITY,
            sound = { pack = { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav" }, volume = 130, cutoff = 1500., delay = 0.15 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 0.65,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                    { effect = "Effect\\WarpDarkCaster.mdx", point = "origin", duration = 1., animation_time_influence = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 30.,
                    cooldown            = 22.,
                }
            }
        })

        --============================================--
        NewSkillData('ANHV', {
            name            = LOCALE_LIST[my_locale].SKILL_HARVEST,
            icon            = "Spell\\BTNCursedScythe.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_DARK_ART,
            classification  = SKILL_CLASS_ATTACK,
            sound = { pack = { "Sounds\\Spells\\reversevampire.wav" }, volume = 120, cutoff = 1500., delay = 0.1 },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw"), timescale = 1.1,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = 'right hand' },
                },
                on_terrain = {
                    { effect = "Spell\\SoulScythe.mdx", plane_offset = 20., height = 125., appear_delay = 0., animation_time_influence = true, appear_delay = 0.2, timescale = 1.45, scale = 1.55, permanent = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect = "ENHV",
                    resource_cost       = 6.,
                    cooldown            = 8.,
                    range = 200.,
                }
            }
        })

        --============================================--
        NewSkillData('ASQB', {
            name            = "spider queen bile",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_UNIQUE,
            sound = { pack = { "Units\\Creeps\\Spider\\SpiderYes1.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence = GetAnimationSequence("spider_venom_bile"), timescale     = 2.,
            },

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 0.,
                    cooldown            = 7.3,
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
            animation = {
                sequence = GetAnimationSequence("spider_bite"), timescale     = 1.8,
            },

            level = {
                [1] = {
                    range               = 200.,
                    resource_cost       = 0.,
                    cooldown            = 5.3,
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
            animation = {
                sequence  = GetAnimationSequence("spider_spell"), timescale = 1.,
            },

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 12.,
                }
            }
        })
        --============================================--
        NewSkillData('ASQS', {
            name            = "spider queen brood",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            sound = { pack = { "Units\\Creeps\\Spider\\SpiderYes2.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("spider_spell"), timescale = 1.2,
            },

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 6.,
                }
            }
        })
        --============================================--
        NewSkillData('ABCH', {
            name            = "bandit charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence = GetAnimationSequence("bandit_charge"), timescale     = 0.9,
            },

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 5.3,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AACL', {
            name            = "arachno bite",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("arachno_bite"), timescale = 1.75,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand right", scale = 1.5 },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", scale = 1.5 }
                }
            },

            level = {
                [1] = {
                    range               = 215.,
                    resource_cost       = 0.,
                    cooldown            = 5.3,
                    effect = "EACL",
                }
            }
        })
        --============================================--
        NewSkillData('AAPN', {
            name            = "arachno poison nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav" }, volume = 128, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("arachno_spell"), timescale = 1.9,
            },

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 8.,
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
            animation = {
                sequence  = GetAnimationSequence("arachno_charge"), timescale = 0.9,
            },
            --sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 9.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ASSM', {
            name            = "summon skele",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = {
                sequence  = GetAnimationSequence("skele_boss_spell"), timescale = 1.2,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "hand right", scale = 1.25 },
                }
            },
            --sound = { pack = { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ASBN', {
            name            = "chasing curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Abilities\\Spells\\Undead\\Possession\\PossessionMissileLaunch1.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("skele_boss_spell"), timescale = 1.65,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Soul_Medium.mdx", point = "hand right", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    range               = 550.,
                    resource_cost       = 0.,
                    cooldown            = 5.,
                    missile             = "MSCN",
                }
            }
        })
        --============================================--
        NewSkillData('AMLN', {
            name            = "meph nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Sounds\\Spell\\mephisto_cast2.wav", "Sounds\\Spell\\mephisto_cast3.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("meph_spell"), timescale = 1.75,
            },

            level = {
                [1] = {
                    cooldown            = 5.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AQBC', {
            name            = "boar charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Creeps\\QuillBeast\\QuillBoarYes1.wav", "Units\\Creeps\\QuillBeast\\QuillBoarYes2.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("boar_charge"), timescale = 1.15,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "weapon", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AWRG', {
            name            = "wolf rage",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("wolf_spell"), timescale = 0.8,
            },

            level = {
                [1] = {
                    cooldown            = 17.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AGHS', {
            name            = "ghoul cut",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
            animation = { sequence  = GetAnimationSequence("ghoul_spell"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", scale = 1.5 },
                },
                on_terrain = {
                    --{ effect = "Spell\\Reaper's Claws Red.mdx", plane_offset = 55., height = 65., roll = 315., appear_delay = 0.21, animation_time_influence = true, scale = 0.75, timescale = 1.1 },
                    { effect = "Spell\\Ephemeral Slash Red.mdx", plane_offset = 55., height = 65., roll = -45., appear_delay = 0.26, animation_time_influence = true, scale = 0.75, timescale = 0.7 },
                }
            },

            --Spell\Reaper's Claws Red.mdx

            level = {
                [1] = {
                    cooldown            = 9.,
                    resource_cost       = 0.,
                    effect = "EGHC",
                }
            }
        })
        --============================================--
        NewSkillData('AHBA', {
            name            = "hell beast antimagic",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            animation = {
                sequence  = GetAnimationSequence("hellbeast_spell"), timescale = 1.15,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", scale = 1.25 },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.25 },
                }
            },
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                    effect = "EHBA",
                }
            }
        })
        --============================================--
        NewSkillData('AVDS', {
            name            = "void disc",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
            animation = { sequence  = GetAnimationSequence("voidvalker_spell"), timescale = 1.35, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.3, permanent = true }, { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", scale = 1.3, permanent = true } }
            },


            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AVDR', {
            name            = "void rain",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            --sound = { pack = { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
            animation = { sequence  = GetAnimationSequence("voidvalker_spell"), timescale = 1.5, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.5, permanent = true }, { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", scale = 1.5, permanent = true } }
            },


            level = {
                [1] = {
                    cooldown            = 17.,
                    resource_cost       = 0.,
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
                    timescale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('ANRA', {
            name            = "necro reanim",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("necro_spell_channel"), timescale = 1.5, },
            --sfx_pack = {
                --on_caster = { { effect = "Spell\\Darkness High.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Darkness High.mdx", point = "hand right", permanent = true } }
            --},
            sound = { pack = { "Units\\Undead\\Necromancer\\NecromancerYes3.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AFRD', {
            name            = "frost drop",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("ghost_spell"), timescale = 1.25, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Ice High.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Ice High.mdx", point = "hand right", permanent = true } }
            },
            sound = { pack = { "Units\\Creeps\\BansheeGhost\\BansheeGhostYesAttack1.wav", "Units\\Creeps\\BansheeGhost\\BansheeGhostYesAttack2.wav" }, volume = 120, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 7.,
                    effect = "EFRD",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AAPB', {
            name            = "poison barrage",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = { pack = { "Sounds\\Spell\\andariel_castsmall.wav" }, volume = 123, cutoff = 1500., delay = 0.4 },
            animation = { sequence  = GetAnimationSequence("andariel_spell_throw"), timescale = 1.9, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Acid_Small.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Sweep_Acid_Small.mdx", point = "hand right" } }
            },

            level = {
                [1] = {
                    cooldown            = 7.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABSS', {
            name            = "summon tentacle ",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = { pack = { "Sounds\\Spell\\baal_summon.wav" }, volume = 123, cutoff = 1500. },
            animation = { sequence  = GetAnimationSequence("baal_spell"), timescale = 1.45, },

            level = {
                [1] = {
                    cooldown            = 6.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ASKC', {
            name            = "ske mage curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("skeleton_mage_spell"), timescale = 1.45, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Blight_Medium.mdx", point = "hand right", permanent = true } }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    effect              = "ESKC",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ACNF', {
            name            = "conflagrate",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("sorceress_spell"), timescale = 1.5, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", scale = 1.5, permanent = true }, effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", scale = 1.5, permanent = true }
            },

            level = {
                [1] = {
                    cooldown            = 14.,
                    effect              = "conflagrate_effect",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AFRR', {
            name            = "fire rain",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("sorceress_spell"), timescale = 1.25, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", permanent = true }, effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", permanent = true }
            },

            level = {
                [1] = {
                    cooldown            = 10.,
                    --effect              = "conflagrate_effect",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ARLR', {
            name            = "lightning laser",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("revenant_spell"), timescale = 1.45, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" } }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    missile             = "MRLR",
                    resource_cost       = 0.,
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
                    timescale     = 1.,
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
                    timescale     = 1.,
                }
            }
        })
        --============================================--
        NewSkillData('AGEN', {
            name            = "gnoll ensnare",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            animation = { sequence  = GetAnimationSequence("gnoll_archer_spell"), timescale = 1.45, },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", permanent = true } }
            },

            level = {
                [1] = {
                    cooldown            = 15.,
                    missile             = "ensnare_missile",
                    resource_cost       = 0.,
                }
            }
        })

        DefineTalentsData()
    end

end