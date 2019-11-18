do
	---@param raw string
	---@param x real
	---@param y real
	function CreateCustomItem(raw, x, y)
		return  CreateItem(FourCC(raw), x, y)
	end
end