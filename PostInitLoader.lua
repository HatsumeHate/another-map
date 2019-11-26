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



		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, {  ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15., missile = 'M002' })
        NewUnitData(gg_unit_HSRC_0004, SORCERESS_CLASS,  { health = 3000., hp_regen = 30. }, nil)


		TimerStart(CreateTimer(), 3., false, function()
			ThrowMissile(gg_unit_HBRB_0005, nil, '0000', nil, GetUnitX(gg_unit_HBRB_0005), GetUnitY(gg_unit_HBRB_0005), GetUnitX(gg_unit_HSRC_0004), GetUnitY(gg_unit_HSRC_0004), 0.)
            --ApplyEffect(gg_unit_HBRB_0005, gg_unit_HSRC_0004, 0., 0., 'EFF1', 1)
			--ApplyBuff(gg_unit_HSRC_0004, gg_unit_HSRC_0004, 'A002', 1)
		end)

        InventoryInit()

	end
end