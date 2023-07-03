do

	local InitGlobalsOrigin = InitGlobals



	function CreateShops()

			CreateShop(gg_unit_n000_0056, LOCALE_LIST[my_locale].VENDOR_BILL_NAME, "ReplaceableTextures\\CommandButtons\\BTNVillagerMan1.blp",
					{
						open = { "Units\\Human\\Peasant\\PeasantWhat2.wav", "Units\\Human\\Peasant\\PeasantWhat4.wav", },
						close = { "Units\\Human\\Peasant\\PeasantYesAttack1.wav", "Units\\Human\\Peasant\\PeasantPissed4.wav", },
					}
			)

			CreateShop(gg_unit_opeo_0031, LOCALE_LIST[my_locale].SMORC_NAME, "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
					{
						open = { "Units\\Orc\\Peon\\PeonPissed1.wav", "Units\\Orc\\Peon\\PeonWhat1.wav", "Units\\Orc\\Peon\\PeonWhat2.wav", "Units\\Orc\\Peon\\PeonWhat3.wav", "Units\\Orc\\Peon\\PeonYesAttack1.wav", },
						close = { "Units\\Orc\\Peon\\PeonPissed2.wav", "Units\\Orc\\Peon\\PeonPissed4.wav", "Units\\Orc\\Peon\\PeonYesAttack1.wav", "Units\\Orc\\Peon\\PeonYes3.wav", },
					}
			)

			CreateShop(gg_unit_n001_0055, LOCALE_LIST[my_locale].HEALER_NAME, "ReplaceableTextures\\CommandButtons\\BTNVillagerWoman.blp",
					{
						open = { "Units\\Human\\Sorceress\\SorceressWhat1.wav", "Units\\Human\\Sorceress\\SorceressWhat2.wav", "Units\\Human\\Sorceress\\SorceressWhat3.wav", "Units\\Human\\Sorceress\\SorceressWhat1.wav", "Units\\Human\\Sorceress\\SorceressWhat1.wav", },
						close = { "Units\\Human\\Sorceress\\SorceressYes1.wav", "Units\\Human\\Sorceress\\SorceressYes3.wav", "Units\\Human\\Sorceress\\SorceressWhat5.wav", },
					}
			)

			CreateShop(gg_unit_n01W_0111, LOCALE_LIST[my_locale].SCAVENGER_NAME, "ReplaceableTextures\\CommandButtons\\BTNAcolyte.blp",
					{
						open = { "Units\\Undead\\Acolyte\\AcolyteReady1.wav", "Units\\Undead\\Acolyte\\AcolyteWhat5.wav", "Units\\Undead\\Acolyte\\AcolyteYes4.wav", },
						close = { "Units\\Undead\\Acolyte\\AcolyteYes1.wav", "Units\\Undead\\Acolyte\\AcolyteYesAttack2.wav", "Units\\Undead\\Acolyte\\AcolytePissed1.wav", },
					}
			)
			InitWanderingTraderNPC()

			CreateShop(gg_unit_n020_0075, LOCALE_LIST[my_locale].LYNN_NAME, "ReplaceableTextures\\CommandButtons\\BTNSorceress.blp",
					{
						open = { "Units\\Human\\Sorceress\\SorceressWhat1.wav", "Units\\Human\\Sorceress\\SorceressWhat2.wav", "Units\\Human\\Sorceress\\SorceressWhat3.wav", "Units\\Human\\Sorceress\\SorceressWhat1.wav", "Units\\Human\\Sorceress\\SorceressWhat1.wav", },
						close = { "Units\\Human\\Sorceress\\SorceressYes1.wav", "Units\\Human\\Sorceress\\SorceressYes3.wav", "Units\\Human\\Sorceress\\SorceressWhat5.wav", },
					}
			)

			local my_item = CreateCustomItem("I006",  0.,0.)
			SetItemCharges(my_item, 20)
			AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 32, true)

			my_item = CreateCustomItem("I003",  0.,0.)
			SetItemCharges(my_item, 20)
			AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 31, true)

			my_item = CreateCustomItem(ITEM_FOOD,  0.,0.)
			SetItemCharges(my_item, 20)
			AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 29, true)

			my_item = CreateCustomItem(ITEM_DRINKS,  0.,0.)
			SetItemCharges(my_item, 20)
			AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 30, true)
			my_item = nil

	end


	function InitGlobals()
		InitGlobalsOrigin()

		GetUnitX = GetUnitRealX
        GetUnitY = GetUnitRealY

		EnableDragSelect(false, false)
		BlzEnableSelections(false, true)
		EnablePreSelect(true, false)
		SetCameraBoundsToRect(gg_rct_super_starting_location)

		SetTexture(gg_unit_HSRC_0043, TEXTURE_ID_EMPTY)
		SetTexture(gg_unit_HNCR_0019, TEXTURE_ID_EMPTY)
		SetTexture(gg_unit_HBRB_0041, TEXTURE_ID_EMPTY)

		ClearMapMusic()
		StopMusic(false)
		PlayMusic("Sound\\Music\\mp3Music\\Comradeship.mp3")
		SetGameSpeed(MAP_SPEED_FASTEST)
		SetMapFlag(MAP_LOCK_SPEED, true)
		EnableOcclusion(true)

		MONSTER_PLAYER = Player(10)
        SECOND_MONSTER_PLAYER = Player(11)
		ScaleMonstersGroup = CreateGroup()

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
					InitAltars, InitQuestMaster, InitQuestUtils, InitNPCs, InitFileData
				}

				TimerStart(GetExpiredTimer(), 0.05, true, function()
					func_id = func_id + 1

					if init_que[func_id] then
						init_que[func_id]()
						print("Loading data " .. func_id.." / " .. #init_que)
					else
						DestroyTimer(GetExpiredTimer())
						InitWeather(bj_mapInitialPlayableArea)
						InitUnitsDataOnMap()
						print("Done")

						CreateShops()

						BlzSetUnitName(gg_unit_n013_0011, LOCALE_LIST[my_locale].BLACKSMITH_NAME)
						BlzSetUnitName(gg_unit_n01V_0110, LOCALE_LIST[my_locale].LIBRARIAN_NAME)

						CreateLibrarian(gg_unit_n01V_0110, "ReplaceableTextures\\CommandButtons\\BTNNightElfRunner.blp")
						CreateBlacksmith(gg_unit_n013_0011, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")

						AddInteractiveOption(gg_unit_n000_0056, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "bill_intro_conv", feedback = function(clicked, clicking, player) PlayConversation("bill_intro", gg_unit_n000_0056, player) end }, 1)
						AddInteractiveOption(gg_unit_n001_0055, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "dalia_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("dalia_intro", gg_unit_n001_0055, player) end }, 1)
						AddInteractiveOption(gg_unit_n013_0011, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "blacksmith_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("blacksmith_intro", gg_unit_n013_0011, player) end }, 1)
						AddInteractiveOption(gg_unit_n01V_0110, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "librarian_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("librarian_intro", gg_unit_n01V_0110, player) end }, 1)
						AddInteractiveOption(gg_unit_opeo_0031, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "smorc_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("smorc_intro", gg_unit_opeo_0031, player) end }, 1)
						AddInteractiveOption(gg_unit_n020_0075, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "lynn_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("lynn_intro", gg_unit_n020_0075, player) end }, 1)
						AddInteractiveOption(gg_unit_n01W_0111, { name = LOCALE_LIST[my_locale].INT_OPTION_TALK, id = "wandering_intro_conv",feedback = function(clicked, clicking, player) PlayConversation("wandering_intro", gg_unit_n01W_0111, player) end }, 1)

						--print("librarian")
						CreateHeroSelections()
						CreatePlayerUI()
						LoadPlayerProgression()

						PickUpItemReaction("I02U", function()
							local picker = GetTriggerUnit()

								for i = 1, 6 do
									if PlayerHero[i] and IsUnitInRange(picker, PlayerHero[i], 500.) then
										ApplyEffect(PlayerHero[i], PlayerHero[i], 0.,0., "effect_heal_rune", 1)
									end
								end

						end)

						PickUpItemReaction("I02V", function()
							local picker = GetTriggerUnit()

								for i = 1, 6 do
									if PlayerHero[i] and IsUnitInRange(picker, PlayerHero[i], 500.) then
										ApplyEffect(PlayerHero[i], PlayerHero[i], 0.,0., "effect_resource_rune", 1)
									end
								end

						end)


						local timer = CreateTimer()
						TimerStart(timer, 5., false, function()
							WavesInit()
							AddWaveTimer(340.)
							NewQuest("Credits", "Thanks for the resources and help.", "ReplaceableTextures\\WorldEditUI\\Editor-MultipleUnits.blp", false, true, "cred")
							AddQuestItem("cred",  "cred1",  "Hive:|nGeneral Frank, Mythic, Veronnis, JetFangInferno, Daelin, PeeKay(Novart), stonneash, PrinceYaser,",  false)
							AddQuestItem("cred",  "cred2",  "The Panda, Tasyen, Spellbound, Crazy Russian, Judash137, Kenathorn, stan0033, morbent, Solu9, L_Lawliet",  false)
							AddQuestItem("cred",  "cred3",  "Infrisios, Manoo, Daenar7, -Berz-, graystuff111, Akolyt0r, Hellx-Magnus, ElfWarfare, Pyramidhe@d, San",  false)
							AddQuestItem("cred",  "cred4",  "The_Spellweaver, CloudWolf, GooS, zbc, The_Silent, JollyD, Big Dub, AL0NE, ~Nightmare, Darkfang, RodOfNOD", false)
							AddQuestItem("cred",  "cred5",  "Tarrasque, dab, Pyritie, Em!, Mr.Goblin, Avatars Lord, Shardeth, dickxunder, Amigurumi, Mc !, HerrDave, TriggerHappy", false)
							AddQuestItem("cred",  "cred6",  "XGM:|nBergiBear, NazarPunk, MF, Empyreal, Beyhut, Prometheus, PrincePhoenix, RoyMustang, NightSiren",  false)
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

				local trg = CreateTrigger()
				TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(1), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(2), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(3), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(4), EVENT_PLAYER_LEAVE)
				TriggerRegisterPlayerEvent(trg, Player(5), EVENT_PLAYER_LEAVE)
				TriggerAddAction(trg, function()
					ActivePlayers = ActivePlayers - 1
					PlayerLeft(GetPlayerId(GetTriggerPlayer()) + 1)
				end)

				DoNotSaveReplay()
				AirPathingUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("hgry"), 0.,0., 0.)
				ShowUnit(AirPathingUnit, false)
				GroundPathingItem = CreateItem(FourCC("rde2"), 0.,0.)
				SetItemVisible(GroundPathingItem, false)
			end
		end)

	end


end