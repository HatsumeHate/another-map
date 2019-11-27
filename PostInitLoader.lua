do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
        DefineItemsData()
		DefineBuffsData()
		DefineMissilesData()
        MainEngineInit()
		BasicFramesInit()
        StatsPanelInit()
		InventoryInit()




		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, {  ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15., missile = 'M002' })
        NewUnitData(gg_unit_HSRC_0004, SORCERESS_CLASS,  { health = 3000., hp_regen = 30. }, nil)
        AddToPanel(gg_unit_HBRB_0005, 1)

		TimerStart(CreateTimer(), 5., false, function()
			CreateCustomItem('I000', GetUnitX(gg_unit_HBRB_0005), GetUnitY(gg_unit_HBRB_0005))
            AddPointsToPlayer(1, 10)
			--ThrowMissile(gg_unit_HBRB_0005, nil, '0000', nil, GetUnitX(gg_unit_HBRB_0005), GetUnitY(gg_unit_HBRB_0005), GetUnitX(gg_unit_HSRC_0004), GetUnitY(gg_unit_HSRC_0004), 0.)
            --ApplyEffect(gg_unit_HBRB_0005, gg_unit_HSRC_0004, 0., 0., 'EFF1', 1)
			--ApplyBuff(gg_unit_HSRC_0004, gg_unit_HSRC_0004, 'A002', 1)
		end)

        InventoryInit()

	end
end