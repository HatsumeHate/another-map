---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 02.09.2021 17:40
---
do


    local Click_Ability = 0
    local Click_Condition = 0
    local TrackingData = 0
    MARK_TYPE_QUESTION = 1
    MARK_TYPE_EXCLAMATION = 2

    MARK_COMMON = 1
    MARK_SPECIAL = 2
    MARK_DAILY = 3
    MARK_EMERGENCY = 4
    MARK_LOW_COMMON = 5
    MARK_LOW_DAILY = 6
    MARK_UNAVAILABLE = 7
    MARK_TEAMCOLOR = 8
    MARK_ATTENTION = 9

    local MarkList = 0




    function ClickCondition()
        return GetOrderTargetItem() == nil and GetUnitAbilityLevel(GetOrderTargetUnit(), Click_Ability) > 0 and GetIssuedOrderId() == order_smart and IsUnitInRange(GetOrderTargetUnit(), GetTriggerUnit(), 200.)
    end

    ---@param unit unit
    ---@param trig trigger
    function ClickFunctionsRemove(unit, trig)
        UnitRemoveAbility(unit, Click_Ability)
        if trig then DestroyTrigger(trig) end
    end

    function ClickFunctionsAdd(unit)
        UnitAddAbility(unit, Click_Ability)
    end

    ---@param npc unit
    ---@param actions function
    function RegisterClickFeedbackOnNPC(npc, actions)
        local ClickTrig = CreateTrigger()

            TriggerRegisterAnyUnitEventBJ(ClickTrig, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
            TriggerAddCondition(ClickTrig, Click_Condition)
            TriggerAddAction(ClickTrig, function()
                if GetOrderTargetUnit() == npc then
                    actions()
                end
            end)


        return ClickTrig
    end


    ---@param unit unit
    ---@param duration real
    ---@param feedback function
    ---@param rgb table
    function VanishUnit(unit, duration, rgb, feedback)
        local timer = CreateTimer()
        local alpha = 255
        local step = 255 / duration / 40

            TimerStart(timer, 0.025, true, function()
                if alpha <= 0 then
                    SetUnitVertexColor(unit, rgb.r, rgb.g, rgb.b, 0)
                    DestroyTimer(timer)
                    feedback()
                else
                    alpha = alpha - step
                    SetUnitVertexColor(unit, rgb.r, rgb.g, rgb.b, alpha)
                end
            end)

    end


    ---@param count integer
    ---@param item integer
    ---@param where table
    ---@param max_per_spawn integer
    function CreateQuestItems(count, item, where, max_per_spawn)

        while(count > 0) do
            local currentspawn = GetRandomInt(1, max_per_spawn or 1)
            local rect = where[GetRandomInt(1, #where)]

            if count - currentspawn < 0 then currentspawn = currentspawn - count end
            count = count - currentspawn

            for i = 1, currentspawn do CreateItem(item, GetRandomRectX(rect), GetRandomRectY(rect)) end
        end

        where = nil
    end


    ---@param myfunction function
    function PickUpItemReaction(item_id, myfunction)
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        TriggerAddAction(trg, function()
            if GetItemTypeId(GetManipulatedItem()) == FourCC(item_id) then
                myfunction()
            end
        end)
    end


    ---@param myfunction function
    function PickUpAnyItemReaction(myfunction)
        local trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        TriggerAddAction(trg, myfunction)
    end

    ---@param unit unit
    ---@param leash_range real
    function CreateLeashForUnit(unit, leash_range)
        local x = GetUnitX(unit); local y = GetUnitY(unit)
        local returning = false

            DelayAction(0., function()
                local data = GetUnitData(unit)
                data.leash_range = leash_range
                data.leash_x = x
                data.leash_y = y
            end)


            local timer = CreateTimer()
            TimerStart(timer, 3.25, true, function()
                local state = GetUnitState(unit, UNIT_STATE_LIFE) > 0.045

                    if state and not returning and not IsUnitInRangeXY(unit, x, y, leash_range) then
                        UnitAddAbility(unit, FourCC("AAIM"))
                        UnitAddAbility(unit, FourCC("Avul"))
                        UnitAddAbility(unit, FourCC("Abun"))
                        returning = true
                        IssueImmediateOrderById(unit, order_stop)
                        DelayAction(0., function() IssuePointOrderById(unit, order_move, x, y) end)
                    elseif IsUnitInRangeXY(unit, x, y, 35.) and state and returning then
                        SetUnitState(unit, UNIT_STATE_LIFE, GetUnitState(unit, UNIT_STATE_MAX_LIFE))
                        UnitRemoveAbility(unit, FourCC("AAIM"))
                        UnitRemoveAbility(unit, FourCC("Avul"))
                        UnitRemoveAbility(unit, FourCC("Abun"))
                        IssueImmediateOrderById(unit, order_stop)
                        returning = false
                    elseif not state then
                        DestroyTimer(GetExpiredTimer())
                    elseif returning then
                        IssuePointOrderById(unit, order_move, x, y)
                    end

                if not IsAnyHeroInRange(x, y, leash_range) and state then
                    SetUnitState(unit, UNIT_STATE_LIFE, GetUnitState(unit, UNIT_STATE_MAX_LIFE))
                end

            end)

    end



    ---@param unit unit
    ---@return unit
    function GetCurrentUnitQuestTracking(unit)
        if TrackingData[unit] then
            return TrackingData[unit].target or nil
        end
    end


    ---@param unit unit
    ---@return string
    function GetCurrentUnitQuestTrackingId(unit)
        if TrackingData[unit] then
            return TrackingData[unit].id or ""
        end
    end


    ---@param unit unit
    function DisableQuestTracking(unit)
        if TrackingData[unit] then
            DestroyTimer(TrackingData[unit].timer)
            DestroyEffect(TrackingData[unit].arrow)
        end
    end


    local function CreateTrackingData(unit, id)
        local effect_path = ""

        if GetLocalPlayer() == GetOwningPlayer(unit) then effect_path = "Quest\\Target.mdx" end
        TrackingData[unit] = { timer = CreateTimer(), arrow = AddSpecialEffect(effect_path, GetUnitX(unit), GetUnitY(unit)), id = id }

        return TrackingData[unit]
    end


    ---@param unit unit
    ---@param target unit
    ---@param id string
    ---@param bonus_z real
    function EnableUnitPointQuestTracking(unit, point_x, point_y, id, bonus_z)
        local tracking

            DisableQuestTracking(unit)
            tracking = CreateTrackingData(unit, id)

            BlzSetSpecialEffectYaw(tracking.arrow, AngleBetweenUnitXY(unit, point_x, point_y) * bj_DEGTORAD)
            BlzSetSpecialEffectZ(tracking.arrow, GetUnitZ(unit) + (bonus_z or 0.))

            TimerStart(tracking.timer, 0.025, true, function()
                BlzSetSpecialEffectX(tracking.arrow, GetUnitX(unit))
                BlzSetSpecialEffectY(tracking.arrow, GetUnitY(unit))
                BlzSetSpecialEffectZ(tracking.arrow, GetUnitZ(unit) + (bonus_z or 0.))
                BlzSetSpecialEffectYaw(tracking.arrow, AngleBetweenUnitXY(unit, point_x, point_y) * bj_DEGTORAD)
            end)

    end

    ---@param unit unit
    ---@param target unit
    ---@param id string
    ---@param bonus_z real
    function EnableUnitTargetQuestTracking(unit, target, id, bonus_z)
        local tracking

            DisableQuestTracking(unit)
            tracking = CreateTrackingData(unit, id)

            BlzSetSpecialEffectYaw(tracking.arrow, AngleBetweenUnits(unit, target) * bj_DEGTORAD)
            BlzSetSpecialEffectZ(tracking.arrow, GetUnitZ(unit) + (bonus_z or 0.))

            TimerStart(tracking.timer, 0.025, true, function()
                BlzSetSpecialEffectX(tracking.arrow, GetUnitX(unit))
                BlzSetSpecialEffectY(tracking.arrow, GetUnitY(unit))
                BlzSetSpecialEffectZ(tracking.arrow, GetUnitZ(unit) + (bonus_z or 0.))
                BlzSetSpecialEffectYaw(tracking.arrow, AngleBetweenUnits(unit, target) * bj_DEGTORAD)
            end)

    end


    local QuestAreas

    ---@param unit unit
    ---@param quest_area table
    ---@return boolean
    function IsUnitInQuestArea(unit, quest_area)
        return IsUnitInRegion(quest_area.region, unit)
    end

    ---@param pack table
    function RemoveStaticQuestAreaForPlayer(pack)
        RemoveRect(pack.rect)
        RemoveRegion(pack.region)
    end


    ---@param player integer
    ---@param mark_type integer
    ---@param mark_var integer
    ---@param mark_scale real
    ---@param radius real
    ---@param x real
    ---@param y real
    ---@return table
    function AddStaticQuestAreaForPlayer(player, mark_type, mark_var, mark_scale, radius, x, y)
        radius = radius * 0.5
        local rect = Rect(x-radius, y-radius, x+radius, y+radius)
        local region = CreateRegion()
        local mark
        local area_effect = ""
        local area_aura = ""
        local mark_effect = ""
        local scale = radius / 70.

            if GetLocalPlayer() == Player(player-1) then
                area_effect = "Quest\\LootEFFECT.mdx"
                area_aura = "Quest\\QuestMarking.mdx"
                mark_effect = MarkList[mark_type or 1][mark_var or 1]
            end

            area_effect = AddSpecialEffect(area_effect, x, y)
            area_aura = AddSpecialEffect(area_aura, x, y)

            BlzSetSpecialEffectZ(area_aura, GetZ(x,y) + 10.)
            BlzSetSpecialEffectScale(area_aura, 1)
            BlzSetSpecialEffectScale(area_effect, 1)
            BlzSetSpecialEffectScale(area_aura, scale)
            BlzSetSpecialEffectScale(area_effect, scale)
            BlzSetSpecialEffectAlpha(area_aura, 155)

            if mark_type then
                mark = AddSpecialEffect(mark_effect, x, y)
                BlzSetSpecialEffectScale(mark, mark_scale)
            end

            RegionAddRect(region, rect)
            QuestAreas[region] = { region = region, rect = rect }

        return QuestAreas[region]
    end


    ---@param player integer
    ---@param mark_type integer
    ---@param mark_var integer
    ---@param mark_scale real
    ---@param radius real
    ---@param x real
    ---@param y real
    ---@param react_func function
    function AddQuestAreaForPlayer(player, mark_type, mark_var, mark_scale, radius, x, y, react_func)
        local trigger = CreateTrigger()
        radius = radius * 0.5
        local rect = Rect(x-radius, y-radius, x+radius, y+radius)
        local region = CreateRegion()
        local mark
        local area_effect = ""
        local area_aura = ""
        local mark_effect = ""

        local scale = radius / 70.

            if GetLocalPlayer() == Player(player-1) then
                area_effect = "Quest\\LootEFFECT.mdx"
                area_aura = "Quest\\QuestMarking.mdx"
                mark_effect = MarkList[mark_type or 1][mark_var or 1]
            end

            area_effect = AddSpecialEffect(area_effect, x, y)
            area_aura = AddSpecialEffect(area_aura, x, y)

            BlzSetSpecialEffectZ(area_aura, GetZ(x,y) + 10.)
            BlzSetSpecialEffectScale(area_aura, 1)
            BlzSetSpecialEffectScale(area_effect, 1)
            BlzSetSpecialEffectScale(area_aura, scale)
            BlzSetSpecialEffectScale(area_effect, scale)
            BlzSetSpecialEffectAlpha(area_aura, 155)

            if mark_type then
                mark = AddSpecialEffect(mark_effect, x, y)
                BlzSetSpecialEffectScale(mark, mark_scale)
            end

            RegionAddRect(region, rect)
            TriggerRegisterEnterRegion(trigger, region, nil)
            TriggerAddAction(trigger, function()
                if GetTriggerUnit() == PlayerHero[player] then
                    RemoveRegion(region)
                    RemoveRect(rect)
                    DestroyTrigger(trigger)
                    if mark then DestroyEffect(mark) end
                    DestroyEffect(area_aura)
                    DestroyEffect(area_effect)
                    react_func(GetTriggerUnit())
                end
            end)

    end


    ---@param mark_type integer
    ---@param mark_var integer
    ---@param mark_scale real
    ---@param radius real
    ---@param x real
    ---@param y real
    ---@param react_func function
    function AddQuestArea(mark_type, mark_var, mark_scale, radius, x, y, react_func)
        local trigger = CreateTrigger()
        radius = radius * 0.5
        local rect = Rect(x-radius, y-radius, x+radius, y+radius)
        local region = CreateRegion()
        local mark
        local area_effect = AddSpecialEffect("Quest\\LootEFFECT.mdx", x, y)
        local area_aura = AddSpecialEffect("Quest\\QuestMarking.mdx", x, y)
        local scale = radius / 70.

            BlzSetSpecialEffectZ(area_aura, GetZ(x,y) + 5.)
            BlzSetSpecialEffectScale(area_aura, 1)
            BlzSetSpecialEffectScale(area_effect, 1)
            BlzSetSpecialEffectScale(area_aura, scale)
            BlzSetSpecialEffectScale(area_effect, scale)
            BlzSetSpecialEffectAlpha(area_aura, 155)

            if mark_type then
                mark = AddSpecialEffect(MarkList[mark_type or 1][mark_var or 1], x, y)
                BlzSetSpecialEffectScale(mark, mark_scale)
            end

            RegionAddRect(region, rect)
            TriggerRegisterEnterRegion(trigger, region, nil)
            TriggerAddAction(trigger, function()
                if IsAHero(GetTriggerUnit()) then
                    RemoveRegion(region)
                    RemoveRect(rect)
                    DestroyTrigger(trigger)
                    if mark then DestroyEffect(mark) end
                    DestroyEffect(area_aura)
                    DestroyEffect(area_effect)
                    react_func(GetTriggerUnit())
                end
            end)

    end

    ---@param unit unit
    ---@param mark_type number
    ---@param mark_var number
    ---@return effect
    function AddQuestMark(unit, mark_type, mark_var)
        return AddSpecialEffectTarget(MarkList[mark_type or 1][mark_var or 1], unit, "overhead")
    end


    function InitQuestUtils()
        Click_Ability = FourCC("A01W")
        Click_Condition = Condition(ClickCondition)
        TrackingData = {}
        QuestAreas = {}

        MarkList = {
            [MARK_TYPE_QUESTION] = {
                [MARK_COMMON] = "Quest\\Completed_Quest.mdx",
                [MARK_SPECIAL] = "Quest\\Completed_Quest_Special.mdx",
                [MARK_DAILY] = "Quest\\Completed_Quest_Daily.mdx",
                [MARK_EMERGENCY] = "Quest\\Completed_Quest_Emergency.mdx",
                [MARK_LOW_COMMON] = "Quest\\Completed_Quest_Low.mdx",
                [MARK_LOW_DAILY] = "Quest\\Completed_Quest_Low_Daily.mdx",
                [MARK_UNAVAILABLE] = "Quest\\Completed_Quest_NOT.mdx",
                [MARK_TEAMCOLOR] = "Quest\\Completed_Quest_TEAMCOLOR.mdx"
            },
            [MARK_TYPE_EXCLAMATION] = {
                [MARK_COMMON] = "Quest\\ExcMark_Gold_NonrepeatableQuest.mdx",
                [MARK_SPECIAL] = "Quest\\ExcMark_Orange_ClassQuest.mdx",
                [MARK_DAILY] = "Quest\\ExcMark_Blue_RepetableQuest.mdx",
                [MARK_EMERGENCY] = "Quest\\ExcMark_Red_Emergency.mdx",
                [MARK_LOW_COMMON] = "Quest\\ExcMark_Gold_LowNonrepeatableQuest.mdx",
                [MARK_LOW_DAILY] = "Quest\\ExcMark_Blue_LowRepeatableQuest.mdx",
                [MARK_UNAVAILABLE] = "Quest\\ExcMark_Grey_UnavailableQuest.mdx",
                [MARK_TEAMCOLOR] = "Quest\\ExcMark_TeamColor.mdx",
                [MARK_ATTENTION] = "Quest\\ExcMark_Green_FlightPath.mdx",
            }
        }

        InitQuestsData()
        InitOutskirtsQuestsData()


    end

end