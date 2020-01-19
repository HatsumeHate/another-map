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
	SHIELD_OFFHAND 		  = 19
	ORB_OFFHAND 		  = 20


	
	COMMON_ITEM        = 1
	RARE_ITEM          = 2
	MAGIC_ITEM         = 3
	SET_ITEM           = 4
	UNIQUE_ITEM        = 5

	ITEM_STONE_AQUAMARINE = "I00B"
	ITEM_STONE_DIAMOND = "I002"
	ITEM_STONE_AMETHYST = "I00A"
	ITEM_STONE_TURQUOISE = "I00J"
	ITEM_STONE_EMERALD = "I00C"
	ITEM_STONE_MALACHITE = "I00E"
	ITEM_STONE_JADE = "I00D"
	ITEM_STONE_OPAL = "I00F"
	ITEM_STONE_RUBY = "I00G"
	ITEM_STONE_SAPPHIRE = "I00H"
	ITEM_STONE_TOPAZ = "I00I"
	ITEM_STONE_AMBER = "I009"


	ITEM_POTION_HEALTH_WEAK = "I003"
	ITEM_POTION_MANA_WEAK = "I006"
	ITEM_POTION_MIX_WEAK = "I00K"

	ITEM_POTION_HEALTH_HALF = "I005"
	ITEM_POTION_MANA_HALF = "I007"
	ITEM_POTION_MIX_HALF = "I00M"

	ITEM_POTION_HEALTH_STRONG = "I004"
	ITEM_POTION_MANA_STRONG = "I008"
	ITEM_POTION_MIX_STRONG = "I00L"




	EQUIP_SOUND = 1
	UNEQUIP_SOUND = 2
	INTERACT_SOUND = 3


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

            --ItemMergeData(default_weapon, weapons[FIST_WEAPON])
			MergeTables(default_weapon, weapons[FIST_WEAPON])
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
			sell_value = 50,
			soundpack = {
				equip = "Sound\\sword_equip01.wav",
				uneqip = "Sound\\weapon_unequip.wav",
				drop = "Sound\\sword.wav"
			}
        })

		ItemAddData('I00W', {
			NAME    = 'Сбалансированный меч',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = SWORD_WEAPON,
			DAMAGE  = 14,
			QUALITY = COMMON_ITEM,
			frame_texture = "Weapons\\BTNTier1 Sword.blp",
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = { equip = "Sound\\sword_equip01.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\sword.wav" }
		})

		ItemAddData('I011', {
			NAME    = 'Клеймор',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			DAMAGE  = 27,
			QUALITY = COMMON_ITEM,
			frame_texture = "Weapons\\BTNBarbarian Brutal Slasher.blp",
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = { equip = "Sound\\weapon_equip.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\largemetalweapon.wav" }
		})

		ItemAddData('I012', {
			NAME    = 'Потертый посох',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			DAMAGE  = 24,
			QUALITY = COMMON_ITEM,
			frame_texture = "Weapons\\BTNIce Staff.blp",
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = { equip = "Sound\\staff_equip.wav", uneqip = "Sound\\staff_unequip.wav", drop = "Sound\\staff.wav" }
		})


		ItemAddData('I00X', {
			NAME    = 'Клепанная броня',
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			DEFENCE  = 25,
			QUALITY = COMMON_ITEM,
			frame_texture = "Armor\\BTNSteelArmor2.blp",
			BONUS   = {
				{ PARAM = HP_VALUE, VALUE = 15, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = { equip = "Sound\\chain_armor_equip.wav", uneqip = "Sound\\chain_armor_unequip.wav", drop = "Sound\\chainarmor.wav" }
		})

		ItemAddData('I010', {
			NAME    = 'Клепанные сапоги',
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			DEFENCE  = 18,
			QUALITY = COMMON_ITEM,
			frame_texture = "Armor\\BTNBoots.blp",
			BONUS   = {
				{ PARAM = MAGICAL_SUPPRESSION, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = { equip = "Sound\\bootschain.wav", uneqip = "Sound\\bootschain.wav", drop = "Sound\\bootschain.wav" }
		})

		ItemAddData('I00Y', {
			NAME    = 'Шлем',
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			DEFENCE  = 12,
			QUALITY = COMMON_ITEM,
			frame_texture = "Armor\\BTNNFHelmet02.blp",
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = { equip = "Sound\\helmet_equip.wav", uneqip = "Sound\\helmet_unequip.wav", drop = "Sound\\helm.wav" }
		})

		ItemAddData('I00Z', {
			NAME    = 'Стеганные рукавицы',
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			DEFENCE  = 15,
			QUALITY = COMMON_ITEM,
			frame_texture = "Armor\\BTNDuelists Gauntlets.blp",
			BONUS   = {
				{ PARAM = PHYSICAL_RESIST, VALUE = 4, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = { equip = "Sound\\gloveschain.wav", uneqip = "Sound\\gloveschain.wav", drop = "Sound\\gloveschain.wav" }
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
		ItemAddData('IGST', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})

		ItemAddData('IGAO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = AXE_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
		ItemAddData('IGAT', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATAXE_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})

		ItemAddData('IGBO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BLUNT_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
		ItemAddData('IGBT', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATBLUNT_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})

		ItemAddData('IGDR', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
		ItemAddData('IGSF', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
		ItemAddData('IGBW', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BOW_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50
		})
		ItemAddData('IGAC', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
		ItemAddData('IGAD', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
		ItemAddData('IGAH', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
		ItemAddData('IGAL', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
		ItemAddData('IGJN', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = NECKLACE_JEWELRY,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
		ItemAddData('IGJR', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
		})
        --
        ItemAddData('I001', {
            NAME    = 'Плащ Теней',
            TYPE    = ITEM_TYPE_ARMOR,
            SUBTYPE = CHEST_ARMOR,
            QUALITY = MAGIC_ITEM,
            DEFENCE = 50,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			soundpack = {
				equip = "Sound\\cloth_armor_equip.wav",
				uneqip = "Sound\\cloth_armor_unequip.wav",
				drop = "Sound\\lightarmor.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			},
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			},
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
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
			sell_value = 50,
			soundpack = {
				drop = "Sound\\gem.wav"
			}
		})


		ItemAddData('I003', {
			NAME    		   = 'Зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredAApotionGS.blp",
			item_description = "Восстанавливает 25%% здоровья",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I005', {
			NAME    		   = 'Большое зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredEApotionGS.blp",
			item_description = "Восстанавливает 50%% здоровья",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I004', {
			NAME    		   = 'Великое зелье исцеления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredJApotionGS.blp",
			item_description = "Восстанавливает 75%% здоровья",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I006', {
			NAME    		   = 'Зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueAApotionGS.blp",
			item_description = "Восстанавливает 25%% маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I007', {
			NAME    		   = 'Большое зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueEApotionGS.blp",
			item_description = "Восстанавливает 50%% маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I008', {
			NAME    		   = 'Великое зелье маны',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueJApotionGS.blp",
			item_description = "Восстанавливает 75%% маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I00K', {
			NAME    		   = 'Зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleAApotionGS.blp",
			item_description = "Восстанавливает 25%% здоровья и маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I00M', {
			NAME    		   = 'Большое зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleEApotionGS.blp",
			item_description = "Восстанавливает 50%% здоровья и маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I00L', {
			NAME    		   = 'Великое зелье восстановления',
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleJApotionGS.blp",
			item_description = "Восстанавливает 75%% здоровья и маны",
			soundpack = {
				drop = "Sound\\potionui.wav"
			}
		})

		ItemAddData('I00N', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_RAT_HUNTER,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BOW_WEAPON,
			ATTRIBUTE = POISON_ATTRIBUTE,
			DAMAGE  = 50,
			QUALITY = UNIQUE_ITEM,
			level = 5,
			frame_texture = "Weapons\\BTNInfernal bow.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_RAT_HUNTER .."\"",
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 1.25, METHOD = STRAIGHT_BONUS },
				{ PARAM = AGI_STAT, VALUE = 3, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			soundpack = {
				equip = "Sound\\bow_equip.wav",
				uneqip = "Sound\\bow_unequip.wav",
				drop = "Sound\\bow.wav"
			}
		})

		ItemAddData('I00O', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_BOOT_OF_COWARD,
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
			legendary_description = LOCALE_LIST[my_locale].ITEM_LEG_DESCRIPTION_BOOT_OF_COWARD,
			special_description = "\""..LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_BOOT_OF_COWARD.."\"",
			soundpack = {
				equip = "Sound\\cloth_armor_equip.wav",
				uneqip = "Sound\\cloth_armor_unequip.wav",
				drop = "Sound\\boots.wav"
			}
		})

		ItemAddData('I00P', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_WITCH_MASTERY,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			ATTRIBUTE = FIRE_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			level = 10,
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 0.3, METHOD = STRAIGHT_BONUS },
				{ PARAM = INT_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTN_CW_Red_Scepter.blp",
			legendary_description = LOCALE_LIST[my_locale].ITEM_LEG_DESCRIPTION_WITCH_MASTERY,
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_WITCH_MASTERY .."\"",
			soundpack = {
				equip = "Sound\\staff_manadrinker_equip.wav",
				uneqip = "Sound\\staff_unequip.wav",
				drop = "Sound\\staff.wav"
			}
		})

		ItemAddData('I00Q', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_DARK_CROWN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			level = 10,
			BONUS   = {
				{ PARAM = DARKNESS_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = DARKNESS_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = CONTROL_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNDarkCrown.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_DARK_CROWN .."\"",
			soundpack = {
				equip = "Sound\\rare.wav",
				uneqip = "Sound\\rare.wav",
				drop = "Sound\\rare.wav"
			}
		})

		ItemAddData('I00R', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_RITUAL_DAGGER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS },
				{ PARAM = HP_REGEN, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
				{ PARAM = AGI_STAT, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTNBlack Navaja.blp",
			legendary_description = LOCALE_LIST[my_locale].ITEM_LEG_DESCRIPTION_RITUAL_DAGGER,
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_RITUAL_DAGGER .."\"",
			soundpack = {
				equip = "Sound\\daggers_ashes_equip.wav",
				uneqip = "Sound\\dagger_unequip.wav",
				drop = "Sound\\dagger.wav"
			}
		})

		ItemAddData('I00S', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_ACOLYTE_MANTLE,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			level = 10,
			BONUS   = {
				{ PARAM = PHYSICAL_DEFENCE, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = MAGICAL_SUPPRESSION, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = ALL_RESIST, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Armor\\BTNCloak of shadows.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_ACOLYTE_MANTLE .."\"",
			soundpack = {
				equip = "Sound\\cloth_armor_equip.wav",
				uneqip = "Sound\\cloth_armor_unequip.wav",
				drop = "Sound\\lightarmor.wav"
			}
		})

		ItemAddData('I00T', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_SMORC_PICKAXE,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = AXE_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_MULTIPLIER, VALUE = 1., METHOD = STRAIGHT_BONUS },
				{ PARAM = STR_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 4,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNGatherGold.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_SMORC_PICKAXE .."\"",
			soundpack = {
				equip = "Sound\\staff_equip.wav",
				uneqip = "Sound\\staff_unequip.wav",
				drop = "Sound\\sword.wav"
			}
		})

    end

	--[[
	ух сет Короля и шута
	дуальные оружия король а второе шут

	Кукла вуду
	Содержит чьи-то волосы. Опасная игрушка.

	Громоотвод
	Где вы его раздобыли??? В любом случае, может воскресить вас при ударе молнии. Или убить.

		Амулет хаоса
	Переодически нестабильным и начинается дичь.

	Кирка Сморка
	Легенды гласят, что шахтёр Сморк наповал косил ей врагов.


		Кристальный топор
	Превращает в кристаллы всё что коснётся. Специальные перчатки прилагаются.

	Рубик в Кубике
	Маленькое существо в кубике. Вы чувствуете что его зовут Рубик.

		Трезубец короля морей
	Может в красивые молнии. Однако владелец также в опасности.

	Непробиваемый Наколенник Искателя Приключений

	хочу легендарный меч проворства
	легенда увеличивает шанс крита на 20%, а проворства +25 ловкости

	]]
	
end