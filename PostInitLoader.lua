do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
        DefineItemsData()
        AutoattackInit()


		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, nil)


	end
end