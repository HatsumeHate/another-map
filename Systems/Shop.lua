---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 27.12.2019 21:14
---

do

    ShopFrame = 0
    ShopInFocus = 0
    ShopData = 0
    local MAXIMUM_ITEMS = 32
    local last_EnteredFrame
    local last_EnteredFrameTimer


    function UpdateShopWindow()
            for player = 1, 6 do
                local my_shop_data = ShopData[ShopInFocus[player]]

                    if my_shop_data then
                        for i = 1, MAXIMUM_ITEMS do
                            local button = ButtonList[ShopFrame[player].slot[i]]
                            button.item = my_shop_data.item_list[i].item

                            if button.item then
                                local item_data = GetItemData(button.item)
                                BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                                FrameChangeTexture(button.button, item_data.frame_texture)

                                    if GetItemType(button.item) == ITEM_TYPE_CHARGED then
                                        BlzFrameSetVisible(button.charges_frame, true)
                                        BlzFrameSetText(button.charges_text_frame, I2S(R2I(GetItemCharges(button.item))))

                                            if GetItemCharges(button.item) >= 10 and GetItemCharges(button.item) < 100 then
                                                BlzFrameSetScale(button.charges_text_frame, 0.95)
                                            elseif GetItemCharges(button.item) >= 100 and GetItemCharges(button.item) < 1000 then
                                                BlzFrameSetScale(button.charges_text_frame, 0.65)
                                            elseif GetItemCharges(button.item) >= 1000 then
                                                BlzFrameSetScale(button.charges_text_frame, 0.5)
                                            end

                                    else
                                        BlzFrameSetVisible(button.charges_frame, false)
                                        BlzFrameSetText(button.charges_text_frame, "")
                                    end

                            else
                                BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                                FrameChangeTexture(button.button, button.original_texture)
                                BlzFrameSetVisible(button.charges_frame, false)
                                BlzFrameSetText(button.charges_text_frame, "")
                            end
                        end
                    end
        end
    end


    function ShowAlternateShopTooltip(player)

        if IsTooltipActive(player) then
            local item_to_compare = GetItemToCompare(ShopFrame[player].in_focus.item, player)
                if item_to_compare then
                    ShowItemTooltip(item_to_compare, ShopFrame[player].alternate_tooltip, ShopFrame[player].in_focus, player, FRAMEPOINT_LEFT, GetTooltip(ShopFrame[player].alternate_tooltip), true, ShopFrame[player].in_focus.item)
                    BlzFrameClearAllPoints(ShopFrame[player].alternate_tooltip)
                    BlzFrameSetPoint(ShopFrame[player].alternate_tooltip, FRAMEPOINT_LEFT, ShopFrame[player].tooltip, FRAMEPOINT_RIGHT, 0., 0.)
                end
        end

    end


    local LeaveTrigger = 0
    local EnterTrigger = 0
    local ClickTrigger = 0

    local function EnterAction()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = BlzGetTriggerFrame()


        TimerStart(last_EnteredFrameTimer[player], GLOBAL_TOOLTIP_FADE_TIME, false, function()
            ShopFrame[player].in_focus = nil
            RemoveTooltip(player)
            last_EnteredFrame[player] = nil
            --print("remove timed")
        end)


        if last_EnteredFrame[player] == h then
            --print("same frame")
            return
        else
            ShopFrame[player].in_focus = nil
            RemoveTooltip(player)
            --print("remove")
        end

        last_EnteredFrame[player] = h

            if ButtonList[h].item then
                ShopFrame[player].in_focus = ButtonList[h]
                ShowItemTooltip(ButtonList[h].item, ShopFrame[player].tooltip, ButtonList[h], player, FRAMEPOINT_RIGHT)
                if ShopFrame[player].shift_state then
                    RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                    ShowAlternateShopTooltip(player)
                end
            else
                ShopFrame[player].in_focus = nil
                RemoveTooltip(player)
            end

    end

    local function LeaveAction()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        ShopFrame[player].in_focus = nil
        RemoveTooltip(player)
    end


    local function ShopSlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = BlzGetTriggerFrame()
        --local item_data = GetItemData(ButtonList[h].item)

            if ButtonList[h].item then
                local button_data = GetButtonData(ShopFrame[player].slot[32])
                CreatePlayerContextMenu(player, ButtonList[h].button, FRAMEPOINT_RIGHT, ButtonList[button_data.image])
                AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_BUY, function()

                    if GetItemCharges(ButtonList[h].item) > 1 then
                        CreateSlider(player, ButtonList[h], ButtonList[ShopFrame[player].slot[32]].image, function()
                            local value = SliderFrame[player].value
                            if value > GetItemCharges(ButtonList[h].item) then
                                value = GetItemCharges(ButtonList[h].item)
                            end
                            BuyItem(player, ButtonList[h].item, value)
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
        local new_FrameChargesBorder = BlzCreateFrameByType("BACKDROP", "Border", new_FrameCharges, "", 0)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
        local new_FrameBorder = BlzCreateFrameByType("BACKDROP", "ButtonBorder", new_FrameImage, "", 0)


        ButtonList[new_Frame] = {
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
        BlzFrameSetText(new_FrameChargesText, "")
        BlzFrameSetVisible(new_FrameCharges, false)

        BlzFrameSetSize(new_FrameChargesBorder, 1., 1.)
        BlzFrameSetTexture(new_FrameChargesBorder, "UI\\inventory_frame.blp", 0, true)
        BlzFrameSetAllPoints(new_FrameChargesBorder, new_FrameCharges)

        BlzFrameSetSize(new_FrameBorder, size_x, size_y)
        BlzFrameSetTexture(new_FrameBorder, "UI\\inventory_frame.blp", 0, true)
        BlzFrameSetAllPoints(new_FrameBorder, new_FrameImage)

        BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
        BlzFrameSetSize(new_Frame, size_x, size_y)
        BlzFrameSetTexture(new_FrameImage, texture, 0, true)
        BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    function ReloadShopFrames()
        for player = 1, 6 do
            if PlayerHero[player] then
                local new_Frame
                local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

                    BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.01, -0.05)
                    BlzFrameSetSize(main_frame, 0.4, 0.28)


                    new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.07)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.07)
                    ShopFrame[player].inventory_border = new_Frame
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

                ShopFrame[player].masterframe = BlzCreateFrameByType("BACKDROP", "ButtonIcon", ShopFrame[player].slot[32], "", 0)

                new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
                BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
                ShopFrame[player].portrait = new_Frame

                local border = BlzCreateFrameByType("BACKDROP", "aaa", new_Frame, "", 0)
                BlzFrameSetSize(border, 1., 1.)
                BlzFrameSetTexture(border, "UI\\inventory_frame.blp", 0, true)
                BlzFrameSetAllPoints(border, new_Frame)

                new_Frame = BlzCreateFrameByType("TEXT", "shop name", ShopFrame[player].portrait, "", 0)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, ShopFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
                BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                BlzFrameSetScale(new_Frame, 1.35)

                ShopFrame[player].shift_state = false

                ShopFrame[player].tip_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.02, 0.02, main_frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.017, -0.017, main_frame)
                CreateTooltip(LOCALE_LIST[my_locale].UI_SHOP_TOOLTIP_HEADER, LOCALE_LIST[my_locale].UI_SHOP_TOOLTIP_DESCRIPTION, ShopFrame[player].tip_button, 0.14, 0.12, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT)
                BlzTriggerRegisterFrameEvent(ShopFrame[player].tip_trigger , ShopFrame[player].tip_button, FRAMEEVENT_CONTROL_CLICK)

                local border = BlzCreateFrameByType("BACKDROP", "aaa", ShopFrame[player].tip_button, "", 0)
                BlzFrameSetSize(border, 1., 1.)
                BlzFrameSetTexture(border, "UI\\inventory_frame.blp", 0, true)
                BlzFrameSetAllPoints(border, ShopFrame[player].tip_button)

                ShopFrame[player].name = new_Frame
                ShopFrame[player].tooltip = NewTooltip(ShopFrame[player].masterframe)
                ShopFrame[player].alternate_tooltip = NewTooltip(ShopFrame[player].masterframe)
                ShopFrame[player].main_frame = main_frame
                BlzFrameSetVisible(ShopFrame[player].main_frame, false)
                ShopFrame[player].state = false
            end
        end
    end


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

        ShopFrame[player].masterframe = BlzCreateFrameByType("BACKDROP", "ButtonIcon", ShopFrame[player].slot[32], "", 0)

        new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
        BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
        BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
        ShopFrame[player].portrait = new_Frame

        local border = BlzCreateFrameByType("BACKDROP", "aaa", ShopFrame[player].portrait, "", 0)
        BlzFrameSetSize(border, 1., 1.)
        BlzFrameSetTexture(border, "UI\\inventory_frame.blp", 0, true)
        BlzFrameSetAllPoints(border, ShopFrame[player].portrait)

        new_Frame = BlzCreateFrameByType("TEXT", "shop name", ShopFrame[player].portrait, "", 0)
        BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, ShopFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
        BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(new_Frame, 1.35)



        ShopFrame[player].shift_state = false
        local actual_player = Player(player-1)
        local comparison_trigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 1, true)
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 0, false)
        TriggerAddAction(comparison_trigger, function()

            if ShopFrame[player].in_focus then
                if BlzGetTriggerPlayerIsKeyDown() and not ShopFrame[player].shift_state then
                    ShopFrame[player].shift_state = true
                    AltState[player] = false
                    ShowAlternateShopTooltip(player)
                elseif not BlzGetTriggerPlayerIsKeyDown() and ShopFrame[player].shift_state then
                    RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                    ShopFrame[player].shift_state = false
                end
            else
                RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                ShopFrame[player].shift_state = false
            end


        end)


        local AltStateTrigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(AltStateTrigger, actual_player, OSKEY_LALT, 5, true)
        --BlzTriggerRegisterPlayerKeyEvent(AltStateTrigger, actual_player, OSKEY_LALT, 0, false)
        TriggerAddAction(AltStateTrigger, function()

            if ShopFrame[player].in_focus then
                if AltState[player] then AltState[player] = false
                else AltState[player] = true end
                RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                ShowAlternateShopTooltip(player)
            end

        end)


        ShopFrame[player].tip_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.02, 0.02, main_frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.017, -0.017, main_frame)
        CreateTooltip(LOCALE_LIST[my_locale].UI_SHOP_TOOLTIP_HEADER, LOCALE_LIST[my_locale].UI_SHOP_TOOLTIP_DESCRIPTION, ShopFrame[player].tip_button, 0.14, 0.12, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT)
        ShopFrame[player].tip_trigger  = CreateTrigger()
        BlzTriggerRegisterFrameEvent(ShopFrame[player].tip_trigger , ShopFrame[player].tip_button, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(ShopFrame[player].tip_trigger , function()
            ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_SHOP_1, player-1)
            DisableTrigger(ShopFrame[player].tip_trigger )
            DelayAction(5., function()
                EnableTrigger(ShopFrame[player].tip_trigger )
            end)
        end)

        local border = BlzCreateFrameByType("BACKDROP", "aaa", ShopFrame[player].tip_button, "", 0)
        BlzFrameSetSize(border, 1., 1.)
        BlzFrameSetTexture(border, "UI\\inventory_frame.blp", 0, true)
        BlzFrameSetAllPoints(border, ShopFrame[player].tip_button)

        ShopFrame[player].name = new_Frame
        ShopFrame[player].tooltip = NewTooltip(ShopFrame[player].masterframe)
        ShopFrame[player].alternate_tooltip = NewTooltip(ShopFrame[player].masterframe)
        ShopFrame[player].main_frame = main_frame
        BlzFrameSetVisible(ShopFrame[player].main_frame, false)
        ShopFrame[player].state = false
    end





    ---@param shop unit
    ---@param item item
    function RemoveItemFromShop(shop, item)
        local my_shop_data = ShopData[shop]

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
        local my_shop_data = ShopData[shop]

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
                Feedback_InventoryNoSpace(player)
                return false
            end


            if GetItemCharges(item) > 1 then
                total_cost = total_cost * amount
            end

            if gold >= total_cost then
                SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, gold - total_cost)


                if GetItemType(item) == ITEM_TYPE_CHARGED then
                        if GetItemCharges(item) == amount then
                            item = RemoveItemFromShop(ShopInFocus[player], item)
                        else
                            SetItemCharges(item, GetItemCharges(item) - amount)
                            item = CreateCustomItem_Id(GetItemTypeId(item), 0., 0.)
                            UpdateShopWindow()
                        end
                    SetItemCharges(item, amount)
                else
                    item = RemoveItemFromShop(ShopInFocus[player], item)
                end


                AddToInventory(player, item)
                if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player-1, 128) end
                PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", player-1)
                DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdx", ShopInFocus[player], "origin"))
                return true
            else
                Feedback_NoGold(player)
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
                SimError(LOCALE_LIST[my_locale].SHOP_MESSAGE_NO_SPACE, player-1)
                return false
            end

            if item_data.sell_penalty then
                total_cost = R2I(total_cost * item_data.sell_penalty)
            end


            if GetItemCharges(item) > 1 then
                total_cost = total_cost * GetItemCharges(item)
            end

            SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, gold + total_cost)
            DropItemFromInventory(player, item, true)
            AddItemToShop(ShopInFocus[player], item, false)

            if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player-1, 128) end
            PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", player-1)

        return true
    end


    ---@param shop unit
    function CountFreeSlotsShop(shop)
        local my_shop_data = ShopData[shop]
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
        local my_shop_data = ShopData[shop]


            if GetItemType(item) == ITEM_TYPE_CHARGED then
                local id = GetItemTypeId(item)
                    for i = 1, MAXIMUM_ITEMS do
                        if my_shop_data.item_list[i].item and id == GetItemTypeId(my_shop_data.item_list[i].item) then
                            if my_shop_data.item_list[i].perm then
                                RemoveCustomItem(item)
                                return true
                            else
                                SetItemCharges(my_shop_data.item_list[i].item, GetItemCharges(item) + GetItemCharges(my_shop_data.item_list[i].item))
                                UpdateShopWindow()
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
                    if item_data.quality_effect then BlzSetSpecialEffectAlpha(item_data.quality_effect, 0) end
                    if item_data.quality_effect_light then DestroyEffect(item_data.quality_effect_light, 0) end

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
        local my_shop_data = ShopData[shop]

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
            elseif my_shop_data.item_list[slot].item and GetItemType(item) == ITEM_TYPE_CHARGED and GetItemTypeId(item) == GetItemTypeId(my_shop_data.item_list[slot].item) then
                SetItemCharges(my_shop_data.item_list[slot].item, GetItemCharges(my_shop_data.item_list[slot].item) + GetItemCharges(item))
                --my_shop_data.item_list[slot].charges = my_shop_data.item_list[slot].charges + GetItemCharges(item)
                RemoveCustomItem(item)
                UpdateShopWindow()
            end

    end

    local FirstTime_Data


    ---@param unit_owner unit
    ---@param texture string
    function CreateShop(unit_owner, name, texture, soundpack)
        local handle = unit_owner

            ShopData[handle] = {}
            ShopData[handle].item_list = {}
            ShopData[handle].soundpack = soundpack or nil


            for i = 1, MAXIMUM_ITEMS do
                ShopData[handle].item_list[i] = {}
                ShopData[handle].item_list[i].item = nil
                ShopData[handle].item_list[i].perm = false
            end

            BlzSetUnitName(handle, name)


            CreateNpcData(handle, name)

            if not FirstTime_Data then

                FirstTime_Data = {
                    [1] = { first_time = true },
                    [2] = { first_time = true },
                    [3] = { first_time = true },
                    [4] = { first_time = true },
                    [5] = { first_time = true },
                    [6] = { first_time = true }
                }

                for i = 1, 6 do
                    if GetLocalPlayer() == Player(i-1) then
                        FirstTime_Data[i].effect = AddSpecialEffectTarget("Quest\\ExcMark_Green_FlightPath.mdx ", unit_owner, "overhead")
                    else
                        FirstTime_Data[i].effect = AddSpecialEffectTarget("", unit_owner, "overhead")
                    end
                end

            end

            AddSpecialEffectTarget("Marker\\VendorIcon.mdx", unit_owner, "overhead")


        AddInteractiveOption(handle, { name = GetLocalString("Торговать", "Trade"), id = "trade_conv", feedback = function(clicked, clicking, player)
            if not IsUnitHidden(clicked) then
                local id = player - 1

                    if player <= 6 then

                        ShopInFocus[player] = clicked
                        if GetLocalPlayer() == Player(id) then BlzFrameSetVisible(ShopFrame[player].main_frame, true) end
                        ShopFrame[player].state = true
                        BlzFrameSetTexture(ShopFrame[player].portrait, texture, 0, true)
                        BlzFrameSetText(ShopFrame[player].name, GetUnitName(clicked))
                        UpdateShopWindow()

                        SetUIState(player, SKILL_PANEL, false)
                        SetUIState(player, CHAR_PANEL, false)
                        SetUIState(player, TALENT_PANEL, false)

                        if soundpack then
                            PlayLocalSound(soundpack.open[GetRandomInt(1, #soundpack.open)], id, 125)
                        end

                            local timer = CreateTimer()
                            TimerStart(timer, 0.1, true, function()
                                if not IsUnitInRange(clicking, clicked, 250.) or IsUnitHidden(clicked) or GetUnitState(clicking, UNIT_STATE_LIFE) < 0.045 then
                                    ShopFrame[player].in_focus = nil
                                    DestroySlider(player)
                                    DestroyContextMenu(player)
                                    ShopInFocus[player] = nil
                                    ShopFrame[player].state = false
                                    TimerStart(last_EnteredFrameTimer[player], 0., false, nil)
                                    if GetLocalPlayer() == Player(id) then BlzFrameSetVisible(ShopFrame[player].main_frame, false) end
                                    DestroyTimer(GetExpiredTimer())
                                    if soundpack then
                                        PlayLocalSound(soundpack.close[GetRandomInt(1, #soundpack.open)], id, 125)
                                    end
                                end
                            end)



                        if FirstTime_Data[player].first_time then
                            DestroyEffect(FirstTime_Data[player].effect)
                            FirstTime_Data[player].first_time = false
                        end

                    end
                end
        end
        })

        return ShopData[handle]
    end


    function InitShopData()

        ShopFrame = {}
        ShopInFocus = {}
        ShopData = {}

        last_EnteredFrame = {}
        last_EnteredFrameTimer = {}

        for i = 1, 6 do
            last_EnteredFrameTimer[i] = CreateTimer()
        end

        LeaveTrigger = CreateTrigger()
        EnterTrigger = CreateTrigger()
        ClickTrigger = CreateTrigger()

        --TriggerAddAction(LeaveTrigger, LeaveAction)
        TriggerAddAction(EnterTrigger, EnterAction)
        TriggerAddAction(ClickTrigger, ShopSlot_Clicked)
    end

end