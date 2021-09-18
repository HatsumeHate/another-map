do

    GAME_UI = 0
    WORLD_FRAME = 0
    MASTER_FRAME = 0
    ButtonList = 0

    local FocusTrigger = 0
    local ButtonClickList = 0
    local ClickTrigger = 0


    ---@param frame framehandle
    function FrameRegisterNoFocus(frame)
        BlzTriggerRegisterFrameEvent(FocusTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
    end


    function CreateMasterFrame()
        MASTER_FRAME = BlzCreateFrameByType("BACKDROP", "ABC", GAME_UI, "", 0)
        BlzFrameSetAbsPoint(MASTER_FRAME, FRAMEPOINT_CENTER, 0.4, 0.3)
    end



    function FrameChangeTexture(frame, texture)
        --ButtonTextureList[GetHandleId(frame)] = texture
        BlzFrameSetTexture(ButtonClickList[frame].image, texture, 0, true)
    end



    ---@param frame framehandle
    function FrameRegisterClick(frame, texture)
        local new_Frame_backdrop = BlzCreateFrameByType("BACKDROP", "ABC", frame, "", 0)
        local new_Frame_image = BlzCreateFrameByType("BACKDROP", "ABCD", new_Frame_backdrop, "", 0)
        BlzFrameSetAllPoints(new_Frame_backdrop, frame)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_TOPLEFT, new_Frame_backdrop, FRAMEPOINT_TOPLEFT, 0.003, -0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_TOPRIGHT, new_Frame_backdrop, FRAMEPOINT_TOPRIGHT, -0.003, -0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_BOTTOMLEFT, new_Frame_backdrop, FRAMEPOINT_BOTTOMLEFT, 0.003, 0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_BOTTOMRIGHT, new_Frame_backdrop, FRAMEPOINT_BOTTOMRIGHT, -0.003, 0.003)
        --BlzFrameSetAllPoints(new_Frame_image, new_Frame_backdrop)
        BlzFrameSetTexture(new_Frame_backdrop, "button_backdrop.blp", 0, true)
        BlzFrameSetTexture(new_Frame_image, texture, 0, true)
        ButtonClickList[frame] = {
            frame = new_Frame_backdrop,
            image = new_Frame_image,
            timer = CreateTimer()
        }
        BlzFrameSetVisible(new_Frame_backdrop, false)
        BlzTriggerRegisterFrameEvent(ClickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
    end


    function RegisterConstructor(frame, base_x, base_y, step)
        local trg

        local coords = { x = base_x, y = base_y }
        --local manipulated_frame = MainInventoryFrame[1]


        local update = function()
            BlzFrameSetSize(frame, coords.x, coords.y)
            print(coords.x .. "/" .. coords.y)
        end

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_DOWN_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y - (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_UP_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y + (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_LEFT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x - (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_RIGHT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x + (step or 0.01)
            update()
        end)

    end

    function RegisterDecorator(frame, framepoint, base_x, base_y, step)
        local trg

        local coords = { x = base_x, y = base_y }
        --local manipulated_frame = MainInventoryFrame[1]

        local update = function()
            BlzFrameClearAllPoints(frame)
            BlzFrameSetAbsPoint(frame, framepoint, coords.x, coords.y)
            --BlzFrameSetSize(frame, coords.x, coords.y)
            print(coords.x .. "/" .. coords.y)
        end

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_K, 0, true)
        TriggerAddAction(trg, function()
            coords.y = coords.y - (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_I, 0, true)
        TriggerAddAction(trg, function()
            coords.y = coords.y + (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_J, 0, true)
        TriggerAddAction(trg, function()
            coords.x = coords.x - (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_L, 0, true)
        TriggerAddAction(trg, function()
            coords.x = coords.x + (step or 0.01)
            update()
        end)

    end

    function RegisterScaler(frame, base_scale, step)
        local trg

        local update = function()
            BlzFrameSetScale(frame, base_scale)
            print(base_scale)
        end

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_PAGEDOWN, 0, true)
        --TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_DOWN_DOWN)
        TriggerAddAction(trg, function()
            base_scale = base_scale - (step or 0.01)
            update()
        end)

        trg = CreateTrigger()
        BlzTriggerRegisterPlayerKeyEvent(trg, Player(0), OSKEY_PAGEUP, 0, true)
        --TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_UP_DOWN)
        TriggerAddAction(trg, function()
            base_scale = base_scale + (step or 0.01)
            update()
        end)

    end


    function BasicFramesInit()
        ButtonList = {}
        ButtonClickList = {}
        GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)

        FocusTrigger = CreateTrigger()
        TriggerAddAction(FocusTrigger, function()
            if GetTriggerPlayer() == GetLocalPlayer() then
                BlzFrameSetEnable(BlzGetTriggerFrame(), false)
                BlzFrameSetEnable(BlzGetTriggerFrame(), true)
            end
        end)

        ClickTrigger = CreateTrigger()
        TriggerAddAction(ClickTrigger, function()
            local frame = BlzGetTriggerFrame()
            local player = GetTriggerPlayer()

                if ButtonClickList[frame] then
                    if GetLocalPlayer() == player then BlzFrameSetVisible(ButtonClickList[frame].frame, true) end
                    TimerStart(ButtonClickList[frame].timer, 0.1, false, function()
                        BlzFrameSetVisible(ButtonClickList[frame].frame, false)
                    end)
                end

        end)

        BlzLoadTOCFile("war3mapimported\\BoxedText.toc")
        if not BlzLoadTOCFile("war3mapImported\\MyTOCfile.toc") then print("MyTOCfile.toc not loaded") end
        --if not BlzLoadTOCFile("war3mapImported\\testtoc.toc") then print("testtoc.toc not loaded") end

        InitContextMenu()
        InitSlider()
    end

end




