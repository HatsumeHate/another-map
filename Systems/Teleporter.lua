---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 11.02.2020 16:14
---
do

    TeleportFrame = 0
    TeleportLocation = 0
    local PlayerCurrentButtonList = 0
    local TeleportTrigger


    local function TeleportButtonPressed()
        local frame = BlzGetTriggerFrame()
        local player = GetPlayerId(GetTriggerPlayer()) + 1

            PlayLocalSound("Sound\\location_change.wav", player - 1, 110)
            BlzFrameSetVisible(TeleportFrame[player].mainframe, false)

            for i = 1, #TeleportLocation do
                if PlayerCurrentButtonList[player].buttonlist[i].button == frame then
                    local x, y = GetRectCenterX(PlayerCurrentButtonList[player].buttonlist[i].teleport), GetRectCenterY(PlayerCurrentButtonList[player].buttonlist[i].teleport)
                    SetUnitX(PlayerHero[player], x)
                    SetUnitY(PlayerHero[player], y)
                    IssueImmediateOrderById(PlayerHero[player], order_stop)

                    local minions = GetAllUnitSummonUnits(PlayerHero[player])

                    ForGroup(minions, function()
                        local angle = GetRandomReal(0., 360.)
                        local distance = GetMaxAvailableDistance(x, y, angle, GetRandomReal(150., 450.))
                        SetUnitX(GetEnumUnit(), x + Rx(distance, angle))
                        SetUnitY(GetEnumUnit(), y + Ry(distance, angle))
                    end)

                    DestroyGroup(minions)
                    OnTeleportPadUsed(player)

                    break
                end
            end
    end


    function ShowTeleportList(trackable, player)
        BlzFrameSetVisible(TeleportFrame[player].mainframe, GetLocalPlayer() == Player(player-1))
        local slot = 1

            for i = 1, #TeleportLocation do
                if TeleportLocation[i].trackable ~= trackable then
                    BlzFrameClearAllPoints(TeleportFrame[player].slots[slot].button)
                    BlzFrameSetVisible(TeleportFrame[player].slots[slot].button, true)
                    BlzFrameSetText(TeleportFrame[player].slots[slot].text, TeleportLocation[i].name)

                        if slot == 1 then
                            BlzFrameSetPoint(TeleportFrame[player].slots[slot].button, FRAMEPOINT_TOP, TeleportFrame[player].mainframe, FRAMEPOINT_TOP, 0., -0.01)
                        else
                            BlzFrameSetPoint(TeleportFrame[player].slots[slot].button, FRAMEPOINT_TOP, TeleportFrame[player].slots[slot-1].button, FRAMEPOINT_BOTTOM, 0., -0.001)
                        end

                PlayerCurrentButtonList[player].buttonlist[slot].button = TeleportFrame[player].slots[slot].button
                PlayerCurrentButtonList[player].buttonlist[slot].teleport = TeleportLocation[i].rect
                slot = slot + 1
                end
            end

        BlzFrameSetSize(TeleportFrame[player].mainframe, BlzFrameGetWidth(TeleportFrame[player].mainframe), (BlzFrameGetHeight(TeleportFrame[player].slots[slot].button) * (slot - 1)) + 0.02)
    end



    function ReloadTeleportFrames()
        for i = 1, 6 do
            TeleportFrame[i].mainframe =  BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            BlzFrameSetPoint(TeleportFrame[i].mainframe, FRAMEPOINT_CENTER, GAME_UI, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetSize(TeleportFrame[i].mainframe, 0.12, 0.2)

                for k = 1, 6 do
                    TeleportFrame[i].slots[k].button = BlzCreateFrame('ScriptDialogButton', TeleportFrame[i].mainframe, 0, 0)
                    TeleportFrame[i].slots[k].text = BlzGetFrameByName("ScriptDialogButtonText", 0)
                    BlzFrameSetSize(TeleportFrame[i].slots[k].button, BlzFrameGetWidth(TeleportFrame[i].mainframe) * 0.8, 0.025)
                    BlzFrameSetTextAlignment(TeleportFrame[i].slots[k].text, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)
                    BlzFrameSetVisible(TeleportFrame[i].slots[k].button, false)
                    BlzTriggerRegisterFrameEvent(TeleportTrigger, TeleportFrame[i].slots[k].button, FRAMEEVENT_CONTROL_CLICK)

                end

            BlzFrameSetVisible(TeleportFrame[i].mainframe, false)
        end
        BlzSetSpecialEffectZ(TeleportLocation[2].sfx, GetZ(GetRectCenterX(TeleportLocation[2].rect), GetRectCenterY(TeleportLocation[2].rect)) - 55.)
    end


    local function CreateTeleportFrame()

        for i = 1, 6 do
            TeleportFrame[i] = {}
            TeleportFrame[i].mainframe =  BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            BlzFrameSetPoint(TeleportFrame[i].mainframe, FRAMEPOINT_CENTER, GAME_UI, FRAMEPOINT_CENTER, 0., 0.)
            BlzFrameSetSize(TeleportFrame[i].mainframe, 0.12, 0.2)

            TeleportFrame[i].slots = {}

                for k = 1, 6 do
                    TeleportFrame[i].slots[k] = {}
                    TeleportFrame[i].slots[k].button = BlzCreateFrame('ScriptDialogButton', TeleportFrame[i].mainframe, 0, 0)
                    TeleportFrame[i].slots[k].text = BlzGetFrameByName("ScriptDialogButtonText", 0)
                    BlzFrameSetSize(TeleportFrame[i].slots[k].button, BlzFrameGetWidth(TeleportFrame[i].mainframe) * 0.8, 0.025)
                    BlzFrameSetTextAlignment(TeleportFrame[i].slots[k].text, TEXT_JUSTIFY_CENTER , TEXT_JUSTIFY_MIDDLE)
                    BlzFrameSetVisible(TeleportFrame[i].slots[k].button, false)
                    BlzTriggerRegisterFrameEvent(TeleportTrigger, TeleportFrame[i].slots[k].button, FRAMEEVENT_CONTROL_CLICK)

                end

            BlzFrameSetVisible(TeleportFrame[i].mainframe, false)
        end

    end


    local HitTrigger = 0

    function RegisterUnitForTeleport(unit)
        TriggerRegisterUnitEvent(HitTrigger, unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
    end


    function HitCond()
        return GetOrderTargetUnit() ~= nil and GetUnitTypeId(GetOrderTargetUnit()) == FourCC("ntel") and GetIssuedOrderId() == order_smart and IsUnitInRange(GetOrderTargetUnit(), GetTriggerUnit(), 200.)
    end

    function TeleporterInit()

        InitLocations()

        TeleportFrame = {}
        --TeleportLocation = {}
        PlayerCurrentButtonList = {}

        for i = 1, 6 do PlayerCurrentButtonList[i] = {} end

        TeleportTrigger = CreateTrigger()
        HitTrigger = CreateTrigger()
        TriggerAddAction(TeleportTrigger, TeleportButtonPressed)

        TeleportLocation = {
            [1] = {
                name = LOCALE_LIST[my_locale].CASTLE_LOCATION,
                rect = gg_rct_castle_loc,
            },
            [2] = {
                name = LOCALE_LIST[my_locale].SHORE_LOCATION,
                rect = gg_rct_shore_loc,
            },
            [3] = {
                name = LOCALE_LIST[my_locale].WOODS_LOCATION,
                rect = gg_rct_woods_loc,
            },
            [4] = {
                name = LOCALE_LIST[my_locale].RUINS_LOCATION,
                rect = gg_rct_ruins_loc,
            },
            [5] = {
                name = GetLocalString("Задворки", "Outskirts"),
                rect = gg_rct_outskirts_loc,
            },
        }

        for i = 1, #TeleportLocation do
            local x, y = GetRectCenterX(TeleportLocation[i].rect), GetRectCenterY(TeleportLocation[i].rect)
            TeleportLocation[i].trackable = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("ntel"), x, y, 270.)
            TeleportLocation[i].effect = AddSpecialEffect("war3mapImported\\Glow.mdx", x, y)
            BlzSetSpecialEffectScale(TeleportLocation[i].effect, 3.)
            SetUnitPathing(TeleportLocation[i].trackable, false)
            SetUnitX(TeleportLocation[i].trackable, x)
            SetUnitY(TeleportLocation[i].trackable, y)
            TeleportLocation[i].sfx = AddSpecialEffect("Other\\MagicPlatform.mdx", x, y)
            if i == 2 then BlzSetSpecialEffectZ(TeleportLocation[i].sfx, GetZ(x, y) - 55.) end
        end


        TriggerAddCondition(HitTrigger, Condition(HitCond))
        TriggerAddAction(HitTrigger, function()
            local trackable = GetOrderTargetUnit()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local id = 0

                for i = 1, #TeleportLocation do if trackable == TeleportLocation[i].trackable then id = i; break end end

                ShowTeleportList(trackable, player)
                local timer = CreateTimer()
                TimerStart(timer, 0.3, true, function()
                    if not IsUnitInRange(PlayerHero[player], TeleportLocation[id].trackable, 200.) then
                        BlzFrameSetVisible(TeleportFrame[player].mainframe, false)
                        DestroyTimer(GetExpiredTimer())
                    end
                end)

        end)


            for i = 1, 6 do
                PlayerCurrentButtonList[i] = {}
                PlayerCurrentButtonList[i].buttonlist = {}
                for k = 1, 10 do
                    PlayerCurrentButtonList[i].buttonlist[k] = {}
                end
            end

        CreateTeleportFrame()

    end


end