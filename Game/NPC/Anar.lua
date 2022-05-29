---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 01.04.2022 14:19
---
do



    local function Conversations()
        NewConversation("quartermaster_game_start_conv", {
            { phrase = LOCALE_LIST[my_locale].INTRODUCTION_TEXT_1, duration = 6.25 },
            { phrase = LOCALE_LIST[my_locale].INTRODUCTION_TEXT_2, duration = 6.25 },
            { phrase = LOCALE_LIST[my_locale].INTRODUCTION_TEXT_3, duration = 6.25 },
            { responce_phrase = {
                class_related = true,
                [BARBARIAN_CLASS] = { phrase = LOCALE_LIST[my_locale].INTRODUCTION_BARBARIAN_RESPONCE, duration = 6.25 },
                [SORCERESS_CLASS] = { phrase = LOCALE_LIST[my_locale].INTRODUCTION_SORCERESS_RESPONCE, duration = 5.25 },
                [NECROMANCER_CLASS] = { phrase = LOCALE_LIST[my_locale].INTRODUCTION_NECROMANCER_RESPONCE, duration = 5.25 }
            }, duration = 6.25 },
            { phrase = LOCALE_LIST[my_locale].INTRODUCTION_TEXT_4, duration = 5.25 },
        })


        NewConversation("quartermaster_intro", {
            { phrase = GetLocalString(
                    "Я Анар - интендант этого замка",
                    "I'm Anar - the quartermeister of this castle"),
              duration = 4.25 },
            { phrase = GetLocalString(
                    "Надеюсь на твою помощь здесь",
                    "I hope that you can help us here."),
              duration = 4.35 },
            { phrase = GetLocalString(
                    "Если что-то понадобится разузнать то постараюсь держать тебя в курсе.",
                    "If you need something to know, I'll try to get you informed."),
              duration = 5.55 },
        })


        NewConversation("quartermaster_scoutquest_conv", {
            { phrase = GetLocalString(
                    "В данный момент нам необходимо произвести разведку местности",
                    "Scouting is what we need at first"),
              duration = 4.45 },
            { phrase = GetLocalString(
                    "Держи эту карту. На ней отмечены участки которые нам необходимо осмотреть",
                    "Here, take this map. There are several points marked that need to be looked at"),
              duration = 4.75 },
            { phrase = GetLocalString(
                    "Как только все сделаешь, возвращайся обратно",
                    "As soon as you done come back to me"),
              duration = 4.55,
            },
            feedback = function(conv_id, npc, player)
                EnableQuartermeisterScoutQuest(player)
            end
        })


        NewConversation("quartermaster_scoutquest_done_conv", {
            { phrase = GetLocalString(
                    "А, @Mвернулся!Fвернулась#",
                    "Ah, you returned"),
              duration = 4.45 },
            { phrase = GetLocalString(
                    "Я смотрю ты @Mзакончил!Fзакончила# разведку",
                    "Looks like you completed the scouting"),
              duration = 4.75 },
            { phrase = GetLocalString(
                    "Давай свои заметки и возьми награду. Пока что у меня нет больше поручений. Приходи позже",
                    "Give me your notes and take this reward. For now I don't have any tasks for you. Come back later"),
              duration = 4.55,
            },
            feedback = function(conv_id, npc, player)
                CompleteQuartermeisterScoutQuest(player)
            end
        })

        NewConversation("quartermaster_altar_1", {
            { phrase = GetLocalString(
                    "Хм... @Mвстретил!Fвстретила# странный алтарь?",
                    "Hmmm... you did see a strange altar?"),
              duration = 2.25 },
            { phrase = GetLocalString(
                    "Судя по твоему описанию, я читал о чем то подобном.",
                    "Based on your description I read something about a similar thing."),
              duration = 2.35 },
            { phrase = GetLocalString(
                    "Но мне нужно будет немного поискать информации о нем, не помню где я видел его.",
                    "But I'll have to seek more info about it, don't remeber where I've seen it."),
              duration = 2.65 },
            { phrase = GetLocalString(
                    "Приходи попозже. У тебя явно есть дела поважнее.",
                    "Come back to me later. You have more importand things to do."),
              duration = 2.25 },
        })

        NewConversation("quartermaster_altar_2", {
            { phrase = GetLocalString(
                    "Хм... хммм.. ах да, алтарь.",
                    "Hmm... hmmm... ah, yes, the altar."),
              duration = 2.35 },
            { phrase = GetLocalString(
                    "Искусное творение. Создано оно конечно же не нами. Не людьми.",
                    "Marvellous creation. It's not built by us. Humans."),
              duration = 2.5 },
            { phrase = GetLocalString(
                    "Проводник нечестивых сил. В книгах написано, что он питается чистой ненавистью. Что бы это ни значило",
                    "Conductor of the unholy powers. It's written in the books that it's powered by the pure hate. Whatever that means"),
              duration = 3.45 },
            { phrase = GetLocalString(
                    "Остальное лишь слухи и домыслы. Даже не представляю как можно напитать что-то ненавистью.",
                    "The rest is just rumors and speculation. I can't even imagine how you can fuel something with hate."),
              duration = 3.35 },
        })

        -- встретил алтарь -> встретил камень
        NewConversation("quartermaster_shrine_stone_after", {
            { phrase = GetLocalString(
                    "Говоришь @Mнашел!Fнашла# камень ненависти?",
                    "Found a shard of hate you say?"),
              duration = 2.35 },
            { phrase = GetLocalString(
                    "Давай ка посмотрим на него...",
                    "Let's see..."),
              duration = 4.25 },
            { phrase = GetLocalString(
                    "Удивительно! Даже смотря на него, ощущаю как во мне что-то кипит. Знаешь, у меня есть идея",
                    "Amazing! Even just looking at it I can feel burning in me. You know, I have an idea"),
              duration = 3.45 },
            { phrase = GetLocalString(
                    "Как насчет того, что бы закинуть их в алтарь? Интересно, что же произойдет",
                    "How about you throw some of them into it? I wander what happens next"),
              duration = 3.35 },
        })

        NewConversation("quartermaster_shrine_stone_before", {
            { phrase = GetLocalString(
                    "У тебя есть необычный самоцвет?",
                    "You have an unusual gem?"),
              duration = 2.35 },
            { phrase = GetLocalString(
                    "Интересно, я встречал кое что в книгах про подобные камни, но не помню точно где",
                    "Interesting, I've read something about similar gems but don't remember where exactly"),
              duration = 6.45 },
            { phrase = GetLocalString(
                    "Там было про какой то алтарь, так что если встретишь какой то необычный алтарь, дай знать",
                    "There was something about an altar, let me know if you stumble upon one"),
              duration = 6.15 },
            { phrase = GetLocalString(
                    "А я пока поищу в книгах еще про них",
                    "I'll look in the books more"),
              duration = 3.45 },
        })

        NewConversation("quartermaster_shrine_stone_before_2", {
            { phrase = GetLocalString(
                    "Хм... все таки @Mнашел!Fнашла# странный алтарь?",
                    "Hm... so you have found an unusual altar?"),
              duration = 2.25 },
            { phrase = GetLocalString(
                    "Судя по твоему описанию, это похоже на него. Искусное творение. Создано оно конечно же не нами. Не людьми.",
                    "Seems like it is it. Marvellous creation. It's not built by us of course. Humans."),
              duration = 2.35 },
            { phrase = GetLocalString(
                    "Проводник нечестивых сил. В книгах написано, что он питается чистой ненавистью. Возможно, эти самые камни",
                    "Conductor of the unholy powers. It's written in the books that it's powered by the pure hate. Whatever that means"),
              duration = 2.65 },
            { phrase = GetLocalString(
                    "Как насчет того, что бы закинуть их в алтарь? Интересно, что же произойдет",
                    "How about you throw some of them into it? I wander what happens next"),
              duration = 2.25 },
        })

        NewConversation("quartermaster_task_spiderqueen_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На юге от замка, если спуститься через луга и пойти по кромке воды, есть закоулок где притаилась королева пауков",
                    "If you walk from meadows and walk along the water's edge you'll see a nook where the Brood Mother is."),
              duration = 6.35 },
            { phrase = GetLocalString(
                    "Нам было бы очень кстати, если бы ты убил эту тварь. Это бы успокоило всех в округе",
                    "It would be really handy if you could kill this beast. Put the minds of people to ease"),
              duration = 3.65 },
        })

        NewConversation("quartermaster_task_spiderqueen_done", {
            { phrase = GetLocalString(
                    "Отличная работа. Теперь многие тут будут спать спокойнее, зная что она мертва. Держи свою награду",
                    "Nicely done. Everyone around here now can sleep with safe. Take your reward"),
              duration = 6.45 },
        })


        NewConversation("quartermaster_task_restlessundead_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На северо-востоке от замка, у руин склепа воскрес неупокоенный дух мертвого монарха",
                    "There are a restless spirit of an old monarch at the ruins on the north-east from the castle"),
              duration = 6.35 },
            { phrase = GetLocalString(
                    "Стоит покончить с его величеством и упокоить его дух, бедняга никак не может обрести покой",
                    "You should deal with his majesty and put his soul to rest, poor guy can't find it"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_restlessundead_done", {
            { phrase = GetLocalString(
                    "Отлично. Надеемся это был последний раз когда он воскрес",
                    "Well done. I hope his ressurection was the last"),
              duration = 5.45 },
        })


        NewConversation("quartermaster_task_banditlord_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На западе от замка проходя через луга и выйдя в рощу завелась шайка бандитов",
                    "There are bandit's camp at the sacred grove, you can reach it coming through meadows"),
              duration = 6.35 },
            { phrase = GetLocalString(
                    "У нас и так тут проблем хватает с нечистью, так что избавиться от отребья просто необходимо",
                    "We got plenty of problems here and have to get rid of them too"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_banditlord_done", {
            { phrase = GetLocalString(
                    "Видимо он получил по заслугам. Бандитской шавке - позорная смерть",
                    "I see that he got what he deserved. Bandit scum gets filthy death"),
              duration = 5.45 },
        })

        NewConversation("quartermaster_task_arachno_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На северо-западе от замка расположилось гнездо арахнидов. Мы не можем позволить себе что бы они расплодились",
                    "There is an arachno nest at the north-west from the castle. We can't let them swarm us"),
              duration = 7.35 },
            { phrase = GetLocalString(
                    "Надо вырезать их логово, убить главного арахнида. Надеюсь это тебе по плечам",
                    "You need to cut them out and kill overlord arachno. I hope you can handle it"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_arachno_done", {
            { phrase = GetLocalString(
                    "Хорошая работа. Одной проблемой меньше",
                    "Good job. One problem less"),
              duration = 5.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_1_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На юге от лугов мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the south of meadows. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_2_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "В роще мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the sacred grove. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_3_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На юге от лугов мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the south of meadows. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_4_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "В узком ущелье мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the narrow pass. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_5_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На торговом пути мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the trading path. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_6_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На торговом пути мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the trading path. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_7_give", {
            { phrase = GetLocalString(
                    "У меня есть для тебя поручение",
                    "I have a task for you"),
              duration = 3.25 },
            { phrase = GetLocalString(
                    "На торговом пути рядом с сумеречным лесом мы потеряли связь с нашим отрядом. Людей не хватает, поэтому тебе необходимо спасти тех кто еще там остался",
                    "We lost a contact with our squad at the trading path near the duskwood. We don't have much troops around, so we need you to rescue them"),
              duration = 7.55 },
            { phrase = GetLocalString(
                    "Спаси выживших и отдай им этот свиток, я надеюсь еще не слишком поздно",
                    "Save as much as you can and give them this scroll, I hope it's still not too late"),
              duration = 6.45 },
        })

        NewConversation("quartermaster_task_soldiersrescue_done", {
            { phrase = GetLocalString(
                    "Премного тебе благодарен за спасение этих парней",
                    "I'm greatly appreciate you for saving those men"),
              duration = 3.25 },
        })

    end



    function InitAnarNPC()
        Conversations()
        CreateNpcData(gg_unit_n029_0022, GetLocalString("Интендант Анар", "Quartermeister Anar"))
        local anar_data = GetUnitData(gg_unit_n029_0022)
        anar_data.marker = AddQuestMark(gg_unit_n029_0022, MARK_TYPE_EXCLAMATION, MARK_ATTENTION)
        anar_data.questmarker = AddQuestMark(gg_unit_n029_0022, MARK_TYPE_EXCLAMATION, MARK_COMMON)
        anar_data.questmarker_done = AddQuestMark(gg_unit_n029_0022, MARK_TYPE_QUESTION, MARK_COMMON)
        anar_data.daily_questmarker = AddQuestMark(gg_unit_n029_0022, MARK_TYPE_EXCLAMATION, MARK_DAILY)
        anar_data.daily_questmarker_done = AddQuestMark(gg_unit_n029_0022, MARK_TYPE_QUESTION, MARK_DAILY)
        BlzPlaySpecialEffect(anar_data.questmarker, ANIM_TYPE_DEATH)
        BlzPlaySpecialEffect(anar_data.questmarker_done, ANIM_TYPE_DEATH)
        BlzPlaySpecialEffect(anar_data.daily_questmarker, ANIM_TYPE_DEATH)
        BlzPlaySpecialEffect(anar_data.daily_questmarker_done, ANIM_TYPE_DEATH)

        DelayAction(119., function()
            local timer = CreateTimer()
            TimerStart(timer, 1., true, function()
                if not IsBlockedByConversation(gg_unit_n029_0022) then
                    IssuePointOrderById(gg_unit_n029_0022, order_move, GetRectCenterX(gg_rct_anar_position), GetRectCenterY(gg_rct_anar_position))
                    TimerStart(timer, 0.5, true, function()
                        if IsUnitInRangeXY(gg_unit_n029_0022, GetRectCenterX(gg_rct_anar_position), GetRectCenterY(gg_rct_anar_position), 20.) then
                            DestroyTimer(timer)
                            SetUnitFacing(gg_unit_n029_0022, 250.)
                        else
                            IssuePointOrderById(gg_unit_n029_0022, order_move, GetRectCenterX(gg_rct_anar_position), GetRectCenterY(gg_rct_anar_position))
                        end
                    end)
                end
            end)
        end)


        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Ммм?", "Huh?"),
            id = "quartermaster_game_start_int",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_game_start_conv", gg_unit_n029_0022, player)
                if GetLocalPlayer() == Player(player - 1) then
                    BlzPlaySpecialEffect(anar_data.marker, ANIM_TYPE_DEATH)
                    BlzPlaySpecialEffect(anar_data.questmarker, ANIM_TYPE_STAND)
                end
                LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "quartermaster_game_start_int", player)
                UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_scoutquest_intro", player)
                UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_intro_conv", player)
            end }, 1)


        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TALK,
            id = "anar_intro_conv",
            feedback = function(clicked, clicking, player) PlayConversation("quartermaster_intro", gg_unit_n029_0022, player) end }, 1)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_intro_conv")


        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Разведка", "Scouting"),
            id = "anar_scoutquest_intro",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_scoutquest_conv", gg_unit_n029_0022, player)
                LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_scoutquest_intro", player)
                if GetLocalPlayer() == Player(player - 1) then BlzPlaySpecialEffect(anar_data.questmarker, ANIM_TYPE_DEATH) end
            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_scoutquest_intro")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Разведка", "Scouting"),
            id = "anar_scoutquest_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_scoutquest_done_conv", gg_unit_n029_0022, player)
                LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_scoutquest_done", player)
                if GetLocalPlayer() == Player(player - 1) then BlzPlaySpecialEffect(anar_data.questmarker_done, ANIM_TYPE_DEATH) end
                EnableAnarTasks()
            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_scoutquest_done")


        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Алтарь", "The Altar"),
            id = "anar_altar_conv",
            feedback = function(clicked, clicking, player)
                local unit_data = GetUnitData(clicked)

                if not unit_data.delay_timers then
                    unit_data.delay_timers = { }
                end

                if not unit_data.delay_timers[player] and not HasJournalEntryLabel(player, "shrine_journal", "shrine_delay_told") then
                    unit_data.delay_timers[player] = CreateTimer()
                    TimerStart(unit_data.delay_timers[player], 60., false, function()
                        AddJournalEntryLabel(player, "shrine_journal", "shrine_delay_told")
                        LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv", player)
                        UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_2", player)
                        DestroyTimer(unit_data.delay_timers[player])
                    end)
                end

                PlayConversation("quartermaster_altar_1", gg_unit_n029_0022, player)
                if not HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_1") then
                    AddJournalEntryText(player, "shrine_journal", GetConversationText("quartermaster_altar_1", gg_unit_n029_0022), false)
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_1")
                end
            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_altar_conv")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Алтарь", "The Altar"),
            id = "anar_altar_conv_2",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_altar_2", gg_unit_n029_0022, player)

                if not HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_2") then
                    AddJournalEntryText(player, "shrine_journal", GetConversationText("quartermaster_altar_2", gg_unit_n029_0022), false)
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_2")
                end

                if HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_stone_aquired_first") then
                    LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_2", player)
                    UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_3", player)
                else
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_stone_seek")
                end

            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_altar_conv_2")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Камень ненависти", "Shard of hate"),
            id = "anar_altar_conv_3",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_shrine_stone_after", gg_unit_n029_0022, player)

                if not HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone") then
                    AddJournalEntryText(player, "shrine_journal", GetConversationText("quartermaster_shrine_stone_after", gg_unit_n029_0022), false)
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone")
                end


            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_altar_conv_3")



        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Камень ненависти", "Shard of hate"),
            id = "anar_altar_conv_stone_before",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_shrine_stone_before", gg_unit_n029_0022, player)

                if not HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone_before") then
                    AddJournalEntryText(player, "shrine_journal", GetConversationText("quartermaster_shrine_stone_before", gg_unit_n029_0022), false)
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone_before")
                end

            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_altar_conv_stone_before")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Камень ненависти", "Shard of hate"),
            id = "anar_altar_conv_4",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_shrine_stone_before_2", gg_unit_n029_0022, player)

                if not HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone_before_2") then
                    AddJournalEntryText(player, "shrine_journal", GetConversationText("quartermaster_shrine_stone_before_2", gg_unit_n029_0022), false)
                    AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_entry_stone_before_2")
                end
            end }, 2)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_altar_conv_4")


        -- tasks
        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_spiderqueen",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_spiderqueen_give", gg_unit_n029_0022, player)
                Task_SpiderQueen_Aquired(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_spiderqueen")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Завершить поручение", "Complete task"),
            id = "anar_task_spiderqueen_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_spiderqueen_done", gg_unit_n029_0022, player)
                Task_SpiderQueen_Done(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_spiderqueen_done")

        --============--

        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_restlessundead",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_restlessundead_give", gg_unit_n029_0022, player)
                Task_RestlessUndead_Aquired(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_restlessundead")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Завершить поручение", "Complete task"),
            id = "anar_task_restlessundead_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_restlessundead_done", gg_unit_n029_0022, player)
                Task_RestlessUndead_Done(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_restlessundead_done")

        --============--

        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_banditlord",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_banditlord_give", gg_unit_n029_0022, player)
                Task_BanditLord_Aquired(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_banditlord")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Завершить поручение", "Complete task"),
            id = "anar_task_banditlord_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_banditlord_done", gg_unit_n029_0022, player)
                Task_BanditLord_Done(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_banditlord_done")

        --============--

        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_arachno",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_arachno_give", gg_unit_n029_0022, player)
                Task_Arachno_Aquired(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_arachno")

        AddInteractiveOption(gg_unit_n029_0022, {
            name = GetLocalString("Завершить поручение", "Complete task"),
            id = "anar_task_arachno_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_arachno_done", gg_unit_n029_0022, player)
                Task_Arachno_Done(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_arachno_done")

        --============--

        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_soldiersrescue",
            feedback = function(clicked, clicking, player)
                PlayConversation(SoldierRescueTaskData[PlayerTask[player]].conversation, gg_unit_n029_0022, player)
                Task_SoldiersRescue_Aquired(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_soldiersrescue")


        AddInteractiveOption(gg_unit_n029_0022, {
            name = LOCALE_LIST[my_locale].INT_OPTION_TASK,
            id = "anar_task_soldiersrescue_done",
            feedback = function(clicked, clicking, player)
                PlayConversation("quartermaster_task_soldiersrescue_done", gg_unit_n029_0022, player)
                Task_SoldiersRescue_Done(player)
            end }, 3)
        LockInteractiveOptionId(gg_unit_n029_0022, "anar_task_soldiersrescue_done")


        RegisterTestCommand("dai", function()
            EnableAnarTasks()
        end)

        RegisterTestCommand("ddd", function()
            SetUnitX(PlayerHero[1], GetUnitX(BossPack[4].boss))
            SetUnitY(PlayerHero[1], GetUnitY(BossPack[4].boss)-150.)
            KillUnit(BossPack[4].boss)
        end)
    end



end

