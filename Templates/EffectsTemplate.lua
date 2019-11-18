    EffectsData           = {}
    local MaxEffectLevels = 10

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


    local function NewEffectData()
        return {
            Power               = 0,
            SummBaseAttack      = false,
            PercentOfBaseAttack = 0,
            DamageType          = DAMAGE_TYPE_NONE,
            HealAmount          = 0,
            Attribute           = 1,
            Unavoidable         = false,
            BonusAccuracy       = 0,
            CanCrit             = true,
            BonusCrit           = 0,
            BonusCritMultiplier = 0.,

            AppliedBuff         = 0,
            PersistentAuraBuff  = 0,

            BaseDrainLife       = 0,
            BaseDrainResource   = 0,
            BonusSideDamage     = 0,
            BonusBackDamage     = 0,
            AreaOfEffect        = 0.,

            UsedSFX             = '',
            OnUnitSFX           = '',
            OnUnitSFX_Point     = '',
            EffectDelay         = 0.,
            EffectSound         = ''
        }
    end

    ---@param effect_id integer
    local function NewEffectTemplate(effect_id)
        local my_new_effect = { level = {  }, id = effect_id, name = '' }

            for i = 1, MaxEffectLevels do
                my_new_effect.level[i] = NewEffectData()
            end

        return my_new_effect
    end

    function DefineEffectsData()

        for i = 1, 5 do
            EffectsData[i] = NewEffectTemplate(i)
        end

        -- defined effects
        --=======================================--
        -- test effect
        EffectsData[1].name = "test effect 1"
        EffectsData[1].level[1].Power     = 30
        EffectsData[1].level[1].Attribute = PHYSICAL_BONUS

    end