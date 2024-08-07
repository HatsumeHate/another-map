---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 23:28
---
do


    WaveTimer = 0
    Current_Wave = 1
    WavesUntilShopsUpdate = 2
    OngoingWave = false
    local MusicMix = 0
    local WaveToAquireHalfPotions = 12



    function GetRandomMusicMix()
        
        local result_mix = ""
        local order_table = GetRandomIntTable(1, #MusicMix, #MusicMix)

        for i = 1, #order_table do
            result_mix = result_mix .. MusicMix[order_table[i]] .. ";"
        end

        return result_mix
    end


    function EndWave()

        if Current_Wave >= 51 then
            VictoryScreen()
        else
            Current_Wave = Current_Wave + 1 + GLOBAL_WAVE_SKIP_BONUS
            AddWaveTimer(390.)
            --print("reset shops")
            ResetShops()
            --print("toggle citizens")
            ToggleCitizens(true)
            --print("prescale")
            ScaleMonsterPacks()
            UpdateSacrificeAltarHexCosts()
            --print("scaling done")
            StopMusic(true)
            ClearMapMusic()
            PlayMusic(GetRandomMusicMix())
            ResumeMusic()
            OngoingWave = false
        end

        for i = 1, 6 do
            UpdateBlacksmithWindow(i)
            SavePlayerProgression(i)
        end

    end

    function ResetPeonShop()
         local item_count = GetRandomInt(7, 12)

            --print("clear peon")
            ClearShop(gg_unit_opeo_0031)
            --print("clear ok")
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedItemId(), 0., 0.)
                local roll = GetRandomInt(1, 5)
                local quality
                local item_data = GetItemData(item)

                    item_data.picked_up = true

                    if roll == 1 then quality = MAGIC_ITEM
                    elseif roll == 2 then quality = RARE_ITEM
                    else quality = COMMON_ITEM end

                GenerateItemStats(item, Current_Wave + GetRandomInt(1, 2), quality)
                AddItemToShop(gg_unit_opeo_0031, item, false)
            end
    end


    function ResetBlackShop()
        local item_pool = {
            SWORD_WEAPON, GREATSWORD_WEAPON, AXE_WEAPON, GREATAXE_WEAPON, BLUNT_WEAPON, GREATBLUNT_WEAPON, STAFF_WEAPON, BOW_WEAPON,
            DAGGER_WEAPON, CHEST_ARMOR, HANDS_ARMOR, HEAD_ARMOR, LEGS_ARMOR, SHIELD_OFFHAND
        }

            --print("clear smith")
            --smith
            ClearShop(gg_unit_n000_0056)
            --print("clear ok")
            for i = 1, #item_pool do
                local item = CreateCustomItem(GetGeneratedItemId(item_pool[i]), 0., 0.)
                local item_data = GetItemData(item)

                    item_data.picked_up = true
                    GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                    AddItemToShop(gg_unit_n000_0056, item, false)
            end
            --print("smith A")

            local item_count = GetRandomInt(2, 5)
            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedItemId(), 0., 0.)
                local item_data = GetItemData(item)

                    item_data.picked_up = true
                    GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                    AddItemToShop(gg_unit_n000_0056, item, false)
            end
            --print("smith B")
            --print("smith done")
    end


    function ResetHerbalistShop()
        local item_pool = { RING_JEWELRY, NECKLACE_JEWELRY, ORB_OFFHAND, BELT_ARMOR }

            --herbalist
            --print("clear herb")
            ClearShop(gg_unit_n001_0055)
           -- print("clear ok")

            if WaveToAquireHalfPotions and Current_Wave >= WaveToAquireHalfPotions then
                local my_item = CreateCustomItem(ITEM_POTION_HEALTH_HALF,  0.,0.)
                    SetItemCharges(my_item, 20)
                    AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 26, true)
                    my_item = CreateCustomItem(ITEM_POTION_MANA_HALF,  0.,0.)
                    SetItemCharges(my_item, 20)
                    AddItemToShopWithSlot(gg_unit_n001_0055, my_item, 27, true)
                    WaveToAquireHalfPotions = nil
            end
            --print("half pots done")

            local item_count = GetRandomInt(2, 6)
            for i = 1, item_count do
                local item = CreateCustomItem(GetGeneratedItemId(item_pool[GetRandomInt(1, 4)]), 0., 0.)
                local item_data = GetItemData(item)

                    item_data.picked_up = true
                    GenerateItemStats(item, Current_Wave, GetRandomInt(1, 5) == 1 and RARE_ITEM or COMMON_ITEM)
                    AddItemToShop(gg_unit_n001_0055, item, false)
            end
            --print("herb A")


            item_count = GetRandomInt(0, 6)
            if item_count > 0 then
                 AddItemToShop(gg_unit_n001_0055, CreateCustomItem(GetRandomBookItemId(COMMON_ITEM), 0, 0, false), false)
            end
            --print("herb B")

            if GetRandomInt(1, 2) == 2 then
                local item = CreateCustomItem("I01O", 0, 0, false)
                SetItemCharges(item, GetRandomInt(1, 2))
                AddItemToShop(gg_unit_n001_0055, item, false)
            end

            --print("herb done")
    end

    function ResetLynnShop()
        local item_count = GetRandomInt(1, 6)

            --print("clear lynn")
            ClearShop(gg_unit_n020_0075)
            --print("clear ok")

            for i = 1, item_count do
                local item = CreateCustomItem(GetRandomGeneratedItemId(), 0., 0., false)
                local roll = GetRandomInt(1, 6)
                local quality
                local item_data = GetItemData(item)

                    item_data.picked_up = true

                    if roll == 2 then quality = RARE_ITEM
                    else quality = COMMON_ITEM end

                GenerateItemStats(item, Current_Wave + GetRandomInt(1, 2), quality)
                AddItemToShop(gg_unit_n020_0075, item, false)
            end
            --print("lynn A")

            if GetRandomInt(1, 2) == 1 then
                local item = CreateCustomItem(ITEM_POTION_MIX_WEAK, 0., 0.)
                SetItemCharges(item, GetRandomInt(15, 20) * ActivePlayers)
                AddItemToShopWithSlot(gg_unit_n020_0075, item, 31, false)
            end
            --print("lynn B")

            if GetRandomInt(1, 2) == 1 then
                local item = CreateCustomItem(ITEM_POTION_MIX_HALF, 0., 0.)
                SetItemCharges(item, GetRandomInt(15, 20) * ActivePlayers)
                AddItemToShopWithSlot(gg_unit_n020_0075, item, 32, false)
            end
            --print("lynn C")
    end

    function ResetShops()
        --print("shops reset start")
        WavesUntilShopsUpdate = WavesUntilShopsUpdate + 1
        --print("clear wanderer")
        ClearShop(gg_unit_n01W_0111)
        --print("clear ok")

        if WavesUntilShopsUpdate == 3 then
            WavesUntilShopsUpdate = 0
            DelayAction(0.1, function() ResetPeonShop() end)
            DelayAction(0.15, function() ResetBlackShop() end)
            DelayAction(0.2, function() ResetHerbalistShop() end)
            DelayAction(0.25, function() ResetLynnShop() end)
        end


        DelayAction(0.26, function()
            local item_count = GetRandomInt(0, 7)
            local item

                if item_count > 0 then
                    item = CreateCustomItem(ITEM_POTION_ADRENALINE, 0, 0, false)
                    SetItemCharges(item, item_count * ActivePlayers)
                    AddItemToShop(gg_unit_n001_0055, item, false)
                end

                item_count = GetRandomInt(0, 5)
                if item_count > 0 then
                    item = CreateCustomItem(ITEM_POTION_ANTIDOTE, 0, 0, false)
                    SetItemCharges(item, item_count * ActivePlayers)
                    AddItemToShop(gg_unit_n001_0055, item, false)
                end

                item_count = GetRandomInt(0, 7)
                if item_count > 0 then
                    item = CreateCustomItem(ITEM_SCROLL_OF_PROTECTION, 0, 0, false)
                    SetItemCharges(item, item_count * ActivePlayers)
                    AddItemToShop(gg_unit_n001_0055, item, false)
                end

                local scrolls = CreateCustomItem(ITEM_SCROLL_OF_TOWN_PORTAL, 0., 0.)
                SetItemCharges(scrolls, 5 * ActivePlayers)
                AddItemToShopWithSlot(gg_unit_n001_0055, scrolls, 28, false)

                if GetRandomInt(1, 4) == 1 then
                    local item = CreateCustomItem(ITEM_ELIXIR_INNOCENCE, 0, 0, false)

                        SetItemCharges(item, GetRandomInt(1, 2) * ActivePlayers)
                        AddItemToShop(gg_unit_n001_0055, item, false)
                end

                if GetRandomInt(1, 5) == 1 then
                    local item = CreateCustomItem(ITEM_NECRONOMICON, 0, 0, false)

                        SetItemCharges(item, GetRandomInt(1, 4))
                        AddItemToShop(gg_unit_n001_0055, item, false)
                end
        end)
        --print("shops resetted")
    end



    function AddWaveTimer(total_time)
        local item = MultiboardGetItem(MAIN_MULTIBOARD, 0, 1)

        MultiboardSetItemStyle(item, true, false)
        MultiboardSetItemValue(item, TimeToText(total_time))
        MultiboardSetItemValue(MultiboardGetItem(MAIN_MULTIBOARD, 0, 0),  LOCALE_LIST[my_locale].WAVE_LEVEL .. I2S(Current_Wave))
        TimerStart(WaveTimer, 0., false, nil)

        TimerStart(WaveTimer, 1., true, function()
            item = MultiboardGetItem(MAIN_MULTIBOARD, 0, 1)
            total_time = total_time - 1.
            MultiboardSetItemValue(item, TimeToText(total_time))

                if total_time <= 0. then
                    OngoingWave = true
                    PauseTimer(WaveTimer)
                    SpawnMonstersWave(GetRandomMonsterSpawnPoint())
                    ToggleCitizens(false)
                    Play2DSound("Sound\\Interface\\Warning.wav", 127)
                    StopMusic(true)
                    ClearMapMusic()
                    PlayMusic("Sound\\Music\\mp3Music\\PursuitTheme.mp3")
                    ResumeMusic()
                end

        end)

    end


    function WavesInit()

        MusicMix = {
            "Sound\\Music\\mp3Music\\IllidansTheme.mp3",
            "Sound\\Music\\mp3Music\\ArthasTheme.mp3",
            "Sound\\Music\\mp3Music\\BloodElfTheme.mp3"
        }

        InitMultiboard()
        WaveTimer = CreateTimer()

        RegisterTestCommand("run", function() AddWaveTimer(3.) end)

        RegisterTestCommand("lvl4", function() Current_Wave = 4 end)
        RegisterTestCommand("extreme", function() Current_Wave = 48 end)

    end

end