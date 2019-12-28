-- Ставь блоки если уж так хочется отступов
do
	ITEM_TEMPLATE_DATA = {} -- данные для ТИПОВ предметов по равкоду
	ITEM_DATA          = {} -- данные для КАЖДОГО предмета по хэндлу
	
	ITEM_TYPE_WEAPON     = 1
	ITEM_TYPE_ARMOR      = 2
	ITEM_TYPE_JEWELRY    = 3
	ITEM_TYPE_OFFHAND    = 4
    ITEM_TYPE_CONSUMABLE = 5
    ITEM_TYPE_GEM        = 6

	
	FIST_WEAPON           = 1
	BOW_WEAPON            = 2
	BLUNT_WEAPON          = 3
	GREATBLUNT_WEAPON     = 4
	SWORD_WEAPON          = 5
	GREATSWORD_WEAPON     = 6
	AXE_WEAPON            = 7
	GREATAXE_WEAPON       = 8
	DAGGER_WEAPON         = 9
	STAFF_WEAPON          = 10
	JAWELIN_WEAPON        = 11
	HEAD_ARMOR            = 12
	CHEST_ARMOR           = 13
	LEGS_ARMOR            = 14
	HANDS_ARMOR           = 15
	RING_JEWELRY          = 16
	NECKLACE_JEWELRY      = 17
    THROWING_KNIFE_WEAPON = 18

	
	COMMON_ITEM        = 1
	RARE_ITEM          = 2
	MAGIC_ITEM         = 3
	SET_ITEM           = 4
	UNIQUE_ITEM        = 5

	EQUIP_SOUND = 1
	UNEQUIP_SOUND = 2
	INTERACT_SOUND = 3

	
	---@param a table
	---@param b table
	local function ItemMergeData(a, b)
		if b == nil then return a end
		for k, v in pairs(b) do
			a[k] = v
		end
		return a
	end



	local weapons = {
		[FIST_WEAPON]       = {
			DAMAGE          = 4,
			ATTACK_SPEED    = 1.8,
			CRIT_CHANCE     = 0,
			CRIT_MULTIPLIER = 1.5,
			RANGE           = 90,
			DISPERSION      = { 0.9, 1.1 },
			WEAPON_SOUND    = WEAPON_TYPE_WOOD_LIGHT_BASH
		},
		[SWORD_WEAPON]      = {
			ATTACK_SPEED    = 1.6,
			CRIT_CHANCE     = 4,
			CRIT_MULTIPLIER = 2.1,
			RANGE           = 90,
			DISPERSION      = { 0.9, 1.1 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_SLICE
		},
		[GREATSWORD_WEAPON] = {
			ATTACK_SPEED    = 2.3,
			CRIT_CHANCE     = 5,
			CRIT_MULTIPLIER = 1.6,
			RANGE           = 100,
			ANGLE           = 35, --math.pi / 5,  36 градусов
			DISPERSION      = { 0.9, 1.1 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_SLICE
		},
		[AXE_WEAPON]        = {
			ATTACK_SPEED    = 1.5,
			CRIT_CHANCE     = 6,
			CRIT_MULTIPLIER = 1.7,
			RANGE           = 100,
			DISPERSION      = { 0.85, 1.15 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_CHOP
		},
		[GREATAXE_WEAPON]   = {
			ATTACK_SPEED    = 2.2,
			CRIT_CHANCE     = 6,
			CRIT_MULTIPLIER = 1.7,
			RANGE           = 110,
			DISPERSION      = { 0.85, 1.15 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_CHOP
		},
		[DAGGER_WEAPON]     = {
			ATTACK_SPEED    = 1.4,
			CRIT_CHANCE     = 9,
			CRIT_MULTIPLIER = 2.3,
			RANGE           = 90,
			ANGLE           = 25, --math.pi / 7.2, -- 25 градусов
			DISPERSION      = { 0.9, 1.1 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_LIGHT_SLICE
		},
		[STAFF_WEAPON]      = {
			ATTACK_SPEED    = 2.4,
			CRIT_CHANCE     = 9,
			CRIT_MULTIPLIER = 2.3,
			RANGE           = 100,
			DISPERSION      = { 0.85, 1.15 },
			WEAPON_SOUND    = WEAPON_TYPE_WOOD_MEDIUM_BASH
		},
		[JAWELIN_WEAPON]    = {
			ATTACK_SPEED    = 2.3,
			CRIT_CHANCE     = 5,
			CRIT_MULTIPLIER = 1.7,
			RANGE           = 110,
			DISPERSION      = { 0.85, 1.15 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_BASH
		},
		[BLUNT_WEAPON]      = {
			ATTACK_SPEED    = 1.7,
			CRIT_CHANCE     = 5,
			CRIT_MULTIPLIER = 1.6,
			RANGE           = 90,
			DISPERSION      = { 0.8, 1.2 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_BASH
		},
		[GREATBLUNT_WEAPON] = {
			ATTACK_SPEED    = 2.4,
			CRIT_CHANCE     = 5,
			CRIT_MULTIPLIER = 1.7,
			RANGE           = 100,
			DISPERSION      = { 0.8, 1.2 },
			WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_BASH
		},
		[BOW_WEAPON]        = {
			ATTACK_SPEED    = 2.6,
			CRIT_CHANCE     = 7,
			CRIT_MULTIPLIER = 2.2,
			RANGE           = 1000,
            ranged          = true,
			DISPERSION      = { 0.75, 1.25 },
			WEAPON_SOUND    = nil
		}
	}
	
	for k, v in pairs(weapons) do
		v.TYPE    = ITEM_TYPE_WEAPON
		v.SUBTYPE = k
	end


    local function GetItemTemplate()
        return {
                item               = nil,
                NAME               = '',
                TYPE               = nil,
                SUBTYPE            = nil,

                DAMAGE             = 0,
                DAMAGE_TYPE        = DAMAGE_TYPE_PHYSICAL,
                ATTRIBUTE          = PHYSICAL_ATTRIBUTE,
                ATTRIBUTE_BONUS    = 0,
                ranged             = false,

                DEFENCE            = 0,
                SUPPRESSION        = 0,

                ATTACK_SPEED       = 1,
                CRIT_CHANCE        = 0,
                CRIT_MULTIPLIER    = 1.,

                DISPERSION         = { 0.9, 1.1 },
                RANGE              = 100,
                ANGLE              = 30, --math.pi * 2, 360 градусов
                MAX_TARGETS        = 1,

                missile = 0,
                EFFECT_ON_ATTACK   = 0,
                WEAPON_SOUND       = nil,
                MODEL              = '',
				frame_texture      = nil,

                QUALITY            = COMMON_ITEM,
                BONUS              = {},
				SKILL_BONUS 	   = {},
                MAX_SLOTS          = 0,
                STONE_SLOTS        = {},

				cost 				= 0,
				sell_value 			= 0,
                level               = 1,

				sound 			   = {}
            }
    end

    ---@param raw string
    ---@param data table
	local function ItemAddData(raw, data)
		local newdata

		if data.TYPE >= ITEM_TYPE_WEAPON and data.TYPE <= ITEM_TYPE_OFFHAND then
			newdata = GetItemTemplate()
			MergeTables(newdata, weapons[data.SUBTYPE])
			MergeTables(newdata, data)
		elseif data.TYPE == ITEM_TYPE_CONSUMABLE then
			newdata = {
				item               = nil,
				NAME               = '',
				TYPE               = ITEM_TYPE_CONSUMABLE,
				frame_texture      = nil,
				special_description = "",
				QUALITY            = COMMON_ITEM,
			}
			MergeTables(newdata, data)
		elseif data.TYPE == ITEM_TYPE_GEM then
			newdata = {
				item               = nil,
				NAME               = '',
				TYPE               = ITEM_TYPE_GEM,
				frame_texture      = nil,
				point_bonus 	   = { },
				QUALITY            = COMMON_ITEM,
			}
			MergeTables(newdata, data)
		end

		if newdata.sell_value == nil then newdata.sell_value = 0 end
		if newdata.cost == nil then newdata.cost = 0 end
		if newdata.level == nil then newdata.level = 1 end

		ITEM_TEMPLATE_DATA[FourCC(raw)] = newdata
	end



	function CreateDefaultWeapon()
		local default_weapon = GetItemTemplate()

            ItemMergeData(default_weapon, weapons[FIST_WEAPON])
			MergeTables(default_weapon, ITEM_TEMPLATE_DATA[FourCC('0000')])

		return default_weapon
	end



    function DefineItemsData()
		ItemAddData('0000', {
			NAME    = 'Fists',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = FIST_WEAPON,
			DAMAGE  = 4,
			QUALITY = COMMON_ITEM
		})

        ItemAddData('I000', {
            NAME    = 'Ледяной страж',
			TYPE = ITEM_TYPE_WEAPON,
            SUBTYPE = SWORD_WEAPON,
            DAMAGE  = 50,
            QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
            BONUS   = {
                { PARAM = PHYSICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
                { PARAM = CRIT_CHANCE, VALUE = 1.25, METHOD = MULTIPLY_BONUS },
            },
			MAX_SLOTS = 3,
			sell_value = 50
        })
		ItemAddData('IGSO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = SWORD_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
        --
        ItemAddData('I001', {
            NAME    = 'Плащ Теней',
            TYPE    = ITEM_TYPE_ARMOR,
            SUBTYPE = CHEST_ARMOR,
            QUALITY = MAGIC_ITEM,
            DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50
        })

		ItemAddData('I00G', {
			NAME    		   = 'Рубин',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Ruby.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = FIRE_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_VALUE, VALUE = 75, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = FIRE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = REFLECT_MELEE_DAMAGE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00H', {
			NAME    		   = 'Сапфир',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Sapphire.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = ICE_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MP_VALUE, VALUE = 55, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ICE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = REFLECT_RANGE_DAMAGE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			}
		})

		ItemAddData('I00I', {
			NAME    		   = 'Топаз',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Topaz.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = HOLY_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = HOLY_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = BLOCK_CHANCE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I009', {
			NAME    		   = 'Янтарь',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Amber.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CRIT_MULTIPLIER, VALUE = .4, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MOVING_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = CONTROL_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = PHYSICAL_ATTACK, VALUE = 22, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00B', {
			NAME    		   = 'Аквамарин',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Aquamarine.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = LIGHTNING_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MAGICAL_SUPPRESSION, VALUE = 1.03, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = LIGHTNING_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS }
			}
		})

		ItemAddData('I002', {
			NAME    		   = 'Алмаз',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Diamond.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = PHYSICAL_DEFENCE, VALUE = 1.03, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ALL_RESIST, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00A', {
			NAME    		   = 'Аметист',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Amethyst.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = ARCANE_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MP_PER_HIT, VALUE = 1, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ARCANE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = PHYSICAL_DEFENCE, VALUE = 70, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00J', {
			NAME    		   = 'Бирюза',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Turquoise.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = MAGICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MAGICAL_SUPPRESSION, VALUE = 75, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = MP_REGEN, VALUE = 1.03, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CRIT_MULTIPLIER, VALUE = 0.12, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00C', {
			NAME    		   = 'Изумруд',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Emerald.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = POISON_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 75, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = POISON_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = MAGICAL_ATTACK, VALUE = 27, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00E', {
			NAME    		   = 'Малахит',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Malachite.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = DARKNESS_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = PHYSICAL_DEFENCE, VALUE = 25, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = DARKNESS_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = MP_VALUE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00D', {
			NAME    		   = 'Нефрит',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Jade.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = CONTROL_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS }
			},
			sell_value = 50
		})

		ItemAddData('I00F', {
			NAME    		   = 'Опал',
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Opal.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = PHYSICAL_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_REGEN, VALUE = 1.05, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = PHYSICAL_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = HP_VALUE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
			},
			sell_value = 50
		})


		ItemAddData('I003', {
			NAME    		   = 'Зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredAApotionGS.blp",
			item_description = "Восстанавливает 25%% здоровья"
		})

		ItemAddData('I005', {
			NAME    		   = 'Большое зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredEApotionGS.blp",
			item_description = "Восстанавливает 50%% здоровья"
		})

		ItemAddData('I004', {
			NAME    		   = 'Великое зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredJApotionGS.blp",
			item_description = "Восстанавливает 75%% здоровья"
		})

		ItemAddData('I006', {
			NAME    		   = 'Зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueAApotionGS.blp",
			item_description = "Восстанавливает 25%% маны"
		})

		ItemAddData('I007', {
			NAME    		   = 'Большое зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueEApotionGS.blp",
			item_description = "Восстанавливает 50%% маны"
		})

		ItemAddData('I008', {
			NAME    		   = 'Великое зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueJApotionGS.blp",
			item_description = "Восстанавливает 75%% маны"
		})

		ItemAddData('I00K', {
			NAME    		   = 'Зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleAApotionGS.blp",
			item_description = "Восстанавливает 25%% здоровья и маны"
		})

		ItemAddData('I00M', {
			NAME    		   = 'Большое зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleEApotionGS.blp",
			item_description = "Восстанавливает 50%% здоровья и маны"
		})

		ItemAddData('I00L', {
			NAME    		   = 'Великое зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleJApotionGS.blp",
			item_description = "Восстанавливает 75%% здоровья и маны"
		})

		ItemAddData('I00N', {
			NAME    = 'Охотник на крыс',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BOW_WEAPON,
			ATTRIBUTE = POISON_ATTRIBUTE,
			DAMAGE  = 50,
			QUALITY = UNIQUE_ITEM,
			level = 5,
			frame_texture = "Weapons\\BTNInfernal bow.blp",
			special_description = "\"Даже у крысоловов был легендарный лук, коего желали все охотники на крыс\"",
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 1.25, METHOD = STRAIGHT_BONUS },
				{ PARAM = AGI_STAT, VALUE = 3, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3
		})

		ItemAddData('I00O', {
			NAME    = 'Сапог Труса',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			BONUS   = {
				{ PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = AGI_STAT, VALUE = 4, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNbt.blp",
			legendary_description = "Каждый противник неподалеку, повышает скорость передвижения на 3%% до максимума в 25%%",
			special_description = "\"Владелец этого сапога применял секретную тактику своего знатного рода, передававшуюся в течении 300 лет. До поры до времени...\"",
		})

    end

	--[[

	Легендарный ботинок труса. Один
	"Увеличивает скорость передвижения, если моделька врага больше вашей"

	Непробиваемый Наколенник Искателя Приключений


	хочу легендарный меч проворства
	легенда увеличивает шанс крита на 20%, а проворства +25 ловкости

	Легендарный лук охотника на крыс
	"Даже у крысоловов был легендарный лук, коего желали все охотники на крыс"
	]]
	
end