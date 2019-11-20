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
	
	PHYSICAL_RESIST        = 15
	FIRE_RESIST            = 16
	ICE_RESIST             = 17
	LIGHTNING_RESIST       = 18
	POISON_RESIST          = 19
	ARCANE_RESIST          = 20
	DARKNESS_RESIST        = 21
	HOLY_RESIST            = 22
	
	PHYSICAL_BONUS         = 23
	FIRE_BONUS             = 24
	ICE_BONUS              = 25
	LIGHTNING_BONUS        = 26
	POISON_BONUS           = 27
	ARCANE_BONUS           = 28
	DARKNESS_BONUS         = 29
	HOLY_BONUS             = 30
	
	MELEE_DAMAGE_REDUCTION = 31
	RANGE_DAMAGE_REDUCTION = 32
    CONTROL_REDUCTION      = 33

    ATTACK_SPEED           = 34
    CAST_SPEED             = 35
    MOVING_SPEED           = 36


	
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
	
	local PARAMETER_NAME = {
		[PHYSICAL_ATTACK]     = 'Физическая атака',
		[PHYSICAL_DEFENCE]    = 'Физическая защита',
		[MAGICAL_ATTACK]    = 'Магическая атака',
		[MAGICAL_SUPPRESSION] = 'Подавление магии',
		
		[CRIT_CHANCE]         = 'Критческий шанс',
		[CRIT_MULTIPLIER]     = 'Критический множитель',
		
		[PHYSICAL_BONUS]      = 'Физический урон',
		[ICE_BONUS]           = 'Урон от льда',
		[FIRE_BONUS]          = 'Урон от огня',
		[LIGHTNING_BONUS]     = 'Урон от молнии',
		[POISON_BONUS]        = 'Урон от яда',
		[ARCANE_RESIST]       = 'Урон от тайной магии',
		[DARKNESS_BONUS]      = 'Урон от тьмы',
		[HOLY_BONUS]          = 'Урон от святости',
		
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
		[MOVING_SPEED]            = 'Скорость бега'

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
				if data.equip_slot[i] ~= nil then
					defence = defence + data.equip_slot[i].DEFENCE
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
                if data.equip_slot[i] ~= nil then
                    defence = defence + data.equip_slot[i].SUPPRESSION
                end
            end

            data.stats[MAGICAL_SUPPRESSION].value = (defence + data[MAGICAL_SUPPRESSION].bonus) * data.stats[MAGICAL_SUPPRESSION].multiplier
        end,
		
		---@param data table
		[CRIT_CHANCE]            = function(data)
            print(data.equip_slot[WEAPON_POINT].NAME)
            print(data.equip_slot[WEAPON_POINT].CRIT_CHANCE)
			data.stats[CRIT_CHANCE].value = (data.equip_slot[WEAPON_POINT].CRIT_CHANCE + data.stats[CRIT_CHANCE].bonus) * data.stats[CRIT_CHANCE].multiplier
		end,
		
		---@param data table
		[CRIT_MULTIPLIER]        = function(data)

			data.stats[CRIT_MULTIPLIER].value = (data.equip_slot[WEAPON_POINT].CRIT_MULTIPLIER + data.stats[CRIT_MULTIPLIER].bonus) * data.stats[CRIT_MULTIPLIER].multiplier
		end,
		
		---@param data table
		[HP_REGEN]               = function(data)
			data.stats[HP_REGEN].value = (data.base_stats.hp_regen + data.stats[HP_REGEN].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_REGEN].multiplier
            BlzSetUnitRealField(data.Owner, UNIT_RF_HIT_POINTS_REGENERATION_RATE, data.stats[HP_REGEN].value)
		end,
		
		---@param data table
		[MP_REGEN]               = function(data)
			data.stats[MP_REGEN].value = (data.base_stats.mp_regen + data.stats[MP_REGEN].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_REGEN].multiplier
            BlzSetUnitRealField(data.Owner, UNIT_RF_MANA_REGENERATION, data.stats[HP_REGEN].value)
		end,
		
		---@param data table
		[HP_VALUE]               = function(data)
			data.stats[HP_VALUE].value = (data.base_stats.health + data.stats[HP_VALUE].bonus) * GetBonus_VIT(data.stats[VIT_STAT].value) * data.stats[HP_VALUE].multiplier
            BlzSetUnitMaxHP(data.Owner, data.stats[HP_VALUE].value)
		end,

		---@param data table
		[MP_VALUE]               = function(data)
			data.stats[MP_VALUE].value = (data.base_stats.mana + data.stats[MP_VALUE].bonus) * GetBonus_INT(data.stats[INT_STAT].value) * data.stats[MP_VALUE].multiplier
            BlzSetUnitMaxMana(data.Owner, data.stats[MP_VALUE].value)
		end,

		---@param data table
		[PHYSICAL_RESIST]       = function(data)
			data.stats[PHYSICAL_RESIST].value = data.stats[PHYSICAL_RESIST].bonus
		end,
		
		---@param data table
		[FIRE_RESIST]            = function(data)
			data.stats[FIRE_RESIST].value = data.stats[FIRE_RESIST].bonus
		end,
		
		---@param data table
		[ICE_RESIST]             = function(data)
			data.stats[ICE_RESIST].value = data.stats[ICE_RESIST].bonus
		end,
		
		---@param data table
		[LIGHTNING_RESIST]       = function(data)
			data.stats[LIGHTNING_RESIST].value = data.stats[LIGHTNING_RESIST].bonus
		end,
		
		---@param data table
		[POISON_RESIST]          = function(data)
			data.stats[POISON_RESIST].value = data.stats[POISON_RESIST].bonus
		end,
		
		---@param data table
		[ARCANE_RESIST]          = function(data)
			data.stats[ARCANE_RESIST].value = data.stats[ARCANE_RESIST].bonus
		end,
		
		---@param data table
		[DARKNESS_RESIST]        = function(data)
			data.stats[DARKNESS_RESIST].value = data.stats[DARKNESS_RESIST].bonus
		end,
		
		---@param data table
		[HOLY_RESIST]            = function(data)
			data.stats[HOLY_RESIST].value = data.stats[HOLY_RESIST].bonus
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
            data.stats[ATTACK_SPEED].value = data.equip_point[WEAPON_POINT].attack_speed * ((1 - data[ATTACK_SPEED].multiplier) + 1)
            BlzSetUnitWeaponRealField(data.Owner, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, data.stats[ATTACK_SPEED].value)
        end,

        ---@param data table
        [CAST_SPEED] = function(data)
            data.stats[CAST_SPEED].value = data[CAST_SPEED].bonus
        end,

        ---@param data table
        [MOVING_SPEED] = function(data)
            data.stats[MOVING_SPEED].value = (data.base_stats.moving_speed + data[MOVING_SPEED].bonus) * data[MOVING_SPEED].multiplier
            SetUnitMoveSpeed(data.Owner, data.stats[MOVING_SPEED].value)
        end

	}
	
	---@param type integer
	function GetParameterName(type)
		return PARAMETER_NAME[type]
	end
	
	function NewStat(stat_type)
		return {
			stat_type  = stat_type,
			
			value      = 0,
			multiplier = 1,
			bonus      = 0,
			
			
			---@param data table
			---@param param integer
			---@param value real
			---@param flag boolean
			multiply   = function(data, param, value, flag)
				param.multiplier = flag and param.multiplier * value or param.multiplier / value
				PARAMETER_FUNC[param](data)
			end,
			
			---@param data table
			---@param param integer
			---@param value real
			---@param flag boolean
			summ       = function(data, param, value, flag)
				param.bonus = flag and param.bonus + value or param.bonus - value
				PARAMETER_FUNC[param](data)
			end,

            update     = function(data, param)
				print("processing update of " .. GetParameterName(param))
                PARAMETER_FUNC[param](data)
            end
		}
	
	end
	
	function CreateParametersData()
		local parameters = { }
		
		for i = 1, 36 do
			parameters[i] = NewStat(i)
		end
		
		return parameters
	end
end