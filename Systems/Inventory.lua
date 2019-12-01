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
                if GetItemType(button.item) == ITEM_TYPE_CHARGED then
                    BlzFrameSetVisible(button.charges_frame, true)
                    BlzFrameSetText(button.charges_text_frame, R2I(GetItemCharges(button.item)))
                else
                    BlzFrameSetVisible(button.charges_frame, false)
                end
            else
                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                BlzFrameSetVisible(button.charges_frame, false)
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


    local function LockWidth(frame, width, min, max)

            if width < min then
                width = min
            elseif width > max  then
                width = max
            end

        BlzFrameSetSize(frame, width, 0.)
    end


    local function ShowTooltip(player, h)
        local item_data = GetItemData(ButtonList[h].item)
        local width = 0.
        local frame_number = 1
        
        if ContextFrame[player] ~= nil then return end
        RemoveTooltip(player)

        PlayerTooltip[player] = {}
        PlayerTooltip[player].frames = {}

        PlayerTooltip[player].backdrop = BlzCreateFrame("BoxedText", ButtonList[GetHandleId(InventorySlots[32])].image, 150, 0)

        local property_text = ""
        if item_data.SUBTYPE ~= nil then
            property_text = GetItemSubTypeName(item_data.SUBTYPE) .. "|n" .. "|n"
        end

        if item_data.TYPE == ITEM_TYPE_WEAPON then
            property_text = property_text .. "Урон: " .. R2I(item_data.DAMAGE * item_data.DISPERSION[1]) .. "-" .. R2I(item_data.DAMAGE * item_data.DISPERSION[2]) .. "|n" .. "Тип урона: " .. GetItemAttributeName(item_data.ATTRIBUTE)
        elseif item_data.TYPE == ITEM_TYPE_ARMOR then
            property_text = property_text .. "Защита: " .. item_data.DEFENCE
        elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
            property_text = property_text .. "Подавление: " .. item_data.SUPPRESSION
        elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
            property_text = property_text .. "Защита: " .. item_data.DEFENCE
        elseif item_data.TYPE == ITEM_TYPE_GEM then
            property_text = "Камень"
        end


        local bonus_text

        if item_data.BONUS ~= nil and #item_data.BONUS > 0 then

            bonus_text = "|nДополнительные свойства:|n"
            for i = 1, #item_data.BONUS do
                bonus_text = bonus_text .. GetParameterName(item_data.BONUS[i].PARAM) .. ": " .. GetCorrectParamText(item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD) .. "|n"
            end

        elseif item_data.TYPE == ITEM_TYPE_GEM then

            bonus_text = "|nАугментации:|n"
            for i = 1, #item_data.point_bonus do
                if item_data.point_bonus[i] ~= nil then
                    bonus_text = bonus_text .. GetItemTypeName(i) .. " - " .. GetParameterName(item_data.point_bonus[i].PARAM) .. ": " .. GetCorrectParamText(item_data.point_bonus[i].VALUE, item_data.point_bonus[i].METHOD).. "|n"
                end
            end
        end

        BlzFrameSetAllPoints(PlayerTooltip[player].backdrop, ButtonList[h].image)


        PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "name", PlayerTooltip[player].backdrop, "", 0)
        BlzFrameSetPoint(PlayerTooltip[player].frames[frame_number], FRAMEPOINT_CENTER, ButtonList[h].image, FRAMEPOINT_CENTER, 0.05, -0.01)
        BlzFrameSetText(PlayerTooltip[player].frames[frame_number], GetItemNameColorized(ButtonList[h].item))
        BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 1.3)


        frame_number = 2
        PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "item type", PlayerTooltip[player].frames[1], "", 0)
        BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetText(PlayerTooltip[player].frames[frame_number], property_text)
        BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 0.95)


        if bonus_text ~= nil then
            frame_number = frame_number + 1
            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "item type", PlayerTooltip[player].frames[frame_number - 1], "", 0)
            BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetText(PlayerTooltip[player].frames[frame_number], bonus_text)
            BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 1.)
        end


        if item_data.MAX_SLOTS ~= nil and item_data.MAX_SLOTS > 0 then
            frame_number = frame_number + 1

            local free_stone_slots = item_data.MAX_SLOTS - #item_data.STONE_SLOTS
            local stones_text = "|nСокеты:|n"
            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "STONE", PlayerTooltip[player].frames[frame_number - 1], "", 0)

            for i = 1, #item_data.STONE_SLOTS do
                if item_data.STONE_SLOTS[i] ~= nil then
                    stones_text = stones_text .. GetParameterName(item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM) .. ": "
                            .. GetCorrectParamText(item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE,
                            item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].METHOD) .. "|n"
                else
                    stones_text = stones_text .. "|n"
                end
            end

            BlzFrameSetText(PlayerTooltip[player].frames[frame_number], stones_text)
            BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

            if free_stone_slots > 0 then
                local stones = {}
                frame_number = frame_number + 1
                PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "STONE", PlayerTooltip[player].frames[frame_number - 1], "", 0)
                BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], 0.01, 0.028)
                    for i = 1, free_stone_slots do
                        stones[i] = BlzCreateFrameByType("BACKDROP", "STONE", PlayerTooltip[player].frames[frame_number], "", 0)
                        BlzFrameSetTexture(stones[i], "GUI\\empty stone.blp", 0, true)
                        BlzFrameSetSize(stones[i], 0.01, 0.01)
                            if i == 1 then
                                BlzFrameSetPoint(stones[i], FRAMEPOINT_CENTER, PlayerTooltip[player].frames[frame_number], FRAMEPOINT_CENTER, free_stone_slots*((free_stone_slots * 0.001) * -1.),  0.)
                            else
                                BlzFrameSetPoint(stones[i], FRAMEPOINT_LEFT, stones[i - 1], FRAMEPOINT_RIGHT, 0., 0.)
                            end
                    end
                stones = nil
            end

        end


        for i = 1, #PlayerTooltip[player].frames do

                if BlzFrameGetWidth(PlayerTooltip[player].frames[i]) > width then
                    width = BlzFrameGetWidth(PlayerTooltip[player].frames[i])
                    --if i == 1 then width = width * 0.7 end
                end

                if i ~= 1 then
                    BlzFrameSetPoint(PlayerTooltip[player].frames[i], FRAMEPOINT_TOP, PlayerTooltip[player].frames[i - 1], FRAMEPOINT_BOTTOM, 0., 0.)
                end

        end

        width = width - 0.02
        LockWidth(PlayerTooltip[player].frames[1], width, 0.06, 0.2)


        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOP, PlayerTooltip[player].frames[1], FRAMEPOINT_TOP, 0., 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPLEFT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPLEFT, -0.007, 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPRIGHT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPRIGHT, 0.007, 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMLEFT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMLEFT, -0.007, -0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.007)
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
            local scale = 0.0415
            if PlayerMovingItem[player].mode == 2 then scale = 0.035 end
            BlzFrameSetSize(PlayerMovingItem[player].frame, scale, scale)
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

    local function StartSelectionMode(player, h, mode)
        local item_data = GetItemData(ButtonList[h].item)
        PlayerMovingItem[player] = { frame = nil, selector_frame = nil, selected_frame = h, mode = mode }

        PlayerMovingItem[player].selector_frame = BlzCreateFrameByType("SPRITE", "justAName", ButtonList[GetHandleId(InventorySlots[32])].image, "WarCraftIIILogo", 0)
        BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, ButtonList[h].image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetSize(PlayerMovingItem[player].selector_frame, 1., 1.)
        BlzFrameSetScale(PlayerMovingItem[player].selector_frame, 1.)


        PlayerMovingItem[player].frame = BlzCreateFrameByType("BACKDROP", "selection frame", PlayerMovingItem[player].selector_frame, "", 0)
        BlzFrameSetTexture(PlayerMovingItem[player].frame, item_data.frame_texture, 0, true)
        BlzFrameSetAllPoints(PlayerMovingItem[player].frame, ButtonList[h].image)

        if mode == 1 then
            BlzFrameSetSize(PlayerMovingItem[player].frame, 0.041, 0.041)
            BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter4.mdx", 0)
        else
            BlzFrameSetSize(PlayerMovingItem[player].frame, 0.035, 0.035)
            BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter5.mdx", 0)
        end

        BlzFrameSetAlpha(PlayerMovingItem[player].frame, 175)
        RemoveTooltip(player)
    end


    TriggerAddAction(EnterTrigger, EnterAction)


    
    local function InteractWithItemInSlot(h, id)
        local item_data = GetItemData(ButtonList[h].item)

        if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then

            if ButtonList[h].button_type == INV_SLOT then
                    EquipItem(InventoryOwner[id], ButtonList[h].item, true)
                    ButtonList[h].item = nil
                    UpdateEquipPointsWindow(id)
                    UpdateInventoryWindow(id)
            elseif ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
                EquipItem(InventoryOwner[id], ButtonList[h].item, false)
                local free_slot = GetFirstFreeSlotButton()
                free_slot.item = ButtonList[h].item
                UpdateEquipPointsWindow(id)
                UpdateInventoryWindow(id)
            end

        end

    end


    local function ForceEquip(h, player)
        if ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
            EquipItem(InventoryOwner[player], ButtonList[PlayerMovingItem[player].selected_frame].item, true)
            ButtonList[PlayerMovingItem[player].selected_frame].item = nil
            UpdateEquipPointsWindow(player)
            UpdateInventoryWindow(player)
        end
    end


    local function Socket(stone, item, player, slot)
        local stone_data = GetItemData(stone)
        local item_data = GetItemData(item)


        if item_data.MAX_SLOTS ~= #item_data.STONE_SLOTS then
            for i = 1, item_data.MAX_SLOTS do
                if item_data.STONE_SLOTS[i] == nil then
                    local flag = slot.button_type >= WEAPON_POINT and slot.button_type <= NECKLACE_POINT

                    if flag then EquipItem(InventoryOwner[player], item, false) end
                    item_data.STONE_SLOTS[i] = stone_data
                    if flag then EquipItem(InventoryOwner[player], item, true) end


                    if GetItemCharges(stone) - 1 <= 0 then
                        RemoveItemFromInventory(player, stone)
                    else
                        SetItemCharges(stone, GetItemCharges(stone) - 1)
                    end

                    RemoveSelectionFrames(player)
                    UpdateInventoryWindow(player)
                    break
                end
            end
        end

    end




    local function InventorySlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())
        local item_data = GetItemData(ButtonList[h].item)

        if TimerGetRemaining(DoubleClickTimer[player]) > 0. then
            if ButtonList[h].item ~= nil and item_data.TYPE ~= ITEM_TYPE_GEM then
                RemoveTooltip(player)
                DestroyContextMenu(player)
                InteractWithItemInSlot(h, player)
            end
        else
            TimerStart(DoubleClickTimer[player], 0.25, false, function()
                if ButtonList[h].item ~= nil and PlayerMovingItem[player] == nil and ButtonList[h].button_type == INV_SLOT then

                    CreatePlayerContextMenu(player, ButtonList[h].button)

                    if item_data.TYPE ~= ITEM_TYPE_GEM then
                        AddContextOption(player, "Надеть", function()
                            InteractWithItemInSlot(h, player)
                        end)
                    else
                        AddContextOption(player, "Вставить", function()
                            StartSelectionMode(player, h, 2)
                        end)
                    end

                    AddContextOption(player, "Переместить", function()
                        StartSelectionMode(player, h, 1)
                    end)

                    AddContextOption(player, "Выкинуть", function()
                        DropItemFromInventory(player, ButtonList[h].item)
                    end)
                end
            end)

            if PlayerMovingItem[player] ~= nil then
                TimerStart(DoubleClickTimer[player], 0., false, nil)
                local moved_item_data = GetItemData(ButtonList[PlayerMovingItem[player].selected_frame].item)

                    if PlayerMovingItem[player].mode == 2 then
                        if ButtonList[h].item ~= nil then
                            if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then
                                Socket(ButtonList[PlayerMovingItem[player].selected_frame].item, ButtonList[h].item, player, ButtonList[h])
                                return
                            end
                        else
                            RemoveSelectionFrames(player)
                        end
                    end

                    if ButtonList[h].item == nil then

                        if ButtonList[h].button_type == INV_SLOT then
                            ButtonList[h].item = ButtonList[PlayerMovingItem[player].selected_frame].item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = nil
                            UpdateInventoryWindow(player)
                            RemoveSelectionFrames(player)
                        else
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM then
                                ForceEquip(h, player)
                                RemoveSelectionFrames(player)
                            end
                        end

                    else

                        if ButtonList[h].button_type == INV_SLOT then
                            local item = ButtonList[PlayerMovingItem[player].selected_frame].item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = ButtonList[h].item
                            ButtonList[h].item = item
                            UpdateInventoryWindow(player)
                            RemoveSelectionFrames(player)
                        else
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM then
                                local item = ButtonList[PlayerMovingItem[player].selected_frame].item
                                ButtonList[PlayerMovingItem[player].selected_frame].item = ButtonList[h].item
                                ButtonList[h].item = item
                                UpdateInventoryWindow(player)
                                RemoveSelectionFrames(player)
                            end
                        end

                    end

            end

        end

    end

    TriggerAddAction(ClickTrigger, InventorySlot_Clicked)


    ---@param item item
    function RemoveItemFromInventory(player, item)
        local button
        for i = 1, 32 do
            button = ButtonList[GetHandleId(InventorySlots[i])]
            if button.item == item then
                --BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                UpdateInventoryWindow()
                button.item = nil
                RemoveCustomItem(item)
                break
            end
        end
    end

    ---@param player integer
    ---@param item item
    function DropItemFromInventory(player, item)
        local button
        for i = 1, 32 do
            button = ButtonList[GetHandleId(InventorySlots[i])]
            if button.item == item then
                SetItemVisible(item, true)
                SetItemPosition(item, GetUnitX(PlayerHero[player]) + GetRandomReal(-55., 55.), GetUnitY(PlayerHero[player]) + GetRandomReal(-55., 55.))
                --BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                button.item = nil
                UpdateInventoryWindow()
                break
            end
        end
    end

    ---@param item item
    function IsPlayerHaveItem(player, item)
        for i = 1, 32 do
            if ButtonList[GetHandleId(InventorySlots[i])].item == item then
                return true
            end
        end
        return false
    end

    ---@param itemid integer
    function IsPlayerHaveItemId(player, itemid)
        for i = 1, 32 do
            if GetItemTypeId(ButtonList[GetHandleId(InventorySlots[i])].item) == itemid then
                return true
            end
        end
        return false
    end

    ---@param itemid integer
    function GetSameItemSlotItem(player, itemid)
        for i = 1, 32 do
            if GetItemTypeId(ButtonList[GetHandleId(InventorySlots[i])].item) == itemid then
                return ButtonList[GetHandleId(InventorySlots[i])].item
            end
        end
        return nil
    end


    ---@param item item
    function AddToInventory(player, item)
        if GetItemData(item) ~= nil then

            if GetItemType(item) == ITEM_TYPE_CHARGED then

                local inv_item = GetSameItemSlotItem(player, GetItemTypeId(item))
                if inv_item ~= nil then
                    SetItemCharges(inv_item, GetItemCharges(item) + GetItemCharges(inv_item))
                    RemoveCustomItem(item)
                    UpdateInventoryWindow()
                else
                    local free_slot = GetFirstFreeSlotButton()

                    if free_slot ~= nil then
                        free_slot.item = item
                        SetItemVisible(item, false)
                        UpdateInventoryWindow()
                    end

                end

            else
                local free_slot = GetFirstFreeSlotButton()

                if free_slot ~= nil then
                    free_slot.item = item
                    UpdateInventoryWindow()
                    SetItemVisible(item, false)
                end
            end

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
        local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", new_Frame, "", 0)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)

        
            ButtonList[GetHandleId(new_Frame)] = {
                button_type = button_type,
                item = nil,
                button = new_Frame,
                image = new_FrameImage,
                original_texture = texture,
                charges_frame = new_FrameCharges,
                charges_text_frame = new_FrameChargesText }

            FrameRegisterNoFocus(new_Frame)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)


            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, new_FrameImage, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
            BlzFrameSetSize(new_FrameCharges, 0.012, 0.012)
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
            BlzFrameSetPoint(new_FrameChargesText, FRAMEPOINT_CENTER, new_FrameCharges, FRAMEPOINT_CENTER, 0.,0.)
            BlzFrameSetVisible(new_FrameCharges, false)

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