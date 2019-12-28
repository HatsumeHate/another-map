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
        EnumItemsOnInit()
		UnitDataInit()
        InitWeather(bj_mapInitialPlayableArea)


		--NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS, nil, {  ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15., missile = 'M002' })
        --NewUnitData(gg_unit_HSRC_0004, SORCERESS_CLASS,  { health = 3000., hp_regen = 30. }, nil)
        AddToPanel(gg_unit_HBRB_0005, 1)


		UnitAddMyAbility(gg_unit_HBRB_0005, 'A007')
		BindAbilityKey(gg_unit_HBRB_0005, 'A007', KEY_Q)

		UnitAddMyAbility(gg_unit_HBRB_0005, 'A00K')
		BindAbilityKey(gg_unit_HBRB_0005, 'A00K', KEY_R)

        DrawShopFrames(1)
        CreateShop(gg_unit_opeo_0031)

		--PushUnit(gg_unit_HBRB_0005, 270., 400., 1.25)
		--MakeUnitJump(gg_unit_HBRB_0005, 0., GetUnitX(gg_unit_HBRB_0005) + 500., GetUnitY(gg_unit_HBRB_0005), 500., 0.6)

		TimerStart(CreateTimer(), 5., false, function()
            local item = CreateCustomItem("IGSO",  GetUnitX(gg_unit_HBRB_0005) - 100., GetUnitY(gg_unit_HBRB_0005) - 100.)
            GenerateItemStats(item, GetRandomInt(1, 100), COMMON_ITEM)
            AddItemToShop(gg_unit_opeo_0031, item, false)
			--CreateCustomItem('I000', GetUnitX(gg_unit_HBRB_0005), GetUnitY(gg_unit_HBRB_0005))
            AddPointsToPlayer(1, 10)
		end)


	end
end