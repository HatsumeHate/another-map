do

    GAME_UI = nil
    WORLD_FRAME = nil



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



    local ButtonTextureList = {}

    function FrameChangeTexture(frame, texture)
        ButtonTextureList[GetHandleId(frame)] = texture
    end

    local ClickTrigger = CreateTrigger()
    TriggerAddAction(ClickTrigger, function()
        local frame = BlzGetTriggerFrame()
        local new_Frame_backdrop = BlzCreateFrameByType("BACKDROP", "ABC", frame, "", 0)
        local new_Frame_image = BlzCreateFrameByType("BACKDROP", "ABCD", new_Frame_backdrop, "", 0)

        BlzFrameSetAllPoints(new_Frame_backdrop, frame)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_TOPLEFT, new_Frame_backdrop, FRAMEPOINT_TOPLEFT, 0.003, -0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_TOPRIGHT, new_Frame_backdrop, FRAMEPOINT_TOPRIGHT, -0.003, -0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_BOTTOMLEFT, new_Frame_backdrop, FRAMEPOINT_BOTTOMLEFT, 0.003, 0.003)
        BlzFrameSetPoint(new_Frame_image, FRAMEPOINT_BOTTOMRIGHT, new_Frame_backdrop, FRAMEPOINT_BOTTOMRIGHT, -0.003, 0.003)
        --BlzFrameSetAllPoints(new_Frame_image, new_Frame_backdrop)
        BlzFrameSetTexture(new_Frame_backdrop, "button_backdrop.blp", 0, true)
        BlzFrameSetTexture(new_Frame_image, ButtonTextureList[GetHandleId(frame)], 0, true)


        TimerStart(CreateTimer(), 0.1, false, function()
            BlzDestroyFrame(new_Frame_backdrop)
            DestroyTimer(GetExpiredTimer())
            new_Frame_image = nil
            new_Frame_backdrop = nil
            frame = nil
        end)

    end)

    ---@param frame framehandle
    function FrameRegisterClick(frame, texture)
        BlzTriggerRegisterFrameEvent(ClickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
        ButtonTextureList[GetHandleId(frame)] = texture
    end


    function RegisterConstructor(frame, base_x, base_y)
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


    function BasicFramesInit()
        GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)

        BlzLoadTOCFile("war3mapimported\\BoxedText.toc")
        BlzLoadTOCFile("war3mapImported\\MyTOCfile.toc")


    end

end




