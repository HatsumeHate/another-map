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
            get_attack_bonus      = false,
            attack_percent_bonus  = 0,
            damage_type           = DAMAGE_TYPE_NONE,
            attribute             = PHYSICAL_ATTRIBUTE,
            attack_type           = nil,
            can_crit              = true,
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

            triggered_function     = nil,

            SFX_used               = '',
            SFX_on_unit            = '',
            SFX_on_unit_point      = '',
            delay                  = 0.,
            sound                  = ''
        }
    end

    ---@param effect_id integer
    ---@param reference table
    function NewEffectTemplate(effect_id, reference)

        if EffectsData[FourCC(effect_id)] ~= nil then return nil end

        local my_new_effect = { level = {  }, id = effect_id, name = '' }

        for i = 1, MAX_LEVELS do
            my_new_effect.level[i] = NewEffectData()
        end


        MergeTables(my_new_effect, reference)
        EffectsData[FourCC(effect_id)] = my_new_effect

        return my_new_effect
    end


    function DefineEffectsData()

        NewEffectTemplate('EFF1', {
            name = "test effect 1",
            level = {
                [1] = {
                    power = 30,
                    delay = 0.,
                    can_crit = true,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    attribute = PHYSICAL_ATTRIBUTE,
                    applied_buff = {
                        [1] = { modificator = ADD_BUFF, buff_id = 'A002', target_type = ON_SELF },
                        [2] = { modificator = ADD_BUFF, buff_id = 'A002', target_type = ON_ENEMY }
                    },
                }
            }

        })

    end

end