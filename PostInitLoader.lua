do

	local InitGlobalsOrigin = InitGlobals

	function InitGlobals()
		InitGlobalsOrigin()


		EnableDragSelect(false, false)
		BlzEnableSelections(false, true)
		EnablePreSelect(true, false)
		SetCameraBoundsToRect(gg_rct_super_starting_location)

		ClearMapMusic()
		StopMusic(false)
		PlayMusic("Sound\\Music\\mp3Music\\Comradeship.mp3")
		SetGameSpeed(MAP_SPEED_FASTEST)
		SetMapFlag(MAP_LOCK_SPEED, true)


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
					InitAltars, InitQuestMaster, InitQuestUtils, InitFileData
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

						CreateShop(gg_unit_n020_0075, "ReplaceableTextures\\CommandButtons\\BTNSorceress.blp",
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
						BlzSetUnitName(gg_unit_n001_0055, LOCALE_LIST[my_locale].HEALER_NAME)

						my_item = CreateCustomItem("I003",  0.,0.)
						SetItemCharges(my_item, 20)
						AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)
						my_item = nil

						BlzSetUnitName(gg_unit_n000_0056, LOCALE_LIST[my_locale].VENDOR_BILL_NAME)
						BlzSetUnitName(gg_unit_opeo_0031, LOCALE_LIST[my_locale].SMORC_NAME)
						BlzSetUnitName(gg_unit_n01W_0111, LOCALE_LIST[my_locale].SCAVENGER_NAME)
						BlzSetUnitName(gg_unit_n013_0011, LOCALE_LIST[my_locale].BLACKSMITH_NAME)
						BlzSetUnitName(gg_unit_n01V_0110, LOCALE_LIST[my_locale].LIBRARIAN_NAME)
						BlzSetUnitName(gg_unit_n020_0075, LOCALE_LIST[my_locale].LYNN_NAME)


						CreateLibrarian(gg_unit_n01V_0110, "ReplaceableTextures\\CommandButtons\\BTNNightElfRunner.blp")
						CreateBlacksmith(gg_unit_n013_0011, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")

						--print("librarian")
						CreateHeroSelections()
						CreatePlayerUI()

						local timer = CreateTimer()
						TimerStart(timer, 5., false, function()
							WavesInit()
							AddWaveTimer(325.)
							NewQuest("Credits", "Thanks for the resources and help.", "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp", false, true, "cred")
							AddQuestItem("cred",  "cred1",  "Hive:|nGeneral Frank, Mythic, Veronnis, JetFangInferno, Daelin, PeeKay(Novart), stonneash, PrinceYaser,",  false)
							AddQuestItem("cred",  "cred2",  "The Panda, Tasyen, Spellbound, Crazy Russian, Judash137, Kenathorn, stan0033, morbent, Solu9, L_Lawliet",  false)
							AddQuestItem("cred",  "cred3",  "Infrisios, Manoo, Daenar7, -Berz-, graystuff111, Akolyt0r, Hellx-Magnus, ElfWarfare, Pyramidhe@d, San",  false)
							AddQuestItem("cred",  "cred4",  "The_Spellweaver, CloudWolf, GooS, zbc, The_Silent, JollyD, Big Dub, AL0NE, ~Nightmare, Darkfang, RodOfNOD", false)
							AddQuestItem("cred",  "cred5",  "Tarrasque, dab, Pyritie, Em!, Mr.Goblin, Avatars Lord, Shardeth, dickxunder, Amigurumi, Mc !, HerrDave", false)
							AddQuestItem("cred",  "cred6",  "XGM:|nBergiBear, NazarPunk, MF, Empyreal, Beyhut, Prometheus, PrincePhoenix",  false)
							DelayAction(145., function() EnableQuest1NPC() end)
							DelayAction(225., function() EnableMainQuest1() end )
						end)
					end

				end)


				local occ_rects = { gg_rct_occlusion_rect_1, gg_rct_occlusion_rect_2, gg_rct_occlusion_rect_3, gg_rct_occlusion_rect_4, gg_rct_occlusion_rect_5, gg_rct_occlusion_rect_6, gg_rct_occlusion_rect_7, gg_rct_occlusion_rect_8, gg_rct_occlusion_rect_9, gg_rct_occlusion_rect_10,}
				local occ_region = CreateRegion()

				for i = 1, #occ_rects do
					RegionAddRect(occ_region, occ_rects[i])
				end


				local occlusion_enter_trigger = CreateTrigger()
				TriggerRegisterEnterRegion(occlusion_enter_trigger, occ_region, nil)
				TriggerAddAction(occlusion_enter_trigger, function()
					if IsAHero(GetTriggerUnit()) then
						ShowDestructable(gg_dest_B000_2762, false)
						ShowDestructable(gg_dest_B000_2763, false)
						ShowDestructable(gg_dest_B000_2764, false)
					end
				end)

				local occlusion_leave_trigger = CreateTrigger()
				TriggerRegisterLeaveRegion(occlusion_leave_trigger, occ_region, nil)
				TriggerAddAction(occlusion_leave_trigger, function()
					local occ_state = false

						for i = 1, 6 do
							if PlayerHero[i] and IsUnitInRegion(occ_region, PlayerHero[i]) then
								occ_state = true
							end
						end

						if not occ_state then
							ShowDestructable(gg_dest_B000_2762, true)
							ShowDestructable(gg_dest_B000_2763, true)
							ShowDestructable(gg_dest_B000_2764, true)
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