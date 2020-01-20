do

    EffectsData           = {}
    local MAX_LEVELS = 10

    ON_ENEMY = 1
    ON_ALLY = 2
    ON_SELF = 3

    ADD_BUFF = 1
    REMOVE_BUFF = 2
    INCREASE_BUFF_LEVEL = 3
    DECREASE_BUFF_LEVEL = 4
    SET_BUFF_LEVEL = 5
    SET_BUFF_TIME = 6



    function GetEffectData(effect_id)
        return EffectsData[FourCC(effect_id)]
    end



    ---@param source unit
    ---@param victim unit
    ---@param effect_id integer
    ---@param level integer
    function NewEffect(source, victim, effect_id, level)
        return {
            source    = source,
            victim    = victim,
            effect_id = effect_id,
            level     = level
        }
    end


    function NewEffectData()
        return {
            power                 = 0,
            attack_percent_bonus  = 1.,
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

            SFX_on_caster            = '',
            SFX_on_caster_point      = '',
            SFX_on_caster_scale      = 1.,
            
            SFX_on_unit            = '',
            SFX_on_unit_point      = '',
            SFX_on_unit_scale      = 1.,
            delay                  = 0.,
            hit_delay              = 0.,
            timescale              = 1.,
            sound                  = ''
        }
    end

    ---@param effect_id integer
    ---@param reference table
    function NewEffectTemplate(effect_id, reference)

        if EffectsData[FourCC(effect_id)] ~= nil then return nil end

        local my_new_effect = { level = {  }, id = effect_id, name = '', current_level = 1, remove_after_use = true }

        for i = 1, MAX_LEVELS do
            my_new_effect.level[i] = NewEffectData()
        end


        MergeTables(my_new_effect, reference)
        EffectsData[FourCC(effect_id)] = my_new_effect

        for i = 1, MAX_LEVELS do
            if  my_new_effect.level[i] ~= nil then

                if my_new_effect.level[i].area_of_effect == nil then
                    my_new_effect.level[i].area_of_effect = 0.
                end

                if my_new_effect.level[i].attack_percent_bonus == nil then
                    my_new_effect.level[i].attack_percent_bonus = 0.
                end

                if my_new_effect.level[i].can_crit == nil then
                    my_new_effect.level[i].can_crit = false
                end

                if my_new_effect.level[i].is_direct == nil then
                    my_new_effect.level[i].is_direct = false
                end

                if my_new_effect.level[i].timescale == nil then
                    my_new_effect.level[i].timescale = 1.
                end

                if my_new_effect.level[i].SFX_used_scale == nil then
                    my_new_effect.level[i].SFX_used_scale = 1.
                end

                if my_new_effect.level[i].hit_delay == nil then
                    my_new_effect.level[i].hit_delay = 0.
                end

                if my_new_effect.level[i].delay == nil then
                    my_new_effect.level[i].delay = 0.
                end

                if my_new_effect.level[i].angle_window == nil then
                    my_new_effect.level[i].angle_window = 0.
                end

                if my_new_effect.level[i].force_from_caster_position == nil then
                    my_new_effect.level[i].force_from_caster_position = false
                end

            end
        end

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
            level = {
                [1] = {
                    power = 10,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A004', target_type = ON_ENEMY }
                    },
                }
            }

        })

        NewEffectTemplate('EFRN', {
            name = "frost nova effect",
            level = {
                [1] = {
                    power = 10,
                    attack_percent_bonus = 1.,
                    delay = 0.3,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    area_of_effect = 300.,
                    max_targets = 300,
                    SFX_used = "Spell\\IceNova.mdx",
                    SFX_used_scale = 1.,

                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00S', target_type = ON_ENEMY }
                    },
                }
            }

        })

        NewEffectTemplate('EGFB', {
            name = "fireball effect",
            level = {
                [1] = {
                    power = 17,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    area_of_effect = 175.,
                    max_targets = 300,

                }
            }

        })

        NewEffectTemplate('EFRO', {
            name = "frost orb end effect",
            level = {
                [1] = {
                    power = 20,
                    attack_percent_bonus = 1.,
                    delay = 0.1,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    area_of_effect = 225.,
                    max_targets = 300,

                }
            }

        })

        NewEffectTemplate('EFOA', {
            name = "frost orb mid effect",
            level = {
                [1] = {
                    power = 5,
                    attack_percent_bonus = 1.,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = ICE_ATTRIBUTE,

                    area_of_effect = 175.,
                    max_targets = 300,

                }
            }

        })
        --==========================================--
        NewEffectTemplate('ELST', {
            name = "lightning strike effect",
            level = {
                [1] = {
                    power = 30,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    SFX_used = "Spell\\Lightnings Long.mdx",
                    SFX_used_scale = 1.,

                    area_of_effect = 255.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EMTR', {
            name = "meteor effect",
            level = {
                [1] = {
                    delay = 0.77,
                    timescale = 1.34,

                    power = 27,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = FIRE_ATTRIBUTE,

                    SFX_used = "war3mapImported\\Rain of Fire.mdx",
                    SFX_used_scale = 1.25,

                    area_of_effect = 325.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EDSC', {
            name = "discharge effect",
            level = {
                [1] = {
                    power = 5,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    attack_type = RANGE_ATTACK,
                    attribute = LIGHTNING_ATTRIBUTE,

                    area_of_effect = 100.,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ELBL', {
            name = "lightning ball effect",
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 1.,
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
        NewEffectTemplate('EFCS', {
            name = "focus effect",
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
            level = {
                [1] = {
                    power = 5,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
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
            level = {
                [1] = {
                    power = 3,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    area_of_effect = 155.,
                    angle_window  = 35.,
                    force_from_caster_position = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBRS', {
            name = "berserk effect",
            level = {
                [1] = {
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00V', target_type = ON_SELF }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EWHW', {
            name = "whirlwind effect",
            level = {
                [1] = {
                    power = 7,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 225.,
                    max_targets = 300,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECRH', {
            name = "crushing strike effect",
            level = {
                [1] = {
                    power = 10,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 155.,
                    angle_window  = 35.,
                    force_from_caster_position = true,
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00W', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EBCH', {
            name = "chain effect",
            level = {
                [1] = {
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A013', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECSL', {
            name = "cutting slash effect",
            level = {
                [1] = {
                    power = 4,
                    attack_percent_bonus = 1.,
                    can_crit = true,
                    is_direct = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = MELEE_ATTACK,
                    attribute = PHYSICAL_ATTRIBUTE,
                    area_of_effect = 155.,
                    angle_window  = 35.,
                    force_from_caster_position = true,
                    max_targets = 1,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A014', target_type = ON_ENEMY }
                    },
                }
            }
        })
        --==========================================--
        NewEffectTemplate('ECSP', {
            name = "cutting slash periodic effect",
            level = {
                [1] = {
                    power = 1,
                    attack_percent_bonus = 0.7,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attack_type = nil,
                    attribute = PHYSICAL_ATTRIBUTE,
                    max_targets = 1,
                }
            }
        })
        --==========================================--
        NewEffectTemplate('EWCR', {
            name = "warcry effect",
            level = {
                [1] = {
                    max_targets = 300,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A00Y', target_type = ON_ENEMY }
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
                    sound =  "Sound\\life_potion.wav"
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.5,
                    sound =  "Sound\\life_potion.wav"
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    life_percent_restored = 0.75,
                    sound =  "Sound\\life_potion.wav"
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
                    sound =  "Sound\\mana_potion.wav"
                },
                [2] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 0.85,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.5,
                    sound =  "Sound\\mana_potion.wav"
                },
                [3] = {
                    max_targets = 1,
                    SFX_on_caster            = 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx',
                    SFX_on_caster_point      = 'origin',
                    SFX_on_caster_scale      = 1.,
                    SFX_on_caster_duration = 1.833,
                    resource_percent_restored = 0.75,
                    sound =  "Sound\\mana_potion.wav"
                }
            }
        })
    end

end