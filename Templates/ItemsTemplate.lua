-- Ставь блоки если уж так хочется отступов
do

	ITEM_TEMPLATE_DATA = 0
	ITEM_DATA          = 0
	
	ITEM_TYPE_WEAPON     = 1
	ITEM_TYPE_ARMOR      = 2
	ITEM_TYPE_JEWELRY    = 3
	ITEM_TYPE_OFFHAND    = 4
    ITEM_TYPE_CONSUMABLE = 5
    ITEM_TYPE_GEM        = 6
	ITEM_TYPE_OTHER      = 7
	ITEM_TYPE_SKILLBOOK  = 8
	ITEM_TYPE_GIFT  	 = 9

	ITEM_PASSIVE_EFFECT = 1
	ITEM_ACTIVE_EFFECT 	= 2
	
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
	QUIVER_OFFHAND 		  = 21
	BELT_ARMOR 			  = 22


    SOUNDPACK_SWORD_1 = 1; SOUNDPACK_SWORD_2 = 2; SOUNDPACK_2HSWORD = 3
    SOUNDPACK_BLUNT = 4
    SOUNDPACK_BOW = 5
    SOUNDPACK_DAGGER = 6
    SOUNDPACK_STAFF = 7
    SOUNDPACK_JAVELIN = 8

    SOUNDPACK_SHIELD_METAL = 9; SOUNDPACK_SHIELD_WOOD = 10; SOUNDPACK_ORB = 11; SOUNDPACK_QUIVER = 12

    SOUNDPACK_CHEST_HEAVY_ARMOR = 13
    SOUNDPACK_CHEST_MID_ARMOR = 14
    SOUNDPACK_CHEST_LIGHT_ARMOR = 15
    SOUNDPACK_HEAD_HEAVY_ARMOR = 16
    SOUNDPACK_HEAD_MID_ARMOR = 17
    SOUNDPACK_HEAD_LIGHT_ARMOR = 18
    SOUNDPACK_HANDS_HEAVY_ARMOR = 19
    SOUNDPACK_HANDS_MID_ARMOR = 20
    SOUNDPACK_HANDS_LIGHT_ARMOR = 21
    SOUNDPACK_BOOTS_HEAVY_ARMOR = 22
    SOUNDPACK_BOOTS_MID_ARMOR = 23
    SOUNDPACK_BOOTS_LIGHT_ARMOR = 24
    SOUNDPACK_BELT = 25

    SOUNDPACK_AMULET = 26; SOUNDPACK_RING = 27

    SOUNDPACK_POTION = 28; SOUNDPACK_SCROLL = 29; SOUNDPACK_GEM = 30; SOUNDPACK_BOOK = 31; SOUNDPACK_RUNE = 32; SOUNDPACK_CHARM = 33


    ITEM_SOUNDPACK = 0

	
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

	ITEM_POTION_ANTIDOTE = "I01R"
	ITEM_POTION_ADRENALINE = "I01S"

	ITEM_SCROLL_OF_TOWN_PORTAL = "I01K"
	ITEM_SCROLL_OF_PROTECTION = "I01Q"
	ITEM_SCROLL_OF_PETRI = "I02W"
	ITEM_FOOD = "I03B"
	ITEM_DRINKS = "I03C"

	ITEM_RUNE_FEH = "I02Y"
	ITEM_RUNE_RAIDO = "I02Z"
	ITEM_RUNE_KANO = "I030"
	ITEM_RUNE_GEBO = "I031"
	ITEM_RUNE_ISA = "I032"
	ITEM_RUNE_SOL = "I033"
	ITEM_RUNE_BER = "I034"
	ITEM_RUNE_EHW = "I035"
	ITEM_RUNE_DAG = "I036"


	EQUIP_SOUND = 1
	UNEQUIP_SOUND = 2
	INTERACT_SOUND = 3


	CLASS_SKILL_LIST = 0


	local weapons = 0


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
				BLOCK 			   = 0,
				BLOCK_RATE 		   = 40.,

                ATTACK_SPEED       = 1,
                CRIT_CHANCE        = 0,
                CRIT_MULTIPLIER    = 1.,

                DISPERSION         = { 0.9, 1.1 },
                RANGE              = 100,
                ANGLE              = 30, --math.pi * 2, 360 градусов
                MAX_TARGETS        = 1,

                EFFECT_ON_ATTACK   = 0,
                WEAPON_SOUND       = nil,
				frame_texture      = nil,

                QUALITY            = COMMON_ITEM,
                BONUS              = {},
				SKILL_BONUS 	   = {},
                MAX_SLOTS          = 0,
                STONE_SLOTS        = {},

				cost 				= 0,
				sell_value 			= 0,
                level               = 1,

				sound 			   = {},

				droppable = true,
				sellable = true
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
				item              	= nil,
				NAME               	= '',
				TYPE               	= ITEM_TYPE_CONSUMABLE,
				frame_texture      	= nil,
				special_description = "",
				QUALITY            	= COMMON_ITEM,
				droppable 			= true,
				sellable 			= true
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
				droppable 			= true,
				sellable 			= true
			}
			MergeTables(newdata, data)
		elseif data.TYPE == ITEM_TYPE_SKILLBOOK then
			newdata = {
				item               = nil,
				NAME               = '',
				TYPE               = ITEM_TYPE_SKILLBOOK,
				frame_texture      = nil,
				QUALITY            = COMMON_ITEM,
				droppable 			= true,
				sellable 			= true
			}
			MergeTables(newdata, data)
		else
			newdata = {
				item               = nil,
				NAME               = '',
				TYPE               = ITEM_TYPE_OTHER,
				frame_texture      = nil,
				QUALITY            = COMMON_ITEM,
				droppable 			= true,
				sellable 			= true
			}
			MergeTables(newdata, data)
		end

		if newdata.sell_value == nil then newdata.sell_value = 0 end
		if newdata.cost == nil then newdata.cost = 0 end
		if newdata.level == nil then newdata.level = 1 end
		newdata.raw = raw

		ITEM_TEMPLATE_DATA[FourCC(raw)] = newdata
	end



	function CreateDefaultWeapon()
		local default_weapon = GetItemTemplate()

            --ItemMergeData(default_weapon, weapons[FIST_WEAPON])
			MergeTables(default_weapon, weapons[FIST_WEAPON])
			MergeTables(default_weapon, ITEM_TEMPLATE_DATA[FourCC('0000')])

		return default_weapon
	end


	function CreateDefaultShieldOffhand()
		local default_shield = GetItemTemplate()

			MergeTables(default_shield, ITEM_TEMPLATE_DATA[FourCC('SDEF')])

		return default_shield
	end


	function IsItemSubType(item, item_type)
		local item_data = GetItemData(item)
		return item_data.SUBTYPE == item_type
	end

	function IsItemType(item, item_type)
		local item_data = GetItemData(item)
		return item_data.TYPE == item_type
	end

	function ItemAddSkillBonus(item_data, id, levels)
		if not item_data.SKILL_BONUS then item_data.SKILL_BONUS = {} end
		item_data.SKILL_BONUS = { [#item_data.SKILL_BONUS+1] = { id = id, bonus_levels = levels } }
	end


    function DefineItemsData()

		ITEM_TEMPLATE_DATA = {}
		ITEM_DATA          = {}

		weapons = {
			[FIST_WEAPON]       = {
				DAMAGE          = 4,
				ATTACK_SPEED    = 1.8,
				CRIT_CHANCE     = 0,
				CRIT_MULTIPLIER = 1.5,
				RANGE           = 110,
				DISPERSION      = { 0.9, 1.1 },
				WEAPON_SOUND    = WEAPON_TYPE_WOOD_LIGHT_BASH
			},
			[SWORD_WEAPON]      = {
				ATTACK_SPEED    = 1.6,
				CRIT_CHANCE     = 4,
				CRIT_MULTIPLIER = 2.1,
				RANGE           = 160,
				DISPERSION      = { 0.9, 1.1 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_SLICE
			},
			[GREATSWORD_WEAPON] = {
				ATTACK_SPEED    = 2.3,
				CRIT_CHANCE     = 5,
				CRIT_MULTIPLIER = 1.6,
				RANGE           = 190,
				ANGLE           = 35, --math.pi / 5,  36 градусов
				DISPERSION      = { 0.9, 1.1 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_SLICE
			},
			[AXE_WEAPON]        = {
				ATTACK_SPEED    = 1.5,
				CRIT_CHANCE     = 6,
				CRIT_MULTIPLIER = 1.7,
				RANGE           = 150,
				DISPERSION      = { 0.85, 1.15 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_CHOP
			},
			[GREATAXE_WEAPON]   = {
				ATTACK_SPEED    = 2.2,
				CRIT_CHANCE     = 6,
				CRIT_MULTIPLIER = 1.7,
				RANGE           = 190,
				DISPERSION      = { 0.85, 1.15 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_CHOP
			},
			[DAGGER_WEAPON]     = {
				ATTACK_SPEED    = 1.4,
				CRIT_CHANCE     = 9,
				CRIT_MULTIPLIER = 2.3,
				RANGE           = 130,
				ANGLE           = 25, --math.pi / 7.2, -- 25 градусов
				DISPERSION      = { 0.9, 1.1 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_LIGHT_SLICE
			},
			[STAFF_WEAPON]      = {
				ATTACK_SPEED    = 2.4,
				CRIT_CHANCE     = 9,
				CRIT_MULTIPLIER = 2.3,
				RANGE           = 195,
				DISPERSION      = { 0.85, 1.15 },
				WEAPON_SOUND    = WEAPON_TYPE_WOOD_MEDIUM_BASH
			},
			[JAWELIN_WEAPON]    = {
				ATTACK_SPEED    = 2.3,
				CRIT_CHANCE     = 5,
				CRIT_MULTIPLIER = 1.7,
				RANGE           = 200,
				DISPERSION      = { 0.85, 1.15 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_BASH
			},
			[BLUNT_WEAPON]      = {
				ATTACK_SPEED    = 1.7,
				CRIT_CHANCE     = 5,
				CRIT_MULTIPLIER = 1.6,
				RANGE           = 140,
				DISPERSION      = { 0.8, 1.2 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_MEDIUM_BASH
			},
			[GREATBLUNT_WEAPON] = {
				ATTACK_SPEED    = 2.4,
				CRIT_CHANCE     = 5,
				CRIT_MULTIPLIER = 1.7,
				RANGE           = 180,
				DISPERSION      = { 0.8, 1.2 },
				WEAPON_SOUND    = WEAPON_TYPE_METAL_HEAVY_BASH
			},
			[BOW_WEAPON]        = {
				ATTACK_SPEED    = 2.6,
				CRIT_CHANCE     = 7,
				CRIT_MULTIPLIER = 2.2,
				RANGE           = 850.,
				ranged          = true,
				DISPERSION      = { 0.75, 1.25 },
				missile  		= "MSTA",
				WEAPON_SOUND    = nil
			}
		}

		for k, v in pairs(weapons) do
			v.TYPE    = ITEM_TYPE_WEAPON
			v.SUBTYPE = k
		end

		CLASS_SKILL_LIST = {
			[BARBARIAN_CLASS] = {
				[SKILL_CATEGORY_FIGHTING_MASTERY] 	= { "A010", "A007", "A006", "A020", "ADBS", "ABRV" },
				[SKILL_CATEGORY_BATTLE_ADVANTAGE]	= { "A00O", "A00Z", "A00A", "ASHG", "A00B", "ABTR" },
				[SKILL_CATEGORY_INNER_STRENGTH] 	= { "A00Q", "A00C", "ABFA", "ABRC", "ABCA" }
			},
			[SORCERESS_CLASS] = {
				[SKILL_CATEGORY_LIGHTNING] = { 'A00M', "A00J", "A00K", "A019", },
				[SKILL_CATEGORY_ICE] = { "A003", "A001", "A005", "A00E", "ABLZ", "ASIR" },
				[SKILL_CATEGORY_FIRE] = { "A00D", "A00F", "A00I", "AMLT", "AFRW" },
				[SKILL_CATEGORY_ARCANE] = { "A00L", "A00N", "A00H" }
			},
			[NECROMANCER_CLASS] = {
				[SKILL_CATEGORY_DARK_ART] = { "ANBR", "ANBS", "ANTS", "ANBB", "ANCE", "ANBK", "ANWS", "ANPB" },
				[SKILL_CATEGORY_CURSES] = { "ANUL", "ANWK", "ANDF", "ANFR", "ANHV", "ANBP" },
				[SKILL_CATEGORY_SUMMONING] = { "ANRD", "ANLR", "ANDV", "ANUC", "ANDR", "ANGS" }
			},
			[ASSASSIN_CLASS] = {
				[SKILL_CATEGORY_LETHALITY] = { "AACS", "AABR", "AABA", "AASH", "AAEV", "AAVB", "AABF", "AATL", "AALL" },
				[SKILL_CATEGORY_SHADOWS] = { "AANS", "AATW","AABD","AAST","AACB","AADB" },
				[SKILL_CATEGORY_GEAR] = { "AAIG", "AACT", "AASC", "AABT", "AASB", "AARL" }
			},
		}


		ITEM_SOUNDPACK = {
            [SOUNDPACK_SWORD_1]               = { equip = "Sound\\sword_equip01.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\sword.wav" },
            [SOUNDPACK_SWORD_2]               = { equip = "Sound\\sword_equip02.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\sword.wav" },
            [SOUNDPACK_2HSWORD]               = { equip = "Sound\\weapon_equip.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\largemetalweapon.wav" },
            [SOUNDPACK_BLUNT]                 = { equip = "Sound\\dagger_equip.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\sword.wav" },
            [SOUNDPACK_STAFF]                 = { equip = "Sound\\staff_equip.wav", uneqip = "Sound\\staff_unequip.wav", drop = "Sound\\staff.wav" },
            [SOUNDPACK_DAGGER]                = { equip = "Sound\\dagger_equip.wav", uneqip = "Sound\\dagger_unequip.wav", drop = "Sound\\smallmetalweapon.wav" },
            [SOUNDPACK_JAVELIN]               = { equip = "Sound\\bow_equip.wav", uneqip = "Sound\\bow_unequip.wav", drop = "Sound\\bow.wav" },
            [SOUNDPACK_BOW]                   = { equip = "Sound\\bow_equip.wav", uneqip = "Sound\\bow_unequip.wav", drop = "Sound\\bow.wav" },

            [SOUNDPACK_SHIELD_WOOD]           = { equip = "Sound\\shield_equip.wav", uneqip = "Sound\\shield_unequip.wav", drop = "Sound\\woodshield.wav" },
            [SOUNDPACK_SHIELD_METAL]          = { equip = "Sound\\shield_equip.wav", uneqip = "Sound\\shield_unequip.wav", drop = "Sound\\metalshield.wav" },
            [SOUNDPACK_ORB]                   = { equip = "Sound\\amulet.wav", uneqip = "Sound\\amulet.wav", drop = "Sound\\amulet.wav" },
            [SOUNDPACK_QUIVER]                = { equip = "Sound\\quiver.wav", uneqip = "Sound\\quiver.wav", drop = "Sound\\quiver.wav" },

            [SOUNDPACK_AMULET]                = { equip = "Sound\\ring_equip.wav", uneqip = "Sound\\ring_unequip.wav", drop = "Sound\\amulet.wav" },
            [SOUNDPACK_RING]                  = { equip = "Sound\\ring_equip.wav", uneqip = "Sound\\ring_unequip.wav", drop = "Sound\\ring.wav" },


            [SOUNDPACK_CHEST_HEAVY_ARMOR]    = { equip = "Sound\\chain_armor_equip.wav", uneqip = "Sound\\chain_armor_unequip.wav", drop = "Sound\\platearmor.wav" },
            [SOUNDPACK_CHEST_MID_ARMOR]      = { equip = "Sound\\chain_armor_equip.wav", uneqip = "Sound\\chain_armor_unequip.wav", drop = "Sound\\chainarmor.wav" },
            [SOUNDPACK_CHEST_LIGHT_ARMOR]    = { equip = "Sound\\cloth_armor_equip.wav", uneqip = "Sound\\cloth_armor_unequip.wav", drop = "Sound\\lightarmor.wav" },

            [SOUNDPACK_HEAD_HEAVY_ARMOR]     = { equip = "Sound\\helmet_equip.wav", uneqip = "Sound\\helmet_unequip.wav", drop = "Sound\\helm.wav" },
            [SOUNDPACK_HEAD_MID_ARMOR]       = { equip = "Sound\\cap.wav", uneqip = "Sound\\cap.wav", drop = "Sound\\cap.wav" },
            [SOUNDPACK_HEAD_LIGHT_ARMOR]     = { equip = "Sound\\rare.wav", uneqip = "Sound\\rare.wav", drop = "Sound\\rare.wav" },

            [SOUNDPACK_HANDS_HEAVY_ARMOR]    = { equip = "Sound\\glovesmetal.wav", uneqip = "Sound\\glovesmetal.wav", drop = "Sound\\glovesmetal.wav" },
            [SOUNDPACK_HANDS_MID_ARMOR]      = { equip = "Sound\\gloveschain.wav", uneqip = "Sound\\gloveschain.wav", drop = "Sound\\gloveschain.wav" },
            [SOUNDPACK_HANDS_LIGHT_ARMOR]    = { equip = "Sound\\gloves.wav", uneqip = "Sound\\gloves.wav", drop = "Sound\\gloves.wav" },

            [SOUNDPACK_BOOTS_HEAVY_ARMOR]    = { equip = "Sound\\bootsmetal.wav", uneqip = "Sound\\bootsmetal.wav", drop = "Sound\\bootsmetal.wav" },
            [SOUNDPACK_BOOTS_MID_ARMOR]      = { equip = "Sound\\bootschain.wav", uneqip = "Sound\\bootschain.wav", drop = "Sound\\bootschain.wav" },
            [SOUNDPACK_BOOTS_LIGHT_ARMOR]    = { equip = "Sound\\boots.wav", uneqip = "Sound\\boots.wav", drop = "Sound\\boots.wav" },

            [SOUNDPACK_BELT]                 = { equip = "Sound\\belt.wav", uneqip = "Sound\\belt.wav", drop = "Sound\\belt.wav" },

            [SOUNDPACK_POTION]               = { drop = "Sound\\potionui.wav" },
            [SOUNDPACK_SCROLL]               = { drop = "Sound\\scroll.wav" },
            [SOUNDPACK_GEM]                  = { drop = "Sound\\gem.wav" },
            [SOUNDPACK_BOOK]                 = { drop = "Sound\\book.wav" },
			[SOUNDPACK_RUNE] 				 = { drop = "Sound\\rune.flac" },
			[SOUNDPACK_CHARM] 				 = { drop = "Sound\\charm.wav" },

        }


		ItemAddData('0000', {
			NAME    = 'Fists',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = FIST_WEAPON,
			DAMAGE  = 4,
			QUALITY = COMMON_ITEM
		})

		ItemAddData('SDEF', {
			NAME    = 'SHIELD',
			TYPE = ITEM_TYPE_OFFHAND,
			SUBTYPE = SHIELD_OFFHAND,
			QUALITY = COMMON_ITEM
		})

        ItemAddData('I000', {
            NAME    = 'Ледяной страж',
			TYPE = ITEM_TYPE_WEAPON,
            SUBTYPE = SWORD_WEAPON,
            DAMAGE  = 50,
            QUALITY = RARE_ITEM,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			flippy = true,
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
			flippy = true,
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = { equip = "Sound\\sword_equip01.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\sword.wav" }
		})

		ItemAddData('I011', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_2HSWORD,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			DAMAGE  = 37,
			stat_modificator = 1.7,
			QUALITY = COMMON_ITEM,
			--set_bonus = GetItemSet("STST"),
			model = "Items\\Weapon_TwoHandSword_1.mdx",
			frame_texture = "Weapons\\BTNBarbarian Brutal Slasher.blp",
			flippy = true,
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_2HSWORD]
		})

		ItemAddData('I012', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_STAFF,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			DAMAGE  = 24,
			stat_modificator = 1.7,
			QUALITY = COMMON_ITEM,
			model = "Items\\Weapon_Staff.mdx",
			frame_texture = "Weapons\\BTNIce Staff.blp",
			flippy = true,
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
				--{ PARAM = MAGICAL_ATTACK, VALUE = 500, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_STAFF]
		})


		ItemAddData('I00X', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_CHEST,
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			DEFENCE  = 25,
			stat_modificator = 1.1,
			QUALITY = COMMON_ITEM,
			flippy = true,
			frame_texture = "Armor\\BTNSteelArmor2.blp",
			model = "Items\\Armor_09.mdx",
			texture = TEXTURE_ID_ARMOR_05,
			BONUS   = {
				{ PARAM = HP_VALUE, VALUE = 15, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 70,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHEST_MID_ARMOR]
		})

		ItemAddData('I010', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_LEGS,
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			DEFENCE  = 18,
			stat_modificator = 1.,
			QUALITY = COMMON_ITEM,
			--set_bonus = GetItemSet("STST"),
			flippy = true,
			frame_texture = "Armor\\BTNBoots.blp",
			BONUS   = {
				{ PARAM = MAGICAL_SUPPRESSION, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOTS_MID_ARMOR]
		})

		ItemAddData('I00Y', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_HEAD,
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			DEFENCE  = 12,
			stat_modificator = 0.8,
			QUALITY = COMMON_ITEM,
			--set_bonus = GetItemSet("STST"),
			flippy = true,
			frame_texture = "Armor\\BTNNFHelmet02.blp",
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 2, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_HEAVY_ARMOR]
		})

		ItemAddData('I00Z', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_HANDS,
			TYPE = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			DEFENCE  = 15,
			stat_modificator = 0.9,
			QUALITY = COMMON_ITEM,
			--set_bonus = GetItemSet("STST"),
			flippy = true,
			frame_texture = "Armor\\BTNDuelists Gauntlets.blp",
			BONUS   = {
				{ PARAM = PHYSICAL_RESIST, VALUE = 4, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HANDS_MID_ARMOR]
		})


		ItemAddData('I02O', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_MACE,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BLUNT_WEAPON,
			DAMAGE  = 37,
			stat_modificator = 1.,
			QUALITY = COMMON_ITEM,
			model = "Items\\Mace.mdx",
			frame_texture = "Weapons\\BTNAntiqueMace.blp",
			flippy = true,
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = MAGICAL_ATTACK, VALUE = 15, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 60,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BLUNT]
		})

		ItemAddData('I02N', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_SHIELD,
			TYPE = ITEM_TYPE_OFFHAND,
			SUBTYPE = SHIELD_OFFHAND,
			DEFENCE  = 15,
			BLOCK = 20.,
			BLOCK_RATE = 0.3,
			stat_modificator = 0.9,
			QUALITY = COMMON_ITEM,
			flippy = true,
			frame_texture = "Offhand\\BTNFancy Shield.blp",
			model = "Items\\Rustier Wooden Buckler Condensed.mdx",
			BONUS   = {
				{ PARAM = HP_VALUE, VALUE = 25, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_SHIELD_WOOD]
		})


		ItemAddData('I02P', {
			NAME    = LOCALE_LIST[my_locale].STARTING_ITEM_NAME_DAGGER,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			DAMAGE  = 25,
			stat_modificator = 1.,
			QUALITY = COMMON_ITEM,
			model = "Items\\Mithril Dagger.mdx",
			frame_texture = "Weapons\\BTNNastyShiv.blp",
			flippy = true,
			BONUS   = {
				{ PARAM = ATTACK_SPEED, VALUE = 3, METHOD = STRAIGHT_BONUS },
				{ PARAM = MOVING_SPEED, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 0,
			sell_value = 45,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_DAGGER]
		})


		ItemAddData('IGSO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = SWORD_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			model = "FlippySword.mdx",
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGST', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			model = "FlippyGreatSword.mdx",
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})

		ItemAddData('IGAO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = AXE_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAT', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATAXE_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})

		ItemAddData('IGBO', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BLUNT_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGBT', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATBLUNT_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})

		ItemAddData('IGDR', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGSF', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGBW', {
			NAME    = 'NAN',
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BOW_WEAPON,
			DAMAGE  = 100,
			QUALITY = RARE_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNThoriumMelee.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAC', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAD', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAH', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAL', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGAB', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = BELT_ARMOR,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGJN', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = NECKLACE_JEWELRY,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGJR', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = MAGIC_ITEM,
			DEFENCE = 50,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGOO', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_OFFHAND,
			SUBTYPE = ORB_OFFHAND,
			QUALITY = MAGIC_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGOS', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_OFFHAND,
			SUBTYPE = SHIELD_OFFHAND,
			QUALITY = MAGIC_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
		ItemAddData('IGOQ', {
			NAME    = 'NAN',
			TYPE    = ITEM_TYPE_OFFHAND,
			SUBTYPE = QUIVER_OFFHAND,
			QUALITY = MAGIC_ITEM,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			sell_value = 50,
			sell_penalty = 0.55
		})
        --
        ItemAddData('I001', {
            NAME    = 'Плащ Теней',
            TYPE    = ITEM_TYPE_ARMOR,
            SUBTYPE = CHEST_ARMOR,
            QUALITY = MAGIC_ITEM,
            DEFENCE = 50,
			stat_modificator = 0.9,
			flippy = true,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNCloak.blp",
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHEST_LIGHT_ARMOR]
        })

		ItemAddData('I01O', {
			NAME    		   = LOCALE_LIST[my_locale].SHARD_OF_HATE,
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 		   = MAGIC_ITEM,
			frame_texture      = "GUI\\BTNRuby.blp",
			item_description = LOCALE_LIST[my_locale].SHARD_OF_HATE_DESC,
			cost = 1000,
			sell_penalty = 0.04,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00G', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_RUBY,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Ruby.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = FIRE_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_VALUE, VALUE = 55, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = FIRE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = REFLECT_MELEE_DAMAGE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00H', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_SAPPHIRE,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Sapphire.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = ICE_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MP_VALUE, VALUE = 25, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ICE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = REFLECT_RANGE_DAMAGE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00I', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_TOPAZ,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Topaz.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = HOLY_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = HOLY_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = BLOCK_CHANCE, VALUE = 20, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I009', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_AMBER,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Amber.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MOVING_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = HP_REGEN, VALUE = 0.3, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = PHYSICAL_ATTACK, VALUE = 22, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00B', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_AQUAMARINE,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Aquamarine.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = LIGHTNING_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MAGICAL_SUPPRESSION, VALUE = 1.03, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = LIGHTNING_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I002', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_DIAMOND,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Diamond.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = PHYSICAL_DEFENCE, VALUE = 1.03, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ALL_RESIST, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00A', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_AMETHYST,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Amethyst.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = PHYSICAL_ATTACK, VALUE = 15, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MP_PER_HIT, VALUE = 2, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = ARCANE_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = PHYSICAL_DEFENCE, VALUE = 70, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00J', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_TURQUOISE,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Turquoise.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = MAGICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MAGICAL_SUPPRESSION, VALUE = 75, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = MP_REGEN, VALUE = 1.07, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CRIT_MULTIPLIER, VALUE = 0.06, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00C', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_EMERALD,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Emerald.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = POISON_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = POISON_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = MAGICAL_ATTACK, VALUE = 27, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00E', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_MALACHITE,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Malachite.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = DARKNESS_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = PHYSICAL_DEFENCE, VALUE = 50, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = DARKNESS_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = MP_VALUE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00D', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_JADE,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Jade.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 4, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = CONTROL_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})

		ItemAddData('I00F', {
			NAME    		   = LOCALE_LIST[my_locale].GEM_OPAL,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNItem_Gem_Opal.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = PHYSICAL_BONUS, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HP_REGEN, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = PHYSICAL_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = HP_VALUE, VALUE = 1.1, METHOD = MULTIPLY_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM]
		})


		ItemAddData('I02Y', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_FEH,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_orange.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = CRIT_MULTIPLIER, VALUE = 0.1, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = PHYSICAL_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = BONUS_DEMON_DAMAGE, VALUE = 22, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = PHYSICAL_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I02Z', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_RAIDO,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_white.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = AGI_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = LIGHTNING_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = BONUS_UNDEAD_DAMAGE, VALUE = 22, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = LIGHTNING_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I030', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_KANO,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_red.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = DAMAGE_BOOST, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = FIRE_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = MAGICAL_SUPPRESSION, VALUE = 50, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = FIRE_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I031', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_GEBO,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_blue.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = MP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = ICE_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = PHYSICAL_DEFENCE, VALUE = 66, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = ICE_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I032', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_ISA,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_green.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = POISON_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = BONUS_BEAST_DAMAGE, VALUE = 22, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = POISON_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I033', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_SOL,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_teal.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = ALL_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = BONUS_HUMAN_DAMAGE, VALUE = 22, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = MANACOST, VALUE = -2, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I034', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_BER,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_gray.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = HP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = DARKNESS_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = DROP_BONUS, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = DARKNESS_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I035', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_EHW,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_yellow.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = STR_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = HOLY_BONUS, VALUE = 24, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = HEALING_BONUS, VALUE = 7, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = HOLY_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})

		ItemAddData('I036', {
			NAME    		   = LOCALE_LIST[my_locale].RUNE_DAG,
			TYPE    		   = ITEM_TYPE_GEM,
			frame_texture      = "GUI\\BTNrune_purple.blp",
			point_bonus 	   = {
				[ITEM_TYPE_WEAPON] 		= {  PARAM = INT_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_ARMOR]  		= {  PARAM = VIT_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_JEWELRY]  	= {  PARAM = REFLECT_DAMAGE, VALUE = 35, METHOD = STRAIGHT_BONUS },
				[ITEM_TYPE_OFFHAND]  	= {  PARAM = ARCANE_RESIST, VALUE = 24, METHOD = STRAIGHT_BONUS }
			},
			cost = 50,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE]
		})


		ItemAddData('I01K', {
			NAME    		   = LOCALE_LIST[my_locale].SCROLL_OF_TOWN_PORTAL_NAME,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNScrollOfHealing.blp",
			item_description = LOCALE_LIST[my_locale].SCROLL_OF_TOWN_PORTAL_DESC,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_SCROLL],
			cost = 50,
			cooldown_type = 2,
			usable = true
		})

		ItemAddData('I01Q', {
			NAME    		   = LOCALE_LIST[my_locale].SCROLL_OF_PROTECTION_NAME,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNScrollOfProtection.blp",
			item_description = LOCALE_LIST[my_locale].SCROLL_OF_PROTECTION_DESC,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_SCROLL],
			cost = 150,
			cooldown_type = 3,
			usable = true
		})

		ItemAddData('I02W', {
			NAME    		   = LOCALE_LIST[my_locale].SCROLL_OF_PETRIFICATION_NAME,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNScrollOfTownPortal.blp",
			item_description = LOCALE_LIST[my_locale].SCROLL_OF_PETRIFICATION_DESC,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_SCROLL],
			cost = 150,
			cooldown_type = 3,
			usable = true
		})

		ItemAddData('I003', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_WEAK_HP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredAApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_WEAK_HP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 25,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I005', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_HALF_HP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredEApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_HALF_HP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 50,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I004', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_STRONG_HP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNredJApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_STRONG_HP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 75,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I006', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_WEAK_MP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueAApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_WEAK_MP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 25,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I007', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_HALF_MP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueEApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_HALF_MP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 50,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I008', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_STRONG_MP_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNblueJApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_STRONG_MP_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 75,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I00K', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_WEAK_MIX_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleAApotionGS.blp",
			item_description   = LOCALE_LIST[my_locale].POTION_WEAK_MIX_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 75,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I00M', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_HALF_MIX_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleEApotionGS.blp",
			item_description = LOCALE_LIST[my_locale].POTION_HALF_MIX_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 100,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I00L', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_STRONG_MIX_NAME_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNpurpleJApotionGS.blp",
			item_description   = LOCALE_LIST[my_locale].POTION_STRONG_MIX_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 125,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I01S', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_ADRENALINE_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNYellowBottle.blp",
			item_description   = LOCALE_LIST[my_locale].POTION_ADRENALINE_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 50,
			cooldown_type = 3,
			usable = true
		})

		ItemAddData('I03B', {
			NAME    		   = LOCALE_LIST[my_locale].FOOD_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNRpgFood.blp",
			item_description   = LOCALE_LIST[my_locale].FOOD_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE],
			cost = 50,
			cooldown_type = 4,
			usable = true
		})

		ItemAddData('I03C', {
			NAME    		   = LOCALE_LIST[my_locale].DRINKS_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "GUI\\BTNRpgDrink.blp",
			item_description   = LOCALE_LIST[my_locale].DRINKS_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_RUNE],
			cost = 50,
			cooldown_type = 4,
			usable = true
		})


		ItemAddData('I01R', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_ANTIDOTE_TEXT,
			TYPE    		   = ITEM_TYPE_CONSUMABLE,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall.blp",
			item_description   = LOCALE_LIST[my_locale].POTION_ANTIDOTE_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 25,
			cooldown_type = 3,
			usable = true
		})

		ItemAddData('I027', {
			NAME    		   = LOCALE_LIST[my_locale].POTION_OF_OBLIVION,
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 			= RARE_ITEM,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNLesserInvulneralbility.blp",
			item_description   = LOCALE_LIST[my_locale].POTION_OF_OBLIVION_DESC_TEXT,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_POTION],
			cost = 500,
			usable = true
		})


		ItemAddData('I01V', {
			NAME    		   = LOCALE_LIST[my_locale].BOOK_TOME_NAME,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNDemonology.blp",
			item_description = LOCALE_LIST[my_locale].BOOK_TOME_NAME_TEXT,
			bonus_points = 1,
			QUALITY = MAGIC_ITEM,
			learn_effect = "Abilities\\Spells\\Items\\AIem\\AIemTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 500,
			sell_penalty = 0.5
		})

		ItemAddData('I00U', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_FIRE,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNbook1fire .blp",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = SORCERESS_CLASS,
			skill_category = CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_FIRE],
			learn_effect = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I021', {
			NAME    		  	 	= LOCALE_LIST[my_locale].SKILLBOOK_FIRE,
			QUALITY 		   		= RARE_ITEM,
			TYPE    		  		= ITEM_TYPE_SKILLBOOK,
			frame_texture    		= "Items\\Book\\BTNbook1fire .blp",
			item_description		= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 			= SORCERESS_CLASS,
			skill_category 			= CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_FIRE],
			learn_effect 			= "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack 				= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 					= 700,
			sell_penalty 			= 0.5
		})

		ItemAddData('I00V', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_ICE,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNbook1water .blp",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = SORCERESS_CLASS,
			skill_category = CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_ICE],
			learn_effect = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I020', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_ICE,
			QUALITY 		   	= RARE_ITEM,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNbook1water .blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= SORCERESS_CLASS,
			skill_category 		= CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_ICE],
			learn_effect 		= "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I013', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_LIGHTNING,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNbook1wind .blp",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = SORCERESS_CLASS,
			skill_category = CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_LIGHTNING],
			learn_effect = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I01Z', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_LIGHTNING,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNbook1wind .blp",
			item_description	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= SORCERESS_CLASS,
			skill_category 		= CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_LIGHTNING],
			learn_effect 		= "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty		 = 0.5
		})


		ItemAddData('I014', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_ARCANE,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNBK_Red_Book.blp",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = SORCERESS_CLASS,
			skill_category = CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_ARCANE],
			learn_effect = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I022', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_ARCANE,
			QUALITY 		   	= RARE_ITEM,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNBK_Red_Book.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= SORCERESS_CLASS,
			skill_category 		= CLASS_SKILL_LIST[SORCERESS_CLASS][SKILL_CATEGORY_ARCANE],
			learn_effect 		= "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})


		ItemAddData('I015', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_FIGHTING_MASTERY,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTN_cr_BookNOADD.blp",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = BARBARIAN_CLASS,
			skill_category = CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_FIGHTING_MASTERY],
			learn_effect = "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I023', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_FIGHTING_MASTERY,
			QUALITY 		   	= RARE_ITEM,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTN_cr_BookNOADD.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= BARBARIAN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_FIGHTING_MASTERY],
			learn_effect 		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I016', {
			NAME    		   = LOCALE_LIST[my_locale].SKILLBOOK_INNER_STRENGTH,
			TYPE    		   = ITEM_TYPE_SKILLBOOK,
			frame_texture      = "Items\\Book\\BTNRuneBook.BLP",
			item_description = LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to = BARBARIAN_CLASS,
			skill_category = CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_INNER_STRENGTH],
			learn_effect = "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 200,
			sell_penalty = 0.5
		})

		ItemAddData('I024', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_INNER_STRENGTH,
			QUALITY 		   	= RARE_ITEM,
			TYPE    		  	= ITEM_TYPE_SKILLBOOK,
			frame_texture     	= "Items\\Book\\BTNRuneBook.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= BARBARIAN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_INNER_STRENGTH],
			learn_effect 		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I017', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_BATTLE_ADVANTAGE,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNSimpleBook1.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= BARBARIAN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_BATTLE_ADVANTAGE],
			learn_effect 		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I025', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_BATTLE_ADVANTAGE,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNSimpleBook1.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= BARBARIAN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[BARBARIAN_CLASS][SKILL_CATEGORY_BATTLE_ADVANTAGE],
			learn_effect 		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I028', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_DARK_ART,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNTomePowerPoison.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_DARK_ART],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I029', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_CURSES,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNTomePowerDarkness.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_CURSES],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I02A', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_SUMMONING,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNDemonicBook.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_SUMMONING],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I02B', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_DARK_ART,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNTomePowerPoison.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_DARK_ART],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I02C', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_CURSES,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNTomePowerDarkness.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_CURSES],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I02D', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_SUMMONING,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNDemonicBook.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= NECROMANCER_CLASS,
			skill_category 		= CLASS_SKILL_LIST[NECROMANCER_CLASS][SKILL_CATEGORY_SUMMONING],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})


		ItemAddData('I03E', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_LETHALITY,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_LETHALITY],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I03F', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_SHADOWS,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_SHADOWS],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})

		ItemAddData('I03G', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_GEAR,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_GEAR],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 200,
			sell_penalty 		= 0.5
		})


		ItemAddData('I03H', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_LETHALITY,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_LETHALITY],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I03I', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_SHADOWS,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.BLP",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_SHADOWS],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})

		ItemAddData('I03J', {
			NAME    		   	= LOCALE_LIST[my_locale].SKILLBOOK_GEAR,
			TYPE    		   	= ITEM_TYPE_SKILLBOOK,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "Items\\Book\\BTNBK_Black_Book.blp",
			item_description 	= LOCALE_LIST[my_locale].SKILLBOOK_TEXT,
			restricted_to 		= ASSASSIN_CLASS,
			skill_category 		= CLASS_SKILL_LIST[ASSASSIN_CLASS][SKILL_CATEGORY_GEAR],
			learn_effect		= "Abilities\\Spells\\Items\\AIsm\\AIsmTarget.mdx",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost 				= 700,
			sell_penalty 		= 0.5
		})


		ItemAddData('I03D', {
			NAME    		   = LOCALE_LIST[my_locale].GIFT_SCREAMING_MASK,
			TYPE    		   = ITEM_TYPE_GIFT,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNSobiMask.blp",
			gift 			   = "screaming_mask_gift",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHARM],
			cost = 200,
			sell_penalty = 0.5
		})


		ItemAddData('I03K', {
			NAME    		   	= LOCALE_LIST[my_locale].MEDALLION,
			TYPE    		   	= ITEM_TYPE_OTHER,
			frame_texture      	= "ReplaceableTextures\\CommandButtons\\BTNMedalionOfCourage.blp",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_CHARM],
			item_description 	= LOCALE_LIST[my_locale].MEDALLION_DESC_1,
			cost = 200,
			sell_penalty = 0.5,
			sellable = false,
			droppable = false,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I03L', {
			NAME    		   	= LOCALE_LIST[my_locale].MEDALLION,
			TYPE    		   	= ITEM_TYPE_OTHER,
			QUALITY 		   	= RARE_ITEM,
			frame_texture      	= "ReplaceableTextures\\CommandButtons\\BTNMedalionOfCourage.blp",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_CHARM],
			item_description 	= LOCALE_LIST[my_locale].MEDALLION_DESC_2,
			cost = 200,
			sell_penalty = 0.5,
			sellable = false,
			droppable = false,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I03M', {
			NAME    		   	= LOCALE_LIST[my_locale].MEDALLION,
			TYPE    		   	= ITEM_TYPE_OTHER,
			QUALITY 		   	= MAGIC_ITEM,
			frame_texture      	= "ReplaceableTextures\\CommandButtons\\BTNMedalionOfCourage.blp",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_CHARM],
			item_description 	= LOCALE_LIST[my_locale].MEDALLION_DESC_3,
			cost = 200,
			sell_penalty = 0.5,
			sellable = false,
			droppable = false,
			cooldown_type = 1,
			usable = true
		})

		ItemAddData('I03N', {
			NAME    		   	= LOCALE_LIST[my_locale].MEDALLION,
			TYPE    		   	= ITEM_TYPE_OTHER,
			QUALITY 		   	= UNIQUE_ITEM,
			frame_texture      	= "ReplaceableTextures\\CommandButtons\\BTNMedalionOfCourage.blp",
			soundpack 			= ITEM_SOUNDPACK[SOUNDPACK_CHARM],
			item_description 	= LOCALE_LIST[my_locale].MEDALLION_DESC_4,
			cost = 200,
			sell_penalty = 0.5,
			sellable = false,
			droppable = false,
			cooldown_type = 1,
			usable = true
		})


		ItemAddData('I00N', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_RAT_HUNTER,
			TYPE = ITEM_TYPE_WEAPON,
			SUBTYPE = BOW_WEAPON,
			ATTRIBUTE = POISON_ATTRIBUTE,
			DAMAGE  = 50,
			stat_modificator = 1.2,
			QUALITY = UNIQUE_ITEM,
			level = 5,
			flippy = true,
			frame_texture = "Weapons\\BTNInfernal bow.blp",
			model = "Items\\Weapon_Bow_1.mdx",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_RAT_HUNTER .."\"",
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 1.25, METHOD = STRAIGHT_BONUS },
				{ PARAM = AGI_STAT, VALUE = 3, METHOD = STRAIGHT_BONUS, base = 3, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOW],
		})

		ItemAddData('I00O', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_BOOT_OF_COWARD,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			stat_modificator = 0.8,
			flippy = true,
			BONUS   = {
				{ PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 20, METHOD = STRAIGHT_BONUS },
				{ PARAM = AGI_STAT, VALUE = 4, METHOD = STRAIGHT_BONUS, base = 4, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNbt.blp",
			legendary_effect = GetLegendaryEffect("BTCW"),
			--legendary_description = LOCALE_LIST[my_locale].ITEM_LEG_DESCRIPTION_BOOT_OF_COWARD,
			special_description = "\""..LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_BOOT_OF_COWARD.."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOTS_LIGHT_ARMOR],
		})

		ItemAddData('I00P', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_WITCH_MASTERY,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			ATTRIBUTE = FIRE_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 5, METHOD = STRAIGHT_BONUS },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 0.3, METHOD = STRAIGHT_BONUS },
				{ PARAM = INT_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTN_CW_Red_Scepter.blp",
			model = "Items\\StaffOfSilence.mdx",
			legendary_effect = GetLegendaryEffect("EWTM"),--{ id = "EWTM", type = ITEM_PASSIVE_EFFECT },
			--legendary_description = LOCALE_LIST[my_locale].ITEM_LEG_DESCRIPTION_WITCH_MASTERY,
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_WITCH_MASTERY .."\"",
			soundpack = { equip = "Sound\\staff_manadrinker_equip.wav", uneqip = "Sound\\staff_unequip.wav", drop = "Sound\\staff.wav" }
		})

		ItemAddData('I00Q', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_DARK_CROWN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			stat_modificator = 0.85,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = DARKNESS_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = DARKNESS_RESIST, VALUE = 20, METHOD = STRAIGHT_BONUS, base = 20, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = CONTROL_REDUCTION, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNDarkCrown.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_DARK_CROWN .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_LIGHT_ARMOR],
		})

		ItemAddData('I01L', {
			NAME    = "Обруч Напряжения", --LOCALE_LIST[my_locale].ITEM_NAME_DARK_CROWN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 30,
			stat_modificator = 0.85,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MAGICAL_ATTACK, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = CRIT_CHANCE, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = DARKNESS_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNdiadem1.blp",
			special_description = "\"".. "Приносит одну головную боль. Но не только его владельцу." .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_LIGHT_ARMOR],
		})

		ItemAddData('I00R', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_RITUAL_DAGGER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 0.9,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 5, METHOD = STRAIGHT_BONUS },
				{ PARAM = HP_REGEN, VALUE = 1.15, METHOD = MULTIPLY_BONUS },
				{ PARAM = AGI_STAT, VALUE = 2, METHOD = STRAIGHT_BONUS, base = 2, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTNBlack Navaja.blp",
			model = "Items\\RuneDagger.mdx",
			legendary_effect = GetLegendaryEffect("RDAG"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_RITUAL_DAGGER .."\"",
			soundpack = { equip = "Sound\\daggers_ashes_equip.wav", uneqip = "Sound\\dagger_unequip.wav", drop = "Sound\\dagger.wav" }
		})

		ItemAddData('I02E', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_BLOOD_DRINKER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.7,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS },
				{ PARAM = STR_STAT, VALUE = 4, METHOD = STRAIGHT_BONUS, base = 4, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = HP_PER_HIT, VALUE = 15, METHOD = STRAIGHT_BONUS, base = 15, delta = 1, delta_level = 5, delta_level_max = 8 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTNtier4 sword.blp",
			model = "Items\\Bloodstone Longsword.mdx",
			--legendary_effect = GetLegendaryEffect("RDAG"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_BLOOD_DRINKER .."\"",
			soundpack = { equip = "Sound\\sword_souldrinker_equip.wav", uneqip = "Sound\\weapon_unequip.wav", drop = "Sound\\largemetalweapon.wav" }
		})


		ItemAddData('I02F', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_FAMILY_RING,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 0.85,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = EXP_BONUS, VALUE = 15, METHOD = STRAIGHT_BONUS },
				{ PARAM = HEALING_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = BONUS_UNDEAD_DAMAGE, VALUE = 7, METHOD = STRAIGHT_BONUS, base = 7, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Jewelry\\BTNGold Mystic Ring.blp",
			--set_bonus = GetItemSet("FRBD"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_FAMILY_RING .."\"",
			soundpack = { equip = "Sound\\ring_secondchance_equip.wav", uneqip = "Sound\\ring_secondchance_unequip.wav", drop = "Sound\\ring.wav" }
		})

		ItemAddData('I02G', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_PRIMAL_TOME,
			TYPE    = ITEM_TYPE_OFFHAND,
			SUBTYPE = ORB_OFFHAND,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MP_VALUE, VALUE = 50, METHOD = STRAIGHT_BONUS, base = 50, delta = 3, delta_level = 5, delta_level_max = 10 },
				{ PARAM = INT_STAT, VALUE = 7, METHOD = STRAIGHT_BONUS, base = 7, delta = 1, delta_level = 15, delta_level_max = 5 },
				{ PARAM = DARKNESS_BONUS, VALUE = 4, METHOD = STRAIGHT_BONUS, base = 4, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 2,
			frame_texture = "Offhand\\BTNUmbralTome2.blp",
			model = "Items\\Primal Tome.mdx",
			legendary_effect = GetLegendaryEffect("primal_tome_leg"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_PRIMAL_TOME .."\"",
			soundpack = { equip = "Sound\\gem.wav", uneqip = "Sound\\gem.wav", drop = "Sound\\gem.wav" }
		})

		ItemAddData('I00S', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_ACOLYTE_MANTLE,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			stat_modificator = 1.,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = PHYSICAL_DEFENCE, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = MAGICAL_SUPPRESSION, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = ALL_RESIST, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Armor\\BTNCloak of shadows.blp",
			texture = TEXTURE_ID_ARMOR_03,
			model = "Items\\Armor_04.mdx",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_ACOLYTE_MANTLE .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHEST_LIGHT_ARMOR],
		})

		ItemAddData('I00T', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_SMORC_PICKAXE,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = AXE_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			ATTRIBUTE_BONUS = 5,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_MULTIPLIER, VALUE = 1., METHOD = STRAIGHT_BONUS },
				{ PARAM = STR_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 4,
			frame_texture = "ReplaceableTextures\\CommandButtons\\BTNGatherGold.blp",
			model = "Items\\Pickaxe.mdx",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_SMORC_PICKAXE .."\"",
			soundpack = { equip = "Sound\\staff_equip.wav", uneqip = "Sound\\staff_unequip.wav", drop = "Sound\\sword.wav" }
		})
		ItemAddData('I018', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_BOOSTERS,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			stat_modificator = 1.1,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = PHYSICAL_RESIST, VALUE = 7, METHOD = STRAIGHT_BONUS },
				{ PARAM = MOVING_SPEED, VALUE = 20, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Armor\\BTNSteampunkBoots.blp",
			legendary_effect =  GetLegendaryEffect("BSTR"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_BOOSTERS .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOTS_HEAVY_ARMOR],
		})

		ItemAddData('I019', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_EYE_OF_THE_STORM,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = NECKLACE_JEWELRY,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 1.12,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = LIGHTNING_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 1, delta_level = 5, delta_level_max = 25 },
				{ PARAM = INT_STAT, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			SKILL_BONUS = { { id = "A00J", bonus_levels = 3 } },
			MAX_SLOTS = 2,
			frame_texture = "Jewelry\\BTNStorm Necklace.blp",
			legendary_effect = GetLegendaryEffect("EOTS"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_EYE_OF_THE_STORM .."\"",
			soundpack = { equip = "Sound\\ring_dexterity_equip.wav", uneqip = "Sound\\ring_dexterity_unequip.wav", drop = "Sound\\amulet.wav" }
		})

		ItemAddData('I01A', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_FIREPRINCESS,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = NECKLACE_JEWELRY,
			QUALITY = SET_ITEM,
			stat_modificator = 1.12,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = FIRE_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 1, delta_level = 5, delta_level_max = 25 },
				{ PARAM = MAGICAL_ATTACK, VALUE = 35, METHOD = STRAIGHT_BONUS, base = 35, delta = 2, delta_level = 1, delta_level_max = 35 },
				{ PARAM = CRIT_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 1,
			frame_texture = "Jewelry\\BTNFireprincessNecklace2.blp",
			set_bonus = GetItemSet("FRBD"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_FIREPRINCESS .."\"",
			soundpack = { equip = "Sound\\ring_protectfire_equip.wav", uneqip = "Sound\\ring_protectfire_unequip.wav", drop = "Sound\\amulet.wav" }
		})

		ItemAddData('I01B', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_FIREQUEEN,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = SET_ITEM,
			stat_modificator = 0.9,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MP_VALUE, VALUE = 25, METHOD = STRAIGHT_BONUS, base = 25, delta = 1, delta_level = 1, delta_level_max = 35 },
				{ PARAM = FIRE_RESIST, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 2, delta_level = 5, delta_level_max = 10 },
				{ PARAM = CAST_SPEED, VALUE = 15, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 1,
			frame_texture = "Jewelry\\BTNFirequeenRing.blp",
			set_bonus = GetItemSet("FRBD"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_FIREQUEEN .."\"",
			soundpack = { equip = "Sound\\ring_protectfire_equip.wav", uneqip = "Sound\\ring_protectfire_unequip.wav", drop = "Sound\\ring.wav" }
		})

		ItemAddData('I01C', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_PAIN_ECHO,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 0.8,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = REFLECT_DAMAGE, VALUE = 55, METHOD = STRAIGHT_BONUS, base = 55, delta = 3, delta_level = 1, delta_level_max = 25 },
				{ PARAM = ATTACK_SPEED, VALUE = 12, METHOD = STRAIGHT_BONUS },
				{ PARAM = PHYSICAL_ATTACK, VALUE = 27, METHOD = STRAIGHT_BONUS, base = 27, delta = 1, delta_level = 1, delta_level_max = 45 },
			},
			MAX_SLOTS = 1,
			SKILL_BONUS = { { id = "A006", bonus_levels = 4 } },
			frame_texture = "Jewelry\\BTNDarknessRing.blp",
			legendary_effect = GetLegendaryEffect("PNEC"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_PAIN_ECHO .."\"",
			soundpack = { equip = "Sound\\ring_regeneration_equip.wav", uneqip = "Sound\\ring_regeneration_unequip.wav", drop = "Sound\\ring.wav" }
		})

		ItemAddData('I01D', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CRYSTAL_AXE,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = AXE_WEAPON,
			QUALITY = UNIQUE_ITEM,
			ATTRIBUTE = ICE_ATTRIBUTE,
			ATTRIBUTE_BONUS = 7,
			stat_modificator = 0.9,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = STR_STAT, VALUE = 2, METHOD = STRAIGHT_BONUS, base = 2, delta = 1, delta_level = 15, delta_level_max = 3 },
				{ PARAM = ICE_RESIST, VALUE = 4, METHOD = STRAIGHT_BONUS, base = 4, delta = 1, delta_level = 10, delta_level_max = 10 },
				{ PARAM = PHYSICAL_ATTACK, VALUE = 27, METHOD = STRAIGHT_BONUS, base = 27, delta = 1, delta_level = 1, delta_level_max = 45 },
			},
			MAX_SLOTS = 1,
			frame_texture = "Weapons\\BTNFrostAxe.blp",
			model = "Items\\Frozen Axe.mdx",
			legendary_effect = GetLegendaryEffect("ECRA"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CRYSTAL_AXE .."\"",
			soundpack = { equip = "Sound\\daggers_polar_equip.wav", uneqip = "Sound\\daggers_polar_unequip.wav", drop = "Sound\\largemetalweapon.wav" }
		})

		ItemAddData('I01E', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_BOOTSOFPAIN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = SET_ITEM,
			DEFENCE = 20,
			stat_modificator = 1.1,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = PHYSICAL_ATTACK, VALUE = 37, METHOD = STRAIGHT_BONUS, base = 37, delta = 1, delta_level = 1, delta_level_max = 45 },
				{ PARAM = MAGICAL_ATTACK, VALUE = 55, METHOD = STRAIGHT_BONUS, base = 55, delta = 2, delta_level = 1, delta_level_max = 45 },
				{ PARAM = MOVING_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNGoreBoot.blp",
			set_bonus = GetItemSet("FRDL"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_BOOTSOFPAIN .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOTS_HEAVY_ARMOR],
		})

		ItemAddData('I01F', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CHESTOFPAIN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = SET_ITEM,
			DEFENCE = 20,
			stat_modificator = 1.25,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 6, METHOD = STRAIGHT_BONUS },
				{ PARAM = ATTACK_SPEED, VALUE = 7, METHOD = STRAIGHT_BONUS },
				{ PARAM = CAST_SPEED, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNSpikedArmor.blp",
			set_bonus = GetItemSet("FRDL"),
			model = "Items\\Armor_06.mdx",
			texture = TEXTURE_ID_ARMOR_04,
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CHESTOFPAIN .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHEST_MID_ARMOR],
		})

		ItemAddData('I01G', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_HEADOFPAIN,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = SET_ITEM,
			DEFENCE = 20,
			stat_modificator = 1.12,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 11, METHOD = STRAIGHT_BONUS },
				{ PARAM = RANGE_DAMAGE_REDUCTION, VALUE = 11, METHOD = STRAIGHT_BONUS },
				{ PARAM = HP_VALUE, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTN_Royal_Helmet.blp",
			set_bonus = GetItemSet("FRDL"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_HEADOFPAIN .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_HEAVY_ARMOR],
		})

		ItemAddData('I01H', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_THE_KING,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = BLUNT_WEAPON,
			QUALITY = SET_ITEM,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			ATTRIBUTE_BONUS = 5,
			stat_modificator = 0.9,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = STR_STAT, VALUE = 1, METHOD = STRAIGHT_BONUS, base = 1, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = HP_VALUE, VALUE = 44, METHOD = STRAIGHT_BONUS, base = 44, delta = 5, delta_level = 3, delta_level_max = 45 },
				{ PARAM = HOLY_RESIST, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 2, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 1,
			frame_texture = "Weapons\\BTNInfernal Mace.blp",
			model = "Items\\SauronsMace.mdx",
			set_bonus = GetItemSet("KAJS"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_THE_KING .."\"",
			soundpack = { equip = "Sound\\dagger_equip.wav", uneqip = "Sound\\dagger_unequip.wav", drop = "Sound\\largemetalweapon.wav" }
		})

		ItemAddData('I01I', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_THE_JESTER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = DAGGER_WEAPON,
			QUALITY = SET_ITEM,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			ATTRIBUTE_BONUS = 5,
			stat_modificator = 0.82,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = AGI_STAT, VALUE = 1, METHOD = STRAIGHT_BONUS, base = 1, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = MP_VALUE, VALUE = 20, METHOD = STRAIGHT_BONUS, base = 20, delta = 3, delta_level = 2, delta_level_max = 25 },
				{ PARAM = DARKNESS_RESIST, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 2, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 1,
			frame_texture = "Weapons\\BTNBlood Stinger.blp",
			model = "Items\\Inferno Dagger.mdx",
			set_bonus = GetItemSet("KAJS"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_THE_JESTER .."\"",
			soundpack = { equip = "Sound\\dagger_equip.wav", uneqip = "Sound\\dagger_unequip.wav", drop = "Sound\\smallmetalweapon.wav" }
		})

		ItemAddData('I01J', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_MASTER_OF_ELEMENTS,
			TYPE    = ITEM_TYPE_OFFHAND,
			SUBTYPE = ORB_OFFHAND,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MP_REGEN, VALUE = 1.05, METHOD = MULTIPLY_BONUS },
				{ PARAM = INT_STAT, VALUE = 4, METHOD = STRAIGHT_BONUS, base = 4, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Offhand\\BTNMageOrb.blp",
			model = "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdx",
			legendary_effect = GetLegendaryEffect("MOFE"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_MASTER_OF_ELEMENTS .."\"",
			soundpack = { equip = "Sound\\gem.wav", uneqip = "Sound\\gem.wav", drop = "Sound\\gem.wav" }
		})

		ItemAddData('I01W', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_ICE_TOUCH,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 1.1,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = ICE_BONUS, VALUE = 10, METHOD = STRAIGHT_BONUS, base = 10, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = CRIT_MULTIPLIER, VALUE = 0.1, METHOD = STRAIGHT_BONUS },
				{ PARAM = MELEE_DAMAGE_REDUCTION, VALUE = 5, METHOD = STRAIGHT_BONUS },
			},
			SKILL_BONUS = { { id = "A003", bonus_levels = 4 } },
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNWater Composite Gloves.blp",
			legendary_effect = GetLegendaryEffect("ITCH"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_ICE_TOUCH .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HANDS_MID_ARMOR],
		})

		ItemAddData('I026', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_DEATH_HERALD,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = BELT_ARMOR,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 1.,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = MOVING_SPEED, VALUE = 1.1, METHOD = MULTIPLY_BONUS },
				{ PARAM = PHYSICAL_ATTACK, VALUE = 35, METHOD = STRAIGHT_BONUS, base = 35, delta = 1, delta_level = 2, delta_level_max = 15 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Armor\\BTNUnholyStrength.blp",
			legendary_effect = GetLegendaryEffect("ITDH"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_DEATH_HERALD .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BELT],
		})

		ItemAddData('I02I', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CRIMSON_BREASTPLATE,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = CHEST_ARMOR,
			QUALITY = SET_ITEM,
			stat_modificator = 1.3,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = HP_VALUE, VALUE = 30, METHOD = STRAIGHT_BONUS, base = 30, delta = 10, delta_level = 3, delta_level_max = 25 },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNFire Plate Armor.blp",
			set_bonus = GetItemSet("crimson_legion_set"),
			texture = TEXTURE_ID_ARMOR_02,
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CRIMSON_BREASTPLATE .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_CHEST_HEAVY_ARMOR]
		})

		ItemAddData('I02J', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CRIMSON_HELMET,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = SET_ITEM,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MP_VALUE, VALUE = 30, METHOD = STRAIGHT_BONUS, base = 30, delta = 10, delta_level = 3, delta_level_max = 25 },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNFire Horned Helmet.blp",
			set_bonus = GetItemSet("crimson_legion_set"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CRIMSON_HELMET .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_HEAVY_ARMOR]
		})


		ItemAddData('I02K', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CRIMSON_BOOTS,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = LEGS_ARMOR,
			QUALITY = SET_ITEM,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = STR_STAT, VALUE = 2, METHOD = STRAIGHT_BONUS, base = 2, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = MOVING_SPEED, VALUE = 25, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 2,
			frame_texture = "Armor\\BTNFire Boot.blp",
			set_bonus = GetItemSet("crimson_legion_set"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CRIMSON_BOOTS .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOTS_HEAVY_ARMOR]
		})

		ItemAddData('I02L', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CRIMSON_GAUNTLETS,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HANDS_ARMOR,
			QUALITY = SET_ITEM,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS },
				{ PARAM = ATTACK_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
				{ PARAM = CAST_SPEED, VALUE = 10, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 1,
			frame_texture = "Armor\\BTNFire Gauntlet.blp",
			set_bonus = GetItemSet("crimson_legion_set"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CRIMSON_GAUNTLETS .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HANDS_HEAVY_ARMOR]
		})

		ItemAddData('I02Q', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_MASK_OF_SHADOWS,
			TYPE    = ITEM_TYPE_ARMOR,
			SUBTYPE = HEAD_ARMOR,
			QUALITY = UNIQUE_ITEM,
			DEFENCE = 20,
			stat_modificator = 0.9,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MAGICAL_SUPPRESSION, VALUE = 40, METHOD = STRAIGHT_BONUS, base = 40, delta = 2, delta_level = 1, delta_level_max = 50 },
				{ PARAM = MP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 1, delta_level = 5, delta_level_max = 5 },
				{ PARAM = CRIT_CHANCE, VALUE = 7, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			legendary_effect = GetLegendaryEffect("illusion_legendary"),
			frame_texture = "Armor\\BTNShadowHelmet.BLP",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_MASK_OF_SHADOWS .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_HEAD_MID_ARMOR],
		})

		ItemAddData('I02R', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_SPLITTER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			ATTRIBUTE = DARKNESS_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.2,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 12, METHOD = STRAIGHT_BONUS },
				{ PARAM = DARKNESS_BONUS, VALUE = 14, METHOD = STRAIGHT_BONUS, base = 14, delta = 1, delta_level = 5, delta_level_max = 5 },
				{ PARAM = MAGICAL_ATTACK, VALUE = 35, METHOD = STRAIGHT_BONUS, base = 35, delta = 2, delta_level = 1, delta_level_max = 15 },
				{ PARAM = BONUS_HUMAN_DAMAGE, VALUE = 14, METHOD = STRAIGHT_BONUS, base = 14, delta = 1, delta_level = 10, delta_level_max = 5 },
				{ PARAM = BONUS_BEAST_DAMAGE, VALUE = 14, METHOD = STRAIGHT_BONUS, base = 14, delta = 1, delta_level = 10, delta_level_max = 5 },
			},
			MAX_SLOTS = 2,
			frame_texture = "Weapons\\BTNHollowScythe.blp",
			model = "Items\\Scythe2.mdx",
			legendary_effect = GetLegendaryEffect("splitter_legendary"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_SPLITTER .."\"",
			soundpack = { equip = "Sound\\staff_manadrinker_equip.wav", uneqip = "Sound\\staff_unequip.wav", drop = "Sound\\staff.wav" }
		})

		ItemAddData('I02S', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_EXECUTIONER,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = GREATSWORD_WEAPON,
			ATTRIBUTE = PHYSICAL_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			stat_modificator = 1.7,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CRIT_CHANCE, VALUE = 6, METHOD = STRAIGHT_BONUS },
				{ PARAM = HP_VALUE, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
				{ PARAM = MP_PER_HIT, VALUE = 5, METHOD = STRAIGHT_BONUS, base = 5, delta = 1, delta_level = 5, delta_level_max = 10 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTNDeathbringer.blp",
			model = "Items\\Blade_Blood_King.mdx",
			legendary_effect = GetLegendaryEffect("executioner_Legendary"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_EXECUTIONER .."\"",
			soundpack = { equip = "Sound\\sword_souldrinker_equip.wav", unequip = "Sound\\sword_unequip.wav", drop = "Sound\\sword.wav" }
		})

		ItemAddData('I02X', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_FULLMOON,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = NECKLACE_JEWELRY,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 1.5,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = MP_VALUE, VALUE = 100, METHOD = STRAIGHT_BONUS, base = 100, delta = 3, delta_level = 1, delta_level_max = 50 },
				{ PARAM = MP_REGEN, VALUE = 1.3, METHOD = MULTIPLY_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Jewelry\\BTNMoonAmulet.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_FULLMOON .."\"",
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_AMULET],
		})

		ItemAddData('I037', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_PAIN_CONDUCTOR,
			TYPE    = ITEM_TYPE_JEWELRY,
			SUBTYPE = RING_JEWELRY,
			QUALITY = UNIQUE_ITEM,
			stat_modificator = 1.,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = VULNERABILITY, VALUE = 100, METHOD = STRAIGHT_BONUS },
				{ PARAM = DAMAGE_BOOST, VALUE = 100, METHOD = STRAIGHT_BONUS },
			},
			MAX_SLOTS = 3,
			frame_texture = "Jewelry\\BTNRing.blp",
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_PAIN_CONDUCTOR .."\"",
			soundpack = { equip = "Sound\\ring_mana_equip.wav", unequip = "Sound\\ring_unequip.wav", drop = "Sound\\ring.wav" }
		})

		ItemAddData('I03A', {
			NAME    = LOCALE_LIST[my_locale].ITEM_NAME_CATALYST,
			TYPE    = ITEM_TYPE_WEAPON,
			SUBTYPE = STAFF_WEAPON,
			ATTRIBUTE = FIRE_ATTRIBUTE,
			QUALITY = UNIQUE_ITEM,
			DAMAGE  = 50,
			ATTRIBUTE_BONUS = 10,
			stat_modificator = 1.25,
			flippy = true,
			level = 10,
			BONUS   = {
				{ PARAM = CAST_SPEED, VALUE = 12, METHOD = STRAIGHT_BONUS },
				{ PARAM = MAGICAL_ATTACK, VALUE = 75, METHOD = STRAIGHT_BONUS, base = 75, delta = 1, delta_level = 1, delta_level_max = 25 },
				{ PARAM = MP_VALUE, VALUE = 25, METHOD = STRAIGHT_BONUS, base = 25, delta = 1, delta_level = 1, delta_level_max = 25 },
			},
			MAX_SLOTS = 3,
			frame_texture = "Weapons\\BTNInfernoStaff.blp",
			model = "Items\\Staff-DragonStaff.mdx",
			legendary_effect = GetLegendaryEffect("catalyst_Legendary"),
			special_description = "\"".. LOCALE_LIST[my_locale].ITEM_SPEC_DESCRIPTION_CATALYST .."\"",
			soundpack = { equip = "Sound\\staff_fire_equip.wav", unequip = "Sound\\staff_unequip.wav", drop = "Sound\\staff.wav" }
		})

		ItemAddData('I02H', {
			NAME    		   = LOCALE_LIST[my_locale].LOOTBOX_NAME,
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 		   = RARE_ITEM,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNMagicVault.blp",
			item_description   = LOCALE_LIST[my_locale].LOOTBOX_DESC,
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_GEM],
			cost = 1000,
			usable = true
		})

		ItemAddData('I02M', {
			NAME    		   = GetLocalString("Карта", "The Map"),
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 		   = RARE_ITEM,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNSpy.blp",
			item_description   = GetLocalString("На нее нанесены несколько отметок.", "You can see several markers on it."),
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_SCROLL],
			cost = 1000,
			usable = true,
			droppable = false,
			sellable = false,
			permanent = true
		})

		ItemAddData('I02T', {
			NAME    		   = GetLocalString("Припасы", "Supplies"),
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 		   = COMMON_ITEM,
			frame_texture      = "ReplaceableTextures\\CommandButtons\\BTNDust.blp",
			item_description   = GetLocalString("Тяжелый.", "It's heavy."),
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_BOOK],
			cost = 1000,
			usable = false,
			droppable = false,
			sellable = false,
			permanent = true
		})

		ItemAddData('I038', {
			NAME    		   = GetLocalString("Лопата", "Shovel"),
			TYPE    		   = ITEM_TYPE_OTHER,
			QUALITY 		   = RARE_ITEM,
			frame_texture      = "war3mapImported\\BTNINV_Misc_Shovel_01.blp",
			item_description   = GetLocalString("Копай!", "Gig in!"),
			soundpack = ITEM_SOUNDPACK[SOUNDPACK_STAFF],
			cost = 1000,
			usable = true,
			droppable = false,
			sellable = false,
			permanent = true
		})

		InitRunewords()

    end

	--[[

	The Conductor
	big lightning strike

	Кукла вуду
	Содержит чьи-то волосы. Опасная игрушка.

	Громоотвод
	Где вы его раздобыли??? В любом случае, может воскресить вас при ударе молнии. Или убить.

		Амулет хаоса
	Переодически нестабильным и начинается дичь.

	Рубик в Кубике
	Маленькое существо в кубике. Вы чувствуете что его зовут Рубик.

		Трезубец короля морей
	Может в красивые молнии. Однако владелец также в опасности.

	Непробиваемый Наколенник Искателя Приключений

	хочу легендарный меч проворства
	легенда увеличивает шанс крита на 20%, а проворства +25 ловкости


	сапоги на некра
	тяжесть
	пока действует броня + к резисту контроля

	расщепление
	костяное копье при столкновении расщепляется на несколько мелких

	]]
	
end