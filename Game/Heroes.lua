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
    local Colours
    local DashAnimationTable



    ---@param player integer
    function SwitchPlayerDashMode(player)
        PlayerDash[player].mode = PlayerDash[player].mode * -1
    end

    ---@param player integer
    function DashPlayerHero(player)
        local unit_data = GetUnitData(PlayerHero[player])

        if GetUnitState(PlayerHero[player], UNIT_STATE_LIFE) > 0.045  and not (TimerGetRemaining(PlayerDash[player].timer) > 0.) and not (IsUnitDisabled(PlayerHero[player]) or IsUnitRooted(PlayerHero[player])) then
            local angle = PlayerDash[player].mode == DASH_MODE_FACING and GetUnitFacing(PlayerHero[player]) or AngleBetweenUnitXY(PlayerHero[player], PlayerMousePosition[player].x, PlayerMousePosition[player].y)
                --and not (TimerGetRemaining(unit_data.action_timer) > 0.)

                ResetUnitSpellCast(PlayerHero[player])
                --SpellBackswing(PlayerHero[player])
                DisableHeroSkills(player)
                TimerStart(PlayerDash[player].timer, 5., false, nil)
                SetUnitFacing(PlayerHero[player], angle)
                unit_data.nudge_timer = CreateTimer()
                SetCameraQuickPositionForPlayer(Player(player-1), GetUnitX(PlayerHero[player]), GetUnitY(PlayerHero[player]))
                NudgeUnit(PlayerHero[player], angle, 300., 0.5)
                PlayerSkillQueue[player].is_casting_skill = false
                PlayerSkillQueue[player].queue_skill = nil
                unit_data.dashing = true

                SetUnitAnimationByIndex(PlayerHero[player], DashAnimationTable[unit_data.unit_class])
                ModifyStat(PlayerHero[player], CONTROL_REDUCTION, 1000, STRAIGHT_BONUS, true)
                SetUnitTimeScale(PlayerHero[player], 1. / 0.5)

                TimerStart(CreateTimer(), 0.4, false, function()
                    SetUnitTimeScale(PlayerHero[player], 1.)
                    ModifyStat(PlayerHero[player], CONTROL_REDUCTION, 1000, STRAIGHT_BONUS, false)
                    EnableHeroSkills(player)
                    DestroyTimer(GetExpiredTimer())
                    unit_data.dashing = false
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
            AddSoundVolume(HeroGroanSoundpack[target.unit_class]["soft"][GetRandomInt(1, #HeroGroanSoundpack[target.unit_class]["soft"])], GetUnitX(target.Owner), GetUnitY(target.Owner), 123, 1400., 4000.)
        else
            AddSoundVolume(HeroGroanSoundpack[target.unit_class]["hard"][GetRandomInt(1, #HeroGroanSoundpack[target.unit_class]["hard"])], GetUnitX(target.Owner), GetUnitY(target.Owner), 123, 1400., 4000.)
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
                AddHeroXP(PlayerHero[player], math.ceil(amount * (1. + GetUnitParameterValue(PlayerHero[player], EXP_BONUS) * 0.01)), false)
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
                AddHeroXP(PlayerHero[i], math.ceil(amount * (1. + GetUnitParameterValue(PlayerHero[i], EXP_BONUS) * 0.01)), false)
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
                SetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(player-1), PLAYER_STATE_RESOURCE_GOLD) + math.floor(amount))
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
                SetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(i-1), PLAYER_STATE_RESOURCE_GOLD) + math.floor(amount))
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


    function CloneHero(unit, id, x, y, angle, time, death_sfx_path)
        local illusion = CreateUnit(GetOwningPlayer(unit), FourCC("srci"), x, y, angle)
        local hair_sfx = nil
        local weapon_sfx
        local offhand_sfx

            UnitApplyTimedLife(illusion, 0, time)

            if GetUnitClass(unit) == SORCERESS_CLASS then
                hair_sfx = AddSpecialEffectTarget("Model\\Sorceress_Hair.mdx", illusion, "head")
            end

            DelayAction(0., function()
                local unit_data = GetUnitData(unit)
                local illusion_data = GetUnitData(illusion)

                for i = 1, #illusion_data.stats do illusion_data.stats[i].value = unit_data.stats[i].value end
                UpdateParameters(illusion_data)

                if GetUnitClass(unit) == ASSASSIN_CLASS then
                    SetTexture(illusion, unit_data.equip_point[CHEST_POINT] and unit_data.equip_point[CHEST_POINT].assassin_texture or TEXTURE_ID_ASSASSIN_BASE)
                else
                    SetTexture(illusion, unit_data.equip_point[CHEST_POINT] and unit_data.equip_point[CHEST_POINT].texture or TEXTURE_ID_EMPTY)
                end

                weapon_sfx = AddSpecialEffectTarget(unit_data.equip_point[WEAPON_POINT].model or "", illusion, "hand right")
                offhand_sfx = AddSpecialEffectTarget(unit_data.equip_point[OFFHAND_POINT] and unit_data.equip_point[OFFHAND_POINT].model or "", illusion, "hand left")
            end)

            local timer = CreateTimer()
            local trg = CreateTrigger()
                TriggerRegisterUnitEvent(trg, illusion, EVENT_UNIT_DEATH)
                TriggerAddAction(trg, function()
                    AddSpecialEffect(death_sfx_path or "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdx", GetUnitX(illusion), GetUnitY(illusion))
                    ShowUnit(illusion, false)
                    DestroyEffect(weapon_sfx)
                    if hair_sfx then DestroyEffect(hair_sfx) end
                    DestroyEffect(offhand_sfx)
                    DestroyTrigger(trg)
                    DestroyTimer(timer)
                end)

    end


    function HeroSelect()
        local region = GetTriggeringRegion()
        local id
        local player_id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        local starting_items = {}
        local starting_skills = {}
        local icon

            ActivePlayers = ActivePlayers + 1
            if region == ClassRegions[BARBARIAN_CLASS] then
                id = FourCC("HBRB")
                starting_items[1] = CreateCustomItem("I011", 0., 0.)
                starting_items[2] = CreateCustomItem("I00X", 0., 0.)
                starting_items[3] = CreateCustomItem("I010", 0., 0.)
                starting_items[4] = CreateCustomItem("I00Z", 0., 0.)
                starting_items[5] = CreateCustomItem("I00Y", 0., 0.)
                starting_skills[1] = 'A007'
                starting_skills[2] = 'ABWC'
                starting_skills[3] = 'A00Z'
                icon = "ReplaceableTextures\\CommandButtons\\BTNBandit.blp"
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
                icon = "war3mapImported\\BTNSorceress.blp"
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
                icon = "ReplaceableTextures\\CommandButtons\\BTNLichVersion2.blp"
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
                --starting_items[6] = CreateCustomItem("I046", 0., 0.)


                starting_skills[1] = "AACS"
                starting_skills[2] = "AABD"
                starting_skills[3] = "AAPS"

                --[[
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

                starting_skills[13] = "AAST"
                starting_skills[14] = "AACB"
                starting_skills[15] = "AADB"
                starting_skills[16] = "AAIG"
                starting_skills[17] = "AACT"
                starting_skills[18] = "AASC"
                starting_skills[19] = "AABT"
                starting_skills[20] = "AASB"

                starting_skills[22] = "AAEX"
                starting_skills[23] = "AACA"
                starting_skills[24] = "AACR"
                starting_skills[25] = "AASR"
                starting_skills[26] = "AASF"
                starting_skills[27] = "AACO"
                starting_skills[28] = "AAMH"
                starting_skills[29] = "AAPA"]]
                icon = "ReplaceableTextures\\CommandButtons\\BTNAssassin.blp"
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

                local sprint_timer = CreateTimer()
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
                    elseif unit_data.unit_class == ASSASSIN_CLASS then ModifyStat(hero, VULNERABILITY, -15, STRAIGHT_BONUS, true); AddSpecialEffectTarget("Units\\Hero\\Appearance\\SlayerHead.mdx", hero, "head")
                    elseif unit_data.unit_class == SORCERESS_CLASS then AddSpecialEffectTarget("Units\\Hero\\Appearance\\Sorceress_Hair.mdx", hero, "head") end

                    local glow = AddSpecialEffectTarget(Colours[player_id], hero, "origin")--Colours
                    unit_data.sprint_timer = sprint_timer
                end)

                SetCameraBoundsToRectForPlayerBJ(Player(player_id), bj_mapInitialCameraBounds)

                local player_number = player_id
                player_id = player_id + 1
                PlayerHero[player_id] = hero
                local last_damages = {}
                local last_damages_timer = {}
                for i = 1, 6 do
                    last_damages[i] = 0
                    last_damages_timer[i] = CreateTimer()
                end


                    TriggerRegisterDeathEvent(DeathTrigger, hero)
                    TriggerRegisterUnitEvent(LvlupTrigger, hero, EVENT_UNIT_HERO_LEVEL)
                    TriggerRegisterUnitEvent(OrderInterceptionTrigger, hero, EVENT_UNIT_ATTACKED)
                    local damage_trigger = CreateTrigger()
                    local hp_state_trigger = CreateTrigger()


                    TimerStart(sprint_timer, 10., false, function()
                        ApplyBuff(hero, hero, "A02Z", 1)
                    end)

                    TriggerRegisterUnitEvent(damage_trigger, hero, EVENT_UNIT_DAMAGED)
                    TriggerAddAction(damage_trigger, function()
                        local damage = GetEventDamage()

                            if damage > 0 then
                                local hero_data = GetUnitData(hero)

                                RemoveBuff(hero, "A02Z")
                                TimerStart(sprint_timer, 10., false, function()
                                    ApplyBuff(hero, hero, "A02Z", 1)
                                end)

                                if not hero_data.groan_cd then
                                    if Chance(12.) then
                                        PlayGroanSound(hero, (damage / BlzGetUnitMaxHP(hero) > 0.1))
                                    end
                                end

                                if (GetUnitState(hero, UNIT_STATE_LIFE) - GetEventDamage()) / BlzGetUnitMaxHP(hero) < 0.2 then
                                    if not HpFeedbackCooldown[player_id] then
                                        Feedback_Health(player_id)
                                        HpFeedbackCooldown[player_id] = true
                                        DelayAction(14., function() HpFeedbackCooldown[player_id] = false end)
                                    end

                                    if GetLocalPlayer() == Player(player_number) then
                                        SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp")
                                        SetCineFilterBlendMode(BLEND_MODE_ADDITIVE)
                                        SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                                        SetCineFilterStartUV(0, 0, 1, 1)
                                        SetCineFilterEndUV(0, 0, 1, 1)
                                        SetCineFilterStartColor(255, 75, 75, 0)
                                        SetCineFilterEndColor(255, 75, 75, 100)
                                        DisplayCineFilter(true)
                                        SetCineFilterDuration(0.75)
                                    end

                                    EnableTrigger(hp_state_trigger)
                                    DisableTrigger(damage_trigger)
                                elseif damage > last_damages[player_id] * 2. then
                                    last_damages[player_id] = damage

                                    local alpha = math.floor(80 * (damage / (BlzGetUnitMaxHP(hero) * 0.15)))
                                    if alpha > 150 then alpha = 150 end


                                    if GetLocalPlayer() == Player(player_number) then
                                        SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp")
                                        SetCineFilterBlendMode(BLEND_MODE_ADDITIVE)
                                        SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
                                        SetCineFilterStartUV(0, 0, 1, 1)
                                        SetCineFilterEndUV(0, 0, 1, 1)
                                        SetCineFilterStartColor(255, 35, 35, alpha)
                                        SetCineFilterEndColor(255, 35, 35, 0)
                                        SetCineFilterDuration(0.33)
                                        DisplayCineFilter(true)
                                    end

                                    TimerStart(last_damages_timer[player_id], 0.57, false, function()
                                        last_damages[player_id] = 0
                                    end)
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


                    local order_trigger = CreateTrigger()
                    local last_order_point = nil
                    TriggerRegisterUnitEvent(order_trigger, hero, EVENT_UNIT_ISSUED_POINT_ORDER)
                    TriggerRegisterUnitEvent(order_trigger, hero, EVENT_UNIT_ISSUED_ORDER)
                    TriggerRegisterUnitEvent(order_trigger, hero, EVENT_UNIT_ISSUED_TARGET_ORDER)
                    TriggerAddAction(order_trigger, function()
                        local order = GetIssuedOrderId()

                            if order == order_smart then
                                if GetOrderTarget() then last_order_point = { widget = GetOrderTarget() }
                                else last_order_point = { x = GetOrderPointX(), y = GetOrderPointY() } end
                            elseif IsItemOrder(order) then
                                DelayAction(0., function()
                                   if last_order_point then
                                       if last_order_point.widget then IssueTargetOrderById(hero, order_smart, last_order_point.widget)
                                       else IssuePointOrderById(hero, order_smart, last_order_point.x, last_order_point.y) end
                                    end
                                end)
                            else
                                last_order_point = nil
                            end

                    end)


                    CreateGUILayoutForPlayer(player_id, hero)
                    LockCameraForPlayer(player_id)
                    RegisterItemPickUp(PlayerHero[player_id])

                    local timer = CreateTimer()
                    TimerStart(timer, 1.5, false, function()
                        local pid = player_id

                            for i = 1, #starting_items do
                                --AddToInventory(player_id, starting_items[i])
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

                        if GetUnitClass(hero) == ASSASSIN_CLASS then
                            AddToInventory(pid, CreateCustomItem("I046", 0, 0, false))
                        end

                        AddToInventory(pid, CreateCustomItem(ITEM_SCROLL_OF_TOWN_PORTAL, 0.,0., false))

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

                AddToHeroPool(player_id, icon)

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

        RegisterTestCommand("invul", function()
            UnitAddAbility(PlayerHero[1], FourCC("Avul"))
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

            DestroyEffect(AddSpecialEffect("Effect\\BloodExplosionEx.mdx", GetUnitX(hero), GetUnitY(hero)))
            DisplayTextToPlayer(player, 0.,0., LOCALE_LIST[my_locale].RESSURECT_TEXT_1 .. string.format('%%.2f', R2S(8. + (Current_Wave / 5.))) .. LOCALE_LIST[my_locale].RESSURECT_TEXT_2)
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
            TimerStart(timer, 8. + (Current_Wave / 5.), false, function()
                local unit_data = GetUnitData(hero)
                ReviveHero(hero, CemetaryX, CemetaryY, true)
                SetUnitTimeScale(hero, 1.)
                SetUnitAnimation(hero, "Birth")
                IssueImmediateOrderById(hero, order_stop)
                SetUnitState(hero, UNIT_STATE_LIFE, GetUnitState(hero, UNIT_STATE_MAX_LIFE) * 0.5)
                SetUnitState(hero, UNIT_STATE_MANA, GetUnitState(hero, UNIT_STATE_MAX_MANA) * 0.5)
                DestroyTimer(GetExpiredTimer())
                SelectUnitForPlayerSingle(hero, player)
                for i = 1, #ActiveCurses do ApplyCurse(ActiveCurses[i]) end
                local minions = GetAllUnitSummonUnits(hero)
                ForGroup(minions, function() KillUnit(GetEnumUnit()) end)
                DestroyGroup(minions)
                OnHeroRevive(hero)
                TimerStart(unit_data.sprint_timer, 10., false, function()
                    ApplyBuff(hero, hero, "A02Z", 1)
                end)
                PlayerSkillQueue[GetPlayerId(player)+1].queue_skill = nil
                PlayerSkillQueue[GetPlayerId(player)+1].is_casting_skill = false
                PlayerCanChangeEquipment[GetPlayerId(player)+1] = true
            end)

        end)


        local DefeatTrigger = CreateTrigger()
        TriggerRegisterUnitEvent(DefeatTrigger, gg_unit_h001_0057, EVENT_UNIT_DEATH)
        TriggerAddAction(DefeatTrigger, function()
            DefeatScreen()
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
                ["soft"] = { "Sound\\Necromancer\\soft1.wav", "Sound\\Necromancer\\soft3.wav", "Sound\\Necromancer\\soft5.wav" },
                ["hard"] = { "Sound\\Necromancer\\hard1.wav", "Sound\\Necromancer\\hard6.wav" }
            },
            [ASSASSIN_CLASS] = {
                ["soft"] = { "Sound\\Assassin\\gethit01.wav", "Sound\\Assassin\\gethit12.wav", "Sound\\Assassin\\gethit13.wav" },
                ["hard"] = { "Sound\\Assassin\\gethit14.wav", "Sound\\Assassin\\gethit16.wav" }
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

        Colours = {
            [1] = "Units\\Hero\\HeroGlow_Red.mdx",
            [2] = "Units\\Hero\\HeroGlow_Blue.mdx",
            [3] = "Units\\Hero\\HeroGlow_Teal.mdx",
            [4] = "Units\\Hero\\HeroGlow_Purple.mdx",
            [5] = "Units\\Hero\\HeroGlow_Yellow.mdx",
            [6] = "Units\\Hero\\HeroGlow_Orange.mdx",
        }

        DashAnimationTable = {
            [BARBARIAN_CLASS] = 44,
            [SORCERESS_CLASS] = 8,
            [NECROMANCER_CLASS] = 37,
            [ASSASSIN_CLASS] = 28,
        }

        CemetaryX, CemetaryY = GetRectCenterX(gg_rct_cemetary), GetRectCenterY(gg_rct_cemetary)


        InitUnitTracking()
        InitAlliedHeroesBar()

    end

end