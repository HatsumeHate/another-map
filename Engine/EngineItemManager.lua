do
	---@param raw string
	---@param x real
	---@param y real
	function CreateCustomItem(raw, x, y)
		local id          = FourCC(raw)
		local item        = CreateItem(id, x, y)
		local handle      = GetHandleId(item)
		ITEM_DATA[handle] = ITEM_TEMPLATE_DATA[id]
		return item
	end
end