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
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].NAME)

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1][1]))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1][2])
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1][3])

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2][1]))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2][2])
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2][3])

		BJDebugMsg("=================")
		local my_item = CreateCustomItem('I000', GetRectCenterX(gg_rct_test), GetRectCenterY(gg_rct_test))

		BJDebugMsg(ITEM_DATA[GetHandleId(my_item)].NAME)
	end
end