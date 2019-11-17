do
	local ITEM_EQUIP_SLOT_LEFT_HAND  = 1 -- левая рука
	local ITEM_EQUIP_SLOT_RIGHT_HAND = 2 -- правая рука
	local ITEM_EQUIP_SLOT_BOTH_HAND  = 3 -- двуручное
	
	local ITEM_DATA                  = {}
	
	local function ItemMergeData(a, b)
		-- написать свою функцию с блэкджеком и шлюхами
	end
	
	function ItemAddData(raw, data)
		ITEM_DATA[FourCC(raw)] = ItemMergeData(
				{
					NAME         = '',
					IS_CAN_EQUIP = false, -- можно ли экипировать, по умолчанию выключено
					EQUIP_SLOT   = {}, -- слоты сделаны массивом, чтоб например можно было брать в руки шлем и гниздить им врагов
					SOME_DATA    = '', -- какаято инфа
					MODEL        = {}, -- модель сделана таблицей, чтоб например держать аттачи оружия для левой или правой руки
					LEVEL_DATA   = {},
					LEVEL        = 1,
					DAMAGE       = 5,
					ARMOR        = 0,
					SPEED        = 100
				},
				data
		)
	end
	
	ItemAddData('I000', {
		IS_CAN_EQUIP = true,
		EQUIP_SLOT   = { ITEM_EQUIP_SLOT_RIGHT_HAND, ITEM_EQUIP_SLOT_LEFT_HAND },
		LEVEL_DATA   = { -- при повышении уровня основное значение заменится соответствующим
			{ DAMAGE = 10 },
			{
				DAMAGE = 20,
				ARMOR  = 2
			},
			{
				DAMAGE = 30,
				ARMOR  = 2,
				SPEED  = 200
			}
		}
	})


end