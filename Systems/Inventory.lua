do

    PlayerInventoryFrame = {}
    InventorySlots = {}
    InventoryOwner = {}
    InventoryTriggerButton = nil
    INV_SLOT = 0
    local ClickTrigger = CreateTrigger()




    local function GetFirstFreeSlotButton(player)
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

    function UpdateEquipPointsWindow(player)
        local unit_data = GetUnitData(InventoryOwner[player])

        for i = WEAPON_POINT, NECKLACE_POINT do
            local button = ButtonList[GetHandleId(InventorySlots[UNIT_POINT_LIST[i]])]

            if unit_data.equip_point[i] ~= nil and unit_data.equip_point[i].SUBTYPE ~= FIST_WEAPON then
                local item_data = GetItemData(unit_data.equip_point[i].item)
                button.item = item_data.item
                BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                FrameChangeTexture(button.button, item_data.frame_texture)
            else
                button.item = nil
                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                FrameChangeTexture(button.button, button.original_texture)
            end

        end

    end

    function UpdateInventoryWindow(player)
        if InventoryOwner[player] ~= nil then

            for i = 1, 32 do
                local button = ButtonList[GetHandleId(InventorySlots[i])]
                if button.item ~= nil then
                    local item_data = GetItemData(button.item)
                    BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                    FrameChangeTexture(button.button, item_data.frame_texture)

                    if GetItemType(button.item) == ITEM_TYPE_CHARGED then
                        BlzFrameSetVisible(button.charges_frame, true)
                        BlzFrameSetText(button.charges_text_frame, R2I(GetItemCharges(button.item)))

                        if button.sprite ~= nil and not IsItemInvulnerable(button.item) then
                            BlzDestroyFrame(button.sprite)
                            button.sprite = nil
                        elseif button.sprite == nil and IsItemInvulnerable(button.item) then
                            button.sprite = BlzCreateFrameByType("SPRITE", "justAName", button.image, "WarCraftIIILogo", 0)

                            BlzFrameSetPoint(button.sprite, FRAMEPOINT_BOTTOMLEFT, button.image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
                            BlzFrameSetSize(button.sprite, 1., 1.)
                            BlzFrameSetScale(button.sprite, 1.)

                            BlzFrameSetModel(button.sprite, "selecter3.mdx", 0)
                        end

                    else
                        BlzFrameSetVisible(button.charges_frame, false)
                    end

                else
                    BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                    FrameChangeTexture(button.button, button.original_texture)
                    BlzFrameSetVisible(button.charges_frame, false)

                    if button.sprite ~= nil then
                        BlzDestroyFrame(button.sprite)
                    end

                end
            end

        end
    end



    --======================================================================
    -- BELT LOCK   =========================================================


    local ItemUseTrigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(ItemUseTrigger, EVENT_PLAYER_UNIT_USE_ITEM)
    TriggerAddAction(ItemUseTrigger, function()
        UpdateInventoryWindow(GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1)
    end)

    local function LockItemOnBelt(player, button)
        if button.sprite == nil then
            if UnitInventoryCount(InventoryOwner[player]) < 6 then
                button.sprite = BlzCreateFrameByType("SPRITE", "justAName", button.image, "WarCraftIIILogo", 0)

                BlzFrameSetPoint(button.sprite, FRAMEPOINT_BOTTOMLEFT, button.image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
                BlzFrameSetSize(button.sprite, 1., 1.)
                BlzFrameSetScale(button.sprite, 1.)

                BlzFrameSetModel(button.sprite, "selecter3.mdx", 0)
                PlayLocalSound("Sound\\Interface\\AutoCastButtonClick1.wav", player)

                SetItemVisible(button.item, true)
                SetItemInvulnerable(button.item, true)
                UnitAddItem(PlayerHero[player], button.item)
            end
        else
            BlzDestroyFrame(button.sprite)

            UnitRemoveItem(PlayerHero[player], button.item)
            SetItemVisible(button.item, false)
            SetItemInvulnerable(button.item, false)
            button.sprite = nil
        end
    end






    local PlayerMovingItem = {}
    local EnterTrigger = CreateTrigger()
    local LeaveTrigger = CreateTrigger()


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
                    ShowTooltip(player, h, FRAMEPOINT_LEFT, MASTER_FRAME)--ButtonList[GetHandleId(InventorySlots[32])].image)
                else
                    RemoveTooltip(player)
                end
            end

    end

    local function LeaveAction()
        --local player = GetPlayerId(GetTriggerPlayer()) + 1
        --local h = GetHandleId(BlzGetTriggerFrame())

            RemoveTooltip(GetPlayerId(GetTriggerPlayer()) + 1)
    end

    TriggerAddAction(LeaveTrigger, LeaveAction)

    --======================================================================
    -- SELECTOION MODE =====================================================

    function RemoveSelectionFrames(player)
        if PlayerMovingItem[player] ~= nil then

            if ButtonList[PlayerMovingItem[player].selected_frame].sprite ~= nil then
                BlzFrameSetEnable(ButtonList[PlayerMovingItem[player].selected_frame].sprite, true)
            end

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


        if ButtonList[h].sprite ~= nil then
            BlzFrameSetEnable(ButtonList[h].sprite, false)
        end

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
                        local uneqiped_item = EquipItem(InventoryOwner[id], ButtonList[h].item, true)

                            if item_data.soundpack ~= nil and item_data.soundpack.equip ~= nil then
                                PlayLocalSound(item_data.soundpack.equip, id - 1)
                            end

                        ButtonList[h].item = uneqiped_item
                        UpdateEquipPointsWindow(id)
                        UpdateInventoryWindow(id)
                elseif ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
                    EquipItem(InventoryOwner[id], ButtonList[h].item, false)

                        if item_data.soundpack ~= nil and item_data.soundpack.uneqip ~= nil then
                            PlayLocalSound(item_data.soundpack.uneqip, id - 1)
                        end

                    local free_slot = GetFirstFreeSlotButton(id)
                    free_slot.item = ButtonList[h].item
                    UpdateEquipPointsWindow(id)
                    UpdateInventoryWindow(id)
                end

            end

    end


    local function ForceEquip(h, player)

        if ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
            EquipItem(InventoryOwner[player], ButtonList[PlayerMovingItem[player].selected_frame].item, true)
            local item_data = GetItemData(ButtonList[PlayerMovingItem[player].selected_frame].item)

                if item_data.soundpack ~= nil and item_data.soundpack.equip ~= nil then
                    PlayLocalSound(item_data.soundpack.equip, player - 1)
                end

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
                    print(stone_data)
                    print("stone slot is " .. i)
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


    function SplitChargedItem(item, count, player)
            SetItemCharges(item, GetItemCharges(item) - count)
            local new_item = CreateCustomItem_Id(GetItemTypeId(item), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
            GenerateItemLevel(new_item, 1)
            SetItemCharges(new_item, count)
        return new_item
    end



    local function InventorySlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())
        local item_data = GetItemData(ButtonList[h].item)


        if TimerGetRemaining(DoubleClickTimer[player]) > 0. then
            if ButtonList[h].item ~= nil and item_data.TYPE ~= ITEM_TYPE_GEM and item_data.TYPE ~= ITEM_TYPE_CONSUMABLE then
                RemoveTooltip(player)
                DestroyContextMenu(player)
                InteractWithItemInSlot(h, player)
                TimerStart(DoubleClickTimer[player], 0.01, false, nil)
            elseif item_data.TYPE == ITEM_TYPE_CONSUMABLE then
                LockItemOnBelt(player, ButtonList[h])
                RemoveTooltip(player)
                DestroyContextMenu(player)
                TimerStart(DoubleClickTimer[player], 0.01, false, nil)
            end
        else
            TimerStart(DoubleClickTimer[player], 0.25, false, function()
                if ButtonList[h].item ~= nil and PlayerMovingItem[player] == nil and ButtonList[h].button_type == INV_SLOT then

                    CreatePlayerContextMenu(player, ButtonList[h].button, ButtonList[GetHandleId(InventorySlots[32])].image)

                    if ShopInFocus[player] ~= nil then
                        AddContextOption(player, "Продать", function()
                            if ShopInFocus[player] ~= nil then

                                if GetItemCharges(ButtonList[h].item) > 1 then
                                    CreateSlider(player, ButtonList[h], ButtonList[GetHandleId(InventorySlots[32])].image, function()

                                        if BlzFrameGetValue(SliderFrame[player].slider) < GetItemCharges(ButtonList[h].item) then
                                            local new_item = SplitChargedItem(ButtonList[h].item, BlzFrameGetValue(SliderFrame[player].slider), player)
                                            SellItem(player, new_item)
                                            UpdateInventoryWindow(player)
                                        else
                                            SellItem(player, ButtonList[h].item)
                                            -- DropItemFromInventory(player, ButtonList[h].item)
                                        end

                                    end, nil)
                                else
                                    SellItem(player, ButtonList[h].item)
                                end

                            end
                        end)
                    end

                    if item_data.TYPE == ITEM_TYPE_GEM then
                        AddContextOption(player, "Вставить", function()
                            StartSelectionMode(player, h, 2)
                        end)
                    elseif item_data.TYPE == ITEM_TYPE_CONSUMABLE then
                        AddContextOption(player, ButtonList[h].sprite ~= nil and "Открепить" or "Закрепить", function()
                            LockItemOnBelt(player, ButtonList[h])
                        end)
                    else
                        AddContextOption(player, "Надеть", function()
                            InteractWithItemInSlot(h, player)
                        end)
                    end

                    AddContextOption(player, "Переместить", function()
                        StartSelectionMode(player, h, 1)
                    end)

                    AddContextOption(player, "Выкинуть", function()

                        if item_data.soundpack ~= nil and item_data.soundpack.drop ~= nil then
                            AddSoundVolumeZ(item_data.soundpack.drop, GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]), BlzGetLocalUnitZ(PlayerHero[player]) + GetUnitFlyHeight(PlayerHero[player]), 127, 2200.)
                        end

                        if GetItemType(ButtonList[h].item) ~= ITEM_TYPE_CHARGED then
                            DropItemFromInventory(player, ButtonList[h].item)
                        else
                            if GetItemCharges(ButtonList[h].item) > 1 then
                                CreateSlider(player, ButtonList[h], ButtonList[GetHandleId(InventorySlots[32])].image, function()

                                    if BlzFrameGetValue(SliderFrame[player].slider) < GetItemCharges(ButtonList[h].item) then
                                        SetItemCharges(ButtonList[h].item, GetItemCharges(ButtonList[h].item) - BlzFrameGetValue(SliderFrame[player].slider))
                                        local new_item = CreateCustomItem_Id(GetItemTypeId(ButtonList[h].item), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
                                        SetItemCharges(new_item, BlzFrameGetValue(SliderFrame[player].slider))
                                    else
                                        DropItemFromInventory(player, ButtonList[h].item)
                                    end
                                    UpdateInventoryWindow(player)

                                end, nil)
                            else
                                DropItemFromInventory(player, ButtonList[h].item)
                            end
                        end
                    end)
                end
            end)

            DestroySlider(player)
            DestroyContextMenu(player)

            if PlayerMovingItem[player] ~= nil then
                TimerStart(DoubleClickTimer[player], 0., false, nil)
                local moved_item_data = GetItemData(ButtonList[PlayerMovingItem[player].selected_frame].item)

                    if PlayerMovingItem[player].mode == 2 then
                            if ButtonList[h].item ~= nil then
                                if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then
                                    Socket(ButtonList[PlayerMovingItem[player].selected_frame].item, ButtonList[h].item, player, ButtonList[h])
                                end
                            else
                                RemoveSelectionFrames(player)
                            end
                        return
                    end

                if moved_item_data.soundpack ~= nil and moved_item_data.soundpack.drop ~= nil then
                    PlayLocalSound(moved_item_data.soundpack.drop, player - 1)
                end

                    if ButtonList[h].item == nil then

                        if ButtonList[h].button_type == INV_SLOT then
                            ButtonList[h].item = ButtonList[PlayerMovingItem[player].selected_frame].item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = nil
                            UpdateInventoryWindow(player)
                            RemoveSelectionFrames(player)
                        else
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM and moved_item_data.TYPE ~= ITEM_TYPE_CONSUMABLE then
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
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM and moved_item_data.TYPE ~= ITEM_TYPE_CONSUMABLE then
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
                        if button.sprite ~= nil then
                            LockItemOnBelt(player, button)
                        end
                        SetItemVisible(item, true)
                        SetItemPosition(item, GetUnitX(PlayerHero[player]) + GetRandomReal(-55., 55.), GetUnitY(PlayerHero[player]) + GetRandomReal(-55., 55.))
                        button.item = nil
                        UpdateInventoryWindow(player)
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
    ---@param player integer
    function AddToInventory(player, item)
        if GetItemData(item) ~= nil then

            if CountFreeBagSlots(player) <= 0 then
                SimError("В рюкзаке нет места", player-1)
                return
            end

            if GetItemType(item) == ITEM_TYPE_CHARGED then

                local inv_item = GetSameItemSlotItem(player, GetItemTypeId(item))

                    if inv_item ~= nil then
                        SetItemCharges(inv_item, GetItemCharges(item) + GetItemCharges(inv_item))
                        RemoveCustomItem(item)
                        UpdateInventoryWindow(player)
                    else
                        local free_slot = GetFirstFreeSlotButton(player)

                        if free_slot ~= nil then
                            free_slot.item = item
                            SetItemVisible(item, false)
                            UpdateInventoryWindow(player)
                        end

                    end

            else
                local free_slot = GetFirstFreeSlotButton(player)

                    if free_slot ~= nil then
                        free_slot.item = item
                        UpdateInventoryWindow(player)
                        SetItemVisible(item, false)
                    end

            end

        end
    end


    function CountFreeBagSlots(player)
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
                charges_text_frame = new_FrameChargesText,
                sprite = nil
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

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    function DrawInventoryFrames(player, unit)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)


        BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPRIGHT, GAME_UI, FRAMEPOINT_TOPRIGHT, 0., -0.05)
        BlzFrameSetSize(main_frame, 0.4, 0.38)
        PlayerInventoryFrame[player] = main_frame

        InventoryOwner[1] = unit


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

       -- BlzFrameSetModel(new_Frame, "UI\\Glues\\MainMenu\\WarCraftIIILogo\\WarCraftIIILogo.mdx", 0)
        --BlzFrameSetSpriteAnimate(new_Frame, 2, 0)
        --BlzFrameSetModel(new_Frame, "selecter1.mdx", 0)

        BlzFrameSetVisible(main_frame, false)

    end




    function InventoryInit()

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
        BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_DESCRIPTION)--BoxedText has a child showing the text, set that childs Text.
        BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), LOCALE_LIST[my_locale].INVENTORY_PANEL_TOOLTIP_NAME)--BoxedText has a child showing the Title-text, set that childs Text.
        FrameRegisterNoFocus(InventoryTriggerButton)
        FrameRegisterClick(InventoryTriggerButton, "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp")

        BlzFrameSetVisible(InventoryTriggerButton, false)

        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, InventoryTriggerButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, function()
            local player = GetPlayerId(GetTriggerPlayer()) + 1

            BlzFrameSetVisible(PlayerInventoryFrame[player], not BlzFrameIsVisible(PlayerInventoryFrame[player]))
            RemoveTooltip(player)
            RemoveSelectionFrames(player)
            DestroyContextMenu(player)
            DestroySlider(player)
        end)

    end

end