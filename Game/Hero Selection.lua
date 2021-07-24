---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 16:52
---
do

    local MAX_RANGE_XP_LOSS = 1700.
    local MIN_XP_LOSS_RATE = 0.35



    function IsAHero(unit)
        for i = 1, 6 do if PlayerHero[i] and PlayerHero[i] == unit then return true end end
        return false
    end


     function IsAnyHeroInRange(x, y, range)
        for i = 1, 6 do if PlayerHero[i] and IsUnitInRangeXY(PlayerHero[i], x, y, range) then return true end end
        return false
    end


    ---@param amount integer
    ---@param x real
    ---@param y real
    function GiveExpForKill(amount, x, y)
        for i = 1, 6 do
            if PlayerHero[i] and GetUnitState(PlayerHero[i], UNIT_STATE_LIFE) > 0.045 then
                local xp_rate = 1.
                local distance = DistanceBetweenUnitXY(PlayerHero[i], x, y)

                    if distance > MAX_RANGE_XP_LOSS then
                        xp_rate = MAX_RANGE_XP_LOSS / distance
                    end

                if xp_rate < MIN_XP_LOSS_RATE then xp_rate = MIN_XP_LOSS_RATE end
                SuspendHeroXP(PlayerHero[i], false)
                AddHeroXP(PlayerHero[i], math.ceil(amount * xp_rate), false)
                SuspendHeroXP(PlayerHero[i], true)
            end
        end
    end


    ---@param amount integer
    function GiveExp(amount)
        amount = amount + (Current_Wave * 5)
        for i = 1, 6 do
            if PlayerHero[i] then
                SuspendHeroXP(PlayerHero[i], false)
                AddHeroXP(PlayerHero[i], amount, false)
                SuspendHeroXP(PlayerHero[i], true)
            end
        end
        return amount
    end

    ---@param amount integer
    function GiveGold(amount)
        amount = amount + Current_Wave * 20
        for i = 1, 6 do
            if PlayerHero[i] then
                SetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD) + amount)
                PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", i-1, 120)
                --AddHeroXP(PlayerHero[i], amount + (Current_Wave * 3), false)
            end
        end
        return amount
    end


    local HeroDeathSoundpack = {
        [BARBARIAN_CLASS] = { "Sound\\Barbarian\\death1.wav", "Sound\\Barbarian\\death2.wav" },
        [SORCERESS_CLASS] = { "Sound\\Sorceress\\death1.wav", "Sound\\Sorceress\\death2.wav", "Sound\\Sorceress\\death3.wav" }
    }


    function CreateHeroSelections()

        local DeathTrigger = CreateTrigger()
        local LvlupTrigger = CreateTrigger()
        local trg = CreateTrigger()
        local barbarian_region = CreateRegion()
        RegionAddRect(barbarian_region, gg_rct_barbarian_select)

        local sorc_region = CreateRegion()
        RegionAddRect(sorc_region, gg_rct_sorceress_select)

        TriggerRegisterEnterRegionSimple(trg, barbarian_region)
        TriggerRegisterEnterRegionSimple(trg, sorc_region)

        TriggerAddAction(trg, function ()
            local region = GetTriggeringRegion()
            local id
            local player_id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            local starting_items = {}
            local starting_skills = {}

                ActivePlayers = ActivePlayers + 1
                if region == barbarian_region then
                    id = FourCC("HBRB")
                    starting_items[1] = CreateCustomItem("I011", 0., 0.)
                    starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                    starting_items[3] = CreateCustomItem("I010", 0., 0.)
                    starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                    starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
                    starting_skills[1] = 'A007'
                    starting_skills[2] = 'A00C'
                    starting_skills[3] = 'A00Z'

                    --starting_skills[4] = 'A010'
                    --starting_skills[5] = 'A006'
                    --starting_skills[6] = 'A00O'
                else
                    id = FourCC("HSRC")
                    starting_items[1] = CreateCustomItem("I012", 0., 0.)
                    starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                    starting_items[3] = CreateCustomItem("I010", 0., 0.)
                    starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                    starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
                    starting_skills[1] = 'A003'
                    starting_skills[2] = 'A00J'
                    starting_skills[3] = 'A00D'
                    --starting_skills[4] = "AMLT"
                    --[[
                    starting_skills[4] = 'A005'
                    starting_skills[5] = 'A00L'
                    starting_skills[6] = 'A001'
                    starting_skills[7] = 'A00K'
                    starting_skills[8] = 'A00M'
                    starting_skills[9] = 'A019'
                    starting_skills[10] = 'A00F'
                    starting_skills[11] = 'A00I'
                    starting_skills[12] = 'A00N'
                    starting_skills[13] = 'A00E'
                    starting_skills[14] = 'A00H']]
                end

                local hero = CreateUnit(Player(player_id), id, GetRectCenterX(gg_rct_starting_location) , GetRectCenterY(gg_rct_starting_location), 270.)
                RemoveUnit(GetTriggerUnit())
                --SelectUnit(hero, true)
                --SelectUnitAddForPlayer(hero, Player(player_id))

                SetCameraBoundsToRectForPlayerBJ(Player(player_id), bj_mapInitialCameraBounds)


                local player_number = player_id
                --local SelectTrigger = CreateTrigger()

                --TimerStart(CreateTimer(), 0.03, true,
                --TriggerAddAction(trg, )
                    --function()
                    --if GetLocalPlayer() == Player(player_number) then
                      --  if not IsUnitSelected(hero, Player(player_number)) then
                       --     ClearSelection()
                       --     SelectUnit(hero, true)
                      --  end
                    --end
                    --SelectUnitSingle()
                    --SyncSelections()
                    --SelectUnitSingle(hero)
                        --if not IsUnitSelected(hero, Player(player_number)) then
                           -- if GetLocalPlayer() == Player(player_number) then
                             --   ClearSelection()
                             --   SelectUnit(hero, true)
                            --end
                        --end
               -- end)


                TimerStart(CreateTimer(), 0., false, function()
                    player_id = player_id + 1
                    PlayerHero[player_id] = hero

                    TriggerRegisterDeathEvent(DeathTrigger, hero)
                    TriggerRegisterUnitEvent(LvlupTrigger, hero, EVENT_UNIT_HERO_LEVEL)
                    TriggerRegisterUnitEvent(OrderInterceptionTrigger, hero, EVENT_UNIT_ATTACKED)
                    --TriggerRegisterUnitEvent(OrderInterceptionTrigger, hero, EVENT_UNIT_ISSUED_TARGET_ORDER)


                    CreateGUILayoutForPlayer(player_id, hero)
                    AddPointsToPlayer(player_id, 0)
                    LockCameraForPlayer(player_id)
                    RegisterItemPickUp(PlayerHero[player_id])
                    --SetUIState(player_id, INV_PANEL, false)
                    --SetUIState(player_id, SKILL_PANEL, false)
                    --SetUIState(player_id, CHAR_PANEL, false)

                    for i = 1, #starting_items do
                        EquipItem(hero, starting_items[i], true)
                        SetItemVisible(starting_items[i], false)
                        UpdateEquipPointsWindow(player_id)
                    end

                    local potions = CreateCustomItem(ITEM_POTION_HEALTH_WEAK, 0, 0, false)
                    SetItemCharges(potions, 5)
                    AddToInventory(player_id, potions)

                    potions = CreateCustomItem(ITEM_POTION_MANA_WEAK, 0, 0, false)
                    SetItemCharges(potions, 5)
                    AddToInventory(player_id, potions)


                    for i = 1, #starting_skills do
                        UnitAddMyAbility(hero, starting_skills[i])
                    end

                    if id == FourCC("HBRB") then
                        BlzSetUnitName(hero, LOCALE_LIST[my_locale].BARBARIAN_NAME)
                    else
                        BlzSetUnitName(hero, LOCALE_LIST[my_locale].SORCERESS_NAME)
                    end


                    DelayAction(6., function()
                        PlayCinematicSpeech(player_id-1, gg_unit_h000_0054, LOCALE_LIST[my_locale].INTRODUCTION_TEXT_1, 6.)
                        DelayAction(7., function()
                            PlayCinematicSpeech(player_id-1, gg_unit_h000_0054, LOCALE_LIST[my_locale].INTRODUCTION_TEXT_2, 6.)
                            DelayAction(7., function()
                                PlayCinematicSpeech(player_id-1, gg_unit_h000_0054, LOCALE_LIST[my_locale].INTRODUCTION_TEXT_3, 6.)
                                DelayAction(7., function()
                                    if id == FourCC("HBRB") then
                                        PlayCinematicSpeech(player_id-1, PlayerHero[player_id], LOCALE_LIST[my_locale].INTRODUCTION_BARBARIAN_RESPONCE, 6.)
                                    else
                                        PlayCinematicSpeech(player_id-1, PlayerHero[player_id], LOCALE_LIST[my_locale].INTRODUCTION_SORCERESS_RESPONCE, 6.)
                                    end
                                    SelectUnitForPlayerSingle(hero, Player(player_number))
                                    EnableGUIForPlayer(player_id)
                                    --SetUIState(player_id, INV_PANEL, true)
                                    --SetUIState(player_id, SKILL_PANEL, true)
                                    --SetUIState(player_id, CHAR_PANEL, true)
                                end)
                            end)
                        end)
                    end)

                    --GetHandleId()
                    if GetLocalPlayer() == Player(player_id - 1) then
                        PanCameraToTimed(GetUnitX(hero), GetUnitY(hero), 0.)
                    end

                    SuspendHeroXP(hero, true)
                    SetPlayerHandicapXP(Player(player_id-1), 0.)
                    DestroyTimer(GetExpiredTimer())
                end)

        end)


        TriggerAddAction(LvlupTrigger, function()
            AddPointsToPlayer(GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1, 3)
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdx", GetTriggerUnit(), "origin"))
        end)

        TriggerAddAction(DeathTrigger, function ()
            local hero = GetTriggerUnit()
            local player = GetOwningPlayer(hero)
            local unit_data = GetUnitData(hero)

            DisplayTextToPlayer(player, 0.,0., LOCALE_LIST[my_locale].RESSURECT_TEXT_1 .. string.format('%%.2f', R2S(7. + (Current_Wave / 4.))) .. LOCALE_LIST[my_locale].RESSURECT_TEXT_2)
            ResetUnitSpellCast(hero)
            SetUIState(GetPlayerId(player)+1, INV_PANEL, false)
            SetUIState(GetPlayerId(player)+1, SKILL_PANEL, false)
            local gold_lost = R2I(GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) * 0.1)

            if gold_lost > 1 then
                DisplayTextToPlayer(player, 0.,0., LOCALE_LIST[my_locale].GOLD_PENALTY_TEXT_1 .. R2I(gold_lost) .. LOCALE_LIST[my_locale].GOLD_PENALTY_TEXT_2)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - gold_lost)
            end


            AddSoundVolumeZ(HeroDeathSoundpack[unit_data.unit_class][GetRandomInt(1, #HeroDeathSoundpack[unit_data.unit_class])], GetUnitX(hero), GetUnitY(hero), 50., 115, 2200.)
                local timer = CreateTimer()
                TimerStart(timer, 7. + (Current_Wave / 4.), false, function()
                    ReviveHero(hero, GetRectCenterX(gg_rct_cemetary), GetRectCenterY(gg_rct_cemetary), true)
                    SetUnitTimeScale(hero, 1.)
                    SetUnitAnimationByIndex(hero, 0)
                    IssueImmediateOrderById(hero, order_stop)
                    SetUnitState(hero, UNIT_STATE_LIFE, GetUnitState(hero, UNIT_STATE_MAX_LIFE) * 0.5)
                    SetUnitState(hero, UNIT_STATE_MANA, GetUnitState(hero, UNIT_STATE_MAX_MANA) * 0.5)
                    DestroyTimer(GetExpiredTimer())
                    SelectUnitForPlayerSingle(hero, player)
                end)

        end)


        RegisterTestCommand("ded", function()
            KillUnit(PlayerHero[1])
        end)


        RegisterTestCommand("handle", function()
            print(GetHandleId(PlayerHero[1]))
        end)


    end

end