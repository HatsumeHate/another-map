---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 25.08.2021 22:30
---
do


    PrivateChestFrame = nil
    local ClickTrigger; local EnterTrigger; local LeaveTrigger
    local DoubleClickTimer
    local PlayerMovingItem
    local BackupButtonData



    ---@param texture string
    ---@param size_x real
    ---@param size_y real
    ---@param relative_frame framehandle
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent_frame framehandle
    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
        local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", new_Frame, "", 0)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)

            ButtonList[new_Frame] = {
                item = nil,
                button = new_Frame,
                image = new_FrameImage,
                original_texture = texture,
                charges_frame = new_FrameCharges,
                charges_text_frame = new_FrameChargesText,
                charges_frame_state = false,
            }

            FrameRegisterNoFocus(new_Frame)
            FrameRegisterClick(new_Frame, texture)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
            BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)

            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, new_FrameImage, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
            BlzFrameSetSize(new_FrameCharges, 0.012, 0.012)
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
            BlzFrameSetPoint(new_FrameChargesText, FRAMEPOINT_CENTER, new_FrameCharges, FRAMEPOINT_CENTER, 0.,0.)
            BlzFrameSetVisible(new_FrameCharges, false)
            BlzFrameSetText(new_FrameChargesText, "")

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


     function RemovePrivateChestSelectionFrames(player)

            if PlayerMovingItem[player].state then
                PlayerMovingItem[player].state = false

                if PlayerMovingItem[player].selected_frame and ButtonList[PlayerMovingItem[player].selected_frame].button_state then
                    if GetLocalPlayer() == Player(player - 1) then
                        BlzFrameSetVisible(ButtonList[PlayerMovingItem[player].selected_frame].sprite, true)
                    end
                end

                PlayerMovingItem[player].selected_frame = nil

                if GetLocalPlayer() == Player(player - 1) then
                    BlzFrameSetVisible(PlayerMovingItem[player].frame, false)
                    BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, false)
                end

            end

    end


    local function CreateSelectionFrames(player)
        local button = GetButtonData(PrivateChestFrame[player].slots[40])

            PlayerMovingItem[player] = {
                frame = nil,
                selector_frame = nil,
                selected_frame = nil,
            }

            PlayerMovingItem[player].selector_frame = BlzCreateFrameByType("SPRITE", "justAName", button.image, "WarCraftIIILogo", 0)
            BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, button.image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
            BlzFrameSetSize(PlayerMovingItem[player].selector_frame, 1., 1.)
            BlzFrameSetScale(PlayerMovingItem[player].selector_frame, 1.)
            PlayerMovingItem[player].frame = BlzCreateFrameByType("BACKDROP", "selection frame", PlayerMovingItem[player].selector_frame, "", 0)
            PlayerMovingItem[player].state = false

                if GetLocalPlayer() == Player(player - 1) then
                    BlzFrameSetVisible(PlayerMovingItem[player].frame, false)
                    BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, false)
                end

    end

    local function StartSelectionMode(player, h)
        local button = GetButtonData(h)
        local item_data = GetItemData(button.item)

            PlayerMovingItem[player].state = true
            PlayerMovingItem[player].selected_frame = h
            BlzFrameClearAllPoints(PlayerMovingItem[player].selector_frame)

            if GetLocalPlayer() == Player(player - 1) then
                BlzFrameSetVisible(PlayerMovingItem[player].frame, true)
                BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, true)
            end

            BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, button.image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)

            BlzFrameClearAllPoints(PlayerMovingItem[player].frame)
            BlzFrameSetTexture(PlayerMovingItem[player].frame, item_data.frame_texture, 0, true)
            BlzFrameSetAllPoints(PlayerMovingItem[player].frame, button.image)

            BlzFrameSetSize(PlayerMovingItem[player].frame, 0.041, 0.041)
            BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter4.mdx", 0)

            BlzFrameSetAlpha(PlayerMovingItem[player].frame, 175)
            RemoveTooltip(player)
    end


    function UpdatePrivateChestWindow(player)
         for i = 1, 40 do
                local button = ButtonList[PrivateChestFrame[player].slots[i]]
                if button.item then
                    local item_data = GetItemData(button.item)
                    BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                    FrameChangeTexture(button.button, item_data.frame_texture)

                        if GetItemType(button.item) == ITEM_TYPE_CHARGED then

                            if GetItemCharges(button.item) <= 0 then

                                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                                FrameChangeTexture(button.button, button.original_texture)
                                if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.charges_frame, false) end
                                button.charges_frame_state = false
                                RemoveCustomItem(button.item)
                                button.item = nil

                            else
                                button.charges_frame_state = true
                                if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.charges_frame, true) end
                                BlzFrameSetText(button.charges_text_frame, R2I(GetItemCharges(button.item)))
                            end

                        elseif button.charges_frame_state then
                            button.charges_frame_state = false
                            if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.charges_frame, false) end
                        end

                else
                    BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                    FrameChangeTexture(button.button, button.original_texture)

                    if button.charges_frame_state then
                        button.charges_frame_state = false
                        if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.charges_frame, false) end
                    end

                    BlzFrameSetText(button.charges_text_frame, "")
                end
            end

    end


    ---@param itemid integer
    ---@param player number
    function GetSameItemPrivateChestSlot(player, itemid)
        for i = 1, 40 do
            local button = GetButtonData(PrivateChestFrame[player].slots[i])
            if button.item and GetItemTypeId(button.item) == itemid then
                return button.item
            end
        end
        return nil
    end


    ---@param itemid integer
    ---@param player number
    function IsPlayerPrivateChestHasItemId(player, itemid)
        for i = 1, 40 do
            local button = GetButtonData(PrivateChestFrame[player].slots[i])
            if button.item and GetItemTypeId(button.item) == itemid then
                return true
            end
        end
        return false
    end

    local function GetFirstFreePrivateChestButton(player)
        for i = 1, 40 do

            if ButtonList[PrivateChestFrame[player].slots[i]].item == nil then
                return ButtonList[PrivateChestFrame[player].slots[i]]
            end

        end
        return nil
    end


    ---@param player integer
    ---@param item item
    function DropItemFromPrivateChest(player, item)
        local button

            for i = 1, 40 do
                button = ButtonList[PrivateChestFrame[player].slots[i]]

                    if button.item == item then

                        local item_data = GetItemData(item)
                        if item_data.soundpack then PlayLocalSound(item_data.soundpack.drop, player - 1, 120) end
                        button.item = nil
                        UpdatePrivateChestWindow(player)

                        break
                    end

            end
    end

    ---@param item item
    ---@param player integer
    function AddToPrivateChest(player, item)

        if GetItemData(item) == nil then return false end

        local item_data = GetItemData(item)

        if CountFreePrivateChestSlots(player) <= 0 and GetItemType(item) ~= ITEM_TYPE_CHARGED then
            Feedback_InventoryNoSpace(player)
            return false
        elseif GetItemType(item) == ITEM_TYPE_CHARGED and not IsPlayerPrivateChestHasItemId(player, GetItemTypeId(item)) and CountFreePrivateChestSlots(player) <= 0 then
            Feedback_InventoryNoSpace(player)
            return false
        end


            if GetItemType(item) == ITEM_TYPE_CHARGED then
                local inv_item = GetSameItemPrivateChestSlot(player, GetItemTypeId(item))

                    if inv_item ~= nil then
                        SetItemCharges(inv_item, GetItemCharges(item) + GetItemCharges(inv_item))
                        RemoveCustomItem(item)
                        UpdatePrivateChestWindow(player)
                        if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                        return true
                    else
                        local free_slot = GetFirstFreePrivateChestButton(player)

                            if free_slot ~= nil then
                                free_slot.item = item
                                UpdatePrivateChestWindow(player)
                                if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                                return true
                            end

                    end

            else
                local free_slot = GetFirstFreePrivateChestButton(player)

                    if free_slot ~= nil then
                        free_slot.item = item
                        UpdatePrivateChestWindow(player)
                        if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                        return true
                    end

            end


        return false
    end


    function CountFreePrivateChestSlots(player)
        local count = 0

            for i = 1, 32 do
                if PrivateChestFrame[player].slots[i] ~= nil then
                    if ButtonList[PrivateChestFrame[player].slots[i]].item == nil then
                        count = count + 1
                    end
                end
            end

        return count
    end


    function ReloadPrivateChestFrames()
        for player = 1, 6 do
            if PlayerHero[player] then
                local new_Frame
                local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

                    BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.11, -0.025)
                    BlzFrameSetSize(main_frame, 0.27, 0.43)

                    new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
                    BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
                    PrivateChestFrame[player].portrait = new_Frame

                    new_Frame = BlzCreateFrameByType("TEXT", "shop name", PrivateChestFrame[player].portrait, "", 0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, PrivateChestFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
                    BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                    BlzFrameSetScale(new_Frame, 1.35)
                    PrivateChestFrame[player].name = new_Frame


                    new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
                    BlzFrameSetSize(new_Frame, 0.28, 0.355)
                    PrivateChestFrame[player].border = new_Frame

                    PrivateChestFrame[player].slots[1] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, new_Frame)
                    local new_button_data = GetButtonData(PrivateChestFrame[player].slots[1])
                    new_button_data.item = BackupButtonData[player][1].item or nil
                    BackupButtonData[player][1] = new_button_data

                    for i = 2, 5 do
                        PrivateChestFrame[player].slots[i] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, PrivateChestFrame[player].slots[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., new_Frame)
                        new_button_data = GetButtonData(PrivateChestFrame[player].slots[i])
                        new_button_data.item = BackupButtonData[player][i].item or nil
                        BackupButtonData[player][i] = new_button_data
                    end

                    for row = 2, 8 do
                        for i = 1, 5 do
                            local slot = i + ((row - 1) * 5)
                            PrivateChestFrame[player].slots[slot] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, PrivateChestFrame[player].slots[slot - 5], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., new_Frame)
                            new_button_data = GetButtonData(PrivateChestFrame[player].slots[slot])
                            new_button_data.item = BackupButtonData[player][slot].item or nil
                            BackupButtonData[player][slot] = new_button_data
                        end
                    end

                UpdatePrivateChestWindow(player)


                PrivateChestFrame[player].shift_state = false

                CreateSelectionFrames(player)
                PrivateChestFrame[player].tooltip = NewTooltip(PrivateChestFrame[player].slots[40])
                local tooltip = GetTooltip(PrivateChestFrame[player].tooltip)
                tooltip.is_sell_penalty = true

                PrivateChestFrame[player].alternate_tooltip = NewTooltip(PrivateChestFrame[player].slots[40])
                local tooltip = GetTooltip(PrivateChestFrame[player].alternate_tooltip)
                tooltip.is_sell_penalty = true

                PrivateChestFrame[player].main_frame = main_frame
                BlzFrameSetVisible(PrivateChestFrame[player].main_frame, false)
                BlzFrameSetTexture(PrivateChestFrame[player].portrait, "UI\\BTNTreasure Chest.blp", 0, true)
                BlzFrameSetText(PrivateChestFrame[player].name, GetUnitName(gg_unit_n01Y_0018))
            end
        end
    end


    ---@param player integer
    function DrawPrivateChestFrames(player)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            PrivateChestFrame[player] = {}
            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.11, -0.025)
            BlzFrameSetSize(main_frame, 0.27, 0.43)

            new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
            BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
            PrivateChestFrame[player].portrait = new_Frame

            new_Frame = BlzCreateFrameByType("TEXT", "shop name", PrivateChestFrame[player].portrait, "", 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, PrivateChestFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
            BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetScale(new_Frame, 1.35)
            PrivateChestFrame[player].name = new_Frame


            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            --BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, PrivateChestFrame[player].portrait, FRAMEPOINT_ЕЩЗLEFT, 0.015, 0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
            BlzFrameSetSize(new_Frame, 0.28, 0.355)
            -- РЯДЫ - 0.035 5 КОЛОННЫ - 0.045 8
            PrivateChestFrame[player].border = new_Frame


            PrivateChestFrame[player].slots = {}
            BackupButtonData[player] = {}

            PrivateChestFrame[player].slots[1] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, new_Frame)
            BackupButtonData[player][1] = GetButtonData(PrivateChestFrame[player].slots[1])


            for i = 2, 5 do
                PrivateChestFrame[player].slots[i] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, PrivateChestFrame[player].slots[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., new_Frame)
                BackupButtonData[player][i] = GetButtonData(PrivateChestFrame[player].slots[i])
            end

            for row = 2, 8 do
                for i = 1, 5 do
                    local slot = i + ((row - 1) * 5)
                    PrivateChestFrame[player].slots[slot] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, PrivateChestFrame[player].slots[slot - 5], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., new_Frame)
                    BackupButtonData[player][slot] = GetButtonData(PrivateChestFrame[player].slots[slot])
                end
            end


        PrivateChestFrame[player].shift_state = false
        local actual_player = Player(player-1)
        local comparison_trigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 1, true)
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 0, false)
        TriggerAddAction(comparison_trigger, function()

            if PrivateChestFrame[player].in_focus then
                if BlzGetTriggerPlayerIsKeyDown() and not PrivateChestFrame[player].shift_state then
                    PrivateChestFrame[player].shift_state = true
                    AltState[player] = false
                    ShowAlternateChestTooltip(player)
                elseif not BlzGetTriggerPlayerIsKeyDown() and PrivateChestFrame[player].shift_state then
                    RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                    RemoveSpecificTooltip(PrivateChestFrame[player].alternate_tooltip)
                    PrivateChestFrame[player].shift_state = false
                end
            else
                PrivateChestFrame[player].shift_state = false
            end


        end)


        local AltStateTrigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(AltStateTrigger, actual_player, OSKEY_LALT, 5, true)
        TriggerAddAction(AltStateTrigger, function()

            if PrivateChestFrame[player].in_focus then
                if AltState[player] then AltState[player] = false
                else AltState[player] = true end
                RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                RemoveSpecificTooltip(PrivateChestFrame[player].alternate_tooltip)
                ShowAlternateChestTooltip(player)
            end

        end)



        local mouse_state = false
        local DragTimer = CreateTimer()
        local MouseDownTrigger = CreateTrigger()
        local MouseUpTrigger = CreateTrigger()
        TriggerRegisterPlayerEvent(MouseDownTrigger, actual_player, EVENT_PLAYER_MOUSE_DOWN)
        TriggerAddAction(MouseDownTrigger, function()

            if PrivateChestFrame[player].state and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                  if PrivateChestFrame[player].in_focus and PrivateChestFrame[player].in_focus.item then
                        mouse_state = true
                        local in_focus = PrivateChestFrame[player].in_focus
                        TimerStart(DragTimer, 0.2, false, function()
                            if PrivateChestFrame[player].in_focus and in_focus == PrivateChestFrame[player].in_focus and mouse_state and PrivateChestFrame[player].in_focus.item then
                                DestroyContextMenu(player)
                                StartSelectionMode(player, PrivateChestFrame[player].in_focus.button)
                            end
                        end)
                  else
                      mouse_state = false
                      TimerStart(DragTimer, 0., false, nil)
                  end
            end

        end)

        TriggerRegisterPlayerEvent(MouseUpTrigger, actual_player, EVENT_PLAYER_MOUSE_UP)
        TriggerAddAction(MouseUpTrigger, function()
            if mouse_state and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                mouse_state = false
                TimerStart(DragTimer, 0., false, nil)
            end
        end)



        CreateSelectionFrames(player)
        PrivateChestFrame[player].tooltip = NewTooltip(PrivateChestFrame[player].slots[40])
        local tooltip = GetTooltip(PrivateChestFrame[player].tooltip)
        tooltip.is_sell_penalty = true

        PrivateChestFrame[player].alternate_tooltip = NewTooltip(PrivateChestFrame[player].slots[40])
        local tooltip = GetTooltip(PrivateChestFrame[player].alternate_tooltip)
        tooltip.is_sell_penalty = true

        PrivateChestFrame[player].main_frame = main_frame
        BlzFrameSetVisible(PrivateChestFrame[player].main_frame, false)

    end


    function ShowAlternateChestTooltip(player)

        if IsTooltipActive(player) then

            local item_to_compare = GetItemToCompare(PrivateChestFrame[player].in_focus.item, player)
                if item_to_compare then
                    local proper_tooltip = PrivateChestFrame[player].tooltip
                    local proper_alternate_tooltip = PrivateChestFrame[player].alternate_tooltip

                    if PlayerInventoryFrameState[player] then
                        proper_tooltip = InventoryTooltip[player]
                        proper_alternate_tooltip = InventoryAlternateTooltip[player]
                    end

                    ShowItemTooltip(item_to_compare, proper_alternate_tooltip, PrivateChestFrame[player].in_focus, player, FRAMEPOINT_RIGHT, GetTooltip(proper_alternate_tooltip), true, PrivateChestFrame[player].in_focus.item)
                    BlzFrameClearAllPoints(proper_alternate_tooltip)
                    BlzFrameSetPoint(proper_alternate_tooltip, FRAMEPOINT_LEFT, proper_tooltip, FRAMEPOINT_RIGHT, 0., 0.)
                end
        end

    end



    function InitPrivateChest()

        PrivateChestFrame = {}
        BackupButtonData = {}

        local trg = CreateTrigger()
        TriggerRegisterUnitInRangeSimple(trg, 175., gg_unit_n01Y_0018)
        TriggerAddAction(trg, function()
            local id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            local player = id + 1

                if id <= 5 and IsAHero(GetTriggerUnit()) then
                    local hero = GetTriggerUnit()

                        PrivateChestFrame[player].state = true

                        if GetLocalPlayer() == Player(id) then
                            BlzFrameSetVisible(PrivateChestFrame[player].main_frame, true)
                            SetUnitAnimation(gg_unit_n01Y_0018, "Morph")
                        end

                        local timer = CreateTimer()
                            TimerStart(timer, 0.1, true, function()
                                if not IsUnitInRange(hero, gg_unit_n01Y_0018, 176.) then
                                    DestroyContextMenu(player)
                                    RemoveTooltip(player)
                                    RemovePrivateChestSelectionFrames(player)
                                    PrivateChestFrame[player].state = false

                                        if GetLocalPlayer() == Player(id) then
                                            BlzFrameSetVisible(PrivateChestFrame[player].main_frame, false)
                                            SetUnitAnimation(gg_unit_n01Y_0018, "Morph Alternate")
                                        end

                                    DestroyTimer(GetExpiredTimer())
                                end

                            end)
                end

        end)


        LeaveTrigger = CreateTrigger()
        TriggerAddAction(LeaveTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1

                if button.item then
                    PrivateChestFrame[player].in_focus = nil
                    RemoveTooltip(player)
                end

        end)

        EnterTrigger = CreateTrigger()
        TriggerAddAction(EnterTrigger, function()
            local frame = BlzGetTriggerFrame()
            local button = GetButtonData(frame)
            local player = GetPlayerId(GetTriggerPlayer()) + 1

                if PlayerMovingItem[player].state then
                    BlzFrameSetAllPoints(PlayerMovingItem[player].frame, button.image)
                    BlzFrameSetSize(PlayerMovingItem[player].frame, 0.0415, 0.0415)
                elseif button.item then
                    PrivateChestFrame[player].in_focus = ButtonList[frame]
                    local proper_tooltip = PrivateChestFrame[player].tooltip

                    if PlayerInventoryFrameState[player] then
                        proper_tooltip = InventoryTooltip[player]
                    end

                    ShowItemTooltip(button.item, proper_tooltip, button, player, FRAMEPOINT_RIGHT, GetTooltip(InventoryTooltip[player]))

                    if PrivateChestFrame[player].shift_state then
                        RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                        RemoveSpecificTooltip(PrivateChestFrame[player].alternate_tooltip)
                        ShowAlternateChestTooltip(player)
                    end

                else
                    PrivateChestFrame[player].in_focus = nil
                    RemoveTooltip(player)
                end

        end)


        DoubleClickTimer = { [1] = { timer = CreateTimer() }, [2] = { timer = CreateTimer() }, [3] = { timer = CreateTimer() }, [4] = { timer = CreateTimer() }, [5] = { timer = CreateTimer() }, [6] = { timer = CreateTimer() } }

        ClickTrigger = CreateTrigger()
        TriggerAddAction(ClickTrigger, function()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local frame = BlzGetTriggerFrame()
            local button = GetButtonData(frame)
            local item_data = GetItemData(button.item) or nil


            RemoveSelectionFrames(player)
            DestroyContextMenu(player)

                if PlayerMovingItem[player].state then
                    local item = ButtonList[PlayerMovingItem[player].selected_frame].item
                    local moved_item_data = GetItemData(item)

                        if button.item == nil then
                            button.item = item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = nil
                        else
                            ButtonList[PlayerMovingItem[player].selected_frame].item = button.item
                            button.item = item
                        end

                    if moved_item_data.soundpack and moved_item_data.soundpack.drop then PlayLocalSound(moved_item_data.soundpack.drop, player - 1) end
                    RemovePrivateChestSelectionFrames(player)
                    UpdatePrivateChestWindow(player)
                    PrivateChestFrame[player].in_focus = ButtonList[frame]
                elseif TimerGetRemaining(DoubleClickTimer[player].timer) > 0. then
                    --print("double a")
                    if item_data then
                        RemoveTooltip(player)
                        DestroyContextMenu(player)

                        if AddToInventory(player, button.item) then
                            if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                            button.item = nil
                            UpdatePrivateChestWindow(player)
                        else
                            Feedback_InventoryNoSpace(player)
                        end

                        TimerStart(DoubleClickTimer[player].timer, 0., false, nil)
                    end
                else

                    TimerStart(DoubleClickTimer[player].timer, 0.25, false, function()

                        if item_data then
                            local context_parent_frame = PrivateChestFrame[player].slots[40]

                            if PlayerInventoryFrameState[player] then
                                context_parent_frame = InventorySlots[player][45]
                            end

                            CreatePlayerContextMenu(player, button.button, FRAMEPOINT_RIGHT, context_parent_frame)

                            AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_FROM_STASH, function()
                                if AddToInventory(player, button.item) then
                                    if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                                    button.item = nil
                                    UpdatePrivateChestWindow(player)
                                else
                                    Feedback_InventoryNoSpace(player)
                                end
                            end)

                            AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_MOVE, function() StartSelectionMode(player, frame) end)
                        end

                    end)
                end


        end)


        PlayerMovingItem = {}

        for i = 1, 6 do
            DrawPrivateChestFrames(i)
            BlzFrameSetTexture(PrivateChestFrame[i].portrait, "UI\\BTNTreasure Chest.blp", 0, true)
            BlzFrameSetText(PrivateChestFrame[i].name, GetUnitName(gg_unit_n01Y_0018))
        end


        InitPrivateStash()

    end

end