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
    SKILL_CATEGORY_GEAR = 16

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
            [SKILL_CATEGORY_COMBAT_SKILLS] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_FAITH] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_HOLY_DOCTRINE] = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
            [SKILL_CATEGORY_LETHALITY] = "GUI\\BTNBackstab2.blp",
            [SKILL_CATEGORY_SHADOWS] = "GUI\\BTN1462810141.blp",
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
            icon            = "Spell\\BTNfrost_nova.blp",
            activation_type = SELF_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_ICE,
            sound = {
                { "Sounds\\Spells\\FrostNova_Cast_1.wav", "Sounds\\Spells\\FrostNova_Cast_2.wav", "Sounds\\Spells\\FrostNova_Cast_3.wav", volume = 205, cutoff = 1600. },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_empower"), timescale = 1., },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice Low.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice Low.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
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
            sound = { 
                { "Sounds\\Spells\\fire_light_launch_1.wav", "Sounds\\Spells\\fire_light_launch_2.wav", "Sounds\\Spells\\fire_light_launch_3.wav", volume = 117, cutoff = 1500. },
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
            sound = { 
                { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. }, 
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.85,
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
            sound = {
                { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 117, cutoff = 1500. }, 
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
            sound = { 
                { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 110, cutoff = 1500. }
            },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.7,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Ice High.mdx", point = 'hand right' },
                    { effect = "Spell\\Ice High.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MFRO',
                    from_unit           = true,
                    resource_cost       = 14.,
                    cooldown            = 2.,
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
            sound = { { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 110, cutoff = 1500. }, },
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    effect              = 'ELST',
                    resource_cost       = 24.,
                    cooldown            = 2.,
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
            sound = { { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 1.2,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 14.,
                    cooldown            = 4.,
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
            sound = {  { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav", volume = 117, cutoff = 1500. }, },
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
            projection = { type = PROJECTION_TYPE_AREA },
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
            sound = {  { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 120, cutoff = 1500. }, },
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    resource_cost       = 10.,
                    cooldown            = 0.3,
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
            sound = {  { "Sounds\\Spells\\cast_lightning_1.wav", "Sounds\\Spells\\cast_lightning_2.wav", "Sounds\\Spells\\cast_lightning_3.wav", volume = 120, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_small"), timescale = 0.95,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON } },
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON } },
                    { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }
                }
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 870.,
                    resource_cost       = 15.,
                    cooldown            = 3.,
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
            sound = {  { "Sounds\\Spells\\cast_lightning_1_diff.wav", "Sounds\\Spells\\cast_lightning_2_diff.wav", volume = 120, cutoff = 1500. }, },
            animation = {
                sequence  = GetAnimationSequence("sorc_spell_throw_big"), timescale = 0.85,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Lightning_Medium.mdx", point = "weapon" }, { effect = "Spell\\Storm Cast.mdx", point = 'hand right' }, { effect = "Spell\\Storm Cast.mdx", point = 'hand left' }
                }
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 900.,
                    resource_cost       = 25.,
                    missile             = 'MBLB',
                    from_unit           = true,
                    cooldown            = 11.,
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
            sound = {  { "Sounds\\Spells\\focus_cast_1.wav", "Sounds\\Spells\\focus_cast_2.wav", "Sounds\\Spells\\focus_cast_3.wav", volume = 120, cutoff = 1500.}, },
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
                }
            }
        })
        --============================================--
        NewSkillData('A00E', {
            name            = LOCALE_LIST[my_locale].SKILL_FROSTARMOR,
            icon            = "Spell\\BTN_AuraCloak_Ice.blp",--"Spell\\BTNCloakOfFrost.blp",
            activation_type = SELF_CAST,
            type            = SKILL_UNIQUE,
            category = SKILL_CATEGORY_ICE,
            sound = {  { "Sounds\\Spells\\frost_armor_launch_2.wav", volume = 110, cutoff = 1500. }, },
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
                    resource_cost       = 10.,
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
            sound = {
                { "Sounds\\Spells\\Hydra_Cast_1.wav", "Sounds\\Spells\\Hydra_Cast_2.wav", "Sounds\\Spells\\Hydra_Cast_3.wav", volume = 128, cutoff = 1600. },
                on_cast_end = { "Sounds\\Spells\\Hydra_CastAtHydra_1.wav", "Sounds\\Spells\\Hydra_CastAtHydra_2.wav", "Sounds\\Spells\\Hydra_CastAtHydra_3.wav", volume = 128, cutoff = 1600. },
            },
            animation = { sequence  = GetAnimationSequence("sorc_spell_throw_air"), timescale = 1.45, },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            sound = {  { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav", volume = 110, cutoff = 1500. }, },
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
            projection = {
                type = PROJECTION_TYPE_AREA,
                area_of_effect = 250.,
                area_of_effect_delta = 5.,
                area_of_effect_delta_level = 1
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 750.,
                    resource_cost       = 12.,
                    cooldown            = 8.,
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
            resource_cost_delta_level = 5,


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
            animation = { sequence = GetAnimationSequence("barb_spell_throw"), timescale = 1.1 },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'MTHK',
                    from_unit           = true,
                    resource_cost       = 5.,
                    cooldown            = 9.,
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
            category = SKILL_CATEGORY_BATTLE_ADVANTAGE,
            always_max_range_cast = true,
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500. }, },
            animation = {
                sequence = GetAnimationSequence("barb_spell_punch"), timescale = 1.15
            },
            motion = {
                power = 45,
                time = 0.3,
                delay = 0.33
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,


            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EUPP',
                    cooldown            = 7.,
                    resource_cost       = 7.,
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
                sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.75
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'EBRS',
                    resource_cost       = 15.,
                    cooldown            = 16.,
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
            always_max_range_cast = true,
            sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },  },
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
            motion = {
                power = 75,
                time = 0.5,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECRH',
                    cooldown            = 4.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
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
            sound = {  { "Sounds\\Spells\\skill_swing_crack_1.wav", "Sounds\\Spells\\skill_swing_crack_2.wav", "Sounds\\Spells\\skill_swing_crack_3.wav", "Sounds\\Spells\\skill_swing_crack_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
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
            motion = {
                power = 50,
                time = 0.4,
                delay = 0.2
            },
            projection = { type = PROJECTION_TYPE_ARC },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'EEXC',
                    cooldown            = 3.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 500.,
                    resource_cost       = 10,
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 120, cutoff = 1500., delay = 0.3 },  },
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1.1 },
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'ECSL',
                    cooldown            = 4.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 120, cutoff = 1500. }, },
            animation = { sequence = GetAnimationSequence("barb_swing_2"), timescale = 1.25 },
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 400.,
                    missile             = "MSHG",
                    cooldown            = 12.,
                    resource_cost       = 15.,
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
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.8 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,
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
                    resource_cost       = 7,
                    cooldown            = 18.,
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
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 0.7 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,
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
                    cooldown            = 15.,
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
                    resource_cost       = 7.,
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
            sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },  },
            animation = {
                sequence = GetAnimationSequence("barb_swing_3"), timescale = 0.8
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 135.,
                    effect              = 'effect_double_strike',
                    cooldown            = 4.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
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
            --sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav" }, volume = 128, cutoff = 1500., delay = 0.3},
            animation = { sequence = GetAnimationSequence("barb_spell_swing"), timescale = 1. },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 500. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    cooldown            = 5.,
                    resource_cost       = 7.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav", volume = 128, cutoff = 1500., delay = 0.45 },  },
            animation = { sequence = GetAnimationSequence("barb_spell_swing_vertical"), timescale = 1.4 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,
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

            level = {
                [1] = {
                    effect = "effect_tremble",
                    range               = 200.,
                    cooldown            = 6.,
                    resource_cost       = 12.,
                    required_weapon = { SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, DAGGER_WEAPON, JAWELIN_WEAPON },
                }
            }
        })
        --============================================--
        NewSkillData('ABCA', {
            name            = LOCALE_LIST[my_locale].SKILL_CALL_OF_THE_ANCIENTS,
            icon            = "Spell\\BTNOutcrySummon.blp",
            activation_type = SELF_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_INNER_STRENGTH,
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\CallOfTheAncients_Cast_1.wav", "Sounds\\Spells\\CallOfTheAncients_Cast_2.wav", "Sounds\\Spells\\CallOfTheAncients_Cast_3.wav", volume = 158, cutoff = 1500. },  },
            animation = { sequence = GetAnimationSequence("barb_spell_howl"), timescale = 1. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            sound = {  { "Sounds\\Spells\\revivecast.wav", volume = 115, cutoff = 1500., delay = 0.35  },},
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
                if CountNearbyCorpses(GetUnitX(caster), GetUnitY(caster), GetOwningPlayer(caster), 600.) > 2 then return true
                else
                    SimError(GetLocalString("Поблизости нет трупов", "No corpses nearby"), GetPlayerId(GetOwningPlayer(caster)))
                    return false
                end
            end,
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 700. },
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
            sound = {  { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav", volume = 128, cutoff = 1500., delay = 0.2 },  },
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
            icon            = "Spell\\BTNBonePrison.blp",--"Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_CURSES,
            classification = SKILL_CLASS_ATTACK,
            sound = {  { "Sounds\\Spells\\bonecast.wav", volume = 115, cutoff = 1500., delay = 0.35 },  },
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
            sound = {
                { "Sounds\\Spells\\Bone_Spear_Cast_start_1.wav", "Sounds\\Spells\\Bone_Spear_Cast_start_2.wav", "Sounds\\Spells\\Bone_Spear_Cast_start_3.wav", volume = 135, cutoff = 1500. },
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
            sound = {  { "Sounds\\Spells\\poison_cast_1.wav", "Sounds\\Spells\\poison_cast_2.wav", "Sounds\\Spells\\poison_cast_3.wav", volume = 125, cutoff = 1500., delay = 0.23 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 0.9,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
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
            icon            = "Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {  { "Sounds\\Spells\\teethlaunch1.wav", "Sounds\\Spells\\teethlaunch2.wav", "Sounds\\Spells\\teethlaunch3.wav", volume = 121, cutoff = 1500., delay = 0.21 },  },
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
            sound = {  { "Sounds\\Spells\\poisonnova.wav", volume = 121, cutoff = 1500. },  },
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
                    { effect = "Effect\\Nether Blast IV.mdx", animation_time_influence = true, timescale = 1.11 },
                }
            },
            projection = { type = PROJECTION_TYPE_AREA, effect = "ENPB" },
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
            sound = {  { "Sounds\\Spells\\necro_cast_soft_1.wav", "Sounds\\Spells\\necro_cast_soft_2.wav", "Sounds\\Spells\\necro_cast_soft_3.wav", "Sounds\\Spells\\necro_cast_soft_4.wav", "Sounds\\Spells\\necro_cast_soft_5.wav", volume = 130, cutoff = 1500., delay = 0.15 },  },
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
            sound = {  { "Sounds\\Spells\\corpseexplodecast.wav", volume = 117, cutoff = 1500., delay = 0.45 },  },
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
            sound = {  { "Sounds\\Spells\\necro_cast_sharp_1.wav", "Sounds\\Spells\\necro_cast_sharp_2.wav", "Sounds\\Spells\\necro_cast_sharp_3.wav", "Sounds\\Spells\\necro_cast_sharp_4.wav", volume = 120, cutoff = 1500., delay = 0.15 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_rise"), timescale = 1.2,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 475., area_of_effect_delta = 25., area_of_effect_delta_level = 3 },
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
            sound = {  { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.4 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.14,
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
            sound = {  { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.4},  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.08,
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
            sound = {  { "Sounds\\Spells\\cursecast.wav", volume = 120, cutoff = 1500., delay = 0.4 },  },
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
            category        = SKILL_CATEGORY_SUMMONING,
            classification  = SKILL_CLASS_SUPPORT,
            sound = {  { "Sounds\\Spells\\bonearmor2.wav", volume = 120, cutoff = 1500., delay = 0.2 },  },
            animation = { sequence  = GetAnimationSequence("necro_spell_slam"), timescale = 1.1, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
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
            icon            = "Spell\\BTNicons_harvest.blp",--"Spell\\BTNCursedScythe.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category        = SKILL_CATEGORY_CURSES,
            classification  = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {  { "Sounds\\Spells\\reversevampire.wav", volume = 120, cutoff = 1500., delay = 0.1 },  },
            animation = {
                sequence  = GetAnimationSequence("necro_spell_throw_small"), timescale = 1.,
            },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Unholy_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Unholy_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Spell\\SoulScythe.mdx", plane_offset = 20., height = 125., appear_delay = 0., animation_time_influence = true, appear_delay = 0.2, timescale = 1.45, scale = 1.55, permanent = true, remove_on_recast = false }
                }
            },
            projection = { type = PROJECTION_TYPE_ARC },
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
        NewSkillData('ANWS', {
            name            = LOCALE_LIST[my_locale].SKILL_WANDERING_SPIRIT,
            icon            = "Spell\\BTNWSpirit.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {
                { "Sounds\\Spells\\Bone_Spirit_Cast_start_1.wav", "Sounds\\Spells\\Bone_Spirit_Cast_start_2.wav", volume = 135, cutoff = 1600. },
                on_cast_end = { "Sounds\\Spells\\Bone_Spirit_Cast_end_1.wav", "Sounds\\Spells\\Bone_Spirit_Cast_end_2.wav", volume = 135, cutoff = 1600. }
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    missile             = 'MNWS',
                    resource_cost       = 5.,
                    cooldown            = 0.3,
                    range               = 800.,
                }
            }
        })
        --============================================--
        NewSkillData('ANBK', {
            name            = "Bone Spikes",--LOCALE_LIST[my_locale].SKILL_BONE_BARRAGE,
            icon            = "Spell\\BTNImpale.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_MAGICAL,
            category = SKILL_CATEGORY_DARK_ART,
            classification = SKILL_CLASS_ATTACK,
            sound = {  { "Sounds\\Spells\\teethlaunch1.wav", "Sounds\\Spells\\teethlaunch2.wav", "Sounds\\Spells\\teethlaunch3.wav", volume = 121, cutoff = 1500., delay = 0.21 },  },
            animation = { sequence  = GetAnimationSequence("necro_spell_throw_big"), timescale = 0.58, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            --projection = { type = PROJECTION_TYPE_ARC, angle_window = 70, area_of_effect = 550. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    resource_cost       = 7.,
                    cooldown            = 2.,
                    range               = 800.,
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
            resource_cost_delta_level = 5,


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
            resource_cost_delta_level = 5,


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
            resource_cost_delta_level = 5,


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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_4_quick"), timescale = 0.8 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\AZ_PA_C.mdx", plane_offset = 50., height = 85., roll = -225., appear_delay = 0.5, animation_time_influence = true, scale = 0.5,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\AZ_PA_C.mdx", plane_offset = 50., height = 85., appear_delay = 0.5, animation_time_influence = true, scale = 0.4,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_curved_strike',
                    cooldown            = 2.,
                    resource_cost       = 5.,
                    required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = { { "Sounds\\Spells\\DashAttack_Lunge_1.wav", "Sounds\\Spells\\DashAttack_Lunge_2.wav" }, volume = 135, cutoff = 1600. },
            animation = { sequence = GetAnimationSequence("assassin_swing_3"), timescale = 0.8 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "hand left", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 400., radius = 75. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 400.,
                    cooldown            = 7.,
                    resource_cost       = 15.,
                    required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_2"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\BasicStrike_Black.mdx", plane_offset = 60., height = 75., roll = -45., appear_delay = 0.57, animation_time_influence = true, scale = 1.2,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\BasicStrike_Black.mdx",plane_offset = 60., height = 75., roll = -45., appear_delay = 0.57, animation_time_influence = true, scale = 1.,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_backstab',
                    cooldown            = 4.,
                    resource_cost       = 7.,
                    required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_swing_3"), timescale = 0.5 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "weapon", permanent = true },
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 1000., radius = 70. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 1000.,
                    cooldown            = 3.5,
                    resource_cost       = 6.,
                }
            }
        })
        -- 3 quick strikes, each hits harder
        NewSkillData('AAEV', {
            name            = LOCALE_LIST[my_locale].SKILL_EVISCERATE,
            icon            = "Spell\\BTNeviscerate.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_LETHALITY,
            classification = SKILL_CLASS_ATTACK,
            always_max_range_cast = true,
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3}, },
            animation = { sequence = GetAnimationSequence("assassin_swing_4_quick"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\[TX]LTSMN_R2.mdx", plane_offset = 60., height = 75., roll = -210., appear_delay = 0.57, animation_time_influence = true, scale = 0.3,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\[TX]LTSMN_R2.mdx", plane_offset = 60., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 0.2,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_eviscerate',
                    cooldown            = 3.,
                    resource_cost       = 7.,
                    required_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_1"), timescale = 1.1 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Acid_Large.mdx.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Acid_Medium.mdx.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                },
                on_terrain = {
                    { effect = "Spell\\Toxic Slash.mdx", plane_offset = 60., height = 80., roll = 145., appear_delay = 0.61, animation_time_influence = true, scale = 2.,
                      conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Spell\\Toxic Slash.mdx", plane_offset = 60., height = 80., roll = 145., appear_delay = 0.61, animation_time_influence = true, scale = 1.8,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_viper_bite',
                    cooldown            = 3.,
                    resource_cost       = 5.,
                    required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = {  { "Sounds\\Spells\\blade_shift_1.wav", "Sounds\\Spells\\blade_shift_2.wav", "Sounds\\Spells\\blade_shift_3.wav", volume = 128, cutoff = 1500., delay = 0.25 },  },
            animation = { sequence = GetAnimationSequence("assassin_swing_5_circle"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    effect              = 'effect_blade_flurry',
                    cooldown            = 5.,
                    resource_cost       = 15.,
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
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1.2 },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1. },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 0.85 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true }
                },
            },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1.2 },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 450. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    aura = "twilight_aura",
                    cooldown            = 12.,
                    resource_cost       = 15.,
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_1"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\rb3.mdx", plane_offset = 70., height = 80., roll = 45., appear_delay = 0.61, animation_time_influence = true, scale = 2.2,
                        conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., roll = -225., appear_delay = 0.57, animation_time_influence = true, scale = 2.,
                        conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 1.8,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_blade_of_darkness',
                    cooldown            = 4.,
                    resource_cost       = 5.,
                    required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
                }
            }
        })
        -- teleport behind, gain critical strike chance
        NewSkillData('AAST', {
            name            = LOCALE_LIST[my_locale].SKILL_SHADOWSTEP,
            icon            = "Spell\\BTNshadowstep.blp",
            activation_type = TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_SHADOWS,
            classification = SKILL_CLASS_UTILITY,
            sound = {  { "Sounds\\Spells\\Shadowstep_Vanish_1.wav", "Sounds\\Spells\\Shadowstep_Vanish_2.wav" }, volume = 150, cutoff = 1500. },
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 0.85 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand left", permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 700.,
                    cooldown            = 8.,
                    resource_cost       = 8.,
                    start_effect_on_cast_point = 'Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdx',
                    start_effect_on_cast_point_scale = 1.,
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
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 128, cutoff = 1500., delay = 0.3 }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_2"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Astral_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Astral_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
                on_terrain = {
                    { effect = "Effect\\rb3.mdx", plane_offset = 70., height = 80., roll = 45., appear_delay = 0.61, animation_time_influence = true, scale = 2.,
                    conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., roll = 45., appear_delay = 0.57, animation_time_influence = true, scale = 1.8,
                      conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }
                    },
                    { effect = "Effect\\rb3.mdx", plane_offset = 60., height = 75., appear_delay = 0.56, animation_time_influence = true, scale = 1.8,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 150.,
                    effect              = 'effect_cursed_hit',
                    cooldown            = 5.,
                    resource_cost       = 8.,
                    required_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON },
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
            sound = {  { "Sounds\\Spells\\chakram_throw_1.wav", "Sounds\\Spells\\chakram_throw_2.wav", "Sounds\\Spells\\chakram_throw_3.wav", volume = 128, cutoff = 1500., delay = 0.2  }, },
            animation = { sequence = GetAnimationSequence("assassin_swing_1"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW, max_distance = 1000., radius = 80. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 1000.,
                    cooldown            = 5.,
                    resource_cost       = 10.,
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
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 500.,
                    missile             = 'incendiary_grenade_missile',
                    cooldown            = 5.,
                    resource_cost       = 17.,
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
            animation = { sequence = GetAnimationSequence("assassin_swing_5_circle"), timescale = 1. },
            projection = { type = PROJECTION_TYPE_AREA },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

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
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 300. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    cooldown            = 10.,
                    resource_cost       = 12.,
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
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_AREA, area_of_effect = 270. },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    cooldown            = 8.,
                    resource_cost       = 10.,
                }
            }
        })
        -- aoe blind
        NewSkillData('AASB', {
            name            = LOCALE_LIST[my_locale].SKILL_SMOKE_BOMB,
            icon            = "Spell\\BTNSoulDischarge.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
            classification = SKILL_CLASS_UTILITY,
            --sound = {  { "Sounds\\Spells\\skill_heavy_swing_1.wav", "Sounds\\Spells\\skill_heavy_swing_2.wav", "Sounds\\Spells\\skill_heavy_swing_3.wav" }, volume = 128, cutoff = 1500., delay = 0.45 },
            animation = { sequence = GetAnimationSequence("assassin_spell"), timescale = 1.2 },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Sweep_Chaos_Large.mdx", point = "weapon", conditional_weapon = { GREATAXE_WEAPON, GREATSWORD_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Medium.mdx", point = "weapon", conditional_weapon = { SWORD_WEAPON, AXE_WEAPON, BLUNT_WEAPON, DAGGER_WEAPON }, permanent = true },
                    { effect = "Spell\\Sweep_Chaos_Small.mdx", point = "hand right", conditional_weapon = { FIST_WEAPON }, permanent = true }
                },
            },
            projection = { type = PROJECTION_TYPE_ARROW },
            resource_cost_delta = 1,
            resource_cost_delta_level = 5,

            level = {
                [1] = {
                    range               = 800.,
                    missile             = 'smoke_bomb_missile',
                    cooldown            = 12.,
                    resource_cost       = 9.,
                }
            }
        })
        -- aoe damage
        NewSkillData('AARL', {
            name            = LOCALE_LIST[my_locale].SKILL_ROCKET_LAUNCHER,
            icon            = "Spell\\BTNrocket launcher.blp",
            activation_type = POINT_AND_TARGET_CAST,
            type            = SKILL_PHYSICAL,
            category = SKILL_CATEGORY_GEAR,
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
            resource_cost_delta_level = 5,

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
            animation = {
                sequence = GetAnimationSequence("bandit_charge"), timescale     = 1.4,
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
            sound = {  { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav", volume = 123, cutoff = 1500. }, },
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
            sound = {  { "Units\\Creeps\\Arachnathid\\ArachnathidYes1.wav", "Units\\Creeps\\Arachnathid\\ArachnathidYes2.wav", volume = 128, cutoff = 1500. }, },
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
            --sound = {  { "Units\\Creeps\\Bandit\\BanditYesAttack2.wav", "Units\\Creeps\\Bandit\\BanditYesAttack3.wav" }, volume = 123, cutoff = 1500.},

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
            sound = {  { "Units\\Demon\\Demoness\\SuccubusYesAttack1.wav", "Units\\Demon\\Demoness\\SuccubusYesAttack2.wav", volume = 127, cutoff = 1500. }, },
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
                    missile = "demoness_evolt_missile",
                    resource_cost       = 0.,
                }
            }
        })
        --============================================--
        NewSkillData('ABCC', {
            name            = "butcher cut",
            activation_type = POINT_CAST,
            type            = SKILL_MAGICAL,
            sound = {  { "Sounds\\Spells\\skill_swing_1.wav", "Sounds\\Spells\\skill_swing_2.wav", "Sounds\\Spells\\skill_swing_3.wav", "Sounds\\Spells\\skill_swing_4.wav", volume = 122, cutoff = 1500., delay = 0.1 },},
            animation = {
                sequence  = GetAnimationSequence("butcher_spell"), timescale = 1.15,
            },
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
        NewSkillData('AQBC', {
            name            = "boar charge",
            activation_type = POINT_AND_TARGET_CAST,
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
        NewSkillData('AAPB', {
            name            = "poison barrage",
            activation_type = POINT_CAST,
            type            = SKILL_PHYSICAL,
            sound = {  { "Sounds\\Spells\\andariel_castsmall.wav", volume = 123, cutoff = 1500., delay = 0.4 },  },
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
            sound = {  { "Sounds\\Spells\\baal_summon.wav", volume = 123, cutoff = 1500.  }, },
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
            sound = {  { "Sounds\\blood_raven_rise_undead.wav", volume = 123, cutoff = 1500. }, },
            animation = { sequence  = GetAnimationSequence("bloodraven_spell"), timescale = 2.34, },
            sfx_pack = {
                on_caster = {
                    { effect = "Spell\\Darkness High.mdx", point = "hand fist left", permanent = true },
                    { effect = "Spell\\Darkness High.mdx", point = "hand fist right", permanent = true },
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

        RegisterTestCommand("hat",function() AddSpecialEffectTarget("Personalization\\Mage Hat.mdx", PlayerHero[1], "head") end)

        RegisterTestCommand("clay",function()
            local item = CreateItem(FourCC("I039"), GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1])-200.)
            local effect = AddSpecialEffectTarget("Items\\Blade_Blood_King.mdx", item, "origin")
                --SetItemPosition(item, GetItemX(item), GetItemY(item))
                --BlzSetItemStringField(item, ITEM_SF_MODEL_USED, "Items\\Blade_Blood_King.mdx")
                --BlzSetItemRealField(item, ITEM_RF_SCALING_VALUE, 0.6)
                print("A")
                BlzSetSpecialEffectScale(effect, 1.)
        end)

        DefineTalentsData()
        InitActions()
    end

end