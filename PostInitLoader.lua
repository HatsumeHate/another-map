do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()

		InitLocaleLibrary()
		InitParameters()
		DefineSkillsData()
		DefineEffectsData()
		DefineItemGeneratorTemplates()
        DefineItemsData()
		DefineBuffsData()
		DefineMissilesData()
        MainEngineInit()
		BasicFramesInit()
        EnumItemsOnInit()
		UnitDataInit()
		StatsPanelInit()
		InventoryInit()
		SkillPanelInit()
        InitWeather(bj_mapInitialPlayableArea)
		InitMonsterData()

		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A007')
		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A00K')
		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A00O')
		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A00Z')
		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A00B')
		--UnitAddMyAbility(gg_unit_HBRB_0005, 'A00Q')
        CreateShop(gg_unit_opeo_0031, "ReplaceableTextures\\CommandButtons\\BTNPeon.blp")
		CreateShop(gg_unit_n000_0056, "ReplaceableTextures\\CommandButtons\\BTNVillagerMan1.blp")
		CreateShop(gg_unit_n001_0055, "ReplaceableTextures\\CommandButtons\\BTNVillagerWoman.blp")


		local my_item = CreateCustomItem("I006",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 32, true)


		my_item = CreateCustomItem("I003",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)
		my_item = nil


		CreateHeroSelections()

		--PushUnit(gg_unit_HBRB_0005, 270., 400., 1.25)
		--MakeUnitJump(gg_unit_HBRB_0005, 0., GetUnitX(gg_unit_HBRB_0005) + 500., GetUnitY(gg_unit_HBRB_0005), 500., 0.6)


		TimerStart(CreateTimer(), 5., false, function()
			WavesInit()
			AddWaveTimer(360.)

			CreateGoldStack(25, 7345., 3201., 0)
			CreateGoldStack(35, 7445., 3201., 0)
			CreateGoldStack(45, 7555., 3201., 0)

			--local quality_table = {COMMON_ITEM, MAGIC_ITEM, RARE_ITEM }
				--[[
				TimerStart(CreateTimer(), 5., true, function()
					local item = CreateCustomItem(GetRandomGeneratedId(),  GetUnitX(gg_unit_HBRB_0005) - 100., GetUnitY(gg_unit_HBRB_0005) - 100.)
					GenerateItemStats(item, 1, MAGIC_ITEM)
					AddItemToShop(gg_unit_opeo_0031, item, false)
					counter = counter + 1
					if counter == 32 then DestroyTimer(GetExpiredTimer()) end
				end)]]


			--for i = 1, 32 do
				--local item = CreateCustomItem(GetRandomGeneratedId(),  GetUnitX(gg_unit_HBRB_0005) - 100., GetUnitY(gg_unit_HBRB_0005) - 100.)
				--GenerateItemStats(item, 1, quality_table[GetRandomInt(1, 3)])
				--AddItemToShop(gg_unit_opeo_0031, item, false)
			--end

			--CreateCustomItem('I000', GetUnitX(gg_unit_HBRB_0005), GetUnitY(gg_unit_HBRB_0005))
            --AddPointsToPlayer(1, 10)
		end)


	end
end