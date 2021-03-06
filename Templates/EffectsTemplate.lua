do

    EffectsData           = {}
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
        return EffectsData[FourCC(effect_id)]
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
        if EffectsData[FourCC(effect_id)] ~= nil then return nil end
        local my_new_effect = { level = {  }, id = effect_id, name = '', current_level = 1, remove_after_use = true }


            my_new_effect.level[1] = NewEffectData()
            MergeTables(my_new_effect, reference)


                for i = 2, MAX_LEVELS do
                    my_new_effect.level[i] = GenerateEffectLevelData(my_new_effect, i)
                end


            EffectsData[FourCC(effect_id)] = my_new_effect


        return my_new_effect
    end


    function DefineEffectsData()

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

        NewEffectTemplate('EFRB', {
            name = "frostbolt",
            power_delta = 1,
            power_delta_level = 1,
            get_level_from_skill = "A003",
            level = {
                [1] = {
                    power = 47,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    area_of_effect = 175.,
                    max_targets = 300,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A004', target_type = ON_ENEMY }
                    },
                    sound = {
                        pack = { "Sounds\\Spells\\ice_crack_1.wav", "Sounds\\Spells\\ice_crack_2.wav", "Sounds\\Spells\\ice_crack_3.wav" },
                        volume = 122, cutoff = 1800.
                    },

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
            level = {
                [1] = {
                    power = 49,
                    --attack_percent_bonus = 1.,
                    delay = 0.3,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    area_of_effect = 300.,
                    max_targets = 300,
                    SFX_used = "Spell\\IceNova.mdx",
                    SFX_used_scale = 1.,

                    sound = {
                        pack = { "Sounds\\Spells\\IceNova.wav" },
                        volume = 128, cutoff = 1800.
                    },

                    sound_on_hit = {
                        pack = { "Sounds\\Spells\\frost_nova_hit_1.wav", "Sounds\\Spells\\frost_nova_hit_2.wav", "Sounds\\Spells\\frost_nova_hit_3.wav" },
                        volume = 117, cutoff = 1800.
                    },

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00S', target_type = ON_ENEMY }
                    },

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
            level = {
                [1] = {
                    power = 65,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    area_of_effect = 175.,
                    max_targets = 300,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx", point = "chest", duration = 1. }, } },
                    --SFX_on_unit = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx",
                    --SFX_on_unit_point = "chest",
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
                    power = 3,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    sfx_pack = { on_unit = { { effect = "Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdl", point = "chest" }, } },
                    --SFX_on_unit = "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdx",
                    --SFX_on_unit_point = "chest",
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
            level = {
                [1] = {
                    power = 66,
                    --attack_percent_bonus = 1.,
                    delay = 0.1,
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
                    sound = {
                        pack = { "Sounds\\Spells\\frost_orb_impact_1.wav", "Sounds\\Spells\\frost_orb_impact_2.wav" },
                        volume = 120
                    },
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
                    power = 21,
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
            level = {
                [1] = {
                    power = 75,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    SFX_delay = 0.5,
                    SFX_used = "Spell\\Lightnings Long.mdx",
                    SFX_used_scale = 1.,

                    shake_magnitude = 1.5,
                    shake_distance = 1450.,
                    shake_duration = 0.7,

                    delay = 0.5,
                    area_of_effect = 255.,
                    max_targets = 300,
                    sound = {
                        pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" },
                        volume = 128, cutoff = 1800.
                    },
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
            level = {
                [1] = {
                    delay = 0.86,
                    timescale = 1.34,

                    power = 94,
                    --attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    shake_magnitude = 1.7,
                    shake_distance = 1450.,
                    shake_duration = 0.7,

                    SFX_used = "Spell\\Meteor2.mdx",
                    SFX_used_scale = 1.25,

                    sound = {
                        pack = { "Sounds\\Spells\\meteorimpact.wav" },
                        volume = 128, cutoff = 1800.
                    },

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

                    sound = {
                        pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" },
                        volume = 110, cutoff = 1500.
                    },
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

                    --area_of_effect = 100.,
                    max_targets = 1,

                    --Abilities\Spells\Items\AIlb\AIlbSpecialArt.mdl
                    SFX_on_unit = "Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx",
                    SFX_on_unit_point = "chest",

                    sound = {
                        pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" },
                        volume = 115, cutoff = 1500.
                    },
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

                    sound = {
                        pack = { "Sounds\\Spells\\lightning_hit_1.wav", "Sounds\\Spells\\lightning_hit_2.wav", "Sounds\\Spells\\lightning_hit_3.wav" },
                        volume = 115, cutoff = 1600.
                    },
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
            level = {
                [1] = {
                    power = 15,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    area_of_effect = 255.,
                    angle_window  = 45.,
                    force_from_caster_position = true,
                    shake_magnitude = 1.,
                    shake_distance = 1000.,
                    shake_duration = 0.7,
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
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 1.,
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
                    SFX_on_unit = "Abilities\\Spells\\Demon\\DemonBoltImpact\\DemonBoltImpact.mdx",
                    SFX_on_unit_point = "chest",
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
            level = {
                [1] = {
                    power = 6,
                    attack_percent_bonus = 1.,
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
            level = {
                [1] = {
                    power = 25,
                    attack_percent_bonus = 1.,
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
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,

                    area_of_effect = 300.,
                    max_targets = 300,

                    SFX_used = "Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdx",

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

                    sound = {
                        pack = { "Abilities\\Spells\\Human\\Heal\\HealTarget.wav" },
                        volume = 120, cutoff = 1600.
                    },
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
                        pack = { "Sounds\\Spells\\chain_hit_1.wav", "Sounds\\Spells\\chain_hit_2.wav", "Sounds\\Spells\\chain_hit_3.wav", "Sounds\\Spells\\chain_hit_4.wav", "Sounds\\Spells\\chain_hit_5.wav" },
                        volume = 115, cutoff = 1600.
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
            level = {
                [1] = {
                    power = 13,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 255.,
                    angle_window  = 45.,
                    force_from_caster_position = true,
                    max_targets = 300,
                    --SFX_used               = 'Spell\\Coup de Grace.mdx',
                    --SFX_used_scale         = 1.,
                    --SFX_bonus_z = 50.,
                    --SFX_inherit_angle = true,
                    hit_delay = 0.3,
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
            level = {
                [1] = {
                    area_of_effect = 800.,
                    max_targets = 300,
                    SFX_on_caster            = 'Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    sound = {
                        pack = { "Sounds\\Spells\\barbarian_howl_1.wav", "Sounds\\Spells\\barbarian_howl_2.wav" },
                        volume = 115, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00Y', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EWTM', {
            name = "witch effect",

            level = {
                [1] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\VampiricPotion\\VampPotionCaster.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 0.95,
                    sound = {
                        pack = { "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav" },
                        volume = 127, cutoff = 1500.
                    },
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
                    sound = {
                        pack = { "Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav" },
                        volume = 120, cutoff = 1500.
                    },
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
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'A01C', target_type = ON_ENEMY, value = -1 }
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
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01B', target_type = ON_ENEMY },
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'A01B', target_type = ON_ENEMY, value = -1 }
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
                        [1] = { modificator = INCREASE_BUFF_LEVEL, buff_id = 'A01F', target_type = ON_ENEMY },
                        [2] = { modificator = SET_BUFF_TIME, buff_id = 'A01F', target_type = ON_ENEMY, value = -1 }
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
                    sound = {
                        pack = { "Sound\\life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.5,
                    sound = {
                        pack = { "Sound\\life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.75,
                    sound = {
                        pack = { "Sound\\life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
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
                    sound = {
                        pack = { "Sound\\mana_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.5,
                    sound = {
                        pack = { "Sound\\mana_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.75,
                    sound = {
                        pack = { "Sound\\mana_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('PHUN', {
            name = "health and mana restore",
            level = {
                [1] = {
                    max_targets  = 1,
                    sound = {
                        pack = { "Sound\\full_life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01D', target_type = ON_SELF }
                    },
                },
                [2] = {
                    max_targets  = 1,
                    sound = {
                        pack = { "Sound\\full_life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A01D', target_type = ON_SELF }
                    },
                },
                [3] = {
                    max_targets  = 1,
                    sound = {
                        pack = { "Sound\\full_life_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
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
                    sound = {
                        pack = { "Sound\\cure_poison_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
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
                    sound = {
                        pack = { "Sound\\strengh_potion.wav" },
                        volume = 120, cutoff = 1600.
                    },
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
                    --sound = {
                      --  pack = { "Sound\\strengh_potion.wav" },
                      --  volume = 120, cutoff = 1600.
                    --},
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
        NewEffectTemplate('EGHC', {
            name = "ghoul clac effect",
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
        --Spell\Bone Guard.mdx



        RegisterTestCommand("fr effect", function()
        local effect = GetEffectData("PHWK")
            print(effect.name)
            print(R2S(effect.level[1].max_targets))

    end)
    end

end