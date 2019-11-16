

    EffectsData = {}
    local MaxEffectLevels = 10



---@param source unit
---@param victim unit
---@param effect_id integer
---@param level integer
    function NewEffect(source, victim, effect_id, level)
        local myeffect = {
            source = source,
            victim = victim,
            effect_id = effect_id,
            level = level
        }

        return myeffect
    end




    local function NewEffectData(effect_id)
        --local index = 1
        local my_new_effect = {
            Id = effect_id,

            Power = 0,
            SummBaseAttack = false,
            PercentOfBaseAttack = 0,
            DamageType = true,
            HealAmount = 0,
            Attribute = 1,
            Unavoidable = false,
            BonusAccuracy = 0,
            CanCrit = true,
            BonusCrit = 0,
            BonusCritMultiplier = 0.,

            AppliedBuff = 0,
            PersistentAuraBuff = 0,

            BaseDrainLife = 0,
            BaseDrainResource = 0,
            BonusSideDamage = 0,
            BonusBackDamage = 0,
            AreaOfEffect = 0.,

            UsedSFX = '',
            OnUnitSFX = '',
            OnUnitSFX_Point = '',
            EffectDelay = 0.,
            EffectSound = ''
        }
        return my_new_effect
    end


    local function NewEffectDataLevel(effect_id)
        local index = 1
        local my_new_effect = { effect_level = {} }

            while(index < MaxEffectLevels) do
                my_new_effect.effect_level[index] = NewEffectData(effect_id)
                index = index + 1
            end

        return my_new_effect
    end


    function DefineEffectsData()
        local effect_count = 5
        local index = 1

            while(index < effect_count) do
                EffectsData[index] = NewEffectDataLevel(index)
                index = index + 1
            end

        EffectsData[1].effect_level[1].Attribute = PHYSICAL

    end