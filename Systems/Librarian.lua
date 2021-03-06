---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 02.07.2021 17:26
---
do

    LibrarianFrame = {}
    local EXCHANGE_COST = 500



    local function RemovePlayerItems(player)
        local button_data = GetButtonData(LibrarianFrame[player].exchange_item_slot)

        if button_data.item then
            button_data.item = nil


        end

    end


    local ClickTrigger
    local EnterTrigger
    local LeaveTrigger


    local function CreateTextBox(player, size_x, size_y, scale, relative_frame, from, to, offset_x, offset_y, owning_frame)
        local new_frame = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', owning_frame, 0, 0)
            BlzFrameSetPoint(new_frame, from, relative_frame, to, offset_x, offset_y)
            BlzFrameSetSize(new_frame, size_x, size_y)

            LibrarianFrame[player].exchange_frame = BlzCreateFrameByType("TEXT", "text", new_frame, "", 0)
            BlzFrameSetPoint(LibrarianFrame[player].exchange_frame, FRAMEPOINT_LEFT, new_frame, FRAMEPOINT_LEFT, 0.01, 0.)
            BlzFrameSetSize(LibrarianFrame[player].exchange_frame, 0.08, 0.03)
            BlzFrameSetText(LibrarianFrame[player].exchange_frame , "")
            BlzFrameSetTextAlignment(LibrarianFrame[player].exchange_frame, TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_LEFT )
            BlzFrameSetScale(LibrarianFrame[player].exchange_frame, scale)
        return new_frame
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

        ButtonList[GetHandleId(new_Frame)] = {
            button_type = button_type,
            item = nil,
            button = new_Frame,
            image = new_FrameImage
        }

        FrameRegisterNoFocus(new_Frame)
        FrameRegisterClick(new_Frame, texture)

        BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
        BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)

        BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
        BlzFrameSetSize(new_Frame, size_x, size_y)
        BlzFrameSetTexture(new_FrameImage, texture, 0, true)
        BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end



    ---@param text string
    ---@param size_x real
    ---@param size_y real
    ---@param relative_frame framehandle
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent_frame framehandle
    local function NewSpecialButton(text, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local textframe = BlzGetFrameByName("ScriptDialogButtonText", 0)

            BlzFrameSetText(textframe, text)
            BlzFrameSetScale(textframe, 0.8)
            BlzFrameSetTextAlignment(textframe, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)

            BlzFrameSetPoint(frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(frame, size_x, size_y)

            FrameRegisterNoFocus(frame)

            BlzTriggerRegisterFrameEvent(ClickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)

            ButtonList[GetHandleId(frame)] = {
                button = frame,
                button_type = 1
            }

        return frame
    end


    function UpdateLibrarianWindow(player)

        if LibrarianFrame[player].state then
            local button = GetButtonData(LibrarianFrame[player].exchange_item_slot)

                if button.item then
                    BlzFrameSetText(LibrarianFrame[player].exchange_frame, "|c00FFFF00" .. I2S(EXCHANGE_COST) .. "|r")
                else
                    BlzFrameSetTexture(button.image, "GUI\\inventory_slot.blp", 0, true)
                    BlzFrameSetText(LibrarianFrame[player].exchange_frame, "")
                end

        end

    end


    ---@param player number
    ---@param item item
    ---@param where number
    function GiveItemToLibrarian(player, item)
        local button = GetButtonData(LibrarianFrame[player].exchange_item_slot)
        local item_data = GetItemData(item)

            button.item = item
            BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
            BlzFrameSetAlpha(button.image, 255)
            BlzFrameSetAlpha(button.button, 255)
            UpdateLibrarianWindow(player)

    end

    ---@param player number
    function DrawLibrarianFrames(player)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)


            LibrarianFrame[player] = {}
            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.01, -0.05)
            BlzFrameSetSize(main_frame, 0.3, 0.15)


            new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
            BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
            LibrarianFrame[player].portrait = new_Frame

            new_Frame = BlzCreateFrameByType("TEXT", "shop name", LibrarianFrame[player].portrait, "", 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, LibrarianFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
            BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetScale(new_Frame, 1.35)
            LibrarianFrame[player].name = new_Frame


            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
            BlzFrameSetSize(new_Frame, 0.1, 0.07)
            LibrarianFrame[player].inner_exchange_border = new_Frame

            new_Frame = BlzCreateFrame('EscMenuBackdrop', LibrarianFrame[player].inner_exchange_border, 0, 0)
            LibrarianFrame[player].exchange_item_slot = NewButton(0, "GUI\\inventory_slot.blp", 0.04, 0.04, LibrarianFrame[player].inner_exchange_border, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.015, -0.015, LibrarianFrame[player].inner_exchange_border)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, LibrarianFrame[player].exchange_item_slot, FRAMEPOINT_BOTTOMLEFT, -0.015, -0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, LibrarianFrame[player].exchange_item_slot, FRAMEPOINT_TOPRIGHT, 0.015, 0.015)

            LibrarianFrame[player].exchange_button = NewSpecialButton(LOCALE_LIST[my_locale].EXCHANGE_BUTTON_TEXT, 0.06, 0.04, LibrarianFrame[player].exchange_item_slot, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.025, 0., LibrarianFrame[player].inner_exchange_border)
            new_Frame = CreateTextBox(player, 0.085, 0.03, 1., LibrarianFrame[player].exchange_button, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0015, 0., main_frame)
            CreateTooltip(LOCALE_LIST[my_locale].UI_TOOLTIP_EXCHANGE_TITLE, LOCALE_LIST[my_locale].UI_TOOLTIP_EXCHANGE_DESC, LibrarianFrame[player].exchange_button, 0.125, 0.06)
            LibrarianFrame[player].masterframe = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)


            LibrarianFrame[player].tooltip = NewTooltip(LibrarianFrame[player].masterframe)

            LibrarianFrame[player].main_frame = main_frame
            BlzFrameSetVisible(LibrarianFrame[player].main_frame, false)
            LibrarianFrame[player].state = false

    end


    ---@param unit_owner unit
    ---@param texture string
    function CreateLibrarian(unit_owner, texture)



        ClickTrigger = CreateTrigger()
        TriggerAddAction(ClickTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local exchange_button = GetButtonData(LibrarianFrame[player].exchange_item_slot)

             if button.item then
                 button.item = nil
                 BlzFrameSetTexture(button.image, "GUI\\inventory_slot.blp", 0, true)
                 BlzFrameSetText(LibrarianFrame[player].exchange_frame, "")
                 RemoveTooltip(player)
             elseif button.button_type == 1 and exchange_button.item then
                 local unit_data = GetUnitData(PlayerHero[player])
                 local item_data = GetItemData(exchange_button.item)
                 local gold = GetPlayerState(Player(player - 1), PLAYER_STATE_RESOURCE_GOLD)

                 if item_data.restricted_to then
                     if item_data.restricted_to == unit_data.unit_class then
                         Feedback_CantUse(player)
                     else
                         if gold >= EXCHANGE_COST then
                             SetPlayerState(Player(player - 1), PLAYER_STATE_RESOURCE_GOLD, gold - EXCHANGE_COST)
                             PlayLocalSound("Sound\\altarshop_buymagicspell.wav", player-1, 115)
                             BlzFrameSetText(LibrarianFrame[player].exchange_frame, "")

                             DropItemFromInventory(player, exchange_button.item)
                             RemoveCustomItem(exchange_button.item)
                             exchange_button.item = nil
                             UpdateLibrarianWindow(player)
                             local new_book = CreateCustomItem(BOOK_CLASS_ITEM_LIST[unit_data.unit_class][GetRandomInt(1, #BOOK_CLASS_ITEM_LIST[unit_data.unit_class])], 0.,0., false)
                             AddToInventory(player, new_book)
                         else
                             Feedback_NoGold(player)
                         end
                     end
                 end

             end

        end)

        LeaveTrigger = CreateTrigger()
        TriggerAddAction(LeaveTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1

                if button.item then
                    RemoveTooltip(player)
                end

        end)

        EnterTrigger = CreateTrigger()
        TriggerAddAction(EnterTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1

            if button.item then
                ShowItemTooltip(button.item, LibrarianFrame[player].tooltip, button, player, FRAMEPOINT_RIGHT)
            else
                RemoveTooltip(player)
            end

        end)

        local trg = CreateTrigger()
        local soundpack = {
            open = {
                "Units\\NightElf\\Runner\\RunnerWhat2.wav",
                "Units\\NightElf\\Runner\\RunnerWhat5.wav"
            }
        }


            for i = 1, 6 do
                DrawLibrarianFrames(i)
                BlzFrameSetTexture(LibrarianFrame[i].portrait, texture, 0, true)
                BlzFrameSetText(LibrarianFrame[i].name, GetUnitName(unit_owner))
            end

            TriggerRegisterUnitInRangeSimple(trg, 300., unit_owner)
            TriggerAddAction(trg, function()
                local id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
                local player = id + 1

                    if id <= 5 then
                        local hero = GetTriggerUnit()

                        if GetLocalPlayer() == Player(id) then BlzFrameSetVisible(LibrarianFrame[player].main_frame, true) end
                        LibrarianFrame[player].state = true
                        UpdateLibrarianWindow(player)
                        if soundpack then
                            PlayLocalSound(soundpack.open[GetRandomInt(1, #soundpack.open)], id, 125)
                        end

                            TimerStart(CreateTimer(), 0.1, true, function()
                                if not IsUnitInRange(hero, unit_owner, 299.) or IsUnitHidden(unit_owner) then
                                    --DestroySlider(player)
                                    RemovePlayerItems(player)
                                    DestroyContextMenu(player)
                                    RemoveTooltip(player)
                                    --ShopInFocus[player] = nil
                                    LibrarianFrame[player].state = false
                                    if GetLocalPlayer() == Player(id) then BlzFrameSetVisible(LibrarianFrame[player].main_frame, false) end
                                    DestroyTimer(GetExpiredTimer())
                                    if soundpack then
                                        PlayLocalSound(soundpack.close[GetRandomInt(1, #soundpack.open)], id, 125)
                                    end
                                end
                            end)


                    end
            end)

    end


end