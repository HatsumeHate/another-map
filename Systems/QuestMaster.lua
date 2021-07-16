---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 10.02.2020 9:46
---
do


    QUEST_REVEALED_STRING = "|c00FFCE00Задание получено: |r"
    QUEST_DONE_STRING = "|c005AFF00Задание выполнено: |r"
    QUEST_FAILED_STRING = "|c00FF5151Задание провалено: |r"
    QUEST_UPDATED_STRING = "|c0079C8FFЗадание обновлено: |r"
    QUEST_REQUIREMENT_STRING = "|c00009FFFНовые подробности задания: |r"
    QUEST_HINT_STRING = "|c004FFFE4Подсказка: |r"
    QUEST_ALERT_STRING = "|c00FF7D63Внимание: |r"

    QUEST_REVEALED_SOUND = nil
    QUEST_DONE_SOUND = nil
    QUEST_FAILED_SOUND = nil
    QUEST_UPDATED_SOUND = nil
    QUEST_REQUIREMENT_SOUND = nil
    QUEST_HINT_SOUND = nil
    QUEST_ALERT_SOUND = nil


    QuestsList = {}




    local function NewQuestTemplate(title, description)
        return {
            name = title,
            quest = CreateQuest(),
            description = description,
            discovered = false,
            completed = false,
            failed = false,
            quest_items = {}
        }
    end


    ---@param message string
    ---@param time real
    function SendQuestMessage(message, time)
        for i = 1, bj_MAX_PLAYERS do
            DisplayTimedTextToPlayer(Player(i-1), 0, 0, time, " ")
            DisplayTimedTextToPlayer(Player(i-1), 0, 0, time, message)
        end
    end



    ---@param message string
    function ShowQuestHint(message)
        SendQuestMessage(QUEST_HINT_STRING .. message, bj_TEXT_DELAY_ALWAYSHINT)
        StartSound(QUEST_HINT_SOUND or bj_questHintSound)
    end

    ---@param message string
    function ShowQuestHintForPlayer(message, player)
        if GetLocalPlayer() == Player(player) then
            DisplayTimedTextToPlayer(Player(player), 0, 0, bj_TEXT_DELAY_ALWAYSHINT, " ")
            DisplayTimedTextToPlayer(Player(player), 0, 0, bj_TEXT_DELAY_ALWAYSHINT, QUEST_HINT_STRING .. message)
            StartSound(QUEST_HINT_SOUND or bj_questHintSound)
        end
    end

    ---@param message string
    function ShowQuestAlert(message)
        SendQuestMessage(QUEST_ALERT_STRING .. message, bj_TEXT_DELAY_WARNING)
        StartSound(QUEST_ALERT_SOUND or bj_questWarningSound)
    end


    function HintQuestUpdated(quest_id)
        SendQuestMessage(QUEST_UPDATED_STRING .. QuestsList[quest_id].name, bj_TEXT_DELAY_QUESTUPDATE)
        StartSound(QUEST_UPDATED_SOUND or bj_questUpdatedSound)
        FlashQuestDialogButton()
    end


    function MarkQuestAsFailed(quest_id)
        QuestsList[quest_id].failed = true
        QuestSetFailed(QuestsList[quest_id].quest, true)
        SendQuestMessage(QUEST_FAILED_STRING .. QuestsList[quest_id].name, bj_TEXT_DELAY_QUESTFAILED)
        StartSound(QUEST_FAILED_SOUND or bj_questFailedSound)
        FlashQuestDialogButton()
    end

    function MarkQuestAsCompleted(quest_id)
        QuestsList[quest_id].completed = true
        QuestSetCompleted(QuestsList[quest_id].quest, true)
        SendQuestMessage(QUEST_DONE_STRING .. QuestsList[quest_id].name, bj_TEXT_DELAY_QUESTDONE)
        StartSound(QUEST_DONE_SOUND or bj_questCompletedSound)
        FlashQuestDialogButton()
    end


    function RevealQuest(quest_id)
        QuestSetDiscovered(QuestsList[quest_id].quest, true)
        QuestsList[quest_id].discovered = true
        SendQuestMessage(QUEST_REVEALED_STRING .. QuestsList[quest_id].name, bj_TEXT_DELAY_QUEST)
        StartSound(QUEST_REVEALED_SOUND or bj_questDiscoveredSound)
        FlashQuestDialogButton()
    end



    local function GetQuestItem(player_quest, id)
            for i = 1, #player_quest.quest_items do
                if player_quest.quest_items[i].id == id then
                    return player_quest.quest_items[i]
                end
            end
        return nil
    end


    ---@param description string
    ---@param notify boolean
    function ChangeQuestItem(quest_id, id, description, notify)
         local questitem = GetQuestItem(QuestsList[quest_id], id)
        
            QuestItemSetDescription(questitem, description)

            if notify then
                HintQuestUpdated(quest_id)
            end

    end

    function IsMyQuestItemCompleted(quest_id, quest_item_id)
        local quest = QuestsList[quest_id]
        local qitem_table = GetQuestItem(quest, quest_item_id)
        if not qitem_table then return false end
        return IsQuestItemCompleted(qitem_table.qitem)
    end

    ---@param quest_item questitem
    ---@param state boolean
    function SetQuestItemState(quest_id, quest_item, state)
        local quest = QuestsList[quest_id] or nil
        local completed_quest_items = 0

        if quest == nil then return end

        for i = 1, #quest.quest_items do
            if quest.quest_items[i].id == quest_item then
                quest_item = quest.quest_items[i]
                QuestItemSetCompleted(quest_item.qitem, state)
                quest_item.completed = state

                for i2 = 1, #quest.quest_items do
                    if quest.quest_items[i2].completed then
                        completed_quest_items = completed_quest_items + 1
                    end
                end

                if completed_quest_items == #quest.quest_items then
                    MarkQuestAsCompleted(quest_id)
                    return true
                else
                    HintQuestUpdated(quest_id)
                end
                break
            end
        end

        return false
    end


    ---@param number integer
    function SetQuestItemPool(quest_id, id, number)
        local player_quest = QuestsList[quest_id]
        local qitem_table = GetQuestItem(player_quest, id)

        if not qitem_table or player_quest.completed then return true end

            qitem_table.current_pool_count = (qitem_table.current_pool_count or 0) + number
            QuestItemSetDescription(qitem_table.qitem, qitem_table.description .. " " ..  qitem_table.current_pool_count .. "/" .. qitem_table.pool_count)

            if qitem_table.current_pool_count >= qitem_table.pool_count then
                SetQuestItemState(quest_id, id, true)
                return true
            else
                HintQuestUpdated(quest_id)
            end

        return false
    end


    ---@param count integer
    function AddQuestItemPool(quest_id, id, count)
        local player_quest = QuestsList[quest_id]
        local qitem_table = GetQuestItem(player_quest, id)

            if qitem_table ~= nil then
                qitem_table.pool_count = count
                qitem_table.current_pool_count = 0
                QuestItemSetDescription(qitem_table.qitem, qitem_table.description .. " 0/" .. I2S(count))
            end
    end


    ---@param quest_id any
    ---@param id any
    ---@param description string
    ---@param notify boolean
    function AddQuestItem(quest_id,  id,  description,  notify)
        local player_quest = QuestsList[quest_id]
        if player_quest == nil then return end

        local qitem_table = GetQuestItem(player_quest, id)


            if qitem_table == nil then
                local qitem = QuestCreateItem(player_quest.quest)
                    qitem_table = { qitem = qitem, id = id, description = description, completed = false }

                    QuestItemSetCompleted(qitem, false)
                    QuestItemSetDescription(qitem, description)

                    table.insert(player_quest.quest_items, qitem_table)

                        if notify then
                            SendQuestMessage(QUEST_REQUIREMENT_STRING .. QuestsList[quest_id].name, bj_TEXT_DELAY_QUESTREQUIREMENT)
                            StartSound(QUEST_REQUIREMENT_SOUND or bj_questItemAcquiredSound)
                        end

            end

    end


    ---@param player number
    ---@param unit unit
    ---@param text string
    ---@param time number
    function PlayCinematicSpeech(player, unit, text, time)
        if GetLocalPlayer() == Player(player) then
            ForceCinematicSubtitles(true)
            SetCinematicScene(GetUnitTypeId(unit), GetPlayerColor(GetOwningPlayer(unit)), GetUnitName(unit), text, time, time)
            PingMinimap(GetUnitX(unit), GetUnitY(unit), bj_TRANSMISSION_PING_TIME)
            UnitAddIndicator(unit, bj_TRANSMISSION_IND_RED, bj_TRANSMISSION_IND_BLUE, bj_TRANSMISSION_IND_GREEN, bj_TRANSMISSION_IND_ALPHA)
        end
    end


    ---@param unit unit
    ---@param text string
    ---@param time number
    function PlayCinematicSpeechForEveryone(unit, text, time, waittime)
        ForceCinematicSubtitles(true)
        SetCinematicScene(GetUnitTypeId(unit), GetPlayerColor(GetOwningPlayer(unit)), GetUnitName(unit), text, time, time)
        PingMinimap(GetUnitX(unit), GetUnitY(unit), bj_TRANSMISSION_PING_TIME)
        UnitAddIndicator(unit, bj_TRANSMISSION_IND_RED, bj_TRANSMISSION_IND_BLUE, bj_TRANSMISSION_IND_GREEN, bj_TRANSMISSION_IND_ALPHA)
        if waittime then TriggerSleepAction(waittime) end
    end
    

    RegisterTestCommand("it", function()
        SetQuestItemPool("MQ01", 1, 1)
    end)

    RegisterTestCommand("qip", function()
        AddQuestItemPool("MQ01", 1, 6)
    end)

    RegisterTestCommand("qi1", function()
        AddQuestItem("MQ01", 1, "item_description",  true)
    end)

    RegisterTestCommand("quest1", function()
        NewQuest("myquest1", "description?", "ReplaceableTextures\\CommandButtons\\BTNDivineIntervention.blp", true, true, "MQ01")
    end)


    ---@param quest_type boolean
    ---@param description string
    ---@param icon string
    ---@param discovered boolean
    ---@param title string
    function NewQuest(title, description, icon, quest_type, discovered, quest_id)

            if QuestsList[quest_id] == nil then
                local my_quest = NewQuestTemplate(title, description)

                    QuestSetTitle(my_quest.quest, title)
                    QuestSetDescription(my_quest.quest, description)
                    QuestSetIconPath(my_quest.quest, icon)
                    QuestSetRequired(my_quest.quest, quest_type)
                    QuestSetDiscovered(my_quest.quest, false)
                    QuestSetCompleted(my_quest.quest, false)

                QuestsList[quest_id] = my_quest
            end


            if discovered then
                RevealQuest(quest_id)
            end

        return QuestsList[quest_id]
    end



    function InitQuestMaster()

        for i = 1, bj_MAX_PLAYERS do
            QuestsList[i] = {}
        end

        QUEST_REVEALED_STRING = "|c00FFCE00Задание получено: |r"
        QUEST_DONE_STRING = "|c005AFF00Задание выполнено: |r"
        QUEST_FAILED_STRING = "|c00FF5151Задание провалено: |r"
        QUEST_UPDATED_STRING = "|c0079C8FFЗадание обновлено: |r"
        QUEST_REQUIREMENT_STRING = "|c00009FFFНовые подробности задания: |r"
        QUEST_HINT_STRING = "|c004FFFE4Подсказка: |r"
        QUEST_ALERT_STRING = "|c00FF7D63Внимание: |r"

        QUEST_REVEALED_SOUND = nil
        QUEST_DONE_SOUND = nil
        QUEST_FAILED_SOUND = nil
        QUEST_UPDATED_SOUND = nil
        QUEST_REQUIREMENT_SOUND = nil
        QUEST_HINT_SOUND = nil
        QUEST_ALERT_SOUND = nil


        QUEST_REVEALED_SOUND = CreateSound("", false, false, false, 100, 100, "")
        SetSoundVolume(QUEST_REVEALED_SOUND, 0)
        SetSoundChannel(QUEST_REVEALED_SOUND, 1)

        QUEST_UPDATED_SOUND = CreateSound("", false, false, false, 100, 100, "")
        SetSoundVolume(QUEST_UPDATED_SOUND, 0)
        SetSoundChannel(QUEST_UPDATED_SOUND, 1)

        QUEST_DONE_SOUND = CreateSound("", false, false, false, 100, 100, "")
        SetSoundVolume(QUEST_DONE_SOUND, 0)
        SetSoundChannel(QUEST_DONE_SOUND, 1)

    end

end