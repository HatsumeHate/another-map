---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 18.09.2021 23:07
---

do

    TalentPanel = nil
    local BUTTON_SIZE = 0.036
    local BUTTON_INTERVAL = 0.026
    local ROW_INTERVAL = 0.034
    local ROWS = 6
    local MAX_BUTTONS = 30
    local ClickTrigger
    local EnterTrigger
    local LeaveTrigger
    local TalentData
    local last_EnteredFrame
    local last_EnteredFrameTimer


    local function NewButtonSimple(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local border = BlzCreateFrame("EscMenuBackdropEx", new_Frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
        local sprite = CreateSprite("selecter4.mdx", 0.9, new_Frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, new_Frame)

            ButtonList[new_Frame] = {
                frame = new_Frame, image = new_FrameImage, category = nil, sprite = sprite, points_spent = 0
            }

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

            BlzFrameSetPoint(border, FRAMEPOINT_TOPRIGHT, new_Frame, FRAMEPOINT_TOPRIGHT, 0.008, 0.008)
            BlzFrameSetPoint(border, FRAMEPOINT_BOTTOMLEFT, new_Frame, FRAMEPOINT_BOTTOMLEFT, -0.008, -0.008)
            BlzFrameSetVisible(sprite, false)
            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)


        return new_Frame
    end


    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local border = BlzCreateFrame("EscMenuBackdropEx", new_Frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
        local new_FrameMask = BlzCreateFrameByType("BACKDROP", "ButtonMask", new_Frame, "", 0)
        local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", new_Frame, "", 0)
        local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
        local new_FrameBorder = BlzCreateFrameByType("BACKDROP", "ButtonBorder", new_Frame, "", 0)

            ButtonList[new_Frame] = {
                frame = new_Frame, image = new_FrameImage, mask = new_FrameMask, charges_frame = new_FrameCharges, charges_text_frame = new_FrameChargesText, talent = nil
            }

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetTexture(new_FrameMask, "UI\\LockedMask.blp", 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

            BlzFrameSetPoint(border, FRAMEPOINT_TOPRIGHT, new_Frame, FRAMEPOINT_TOPRIGHT, 0.008, 0.008)
            BlzFrameSetPoint(border, FRAMEPOINT_BOTTOMLEFT, new_Frame, FRAMEPOINT_BOTTOMLEFT, -0.008, -0.008)
            --BlzFrameSetAllPoints(border, new_Frame)

            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMRIGHT, new_FrameImage, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.002)
            BlzFrameSetAllPoints(new_FrameMask, new_FrameImage)
            BlzFrameSetSize(new_FrameCharges, 0.01, 0.01)
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
            BlzFrameSetPoint(new_FrameChargesText, FRAMEPOINT_CENTER, new_FrameCharges, FRAMEPOINT_CENTER, 0.,0.)
            BlzFrameSetText(new_FrameChargesText, "")

            BlzFrameSetTexture(new_FrameBorder, "DiabolicUI_Button_50x50_BorderHighlight.tga", 0, true)
            BlzFrameSetPoint(new_FrameBorder, FRAMEPOINT_TOPRIGHT, new_Frame, FRAMEPOINT_TOPRIGHT, 0.009, 0.009)
            BlzFrameSetPoint(new_FrameBorder, FRAMEPOINT_BOTTOMLEFT, new_Frame, FRAMEPOINT_BOTTOMLEFT, -0.009, -0.009)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
            BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)

        return new_Frame
    end



    local function TalentPanelClear(player)
        local panel = TalentPanel[player]
        local button_data

        for i = 1, MAX_BUTTONS do
            button_data = GetButtonData(panel.talent_buttons[i])
            BlzFrameSetVisible(panel.talent_buttons[i], false)
            button_data.talent = nil
            button_data.connections = nil
        end

        for i = 1, #panel.connectors do
            BlzFrameSetVisible(panel.connectors[i], false)
        end

        panel.current_row_amount = 0
        panel.button_index = 0
        panel.connector_index = 0
    end


    ---@param player integer
    local function TalentPanelUpdateRows(player)
        local panel = TalentPanel[player]
        
        local total_width = (panel.current_row_amount * BUTTON_SIZE)+ ((panel.current_row_amount-1) * ROW_INTERVAL)
        local delta_width = total_width / panel.current_row_amount
        local half_amount = panel.current_row_amount * 0.5
        local start_width = (delta_width * half_amount) - (delta_width / 2.)

        for i = 1, panel.current_row_amount do
            BlzFrameClearAllPoints(panel.row[i])
            BlzFrameSetPoint(panel.row[i], FRAMEPOINT_CENTER, panel.background, FRAMEPOINT_CENTER, 0., start_width)
            start_width = start_width - delta_width
        end
    end


    ---@param player integer
    ---@param amount integer
    function TalentPanelAddRow(player, amount)
        local panel = TalentPanel[player]
        local row_buttons = {}

        panel.current_row_amount = panel.current_row_amount + 1

        local total_width = (amount * BUTTON_SIZE)+ ((amount-1) * BUTTON_INTERVAL)
        local delta_width = total_width / amount
        local half_amount = amount * 0.5
        local start_width = ((delta_width * half_amount) * -1.) + (delta_width / 2.)

        for i = 1, amount do
            panel.button_index = panel.button_index + 1
            BlzFrameClearAllPoints(panel.talent_buttons[panel.button_index])
            BlzFrameSetPoint(panel.talent_buttons[panel.button_index], FRAMEPOINT_CENTER, panel.row[panel.current_row_amount], FRAMEPOINT_CENTER, start_width, 0.)
            start_width = start_width + delta_width
            BlzFrameSetVisible(panel.talent_buttons[panel.button_index], true)
            row_buttons[#row_buttons+1] = panel.talent_buttons[panel.button_index]
        end

        TalentPanelUpdateRows(player)
        return row_buttons
    end


    function AddTalentCategories(unit, player)
        DrawTalentWindow(player)
        local unit_data = GetUnitData(unit)

        for i = 1, 3 do
            local button_data = GetButtonData(TalentPanel[player].category_button[i])
            button_data.category = CLASS_SKILL_CATEGORY[unit_data.unit_class][i]
            BlzFrameSetTexture(button_data.image, SKILL_CATEGORY_ICON[button_data.category], 0, true)
            FrameChangeTexture(button_data.frame, SKILL_CATEGORY_ICON[button_data.category])
        end

        TalentPanel[player].current_category = CLASS_SKILL_CATEGORY[unit_data.unit_class][1]
        TalentPanel[player].tooltip = NewTooltip(TalentPanel[player].points_border_frame, "MyTextTemplateMedium")
        TalentPanel[player].alt_tooltip = NewTooltip(TalentPanel[player].points_border_frame, "MyTextTemplateMedium")
        TalentPanel[player].class = unit_data.unit_class
    end


    function ReloadTalentFrames()
        for player = 1, 6 do
            if PlayerHero[player] then
                local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

                BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.05)
                BlzFrameSetSize(main_frame, 0.34, 0.43)

                local new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)

                BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.075)

                TalentPanel[player].current_row_amount = 0
                TalentPanel[player].current_col_amount = 0
                TalentPanel[player].button_index = 0
                TalentPanel[player].connector_index = 0
                TalentPanel[player].background = new_Frame


                new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)


                TalentPanel[player].categories_border = new_Frame

                TalentPanel[player].category_button = {
                    [2] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, main_frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.03, main_frame)
                }

                TalentPanel[player].category_button[1] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, TalentPanel[player].category_button[2], FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.016, 0., main_frame)
                TalentPanel[player].category_button[3] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, TalentPanel[player].category_button[2], FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.016, 0., main_frame)

                TalentPanel[player].last_category_button = TalentPanel[player].category_button[1]

                BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, TalentPanel[player].category_button[3], FRAMEPOINT_TOPRIGHT, 0.016, 0.016)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, TalentPanel[player].category_button[1], FRAMEPOINT_BOTTOMLEFT, -0.016, -0.016)

                for i = 1, ROWS do
                    TalentPanel[player].row[i] = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
                    BlzFrameClearAllPoints(TalentPanel[player].row[i])
                    BlzFrameSetPoint(TalentPanel[player].row[i], FRAMEPOINT_CENTER, new_Frame, FRAMEPOINT_CENTER, 0., 0.)
                    BlzFrameSetSize(TalentPanel[player].row[i], 0.1, 0.1)
                    BlzFrameSetAlpha(TalentPanel[player].row[i], 0)
                end

                for i = 1, MAX_BUTTONS * 2 do
                    TalentPanel[player].connectors[i] = CreateSprite("", 0.0003, TalentPanel[player].background, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., 0., TalentPanel[player].background)
                    BlzFrameSetVisible(TalentPanel[player].connectors[i], false)
                end

                for i = 1, MAX_BUTTONS do
                    TalentPanel[player].talent_buttons[i] = NewButton("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.036, -0.036, new_Frame)
                    BlzFrameSetVisible(TalentPanel[player].talent_buttons[i], false)
                end

                new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.02)
                BlzFrameSetSize(new_Frame, 0.07, 0.06)
                TalentPanel[player].points_border_frame = new_Frame

                new_Frame = BlzCreateFrameByType("TEXT", "text", main_frame, "MyTextTemplate", 0)
                BlzFrameSetPoint(new_Frame, FRAMEPOINT_CENTER, TalentPanel[player].points_border_frame, FRAMEPOINT_CENTER, 0., 0.)
                BlzFrameSetText(new_Frame, "1")
                BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_CENTER )
                BlzFrameSetScale(new_Frame, 1.1)


                TalentPanel[player].points_text_frame = new_Frame
                BlzFrameSetText(TalentPanel[player].points_text_frame, TalentPanel[player].points)

                TalentPanel[player].main_frame = main_frame
                BlzFrameSetVisible(main_frame, false)
                TalentPanel[player].state = false

                local unit_data = GetUnitData(PlayerHero[player])

                for i = 1, 3 do
                    local button_data = GetButtonData(TalentPanel[player].category_button[i])
                    button_data.category = CLASS_SKILL_CATEGORY[unit_data.unit_class][i]
                    BlzFrameSetTexture(button_data.image, SKILL_CATEGORY_ICON[button_data.category], 0, true)
                    FrameChangeTexture(button_data.frame, SKILL_CATEGORY_ICON[button_data.category])
                    button_data.points_spent = TalentPanel[player].points_spent[i]
                end

                TalentPanel[player].current_category = CLASS_SKILL_CATEGORY[unit_data.unit_class][1]
                TalentPanel[player].tooltip = NewTooltip(TalentPanel[player].points_border_frame, "MyTextTemplateMedium")
                TalentPanel[player].alt_tooltip = NewTooltip(TalentPanel[player].points_border_frame, "MyTextTemplateMedium")
                TalentPanel[player].class = unit_data.unit_class

            end
        end
    end


    ---@param player integer
    function DrawTalentWindow(player)
        TalentPanel[player] = {}
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.05)
            BlzFrameSetSize(main_frame, 0.34, 0.43)

            local new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)

            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.075)

            TalentPanel[player].current_row_amount = 0
            TalentPanel[player].current_col_amount = 0
            TalentPanel[player].button_index = 0
            TalentPanel[player].connector_index = 0

            TalentPanel[player].talent_buttons = {}
            TalentPanel[player].row = {}
            TalentPanel[player].background = new_Frame


            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)



            TalentPanel[player].categories_border = new_Frame

            TalentPanel[player].category_button = {
                [2] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, main_frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.03, main_frame)
            }

            TalentPanel[player].category_button[1] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, TalentPanel[player].category_button[2], FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, -0.016, 0., main_frame)
            TalentPanel[player].category_button[3] = NewButtonSimple("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, TalentPanel[player].category_button[2], FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.016, 0., main_frame)

            TalentPanel[player].last_category_button = TalentPanel[player].category_button[1]

            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, TalentPanel[player].category_button[3], FRAMEPOINT_TOPRIGHT, 0.016, 0.016)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, TalentPanel[player].category_button[1], FRAMEPOINT_BOTTOMLEFT, -0.016, -0.016)

            TalentPanel[player].current_category = 0


            for i = 1, ROWS do
                TalentPanel[player].row[i] = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)
                BlzFrameClearAllPoints(TalentPanel[player].row[i])
                BlzFrameSetPoint(TalentPanel[player].row[i], FRAMEPOINT_CENTER, new_Frame, FRAMEPOINT_CENTER, 0., 0.)
                BlzFrameSetSize(TalentPanel[player].row[i], 0.1, 0.1)
                BlzFrameSetAlpha(TalentPanel[player].row[i], 0)
            end

            TalentPanel[player].connectors = {}
            for i = 1, MAX_BUTTONS * 2 do
                TalentPanel[player].connectors[i] = CreateSprite("", 0.0003, TalentPanel[player].background, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., 0., TalentPanel[player].background)
                BlzFrameSetVisible(TalentPanel[player].connectors[i], false)
            end

            for i = 1, MAX_BUTTONS do
                TalentPanel[player].talent_buttons[i] = NewButton("ReplaceableTextures\\CommandButtons\\BTNPeon.blp", BUTTON_SIZE, BUTTON_SIZE, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.036, -0.036, new_Frame)
                BlzFrameSetVisible(TalentPanel[player].talent_buttons[i], false)
            end

            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPRIGHT, main_frame, FRAMEPOINT_TOPRIGHT, -0.02, -0.02)
            BlzFrameSetSize(new_Frame, 0.07, 0.06)
            TalentPanel[player].points_border_frame = new_Frame

            new_Frame = BlzCreateFrameByType("TEXT", "text", main_frame, "MyTextTemplate", 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_CENTER, TalentPanel[player].points_border_frame, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetText(new_Frame, "1")
            BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_CENTER )
            BlzFrameSetScale(new_Frame, 1.1)


            TalentPanel[player].points_text_frame = new_Frame


            TalentPanel[player].main_frame = main_frame
            BlzFrameSetVisible(main_frame, false)
            TalentPanel[player].state = false
            TalentPanel[player].points = 1
            TalentPanel[player].points_spent = {0,0,0}


    end



    local function GetTalentButton(player, talent_id)
        local panel = TalentPanel[player]

            for i = 1, panel.button_index do
                local button_data = GetButtonData(panel.talent_buttons[i])

                    if button_data.talent then

                        if button_data.talent.talent_id == talent_id then
                            return panel.talent_buttons[i]
                        end

                    end

            end

    end


    local function GetFreeSprite(player)
        TalentPanel[player].connector_index = TalentPanel[player].connector_index + 1
        return TalentPanel[player].connectors[TalentPanel[player].connector_index]
    end


    ---@param button framehandle
    ---@param player integer
    function UpdateButtonDependancy(player, button)
        local current_button = GetButtonData(button)
        local talent = current_button.talent
        local category = GetButtonData(TalentPanel[player].last_category_button)

            if talent and talent.requires then

                if current_button.connections then
                    for i = 1, #current_button.connections do
                        BlzFrameSetVisible(current_button.connections[i], false)
                    end
                else
                    current_button.connections = {}
                    for i = 1, #talent.requires do
                        current_button.connections[i] = GetFreeSprite(player)
                    end
                end

                for k = 1, #talent.requires do
                    local new_connector = current_button.connections[k]
                    local unlock_button = GetButtonData(GetTalentButton(player, talent.requires[k]))
                    local unlock_col = unlock_button.col_number
                    local current_col = current_button.col_number
                    local path
                    local lock = true

                    if GetUnitTalentLevel(PlayerHero[player], talent.requires[k]) > 0 then lock = false
                    else current_button.locked = true end

                    if current_button.cols_amount < unlock_button.cols_amount then
                        current_col = math.floor(unlock_button.cols_amount / 2.) + current_button.col_number
                    elseif current_button.cols_amount > unlock_button.cols_amount then
                        unlock_col = math.floor(current_button.cols_amount / 2.) + unlock_button.col_number
                    end

                    BlzFrameSetVisible(current_button.charges_frame, false)
                    BlzFrameSetVisible(current_button.mask, true)
                    BlzFrameClearAllPoints(new_connector)
                    BlzFrameSetVisible(new_connector, true)
                    --BlzFrameSetParent(new_connector, current_button.frame)
                    BlzFrameSetPoint(new_connector, FRAMEPOINT_CENTER, current_button.frame, FRAMEPOINT_CENTER, 0.,0.)
                    --BlzFrameSetAlpha(new_connector, 125)

                    if unlock_button.row_number == current_button.row_number then
                        if unlock_col > current_col then path = "UI\\talent_connector_180"
                        else path = "UI\\talent_connector_0" end
                    else
                        if unlock_button.cols_amount - current_button.cols_amount == 1 then
                            local current_pos = current_button.col_number + 0.5
                            if unlock_col > current_pos then path = "UI\\talent_connector_112"
                            elseif unlock_col < current_pos then path = "UI\\talent_connector_67"
                            else path = "UI\\talent_connector_90" end
                        elseif unlock_button.cols_amount - current_button.cols_amount == -1 then
                            local current_pos = current_button.col_number + 1.5
                            if unlock_col > current_pos then path = "UI\\talent_connector_112"
                            elseif unlock_col < current_pos then path = "UI\\talent_connector_67"
                            else path = "UI\\talent_connector_90" end
                        else
                            if unlock_col > current_col then path = "UI\\talent_connector_135"
                            elseif unlock_col < current_col then path = "UI\\talent_connector_45"
                            else path = "UI\\talent_connector_90" end
                        end
                    end


                    if lock then BlzFrameSetModel(new_connector, path .. ".mdx", 0) else BlzFrameSetModel(new_connector, path.."_unlocked.mdx", 0) end

                end

                for i = 1, #talent.requires do
                    if GetUnitTalentLevel(PlayerHero[player], talent.requires[i]) > 0 and category.points_spent >= talent.points_required then
                        BlzFrameSetVisible(current_button.mask, false)
                        BlzFrameSetVisible(current_button.charges_frame, true)
                        current_button.locked = nil
                        break
                    end
                end


            elseif category.points_spent >= talent.points_required then
                BlzFrameSetVisible(current_button.charges_frame, true)
                BlzFrameSetVisible(current_button.mask, false)
                current_button.locked = nil
            end

    end

    function UpdateTalentsRequirements(player)
        local panel = TalentPanel[player]

            for i = 1, panel.button_index do
                UpdateButtonDependancy(player, panel.talent_buttons[i])
            end

    end


    local function RefreshTalentConnectors(player, talent_id)
        local panel = TalentPanel[player]
        local current_button
        local talent

        for i = 1, MAX_BUTTONS do
            current_button = GetButtonData(panel.talent_buttons[i])

                if current_button then
                    talent = current_button.talent or nil

                    if talent and talent.requires then
                        for k = 1, #talent.requires do
                            if talent.requires[k] == talent_id then
                                UpdateButtonDependancy(player, panel.talent_buttons[i])
                            end
                        end
                    end
                end

        end

    end

    ---@param talent string
    ---@param button framehandle
    function AssignTalentToButton(talent, button, col_number, row_number, cols_amount, player)
        button = GetButtonData(button)
        talent = GetTalentData(talent)

            if talent then
                BlzFrameSetTexture(button.image, talent.icon, 0, true)
                FrameChangeTexture(button.frame, talent.icon)
                local level = GetUnitTalentLevel(PlayerHero[player], talent.talent_id)

                if level == talent.max_level then
                    BlzFrameSetText(button.charges_text_frame, "|c00FF0000"..level.. "|r")
                else
                    BlzFrameSetText(button.charges_text_frame, level)
                end

                button.talent = talent
                button.col_number = col_number
                button.row_number = row_number
                button.cols_amount = cols_amount
            else
                BlzFrameSetVisible(button.frame, false)
                BlzFrameSetVisible(button.connector, false)
                button.talent = nil
            end

    end


    function ShowTalentCategoryTemplate(player, category)
        local buttons

        TalentPanelClear(player)

        local category_data = ClassTalents[TalentPanel[player].class][category]


            for row = 1, #category_data do
                buttons = TalentPanelAddRow(player, #category_data[row])
                for button = 1, #buttons do
                    AssignTalentToButton(category_data[row][button], buttons[button], button, row, #category_data[row], player)
                end
            end

        UpdateTalentsRequirements(player)
        TalentPanel[player].current_category = category


    end



    function SetTalentPanelState(player, state)

        BlzFrameSetVisible(TalentPanel[player].main_frame, state)

        if GetLocalPlayer() ~= Player(player-1) then
            BlzFrameSetVisible(TalentPanel[player].main_frame, false)
        end

        TalentPanel[player].state = state

        if state then
            ShowTalentCategoryTemplate(player, TalentPanel[player].current_category)
            local button_data = GetButtonData(TalentPanel[player].last_category_button)
            BlzFrameSetVisible(button_data.sprite, true)
        else
            TimerStart(last_EnteredFrameTimer[player], 0., false, nil)
            RemoveTooltip(player)
        end

        return state
    end



    function ResetPlayerTalents(player)
        local unit_data = GetUnitData(PlayerHero[player])
        local total_points = 0
        local category

        for i = 1, 3 do
            category = GetButtonData(TalentPanel[player].category_button[i])
            total_points = total_points + category.points_spent
            category.points_spent = 0
            TalentPanel[player].points_spent[i] = 0
        end


        for i = 1, #unit_data.talent_list do
            local talent = GetTalentData(unit_data.talent_list[i])
            local talent_level = GetUnitTalentLevel(PlayerHero[player], talent.talent_id)
            if talent.instant_effects then
                if talent.instant_effects.cancel_last_level then
                    talent.instant_effects[talent_level](PlayerHero[player], false)
                else
                    for k = talent_level, 1, -1 do
                        if talent.instant_effects[k] then
                            talent.instant_effects[k](PlayerHero[player], false)
                        end
                    end
                end
            end
        end

        unit_data.talents = nil
        unit_data.talent_list = nil
        AddTalentPointsToPlayer(player, total_points)
        UpdateTalentsRequirements(player)

    end


    function AddTalentPointsToPlayer(player, amount)
        TalentPanel[player].points = TalentPanel[player].points + amount
        BlzFrameSetText(TalentPanel[player].points_text_frame, TalentPanel[player].points)
    end


    function InitTalentsWindow()
        TalentPanel = {}
        last_EnteredFrame = {}
        last_EnteredFrameTimer = {}

        for i = 1, 6 do
            last_EnteredFrameTimer[i] = CreateTimer()
        end

        ClickTrigger = CreateTrigger()
        EnterTrigger = CreateTrigger()
        LeaveTrigger = CreateTrigger()


        TriggerAddAction(EnterTrigger, function()
            --print("enter")
            --DisableTrigger(LeaveTrigger)
            local player = GetPlayerId(GetTriggerPlayer()) + 1

            --last_EnteredFrame[player] = true
            --DelayAction(0., function() last_EnteredFrame[player] = false end)

            TimerStart(last_EnteredFrameTimer[player], GLOBAL_TOOLTIP_FADE_TIME, false, function()
                RemoveTooltip(player)
                RemoveSpecificTooltip(TalentPanel[player].alt_tooltip)
                last_EnteredFrame[player] = nil
                --print("remove timed")
            end)

            if last_EnteredFrame[player] == BlzGetTriggerFrame() then
                --print("same frame")
                return
            else
                RemoveTooltip(player)
                RemoveSpecificTooltip(TalentPanel[player].alt_tooltip)
                --print("remove")
            end

            last_EnteredFrame[player] = BlzGetTriggerFrame()

            local button = GetButtonData(BlzGetTriggerFrame())
            local talent = button.talent


                if talent then
                    --print("show")
                    local level = GetUnitTalentLevel(PlayerHero[player], talent.talent_id)
                    ShowTalentTooltip(talent, level, TalentPanel[player].tooltip, button, player)
                    if level < talent.max_level then
                        if level == 0 then
                            ShowTalentTooltip(talent, 2, TalentPanel[player].alt_tooltip, button, player, true)
                        else
                            ShowTalentTooltip(talent, level + 1, TalentPanel[player].alt_tooltip, button, player, true)
                        end
                    end
                end

                --BlzFrameSetEnable(BlzGetTriggerFrame(), false)
        end)

        TriggerAddAction(LeaveTrigger, function()
            --print("leave")
            --local player = GetPlayerId(GetTriggerPlayer()) + 1
            --if last_EnteredFrame[player] then
            --    return
           -- end
            --RemoveTooltip(player)
            --RemoveSpecificTooltip(TalentPanel[player].alt_tooltip)
        end)


        TriggerAddAction(ClickTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local talent = button.talent
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            --print("1")

                if talent then
                    --print("2")
                    local unit_talent_level = GetUnitTalentLevel(PlayerHero[player], talent.talent_id)

                    --print("lvl "..unit_talent_level)

                        if unit_talent_level < talent.max_level and not button.locked and TalentPanel[player].points > 0 then
                            unit_talent_level = AddUnitTalentLevel(PlayerHero[player], talent.talent_id)
                            BlzFrameSetText(button.charges_text_frame, unit_talent_level)
                            if unit_talent_level == talent.max_level then
                                BlzFrameSetText(button.charges_text_frame, "|c00FF0000"..unit_talent_level.. "|r")
                            end
                            PlayLocalSound("Sound\\altarshop_buymagicspell.wav", player-1, 110)

                            local category = GetButtonData(TalentPanel[player].last_category_button)
                            category.points_spent = category.points_spent + 1
                            for i = 1, 3 do
                                local btn = GetButtonData(TalentPanel[player].category_button[i])
                                if btn == category then
                                    TalentPanel[player].points_spent[i] = TalentPanel[player].points_spent[i] + 1
                                    break
                                end
                            end

                            UpdateTalentsRequirements(player)
                            --RefreshTalentConnectors(player, talent.talent_id)
                            AddTalentPointsToPlayer(player, -1)

                            RemoveTooltip(player)
                            RemoveSpecificTooltip(TalentPanel[player].alt_tooltip)

                            if talent.instant_effects and talent.instant_effects[unit_talent_level] then
                                if talent.instant_effects.cancel_last_level and unit_talent_level > 1 then talent.instant_effects[unit_talent_level-1](PlayerHero[player], false) end
                                talent.instant_effects[unit_talent_level](PlayerHero[player], true)
                            end

                            ShowTalentTooltip(talent, unit_talent_level, TalentPanel[player].tooltip, button, player)
                            if unit_talent_level >= 1 and unit_talent_level < talent.max_level then
                                ShowTalentTooltip(talent, unit_talent_level + 1, TalentPanel[player].alt_tooltip, button, player, true)
                            end

                        else
                            PlayLocalSound("Sound\\item_cant_be_equipped.wav", player-1, 110)
                        end

                elseif button.category then
                    local category = GetButtonData(TalentPanel[player].last_category_button)
                    BlzFrameSetVisible(category.sprite, false)
                    --local last_button_data = GetButtonData(TalentPanel[player].category_button[TalentPanel[player].current_category])
                    ShowTalentCategoryTemplate(player, button.category)
                    TalentPanel[player].last_category_button = BlzGetTriggerFrame()
                    BlzFrameSetVisible(button.sprite, true)
                    UpdateTalentsRequirements(player)
                end

        end)

        RegisterTestCommand("tal", function()
            AddTalentPointsToPlayer(1, 10)
        end)


    end

end