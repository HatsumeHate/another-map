---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 16:52
---
do

    local MAX_RANGE_XP_LOSS = 1700.
    local MIN_XP_LOSS_RATE = 0.35
    local DeathTrigger = 0
    local LvlupTrigger = 0
    local HeroDeathSoundpack = 0
    local HeroGroanSoundpack
    local HeroProperNames
    local HeroXPLevelFactor = 125.
    local HeroXPPrevLevelFactor = 1.14
    local HeroXPConstantFactor = 150.
    local CemetaryX
    local CemetaryY
    local PlayerLabels
    PlayerRequiredEXP = nil
    PlayerLastRequiredEXP = nil
    PlayerDash = nil
    local DASH_MODE_FACING = 1
    local DASH_MODE_CURSOR = -1
    local HpFeedbackCooldown



    ---@param player integer
    function SwitchPlayerDashMode(player)
        PlayerDash[player].mode = PlayerDash[player].mode * -1
    end

    ---@param player integer
    function DashPlayerHero(player)
        local unit_data = GetUnitData(PlayerHero[player])

        if not (TimerGetRemaining(unit_data.action_timer) > 0.) and not (TimerGetRemaining(PlayerDash[player].timer) > 0.) and not (IsUnitDisabled(PlayerHero[player]) or IsUnitRooted(PlayerHero[player])) then
            local angle = PlayerDash[player].mode == DASH_MODE_FACING and GetUnitFacing(PlayerHero[player]) or AngleBetweenUnitXY(PlayerHero[player], PlayerMousePosition[player].x, PlayerMousePosition[player].y)

                DisableHeroSkills(player)
                TimerStart(PlayerDash[player].timer, 5., false, nil)
                SetUnitFacing(PlayerHero[player], angle)
                unit_data.nudge_timer = CreateTimer()
                SetCameraQuickPositionForPlayer(Player(player-1), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
                NudgeUnit(PlayerHero[player], angle, 300., 0.52)
                TimerStart(CreateTimer(), 0.41, false, function()
                    EnableHeroSkills(player)
                    DestroyTimer(GetExpiredTimer())
                end)

                local value = 0
                local step = 100. / (5. / 0.025)
                BlzFrameSetValue(GlobalButton[player].dash_button_cooldown, 0)
                BlzFrameSetVisible(GlobalButton[player].dash_button_cooldown, true)

                TimerStart(CreateTimer(), 0.025, true, function()
                    value = value + step
                    BlzFrameSetValue(GlobalButton[player].dash_button_cooldown, value)
                    if value >= 100. then
                        BlzFrameSetVisible(GlobalButton[player].dash_button_cooldown, false)
                        DestroyTimer(GetExpiredTimer())
                    end
                end)

        end
    end

    ---@param player integer
    ---@param label string
    function HasPlayerLabel(player, label)
        return PlayerLabels[player][label]
    end

    ---@param player integer
    ---@param label string
    ---@param flag boolean
    function SetPlayerLabel(player, label, flag)
        PlayerLabels[player][label] = flag
    end

    ---@param unit unit
    function IsAHero(unit)
        for i = 1, 6 do if PlayerHero[i] and PlayerHero[i] == unit then return true end end
        return false
    end


     ---@param range real
     ---@param x real
     ---@param y real
     function IsAnyHeroInRange(x, y, range)
        for i = 1, 6 do if PlayerHero[i] and IsUnitInRangeXY(PlayerHero[i], x, y, range) and GetUnitState(PlayerHero[i], UNIT_STATE_LIFE) > 0.045 then return true end end
        return false
    end


    ---@param target table
    ---@param groan_type boolean
    function PlayGroanSound(target, groan_type)

        if groan_type then
            AddSoundVolume(HeroGroanSoundpack[target.unit_class]["soft"][GetRandomInt(1, #HeroGroanSoundpack[target.unit_class]["soft"])], GetUnitX(target.Owner), GetUnitY(target.Owner), 123, 1400.)
        else
            AddSoundVolume(HeroGroanSoundpack[target.unit_class]["hard"][GetRandomInt(1, #HeroGroanSoundpack[target.unit_class]["hard"])], GetUnitX(target.Owner), GetUnitY(target.Owner), 123, 1400.)
        end

        DelayAction(1.23, function()
            target.groan_cd = false
        end)

    end

    ---@param level integer
    function GetLevelXP(level)
        local xp = 200 -- level 1
        local i = 1

            for i = 2, level do
                xp = ((xp*HeroXPPrevLevelFactor) + (i+1) * HeroXPLevelFactor) + HeroXPConstantFactor
            end

        return xp
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
    ---@return integer
    ---@param player integer
    function GiveExpForPlayer(amount, player)
        amount = amount + (Current_Wave * 5)

            if PlayerHero[player] then
                SuspendHeroXP(PlayerHero[player], false)
                AddHeroXP(PlayerHero[player], amount * (1. + GetUnitParameterValue(PlayerHero[player], EXP_BONUS) * 0.01), false)
                SuspendHeroXP(PlayerHero[player], true)
            end

        return amount
    end

    ---@param amount integer
    ---@return integer
    function GiveExp(amount)
        amount = amount + (Current_Wave * 5)
        for i = 1, 6 do
            if PlayerHero[i] then
                SuspendHeroXP(PlayerHero[i], false)
                AddHeroXP(PlayerHero[i], amount * (1. + GetUnitParameterValue(PlayerHero[i], EXP_BONUS) * 0.01), false)
                SuspendHeroXP(PlayerHero[i], true)
            end
        end
        return amount
    end



    ---@param amount integer
    ---@param player integer
    ---@return integer
    function GiveGoldForPlayer(amount, player)
        amount = amount + Current_Wave * 20
            if PlayerHero[player] then
                SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD) + amount)
                PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", player-1, 120)
            end
        return amount
    end

    ---@param amount integer
    ---@return integer
    function GiveGold(amount)
        amount = amount + Current_Wave * 20
        for i = 1, 6 do
            if PlayerHero[i] then
                SetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD) + amount)
                PlayLocalSound("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", i-1, 120)
            end
        end
        return amount
    end



    ---@param hero unit
    ---@param message string
    function ParseStringHeroGender(hero, message)
        local data = GetUnitData(hero)
        local result_string = ""
        local last_sector = 0
        local new_block = 0
        local gender = false

        if data.unit_class == BARBARIAN_CLASS or data.unit_class == NECROMANCER_CLASS or data.unit_class == DRUID_CLASS or data.unit_class == PALADIN_CLASS then
            gender = true
        end

            while(true) do
                local new_parse_block = string.find(message, "@", last_sector)
                if new_parse_block then
                    local parse_block_ending = string.find(message, "#", last_sector)
                    local declension = ""

                    if gender then
                        local block = string.find(message, "@M", new_parse_block)
                        declension = string.sub(message, string.find(message, "@M", new_parse_block)+2, string.find(message, "!", block)-1)
                    else
                        local block = string.find(message, "!F", new_parse_block)
                        declension = string.sub(message, string.find(message, "!F", new_parse_block)+2, string.find(message, "#", block)-1)
                    end

                    result_string = result_string .. string.sub(message, new_block, new_parse_block-1) .. declension
                    last_sector = parse_block_ending + 1
                    new_block = last_sector
                else
                    result_string = result_string .. string.sub(message, last_sector, #message)
                    break
                end

            end

        return result_string
    end



    function HeroSelect()
        local region = GetTriggeringRegion()
        local id
        local player_id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        local starting_items = {}
        local starting_skills = {}

            ActivePlayers = ActivePlayers + 1
            if region == ClassRegions[BARBARIAN_CLASS] then
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
            elseif region == ClassRegions[SORCERESS_CLASS] then
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
            elseif region == ClassRegions[NECROMANCER_CLASS] then
                id = FourCC("HNCR")
                starting_items[1] = CreateCustomItem("I012", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
                starting_skills[1] = "ANRD"
                starting_skills[2] = "ANWK"
                starting_skills[3] = "ANBS"
                --[[
                starting_skills[4] = "ANGS"
                starting_skills[5] = "ANUC"
                starting_skills[6] = "ANDR"
                starting_skills[7] = "ANHV"
                starting_skills[8] = "ANWK"
                starting_skills[9] = "ANUL"
                starting_skills[10] = "ANCE"
                starting_skills[11] = "ANDV"
                starting_skills[12] = "ANDF"
                starting_skills[13] = "ANFR"
                starting_skills[14] = "ANBB"
                starting_skills[15] = "ANLR"
                starting_skills[16] = "ANPB"
                starting_skills[17] = "ANBR"
                starting_skills[18] = "ANTS"]]
            elseif region == ClassRegions[PALADIN_CLASS] then
                id = FourCC("HPAL")
                starting_items[1] = CreateCustomItem("I02O", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
                starting_items[6] = CreateCustomItem("I02N", 0., 0.)
            elseif region == ClassRegions[ASSASSIN_CLASS] then
                id = FourCC("HASS")
                starting_items[1] = CreateCustomItem("I02P", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)

                starting_skills[1] = "AACS"
                starting_skills[2] = "AABR"
                starting_skills[3] = "AABA"
                starting_skills[4] = "AASH"
                starting_skills[5] = "AAEV"
                starting_skills[6] = "AAVB"
                starting_skills[7] = "AABF"
                starting_skills[8] = "AATL"
                starting_skills[9] = "AALL"
                starting_skills[10] = "AANS"
                starting_skills[11] = "AATW"
                starting_skills[12] = "AABD"
                starting_skills[13] = "AAST"
                starting_skills[14] = "AACB"
                starting_skills[15] = "AADB"
                starting_skills[16] = "AAIG"
                starting_skills[17] = "AACT"
                starting_skills[18] = "AASC"
                starting_skills[19] = "AABT"
                starting_skills[20] = "AASB"
                starting_skills[21] = "AARL"


            elseif region == ClassRegions[AMAZON_CLASS] then
                id = FourCC("HAMA")
                --starting_items[1] = CreateCustomItem("I02P", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
            elseif region == ClassRegions[DRUID_CLASS] then
                id = FourCC("HDRU")
                starting_items[1] = CreateCustomItem("I012", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
            else
                ActivePlayers = ActivePlayers - 1
                return
            end

            SetPlayerState(Player(player_id), PLAYER_STATE_RESOURCE_GOLD, 1000)

                local hero = CreateUnit(Player(player_id), id, GetRectCenterX(gg_rct_starting_location) , GetRectCenterY(gg_rct_starting_location), 270.)
                RemoveUnit(GetTriggerUnit())
                DelayAction(0., function()
                    local unit_data = GetUnitData(hero)
                    SetTexture(hero, TEXTURE_ID_EMPTY)

                    if type(HeroProperNames[unit_data.unit_class]) == "table" then
                        BlzSetHeroProperName(hero, HeroProperNames[unit_data.unit_class][GetRandomInt(1, #HeroProperNames[unit_data.unit_class])])
                    else
                        local unt = CreateUnit(Player(0), FourCC(HeroProperNames[unit_data.unit_class]), 0.,0., 0.)
                        BlzSetHeroProperName(hero, BlzGetUnitStringField(unt, UNIT_SF_PROPER_NAMES))
                        RemoveUnit(unt)
                    end

                    if region == ClassRegions[NECROMANCER_CLASS] then RegisterNecromancerCorpseSpawn(hero) end

                    if unit_data.unit_class == BARBARIAN_CLASS or unit_data.unit_class == PALADIN_CLASS then ModifyStat(hero, VULNERABILITY, -30, STRAIGHT_BONUS, true)
                    elseif unit_data.unit_class == ASSASSIN_CLASS then ModifyStat(hero, VULNERABILITY, -15, STRAIGHT_BONUS, true)
                    elseif unit_data.unit_class == SORCERESS_CLASS then AddSpecialEffectTarget("Model\\Sorceress_Hair.mdx", hero, "head") end

                end)

                SetCameraBoundsToRectForPlayerBJ(Player(player_id), bj_mapInitialCameraBounds)

                local player_number = player_id
                player_id = player_id + 1
                PlayerHero[player_id] = hero

                    TriggerRegisterDeathEvent(DeathTrigger, hero)
                    TriggerRegisterUnitEvent(LvlupTrigger, hero, EVENT_UNIT_HERO_LEVEL)
                    TriggerRegisterUnitEvent(OrderInterceptionTrigger, hero, EVENT_UNIT_ATTACKED)
                    local damage_trigger = CreateTrigger()
                    local hp_state_trigger = CreateTrigger()
                    TriggerRegisterUnitEvent(damage_trigger, hero, EVENT_UNIT_DAMAGED)
                    TriggerAddAction(damage_trigger, function()
                        if GetEventDamage() > 0 then
                            if (GetUnitState(hero, UNIT_STATE_LIFE) - GetEventDamage()) / BlzGetUnitMaxHP(hero) < 0.2 then
                                if not HpFeedbackCooldown[player_id] then
                                    Feedback_Health(player_id)
                                    HpFeedbackCooldown[player_id] = true
                                    DelayAction(14., function() HpFeedbackCooldown[player_id] = false end)
                                end
                                SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp")
                                SetCineFilterBlendMode(BLEND_MODE_ADDITIVE)
                                SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                                SetCineFilterStartUV(0, 0, 1, 1)
                                SetCineFilterEndUV(0, 0, 1, 1)
                                SetCineFilterStartColor(255, 75, 75, 0)
                                SetCineFilterEndColor(255, 75, 75, 100)
                                if GetLocalPlayer() == Player(player_number) then DisplayCineFilter(true) end
                                SetCineFilterDuration(0.75)
                                EnableTrigger(hp_state_trigger)
                                DisableTrigger(damage_trigger)
                            end
                        end
                    end)

                    TriggerRegisterTimerEventPeriodic(hp_state_trigger, 0.33)
                    TriggerAddAction(hp_state_trigger, function()
                        if GetUnitState(hero, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(hero) > 0.2 then
                            if GetLocalPlayer() == Player(player_number) then DisplayCineFilter(false) end
                            EnableTrigger(damage_trigger)
                            DisableTrigger(hp_state_trigger)
                        end
                    end)


                    CreateGUILayoutForPlayer(player_id, hero)
                    LockCameraForPlayer(player_id)
                    RegisterItemPickUp(PlayerHero[player_id])

                    local timer = CreateTimer()
                    TimerStart(timer, 1.5, false, function()
                        local pid = player_id

                            for i = 1, #starting_items do
                                AddToInventory(player_id, starting_items[i])
                                local id = GetItemData(starting_items[i])
                                DestroyEffect(id.quality_effect_light)
                                EquipItem(hero, starting_items[i], true)
                                SetItemVisible(starting_items[i], false)
                            end

                        local potions = CreateCustomItem(ITEM_POTION_HEALTH_WEAK, 0, 0, false)
                        SetItemCharges(potions, 5)
                        AddToInventory(pid, potions)
                        potions = CreateCustomItem(ITEM_POTION_MANA_WEAK, 0, 0, false)
                        SetItemCharges(potions, 5)
                        AddToInventory(pid, potions)
                        UpdateEquipPointsWindow(pid)

                        for i = 1, #starting_skills do
                            UnitAddMyAbility(hero, starting_skills[i])
                        end

                        AddPointsToPlayer(player_id, 0)
                        ShowPlayerUI(player_id)
                        SelectUnitForPlayerSingle(hero, Player(player_number))
                        EnableGUIForPlayer(player_id)
                        DelayAction(3., function()
                            SkillPanelTutorialData[player_id] = true
                            if GetLocalPlayer() == Player(player_number) then
                                StartSound(bj_questHintSound)
                                BlzFrameSetVisible(PlayerUI.arrow, true)
                                BlzFrameSetVisible(PlayerUI.arrow_ability_text, true)
                            end
                            DisplayPlayerProgression(player_id)
                        end)
                    end)


                    if id == FourCC("HBRB") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].BARBARIAN_NAME)
                    elseif id == FourCC("HSRC") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].SORCERESS_NAME)
                    elseif id == FourCC("HNCR") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].NECROMANCER_NAME)
                    elseif id == FourCC("HPAL") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].PALADIN_NAME)
                    elseif id == FourCC("HDRU") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].DRUID_NAME)
                    elseif id == FourCC("HASS") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].ASSASSIN_NAME)
                    elseif id == FourCC("HAMA") then BlzSetUnitName(hero, LOCALE_LIST[my_locale].AMAZON_NAME) end

                    if GetLocalPlayer() == Player(player_id - 1) then
                        PanCameraToTimed(GetUnitX(hero), GetUnitY(hero), 0.)
                    end

        SuspendHeroXP(hero, true)
        SetPlayerHandicapXP(Player(player_id-1), 0.)

    end



    BarbarianRegion = 0
    SorceressRegion = 0
    NecromancerRegion = 0
    ClassRegions = nil


    local function CreateClassText(rect, text)
        local texttag = CreateTextTag()
        SetTextTagText(texttag, text, 0.02)
        SetTextTagColor(texttag, 255, 140, 140, 0)
        SetTextTagPos(texttag, GetRectCenterX(rect)-32., GetRectCenterY(rect), 35.)
    end


    function CreateHeroSelections()

        PlayerHero = {}
        PlayerLabels = {}
        PlayerRequiredEXP = {}
        PlayerLastRequiredEXP = {}
        PlayerDash = {}
        HpFeedbackCooldown = {}

        for i = 1, 6 do
            PlayerLastRequiredEXP[i] = 0
            PlayerRequiredEXP[i] = GetLevelXP(1)
            PlayerLabels = { }
            PlayerDash[i] = { mode = DASH_MODE_CURSOR, timer = CreateTimer() }
            HpFeedbackCooldown[i] = false
        end

        DeathTrigger = CreateTrigger()
        LvlupTrigger = CreateTrigger()
        local trg = CreateTrigger()


        local class_rects = {
            [BARBARIAN_CLASS] = gg_rct_barbarian_select,
            [SORCERESS_CLASS] = gg_rct_sorceress_select,
            [NECROMANCER_CLASS] = gg_rct_necro_select,
            [PALADIN_CLASS] = gg_rct_paladin_select,
            [ASSASSIN_CLASS] = gg_rct_assassin_select,
            [DRUID_CLASS] = gg_rct_druid_select,
            [AMAZON_CLASS] = gg_rct_amazon_select,
        }

        local hero_state = {
            [BARBARIAN_CLASS] = true,
            [SORCERESS_CLASS] = true,
            [NECROMANCER_CLASS] = true,
            [PALADIN_CLASS] = false,
            [ASSASSIN_CLASS] = true,
            [DRUID_CLASS] = false,
            [AMAZON_CLASS] = false,
        }

        ClassRegions = { }

        for i = 1, 7 do
            if class_rects[i] then
                ClassRegions[i] = CreateRegion()
                RegionAddRect(ClassRegions[i], class_rects[i])
                if hero_state[i] then TriggerRegisterEnterRegionSimple(trg, ClassRegions[i]) end
            end
        end

        RegisterTestCommand("unlock", function()
            for i = 1, 7 do
                if class_rects[i] and not hero_state[i] then
                    TriggerRegisterEnterRegionSimple(trg, ClassRegions[i])
                end
            end
            CreateClassText(gg_rct_paladin_select, LOCALE_LIST[my_locale].PALADIN_NAME)
            CreateClassText(gg_rct_druid_select, LOCALE_LIST[my_locale].DRUID_NAME)
            CreateClassText(gg_rct_amazon_select, LOCALE_LIST[my_locale].AMAZON_NAME)
        end)


        CreateClassText(gg_rct_barbarian_select, LOCALE_LIST[my_locale].BARBARIAN_NAME)
        CreateClassText(gg_rct_sorceress_select, LOCALE_LIST[my_locale].SORCERESS_NAME)
        CreateClassText(gg_rct_necro_select, LOCALE_LIST[my_locale].NECROMANCER_NAME)
        CreateClassText(gg_rct_assassin_select, LOCALE_LIST[my_locale].ASSASSIN_NAME)


        TriggerAddAction(trg, HeroSelect)
        TriggerAddAction(LvlupTrigger, function()
            local player_id = GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1
            AddPointsToPlayer(player_id, 3)
            DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdx", PlayerHero[player_id], "origin"))
            PlayerLastRequiredEXP[player_id] = math.floor(GetLevelXP(GetHeroLevel(PlayerHero[player_id]) - 1) + 0.5)
            PlayerRequiredEXP[player_id] = math.floor(GetLevelXP(GetHeroLevel(PlayerHero[player_id])) + 0.5)
            AddTalentPointsToPlayer(player_id, 1)
        end)

        TriggerAddAction(DeathTrigger, function ()
            local hero = GetTriggerUnit()
            local player = GetOwningPlayer(hero)
            local unit_data = GetUnitData(hero)

            DisplayTextToPlayer(player, 0.,0., LOCALE_LIST[my_locale].RESSURECT_TEXT_1 .. string.format('%%.2f', R2S(7. + (Current_Wave / 4.))) .. LOCALE_LIST[my_locale].RESSURECT_TEXT_2)
            ResetUnitSpellCast(hero)
            SetUIState(GetPlayerId(player)+1, INV_PANEL, false)
            SetUIState(GetPlayerId(player)+1, SKILL_PANEL, false)
            local gold_lost = R2I(GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) * 0.2)

            if gold_lost > 1 then
                DisplayTextToPlayer(player, 0.,0., LOCALE_LIST[my_locale].GOLD_PENALTY_TEXT_1 .. R2I(gold_lost) .. LOCALE_LIST[my_locale].GOLD_PENALTY_TEXT_2)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - gold_lost)
            end


            AddSoundVolumeZ(HeroDeathSoundpack[unit_data.unit_class][GetRandomInt(1, #HeroDeathSoundpack[unit_data.unit_class])], GetUnitX(hero), GetUnitY(hero), 50., 115, 2200.)
                local timer = CreateTimer()
                TimerStart(timer, 7. + (Current_Wave / 4.), false, function()
                    ReviveHero(hero, CemetaryX, CemetaryY, true)
                    SetUnitTimeScale(hero, 1.)
                    SetUnitAnimationByIndex(hero, 0)
                    IssueImmediateOrderById(hero, order_stop)
                    SetUnitState(hero, UNIT_STATE_LIFE, GetUnitState(hero, UNIT_STATE_MAX_LIFE) * 0.5)
                    SetUnitState(hero, UNIT_STATE_MANA, GetUnitState(hero, UNIT_STATE_MAX_MANA) * 0.5)
                    DestroyTimer(GetExpiredTimer())
                    SelectUnitForPlayerSingle(hero, player)
                    for i = 1, #ActiveCurses do ApplyCurse(ActiveCurses[i]) end
                    local minions = GetAllUnitSummonUnits(hero)
                    ForGroup(minions, function() KillUnit(GetEnumUnit()) end)
                    DestroyGroup(minions)
                end)

        end)


        local DefeatTrigger = CreateTrigger()
        TriggerRegisterUnitEvent(DefeatTrigger, gg_unit_h001_0057, EVENT_UNIT_DEATH)
        TriggerAddAction(DefeatTrigger, function()
            DefeatScreen()
        end)



        RegisterTestCommand("ded", function()
            KillUnit(PlayerHero[1])
        end)

        RegisterTestCommand('vct', function()
            Current_Wave = 51
            EndWave()
        end)

        RegisterTestCommand('dft', function()
            KillUnit(gg_unit_h001_0057)
        end)

        HeroDeathSoundpack = {
            [BARBARIAN_CLASS] = { "Sound\\Barbarian\\death1.wav", "Sound\\Barbarian\\death2.wav" },
            [SORCERESS_CLASS] = { "Sound\\Sorceress\\death1.wav", "Sound\\Sorceress\\death2.wav", "Sound\\Sorceress\\death3.wav" },
            [NECROMANCER_CLASS] = { "Sound\\Necromancer\\death1.wav", "Sound\\Necromancer\\death3.wav" },
            [PALADIN_CLASS] = { "Sound\\Paladin\\death1.wav", "Sound\\Paladin\\death2.wav","Sound\\Paladin\\death3.wav" },
            [ASSASSIN_CLASS] = { "Sound\\Assassin\\death1.wav", "Sound\\Assassin\\death2.wav","Sound\\Assassin\\death3.wav" },
            [DRUID_CLASS] = { "Sound\\Druid\\death1.wav","Sound\\Druid\\death3.wav" },
            [AMAZON_CLASS] = { "Sound\\Amazon\\death1.wav","Sound\\Amazon\\death2.wav" },
        }

        HeroGroanSoundpack = {
            [BARBARIAN_CLASS] = {
                ["soft"] = { "Sound\\Barbarian\\soft1.wav", "Sound\\Barbarian\\soft4.wav", "Sound\\Barbarian\\soft5.wav" },
                ["hard"] = { "Sound\\Barbarian\\hard2.wav", "Sound\\Barbarian\\hard3.wav" }
            },
            [SORCERESS_CLASS] = {
                ["soft"] = { "Sound\\Sorceress\\soft1.wav", "Sound\\Sorceress\\soft3.wav", "Sound\\Sorceress\\soft4.wav", "Sound\\Sorceress\\soft5.wav" },
                ["hard"] = { "Sound\\Sorceress\\hard3.wav" }
            },
            [NECROMANCER_CLASS] = {
                ["soft"] = { "Sound\\BNecromancer\\soft1.wav", "Sound\\Necromancer\\soft3.wav", "Sound\\Necromancer\\soft5.wav" },
                ["hard"] = { "Sound\\Necromancer\\hard1.wav", "Sound\\Necromancer\\hard6.wav" }
            },
            [ASSASSIN_CLASS] = {
                ["soft"] = { "Sound\\BNecromancer\\gethit01.wav", "Sound\\Necromancer\\gethit12.wav", "Sound\\Necromancer\\gethit13.wav" },
                ["hard"] = { "Sound\\Necromancer\\gethit14.wav", "Sound\\Necromancer\\gethit14.wav" }
            },
        }


        HeroProperNames = {
            [BARBARIAN_CLASS] = "Ofar",
            [SORCERESS_CLASS] = "Nbrn",
            [PALADIN_CLASS] = "Hpal",
            [NECROMANCER_CLASS] = "Ulic",
            [ASSASSIN_CLASS] = "Ewar",
            [DRUID_CLASS] = "Ekee",
            [AMAZON_CLASS] = "Emoo",
        }


        CemetaryX, CemetaryY = GetRectCenterX(gg_rct_cemetary), GetRectCenterY(gg_rct_cemetary)

        RegisterTestCommand("exp", function()
            SuspendHeroXP(PlayerHero[1], false)
            AddHeroXP(PlayerHero[1], 100, false)
            SuspendHeroXP(PlayerHero[1], true)
        end)

        InitUnitTracking()

    end

end