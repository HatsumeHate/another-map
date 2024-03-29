---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 02.09.2021 17:33
---
do


    local Manto


    function MantoRescueQuestEnable()
        local MantoPosition = { gg_rct_manto_1, gg_rct_manto_2, gg_rct_manto_3 }
        Manto = CreateNPC("n021", MantoPosition[GetRandomInt(1, #MantoPosition)], 270., LOCALE_LIST[my_locale].MANTO_NAME)
        local questmark = AddQuestMark(Manto, MARK_TYPE_EXCLAMATION, MARK_SPECIAL)
        local death_trigger = CreateTrigger()


            RegisterClickFeedbackOnNPC(Manto, function()
                ClickFunctionsRemove(Manto, GetTriggeringTrigger())
                DestroyEffect(questmark)

                PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_INTRO_1, 12., 12.)
                PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_INTRO_2, 12., 12.)
                PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_INTRO_3, 12., 12.)
                PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_INTRO_4, 12., 12.)

                NewQuest(LOCALE_LIST[my_locale].QUEST_3_M_TITLE, LOCALE_LIST[my_locale].QUEST_3_M_DESC, "ReplaceableTextures\\CommandButtons\\BTNSkeletonWarrior.blp", true, true, "quest_3_main")
                AddQuestItem("quest_3_main",  "quest_3_main_item_1", LOCALE_LIST[my_locale].QUEST_3_M_ITEM_1_DESC, false)
                CreateQuestItems(1, "I01Y", { gg_rct_emanator_1, gg_rct_emanator_2, gg_rct_emanator_3 })

                PickUpItemReaction("I01Y", function()
                    ClickFunctionsAdd(Manto)
                    questmark = AddQuestMark(Manto, MARK_TYPE_QUESTION, MARK_SPECIAL)

                        RegisterClickFeedbackOnNPC(Manto, function()

                            ClickFunctionsRemove(Manto)
                            DestroyEffect(questmark)
                            TriggerSleepAction(1.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_1, 8., 8.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_2, 8., 8.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_3, 8., 8.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_4, 8., 8.)
                            AddQuestItem("quest_3_main",  "quest_3_main_item_2", LOCALE_LIST[my_locale].QUEST_3_M_ITEM_2_DESC, true)
                            AddQuestItemPool("quest_3_main", "quest_3_main_item_2", 12)
                            SetQuestItemState("quest_3_main", "quest_3_main_item_1", true)
                            AddQuestItem("quest_3_main",  "quest_3_main_item_3", LOCALE_LIST[my_locale].QUEST_3_M_ITEM_3_DESC, false)
                            EnableTrigger(death_trigger)
                            DestroyTrigger(GetTriggeringTrigger())
                        end)

                end)

            end)

        TriggerRegisterPlayerEvent(death_trigger, MONSTER_PLAYER, EVENT_PLAYER_UNIT_DEATH)
        TriggerRegisterPlayerEvent(death_trigger, MONSTER_PLAYER, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddAction(death_trigger, function()
            local unit_type_id = GetUnitTypeId(GetTriggerUnit())

                if unit_type_id == FourCC("u00C") or unit_type_id == FourCC("u00K") or unit_type_id == FourCC("n006") then
                    if SetQuestItemPool("quest_3_main", "quest_3_main_item_2", 1) then
                        DisableTrigger(death_trigger)
                        ClickFunctionsAdd(Manto)
                        questmark = AddQuestMark(Manto, MARK_TYPE_QUESTION, MARK_SPECIAL)

                        RegisterClickFeedbackOnNPC(Manto, function()
                            ClickFunctionsRemove(Manto)
                            DestroyEffect(questmark)
                            TriggerSleepAction(1.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_5, 8., 8.)
                            local sfx = AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdx", GetUnitX(Manto), GetUnitY(Manto))
                            TriggerSleepAction(7.)
                            DestroyEffect(sfx)
                            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdx"), GetUnitX(Manto), GetUnitY(Manto))
                            TriggerSleepAction(4.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_6, 7., 7.)
                            PlayCinematicSpeechForEveryone(Manto, LOCALE_LIST[my_locale].QUEST_3_M_SPEECH_7, 8., 8.)
                            SetQuestItemState("quest_3_main","quest_3_main_item_3", true)
                            GiveExp(450)
                            local gold = GiveGold(200)
                            ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_FIRST .. gold .. LOCALE_LIST[my_locale].QUEST_REWARD_GOLD_SECOND)
                            DestroyTrigger(GetTriggeringTrigger())
                            DelayAction(70., function() ShowUnit(Manto, false) end)
                        end)

                    end
                end

        end)


    end
    

    function InitOutskirtsQuestsData()

        DelayAction(GetRandomInt(40, 120), function()

            MantoRescueQuestEnable()
        end)
        
    end

end