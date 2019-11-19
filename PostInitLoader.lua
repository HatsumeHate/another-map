do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
		DefineParametersData()


		BJDebugMsg("ok")

		BJDebugMsg("=================")
		BJDebugMsg("ЭФФЕКТЫ")
		BJDebugMsg(EffectsData[1].name)
		BJDebugMsg(EffectsData[1].level[1].Power)
		BJDebugMsg(GetParameterName(EffectsData[1].level[1].Attribute))
		BJDebugMsg("=================")
		BJDebugMsg("ПРЕДМЕТЫ")
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].NAME)
		if ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1] == nil then
			BJDebugMsg("пустой бонус")
		end

		if ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1].PARAMETER == nil then
			BJDebugMsg("пустой бонус параметр")
		end

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1].PARAMETER))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1].VALUE)
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[1].METHOD)

		BJDebugMsg(GetParameterName(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2].PARAMETER))
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2].VALUE)
		BJDebugMsg(ITEM_TEMPLATE_DATA[FourCC('I000')].BONUS[2].METHOD)

		BJDebugMsg("=================")
		local my_item = CreateCustomItem('I000', GetRectCenterX(gg_rct_test), GetRectCenterY(gg_rct_test))

		BJDebugMsg(ITEM_DATA[GetHandleId(my_item)].NAME)
	end
end