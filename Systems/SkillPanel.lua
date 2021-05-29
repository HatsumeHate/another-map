---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 30.12.2019 14:00
---
do

    SkillPanelFrame = {}

    SkillPanelButton = nil

    local ClickTrigger = CreateTrigger()
    local EnterTrigger = CreateTrigger()
    local LeaveTrigger = CreateTrigger()

    local SKILL_BUTTON = 0


    ---@param player integer
    ---@param button_data table
    ---@param skip_key integer
    function CreateBindContext(player, button_data, skip_key)

        for key = KEY_Q, KEY_D do
            if skip_key ~= key then
                AddContextOption(player, KEYBIND_LIST[key].bind_name, function()
                    local skill = button_data.skill
                    UnregisterPlayerSkillHotkey(player, button_data.skill)
                    RegisterPlayerSkillHotkey(player, skill, key)
                end)
            end
        end

    end


    ---@param player integer
    ---@param skill table
    function UnregisterPlayerSkillHotkey(player, skill)

        for i = KEY_Q, KEY_D do
            local button = GetButtonData(SkillPanelFrame[player].button_keys[i])
                -- and not BlzGetUnitAbilityCooldownRemaining(PlayerHero[player], GetKeybindAbilityId(FourCC(skill.Id), player-1)) > 0.
                --print(R2S(BlzGetUnitAbilityCooldownRemaining(PlayerHero[player], GetKeybindAbilityId(skill.Id, player-1))))

                if button.skill ~= nil and skill.Id == button.skill.Id and not (BlzGetUnitAbilityCooldownRemaining(PlayerHero[player], GetKeybindKeyAbility(FourCC(skill.Id), player)) > 0.) then
                    --GetKeybindAbilityId(skill.Id, player-1)
                    --print("skill is found, trying to unbind")
                    UnbindAbilityKey(PlayerHero[player], skill.Id)
                    --print("skill is unbinded")
                    BlzFrameSetTexture(button.image, "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0, true)
                    FrameChangeTexture(button.button, "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
                    button.skill = nil
                    break
                end

        end

    end


    ---@param player integer
    ---@param skill table
    ---@param key integer
    function RegisterPlayerSkillHotkey(player, skill, key)
        local key_button_data = GetButtonData(SkillPanelFrame[player].button_keys[key])
        local ability = GetKeybindKeyAbility(FourCC(skill.Id), player)

            if (ability == 0 or (ability ~= 0 and not (BlzGetUnitAbilityCooldownRemaining(PlayerHero[player], ability) > 0.))) and not (BlzGetUnitAbilityCooldownRemaining(PlayerHero[player], KEYBIND_LIST[key].ability) > 0.) then
                BindAbilityKey(PlayerHero[player], skill.Id, key)
                BlzFrameSetTexture(key_button_data.image, skill.icon, 0, true)
                FrameChangeTexture(key_button_data.button, skill.icon)
                key_button_data.skill = skill
                --print("ability " .. key_button_data.skill.name .." is binded")
                --print("ability " .. key_button_data.skill.name .." id is " .. key_button_data.skill.Id)
            end

    end


    ---@param player integer
    function UpdateSkillWindow(player)
        local max_skill_count = #SkillPanelFrame[player].category[SkillPanelFrame[player].current_category].skill_list

            if max_skill_count == nil or max_skill_count <= 0 then
                max_skill_count = 1
            end

            BlzFrameSetMinMaxValue(SkillPanelFrame[player].slider, 1., max_skill_count)
            local current_position = max_skill_count - BlzFrameGetValue(SkillPanelFrame[player].slider)

            for i = 1, 4 do
                local button_data = GetButtonData(SkillPanelFrame[player].displayed_skill_button[i])
                local position = current_position + i

                    if position <= max_skill_count and SkillPanelFrame[player].category[SkillPanelFrame[player].current_category].skill_list[position] ~= nil then

                        button_data.skill = SkillPanelFrame[player].category[SkillPanelFrame[player].current_category].skill_list[position]
                        BlzFrameSetTexture(button_data.image, button_data.skill.icon, 0, true)
                        FrameChangeTexture(button_data.button, button_data.skill.icon)
                        BlzFrameSetVisible(SkillPanelFrame[player].displayed_skill_button[i], true)
                        BlzFrameSetText(button_data.name_text, button_data.skill.name)
                        BlzFrameSetText(button_data.level_text, LOCALE_LIST[my_locale].SKILL_PANEL_LVL_TEXT .. UnitGetAbilityLevel(PlayerHero[player], button_data.skill.Id))

                    else
                        button_data.skill = nil
                        BlzFrameSetVisible(SkillPanelFrame[player].displayed_skill_button[i], false)
                    end

            end

    end


    ---@param player integer
    function UpdateSkillList(player)
        local unit_data = GetUnitData(PlayerHero[player])
        local c = SkillPanelFrame[player].current_category or CLASS_SKILL_CATEGORY[unit_data.unit_class][1]

            SkillPanelFrame[player].category[c].skill_list = nil
            SkillPanelFrame[player].category[c].skill_list = {}

            for skill = 1, #unit_data.skill_list do
                if unit_data.skill_list[skill].category == CLASS_SKILL_CATEGORY[unit_data.unit_class][c] then
                    SkillPanelFrame[player].category[c].skill_list[#SkillPanelFrame[player].category[c].skill_list + 1] = unit_data.skill_list[skill]
                end
            end

            BlzFrameSetMinMaxValue(SkillPanelFrame[player].slider, 1., #SkillPanelFrame[player].category[c].skill_list)
            BlzFrameSetValue(SkillPanelFrame[player].slider, #SkillPanelFrame[player].category[c].skill_list)

        UpdateSkillWindow(player)
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
        local handle = GetHandleId(new_Frame)

            ButtonList[handle] = {
                button_type = button_type,
                skill = nil,
                button = new_Frame,
                image = new_FrameImage,
                original_texture = texture,
                sprite = nil
            }

            FrameRegisterNoFocus(new_Frame)
            FrameRegisterClick(new_Frame, texture)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
            BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)


            if button_type == SKILL_BUTTON then
                local new_FrameText = BlzCreateFrameByType("TEXT", "skill name", new_FrameImage, "", 0)
                local new_FrameLevelText = BlzCreateFrameByType("TEXT", "skill name", new_FrameImage, "", 0)

                    BlzFrameSetTextAlignment(new_FrameText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
                    BlzFrameSetPoint(new_FrameText, FRAMEPOINT_LEFT, new_FrameImage, FRAMEPOINT_RIGHT, 0.005, 0.008)
                    BlzFrameSetScale(new_FrameText, 0.93)


                    BlzFrameSetTextAlignment(new_FrameLevelText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
                    BlzFrameSetPoint(new_FrameLevelText, FRAMEPOINT_LEFT, new_FrameImage, FRAMEPOINT_RIGHT, 0.005, -0.005)
                    BlzFrameSetScale(new_FrameLevelText, 1.03)

                    ButtonList[handle].name_text = new_FrameText
                    ButtonList[handle].level_text = new_FrameLevelText
            elseif button_type > 0 then
                local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", new_FrameImage, "", 0)
                local new_FrameText = BlzCreateFrameByType("TEXT", "hotkey", new_FrameCharges, "", 0)

                    BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, new_FrameImage, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
                    BlzFrameSetSize(new_FrameCharges, 0.012, 0.012)
                    BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)

                    BlzFrameSetTextAlignment(new_FrameText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
                    BlzFrameSetPoint(new_FrameText, FRAMEPOINT_CENTER, new_FrameCharges, FRAMEPOINT_CENTER, 0., 0.)
                    BlzFrameSetScale(new_FrameText, 0.98)

                    if button_type == KEY_Q then BlzFrameSetText(new_FrameText, "Q")
                    elseif button_type == KEY_W then BlzFrameSetText(new_FrameText, "W")
                    elseif button_type == KEY_E then BlzFrameSetText(new_FrameText, "E")
                    elseif button_type == KEY_R then BlzFrameSetText(new_FrameText, "R")
                    elseif button_type == KEY_D then BlzFrameSetText(new_FrameText, "D")
                    elseif button_type == KEY_F then BlzFrameSetText(new_FrameText, "F") end

            end

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end

    ---@param player integer
    function DrawSkillPanel(player)
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)
        local new_Frame
        local unit_data = GetUnitData(PlayerHero[player])

            SkillPanelFrame[player] = {}

            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.08)
            BlzFrameSetSize(main_frame, 0.28, 0.31)


            local category_border_panel = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            BlzFrameSetPoint(category_border_panel, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.015, -0.015)
            BlzFrameSetSize(category_border_panel, BlzFrameGetWidth(main_frame) - (BlzFrameGetWidth(main_frame) * 0.75), BlzFrameGetHeight(main_frame) * 0.64)



            SkillPanelFrame[player].category = {}
            SkillPanelFrame[player].current_category = 1

            for i = 1, #CLASS_SKILL_CATEGORY[unit_data.unit_class] do
                local icon_path = SKILL_CATEGORY_ICON[CLASS_SKILL_CATEGORY[unit_data.unit_class][i]]

                SkillPanelFrame[player].category[i] = {}
                SkillPanelFrame[player].category[i].skill_list = {}

                    if i == 1 then
                        local button_data
                        SkillPanelFrame[player].category[i].button = NewButton(-1, icon_path, 0.035, 0.035, category_border_panel, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.02, main_frame)
                        button_data = GetButtonData(SkillPanelFrame[player].category[i].button)
                        button_data.sprite = CreateSprite("selecter2.mdx", 0.9, SkillPanelFrame[player].category[i].button, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, button_data.image)
                    else
                        SkillPanelFrame[player].category[i].button = NewButton(i * -1, icon_path, 0.035, 0.035, SkillPanelFrame[player].category[i-1].button, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., -0.0055, SkillPanelFrame[player].category[i-1].button)
                    end

            end


            local skill_bind_panel = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            BlzFrameSetPoint(skill_bind_panel, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
            BlzFrameSetPoint(skill_bind_panel, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
            BlzFrameSetSize(skill_bind_panel, 0.1, 0.07)


            SkillPanelFrame[player].button_keys = {}
            SkillPanelFrame[player].button_keys[KEY_Q] = NewButton(KEY_Q, "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.035, 0.035, skill_bind_panel, FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.017, 0., main_frame)

                for key = 2, KEY_D do
                    SkillPanelFrame[player].button_keys[key] = NewButton(key, "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.035, 0.035, SkillPanelFrame[player].button_keys[key-1], FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0012, 0., SkillPanelFrame[player].button_keys[key-1])
                end


            SkillPanelFrame[player].displayed_skill_button = {}

            local last_frame
            for i = 1, 4 do
                new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                    if i == 1 then
                        BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, category_border_panel, FRAMEPOINT_TOPRIGHT, -0.006, 0.)
                    else
                        BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOP, last_frame, FRAMEPOINT_BOTTOM, 0., 0.01)
                    end
                BlzFrameSetSize(new_Frame, 0.18, 0.06)
                SkillPanelFrame[player].displayed_skill_button[i] = NewButton(SKILL_BUTTON, "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0.03, 0.03, new_Frame, FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0.015, 0., new_Frame)
                BlzFrameSetVisible(SkillPanelFrame[player].displayed_skill_button[i], false)
                last_frame = new_Frame
            end


            new_Frame = BlzCreateFrameByType("SLIDER", "ASD", main_frame, "QuestMainListScrollBar", 0)
            BlzFrameClearAllPoints(new_Frame)
            BlzFrameSetMinMaxValue(new_Frame, 1, 1)
            BlzFrameSetValue(new_Frame, 1)
            BlzFrameSetStepSize(new_Frame, 1)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_RIGHT, main_frame, FRAMEPOINT_RIGHT, -0.015, 0.035)
            BlzFrameSetSize(new_Frame, 0.015, 0.2)

            SkillPanelFrame[player].slider = new_Frame

            local trg = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trg, SkillPanelFrame[player].slider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
            TriggerAddAction(trg, function ()
                local id = GetPlayerId(GetTriggerPlayer()) + 1
                    if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_WHEEL then
                        if BlzGetTriggerFrameValue() > 0 then
                            BlzFrameSetValue(SkillPanelFrame[id].slider, BlzFrameGetValue(SkillPanelFrame[id].slider) + 1)
                        else
                            BlzFrameSetValue(SkillPanelFrame[id].slider, BlzFrameGetValue(SkillPanelFrame[id].slider) - 1)
                        end
                    end
                    UpdateSkillWindow(id)
                end)

            BlzTriggerRegisterFrameEvent(trg, SkillPanelFrame[player].slider, FRAMEEVENT_MOUSE_WHEEL)


        SkillPanelFrame[player].tooltip = NewTooltip(SkillPanelFrame[player].slider)

        BlzFrameSetVisible(main_frame, false)

        SkillPanelFrame[player].main_frame = main_frame
        SkillPanelFrame[player].state = false


        --SkillPanelFrame[player].default_category = CLASS_SKILL_CATEGORY[unit_data.unit_class][1]
    end

    
    function SkillPanelInit()
        SkillPanelButton = CreateSimpleButton("ReplaceableTextures\\CommandButtons\\BTNSpellBookBLS.blp", 0.03, 0.03, InventoryTriggerButton, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.01, 0., GAME_UI)
        CreateTooltip(LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_NAME, LOCALE_LIST[my_locale].SKILL_PANEL_TOOLTIP_DESCRIPTION, SkillPanelButton, 0.14, 0.06)
        BlzFrameSetVisible(SkillPanelButton, false)

            local trg = CreateTrigger()
            BlzTriggerRegisterFrameEvent(trg, SkillPanelButton, FRAMEEVENT_CONTROL_CLICK)
            TriggerAddAction(trg, function()
                local player = GetPlayerId(GetTriggerPlayer()) + 1

                    if GetLocalPlayer() == Player(player-1) then
                        BlzFrameSetVisible(SkillPanelFrame[player].main_frame, not BlzFrameIsVisible(SkillPanelFrame[player].main_frame))
                        BlzFrameSetVisible(PlayerStatsFrame[player], false)
                    end

                UpdateSkillList(player)
                DestroyContextMenu(player)
                RemoveTooltip(player)
                SkillPanelFrame[player].state = not SkillPanelFrame[player].state
                end)


        TriggerAddAction(LeaveTrigger, function()
            RemoveTooltip(GetPlayerId(GetTriggerPlayer()) + 1)
        end)

        TriggerAddAction(EnterTrigger, function()
            local button_data = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1

                if button_data.skill ~= nil then
                    ShowSkillTooltip(button_data.skill, SkillPanelFrame[player].tooltip, button_data, player)
                end

        end)


        TriggerAddAction(ClickTrigger, function ()
            local button_data = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1


                if button_data.button_type < 0 then
                    local last_category_button = GetButtonData(SkillPanelFrame[player].category[SkillPanelFrame[player].current_category].button)
                    if last_category_button.sprite ~= nil then BlzDestroyFrame(last_category_button.sprite) end

                    button_data.sprite = CreateSprite("selecter2.mdx", 0.9, SkillPanelFrame[player].category[button_data.button_type * -1].button, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, button_data.image)
                    SkillPanelFrame[player].current_category = button_data.button_type * -1
                    UpdateSkillList(player)
                    DestroyContextMenu(player)
                elseif button_data.button_type == SKILL_BUTTON then
                    CreatePlayerContextMenu(player, button_data.button, FRAMEPOINT_RIGHT, SkillPanelFrame[player].slider)
                    CreateBindContext(player, button_data, 0)
                elseif button_data.button_type > 0 then
                    if button_data.skill ~= nil then
                        CreatePlayerContextMenu(player, button_data.button, FRAMEPOINT_RIGHT, SkillPanelFrame[player].slider)
                        CreateBindContext(player, button_data, button_data.button_type)
                        AddContextOption(player, LOCALE_LIST[my_locale].SKILL_PANEL_UNBIND, function()
                            --print(button_data.skill.name)
                            UnregisterPlayerSkillHotkey(player, button_data.skill)
                        end)
                    end
                end

        end)

    end

end