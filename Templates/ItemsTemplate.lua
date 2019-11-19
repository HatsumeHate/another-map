-- Ставь блоки если уж так хочется отступов
do
	ITEM_TEMPLATE_DATA = {} -- данные для ТИПОВ предметов по равкоду
	ITEM_DATA          = {} -- данные для КАЖДОГО предмета по хэндлу
	
	ITEM_TYPE_WEAPON   = 1
	ITEM_TYPE_ARMOR    = 2
	ITEM_TYPE_JEWELRY  = 3
	
	FIST_WEAPON        = 1
	BOW_WEAPON         = 2
	BLUNT_WEAPON       = 3
	GREATBLUNT_WEAPON  = 4
	SWORD_WEAPON       = 5
	GREATSWORD_WEAPON  = 6
	AXE_WEAPON         = 7
	GREATAXE_WEAPON    = 8
	DAGGER_WEAPON      = 9
	STAFF_WEAPON       = 10
	JAWELIN_WEAPON     = 11
	HEAD_ARMOR         = 12
	CHEST_ARMOR        = 13
	LEGS_ARMOR         = 14
	HANDS_ARMOR        = 15
	RING_JEWELRY       = 16 --TODO после прочтения удалить комментарий
	NECKLACE_JEWELRY   = 17
	
	COMMON_ITEM        = 1
	RARE_ITEM          = 2
	MAGIC_ITEM         = 3
	SET_ITEM           = 4
	UNIQUE_ITEM        = 5
	
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
			ANGLE           = math.pi() / 5, -- 36 градусов
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
			ANGLE           = math.pi() / 7.2, -- 25 градусов
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
			DISPERSION      = { 0.75, 1.25 },
			WEAPON_SOUND    = nil
		}
	}
	for k, v in pairs(weapons) do
		v.TYPE    = ITEM_TYPE_WEAPON
		v.SUBTYPE = k
	end
	
	---@param raw string
	---@param data table
	local function ItemAddData(raw, data)
		local newdata = {
			NAME               = '',
			TYPE               = nil,
			SUBTYPE            = nil,
			
			DAMAGE             = 0,
			DAMAGE_TYPE        = DAMAGE_TYPE_PHYSICAL,
			ATTRIBUTE          = PHYSICAL_ATTRIBUTE,
			ATTRIBUTE_BONUS    = 0,
			
			DEFENCE            = 0,
			SUPPRESSION        = 0,
			
			ATTACK_SPEED       = 1,
			CRIT_CHANCE        = 0,
			CRIT_MULTIPLIER    = 0,
			
			DISPERSION         = { 0.9, 1.1 },
			RANGE              = 100,
			ANGLE              = math.pi() / 6, -- 30 градусов
			MAX_TARGETS        = 1,
			
			MISSILE_ON_ATTATCK = 0,
			EFFECT_ON_ATTACK   = 0,
			WEAPON_SOUND       = nil,
			MODEL              = '',
			
			QUALITY            = COMMON_ITEM,
			BONUS              = {},
			MAX_SLOTS          = 0,
			STONE_SLOTS        = {}
		}
		
		ItemMergeData(newdata, weapons[data.SUBTYPE])
		ItemMergeData(newdata, data)
		
		ITEM_TEMPLATE_DATA[FourCC(raw)] = newdata
	end
	
	-- чтобы заполнить инфу не нужно ждать InitGlobals
	ItemAddData('I000', {
		NAME    = 'test sword',
		SUBTYPE = SWORD_WEAPON,
		DAMAGE  = 100,
		QUALITY = RARE_ITEM,
		BONUS   = {
			{ PHYSICAL_BONUS, 20, STRAIGHT_BONUS },
			{ CRIT_CHANCE, 1.25, MULTIPLY_BONUS }
		}
	})
	--
	ItemAddData('I001', {
		NAME    = 'test armor piece',
		TYPE    = ITEM_TYPE_ARMOR,
		SUBTYPE = CHEST_ARMOR,
		QUALITY = MAGIC_ITEM,
		DEFENCE = 50
	})
end