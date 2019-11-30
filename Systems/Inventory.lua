do

    PlayerInventoryFrame = {}
    PlayerInventoryWindow = {}
    ButtonList = {}
    InventorySlots = {}
    InventoryOwner = {}
    InventoryTriggerButton = nil
    INV_SLOT = 0
    local ClickTrigger = CreateTrigger()




    local function GetFirstFreeSlotButton()
        for i = 1, 32 do
            local h = GetHandleId(InventorySlots[i])

            if ButtonList[h].item == nil then
                return ButtonList[h]
            end

        end
        return nil
    end


    local DoubleClickTimer = { [1] = CreateTimer() }




    local UNIT_POINT_LIST = {
        [WEAPON_POINT]    = 33,
        [OFFHAND_POINT]   = 34,
        [HEAD_POINT]      = 35,
        [CHEST_POINT]     = 36,
        [LEGS_POINT]      = 38,
        [HANDS_POINT]     = 37,
        [RING_1_POINT]    = 40,
        [RING_2_POINT]    = 41,
        [NECKLACE_POINT]  = 39
    }

    local function UpdateEquipPointsWindow(player)
        local unit_data = GetUnitData(InventoryOwner[player])

        for i = WEAPON_POINT, NECKLACE_POINT do
            local button = ButtonList[GetHandleId(InventorySlots[UNIT_POINT_LIST[i]])]

            if unit_data.equip_point[i] ~= nil and unit_data.equip_point[i].SUBTYPE ~= FIST_WEAPON then
                local item_data = GetItemData(unit_data.equip_point[i].item)
                button.item = item_data.item
                BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
            else
                button.item = nil
                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
            end

        end

    end

    local function UpdateInventoryWindow(player)
        for i = 1, 32 do
            local button = ButtonList[GetHandleId(InventorySlots[i])]
            if button.item ~= nil then
                local item_data = GetItemData(button.item)
                BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
            else
                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
            end
        end
    end


    --======================================================================
    -- CONTEXT MENU   ======================================================
    local ContextFrame = {}

    local function DestroyContextMenu(player)
        if ContextFrame[player] ~= nil then
            for i = 1, #ContextFrame[player].frames do
                BlzDestroyFrame(ContextFrame[player].frames[i])
            end
            BlzDestroyFrame(ContextFrame[player].backdrop)
            ContextFrame[player].frames = nil
            ContextFrame[player] = nil
        end
    end



    local function AddContextOption(player, text, result)
        local frame = BlzCreateFrame('ScriptDialogButton', PlayerInventoryFrame[player], 0, 0)
        local position = #ContextFrame[player].frames + 1

        local textframe = BlzGetFrameByName("ScriptDialogButtonText", 0)
        BlzFrameSetText(textframe, text)
        BlzFrameSetScale(textframe, 0.8)
        BlzFrameSetTextAlignment(textframe, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)


        if position == 1 or position == nil then
            BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, ContextFrame[player].originframe, FRAMEPOINT_RIGHT, 0., 0.)
            position = 1
        else
            BlzFrameSetPoint(frame, FRAMEPOINT_TOP, ContextFrame[player].frames[position - 1], FRAMEPOINT_BOTTOM, 0., 0.004)
        end

        BlzFrameSetSize(frame, 0.074, 0.025)

        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, frame, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, function()
            result()
            DestroyContextMenu(player)
            DestroyTrigger(GetTriggeringTrigger())
        end)

        ContextFrame[player].frames[position] = frame

        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOP, ContextFrame[player].frames[1], FRAMEPOINT_TOP, 0., 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOPLEFT, ContextFrame[player].frames[1], FRAMEPOINT_TOPLEFT, -0.003, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOPRIGHT, ContextFrame[player].frames[1], FRAMEPOINT_TOPRIGHT, 0.003, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, -0.003, -0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, -0.03, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOM, frame, FRAMEPOINT_BOTTOM, 0., -0.003)

        FrameRegisterNoFocus(frame)

    end



    local function CreatePlayerContextMenu(player, originframe)
        DestroyContextMenu(player)
        ContextFrame[player] = {}
        ContextFrame[player].frames = {}
        ContextFrame[player].backdrop = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', ButtonList[GetHandleId(InventorySlots[32])].image, 0, 0)
        ContextFrame[player].originframe = originframe

        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_LEFT, originframe, FRAMEPOINT_RIGHT, 0.,0.)
        RemoveTooltip(player)
    end



    --======================================================================
    -- TOOLTIP        ======================================================
    local PlayerTooltip = {}


    local function LockWidth(frame, min, max)
        local width

            if BlzFrameGetWidth(frame) < min then
                width = min
            elseif BlzFrameGetWidth(frame) > max  then
                width = max
            end

        BlzFrameSetSize(frame, width, 0.)
    end


    local function ShowTooltip(player, h)
        local item_data = GetItemData(ButtonList[h].item)
        local width = 0.1
        local frame_number = 1
        
        if ContextFrame[player] ~= nil then return end
        RemoveTooltip(player)

        PlayerTooltip[player] = {}
        PlayerTooltip[player].frames = {}

        PlayerTooltip[player].backdrop = BlzCreateFrame("BoxedText", ButtonList[GetHandleId(InventorySlots[32])].image, 150, 0)



        local areatext = GetItemSubTypeName(item_data.SUBTYPE) .. "|n" .. "|n"

        if item_data.TYPE == ITEM_TYPE_WEAPON then
            areatext = areatext
                    .. "Урон: " .. R2I(item_data.DAMAGE * item_data.DISPERSION[1]) .. "-" .. R2I(item_data.DAMAGE * item_data.DISPERSION[2]) .. "|n"
                    .. "Тип урона: " .. GetItemAttributeName(item_data.ATTRIBUTE)
        elseif item_data.TYPE == ITEM_TYPE_ARMOR then
            areatext = areatext
                    .. "Защита: " .. item_data.DEFENCE
        elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
            areatext = areatext
                    .. "Подавление: " .. item_data.SUPPRESSION
        elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
            areatext = areatext
                    .. "Защита: " .. item_data.DEFENCE
        end


        local bonus_text

        if item_data.BONUS ~= nil and #item_data.BONUS > 0 then
            bonus_text = "|n" .. "Дополнительные свойства:" .. "|n"
            for i = 1, #item_data.BONUS do
                local value
                    if item_data.BONUS[i].METHOD == MULTIPLY_BONUS then
                        value = R2I((item_data.BONUS[i].VALUE * 100.) - 100.) .. "%%"
                    else
                        value = item_data.BONUS[i].VALUE
                    end
                bonus_text = bonus_text .. GetParameterName(item_data.BONUS[i].PARAM) .. ": " .. value .. "|n"
            end
        end

        
        PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "name", PlayerTooltip[player].backdrop, "", 0)
        BlzFrameSetPoint(PlayerTooltip[player].frames[frame_number], FRAMEPOINT_TOPLEFT, ButtonList[h].image, FRAMEPOINT_TOPRIGHT, 0., 0.)
        BlzFrameSetText(PlayerTooltip[player].frames[frame_number], GetItemNameColorized(ButtonList[h].item))
        BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 1.3)


        frame_number = 2
        PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "item type", PlayerTooltip[player].frames[1], "", 0)
        BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetText(PlayerTooltip[player].frames[frame_number], areatext)
        BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 0.95)
        BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], BlzFrameGetWidth(PlayerTooltip[player].frames[frame_number]), 0.)


        if bonus_text ~= nil then
            frame_number = frame_number + 1
            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "item type", PlayerTooltip[player].frames[frame_number - 1], "", 0)
            BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetText(PlayerTooltip[player].frames[frame_number], bonus_text)
            BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 1.)
        end


        if item_data.MAX_SLOTS ~= nil and item_data.MAX_SLOTS > 0 then
            frame_number = frame_number + 1
            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "STONE", PlayerTooltip[player].frames[frame_number - 1], "", 0)
            BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], 0.01, 0.018)
            local stones = {}
                for i = 1, item_data.MAX_SLOTS do
                    stones[i] = BlzCreateFrameByType("BACKDROP", "STONE", PlayerTooltip[player].frames[frame_number], "", 0)
                    BlzFrameSetTexture(stones[i], "GUI\\empty stone.blp", 0, true)
                    BlzFrameSetSize(stones[i], 0.01, 0.01)
                        if i == 1 then
                            BlzFrameSetPoint(stones[i], FRAMEPOINT_CENTER, PlayerTooltip[player].frames[frame_number], FRAMEPOINT_CENTER, item_data.MAX_SLOTS*((item_data.MAX_SLOTS * 0.001) * -1.),  0.)
                        else
                            BlzFrameSetPoint(stones[i], FRAMEPOINT_LEFT, stones[i - 1], FRAMEPOINT_RIGHT, 0., 0.)
                        end
                end

            end


        for i = 1, #PlayerTooltip[player].frames do
            print(BlzFrameGetWidth(PlayerTooltip[player].frames[i]))

                if BlzFrameGetWidth(PlayerTooltip[player].frames[i]) > width then
                    width = BlzFrameGetWidth(PlayerTooltip[player].frames[i])
                    if i == 1 then width = width * 0.7 end
                end

                if i == 1 then
                    BlzFrameSetPoint(PlayerTooltip[player].frames[i], FRAMEPOINT_LEFT, ButtonList[h].image, FRAMEPOINT_RIGHT, 0.01, 0.)
                else
                    BlzFrameSetPoint(PlayerTooltip[player].frames[i], FRAMEPOINT_TOP, PlayerTooltip[player].frames[i - 1], FRAMEPOINT_BOTTOM, 0., 0.)
                end
        end


        BlzFrameSetSize(PlayerTooltip[player].frames[1], width, 0.)
        LockWidth(PlayerTooltip[player].frames[1], 0.04, 0.11)

        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOP, PlayerTooltip[player].frames[1], FRAMEPOINT_TOP, 0., 0.005)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPLEFT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPLEFT, -0.005, 0.005)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPRIGHT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPRIGHT, 0.005, 0.005)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMLEFT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMLEFT, -0.005, -0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOM, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOM, 0., -0.007)

    end


    function RemoveTooltip(player)
        if PlayerTooltip[player] ~= nil then
            for i = 1, #PlayerTooltip[player].frames do
                BlzDestroyFrame(PlayerTooltip[player].frames[i])
            end
            BlzDestroyFrame(PlayerTooltip[player].backdrop)
        end
        PlayerTooltip[player] = nil
    end



    local PlayerMovingItem = {}
    local EnterTrigger = CreateTrigger()


    local function EnterAction()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())

        if PlayerMovingItem[player] ~= nil then
            BlzFrameSetAllPoints(PlayerMovingItem[player].frame, ButtonList[h].image)
            BlzFrameSetSize(PlayerMovingItem[player].frame, 0.0415, 0.0415)
        else
            if ButtonList[h].item ~= nil then
                ShowTooltip(player, h)
            else
                RemoveTooltip(player)
            end
        end
    end


    --======================================================================
    -- SELECTOION MODE =====================================================

    local function RemoveSelectionFrames(player)
        if PlayerMovingItem[player] ~= nil then
            BlzDestroyFrame(PlayerMovingItem[player].frame)
            BlzDestroyFrame(PlayerMovingItem[player].selector_frame)
        end
        PlayerMovingItem[player] = nil
    end

    local function StartSelectionMode(player, h)
        local item_data = GetItemData(ButtonList[h].item)
        PlayerMovingItem[player] = { frame = nil, selector_frame = nil, selected_frame = h }

        PlayerMovingItem[player].selector_frame = BlzCreateFrameByType("SPRITE", "justAName", ButtonList[GetHandleId(InventorySlots[32])].image, "WarCraftIIILogo", 0)
        BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, ButtonList[h].image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetSize(PlayerMovingItem[player].selector_frame, 1., 1.)
        BlzFrameSetScale(PlayerMovingItem[player].selector_frame, 1.)
        BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter4.mdx", 0)

        PlayerMovingItem[player].frame = BlzCreateFrameByType("BACKDROP", "selection frame", PlayerMovingItem[player].selector_frame, "", 0)
        BlzFrameSetTexture(PlayerMovingItem[player].frame, item_data.frame_texture, 0, true)
        BlzFrameSetAllPoints(PlayerMovingItem[player].frame, ButtonList[h].image)
        BlzFrameSetSize(PlayerMovingItem[player].frame, 0.041, 0.041)
        BlzFrameSetAlpha(PlayerMovingItem[player].frame, 175)
        RemoveTooltip(player)
    end

    TriggerAddAction(EnterTrigger, EnterAction)


    
    local function InteractWithItemInSlot(h, id)
        local item_data = GetItemData(ButtonList[h].item)
        if ButtonList[h].button_type == INV_SLOT then
            if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then
                EquipItem(InventoryOwner[id], ButtonList[h].item, true)
                ButtonList[h].item = nil
                UpdateEquipPointsWindow(id)
                UpdateInventoryWindow(id)
            end
        elseif ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
            EquipItem(InventoryOwner[id], ButtonList[h].item, false)
            local free_slot = GetFirstFreeSlotButton()
            free_slot.item = ButtonList[h].item
            UpdateEquipPointsWindow(id)
            UpdateInventoryWindow(id)
        end
    end


    local function ForceEquip(h, player)
        if ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
            EquipItem(InventoryOwner[player], ButtonList[h].item, true)
            UpdateEquipPointsWindow(player)
            UpdateInventoryWindow(player)
        end
    end


    local function InventorySlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())

        if TimerGetRemaining(DoubleClickTimer[player]) > 0. then
            if ButtonList[h].item ~= nil then
                RemoveTooltip(player)
                DestroyContextMenu(player)
                InteractWithItemInSlot(h, player)
            end
        else
            TimerStart(DoubleClickTimer[player], 0.25, false, function()
                if ButtonList[h].item ~= nil and PlayerMovingItem[player] == nil and  ButtonList[h].button_type == INV_SLOT then
                    CreatePlayerContextMenu(player, ButtonList[h].button)

                    AddContextOption(player, "Надеть", function()
                        InteractWithItemInSlot(h, player)
                    end)

                    AddContextOption(player, "Переместить", function()
                        StartSelectionMode(player, h)
                    end)

                    AddContextOption(player, "Выкинуть", function()
                        DropFromInventory(player, ButtonList[h].item)
                    end)
                end
            end)

            if PlayerMovingItem[player] ~= nil then
                TimerStart(DoubleClickTimer[player], 0., false, nil)
                ButtonList[h].item = ButtonList[PlayerMovingItem[player].selected_frame].item
                ButtonList[PlayerMovingItem[player].selected_frame].item = nil

                if ButtonList[h].button_type == INV_SLOT then
                    UpdateInventoryWindow(player)
                else
                    ForceEquip(h, player)
                end
                RemoveSelectionFrames(player)
            elseif ButtonList[h].item ~= nil then
                if PlayerMovingItem[player] ~= nil then
                    TimerStart(DoubleClickTimer[player], 0., false, nil)
                    local item = ButtonList[PlayerMovingItem[player].h].item
                    ButtonList[PlayerMovingItem[player].h].item = ButtonList[h].item
                    ButtonList[h].item = item
                    UpdateInventoryWindow(player)
                end
            end

        end

    end

    TriggerAddAction(ClickTrigger, InventorySlot_Clicked)


    ---@param player integer
    ---@param item item
    function DropFromInventory(player, item)
        local button
        for i = 1, 32 do
            button = ButtonList[GetHandleId(InventorySlots[i])]
            if button.item == item then
                SetItemVisible(item, true)
                SetItemPosition(item, GetUnitX(PlayerHero[player]) + GetRandomReal(-55., 55.), GetUnitY(PlayerHero[player]) + GetRandomReal(-55., 55.))
                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                button.item = nil
                break
            end
        end
    end


    ---@param item item
    function AddToInventory(player, item)
        local free_slot = GetFirstFreeSlotButton()

        if free_slot ~= nil and GetItemData(item) ~= nil then
            local item_data = GetItemData(item)
            free_slot.item = item
            BlzFrameSetTexture(free_slot.image, item_data.frame_texture, 0, true)
            SetItemVisible(item, false)
        end

    end


    function CountFreeBagSlots()
        local count = 0

        for i = 1, 32 do
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

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)

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

--WarCraftIIILogo


        BlzFrameSetVisible(main_frame, false)

    end




    function InventoryInit()
        DrawInventoryFrames(1)



        --HeroSelectorButton
        --ScriptDialogButton
        InventoryOwner[1] = gg_unit_HBRB_0005


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
            local player = GetPlayerId(GetTriggerPlayer()) + 1

            BlzFrameSetVisible(PlayerInventoryFrame[player], not BlzFrameIsVisible(PlayerInventoryFrame[player]))
            RemoveTooltip(player)
            RemoveSelectionFrames(player)
            DestroyContextMenu(player)
        end)

    end

end