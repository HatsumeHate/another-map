---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 23:28
---
do


    WaveTimer = nil
    Current_Wave = 1

    local MusicMix = {
        "Sound\\Music\\mp3Music\\IllidansTheme.mp3",
        "Sound\\Music\\mp3Music\\ArthasTheme.mp3",
        "Sound\\Music\\mp3Music\\BloodElfTheme.mp3"
    }

    function GetRandomMusicMix()
        local result_mix = ""
        local order_table = GetRandomIntTable(1, #MusicMix, #MusicMix)

        for i = 1, #order_table do
            result_mix = result_mix .. MusicMix[order_table[i]] .. ";"
        end

        return result_mix
    end


    function EndWave()

        if Current_Wave == 50 then
            VictoryScreen()
        else
            Current_Wave = Current_Wave + 1
            AddWaveTimer(330.)
            ResetShops()
            ToggleCitizens(true)
            ScaleMonsterPacks()

            StopMusic(true)
            ClearMapMusic()
            PlayMusic(GetRandomMusicMix())
            ResumeMusic()
        end

    end


    function ResetShops()
        local item_count = GetRandomInt(7, 12)

        --print("shops reset - start")
            --smorc
            ClearShop(gg_unit_opeo_0031)
            --print("shop cleared")
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedItemId(), 0., 0.)
                --print("create item number " .. i)
                local roll = GetRandomInt(1, 5)
                local quality

                    if roll == 1 then quality = MAGIC_ITEM
                    elseif roll == 2 then quality = RARE_ITEM
                    else quality = COMMON_ITEM
                    end

                GenerateItemStats(item, Current_Wave + GetRandomInt(1, 2), quality)
                AddItemToShop(gg_unit_opeo_0031, item, false)
            end

        --print("smorc shop is generated")

            local item_pool = {
                SWORD_WEAPON,
                GREATSWORD_WEAPON,
                AXE_WEAPON,
                GREATAXE_WEAPON,
                BLUNT_WEAPON,
                GREATBLUNT_WEAPON,
                STAFF_WEAPON,
                --BOW_WEAPON,
                DAGGER_WEAPON,
                CHEST_ARMOR,
                HANDS_ARMOR,
                HEAD_ARMOR,
                LEGS_ARMOR,
                SHIELD_OFFHAND
            }

            --smith
            ClearShop(gg_unit_n000_0056)
            for i = 1, #item_pool do
                local item = CreateCustomItem(GetGeneratedItemId(item_pool[i]), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                AddItemToShop(gg_unit_n000_0056, item, false)
            end


            item_count = GetRandomInt(2, 7)
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedItemId(), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                AddItemToShop(gg_unit_n000_0056, item, false)
            end

        --print("blacksmith shop is generated")

            item_pool = {
                RING_JEWELRY,
                NECKLACE_JEWELRY,
                ORB_OFFHAND,
                BELT_ARMOR,
            }

            --herbalist
            ClearShop(gg_unit_n001_0055)
            item_count = GetRandomInt(2, 6)
            for i = 1, item_count do
                local item = CreateCustomItem(GetGeneratedItemId(item_pool[GetRandomInt(1, 4)]), 0., 0.)
                GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                AddItemToShop(gg_unit_n001_0055, item, false)
            end

            local scrolls = CreateCustomItem(ITEM_SCROLL_OF_TOWN_PORTAL, 0., 0.)
            SetItemCharges(scrolls, 5)
            AddItemToShopWithSlot(gg_unit_n001_0055, scrolls, 30, false)

        --print("shops resetted")
    end


    function AddWaveTimer(total_time)
        local item = MultiboardGetItem(MAIN_MULTIBOARD, 0, 1)

        MultiboardSetItemStyle(item, true, false)
        MultiboardSetItemValue(item, TimeToText(total_time))
        MultiboardSetItemValue(MultiboardGetItem(MAIN_MULTIBOARD, 0, 0),  LOCALE_LIST[my_locale].WAVE_LEVEL .. I2S(Current_Wave))
        TimerStart(WaveTimer, 0., false, nil)

        TimerStart(WaveTimer, 1., true, function()
            total_time = total_time - 1.
            MultiboardSetItemValue(item, TimeToText(total_time))

            if total_time <= 0. then
                PauseTimer(WaveTimer)
                SpawnMonstersWave(GetRandomMonsterSpawnPoint())
                ToggleCitizens(false)
                Play2DSound("Sound\\Interface\\Warning.wav", 127)
                StopMusic(true)
                ClearMapMusic()
                PlayMusic("Sound\\Music\\mp3Music\\PursuitTheme.mp3")
                --SetMapMusic("Sound\\Music\\mp3Music\\PursuitTheme.mp3", false, 0)
                ResumeMusic()
            end

        end)

    end


    function WavesInit()

        InitMultiboard()
        WaveTimer = CreateTimer()

        RegisterTestCommand("run", function() AddWaveTimer(3.) end)

    end

end