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


    local ClickTrigger = CreateTrigger()
    TriggerAddAction(ClickTrigger, function()
        local frame = BlzGetTriggerFrame()
        BlzFrameSetScale(frame, 0.85)
        TimerStart(CreateTimer(), 0.1, false, function()
            BlzFrameSetScale(frame, 1.)
            DestroyTimer(GetExpiredTimer())
            frame = nil
        end)
    end)

    ---@param frame framehandle
    function FrameRegisterClick(frame)
        BlzTriggerRegisterFrameEvent(ClickTrigger, frame, FRAMEEVENT_CONTROL_CLICK)
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




