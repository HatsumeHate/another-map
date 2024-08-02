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

    SKILL_CATEGORY_COMBAT_SKILLS = 11
    SKILL_CATEGORY_FAITH = 12
    SKILL_CATEGORY_HOLY_DOCTRINE = 13

    SKILL_CATEGORY_LETHALITY = 14
    SKILL_CATEGORY_SHADOWS = 15
    SKILL_CATEGORY_BOW = 16
    SKILL_CATEGORY_GEAR = 17

    SKILL_CATEGORY_NAME = 0
    SKILL_CATEGORY_ICON = 0
    CLASS_SKILL_CATEGORY = 0

    PROJECTION_TYPE_ARC = 1
    PROJECTION_TYPE_AREA = 2
    PROJECTION_TYPE_ARROW = 3


    ---@param id integer
    ---@return string
    function GetSkillName(id)
        local skill = SkillsData[FourCC(id)]
        if skill == nil then return "unnamed skill" end
        return skill.name
    end

    function GetSkillCategoryName(category)
        return SKILL_CATEGORY_NAME[category] or "unnamed category"
    end

    ---@param unit unit
    ---@param id string
    ---@return table
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
            proc_rate = 1.
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

            if skill.proc_rate_delta then
                skill.level[lvl].proc_rate = (skill.level[1].proc_rate or 0) + math.floor(lvl / (skill.proc_rate_delta_level or 1.)) * skill.proc_rate_delta
                --if skill.level[lvl].proc_rate > 1. then skill.level[lvl].proc_rate = 1. end
            end

            skill.level[lvl].generated = true
            --print("GenerateSkillLevelData - gen done")
        end
    end

    ---@param skillId integer
    ---@param data table
    function NewSkillData(skillId, data)

        if SkillsData[FourCC(skillId)] then
            print("override detected - " .. skillId)
        end

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
            [SKILL_CATEGORY_COMBAT_SKILLS] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_FAITH] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_HOLY_DOCTRINE] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_LETHALITY] = "GUI\\BTNBackstab2.blp",
            [SKILL_CATEGORY_SHADOWS] = "GUI\\BTN1462810141.blp",
            [SKILL_CATEGORY_BOW] = "ReplaceableTextures\\CommandButtons\\BTNMarksmanship.blp",
            [SKILL_CATEGORY_GEAR] = "GUI\\BTNMechanism.blp",
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
            },
            [PALADIN_CLASS] = {
                SKILL_CATEGORY_COMBAT_SKILLS,
                SKILL_CATEGORY_FAITH,
                SKILL_CATEGORY_HOLY_DOCTRINE
            },
            [ASSASSIN_CLASS] = {
                SKILL_CATEGORY_LETHALITY,
                SKILL_CATEGORY_SHADOWS,
                SKILL_CATEGORY_BOW,
                SKILL_CATEGORY_GEAR
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
            [SKILL_CATEGORY_COMBAT_SKILLS] = LOCALE_LIST[my_locale].SKILL_CATEGORY_COMBAT_SKILLS_ADVANCED,
            [SKILL_CATEGORY_FAITH] = LOCALE_LIST[my_locale].SKILL_CATEGORY_FAITH_ADVANCED,
            [SKILL_CATEGORY_HOLY_DOCTRINE] = LOCALE_LIST[my_locale].SKILL_CATEGORY_HOLY_DOCTRINE_ADVANCED,
            [SKILL_CATEGORY_LETHALITY] = LOCALE_LIST[my_locale].SKILL_CATEGORY_LETHALITY_ADVANCED,
            [SKILL_CATEGORY_SHADOWS] = LOCALE_LIST[my_locale].SKILL_CATEGORY_SHADOWS_ADVANCED,
            [SKILL_CATEGORY_BOW] = LOCALE_LIST[my_locale].SKILL_CATEGORY_BOW_ADVANCED,
            [SKILL_CATEGORY_GEAR] = LOCALE_LIST[my_locale].SKILL_CATEGORY_GEAR_ADVANCED,
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
            icon            = "Spell\\BTNFrostBolt3.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            sound = {
                { "Sounds\\Spells\\FrostBolt_Cast_Form_1.wav", "Sounds\\Spells\\FrostBolt_Cast_Form_2.wav", "Sounds\\Spells\\FrostBolt_Cast_Form_3.wav", "Sounds\\Spells\\FrostBolt_Cast_Form_4.wav", volume = 205, cutoff = 1600., delay = 0.1 },
                { "Sounds\\Spells\\FrostBolt_CastPre_Crack_1.wav", "Sounds\\Spells\\FrostBolt_CastPre_Crack_2.wav", "Sounds\\Spells\\FrostBolt_CastPre_Crack_3.wav", "Sounds\\Spells\\FrostBolt_CastPre_Crack_4.wav", volume = 205, cutoff = 1600., delay = 0.25 },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.25, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MFRB',
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    proc_rate           = 1.
                },
            }

        })
        --============================================--
        NewSkillData('A001', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTNOVA,
            icon            = "Spell\\BTNfrost_nova.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            sound = {
                { "Sounds\\Spells\\FrostNova_Cast_1.wav", "Sounds\\Spells\\FrostNova_Cast_2.wav", "Sounds\\Spells\\FrostNova_Cast_3.wav", volume = 235, cutoff = 1600. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 1., },
            sfx_pack = {
                on_caster = {
                    { effect = "Effect\\FrostHands.mdx", point = 'hand right' },
                    { effect = "Effect\\FrostHands.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'EFRN',
                    resource_cost       = 10.,
                    cooldown            = 10.,
                    proc_rate           = 0.5
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
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\fire_light_launch_1.wav", "Sounds\\Spells\\fire_light_launch_2.wav", "Sounds\\Spells\\fire_light_launch_3.wav", volume = 117, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.25, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    missile             = 'MGFB',
                    from_unit           = true,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    proc_rate           = 1.
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
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.33 },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 1. },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.8,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand left' }
                }
            },
            projection = {
                type = PROJECTION_TYPE_ARROW,
                missile = "MMLT"
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 20.,
                    cooldown            = 6.,
                    proc_rate           = 1.
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
            sound = {
                { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 117, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.85,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand left' }
                }
            },
            projection = {
                type = PROJECTION_TYPE_AREA,
                effect = "EBLZ"
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 18.,
                    cooldown            = 10.,
                    proc_rate           = 0.5
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
            sound = {
                { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 110, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 1.3 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.57,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice High.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice High.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MFRO',
                    from_unit           = true,
                    resource_cost       = 14.,
                    cooldown            = 1.5,
                    proc_rate           = 1.
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
            sound = {
                { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 110, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.5 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 1.3, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    effect              = 'ELST',
                    resource_cost       = 24.,
                    cooldown            = 1.5,
                    proc_rate           = 0.7
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
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\teleport.wav" }, volume = 112, cutoff = 1500.},
            animation = {
                sequence  = GetAnimationSequence("sorc_blink"), timescale = 0.33,
            },
            custom_condition = function(caster)
                if not IsUnitRooted(caster) then return true
                else
                    SimError(GetLocalString("Вы обездвижены", "You are rooted"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA },
            range_delta = 5.,
            range_delta_level = 1,
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


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
            sound = {
                { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                }
            },
            projection = {
                type = PROJECTION_TYPE_ARC,
                angle_window = 30.,
                area_of_effect = 700.
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 15.,
                    cooldown            = 3.,
                    proc_rate           = 0.7
                }
            }
        })
        --============================================--
        NewSkillData('AFWL', {
            name            = LOCALE_LIST[my_locale].SKILL_FIRE_WALL,
            icon            = "Spell\\BTNopr001BA.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            sound = {
                { "Sounds\\Spells\\Firewall_Cast_1.wav", "Sounds\\Spells\\Firewall_Cast_2.wav", "Sounds\\Spells\\Firewall_Cast_3.wav", "Sounds\\Spells\\Firewall_Cast_4.wav", volume = 128, cutoff = 1600. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Low.mdx", point = 'hand right' }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    resource_cost       = 14.,
                    cooldown            = 1.,
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
            sound = {
                { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Heavy_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Heavy_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 0.36 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.6,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Fire Uber.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    effect              = 'EMTR',
                    resource_cost       = 20.,
                    cooldown            = 8.,
                    proc_rate           = 0.5
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
            sound = {
                { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 120, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 0.92,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon" }, { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            projection = {
                type = PROJECTION_TYPE_ARC,
                angle_window = 45.,
                angle_window_delta = 7.5,
                angle_window_delta_level = 10,
                area_of_effect = 800.
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
                    proc_rate           = 1.
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
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 120, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 870.,
                    resource_cost       = 15.,
                    cooldown            = 1.5,
                    proc_rate           = 1.
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
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav", volume = 120, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
                { "Sound\\Sorceress\\Wizard_Gasp_Heavy_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Heavy_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 1.4 },
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.8,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" }, { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }, { effect = "Spell\\Storm Cast.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 900.,
                    resource_cost       = 25.,
                    missile             = 'MBLB',
                    from_unit           = true,
                    cooldown            = 11.,
                    proc_rate           = 0.33
                }
            }
        })
        --============================================--
        NewSkillData('ALSP', {
            name            = LOCALE_LIST[my_locale].SKILL_LIGHTNING_SPEAR,
            icon            = "Spell\\BTNicons_11465_btn.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav", volume = 120, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
                on_cast_end = { "Sounds\\Spells\\static1.wav", "Sounds\\Spells\\static2.wav.wav", "Sounds\\Spells\\static3.wav", "Sounds\\Spells\\static4.wav", volume = 115, cutoff = 1500. }
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    resource_cost       = 17.,
                    missile             = "lightning_spear_missile",
                    cooldown            = 4.,
                    proc_rate           = 0.75
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
            classification = SKILL_CLASS_SUPPORT,
            sound = {  { "Sounds\\Spells\\focus_cast_1.wav", "Sounds\\Spells\\focus_cast_2.wav", "Sounds\\Spells\\focus_cast_3.wav", volume = 120, cutoff = 1500.}, },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.85,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdx", point = "origin", scale = 0.4, permanent = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect             = 'EFCS',
                    resource_cost       = 25.,
                    cooldown            = 12.,
                }
            }
        })
        --============================================--
        NewSkillData('A00E', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTARMOR,
            icon            = "Spell\\BTN_AuraCloak_Ice.blp",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            category        = SKILL_CATEGORY_ICE,
            classification = SKILL_CLASS_SUPPORT,
            sound = {  { "Sounds\\Spells\\frost_armor_launch_2.wav", volume = 110, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\ShivasEnchantment.mdx", point = "origin", duration = 1.233 }, { effect = "Spell\\ColdRitual.mdx", point = "origin", permanent = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect             = 'EFAR',
                    resource_cost       = 10.,
                    cooldown            = 12.,
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
            classification = SKILL_CLASS_SUPPORT,
            animation       = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 0.75, },
            sfx_pack = {
                on_caster = {
                    { effect = "Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdx", point = "origin", duration = 1.233 }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect             = 'EEMA',
                    resource_cost       = 20.,
                    cooldown            = 14.,
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
            classification = SKILL_CLASS_ATTACK,
            autotrigger = false,
            sound = {
                { "Sounds\\Spells\\Hydra_Cast_1.wav", "Sounds\\Spells\\Hydra_Cast_2.wav", "Sounds\\Spells\\Hydra_Cast_3.wav", volume = 128, cutoff = 1600. },
                on_cast_end = { "Sounds\\Spells\\Hydra_CastAtHydra_1.wav", "Sounds\\Spells\\Hydra_CastAtHydra_2.wav", "Sounds\\Spells\\Hydra_CastAtHydra_3.wav", volume = 128, cutoff = 1600. },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.35, },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 600.,
                    cooldown            = 6.,
                    resource_cost       = 12.,
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
            icon            = "Spell\\BTNIcicle.blp",--"Spell\\BTNRainFall.BLP",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_ICE,
            sound = {
                { "Sounds\\Spells\\IcicleRain_Cast_1.wav", "Sounds\\Spells\\IcicleRain_Cast_2.wav", "Sounds\\Spells\\IcicleRain_Cast_3.wav", volume = 150, cutoff = 1500., delay = 0.15 },
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.23, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Effect\\FrostHands.mdx", point = 'hand right' },
                }
            },
            projection = {
                type = PROJECTION_TYPE_AREA,
                area_of_effect = 250.,
                area_of_effect_delta = 5.,
                area_of_effect_delta_level = 1
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            cooldown_delta = 0.1,
            cooldown_delta_level = 1,

            level = {
                [1] = {
                    range               = 750.,
                    resource_cost       = 13.,
                    cooldown            = 3.5,
                    proc_rate           = 0.75
                }
            }
        })
        --============================================--
        NewSkillData('ASSU', {
            name            = LOCALE_LIST[my_locale].SKILL_SURGE,
            icon            = "Spell\\BTNElectricStrike.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("sorc_spell_empower"), timescale = 0.6 },
            sound = {
                { "Sounds\\Spells\\Surge_pre_1.wav", "Sounds\\Spells\\Surge_pre_2.wav", "Sounds\\Spells\\Surge_pre_3.wav", volume = 150, cutoff = 1500. },
                on_cast_end = { "Sounds\\Spells\\Surge_1.wav", "Sounds\\Spells\\Surge_2.wav", "Sounds\\Spells\\Surge_3.wav", volume = 150, cutoff = 1600. },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand left' },
                },
                on_terrain = {
                    { effect = "Effect\\RollingStormSFX.mdx", duration = 1.7 }
                }
            },

            level = {
                [1] = {
                    effect              = 'effect_surge',
                    resource_cost       = 14,
                    cooldown            = 13.,
                }
            }
        })
        --============================================--
        NewSkillData('ASSF', {
            name            = LOCALE_LIST[my_locale].SKILL_STATIC_FIELD,
            icon            = "Spell\\BTNLightningSphereBlue.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_LIGHTNING,
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("sorc_spell_empower"), timescale = 0.85 },
            sound = {
                { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav", volume = 130, cutoff = 1700. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.5 },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "overhead" },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand left' },
                },
            },

            level = {
                [1] = {
                    effect              = 'effect_static_field',
                    resource_cost       = 17,
                    cooldown            = 10.,
                }
            }
        })
        --============================================--
        NewSkillData('ASFS', {
            name            = LOCALE_LIST[my_locale].SKILL_FLAME_SHROUD,
            icon            = "Spell\\BTNFlameCloak.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\FlameShield_1.wav", "Sounds\\Spells\\FlameShield_2.wav", volume = 150, cutoff = 1500. }, },
            animation = { sequence = GetAnimationSequence("sorc_spell_empower"), timescale = 0.7 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Fire Uber.mdx", point = 'hand right' },
                    { effect = "Spell\\Fire Uber.mdx", point = 'hand left' },
                }
            },

            level = {
                [1] = {
                    effect              = 'effect_flame_shroud',
                    resource_cost       = 16,
                    cooldown            = 12.,
                }
            }
        })
        --============================================--
        NewSkillData('ASEF', {
            name            = LOCALE_LIST[my_locale].SKILL_ENFLAME,
            icon            = "Spell\\BTNSw_FireSword3.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FIRE,
            classification = SKILL_CLASS_UTILITY,
            sound = {
                { "Sounds\\Spells\\firecast.wav", volume = 128, cutoff = 1500. },
                on_cast_end  = { "Sounds\\Spells\\enchant.wav", volume = 128, cutoff = 1500. }, },
            animation = { sequence = GetAnimationSequence("sorc_spell_empower"), timescale = 0.55 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Effect\\FireHands.mdx", point = 'hand right' },
                    { effect = "Effect\\FireHands.mdx", point = 'hand left' },
                }
            },

            level = {
                [1] = {
                    resource_cost       = 12,
                    cooldown            = 8.,
                }
            }
        })
        --============================================--
        NewSkillData('AARF', {
            name            = LOCALE_LIST[my_locale].SKILL_ARCANE_RIFT,
            icon            = "Spell\\BTNrunes-magenta-2.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ARCANE,
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("sorc_spell_empower"), timescale = 0.65 },
            sound = {
                { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 110, cutoff = 1500. },
                { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.5 },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Effect\\DarkHands.mdx", point = 'hand right', permanent = true },
                    { effect = "Effect\\DarkHands.mdx", point = 'hand left', permanent = true },
                },
            },
            projection = {
                type = PROJECTION_TYPE_AREA,
                area_of_effect = 500.,
            },

            level = {
                [1] = {
                    resource_cost       = 25,
                    cooldown            = 15.,
                }
            }
        })
        --============================================--
        NewSkillData('AARC', {
            name            = LOCALE_LIST[my_locale].SKILL_ARCANE_BARRAGE,
            icon            = "Spell\\BTNicons_12696_btn.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ARCANE,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Sorceress\\Wizard_Gasp_Light_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Light_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_twohanded"), timescale = 1.2, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Effect\\DarkHands.mdx", point = 'hand right', permanent = true },
                    { effect = "Effect\\DarkHands.mdx", point = 'hand left', permanent = true },
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    resource_cost       = 14.,
                    cooldown            = 3.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('APRF', {
            name            = LOCALE_LIST[my_locale].SKILL_PERMAFROST,
            icon            = "Spell\\BTNjakiroice2.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\frosbolt_launch_1.wav", "Sounds\\Spells\\frosbolt_launch_2.wav", volume = 128, cutoff = 1500., delay = 0.25 },
                on_cast_end = { "Sound\\Sorceress\\Wizard_Gasp_Medium_1.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_2.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_3.wav", "Sound\\Sorceress\\Wizard_Gasp_Medium_4.wav", volume = 150, cutoff = 1500. },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "weapon", conditional_weapon = { FIST_WEAPON } },
                    { effect = "Effect\\FrostHands.mdx", point = 'hand right', permanent = true },
                    { effect = "Effect\\FrostHands.mdx", point = 'hand left', permanent = true },
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 600., radius = 150. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 600.,
                    resource_cost       = 16.,
                    cooldown            = 6.,
                    proc_rate           = 0.75
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
            custom_condition = function(caster)
                if not IsUnitRooted(caster) then return true
                else
                    SimError(GetLocalString("Вы обездвижены", "You are rooted"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA },
            sound = {  { "Sounds\\Spells\\leap1.wav", "Sounds\\Spells\\leap2.wav", "Sounds\\Spells\\leap3.wav", volume = 115, cutoff = 1500. }, },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


            level = {
                [1] = {
                    range               = 300.,
                    cooldown            = 9.,
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
            sound = {  { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.33 }, },
            animation = { sequence = GetAnimationSequence("barb_spell_throw"), timescale = 0.75 },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MTHK',
                    from_unit           = true,
                    resource_cost       = 5.,
                    cooldown            = 7.,
                    charges             = 2,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('ABUP', {
            name            = LOCALE_LIST[my_locale].SKILL_UPPERCUT,
            icon            = "Spell\\BTNContusing Punch.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            always_max_range_cast = true,
            sound = {
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500. },
                { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.33 },
            },
            animation = {
                sequence = GetAnimationSequence("barb_spell_punch"), timescale = 1.05
            },
            motion = {
                power = 45,
                time = 0.3,
                delay = 0.33
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EUPP',
                    cooldown            = 7.,
                    resource_cost       = 7.,
                    proc_rate           = 0.5
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
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.45 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'EBRS',
                    resource_cost       = 15.,
                    cooldown            = 13.,
                }
            }
        })
        --============================================--
        NewSkillData('A010', {
            name            = LOCALE_LIST[my_locale].SKILL_WHIRLWIND,
            icon            = "Spell\\BTNwhirl.blp",--"Spell\\BTNicons_13168_btn.blp","Spell\\BTNHot Wirlwind.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            channel = true,
            animation = {
                sequence  = GetAnimationSequence("barb_whirlwind"), timescale = 1.,
            },
            projection = { type = PROJECTION_TYPE_AREA, effect = "EWHW" },
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON, FIST_WEAPON },

            level = {
                [1] = {
                    cooldown            = 0.3,
                    proc_rate           = 0.5
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
            always_max_range_cast = true,
            sound = {
                { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },
                { "Sound\\Barbarian\\Barbarian_Gasp_Medium_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Medium_2.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = {
                sequence = GetAnimationSequence("barb_swing_1"), timescale = 1.1
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
            motion = {
                power = 70,
                time = 0.4,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECRH',
                    cooldown            = 2.,
                    resource_cost       = 5.,
                    proc_rate           = 0.8
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
            always_max_range_cast = true,
            sound = {
                { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\skill_swing_crack_1.wav", "Sounds\\Spells\\skill_swing_crack_2.wav", "Sounds\\Spells\\skill_swing_crack_3.wav", "Sounds\\Spells\\skill_swing_crack_4.wav", volume = 128, cutoff = 1500., delay = 0.3 },
            },
            animation = { sequence = GetAnimationSequence("barb_swing_1"), timescale = 0.9 },
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
            motion = {
                power = 50,
                time = 0.4,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EEXC',
                    cooldown            = 2.,
                    resource_cost       = 4.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('A00A', {
            name            = LOCALE_LIST[my_locale].SKILL_HARPOON,
            icon            = "Spell\\BTNHookChain.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("barb_spell_throw"), timescale = 0.8 },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 500., radius = 75. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 500.,
                    resource_cost       = 8,
                    cooldown            = 7.,
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
            always_max_range_cast = true,
            sound = {
                { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.21 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 120, cutoff = 1500., delay = 0.3 },
            },
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Blood_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                }
            },
            motion = {
                power = 55,
                time = 0.4,
                delay = 0.33
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECSL',
                    cooldown            = 3.,
                    resource_cost       = 5.,
                    proc_rate           = 0.75
                }
            }
        })
        --============================================--
        NewSkillData('ASHG', {
            name            = LOCALE_LIST[my_locale].SKILL_SHATTERGROUND,
            icon            = "Spell\\BTNshatter.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            sound = {
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 120, cutoff = 1500. },
                { "Sound\\Barbarian\\Barbarian_Gasp_Heavy_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Heavy_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1.15 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                }
            },
            motion = {
                power = 50,
                time = 0.38,
                delay = 0.33
            },
            projection = { type = PROJECTION_TYPE_ARC, angle_window = 70., area_of_effect = 570. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    range               = 400.,
                    missile             = "MSHG",
                    cooldown            = 12.,
                    resource_cost       = 15.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('ABWC', {
            name            = LOCALE_LIST[my_locale].SKILL_WARCRY,
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,
            classification = SKILL_CLASS_SUPPORT,
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.6 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_terrain = {
                    {
                        effect = "Effect\\barbarian_shout_clean.mdx",
                        height = 120.,
                        appear_delay = 0.8,
                        permanent = true
                    },
                }
            },

            level = {
                [1] = {
                    effect              = 'EWCR',
                    resource_cost       = 8,
                    cooldown            = 14.,
                }
            }
        })
        --============================================--
        NewSkillData('ABRC', {
            name            = LOCALE_LIST[my_locale].SKILL_RALLYING_CRY,
            icon            = "Spell\\BTNrallying cry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,
            classification = SKILL_CLASS_SUPPORT,
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.55 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
             sfx_pack = {
                on_terrain = {
                    {
                        effect = "Effect\\barbarian_shout_mixed.mdx",
                        height = 120.,
                        appear_delay = 0.8,
                        permanent = true
                    },
                }
            },

            level = {
                [1] = {
                    effect              = 'effect_rallying_cry',
                    resource_cost       = 10,
                    cooldown            = 11.,
                }
            }
        })
        --============================================--
        NewSkillData('ABFA', {
            name            = LOCALE_LIST[my_locale].SKILL_FIRSTAID,
            icon            = "Spell\\BTNBlood (6).blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,
            classification = SKILL_CLASS_SUPPORT,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.54
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'EBFA',
                    resource_cost       = 10.,
                    cooldown            = 18.,
                }
            }
        })
        --============================================--
        NewSkillData('ADBS', {
            name            = LOCALE_LIST[my_locale].SKILL_DOUBLESTRIKE,
            icon            = "Spell\\BTNDoubleStrike.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.4 },
                { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence = GetAnimationSequence("barb_swing_3"), timescale = 0.75
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\[TX]LTSMN_R.mdx", plane_offset = 50., height = 80., roll = 135., appear_delay = 0.61, animation_time_influence = true, scale = 0.6,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Effect\\[TX]LTSMN_R.mdx", plane_offset = 40., height = 75., roll = -225., appear_delay = 0.57, animation_time_influence = true, scale = 0.5,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\[TX]LTSMN_R.mdx", plane_offset = 30., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 0.4,
                    conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'effect_double_strike',
                    cooldown            = 2.,
                    resource_cost       = 7.,
                    proc_rate           = 0.75
                }
            }
        })
        --============================================--
        NewSkillData('ABRV', {
            name            = LOCALE_LIST[my_locale].SKILL_RAVAGE,
            icon            = "Spell\\BTN128.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_FIGHTING_MASTERY,
            sound = {
                { "Sound\\Barbarian\\Barbarian_Gasp_Light_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Light_3.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("barb_spell_swing"), timescale = 0.8 },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 500. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 12.,
                    proc_rate           = 0.5
                }
            }
        })
        --============================================--
        NewSkillData('ABTR', {
            name            = LOCALE_LIST[my_locale].SKILL_TREMBLE,
            icon            = "Spell\\BTNTremble.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            sound = {
                { "Sound\\Barbarian\\Barbarian_Gasp_Heavy_1.wav", "Sound\\Barbarian\\Barbarian_Gasp_Heavy_2.wav", "Sound\\Barbarian\\Barbarian_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 0.37 },
                { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },
            },
            animation = { sequence = GetAnimationSequence("barb_spell_swing_vertical"), timescale = 1.3 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            always_max_range_cast = true,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                },
                on_terrain = {
                    { effect = "Spell\\TrueStrike.mdx", plane_offset = 70., height = 100., roll = 90., appear_delay = 0.51, animation_time_influence = true, scale = 2.6,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Spell\\TrueStrike.mdx", plane_offset = 60., height = 90., roll = 90., appear_delay = 0.45, animation_time_influence = true, scale = 2.3,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                }
            },
            motion = {
                power = 35,
                time = 0.4,
                delay = 0.36
            },
            required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },

            level = {
                [1] = {
                    effect = "effect_tremble",
                    range               = 200.,
                    cooldown            = 4.,
                    resource_cost       = 12.,
                    proc_rate           = 0.7
                }
            }
        })
        --============================================--
        NewSkillData('ABCA', {
            name            = LOCALE_LIST[my_locale].SKILL_CALL_OF_THE_ANCIENTS,
            icon            = "Spell\\BTNKotL.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,
            classification = SKILL_CLASS_SUPPORT,
            sound = {  { "Sounds\\Spells\\CallOfTheAncients_Cast_1.wav", "Sounds\\Spells\\CallOfTheAncients_Cast_2.wav", "Sounds\\Spells\\CallOfTheAncients_Cast_3.wav", volume = 158, cutoff = 1500. },  },
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.75 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 8,
                    cooldown            = 14.,
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
            sound = {  { "Sounds\\Spells\\revivecast.wav", volume = 115, cutoff = 1500., delay = 0.35 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_rise"), timescale = 1.1,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            custom_condition = function(caster)
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 600. },
            classification = SKILL_CLASS_UTILITY,
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            minions = true,

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
            sound = {
                { "Sounds\\Spells\\revivecast.wav", volume = 115, cutoff = 1500., delay = 0.35 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_rise"), timescale = 1.23,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            custom_condition = function(caster)
                local skill = GetUnitSkillData(caster, "ANLR")

                    if skill.summoned_group and BlzGroupGetSize(skill.summoned_group) > 0 then
                        return true
                    else
                        if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 2 then return true
                        else
                            SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                            return false
                        end
                    end

            end,
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 700. },
            classification = SKILL_CLASS_UTILITY,
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            minions = true,

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
            sound = {
                { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav", volume = 128, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.4 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 1.2,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Spell\\model (467).mdx", scale = 0.6, appear_delay = 0.15, animation_time_influence = true, random_orientation_angle = true  }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 450. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 14.,
                    cooldown            = 12.,
                    proc_rate           = 0.5
                }
            }
        })

        --============================================--
        NewSkillData('ANBP', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_PRISON,
            icon            = "Spell\\BTNBonePrison.blp",--"Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_CURSES,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\bonecast.wav", volume = 115, cutoff = 1500., delay = 0.35 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.37 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_air"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'ENBP',
                    resource_cost       = 15.,
                    cooldown            = 12.,
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
            sound = {
                { "Sounds\\Spells\\Bone_Spear_Cast_start_1.wav", "Sounds\\Spells\\Bone_Spear_Cast_start_2.wav", "Sounds\\Spells\\Bone_Spear_Cast_start_3.wav", volume = 135, cutoff = 1500. },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
                on_cast_end = { "Sounds\\Spells\\bonespear1.wav", "Sounds\\Spells\\bonespear2.wav", "Sounds\\Spells\\bonespear3.wav", volume = 125, cutoff = 1500. },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_medium"), timescale = 1.1,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    missile             = 'MNBS',
                    resource_cost       = 7.,
                    cooldown            = 0.3,
                    range               = 800.,
                    proc_rate           = 1.
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
            short_name = true,
            sound = {
                { "Sounds\\Spells\\poison_cast_1.wav", "Sounds\\Spells\\poison_cast_2.wav", "Sounds\\Spells\\poison_cast_3.wav", volume = 125, cutoff = 1500., delay = 0.23 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 0.9, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    missile             = 'MNPS',
                    resource_cost       = 5.,
                    cooldown            = 0.3,
                    range               = 800.,
                    proc_rate           = 1.
                }
            }
        })

        --============================================--
        NewSkillData('ANBB', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_BARRAGE,
            icon            = "Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\teethlaunch1.wav", "Sounds\\Spells\\teethlaunch2.wav", "Sounds\\Spells\\teethlaunch3.wav", volume = 121, cutoff = 1500., delay = 0.21 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 1. },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_big"), timescale = 0.58,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARC, angle_window = 70, area_of_effect = 550. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 9.,
                    range               = 800.,
                    proc_rate           = 0.44
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
            sound = {
                { "Sounds\\Spells\\poisonnova.wav", volume = 126, cutoff = 1500. },
                { "Sound\\Necromancer\\Necromancer_Gasp_Heavy_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_4.wav", volume = 150, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence = GetAnimationSequence("necro_spell_slam"), timescale = 1.2,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\Acid Ex.mdx", animation_time_influence = true, timescale = 0.6, permanent = true, scale = 2. },
                    { effect = "Effect\\Nether Blast IV.mdx", animation_time_influence = true, timescale = 1.11 },
                }
            },
            projection = { type = PROJECTION_TYPE_AREA, effect = "ENPB" },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 20.,
                    cooldown            = 10.,
                    proc_rate           = 0.33
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
            sound = {
                { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav", volume = 130, cutoff = 1500., delay = 0.15 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence = GetAnimationSequence("necro_spell_rise"), timescale = 1.18,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Blood_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Blood_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            custom_condition = function(caster)
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 600. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 20.,
                    cooldown            = 12.,
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
            sound = {
                { "Sounds\\Spells\\corpseexplodecast.wav", volume = 117, cutoff = 1500., delay = 0.45 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Medium_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Medium_4.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_air"), timescale = 1.1,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            custom_condition = function(caster, x, y)
                if CountNearbyCorpses(x, y, GetOwningPlayer(caster), 300.) > 0 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 25.,
                    cooldown            = 3.,
                    range               = 700.,
                    proc_rate           = 0.75
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
            sound = {
                { "Sounds\\Spells\\necro_cast_sharp_1.wav", "Sounds\\Spells\\necro_cast_sharp_2.wav", "Sounds\\Spells\\necro_cast_sharp_3.wav", "Sounds\\Spells\\necro_cast_sharp_4.wav", volume = 120, cutoff = 1500., delay = 0.15 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Heavy_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_3.wav", "Sound\\Necromancer\\Necromancer_Gasp_Heavy_4.wav", volume = 150, cutoff = 1500., delay = 0.45 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_rise"), timescale = 1.2,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 475., area_of_effect_delta = 25., area_of_effect_delta_level = 3 },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

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
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = {
                { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.14,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'ENWK',
                    resource_cost       = 15.,
                    cooldown            = 4.,
                    range               = 700.,
                }
            }
        })

        --============================================--
        NewSkillData('ANDF', {
            name            = LOCALE_LIST[my_locale].SKILL_DECREPIFY,
            icon            = "Spell\\BTNBreathOfTheDying.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = {
                { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.08, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Black_Frost_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Black_Frost_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Black_Frost_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'ENDC',
                    resource_cost       = 15.,
                    cooldown            = 4.,
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
            sound = {
                { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_big"), timescale = 0.68,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = "ENHF",
                    resource_cost       = 25.,
                    cooldown            = 14.,
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
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_SUPPORT,
            sound = {
                { "Sounds\\Spells\\bonearmor2.wav", volume = 120, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 1.1, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 15.,
                    cooldown            = 12.,
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
            sound = {  { "Sounds\\Spells\\necro_cast_sharp_1.wav", "Sounds\\Spells\\necro_cast_sharp_2.wav", "Sounds\\Spells\\necro_cast_sharp_3.wav", "Sounds\\Spells\\necro_cast_sharp_4.wav", volume = 120, cutoff = 1500., delay = 0.15 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 0.9,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 8.,
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
            sound = {  { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav", volume = 130, cutoff = 1500., delay = 0.15  }, },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_air"), timescale = 1.15,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true },
                    { effect = "Effect\\WarpDarkCaster.mdx", point = "origin", duration = 1., animation_time_influence = true }
                }
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 30.,
                    cooldown            = 14.,
                }
            }
        })
        --============================================--
        NewSkillData('ANHV', {
            name            = LOCALE_LIST[my_locale].SKILL_HARVEST,
            icon            = "Spell\\BTNicons_harvest.blp",--"Spell\\BTNCursedScythe.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sounds\\Spells\\reversevampire.wav", volume = 120, cutoff = 1500., delay = 0.1 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Spell\\SoulScythe.mdx", plane_offset = 20., height = 125., appear_delay = 0., animation_time_influence = true, appear_delay = 0.2, timescale = 1.45, scale = 1.55, permanent = true, remove_on_recast = false }
                }
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect = "ENHV",
                    resource_cost       = 6.,
                    cooldown            = 8.,
                    range               = 200.,
                    proc_rate           = 0.75
                }
            }
        })
        --============================================--
        NewSkillData('ANWS', {
            name            = LOCALE_LIST[my_locale].SKILL_WANDERING_SPIRIT,
            icon            = "Spell\\BTNWSpirit.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\Bone_Spirit_Cast_start_1.wav", "Sounds\\Spells\\Bone_Spirit_Cast_start_2.wav", volume = 138, cutoff = 1600. },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
                on_cast_end = { "Sounds\\Spells\\Bone_Spirit_Cast_end_1.wav", "Sounds\\Spells\\Bone_Spirit_Cast_end_2.wav", volume = 138, cutoff = 1600. }
            },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_medium"), timescale = 1.25,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Black_Frost_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Black_Frost_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Black_Frost_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    missile             = 'MNWS',
                    resource_cost       = 5.,
                    cooldown            = 0.3,
                    range               = 800.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('ANBK', {
            name            = LOCALE_LIST[my_locale].SKILL_BONE_IMPALE,
            icon            = "Spell\\BTNBoneImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\teethlaunch1.wav", "Sounds\\Spells\\teethlaunch2.wav", "Sounds\\Spells\\teethlaunch3.wav", volume = 121, cutoff = 1500., delay = 0.21 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 1. },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_big"), timescale = 0.5, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 300. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 1.,
                    range               = 800.,
                    proc_rate           = 0.85
                }
            }
        })
        --============================================--
        NewSkillData('ANFD', {
            name            = LOCALE_LIST[my_locale].SKILL_FORCED_DECAY,
            icon            = "Spell\\BTNShadowSpell_3.blp",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\Decompose_Cast_1.wav", "Sounds\\Spells\\Decompose_Cast_2.wav", "Sounds\\Spells\\Decompose_Cast_3.wav", "Sounds\\Spells\\Decompose_Cast_4.wav", volume = 128, cutoff = 1600. },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.33 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 0.77, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 800. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 10.,
                    cooldown            = 6.,
                    range               = 800.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('ANTT', {
            name            = LOCALE_LIST[my_locale].SKILL_TORTURE,
            icon            = "Spell\\BTNTorture.blp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_UTILITY,
            sound = {
                { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.2 },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.08, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Blood_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Blood_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'torture_effect',
                    resource_cost       = 15.,
                    cooldown            = 4.,
                    range               = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ANRP', {
            name            = LOCALE_LIST[my_locale].SKILL_REAPER,
            icon            = "Spell\\BTNf9c1640f48f8.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\ReaperCast_1.wav", "Sounds\\Spells\\ReaperCast_2.wav", "Sounds\\Spells\\ReaperCast_3.wav", "Sounds\\Spells\\ReaperCast_4.wav", volume = 128, cutoff = 1500. },
                { "Sound\\Necromancer\\Necromancer_Gasp_Light_1.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_2.wav", "Sound\\Necromancer\\Necromancer_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.33 },
            },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 0.95, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\Soul Discharge Purple.mdx", plane_offset = 50., animation_time_influence = true, },
                }
            },

            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 650., radius = 100. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    resource_cost       = 20.,
                    cooldown            = 4.,
                    range               = 600.,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        NewSkillData('APRA', {
            name            = LOCALE_LIST[my_locale].SKILL_PRAYER,
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_HOLY_DOCTRINE,
            classification = SKILL_CLASS_SUPPORT,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 1.
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


            level = {
                [1] = {
                    --effect              = 'EWCR',
                    resource_cost       = 5,
                    cooldown            = 22.,
                }
            }
        })
        --============================================--
        NewSkillData('ASBA', {
            name            = LOCALE_LIST[my_locale].SKILL_SHIELDBASH,
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_COMBAT_SKILLS,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            animation = {
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 1.
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


            level = {
                [1] = {
                    --effect              = 'EWCR',
                    resource_cost       = 5,
                    cooldown            = 22.,
                }
            }
        })

        --============================================--
        NewSkillData('ACHA', {
            name            = LOCALE_LIST[my_locale].SKILL_CHASTISE,
            icon            = "Spell\\BTNWarCry.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_FAITH,
            classification = SKILL_CLASS_ATTACK,
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 1. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,


            level = {
                [1] = {
                    --effect              = 'EWCR',
                    resource_cost       = 5,
                    cooldown            = 22.,
                }
            }
        })
        -- ASSSASSIN SKILLS
        --============================================--
        -- each hit increases damage of the next attack ability
        NewSkillData('AACS', {
            name            = LOCALE_LIST[my_locale].SKILL_CURVED_STRIKE,
            icon            = "Spell\\BTNcurved_strike.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 1.27 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 1.45 },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing"), timescale = 0.4 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\AZ_PA_C.mdx", plane_offset = 65., height = 100., roll = -165., appear_delay = 1.55, animation_time_influence = true, scale = 0.55,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\AZ_PA_C.mdx", plane_offset = 65., height = 100., appear_delay = 1.55, animation_time_influence = true, scale = 0.45,
                        conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 0.5
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_curved_strike',
                    cooldown            = 1.,
                    resource_cost       = 5.,
                    proc_rate           = 1.
                }
            }
        })
        -- dash through enemies
        NewSkillData('AABR', {
            name            = LOCALE_LIST[my_locale].SKILL_BREAKTHROUGH,
            icon            = "Spell\\BTNbreakthrought.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.9 },
                { "Sounds\\Spells\\DashAttack_Lunge_1.wav", "Sounds\\Spells\\DashAttack_Lunge_2.wav" , volume = 150, cutoff = 1600. }
            },
            animation = { sequence = GetAnimationSequence("assassin_stab"), timescale = 0.35 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 500., radius = 75. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 400.,
                    cooldown            = 7.,
                    resource_cost       = 15.,
                    proc_rate           = 0.66
                }
            }
        })
        -- deal bonus damage from side or back
        NewSkillData('AABA', {
            name            = LOCALE_LIST[my_locale].SKILL_BACKSTAB,
            icon            = "Spell\\BTNbackstab.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 1. },
                { "Sound\\Assassin\\Assassin_Gasp_Heavy_1.wav", "Sound\\Assassin\\Assassin_Gasp_Heavy_2.wav","Sound\\Assassin\\Assassin_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 1.67 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 1.5 },
            },
            animation = { sequence = GetAnimationSequence("assassin_stab_2"), timescale = 0.33 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\BY_Wood_GongChengSiPai_405.mdx", plane_offset = 100., height = 75., roll = 0., appear_delay = 1.8, animation_time_influence = false, scale = 0.5,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 1.5
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_backstab',
                    cooldown            = 4.,
                    resource_cost       = 7.,
                    proc_rate           = 1.
                }
            }
        })
        -- throw 3 shurikens forward
        NewSkillData('AASH', {
            name            = LOCALE_LIST[my_locale].SKILL_SHURIKENS,
            icon            = "Spell\\BTNshurikens.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            sound = {  { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.8 } },
            animation = { sequence = GetAnimationSequence("assassin_throw"), timescale = 0.3 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "weapon", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 1000., radius = 70. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    cooldown            = 3.5,
                    resource_cost       = 6.,
                    proc_rate           = 1.
                }
            }
        })
        -- 3 quick strikes, each hits harder
        NewSkillData('AAEV', {
            name            = LOCALE_LIST[my_locale].SKILL_EVISCERATE,
            icon            = "Spell\\BTNeviscerate.blp",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.17 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.2},
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_combo_1"), timescale = 0.8 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\[TX]LTSMN_R2.mdx", plane_offset = 60., height = 75., roll = -175., appear_delay = 0.2, animation_time_influence = true, scale = 0.3,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\[TX]LTSMN_R2.mdx", plane_offset = 60., height = 75., appear_delay = 0.2, animation_time_influence = true, scale = 0.2,
                        conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_eviscerate',
                    cooldown            = 3.,
                    resource_cost       = 7.,
                    proc_rate           = 0.65
                }
            }
        })
        -- poisons enemies, slowing them down
        NewSkillData('AAVB', {
            name            = LOCALE_LIST[my_locale].SKILL_VIPER_BITE,
            icon            = "Spell\\BTNviper bite.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.27 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.33 },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_right_to_left"), timescale = 1.1 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                },
                on_terrain = {
                    { effect = "Spell\\Toxic Slash.mdx", plane_offset = 60., height = 80., roll = 145., appear_delay = 0.36, animation_time_influence = true, scale = 2.,
                      conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Spell\\Toxic Slash.mdx", plane_offset = 60., height = 80., roll = 145., appear_delay = 0.36, animation_time_influence = true, scale = 1.8,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_viper_bite',
                    cooldown            = 3.,
                    resource_cost       = 5.,
                    proc_rate           = 0.77
                }
            }
        })
        -- aoe damage around the assassin
        NewSkillData('AABF', {
            name            = LOCALE_LIST[my_locale].SKILL_BLADE_FLURRY,
            icon            = "ReplaceableTextures\\CommandButtons\\BTNFanOfKnives.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Medium_1.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_2.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_3.wav", volume = 150, cutoff = 1500., delay = 0.5 },
                { "Sounds\\Spells\\blade_shift_1.wav", "Sounds\\Spells\\blade_shift_2.wav", "Sounds\\Spells\\blade_shift_3.wav", volume = 128, cutoff = 1500., delay = 1. },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.44 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    effect              = 'effect_blade_flurry',
                    cooldown            = 5.,
                    resource_cost       = 15.,
                    proc_rate           = 0.66
                }
            }
        })
        -- mark enemies and make them vulnerable, attacking them gains attack speed
        NewSkillData('AATL', {
            name            = LOCALE_LIST[my_locale].SKILL_TARGET_LOCKED,
            icon            = "Spell\\BTNtarget locked.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_UTILITY,
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_empower"), timescale = 0.3 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand left", permanent = true }
                },
            },

            level = {
                [1] = {
                    range               = 500.,
                    effect              = 'effect_target_locked',
                    cooldown            = 12.,
                    resource_cost       = 15.,
                }
            }
        })
        -- resets all abilities cooldown, boosts moving speed and damage
        NewSkillData('AALL', {
            name            = LOCALE_LIST[my_locale].SKILL_LOCKED_AND_LOADED,
            icon            = "Spell\\BTNlocked and loaded.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_UTILITY,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.25 },
            },
            animation = { sequence = GetAnimationSequence("assassin_empower"), timescale = 0.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    cooldown            = 16.,
                    resource_cost       = 15.,
                }
            }
        })
        -- gives dodge, cc reduction, move speed
        NewSkillData('AANS', {
            name            = LOCALE_LIST[my_locale].SKILL_NIGHT_SHROUD,
            icon            = "Spell\\BTNDarkMantle.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_SUPPORT,
            sound = {  { "Sounds\\Spells\\shadows_buff_1.wav", "Sounds\\Spells\\shadows_buff_2.wav", "Sounds\\Spells\\shadows_buff_3.wav", "Sounds\\Spells\\shadows_buff_4.wav", volume = 115, cutoff = 1500., delay = 0.45 },  },
            animation = { sequence = GetAnimationSequence("assassin_empower"), timescale = 0.27 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 15.,
                }
            }
        })
        -- reduces enemies defence in aoe
        NewSkillData('AATW', {
            name            = LOCALE_LIST[my_locale].SKILL_TWILIGHT,
            icon            = "Spell\\BTNtwilight.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_UTILITY,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\shadows_buff_1.wav", "Sounds\\Spells\\shadows_buff_2.wav", "Sounds\\Spells\\shadows_buff_3.wav", "Sounds\\Spells\\shadows_buff_4.wav", volume = 115, cutoff = 1500., delay = 0.45 },
            },
            animation = { sequence = GetAnimationSequence("assassin_empower"), timescale = 0.33 },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 450. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            sfx_pack = {
                on_caster = {
                    { effect = "Effect\\DarkHands.mdx", point = "hand left", permanent = true },
                    { effect = "Effect\\DarkHands.mdx", point = "hand right", permanent = true }
                },
            },

            level = {
                [1] = {
                    aura = "twilight_aura",
                    cooldown            = 20.,
                    resource_cost       = 15.,
                    proc_rate           = 0.33
                }
            }
        })
        -- darkness damage, gain darkness bonus with every attack and then spend it all with skill
        NewSkillData('AABD', {
            name            = LOCALE_LIST[my_locale].SKILL_BLADE_OF_DARKNESS,
            icon            = "Spell\\BTNblade of darkness.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Medium_1.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_2.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_3.wav", volume = 150, cutoff = 1500., delay = 0.1 },
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.13 },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_combo_2"), timescale = 2.5 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\rb3.mdx", plane_offset = 70., height = 80., roll = 35., appear_delay = 0.13, animation_time_influence = true, scale = 2.2,
                        conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., roll = 35., appear_delay = 0.13, animation_time_influence = true, scale = 2.,
                        conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., appear_delay = 0.13, animation_time_influence = true, scale = 1.8,
                        conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_blade_of_darkness',
                    cooldown            = 4.,
                    resource_cost       = 5.,
                    proc_rate           = 1.
                }
            }
        })
        -- teleport behind, gain critical strike chance
        NewSkillData('AAST', {
            name            = LOCALE_LIST[my_locale].SKILL_SHADOWSTEP,
            icon            = "Spell\\BTNshadowstep.blp",
            activation_type = TARGET_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\Shadowstep_Vanish_1.wav", "Sounds\\Spells\\Shadowstep_Vanish_2.wav" , volume = 150, cutoff = 1500. }, },
            animation = { sequence = GetAnimationSequence("assassin_blink"), timescale = 0.8 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 8.,
                    resource_cost       = 15.,
                }
            }
        })
        -- strike with moderate damage, reduces enemies damage
        NewSkillData('AACB', {
            name            = LOCALE_LIST[my_locale].SKILL_CURSED_HIT,
            icon            = "Spell\\BTNDarkShaft.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.2 },
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.25 },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_combo_1"), timescale = 1.43 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\rb3.mdx", plane_offset = 70., height = 80., roll = -175., appear_delay = 0.2, animation_time_influence = true, scale = 2.,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., roll = -175., appear_delay = 0.2, animation_time_influence = true, scale = 1.8,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., appear_delay = 0.2, animation_time_influence = true, scale = 1.8,
                    conditional_weapon = { FIST_WEAPON }
                    }
                }
            },
            motion = {
                power = 25,
                time = 0.3,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_cursed_hit',
                    cooldown            = 3.,
                    resource_cost       = 8.,
                    proc_rate           = 0.8
                }
            }
        })
        -- throw two spinning blades that make 8 shaped movement
        NewSkillData('AADB', {
            name            = LOCALE_LIST[my_locale].SKILL_DANCING_BLADE,
            icon            = "Spell\\BTNdancing blade.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\chakram_throw_1.wav", "Sounds\\Spells\\chakram_throw_2.wav", "Sounds\\Spells\\chakram_throw_3.wav", volume = 128, cutoff = 1500., delay = 0.5 },
            },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.33 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 1000., radius = 80. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 1000.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
                    proc_rate           = 1.
                }
            }
        })
        -- throw a grenade, moderate damage and DOT
        NewSkillData('AAIG', {
            name            = LOCALE_LIST[my_locale].SKILL_INCENDIARY_GRENADE,
            icon            = "Spell\\BTNThe Bomb.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_ATTACK,
            short_name = true,
            sound = { { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.8 }, },
            animation = { sequence = GetAnimationSequence("assassin_throw"), timescale = 0.3 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 500.,
                    missile             = 'incendiary_grenade_missile',
                    cooldown            = 5.,
                    resource_cost       = 17.,
                    proc_rate           = 1.
                }
            }
        })
        -- aoe slowing aura
        NewSkillData('AACT', {
            name            = LOCALE_LIST[my_locale].SKILL_CALTROPS,
            icon            = "Spell\\BTNcaltrops.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_UTILITY,
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.5 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    cooldown            = 10.,
                    resource_cost       = 10.,
                }
            }
        })
        -- explodes upon stepping, aoe stun
        NewSkillData('AASC', {
            name            = LOCALE_LIST[my_locale].SKILL_SHOCKING_TRAP,
            icon            = "Spell\\BTNshocking trap.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_UTILITY,
            short_name = true,
            sound = {  { "Sounds\\Spells\\place_trap_1.wav", "Sounds\\Spells\\place_trap_2.wav", "Sounds\\Spells\\place_trap_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },  },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.5 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 300. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 18.,
                    proc_rate           = 0.5
                }
            }
        })
        -- explodes upon stepping, launches spinning blades in every direction
        NewSkillData('AABT', {
            name            = LOCALE_LIST[my_locale].SKILL_BLADE_TRAP,
            icon            = "Spell\\BTNblade trap.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\place_trap_1.wav", "Sounds\\Spells\\place_trap_2.wav", "Sounds\\Spells\\place_trap_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },  },
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.5 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 270. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 15.,
                    proc_rate           = 0.5
                }
            }
        })
        --============================================--
        -- aoe blind
        NewSkillData('AASB', {
            name            = LOCALE_LIST[my_locale].SKILL_SMOKE_BOMB,
            icon            = "Spell\\BTNSoulDischarge.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_UTILITY,
            sound = { { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.8 }, },
            animation = { sequence = GetAnimationSequence("assassin_throw"), timescale = 0.3 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'smoke_bomb_missile',
                    cooldown            = 12.,
                    resource_cost       = 9.,
                }
            }
        })
        --============================================--
        -- aoe damage
        NewSkillData('AARL', {
            name            = LOCALE_LIST[my_locale].SKILL_ROCKET_LAUNCHER,
            icon            = "Spell\\BTNrocket launcher.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'rocket_missile',
                    cooldown            = 5.,
                    resource_cost       = 5.,
                }
            }
        })
        --============================================--
        -- fast shot
        NewSkillData('AAPS', {
            name            = LOCALE_LIST[my_locale].SKILL_PRECISION_SALVO,
            icon            = "Spell\\BTNicons_12796_btn.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\PenetratingShot_Launch_1.wav", "Sounds\\Spells\\PenetratingShot_Launch_2.wav", "Sounds\\Spells\\PenetratingShot_Launch_3.wav", "Sounds\\Spells\\PenetratingShot_Launch_4.wav", "Sounds\\Spells\\PenetratingShot_Launch_5.wav" , volume = 128, cutoff = 1500., delay = 0.4 }, },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_fast_1"), timescale = 0.85 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Blood.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },
            separate_recharge = true,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'precision_arrow',
                    cooldown            = 3.,
                    resource_cost       = 5.,
                    charges             = 3,
                    from_unit           = true,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        -- expose for critical strike
        NewSkillData('AAEX', {
            name            = LOCALE_LIST[my_locale].SKILL_EXPOSE,
            icon            = "Spell\\BTNSunderingSpear.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.23 },
                { "Sounds\\Spells\\Forceful_Arrow_Cast_1.wav", "Sounds\\Spells\\Forceful_Arrow_Cast_2.wav", "Sounds\\Spells\\Forceful_Arrow_Cast_3.wav" , volume = 128, cutoff = 1500., delay = 0.},
                on_cast_end = { "Sounds\\Spells\\Forceful_Arrow_Launch_1.wav", "Sounds\\Spells\\Forceful_Arrow_Launch_2.wav", "Sounds\\Spells\\Forceful_Arrow_Launch_3.wav" , volume = 128, cutoff = 1500., delay = 0.45},
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_fast_2"), timescale = 1.1 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Void.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'expose_arrow',
                    cooldown            = 1.,
                    resource_cost       = 5.,
                    from_unit           = true,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        -- an arrow that splits to small arrows on hit
        NewSkillData('AACA', {
            name            = LOCALE_LIST[my_locale].SKILL_CLUSTER_SHOT,
            icon            = "Spell\\BTNCluster.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\Bow_Shot_1.wav", "Sounds\\Spells\\Bow_Shot_2.wav", "Sounds\\Spells\\Bow_Shot_3.wav", "Sounds\\Spells\\Bow_Shot_4.wav", "Sounds\\Spells\\Bow_Shot_5.wav", volume = 128, cutoff = 1500., delay = 0.2 },
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.35 },
                on_cast_end = { "Sounds\\Spells\\Forceful_Arrow_Launch_1.wav", "Sounds\\Spells\\Forceful_Arrow_Launch_2.wav", "Sounds\\Spells\\Forceful_Arrow_Launch_3.wav" , volume = 128, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_heavy"), timescale = 0.6 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Cinder.mdx", point = "hand left", permanent = true },
                },
            },
            motion = {
                power = 47,
                time = 0.35,
                delay = 1.166,
                bonus_angle = -180.
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'cluster_arrow',
                    cooldown            = 4.,
                    resource_cost       = 10.,
                    from_unit           = true,
                    proc_rate           = 0.5
                }
            }
        })
        --============================================--
        -- shot that slows down, a strong slow that fades away
        NewSkillData('AACR', {
            name            = LOCALE_LIST[my_locale].SKILL_FROST_ARROWS,
            icon            = "Spell\\BTNIcyArrows.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.22 },
                on_cast_end = { "Sounds\\Spells\\Bow_Whiff_1.wav", "Sounds\\Spells\\Bow_Whiff_2.wav" , volume = 128, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_fast_2"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Chilled.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'frost_arrow',
                    cooldown            = 5.,
                    resource_cost       = 7.,
                    from_unit           = true,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        -- shot that slows down, a strong slow that fades away
        NewSkillData('AAPA', {
            name            = LOCALE_LIST[my_locale].SKILL_POISON_ARROWS,
            icon            = "Spell\\BTNPoisonsArrow.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Light_1.wav", "Sound\\Assassin\\Assassin_Gasp_Light_2.wav", "Sound\\Assassin\\Assassin_Gasp_Light_3.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\poisoncast.wav", volume = 128, cutoff = 1500., delay = 0.1 },
                on_cast_end = { "Sounds\\Spells\\Bow_Whiff_1.wav", "Sounds\\Spells\\Bow_Whiff_2.wav" , volume = 128, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_fast_1"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Necro.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'poison_arrow',
                    cooldown            = 5.,
                    resource_cost       = 7.,
                    from_unit           = true,
                    proc_rate           = 1.
                }
            }
        })
        --============================================--
        -- wave of arrows from sky that moves forward
        NewSkillData('AASR', {
            name            = LOCALE_LIST[my_locale].SKILL_STEEL_RAIN,
            icon            = "Spell\\BTNArrowShower.blp",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_hmph_1.wav", "Sound\\Assassin\\Assassin_Gasp_hmph_2.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sound\\Assassin\\Assassin_Gasp_Heavy_1.wav", "Sound\\Assassin\\Assassin_Gasp_Heavy_2.wav", "Sound\\Assassin\\Assassin_Gasp_Heavy_3.wav", volume = 150, cutoff = 1500., delay = 0.9 },
                { "Sounds\\Spells\\SteelRain_Bow_Stretch_1.wav", "Sounds\\Spells\\SteelRain_Bow_Stretch_2.wav", "Sounds\\Spells\\SteelRain_Bow_Stretch_3.wav", volume = 115, cutoff = 1500., delay = 0.1 },
                { "Sounds\\Spells\\SteelRain_Charge_1.wav", "Sounds\\Spells\\SteelRain_Charge_2.wav", "Sounds\\Spells\\SteelRain_Charge_3.wav", volume = 128, cutoff = 1500., delay = 0.5 },
                { "Sounds\\Spells\\SteelRain_Bow_Cast_1.wav", "Sounds\\Spells\\SteelRain_Bow_Cast_2.wav", "Sounds\\Spells\\SteelRain_Bow_Cast_3.wav", volume = 135, cutoff = 1500., delay = 1. },
                on_cast_end = { "Sounds\\Spells\\SteelRain_Arrows_1.wav", "Sounds\\Spells\\SteelRain_Arrows_2.wav", "Sounds\\Spells\\SteelRain_Arrows_3.wav" , volume = 125, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_sky"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Cinder.mdx", point = "hand left", permanent = true },
                },
            },
            motion = {
                power = 45,
                time = 0.25,
                delay = 1.1,
                bonus_angle = -180.
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 1000., radius = 200. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    cooldown            = 6.,
                    resource_cost       = 14.,
                    from_unit           = true,
                    proc_rate           = 0.66
                }
            }
        })
        --============================================--
        -- multiple shots within arc
        NewSkillData('AASF', {
            name            = LOCALE_LIST[my_locale].SKILL_SUPPRESSION_FIRE,
            icon            = "Spell\\BTNFrostArrowShower.blp",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            short_name = true,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Medium_1.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_2.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_3.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\SteelRain_Bow_Stretch_1.wav", "Sounds\\Spells\\SteelRain_Bow_Stretch_2.wav", "Sounds\\Spells\\SteelRain_Bow_Stretch_3.wav", volume = 115, cutoff = 1500., delay = 0.1 },
                { "Sounds\\Spells\\Bow_Shot_1.wav", "Sounds\\Spells\\Bow_Shot_2.wav", "Sounds\\Spells\\Bow_Shot_3.wav", "Sounds\\Spells\\Bow_Shot_4.wav", "Sounds\\Spells\\Bow_Shot_5.wav", volume = 128, cutoff = 1500., delay = 0.9 },
                on_cast_end = { "Sounds\\Spells\\Bow_Whiff_1.wav", "Sounds\\Spells\\Bow_Whiff_2.wav" , volume = 138, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_1"), timescale = 0.65 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Soul Bow Enchantment Chilled.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARC, angle_window = 30., area_of_effect = 800. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
                    proc_rate           = 0.65
                }
            }
        })
        --============================================--
        -- electrified arrow that stuns in aoe
        NewSkillData('AACO', {
            name            = LOCALE_LIST[my_locale].SKILL_CHARGED_SHOT,
            icon            = "Spell\\BTNSpearOfJustice.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sound\\Assassin\\Assassin_Gasp_Medium_1.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_2.wav", "Sound\\Assassin\\Assassin_Gasp_Medium_3.wav", volume = 150, cutoff = 1500., delay = 0.25 },
                { "Sounds\\Spells\\ChargedShot_1.wav", "Sounds\\Spells\\ChargedShot_2.wav", "Sounds\\Spells\\ChargedShot_3.wav", "Sounds\\Spells\\ChargedShot_4.wav" , volume = 128, cutoff = 1500., delay = 0.1 },
                on_cast_end = { "Sounds\\Spells\\Bow_Whiff_1.wav", "Sounds\\Spells\\Bow_Whiff_2.wav" , volume = 128, cutoff = 1500. },
            },
            animation = { sequence = GetAnimationSequence("assassin_bow_shot_1"), timescale = 0.8 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "hand left", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'charged_arrow',
                    cooldown            = 7.,
                    resource_cost       = 15.,
                    from_unit           = true,
                    proc_rate           = 0.7
                }
            }
        })
        --============================================--
        -- multishot
        NewSkillData('AAMH', {
            name            = LOCALE_LIST[my_locale].SKILL_MULTISHOT,
            icon            = "Spell\\BTNIchaival.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_BOW,
            classification = SKILL_CLASS_UTILITY,
            animation = { sequence = GetAnimationSequence("assassin_swing_long_upwing_left_to_right"), timescale = 0.35 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 4,
            required_weapon = { BOW_WEAPON },

            level = {
                [1] = {
                    range               = 800.,
                    cooldown            = 7.,
                    resource_cost       = 15.,
                }
            }
        })
        --============================================--
        NewSkillData('ASQB', {
            name            = "spider queen bile",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_UNIQUE,
            sound = {  { "Units\\Creeps\\Spider\\SpiderYes1.wav", volume = 123, cutoff = 1500. }, },
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
            sound = {  { "Units\\Creeps\\Spider\\SpiderYesAttack1.wav", "Units\\Creeps\\Spider\\SpiderYesAttack2.wav", volume = 123, cutoff = 1500. }, },
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
            sound = {  { "Units\\Creeps\\Spider\\SpiderYes2.wav", volume = 123, cutoff = 1500. }, },
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
            sound = {  { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav", volume = 123, cutoff = 1500.}, },
            animation = { sequence = GetAnimationSequence("bandit_charge"), timescale     = 1.4, },

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
            sound = {  { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav", volume = 123, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("arachno_bite"), timescale = 1.75, },
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
            sound = {  { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav", volume = 128, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("arachno_spell"), timescale = 1.9, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Small.mdx", point = "weapon", scale = 2.25, permanent = true }
                },
            },

            level = {
                [1] = {
                    resource_cost       = 0.,
                    cooldown            = 8.,
                    effect              = "EACL",
                }
            }
        })
        --============================================--
        NewSkillData('AACH', {
            name            = "arachno charge",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav", volume = 128, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("arachno_charge"), timescale = 0.9, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand right", scale = 1.5 },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", scale = 1.5 }
                }
            },

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
            --sound = {  { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('A021', {
            name            = "succubus defence curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = { { "Sounds\\Monsters\\Spells\\monster_succubus_cast.wav", volume = 128, cutoff = 1600. }, },
            animation = {
                sequence  = GetAnimationSequence("succubus_spell"), timescale = 1.85,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                },
                on_target = {
                    { effect = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdx", point = "origin", permanent = true, timescale = 1.25, animation_time_influence = true },
                }
            },

            level = {
                [1] = {
                    effect              = "succubus_curse_effect",
                    range               = 800.,
                    resource_cost       = 0.,
                    cooldown            = 10.,
                }
            }
        })
        --============================================--
        NewSkillData('A01Z', {
            name            = "succubus blood curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = { { "Sounds\\Monsters\\Spells\\monster_succubus_cast.wav", volume = 128, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("succubus_spell"), timescale = 1.85, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Blood_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Blood_Small.mdx", point = "hand left", permanent = true },
                },
            },

            level = {
                [1] = {
                    effect              = "succubus_blood_curse_effect",
                    range               = 800.,
                    resource_cost       = 0.,
                    cooldown            = 10.,
                }
            }
        })
        --============================================--
        NewSkillData('A01Y', {
            name            = "demon assassin defence",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            --sound = { { "Sounds\\Monsters\\Spells\\monster_succubus_cast.wav", volume = 128, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("demon_assassin_spell"), timescale = 1.5, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                },
            },

            level = {
                [1] = {
                    effect              = "demon_assassin_defence_effect",
                    resource_cost       = 0.,
                    cooldown            = 6.,
                }
            }
        })
        --============================================--
        NewSkillData('A022', {
            name            = "demon assassin attack",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = { { "Sounds\\Monsters\\Spells\\demon_assassin_attack1.wav", "Sounds\\Monsters\\Spells\\demon_assassin_attack3.wav", "Sounds\\Monsters\\Spells\\demon_assassin_attack5.wav", volume = 128, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("demon_assassin_attack"), timescale = 1., },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", permanent = true },
                    { effect = "Spell\\Ice High.mdx", point = 'hand left', permanent = true }
                },
            },

            level = {
                [1] = {
                    range               = 125.,
                    effect              = "demon_assassin_attack_effect",
                    resource_cost       = 0.,
                    cooldown            = 6.,
                }
            }
        })
        --============================================--
        NewSkillData('A023', {
            name            = "demon assassin blink",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = { { "Sounds\\Monsters\\Spells\\demon_assassin_attack2.wav", "Sounds\\Monsters\\Spells\\demon_assassin_attack4.wav", volume = 128, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("demon_assassin_blink"), timescale = 1., },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = 'hand left', permanent = true }
                },
                on_terrain = { { effect = "Effect\\Blink Red Caster.mdx", permanent = true }, }
            },

            level = {
                [1] = {
                    range               = 500.,
                    resource_cost       = 0.,
                    cooldown            = 12.,
                }
            }
        })
        --============================================--
        NewSkillData('ASBN', {
            name            = "chasing curse",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Abilities\\Spells\\Undead\\Possession\\PossessionMissileLaunch1.wav", volume = 123, cutoff = 1500. }, },
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
        NewSkillData('APNV', {
            name            = "phantom nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Monsters\\Spells\\wisp_cast1.wav", "Sounds\\Monsters\\Spells\\wisp_cast2.wav", "Sounds\\Monsters\\Spells\\wisp_cast3.wav", "Sounds\\Monsters\\Spells\\wisp_cast4.wav", volume = 126, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("phantom_cast"), timescale = 1.5, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "chest", scale = 1. },
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
        NewSkillData('AMLN', {
            name            = "meph nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\mephisto_cast2.wav", "Sounds\\Spells\\mephisto_cast3.wav", volume = 123, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("meph_spell"), timescale = 1.75,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon right", scale = 1.25 },
                    { effect = "Spell\\Sweep_Lightning_Small.mdx", point = "weapon left", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    cooldown            = 5.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AMFB', {
            name            = "meph frost blast",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\mephisto_cast1.wav", volume = 123, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("meph_spell_throw"), timescale = 1.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "weapon right", scale = 1.25 },
                    { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "weapon left", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    cooldown            = 7.,
                    missile = "meph_frost_blast_missile",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ADME', {
            name            = "demoness evolt",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Units\\Demon\\Demoness\\SuccubusYesAttack1.wav", "Units\\Demon\\Demoness\\SuccubusYesAttack2.wav", volume = 128, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("demoness_spell_throw"), timescale = 1.1,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    cooldown            = 16.,
                    missile             = "demoness_evolt_missile",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ADMP', {
            name            = "demoness psison",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Units\\Demon\\Demoness\\SuccubusYesAttack1.wav", "Units\\Demon\\Demoness\\SuccubusYesAttack2.wav", volume = 128, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("demoness_spell_whip"), timescale = 1.25, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.25 },
                }
            },

            level = {
                [1] = {
                    cooldown            = 16.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABCC', {
            name            = "butcher cut",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {
                { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 122, cutoff = 1500., delay = 0.1 },
                { "Sounds\\Monsters\\butcher_skill_1.wav", "Sounds\\Monsters\\butcher_skill_2.wav", "Sounds\\Monsters\\butcher_skill_3.wav", "Sounds\\Monsters\\butcher_skill_4.wav", volume = 128, cutoff = 1500. },
            },
            animation = { sequence  = GetAnimationSequence("butcher_spell"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", scale = 1.25, permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 9.,
                    effect              = "butcher_cripple_effect",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABBC', {
            name            = "butcher charge",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = {
                { "Sounds\\Monsters\\butcher_Fresh_Meat_1.wav", "Sounds\\Monsters\\butcher_Fresh_Meat_2.wav", "Sounds\\Monsters\\butcher_Fresh_Meat_3.wav", "Sounds\\Monsters\\butcher_Fresh_Meat_4.wav", volume = 128, cutoff = 1500. },
                on_cast_end = { "Sounds\\Monsters\\Spells\\butcher_Charge_1.wav", "Sounds\\Monsters\\Spells\\butcher_Charge_2.wav", "Sounds\\Monsters\\Spells\\butcher_Charge_3.wav", "Sounds\\Monsters\\Spells\\butcher_Charge_4.wav", volume = 128, cutoff = 1500.},
            },
            animation = { sequence  = GetAnimationSequence("butcher_spell_throw"), timescale = 1.85, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", scale = 1.25, permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 9.,
                    resource_cost       = 0.,
                    range               = 800.
                }
            }
        })
        --============================================--
        NewSkillData('AQBC', {
            name            = "boar charge",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Units\\Creeps\\QuillBeast\\QuillBoarYes1.wav", "Units\\Creeps\\QuillBeast\\QuillBoarYes2.wav", volume = 123, cutoff = 1500. },},
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
            sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav", volume = 123, cutoff = 1500. }, },
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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
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
            animation = { sequence  = GetAnimationSequence("hellbeast_spell"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", scale = 1.25 },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", scale = 1.25 },
                }
            },
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},
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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

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
        NewSkillData('AWWO', {
            name            = "werewolf howl",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            animation = { sequence  = GetAnimationSequence("werewolf_spell"), timescale = 0.3, },
            sfx_pack = {
                on_caster = {
                    { effect = "Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdx", point = "head", permanent = true },
                }
            },
            sound = {  { "Units\\Creeps\\Owlbear\\OwlbearYesAttack1.wav", "Units\\Creeps\\Owlbear\\OwlbearYesAttack2.wav", volume = 135, cutoff = 1500. }, },

            level = {
                [1] = {
                    cooldown            = 14.,
                    resource_cost       = 0.,
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
            sound = {  { "Units\\Undead\\Necromancer\\NecromancerYes3.wav", volume = 120, cutoff = 1500. }, },

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
            sound = {  { "Units\\Creeps\\BansheeGhost\\BansheeGhostYesAttack1.wav", "Units\\Creeps\\BansheeGhost\\BansheeGhostYesAttack2.wav", volume = 120, cutoff = 1500.}, },

            level = {
                [1] = {
                    cooldown            = 7.,
                    effect = "EFRD",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AZVO', {
            name            = "zombie vomit",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Abilities\\Spells\\NightElf\\CorrosiveBreath\\CorrosiveBreathMissileLaunch1.wav" }, volume = 128, cutoff = 1500.},
            animation = { sequence  = GetAnimationSequence("zombie_vomit"), timescale = 1.75, },
            sfx_pack = {
                on_caster = {
                    { effect = "Effect\\PoisonHands.mdx", point = "head", scale = 1.5 },
                },
            },

            level = {
                [1] = {
                    cooldown            = 7.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('A00B', {
            name            = "pitlord waves",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            animation = { sequence  = GetAnimationSequence("pitlord_spell_throw"), timescale = 1.85, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Darkness High.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Darkness High.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "hand right", permanent = true },
                }
            },
            sound = {  { "Units\\Demon\\HeroPitLord\\HPitLordWhat1.wav", "Units\\Demon\\HeroPitLord\\HPitLordYesAttack3.wav", "Units\\Demon\\HeroPitLord\\HPitLordYes3.wav", volume = 128, cutoff = 1600.}, },

            level = {
                [1] = {
                    cooldown            = 6.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('A00C', {
            name            = "pitlord meteors",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("pitlord_spell"), timescale = 1.5, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Darkness High.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Darkness High.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "hand right", permanent = true },
                }
            },
            sound = {  { "Units\\Demon\\HeroPitLord\\HPitLordWhat3.wav", "Units\\Demon\\HeroPitLord\\HPitLordYesAttack1.wav", "Units\\Demon\\HeroPitLord\\HPitLordYesAttack3.wav", volume = 128, cutoff = 1600.}, },

            level = {
                [1] = {
                    cooldown            = 10.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AAPB', {
            name            = "andariel poison barrage",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = {
                { "Sounds\\Spells\\andariel_castsmall.wav", volume = 130, cutoff = 1600., delay = 0.4 },
                { "Sounds\\Monsters\\andarieltaunt1.wav", volume = 170, cutoff = 1600. },
            },
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
        NewSkillData('AAHF', {
            name            = "andariel hell fires",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {
                { "Sounds\\Spells\\andariel_castlarge.wav", volume = 130, cutoff = 1600. },
                { "Sounds\\Monsters\\andarieltaunt2.wav", volume = 170, cutoff = 1600. },
            },
            animation = { sequence  = GetAnimationSequence("andariel_spell"), timescale = 2., },
            sfx_pack = {
                on_caster = { { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right" } }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABSS', {
            name            = "summon tentacle ",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\baal_summon.wav", volume = 128, cutoff = 1500.  }, },
            animation = { sequence  = GetAnimationSequence("baal_spell"), timescale = 1.45, },

            level = {
                [1] = {
                    cooldown            = 6.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABHF', {
            name            = "baal hoarfrost",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Monsters\\Spells\\missilecast.wav", volume = 128, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("baal_spell"), timescale = 2.5, },
            sfx_pack = { on_caster = { { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Sweep_True_Ice_Small.mdx", point = "hand right" } } },

            level = {
                [1] = {
                    missile             = "baal_hoarfrost_missile",
                    cooldown            = 10.,
                    resource_cost       = 0.,
                    range               = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ABFN', {
            name            = "baal nova",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Monsters\\Spells\\baal_nova.wav", volume = 133, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("baal_spell"), timescale = 3.5, },
            sfx_pack = { on_caster = { { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", permanent = true }, { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right" } } },

            level = {
                [1] = {
                    cooldown            = 12.,
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
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", scale = 1.5, permanent = true },
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", scale = 1.5, permanent = true }
                }
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
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand right", permanent = true },
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "hand left", permanent = true }
                }
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
            sound = {  { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav", volume = 123, cutoff = 1500. },  },
            animation = { sequence  = GetAnimationSequence("revenant_spell"), timescale = 1.55, },
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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

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
            --sound = {  { "Units\\Orc\\Spiritwolf\\SpiritWolfBirth1.wav" }, volume = 123, cutoff = 1500.},

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
                    cooldown            = 25.,
                    missile             = "ensnare_missile",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ASRL', {
            name            = "satyr rally",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Units\\Creeps\\Satyr\\SatyreYesAttack1.wav", "Units\\Creeps\\Satyr\\SatyreYesAttack2.wav", "Units\\Creeps\\Satyr\\SatyreYesAttack3.wav", volume = 125, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("satyr_spell"), timescale = 1.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", scale = 1., permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 10.,
                    effect              = "satyr_rally_effect",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ASBL', {
            name            = "satyr blink",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("satyr_spell"), timescale = 0.9, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "weapon", scale = 1., permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 5.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AHGF', {
            name            = "hguard fire ench",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("hguard_spell"), timescale = 1.2, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Medium.mdx", point = "weapon", scale = 1., permanent = true },
                }
            },

            level = {
                [1] = {
                    effect = "hguard_ench_effect",
                    cooldown            = 10.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AFBB', {
            name            = "frost revenant blast",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("revenant_spell_2"), timescale = 0.9, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_True_Ice_Medium.mdx", point = "weapon", permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 7.,
                    resource_cost       = 0.,
                    range = 500.,
                }
            }
        })
        --============================================--
        NewSkillData('AARB', {
            name            = "succubus astral barrage",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            animation = { sequence  = GetAnimationSequence("succubus_spell"), timescale = 1.45, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true },
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
        NewSkillData('ABRR', {
            name            = "blood raven rise",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Monsters\\Spells\\blood_raven_rise_undead.wav", volume = 123, cutoff = 1500. }, { "Sounds\\Monsters\\bloodraventaunt1.wav", volume = 123, cutoff = 1500. } },
            animation = { sequence  = GetAnimationSequence("bloodraven_spell"), timescale = 2.34, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Darkness High.mdx", point = "hand fist left", permanent = true },
                    { effect = "Spell\\Darkness High.mdx", point = "hand fist right", permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand fist left", permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand fist right", permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 17.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABRA', {
            name            = "blood raven amplify",
            activation_type = TARGET_CAST,
            type            = SKILL_MAGICAL,
            sound = {
                { "Sounds\\Monsters\\bloodraventaunt2.wav", volume = 123, cutoff = 1500. },
                on_cast_end = { "Sounds\\Spells\\amplifydamage.wav", volume = 123, cutoff = 1500.}
            },
            animation = { sequence  = GetAnimationSequence("bloodraven_spell"), timescale = 2.34, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand fist left", permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand fist right", permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 0.,
                    range               = 800.
                }
            }
        })
        --============================================--
        NewSkillData('ARNA', {
            name            = "reanimated arrows",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            animation = { sequence  = GetAnimationSequence("reanimated_spell_slam"), timescale = 1.1, },

            level = {
                [1] = {
                    cooldown            = 12.,
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('AFSM', {
            name            = "faceless stun attack",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Units\\Creeps\\FacelessOne\\FacelessOneYes1.wav", "Units\\Creeps\\FacelessOne\\FacelessOneYes2.wav", volume = 123, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("faceless_spell_attack"), timescale = 1.42, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", permanent = true },
                }
            },

            level = {
                [1] = {
                    cooldown            = 12.,
                    range = 175.,
                    effect              = "faceless_attack_effect",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ADLB', {
            name            = "diablo lightning breath",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\Diablo_LightningBreath_Hellstorm_Launch01.wav", "Sounds\\Spells\\Diablo_LightningBreath_Hellstorm_Launch02.wav", volume = 125, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("diablo_breath"), timescale = 0.9, },

            level = {
                [1] = {
                    cooldown            = 15.,
                    resource_cost       = 0.,
                    range = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ADFS', {
            name            = "diablo fire stomp",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            --sound = {  { "Sounds\\Spells\\Diablo_LightningBreath_Hellstorm_Launch01.wav", "Sounds\\Spells\\Diablo_LightningBreath_Hellstorm_Launch02.wav" }, volume = 125, cutoff = 1600.},
            animation = { sequence  = GetAnimationSequence("diablo_stomp"), timescale = 2.15, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Fire_Small.mdx", point = "foot left" },
                    { effect = "Spell\\Fire Low.mdx", point = "foot left" },

                }
            },

            level = {
                [1] = {
                    cooldown            = 7.,
                    resource_cost       = 0.,
                    range = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ADCH', {
            name            = "diablo charge",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Sounds\\Spells\\Diablo_Demonic_Charge_Launch01.wav", "Sounds\\Spells\\Diablo_Demonic_Charge_Launch02.wav", "Sounds\\Spells\\Diablo_Demonic_Charge_Launch03.wav", volume = 130, cutoff = 1600. }, },
            animation = { sequence  = GetAnimationSequence("diablo_charge"), timescale = 1., },

            level = {
                [1] = {
                    cooldown            = 9.,
                    resource_cost       = 0.,
                    range = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ADAP', {
            name            = "diablo apoc",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\Diablo_Apocalypse_Roar.wav", volume = 125, cutoff = 1600.}, },
            animation = { sequence  = GetAnimationSequence("diablo_apoc"), timescale = 1.65, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right" },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand left" },

                }
            },

            level = {
                [1] = {
                    cooldown            = 9.,
                    resource_cost       = 0.,
                }
            }
        })

        --[[
        Static Field: Upon impact, enemies hit by the lightning are temporarily electrified, causing them to become slowed and vulnerable to additional lightning damage for a short duration. This effect enhances the sorcerer's subsequent lightning-based attacks against affected targets, amplifying the potency of the storm's wrath.

        Shield Bash: The demon swings its shield forward, knocking back players and stunning them momentarily.

        Fiery Slash: The demon imbues its sword with hellfire, dealing additional fire damage with its basic attacks or unleashing a fiery slash in a cone in front of it.

        Demon's Defiance: When the demon's health drops below a certain threshold, it enters a defensive stance, significantly reducing incoming damage and regenerating health for a short duration.

        Infernal Charge: The demon charges forward with its shield raised, knocking down any players in its path and causing damage upon impact.

        Cursed Aura: The demon emits a cursed aura, reducing the effectiveness of healing spells or potions used by players within its vicinity.

        Soul Drain: Upon hitting a player with its sword, the demon has a chance to drain a portion of the player's health and add it to its own.

        Hellfire Nova: The demon channels dark energy, causing flames to erupt from the ground around it, damaging players caught in the inferno.

        Demonic Resilience: The demon gains temporary invulnerability, negating all damage for a short duration, but becoming vulnerable afterwards as it recovers.

        Summon Minions: The demon summons lesser demons or imps to aid it in battle, increasing the challenge for players.

        Rage of the Underworld: As the battle progresses, the demon's attacks become faster and more aggressive, increasing in speed and damage output.





        Certainly! A boss succubus demon in an ARPG could have a range of abilities to make the encounter challenging and engaging. Here are some concepts for abilities:

1. **Seductive Charm**: The succubus emits a seductive aura, temporarily confusing players and causing them to attack their allies or wander aimlessly.

2. **Lustful Lash**: The succubus lashes out with her whip, dealing damage and inflicting a debuff that reduces the movement speed of affected players.

3. **Soul Siphon**: The succubus drains the life force from nearby players, siphoning their health to replenish her own.

4. **Illusory Mirage**: The succubus creates illusory duplicates of herself, confusing players and making it difficult to discern the real succubus from the illusions.

5. **Ethereal Flight**: The succubus takes flight, becoming temporarily immune to melee attacks while pelting players with ranged magical attacks.

6. **Succubus' Embrace**: The succubus ensnares a player with her embrace, immobilizing them and draining their health over time until they are rescued by another player or break free.

7. **Dark Temptation**: The succubus whispers dark promises to players, tempting them to forsake their allies or abandon their quests for power, causing them to momentarily lose focus in battle.

8. **Hellish Whirlwind**: The succubus spins rapidly, creating a whirlwind of dark energy around her that damages and knocks back players caught in its radius.

9. **Curse of Desire**: The succubus curses players with insatiable desire, causing them to take increased damage for a duration as they become consumed by their own desires.

10. **Infernal Kiss**: The succubus launches herself at a player, delivering a powerful kiss that drains their life force and leaves them weakened for a period of time.

These abilities can be combined and scaled in difficulty depending on the level and strength of the succubus boss within the game. They add depth to the boss encounter and provide players with a memorable and challenging battle to overcome.

1. **Seductive Gaze**: The succubus locks eyes with a player, momentarily mesmerizing them and reducing their movement and attack speed.

2. **Lustful Lash**: The succubus whips her tail in a wide arc, dealing damage and leaving players with a debuff that increases incoming damage for a short duration.

3. **Enchanting Allure**: The succubus releases a captivating aura, drawing players towards her. Players caught in the aura may suffer periodic damage over time.

4. **Soul Drain Kiss**: The succubus targets a player and plants a kiss, draining their life force to replenish her own health.

5. **Demonic Temptation**: Summons illusions of desirable visions, confusing players and causing them to attack their allies for a brief duration.

6. **Succubus's Embrace**: Creates an area of darkness where players are slowed and take damage over time. The succubus gains health from any damage dealt within this area.

7. **Infernal Whispers**: The succubus whispers dark secrets into the minds of players, causing confusion and disorienting their controls for a short period.

8. **Ephemeral Flight**: The succubus briefly takes flight, becoming immune to ground-based attacks and casting powerful spells from above.

9. **Charm of Shadows**: The succubus summons shadow clones that mimic her abilities, making it difficult for players to predict and avoid attacks.

10. **Pact of the Abyss**: The succubus opens a portal to the abyss, summoning demonic minions to aid her in battle periodically.

11. **Siren's Song**: The succubus sings an enchanting melody, putting players to sleep temporarily, leaving them vulnerable to follow-up attacks.

12. **Eternal Desires**: As the succubus's health diminishes, her attacks become more potent, and she gains access to additional abilities, escalating the challenge.

These abilities can be tailored to fit the overall theme of the succubus boss and can be used to create a dynamic and engaging boss battle in the ARPG.


    1. Meat Slam
Description: The golem uses its massive, meaty arms to deliver a powerful slam attack.

Effect: Deals heavy physical damage to a single target and has a chance to stun the target for one turn.
2. Flesh Regeneration
Description: The golem taps into its inherent regenerative abilities to heal itself.

Effect: Restores a percentage of the golem’s maximum health over a few turns.
3. Pound of Flesh
Description: The golem tears off a chunk of its own flesh and throws it at an enemy.

Effect: Deals moderate damage and applies a bleed effect, causing the target to take damage over time.
4. Bone Crush
Description: The golem uses the bones embedded in its body to execute a crushing blow.

Effect: Deals massive damage to a single target and has a chance to reduce the target's defense.
5. Meat Shield
Description: The golem hardens its flesh to absorb incoming attacks.

Effect: Reduces all incoming damage by a certain percentage for a few turns.
6. Stench of Decay
Description: The golem emits a nauseating odor from its decaying flesh.

Effect: Reduces the accuracy and evasion of all nearby enemies and has a chance to cause them to flee in fear.
7. Flesh Meld
Description: The golem absorbs the flesh of fallen enemies to strengthen itself.

Effect: Gains a temporary boost to attack and defense for each nearby enemy that has been defeated.
8. Gore Storm
Description: The golem releases a violent burst of blood and gore from its body.

Effect: Deals area-of-effect damage to all nearby enemies and has a chance to inflict a blindness debuff.
9. Grasp of Meat
Description: The golem extends its fleshy tendrils to grab and crush an enemy.

Effect: Immobilizes the target and deals damage over time while the target is held.
10. Meaty Roar
Description: The golem lets out a terrifying roar that intimidates its enemies.

Effect: Reduces the attack power of all enemies in the vicinity and may cause weaker foes to flee.
11. Blood Sacrifice
Description: The golem sacrifices a portion of its health to unleash a powerful attack.

Effect: Deals significant damage to all enemies in the area at the cost of a percentage of the golem’s own health.
12. Carnal Resilience
Description: The golem's toughened flesh reduces the impact of status effects.

Effect: Grants immunity to certain status effects (e.g., poison, bleed) for a duration.
13. Corpse Explosion
Description: The golem detonates a piece of its flesh, causing an explosive burst.

Effect: Deals area-of-effect damage and can knock back enemies caught in the blast radius.
14. Meat Puppet
Description: The golem animates a piece of its flesh to act as a decoy.

Effect: Summons a small minion that distracts enemies and absorbs damage for a limited time.
These skills provide a mix of offensive, defensive, and utility abilities, making the meat golem a versatile and formidable creature in any fantasy setting.





i have a skill that enflames a weapon of sorceress. write down possible effects from that
ChatGPT
Enflaming a sorceress's weapon can add a variety of effects, enhancing both offensive and defensive capabilities. Here are some possible effects:

1. Fire Damage Boost
Description: The enflamed weapon deals additional fire damage with each strike.

Effect: Adds a percentage of the sorceress's magic power as fire damage to each attack.
2. Burning Strike
Description: Attacks with the enflamed weapon set enemies on fire.

Effect: Inflicts a burn status on the target, causing them to take damage over time.
3. Flame Burst
Description: Each attack with the enflamed weapon has a chance to release a burst of flame.

Effect: Deals area-of-effect fire damage to enemies near the target.
4. Inferno Shield
Description: The enflamed weapon creates a fiery barrier around the sorceress.

Effect: Reduces incoming damage by a certain percentage and deals fire damage to attackers in close combat.
5. Scorching Mark
Description: Strikes with the enflamed weapon leave a mark that amplifies fire damage.

Effect: Enemies hit by the weapon take increased fire damage from all sources for a short duration.
6. Heatwave Aura
Description: The enflamed weapon radiates intense heat, affecting nearby enemies.

Effect: Lowers the attack power and defense of enemies within a certain radius of the sorceress.
7. Flaming Arc
Description: Sweeping attacks with the enflamed weapon unleash arcs of fire.

Effect: Deals additional fire damage to all enemies in a cone in front of the sorceress.
8. Phoenix Strike
Description: A powerful attack with the enflamed weapon channels the essence of a phoenix.

Effect: Deals massive fire damage to a single target and has a chance to revive the sorceress with a portion of health if she is defeated within a short time.
9. Combustion
Description: Strikes with the enflamed weapon cause spontaneous combustion in enemies.

Effect: Enemies hit by the weapon have a chance to explode, dealing area-of-effect fire damage to themselves and nearby enemies.
10. Blazing Trail
Description: The enflamed weapon leaves a trail of fire behind each swing.

Effect: Creates a temporary burning path that deals fire damage to any enemy that crosses it.
11. Ember Infusion
Description: The enflamed weapon enhances the sorceress's spellcasting.

Effect: Increases the damage of the sorceress’s fire spells while the weapon is enflamed.
12. Flame Whip
Description: The enflamed weapon can extend and lash out like a whip of fire.

Effect: Increases the weapon’s range and allows it to hit multiple enemies in a line.
13. Hellfire Explosion
Description: On critical hits, the enflamed weapon causes a fiery explosion.

Effect: Deals significant fire damage in an area around the target on a critical strike.
14. Pyroclasmic Barrier
Description: The enflamed weapon grants the sorceress temporary immunity to fire damage.

Effect: Absorbs a certain amount of fire damage and converts it into health or mana.
15. Molten Fury
Description: Consecutive hits with the enflamed weapon increase its fire damage.

Effect: Each successive hit with the weapon increases its fire damage for a short period, stacking up to a certain limit.
        ]]
        DefineTalentsData()
        InitActions()
    end

end