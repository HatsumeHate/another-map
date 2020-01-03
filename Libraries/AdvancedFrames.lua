do



    function GetButtonData(button)
        return ButtonList[GetHandleId(button)]
    end

    function CreateSprite(model, scale, relative_to_frame, relative_point_from, relative_point_to, offset_x, offset_y, parent)
        local new_Frame = BlzCreateFrameByType("SPRITE", "justAName", parent, "WarCraftIIILogo", 0)
            BlzFrameSetPoint(new_Frame, relative_point_from, relative_to_frame, relative_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, 1., 1.)
            BlzFrameSetScale(new_Frame, scale)
            BlzFrameSetModel(new_Frame, model, 0)
        return new_Frame
    end



    function CreateSimpleButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    function CreateTooltip(header, context, frame, size_x, size_y)
        local tooltip = BlzCreateFrame("BoxedText", frame, 0, 1)
            BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_RIGHT, 0, 0)
            BlzFrameSetTooltip(frame, tooltip)
            BlzFrameSetSize(tooltip, size_x, size_y)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 1), context)
            BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 1), header)
    end


    --======================================================================
    -- SLIDER MODE =========================================================

    SliderFrame = {}


    function DestroySlider(player)
        if SliderFrame[player] ~= nil then
            BlzDestroyFrame(SliderFrame[player].backdrop)
            DestroyTimer(SliderFrame[player].timer)
            DestroyTrigger(SliderFrame[player].trigger)
            SliderFrame[player] = nil
        end
    end


    function CreateSlider(player, origin_button, parent, ok_func, cancel_func)
        SliderFrame[player] = {}
        SliderFrame[player].backdrop = BlzCreateFrame("ScoreScreenButtonBackdropTemplate", parent, 0, 0)
        SliderFrame[player].slider = BlzCreateFrame("EscMenuSliderTemplate", SliderFrame[player].backdrop, 0, 0)
        SliderFrame[player].text_frame = BlzCreateFrameByType("BACKDROP", "text backdrop", SliderFrame[player].slider, "", 0)
        SliderFrame[player].text = BlzCreateFrame("EscMenuLabelTextTemplate",  SliderFrame[player].slider, 0, 0)


        BlzFrameSetPoint(SliderFrame[player].text_frame, FRAMEPOINT_BOTTOM, SliderFrame[player].slider, FRAMEPOINT_TOP, 0., 0.)
        BlzFrameSetSize(SliderFrame[player].text_frame, 0.012, 0.012)
        BlzFrameSetTexture(SliderFrame[player].text_frame, "GUI\\ChargesTexture.blp", 0, true)

        BlzFrameSetPoint(SliderFrame[player].backdrop, FRAMEPOINT_TOPLEFT, origin_button.image, FRAMEPOINT_TOPRIGHT, 0., 0.)

        BlzFrameSetMinMaxValue(SliderFrame[player].slider, 1, GetItemCharges(origin_button.item))
        BlzFrameSetValue(SliderFrame[player].slider, 1)
        BlzFrameSetStepSize(SliderFrame[player].slider, 1)

        BlzFrameSetSize(SliderFrame[player].backdrop, 0.115, 0.035)

        BlzFrameSetPoint(SliderFrame[player].slider, FRAMEPOINT_CENTER, SliderFrame[player].backdrop, FRAMEPOINT_CENTER, 0., 0.)
        BlzFrameSetSize(SliderFrame[player].slider, 0.1, 0.015)

        BlzFrameSetPoint(SliderFrame[player].text, FRAMEPOINT_CENTER, SliderFrame[player].text_frame, FRAMEPOINT_CENTER, 0., 0.)
        BlzFrameSetText(SliderFrame[player].text, GetItemCharges(origin_button.item))
        BlzFrameSetScale(SliderFrame[player].text_frame, 1.15)

        SliderFrame[player].button_ok = BlzCreateFrame("ScriptDialogButton", SliderFrame[player].slider, 0, 0)
        SliderFrame[player].button_cancel = BlzCreateFrame("ScriptDialogButton", SliderFrame[player].slider, 0, 1)

        BlzFrameSetPoint(SliderFrame[player].button_ok, FRAMEPOINT_TOPLEFT, SliderFrame[player].slider, FRAMEPOINT_BOTTOM, 0., 0.)
        BlzFrameSetPoint(SliderFrame[player].button_cancel, FRAMEPOINT_TOPRIGHT, SliderFrame[player].slider, FRAMEPOINT_BOTTOM, 0., 0.)

        BlzFrameSetSize(SliderFrame[player].button_ok, 0.05, 0.025)
        BlzFrameSetSize(SliderFrame[player].button_cancel, 0.05, 0.025)
        BlzFrameSetText(SliderFrame[player].button_ok, "ок")
        BlzFrameSetText(SliderFrame[player].button_cancel, "отмена")
        BlzFrameSetTextAlignment(SliderFrame[player].button_ok, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetTextAlignment(SliderFrame[player].button_cancel, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_MIDDLE)

        BlzFrameSetFocus(SliderFrame[player].slider, true)
        BlzFrameSetLevel(SliderFrame[player].slider, 3)


        SliderFrame[player].timer = CreateTimer()

        TimerStart(SliderFrame[player].timer, 0.08, true, function()
            BlzFrameSetText(SliderFrame[player].text, R2I(BlzFrameGetValue(SliderFrame[player].slider)))
        end)

        SliderFrame[player].trigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(SliderFrame[player].trigger, SliderFrame[player].button_ok, FRAMEEVENT_CONTROL_CLICK)
        BlzTriggerRegisterFrameEvent(SliderFrame[player].trigger, SliderFrame[player].button_cancel, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(SliderFrame[player].trigger, function()
            if BlzGetTriggerFrame() == SliderFrame[player].button_ok then
                if ok_func ~= nil then ok_func() end
            else
                if cancel_func ~= nil then cancel_func() end
            end
            DestroySlider(player)
        end)
    end



    --======================================================================
    -- CONTEXT MENU   ======================================================
    ContextFrame = {}

    function DestroyContextMenu(player)
        if ContextFrame[player] ~= nil then
            for i = 1, #ContextFrame[player].frames do
                BlzDestroyFrame(ContextFrame[player].frames[i])
            end
            BlzDestroyFrame(ContextFrame[player].backdrop)
            DestroyTrigger(ContextFrame[player].focus_trigger)
            ContextFrame[player].frames = nil
            ContextFrame[player] = nil
        end
    end



     function AddContextOption(player, text, result)
        local frame = BlzCreateFrame('ScriptDialogButton', ContextFrame[player].backdrop, 0, 0)
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

        BlzFrameSetPoint(ContextFrame[player].focus_frame, FRAMEPOINT_CENTER, ContextFrame[player].backdrop, FRAMEPOINT_CENTER, 0.,0.)
        BlzFrameSetSize(ContextFrame[player].focus_frame, BlzFrameGetWidth(ContextFrame[player].backdrop) + 0.02, BlzFrameGetHeight(ContextFrame[player].backdrop) + 0.02)
        FrameRegisterNoFocus(frame)

    end



    function CreatePlayerContextMenu(player, originframe, parent)
        DestroyContextMenu(player)
        ContextFrame[player] = {}
        ContextFrame[player].frames = {}
        ContextFrame[player].backdrop = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', parent, 0, 0)
        ContextFrame[player].originframe = originframe
        ContextFrame[player].focus_frame = BlzCreateFrameByType("TEXT", "123asd", ContextFrame[player].backdrop, "", 0)
        ContextFrame[player].focus_trigger = CreateTrigger()
        BlzTriggerRegisterFrameEvent(ContextFrame[player].focus_trigger, ContextFrame[player].focus_frame, FRAMEEVENT_MOUSE_LEAVE)

        BlzFrameSetPoint(ContextFrame[player].focus_frame, FRAMEPOINT_CENTER, ContextFrame[player].backdrop, FRAMEPOINT_CENTER, 0.,0.)

        TriggerAddAction(ContextFrame[player].focus_trigger, function()
            DestroyContextMenu(player)
        end)

        BlzFrameSetPoint(ContextFrame[player].backdrop, FRAMEPOINT_LEFT, originframe, FRAMEPOINT_RIGHT, 0.,0.)
        RemoveTooltip(player)
        return ContextFrame[player].backdrop
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

-- ButtonList[GetHandleId(InventorySlots[32])].image
     function ShowTooltip(player, h, parent)
         local item_data = GetItemData(ButtonList[h].item)
         local width = 0.
         local frame_number = 1

         if ContextFrame[player] ~= nil or SliderFrame[player] ~= nil then return end
         RemoveTooltip(player)

         PlayerTooltip[player] = {}
         PlayerTooltip[player].frames = {}

         PlayerTooltip[player].backdrop = BlzCreateFrame("BoxedText", parent, 150, 0)

         local property_text = ""
         if item_data.SUBTYPE ~= nil then
             property_text = GetItemSubTypeName(item_data.SUBTYPE) .. "|n" .. "|n"
         end

         if item_data.TYPE == ITEM_TYPE_WEAPON then
             property_text = property_text .. LOCALE_LIST[my_locale].DAMAGE_UI .. R2I(item_data.DAMAGE * item_data.DISPERSION[1]) .. "-" .. R2I(item_data.DAMAGE * item_data.DISPERSION[2]) ..
                     "|n" .. LOCALE_LIST[my_locale].DAMAGE_TYPE_UI .. GetItemAttributeName(item_data.ATTRIBUTE)
         elseif item_data.TYPE == ITEM_TYPE_ARMOR then
             property_text = property_text .. LOCALE_LIST[my_locale].DEFENCE_UI .. item_data.DEFENCE
         elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
             property_text = property_text .. LOCALE_LIST[my_locale].SUPPRESSION_UI .. item_data.SUPPRESSION
         elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
             property_text = property_text .. LOCALE_LIST[my_locale].DEFENCE_UI .. item_data.DEFENCE
         end

            --[[
        elseif item_data.TYPE == ITEM_TYPE_GEM then
            property_text = LOCALE_LIST[my_locale].DEFENCE_UI
        elseif item_data.TYPE == ITEM_TYPE_CONSUMABLE then
            property_text = "Потребляемое"
        end]]


        local bonus_text

        if item_data.BONUS ~= nil and #item_data.BONUS > 0 then

            bonus_text = LOCALE_LIST[my_locale].ADDITIONAL_INFO_UI
            for i = 1, #item_data.BONUS do
                bonus_text = bonus_text .. GetParameterName(item_data.BONUS[i].PARAM) .. ": " .. GetCorrectParamText(item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD) .. "|n"
            end

        end

        if item_data.SKILL_BONUS ~= nil and #item_data.SKILL_BONUS > 0 then
            local skill_bonus_text = ""

            for i = 1, #item_data.SKILL_BONUS do
                skill_bonus_text = skill_bonus_text .. GetSkillName(item_data.SKILL_BONUS[i].id) .. " +" .. item_data.SKILL_BONUS[i].bonus_levels .. "|n"
            end

            if bonus_text ~= nil then
                bonus_text = bonus_text..skill_bonus_text
            else
                bonus_text = LOCALE_LIST[my_locale].ADDITIONAL_INFO_UI .. skill_bonus_text
            end

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
            if bonus_text == nil then
                bonus_text = "|n" .. item_data.item_description
            else
                bonus_text = bonus_text .. "|n" .. item_data.item_description
            end

        end

        BlzFrameSetAllPoints(PlayerTooltip[player].backdrop, ButtonList[h].image)


        PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "name", PlayerTooltip[player].backdrop, "", 0)
        BlzFrameSetPoint(PlayerTooltip[player].frames[frame_number], FRAMEPOINT_CENTER, ButtonList[h].image, FRAMEPOINT_CENTER, 0.05, -0.01)
        BlzFrameSetText(PlayerTooltip[player].frames[frame_number], GetItemNameColorized(ButtonList[h].item))
        BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
        BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 1.3)

        LockWidth(PlayerTooltip[player].frames[frame_number], BlzFrameGetWidth(PlayerTooltip[player].frames[frame_number]), 0.06, 0.14)


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


        if item_data.legendary_description ~= nil then
            frame_number = frame_number + 1

            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "legend", PlayerTooltip[player].frames[frame_number - 1], "", 0)
            BlzFrameSetText(PlayerTooltip[player].frames[frame_number], "|c00DF0000"..item_data.legendary_description.."|r")
            BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], 0.01, 0.01)
            LockWidth(PlayerTooltip[player].frames[frame_number], BlzFrameGetWidth(PlayerTooltip[player].frames[frame_number]), 0.16, 0.2)
            BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], BlzFrameGetWidth(PlayerTooltip[player].frames[frame_number]), BlzFrameGetHeight(PlayerTooltip[player].frames[frame_number]) + 0.01)
        end


        if item_data.MAX_SLOTS ~= nil and item_data.MAX_SLOTS > 0 then
            frame_number = frame_number + 1

            local free_stone_slots = item_data.MAX_SLOTS - #item_data.STONE_SLOTS
            local stones_text = LOCALE_LIST[my_locale].SLOTS_UI
            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "STONE", PlayerTooltip[player].frames[frame_number - 1], "", 0)

            for i = 1, #item_data.STONE_SLOTS do
                if item_data.STONE_SLOTS[i] ~= nil then
                    stones_text = stones_text .. GetParameterName(item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM) .. ": "
                            .. GetCorrectParamText(item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE,
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

                local offset_bonus = 4 - free_stone_slots
                if offset_bonus < 0 then offset_bonus = 0 end

                offset_bonus = offset_bonus * 0.15

                    for i = 1, free_stone_slots do
                        stones[i] = BlzCreateFrameByType("BACKDROP", "STONE", PlayerTooltip[player].frames[frame_number], "", 0)
                        BlzFrameSetTexture(stones[i], "GUI\\empty stone.blp", 0, true)
                        BlzFrameSetSize(stones[i], 0.015, 0.015)
                        if i == 1 then
                            BlzFrameSetPoint(stones[i], FRAMEPOINT_CENTER, PlayerTooltip[player].frames[frame_number], FRAMEPOINT_CENTER, free_stone_slots*((free_stone_slots * 0.0015) * (-1. - offset_bonus)),  0.)
                        else
                            BlzFrameSetPoint(stones[i], FRAMEPOINT_LEFT, stones[i - 1], FRAMEPOINT_RIGHT, 0., 0.)
                        end
                    end

                stones = nil
            end

        end


        if item_data.special_description ~= nil then
            frame_number = frame_number + 1

            PlayerTooltip[player].frames[frame_number] = BlzCreateFrameByType("TEXT", "special", PlayerTooltip[player].frames[frame_number - 1], "", 0)
            BlzFrameSetText(PlayerTooltip[player].frames[frame_number], "|c00FF9748"..item_data.special_description.."|r")
            BlzFrameSetTextAlignment(PlayerTooltip[player].frames[frame_number], TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            BlzFrameSetSize(PlayerTooltip[player].frames[frame_number], 0.01, 0.01)
            LockWidth(PlayerTooltip[player].frames[frame_number], BlzFrameGetWidth(PlayerTooltip[player].frames[frame_number]), 0.16, 0.2)
            BlzFrameSetScale(PlayerTooltip[player].frames[frame_number], 0.9)
        end


        local cost_Frame

        if item_data.sell_value ~= nil or item_data.cost ~= nil then
            local total_cost = 0

            if item_data.sell_value ~= nil then total_cost = total_cost + item_data.sell_value end
            if item_data.cost ~= nil then total_cost = total_cost + item_data.cost end

            if GetItemCharges(item_data.item) > 1 then
                total_cost = total_cost * GetItemCharges(item_data.item)
            end

            if total_cost > 0 then
                cost_Frame = BlzCreateFrameByType("BACKDROP", "GOLD TEXTURE", PlayerTooltip[player].frames[frame_number], "", 0)
                BlzFrameSetTexture(cost_Frame, "UI\\Widgets\\ToolTips\\Human\\ToolTipGoldIcon.blp", 0, true)
                BlzFrameSetSize(cost_Frame, 0.0085, 0.0085)
                BlzFrameSetScale(cost_Frame, 1.05)

                local cost_text_Frame = BlzCreateFrameByType("TEXT", "cost", cost_Frame, "", 0)
                BlzFrameSetPoint(cost_text_Frame, FRAMEPOINT_LEFT, cost_Frame, FRAMEPOINT_RIGHT, 0.002, 0.)
                BlzFrameSetText(cost_text_Frame, R2I(total_cost))
                BlzFrameSetTextAlignment(cost_text_Frame, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
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


        --BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOP, PlayerTooltip[player].frames[1], FRAMEPOINT_TOP, 0., 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPLEFT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPLEFT, -0.007, 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_TOPRIGHT, PlayerTooltip[player].frames[1], FRAMEPOINT_TOPRIGHT, 0.007, 0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMLEFT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMLEFT, -0.007, -0.007)
        BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.007)
        --BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOM, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOM, 0., -0.007)

        if cost_Frame ~= nil then
            BlzFrameSetPoint(cost_Frame, FRAMEPOINT_BOTTOMLEFT, PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMLEFT, 0.0055, 0.0055)
            BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMLEFT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMLEFT, -0.007, -0.015)
            BlzFrameSetPoint(PlayerTooltip[player].backdrop, FRAMEPOINT_BOTTOMRIGHT, PlayerTooltip[player].frames[#PlayerTooltip[player].frames], FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.015)
        end
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








end







