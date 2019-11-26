do

    local GAME_UI
    local WORLD_FRAME

    MainInventoryWindow = nil
    EquipSlotsFrame = {}
    PlayerInventoryFrame = {}
    ButtonList = {}
    InventorySlots = {}
    INV_SLOT = 0



    local FocusTrigger = CreateTrigger()
    TriggerAddAction(FocusTrigger, function()
        if GetTriggerPlayer() == GetLocalPlayer() then
            BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end
    end)

    ---@param frame framehandle
    function FrameRegisterNoFocus(frame)
        BlzTriggerRegisterFrameEvent(FocusTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
    end



    function ShowInventory()
        BlzFrameSetVisible(PlayerInventoryFrame[1], not BlzFrameIsVisible(PlayerInventoryFrame[1]))

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
        
            ButtonList[GetHandleId(new_Frame)] = { button_type = button_type, button = new_Frame, image = new_FrameImage }
            FrameRegisterNoFocus(new_Frame)

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    local function DrawInventoryFrames(player)
        local new_Frame
        local new_FrameImage
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)


        BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPRIGHT, GAME_UI, FRAMEPOINT_TOPRIGHT, 0., -0.05)
        BlzFrameSetSize(main_frame, 0.4, 0.38)
        --BlzFrameSetParent(main_frame, GAME_UI)
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
        InventorySlots[1] = NewButton(INV_SLOT, "GUI\\inventory_slot.blp", 0.04, 0.04, inv_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.016, inv_Frame)

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
        NewButton(WEAPON_POINT, "GUI\\BTNWeapon_Slot.blp", 0.044, 0.044, slots_Frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.03, 0.03, slots_Frame)
        NewButton(OFFHAND_POINT, "GUI\\BTNWeapon_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.03, 0.03, slots_Frame)

        NewButton(HEAD_POINT, "GUI\\BTNHead_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_TOP, FRAMEPOINT_TOP, 0., -0.015, slots_Frame)
        NewButton(CHEST_POINT, "GUI\\BTNChest_Slot.blp", 0.043, 0.043, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0., 0., slots_Frame)
        NewButton(HANDS_POINT, "GUI\\BTNHands_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, -0.058, 0., slots_Frame)
        NewButton(LEGS_POINT, "GUI\\BTNBoots_Slot.blp", 0.038, 0.038, slots_Frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_BOTTOM, 0., 0.015, slots_Frame)


        new_Frame = NewButton(NECKLACE_POINT, "GUI\\BTNNecklace_Slot.blp", 0.04, 0.04, slots_Frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0.064, 0.012, slots_Frame)

        NewButton(RING_1_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, new_Frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMLEFT, 0.016, 0., slots_Frame)
        NewButton(RING_2_POINT, "GUI\\BTNRing_Slot.blp", 0.038, 0.038, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMRIGHT, -0.016, 0., slots_Frame)



        BlzFrameSetVisible(main_frame, false)

    end




    function InventoryInit()
        GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
        BlzLoadTOCFile("war3mapimported\\BoxedText.toc")


        DrawInventoryFrames(1)


        --[[
        --HeroSelectorButton
        --ScriptDialogButton
         ]]


        --TODO everything else. optimize it


        local inv_button_btn = BlzCreateFrameByType("GLUEBUTTON", "inventory button btn", GAME_UI, "HeroSelectorButton", 0)
        local inv_button_backdrop = BlzCreateFrameByType("BACKDROP", "inventory button backdrop", inv_button_btn, "", 0)
        local inv_button_tooltip = BlzCreateFrame("BoxedText", inv_button_backdrop, 150, 0)


        BlzFrameSetSize(inv_button_btn, 0.04, 0.04)
        BlzFrameSetAbsPoint(inv_button_btn, FRAMEPOINT_LEFT, 0., 0.2)
        BlzFrameSetAllPoints(inv_button_backdrop, inv_button_btn)
        BlzFrameSetTexture(inv_button_backdrop, "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0, true)

        BlzFrameSetTooltip(inv_button_btn, inv_button_tooltip)
        BlzFrameSetPoint(inv_button_tooltip, FRAMEPOINT_TOPLEFT, inv_button_backdrop, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetSize(inv_button_tooltip, 0.11, 0.05)
        BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), "Содержит все ваши вещи и экипировку")--BoxedText has a child showing the text, set that childs Text.
        BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), "Инвентарь")--BoxedText has a child showing the Title-text, set that childs Text.



        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, inv_button_btn, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, function()

            BlzFrameSetVisible(PlayerInventoryFrame[1], not BlzFrameIsVisible(PlayerInventoryFrame[1]))

        end)

        FrameRegisterNoFocus(inv_button_btn)



        local coords = { x = 0.01, y = 0.01 }
        --local manipulated_frame = MainInventoryFrame[1]


        local update = function ()
            BlzFrameSetSize(MainInventoryWindow.InventoryWindow.slots[1].backdrop, coords.x, coords.y)
            --BlzFrameSetSize(MainInventoryWindow.EquipSlotsWindow.backdrop, coords.x, coords.y)
            print(coords.x .. "/" .. coords.y)
        end

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_DOWN_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y - 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_UP_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y + 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_LEFT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x - 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_RIGHT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x + 0.01
            update()
        end)

    end

end






--[[

        new_Frame = BlzCreateFrame('ScriptDialogButton', inv_Frame, 0, 0)
        new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

        BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, inv_Frame, FRAMEPOINT_TOPLEFT, 0.02, -0.016)

        BlzFrameSetSize(new_Frame, 0.04, 0.04)
        BlzFrameSetTexture(new_FrameImage, "GUI\\inventory_slot.blp", 0, true)
        BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        ButtonList[GetHandleId(new_Frame)] = { button_type = INV_SLOT, button = new_Frame, image = new_FrameImage }
        FrameRegisterNoFocus(new_Frame)

        InventorySlots[1] = new_Frame

            new_Frame = BlzCreateFrame('ScriptDialogButton', inv_Frame, 0, 0)
            new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            ButtonList[GetHandleId(new_Frame)] = { button_type = INV_SLOT, button = new_Frame, image = new_FrameImage }
            FrameRegisterNoFocus(new_Frame)

            InventorySlots[i] = new_Frame
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, InventorySlots[i - 1], FRAMEPOINT_TOPRIGHT, 0., 0.)
            BlzFrameSetSize(new_Frame, 0.04, 0.04)
            BlzFrameSetTexture(new_FrameImage, "GUI\\inventory_slot.blp", 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)]]

--[[
               new_Frame = BlzCreateFrame('ScriptDialogButton', inv_Frame, 0, 0)
               new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

               ButtonList[GetHandleId(new_Frame)] = { button_type = INV_SLOT, button = new_Frame, image = new_FrameImage }
               FrameRegisterNoFocus(new_Frame)

               InventorySlots[slot] = new_Frame
               BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOP, InventorySlots[slot - 8], FRAMEPOINT_BOTTOM, 0., 0.)
               BlzFrameSetSize(new_Frame, 0.04, 0.04)
               BlzFrameSetTexture(new_FrameImage, "GUI\\inventory_slot.blp", 0, true)
               BlzFrameSetAllPoints(new_FrameImage, new_Frame)