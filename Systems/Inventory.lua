do

    PlayerInventoryFrame = 0
    PlayerInventoryFrameState = 0
    InventoryData = nil
    InventorySlots = 0
    InventoryOwner = 0
    InventoryTooltip = 0
    InventoryAlternateTooltip = 0
    InventoryTriggerButton = 0
    InventoryItemInFocus = nil
    InventoryKeyState = nil
    INV_SLOT = 0
    local ClickTrigger = 0




    function GetWeaponAnimationTag(weapon_type)
        if weapon_type == FIST_WEAPON then
            return ANIM_TAG_FISTS
        elseif weapon_type == SWORD_WEAPON or weapon_type == AXE_WEAPON or weapon_type == BLUNT_WEAPON or weapon_type == DAGGER_WEAPON then
            return ANIM_TAG_ONEHANDED
        elseif weapon_type == GREATSWORD_WEAPON or weapon_type == GREATAXE_WEAPON or weapon_type == GREATBLUNT_WEAPON then
            return ANIM_TAG_TWOHANDED
        elseif weapon_type == STAFF_WEAPON or weapon_type == JAWELIN_WEAPON then
            return ANIM_TAG_STAFF
        elseif weapon_type == BOW_WEAPON then
            return ANIM_TAG_BOW
        end
    end


    local function GetFirstFreeSlotButton(player)
        for i = 1, 32 do
            --local h = GetHandleId(InventorySlots[player][i])

            if ButtonList[InventorySlots[player][i]].item == nil then
                return ButtonList[InventorySlots[player][i]]
            end

        end
        return nil
    end


    local DoubleClickTimer = 0
    local UNIT_POINT_LIST = 0
    local POINT_TO_TYPE = 0


    ---@param point number
    ---@param type number
    function IsItemPointEqualToType(point, type)

        if point == WEAPON_POINT or point == OFFHAND_POINT then
            for i = 1, #POINT_TO_TYPE[point] do
                if POINT_TO_TYPE[point][i] == type then return true end
            end
            return false
        end

        return POINT_TO_TYPE[point] == type
    end


    HeroSpeechFeedbacks = 0


    function Feedback_Health(player)
        --SimError(LOCALE_LIST[my_locale].FEEDBACK_MSG_NOGOLD, player-1)

        if HeroSpeechFeedbacks[player].state then
            local snd = PlayLocalSound(LOCALE_LIST[my_locale].FEEDBACK_HEAL[GetUnitClass(PlayerHero[player])][GetRandomInt(1, 5)], player-1, 110)
            HeroSpeechFeedbacks[player].state = false
            TimerStart(HeroSpeechFeedbacks[player].timer, 1.7, false, function() HeroSpeechFeedbacks[player].state = true end)
        end
    end

    function Feedback_NoGold(player)
        SimError(LOCALE_LIST[my_locale].FEEDBACK_MSG_NOGOLD, player-1)

        if HeroSpeechFeedbacks[player].state then
            local snd = PlayLocalSound(LOCALE_LIST[my_locale].FEEDBACK_GOLD[GetUnitClass(PlayerHero[player])][GetRandomInt(1, 5)], player-1, 128)
            HeroSpeechFeedbacks[player].state = false
            TimerStart(HeroSpeechFeedbacks[player].timer, 1.7, false, function() HeroSpeechFeedbacks[player].state = true end)
        end
    end

    function Feedback_InventoryNoSpace(player)
        SimError(LOCALE_LIST[my_locale].FEEDBACK_MSG_NOSPACE, player-1)

        if HeroSpeechFeedbacks[player].state then
            local snd = PlayLocalSound(LOCALE_LIST[my_locale].FEEDBACK_BAG[GetUnitClass(PlayerHero[player])][GetRandomInt(1, 5)], player-1, 128)
            HeroSpeechFeedbacks[player].state = false
            TimerStart(HeroSpeechFeedbacks[player].timer, 1.7, false, function() HeroSpeechFeedbacks[player].state = true end)
        end
    end



    function Feedback_CantUse(player)
        SimError(LOCALE_LIST[my_locale].FEEDBACK_MSG_CANTUSE, player-1)

        if HeroSpeechFeedbacks[player].state then
            local snd = PlayLocalSound(LOCALE_LIST[my_locale].FEEDBACK_CLASSRESTRICTED[GetUnitClass(PlayerHero[player])][GetRandomInt(1, 4)], player-1, 128)
            HeroSpeechFeedbacks[player].state = false
            TimerStart(HeroSpeechFeedbacks[player].timer, 1.7, false, function() HeroSpeechFeedbacks[player].state = true end)
        end
    end

    function Feedback_NoResource(player)
        --SimError(LOCALE_LIST[my_locale].FEEDBACK_MSG_NORESOURCE, player-1)

        if HeroSpeechFeedbacks[player].state then
            local snd = PlayLocalSound(LOCALE_LIST[my_locale].FEEDBACK_NORESOURCE[GetUnitClass(PlayerHero[player])][GetRandomInt(1, 3)], player-1, 128)
            HeroSpeechFeedbacks[player].state = false
            TimerStart(HeroSpeechFeedbacks[player].timer, 1.7, false, function() HeroSpeechFeedbacks[player].state = true end)
        end
    end


    function UpdateEquipPointsWindow(player)
        local unit_data = GetUnitData(InventoryOwner[player])
        local last_tag = unit_data.animation_tag


            if not unit_data.classic_model then

                unit_data.animation_tag = GetWeaponAnimationTag(unit_data.equip_point[WEAPON_POINT].SUBTYPE)

                if unit_data.animation_tag ~= last_tag then
                    AddUnitAnimationProperties(PlayerHero[player], last_tag or "", false)
                    AddUnitAnimationProperties(PlayerHero[player], unit_data.animation_tag, true)
                end

                if unit_data.equip_point[OFFHAND_POINT] and unit_data.equip_point[OFFHAND_POINT].TYPE == ITEM_TYPE_WEAPON then
                    AddUnitAnimationProperties(PlayerHero[player], "Victory", true)
                else
                    AddUnitAnimationProperties(PlayerHero[player], "Victory", false)
                end
            end

            --print("equip points start")
            for i = WEAPON_POINT, NECKLACE_POINT do
                --print("point " .. i)
                local button = ButtonList[InventorySlots[player][UNIT_POINT_LIST[i]]]

                    if unit_data.equip_point[i] and unit_data.equip_point[i].SUBTYPE ~= FIST_WEAPON then
                        --print("update!")
                        local item_data = GetItemData(unit_data.equip_point[i].item)
                        button.item = item_data.item
                        BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                        FrameChangeTexture(button.button, item_data.frame_texture)

                    else
                       -- print("cleanse!")
                        button.item = nil
                        BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                        FrameChangeTexture(button.button, button.original_texture)
                        --local weapon_button = ButtonList[GetHandleId(InventorySlots[player][33])]
                    end

            end

        --print("equip points updated")
        if unit_data.equip_point[WEAPON_POINT].item then
            --print("weapon exists")
            local item_data = GetItemData(unit_data.equip_point[WEAPON_POINT].item)
            local button = ButtonList[InventorySlots[player][34]]

            --("loaded")
                if IsWeaponTypeTwohanded(item_data.SUBTYPE) and item_data.SUBTYPE ~= BOW_WEAPON then
                    --print("twohanded")
                    BlzFrameSetTexture(button.image, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp", 0, true)
                    FrameChangeTexture(button.button, "ReplaceableTextures\\CommandButtons\\BTNCancel.blp")
                elseif not unit_data.equip_point[OFFHAND_POINT] or not unit_data.equip_point[OFFHAND_POINT].item then
                    --print("no offhand")
                    BlzFrameSetTexture(button.image, "GUI\\BTNWeapon_Slot.blp", 0, true)
                    FrameChangeTexture(button.button, button.original_texture)
                end

        end


    end

    function UpdateInventoryWindow(player)
        --print("UpdateInventoryWindow started")
        if InventoryOwner[player] ~= nil then
        --print("UpdateInventoryWindow unit exists")
            for i = 1, 32 do
                --print("UpdateInventoryWindow index " .. I2S(i))
                local button = ButtonList[InventorySlots[player][i]]
                --print("yep")
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

                                    if button.button_state then
                                        if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, false) end
                                        --BlzFrameSetEnable(button.sprite, false)
                                        button.button_state = false
                                        --BlzDestroyFrame(button.sprite)
                                        --button.sprite = nil
                                    end

                                RemoveCustomItem(button.item)
                                button.item = nil

                            else
                                button.charges_frame_state = true
                                if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.charges_frame, true) end
                                BlzFrameSetText(button.charges_text_frame, R2I(GetItemCharges(button.item)))

                                    if button.button_state and not IsItemInvulnerable(button.item) then
                                        if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, false) end
                                        --BlzFrameSetEnable(button.sprite, false)
                                        button.button_state = false
                                        --BlzDestroyFrame(button.sprite)
                                        --button.sprite = nil
                                    elseif not button.button_state and IsItemInvulnerable(button.item) then
                                        if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, true) end
                                        --BlzFrameSetEnable(button.sprite, true)
                                        button.button_state = true
                                    end

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

                        if button.button_state then
                            if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, false) end
                            --BlzFrameSetEnable(button.sprite, false)
                            button.button_state = false
                            --BlzDestroyFrame(button.sprite)
                            --button.sprite = nil
                        end

                end
            end

        end
    end



    --======================================================================
    -- BELT LOCK   =========================================================

    local FirstTime_Data_Belt = 0

    local function LockItemOnBelt(player, button)
        if not button.button_state then
            if UnitInventoryCount(InventoryOwner[player]) < 6 then
                --button.sprite = BlzCreateFrameByType("SPRITE", "justAName", button.image, "WarCraftIIILogo", 0)
                --BlzFrameClearAllPoints()
                --BlzFrameSetPoint(button.sprite, FRAMEPOINT_BOTTOMLEFT, button.image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
                --BlzFrameSetSize(button.sprite, 1., 1.)
                --BlzFrameSetScale(button.sprite, 1.)

                --BlzFrameSetModel(button.sprite, "selecter3.mdx", 0)
                if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, true) end
                --BlzFrameSetEnable(button.sprite, true)
                button.button_state = true
                PlayLocalSound("Sound\\Interface\\AutoCastButtonClick1.wav", player-1)

                SetItemVisible(button.item, true)
                SetItemInvulnerable(button.item, true)
                UnitAddItem(PlayerHero[player], button.item)

                if FirstTime_Data_Belt[player].first_time then
                    ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_BELT, player-1)
                    FirstTime_Data_Belt[player].first_time = false
                    AddJournalEntry(player, "hints", "UI\\BTNLeatherbound_TomeI.blp", GetLocalString("Подсказки", "Hints and Tips"), 1000)
                    AddJournalEntryText(player, "hints", QUEST_HINT_STRING .. LOCALE_LIST[my_locale].HINT_BELT, true)
                end

            else
                Feedback_CantUse(player)
            end
        else
            if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(button.sprite, false) end
            --BlzFrameSetEnable(button.sprite, false)
            button.button_state = false
            --BlzDestroyFrame(button.sprite)
            SetItemInvulnerable(button.item, false)
            UnitRemoveItem(PlayerHero[player], button.item)
            SetItemVisible(button.item, false)
            --button.sprite = nil
        end
    end



     function GetItemToCompare(item, player)
        local unit_data = GetUnitData(PlayerHero[player])
        local item_data = GetItemData(item)
        local point


            if item_data.TYPE == ITEM_TYPE_WEAPON then
                if AltState[player] then point = OFFHAND_POINT
                else point = WEAPON_POINT end
            elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                if item_data.SUBTYPE == CHEST_ARMOR then point = CHEST_POINT
                elseif item_data.SUBTYPE == HEAD_ARMOR then point = HEAD_POINT
                elseif item_data.SUBTYPE == HANDS_ARMOR then point = HANDS_POINT
                elseif item_data.SUBTYPE == LEGS_ARMOR then point = LEGS_POINT
                elseif item_data.SUBTYPE == BELT_ARMOR then point = BELT_POINT end
            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                if item_data.SUBTYPE == NECKLACE_JEWELRY then point = NECKLACE_POINT
                else
                    if AltState[player] then point = RING_2_POINT
                    else point = RING_1_POINT end
                end
            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                point = OFFHAND_POINT
            end

        if unit_data.equip_point[point] and unit_data.equip_point[point].item then
            return unit_data.equip_point[point].item
        end

        return nil
    end


    function ShowAlternateInventoryTooltip(player)

        if IsTooltipActive(player) then
            local item_to_compare = GetItemToCompare(InventoryItemInFocus[player].item, player)
                if item_to_compare and item_to_compare ~= InventoryItemInFocus[player].item then
                    local proper_tooltip = InventoryTooltip[player]
                    local proper_alternate_tooltip = InventoryAlternateTooltip[player]

                    if ShopFrame[player].state then
                        proper_tooltip = ShopFrame[player].tooltip;
                        proper_alternate_tooltip = ShopFrame[player].alternate_tooltip
                    end

                    ShowItemTooltip(item_to_compare, proper_alternate_tooltip, InventoryItemInFocus[player], player, FRAMEPOINT_LEFT, GetTooltip(proper_alternate_tooltip), true, InventoryItemInFocus[player].item)
                    BlzFrameClearAllPoints(proper_alternate_tooltip)
                    BlzFrameSetPoint(proper_alternate_tooltip, FRAMEPOINT_RIGHT, proper_tooltip, FRAMEPOINT_LEFT, 0., 0.)
                end
        end

    end
    


    local PlayerMovingItem = 0
    local EnterTrigger = 0
    local LeaveTrigger = 0


    local function EnterAction()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local frame = BlzGetTriggerFrame()
        --local h = GetHandleId()
        --print("Entering trigger "..GetHandleId(GetTriggeringTrigger()))

            if PlayerMovingItem[player].state then
                BlzFrameSetAllPoints(PlayerMovingItem[player].frame, ButtonList[frame].image)
                local scale = 0.0415
                if PlayerMovingItem[player].mode == 2 then scale = 0.035 end
                BlzFrameSetSize(PlayerMovingItem[player].frame, scale, scale)
            else
                if ButtonList[frame].item then
                    InventoryItemInFocus[player] = ButtonList[frame]
                    local proper_tooltip = InventoryTooltip[player]

                    if ShopFrame[player].state then proper_tooltip = ShopFrame[player].tooltip end

                    ShowItemTooltip(ButtonList[frame].item, proper_tooltip, ButtonList[frame], player, FRAMEPOINT_LEFT, GetTooltip(InventoryTooltip[player]))

                    if InventoryKeyState[player] then
                        RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                        RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                        ShowAlternateInventoryTooltip(player)
                    end
                    --ShowTooltip(player, h, FRAMEPOINT_LEFT, MASTER_FRAME)--ButtonList[GetHandleId(InventorySlots[32])].image)
                else
                    InventoryItemInFocus[player] = nil
                    RemoveTooltip(player)
                end
            end

    end

    local function LeaveAction()
        InventoryItemInFocus[GetPlayerId(GetTriggerPlayer()) + 1] = nil
        RemoveTooltip(GetPlayerId(GetTriggerPlayer()) + 1)
    end



    --======================================================================
    -- SELECTOION MODE =====================================================

    function RemoveSelectionFrames(player)

            if PlayerMovingItem[player].state then
                PlayerMovingItem[player].state = false

                if PlayerMovingItem[player].selected_frame and ButtonList[PlayerMovingItem[player].selected_frame].button_state then
                    if GetLocalPlayer() == Player(player - 1) then
                        BlzFrameSetVisible(ButtonList[PlayerMovingItem[player].selected_frame].sprite, true)
                    end
                end

                PlayerMovingItem[player].selected_frame = nil
                PlayerMovingItem[player].mode = 0

                if GetLocalPlayer() == Player(player - 1) then
                    BlzFrameSetVisible(PlayerMovingItem[player].frame, false)
                    BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, false)
                end

            end

    end



    local SELECTION_MODE_MOVE = 1
    local SELECTION_MODE_ENCHANT = 2


    local function CreateSelectionFrames(player)
        PlayerMovingItem[player] = {
            frame = nil,
            selector_frame = nil,
            selected_frame = nil,
            mode = 0
        }
        PlayerMovingItem[player].selector_frame = BlzCreateFrameByType("SPRITE", "justAName", ButtonList[InventorySlots[player][32]].image, "WarCraftIIILogo", 0)
        BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, ButtonList[InventorySlots[player][32]].image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetSize(PlayerMovingItem[player].selector_frame, 1., 1.)
        BlzFrameSetScale(PlayerMovingItem[player].selector_frame, 1.)
        PlayerMovingItem[player].frame = BlzCreateFrameByType("BACKDROP", "selection frame", PlayerMovingItem[player].selector_frame, "", 0)
        PlayerMovingItem[player].state = false
        if GetLocalPlayer() == Player(player - 1) then
            BlzFrameSetVisible(PlayerMovingItem[player].frame, false)
            BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, false)
        end
    end

    local function StartSelectionMode(player, h, mode)
        local item_data = GetItemData(ButtonList[h].item)

            --PlayerMovingItem[player] = { frame = nil, selector_frame = nil, selected_frame = h, mode = mode }
            PlayerMovingItem[player].state = true
            --PlayerMovingItem[player].selector_frame = BlzCreateFrameByType("SPRITE", "justAName", ButtonList[GetHandleId(InventorySlots[player][32])].image, "WarCraftIIILogo", 0)
            PlayerMovingItem[player].selected_frame = h -- = { frame = nil, selector_frame = nil, selected_frame = h, mode = mode }
            PlayerMovingItem[player].mode = mode
            BlzFrameClearAllPoints(PlayerMovingItem[player].selector_frame)

            if GetLocalPlayer() == Player(player - 1) then
                BlzFrameSetVisible(PlayerMovingItem[player].frame, true)
                BlzFrameSetVisible(PlayerMovingItem[player].selector_frame, true)
            end

            BlzFrameSetPoint(PlayerMovingItem[player].selector_frame, FRAMEPOINT_BOTTOMLEFT, ButtonList[h].image, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)


            if ButtonList[h].button_state then if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(ButtonList[h].sprite, false) end end


            BlzFrameClearAllPoints(PlayerMovingItem[player].frame)
            BlzFrameSetTexture(PlayerMovingItem[player].frame, item_data.frame_texture, 0, true)
            BlzFrameSetAllPoints(PlayerMovingItem[player].frame, ButtonList[h].image)

                if mode == SELECTION_MODE_MOVE then
                    BlzFrameSetSize(PlayerMovingItem[player].frame, 0.041, 0.041)
                    BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter4.mdx", 0)
                else
                    BlzFrameSetSize(PlayerMovingItem[player].frame, 0.035, 0.035)
                    BlzFrameSetModel(PlayerMovingItem[player].selector_frame, "selecter5.mdx", 0)
                end

            BlzFrameSetAlpha(PlayerMovingItem[player].frame, 175)
            InventoryItemInFocus[player] = nil
            RemoveTooltip(player)

    end





    local function CanEquipOffhand(item, equipped_item)
        local item_data = GetItemData(item)
        local item_button_data = GetItemData(equipped_item)

            if item_data.SUBTYPE == QUIVER_OFFHAND and item_button_data.SUBTYPE ~= BOW_WEAPON then
                return false
            elseif (item_data.SUBTYPE == ORB_OFFHAND or item_data.SUBTYPE == SHIELD_OFFHAND or item_data.TYPE == ITEM_TYPE_WEAPON) and IsWeaponTypeTwohanded(item_button_data.SUBTYPE) then
                return false
            end

        return true
    end

    local function OffhandPointCheck(item, player, target_slot)
        local item_data = GetItemData(item)
        local unit_Data = GetUnitData(InventoryOwner[player])
        local offhand_point = unit_Data.equip_point[OFFHAND_POINT]

            --print("checking " .. GetItemName(item))
            --print("type is  " .. GetItemTypeName(item_data.TYPE))
            --print("subtype is  " .. GetItemSubTypeName(item_data.SUBTYPE))
            --print("item in weapon point is  " .. GetItemName(unit_Data.equip_point[WEAPON_POINT].item))
            --print("item in offhand point is  " .. GetItemName(unit_Data.equip_point[OFFHAND_POINT].item))


            if (item_data.TYPE == ITEM_TYPE_OFFHAND or (item_data.TYPE == ITEM_TYPE_WEAPON and target_slot)) and unit_Data.equip_point[WEAPON_POINT].item and not CanEquipOffhand(item, unit_Data.equip_point[WEAPON_POINT].item) then
                Feedback_CantUse(player)
                return false
            elseif offhand_point and (IsWeaponTypeTwohanded(item_data.SUBTYPE) or (item_data.SUBTYPE ~= BOW_WEAPON and unit_Data.equip_point[OFFHAND_POINT].SUBTYPE == QUIVER_OFFHAND)) then
                if CountFreeBagSlots(player) == 0 then
                    Feedback_InventoryNoSpace(player)
                    return false
                else
                    local free_slot = GetFirstFreeSlotButton(player)
                    free_slot.item = unit_Data.equip_point[OFFHAND_POINT].item
                    --print(GetItemName(unit_Data.equip_point[OFFHAND_POINT].item))
                    EquipItem(InventoryOwner[player], unit_Data.equip_point[OFFHAND_POINT].item, false, true)
                end
            end

        return true
    end


    local function InteractWithItemInSlot(h, id, offhand)
        local item_data = GetItemData(ButtonList[h].item)

            if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then

                if ButtonList[h].button_type == INV_SLOT then

                        if not OffhandPointCheck(ButtonList[h].item, id, offhand) then return end

                        local unequipped_item = EquipItem(InventoryOwner[id], ButtonList[h].item, true, offhand)

                        if item_data.soundpack and item_data.soundpack.equip then PlayLocalSound(item_data.soundpack.equip, id - 1) end
                       -- print("interact")

                        ButtonList[h].item = unequipped_item
                        UpdateEquipPointsWindow(id)
                        UpdateInventoryWindow(id)
                elseif ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT then
                    if CountFreeBagSlots(id) == 0 then
                        Feedback_InventoryNoSpace(id)
                    else
                        EquipItem(InventoryOwner[id], ButtonList[h].item, false, (ButtonList[h].button_type == OFFHAND_POINT and item_data.TYPE == ITEM_TYPE_WEAPON))
                        if item_data.soundpack ~= nil and item_data.soundpack.uneqip ~= nil then PlayLocalSound(item_data.soundpack.uneqip, id - 1) end
                        --print("interact2")

                        local free_slot = GetFirstFreeSlotButton(id)
                        free_slot.item = ButtonList[h].item
                        UpdateEquipPointsWindow(id)
                        UpdateInventoryWindow(id)
                    end
                end

            end

    end


    local function ForceEquip(h, player, offhand)
        local selected_item = ButtonList[PlayerMovingItem[player].selected_frame].item
        local item_data = GetItemData(selected_item)

            if (ButtonList[h].button_type >= WEAPON_POINT and ButtonList[h].button_type <= NECKLACE_POINT) and IsItemPointEqualToType(ButtonList[h].button_type, item_data.SUBTYPE) then

                if not OffhandPointCheck(selected_item, player, offhand) then return end

                local unequipped_item = EquipItem(InventoryOwner[player], selected_item, true, offhand) or nil

                if item_data.soundpack and item_data.soundpack.equip then PlayLocalSound(item_data.soundpack.equip, player - 1) end
                --print("force")

                --if unequipped_item then
                 --   local free_slot = GetFirstFreeSlotButton(player)
                 --   free_slot.item = ButtonList[h].item
               -- end

                ButtonList[PlayerMovingItem[player].selected_frame].item = unequipped_item or nil
                UpdateEquipPointsWindow(player)
                UpdateInventoryWindow(player)

            else
                Feedback_CantUse(player)
            end

    end


    local function Socket(stone, item, player, slot)
        local stone_data = GetItemData(stone)
        local item_data = GetItemData(item)


            if item_data.MAX_SLOTS ~= #item_data.STONE_SLOTS then

                for i = 1, item_data.MAX_SLOTS do
                    if item_data.STONE_SLOTS[i] == nil then
                        local flag = slot.button_type >= WEAPON_POINT and slot.button_type <= NECKLACE_POINT

                        if flag then EquipItem(InventoryOwner[player], item, false, (item_data.TYPE == ITEM_TYPE_WEAPON and slot.button_type == OFFHAND_POINT)) end

                        item_data.STONE_SLOTS[i] = stone_data
                        if flag then EquipItem(InventoryOwner[player], item, true, (item_data.TYPE == ITEM_TYPE_WEAPON and slot.button_type == OFFHAND_POINT)) end


                        if GetItemCharges(stone) - 1 <= 0 then RemoveItemFromInventory(player, stone)
                        else SetItemCharges(stone, GetItemCharges(stone) - 1) end

                        RemoveSelectionFrames(player)
                        UpdateInventoryWindow(player)
                        UpdateBlacksmithWindow(player)
                        break
                    end
                end

                PlayLocalSound("Sounds\\UI\\Socket".. GetRandomInt(1,2) ..".wav", player-1, 100)
            else
                Feedback_CantUse(player)
            end

    end


    local function LearnBook(item, player)
        local item_data = GetItemData(item)

        if item_data.improving_skill and item_data.improving_skill == "invalid" then
            RemoveItemFromInventory(player, item)
        end

            if item_data.restricted_to and item_data.restricted_to ~= GetUnitClass(PlayerHero[player]) then
                Feedback_CantUse(player)
                return
            end

            DestroyEffect(AddSpecialEffectTarget(item_data.learn_effect, PlayerHero[player], "origin"))

            if item_data.improving_skill then
                local points = item_data.QUALITY == RARE_ITEM and 3 or 1

                    if not UnitAddMyAbility(PlayerHero[player], item_data.improving_skill) then
                        UnitAddAbilityLevel(PlayerHero[player], item_data.improving_skill, points)
                    else
                        UnitAddAbilityLevel(PlayerHero[player], item_data.improving_skill, points-1)
                    end

                if SkillPanelFrame[player].state then UpdateSkillList(player) end

            elseif item_data.bonus_points then
                AddPointsToPlayer(player, item_data.bonus_points)
                --ShowQuestAlert(LOCALE_LIST[my_locale].QUEST_REWARD_POINTS_FIRST .. item_data.bonus_points .. LOCALE_LIST[my_locale].QUEST_REWARD_POINTS_SECOND)
            end


            RemoveItemFromInventory(player, item)
    end


    local function UseItem(item, player)
        local item_data = GetItemData(item)

            OnItemUse(PlayerHero[player], item, PlayerHero[player])

            if GetItemType(item) == ITEM_TYPE_CHARGED then RemoveChargesFromInventoryItem(player, item, 1)
            elseif not item_data.permanent then RemoveItemFromInventory(player, item) end

    end


    function SplitChargedItem(item, count, player)
            SetItemCharges(item, GetItemCharges(item) - count)
            local new_item = CreateCustomItem_Id(GetItemTypeId(item), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
            GenerateItemLevel(new_item, 1)
            SetItemCharges(new_item, count)
        --print("compare charges - " .. count .. " and " .. GetItemCharges(new_item))
        return new_item
    end




    -- ========================= CLICK ============================= --

    local function InventorySlot_Clicked()
        local player = GetPlayerId(GetTriggerPlayer()) + 1
        local h = BlzGetTriggerFrame()
        local item_data = GetItemData(ButtonList[h].item) or nil


        RemovePrivateChestSelectionFrames(player)

        if TimerGetRemaining(DoubleClickTimer[player].timer) > 0. then
            if ButtonList[h].item then
                --print("doubleclick")
                RemoveSelectionFrames(player)
                InventoryItemInFocus[player] = nil
                RemoveTooltip(player)
                DestroyContextMenu(player)

                    if item_data.TYPE == ITEM_TYPE_CONSUMABLE then LockItemOnBelt(player, ButtonList[h])
                    elseif item_data.TYPE == ITEM_TYPE_GEM then StartSelectionMode(player, h, SELECTION_MODE_ENCHANT)
                    elseif item_data.TYPE == ITEM_TYPE_SKILLBOOK then if item_data and item_data.item then LearnBook(item_data.item, player) end
                    elseif item_data.usable and item_data.item then UseItem(item_data.item, player)
                    elseif item_data.TYPE ~= ITEM_TYPE_OTHER then InteractWithItemInSlot(h, player) end

                --DoubleClickTimer[player].locked = true

                TimerStart(DoubleClickTimer[player].timer, 0., false, nil)

            end
        else
            TimerStart(DoubleClickTimer[player].timer, 0.25, false, function()
                InventoryItemInFocus[player] = nil
                RemoveSelectionFrames(player)
                local item_data = GetItemData(ButtonList[h].item) or nil

                if ButtonList[h].item and not PlayerMovingItem[player].state and ButtonList[h].button_type == INV_SLOT then
                    CreatePlayerContextMenu(player, ButtonList[h].button, FRAMEPOINT_LEFT, InventorySlots[player][45])

                        if ShopInFocus[player] and item_data.sellable then
                            AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_SELL, function()
                                if ShopInFocus[player] then

                                    if GetItemCharges(ButtonList[h].item) > 1 then
                                        CreateSlider(player, ButtonList[h], ButtonList[InventorySlots[player][32]].image, function()
                                            local value = SliderFrame[player].value
                                            --local value = BlzFrameGetValue(SliderFrame[player].slider)
                                            --print("item charges are " .. GetItemCharges(ButtonList[h].item))
                                            --print("frame value is " .. value)


                                            if value < GetItemCharges(ButtonList[h].item) then
                                                local new_item = SplitChargedItem(ButtonList[h].item, value, player)
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


                    if BlacksmithFrame[player].state and (item_data.TYPE == ITEM_TYPE_OFFHAND or item_data.TYPE == ITEM_TYPE_WEAPON or item_data.TYPE == ITEM_TYPE_ARMOR or item_data.TYPE == ITEM_TYPE_JEWELRY) then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_REFORGE, function() if ButtonList[h].item then GiveItemToBlacksmith(player, ButtonList[h].item, BLACKSMITH_REFORGE) end end)
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_RESOCKET, function() if ButtonList[h].item then GiveItemToBlacksmith(player, ButtonList[h].item, BLACKSMITH_RESOCKET) end end)
                    elseif PrivateChestFrame[player].state and item_data.droppable then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_TO_STASH, function()
                            if IsPlayerHasItem(player, ButtonList[h].item) then
                                if AddToPrivateChest(player, ButtonList[h].item) then
                                    if IsItemInvulnerable(ButtonList[h].item) then LockItemOnBelt(player, ButtonList[h]) end
                                    ButtonList[h].item = nil
                                    UpdateInventoryWindow(player)
                                end
                            end
                        end)
                    elseif StashFrame[player].state and item_data.flippy then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_TO_STASH, function()
                            if IsPlayerHasItem(player, ButtonList[h].item) then
                                if AddToStash(player, ButtonList[h].item) then
                                    ButtonList[h].item = nil
                                    UpdateInventoryWindow(player)
                                    UpdateStashWindow(player)
                                end
                            end
                        end)
                    elseif LibrarianFrame[player].state and item_data.restricted_to then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_EXCHANGE, function() GiveItemToLibrarian(player, ButtonList[h].item) end)
                    end

                    if item_data.TYPE == ITEM_TYPE_WEAPON and not IsWeaponTypeTwohanded(item_data.SUBTYPE)  then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_ALT_WEAPON, function() InteractWithItemInSlot(h, player, true) end)
                    end

                    

                    if item_data.TYPE == ITEM_TYPE_GEM then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_ENCHANT, function() StartSelectionMode(player, h, SELECTION_MODE_ENCHANT) end)
                    elseif item_data.TYPE == ITEM_TYPE_CONSUMABLE then
                        AddContextOption(player, ButtonList[h].button_state and LOCALE_LIST[my_locale].UI_TEXT_BELT_OFF or LOCALE_LIST[my_locale].UI_TEXT_BELT_ON, function() LockItemOnBelt(player, ButtonList[h]) end)
                    elseif item_data.TYPE == ITEM_TYPE_SKILLBOOK then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_LEARN, function() if item_data and item_data.item then LearnBook(item_data.item, player) end end)
                    elseif item_data.usable then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_USE, function() if item_data and item_data.item then UseItem(item_data.item, player) end end)
                    elseif item_data.TYPE ~= ITEM_TYPE_OTHER then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_EQUIP, function() InteractWithItemInSlot(h, player) end)
                    end

                    AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_MOVE, function() StartSelectionMode(player, h, SELECTION_MODE_MOVE) end)

                    if item_data.droppable then
                        AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_DROP, function()

                            if GetItemType(ButtonList[h].item) ~= ITEM_TYPE_CHARGED then
                                DropItemFromInventory(player, ButtonList[h].item, false)
                            else
                                if GetItemCharges(ButtonList[h].item) > 1 then
                                    CreateSlider(player, ButtonList[h], ButtonList[InventorySlots[player][32]].image, function()
                                        local value = SliderFrame[player].value
                                        if value < GetItemCharges(ButtonList[h].item) then
                                            SetItemCharges(ButtonList[h].item, GetItemCharges(ButtonList[h].item) - value)
                                            local new_item = CreateCustomItem_Id(GetItemTypeId(ButtonList[h].item), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
                                            SetItemCharges(new_item, value)
                                            if item_data.soundpack and item_data.soundpack.drop then
                                                AddSoundVolumeZ(item_data.soundpack.drop, GetItemX(new_item), GetItemY(new_item), 25., 127, 1100.)
                                            end
                                            --print("bbbb")
                                        else
                                            --print("aaa")
                                            DropItemFromInventory(player, ButtonList[h].item, false)
                                        end
                                        UpdateInventoryWindow(player)

                                    end, nil)
                                else
                                    DropItemFromInventory(player, ButtonList[h].item, false)
                                    --print("ccccccc")
                                end
                            end

                        end)
                    end

                end
            end)

            DestroySlider(player)
            DestroyContextMenu(player)

            if PlayerMovingItem[player].state then
                TimerStart(DoubleClickTimer[player].timer, 0., false, nil)
                local moved_item_data = GetItemData(ButtonList[PlayerMovingItem[player].selected_frame].item)

                    if PlayerMovingItem[player].mode == SELECTION_MODE_ENCHANT then
                            if ButtonList[h].item then
                                if item_data.TYPE >= ITEM_TYPE_WEAPON and item_data.TYPE <= ITEM_TYPE_OFFHAND then
                                    Socket(ButtonList[PlayerMovingItem[player].selected_frame].item, ButtonList[h].item, player, ButtonList[h])
                                else
                                    Feedback_CantUse(player)
                                end
                            else
                                RemoveSelectionFrames(player)
                            end
                        return
                    end


                    if ButtonList[h].item == nil then

                        if ButtonList[h].button_type == INV_SLOT then
                            --print("moved")
                            if moved_item_data.soundpack and moved_item_data.soundpack.drop then PlayLocalSound(moved_item_data.soundpack.drop, player - 1) end
                            ButtonList[h].item = ButtonList[PlayerMovingItem[player].selected_frame].item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = nil
                            UpdateInventoryWindow(player)
                            RemoveSelectionFrames(player)
                            InventoryItemInFocus[player] = ButtonList[h]
                        else
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM and moved_item_data.TYPE ~= ITEM_TYPE_CONSUMABLE and moved_item_data.TYPE ~= ITEM_TYPE_OTHER then
                                ForceEquip(h, player)
                                RemoveSelectionFrames(player)
                            else
                                Feedback_CantUse(player)
                            end
                        end

                    else

                        if ButtonList[h].button_type == INV_SLOT then
                            local item = ButtonList[PlayerMovingItem[player].selected_frame].item
                            ButtonList[PlayerMovingItem[player].selected_frame].item = ButtonList[h].item
                            ButtonList[h].item = item
                            UpdateInventoryWindow(player)
                            RemoveSelectionFrames(player)
                            InventoryItemInFocus[player] = ButtonList[h]
                        else
                            if moved_item_data.TYPE ~= ITEM_TYPE_GEM and moved_item_data.TYPE ~= ITEM_TYPE_CONSUMABLE and moved_item_data.TYPE ~= ITEM_TYPE_OTHER then
                                ForceEquip(h, player)
                                --UpdateInventoryWindow(player)
                                RemoveSelectionFrames(player)
                            else
                                Feedback_CantUse(player)
                            end
                        end

                    end

            end

        end

    end




    ---@param item item
    ---@param player number
    ---@param amount number
    function RemoveChargesFromInventoryItem(player, item, amount)
        local button
        for i = 1, 32 do
            button = ButtonList[InventorySlots[player][i]]
            if button.item == item and GetItemType(item) == ITEM_TYPE_CHARGED then
                local charges = GetItemCharges(item)

                    if charges - amount <= 0 then
                        RemoveCustomItem(item)
                        button.item = nil
                    else
                        SetItemCharges(item, charges - amount)
                    end

                UpdateInventoryWindow(player)
                break
            end
        end
    end

    ---@param item item
    ---@param player number
    function RemoveItemFromInventory(player, item)
        local button
        RemoveTooltip(player)
        DestroyContextMenu(player)
        for i = 1, 32 do
            button = ButtonList[InventorySlots[player][i]]
            if button.item == item then
                --BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                button.item = nil
                RemoveCustomItem(item)
                UpdateInventoryWindow(player)
                break
            end
        end
    end

    ---@param player integer
    ---@param item item
    function DropItemFromInventory(player, item, is_silent)
        local button

            for i = 1, 32 do
                button = ButtonList[InventorySlots[player][i]]

                    if button.item == item then

                        if button.button_state then LockItemOnBelt(player, button) end
                        RemoveItemFromBlacksmith(player, item)

                        SetItemVisible(item, true)
                        local x = GetUnitX(PlayerHero[player]) + GetRandomReal(-55., 55.)
                        local y = GetUnitY(PlayerHero[player]) + GetRandomReal(-55., 55.)
                        SetItemPosition(item, x, y)

                        local item_data = GetItemData(item)
                       -- if item_data.quality_effect then BlzSetSpecialEffectAlpha(item_data.quality_effect, 255) end
                        --local item_data = GetItemData(item)
                        item_data.picked_up = nil
                        --print("drop")

                        if item_data.soundpack and not is_silent then
                            AddSoundVolume(item_data.soundpack.drop, x, y, 128, 2100.)
                        end

                            if item_data.flippy then
                                if item_data.flippy and item_data.quality_effect then
                                    BlzSetSpecialEffectPosition(item_data.quality_effect, GetItemX(item), GetItemY(item), GetZ(GetItemX(item), GetItemY(item)))
                                    BlzSetItemSkin(item, GetItemTypeId(item))
                                    BlzSetSpecialEffectAlpha(item_data.quality_effect, 255)
                                    --item_data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[item_data.QUALITY], GetItemX(item), GetItemY(item))
                                end
                            end


                        OnItemDrop(PlayerHero[player], item)
                        button.item = nil
                        UpdateInventoryWindow(player)
                        break
                    end

            end
    end


    local DropTrigger = 0


    ---@param item item
    ---@param player number
    function IsPlayerHasItem(player, item)
        for i = 1, 32 do
            local button = GetButtonData(InventorySlots[player][i])
            if button.item and button.item == item then
                return true
            end
        end
        return false
    end

    ---@param itemid integer
    ---@param player number
    function IsPlayerHasItemId(player, itemid)
        for i = 1, 32 do
            local button = GetButtonData(InventorySlots[player][i])
            if button.item and GetItemTypeId(button.item) == itemid then
                return true
            end
        end
        return false
    end


    ---@param player number
    ---@param itemid number
    function GetItemFromInventory(player, itemid)
        for i = 1, 32 do
            local button = GetButtonData(InventorySlots[player][i])
            if button.item and GetItemTypeId(button.item) == itemid then
                return button.item
            end
        end
        return nil
    end

    ---@param itemid integer
    ---@param player number
    function GetSameItemSlotItem(player, itemid)
        for i = 1, 32 do
            local button = GetButtonData(InventorySlots[player][i])
            if button.item and GetItemTypeId(button.item) == itemid then
                return button.item
            end
        end
        return nil
    end


    ---@param item item
    ---@param player integer
    function AddToInventory(player, item)

        if GetItemData(item) == nil then return false end

        local item_data = GetItemData(item)

        if CountFreeBagSlots(player) <= 0 and GetItemType(item) ~= ITEM_TYPE_CHARGED then
            Feedback_InventoryNoSpace(player)
            return false
        elseif GetItemType(item) == ITEM_TYPE_CHARGED and not IsPlayerHasItemId(player, GetItemTypeId(item)) and CountFreeBagSlots(player) <= 0 then
            Feedback_InventoryNoSpace(player)
            return false
        end


        if item_data.owner then
            BlzSetItemSkin(item, GetItemTypeId(item))
            item_data.owner = nil
        end


            item_data.picked_up = true
            OnItemPickUp(PlayerHero[player], item)


            if GetItemType(item) == ITEM_TYPE_CHARGED then
                local inv_item = GetSameItemSlotItem(player, GetItemTypeId(item))

                    if inv_item ~= nil then
                        SetItemCharges(inv_item, GetItemCharges(item) + GetItemCharges(inv_item))
                        RemoveCustomItem(item)
                        UpdateInventoryWindow(player)
                        return true
                    else
                        local free_slot = GetFirstFreeSlotButton(player)

                            if free_slot ~= nil then
                                free_slot.item = item
                                SetItemVisible(item, false)
                                UpdateInventoryWindow(player)
                                return true
                            end

                    end

            else
                local free_slot = GetFirstFreeSlotButton(player)

                    if free_slot ~= nil then
                        free_slot.item = item
                        UpdateInventoryWindow(player)
                        if item_data.quality_effect then
                            BlzSetSpecialEffectAlpha(item_data.quality_effect, 0)
                            --DestroyEffect(item_data.quality_effect_light)
                        end
                        SetItemVisible(item, false)
                        return true
                    end

            end


        return false
    end


    function CountFreeBagSlots(player)
        local count = 0

            for i = 1, 32 do
                if InventorySlots[player][i] ~= nil then
                    if ButtonList[InventorySlots[player][i]].item == nil then
                        count = count + 1
                    end
                end
            end

        return count
    end


    function Inventory_SetAllSprites(player, state)
        for i = 1, 42 do
            if GetLocalPlayer() == Player(player - 1) then BlzFrameSetVisible(ButtonList[InventorySlots[player][i]].sprite, state) end
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
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
        local new_Sprite = BlzCreateFrameByType("SPRITE", "justAName", new_FrameImage, "WarCraftIIILogo", 0)

        
            ButtonList[new_Frame] = {
                button_type = button_type,
                item = nil,
                button = new_Frame,
                image = new_FrameImage,
                original_texture = texture,
                charges_frame = new_FrameCharges,
                charges_text_frame = new_FrameChargesText,
                charges_frame_state = false,
                sprite = new_Sprite,
                button_state = false
            }

            --BlzFrameSetEnable(new_Sprite, false)

            FrameRegisterNoFocus(new_Frame)
            FrameRegisterClick(new_Frame, texture)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
            BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)

            --DestructableAddIndicatorBJ()
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

            BlzFrameSetPoint(new_Sprite, FRAMEPOINT_BOTTOMLEFT, new_FrameImage, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
            BlzFrameSetSize(new_Sprite, 1., 1.)
            BlzFrameSetScale(new_Sprite, 1.)
            BlzFrameSetModel(new_Sprite, "selecter3.mdx", 0)
            --BlzFrameSetAlpha(new_Sprite, 0)
            BlzFrameSetVisible(new_Sprite, false)

        return new_Frame
    end


    function ReloadInventoryFrames()
        for player = 1, 6 do
            if PlayerHero[player] then
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


                InventoryData[player].tip_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.02, 0.02, slots_Frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.016, -0.016, slots_Frame)

                CreateTooltip(LOCALE_LIST[my_locale].UI_INVENTORY_TOOLTIP_HEADER, LOCALE_LIST[my_locale].UI_INVENTORY_TOOLTIP_DESCRIPTION, InventoryData[player].tip_button, 0.14, 0.12, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT)


                BlzTriggerRegisterFrameEvent(InventoryData[player].tip_trigger, InventoryData[player].tip_button, FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(InventoryData[player].tip_trigger, function()
                    ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_INVENTORY_1, player-1)
                    ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_INVENTORY_2, player-1)
                    DisableTrigger(InventoryData[player].tip_trigger)
                    DelayAction(5., function()
                        EnableTrigger(InventoryData[player].tip_trigger)
                    end)
                end)


                -- inventory slots
                InventorySlots[player][1] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, inv_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, inv_Frame)

                for i = 2, 8 do
                    InventorySlots[player][i] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[player][i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., inv_Frame)
                end

                for row = 2, 4 do
                    for i = 1, 8 do
                        local slot = i + ((row - 1) * 8)
                        InventorySlots[player][slot] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[player][slot - 8], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., inv_Frame)
                    end
                end

                InventorySlots[player][45] = BlzCreateFrameByType("BACKDROP", "ButtonIcon", InventorySlots[player][32], "", 0)
                BlzFrameSetAllPoints(InventorySlots[player][45], InventorySlots[player][32])
                BlzFrameSetAlpha(InventorySlots[player][45], 0)

                -- equip slots
                InventorySlots[player][33] = NewButton(WEAPON_POINT, "GUI\\BTNWeapon_Slot.blp", 0.044, 0.044, slots_Frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.03, 0.03, slots_Frame)
                InventorySlots[player][34] = NewButton(OFFHAND_POINT, "GUI\\BTNWeapon_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.03, 0.03, slots_Frame)

                InventorySlots[player][35] = NewButton(HEAD_POINT, "GUI\\BTNHead_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.025, slots_Frame)
                InventorySlots[player][36] = NewButton(CHEST_POINT, "GUI\\BTNChest_Slot.blp", 0.043, 0.043, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., -0.015, slots_Frame)
                InventorySlots[player][37] = NewButton(HANDS_POINT, "GUI\\BTNHands_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_TOPLEFT, -0.003, -0.008, slots_Frame)
                InventorySlots[player][38] = NewButton(LEGS_POINT, "GUI\\BTNBoots_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMLEFT, -0.003, 0.032, slots_Frame)
                InventorySlots[player][42] = NewButton(BELT_POINT, "GUI\\BTNBeltSlot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.0445, 0.0085, slots_Frame)

                InventorySlots[player][39] = NewButton(NECKLACE_POINT, "GUI\\BTNNecklace_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0445, 0.0085, slots_Frame)
                InventorySlots[player][40] = NewButton(RING_1_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_TOPRIGHT, 0.003, -0.008, slots_Frame)
                InventorySlots[player][41] = NewButton(RING_2_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMRIGHT, 0.003, 0.032, slots_Frame)


                CreateSelectionFrames(player)
                InventoryTooltip[player] = NewTooltip(InventorySlots[player][45])
                InventoryAlternateTooltip[player] = NewTooltip(InventorySlots[player][45])

                local tooltip = GetTooltip(InventoryTooltip[player])
                tooltip.is_sell_penalty = true
                local tooltip = GetTooltip(InventoryAlternateTooltip[player])
                tooltip.is_sell_penalty = true

                BlzFrameSetVisible(PlayerInventoryFrame[player], false)
                PlayerInventoryFrameState[player] = false

                UpdateInventoryWindow(player)
            end
        end
    end


    function DrawInventoryFrames(player, unit)
        --local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)


        BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPRIGHT, GAME_UI, FRAMEPOINT_TOPRIGHT, 0., -0.05)
        BlzFrameSetSize(main_frame, 0.4, 0.38)
        PlayerInventoryFrame[player] = main_frame

        InventoryOwner[player] = unit


        -- slots box
        local slots_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
        BlzFrameSetPoint(slots_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
        BlzFrameSetSize(slots_Frame, 0.36, 0.14)

        -- inv box
        local inv_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
        BlzFrameSetPoint(inv_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetSize(inv_Frame, 0.36, 0.195)


        InventoryData[player] = {
            tip_button = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.02, 0.02, slots_Frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.016, -0.016, slots_Frame)
        }

        CreateTooltip(LOCALE_LIST[my_locale].UI_INVENTORY_TOOLTIP_HEADER, LOCALE_LIST[my_locale].UI_INVENTORY_TOOLTIP_DESCRIPTION, InventoryData[player].tip_button, 0.14, 0.12, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT)

        InventoryData[player].tip_trigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(InventoryData[player].tip_trigger, InventoryData[player].tip_button, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(InventoryData[player].tip_trigger, function()
            ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_INVENTORY_1, player-1)
            ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_INVENTORY_2, player-1)
            DisableTrigger(InventoryData[player].tip_trigger)
            DelayAction(5., function()
                EnableTrigger(InventoryData[player].tip_trigger)
            end)
        end)


        InventorySlots[player] = {}
        -- inventory slots
        InventorySlots[player][1] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, inv_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, inv_Frame)

        for i = 2, 8 do
            InventorySlots[player][i] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[player][i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., inv_Frame)
        end

        for row = 2, 4 do
            for i = 1, 8 do
                local slot = i + ((row - 1) * 8)
                InventorySlots[player][slot] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, InventorySlots[player][slot - 8], FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., inv_Frame)
            end
        end

        InventorySlots[player][45] = BlzCreateFrameByType("BACKDROP", "ButtonIcon", InventorySlots[player][32], "", 0)
        BlzFrameSetAllPoints(InventorySlots[player][45], InventorySlots[player][32])
        BlzFrameSetAlpha(InventorySlots[player][45], 0)

        -- equip slots
        InventorySlots[player][33] = NewButton(WEAPON_POINT, "GUI\\BTNWeapon_Slot.blp", 0.044, 0.044, slots_Frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.03, 0.03, slots_Frame)
        InventorySlots[player][34] = NewButton(OFFHAND_POINT, "GUI\\BTNWeapon_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.03, 0.03, slots_Frame)

        InventorySlots[player][35] = NewButton(HEAD_POINT, "GUI\\BTNHead_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.025, slots_Frame)
        InventorySlots[player][36] = NewButton(CHEST_POINT, "GUI\\BTNChest_Slot.blp", 0.043, 0.043, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., -0.015, slots_Frame)
        InventorySlots[player][37] = NewButton(HANDS_POINT, "GUI\\BTNHands_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_TOPLEFT, -0.003, -0.008, slots_Frame)
        InventorySlots[player][38] = NewButton(LEGS_POINT, "GUI\\BTNBoots_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMLEFT, -0.003, 0.032, slots_Frame)
        InventorySlots[player][42] = NewButton(BELT_POINT, "GUI\\BTNBeltSlot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.0445, 0.0085, slots_Frame)

        InventorySlots[player][39] = NewButton(NECKLACE_POINT, "GUI\\BTNNecklace_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0445, 0.0085, slots_Frame)
        InventorySlots[player][40] = NewButton(RING_1_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_TOPRIGHT, 0.003, -0.008, slots_Frame)
        InventorySlots[player][41] = NewButton(RING_2_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, InventorySlots[player][36], FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMRIGHT, 0.003, 0.032, slots_Frame)


        local actual_player = Player(player-1)
        local key_trig = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_1, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_2, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_3, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_4, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_5, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(key_trig, actual_player, OSKEY_6, 0, true)

        TriggerAddAction(key_trig, function()
            local key = BlzGetTriggerPlayerKey()

                if key == OSKEY_1 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 0))
                elseif key == OSKEY_2 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 1))
                elseif key == OSKEY_3 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 2))
                elseif key == OSKEY_4 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 3))
                elseif key == OSKEY_5 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 4))
                elseif key == OSKEY_6 then
                    UnitUseItem(PlayerHero[player], UnitItemInSlot(PlayerHero[player], 5))
                end

        end)

        AltState[player] = false
        InventoryKeyState[player] = false
        local comparison_trigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 1, true)
        BlzTriggerRegisterPlayerKeyEvent(comparison_trigger, actual_player, OSKEY_LSHIFT, 0, false)
        TriggerAddAction(comparison_trigger, function()

            if InventoryItemInFocus[player] then
                if BlzGetTriggerPlayerIsKeyDown() and not InventoryKeyState[player] then
                    InventoryKeyState[player] = true
                    AltState[player] = false
                    ShowAlternateInventoryTooltip(player)
                elseif not BlzGetTriggerPlayerIsKeyDown() and InventoryKeyState[player] then
                    RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                    RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                    InventoryKeyState[player] = false
                end
            else
                InventoryKeyState[player] = false
            end


        end)


        local AltStateTrigger = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(AltStateTrigger, actual_player, OSKEY_LALT, 5, true)
        TriggerAddAction(AltStateTrigger, function()

            if InventoryItemInFocus[player] then
                if AltState[player] then AltState[player] = false
                else AltState[player] = true end
                RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
                RemoveSpecificTooltip(InventoryAlternateTooltip[player])
                ShowAlternateInventoryTooltip(player)
            end

        end)

        local mouse_state = false
        local DragTimer = CreateTimer()
        local MouseDownTrigger = CreateTrigger()
        local MouseUpTrigger = CreateTrigger()
        TriggerRegisterPlayerEvent(MouseDownTrigger, actual_player, EVENT_PLAYER_MOUSE_DOWN)
        TriggerAddAction(MouseDownTrigger, function()

            if PlayerInventoryFrameState[player] and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                  if InventoryItemInFocus[player] and InventoryItemInFocus[player].item and InventoryItemInFocus[player].button_type == INV_SLOT then
                        mouse_state = true
                        local in_focus = InventoryItemInFocus[player]
                        TimerStart(DragTimer, 0.2, false, function()
                            if InventoryItemInFocus[player] and in_focus == InventoryItemInFocus[player] and mouse_state and InventoryItemInFocus[player].item and InventoryItemInFocus[player].button_type == INV_SLOT then
                                --print("drag start")
                                DestroyContextMenu(player)
                                StartSelectionMode(player, InventoryItemInFocus[player].button, SELECTION_MODE_MOVE)
                            end
                        end)
                  else
                      mouse_state = false
                      --print("drag stop")
                      TimerStart(DragTimer, 0., false, nil)
                  end
            end

        end)

        TriggerRegisterPlayerEvent(MouseUpTrigger, actual_player, EVENT_PLAYER_MOUSE_UP)
        TriggerAddAction(MouseUpTrigger, function()
            if mouse_state and BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                mouse_state = false
                --print("drag stop")
                TimerStart(DragTimer, 0., false, nil)
            end
        end)

        CreateSelectionFrames(player)
        TriggerRegisterUnitEvent(DropTrigger, PlayerHero[player],EVENT_UNIT_DROP_ITEM)
        InventoryTooltip[player] = NewTooltip(InventorySlots[player][45])
        InventoryAlternateTooltip[player] = NewTooltip(InventorySlots[player][45])

        local tooltip = GetTooltip(InventoryTooltip[player])
        tooltip.is_sell_penalty = true
        local tooltip = GetTooltip(InventoryAlternateTooltip[player])
        tooltip.is_sell_penalty = true

        BlzFrameSetVisible(PlayerInventoryFrame[player], false)
        PlayerInventoryFrameState[player] = false

        UpdateInventoryWindow(player)
    end


    function SetInventoryState(player, state)

        if GetUnitState(PlayerHero[player], UNIT_STATE_LIFE) < 0.045 and state then
            FrameState[player][INV_PANEL] = false
            return false
        end

        BlzFrameSetVisible(PlayerInventoryFrame[player], state)
        if GetLocalPlayer() ~= Player(player-1) then
            BlzFrameSetVisible(PlayerInventoryFrame[player], false)
        end

        PlayerInventoryFrameState[player] = state

        if state then
            UpdateInventoryWindow(player)
        else
            RemoveSpecificTooltip(ShopFrame[player].alternate_tooltip)
            RemoveSpecificTooltip(InventoryAlternateTooltip[player])
            InventoryItemInFocus[player] = nil
            RemoveTooltip(player)
            RemoveSelectionFrames(player)
            DestroyContextMenu(player)
            DestroySlider(player)
        end

        return state
    end


    function InventoryInit()

        PlayerInventoryFrame = {}
        PlayerInventoryFrameState = {}
        InventorySlots = {}
        InventoryOwner = {}
        InventoryTooltip = {}
        InventoryAlternateTooltip = {}
        AltState = {}
        InventoryItemInFocus = {}
        InventoryKeyState = {}
        InventoryData = {}
        PlayerMovingItem = {}

        UNIT_POINT_LIST = {
            [WEAPON_POINT]    = 33,
            [OFFHAND_POINT]   = 34,
            [HEAD_POINT]      = 35,
            [CHEST_POINT]     = 36,
            [LEGS_POINT]      = 38,
            [HANDS_POINT]     = 37,
            [BELT_POINT]      = 42,
            [RING_1_POINT]    = 40,
            [RING_2_POINT]    = 41,
            [NECKLACE_POINT]  = 39
        }

        POINT_TO_TYPE = {
            [WEAPON_POINT]    = {
                AXE_WEAPON,
                BOW_WEAPON,
                DAGGER_WEAPON,
                SWORD_WEAPON,
                STAFF_WEAPON,
                GREATAXE_WEAPON,
                GREATBLUNT_WEAPON,
                GREATSWORD_WEAPON,
                BLUNT_WEAPON
            },
            [OFFHAND_POINT]   = {
                ORB_OFFHAND,
                SHIELD_OFFHAND,
                QUIVER_OFFHAND
            },
            [HEAD_POINT]      = HEAD_ARMOR,
            [CHEST_POINT]     = CHEST_ARMOR,
            [LEGS_POINT]      = LEGS_ARMOR,
            [HANDS_POINT]     = HANDS_ARMOR,
            [BELT_POINT]      = BELT_ARMOR,
            [RING_1_POINT]    = RING_JEWELRY,
            [RING_2_POINT]    = RING_JEWELRY,
            [NECKLACE_POINT]  = NECKLACE_JEWELRY
        }

        ClickTrigger = CreateTrigger()
        EnterTrigger = CreateTrigger()
        LeaveTrigger = CreateTrigger()

        DoubleClickTimer = { [1] = { timer = CreateTimer() }, [2] = { timer = CreateTimer() }, [3] = { timer = CreateTimer() }, [4] = { timer = CreateTimer() }, [5] = { timer = CreateTimer() }, [6] = { timer = CreateTimer() } }

        TriggerAddAction(ClickTrigger, InventorySlot_Clicked)
        TriggerAddAction(EnterTrigger, EnterAction)
        TriggerAddAction(LeaveTrigger, LeaveAction)

        DropTrigger = CreateTrigger()
        TriggerAddAction(DropTrigger, function()
            if IsItemInvulnerable(GetManipulatedItem()) then
                SetItemInvulnerable(GetManipulatedItem(), false)
                DropItemFromInventory(GetPlayerId(GetOwningPlayer(GetManipulatingUnit()))+1, GetManipulatedItem(), false)
            end
        end)


        FirstTime_Data_Belt = {
            [1] = { first_time = true },
            [2] = { first_time = true },
            [3] = { first_time = true },
            [4] = { first_time = true },
            [5] = { first_time = true },
            [6] = { first_time = true }
        }

        HeroSpeechFeedbacks = {
            [1] = { state = true, timer = CreateTimer() },
            [2] = { state = true, timer = CreateTimer() },
            [3] = { state = true, timer = CreateTimer() },
            [4] = { state = true, timer = CreateTimer() },
            [5] = { state = true, timer = CreateTimer() },
            [6] = { state = true, timer = CreateTimer() }
        }

    end

end