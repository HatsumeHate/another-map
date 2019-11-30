do
	-- parameters types
	PARAMETERS_COUNT       = 41

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

	MELEE_REFLECT_DAMAGE   = 40
	RANGE_REFLECT_DAMAGE   = 41

	VAMPIRIC_DAMAGE        = 42

	
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
	
	-- limits
	VALUE_BY_PERCENT_1     = 11
	FIRST_DEF_LIMIT        = 350
	VALUE_BY_PERCENT_2     = 15
	SECOND_DEF_LIMIT       = 650
	VALUE_BY_PERCENT_3     = 19
	
	--маг атака
	MA_VALUE_BY_PERCENT_1  = 5
	MA_FIRST_LIMIT         = 275
	MA_VALUE_BY_PERCENT_2  = 7
	MA_SECOND_LIMIT        = 340
	MA_VALUE_BY_PERCENT_3  = 12
	
	
	--защита в процент
	---@param x integer
	function DefenceToPercent(x)
		if x <= FIRST_DEF_LIMIT then
			return x / VALUE_BY_PERCENT_1
		elseif x > FIRST_DEF_LIMIT and x <= SECOND_DEF_LIMIT then
			return FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1 + (x - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2
		elseif x > SECOND_DEF_LIMIT then
			return FIRST_DEF_LIMIT / VALUE_BY_PERCENT_1 + (SECOND_DEF_LIMIT - FIRST_DEF_LIMIT) / VALUE_BY_PERCENT_2 + (x - SECOND_DEF_LIMIT) / VALUE_BY_PERCENT_3
		end
		return 0
	end
	
	--маг атака в процент
	---@param x integer
	function MagicAttackToPercent(x)
		if x <= MA_FIRST_LIMIT then
			return x / MA_VALUE_BY_PERCENT_1
		elseif x > MA_FIRST_LIMIT and x <= MA_SECOND_LIMIT then
			return MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1 + (x - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2
		elseif x > MA_SECOND_LIMIT then
			return MA_FIRST_LIMIT / MA_VALUE_BY_PERCENT_1 + (MA_SECOND_LIMIT - MA_FIRST_LIMIT) / MA_VALUE_BY_PERCENT_2 + (x - MA_SECOND_LIMIT) / MA_VALUE_BY_PERCENT_3
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





    --TODO stats +-



	
	local PARAMETER_NAME = {
		[PHYSICAL_ATTACK]     = 'Физическая атака',
		[PHYSICAL_DEFENCE]    = 'Физическая защита',
		[MAGICAL_ATTACK]    = 'Магическая атака',
		[MAGICAL_SUPPRESSION] = 'Подавление магии',
		
		[CRIT_CHANCE]         = 'Критический шанс',
		[CRIT_MULTIPLIER]     = 'Критический множитель',
		
		[PHYSICAL_BONUS]      = 'Физический урон',
		[ICE_BONUS]           = 'Урон от льда',
		[FIRE_BONUS]          = 'Урон от огня',
		[LIGHTNING_BONUS]     = 'Урон от молнии',
		[POISON_BONUS]        = 'Урон от яда',
		[ARCANE_BONUS]        = 'Урон от тайной магии',
		[DARKNESS_BONUS]      = 'Урон от тьмы',
		[HOLY_BONUS]          = 'Урон от святости',

		[ALL_RESIST]          = 'Сопротивления',
		[PHYSICAL_RESIST]     = 'Сопротивление физ атакам',
		[ICE_RESIST]          = 'Сопротивление холоду',
		[FIRE_RESIST]         = 'Сопротивление огню',
		[LIGHTNING_RESIST]    = 'Сопротивление молнии',
		[POISON_RESIST]       = 'Сопротивление ядам',
		[ARCANE_RESIST]       = 'Сопротивление тайной магии',
		[DARKNESS_RESIST]     = 'Сопротивление тьме',
		[HOLY_RESIST]         = 'Сопротивление святости',
		
		[HP_REGEN]            = 'Восстановление здоровья',
		[MP_REGEN]            = 'Восстановление ресурса',
		
		[HP_VALUE]            = 'Здоровье',
		[MP_VALUE]            = 'Ресурс',
		
		[STR_STAT]            = 'Сила',
		[AGI_STAT]            = 'Ловкость',
		[INT_STAT]            = 'Разум',
		[VIT_STAT]            = 'Выносливость',

		[MELEE_DAMAGE_REDUCTION]  = 'Урон от атак ближнего боя',
		[RANGE_DAMAGE_REDUCTION]  = 'Урон от атак дальнего боя',
		[CONTROL_REDUCTION]       = 'Снижение времени контроля',

		[ATTACK_SPEED]            = 'Скорость атаки',
		[CAST_SPEED]              = 'Скорость заклинаний',
		[MOVING_SPEED]            = 'Скорость бега',

		[BLOCK_CHANCE]            = 'Шанс блока',
		[BLOCK_ABSORB]            = 'Поглощение урона',

		[MELEE_REFLECT_DAMAGE]   = 'Отражение урона ближнего боя',
		[RANGE_REFLECT_DAMAGE]   = 'Отражение урона дальнего боя'

	}


	local PARAMETER_FUNC = {
		---@param data table
		[PHYSICAL_ATTACK]        = function(data)
			local total_damage = data.equip_point[WEAPON_POINT].DAMAGE
			
			if data.equip_point[OFFHAND_POINT] ~= nil then
				if data.equip_point[OFFHAND_POINT].item_type == ITEM_TYPE_WEAPON then
					total_damage = total_damage + (data.equip_point[OFFHAND_POINT].DAMAGE * 0.5)
				end
			end

			data.stats[PHYSICAL_ATTACK].value = (total_damage * GetBonus_STR(data.stats[STR_STAT].value) + data.stats[PHYSICAL_ATTACK].bonus) * data.stats[PHYSICAL_ATTACK].multiplier
		end,
		
		---@param data table
		[PHYSICAL_DEFENCE]       = function(data)
			local defence = data.stats[AGI_STAT].value * 2
			
			for i = 2, 6 do
				if data.equip_point[i] ~= nil then
					defence = defence + data.equip_point[i].DEFENCE
				end
			end
			
			data.stats[PHYSICAL_DEFENCE].value = (defence + data.stats[PHYSICAL_DEFENCE].bonus) * data.stats[PHYSICAL_DEFENCE].multiplier
		end,


		---@param data table
		[MAGICAL_ATTACK]        = function(data)
			local total_damage = data.equip_point[WEAPON_POINT].DAMAGE
			data.stats[MAGICAL_ATTACK].value = (total_damage * GetBonus_INT(data.stats[INT_STAT].value) + data.stats[MAGICAL_ATTACK].bonus) * data.stats[MAGICAL_ATTACK].multiplier
		end,

        ---@param data table
        [MAGICAL_SUPPRESSION]       = function(data)
            local defence = data.stats[INT_STAT].value

            for i = 7, 9 do
                if data.equip_point[i] ~= nil then
                    defence = defence + data.equip_point[i].SUPPRESSION
                end
            end

            data.stats[MAGICAL_SUPPRESSION].value = (defence + data.stats[MAGICAL_SUPPRESSION].bonus) * data.stats[MAGICAL_SUPPRESSION].multiplier
        end,

		---@param data table
		[CRIT_CHANCE]            = function(data)
			data.stats[CRIT_CHANCE].value = (data.equip_point[WEAPON_POINT].CRIT_CHANCE + data.stats[CRIT_CHANCE].bonus) * data.stats[CRIT_CHANCE].multiplier
		end,
		
		---@param data table
		[CRIT_MULTIPLIER]        = function(data)
			data.stats[CRIT_MULTIPLIER].value = (data.equip_point[WEAPON_POINT].CRIT_MULTIPLIER + data.stats[CRIT_MULTIPLIER].bonus) * data.stats[CRIT_MULTIPLIER].multiplier
		end,
		
		---@param data table
		[HP_REGEN]               = function(data)
			data.stats[HP_REGEN].value = (data.base_stats.hp_regen + data.stats[HP_REGEN].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_REGEN].multiplier
            BlzSetUnitRealField(data.Owner, UNIT_RF_HIT_POINTS_REGENERATION_RATE, data.stats[HP_REGEN].value)
		end,
		
		---@param data table
		[MP_REGEN]               = function(data)
			data.stats[MP_REGEN].value = (data.base_stats.mp_regen + data.stats[MP_REGEN].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_REGEN].multiplier
				if not data.is_mp_static then
					BlzSetUnitRealField(data.Owner, UNIT_RF_MANA_REGENERATION, data.stats[MP_REGEN].value)
				end
		end,
		
		---@param data table
		[HP_VALUE]               = function(data)
			local ratio = GetUnitState(data.Owner, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(data.Owner)
				data.stats[HP_VALUE].value = (data.base_stats.health + data.stats[HP_VALUE].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_VALUE].multiplier
				BlzSetUnitMaxHP(data.Owner, R2I(data.stats[HP_VALUE].value))
				SetUnitState(data.Owner, UNIT_STATE_LIFE, R2I(data.stats[HP_VALUE].value) * ratio)
		end,

		---@param data table
		[MP_VALUE]               = function(data)
			data.stats[MP_VALUE].value = (data.base_stats.mana + data.stats[MP_VALUE].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_VALUE].multiplier
				if data.have_mp then
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
        [ATTACK_SPEED] = function(data)
            data.stats[ATTACK_SPEED].value = data.equip_point[WEAPON_POINT].ATTACK_SPEED * ((1. - data.stats[ATTACK_SPEED].multiplier) + 1.)
			if data.stats[ATTACK_SPEED].value > 0. then
				BlzSetUnitAttackCooldown(data.Owner, data.stats[ATTACK_SPEED].value, 0)
				BlzSetUnitAttackCooldown(data.Owner, data.stats[ATTACK_SPEED].value, 1)
			else
				BlzSetUnitAttackCooldown(data.Owner, 0.1, 0)
				BlzSetUnitAttackCooldown(data.Owner, 0.1, 1)
			end
		end,

        ---@param data table
        [CAST_SPEED] = function(data)
            data.stats[CAST_SPEED].value = data.stats[CAST_SPEED].bonus
        end,

        ---@param data table
        [MOVING_SPEED] = function(data)
            data.stats[MOVING_SPEED].value = (data.base_stats.moving_speed + data.stats[MOVING_SPEED].bonus) * data.stats[MOVING_SPEED].multiplier
            SetUnitMoveSpeed(data.Owner, data.stats[MOVING_SPEED].value < 0. and 0. or I2R(data.stats[MOVING_SPEED].value))
        end,

		---@param data table
		[ALL_RESIST] = function(data)
			data.stats[ALL_RESIST].value = data.stats[ALL_RESIST].bonus
		end,

		---@param data table
		[BLOCK_CHANCE] = function(data)
			data.stats[BLOCK_CHANCE].value = data.stats[BLOCK_CHANCE].bonus
		end,

		---@param data table
		[BLOCK_ABSORB] = function(data)
			data.stats[BLOCK_ABSORB].value = data.stats[BLOCK_ABSORB].bonus
		end,

		---@param data table
		[MELEE_REFLECT_DAMAGE] = function(data)
			data.stats[MELEE_REFLECT_DAMAGE].value = data.stats[MELEE_REFLECT_DAMAGE].bonus
		end,

		---@param data table
		[RANGE_REFLECT_DAMAGE] = function(data)
			data.stats[RANGE_REFLECT_DAMAGE].value = data.stats[RANGE_REFLECT_DAMAGE].bonus
		end
	}

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


	---@param param integer
	---@param value real
	---@param plus boolean
	---@param target unit
	---@param method number
	function ModifyStat(target, param, value, method, plus)
		local unit_data = GetUnitData(target)

			if method == MULTIPLY_BONUS then
				unit_data.stats[param].multiplier = plus and unit_data.stats[param].multiplier * value or unit_data.stats[param].multiplier / value
			else
				unit_data.stats[param].bonus = plus and unit_data.stats[param].bonus + value or unit_data.stats[param].bonus - value
			end

        if param == STR_STAT then
            PARAMETER_FUNC[PHYSICAL_ATTACK](unit_data)
        elseif param == VIT_STAT then
            PARAMETER_FUNC[HP_VALUE](unit_data)
            PARAMETER_FUNC[HP_REGEN](unit_data)
        elseif param == AGI_STAT then
            PARAMETER_FUNC[PHYSICAL_DEFENCE](unit_data)
        elseif param == INT_STAT then
            PARAMETER_FUNC[MAGICAL_SUPPRESSION](unit_data)
            PARAMETER_FUNC[MAGICAL_ATTACK](unit_data)
            PARAMETER_FUNC[MP_VALUE](unit_data)
            PARAMETER_FUNC[MP_REGEN](unit_data)
        end

		PARAMETER_FUNC[param](unit_data)
	end

	---@param unit_data table
	function UpdateParameters(unit_data)
		for i = 1, PARAMETERS_COUNT do
			PARAMETER_FUNC[i](unit_data)
			--unit_data.stats[i].update(unit_data, i)
		end
	end


	function CreateParametersData()
		local parameters = { }

		for i = 1, PARAMETERS_COUNT do
			parameters[i] = NewStat(i)
		end

		return parameters
	end

end