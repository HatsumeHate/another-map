---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 27.12.2019 21:14
---

do

    local MAXIMUM_ITEMS = 32


    function UpdateShopWindow()
            for player = 1, 6 do
                local my_shop_data = ShopData[GetHandleId(ShopInFocus[player])]

                    if my_shop_data ~= nil then
                        for i = 1, MAXIMUM_ITEMS do
                            local button = ButtonList[GetHandleId(ShopFrame[player].slot[i])]
                            button.item = my_shop_data.item_list[i].item

                            if button.item ~= nil then
                                local item_data = GetItemData(button.item)
                                BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                                FrameChangeTexture(button.button, item_data.frame_texture)

                                if GetItemType(button.item) == ITEM_TYPE_CHARGED then
                                    BlzFrameSetVisible(button.charges_frame, true)
                                    BlzFrameSetText(button.charges_text_frame, R2I(GetItemCharges(button.item)))
                                else
                                    BlzFrameSetVisible(button.charges_frame, false)
                                end

                            else
                                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                                FrameChangeTexture(button.button, button.original_texture)
                                BlzFrameSetVisible(button.charges_frame, false)
                            end
                        end
                    end
        end
    end


    local LeaveTrigger = CreateTrigger()
    local EnterTrigger = CreateTrigger()
    local ClickTrigger = CreateTrigger()

    local function EnterAction()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())

            if ButtonList[h].item ~= nil then

                --ButtonList[GetHandleId(ShopFrame[player].slot[32])].image
                ShowTooltip(player, h, FRAMEPOINT_RIGHT, MASTER_FRAME)
            else
                RemoveTooltip(player)
            end

    end

    local function LeaveAction()
        --local player = GetPlayerId(GetTriggerPlayer()) + 1
        --local h = GetHandleId(BlzGetTriggerFrame())

        RemoveTooltip(GetPlayerId(GetTriggerPlayer()) + 1)
    end


    local function ShopSlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = GetHandleId(BlzGetTriggerFrame())
        --local item_data = GetItemData(ButtonList[h].item)

            if ButtonList[h].item ~= nil then
                CreatePlayerContextMenu(player, ButtonList[h].button, ButtonList[GetHandleId(ShopFrame[player].slot[32])].image)
                AddContextOption(player, "Купить", function()

                    if GetItemCharges(ButtonList[h].item) > 1 then
                        CreateSlider(player, ButtonList[h], ButtonList[GetHandleId(ShopFrame[player].slot[32])].image, function()
                            BuyItem(player, ButtonList[h].item, BlzFrameGetValue(SliderFrame[player].slider))
                        end, nil)
                    else
                        BuyItem(player, ButtonList[h].item, 1)
                    end

                    --print("ЭТО БЫЛ Я! ДИО!")
                end)
            else
                DestroySlider(player)
                DestroyContextMenu(player)
            end

    end


    TriggerAddAction(LeaveTrigger, LeaveAction)
    TriggerAddAction(EnterTrigger, EnterAction)
    TriggerAddAction(ClickTrigger, ShopSlot_Clicked)


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



    ShopFrame = {}

    ---@param player integer
    function DrawShopFrames(player)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            ShopFrame[player] = {}
            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.01, -0.05)
            BlzFrameSetSize(main_frame, 0.4, 0.28)


            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.07)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.07)
            --BlzFrameSetSize(new_Frame, 0.4, 0.38)
            ShopFrame[player].inventory_border = new_Frame

                    ShopFrame[player].slot = {}
                    ShopFrame[player].slot[1] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, new_Frame)

                    for i = 2, 8 do
                        ShopFrame[player].slot[i] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, ShopFrame[player].slot[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., new_Frame)
                    end

                    for row = 2, 4 do
                        for i = 1, 8 do
                            local slot = i + ((row - 1) * 8)
                            ShopFrame[player].slot[slot] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, ShopFrame[player].slot[slot - 8], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., new_Frame)
                        end
                    end

        new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
        BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
        BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
        ShopFrame[player].portrait = new_Frame


        new_Frame = BlzCreateFrameByType("TEXT", "shop name", ShopFrame[player].portrait, "", 0)
        BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, ShopFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
        BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(new_Frame, 1.35)
        ShopFrame[player].name = new_Frame


        ShopFrame[player].main_frame = main_frame
        BlzFrameSetVisible(ShopFrame[player].main_frame, false)
    end


    ShopInFocus = {}
    ShopData = {}


    ---@param shop unit
    ---@param item item
    function RemoveItemFromShop(shop, item)
        local my_shop_data = ShopData[GetHandleId(shop)]

            for i = 1, MAXIMUM_ITEMS do
                if my_shop_data.item_list[i].item == item then

                    if my_shop_data.item_list[i].perm then
                        SetItemCharges(my_shop_data.item_list[i].item, my_shop_data.item_list[i].charges)
                        item = CreateCustomItem_Id(GetItemTypeId(my_shop_data.item_list[i].item), 0., 0.)
                    else
                        my_shop_data.item_list[i].item = nil
                    end

                    UpdateShopWindow()
                    break
                end
            end

        return item
    end


    ---@param shop unit
    function ClearShop(shop)
        local my_shop_data = ShopData[GetHandleId(shop)]

            for i = 1, MAXIMUM_ITEMS do
                if not my_shop_data.item_list[i].perm then
                    RemoveCustomItem(my_shop_data.item_list[i].item)
                    my_shop_data.item_list[i].item = nil
                end
            end

        UpdateShopWindow()
    end

    ---@param player integer
    ---@param item item
    function BuyItem(player, item, amount)
        local item_data = GetItemData(item)
        local gold = GetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD)
        local total_cost = item_data.cost + item_data.sell_value


            if CountFreeBagSlots(player) <= 0 then
                SimError("В рюкзаке нет места", player-1)
                return false
            end


            if GetItemCharges(item) > 1 then
                total_cost = total_cost * amount
            end

            if gold > total_cost then
                SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, gold - total_cost)
                item = RemoveItemFromShop(ShopInFocus[player], item)

                    if GetItemType(item) == ITEM_TYPE_CHARGED then
                        SetItemCharges(item, amount)
                    end

                AddToInventory(player, item)
                PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", player-1)
                return true
            else
                SimError("Недостаточно золота", player-1)
            end

        return false
    end


    ---@param player integer
    ---@param item item
    function SellItem(player, item)
        local item_data = GetItemData(item)
        local gold = GetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD)
        local total_cost = item_data.cost + item_data.sell_value

            if CountFreeSlotsShop(ShopInFocus[player]) <= 0 then
                SimError("В магазине нет места", player-1)
                return false
            end

            if GetItemCharges(item) > 1 then
                total_cost = total_cost * GetItemCharges(item)
            end

            SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, gold + total_cost)
            DropItemFromInventory(player, item, true)
            AddItemToShop(ShopInFocus[player], item, false)
            PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", player-1)

        return true
    end


    ---@param shop unit
    function CountFreeSlotsShop(shop)
        local my_shop_data = ShopData[GetHandleId(shop)]
        local count = 0

            for i = 1, MAXIMUM_ITEMS do
                if my_shop_data.item_list[i].item == nil then
                    count = count + 1
                end
            end

        return count
    end


    ---@param shop unit
    ---@param item item
    ---@param permanent boolean
    function AddItemToShop(shop, item, permanent)
        local my_shop_data = ShopData[GetHandleId(shop)]


            if GetItemType(item) == ITEM_TYPE_CHARGED then
                local id = GetItemTypeId(item)
                    for i = 1, MAXIMUM_ITEMS do
                        if id == GetItemTypeId(my_shop_data.item_list[i].item) then
                            if my_shop_data.item_list[i].perm then
                                RemoveCustomItem(item)
                                return true
                            else
                                SetItemCharges(item, GetItemCharges(item) + GetItemCharges(my_shop_data.item_list[i].item))
                                RemoveCustomItem(item)
                                return true
                            end
                        end
                    end
            end


            for i = 1, MAXIMUM_ITEMS do
                if my_shop_data.item_list[i].item == nil then
                    my_shop_data.item_list[i].item = item
                    my_shop_data.item_list[i].perm = permanent

                    SetItemVisible(item, false)

                    local item_data = GetItemData(item)
                    if item_data.quality_effect ~= nil then DestroyEffect(item_data.quality_effect) end

                    UpdateShopWindow()
                    break
                end
            end

    end

    ---@param shop unit
    ---@param item item
    ---@param permanent boolean
    ---@param slot integer
    function AddItemToShopWithSlot(shop, item, slot, permanent)
        local my_shop_data = ShopData[GetHandleId(shop)]

            if slot > MAXIMUM_ITEMS then
                slot = MAXIMUM_ITEMS
            elseif slot < 1 then
                slot = 1
            end


                if my_shop_data.item_list[slot].item == nil then
                    my_shop_data.item_list[slot].item = item
                    my_shop_data.item_list[slot].perm = permanent

                        if permanent and GetItemType(item) == ITEM_TYPE_CHARGED then
                            my_shop_data.item_list[slot].charges = GetItemCharges(item)
                        end

                    SetItemVisible(item, false)
                    UpdateShopWindow()
                end

    end

    ---@param unit_owner unit
    ---@param texture string
    function CreateShop(unit_owner, texture)
        local handle = GetHandleId(unit_owner)

            ShopData[handle] = {}
            ShopData[handle].item_list = {}


            for i = 1, MAXIMUM_ITEMS do
                ShopData[handle].item_list[i] = {}
                ShopData[handle].item_list[i].item = nil
                ShopData[handle].item_list[i].perm = false
            end


            local trg = CreateTrigger()
            TriggerRegisterUnitInRangeSimple(trg, 300., unit_owner)
            TriggerAddAction(trg, function()
                local id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))

                if id <= 5 then
                    local hero = GetTriggerUnit()

                    ShopInFocus[id + 1] = unit_owner
                    BlzFrameSetVisible(ShopFrame[id + 1].main_frame, true)
                    BlzFrameSetTexture(ShopFrame[id + 1].portrait, texture, 0, true)
                    BlzFrameSetText(ShopFrame[id + 1].name, GetUnitName(unit_owner))
                    UpdateShopWindow()

                        TimerStart(CreateTimer(), 0.1, true, function()
                            if not IsUnitInRange(hero, unit_owner, 300.) then
                                DestroySlider(id + 1)
                                DestroyContextMenu(id + 1)
                                ShopInFocus[id + 1] = nil
                                BlzFrameSetVisible(ShopFrame[id + 1].main_frame, false)
                                DestroyTimer(GetExpiredTimer())
                            end
                        end)

                end

            end)

        return ShopData[handle]
    end

end