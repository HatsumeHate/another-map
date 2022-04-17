do

    EffectsData = 0
    local MAX_LEVELS = 5

    ON_ENEMY = 1
    ON_ALLY = 2
    ON_SELF = 3

    ADD_BUFF = 1
    REMOVE_BUFF = 2
    INCREASE_BUFF_LEVEL = 3
    DECREASE_BUFF_LEVEL = 4
    SET_BUFF_LEVEL = 5
    SET_BUFF_TIME = 6



    ---@param effect_id string
    function GetEffectData(effect_id)
        return EffectsData[effect_id]
    end





    function NewEffectData()
        return {
            power                 = 0,
            attack_percent_bonus  = 0.,
            weapon_damage_percent_bonus = 0.,
            damage_type           = DAMAGE_TYPE_NONE,
            attribute             = PHYSICAL_ATTRIBUTE,
            attack_type           = nil,
            can_crit              = true,
            is_direct             = true,
            bonus_crit_chance     = 0,
            bonus_crit_multiplier = 0.,
            max_targets           = 1,

            heal_amount           = 0,

            applied_buff          = { },
            aura                  = 0,

            life_restored         = 0,
            life_percent_restored = 0.,
            resource_restored     = 0,
            resource_percent_restored = 0.,
            life_restored_from_hit = false,
            resource_restored_from_hit = false,

            area_of_effect         = 0.,
            angle_window           = 0.,
            force_from_caster_position = false,

            triggered_function     = nil,

            SFX_used               = '',
            SFX_used_scale         = 1.,
            SFX_inherit_angle      = false,
            SFX_lifetime            = 0.,
            SFX_bonus_z             = 0.,
            SFX_delay                = 0.,

            SFX_on_caster            = '',
            SFX_on_caster_point      = '',
            SFX_on_caster_scale      = 1.,
            
            SFX_on_unit            = '',
            SFX_on_unit_point      = '',
            SFX_on_unit_scale      = 1.,

            shake_magnitude = 0.,
            shake_distance = 0.,
            shake_duration = 0.,

            delay                  = 0.,
            hit_delay              = 0.,
            timescale              = 1.,

            sound                  = nil,
            sound_on_hit           = nil

        }
    end


    ---@param effect table
    ---@param lvl integer
    function GenerateEffectLevelData(effect, lvl)

        if lvl == 1 then return end

            if effect.level[lvl] == nil then
                effect.level[lvl] = NewEffectData()
                MergeTables(effect.level[lvl], effect.level[1])
                effect.level[lvl].generated = false
            end


        if effect.level[lvl].generated == nil or not effect.level[lvl].generated then
            effect.level[lvl].generated = true


            if effect.power_delta then
                effect.level[lvl].power = (effect.level[1].power or 0) + math.floor(lvl / (effect.power_delta_level or 1.)) * effect.power_delta
            end

            if effect.attack_percent_bonus_delta then
                effect.level[lvl].attack_percent = (effect.level[1].attack_percent or 0.) + math.floor(lvl / (effect.attack_percent_bonus_delta_level or 1.)) * effect.attack_percent_bonus_delta
            end

            if effect.attribute_bonus_delta then
                effect.level[lvl].attribute_bonus = (effect.level[1].attribute_bonus or 0) + math.floor(lvl / (effect.attribute_bonus_level or 1.)) * effect.attribute_bonus_delta
            end

            if effect.weapon_damage_percent_bonus_delta then
                effect.level[lvl].weapon_damage_percent_bonus = (effect.level[1].weapon_damage_percent_bonus or 0) + math.floor(lvl / (effect.weapon_damage_percent_bonus_level or 1.)) * effect.weapon_damage_percent_bonus_delta
            end

            if effect.bonus_crit_chance_delta then
                effect.level[lvl].bonus_crit_chance = (effect.level[1].bonus_crit_chance or 0.) + math.floor(lvl / (effect.bonus_crit_chance_delta_level or 1.)) * effect.bonus_crit_chance_delta
            end

            if effect.bonus_crit_multiplier_delta ~= nil then
                effect.level[lvl].bonus_crit_multiplier = (effect.level[1].bonus_crit_multiplier or 0.) + math.floor(lvl / (effect.bonus_crit_multiplier_delta_level or 1.)) * effect.bonus_crit_multiplier_delta
            end

            if effect.max_targets_delta then
                effect.level[lvl].max_targets = (effect.level[1].max_targets or 0) + math.floor(lvl / (effect.max_targets_delta_level or 1.)) * effect.max_targets_delta
            end

            if effect.heal_amount_delta then
                effect.level[lvl].heal_amount = (effect.level[1].heal_amount or 0) + math.floor(lvl / (effect.heal_amount_delta_level or 1.)) * effect.heal_amount_delta
            end

            if effect.life_restored_delta then
                effect.level[lvl].life_restored = (effect.level[1].life_restored or 0) + math.floor(lvl / (effect.life_restored_delta_level or 1.)) * effect.life_restored_delta
            end

            if effect.life_restored_from_hit_max_delta then
                effect.level[lvl].life_restored_from_hit_max = (effect.level[1].life_restored_from_hit_max or 0) + math.floor(lvl / (effect.life_restored_from_hit_max_delta_level or 1.)) * effect.life_restored_from_hit_max_delta
            end

            if effect.resource_restored_from_hit_max_delta then
                effect.level[lvl].resource_restored_from_hit_max = (effect.level[1].resource_restored_from_hit_max or 0) + math.floor(lvl / (effect.resource_restored_from_hit_max_delta_level or 1.)) * effect.resource_restored_from_hit_max_delta
            end

            if effect.life_percent_restored_delta then
                effect.level[lvl].life_percent_restored = (effect.level[1].life_percent_restored or 0.) + math.floor(lvl / (effect.life_percent_restored_delta_level or 1.)) * effect.life_percent_restored_delta
                --print("generated effect life_percent_restored " .. effect.level[lvl].life_percent_restored .. " for level " .. lvl)
            end

            if effect.resource_restored_delta then
                effect.level[lvl].resource_restored = (effect.level[1].resource_restored or 0) + math.floor(lvl / (effect.resource_restored_delta_level or 1.)) * effect.resource_restored_delta
            end

            if effect.resource_percent_restored_delta then
                effect.level[lvl].resource_percent_restored = (effect.level[1].resource_percent_restored or 0.) + math.floor(lvl / (effect.resource_percent_restored_delta_level or 1.)) * effect.resource_percent_restored_delta
            end

            if effect.area_of_effect_delta then
                effect.level[lvl].area_of_effect = (effect.level[1].area_of_effect or 0.) + math.floor(lvl / (effect.area_of_effect_delta_level or 1.)) * effect.area_of_effect_delta
            end

            if effect.angle_window_delta then
                effect.level[lvl].angle_window = (effect.level[1].angle_window or 0.) + math.floor(lvl / (effect.angle_window_delta_level or 1.)) * effect.angle_window_delta
            end

            if effect.delay_delta then
                effect.level[lvl].delay = (effect.level[1].delay or 0.) + math.floor(lvl / (effect.delay_delta_level or 1.)) * effect.delay_delta
            end

            if effect.hit_delay_delta then
                effect.level[lvl].hit_delay = (effect.level[1].hit_delay or 0.) + math.floor(lvl / (effect.hit_delay_delta_level or 1.)) * effect.hit_delay_delta
            end

            if effect.timescale_delta then
                effect.level[lvl].timescale = (effect.level[1].timescale or 1.) + math.floor(lvl / (effect.timescale_delta_level or 1.)) * effect.timescale_delta
            end

        end

        return effect.level[lvl]
    end

    ---@param effect_id integer
    ---@param reference table
    function NewEffectTemplate(effect_id, reference)
        if EffectsData[effect_id] ~= nil then return nil end
        local my_new_effect = { level = {  }, id = effect_id, name = '', current_level = 1, remove_after_use = true }


            my_new_effect.level[1] = NewEffectData()
            MergeTables(my_new_effect, reference)


                for i = 2, MAX_LEVELS do
                    my_new_effect.level[i] = GenerateEffectLevelData(my_new_effect, i)
                end


            EffectsData[effect_id] = my_new_effect


        return my_new_effect
    end


    function DefineEffectsData()

        EffectsData = {}

        NewEffectTemplate('EFF2', {
            name = "test effect on buff 2",
            level = {
                [1] = {
                    life_restored = 15.
                }
            }

        })

        NewEffectTemplate('EFF1', {
            name = "test effect 1",
            level = {
                [1] = {
                    power = 30,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A002', target_type = ON_SELF },
                        [2] = { modificator = ADD_BUFF, buff_id = 'A002', target_type = ON_ENEMY }
                    },
                }
            }

        })

        NewEffectTemplate('critical_strike_effect', {
            name = "critical strike effect",
            level = {
                [1] = {
                    critical_strike_flag = true
                }
            }
        })

        NewEffectTemplate('EFRB', {
            name = "frostbolt",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "A003",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 47,
                    --attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 185.,
                    max_targets = 300,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A004', target_type = ON_ENEMY }
                    },
                    sound = { { pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" }, volume = 122, cutoff = 1800. } },

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                }
            }

        })

        NewEffectTemplate('EFRN', {
            name = "frost nova effect",
            power_delta = 3,
            power_delta_level = 1,
            area_of_effect_delta = 1.,
            area_of_effect_delta_level = 1,
            get_level_from_skill = "A001",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 49,
                    --attack_percent_bonus = 1.,
                    --delay = 0.3,
                    global_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    area_of_effect = 320.,
                    max_targets = 300,
                    SFX_used = "Spell\\IceNova.mdx",
                    SFX_used_scale = 1.,

                    wave_speed = 500.,

                    sound = { { pack = { "Sounds\\Spells\\IceNova.wav" }, volume = 128, cutoff = 1800. } },
                    sound_on_hit = { pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" }, volume = 117, cutoff = 1800. },

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00S', target_type = ON_ENEMY }
                    },

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                }
            }

        })

        NewEffectTemplate('EICR', {
            name = "icicle rain",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ASIR",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 17,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 150.,
                    max_targets = 300,
                    sound = { { pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" }, volume = 122, cutoff = 1800. } },
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                }
            }

        })

        NewEffectTemplate('EGFB', {
            name = "fireball effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A00D",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 65,
                    --attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    area_of_effect = 185.,
                    max_targets = 300,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                }
            }

        })

        NewEffectTemplate('EMLT', {
            name = "meltdown effect",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "AMLT",
            stack_hitnumbers = true,
            level = {
                [1] = {
                    power = 7,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdx", point = "chest" }, } },
                }
            }
        })

        NewEffectTemplate('fire_wall_effect', {
            name = "fire wall effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "AFRW",
            level = {
                [1] = {
                    power = 42,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1.  }, } },
                    max_targets = 1,
                    hit_once_in = 0.5
                }
            }
        })

        NewEffectTemplate('EBLZ', {
            name = "blizzard effect",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "ABLZ",
            stack_hitnumbers = true,
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 15,
                    can_crit = true,
                    global_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 200.,
                    max_targets = 300,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx", point = "chest" }, } },

                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'ABBZ', target_type = ON_ENEMY },
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'ABBZ', target_type = ON_ENEMY, value = -1 }
                    },

                }
            }

        })

        NewEffectTemplate('EFRO', {
            name = "frost orb end effect",
            power_delta = 2,
            power_delta_level = 1,
            bonus_crit_chance_delta = 1.,
            bonus_crit_chance_delta_level = 5,
            get_level_from_skill = "A005",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 63,
                    --attack_percent_bonus = 1.,
                    delay = 0.1,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 225.,

                    shake_magnitude = 1.2,
                    shake_distance = 1250.,
                    shake_duration = 0.7,

                    max_targets = 300,
                    sound = { { pack = { "Sounds\\Spells\\frost_orb_impact_1.wav", "Sounds\\Spells\\frost_orb_impact_2.wav" }, volume = 120 } },
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                }
            }

        })

        NewEffectTemplate('EFOA', {
            name = "frost orb mid effect",
            power_delta = 1,
            power_delta_level = 1,
            attribute_bonus_delta = 2,
            attribute_bonus_delta_level = 5,
            get_level_from_skill = "A005",
            stack_hitnumbers = true,
            level = {
                [1] = {
                    power = 15,
                    --attack_percent_bonus = 1.,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 175.,
                    max_targets = 300,
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ELST', {
            name = "lightning strike effect",
            power_delta = 2,
            power_delta_level = 1,
            bonus_crit_multiplier_delta = 0.1,
            bonus_crit_multiplier_delta_level = 5.,
            attribute_bonus_delta = 2,
            attribute_bonus_delta_level = 5,
            get_level_from_skill = "A00M",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 75,
                    --attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    shake_magnitude = 1.5,
                    shake_distance = 1450.,
                    shake_duration = 0.5,

                    delay = 0.5,
                    area_of_effect = 220.,
                    max_targets = 300,

                    SFX_used = "Effect\\[a]blue--zhendi3.mdx",
                    SFX_used_scale = 0.9,
                    SFX_random_angle = true,
                    SFX_delay = 0.5,

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 128, cutoff = 1800. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EMTR', {
            name = "meteor effect",
            power_delta = 3,
            power_delta_level = 1,
            area_of_effect_delta = 1.,
            area_of_effect_delta_level = 1,
            attribute_bonus_delta = 2,
            attribute_bonus_delta_level = 5,
            get_level_from_skill = "A00F",
            single_attack_instance = true,
            level = {
                [1] = {
                    delay = 1.56,
                    timescale = 1.34,

                    power = 94,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    shake_magnitude = 1.7,
                    shake_distance = 1450.,
                    shake_duration = 0.7,

                    SFX_used = "Spell\\Meteor2.mdx",
                    SFX_used_scale = 1.15,
                    SFX_delay = 0.7,

                    sound = { { pack = { "Sounds\\Spells\\meteorimpact.wav" }, volume = 128, cutoff = 1800. } },

                    SFX_on_unit = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdx",
                    SFX_on_unit_point = "origin",

                    area_of_effect = 325.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EDSC', {
            name = "discharge effect",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "A00J",
            level = {
                [1] = {
                    power = 33,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    SFX_on_unit = "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldBuff.mdx",
                    SFX_on_unit_point = "origin",

                    area_of_effect = 100.,
                    max_targets = 1,

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 110, cutoff = 1500. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECHL', {
            name = "chain lightning effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A019",
            level = {
                [1] = {
                    power = 72,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    attack_cooldown = 0.5,
                    max_targets = 1,

                    --Abilities\Spells\Items\AIlb\AIlbSpecialArt.mdl
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 115, cutoff = 1500. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ELBL', {
            name = "lightning ball effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A00K",
            level = {
                [1] = {
                    power = 27,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,
                    max_targets = 1,

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 115, cutoff = 1600. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EFCS', {
            name = "focus effect",
            get_level_from_skill = "A00N",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00T', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EFAR', {
            name = "frost armor effect",
            get_level_from_skill = "A00E",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A011', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EEMA', {
            name = "elemental mastery effect",
            get_level_from_skill = "A00H",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00U', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ETHK', {
            name = "throwing knife effect",
            power_delta = 2,
            power_delta_level = 1,
            attack_percent_bonus_delta = 0.05,
            attack_percent_bonus_delta_level = 2,
            bonus_crit_chance_delta = 1.,
            bonus_crit_chance_delta_level = 3,
            get_level_from_skill = "A00Z",
            level = {
                [1] = {
                    power = 19,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EUPP', {
            name = "uppercut effect",
            power_delta = 2,
            power_delta_level = 2,
            get_level_from_skill = "A00B",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 15,
                    attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    area_of_effect = 255.,
                    angle_window  = 45.,
                    force_from_caster_position = true,
                    shake_magnitude = 1.,
                    shake_distance = 1000.,
                    shake_duration = 0.6,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EEXC', {
            name = "execution effect",
            power_delta = 2,
            power_delta_level = 2,
            get_level_from_skill = "A020",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    area_of_effect = 255.,
                    angle_window  = 45,
                    force_from_caster_position = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 300,
                    SFX_on_unit = "Effect\\Ephemeral Cut Orange.mdx",
                    SFX_on_unit_point = "chest",
                    SFX_on_unit_scale = 1.25
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ESHG', {
            name = "shatter ground effect",
            power_delta = 2,
            power_delta_level = 1,
            bonus_crit_multiplier_delta = 0.1,
            bonus_crit_multiplier_delta_level = 5.,
            get_level_from_skill = "ASHG",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 8,
                    attack_percent_bonus = 0.6,
                    can_crit = true,
                    is_direct = true,
                    global_crit = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,

                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ASHS', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBRS', {
            name = "berserk effect",
            get_level_from_skill = "A00Q",
            level = {
                [1] = {
                    SFX_used = 'Spell\\TaurenAvatar.mdx',
                    SFX_used_scale = 2.3,
                    SFX_inherit_angle = true,

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00V', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EWHW', {
            name = "whirlwind effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A010",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 6,
                    attack_percent_bonus = 0.15,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 200.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECRH', {
            name = "crushing strike effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A007",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 25,
                    attack_percent_bonus = 0.9,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 255.,
                    angle_window  = 45.,
                    force_from_caster_position = true,
                    max_targets = 300,
                    shake_magnitude = 1.2,
                    shake_distance = 1000.,
                    shake_duration = 0.7,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00W', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBFA', {
            name = "first aid effect",
            get_level_from_skill = "ABFA",
            level = {
                [1] = {
                    --SFX_used = 'Spell\\TaurenAvatar.mdx',
                    --SFX_used_scale = 2.3,
                    --SFX_facing = 270.,
                    --SFX_inherit_angle = true,
                    --SFX_on_caster            = 'Spell\\TaurenAvatar.mdx',
                    --SFX_on_caster_point      = 'origin',
                    --SFX_on_caster_scale      = 4.,

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01N', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ELBS', {
            name = "boosters effect",

            level = {
                [1] = {
                    --power = 0,
                    weapon_damage_percent_bonus = 2.15,
                    --attack_percent_bonus = 0.,
                    can_crit = true,
                    global_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,

                    area_of_effect = 300.,
                    max_targets = 300,

                    SFX_used = "Spell\\impact_flash.mdx",
                    SFX_used_scale = 0.7,

                }
            }
        })
        --==========================================--
        NewEffectTemplate('EFAA', {
            name = "first aid health restore periodic",
            get_level_from_skill = "ABFA",
            life_percent_restored_delta = 0.001,
            life_percent_restored_delta_level = 1,
            level = {
                [1] = {
                    max_targets = 1,
                    life_percent_restored = 0.015,

                    sound = { { pack = { "Abilities\\Spells\\Human\\Heal\\HealTarget.wav" }, volume = 120, cutoff = 1600. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBCH', {
            name = "chain effect",
            get_level_from_skill = "A00A",
            level = {
                [1] = {
                    max_targets = 1,
                    sound = {
                        { pack = { "Sounds\\Spells\\chain_hit_1.wav", "Sounds\\Spells\\chain_hit_2.wav", "Sounds\\Spells\\chain_hit_3.wav", "Sounds\\Spells\\chain_hit_4.wav", "Sounds\\Spells\\chain_hit_5.wav" },
                          volume = 115, cutoff = 1600. }
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A013', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECSL', {
            name = "cutting slash effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "A006",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 13,
                    attack_percent_bonus = 1.,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 255.,
                    angle_window  = 45.,
                    force_from_caster_position = true,
                    max_targets = 300,
                    --hit_delay = 0.3,

                    wave_speed = 500.,

                    sound_on_hit = {
                        pack = { "Sounds\\Spell\\stab_1.wav", "Sounds\\Spell\\stab_2.wav", "Sounds\\Spell\\stab_3.wav", "Sounds\\Spell\\stab_4.wav", "Sounds\\Spell\\stab_5.wav", "Sounds\\Spell\\stab_6.wav" },
                        volume = 115, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A014', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECSP', {
            name = "cutting slash periodic effect",
            power_delta = 1,
            power_delta_level = 5,
            attack_percent_bonus_delta = 0.1,
            attack_percent_bonus_delta_level = 5,
            get_level_from_skill = "A006",
            level = {
                [1] = {
                    power = 2,
                    can_crit = false,
                    attack_percent_bonus = 0.45,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = nil,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                    SFX_on_unit = 'Spell\\Lascerate.mdx',
                    SFX_on_unit_point = 'chest',
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EWCR', {
            name = "warcry effect",
            get_level_from_skill = "A00C",
            single_attack_instance = true,
            level = {
                [1] = {
                    area_of_effect = 800.,
                    max_targets = 300,
                    SFX_on_caster            = 'Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    sound = { { pack = { "Sounds\\Spells\\barbarian_howl_1.wav", "Sounds\\Spells\\barbarian_howl_2.wav" }, volume = 115, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00Y', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENBP', {
            name = "bone prison effect",
            get_level_from_skill = "ANBP",
            single_attack_instance = true,
            area_of_effect_delta_level = 5,
            area_of_effect_delta = 25.,
            level = {
                [1] = {
                    area_of_effect = 275.,
                    max_targets = 300,
                    --SFX_on_caster            = 'Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdx',
                    --SFX_on_caster_point      = 'origin',
                    --SFX_on_caster_scale      = 1.,
                    --sound = { { pack = { "Sounds\\Spells\\barbarian_howl_1.wav", "Sounds\\Spells\\barbarian_howl_2.wav" }, volume = 115, cutoff = 1600. } },
                    sound_on_hit = {
                        pack = { "Sounds\\Spells\\bone_light_hit_1.wav", "Sounds\\Spells\\bone_light_hit_2.wav", "Sounds\\Spells\\bone_light_hit_3.wav", "Sounds\\Spells\\bone_light_hit_4.wav", "Sounds\\Spells\\bone_light_hit_5.wav" },
                        volume = 120, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A0PB', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENBS', {
            name = "bone spear effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ANBS",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 54,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    max_targets = 1,

                    --SFX_used = "Effect\\blue--zhendi.mdx",
                    --SFX_used_scale = 0.6,
                    --SFX_random_angle = true,

                    sfx_pack = { on_unit = { { effect = "Effect\\model (144).mdx", point = "origin", duration = 0. }, } },
                    --SFX_on_unit = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx",
                    --SFX_on_unit_point = "chest",
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ENBB', {
            name = "bone barrage effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ANBB",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 17,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    max_targets = 1,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareMissile.mdx", point = "chest", duration = 0. }, } },
                    sound_on_hit = {
                        pack = { "Abilities\\Spells\\Undead\\Impale\\ImpaleHit.wav" },
                        volume = 120, cutoff = 1600.
                    },

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABBB', target_type = ON_ENEMY },
                    },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ENPB', {
            name = "poison blast effect",
            power_delta = 3,
            power_delta_level = 1,
            get_level_from_skill = "ANPB",
            single_attack_instance = true,
            level = {
                [1] = {
                    area_of_effect = 300.,
                    power = 77,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                    max_targets = 300,

                    --sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Human\\ManaFlare\\ManaFlareMissile.mdx", point = "chest", duration = 0. }, } },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ENPP', {
            name = "poison blast periodic effect",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "ANPB",
            single_attack_instance = true,
            level = {
                [1] = {
                    area_of_effect = 300.,
                    power = 6,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                    max_targets = 300,
                    sfx_pack = { on_unit = { { effect = "Effect\\SporeDamage.mdx", point = "chest", duration = 0. }, } },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ENDV', {
            name = "devour restore",
            get_level_from_skill = "ANDV",
            life_percent_restored_delta = 0.01,
            life_percent_restored_delta_level = 2,
            level = {
                [1] = {
                    max_targets = 1,
                    life_percent_restored = 0.25,
                    sfx_pack = { on_caster_restore = { { effect = "Effect\\AZ_PA_B2.mdx", point = "origin", duration = 0.466 }, } },
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'ABDV', target_type = ON_SELF },
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENCE', {
            name = "corpse explosion effect",
            power_delta = 4,
            power_delta_level = 1,
            get_level_from_skill = "ANCE",
            single_attack_instance = true,
            level = {
                [1] = {
                    area_of_effect = 300.,
                    power = 121,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                    max_targets = 300,

                    shake_magnitude = 1.33,
                    shake_distance = 1000.,
                    shake_duration = 0.5,

                    wave_speed = 450.,

                    sound = { { pack = {
                        "Sounds\\Spells\\corpse_explosion_1.wav", "Sounds\\Spells\\corpse_explosion_2.wav", "Sounds\\Spells\\corpse_explosion_3.wav",
                        "Sounds\\Spells\\corpse_explosion_4.wav", "Sounds\\Spells\\corpse_explosion_5.wav"
                    }, volume = 133, cutoff = 1600. } },

                    SFX_used_scale = 1.65,
                    SFX_used = "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdx",
                    SFX_random_angle = true,
                }
            }

        })
        --==========================================--
        NewEffectTemplate('ENWK', {
            name = "weaken effect",
            get_level_from_skill = "ANWK",
            level = {
                [1] = {
                    area_of_effect = 550.,
                    max_targets = 300,
                    SFX_used_scale = 1.,
                    SFX_used = "Effect\\az_tian.mdx",
                    SFX_random_angle = true,
                    SFX_lifetime = 0.99,
                    delay = 0.27,
                    sound = { { pack = { "Sounds\\Spells\\weaken.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABWK', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENDC', {
            name = "decrepify effect",
            get_level_from_skill = "ANDF",
            level = {
                [1] = {
                    area_of_effect = 550.,
                    max_targets = 300,
                    SFX_used_scale = 1.75,
                    SFX_used = "Effect\\azrael_mofazhen.mdx",
                    SFX_random_angle = true,
                    SFX_lifetime = 1.,
                    delay = 0.15,
                    sound = { { pack = { "Sounds\\Spells\\decrepify.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABDC', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENHF', {
            name = "horrify effect",
            get_level_from_skill = "ANDF",
            level = {
                [1] = {
                    area_of_effect = 550.,
                    max_targets = 300,
                    SFX_used_scale = 1.65,
                    SFX_used = "Effect\\SuperDarkFlash.mdx",
                    SFX_random_angle = true,
                    SFX_bonus_z = 25.,
                    SFX_lifetime = 0.567,
                    delay = 0.15,
                    sound = { { pack = { "Sounds\\Spells\\cursetarget1.wav", "Sounds\\Spells\\cursetarget2.wav", "Sounds\\Spells\\cursetarget3.wav" }, volume = 117, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABHR', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ENHV', {
            name = "harvest effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ANHV",
            single_attack_instance = true,
            resource_restored_from_hit_max_delta = 1,
            resource_restored_from_hit_max_delta_level = 1,
            resource_percent_restored_delta = 1,
            resource_percent_restored_delta_level = 3,

            level = {
                [1] = {
                    power = 43,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                    attribute_bonus = 10,
                    area_of_effect = 255.,
                    angle_window  = 65.,
                    force_from_caster_position = true,
                    max_targets = 300,
                    resource_restored = 5,
                    resource_restored_from_hit = true,
                    resource_restored_from_hit_max = 20,
                    sfx_pack = { on_caster_restore = { { effect = "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdx", point = "origin", duration = 0. }, } },
                }
            }
        })
        NewEffectTemplate('ENTS', {
            name = "toxic substance effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ANTS",
            single_attack_instance = true,
            level = {
                [1] = {
                    power = 33,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                    attribute_bonus = 10,

                    area_of_effect = 165.,
                    max_targets = 300,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdx", point = "chest", duration = 0.766 }, } },
                }
            }

        })
        NewEffectTemplate('ENRP', {
            name = "rip bones effect",
            power_delta = 2,
            power_delta_level = 1,
            get_level_from_skill = "ANBR",
            level = {
                [1] = {
                    power = 11,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                    max_targets = 1,
                    sound_on_hit = {
                      pack = { "Sounds\\Spells\\bone_rip_1.wav", "Sounds\\Spells\\bone_rip_2.wav", "Sounds\\Spells\\bone_rip_3.wav" },
                      volume = 125,
                      cutoff = 1500.
                    },
                    --sfx_pack = { on_unit = { { effect = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdx", point = "chest", duration = 0.766 }, } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABRD', target_type = ON_ENEMY }
                    },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('effect_pursuer', {
            name = "pursuer effect",
            single_attack_instance = true,
            level = {
                [1] = {
                    weapon_damage_percent_bonus = 0.07,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 135.,
                    max_targets = 300,

                    sound_on_hit = {
                      pack = { "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt1.wav" },
                      volume = 125,
                      cutoff = 1500.
                    },

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest", duration = 1. }, } },
                },
                [2] = {
                    weapon_damage_percent_bonus = 0.11,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 135.,
                    max_targets = 300,

                    sound_on_hit = {
                      pack = { "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt1.wav" },
                      volume = 125,
                      cutoff = 1500.
                    },

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest", duration = 1. }, } },
                },
                [3] = {
                    weapon_damage_percent_bonus = 0.15,
                    global_crit = true,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 135.,
                    max_targets = 300,

                    sound_on_hit = {
                      pack = { "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt1.wav" },
                      volume = 125,
                      cutoff = 1500.
                    },

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest", duration = 1. }, } },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('effect_final_favor', {
            name = "final favour talent",
            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Abilities\\Spells\\Undead\\DeathPact\\DeathPactCaster.mdx',
                    SFX_on_caster_point         = 'origin',
                    SFX_on_caster_scale         = 0.7,
                    SFX_on_caster_duration      = 1.833,
                    life_percent_restored       = 0.05,
                    resource_percent_restored   = 0.05,
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Abilities\\Spells\\Undead\\DeathPact\\DeathPactCaster.mdx',
                    SFX_on_caster_point         = 'origin',
                    SFX_on_caster_scale         = 0.85,
                    SFX_on_caster_duration      = 1.833,
                    life_percent_restored       = 0.07,
                    resource_percent_restored   = 0.07,
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Abilities\\Spells\\Undead\\DeathPact\\DeathPactCaster.mdx',
                    SFX_on_caster_point         = 'origin',
                    SFX_on_caster_scale         = 1.,
                    SFX_on_caster_duration      = 1.833,
                    life_percent_restored       = 0.1,
                    resource_percent_restored   = 0.1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('effect_necromorph', {
            name = "necromorph effect",
            single_attack_instance = true,
            level = {
                [1] = {
                    weapon_damage_percent_bonus = 0.12,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 250.,
                    max_targets = 300,

                    sound = { { pack = {
                        "Sounds\\Spells\\corpse_explosion_1.wav", "Sounds\\Spells\\corpse_explosion_2.wav", "Sounds\\Spells\\corpse_explosion_3.wav",
                        "Sounds\\Spells\\corpse_explosion_4.wav", "Sounds\\Spells\\corpse_explosion_5.wav"
                    }, volume = 120, cutoff = 1600. } },

                    SFX_used = "Effect\\blood-boom.mdx",
                    SFX_random_angle = true,
                },
                [2] = {
                    weapon_damage_percent_bonus = 0.18,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 250.,
                    max_targets = 300,

                    sound = { { pack = {
                        "Sounds\\Spells\\corpse_explosion_1.wav", "Sounds\\Spells\\corpse_explosion_2.wav", "Sounds\\Spells\\corpse_explosion_3.wav",
                        "Sounds\\Spells\\corpse_explosion_4.wav", "Sounds\\Spells\\corpse_explosion_5.wav"
                    }, volume = 120, cutoff = 1600. } },

                    SFX_used = "Effect\\blood-boom.mdx",
                    SFX_random_angle = true,
                },
                [3] = {
                    weapon_damage_percent_bonus = 0.24,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,

                    area_of_effect = 250.,
                    max_targets = 300,

                    sound = { { pack = {
                        "Sounds\\Spells\\corpse_explosion_1.wav", "Sounds\\Spells\\corpse_explosion_2.wav", "Sounds\\Spells\\corpse_explosion_3.wav",
                        "Sounds\\Spells\\corpse_explosion_4.wav", "Sounds\\Spells\\corpse_explosion_5.wav"
                    }, volume = 120, cutoff = 1600. } },

                    SFX_used = "Effect\\blood-boom.mdx",
                    SFX_random_angle = true,
                }
            }

        })
        --==========================================--
        NewEffectTemplate('lesion_effect', {
            name = "lesion talent effect",
            level = {
                [1] = {
                    weapon_damage_percent_bonus = 0.05,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                },
                [2] = {
                    weapon_damage_percent_bonus = 0.1,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                },
                [3] = {
                    weapon_damage_percent_bonus = 0.15,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('effect_blood_pact', {
            name = "blood pact talent",
            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Effect\\AZ_PA_B1.MDX',
                    SFX_on_caster_point         = 'origin',
                    life_percent_restored       = 0.06,
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Effect\\AZ_PA_B1.MDX',
                    SFX_on_caster_point         = 'origin',
                    life_percent_restored       = 0.012,
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster               = 'Effect\\AZ_PA_B1.MDX',
                    SFX_on_caster_point         = 'origin',
                    life_percent_restored       = 0.18,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('effect_insanity', {
            name = "insanity effect",
            level = {
                [1] = {
                    power = 10,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                },
                [2] = {
                    power = 20,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                },
                [3] = {
                    power = 30,
                    global_crit = true,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                }
            }

        })
        --==========================================--
        NewEffectTemplate('effect_grave_cold', {
            name = "grave cold effect",
            level = {
                [1] = {
                    power = 7,
                    global_crit = true,
                    can_crit = false,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                },
            }

        })
        --==========================================--
        NewEffectTemplate('EWTM', {
            name = "witch effect",

            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Spell\\consume_whirl.mdx',
                    SFX_on_caster_point      = 'chest',
                    SFX_on_caster_scale      = 1.,
                    --SFX_on_caster_duration = 0.95,
                    sound = { { pack = { "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav" }, volume = 127, cutoff = 1500. } },
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01R', target_type = ON_SELF },
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'A01R', target_type = ON_SELF, value = -1 }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ERIT', {
            name = "ritual effect",

            level = {
                [1] = {
                    max_targets = 1,
                    sound = { { pack = { "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav" }, volume = 120, cutoff = 1500. } },
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01S', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EMEI', {
            name = "master ice effect",

            level = {
                [1] = {
                    max_targets = 1,

                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01C', target_type = ON_ENEMY },
                        [2] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01B', target_type = ON_ENEMY },
                        [3] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01F', target_type = ON_ENEMY },
                        [4] = { modificator = SET_BUFF_TIME, buff_id = 'A01C', target_type = ON_ENEMY, value = -1 },
                        [5] = { modificator = SET_BUFF_TIME, buff_id = 'A01B', target_type = ON_ENEMY, value = -1 },
                        [6] = { modificator = SET_BUFF_TIME, buff_id = 'A01F', target_type = ON_ENEMY, value = -1 }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EMEF', {
            name = "master fire effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01C', target_type = ON_ENEMY },
                        [2] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01B', target_type = ON_ENEMY },
                        [3] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01F', target_type = ON_ENEMY },
                        [4] = { modificator = SET_BUFF_TIME, buff_id = 'A01C', target_type = ON_ENEMY, value = -1 },
                        [5] = { modificator = SET_BUFF_TIME, buff_id = 'A01B', target_type = ON_ENEMY, value = -1 },
                        [6] = { modificator = SET_BUFF_TIME, buff_id = 'A01F', target_type = ON_ENEMY, value = -1 }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EMEL', {
            name = "master lightning effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01C', target_type = ON_ENEMY },
                        [2] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01B', target_type = ON_ENEMY },
                        [3] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01F', target_type = ON_ENEMY },
                        [4] = { modificator = SET_BUFF_TIME, buff_id = 'A01C', target_type = ON_ENEMY, value = -1 },
                        [5] = { modificator = SET_BUFF_TIME, buff_id = 'A01B', target_type = ON_ENEMY, value = -1 },
                        [6] = { modificator = SET_BUFF_TIME, buff_id = 'A01F', target_type = ON_ENEMY, value = -1 }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PHWK', {
            name = "health restore",
            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.7,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.25,
                    sound = { { pack = { "Sound\\life_potion.wav" }, volume = 120, cutoff = 1600. } },
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.5,
                    sound = { { pack = { "Sound\\life_potion.wav" }, volume = 120, cutoff = 1600. } },
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.75,
                    sound = { { pack = { "Sound\\life_potion.wav" }, volume = 120, cutoff = 1600. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PMWK', {
            name = "mana restore",
            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.7,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.25,
                    sound = { { pack = { "Sound\\mana_potion.wav" }, volume = 120, cutoff = 1600. } },
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.5,
                    sound = { { pack = { "Sound\\mana_potion.wav" }, volume = 120, cutoff = 1600. } },
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.75,
                    sound = { { pack = { "Sound\\mana_potion.wav" }, volume = 120, cutoff = 1600. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PHUN', {
            name = "health and mana restore",
            level = {
                [1] = {
                    max_targets  = 1,
                    sound = { { pack = { "Sound\\full_life_potion.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01D', target_type = ON_SELF }
                    },
                },
                [2] = {
                    max_targets  = 1,
                    sound = { { pack = { "Sound\\full_life_potion.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01D', target_type = ON_SELF }
                    },
                },
                [3] = {
                    max_targets  = 1,
                    sound = { { pack = { "Sound\\full_life_potion.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01D', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PUPR', {
            name = "health and mana restore periodic",
            level = {
                [1] = {
                    max_targets = 1,
                    life_percent_restored    = 0.06,
                    resource_percent_restored = 0.05,
                },
                [2] = {
                    max_targets = 1,
                    life_percent_restored   = 0.11,
                    resource_percent_restored = 0.1,
                },
                [3] = {
                    max_targets = 1,
                    life_percent_restored   = 0.14,
                    resource_percent_restored = 0.13,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PANT', {
            name = "antidote",
            level = {
                [1] = {
                    max_targets  = 1,
                    sound = { { pack = { "Sound\\cure_poison_potion.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'AANT', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PADR', {
            name = "adrenaline",
            level = {
                [1] = {
                    max_targets  = 1,
                    sound = { { pack = { "Sound\\strengh_potion.wav" }, volume = 120, cutoff = 1600. } },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'AADR', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('SOTP', {
            name = "scroll of protection",
            level = {
                [1] = {
                    max_targets  = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ASOP', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ESQM', {
            name = "spider queen bile missile effect",
            --get_level_from_skill = "A006",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01U', target_type = ON_ENEMY }
                    },
                }
            }
        })
        NewEffectTemplate('ESQB', {
            name = "spider queen bile periodic effect",
            get_level_from_wave = true,
            power_delta = 4,
            power_delta_level = 5,
            attack_percent_bonus_delta = 0.1,
            attack_percent_bonus_delta_level = 5,
            --get_level_from_skill = "A006",
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 0.85,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = nil,
                    attribute = POISON_ATTRIBUTE,
                    max_targets = 1
                    --SFX_on_unit = 'Spell\\Lascerate.mdx',
                    --SFX_on_unit_point = 'chest',
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECSC', {
            name = "spider queen bite effect",
            get_level_from_wave = true,
            power_delta = 3,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 14,
                    attack_percent_bonus = 1.25,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 225.,
                    angle_window  = 50.,
                    force_from_caster_position = true,
                    max_targets = 300,
                    --hit_delay = 0.3,
                    sound_on_hit = {
                        pack = { "Sounds\\Spell\\stab_1.wav", "Sounds\\Spell\\stab_2.wav", "Sounds\\Spell\\stab_3.wav", "Sounds\\Spell\\stab_4.wav", "Sounds\\Spell\\stab_5.wav", "Sounds\\Spell\\stab_6.wav" },
                        volume = 100, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01V', target_type = ON_ENEMY }
                    },
                }
            }

        })
        --==========================================--
        NewEffectTemplate('EBCS', {
            name = "bandit boss charge impact effect",
            get_level_from_wave = true,
            power_delta = 4,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 18,
                    attack_percent_bonus = 1.15,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ABCB', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBBS', {
            name = "boldness effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'ABBS', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EACL', {
            name = "arachno clac effect",
            get_level_from_wave = true,
            power_delta = 5,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 13,
                    attack_percent_bonus = 1.15,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 50,
                    area_of_effect = 225.,
                    angle_window  = 50.,
                    force_from_caster_position = true,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ACLS', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EAPN', {
            name = "arachno poison nova effect",
            get_level_from_wave = true,
            power_delta = 4,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 20,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EACH', {
            name = "arachno charge impact effect",
            get_level_from_wave = true,
            power_delta = 3,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 6,
                    attack_percent_bonus = 1.,
                    bonus_crit_chance = 25.,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EALN', {
            name = "lightning nova effect",
            get_level_from_wave = true,
            power_delta = 3,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 18,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECBG', {
            name = "bone guard effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ACBG', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EHOR', {
            name = "horror effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'AHRF', target_type = ON_ENEMY },
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'AHRF', target_type = ON_ENEMY, value = -1 }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('gnoll_snare_effect', {
            name = "gnoll snare effect",

            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A005', target_type = ON_ENEMY },
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EGHC', {
            name = "ghoul clac effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 1.05,
                    can_crit = true,
                    is_direct = true,
                    is_sound = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 50,
                    area_of_effect = 200.,
                    angle_window  = 48.,
                    force_from_caster_position = true,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'AGHB', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EHBA', {
            name = "antimagic effect",

            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_unit = 'Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdч',
                    SFX_on_unit_point = 'origin',
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'AHBB', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ELtrait', {
            name = "discharge trait effect",
            get_level_from_wave = true,
            power_delta = 1,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 18,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    SFX_on_unit = "Abilities\\Spells\\Orc\\LightningShield\\LightningShieldBuff.mdx",
                    SFX_on_unit_point = "origin",

                    area_of_effect = 100.,
                    max_targets = 1,

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 110, cutoff = 1500. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ETtrait', {
            name = "toxic trait effect",
            get_level_from_wave = true,
            power_delta = 1,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 3,
                    can_crit = false,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = POISON_ATTRIBUTE,

                    sfx_pack = { on_unit = { { effect = "Units\\Undead\\PlagueCloud\\PlagueCloudtarget.mdx", point = "chest", duration = 0.33 } } },

                    area_of_effect = 225.,
                    max_targets = 300,

                }
            }
        })
        --==========================================--
        NewEffectTemplate('EAtrait', {
            name = "arcane trait effect",
            get_level_from_wave = true,
            power_delta = 1,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 6,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ARCANE_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest" } } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBtrait', {
            name = "burning trait effect",
            get_level_from_wave = true,
            power_delta = 1,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 4,
                    can_crit = false,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdx", point = "chest" }, } },
                    area_of_effect = 200.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EVDS', {
            name = "void disc effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            attribute_bonus_delta = 3,
            attribute_bonus_delta_level = 5,
            level = {
                [1] = {
                    power = 5,
                    can_crit = true,
                    is_direct = false,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest" } } },
                    max_targets = 300,
                    area_of_effect = 220.,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EVDR', {
            name = "void rain effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 14,
                    can_crit = true,
                    is_direct = false,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = DARKNESS_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", point = "chest" } } },
                    max_targets = 300,
                    area_of_effect = 125.,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EFRD', {
            name = "frost drop effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 25,
                    can_crit = true,
                    is_direct = true,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx", point = "chest" } } },
                    max_targets = 300,
                    area_of_effect = 225.,
                    sound = {
                        {
                            pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" },
                            volume = 100, cutoff = 1500., delay = 0.057
                        },
                        {
                            pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" },
                            volume = 100, cutoff = 1500., delay = 0.352
                        },
                        {
                            pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" },
                            volume = 100, cutoff = 1500., delay = 0.682
                        },
                        {
                            pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" },
                            volume = 100, cutoff = 1500., delay = 1.023
                        },
                        {
                            pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" },
                            volume = 100, cutoff = 1500., delay = 1.5
                        },
                        {
                            pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" },
                            volume = 100, cutoff = 1500., delay = 1.64
                        },
                        {
                            pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" },
                            volume = 100, cutoff = 1500., delay = 1.78
                        },
                    },
                    SFX_used = "Spell\\Frosty Crystal Drop.mdx",
                    delay = 1.5,
                    SFX_lifetime = 3.8
                }
            }
        })
        --==========================================--
        NewEffectTemplate('poison_barrage_effect', {
            name = "poison barrage effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            attribute_bonus_delta = 1,
            attribute_bonus_delta_level = 1,
            level = {
                [1] = {
                    power = 10,
                    can_crit = true,
                    is_direct = true,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = POISON_ATTRIBUTE,
                    attribute_bonus = 10
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ESKC', {
            name = "curse effect",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ASKD', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('conflagrate_effect', {
            name = "conflagrate effect",
            get_level_from_wave = true,
            power_delta = 4,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 17,
                    can_crit = true,
                    is_direct = true,
                    is_sound = false,
                    SFX_used = "Spell\\Conflagrate.mdx",
                    SFX_used_scale = 1.2,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,
                    attribute_bonus = 10,
                    max_targets = 300,
                    area_of_effect = 280.,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ACND', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('conflagrate_effect_periodic', {
            name = "conflagrate effect periodic",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 3,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('fire_rain_effect', {
            name = "fire rain effect",
            get_level_from_wave = true,
            power_delta = 2,
            power_delta_level = 1,
            level = {
                [1] = {
                    power = 12,
                    can_crit = true,
                    is_direct = false,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,
                    SFX_used = "Effect\\Rain of Fire Vol. II.mdx",
                    sound = {
                        { pack = { "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireTarget1.wav", "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireTarget2.wav", "Abilities\\Spells\\Demon\\RainOfFire\\RainOfFireTarget3.wav" },
                          volume = 80, cutoff = 1500., delay = 1.25 }
                    },
                    delay = 1.25,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    max_targets = 300,
                    area_of_effect = 125.,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('revenant_lightning_effect', {
            name = "rev laser effect",
            get_level_from_wave = true,
            power_delta = 1,
            power_delta_level = 1,
            attribute_bonus_delta = 2,
            attribute_bonus_delta_level = 1,
            level = {
                [1] = {
                    power = 6,
                    can_crit = true,
                    is_direct = true,
                    is_sound = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Weapons\\VengeanceMissile\\VengeanceMissile.mdx", point = "chest" } } },
                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 110, cutoff = 1800. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ignite_effect_periodic', {
            name = "ignite effect periodic",
            level = {
                [1] = {
                    power = 13,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                },
                [2] = {
                    power = 17,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                },
                [3] = {
                    power = 23,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('napalm_effect', {
            name = "napalm effect",
            level = {
                [1] = {
                    power = 8,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 0.33 }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                    area_of_effect = 100.,
                    max_targets = 300,
                    hit_once_in = 0.32
                },
                [2] = {
                    power = 10,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 0.33 }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                    area_of_effect = 100.,
                    max_targets = 300,
                    hit_once_in = 0.32
                },
                [3] = {
                    power = 12,
                    can_crit = false,
                    is_direct = false,
                    is_sound = false,
                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 0.33 }, } },
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = nil,
                    attribute = FIRE_ATTRIBUTE,
                    area_of_effect = 100.,
                    max_targets = 300,
                    hit_once_in = 0.32
                }
            }
        })
        --==========================================--
        NewEffectTemplate('lightning_rod_effect', {
            name = "lightning rod effect",
            level = {
                [1] = {
                    power = 0,
                    attack_percent_bonus = 0.1,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,
                    max_targets = 1,

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 100, cutoff = 1500. } },
                },
                [2] = {
                    power = 0,
                    attack_percent_bonus = 0.2,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,
                    max_targets = 1,

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                    sound = { { pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" }, volume = 100, cutoff = 1500. } },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('crystallization_effect', {
            name = "crystallization effect",
            level = {
                [1] = {
                    power = 15,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    delay = 0.1,
                    area_of_effect = 245.,
                    max_targets = 300,
                    SFX_used = "Effect\\IceBlast.mdx",
                    SFX_lifetime = 0.,
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                    sound = { { pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" }, volume = 120, cutoff = 1500. } },
                },
                [2] = {
                    power = 30,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    delay = 0.1,
                    area_of_effect = 245.,
                    max_targets = 300,
                    SFX_used = "Effect\\IceBlast.mdx",
                    SFX_lifetime = 0.,
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                    sound = { { pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" }, volume = 120, cutoff = 1500. } },
                },
                [3] = {
                    power = 45,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = false,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    delay = 0.1,
                    area_of_effect = 245.,
                    max_targets = 300,
                    SFX_used = "Effect\\IceBlast.mdx",
                    SFX_lifetime = 0.,
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                    sound = { { pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" }, volume = 120, cutoff = 1500. } },
                },
            }
        })
        --==========================================--
        NewEffectTemplate('ice_enduring_effect', {
            name = "ice enduring effect",
            level = {
                [1] = {
                    --delay = 0.3,
                    wave_speed = 530.,

                    area_of_effect = 350.,
                    max_targets = 300,
                    SFX_used = "Spell\\IceNova.mdx",
                    SFX_used_scale = 1.1,

                    sound = { { pack = { "Sounds\\Spells\\IceNova.wav" }, volume = 115, cutoff = 1500. } },
                    sound_on_hit = { pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" }, volume = 120, cutoff = 1500. },

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'ATIE', target_type = ON_ENEMY }
                    },

                    SFX_on_unit = "Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx",
                    SFX_on_unit_point = "chest",
                }
            }

        })
        --==========================================--
        NewEffectTemplate('fracture_talent_effect', {
            name = "fracture periodic effect",
            level = {
                [1] = {
                    power = 0,
                    can_crit = false,
                    attack_percent_bonus = 0.06,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = nil,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                    SFX_on_unit = 'Spell\\Lascerate.mdx',
                    SFX_on_unit_point = 'chest',
                },
                [2] = {
                    power = 0,
                    can_crit = false,
                    attack_percent_bonus = 0.12,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = nil,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                    SFX_on_unit = 'Spell\\Lascerate.mdx',
                    SFX_on_unit_point = 'chest',
                }
            }
        })
        --==========================================--
        NewEffectTemplate('adrenaline_talent_effect', {
            name = "adrenaline periodic effect",
            level = {
                [1] = {
                    life_percent_restored = 0.03,
                    max_targets = 1,
                },
                [2] = {
                    life_percent_restored = 0.083,
                    max_targets = 1,
                }
            }
        })
        --==========================================--


        InitAuras()
    end

end