do
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