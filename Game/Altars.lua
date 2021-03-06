---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 13.05.2021 2:55
---
do

    local ChestRects
    local AltarRects
    local AltarsList = {}
    ALTAR_TYPE_WELL_HP = 1
    ALTAR_TYPE_WELL_MP = 2
    ALTAR_TYPE_OBELISK = 3
    ALTAR_TYPE_CHEST = 4
    ALTAR_TYPE_HATRED = 5
    local ChestMax = 15
    local ChestGroup
    local FirstTime_Data




    local AltarEffects



    function GetAltarData(unit)
        return AltarsList[GetHandleId(unit)]
    end


    local function CreateObeliskText(text, rect)
        local tag = CreateTextTag()
            SetTextTagText(tag, text, (8.5 * 0.023) / 10)
            SetTextTagPos(tag, GetRectCenterX(rect), GetRectCenterY(rect), 70.)
            SetTextTagColor(tag, 255, 75, 75, 0)
        return tag
    end

    function GenerateAltarEffect(altar)
        AltarsList[GetHandleId(altar)].obelisk_effect = AltarEffects.obelisk[GetRandomInt(1, #AltarEffects.obelisk)]
    end



    function CreateChest(rect)
        local altar = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("n00N"), GetRectCenterX(rect), GetRectCenterY(rect), GetRandomReal(230., 310.))

            AltarsList[GetHandleId(altar)] = {
                rect = rect,
                altar_type = ALTAR_TYPE_CHEST,
                obelisk_effect = AltarEffects.chest_open
            }

        GroupAddUnit(ChestGroup, altar)

            for i = 1, 6 do
                if FirstTime_Data[i].first_time then
                    TriggerRegisterUnitInRange(FirstTime_Data[i].proximity_trigger, altar, 550., nil)
                end
            end

    end


    ---@param well_type number
    ---@param rect rect
    function CreateWell(well_type, rect)
        local altar = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), well_type == ALTAR_TYPE_WELL_HP and FourCC("n014") or FourCC("n00L"), GetRectCenterX(rect), GetRectCenterY(rect), 270.)

            AltarsList[GetHandleId(altar)] = {
                rect = rect,
                altar_type = well_type,
                obelisk_effect = well_type == ALTAR_TYPE_WELL_HP and AltarEffects.well_hp or AltarEffects.well_mp
            }

        SetUnitAnimation(altar, "stand")

            for i = 1, 6 do
                if FirstTime_Data[i].first_time then
                    TriggerRegisterUnitInRange(FirstTime_Data[i].proximity_trigger, altar, 550., nil)
                end
            end

    end

    ---@param rect rect
    function CreateObelisk(rect)
        local id = GetRandomInt(1, 2) == 1 and "n00M" or "n00K"
        local altar = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC(id), GetRectCenterX(rect), GetRectCenterY(rect), 270.)
        local handle = GetHandleId(altar)
        --local effect_id = GetRandomInt(1, #AltarEffects.obelisk)

            local trg = CreateTrigger()

            AltarsList[handle] = { rect = rect, altar_type = ALTAR_TYPE_OBELISK, in_range_trigger = trg }
            GenerateAltarEffect(altar)

            TriggerRegisterUnitInRange(trg, altar, 1000., nil)
            TriggerAddAction(trg, function()
                if IsAHero(GetTriggerUnit()) and not AltarsList[handle].texttag then
                    AltarsList[handle].texttag = CreateObeliskText(AltarsList[handle].obelisk_effect.name, rect)
                    TimerStart(CreateTimer(), 5., true, function()
                        local count = 0

                        for i = 1, 6 do
                            if PlayerHero[i] and IsUnitInRange(PlayerHero[i], altar, 1000.) then
                                count = count + 1
                            end
                        end

                        if count == 0 then
                            DestroyTextTag(AltarsList[handle].texttag)
                            AltarsList[handle].texttag = nil
                        end

                    end)
                end
            end)

            for i = 1, 6 do
                if FirstTime_Data[i].first_time then
                    TriggerRegisterUnitInRange(FirstTime_Data[i].proximity_trigger, altar, 550., nil)
                end
            end

    end


    function CreateShrineOfHatred(rect)
        local altar = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("n01B"), GetRectCenterX(rect), GetRectCenterY(rect), 270.)
        local handle = GetHandleId(altar)

            AltarsList[handle] = { rect = rect, altar_type = ALTAR_TYPE_HATRED, obelisk_effect = AltarEffects.shrine_of_hatred }

    end


    function InitAltars()

        AltarEffects = {
            obelisk = {
                [1] = {
                    name = "Fury Blessing",
                    recharge_time = 120.,
                    effect = function(target)
                        ApplyBuff(target, target, "A01G", 1)
                        AddSoundVolume("Sounds\\Altar\\exploding.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                    end
                },
                [2] = {
                    name = "Power Blessing",
                    recharge_time = 120.,
                    effect = function(target)
                        ApplyBuff(target, target, "A01L", 1)
                        AddSoundVolume("Sounds\\Altar\\combatboost.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                    end
                },
                [3] = {
                    name = "Elemental Blessing",
                    recharge_time = 120.,
                    effect = function(target)
                        ApplyBuff(target, target, "A01K", 1)
                        AddSoundVolume("Sounds\\Altar\\shrineofenirhs.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                    end
                },
                [4] = {
                    name = "Enduring Blessing",
                    recharge_time = 120.,
                    effect = function(target)
                        ApplyBuff(target, target, "A01J", 1)
                        AddSoundVolume("Sounds\\Altar\\warping.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                    end
                }
            },
            well_hp = {
                recharge_time = 120.,
                effect = function(target)
                    local effect = AddSpecialEffectTarget("Abilities\\Spells\\Human\\Heal\\HealTarget.mdx", target, "origin")
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_MAX_LIFE))
                    AddSoundVolume("Sounds\\Altar\\refill.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                    DelayAction(1.833, function()
                        DestroyEffect(effect)
                    end)
                end
            },
            well_mp = {
                recharge_time = 120.,
                effect = function(target)
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIma\\AImaTarget.mdx", target, "origin"))
                    SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MAX_MANA))
                    AddSoundVolume("Sounds\\Altar\\recharge.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                end
            },
            chest_open = {
                recharge_time = 30.,
                effect = function(target)
                    for i = 1, 6 do
                        DropForPlayer(target, i-1)
                    end
                    AddSoundVolume("Sounds\\Altar\\chestbig.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                end
            },
            shrine_of_hatred = {
                --recharge_time = 10.,
                effect = function(altar, source)
                    local player = GetPlayerId(GetOwningPlayer(source)) + 1
                    local item = GetItemFromInventory(player, FourCC("I01O"))

                        if item then
                            local charges = GetItemCharges(item)
                            if charges >= 5 then
                                RemoveChargesFromInventoryItem(player, item, 5)
                                SetUnitAnimation(altar, "Spell First")
                                DelayAction(2., function()
                                    AddUnitAnimationProperties(altar, "Work", true)
                                    DelayAction(5., function()
                                        Current_Wave = Current_Wave + 5
                                        AddUnitAnimationProperties(altar, "Work", false)
                                        ScaleMonsterPacks()
                                        UnitAddAbility(altar, FourCC("A01H"))
                                        MultiboardSetItemValue(MultiboardGetItem(MAIN_MULTIBOARD, 0, 0),  LOCALE_LIST[my_locale].WAVE_LEVEL .. I2S(Current_Wave))
                                    end)
                                    --SetUnitAnimation(altar, "Stand Work")
                                end)
                            else
                                Feedback_CantUse(player)
                                UnitAddAbility(altar, FourCC("A01H"))
                            end
                        else
                            Feedback_CantUse(player)
                            UnitAddAbility(altar, FourCC("A01H"))
                        end
                    --AddSoundVolume("Sounds\\Altar\\chestbig.wav", GetUnitX(target), GetUnitY(target), 128, 2100.)
                end
            }
        }

        FirstTime_Data = {
            [1] = { first_time = true, proximity_trigger = CreateTrigger() },
            [2] = { first_time = true, proximity_trigger = CreateTrigger() },
            [3] = { first_time = true, proximity_trigger = CreateTrigger() },
            [4] = { first_time = true, proximity_trigger = CreateTrigger() },
            [5] = { first_time = true, proximity_trigger = CreateTrigger() },
            [6] = { first_time = true, proximity_trigger = CreateTrigger() }
        }

        local hint_action = function()
            local player = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            if IsAHero(GetTriggerUnit()) and FirstTime_Data[player+1].first_time then
                DestroyTrigger(GetTriggeringTrigger())
                ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_ALTARS, player)
                FirstTime_Data[player+1].first_time = false
            end
        end

        for i = 1, 6 do
            TriggerAddAction(FirstTime_Data[i].proximity_trigger, hint_action)
        end
        
        

        local trg = CreateTrigger()
        TriggerRegisterPlayerUnitEvent(trg, Player(0), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(trg, Player(1), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(trg, Player(2), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(trg, Player(3), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(trg, Player(4), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(trg, Player(5), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerAddAction(trg, function()

            if GetUnitAbilityLevel(GetOrderTargetUnit(), FourCC("A01H")) <= 0 then return end
            local hero = GetTriggerUnit()

                if IsAHero(hero) and IsUnitInRange(hero, GetOrderTargetUnit(), 225.) then
                    local altar_unit = GetOrderTargetUnit()
                    local altar = GetAltarData(altar_unit)



                    UnitRemoveAbility(altar_unit, FourCC("A01H"))
                    --AltarEffects.obelisk[1](hero)
                    if altar.altar_type == ALTAR_TYPE_CHEST then
                        altar.obelisk_effect.effect(altar_unit)
                    elseif altar.altar_type == ALTAR_TYPE_HATRED then
                        altar.obelisk_effect.effect(altar_unit, hero)
                    else
                        altar.obelisk_effect.effect(hero)
                    end


                    if altar.altar_type == ALTAR_TYPE_OBELISK then
                        DestroyTextTag(altar.texttag)
                        if GetUnitTypeId(altar_unit) == FourCC("n00K") then AddUnitAnimationProperties(altar_unit, "alternate", false) end
                    elseif altar.altar_type == ALTAR_TYPE_WELL_HP or altar.altar_type == ALTAR_TYPE_WELL_MP then
                        SetUnitState(altar_unit, UNIT_STATE_MANA, 0.)
                        AddUnitAnimationProperties(altar_unit, "First", false)
                        AddUnitAnimationProperties(altar_unit, "Third", true)
                    elseif altar.altar_type == ALTAR_TYPE_CHEST then
                        AddUnitAnimationProperties(altar_unit, "alternate", true)
                        SetUnitAnimation(altar_unit, "birth alternate")
                        UnitAddAbility(altar_unit, FourCC("Aloc"))
                    end


                    if altar.obelisk_effect.recharge_time then
                        TimerStart(CreateTimer(), altar.obelisk_effect.recharge_time, false, function()

                            UnitAddAbility(altar_unit, FourCC("A01H"))

                            if altar.altar_type == ALTAR_TYPE_OBELISK then
                                GenerateAltarEffect(altar_unit)
                                if GetUnitTypeId(altar_unit) == FourCC("n00K") then AddUnitAnimationProperties(altar_unit, "alternate", true) end
                            elseif altar.altar_type == ALTAR_TYPE_WELL_HP or altar.altar_type == ALTAR_TYPE_WELL_MP then
                                SetUnitState(altar_unit, UNIT_STATE_MANA, GetUnitState(altar_unit, UNIT_STATE_MAX_MANA))
                                AddUnitAnimationProperties(altar_unit, "First", true)
                                AddUnitAnimationProperties(altar_unit, "Third", false)
                            elseif altar.altar_type == ALTAR_TYPE_CHEST then
                                GroupRemoveUnit(ChestGroup, altar_unit)
                                RemoveUnit(altar_unit)
                                AltarsList[GetHandleId(altar_unit)] = nil
                            end

                            DestroyTimer(GetExpiredTimer())
                            altar_unit = nil
                        end)
                    end


                    --altar = nil

                end

            hero = nil
        end)


        RegisterTestCommand("aaa", function()
            CreateChest(gg_rct_test_a_1)
        end)


        ChestRects = {
            [1]	 = gg_rct_chest_1,
            [2]	 = gg_rct_chest_2,
            [3]	 = gg_rct_chest_3,
            [4]	 = gg_rct_chest_4,
            [5]	 = gg_rct_chest_5,
            [6]	 = gg_rct_chest_6,
            [7]	 = gg_rct_chest_7,
            [8]	 = gg_rct_chest_8,
            [9]	 = gg_rct_chest_9,
            [10]	 = gg_rct_chest_10,
            [11]	 = gg_rct_chest_11,
            [12]	 = gg_rct_chest_12,
            [13]	 = gg_rct_chest_13,
            [14]	 = gg_rct_chest_14,
            [15]	 = gg_rct_chest_15,
            [16]	 = gg_rct_chest_16,
            [17]	 = gg_rct_chest_17,
            [18]	 = gg_rct_chest_18,
            [19]	 = gg_rct_chest_19,
            [20]	 = gg_rct_chest_20,
            [21]	 = gg_rct_chest_21,
            [22]	 = gg_rct_chest_22,
            [23]	 = gg_rct_chest_23,
            [24]	 = gg_rct_chest_24,
            [25]	 = gg_rct_chest_25,
            [26]	 = gg_rct_chest_26,
            [27]	 = gg_rct_chest_27,
            [28]	 = gg_rct_chest_28,
            [29]	 = gg_rct_chest_29,
            [30]	 = gg_rct_chest_30,
            [31]	 = gg_rct_chest_31,
            [32]	 = gg_rct_chest_32,
            [33]	 = gg_rct_chest_33,
            [34]	 = gg_rct_chest_34,
            [35]	 = gg_rct_chest_35,
            [36]	 = gg_rct_chest_36,
            [37]	 = gg_rct_chest_37,
            [38]	 = gg_rct_chest_38,
            [39]	 = gg_rct_chest_39,
            [40]	 = gg_rct_chest_40,
            [41]	 = gg_rct_chest_41,
            [42]	 = gg_rct_chest_42,
            [43]	 = gg_rct_chest_43,
            [44]	 = gg_rct_chest_44,
            [45]	 = gg_rct_chest_45,
            [46]	 = gg_rct_chest_46,
            [47]	 = gg_rct_chest_47,
            [48]	 = gg_rct_chest_48,
            [49]	 = gg_rct_chest_49,
            [50]	 = gg_rct_chest_50,
            [51]	 = gg_rct_chest_51,
            [52]	 = gg_rct_chest_52,
            [53]	 = gg_rct_chest_53,
            [54]	 = gg_rct_chest_54,
            [55]	 = gg_rct_chest_55,
            [56]	 = gg_rct_chest_56,
            [57]	 = gg_rct_chest_57,
            [58]	 = gg_rct_chest_58,
            [59]	 = gg_rct_chest_59,
            [60]	 = gg_rct_chest_60,
            [61]	 = gg_rct_chest_61,
            [62]	 = gg_rct_chest_62,
            [63]	 = gg_rct_chest_63,
            [64]	 = gg_rct_chest_64,
            [65]	 = gg_rct_chest_65,
            [66]	 = gg_rct_chest_66
        }

        AltarRects = {
            [1] = gg_rct_altar_1,
            [2] = gg_rct_altar_2,
            [3] = gg_rct_altar_3,
            [4] = gg_rct_altar_4,
            [5] = gg_rct_altar_5,
            [6] = gg_rct_altar_6,
            [7] = gg_rct_altar_7,
            [8] = gg_rct_altar_8,
            [9] = gg_rct_altar_9,
            [10] = gg_rct_altar_10,
            [11] = gg_rct_altar_11,
            [12] = gg_rct_altar_12,
            [13] = gg_rct_altar_13,
            [14] = gg_rct_altar_14,
            [15] = gg_rct_altar_15
        }


        for i = 1, #AltarRects do
            if Chance(65.) then
                if GetRandomInt(1, 3) == 1 then
                    CreateWell(GetRandomInt(1, 3) == 1 and ALTAR_TYPE_WELL_MP or ALTAR_TYPE_WELL_HP, AltarRects[i])
                else
                    CreateObelisk(AltarRects[i])
                end
            end
        end

        ChestGroup = CreateGroup()

        local chest_index_table = GetRandomIntTable(1, #ChestRects, 15)

        for i = 1, #chest_index_table do
            CreateChest(ChestRects[chest_index_table[i]])
        end


        TimerStart(CreateTimer(), 27.5, true, function()
            if BlzGroupGetSize(ChestGroup) < ChestMax then
                if Chance(75. - (100. * (1. - (BlzGroupGetSize(ChestGroup) / ChestMax)))) then
                    --local rect_index = GetRandomInt(1, #ChestRects)
                    local gr = CreateGroup()
                    local rect_index = GetRandomIntTable(1, #ChestRects, #ChestRects)

                        for i = 1, #rect_index do
                            GroupClear(gr)
                            GroupEnumUnitsInRect(gr, ChestRects[rect_index[i]], nil)
                            if BlzGroupGetSize(gr) == 0 and not IsAnyHeroInRange(GetRectCenterX(ChestRects[rect_index[i]]), GetRectCenterY(ChestRects[rect_index[i]]), 1450.) then
                                CreateChest(ChestRects[rect_index[i]])
                                break
                            end
                        end

                    DestroyGroup(gr)
                end
                --IsAnyHeroInRange(GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 1550.)
            end


        end)

        CreateWell(ALTAR_TYPE_WELL_HP, gg_rct_test_a_2)
        CreateWell(ALTAR_TYPE_WELL_MP, gg_rct_test_a_1)

        local rects = { gg_rct_shrineofhate1, gg_rct_shrineofhate2, gg_rct_shrineofhate3, gg_rct_shrineofhate4, gg_rct_shrineofhate5, gg_rct_shrineofhate6, gg_rct_shrineofhate7 }
        CreateShrineOfHatred(rects[GetRandomInt(1, #rects)])
        rects = nil

    end





end