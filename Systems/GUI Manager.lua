---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 01.04.2020 7:04
---
do

    GlobalButton = {}
    FrameState = {}


    CHAR_PANEL = 1
    INV_PANEL = 2
    SKILL_PANEL = 3
    SHOP_PANEL = 4
    TELEPORT_PANEL = 5


    ---@param player_id integer
    ---@param hero unit
    function CreateGUILayoutForPlayer(player_id, hero)
        DrawStatsPanelInterface(player_id)
        DrawInventoryFrames(player_id, hero)
        DrawSkillPanel(player_id)
        DrawShopFrames(player_id)
        AddToPanel(hero, player_id)
        DrawQuartermeisterFrames(player_id)
        RegisterUnitForTeleport(hero)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_TAB, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_C, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_B, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(GUIManagerHotkeyTrigger, Player(player_id-1), OSKEY_ESCAPE, 0, true)
        if GetLocalPlayer() == Player(player_id - 1) then
            BlzFrameSetVisible(GlobalButton[player_id].char_panel_button, true)
            BlzFrameSetVisible(GlobalButton[player_id].inventory_panel_button, true)
            BlzFrameSetVisible(GlobalButton[player_id].skill_panel_button, true)
        end
    end


    local PlayerUIQueue

    function RemoveUIFromQueue(player, ui_type)
        if #PlayerUIQueue[player] > 0 then
            for i = 1, #PlayerUIQueue[player] do
                if PlayerUIQueue[player][i] == ui_type then
                    table.remove(PlayerUIQueue[player], i)
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
                if SetSkillPanelState(player, FrameState[player][SKILL_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = SKILL_PANEL
                end
            elseif ui_type == CHAR_PANEL then
                if FrameState[player][SKILL_PANEL] and FrameState[player][CHAR_PANEL] then
                    FrameState[player][SKILL_PANEL] = false
                    SetSkillPanelState(player, false)
                    RemoveUIFromQueue(player, SKILL_PANEL)
                end
                if SetStatsPanelState(player, FrameState[player][CHAR_PANEL]) then
                    PlayerUIQueue[player][#PlayerUIQueue[player] + 1] = CHAR_PANEL
                end
            end

    end


    function CreateSimpleChargesText(frame, text, scale, text_scale, bonus_size_x, bonus_size_y)
        local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", frame, "", 0)
            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
            BlzFrameSetSize(new_FrameCharges, 0.012 + (bonus_size_x or 0.), 0.012 + (bonus_size_y or 0.))
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
            --BlzFrameSetPoint(new_FrameChargesText, FRAMEPOINT_CENTER, new_FrameCharges, FRAMEPOINT_CENTER, 0.,0.)
            --BlzFrameSetVisible(new_FrameCharges, true)
            BlzFrameSetAllPoints(new_FrameChargesText, new_FrameCharges)
            BlzFrameSetTextAlignment(new_FrameChargesText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            BlzFrameSetText(new_FrameChargesText, text)
            --BlzFrameSetSize(new_FrameChargesText, text_size, text_size)
            BlzFrameSetScale(new_FrameCharges, scale)
            BlzFrameSetScale(new_FrameChargesText, text_scale)
    end


    GUIManagerHotkeyTrigger = nil

    function InitGUIManager()
        GUIManagerHotkeyTrigger = CreateTrigger()

        PlayerUIQueue = {}


        StatsPanelInit()
		--InventoryInit()
        InventoryInit()
        InitShopData()
		SkillPanelInit()

        for i = 1, 6 do
            PlayerUIQueue[i] = {}
            FrameState[i] = {
                [CHAR_PANEL] = false,
                [INV_PANEL] = false,
                [SKILL_PANEL] = false,
                [SHOP_PANEL] = false,
                [TELEPORT_PANEL] = false,
            }
        end

        local ClickTrigger = CreateTrigger()
        local trg = CreateTrigger()

        for i = 1, 6 do
            GlobalButton[i] = {}

            GlobalButton[i].char_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNTomeRed.blp", 0.03, 0.03, GAME_UI, FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0., -0.12, GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].STAT_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].char_panel_button, 0.14, 0.06)
            BlzFrameSetVisible(GlobalButton[i].char_panel_button, false)
            BlzTriggerRegisterFrameEvent(ClickTrigger, GlobalButton[i].char_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].char_panel_button, "C", 0.9, 0.9)

            GlobalButton[i].skill_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp", 0.03, 0.03, GlobalButton[i].char_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.01, 0., GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].skill_panel_button, 0.14, 0.06)
            BlzFrameSetVisible(GlobalButton[i].skill_panel_button, false)
            BlzTriggerRegisterFrameEvent(ClickTrigger, GlobalButton[i].skill_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].skill_panel_button, "B", 0.9, 0.9)
            --FrameRegisterNoFocus(GlobalButton[i].skill_panel_button)
            --FrameRegisterClick(GlobalButton[i].skill_panel_button, "ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp")


            GlobalButton[i].inventory_panel_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0.03, 0.03, GlobalButton[i].skill_panel_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.01, 0., GAME_UI)
            CreateTooltip(LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_DESCRIPTION, GlobalButton[i].inventory_panel_button, 0.14, 0.06)
            BlzFrameSetVisible(GlobalButton[i].inventory_panel_button, false)
            BlzTriggerRegisterFrameEvent(ClickTrigger, GlobalButton[i].inventory_panel_button, FRAMEEVENT_CONTROL_CLICK)
            CreateSimpleChargesText(GlobalButton[i].inventory_panel_button, "TAB", 0.9, 0.7, 0.008)
            --FrameRegisterNoFocus(GlobalButton[i].inventory_panel_button)
            --FrameRegisterClick(GlobalButton[i].inventory_panel_button, "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp")

        end


        TriggerAddAction(GUIManagerHotkeyTrigger, function()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local key = BlzGetTriggerPlayerKey()

                if key == OSKEY_TAB then
                    BlzFrameClick(GlobalButton[player].inventory_panel_button)
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    --SetUIState(player, INV_PANEL, not FrameState[player][INV_PANEL])
                elseif key == OSKEY_C then
                    BlzFrameClick(GlobalButton[player].char_panel_button)
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    --SetUIState(player, CHAR_PANEL, not FrameState[player][CHAR_PANEL])
                elseif key == OSKEY_B then
                    BlzFrameClick(GlobalButton[player].skill_panel_button)
                    PlayLocalSound("Sound\\Interface\\BigButtonClick.wav", player-1)
                    --SetUIState(player, SKILL_PANEL, not FrameState[player][SKILL_PANEL])
                elseif key == OSKEY_ESCAPE then
                    if #PlayerUIQueue[player] > 0 then
                        PlayLocalSound("Sound\\Interface\\Click.wav", player-1)
                        local ui_type = PlayerUIQueue[player][#PlayerUIQueue[player]]
                        SetUIState(player, ui_type, false)
                        RemoveUIFromQueue(player, ui_type)
                    end
                end

        end)




        TriggerAddAction(ClickTrigger, function()
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
                    end
                end

            frame = nil
        end)

        TeleporterInit()

    end

end