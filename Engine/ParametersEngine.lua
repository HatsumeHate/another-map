do
	-- parameters types

    STR_STAT               = 1
    AGI_STAT               = 2
    INT_STAT               = 3
    VIT_STAT               = 4
	
	CRIT_CHANCE            = 5
	CRIT_MULTIPLIER        = 6
	
	HP_REGEN               = 7
	MP_REGEN               = 8
	
	HP_VALUE               = 9
	MP_VALUE               = 10

    PHYSICAL_ATTACK        = 11
    PHYSICAL_DEFENCE       = 12

    MAGICAL_ATTACK         = 13
    MAGICAL_SUPPRESSION    = 14

	ALL_RESIST 			   = 15
	PHYSICAL_RESIST        = 16
	FIRE_RESIST            = 17
	ICE_RESIST             = 18
	LIGHTNING_RESIST       = 19
	POISON_RESIST          = 20
	ARCANE_RESIST          = 21
	DARKNESS_RESIST        = 22
	HOLY_RESIST            = 23
	
	PHYSICAL_BONUS         = 24
	FIRE_BONUS             = 25
	ICE_BONUS              = 26
	LIGHTNING_BONUS        = 27
	POISON_BONUS           = 28
	ARCANE_BONUS           = 29
	DARKNESS_BONUS         = 30
	HOLY_BONUS             = 31
	
	MELEE_DAMAGE_REDUCTION = 32
	RANGE_DAMAGE_REDUCTION = 33
    CONTROL_REDUCTION      = 34

    ATTACK_SPEED           = 35
    CAST_SPEED             = 36
    MOVING_SPEED           = 37

	BLOCK_CHANCE		   = 38
	BLOCK_ABSORB 		   = 39

	REFLECT_DAMAGE   		= 40
	REFLECT_MELEE_DAMAGE 	= 41
	REFLECT_RANGE_DAMAGE 	= 42

	HP_PER_HIT  			= 43
	MP_PER_HIT 				= 44

	BONUS_DEMON_DAMAGE = 45
	BONUS_UNDEAD_DAMAGE = 46
	BONUS_BEAST_DAMAGE = 47
	BONUS_HUMAN_DAMAGE = 48

	GOLD_BONUS = 49
	EXP_BONUS = 50
	DROP_BONUS = 51

	HEALING_BONUS = 52
	DAMAGE_BOOST = 53
	VULNERABILITY = 68
	MANACOST = 54

	BONUS_MELEE_DAMAGE = 55
	BONUS_RANGE_DAMAGE = 56

	DAMAGE_TO_CLOSE_ENEMIES = 57
	DAMAGE_TO_DISTANT_ENEMIES = 58

	DAMAGE_TO_CC_ENEMIES = 59
	DODGE_CHANCE = 60

	COOLDOWN_REDUCTION = 61
	ENDURANCE_POWER = 62
	DAMAGE_TO_ENDURANCE = 63

	CONTROL_DURATION = 64

	HP_PER_KILL = 65
	MP_PER_KILL = 66

	MINION_POWER =  67

	BLEEDING_DAMAGE_BOOST = 69
	BLEEDING_DAMAGE_REDUCTION = 70

	BURNING_DAMAGE_BOOST = 71
	BURNING_DAMAGE_REDUCTION = 72

	POISONING_DAMAGE_BOOST = 73
	POISONING_DAMAGE_REDUCTION = 74

	DECAYING_DAMAGE_BOOST = 75
	DECAYING_DAMAGE_REDUCTION = 76

	RESOURCE_GENERATION = 77

	
	-- attributes
	PHYSICAL_ATTRIBUTE     = 1
	FIRE_ATTRIBUTE         = 2
	ICE_ATTRIBUTE          = 3
	LIGHTNING_ATTRIBUTE    = 4
	POISON_ATTRIBUTE       = 5
	ARCANE_ATTRIBUTE       = 6
	DARKNESS_ATTRIBUTE     = 7
	HOLY_ATTRIBUTE         = 8
	
	-- damage types
	DAMAGE_TYPE_PHYSICAL   = 1
	DAMAGE_TYPE_MAGICAL    = 2
	DAMAGE_TYPE_NONE       = 3
	
	
	-- calculate methods
	STRAIGHT_BONUS         = 1
	MULTIPLY_BONUS         = 2



	local PARAMETER_NAME = 0
	local PARAMETER_UPDATE_FUNC = 0
	local ParameterLimits = 0
	local SpecialSymbolParam



	function ParamToPercent(value, param)
		if value <= ParameterLimits[param].first_limit then
			return value / ParameterLimits[param].value_by_percent_1
		elseif value > ParameterLimits[param].first_limit and value <= ParameterLimits[param].second_limit then
			return ParameterLimits[param].first_limit / ParameterLimits[param].value_by_percent_1
					+ (value - ParameterLimits[param].first_limit) / ParameterLimits[param].value_by_percent_2
		elseif value > ParameterLimits[param].second_limit then
			return ParameterLimits[param].first_limit / ParameterLimits[param].value_by_percent_1
					+ (ParameterLimits[param].second_limit - ParameterLimits[param].first_limit) / ParameterLimits[param].value_by_percent_2
					+ (value - ParameterLimits[param].second_limit) / ParameterLimits[param].value_by_percent_3
		end
		return 0
	end

	
	---@param value real
	function GetBonus_STR(value) return 0.9 + (value * 0.02) end
	
	---@param value real
	function GetBonus_AGI(value) return 1. + (value * 0.01) end
	
	---@param value real
	function GetBonus_INT(value) return 0.8 + (value * 0.04) end
	
	---@param value real
	function GetBonus_VIT(value) return 0.9 + (value * 0.03) end


    function GetCorrectParamText(parameter, value, method)
        if method == MULTIPLY_BONUS then
            local v = value
			value =  S2I(R2S((value - 1.) * 100.))

				if v >= 1. then value = "+" .. value .. "%%"
				else value = math.abs(value) .. "%%" end

        else
			local special = ""
            local vector = "+"

			if SpecialSymbolParam[parameter] then special = "%%" end
			if parameter == MELEE_DAMAGE_REDUCTION or parameter == RANGE_DAMAGE_REDUCTION then vector = "-" end
			if parameter ~= CRIT_MULTIPLIER and parameter ~= HP_REGEN and parameter ~= MP_REGEN then value = R2I(value) end

			if value < 0 then
				vector = ""
				value = math.abs(value)
			end

			value = vector .. value .. special
        end
        return value
    end


	---@param type integer
	function GetParameterName(type)
		return PARAMETER_NAME[type]
	end


	local function NewStat(stat_type)
		return {
			stat_type  = stat_type,

			value      = 0,
			multiplier = 1,
			bonus      = 0,

		}

	end


	---@param unit unit
	---@param param integer
	---@return number
	function GetUnitParameterValue(unit, param)
		local unit_data = GetUnitData(unit)
		return unit_data.stats[param].value or 0.
	end


	---@param param integer
	---@param value real
	---@param plus boolean
	---@param target unit
	---@param method number
	function ModifyStat(target, param, value, method, plus)
		local unit_data = GetUnitData(target)
		
		if unit_data == nil then return end

			if method == MULTIPLY_BONUS then
				unit_data.stats[param].multiplier = plus and unit_data.stats[param].multiplier * value or unit_data.stats[param].multiplier / value
			else
				unit_data.stats[param].bonus = plus and unit_data.stats[param].bonus + value or unit_data.stats[param].bonus - value
			end

		UpdateUnitParameter(target, param)
	end

	---@param unit_data table
	function UpdateParameters(unit_data)
		for i = 1, #PARAMETER_UPDATE_FUNC do
			PARAMETER_UPDATE_FUNC[i](unit_data)
		end
	end

	function UpdateUnitParameter(unit, param)
		local unit_data = GetUnitData(unit)

			PARAMETER_UPDATE_FUNC[param](unit_data)

				if param == STR_STAT then
					PARAMETER_UPDATE_FUNC[PHYSICAL_ATTACK](unit_data)
					PARAMETER_UPDATE_FUNC[CRIT_CHANCE](unit_data)
				elseif param == VIT_STAT then
					PARAMETER_UPDATE_FUNC[HP_VALUE](unit_data)
					PARAMETER_UPDATE_FUNC[HP_REGEN](unit_data)
				elseif param == AGI_STAT then
					PARAMETER_UPDATE_FUNC[PHYSICAL_DEFENCE](unit_data)
					PARAMETER_UPDATE_FUNC[CAST_SPEED](unit_data)
					PARAMETER_UPDATE_FUNC[ATTACK_SPEED](unit_data)
				elseif param == INT_STAT then
					PARAMETER_UPDATE_FUNC[MAGICAL_SUPPRESSION](unit_data)
					PARAMETER_UPDATE_FUNC[MAGICAL_ATTACK](unit_data)
					PARAMETER_UPDATE_FUNC[MP_VALUE](unit_data)
					PARAMETER_UPDATE_FUNC[MP_REGEN](unit_data)
				elseif param == ALL_RESIST then
					PARAMETER_UPDATE_FUNC[PHYSICAL_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[FIRE_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[ICE_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[LIGHTNING_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[POISON_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[DARKNESS_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[HOLY_RESIST](unit_data)
					PARAMETER_UPDATE_FUNC[ARCANE_RESIST](unit_data)
				elseif param == REFLECT_DAMAGE then
					PARAMETER_UPDATE_FUNC[REFLECT_MELEE_DAMAGE](unit_data)
					PARAMETER_UPDATE_FUNC[REFLECT_RANGE_DAMAGE](unit_data)
				end

	end


	function CreateParametersData()
		local parameters = { }

		for i = 1, #PARAMETER_UPDATE_FUNC do
			parameters[i] = NewStat(i)
		end

		return parameters
	end


	function InitParameters()

		ParameterLimits = {
			[PHYSICAL_DEFENCE] = {
				value_by_percent_1 = 11,
				first_limit = 350,
				value_by_percent_2 = 15,
				second_limit = 650,
				value_by_percent_3 = 19
			},
			[MAGICAL_ATTACK] = {
				value_by_percent_1 = 2,
				first_limit = 300,
				value_by_percent_2 = 4,
				second_limit = 540,
				value_by_percent_3 = 6
			},
			[REFLECT_DAMAGE] = {
				value_by_percent_1 = 7,
				first_limit = 200,
				value_by_percent_2 = 13,
				second_limit = 340,
				value_by_percent_3 = 17
			},
			[CRIT_CHANCE] = {
				value_by_percent_1 = 1,
				first_limit = 37,
				value_by_percent_2 = 2,
				second_limit = 45,
				value_by_percent_3 = 4
			},
			[ATTACK_SPEED] = {
				value_by_percent_1 = 1,
				first_limit = 50,
				value_by_percent_2 = 2,
				second_limit = 75,
				value_by_percent_3 = 4
			},
			[CAST_SPEED] = {
				value_by_percent_1 = 1,
				first_limit = 50,
				value_by_percent_2 = 2,
				second_limit = 75,
				value_by_percent_3 = 4
			},
			[MELEE_DAMAGE_REDUCTION] = {
				value_by_percent_1 = 1,
				first_limit = 40,
				value_by_percent_2 = 2,
				second_limit = 65,
				value_by_percent_3 = 5
			},
			[RANGE_DAMAGE_REDUCTION] = {
				value_by_percent_1 = 1,
				first_limit = 40,
				value_by_percent_2 = 2,
				second_limit = 65,
				value_by_percent_3 = 5
			},
			[COOLDOWN_REDUCTION] = {
				value_by_percent_1 = 1,
				first_limit = 50,
				value_by_percent_2 = 2,
				second_limit = 75,
				value_by_percent_3 = 4
			},
			[DODGE_CHANCE] = {
				value_by_percent_1 = 1,
				first_limit = 44,
				value_by_percent_2 = 2,
				second_limit = 65,
				value_by_percent_3 = 3
			},
		}


		PARAMETER_UPDATE_FUNC = {
			---@param data table
			[PHYSICAL_ATTACK]        = function(data)
				local total_damage = data.equip_point[WEAPON_POINT].DAMAGE

				if data.equip_point[OFFHAND_POINT] then
					if data.equip_point[OFFHAND_POINT].TYPE == ITEM_TYPE_WEAPON then
						total_damage = total_damage + ((data.equip_point[OFFHAND_POINT].DAMAGE or 0) * 0.35)
					end
				end

				data.stats[PHYSICAL_ATTACK].value = (total_damage * GetBonus_STR(data.stats[STR_STAT].value) + data.stats[PHYSICAL_ATTACK].bonus) * data.stats[PHYSICAL_ATTACK].multiplier
			end,

			---@param data table
			[PHYSICAL_DEFENCE]       = function(data)
				local defence = data.stats[AGI_STAT].value * 2

				for i = OFFHAND_POINT, HANDS_POINT do
					if data.equip_point[i] then
						defence = defence + (data.equip_point[i].DEFENCE or 0)
					end
				end

				data.stats[PHYSICAL_DEFENCE].value = (defence + data.stats[PHYSICAL_DEFENCE].bonus) * data.stats[PHYSICAL_DEFENCE].multiplier
			end,


			---@param data table
			[MAGICAL_ATTACK]        = function(data)
				local total_damage = data.equip_point[WEAPON_POINT].DAMAGE

				if data.equip_point[OFFHAND_POINT] then
					if data.equip_point[OFFHAND_POINT].TYPE == ITEM_TYPE_WEAPON then
						total_damage = total_damage + ((data.equip_point[OFFHAND_POINT].DAMAGE or 0) * 0.35)
					end
				end

				data.stats[MAGICAL_ATTACK].value = (total_damage * GetBonus_INT(data.stats[INT_STAT].value) + data.stats[MAGICAL_ATTACK].bonus) * data.stats[MAGICAL_ATTACK].multiplier
			end,

			---@param data table
			[MAGICAL_SUPPRESSION]       = function(data)
				local defence = data.stats[INT_STAT].value

				for i = RING_1_POINT, NECKLACE_POINT do
					if data.equip_point[i] then
						defence = defence + (data.equip_point[i].SUPPRESSION or 0)
					end
				end

				if data.equip_point[BELT_POINT] and data.equip_point[BELT_POINT].item then
					defence = defence + (data.equip_point[BELT_POINT].SUPPRESSION or 0)
				end

				data.stats[MAGICAL_SUPPRESSION].value = (defence + data.stats[MAGICAL_SUPPRESSION].bonus) * data.stats[MAGICAL_SUPPRESSION].multiplier
			end,

			---@param data table
			[CRIT_CHANCE]            = function(data)
				data.stats[CRIT_CHANCE].value = ((data.equip_point[WEAPON_POINT].CRIT_CHANCE or 0.) + data.stats[CRIT_CHANCE].bonus + math.floor((data.stats[STR_STAT].value / 3) + 0.5)) * data.stats[CRIT_CHANCE].multiplier
			end,

			---@param data table
			[CRIT_MULTIPLIER]        = function(data)
				data.stats[CRIT_MULTIPLIER].value = ((data.equip_point[WEAPON_POINT].CRIT_MULTIPLIER or 0.) + data.stats[CRIT_MULTIPLIER].bonus) * data.stats[CRIT_MULTIPLIER].multiplier
			end,

			---@param data table
			[HP_REGEN]               = function(data)
				data.stats[HP_REGEN].value = (data.base_stats.hp_regen + data.stats[HP_REGEN].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_REGEN].multiplier

				--print(data.base_stats.hp_regen .. " + " .. data.stats[HP_REGEN].bonus .. " * " ..  GetBonus_VIT(data.stats[VIT_STAT].value) .. " * " .. data.stats[HP_REGEN].multiplier)
				BlzSetUnitRealField(data.Owner, UNIT_RF_HIT_POINTS_REGENERATION_RATE, data.hp_vector and data.stats[HP_REGEN].value or -data.stats[HP_REGEN].value)
			end,

			---@param data table
			[MP_REGEN]               = function(data)
				data.stats[MP_REGEN].value = (data.base_stats.mp_regen + data.stats[MP_REGEN].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_REGEN].multiplier
					if not data.is_mp_static then
						BlzSetUnitRealField(data.Owner, UNIT_RF_MANA_REGENERATION, data.mp_vector and data.stats[MP_REGEN].value or -data.stats[MP_REGEN].value)
					end
			end,

			---@param data table
			[HP_VALUE]               = function(data)
				local ratio = GetUnitState(data.Owner, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(data.Owner)
					data.stats[HP_VALUE].value = (data.base_stats.health + data.stats[HP_VALUE].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_VALUE].multiplier
					BlzSetUnitMaxHP(data.Owner, R2I(data.stats[HP_VALUE].value))
					if ratio >= 0.9 then SetUnitState(data.Owner, UNIT_STATE_LIFE, R2I(data.stats[HP_VALUE].value) * ratio) end
			end,

			---@param data table
			[MP_VALUE]               = function(data)
				data.stats[MP_VALUE].value = (data.base_stats.mana + data.stats[MP_VALUE].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_VALUE].multiplier
					if data.has_mp then
						local ratio = GetUnitState(data.Owner, UNIT_STATE_MANA) / BlzGetUnitMaxMana(data.Owner)
						BlzSetUnitMaxMana(data.Owner, R2I(data.stats[MP_VALUE].value))
						SetUnitState(data.Owner, UNIT_STATE_MANA, R2I(data.stats[MP_VALUE].value) * ratio)
					end
			end,

			---@param data table
			[PHYSICAL_RESIST]       = function(data)
				data.stats[PHYSICAL_RESIST].value = data.stats[PHYSICAL_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[FIRE_RESIST]            = function(data)
				data.stats[FIRE_RESIST].value = data.stats[FIRE_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[ICE_RESIST]             = function(data)
				data.stats[ICE_RESIST].value = data.stats[ICE_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[LIGHTNING_RESIST]       = function(data)
				data.stats[LIGHTNING_RESIST].value = data.stats[LIGHTNING_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[POISON_RESIST]          = function(data)
				data.stats[POISON_RESIST].value = data.stats[POISON_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[ARCANE_RESIST]          = function(data)
				data.stats[ARCANE_RESIST].value = data.stats[ARCANE_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[DARKNESS_RESIST]        = function(data)
				data.stats[DARKNESS_RESIST].value = data.stats[DARKNESS_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[HOLY_RESIST]            = function(data)
				data.stats[HOLY_RESIST].value = data.stats[HOLY_RESIST].bonus + data.stats[ALL_RESIST].value
			end,

			---@param data table
			[PHYSICAL_BONUS]         = function(data)
				data.stats[PHYSICAL_BONUS].value = data.stats[PHYSICAL_BONUS].bonus
			end,

			---@param data table
			[FIRE_BONUS]             = function(data)
				data.stats[FIRE_BONUS].value = data.stats[FIRE_BONUS].bonus
			end,

			---@param data table
			[ICE_BONUS]              = function(data)
				data.stats[ICE_BONUS].value = data.stats[ICE_BONUS].bonus
			end,

			---@param data table
			[LIGHTNING_BONUS]        = function(data)
				data.stats[LIGHTNING_BONUS].value = data.stats[LIGHTNING_BONUS].bonus
			end,

			---@param data table
			[POISON_BONUS]           = function(data)
				data.stats[POISON_BONUS].value = data.stats[POISON_BONUS].bonus
			end,

			---@param data table
			[ARCANE_BONUS]           = function(data)
				data.stats[ARCANE_BONUS].value = data.stats[ARCANE_BONUS].bonus
			end,

			---@param data table
			[DARKNESS_BONUS]         = function(data)
				data.stats[DARKNESS_BONUS].value = data.stats[DARKNESS_BONUS].bonus
			end,

			---@param data table
			[HOLY_BONUS]             = function(data)
				data.stats[HOLY_BONUS].value = data.stats[HOLY_BONUS].bonus
			end,

			---@param data table
			[STR_STAT]               = function(data)
				data.stats[STR_STAT].value = data.base_stats.strength + data.stats[STR_STAT].bonus
			end,

			---@param data table
			[VIT_STAT]               = function(data)
				data.stats[VIT_STAT].value = data.base_stats.vitality + data.stats[VIT_STAT].bonus
			end,

			---@param data table
			[AGI_STAT]               = function(data)
				data.stats[AGI_STAT].value = data.base_stats.agility + data.stats[AGI_STAT].bonus
			end,

			---@param data table
			[INT_STAT]               = function(data)
				data.stats[INT_STAT].value = data.base_stats.intellect + data.stats[INT_STAT].bonus
			end,

			---@param data table
			[MELEE_DAMAGE_REDUCTION] = function(data)
				if TraceBug then print("update melee damage reduction A") end
				data.stats[MELEE_DAMAGE_REDUCTION].value = data.stats[MELEE_DAMAGE_REDUCTION].bonus
			end,

			---@param data table
			[RANGE_DAMAGE_REDUCTION] = function(data)
				data.stats[RANGE_DAMAGE_REDUCTION].value = data.stats[RANGE_DAMAGE_REDUCTION].bonus
			end,

			---@param data table
			[CONTROL_REDUCTION] = function(data)
				data.stats[CONTROL_REDUCTION].value = data.stats[CONTROL_REDUCTION].bonus
			end,

			---@param data table
			[CONTROL_DURATION] = function(data)
				data.stats[CONTROL_DURATION].value = data.stats[CONTROL_DURATION].bonus
			end,

			---@param data table
			[ATTACK_SPEED] = function(data)
				data.stats[ATTACK_SPEED].actual_bonus = ParamToPercent(data.stats[ATTACK_SPEED].bonus + math.floor((data.stats[AGI_STAT].value / 3) + 0.5), ATTACK_SPEED)
				local modificator = (1. - (data.stats[ATTACK_SPEED].actual_bonus) / 100.)

				data.stats[ATTACK_SPEED].value = data.equip_point[WEAPON_POINT].ATTACK_SPEED * modificator

				if data.stats[ATTACK_SPEED].value > 0.1 then
					BlzSetUnitAttackCooldown(data.Owner, data.stats[ATTACK_SPEED].value, 0)
					BlzSetUnitAttackCooldown(data.Owner, data.stats[ATTACK_SPEED].value, 1)
				else
					BlzSetUnitAttackCooldown(data.Owner, 0.1, 0)
					BlzSetUnitAttackCooldown(data.Owner, 0.1, 1)
				end
			end,

			---@param data table
			[CAST_SPEED] = function(data)
				--local agility_bonus = math.floor((data.stats[AGI_STAT].value / 3) + 0.5)
				data.stats[CAST_SPEED].value = ParamToPercent(data.stats[CAST_SPEED].bonus + math.floor((data.stats[AGI_STAT].value / 3) + 0.5), CAST_SPEED)
			end,

			---@param data table
			[MOVING_SPEED] = function(data)
				data.stats[MOVING_SPEED].value = (data.base_stats.moving_speed + data.stats[MOVING_SPEED].bonus) * data.stats[MOVING_SPEED].multiplier
				SetUnitMoveSpeed(data.Owner, data.stats[MOVING_SPEED].value < 0. and 0. or data.stats[MOVING_SPEED].value)
			end,

			---@param data table
			[ALL_RESIST] = function(data)
				data.stats[ALL_RESIST].value = data.stats[ALL_RESIST].bonus
			end,

			---@param data table
			[BLOCK_CHANCE] = function(data)
				local base = 0.
				if data.equip_point[OFFHAND_POINT] ~= nil and data.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND then
					base = data.equip_point[OFFHAND_POINT].BLOCK or 0.
				end
				data.stats[BLOCK_CHANCE].value = data.stats[BLOCK_CHANCE].bonus + base
			end,

			---@param data table
			[BLOCK_ABSORB] = function(data)
				local base = 0.
				if data.equip_point[OFFHAND_POINT] ~= nil and data.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND then
					base = data.equip_point[OFFHAND_POINT].BLOCK_RATE or 40.
				end
				data.stats[BLOCK_ABSORB].value = data.stats[BLOCK_ABSORB].bonus + base
			end,

			---@param data table
			[REFLECT_DAMAGE] = function(data)
				data.stats[REFLECT_DAMAGE].value = data.stats[REFLECT_DAMAGE].bonus
			end,

			---@param data table
			[REFLECT_MELEE_DAMAGE] = function(data)
				data.stats[REFLECT_MELEE_DAMAGE].value = (data.stats[REFLECT_MELEE_DAMAGE].bonus + data.stats[REFLECT_DAMAGE].value) * data.stats[REFLECT_DAMAGE].multiplier
			end,

			---@param data table
			[REFLECT_RANGE_DAMAGE] = function(data)
				data.stats[REFLECT_RANGE_DAMAGE].value = (data.stats[REFLECT_RANGE_DAMAGE].bonus + data.stats[REFLECT_DAMAGE].value) * data.stats[REFLECT_DAMAGE].multiplier
			end,

			---@param data table
			[HP_PER_HIT] = function(data)
				data.stats[HP_PER_HIT].value = data.stats[HP_PER_HIT].bonus
			end,

			---@param data table
			[MP_PER_HIT] = function(data)
				data.stats[MP_PER_HIT].value = data.stats[MP_PER_HIT].bonus
			end,

			---@param data table
			[BONUS_DEMON_DAMAGE] = function(data)
				data.stats[BONUS_DEMON_DAMAGE].value = data.stats[BONUS_DEMON_DAMAGE].bonus
			end,

			---@param data table
			[BONUS_UNDEAD_DAMAGE] = function(data)
				data.stats[BONUS_UNDEAD_DAMAGE].value = data.stats[BONUS_UNDEAD_DAMAGE].bonus
			end,

			---@param data table
			[BONUS_BEAST_DAMAGE] = function(data)
				data.stats[BONUS_BEAST_DAMAGE].value = data.stats[BONUS_BEAST_DAMAGE].bonus
			end,

			---@param data table
			[BONUS_HUMAN_DAMAGE] = function(data)
				data.stats[BONUS_HUMAN_DAMAGE].value = data.stats[BONUS_HUMAN_DAMAGE].bonus
			end,

			---@param data table
			[GOLD_BONUS] = function(data)
				data.stats[GOLD_BONUS].value = data.stats[GOLD_BONUS].bonus
			end,

			---@param data table
			[EXP_BONUS] = function(data)
				data.stats[EXP_BONUS].value = data.stats[EXP_BONUS].bonus
			end,

			---@param data table
			[DROP_BONUS] = function(data)
				data.stats[DROP_BONUS].value = data.stats[DROP_BONUS].bonus
			end,

			---@param data table
			[HEALING_BONUS] = function(data)
				data.stats[HEALING_BONUS].value = data.stats[HEALING_BONUS].bonus
			end,

			---@param data table
			[RESOURCE_GENERATION] = function(data)
				data.stats[RESOURCE_GENERATION].value = data.stats[RESOURCE_GENERATION].bonus
			end,

			---@param data table
			[DAMAGE_BOOST] = function(data)
				data.stats[DAMAGE_BOOST].value = data.stats[DAMAGE_BOOST].bonus
			end,

			---@param data table
			[VULNERABILITY] = function(data)
				data.stats[VULNERABILITY].value = data.stats[VULNERABILITY].bonus
			end,

			---@param data table
			[MANACOST] = function(data)
				if IsUnitType(data.Owner, UNIT_TYPE_HERO) and IsAHero(data.Owner) then
					UpdateBindedSkillsManacosts(data.Owner)
				end
			end,

			---@param data table
			[BONUS_MELEE_DAMAGE] = function(data)
				data.stats[BONUS_MELEE_DAMAGE].value = data.stats[BONUS_MELEE_DAMAGE].bonus
			end,

			---@param data table
			[BONUS_RANGE_DAMAGE] = function(data)
				data.stats[BONUS_RANGE_DAMAGE].value = data.stats[BONUS_RANGE_DAMAGE].bonus
			end,

			---@param data table
			[DAMAGE_TO_CLOSE_ENEMIES] = function(data)
				data.stats[DAMAGE_TO_CLOSE_ENEMIES].value = data.stats[DAMAGE_TO_CLOSE_ENEMIES].bonus
			end,

			---@param data table
			[DAMAGE_TO_DISTANT_ENEMIES] = function(data)
				data.stats[DAMAGE_TO_DISTANT_ENEMIES].value = data.stats[DAMAGE_TO_DISTANT_ENEMIES].bonus
			end,


			---@param data table
			[DAMAGE_TO_CC_ENEMIES] = function(data)
				data.stats[DAMAGE_TO_CC_ENEMIES].value = data.stats[DAMAGE_TO_CC_ENEMIES].bonus
			end,

			---@param data table
			[DODGE_CHANCE] = function(data)
				data.stats[DODGE_CHANCE].value = data.stats[DODGE_CHANCE].bonus
			end,

			---@param data table
			[COOLDOWN_REDUCTION] = function(data)
				local value = 1. - (ParamToPercent(data.stats[COOLDOWN_REDUCTION].bonus, COOLDOWN_REDUCTION) / 100.)
				data.stats[COOLDOWN_REDUCTION].value = math.max(value, 0.)
			end,

			---@param data table
			[ENDURANCE_POWER] = function(data)
				data.stats[ENDURANCE_POWER].value = 1. + (data.stats[ENDURANCE_POWER].bonus / 100.)
			end,

			---@param data table
			[DAMAGE_TO_ENDURANCE] = function(data)
				data.stats[DAMAGE_TO_ENDURANCE].value = 1. + (data.stats[DAMAGE_TO_ENDURANCE].bonus / 100.)
			end,

			---@param data table
			[HP_PER_KILL] = function(data)
				data.stats[HP_PER_KILL].value = data.stats[HP_PER_KILL].bonus
			end,

			---@param data table
			[MP_PER_KILL] = function(data)
				data.stats[MP_PER_KILL].value = data.stats[MP_PER_KILL].bonus
			end,

			---@param data table
			[MINION_POWER] = function(data)
				data.stats[MINION_POWER].value = 1. + (data.stats[MINION_POWER].bonus / 100.)
			end,

			---@param data table
			[BLEEDING_DAMAGE_BOOST] = function(data)
				data.stats[BLEEDING_DAMAGE_BOOST].value = 1. + (data.stats[BLEEDING_DAMAGE_BOOST].bonus / 100.)
			end,

			---@param data table
			[BLEEDING_DAMAGE_REDUCTION] = function(data)
				data.stats[BLEEDING_DAMAGE_REDUCTION].value = 1. + (data.stats[BLEEDING_DAMAGE_REDUCTION].bonus / 100.)
			end,

			---@param data table
			[BURNING_DAMAGE_BOOST] = function(data)
				data.stats[BURNING_DAMAGE_BOOST].value = 1. + (data.stats[BURNING_DAMAGE_BOOST].bonus / 100.)
			end,

			---@param data table
			[BURNING_DAMAGE_REDUCTION] = function(data)
				data.stats[BURNING_DAMAGE_REDUCTION].value = 1. + (data.stats[BURNING_DAMAGE_REDUCTION].bonus / 100.)
			end,

			---@param data table
			[POISONING_DAMAGE_BOOST] = function(data)
				data.stats[POISONING_DAMAGE_BOOST].value = 1. + (data.stats[POISONING_DAMAGE_BOOST].bonus / 100.)
			end,

			---@param data table
			[POISONING_DAMAGE_REDUCTION] = function(data)
				data.stats[POISONING_DAMAGE_REDUCTION].value = 1. + (data.stats[POISONING_DAMAGE_REDUCTION].bonus / 100.)
			end,

			---@param data table
			[DECAYING_DAMAGE_BOOST] = function(data)
				data.stats[DECAYING_DAMAGE_BOOST].value = 1. + (data.stats[DECAYING_DAMAGE_BOOST].bonus / 100.)
			end,

			---@param data table
			[DECAYING_DAMAGE_REDUCTION] = function(data)
				data.stats[DECAYING_DAMAGE_REDUCTION].value = 1. + (data.stats[DECAYING_DAMAGE_REDUCTION].bonus / 100.)
			end,
		}



		PARAMETER_NAME = {
			[PHYSICAL_ATTACK]     = LOCALE_LIST[my_locale].PHYSICAL_ATTACK_PARAM,
			[PHYSICAL_DEFENCE]    = LOCALE_LIST[my_locale].PHYSICAL_DEFENCE_PARAM,
			[MAGICAL_ATTACK]      = LOCALE_LIST[my_locale].MAGICAL_ATTACK_PARAM,
			[MAGICAL_SUPPRESSION] = LOCALE_LIST[my_locale].MAGICAL_SUPPRESSION_PARAM,

			[CRIT_CHANCE]         = LOCALE_LIST[my_locale].CRIT_CHANCE_PARAM,
			[CRIT_MULTIPLIER]     = LOCALE_LIST[my_locale].CRIT_MULTIPLIER_PARAM,

			[PHYSICAL_BONUS]      = LOCALE_LIST[my_locale].PHYSICAL_BONUS_PARAM,
			[ICE_BONUS]           = LOCALE_LIST[my_locale].ICE_BONUS_PARAM,
			[FIRE_BONUS]          = LOCALE_LIST[my_locale].FIRE_BONUS_PARAM,
			[LIGHTNING_BONUS]     = LOCALE_LIST[my_locale].LIGHTNING_BONUS_PARAM,
			[POISON_BONUS]        = LOCALE_LIST[my_locale].POISON_BONUS_PARAM,
			[ARCANE_BONUS]        = LOCALE_LIST[my_locale].ARCANE_BONUS_PARAM,
			[DARKNESS_BONUS]      = LOCALE_LIST[my_locale].DARKNESS_BONUS_PARAM,
			[HOLY_BONUS]          = LOCALE_LIST[my_locale].HOLY_BONUS_PARAM,

			[ALL_RESIST]          = LOCALE_LIST[my_locale].ALL_RESIST_PARAM,
			[PHYSICAL_RESIST]     = LOCALE_LIST[my_locale].PHYSICAL_RESIST_PARAM,
			[ICE_RESIST]          = LOCALE_LIST[my_locale].ICE_RESIST_PARAM,
			[FIRE_RESIST]         = LOCALE_LIST[my_locale].FIRE_RESIST_PARAM,
			[LIGHTNING_RESIST]    = LOCALE_LIST[my_locale].LIGHTNING_RESIST_PARAM,
			[POISON_RESIST]       = LOCALE_LIST[my_locale].POISON_RESIST_PARAM,
			[ARCANE_RESIST]       = LOCALE_LIST[my_locale].ARCANE_RESIST_PARAM,
			[DARKNESS_RESIST]     = LOCALE_LIST[my_locale].DARKNESS_RESIST_PARAM,
			[HOLY_RESIST]         = LOCALE_LIST[my_locale].HOLY_RESIST_PARAM,

			[HP_REGEN]            = LOCALE_LIST[my_locale].HP_REGEN_PARAM,
			[MP_REGEN]            = LOCALE_LIST[my_locale].MP_REGEN_PARAM,

			[HP_VALUE]            = LOCALE_LIST[my_locale].HP_VALUE_PARAM,
			[MP_VALUE]            = LOCALE_LIST[my_locale].MP_VALUE_PARAM,

			[STR_STAT]            = LOCALE_LIST[my_locale].STR_STAT_PARAM,
			[AGI_STAT]            = LOCALE_LIST[my_locale].AGI_STAT_PARAM,
			[INT_STAT]            = LOCALE_LIST[my_locale].INT_STAT_PARAM,
			[VIT_STAT]            = LOCALE_LIST[my_locale].VIT_STAT_PARAM,

			[MELEE_DAMAGE_REDUCTION]  = LOCALE_LIST[my_locale].MELEE_DAMAGE_REDUCTION_PARAM,
			[RANGE_DAMAGE_REDUCTION]  = LOCALE_LIST[my_locale].RANGE_DAMAGE_REDUCTION_PARAM,
			[CONTROL_REDUCTION]       = LOCALE_LIST[my_locale].CONTROL_REDUCTION_PARAM,
			[CONTROL_DURATION]  	  = LOCALE_LIST[my_locale].CONTROL_DURATION_PARAM,

			[ATTACK_SPEED]            = LOCALE_LIST[my_locale].ATTACK_SPEED_PARAM,
			[CAST_SPEED]              = LOCALE_LIST[my_locale].CAST_SPEED_PARAM,
			[MOVING_SPEED]            = LOCALE_LIST[my_locale].MOVING_SPEED_PARAM,

			[BLOCK_CHANCE]            = LOCALE_LIST[my_locale].BLOCK_CHANCE_PARAM,
			[BLOCK_ABSORB]            = LOCALE_LIST[my_locale].BLOCK_ABSORB_PARAM,


			[REFLECT_DAMAGE]   		 = LOCALE_LIST[my_locale].REFLECT_DAMAGE_PARAM,
			[REFLECT_MELEE_DAMAGE]   = LOCALE_LIST[my_locale].REFLECT_MELEE_DAMAGE_PARAM,
			[REFLECT_RANGE_DAMAGE]   = LOCALE_LIST[my_locale].REFLECT_RANGE_DAMAGE_PARAM,

			[HP_PER_HIT]   = LOCALE_LIST[my_locale].HP_PER_HIT_PARAM,
			[MP_PER_HIT]   = LOCALE_LIST[my_locale].MP_PER_HIT_PARAM,

			[BONUS_DEMON_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_DEMON_DAMAGE_PARAM,
			[BONUS_UNDEAD_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_UNDEAD_DAMAGE_PARAM,
			[BONUS_BEAST_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_BEAST_DAMAGE_PARAM,
			[BONUS_HUMAN_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_HUMAN_DAMAGE_PARAM,

			[GOLD_BONUS]   = LOCALE_LIST[my_locale].GOLD_BONUS_PARAM,
			[EXP_BONUS]   = LOCALE_LIST[my_locale].EXP_BONUS_PARAM,
			[DROP_BONUS]   = LOCALE_LIST[my_locale].DROP_BONUS_PARAM,

			[HEALING_BONUS]   = LOCALE_LIST[my_locale].HEALING_BONUS_PARAM,
			[DAMAGE_BOOST]   = LOCALE_LIST[my_locale].DAMAGE_BOOST_PARAM,
			[VULNERABILITY]   = LOCALE_LIST[my_locale].VULNERABILITY_PARAM,
			[MANACOST]   = LOCALE_LIST[my_locale].MANACOST_PARAM,

			[BONUS_MELEE_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_MELEE_DAMAGE,
			[BONUS_RANGE_DAMAGE]   = LOCALE_LIST[my_locale].BONUS_RANGE_DAMAGE,
			[DAMAGE_TO_CLOSE_ENEMIES]   = LOCALE_LIST[my_locale].DAMAGE_TO_CLOSE_ENEMIES,
			[DAMAGE_TO_DISTANT_ENEMIES]   = LOCALE_LIST[my_locale].DAMAGE_TO_DISTANT_ENEMIES,

			[DAMAGE_TO_CC_ENEMIES]   = LOCALE_LIST[my_locale].DAMAGE_TO_CC_ENEMIES,
			[DODGE_CHANCE] = LOCALE_LIST[my_locale].DODGE_CHANCE,

			[COOLDOWN_REDUCTION] = LOCALE_LIST[my_locale].COOLDOWN_REDUCTION,
			[ENDURANCE_POWER] = LOCALE_LIST[my_locale].ENDURANCE_POWER,
			[DAMAGE_TO_ENDURANCE] = LOCALE_LIST[my_locale].DAMAGE_TO_ENDURANCE,

			[HP_PER_KILL] = LOCALE_LIST[my_locale].HP_PER_KILL_PARAM,
			[MP_PER_KILL] = LOCALE_LIST[my_locale].MP_PER_KILL_PARAM,

			[MINION_POWER] = LOCALE_LIST[my_locale].MINION_POWER_PARAM,

			[BLEEDING_DAMAGE_BOOST] = LOCALE_LIST[my_locale].BLEEDING_DAMAGE_BOOST_PARAM,
			[BLEEDING_DAMAGE_REDUCTION] = LOCALE_LIST[my_locale].BLEEDING_DAMAGE_REDUCTION_PARAM,

			[BURNING_DAMAGE_BOOST] = LOCALE_LIST[my_locale].BURNING_DAMAGE_BOOST_PARAM,
			[BURNING_DAMAGE_REDUCTION] = LOCALE_LIST[my_locale].BURNING_DAMAGE_REDUCTION_PARAM,

			[POISONING_DAMAGE_BOOST] = LOCALE_LIST[my_locale].POISONING_DAMAGE_BOOST_PARAM,
			[POISONING_DAMAGE_REDUCTION] = LOCALE_LIST[my_locale].POISONING_DAMAGE_REDUCTION_PARAM,

			[DECAYING_DAMAGE_BOOST] = LOCALE_LIST[my_locale].DECAYING_DAMAGE_BOOST_PARAM,
			[DECAYING_DAMAGE_REDUCTION] = LOCALE_LIST[my_locale].DECAYING_DAMAGE_REDUCTION_PARAM,

			[RESOURCE_GENERATION] = LOCALE_LIST[my_locale].RESOURCE_GENERATION_PARAM,
		}


		SpecialSymbolParam = {
			[ATTACK_SPEED] = true,
			[CAST_SPEED] = true,
			[CRIT_CHANCE] = true,
			[BLOCK_CHANCE] = true,
			[MELEE_DAMAGE_REDUCTION] = true,
			[RANGE_DAMAGE_REDUCTION] = true,
			[CONTROL_REDUCTION] = true,
			[CONTROL_DURATION] = true,
			[EXP_BONUS] = true,
			[GOLD_BONUS] = true,
			[DROP_BONUS] = true,
			[HEALING_BONUS] = true,
			[DAMAGE_BOOST] = true,
			[VULNERABILITY] = true,
			[BONUS_MELEE_DAMAGE] = true,
			[BONUS_RANGE_DAMAGE] = true,
			[DAMAGE_TO_CLOSE_ENEMIES] = true,
			[DAMAGE_TO_DISTANT_ENEMIES] = true,
			[DAMAGE_TO_CC_ENEMIES] = true,
			[COOLDOWN_REDUCTION] = true,
			[ENDURANCE_POWER] = true,
			[DAMAGE_TO_ENDURANCE] = true,
			[MINION_POWER] = true,
			[PHYSICAL_BONUS] = true,
			[PHYSICAL_RESIST] = true,
			[FIRE_BONUS] = true,
			[FIRE_RESIST] = true,
			[ICE_BONUS] = true,
			[ICE_RESIST] = true,
			[LIGHTNING_BONUS] = true,
			[LIGHTNING_RESIST] = true,
			[HOLY_BONUS] = true,
			[HOLY_RESIST] = true,
			[POISON_BONUS] = true,
			[POISON_RESIST] = true,
			[DARKNESS_BONUS] = true,
			[DARKNESS_RESIST] = true,
			[ARCANE_BONUS] = true,
			[ARCANE_RESIST] = true,
			[ALL_RESIST] = true,
			[RESOURCE_GENERATION] = true,
			[BONUS_BEAST_DAMAGE] = true,
			[BONUS_UNDEAD_DAMAGE] = true,
			[BONUS_DEMON_DAMAGE] = true,
			[BONUS_HUMAN_DAMAGE] = true,
			[BLEEDING_DAMAGE_BOOST] = true,
			[BLEEDING_DAMAGE_REDUCTION] = true,
			[BURNING_DAMAGE_BOOST] = true,
			[BURNING_DAMAGE_REDUCTION] = true,
			[POISONING_DAMAGE_BOOST] = true,
			[POISONING_DAMAGE_REDUCTION] = true,
			[DECAYING_DAMAGE_BOOST] = true,
			[DECAYING_DAMAGE_REDUCTION] = true,
		}


	end

end