do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()

		InitLocaleLibrary()
		InitParameters()
		DefineSkillsData()
		MouseTrackingInit()
		print("skills done")
		DefineEffectsData()
		print("effects done")
		DefineItemGeneratorTemplates()
		print("item generator done")
		InitSetBonusTemplates()
        DefineItemsData()
		print("items done")
		DefineBuffsData()
		print("buffs done")
		DefineMissilesData()
		print("missiles done")
        MainEngineInit()
		print("main done")
		BasicFramesInit()
		print("basic frames done")
        EnumItemsOnInit()
		UnitDataInit()
		print("unit data done")
		InitGUIManager()
		print("skill panel done")
        InitWeather(bj_mapInitialPlayableArea)
		print("weather done")
		InitMonsterData()
		print("monsters done")
		DropListInit()
		ShakerInit()
		InitVillageData()
		InitPlayerCamera()
		InitializeSkillEngine()
		StartSMorcWandering()
		InitAltars()
		InitQuestsData()

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

		BlzSetUnitName(gg_unit_n000_0056, LOCALE_LIST[my_locale].VENDOR_BILL_NAME)
		BlzSetUnitName(gg_unit_opeo_0031, LOCALE_LIST[my_locale].SMORC_NAME)

		local my_item = CreateCustomItem("I006",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 32, true)
		BlzSetUnitName(gg_unit_n001_0055, LOCALE_LIST[my_locale].HEALER_NAME)

		my_item = CreateCustomItem("I003",  0.,0.)
		SetItemCharges(my_item, 20)
		AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)
		my_item = nil


		CreateBlacksmith(gg_unit_n013_0011, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")
		BlzSetUnitName(gg_unit_n013_0011, LOCALE_LIST[my_locale].BLACKSMITH_NAME)

		CreateLibrarian(gg_unit_n01V_0110, "ReplaceableTextures\\CommandButtons\\BTNNightElfRunner.blp")
		BlzSetUnitName(gg_unit_n01V_0110, LOCALE_LIST[my_locale].LIBRARIAN_NAME)

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
			NewQuest("Credits", "Thanks for the resources and help.", "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp", false, true, "cred")
			AddQuestItem("cred",  "cred1",  "Hive:|nGeneral Frank, Mythic, Veronnis, JetFangInferno, Daelin, PeeKay(Novart), stonneash, PrinceYaser,",  false)
			AddQuestItem("cred",  "cred2",  "The Panda, Tasyen, Spellbound, Crazy Russian, Judash137, Kenathorn, stan0033, morbent, Solu9,",  false)
			AddQuestItem("cred",  "cred3",  "The_Spellweaver, CloudWolf, GooS, zbc, The_Silent", false)
			AddQuestItem("cred",  "cred4",  "XGM:|nBergiBear, NazarPunk, MF, Empyreal, Beyhut",  false)
			DelayAction(145., function() EnableQuest1NPC() end)
			DelayAction(225., function() EnableMainQuest1() end )
		end)


		RegisterTestCommand("qe1m", function()
			EnableMainQuest1()
		end)

		RegisterTestCommand("qe2m", function()
			EnableMainQuest2()
		end)



		RegisterTestCommand("fr", function()
			--local frame = BlzCreateSimpleFrame("InfoPanelTitleTextTemplate", GAME_UI, 0)
			local frame = BlzCreateFrame("DemoBoxTooltip", GAME_UI, 0, 0)
			local text = BlzGetFrameByName("DemoBoxTooltipTitle", 0)

			BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, GAME_UI, FRAMEPOINT_CENTER, 0., 0.)
			BlzFrameSetScale(frame, 1.)
			BlzFrameSetSize(frame, 0.3, 0.2)
			BlzFrameSetText(text, "shpaovapa")
			BlzFrameSetVisible(frame, true)
			print("aa " .. BlzFrameGetName(frame))
			print("done " .. BlzFrameGetText(text))

		end)


		RegisterTestCommand("stress", function()
			AddLoopingSoundOnUnit({"Sounds\\Spell\\whirlwind_1.wav", "Sounds\\Spell\\whirlwind_2.wav", "Sounds\\Spell\\whirlwind_3.wav", "Sounds\\Spell\\whirlwind_4.wav"}, PlayerHero[1], 200, 200, -0.15, 110, 1700.)
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
		GroundPathingItem = CreateItem(FourCC("rde2"), 0.,0.)
		SetItemVisible(GroundPathingItem, false)
	end

end