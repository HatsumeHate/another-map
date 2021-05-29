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
		ShakerInit()
		TeleporterInit()
		InitVillageData()
		InitPlayerCamera()
		InitializeSkillEngine()
		StartSMorcWandering()
		InitAltars()

		print("init done")

		CreateShop(gg_unit_n000_0056, "ReplaceableTextures\\CommandButtons\\BTNVillagerMan1.blp",
				{
					open = {
						"Units\\Human\\Peasant\\PeasantWhat2.wav",
						"Units\\Human\\Peasant\\PeasantWhat4.wav",
					},
					close = {
						"Units\\Human\\Peasant\\PeasantYesAttack1.wav",
						"Units\\Human\\Peasant\\PeasantPissed4.wav",
					},
				}
		)
        CreateShop(gg_unit_opeo_0031, "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
				{
					open = {
						"Units\\Orc\\Peon\\PeonPissed1.wav",
						"Units\\Orc\\Peon\\PeonWhat1.wav",
						"Units\\Orc\\Peon\\PeonWhat2.wav",
						"Units\\Orc\\Peon\\PeonWhat3.wav",
						"Units\\Orc\\Peon\\PeonYesAttack1.wav",
					},
					close = {
						"Units\\Orc\\Peon\\PeonPissed2.wav",
						"Units\\Orc\\Peon\\PeonPissed4.wav",
						"Units\\Orc\\Peon\\PeonYesAttack1.wav",
						"Units\\Orc\\Peon\\PeonYes3.wav",
					},
				}
		)
		CreateShop(gg_unit_n001_0055, "ReplaceableTextures\\CommandButtons\\BTNVillagerWoman.blp",
				{
					open = {
						"Units\\Human\\Sorceress\\SorceressWhat1.wav",
						"Units\\Human\\Sorceress\\SorceressWhat2.wav",
						"Units\\Human\\Sorceress\\SorceressWhat3.wav",
						"Units\\Human\\Sorceress\\SorceressWhat1.wav",
						"Units\\Human\\Sorceress\\SorceressWhat1.wav",
					},
					close = {
						"Units\\Human\\Sorceress\\SorceressYes1.wav",
						"Units\\Human\\Sorceress\\SorceressYes3.wav",
						"Units\\Human\\Sorceress\\SorceressWhat5.wav",
					},
				}
		)


		local my_item = CreateCustomItem("I006",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 32, true)


		my_item = CreateCustomItem("I003",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)
		my_item = nil

		CreateBlacksmith(gg_unit_n013_0011, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")

		CreateHeroSelections()

		--CreatePlayerUI(1)
		--PostInitTestUI()

		--PushUnit(gg_unit_HBRB_0005, 270., 400., 1.25)
		--MakeUnitJump(gg_unit_HBRB_0005, 0., GetUnitX(gg_unit_HBRB_0005) + 500., GetUnitY(gg_unit_HBRB_0005), 500., 0.6)
		--EnablePreSelect(false, false)
		EnableDragSelect(false, false)
		SetCameraBoundsToRect(gg_rct_super_starting_location)
		ClearMapMusic()
		StopMusic(false)
		PlayMusic("Sound\\Music\\mp3Music\\Comradeship.mp3")


		TimerStart(CreateTimer(), 5., false, function()
			WavesInit()
			AddWaveTimer(325.)
			--TODO introduction
			--TransmissionFromUnitWithNameBJ(force, gg_unit_h000_0054, GetUnitName(capt), nil, "", 1, 10., false)
		end)

		RegisterTestCommand("buff", function()
			if GetUnitAbilityLevel(PlayerHero[1], FourCC("A01P")) == 0 then
				ApplyBuff(PlayerHero[1], PlayerHero[1], "A01P", 1)
			else
				SetBuffLevel(PlayerHero[1], "A01P", GetBuffLevel(PlayerHero[1], "A01P") + 1)
			end
			print(GetBuffLevel(PlayerHero[1], "A01P"))
        end)

		RegisterTestCommand("st", function()
			SafePauseUnit(PlayerHero[1], true)
		end)

		RegisterTestCommand("ste", function()
			SafePauseUnit(PlayerHero[1], false)
		end)

		local trg = CreateTrigger()
		TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_LEAVE)
		TriggerRegisterPlayerEvent(trg, Player(1), EVENT_PLAYER_LEAVE)
		TriggerRegisterPlayerEvent(trg, Player(2), EVENT_PLAYER_LEAVE)
		TriggerRegisterPlayerEvent(trg, Player(3), EVENT_PLAYER_LEAVE)
		TriggerRegisterPlayerEvent(trg, Player(4), EVENT_PLAYER_LEAVE)
		TriggerAddAction(trg, function()
			ActivePlayers = ActivePlayers - 1
		end)

		DoNotSaveReplay()
		AirPathingUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("hgry"), 0.,0., 0.)
		ShowUnit(AirPathingUnit, false)
	end

end