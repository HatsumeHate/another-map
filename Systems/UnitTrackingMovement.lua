---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 27.05.2022 23:49
---
do

    local PlayerDelayTable


    function InitUnitTracking()
        PlayerDelayTable = {}

        local trigger_down = CreateTrigger()
        local trigger_up = CreateTrigger()

        for i = 0, 5 do
            TriggerRegisterPlayerEvent(trigger_down, Player(i), EVENT_PLAYER_MOUSE_DOWN)
            TriggerRegisterPlayerEvent(trigger_up, Player(i), EVENT_PLAYER_MOUSE_UP)
            PlayerDelayTable[i+1] = CreateTimer()

        end

        TriggerAddAction(trigger_down, function()
            local player = GetPlayerId(GetTriggerPlayer())+1
            local button = BlzGetTriggerPlayerMouseButton()

                if button == MOUSE_BUTTON_TYPE_RIGHT and PlayerHero[player] and GetUnitState(PlayerHero[player], UNIT_STATE_LIFE) > 0.045 and PlayerMousePosition[player].x ~= 0 then
                    TimerStart(PlayerDelayTable[player], 0.25, true, function()
                        local x, y  = GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player])
                        local angle = math.deg(AngleBetweenXY(x, y, PlayerMousePosition[player].x, PlayerMousePosition[player].y))
                        local range = GetMaxAvailableDistance(x, y, angle, DistanceBetweenXY(x, y, PlayerMousePosition[player].x, PlayerMousePosition[player].y))

                            IssuePointOrderById(PlayerHero[player], order_smart, x + Rx(range, angle), y + Ry(range, angle))
                    end)
                end

        end)


        TriggerAddAction(trigger_up, function()
            local player = GetPlayerId(GetTriggerPlayer())+1
            local button = BlzGetTriggerPlayerMouseButton()

                if button == MOUSE_BUTTON_TYPE_RIGHT then
                    TimerStart(PlayerDelayTable[player], 0., false, nil)
                end


        end)


    end

end