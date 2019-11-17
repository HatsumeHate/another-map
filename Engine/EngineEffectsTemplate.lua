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

---@param effect_id integer
local function NewEffectData(effect_id)
	return {
		Id                  = effect_id,
		
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
local function NewEffectDataLevel(effect_id)
	local my_new_effect = { level = {} }
	
	for i = 1, MaxEffectLevels do
		my_new_effect.level[i] = NewEffectData(effect_id)
	end
	
	return my_new_effect
end

function DefineEffectsData()
	
	for i = 1, 5 do
		EffectsData[i] = NewEffectDataLevel(i)
	end
	
	-- defined effects
	--=======================================--
	-- test effect
	EffectsData[1].Level[1].Power     = 30
	EffectsData[1].Level[1].Attribute = PHYSICAL

end