---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 30.08.2021 18:50
---
do

    local BarFrames
    local BarValues
    local BAR_TYPE_BOSS = 3; local BAR_TYPE_ELITE = 2; local BAR_TYPE_COMMON = 1; local BAR_TYPE_COMMON_ADVANCED = 4


    function CreateBossBar()
        --print("????????????1")

        local bar = BlzCreateSimpleFrame("MyBar", GAME_UI, 0)
        local frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "a", bar, "", 0)

        BlzFrameClearAllPoints(frame)
        BlzFrameClearAllPoints(bar)
        BlzFrameSetValue(frame, 100)
        BlzFrameSetValue(bar, 100)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.5)
        BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0.,0.)
        --BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.3)

        --BlzFrameSetPoint(bar, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPRIGHT, -0.08, -0.08)
        --BlzFrameSetPoint(bar, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0.08, 0.08)
        BlzFrameSetTexture(frame, "DiabolicUI_Target_305x15_BorderElite.tga", 0, true)
        BlzFrameSetTexture(bar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
        BlzFrameSetSize(bar, 0.208, 0.009)
        BlzFrameSetScale(bar, 1.6)
        BlzFrameSetSize(frame, 0.35, 0.08)
        BlzFrameSetScale(frame, 1.6)


        TimerStart(CreateTimer(), 1., true, function()
            BlzFrameSetValue(bar, GetRandomInt(0, 100))
        end)
        --RegisterConstructor(frame, 0.1, 0.04)

        --print("????????????2")
        --print(bar)
    end

    function CreateUnitBarSmallest()
        --print("????????????1")

        local bar = BlzCreateSimpleFrame("MyBar", GAME_UI, 0)
        local frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "a", bar, "", 0)

        BlzFrameClearAllPoints(frame)
        BlzFrameClearAllPoints(bar)
        BlzFrameSetValue(frame, 100)
        BlzFrameSetValue(bar, 100)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.2)
        BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0.,0.)
        --BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.3)

        --BlzFrameSetPoint(bar, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPRIGHT, -0.08, -0.08)
        --BlzFrameSetPoint(bar, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0.08, 0.08)
        BlzFrameSetTexture(frame, "DiabolicUI_Target_114x15_Border.tga", 0, true)
        BlzFrameSetTexture(bar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
        BlzFrameSetSize(bar, 0.154, 0.018)
        BlzFrameSetScale(bar, 0.65)
        BlzFrameSetSize(frame, 0.35, 0.08)
        BlzFrameSetScale(frame, 0.65)
        RegisterConstructor(bar, 0.152, 0.018, 0.001)

        TimerStart(CreateTimer(), 1., true, function()
            BlzFrameSetValue(bar, GetRandomInt(0, 100))
        end)
        --RegisterConstructor(frame, 0.1, 0.04)

        --print("????????????2")
        --print(bar)
    end

    function CreateUnitBarMedium()
        --print("????????????1")

        local bar = BlzCreateSimpleFrame("MyBar", GAME_UI, 0)
        local frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "a", bar, "", 0)

        BlzFrameClearAllPoints(frame)
        BlzFrameClearAllPoints(bar)
        BlzFrameSetValue(frame, 100)
        BlzFrameSetValue(bar, 100)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.3)
        BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0.,0.)
        --BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.3)

        --BlzFrameSetPoint(bar, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPRIGHT, -0.08, -0.08)
        --BlzFrameSetPoint(bar, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0.08, 0.08)
        BlzFrameSetTexture(frame, "DiabolicUI_Target_195x13_Border.tga", 0, true)
        BlzFrameSetTexture(bar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
        BlzFrameSetSize(bar, 0.132, 0.009)
        BlzFrameSetScale(bar, 1.2)
        BlzFrameSetSize(frame, 0.35, 0.04)
        BlzFrameSetScale(frame, 1.2)
        RegisterConstructor(bar, 0.132, 0.008, 0.001)

        TimerStart(CreateTimer(), 1., true, function()
            BlzFrameSetValue(bar, GetRandomInt(0, 100))
        end)
        --RegisterConstructor(frame, 0.1, 0.04)

        --print("????????????2")
        --print(bar)
    end

    function CreateUnitBarBiggest()
        --print("????????????1")


        local bar = BlzCreateSimpleFrame("MyBar", GAME_UI, 0)
        local frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "a", bar, "", 0)

        BlzFrameClearAllPoints(frame)
        BlzFrameClearAllPoints(bar)
        BlzFrameSetValue(frame, 100)
        BlzFrameSetValue(bar, 100)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.4)
        BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0.,0.)
        --BlzFrameSetAbsPoint(bar, FRAMEPOINT_CENTER, 0.4, 0.3)

        --BlzFrameSetPoint(bar, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPRIGHT, -0.08, -0.08)
        --BlzFrameSetPoint(bar, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMLEFT, 0.08, 0.08)
        BlzFrameSetTexture(frame, "DiabolicUI_Target_227x15_Border.tga", 0, true)
        BlzFrameSetTexture(bar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
        BlzFrameSetSize(bar, 0.155, 0.011)
        BlzFrameSetScale(bar, 1.3)
        BlzFrameSetSize(frame, 0.35, 0.046)
        BlzFrameSetScale(frame, 1.3)
        RegisterConstructor(bar, 0.154, 0.018, 0.001)

        TimerStart(CreateTimer(), 1., true, function()
            BlzFrameSetValue(bar, GetRandomInt(0, 100))
        end)
        --RegisterConstructor(frame, 0.1, 0.04)

        --print("????????????2")
        --print(bar)
    end

    local function CreateBar(bar_type, player)
        local bar = BlzCreateSimpleFrame("MyBar", GAME_UI, player)
        local frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "a", bar, "", player)

        local bar_table = { bar = bar, frame = frame, text = BlzGetFrameByName("MyBarText", player) }

        BlzFrameClearAllPoints(bar_table.frame)
        BlzFrameClearAllPoints(bar_table.bar)
        BlzFrameSetValue(bar_table.frame, 100)
        BlzFrameSetValue(bar_table.bar, 100)
        BlzFrameSetAbsPoint(bar_table.bar, FRAMEPOINT_CENTER, 0.4, 0.548)
        BlzFrameSetPoint(bar_table.frame, FRAMEPOINT_CENTER, bar, FRAMEPOINT_CENTER, 0.,0.)

        BlzFrameSetTexture(bar_table.frame, BarValues[bar_type].path, 0, true)
        BlzFrameSetTexture(bar_table.bar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
        BlzFrameSetSize(bar_table.bar, BarValues[bar_type].bar_size_x, BarValues[bar_type].bar_size_y)
        BlzFrameSetScale(bar_table.bar, BarValues[bar_type].scale)
        BlzFrameSetSize(bar_table.frame, BarValues[bar_type].frame_size_x, BarValues[bar_type].frame_size_y)
        BlzFrameSetScale(bar_table.frame, BarValues[bar_type].scale)

        BlzFrameSetVisible(bar, false)

        return bar_table
    end



    function ResetPoints(player)
        BlzFrameClearAllPoints(BarFrames[player].elite.bar)
        BlzFrameClearAllPoints(BarFrames[player].common.bar)
        BlzFrameClearAllPoints(BarFrames[player].common_adv.bar)
        BlzFrameSetAbsPoint(BarFrames[player].elite.bar, FRAMEPOINT_CENTER, 0.4, 0.548)
        BlzFrameSetAbsPoint(BarFrames[player].common.bar, FRAMEPOINT_CENTER, 0.4, 0.548)
        BlzFrameSetAbsPoint(BarFrames[player].common_adv.bar, FRAMEPOINT_CENTER, 0.4, 0.548)
    end


    function AttachToBossBar(player)
        BlzFrameClearAllPoints(BarFrames[player].elite.bar)
        BlzFrameClearAllPoints(BarFrames[player].common.bar)
        BlzFrameClearAllPoints(BarFrames[player].common_adv.bar)
        BlzFrameSetPoint(BarFrames[player].elite.bar, FRAMEPOINT_TOP, BarFrames[player].boss.bar, FRAMEPOINT_BOTTOM, 0., -0.022)
        BlzFrameSetPoint(BarFrames[player].common.bar, FRAMEPOINT_TOP, BarFrames[player].boss.bar, FRAMEPOINT_BOTTOM, 0., -0.044)
        BlzFrameSetPoint(BarFrames[player].common_adv.bar, FRAMEPOINT_TOP, BarFrames[player].boss.bar, FRAMEPOINT_BOTTOM, 0., -0.026)
    end


    function CreateBarsForPlayer(player)
        BarFrames[player] = {}

        BarFrames[player].elite = CreateBar(BAR_TYPE_ELITE, player)
        BarFrames[player].common = CreateBar(BAR_TYPE_COMMON, player)
        BarFrames[player].common_adv = CreateBar(BAR_TYPE_COMMON_ADVANCED, player)
        BarFrames[player].boss = CreateBar(BAR_TYPE_BOSS, player)

        BarFrames[player].boss_bar_state = false

        BlzFrameSetVertexColor(BarFrames[player].boss.bar, BlzConvertColor(255, 225, 200, 200))
        BlzFrameSetScale(BarFrames[player].common.text, 2.58)
        BlzFrameSetScale(BarFrames[player].common_adv.text, 2.5)
        BlzFrameSetScale(BarFrames[player].elite.text, 2.73)
        BlzFrameSetScale(BarFrames[player].boss.text, 2.95)

        BarFrames[player].hpbar_value_timer = CreateTimer()

        local proper_bar = BarFrames[player].common
        local last_focus_unit = nil
        local actual_player = Player(player - 1)
        local trigger = CreateTrigger()
        TriggerRegisterPlayerEvent(trigger, actual_player, EVENT_PLAYER_MOUSE_MOVE)
        TriggerAddAction(trigger, function()
            local mouse_focus = BlzGetMouseFocusUnit()

                if mouse_focus ~= nil and GetUnitState(mouse_focus, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(mouse_focus, FourCC("Avul")) == 0 and not IsAHero(mouse_focus) then
                    local unit_data = GetUnitData(mouse_focus)

                    if last_focus_unit ~= mouse_focus and unit_data and unit_data.classification ~= MONSTER_RANK_BOSS then
                        last_focus_unit = mouse_focus

                        BlzFrameSetVisible(BarFrames[player].elite.bar, false)
                        BlzFrameSetVisible(BarFrames[player].common.bar, false)
                        BlzFrameSetVisible(BarFrames[player].common_adv.bar, false)

                        if unit_data.classification == MONSTER_RANK_ADVANCED then proper_bar = BarFrames[player].elite
                        elseif unit_data.traits then proper_bar = BarFrames[player].common_adv
                        else proper_bar = BarFrames[player].common end

                        if GetLocalPlayer() == actual_player then BlzFrameSetVisible(proper_bar.bar, true) end
                        BlzFrameSetValue(proper_bar.bar, math.floor((GetUnitState(mouse_focus, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(mouse_focus) * 100.)) + 0.5)
                        BlzFrameSetText(proper_bar.text, GetUnitName(mouse_focus))

                    end

                else
                    last_focus_unit = nil
                    BlzFrameSetVisible(BarFrames[player].elite.bar, false)
                    BlzFrameSetVisible(BarFrames[player].common.bar, false)
                    BlzFrameSetVisible(BarFrames[player].common_adv.bar, false)
                end

        end)

        TimerStart(BarFrames[player].hpbar_value_timer, 0.1, true, function()
            if last_focus_unit then
                BlzFrameSetValue(proper_bar.bar, math.floor((GetUnitState(last_focus_unit, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(last_focus_unit) * 100.)) + 0.5)
            end
        end)


        local timer = CreateTimer()
        local group = CreateGroup()
        TimerStart(timer, 1., true, function()
            GroupClear(group)
            GroupEnumUnitsInRange(group, GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]), 1500., nil)

            if BlzGroupGetSize(group) > 0 then
                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                    --IsUnitEnemy(BlzGroupUnitAt(group, index), actual_player) and
                    if not BarFrames[player].boss_bar_state then

                        local boss = BlzGroupUnitAt(group, index)
                        local unit_data = GetUnitData(boss)

                            if GetUnitState(boss, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(boss, FourCC("Avul")) == 0 and unit_data and unit_data.classification == MONSTER_RANK_BOSS then
                                BarFrames[player].boss_bar_state = true

                                if GetLocalPlayer() == actual_player then
                                    BlzFrameSetVisible(BarFrames[player].boss.bar, true)
                                end

                                BlzFrameSetValue(BarFrames[player].boss.bar, math.floor((GetUnitState(boss, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(boss) * 100.) + 0.5))
                                BlzFrameSetText(BarFrames[player].boss.text, GetUnitName(boss))
                                AttachToBossBar(player)


                                --PauseTimer(timer)
                                local track_timer = CreateTimer()
                                TimerStart(track_timer, 0.1, true, function()
                                    local health = GetUnitState(boss, UNIT_STATE_LIFE)

                                        if health < 0.045 then
                                            BarFrames[player].boss_bar_state = false
                                            BlzFrameSetValue(BarFrames[player].boss.bar, 0)
                                            TimerStart(track_timer, 5., false, function()
                                                BlzFrameSetVisible(BarFrames[player].boss.bar, false)
                                                ResetPoints(player)
                                                DestroyTimer(track_timer)
                                                --ResumeTimer(timer)
                                            end)
                                        elseif not IsUnitVisible(boss, actual_player) or not IsUnitInRange(boss, PlayerHero[player], 1500.) then
                                            BarFrames[player].boss_bar_state = false
                                            BlzFrameSetValue(BarFrames[player].boss.bar, 0)
                                            BlzFrameSetVisible(BarFrames[player].boss.bar, false)
                                            ResetPoints(player)
                                            DestroyTimer(track_timer)
                                            --ResumeTimer(timer)
                                        else
                                            BlzFrameSetValue(BarFrames[player].boss.bar, R2I(math.floor((health / BlzGetUnitMaxHP(boss) * 100.) + 0.5)))
                                        end

                                end)

                                break
                            end
                    end
                end
            end


        end)

    end


    function CreateUnitBar1()
        CreateUnitBarSmallest()
        CreateUnitBarMedium()
        CreateUnitBarBiggest()
        CreateBossBar()
    end


    function InitUIBars()

        BarFrames = {}
        BarValues = {
            [BAR_TYPE_BOSS] = { frame_size_x = 0.35, frame_size_y = 0.08, bar_size_x = 0.208, bar_size_y = 0.009, scale = 1.6, path = "DiabolicUI_Target_305x15_BorderElite.tga" },
            [BAR_TYPE_ELITE] = { frame_size_x = 0.35, frame_size_y = 0.046, bar_size_x = 0.155, bar_size_y = 0.011, scale = 1.3, path = "DiabolicUI_Target_227x15_Border.tga" },
            [BAR_TYPE_COMMON] = { frame_size_x = 0.35, frame_size_y = 0.08, bar_size_x = 0.154, bar_size_y = 0.018, scale = 0.65, path = "DiabolicUI_Target_114x15_Border.tga" },
            [BAR_TYPE_COMMON_ADVANCED] = { frame_size_x = 0.35, frame_size_y = 0.04, bar_size_x = 0.132, bar_size_y = 0.009, scale = 1.2, path = "DiabolicUI_Target_195x13_Border.tga" }
        }

    end

end