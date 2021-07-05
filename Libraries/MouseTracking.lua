---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 05.07.2021 15:00
---
do


    PlayerMousePosition = {}
    local mouse_track_trigger = CreateTrigger()


    function MouseTrackingInit()
        for i = 0, 5 do
            TriggerRegisterPlayerEvent(mouse_track_trigger, Player(i), EVENT_PLAYER_MOUSE_MOVE)
            PlayerMousePosition[i+1] = {}
        end

        TriggerAddAction(mouse_track_trigger, function()
            if BlzGetTriggerPlayerMouseX() ~= 0. then
                local player = GetPlayerId(GetTriggerPlayer()) + 1
                PlayerMousePosition[player].x = BlzGetTriggerPlayerMouseX()
                PlayerMousePosition[player].y = BlzGetTriggerPlayerMouseY()
            end
        end)
    end


end