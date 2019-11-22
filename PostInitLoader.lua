do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
        DefineItemsData()
		DefineBuffsData()
        MainEngineInit()


		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, {  ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15. })
        NewUnitData(gg_unit_HSRC_0004, SORCERESS_CLASS,  { health = 3000., hp_regen = 30. }, nil)

        print(BUFF_DATA[FourCC('A002')].name)
        print(BUFF_DATA[FourCC('A002')].level[1].time)
		print(BUFF_DATA[FourCC('A002')].level[1].bonus[1].PARAM)

		TimerStart(CreateTimer(), 3., false, function()
			ApplyBuff(gg_unit_HSRC_0004, gg_unit_HSRC_0004, 'A002', 1)
		end)


	end
end