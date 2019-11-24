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


		--print(EffectsData[FourCC('EFF1')].name)
		--print(EffectsData[FourCC('EFF1')].level[1].power)
		--print(EffectsData[FourCC('EFF1')].level[1].SFX_used)

		TimerStart(CreateTimer(), 3., false, function()
            ApplyEffect(gg_unit_HBRB_0005, gg_unit_HSRC_0004, 0., 0., 'EFF1', 1)
			ApplyBuff(gg_unit_HSRC_0004, gg_unit_HSRC_0004, 'A002', 1)
		end)


	end
end