do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()

		InitLocaleLibrary()
		InitParameters()
		DefineSkillsData()
		--print("skills done")
		DefineEffectsData()
		--print("effects done")
		DefineItemGeneratorTemplates()
		--print("item generator done")
		InitSetBonusTemplates()
        DefineItemsData()
		--print("items done")
		DefineBuffsData()
		--print("buffs done")
		DefineMissilesData()
		--print("missiles done")
        MainEngineInit()
		--print("main done")
		BasicFramesInit()
		--print("basic frames done")
        EnumItemsOnInit()
		UnitDataInit()
		--print("unit data done")
		StatsPanelInit()
		--print("stats panel done")
		InventoryInit()
		--print("inventory done")
		SkillPanelInit()
		--print("skill panel done")
        InitWeather(bj_mapInitialPlayableArea)
		--print("weather done")
		InitMonsterData()
		--print("monsters done")
		DropListInit()
		--print("droplist done")
		ShakerInit()
		TeleporterInit()
		InitVillageData()
		InitPlayerCamera()
		InitializeSkillEngine()
		StartSMorcWandering()
		InitAltars()

		print("init done")


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

		--CreatePlayerUI(1)
		--PostInitTestUI()

		--PushUnit(gg_unit_HBRB_0005, 270., 400., 1.25)
		--MakeUnitJump(gg_unit_HBRB_0005, 0., GetUnitX(gg_unit_HBRB_0005) + 500., GetUnitY(gg_unit_HBRB_0005), 500., 0.6)


		TimerStart(CreateTimer(), 5., false, function()
			WavesInit()
			AddWaveTimer(300.)
			--TODO introduction
			--TransmissionFromUnitWithNameBJ(force, gg_unit_h000_0054, GetUnitName(capt), nil, "", 1, 10., false)
		end)

		DoNotSaveReplay()
	end

end