---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 01.04.2020 7:04
---
do

    GlobalButton = 0
    FrameState = 0
    GlobalFrameState = 0
    GlobalButtonClickTrigger = nil


    last_OpenedWindow = nil
    CHAR_PANEL = 1
    INV_PANEL = 2
    SKILL_PANEL = 3
    SHOP_PANEL = 4
    TELEPORT_PANEL = 5
    TALENT_PANEL = 6
    JOURNAL_PANEL = 7
    GLOBAL_TOOLTIP_FADE_TIME = 0.33



    function ReloadUI()

        for player = 1, 6 do
            if UnitBarTrackingTrigger[player] then
                DisableTrigger(UnitBarTrackingTrigger[player])
            end
        end

        DelayAction(0., function()

            EnableDragSelect(false, false)
            BlzEnableSelections(false, true)
            EnablePreSelect(true, false)

            --ClearMapMusic()
            --StopMusic(false)
            --PlayMusic("Sound\\Music\\mp3Music\\Comradeship.mp3")
            SetGameSpeed(MAP_SPEED_FASTEST)
            SetMapFlag(MAP_LOCK_SPEED, true)
            EnableOcclusion(true)

            GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
            BlzLoadTOCFile("war3mapimported\\BoxedText.toc")
            if not BlzLoadTOCFile("war3mapImported\\MyTOCfile.toc") then print("MyTOCfile.toc not loaded") end


            for i = 1, 6 do
                GlobalButton[i].char_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.034, 0.034, GAME_UI, FRAMEPOINT_CENTER, FRAMEPOINT_BOTTOMLEFT, 0.1725, 0.028, GAME_UI)
                CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].char_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                BlzFrameSetVisible(GlobalButton[i].char_panel_button, false)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].char_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateSimpleChargesText(GlobalButton[i].char_panel_button, "C", 0.9, 0.9)

                GlobalButton[i].skill_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp", 0.034, 0.034, GlobalButton[i].char_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.003, 0., GAME_UI)
                CreateTooltip(LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].skill_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                BlzFrameSetVisible(GlobalButton[i].skill_panel_button, false)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].skill_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateSimpleChargesText(GlobalButton[i].skill_panel_button, "B", 0.9, 0.9)

                GlobalButton[i].inventory_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0.034, 0.034, GlobalButton[i].skill_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.003, 0., GAME_UI)
                CreateTooltip(LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].inventory_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                BlzFrameSetVisible(GlobalButton[i].inventory_panel_button, false)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].inventory_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateSimpleChargesText(GlobalButton[i].inventory_panel_button, "TAB", 0.9, 0.7, 0.008)

                GlobalButton[i].talents_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNMarksmanship.blp", 0.034, 0.034, GAME_UI, FRAMEPOINT_CENTER, FRAMEPOINT_BOTTOMLEFT, 0.6275, 0.028, GAME_UI)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].talents_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateTooltip(GetLocalString("Таланты", "Talents"), GetLocalString("Изучение всех доступных талантов героя.", "Learning of all hero talents."), GlobalButton[i].talents_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                CreateSimpleChargesText(GlobalButton[i].talents_panel_button, "N", 0.9, 0.9)
                BlzFrameSetVisible(GlobalButton[i].talents_panel_button, false)

                GlobalButton[i].journal_panel_button = CreateSimpleButton("UI\\BTNScribeScroll.blp", 0.034, 0.034, GlobalButton[i].talents_panel_button, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.003, 0., GAME_UI)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].journal_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateTooltip(GetLocalString("Журнал", "Journal"), GetLocalString("Все заметки и задания.", "All notes and quests tracking."), GlobalButton[i].journal_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                CreateSimpleChargesText(GlobalButton[i].journal_panel_button, "J", 0.9, 0.9)
                BlzFrameSetVisible(GlobalButton[i].journal_panel_button, false)

                GlobalButton[i].settings_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp", 0.034, 0.034, GlobalButton[i].journal_panel_button, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.003, 0., GAME_UI)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].settings_panel_button, FRAMEEVENT_CONTROL_CLICK)
                CreateTooltip(GetLocalString("Настройки", "Settings"), GetLocalString("Пока что отключено.", "Not yet implemented."), GlobalButton[i].settings_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                CreateSimpleChargesText(GlobalButton[i].settings_panel_button, "P", 0.9, 0.9)
                BlzFrameSetVisible(GlobalButton[i].settings_panel_button, false)

                GlobalButton[i].dash_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNEvasion.blp", 0.026, 0.026, GlobalButton[i].talents_panel_button, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0.05, GAME_UI)
                BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].dash_button, FRAMEEVENT_CONTROL_CLICK)
                CreateTooltip(GetLocalString("Рывок", "Dash"), GetLocalString("Нажмите [SPACE] что бы сделать рывок. Кликните что бы сменить режим: на курсор/по направлению взгляда героя",
                    "Press [SPACEBAR] to dash. Click to change mode: to the cursor/to the hero facing"), GlobalButton[i].dash_button, 0.14, 0.08, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                local new_FrameText = BlzCreateFrameByType("TEXT", "hotkeytext", GlobalButton[i].dash_button, "", 0)
                BlzFrameSetPoint(new_FrameText, FRAMEPOINT_BOTTOM, GlobalButton[i].dash_button, FRAMEPOINT_BOTTOM, 0., 0.005)
                BlzFrameSetTextAlignment(new_FrameText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
                BlzFrameSetText(new_FrameText, "space")
                BlzFrameSetScale(new_FrameText, 0.65)
                BlzFrameSetVisible(GlobalButton[i].dash_button, false)

                GlobalButton[i].dash_button_cooldown = BlzCreateFrameByType("STATUSBAR", "dash_button_cooldown", GlobalButton[i].dash_button, "", 0)
                BlzFrameSetSize(GlobalButton[i].dash_button_cooldown, 0.000001, 0.000001)
                BlzFrameSetScale(GlobalButton[i].dash_button_cooldown, 0.65)
                BlzFrameSetPoint(GlobalButton[i].dash_button_cooldown, FRAMEPOINT_BOTTOMLEFT, GlobalButton[i].dash_button, FRAMEPOINT_BOTTOMLEFT, 0., 0.)
                BlzFrameSetModel(GlobalButton[i].dash_button_cooldown, "ui\\feedback\\cooldown\\ui-cooldown-indicator.mdx", 0)
                BlzFrameSetValue(GlobalButton[i].dash_button_cooldown, 0)
                BlzFrameSetVisible(GlobalButton[i].dash_button_cooldown, false)

                --[[
                GlobalButton[i].switch_button = CreateSimpleButton("UI\\BTN_CR_WeaponSwitch.blp", 0.026, 0.026, GlobalButton[i].settings_panel_button, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, -0.02, 0.03, GAME_UI)
                BlzFrameSetEnable(GlobalButton[i].switch_button, false)
                --BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].dash_button, FRAMEEVENT_CONTROL_CLICK)
                CreateTooltip(GetLocalString("Смена оружия", "Weapon Switch"), GetLocalString("Быстро меняет оружие", "Quickly switches weapons"), GlobalButton[i].switch_button, 0.14, 0.08, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
                CreateSimpleChargesText(GlobalButton[i].switch_button, "V", 0.7, 0.7)
                BlzFrameSetVisible(GlobalButton[i].switch_button, false)
                ]]
            end

            --print("0")
            ReloadAdvancedFrames()
            --print("A")
            ReloadPlayerUIFrames()
            --print("B")
            ReloadMultiboard()
            --print("C")
            ReloadTeleportFrames()
            --print("D")
            ReloadPrivateChestFrames()
            ReloadStashFrames()
            ReloadInventoryFrames()
            ReloadShopFrames()
            ReloadBarFrames()
            --print("I")
            ReloadLibrarianFrames()
            --print("J")
            ReloadBlacksmithFrames()
            --print("K")
            ReloadLocationFrames()
            --print("L")
            ReloadInteractionFrames()
            --print("M")
            ReloadStatsFrames()
            --print("N")
            --print("O")
            ReloadTalentFrames()
            --print("P")
            ReloadJournalFrames()
            --print("R")
            ReloadSkillPanelFrames()
            --print("S")
        end)


    end







    ---@param player_id integer
    ---@param hero unit
    function CreateGUILayoutForPlayer(player_id, hero)

        TriggerRegisterUnitEvent(LevelUpFrameTrigger, hero, EVENT_UNIT_HERO_LEVEL)

        local first_timer = CreateTimer()
        TimerStart(first_timer, 0.1, false, function()
            DrawStatsPanelInterface(player_id)
            AddToPanel(hero, player_id)
        end)

        local second_timer = CreateTimer()
        TimerStart(second_timer, 0.5, false, function()
            DrawInventoryFrames(player_id, hero)
        end)

        DelayAction(0.75, function()
            AddTalentCategories(hero, player_id)
            CreateJournal(player_id)
        end)

        local third_timer = CreateTimer()
        TimerStart(third_timer, 1., false, function()
            DrawSkillPanel(player_id)
        end)

        local forth_timer = CreateTimer()
        TimerStart(forth_timer, 1.25, false, function()
            RegisterUnitForTeleport(hero)
            CreateBarsForPlayer(player_id)
        end)

        local fifth_timer = CreateTimer()
        TimerStart(fifth_timer, 1.5, false, function()
            DrawShopFrames(player_id)
        end)

        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_TAB, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_C, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_B, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_N, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_J, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_ESCAPE, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_SPACE, 0, true)
        GlobalFrameState[player_id] = false

    end

    function EnableGUIForPlayer(player_id)
        GlobalFrameState[player_id] = true
        BlzFrameSetVisible(GlobalButton[player_id].char_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].inventory_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].skill_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].talents_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].journal_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].settings_panel_button, true)
        BlzFrameSetVisible(GlobalButton[player_id].dash_button, true)
        --BlzFrameSetVisible(GlobalButton[player_id].switch_button, true)
        if GetLocalPlayer() ~= Player(player_id - 1) then
            BlzFrameSetVisible(GlobalButton[player_id].char_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].inventory_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].skill_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].talents_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].journal_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].settings_panel_button, false)
            BlzFrameSetVisible(GlobalButton[player_id].dash_button, false)
            --BlzFrameSetVisible(GlobalButton[player_id].switch_button, false)
        end
    end

    local PlayerUIQueue = 0

    function RemoveUIFromQueue(player, ui_type)
        if #PlayerUIQueue[player] > 0 then
            for i = 1, #PlayerUIQueue[player] do
                if PlayerUIQueue[player][i] == ui_type then
                    table.remove(PlayerUIQueue[player], i)
                    break
                end
            end
        end
    end


    function SetUIState(player, ui_type, state)

        FrameState[player][ui_type] = state

            if ui_type == INV_PANEL then
                if SetInventoryState(player, FrameState[player][INV_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = INV_PANEL
                else
                    RemoveUIFromQueue(player, INV_PANEL)
                end
            elseif ui_type == SKILL_PANEL then
                if FrameState[player][SKILL_PANEL] and FrameState[player][CHAR_PANEL] then
                    FrameState[player][CHAR_PANEL] = false
                    SetStatsPanelState(player, false)
                    RemoveUIFromQueue(player, CHAR_PANEL)
                end

                if FrameState[player][TALENT_PANEL] and FrameState[player][SKILL_PANEL] then
                    FrameState[player][TALENT_PANEL] = false
                    SetTalentPanelState(player, false)
                    RemoveUIFromQueue(player, TALENT_PANEL)
                end

                if FrameState[player][JOURNAL_PANEL] and FrameState[player][SKILL_PANEL] then
                    FrameState[player][JOURNAL_PANEL] = false
                    SetJournalPanelState(player, false)
                    RemoveUIFromQueue(player, JOURNAL_PANEL)
                end

                if SetSkillPanelState(player, FrameState[player][SKILL_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = SKILL_PANEL
                end
            elseif ui_type == CHAR_PANEL then
                if FrameState[player][SKILL_PANEL] and FrameState[player][CHAR_PANEL] then
                    FrameState[player][SKILL_PANEL] = false
                    SetSkillPanelState(player, false)
                    RemoveUIFromQueue(player, SKILL_PANEL)
                end

                if FrameState[player][TALENT_PANEL] and FrameState[player][CHAR_PANEL] then
                    FrameState[player][TALENT_PANEL] = false
                    SetTalentPanelState(player, false)
                    RemoveUIFromQueue(player, TALENT_PANEL)
                end

                if FrameState[player][JOURNAL_PANEL] and FrameState[player][CHAR_PANEL] then
                    FrameState[player][JOURNAL_PANEL] = false
                    SetJournalPanelState(player, false)
                    RemoveUIFromQueue(player, JOURNAL_PANEL)
                end

                if SetStatsPanelState(player, FrameState[player][CHAR_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = CHAR_PANEL
                end
            elseif ui_type == TALENT_PANEL then

                if FrameState[player][SKILL_PANEL] and FrameState[player][TALENT_PANEL] then
                    FrameState[player][SKILL_PANEL] = false
                    SetSkillPanelState(player, false)
                    RemoveUIFromQueue(player, SKILL_PANEL)
                end

                if FrameState[player][CHAR_PANEL] and FrameState[player][TALENT_PANEL] then
                    FrameState[player][CHAR_PANEL] = false
                    SetStatsPanelState(player, false)
                    RemoveUIFromQueue(player, CHAR_PANEL)
                end

                if FrameState[player][JOURNAL_PANEL] and FrameState[player][TALENT_PANEL] then
                    FrameState[player][JOURNAL_PANEL] = false
                    SetJournalPanelState(player, false)
                    RemoveUIFromQueue(player, JOURNAL_PANEL)
                end

                if SetTalentPanelState(player, FrameState[player][TALENT_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = TALENT_PANEL
                end

            elseif ui_type == JOURNAL_PANEL then


                if FrameState[player][SKILL_PANEL] and FrameState[player][JOURNAL_PANEL] then
                    FrameState[player][SKILL_PANEL] = false
                    SetSkillPanelState(player, false)
                    RemoveUIFromQueue(player, SKILL_PANEL)
                end

                if FrameState[player][CHAR_PANEL] and FrameState[player][JOURNAL_PANEL] then
                    FrameState[player][CHAR_PANEL] = false
                    SetStatsPanelState(player, false)
                    RemoveUIFromQueue(player, CHAR_PANEL)
                end

                if FrameState[player][TALENT_PANEL] and FrameState[player][JOURNAL_PANEL] then
                    FrameState[player][TALENT_PANEL] = false
                    SetTalentPanelState(player, false)
                    RemoveUIFromQueue(player, TALENT_PANEL)
                end

                if SetJournalPanelState(player, FrameState[player][JOURNAL_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = JOURNAL_PANEL
                end
            end

    end


    function CreateSimpleChargesText(frame, text, scale, text_scale, bonus_size_x, bonus_size_y, owner)
        local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", owner or frame, "", 0)
            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
            BlzFrameSetSize(new_FrameCharges, 0.012 + (bonus_size_x or 0.), 0.012 + (bonus_size_y or 0.))
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
            BlzFrameSetAllPoints(new_FrameChargesText, new_FrameCharges)
            BlzFrameSetTextAlignment(new_FrameChargesText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            BlzFrameSetText(new_FrameChargesText, text)
            BlzFrameSetScale(new_FrameCharges, scale)
            BlzFrameSetScale(new_FrameChargesText, text_scale)
        return new_FrameCharges
    end



    GUIManagerHotkeyTrigger = 0


    function InitGUIManager()

        GlobalButton = {}
        FrameState = {}
        GlobalFrameState = {}
        GUIManagerHotkeyTrigger = CreateTrigger()

        PlayerUIQueue = {}


        StatsPanelInit()
        InventoryInit()
        InitShopData()
		SkillPanelInit()
        InitPrivateChest()
        InitUIBars()
        InitTalentsWindow()
        InitJournal()

        last_OpenedWindow = {}

        for i = 1, 6 do
            PlayerUIQueue[i] = {}
            FrameState[i] = {
                [CHAR_PANEL] = false,
                [INV_PANEL] = false,
                [SKILL_PANEL] = false,
                [SHOP_PANEL] = false,
                [TELEPORT_PANEL] = false,
                [TALENT_PANEL] = false,
                [JOURNAL_PANEL] = false,
            }
        end

        GlobalButtonClickTrigger = CreateTrigger()


        for i = 1, 6 do
            GlobalButton[i] = {}

            -- "UI\\StatPanelIcon.blp"
            -- "UI\\SkillPanelIcon.blp"
            -- "UI\\IventoryIcon.blp"
            GlobalButton[i].char_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.034, 0.034, GAME_UI, FRAMEPOINT_CENTER, FRAMEPOINT_BOTTOMLEFT, 0.1725, 0.028, GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].char_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            BlzFrameSetVisible(GlobalButton[i].char_panel_button, false)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].char_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].char_panel_button, "C", 0.9, 0.9)

            GlobalButton[i].skill_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp", 0.034, 0.034, GlobalButton[i].char_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.003, 0., GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].skill_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            BlzFrameSetVisible(GlobalButton[i].skill_panel_button, false)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].skill_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].skill_panel_button, "B", 0.9, 0.9)

            GlobalButton[i].inventory_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0.034, 0.034, GlobalButton[i].skill_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.003, 0., GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].inventory_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            BlzFrameSetVisible(GlobalButton[i].inventory_panel_button, false)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].inventory_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].inventory_panel_button, "TAB", 0.9, 0.7, 0.008)

            GlobalButton[i].talents_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNMarksmanship.blp", 0.034, 0.034, GAME_UI, FRAMEPOINT_CENTER, FRAMEPOINT_BOTTOMLEFT, 0.6275, 0.028, GAME_UI)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].talents_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateTooltip(GetLocalString("Таланты", "Talents"), GetLocalString("Изучение всех доступных талантов героя.", "Learning of all hero talents."), GlobalButton[i].talents_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            CreateSimpleChargesText(GlobalButton[i].talents_panel_button, "N", 0.9, 0.9)
            BlzFrameSetVisible(GlobalButton[i].talents_panel_button, false)

            GlobalButton[i].journal_panel_button = CreateSimpleButton("UI\\BTNScribeScroll.blp", 0.034, 0.034, GlobalButton[i].talents_panel_button, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.003, 0., GAME_UI)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].journal_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateTooltip(GetLocalString("Журнал", "Journal"), GetLocalString("Все заметки и задания.", "All notes and quests tracking."), GlobalButton[i].journal_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            CreateSimpleChargesText(GlobalButton[i].journal_panel_button, "J", 0.9, 0.9)
            BlzFrameSetVisible(GlobalButton[i].journal_panel_button, false)

            GlobalButton[i].settings_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp", 0.034, 0.034, GlobalButton[i].journal_panel_button, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.003, 0., GAME_UI)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].settings_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateTooltip(GetLocalString("Настройки", "Settings"), GetLocalString("Пока что отключено.", "Not yet implemented."), GlobalButton[i].settings_panel_button, 0.14, 0.06, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            CreateSimpleChargesText(GlobalButton[i].settings_panel_button, "P", 0.9, 0.9)
            BlzFrameSetVisible(GlobalButton[i].settings_panel_button, false)

            GlobalButton[i].dash_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNEvasion.blp", 0.026, 0.026, GlobalButton[i].talents_panel_button, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0.05, GAME_UI)
            BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].dash_button, FRAMEEVENT_CONTROL_CLICK)
            CreateTooltip(GetLocalString("Рывок", "Dash"), GetLocalString("Нажмите [SPACE] что бы сделать рывок. Кликните что бы сменить режим: на курсор/по направлению взгляда героя",
                    "Press [SPACEBAR] to dash. Click to change mode: to the cursor/to the hero facing"), GlobalButton[i].dash_button, 0.14, 0.08, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            --CreateSimpleChargesText(GlobalButton[i].dash_button, "space", 0.9, 0.9)
            local new_FrameText = BlzCreateFrameByType("TEXT", "hotkeytext", GlobalButton[i].dash_button, "", 0)
            --BlzFrameSetAllPoints(new_FrameText, GlobalButton[i].dash_button)
            BlzFrameSetPoint(new_FrameText, FRAMEPOINT_BOTTOM, GlobalButton[i].dash_button, FRAMEPOINT_BOTTOM, 0., 0.005)
            --BlzFrameSetSize(new_FrameText, 0.00001, 0.00001)
            BlzFrameSetTextAlignment(new_FrameText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            BlzFrameSetText(new_FrameText, "space")
            BlzFrameSetScale(new_FrameText, 0.65)
            BlzFrameSetVisible(GlobalButton[i].dash_button, false)

            GlobalButton[i].dash_button_cooldown = BlzCreateFrameByType("STATUSBAR", "dash_button_cooldown", GlobalButton[i].dash_button, "", 0)
            BlzFrameSetSize(GlobalButton[i].dash_button_cooldown, 0.000001, 0.000001)
            BlzFrameSetScale(GlobalButton[i].dash_button_cooldown, 0.65)
            BlzFrameSetPoint(GlobalButton[i].dash_button_cooldown, FRAMEPOINT_BOTTOMLEFT, GlobalButton[i].dash_button, FRAMEPOINT_BOTTOMLEFT, 0., 0.)
            BlzFrameSetModel(GlobalButton[i].dash_button_cooldown, "ui\\feedback\\cooldown\\ui-cooldown-indicator.mdx", 0)
            BlzFrameSetValue(GlobalButton[i].dash_button_cooldown, 0)
            BlzFrameSetVisible(GlobalButton[i].dash_button_cooldown, false)

            --[[
            GlobalButton[i].switch_button = CreateSimpleButton("UI\\BTN_CR_WeaponSwitch.blp", 0.026, 0.026, GlobalButton[i].settings_panel_button, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, -0.02, 0.03, GAME_UI)
            BlzFrameSetEnable(GlobalButton[i].switch_button, false)
            --BlzTriggerRegisterFrameEvent(GlobalButtonClickTrigger, GlobalButton[i].dash_button, FRAMEEVENT_CONTROL_CLICK)
            CreateTooltip(GetLocalString("Смена оружия", "Weapon Switch"), GetLocalString("Быстро меняет оружие", "Quickly switches weapons"), GlobalButton[i].switch_button, 0.14, 0.08, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP)
            CreateSimpleChargesText(GlobalButton[i].switch_button, "V", 0.7, 0.7)
            BlzFrameSetVisible(GlobalButton[i].switch_button, false)
]]

        end

        TriggerAddAction(GUIManagerHotkeyTrigger, function()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local key = BlzGetTriggerPlayerKey()

                if not GlobalFrameState[player] then
                    return
                end

                if key == OSKEY_TAB then
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    SetUIState(player, INV_PANEL, not FrameState[player][INV_PANEL])
                elseif key == OSKEY_C then
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    SetUIState(player, CHAR_PANEL, not FrameState[player][CHAR_PANEL])
                elseif key == OSKEY_B then
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    SetUIState(player, SKILL_PANEL, not FrameState[player][SKILL_PANEL])
                elseif key == OSKEY_N then
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    SetUIState(player, TALENT_PANEL, not FrameState[player][TALENT_PANEL])
                elseif key == OSKEY_J then
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    SetUIState(player, JOURNAL_PANEL, not FrameState[player][JOURNAL_PANEL])
                elseif key == OSKEY_ESCAPE then
                    if #PlayerUIQueue[player] > 0 then
                        last_OpenedWindow[player] = PlayerUIQueue[player][#PlayerUIQueue[player]]
                        PlayLocalSound("Sound\\Interface\\Click.wav", player-1)
                        local ui_type = PlayerUIQueue[player][#PlayerUIQueue[player]]
                        SetUIState(player, ui_type, false)
                        RemoveUIFromQueue(player, ui_type)
                    end
                elseif key == OSKEY_SPACE then
                    DashPlayerHero(player)
                --elseif key == OSKEY_V then
                    --SwitchHeroWeapon(player)
                end

        end)


        TriggerAddAction(GlobalButtonClickTrigger, function()
            local frame = BlzGetTriggerFrame()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local panel_type


                for i = 1, 6 do
                    if frame == GlobalButton[i].char_panel_button then
                        panel_type = CHAR_PANEL
                        SetUIState(player, CHAR_PANEL, not FrameState[i][CHAR_PANEL])
                        break
                    elseif frame == GlobalButton[i].inventory_panel_button then
                        panel_type = INV_PANEL
                        SetUIState(player, INV_PANEL, not FrameState[i][INV_PANEL])
                        break
                    elseif frame == GlobalButton[i].skill_panel_button then
                        panel_type = SKILL_PANEL
                        SetUIState(player, SKILL_PANEL, not FrameState[i][SKILL_PANEL])
                        break
                    elseif frame == GlobalButton[i].talents_panel_button then
                        panel_type = TALENT_PANEL
                        SetUIState(player, TALENT_PANEL, not FrameState[i][TALENT_PANEL])
                    elseif frame == GlobalButton[i].journal_panel_button then
                        panel_type = JOURNAL_PANEL
                        SetUIState(player, JOURNAL_PANEL, not FrameState[i][JOURNAL_PANEL])
                        break
                    elseif frame == GlobalButton[i].dash_button then
                        SwitchPlayerDashMode(player)
                        break
                    end
                end

            frame = nil
        end)

        TeleporterInit()

        local LoadTrigger = CreateTrigger()
        TriggerRegisterGameEvent(LoadTrigger, EVENT_GAME_LOADED)
        TriggerAddAction(LoadTrigger, ReloadUI)

        local SaveTrigger = CreateTrigger()
        TriggerRegisterGameEvent(SaveTrigger, EVENT_GAME_SAVE)
        TriggerAddAction(SaveTrigger, function()
            for player = 1, 6 do
                if PlayerProjection[player] then
                    DestroyVisual(PlayerProjection[player])
                    PlayerProjection[player] = nil
                end
            end
        end)
    end

end