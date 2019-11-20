do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
        DefineItemsData()
        MainEngineInit()


		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, { DAMAGE = 15, CRIT_CHANCE = 15. } )


	end
end