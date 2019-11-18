do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
		DefineParametersData()


		BJDebugMsg("ok")

		BJDebugMsg(EffectsData[1].name)
		BJDebugMsg(EffectsData[1].level[1].Power)
		BJDebugMsg(GetParameterName(EffectsData[1].level[1].Attribute))
		BJDebugMsg("=================")
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].name)

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[1].param_type))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[1].param_value)
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[1].modificator)

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[2].param_type))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[2].param_value)
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].bonus_parameters[2].modificator)

		BJDebugMsg("=================")
		local my_item = CreateCustomItem(FourCC('I000'), GetRectCenterX(gg_rct_test), GetRectCenterY(gg_rct_test))

		BJDebugMsg(ItemsData[GetHandleId(my_item)].name)
	end
end