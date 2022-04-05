do

    ContextFrame = 0
    SliderFrame = 0
    local TooltipList = 0
    local PlayerTooltip = 0
    local AlternatePlayerTooltip = 0


    ---@param button framehandle
    function GetButtonData(button)
        return ButtonList[button]
    end


    function GetMasterParentFrame(player)
        local frame
        local btn

            if ShopFrame[player].state then
                btn = GetButtonData(ShopFrame[player].slot[32])
                frame = (StringLength(BlzFrameGetText(btn.charges_text_frame)) > 0) and btn.charges_text_frame or btn.image
            elseif SkillPanelFrame[player].state then
                frame = SkillPanelFrame[player].slider
            elseif PlayerInventoryFrameState[player] then
                btn = GetButtonData(InventorySlots[player][32])
                frame = StringLength(BlzFrameGetText(btn.charges_text_frame)) > 0 and btn.charges_text_frame or btn.image
            end

        return frame
    end


    ---@param model string
    ---@param scale real
    ---@param relative_to_frame framehandle
    ---@param relative_point_from framepointtype
    ---@param relative_point_to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent framehandle
    ---@return framehandle
    function CreateSprite(model, scale, relative_to_frame, relative_point_from, relative_point_to, offset_x, offset_y, parent)
        local new_Frame = BlzCreateFrameByType("SPRITE", "justAName", parent, "WarCraftIIILogo", 0)
            BlzFrameSetPoint(new_Frame, relative_point_from, relative_to_frame, relative_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, 1., 1.)
            BlzFrameSetScale(new_Frame, scale)
            BlzFrameSetModel(new_Frame, model, 0)
        return new_Frame
    end


    ---@param size_x real
    ---@param size_y real
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@return framehandle
    ---@param texture string
    ---@param relative_frame framehandle
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent_frame framehandle
    function CreateSimpleButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButtonEx', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            ButtonList[new_Frame] = { button = new_Frame, image = new_FrameImage }

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    ---@param header string
    ---@param context string
    ---@param frame framehandle
    ---@param size_x real
    ---@param size_y real
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@return table
    function CreateTooltip(header, context, frame, size_x, size_y, frame_point_from, frame_point_to)
        local tooltip = BlzCreateFrame("BoxedText", frame, 0, 1)
            BlzFrameSetPoint(tooltip, frame_point_from or FRAMEPOINT_TOPLEFT, frame, frame_point_to or FRAMEPOINT_RIGHT, 0, 0)
            BlzFrameSetTooltip(frame, tooltip)
            BlzFrameSetSize(tooltip, size_x, size_y)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 1), context)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 1), header)
        return { tooltip = tooltip, title = BlzGetFrameByName("BoxedTextTitle", 1), description = BlzGetFrameByName("BoxedTextValue", 1) }
    end



    function ReloadAdvancedFrames()
        for player = 1, 6 do

            ContextFrame[player].backdrop = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', GAME_UI, 0, 0)

                for button = 1, 8 do
                    ContextFrame[player].frames[button] = { button = BlzCreateFrame('ScriptDialogButton', ContextFrame[player].backdrop, 0, 0) }
                    ContextFrame[player].frames[button].text = BlzGetFrameByName("ScriptDialogButtonText", 0)
                    BlzFrameSetScale(ContextFrame[player].frames[button].text, 0.8)
                    BlzFrameSetSize(ContextFrame[player].frames[button].button, 0.074, 0.025)
                    BlzFrameSetTextAlignment(ContextFrame[player].frames[button].text, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)
                    FrameRegisterNoFocus(ContextFrame[player].frames[button].button)
                    BlzFrameSetVisible(ContextFrame[player].frames[button].button, false)
                    ContextFrame[player].frames[button].react = nil

                    local trg = CreateTrigger()
                    BlzTriggerRegisterFrameEvent(trg, ContextFrame[player].frames[button].button, FRAMEEVENT_CONTROL_CLICK)
                    TriggerAddAction(trg, function()
                        ContextFrame[player].frames[button].react()
                        DestroyContextMenu(player)
                    end)

                end

            BlzFrameSetVisible(ContextFrame[player].backdrop, false)

            SliderFrame[player].backdrop = BlzCreateFrame("ScoreScreenButtonBackdropTemplate", GAME_UI, 0, 0)
            SliderFrame[player].slider = BlzCreateFrame("EscMenuSliderTemplate", SliderFrame[player].backdrop, 0, 0)
            SliderFrame[player].text_frame = BlzCreateFrameByType("BACKDROP", "text backdrop", SliderFrame[player].slider, "", 0)
            SliderFrame[player].text = BlzCreateFrame("EscMenuLabelTextTemplate",  SliderFrame[player].slider, 0, 0)

            BlzFrameSetPoint(SliderFrame[player].text_frame, FRAMEPOINT_BOTTOM, SliderFrame[player].slider, FRAMEPOINT_TOP, 0., 0.)
            BlzFrameSetSize(SliderFrame[player].text_frame, 0.012, 0.012)
            BlzFrameSetSize(SliderFrame[player].backdrop, 0.115, 0.035)
            BlzFrameSetPoint(SliderFrame[player].slider, FRAMEPOINT_CENTER, SliderFrame[player].backdrop, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetSize(SliderFrame[player].slider, 0.1, 0.015)
            BlzFrameSetPoint(SliderFrame[player].text, FRAMEPOINT_CENTER, SliderFrame[player].text_frame, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetMinMaxValue(SliderFrame[player].slider, 1, 1)
            BlzFrameSetTexture(SliderFrame[player].text_frame, "GUI\\ChargesTexture.blp", 0, true)
            BlzFrameSetStepSize(SliderFrame[player].slider, 1)
            BlzFrameSetScale(SliderFrame[player].text_frame, 1.15)

            SliderFrame[player].button_ok = BlzCreateFrame("ScriptDialogButton", SliderFrame[player].slider, 0, 0)
            SliderFrame[player].button_cancel = BlzCreateFrame("ScriptDialogButton", SliderFrame[player].slider, 0, 1)

            BlzFrameSetPoint(SliderFrame[player].button_ok, FRAMEPOINT_TOPLEFT, SliderFrame[player].slider, FRAMEPOINT_BOTTOM, 0., 0.)
            BlzFrameSetPoint(SliderFrame[player].button_cancel, FRAMEPOINT_TOPRIGHT, SliderFrame[player].slider, FRAMEPOINT_BOTTOM, 0., 0.)


            BlzFrameSetSize(SliderFrame[player].button_ok, 0.05, 0.025)
            BlzFrameSetSize(SliderFrame[player].button_cancel, 0.05, 0.025)
            BlzFrameSetText(SliderFrame[player].button_ok, LOCALE_LIST[my_locale].UI_TEXT_OK)
            BlzFrameSetText(SliderFrame[player].button_cancel, LOCALE_LIST[my_locale].UI_TEXT_CANCEL)
            BlzFrameSetTextAlignment(SliderFrame[player].button_ok, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetTextAlignment(SliderFrame[player].button_cancel, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)

            BlzFrameSetLevel(SliderFrame[player].slider, 3)


            local trg = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trg, SliderFrame[player].button_ok, FRAMEEVENT_CONTROL_CLICK)
                BlzTriggerRegisterFrameEvent(trg, SliderFrame[player].button_cancel, FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trg, function()
                    if BlzGetTriggerFrame() == SliderFrame[player].button_ok then
                        if SliderFrame[player].okreact then SliderFrame[player].okreact() end
                    else
                        if SliderFrame[player].cancelreact then SliderFrame[player].cancelreact() end
                    end
                    DestroySlider(player)
                end)

            BlzTriggerRegisterFrameEvent(SliderFrame[player].trigger2, SliderFrame[player].slider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
            TriggerAddAction(SliderFrame[player].trigger2, function()
                SliderFrame[player].value = BlzGetTriggerFrameValue() or 1
                if SliderFrame[player].value < 0 then SliderFrame[player].value = 1 end
                BlzFrameSetText(SliderFrame[player].text, R2I(SliderFrame[player].value))
            end)

            SliderFrame[player].state = false
            BlzFrameSetVisible(SliderFrame[player].backdrop, false)
        end
    end


    --======================================================================
    -- SLIDER MODE =========================================================





    ---@param player integer
    function DestroySlider(player)
        if SliderFrame[player].state then
            BlzFrameSetVisible(SliderFrame[player].backdrop, false)
            SliderFrame[player].state = false
        end
    end


    ---@param player integer
    ---@param origin_button table
    ---@param parent framehandle
    ---@param ok_func function
    ---@param cancel_func function
    function CreateSlider(player, origin_button, parent, ok_func, cancel_func)

        parent = GetMasterParentFrame(player) or parent

        BlzFrameClearAllPoints(SliderFrame[player].backdrop)
        BlzFrameSetParent(SliderFrame[player].backdrop, parent)
        BlzFrameSetPoint(SliderFrame[player].backdrop, FRAMEPOINT_TOPLEFT, origin_button.image, FRAMEPOINT_TOPRIGHT, 0., 0.)
        BlzFrameSetMinMaxValue(SliderFrame[player].slider, 1, GetItemCharges(origin_button.item))
        BlzFrameSetText(SliderFrame[player].text, GetItemCharges(origin_button.item))
        BlzFrameSetValue(SliderFrame[player].slider, GetItemCharges(origin_button.item))

        SliderFrame[player].value = GetItemCharges(origin_button.item)
        SliderFrame[player].okreact = ok_func
        SliderFrame[player].cancelreact = cancel_func
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(SliderFrame[player].backdrop, true) end
        BlzFrameSetFocus(SliderFrame[player].slider, true)
        SliderFrame[player].state = true
    end


    function InitSlider()

        SliderFrame = {}
        for i = 1, 6 do
            SliderFrame[i] = {}
            SliderFrame[i].backdrop = BlzCreateFrame("ScoreScreenButtonBackdropTemplate", GAME_UI, 0, 0)
            SliderFrame[i].slider = BlzCreateFrame("EscMenuSliderTemplate", SliderFrame[i].backdrop, 0, 0)
            SliderFrame[i].text_frame = BlzCreateFrameByType("BACKDROP", "text backdrop", SliderFrame[i].slider, "", 0)
            SliderFrame[i].text = BlzCreateFrame("EscMenuLabelTextTemplate",  SliderFrame[i].slider, 0, 0)

            BlzFrameSetPoint(SliderFrame[i].text_frame, FRAMEPOINT_BOTTOM, SliderFrame[i].slider, FRAMEPOINT_TOP, 0., 0.)
            BlzFrameSetSize(SliderFrame[i].text_frame, 0.012, 0.012)
            BlzFrameSetSize(SliderFrame[i].backdrop, 0.115, 0.035)
            BlzFrameSetPoint(SliderFrame[i].slider, FRAMEPOINT_CENTER, SliderFrame[i].backdrop, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetSize(SliderFrame[i].slider, 0.1, 0.015)
            BlzFrameSetPoint(SliderFrame[i].text, FRAMEPOINT_CENTER, SliderFrame[i].text_frame, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetMinMaxValue(SliderFrame[i].slider, 1, 1)
            BlzFrameSetTexture(SliderFrame[i].text_frame, "GUI\\ChargesTexture.blp", 0, true)
            BlzFrameSetStepSize(SliderFrame[i].slider, 1)
            BlzFrameSetScale(SliderFrame[i].text_frame, 1.15)

            SliderFrame[i].button_ok = BlzCreateFrame("ScriptDialogButton", SliderFrame[i].slider, 0, 0)
            SliderFrame[i].button_cancel = BlzCreateFrame("ScriptDialogButton", SliderFrame[i].slider, 0, 1)

            BlzFrameSetPoint(SliderFrame[i].button_ok, FRAMEPOINT_TOPLEFT, SliderFrame[i].slider, FRAMEPOINT_BOTTOM, 0., 0.)
            BlzFrameSetPoint(SliderFrame[i].button_cancel, FRAMEPOINT_TOPRIGHT, SliderFrame[i].slider, FRAMEPOINT_BOTTOM, 0., 0.)


            BlzFrameSetSize(SliderFrame[i].button_ok, 0.05, 0.025)
            BlzFrameSetSize(SliderFrame[i].button_cancel, 0.05, 0.025)
            BlzFrameSetText(SliderFrame[i].button_ok, LOCALE_LIST[my_locale].UI_TEXT_OK)
            BlzFrameSetText(SliderFrame[i].button_cancel, LOCALE_LIST[my_locale].UI_TEXT_CANCEL)
            BlzFrameSetTextAlignment(SliderFrame[i].button_ok, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetTextAlignment(SliderFrame[i].button_cancel, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)

            BlzFrameSetLevel(SliderFrame[i].slider, 3)


            local trg = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trg, SliderFrame[i].button_ok, FRAMEEVENT_CONTROL_CLICK)
                BlzTriggerRegisterFrameEvent(trg, SliderFrame[i].button_cancel, FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trg, function()
                    if BlzGetTriggerFrame() == SliderFrame[i].button_ok then
                        if SliderFrame[i].okreact then SliderFrame[i].okreact() end
                    else
                        if SliderFrame[i].cancelreact then SliderFrame[i].cancelreact() end
                    end
                    DestroySlider(i)
                end)

            SliderFrame[i].trigger2 = CreateTrigger()
            BlzTriggerRegisterFrameEvent(SliderFrame[i].trigger2, SliderFrame[i].slider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
            TriggerAddAction(SliderFrame[i].trigger2, function()
                SliderFrame[i].value = BlzGetTriggerFrameValue() or 1
                if SliderFrame[i].value < 0 then SliderFrame[i].value = 1 end
                BlzFrameSetText(SliderFrame[i].text, R2I(SliderFrame[i].value))
                --print("slider value " .. BlzFrameGetValue(SliderFrame[player].slider))
            end)

            SliderFrame[i].state = false
            BlzFrameSetVisible(SliderFrame[i].backdrop, false)
        end


    end



    --======================================================================
    -- CONTEXT MENU   ======================================================

    ---@param player integer
    function DestroyContextMenu(player)
        for i = 8, 1, -1 do
            BlzFrameSetVisible(ContextFrame[player].frames[i].button, false)
            ContextFrame[player].frames[i].react = nil
        end
        BlzFrameSetVisible(ContextFrame[player].backdrop, false)
        ContextFrame[player].options = 0
        ContextFrame[player].state = nil
    end


    ---@param player integer
    ---@param text string
    ---@param result function
    function AddContextOption(player, text, result)
        ContextFrame[player].options = ContextFrame[player].options + 1
        local position = ContextFrame[player].options
        local frame = ContextFrame[player].frames[position].button
        local textframe = ContextFrame[player].frames[position].text
        BlzFrameSetText(textframe, text)
        BlzFrameClearAllPoints(frame)

        if position == 1 or position == nil then
            if ContextFrame[player].inverted_side then
                BlzFrameSetPoint(frame, FRAMEPOINT_RIGHT, ContextFrame[player].originframe, FRAMEPOINT_LEFT, 0., 0.)
            else
                BlzFrameSetPoint(frame, FRAMEPOINT_LEFT, ContextFrame[player].originframe, FRAMEPOINT_RIGHT, 0., 0.)
            end
        else
            BlzFrameSetPoint(frame, FRAMEPOINT_TOP, ContextFrame[player].frames[position - 1].button, FRAMEPOINT_BOTTOM, 0., 0.004)
        end

        ContextFrame[player].frames[position].react = result

        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOP, ContextFrame[player].frames[1].button, FRAMEPOINT_TOP, 0., 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOPLEFT, ContextFrame[player].frames[1].button, FRAMEPOINT_TOPLEFT, -0.003, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_TOPRIGHT, ContextFrame[player].frames[1].button, FRAMEPOINT_TOPRIGHT, 0.003, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, -0.003, -0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMRIGHT, -0.003, 0.003)
        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_BOTTOM, frame, FRAMEPOINT_BOTTOM, 0., -0.003)
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(frame, true) end

    end


    ---@param player integer
    ---@param originframe framehandle
    ---@param direction framepointtype
    ---@param parent framehandle
    ---@return framehandle
    function CreatePlayerContextMenu(player, originframe, direction, parent)
        local from

        DestroyContextMenu(player)
        parent = GetMasterParentFrame(player) or parent

            BlzFrameClearAllPoints(ContextFrame[player].backdrop)
            BlzFrameSetParent(ContextFrame[player].backdrop, parent)
                if direction == FRAMEPOINT_RIGHT then
                    from = FRAMEPOINT_LEFT
                    ContextFrame[player].inverted_side = nil
                else
                    from = FRAMEPOINT_RIGHT
                    ContextFrame[player].inverted_side = true
                end

            local to = direction == FRAMEPOINT_RIGHT and FRAMEPOINT_RIGHT or FRAMEPOINT_LEFT
            BlzFrameSetPoint(ContextFrame[player].backdrop, from, originframe, to, 0.,0.)

            if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(ContextFrame[player].backdrop, true) end
            RemoveTooltip(player)
            ContextFrame[player].originframe = originframe
            ContextFrame[player].state = true

        return ContextFrame[player].backdrop
    end


    function InitContextMenu()

        ContextFrame = {}
        TooltipList = {}
        PlayerTooltip = {}
        AlternatePlayerTooltip = {}


        for i = 1, 6 do
            ContextFrame[i] = {
                frames = {},
                backdrop = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', GAME_UI, 0, 0),
                options = 0
            }
            for button = 1, 8 do
                ContextFrame[i].frames[button] = { button = BlzCreateFrame('ScriptDialogButton', ContextFrame[i].backdrop, 0, 0) }
                ContextFrame[i].frames[button].text = BlzGetFrameByName("ScriptDialogButtonText", 0)
                BlzFrameSetScale(ContextFrame[i].frames[button].text, 0.8)
                BlzFrameSetSize(ContextFrame[i].frames[button].button, 0.074, 0.025)
                BlzFrameSetTextAlignment(ContextFrame[i].frames[button].text, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)
                FrameRegisterNoFocus(ContextFrame[i].frames[button].button)
                BlzFrameSetVisible(ContextFrame[i].frames[button].button, false)
                ContextFrame[i].frames[button].react = nil

                local trg = CreateTrigger()
                BlzTriggerRegisterFrameEvent(trg, ContextFrame[i].frames[button].button, FRAMEEVENT_CONTROL_CLICK)
                TriggerAddAction(trg, function()
                    ContextFrame[i].frames[button].react()
                    DestroyContextMenu(i)
                end)

            end
            BlzFrameSetVisible(ContextFrame[i].backdrop, false)

        end

    end

    --======================================================================
    -- TOOLTIP        ======================================================


    local function LockWidth(frame, width, min, max)

        if width < min then
            width = min
        elseif width > max  then
            width = max
        end

        BlzFrameSetSize(frame, width, 0.)
    end



    ---@param frame framehandle
    ---@return table
    function GetTooltip(frame)
        return TooltipList[frame]
    end

    ---@param parent framehandle
    ---@param inheritance string
    ---@return framehandle
    function NewTooltip(parent, inheritance)
        local backdrop = BlzCreateFrame("BoxedTextEx", parent, 15, 0)
        local handle = backdrop

            TooltipList[handle] = {}
            TooltipList[handle].textframe = {}
            TooltipList[handle].imageframe = {}

                for i = 1, 15 do
                    TooltipList[handle].textframe[i] = BlzCreateFrameByType("TEXT", "text", backdrop, (inheritance or ""), 0)
                    TooltipList[handle].imageframe[i] = BlzCreateFrameByType("BACKDROP", "image", backdrop, "", 0)
                    --BlzFrameSetFont(TooltipList[handle].textframe[i], "D3font.ttf", 0.005, 0) --MyTextTemplate
                    --BlzFrameSetTextColor(TooltipList[handle].textframe[i], BlzConvertColor(0, 255, 255, 255))
                end

            TooltipList[handle].backdrop = backdrop
            TooltipList[handle].header = BlzGetFrameByName("HeaderBackdrop", 0)
            TooltipList[handle].header_glow = {
                [COMMON_ITEM] = BlzGetFrameByName("HeaderBackdropGlowCommon", 0),
                [RARE_ITEM] = BlzGetFrameByName("HeaderBackdropGlowRare", 0),
                [MAGIC_ITEM] = BlzGetFrameByName("HeaderBackdropGlowMagic", 0),
                [SET_ITEM] = BlzGetFrameByName("HeaderBackdropGlowSet", 0),
                [UNIQUE_ITEM] = BlzGetFrameByName("HeaderBackdropGlowUnique", 0)
            }
            BlzFrameSetPoint(backdrop, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPRIGHT, 0.01, 0.01)
            BlzFrameSetSize(backdrop, 0.01, 0.01)
            BlzFrameSetVisible(backdrop, false)

        return backdrop
    end


    
    ---@param index number
    ---@param tooltip table
    ---@param icon string
    ---@param value string
    ---@param relative_frame framehandle
    ---@param from framepointtype
    ---@param to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param text_orientation textaligntype
    ---@param player integer
    function AddExtendedSkillValue(index, tooltip, icon, value, relative_frame, from, to, offset_x, offset_y, text_orientation, player)
        if GetLocalPlayer() == Player(player-1) then
            BlzFrameSetVisible(tooltip.imageframe[index], true)
            BlzFrameSetVisible(tooltip.textframe[index], true)
        end

        BlzFrameClearAllPoints(tooltip.imageframe[index])
        BlzFrameSetTexture(tooltip.imageframe[index], icon, 0, true)
        BlzFrameSetPoint(tooltip.imageframe[index], from, relative_frame, to, offset_x, offset_y)
        BlzFrameSetSize(tooltip.imageframe[index], 0.0098, 0.0098)
        BlzFrameSetScale(tooltip.imageframe[index], 1.05)


        local point_from
        local point_to
        local offset
        if text_orientation == TEXT_JUSTIFY_LEFT then
            point_from = FRAMEPOINT_LEFT
            point_to = FRAMEPOINT_RIGHT
            offset = 0.008
        else
            point_from = FRAMEPOINT_RIGHT
            point_to = FRAMEPOINT_LEFT
            offset = -0.008
        end

        BlzFrameClearAllPoints(tooltip.textframe[index])
        BlzFrameSetText(tooltip.textframe[index], value)
        BlzFrameSetPoint(tooltip.textframe[index], point_from, tooltip.imageframe[index], point_to, offset, 0.)
        BlzFrameSetTextAlignment(tooltip.textframe[index], text_orientation, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetScale(tooltip.textframe[index], 0.88)
    end


    ---@param index number
    ---@param tooltip table
    ---@param relative framehandle
    ---@param from framepointtype
    ---@param to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param align textaligntype
    ---@param player integer
    function SetTooltipText(index, tooltip, text, align, relative, from, to, offset_x, offset_y, player)
        BlzFrameClearAllPoints(tooltip.textframe[index])
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(tooltip.textframe[index], true) end
        BlzFrameSetText(tooltip.textframe[index], text)
        BlzFrameSetPoint(tooltip.textframe[index], from, relative, to, offset_x, offset_y)
        BlzFrameSetTextAlignment(tooltip.textframe[index], TEXT_JUSTIFY_CENTER, align)
        --BlzFrameSetSize(tooltip.textframe[index], BlzFrameGetWidth(tooltip.textframe[index]) ,BlzFrameGetHeight(tooltip.textframe[index]))
        return tooltip.textframe[index]
    end

    ---@param index number
    ---@param tooltip table
    ---@param icon string
    ---@param size_x real
    ---@param size_y real
    ---@param scale real
    ---@param relative framehandle
    ---@param from framepointtype
    ---@param to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param player integer
    function SetTooltipIcon(index, tooltip, icon, size_x, size_y, scale, relative, from, to, offset_x, offset_y, player)
        BlzFrameClearAllPoints(tooltip.imageframe[index])
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(tooltip.imageframe[index], true) end
        BlzFrameSetTexture(tooltip.imageframe[index], icon, 0, true)
        BlzFrameSetPoint(tooltip.imageframe[index], from, relative, to, offset_x, offset_y)
        BlzFrameSetSize(tooltip.imageframe[index], size_x, size_y)
        BlzFrameSetScale(tooltip.imageframe[index], scale)
        return tooltip.imageframe[index]
    end


    ---@param number integer
    ---@param dec1 string
    ---@param dec4 string
    ---@param dec5 string
    ---@return string
    function Declension(number, dec1, dec4, dec5)
        local i

            number = ModuloInteger(IAbsBJ(number), 100)

                if (number >= 11 and number <= 19) then
                    return dec5
                else
                    i = ModuloInteger(number, 10)
                    if (i == 1) then return dec1
                    elseif (i >= 2 and i <= 4) then return dec4 end
                    return dec5
                end

            return dec1
    end

    ---@param talent table
    ---@param level integer
    ---@param tooltip framehandle
    ---@param button table
    ---@param player integer
    ---@param alternate_tooltip boolean
    function ShowTalentTooltip(talent, level, tooltip, button, player, alternate_tooltip)
        local category = GetButtonData(TalentPanel[player].last_category_button)

        if ContextFrame[player].state or SliderFrame[player].state then return end
        --RemoveTooltip(player)

        local my_tooltip = TooltipList[tooltip]

        if alternate_tooltip then
            AlternatePlayerTooltip[player] = my_tooltip.backdrop
        else
            RemoveTooltip(player)
            PlayerTooltip[player] = my_tooltip.backdrop
        end

        if level > talent.max_level then
            return
        end

        --PlayerTooltip[player] = my_tooltip.backdrop
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(my_tooltip.backdrop, true) end
        for i = 1, 6 do BlzFrameSetVisible(my_tooltip.header_glow[i], false) end
        BlzFrameSetVisible(my_tooltip.header, false)

        local height = 0.009

        BlzFrameClearAllPoints(my_tooltip.backdrop)
        if alternate_tooltip then BlzFrameSetPoint(my_tooltip.backdrop, FRAMEPOINT_TOPLEFT, PlayerTooltip[player], FRAMEPOINT_TOPRIGHT, 0.001, 0.)
        else BlzFrameSetPoint(my_tooltip.backdrop, FRAMEPOINT_TOPLEFT, button.image, FRAMEPOINT_RIGHT, 0.005, -0.005) end

        BlzFrameSetSize(my_tooltip.backdrop, 0.1, 0.1)

        SetTooltipText(1, my_tooltip, LOCALE_LIST[my_locale].TALENTS[talent.talent_id].name, TEXT_JUSTIFY_LEFT, my_tooltip.backdrop, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.01, -0.01, player)
        BlzFrameSetScale(my_tooltip.textframe[1], 1.02)
        height = height + BlzFrameGetHeight(my_tooltip.textframe[1]) + 0.01

        if level == 0 then level = 1 end

        local description = LOCALE_LIST[my_locale].TALENTS[talent.talent_id][level]
        if category.points_spent < talent.points_required then
            description = description .. "|n|n" .. "|c00FF0000" .. GetLocalString("Требует ", "Requires ") .. talent.points_required .. GetLocalString(Declension(talent.points_required, " очко", " очка", " очков").." в этой категории талантов.", " points in this talent category.").. "|r"
        end

        SetTooltipText(2, my_tooltip, description, TEXT_JUSTIFY_LEFT, my_tooltip.textframe[1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0., -0.03, player)
        BlzFrameSetScale(my_tooltip.textframe[2], 0.88)
        LockWidth(my_tooltip.textframe[2], BlzFrameGetWidth(my_tooltip.textframe[2]), 0.06, 0.14)
        height = height + BlzFrameGetHeight(my_tooltip.textframe[2]) + 0.03

        LockWidth(my_tooltip.textframe[1], BlzFrameGetWidth(my_tooltip.textframe[2]), 0.06, 0.14)

        SetTooltipText(3, my_tooltip, GetLocalString("Уровень ", "Level ") .. level .. "/".. talent.max_level, TEXT_JUSTIFY_MIDDLE, my_tooltip.backdrop, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.008, 0.008, player)
        BlzFrameSetScale(my_tooltip.textframe[3], 0.68)
        --BlzFrameSetFont(my_tooltip.textframe[3], "ExocetBlizzardMedium.ttf", 0.09, 0)


        BlzFrameSetSize(my_tooltip.backdrop, BlzFrameGetWidth(my_tooltip.textframe[2]) + 0.018, height)
    end



    ---@param skill table
    ---@param tooltip framehandle
    ---@param button table
    ---@param player integer
    function ShowSkillTooltip(skill, tooltip, button, player)

        if ContextFrame[player].state or SliderFrame[player].state then return end
        RemoveTooltip(player)

        local my_tooltip = TooltipList[tooltip]
        PlayerTooltip[player] = my_tooltip.backdrop
        if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(my_tooltip.backdrop, true) end
        for i = 1, 6 do BlzFrameSetVisible(my_tooltip.header_glow[i], false) end
        BlzFrameSetVisible(my_tooltip.header, false)

        local ability_level = UnitGetAbilityLevel(PlayerHero[player], skill.Id) or 1
       -- local proper_level_data = ability_level
        local true_id = FourCC(skill.Id)
        local main_description

                    if LOCALE_LIST[my_locale][true_id][ability_level] then
                        main_description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][ability_level], ability_level) or "invalid parse data"
                        --BlzSetAbilityExtendedTooltip(ability, ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id].bind, lvl), 0)
                    else
                        for i = ability_level, 1, -1 do
                            if LOCALE_LIST[my_locale][true_id][i] then
                                main_description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][i], ability_level) or "invalid parse data"
                                break
                                --BlzSetAbilityExtendedTooltip(ability, ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][i], lvl), 0)
                            end
                        end
                    end


        local height = 0.009

            BlzFrameClearAllPoints(my_tooltip.backdrop)
            BlzFrameSetPoint(my_tooltip.backdrop, FRAMEPOINT_TOPLEFT, button.image, FRAMEPOINT_RIGHT, 0.005, -0.005)
            BlzFrameSetSize(my_tooltip.backdrop, 0.1, 0.1)


            SetTooltipText(1, my_tooltip, main_description, TEXT_JUSTIFY_MIDDLE,  my_tooltip.backdrop, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.01, player)
            LockWidth(my_tooltip.textframe[1], BlzFrameGetWidth(my_tooltip.textframe[1]), 0.06, 0.15)
            BlzFrameSetScale(my_tooltip.textframe[1], 0.88)

            height = height + BlzFrameGetHeight(my_tooltip.textframe[1]) + 0.01


            local master_index = 1

            master_index = master_index + 1
            AddExtendedSkillValue(master_index, my_tooltip, "UI\\BTNtime.blp", (skill.level[ability_level].cooldown or 0.1) .. LOCALE_LIST[my_locale].SKILL_PANEL_COOLDOWN_TEXT,
                    my_tooltip.textframe[1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0., -0.004, TEXT_JUSTIFY_LEFT, player)
            height = height + BlzFrameGetHeight(my_tooltip.imageframe[master_index]) + 0.005
            --BlzFrameSetScale(my_tooltip.textframe[master_index], 0.88)


            if skill.level[ability_level].resource_cost ~= nil then
                master_index = master_index + 1
                AddExtendedSkillValue(master_index, my_tooltip,
                        "UI\\Widgets\\ToolTips\\Human\\ToolTipManaIcon.blp", (R2I(skill.level[ability_level].resource_cost) or 0) .. LOCALE_LIST[my_locale].SKILL_PANEL_MANA_TEXT,
                        my_tooltip.imageframe[master_index-1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0., -0.004, TEXT_JUSTIFY_LEFT, player)

                height = height + BlzFrameGetHeight(my_tooltip.imageframe[master_index]) + 0.005
            end
        
            if skill.activation_type ~= SELF_CAST then
                master_index = master_index + 1
                AddExtendedSkillValue(master_index, my_tooltip,
                        "ReplaceableTextures\\CommandButtons\\BTNMarksmanship.blp", (R2I(skill.level[ability_level].range) or 0) .. LOCALE_LIST[my_locale].SKILL_PANEL_RANGE_TEXT,
                        my_tooltip.imageframe[master_index-1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0., -0.004, TEXT_JUSTIFY_LEFT, player)

                height = height + BlzFrameGetHeight(my_tooltip.imageframe[master_index]) + 0.005
            end


            BlzFrameSetSize(my_tooltip.backdrop, BlzFrameGetWidth(my_tooltip.textframe[1]) + 0.012, height)

    end


    ---@param item item
    ---@param parameter integer
    ---@param value real
    ---@param method integer
    ---@return string
    function CompareParameter(item, parameter, value, method)
        local item_data = GetItemData(item)

        if item_data.BONUS then
            for i = 1, #item_data.BONUS do
                if item_data.BONUS[i].PARAM == parameter and item_data.BONUS[i].METHOD == method then
                    if item_data.BONUS[i].VALUE < value then
                        return "|c0000FF00" .. GetCorrectParamText(parameter, value, method) .. "|r"
                    else
                        return "|c00FF0000" .. GetCorrectParamText(parameter, value, method) .. "|r"
                    end
                end
            end
        end

        return GetCorrectParamText(parameter, value, method)
    end


    ---@param item item
    ---@param tooltip framehandle
    ---@param button table
    ---@param player number
    ---@param direction framepointtype
    ---@param fallback_tooltip table
    ---@param free_tooltip boolean
    ---@param alternate_tooltip boolean
    ---@param compare_item item
    function ShowItemTooltip(item, tooltip, button, player, direction, fallback_tooltip, alternate_tooltip, compare_item)

        --if true then return end

        if item == nil then return end

        local item_data = GetItemData(item)
        local width = 0.
        local height = 0.


            if ContextFrame[player].state or SliderFrame[player].state then return end

            tooltip = TooltipList[tooltip]
            if not alternate_tooltip then
                RemoveTooltip(player)
                PlayerTooltip[player] = tooltip.backdrop
            else
                AlternatePlayerTooltip[player] = tooltip.backdrop
            end

            if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(tooltip.backdrop, true) end

            BlzFrameSetAlpha(tooltip.backdrop, 255)
            BlzFrameClearAllPoints(tooltip.backdrop)

            local point_from
            local point_to
            local offset_x
            local offset_y

            if direction == FRAMEPOINT_RIGHT then
                point_from = FRAMEPOINT_TOPLEFT
                point_to = FRAMEPOINT_RIGHT
                offset_x = 0.002
                offset_y = -0.002
            else
                point_from = FRAMEPOINT_TOPRIGHT
                point_to = FRAMEPOINT_LEFT
                offset_x = -0.001
                offset_y = -0.001
            end

            BlzFrameSetPoint(tooltip.backdrop, point_from, button.image, point_to, offset_x, offset_y)
            BlzFrameSetSize(tooltip.backdrop, 0.01, 0.01)


            local property_text = ""
            if item_data.SUBTYPE then property_text = GetItemSubTypeName(item_data.SUBTYPE) .. "|n" .. "|n"
            else
                property_text = GetItemTypeName(item_data.TYPE) .. "|n"
            end


            if item_data.TYPE == ITEM_TYPE_WEAPON then
                local damage_text = R2I(item_data.DAMAGE * item_data.DISPERSION[1]) .. "-" .. R2I(item_data.DAMAGE * item_data.DISPERSION[2])
                if item_data.DAMAGE_TYPE == DAMAGE_TYPE_MAGICAL then damage_text = "|c006BBEFF" .. damage_text .. "|r" end
                property_text = property_text .. LOCALE_LIST[my_locale].DAMAGE_UI .. damage_text .. "|n" .. LOCALE_LIST[my_locale].DAMAGE_TYPE_UI .. GetAttributeColor(item_data.ATTRIBUTE) .. GetAttributeName(item_data.ATTRIBUTE).. "|r"
            elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                property_text = property_text .. LOCALE_LIST[my_locale].DEFENCE_UI .. R2I(item_data.DEFENCE)
                    if item_data.SUBTYPE == BELT_ARMOR then
                        property_text = property_text .. "|n" .. LOCALE_LIST[my_locale].SUPPRESSION_UI .. R2I(item_data.SUPPRESSION)
                    end
            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                property_text = property_text .. LOCALE_LIST[my_locale].SUPPRESSION_UI .. R2I(item_data.SUPPRESSION)
            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                --property_text = property_text .. LOCALE_LIST[my_locale].DEFENCE_UI .. R2I(item_data.DEFENCE)
                    if item_data.SUBTYPE == SHIELD_OFFHAND then
                        property_text = property_text .. LOCALE_LIST[my_locale].DEFENCE_UI .. R2I(item_data.DEFENCE) .. "|n" .. LOCALE_LIST[my_locale].BLOCK_UI .. R2I(item_data.BLOCK) .. "%%"
                    end
            end


            local bonus_text

            if item_data.BONUS ~= nil and #item_data.BONUS > 0 then
                bonus_text = LOCALE_LIST[my_locale].ADDITIONAL_INFO_UI
                for i = 1, #item_data.BONUS do
                    if compare_item then
                        bonus_text = bonus_text .. GetParameterName(item_data.BONUS[i].PARAM) .. ": " .. CompareParameter(compare_item, item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD) .. "|n"
                    else
                        bonus_text = bonus_text .. GetParameterName(item_data.BONUS[i].PARAM) .. ": " .. GetCorrectParamText(item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD) .. "|n"
                    end
                end
            end
        
            


            if item_data.SKILL_BONUS ~= nil and #item_data.SKILL_BONUS > 0 then
                local skill_bonus_text = ""

                for i = 1, #item_data.SKILL_BONUS do
                    if item_data.SKILL_BONUS[i].id then skill_bonus_text = skill_bonus_text .. "|c00EFD572" .. GetSkillName(item_data.SKILL_BONUS[i].id) .. "|r" .. " +" .. item_data.SKILL_BONUS[i].bonus_levels .. "|n"
                    elseif item_data.SKILL_BONUS[i].category then skill_bonus_text = skill_bonus_text .. "|c00FFC2FF" ..  GetSkillCategoryName(item_data.SKILL_BONUS[i].category) .. "|r" .. " +" .. item_data.SKILL_BONUS[i].bonus_levels .. "|n" end
                end

                if bonus_text ~= nil then bonus_text = bonus_text..skill_bonus_text
                else bonus_text = LOCALE_LIST[my_locale].ADDITIONAL_INFO_UI .. skill_bonus_text end

            end


            if item_data.TYPE == ITEM_TYPE_GEM then
                bonus_text = LOCALE_LIST[my_locale].AUGMENTS_UI
                for i = 1, #item_data.point_bonus do
                    if item_data.point_bonus[i] ~= nil then
                        bonus_text = bonus_text .. GetItemTypeName(i) .. " - " .. GetParameterName(item_data.point_bonus[i].PARAM) .. ": " .. GetCorrectParamText(item_data.point_bonus[i].PARAM, item_data.point_bonus[i].VALUE, item_data.point_bonus[i].METHOD).. "|n"
                    end
                end
            end


            if item_data.item_description ~= nil then
                if bonus_text == nil then bonus_text = "|n" .. item_data.item_description
                else bonus_text = bonus_text .. "|n" .. item_data.item_description end
            end


            local myframe = SetTooltipText(1, tooltip, item_data.actual_name, TEXT_JUSTIFY_MIDDLE, tooltip.backdrop, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.01, player)
            LockWidth(myframe, BlzFrameGetWidth(myframe), 0.1, 0.16)
            BlzFrameSetScale(myframe, 1.2)
            --BlzFrameClearAllPoints(tooltip.header
            --BlzFrameSetPoint(tooltip.header, FRAMEPOINT_BOTTOM, myframe, FRAMEPOINT_BOTTOM, -0.02, 0.)
            --print("name " .. BlzFrameGetWidth(myframe))

             --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
            height = height + BlzFrameGetHeight(myframe)


            myframe = SetTooltipText(2, tooltip, property_text, TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., -0.008, player)
            BlzFrameSetScale(myframe, 0.95)
             --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
            height = height + BlzFrameGetHeight(myframe)
            --print("property " .. BlzFrameGetWidth(myframe))

            local master_index = 3

            if bonus_text then
                myframe = SetTooltipText(master_index, tooltip, bonus_text, TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                BlzFrameSetScale(myframe, 0.95)
                LockWidth(myframe, BlzFrameGetWidth(myframe), 0.16, 0.21)
                master_index = master_index + 1
                 --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
                height = height + BlzFrameGetHeight(myframe)
                --print("bonus " .. BlzFrameGetWidth(myframe))
            end


            if item_data.legendary_effect then
                myframe = SetTooltipText(master_index, tooltip, LOCALE_LIST[my_locale].UNIQUE_EFFECT_UI ..":|n|c00DF0000".. item_data.legendary_effect.name.."|r", TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., -0.005, player)
                LockWidth(myframe, BlzFrameGetWidth(myframe), 0.16, 0.2)
                BlzFrameSetScale(myframe, 0.97)
                master_index = master_index + 1
                --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
                height = height + BlzFrameGetHeight(myframe) * 0.95
                --print("legendary " .. BlzFrameGetWidth(myframe))
            elseif item_data.set_bonus then
                local set_bonus_text = GetQualityColor(SET_ITEM) .. item_data.set_bonus.name .. "|r" .. ":|n"
                local set_count = CountSetItems(PlayerHero[player], item_data.set_bonus)

                    for k = 1, #item_data.set_bonus.bonuses do
                        set_bonus_text = set_bonus_text .. item_data.set_bonus.bonuses[k].pieces .. LOCALE_LIST[my_locale].SET_PART_UI
                        local params = item_data.set_bonus.bonuses[k].params
                        if set_count < item_data.set_bonus.bonuses[k].pieces then set_bonus_text = set_bonus_text .. "|c007D7D7D" end
                        for i = 1, #params do
                            if params[i].param then
                                set_bonus_text = set_bonus_text .. GetParameterName(params[i].param) .. ": " .. GetCorrectParamText(params[i].param, params[i].value, params[i].method) .. "|n"
                            else
                                set_bonus_text = set_bonus_text .. params[i].legendary_effect.name  .. "|n"
                            end
                        end
                        if set_count < item_data.set_bonus.bonuses[k].pieces then set_bonus_text = set_bonus_text .. "|r" end
                    end

                BlzFrameSetSize(tooltip.textframe[master_index], 0., 0.)
                myframe = SetTooltipText(master_index, tooltip, set_bonus_text, TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., -0.005, player)
                BlzFrameSetScale(myframe, 0.95)
                LockWidth(myframe, BlzFrameGetWidth(myframe), 0.16, 0.45)
                master_index = master_index + 1
                --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
                height = height + BlzFrameGetHeight(myframe) * 0.95
            end


            if item_data.MAX_SLOTS and item_data.MAX_SLOTS > 0 then
                local free_stone_slots = item_data.MAX_SLOTS - #item_data.STONE_SLOTS
                local stones_text = LOCALE_LIST[my_locale].SLOTS_UI

                    for i = 1, #item_data.STONE_SLOTS do
                        if item_data.STONE_SLOTS[i] ~= nil then
                            local stone_bonus = item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE]
                            stones_text = stones_text .. GetParameterName(stone_bonus.PARAM) .. ": " .. GetCorrectParamText(stone_bonus.PARAM, stone_bonus.VALUE, stone_bonus.METHOD) .. "|n"
                        else
                            stones_text = stones_text .. "|n"
                        end
                    end



                myframe = SetTooltipText(master_index, tooltip, stones_text, TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                LockWidth(myframe, BlzFrameGetWidth(myframe), 0.16, 0.45)
                master_index = master_index + 1
                 --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
                height = height + BlzFrameGetHeight(myframe)

                    if free_stone_slots == 1 then
                        myframe = SetTooltipText(master_index, tooltip, "", TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                        master_index = master_index + 1
                        BlzFrameSetSize(myframe, 0.01, 0.02)
                        height = height + BlzFrameGetHeight(myframe)

                        SetTooltipIcon(1, tooltip, "GUI\\empty stone.blp", 0.015, 0.015, 1., myframe, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0.,  0., player)
                    elseif free_stone_slots > 1 then
                        local stones = {}

                        myframe = SetTooltipText(master_index, tooltip, "", TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                        master_index = master_index + 1
                        BlzFrameSetSize(myframe, 0.01, 0.02)
                        --if BlzFrameGetWidth(myframe) > width then width = BlzFrameGetWidth(myframe) end
                        height = height + BlzFrameGetHeight(myframe)

                        local offset_bonus = 4 - free_stone_slots
                        if offset_bonus < 0 then offset_bonus = 0 end

                        offset_bonus = offset_bonus * 0.15
                        local last_stone_frame

                        for i = 1, free_stone_slots do

                            if i == 1 then
                                last_stone_frame = SetTooltipIcon(i, tooltip, "GUI\\empty stone.blp", 0.015, 0.015, 1., myframe, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, free_stone_slots*((free_stone_slots * 0.0015) * (-1. - offset_bonus)),  0., player)
                            else
                                last_stone_frame = SetTooltipIcon(i, tooltip, "GUI\\empty stone.blp", 0.015, 0.015, 1., last_stone_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.,  0., player)
                            end
                        end

                    elseif free_stone_slots == 0 then
                        myframe = SetTooltipText(master_index, tooltip, "", TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                        master_index = master_index + 1
                    end
            end


            if item_data.special_description then
                myframe = SetTooltipText(master_index, tooltip, "|c00FF9748"..item_data.special_description.."|r", TEXT_JUSTIFY_MIDDLE, myframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0, player)
                LockWidth(myframe, BlzFrameGetWidth(myframe), 0.16, 0.2)
                BlzFrameSetScale(myframe, 0.9)
                master_index = master_index + 1
                 if BlzFrameGetWidth(myframe) * 1.05 > width then width = BlzFrameGetWidth(myframe) * 1.05 end
                height = height + (BlzFrameGetHeight(myframe) * 0.72)
                --print("special " .. BlzFrameGetWidth(myframe))
            end



            if item_data.sell_value or item_data.cost then
                local total_cost = 0
                local single_item_cost = ""

                if item_data.sell_value then total_cost = total_cost + item_data.sell_value end
                if item_data.cost then total_cost = total_cost + item_data.cost end

                if GetItemCharges(item_data.item) > 1 then
                    single_item_cost = " ("..R2I(total_cost)..")"
                    total_cost = total_cost * GetItemCharges(item_data.item)
                end

                if total_cost > 0 then
                    if ((fallback_tooltip and fallback_tooltip.is_sell_penalty) or tooltip.is_sell_penalty) and item_data.sell_penalty then
                        total_cost = total_cost * item_data.sell_penalty
                    end
                    myframe = SetTooltipIcon(6, tooltip, "UI\\Widgets\\ToolTips\\Human\\ToolTipGoldIcon.blp", 0.0085, 0.0085, 1.05, tooltip.backdrop, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.0055, 0.0055, player)
                    height = height + BlzFrameGetHeight(myframe) * 2.55
                    SetTooltipText(master_index, tooltip, R2I(total_cost) .. single_item_cost, TEXT_JUSTIFY_LEFT, myframe, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.002, 0., player)
                end

            end


        local test_width
        for i = 1, master_index do
            test_width = BlzFrameGetWidth(tooltip.textframe[i]) * 1.07
            if test_width > width then
                width = test_width
            end
        end


        --print("most is " .. width)
        --print("before ------" .. BlzFrameGetWidth(tooltip.backdrop) .. " / " ..BlzFrameGetHeight(tooltip.backdrop) )
        BlzFrameSetSize(tooltip.backdrop, width, height * 1.2)
        BlzFrameSetPoint(tooltip.header, FRAMEPOINT_TOPRIGHT, tooltip.backdrop, FRAMEPOINT_TOPRIGHT, -0.004, -0.004)
        BlzFrameSetPoint(tooltip.header, FRAMEPOINT_TOPLEFT, tooltip.backdrop, FRAMEPOINT_TOPLEFT, 0.004, -0.004)
        BlzFrameSetPoint(tooltip.header, FRAMEPOINT_BOTTOM, tooltip.textframe[1], FRAMEPOINT_BOTTOM, 0., -0.007)
        for i = 1, 5 do BlzFrameSetVisible(tooltip.header_glow[i], false) end
        BlzFrameSetVisible(tooltip.header_glow[item_data.QUALITY or COMMON_ITEM], true)

        --BlzFrameSetPoint(tooltip.header_glow, FRAMEPOINT_TOPRIGHT, tooltip.backdrop, FRAMEPOINT_TOPRIGHT, -0.004, -0.004)
        --BlzFrameSetPoint(tooltip.header_glow, FRAMEPOINT_TOPLEFT, tooltip.backdrop, FRAMEPOINT_TOPLEFT, 0.004, -0.004)
        --BlzFrameSetPoint(tooltip.header_glow, FRAMEPOINT_BOTTOM, tooltip.textframe[1], FRAMEPOINT_BOTTOM, 0., -0.007)
        --BlzFrameSetSize(tooltip.header, BlzFrameGetWidth(tooltip.header), BlzFrameGetHeight(tooltip.textframe[1]))
        --print("after ------" .. BlzFrameGetWidth(tooltip.backdrop) .. " / " ..BlzFrameGetHeight(tooltip.backdrop) )
        --local offset = BlzFrameGetWidth(width / 1.98)
        --if direction == FRAMEPOINT_LEFT then offset = -offset end
        --BlzFrameSetPoint(tooltip.backdrop, FRAMEPOINT_CENTER, button.image, FRAMEPOINT_CENTER, offset, -0.01)

        --print("done")
    end


    ---@param player integer
    function RemoveTooltip(player)

        if PlayerTooltip[player] then
            RemoveSpecificTooltip(PlayerTooltip[player])
            PlayerTooltip[player] = nil
        end

        if AlternatePlayerTooltip[player] then
            RemoveSpecificTooltip(AlternatePlayerTooltip[player])
        end
    end


    ---@param tooltip framehandle
    function RemoveSpecificTooltip(tooltip)

        tooltip = GetTooltip(tooltip)

            for i = 15, 1, -1 do
                BlzFrameSetScale(tooltip.imageframe[i], 1.)
                BlzFrameSetVisible(tooltip.imageframe[i], false)
                BlzFrameSetText(tooltip.textframe[i], "")
                BlzFrameSetSize(tooltip.textframe[i], 0.0 ,0.0)
                BlzFrameSetScale(tooltip.textframe[i], 1.)
                BlzFrameSetVisible(tooltip.textframe[i], false)
            end

        BlzFrameSetVisible(tooltip.backdrop, false)

    end

    ---@param player integer
    function IsTooltipActive(player)
        return PlayerTooltip[player]
    end






end







