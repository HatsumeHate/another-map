---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 23:28
---
do

    MAIN_MULTIBOARD = nil
    local WaveTimer
    Current_Wave = 1


    local function TimeToText(time)
        local mins = math.floor(time / 60.)
        local secs = time - (mins * 60.)

        return R2I(mins) .. ":" .. R2I(secs)
    end


    RegisterTestCommand("run", function() AddWaveTimer(3.) end)
    --[[
    local trigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trigger, Player(0), "run", false)
    TriggerAddAction(trigger, function() AddWaveTimer(3.) end)]]



    function ResetShops()
        local item_count = GetRandomInt(2, 7)

            ClearShop(gg_unit_opeo_0031)
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedId(), 0., 0.)
                local roll = GetRandomInt(1, 5)
                local quality

                    if roll == 1 then
                        quality = MAGIC_ITEM
                    elseif roll == 2 then
                        quality = RARE_ITEM
                    else
                        quality = COMMON_ITEM
                    end

                GenerateItemStats(item, Current_Wave, quality)
                AddItemToShop(gg_unit_opeo_0031, item, false)
            end


            local item_pool = {
                SWORD_WEAPON,
                GREATSWORD_WEAPON,
                AXE_WEAPON,
                GREATAXE_WEAPON,
                BLUNT_WEAPON,
                GREATBLUNT_WEAPON,
                STAFF_WEAPON,
                BOW_WEAPON,
                DAGGER_WEAPON,
                CHEST_ARMOR,
                HANDS_ARMOR,
                HEAD_ARMOR,
                LEGS_ARMOR
            }

            ClearShop(gg_unit_n000_0056)
            for i = 1, #item_pool do
                local item = CreateCustomItem(GetGeneratedItemId(item_pool[i]), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 2) == 1 and COMMON_ITEM or RARE_ITEM)
                AddItemToShop(gg_unit_n000_0056, item, false)
            end


            item_count = GetRandomInt(2, 7)
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedId(), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 2) == 1 and COMMON_ITEM or RARE_ITEM)
                AddItemToShop(gg_unit_n000_0056, item, false)
            end


            ClearShop(gg_unit_n001_0055)
            item_count = GetRandomInt(2, 5)
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomInt(1, 2) == 1 and GetGeneratedItemId(RING_JEWELRY) or GetGeneratedItemId(NECKLACE_JEWELRY), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 2) == 1 and COMMON_ITEM or RARE_ITEM)
                AddItemToShop(gg_unit_n001_0055, item, false)
            end

    end


    function AddWaveTimer(total_time)
        local item = MultiboardGetItem(MAIN_MULTIBOARD, 1, 1)

            MultiboardSetItemStyle(item, true, false)
            MultiboardSetItemValue(item, TimeToText(total_time))
            TimerStart(WaveTimer, 0., false, nil)

            TimerStart(WaveTimer, 1., true, function()
                total_time = total_time - 1.
                MultiboardSetItemValue(item, TimeToText(total_time))

                    if total_time <= 0. then
                        PauseTimer(WaveTimer)
                        SpawnMonsters()
                    end

            end)

    end


    function WavesInit()

        WaveTimer = CreateTimer()
        MAIN_MULTIBOARD = CreateMultiboard()
        MultiboardSetTitleText(MAIN_MULTIBOARD, LOCALE_LIST[my_locale].WAVE_INCOMING_TEXT)
        MultiboardSetItemsStyle(MAIN_MULTIBOARD, true, false)
        MultiboardSetItemsWidth(MAIN_MULTIBOARD, 6.5 / 200.0)
        MultiboardSetColumnCount(MAIN_MULTIBOARD, 4)
        MultiboardSetRowCount(MAIN_MULTIBOARD, 4)
        MultiboardDisplay(MAIN_MULTIBOARD, true)


    end

end