---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 02.06.2021 0:41
---
do

    local player_maps


    function CompleteQuartermeisterScoutQuest(player)
        DropItemFromInventory(player, player_maps[player], true)
        RemoveCustomItem(player_maps[player])
        GiveGoldForPlayer(250, player)
        GiveExpForPlayer(500, player)
        TaskCompletedMessage("quest_anar_scout", player)
    end


    function QuartermeisterScoutQuest_IsDone(player)

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_1") == JOURNAL_OBJECTIVE_STATE_DONE
                and GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_2") == JOURNAL_OBJECTIVE_STATE_DONE
                and GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_3") == JOURNAL_OBJECTIVE_STATE_DONE
                and GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_4") == JOURNAL_OBJECTIVE_STATE_DONE
                and GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_5") == JOURNAL_OBJECTIVE_STATE_DONE
        then
            UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_scoutquest_done", player)
            AddJournalEntryText(player, "quest_anar_scout", GetLocalString("Теперь необходимо вернуться к Анару.", "Now I need to get back to Anar."), false)
            local unit_data = GetUnitData(gg_unit_n029_0022)
            if GetLocalPlayer() == Player(player - 1) then BlzPlaySpecialEffect(unit_data.questmarker_done, ANIM_TYPE_STAND) end
        end

    end


    function QuartermeisterScoutQuest_MapActivated(player)

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_1") ~= JOURNAL_OBJECTIVE_STATE_DONE then
            if GetLocalPlayer() == Player(player-1) then
                PingMinimap(GetRectCenterX(gg_rct_scout_region_1), GetRectCenterY(gg_rct_scout_region_1), 3.)
            end
        end

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_2") ~= JOURNAL_OBJECTIVE_STATE_DONE then
            if GetLocalPlayer() == Player(player-1) then
                PingMinimap(GetRectCenterX(gg_rct_scout_region_2), GetRectCenterY(gg_rct_scout_region_2), 3.)
            end
        end

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_3") ~= JOURNAL_OBJECTIVE_STATE_DONE then
            if GetLocalPlayer() == Player(player-1) then
                PingMinimap(GetRectCenterX(gg_rct_scout_region_3), GetRectCenterY(gg_rct_scout_region_3), 3.)
            end
        end

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_4") ~= JOURNAL_OBJECTIVE_STATE_DONE then
            if GetLocalPlayer() == Player(player-1) then
                PingMinimap(GetRectCenterX(gg_rct_scout_region_4), GetRectCenterY(gg_rct_scout_region_4), 3.)
            end
        end

        if GetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_5") ~= JOURNAL_OBJECTIVE_STATE_DONE then
            if GetLocalPlayer() == Player(player-1) then
                PingMinimap(GetRectCenterX(gg_rct_scout_region_5), GetRectCenterY(gg_rct_scout_region_5), 3.)
            end
        end

    end


    function EnableQuartermeisterScoutQuest(player)

        if not player_maps then
            player_maps = {}
        end

        AddJournalEntry(player, "quest_anar_scout", "ReplaceableTextures\\CommandButtons\\BTNSpy.blp", GetLocalString("Поручение разведки", "Scouting Task"), 75, true)

        AddJournalEntryObjective(player, "quest_anar_scout", "scout_target_1", GetLocalString("Восточная точка разведана", "East point scouted"))
        AddQuestAreaForPlayer(player, MARK_TYPE_QUESTION, MARK_COMMON, 1., 300., GetRectCenterX(gg_rct_scout_region_1), GetRectCenterY(gg_rct_scout_region_1), function()
            SetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_1", JOURNAL_OBJECTIVE_STATE_DONE, true)
            QuartermeisterScoutQuest_IsDone(player)
        end)

        AddJournalEntryObjective(player, "quest_anar_scout", "scout_target_2", GetLocalString("Северовосточная точка разведана", "North-East point scouted"))
        AddQuestAreaForPlayer(player, MARK_TYPE_QUESTION, MARK_COMMON, 1., 300., GetRectCenterX(gg_rct_scout_region_2), GetRectCenterY(gg_rct_scout_region_2), function()
            SetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_2", JOURNAL_OBJECTIVE_STATE_DONE, true)
            QuartermeisterScoutQuest_IsDone(player)
        end)

        AddJournalEntryObjective(player, "quest_anar_scout", "scout_target_3", GetLocalString("Северная точка разведана", "North point scouted"))
        AddQuestAreaForPlayer(player, MARK_TYPE_QUESTION, MARK_COMMON, 1., 300., GetRectCenterX(gg_rct_scout_region_3), GetRectCenterY(gg_rct_scout_region_3), function()
            SetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_3", JOURNAL_OBJECTIVE_STATE_DONE, true)
            QuartermeisterScoutQuest_IsDone(player)
        end)

        AddJournalEntryObjective(player, "quest_anar_scout", "scout_target_4", GetLocalString("Ближняя южная точка разведана", "Close South point scouted"))
        AddQuestAreaForPlayer(player, MARK_TYPE_QUESTION, MARK_COMMON, 1., 300., GetRectCenterX(gg_rct_scout_region_4), GetRectCenterY(gg_rct_scout_region_4), function()
            SetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_4", JOURNAL_OBJECTIVE_STATE_DONE, true)
            QuartermeisterScoutQuest_IsDone(player)
        end)

        AddJournalEntryObjective(player, "quest_anar_scout", "scout_target_5", GetLocalString("Дальняя южная точка разведана", "Far South point scouted"))
        AddQuestAreaForPlayer(player, MARK_TYPE_QUESTION, MARK_COMMON, 1., 300., GetRectCenterX(gg_rct_scout_region_5), GetRectCenterY(gg_rct_scout_region_5), function()
            SetJournalEntryObjectiveState(player, "quest_anar_scout", "scout_target_5", JOURNAL_OBJECTIVE_STATE_DONE, true)
            QuartermeisterScoutQuest_IsDone(player)
        end)


        AddJournalEntryText(player, "quest_anar_scout", GetConversationText("quartermaster_scoutquest_conv", gg_unit_n029_0022, player))

        local item = CreateCustomItem("I02M", 0.,0., false, player-1)
        player_maps[player] = item
        DelayAction(0., function()
            if not AddToInventory(player, item) then
                SetItemPosition(item, GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
            end
        end)
    end


    --==============================================================================================--
    --==============================================================================================--
    --==============================================================================================--



    function EnableQuest1NPC()
        local npc = CreateNPC("n016", gg_rct_npc_1, 240., LOCALE_LIST[my_locale].AIZEK_NAME)
        local effect = AddQuestMark(npc, MARK_TYPE_EXCLAMATION, MARK_COMMON)


            AddInteractiveOption(npc, { name = GetLocalString("Просьба", "Favor"), feedback = function(clicked, clicking, player)
                RemoveInteractiveOption(npc, 1)
                DestroyEffect(effect)
                NewQuest(LOCALE_LIST[my_locale].QUEST_1_TITLE, LOCALE_LIST[my_locale].QUEST_1_DESC, "ReplaceableTextures\\CommandButtons\\BTNTelescope.blp", false, true, "que1a")

                AddQuestItem("que1a",  "que1apool",  LOCALE_LIST[my_locale].QUEST_1_ITEM,  false)
                AddQuestItemPool("que1a", "que1apool", 20)

                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_1_SPEECH, 8.)
                CreateQuestItems(20, FourCC("I01M"), { gg_rct_quest_1_itemrect, gg_rct_quest_2_itemrect, gg_rct_quest_3_itemrect, gg_rct_quest_4_itemrect, gg_rct_quest_5_itemrect })



                for i = 1, 6 do
                    if PlayerHero[i] then
                        AddJournalEntry(i, "quest_1_journal", "ReplaceableTextures\\CommandButtons\\BTNTelescope.blp", LOCALE_LIST[my_locale].QUEST_1_TITLE, 50, true)
                        AddJournalEntryText(i, "quest_1_journal", GetUnitNameTextColorized(npc) .. LOCALE_LIST[my_locale].QUEST_1_SPEECH, false)
                        AddJournalEntryText(i, "quest_1_journal", LOCALE_LIST[my_locale].QUEST_1_DESC, false)
                    end
                end


                local trg = CreateTrigger()
                TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
                TriggerAddAction(trg, function()
                    if GetItemTypeId(GetManipulatedItem()) == FourCC("I01M") then
                        if SetQuestItemPool("que1a", "que1apool", 1) then
                            GiveExp(500)
                            local gold = GiveGold(200)
                            ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)
                            DestroyTrigger(trg)
                            RemoveUnit(npc)
                            DelayAction(300., function()
                                EnableQuest2()
                            end)
                        end
                    end
                end)
            end})


    end



    function EnableQuest2()
        local npc = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("n01C"), GetRectCenterX(gg_rct_npc_4), GetRectCenterY(gg_rct_npc_4), 150.)
        local effect = AddSpecialEffectTarget("Quest\\ExcMark_Gold_NonrepeatableQuest.mdx", npc, "overhead")


            BlzSetUnitName(npc, LOCALE_LIST[my_locale].TAKO_NAME)
            RegisterClickFeedbackOnNPC(npc, function()
                ClickFunctionsRemove(npc, GetTriggeringTrigger())
                DestroyEffect(effect)

                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_SPEECH_1, 8., 8.)
                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_SPEECH_2, 8., 8.)
                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_SPEECH_3, 8., 8.)

                NewQuest(LOCALE_LIST[my_locale].QUEST_2_TITLE, LOCALE_LIST[my_locale].QUEST_2_DESC, "ReplaceableTextures\\CommandButtons\\BTNMonsterLure.blp", false, true, "que2")
                AddQuestItem("que2",  "item1",  LOCALE_LIST[my_locale].QUEST_2_ITEM1,  false)
                AddQuestItemPool("que2", "item1", 40)
                AddQuestItem("que2",  "item2",  LOCALE_LIST[my_locale].QUEST_2_ITEM2,  false)

                PlayCinematicSpeechForEveryone(GetTriggerUnit(), LOCALE_LIST[my_locale].QUEST_2_RESPONCE, 6.)

                CreateQuestItems(40, FourCC("I01P"), { gg_rct_quest_rect_1, gg_rct_quest_rect_2, gg_rct_quest_rect_3, gg_rct_quest_rect_4, gg_rct_quest_rect_5, gg_rct_quest_rect_6, gg_rct_quest_rect_7, gg_rct_quest_rect_8 })

                PickUpItemReaction("I01P", function()
                    --if GetItemTypeId(GetManipulatedItem()) == FourCC("I01P") then
                        if SetQuestItemPool("que2", "item1", 1) then
                            effect = AddSpecialEffectTarget("Quest\\Completed_Quest.mdx", npc, "overhead")
                            RegisterClickFeedbackOnNPC(npc, function()
                                SetQuestItemState("que2", "item2", true)
                                ClickFunctionsRemove(npc, GetTriggeringTrigger())
                                DestroyEffect(effect)
                                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_SPEECH_DONE, 8., 8.)
                                GiveExp(250)
                                local gold = GiveGold(200)
                                ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)
                                DestroyTrigger(GetTriggeringTrigger())
                            end)
                        end
                    --end
                end)
            end)

    end



    function EnableMainQuest2()
        local npc = CreateNPC("n01F", gg_rct_npc_5, 235., LOCALE_LIST[my_locale].DON_NAME)
        local effect  = AddQuestMark(npc, MARK_TYPE_EXCLAMATION, MARK_SPECIAL)
        local npc_hunter = CreateNPC("n01D", gg_rct_npc_6, 270., LOCALE_LIST[my_locale].HUNTER_NAME)
        local hunter_effect = AddQuestMark(npc_hunter, MARK_TYPE_QUESTION, MARK_SPECIAL)
        local npc_witch = CreateNPC("n01E", gg_rct_npc_7, 270., LOCALE_LIST[my_locale].WITCH_NAME)
        local witch_effect = AddQuestMark(npc_witch, MARK_TYPE_QUESTION, MARK_SPECIAL)
        local guard = CreateUnit(MONSTER_PLAYER, FourCC("n01X"), GetRectCenterX(gg_rct_npc_8), GetRectCenterY(gg_rct_npc_8), RndAng())
        local proximity = CreateTrigger()
        local DeathTrg = CreateTrigger()


            CreateLeashForUnit(guard, 1000.)
            ShowUnit(npc_hunter, false)
            ShowUnit(npc_witch, false)
            ShowUnit(guard, false)


        local main_feedback = RegisterClickFeedbackOnNPC(npc, function()
                ClickFunctionsRemove(npc, GetTriggeringTrigger())
                DestroyEffect(effect)

                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_M_INTRO_1, 5., 5.)
                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_M_INTRO_2, 5., 5.)
                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_M_INTRO_3, 5., 5.)
                PlayCinematicSpeechForEveryone(GetTriggerUnit(), LOCALE_LIST[my_locale].QUEST_2_M_RESPONCE, 5., 5.)

                NewQuest(LOCALE_LIST[my_locale].QUEST_2_M_TITLE, LOCALE_LIST[my_locale].QUEST_2_M_DESC, "ReplaceableTextures\\CommandButtons\\BTNBearForm.blp", true, true, "q2m")
                AddQuestItem("q2m", "q2mi1", LOCALE_LIST[my_locale].QUEST_2_M_ITEM, false)
                ShowUnit(npc_hunter, true)

            end)


          local hunter_feedback = RegisterClickFeedbackOnNPC(npc_hunter, function()
              ClickFunctionsRemove(npc_hunter)

                    if IsMyQuestItemCompleted("q2m", "q2mivar6") then
                        DestroyEffect(hunter_effect)
                        ClickFunctionsRemove(npc_hunter, GetTriggeringTrigger())
                        --ClickFunctionsRemove(npc_witch, witch_feedback)
                        PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_2_M_RESPONCE_HUNTERS_2, 5., 5.)
                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_6, 7., 7.)
                        MarkQuestAsCompleted("q2m")

                        GiveExp(700)
                        local gold = GiveGold(320)
                        ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)

                        DelayAction(60., function() RemoveUnit(npc_hunter) end)
                        RemoveUnit(npc_witch)
                        RemoveUnit(npc)
                    elseif not IsMyQuestItemCompleted("q2m", "q2mi1") then
                        DestroyEffect(hunter_effect)

                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_1, 4., 4.)
                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_2, 5., 5.)
                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_3, 7., 7.)
                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_4, 8., 8.)
                        PlayCinematicSpeechForEveryone(npc_hunter, LOCALE_LIST[my_locale].QUEST_2_M_HUNTER_5, 8., 8.)
                        PlayCinematicSpeechForEveryone(GetTriggerUnit(), LOCALE_LIST[my_locale].QUEST_2_M_RESPONCE_HUNTERS, 5., 5.)

                        AddQuestItem("q2m", "q2mi2var1", LOCALE_LIST[my_locale].QUEST_2_M_ITEMVAR1, true)
                        AddQuestItem("q2m", "q2mi2var2", LOCALE_LIST[my_locale].QUEST_2_M_ITEMVAR2, true)
                        SetQuestItemState("q2m", "q2mi1", true)
                        ShowUnit(npc_witch, true)
                        ShowUnit(npc_hunter, true)
                        ShowUnit(guard, true)
                    end

            end)


        local witch_feedback = RegisterClickFeedbackOnNPC(npc_witch, function()
                 ClickFunctionsRemove(npc_witch)


                    if not IsMyQuestItemCompleted("q2m", "q2mi2var2") then
                        DestroyEffect(witch_effect)

                        PlayCinematicSpeechForEveryone(npc_witch, LOCALE_LIST[my_locale].QUEST_2_M_WITCH_1, 8., 8.)
                        PlayCinematicSpeechForEveryone(npc_witch, LOCALE_LIST[my_locale].QUEST_2_M_WITCH_2, 8., 8.)
                        PlayCinematicSpeechForEveryone(npc_witch, LOCALE_LIST[my_locale].QUEST_2_M_WITCH_3, 8., 8.)
                        PlayCinematicSpeechForEveryone(npc_witch, LOCALE_LIST[my_locale].QUEST_2_M_WITCH_4, 8., 8.)
                        PlayCinematicSpeechForEveryone(GetTriggerUnit(), LOCALE_LIST[my_locale].QUEST_2_M_RESPONCE_WITCH, 6., 6)

                        AddQuestItem("q2m", "q2mi2var3", LOCALE_LIST[my_locale].QUEST_2_M_ITEMVAR3, true)
                        AddQuestItemPool("q2m", "q2mi2var3", 15)
                        SetQuestItemState("q2m", "q2mi2var2", true)
                        CreateQuestItems(15, FourCC("I01T"), { gg_rct_quest_1_itemrect, gg_rct_quest_5_itemrect, gg_rct_quest_rect_4, gg_rct_quest_rect_5, gg_rct_quest_rect_6 }, 3)

                        PickUpItemReaction("I01T", function()
                            if SetQuestItemPool("q2m", "q2mi2var3", 1) then
                                witch_effect = AddQuestMark(npc_witch, MARK_TYPE_QUESTION, MARK_SPECIAL)
                                ClickFunctionsAdd(npc_witch)
                                DestroyTrigger(GetTriggeringTrigger())
                            end
                        end)

                    elseif IsMyQuestItemCompleted("q2m", "q2mi2var3") then
                        DestroyEffect(witch_effect)

                        ClickFunctionsRemove(npc_witch, GetTriggeringTrigger())
                        ClickFunctionsRemove(npc_hunter, hunter_feedback)
                        PlayCinematicSpeechForEveryone(npc_witch, LOCALE_LIST[my_locale].QUEST_2_M_WITCH_5, 6., 6.)

                        for i = 1, 6 do AddPointsToPlayer(i, 5) end
                        ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_POINTS_FIRST .. "5" .. LOCALE_LIST[my_locale].QUEST_REWARD_POINTS_SECOND)
                        GiveExp(700)

                        MarkQuestAsCompleted("q2m")
                        DelayAction(60., function() RemoveUnit(npc_witch) end)

                        RemoveUnit(npc_hunter)
                        RemoveUnit(npc)
                        DestroyTrigger(DeathTrg)
                        DestroyTrigger(proximity)
                        ShowUnit(guard, false)
                        KillUnit(guard)
                    end

            end)



        TriggerRegisterUnitInRange(proximity, guard, 800., nil)
        TriggerAddAction(proximity, function()
            if IsAHero(GetTriggerUnit()) then
                AddQuestItem("q2m", "q2mivar6", LOCALE_LIST[my_locale].QUEST_2_M_ITEMVAR6, true)
                SetQuestItemState("q2m", "q2mi2var1", true)
                DestroyTrigger(proximity)
            end
        end)


        TriggerRegisterUnitEvent(DeathTrg, guard, EVENT_UNIT_DEATH)
        TriggerAddAction(DeathTrg, function()
            AddQuestItem("q2m", "q2mivar5", LOCALE_LIST[my_locale].QUEST_2_M_ITEMVAR5, true)
            SetQuestItemState("q2m", "q2mivar6", true)
            hunter_effect = AddQuestMark(npc_hunter, MARK_TYPE_QUESTION, MARK_SPECIAL)
            ClickFunctionsAdd(npc_hunter)
        end)


    end


    Guinplen = 0


    function EnableMainQuest1_Guinplen_2()
        Guinplen.effect = AddSpecialEffectTarget("Objects\\RandomObject\\RandomObject", Guinplen.npc, "overhead")

            TriggerAddAction(RegisterClickFeedbackOnNPC(), function()
                ClickFunctionsRemove(Guinplen.npc, GetTriggeringTrigger())
                DestroyEffect(Guinplen.effect)
                AddQuestItem("que1m",  "que1mitemvar2end",  "Опробовать посох на Лилит",  false)
                PlayCinematicSpeechForEveryone(Guinplen.npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_GIUN_2, 8.)
            end)

    end


    function EnableMainQuest1_Guinplen_1()
        Guinplen = {
            npc = CreateNPC("n018", gg_rct_npc_3, 275., LOCALE_LIST[my_locale].GUINPLEN_NAME),
        }


        Guinplen.effect = AddSpecialEffectTarget("Quest\\Completed_Quest_Special.mdx", Guinplen.npc, "overhead")

        AddInteractiveOption(Guinplen.npc, { name = GetLocalString("Гуинплен?", "Guinplen?"), feedback = function(clicked, clicking, player)
            RemoveInteractiveOption(Guinplen.npc, 1)
            DestroyEffect(Guinplen.effect)
            PlayCinematicSpeechForEveryone(Guinplen.npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_GIUN_1, 8., 8.)
            PlayCinematicSpeechForEveryone(Guinplen.npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_GIUN_2, 9., 9.)
            PlayCinematicSpeechForEveryone(Guinplen.npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_GIUN_3, 12., 12.)
            PlayCinematicSpeechForEveryone(Guinplen.npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_GIUN_4, 7., 7.)
            AddQuestItem("que1m",  "que1mitemvar2", LOCALE_LIST[my_locale].QUEST_1_M_ITEMVAR2, true)
            SetQuestItemState("que1m", "que1mitem", true)

            local rects = { gg_rct_staff_of_hope_1, gg_rct_staff_of_hope_2, gg_rct_staff_of_hope_3, gg_rct_staff_of_hope_4 }
            local rect = rects[GetRandomInt(1, #rects)]
            Guinplen.staff = CreateItem(FourCC("I01N"), GetRandomRectX(rect), GetRandomRectY(rect))

            Guinplen.staff_trg = CreateTrigger()
            TriggerRegisterAnyUnitEventBJ(Guinplen.staff_trg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
                TriggerAddAction(Guinplen.staff_trg, function()
                    if GetItemTypeId(GetManipulatedItem()) == FourCC("I01N") then
                        SetQuestItemState("que1m", "que1mitemvar2", true)
                        AddQuestItem("que1m",  "que1mitemvar2end", LOCALE_LIST[my_locale].QUEST_1_M_ITEMVAR2END,  false)
                        PlayCinematicSpeechForEveryone(GetTriggerUnit(), LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_STAFF_FOUND, 8.)
                        Guinplen.staff = nil
                        DestroyTrigger(Guinplen.staff_trg)
                        Guinplen.staff_trg = nil
                    end
                end)

                rects = nil
        end})


    end





    function EndMainQuest1(trg1, trg2)
        MarkQuestAsCompleted("que1m")
        DestroyTrigger(trg1)
        DestroyTrigger(trg2)
        RemoveUnit(Guinplen.npc)
        if Guinplen.effect then DestroyEffect(Guinplen.effect) end
        if Guinplen.staff then RemoveItem(Guinplen.staff) end
        if Guinplen.staff_trg then DestroyTrigger(Guinplen.staff_trg) end
        Guinplen = nil

        DelayAction(670., function() EnableMainQuest2()  end)
    end



    function CreateQuestLilith()
        local lilith_proximity_trigger = CreateTrigger()
        local lilith_death_trg = CreateTrigger()
        local Lilith = CreateUnit(SECOND_MONSTER_PLAYER, FourCC("n017"), GetRectCenterX(gg_rct_quest_lilit), GetRectCenterY(gg_rct_quest_lilit), 155.)

            CreateLeashForUnit(Lilith, 1250.)

            TriggerRegisterUnitInRange(lilith_proximity_trigger, Lilith, 650., nil)
            TriggerAddAction(lilith_proximity_trigger, function()
                if IsAHero(GetTriggerUnit()) then
                    DisableTrigger(lilith_proximity_trigger)
                    SetQuestItemState("que1m", "que1mitemvar1", true)

                    if IsMyQuestItemCompleted("que1m", "que1mitemvar2") then
                        SafePauseUnit(Lilith, true)
                        UnitAddAbility(Lilith, FourCC("Avul"))
                        local starfall = AddSpecialEffect("Abilities\\Spells\\NightElf\\Starfall\\StarfallCaster.mdx", GetUnitX(Lilith), GetUnitY(Lilith))
                        DelayAction(5., function()
                            DestroyEffect(starfall)
                            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdx", GetUnitX(Lilith), GetUnitY(Lilith)))
                            DelayAction(1., function()
                                ShowUnit(Lilith, false)
                                local npc = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("n019"), GetUnitX(Lilith), GetUnitY(Lilith), 350.)
                                SetQuestItemState("que1m", "que1mitemvar2end", true)
                                MarkQuestAsCompleted("que1m")
                                PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_END_2, 8.)
                                EndMainQuest1(lilith_proximity_trigger, lilith_death_trg)
                                GiveExp(500)
                                local gold = GiveGold(250)
                                ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)

                                for i = 1, 6 do
                                    local item = CreateCustomItem(GetGeneratedItemId(CHEST_ARMOR), GetUnitX(Lilith), GetUnitY(Lilith), true, i-1)
                                    GenerateItemStats(item, Current_Wave + 5, MAGIC_ITEM)
                                end

                                KillUnit(Lilith)

                                DelayAction(5., function()
                                    VanishUnit(npc, 3., { r = 255, g = 255, b = 255 }, function()
                                        RemoveUnit(npc)
                                    end)
                                end)

                            end)
                        end)

                    else
                        AddQuestItem("que1m",  "que1mitemvar1end",  LOCALE_LIST[my_locale].QUEST_1_M_ITEMVAR1END,  false)
                    end
                end
            end)


        TriggerRegisterUnitEvent(lilith_death_trg, Lilith, EVENT_UNIT_DEATH)
        TriggerAddAction(lilith_death_trg, function()
            SetQuestItemState("que1m", "que1mitemvar1end", true)
            EndMainQuest1(lilith_proximity_trigger, lilith_death_trg)
            GiveExp(250)
            local gold = GiveGold(550)
            ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)
        end)
    end


    function EnableMainQuest1()
        local npc = CreateNPC("n01A", gg_rct_npc_2, 315., LOCALE_LIST[my_locale].STEPHAN_NAME)
        local effect = AddSpecialEffectTarget("Quest\\ExcMark_Orange_ClassQuest.mdx", npc, "overhead")


        AddInteractiveOption(npc, { name = GetLocalString("Просьба", "Favor"), feedback = function(clicked, clicking, player)
            RemoveInteractiveOption(npc, 1)
            DestroyEffect(effect)

            PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_INTRO, 12., 12.)
            PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_INTRO_2, 10., 10.)
            PlayCinematicSpeechForEveryone(npc, LOCALE_LIST[my_locale].QUEST_1_M_SPEECH_INTRO_3, 8., 8.)

            NewQuest(LOCALE_LIST[my_locale].QUEST_1_M_TITLE, LOCALE_LIST[my_locale].QUEST_1_M_DESC, "ReplaceableTextures\\CommandButtons\\BTNIceShard.blp", true, true, "que1m")
            AddQuestItem("que1m",  "que1mitem", LOCALE_LIST[my_locale].QUEST_1_M_ITEM, false)
            AddQuestItem("que1m",  "que1mitemvar1", LOCALE_LIST[my_locale].QUEST_1_M_ITEMVAR1 , false)
            EnableMainQuest1_Guinplen_1()
            CreateQuestLilith()
        end})



    end




    function InitQuestsData()


    end
    
end 