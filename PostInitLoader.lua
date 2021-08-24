do

	local InitGlobalsOrigin = InitGlobals

	function InitGlobals()
		InitGlobalsOrigin()


		EnableDragSelect(false, false)
		BlzEnableSelections(false, true)
		--EnablePreSelect(true, false)
		SetCameraBoundsToRect(gg_rct_super_starting_location)
		ClearMapMusic()
		StopMusic(false)
		PlayMusic("Sound\\Music\\mp3Music\\Comradeship.mp3")


		--print("Initialization.... Wait for it.")
		local countdown = 5
		print("Init begins in ".. countdown)
		local timer = CreateTimer()
		TimerStart(timer, 1., true, function()
			countdown = countdown - 1
			print("Init begins in ".. countdown)
			if countdown == 0 then
				--DestroyTimer(GetExpiredTimer())
				local func_id = 0
				local init_que = {
					UtilsInit, InitLocaleLibrary, HitnumbersInit, InitParameters, DefineSkillsData, MouseTrackingInit, DefineEffectsData, InitSetBonusTemplates, DefineItemsData, DefineItemGeneratorTemplates, DefineBuffsData, DefineMissilesData,
					MainEngineInit, InitMovementEngine, BasicFramesInit, EnumItemsOnInit, UnitDataInit, InitGUIManager, InitMonsterData, DropListInit, ShakerInit, InitVillageData, InitPlayerCamera, InitializeSkillEngine, StartSMorcWandering,
					InitAltars, InitQuestMaster, InitQuestsData
				}

				TimerStart(GetExpiredTimer(), 0.1, true, function()
					func_id = func_id + 1

					if init_que[func_id] then
						init_que[func_id]()
						print("Loading data "..func_id.." / " .. #init_que)
					else
						DestroyTimer(GetExpiredTimer())
						InitWeather(bj_mapInitialPlayableArea)
						print("Done")

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
						--print("shop 1")
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
						--print("shop 2")
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
						--print("shop 3")
						CreateShop(gg_unit_n01W_0111, "ReplaceableTextures\\CommandButtons\\BTNAcolyte.blp",
								{
									open = {
										"Units\\Undead\\Acolyte\\AcolyteReady1.wav",
										"Units\\Undead\\Acolyte\\AcolyteWhat5.wav",
										"Units\\Undead\\Acolyte\\AcolyteYes4.wav",
									},
									close = {
										"Units\\Undead\\Acolyte\\AcolyteYes1.wav",
										"Units\\Undead\\Acolyte\\AcolyteYesAttack2.wav",
										"Units\\Undead\\Acolyte\\AcolytePissed1.wav",
									},
								}
						)

						--print("items")
						local my_item = CreateCustomItem("I006",  0.,0.)
						SetItemCharges(my_item, 20)
						AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 32, true)
						BlzSetUnitName(gg_unit_n001_0055, LOCALE_LIST[my_locale].HEALER_NAME)

						my_item = CreateCustomItem("I003",  0.,0.)
						SetItemCharges(my_item, 20)
						AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)
						my_item = nil
						--print("items end")

						--print("blacksmith")

						--print("names")
						BlzSetUnitName(gg_unit_n000_0056, LOCALE_LIST[my_locale].VENDOR_BILL_NAME)
						BlzSetUnitName(gg_unit_opeo_0031, LOCALE_LIST[my_locale].SMORC_NAME)
						BlzSetUnitName(gg_unit_n01W_0111, LOCALE_LIST[my_locale].SCAVENGER_NAME)
						BlzSetUnitName(gg_unit_n013_0011, LOCALE_LIST[my_locale].BLACKSMITH_NAME)
						BlzSetUnitName(gg_unit_n01V_0110, LOCALE_LIST[my_locale].LIBRARIAN_NAME)


						CreateLibrarian(gg_unit_n01V_0110, "ReplaceableTextures\\CommandButtons\\BTNNightElfRunner.blp")
						CreateBlacksmith(gg_unit_n013_0011, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")


						--print("librarian")
						CreateHeroSelections()
						--print("selections")
						--CreatePlayerUI(1)
						--PostInitTestUI()

						--PushUnit(gg_unit_HBRB_0005, 270., 400., 1.25)
						--MakeUnitJump(gg_unit_HBRB_0005, 0., GetUnitX(gg_unit_HBRB_0005) + 500., GetUnitY(gg_unit_HBRB_0005), 500., 0.6)
						--EnablePreSelect(false, false)
						local timer = CreateTimer()
						TimerStart(timer, 5., false, function()
							WavesInit()
							--AddWaveTimer(20.)
							AddWaveTimer(325.)
							NewQuest("Credits", "Thanks for the resources and help.", "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp", false, true, "cred")
							AddQuestItem("cred",  "cred1",  "Hive:|nGeneral Frank, Mythic, Veronnis, JetFangInferno, Daelin, PeeKay(Novart), stonneash, PrinceYaser,",  false)
							AddQuestItem("cred",  "cred2",  "The Panda, Tasyen, Spellbound, Crazy Russian, Judash137, Kenathorn, stan0033, morbent, Solu9,",  false)
							AddQuestItem("cred",  "cred3",  "The_Spellweaver, CloudWolf, GooS, zbc, The_Silent", false)
							AddQuestItem("cred",  "cred4",  "XGM:|nBergiBear, NazarPunk, MF, Empyreal, Beyhut",  false)
							DelayAction(145., function() EnableQuest1NPC() end)
							DelayAction(225., function() EnableMainQuest1() end )
						end)
					end

				end)


				RegisterTestCommand("qe1m", function()
					EnableMainQuest1()
				end)

				RegisterTestCommand("qe2m", function()
					EnableMainQuest2()
				end)


				local trg = CreateTrigger()
				TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(1), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(2), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(3), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(4), EVENT_PLAYER_LEAVE)
				TriggerAddAction(trg, function()
					ActivePlayers = ActivePlayers - 1
					PlayerLeft(GetPlayerId(GetTriggerPlayer()) + 1)
				end)

				--DoNotSaveReplay()
				AirPathingUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("hgry"), 0.,0., 0.)
				ShowUnit(AirPathingUnit, false)
				GroundPathingItem = CreateItem(FourCC("rde2"), 0.,0.)
				SetItemVisible(GroundPathingItem, false)
			end
		end)

	end


end