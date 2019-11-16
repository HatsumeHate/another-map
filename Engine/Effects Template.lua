

    EffectsData = {}




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



    local function NewEffectData(id)
        local my_new_effect = {
            Id = id,

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


    function DefineEffectsData()
        local effect_count = 5
        local index = 1

            while(index < effect_count) do
                EffectsData[index] = NewEffectData(index)
                index = index + 1
            end

    end