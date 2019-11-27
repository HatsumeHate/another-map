do



    PlayerInventoryFrame = {}
    ButtonList = {}
    InventorySlots = {}
    InventoryTriggerButton = nil
    INV_SLOT = 0
    DoubleClickTrigger = CreateTrigger()



    local function GetFirstFreeSlotButton()
        for i = 1, 32 do
            local h = GetHandleId(InventorySlots[i])

            if ButtonList[h].item == nil then
                return ButtonList[h]
            end

        end
        return 0
    end


    local DoubleClickTimer = { [1] = CreateTimer() }


    local function ReplaceFromTo(slot_from, slot_to, texture)
            slot_to.item = slot_from.item
            slot_from.item = nil
            BlzFrameSetTexture(slot_from.image, slot_from.original_texture, 0, true)
            BlzFrameSetTexture(slot_to.image, texture, 0, true)
    end

    local function InventorySlot_Doubleclicked()
        local id = GetPlayerId(GetTriggerPlayer()) + 1

        if TimerGetRemaining(DoubleClickTimer[id]) > 0. then
            local h = GetHandleId(BlzGetTriggerFrame())

            if ButtonList[h].item ~= nil then
                local item_data = GetItemData(ButtonList[h].item)
                    if ButtonList[h].button_type == INV_SLOT then
                        if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then
                            EquipItem(gg_unit_HBRB_0005, ButtonList[h].item, true)
                            ReplaceFromTo(ButtonList[h], ButtonList[GetHandleId(InventorySlots[33])], item_data.frame_texture)
                        end
                    elseif ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
                        EquipItem(gg_unit_HBRB_0005, ButtonList[h].item, false)
                        local free_slot = GetFirstFreeSlotButton()
                        ReplaceFromTo(ButtonList[h], free_slot, item_data.frame_texture)
                    end



            end
        else
            TimerStart(DoubleClickTimer[id], 0.25, false, nil)
        end

    end

    TriggerAddAction(DoubleClickTrigger, InventorySlot_Doubleclicked)




    function AddToInventory(player, item)
        for i = 1, 32 do
            if InventorySlots[i] ~= nil then
                local h = GetHandleId(InventorySlots[i])

                if ButtonList[h].item == nil then
                    local item_data = GetItemData(item)
                    ButtonList[h].item = item
                    BlzFrameSetTexture(ButtonList[h].image, item_data.frame_texture, 0, true)
                    SetItemVisible(item, false)
                    break
                end

            end
        end
    end


    function CountFreeBagSlots()
        local count = 0

        for i = 1, 41 do
            if InventorySlots[i] ~= nil then
                if ButtonList[GetHandleId(InventorySlots[i])].item == nil then
                    count = count + 1
                end
            end
        end

        return count
    end


    ---@param button_type number
    ---@param texture string
    ---@param size_x real
    ---@param size_y real
    ---@param relative_frame framehandle
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent_frame framehandle
    local function NewButton(button_type, texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
        
            ButtonList[GetHandleId(new_Frame)] = { button_type = button_type, item = nil, button = new_Frame, image = new_FrameImage, original_texture = texture }
            FrameRegisterNoFocus(new_Frame)

            BlzTriggerRegisterFrameEvent(DoubleClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    local function DrawInventoryFrames(player)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)


        BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPRIGHT, GAME_UI, FRAMEPOINT_TOPRIGHT, 0., -0.05)
        BlzFrameSetSize(main_frame, 0.4, 0.38)
        PlayerInventoryFrame[player] = main_frame


        -- slots box
        local slots_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
        BlzFrameSetPoint(slots_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
        BlzFrameSetSize(slots_Frame, 0.36, 0.14)

        -- inv box
        local inv_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
        BlzFrameSetPoint(inv_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetSize(inv_Frame, 0.36, 0.195)


        -- inventory slots
        InventorySlots[1] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, inv_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, inv_Frame)

        for i = 2, 8 do
            InventorySlots[i] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., inv_Frame)
        end

        for row = 2, 4 do
            for i = 1, 8 do
                local slot = i + ((row - 1) * 8)
                InventorySlots[slot] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[slot - 8], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., inv_Frame)
            end
        end


        -- equip slots
        InventorySlots[33] = NewButton(WEAPON_POINT, "GUI\\BTNWeapon_Slot.blp", 0.044, 0.044, slots_Frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.03, 0.03, slots_Frame)
        InventorySlots[34] = NewButton(OFFHAND_POINT, "GUI\\BTNWeapon_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.03, 0.03, slots_Frame)

        InventorySlots[35] = NewButton(HEAD_POINT, "GUI\\BTNHead_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.015, slots_Frame)
        InventorySlots[36] = NewButton(CHEST_POINT, "GUI\\BTNChest_Slot.blp", 0.043, 0.043, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., 0., slots_Frame)
        InventorySlots[37] = NewButton(HANDS_POINT, "GUI\\BTNHands_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, -0.058, 0., slots_Frame)
        InventorySlots[38] = NewButton(LEGS_POINT, "GUI\\BTNBoots_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_BOTTOM, 0., 0.015, slots_Frame)


        new_Frame = NewButton(NECKLACE_POINT, "GUI\\BTNNecklace_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0.064, 0.012, slots_Frame)
        InventorySlots[39] = new_Frame

        InventorySlots[40] = NewButton(RING_1_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, new_Frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMLEFT, 0.016, 0., slots_Frame)
        InventorySlots[41] = NewButton(RING_2_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMRIGHT, -0.016, 0., slots_Frame)



        BlzFrameSetVisible(main_frame, false)

    end




    function InventoryInit()
        DrawInventoryFrames(1)



        --HeroSelectorButton
        --ScriptDialogButton



        --TODO everything else. optimize it


        InventoryTriggerButton = BlzCreateFrame('ScriptDialogButton', GAME_UI, 0, 0)
        local inv_button_backdrop = BlzCreateFrameByType("BACKDROP", "inventory button backdrop", InventoryTriggerButton, "", 0)
        local inv_button_tooltip = BlzCreateFrame("BoxedText", inv_button_backdrop, 150, 0)


        BlzFrameSetSize(InventoryTriggerButton, 0.03, 0.03)
        BlzFrameSetPoint(InventoryTriggerButton, FRAMEPOINT_LEFT, CharButton, FRAMEPOINT_RIGHT, 0.01, 0.)
        BlzFrameSetAllPoints(inv_button_backdrop, InventoryTriggerButton)
        BlzFrameSetTexture(inv_button_backdrop, "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0, true)

        BlzFrameSetTooltip(InventoryTriggerButton, inv_button_tooltip)
        BlzFrameSetPoint(inv_button_tooltip, FRAMEPOINT_TOPLEFT, inv_button_backdrop, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetSize(inv_button_tooltip, 0.11, 0.05)
        BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), "Содержит все ваши вещи и экипировку")--BoxedText has a child showing the text, set that childs Text.
        BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), "Инвентарь")--BoxedText has a child showing the Title-text, set that childs Text.
        FrameRegisterNoFocus(InventoryTriggerButton)


        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, InventoryTriggerButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, function()

            BlzFrameSetVisible(PlayerInventoryFrame[GetPlayerId(GetTriggerPlayer()) + 1], not BlzFrameIsVisible(PlayerInventoryFrame[GetPlayerId(GetTriggerPlayer()) + 1]))

        end)

    end

end