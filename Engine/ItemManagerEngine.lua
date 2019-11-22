do



    local QUALITY_COLOR = {
        [COMMON_ITEM] = '|c00FFFFFF',
        [RARE_ITEM] = '|c00669FFF',
        [MAGIC_ITEM] = '|c00FFFF00',
        [SET_ITEM] = '|c0000FF00',
        [UNIQUE_ITEM] = '|c00FFD574'
    }

    ---@param quality number
    function GetQualityColor(quality)
        return QUALITY_COLOR[quality]
    end

    ---@param my_item item
    function GetItemNameColorized(my_item)
        local item_data = ITEM_DATA[GetHandleId(my_item)]
        return QUALITY_COLOR[item_data.QUALITY] .. item_data.NAME .. '|r'
    end


    ---@param my_item item
    function GetItemData(my_item)
        return ITEM_DATA[GetHandleId(my_item)]
    end


    ---@param raw string
    ---@param x real
    ---@param y real
	function CreateCustomItem(raw, x, y)
		local id     = FourCC(raw)
		local item   = CreateItem(id, x, y)
		local handle = GetHandleId(item)
		local data   = {}

		for k, v in pairs(ITEM_TEMPLATE_DATA[id]) do
			data[k] = v
		end
		
		-- data это уже данные конкретного предмета с которыми можно делать что угодно
		
		ITEM_DATA[handle] = data
		return item
	end
end