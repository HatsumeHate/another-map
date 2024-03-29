---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 16.09.2021 2:43
---
do

    local CurseData
    ActiveCurses = nil
    MAX_CURSES = 2
    CURRENT_CURSES = 0
    local CurseTimer
    local CURSE_MIN_TIME = 1500; local CURSE_MAX_TIME = 2360
    local curse_totems


    ---@return rect
    local function GetFreeLocation()
        local shuffle = GetRandomIntTable(1, #CurseData.locations, #CurseData.locations)

            for i = 1, #CurseData.locations do
                if not CurseData.locations[shuffle[i]].claimed then
                    CurseData.locations[shuffle[i]].claimed = true
                    return CurseData.locations[shuffle[i]].rect
                end
            end

        return nil
    end

    local function RemoveLocationClaim(rect)

        for i = 1, #CurseData.locations do
            if not CurseData.locations[i].rect == rect then
                CurseData.locations[i].claimed = false
                break
            end
        end

    end



    ---@return table
    local function GetFreeCurse()
        local shuffle = GetRandomIntTable(1, #CurseData.curses, #CurseData.curses)

            for i = 1, #CurseData.curses do
                if not CurseData.curses[shuffle[i]].active then
                    CurseData.curses[shuffle[i]].active = true
                    return CurseData.curses[shuffle[i]]
                end
            end

        return nil
    end


    function RemoveCurse(curse_id)
        for i = 1, 6 do
            if PlayerHero[i] then
                RemoveBuff(PlayerHero[i], curse_id)
            end
        end
    end

    function ApplyCurse(curse_id)
        for i = 1, 6 do
            if PlayerHero[i] then
                ApplyBuff(PlayerHero[i], PlayerHero[i], curse_id, 1)
            end
        end
    end


    function SpawnCurse()

        if CURRENT_CURSES < MAX_CURSES then
            local rect = GetFreeLocation()
            local curse = GetFreeCurse()

            if not rect or not curse then return end
            local x, y = GetRectCenterX(rect), GetRectCenterY(rect)

            ApplyCurse(curse.curse_id)
            ActiveCurses[#ActiveCurses+1] = curse.curse_id
            local curse_totem = CreateUnit(MONSTER_PLAYER, CurseData.totems[1], x, y, 270.)
            curse_totems[#curse_totems+1] = curse_totem
            BlzSetUnitSkin(curse_totem, CurseData.totems[GetRandomInt(1, #CurseData.totems)])
            local guard_group = CreateGroup()
            local timer = CreateTimer()
            local last_pack_count = 1
            local safe_time = 2.
            local bonus_chance = 80.

            PingMinimap(x, y, 5.)
            ShowQuestAlert(GetLocalString("Вы были прокляты ", "You have been cursed by ") .. "|c00FF1818" .. curse.name .. "|r" .. ": " .. curse.desc)

            local minimap_icon = CreateMinimapIcon(x, y, 255, 255, 255, "Marker\\MarkCurse.mdx", FOG_OF_WAR_MASKED)
            local death_trigger = CreateTrigger()
            TriggerAddAction(death_trigger, function()
                GroupRemoveUnit(guard_group, GetTriggerUnit())
            end)


            TimerStart(timer, 1.25, true, function()
                local state = GetUnitState(curse_totem, UNIT_STATE_LIFE) > 0.045

                    if state then
                        local group_size = BlzGroupGetSize(guard_group)

                        if group_size > 0 then
                            ForGroup(guard_group, function()
                                if not IsUnitInRange(GetEnumUnit(), x, y, 1100.) then
                                    IssuePointOrderById(GetEnumUnit(), order_move, x + GetRandomReal(-300., 300.), y + GetRandomReal(-300., 300.))
                                end
                            end)
                        end

                        if group_size <= math.floor(last_pack_count * 0.35 + 0.5) then
                            safe_time = safe_time - 1.25
                        end


                        if IsAnyHeroInRange(x, y, 1100.) then
                            if safe_time <= 0. then bonus_chance = bonus_chance + 2. end

                            local respawn_chance = ((1. - (group_size / last_pack_count)) * 100.) * 0.04 + bonus_chance
                            if respawn_chance > 90. then respawn_chance = 90. end

                            --print(respawn_chance)
                            if safe_time <= 0. and respawn_chance > 0. and Chance(respawn_chance) then
                                local new_group = CreateGroup()
                                SpawnClearMonsterPack(rect, new_group, GetRandomMonsterTag(), 3, 5, 1, 15., MONSTER_PLAYER)

                                    ForGroup(new_group, function()
                                        local spawn_angle = GetRandomReal(0., 359.)
                                        local spawn_range = GetMaxAvailableDistance(x, y, spawn_angle, GetRandomReal(100., 600.))
                                        local spawned = GetEnumUnit()
                                        local new_x = x + Rx(spawn_range, spawn_angle); local new_y = y + Ry(spawn_range, spawn_angle)
                                        local sfx = AddSpecialEffect("Effect\\Void Teleport Red To.mdx", new_x, new_y)

                                        BlzSetSpecialEffectScale(sfx, 0.7)

                                            SetUnitX(spawned, new_x)
                                            SetUnitY(spawned, new_y)

                                            SafePauseUnit(spawned, true)
                                            UnitAddAbility(spawned, FourCC("Avul"))
                                            ShowUnit(spawned, false)

                                            DelayAction(GetRandomReal(3., 5.), function()
                                                if GetUnitState(curse_totem, UNIT_STATE_LIFE) > 0.045 then
                                                    --CreateBarOnUnit(spawned)
                                                    TriggerRegisterUnitEvent(death_trigger, spawned, EVENT_UNIT_DEATH)
                                                    local unit_data = GetUnitData(spawned)
                                                    unit_data.xp = math.floor(unit_data.xp / 4.)
                                                    unit_data.classification = 0
                                                    unit_data.droplist = nil
                                                    SafePauseUnit(spawned, false)
                                                    UnitRemoveAbility(spawned, FourCC("Avul"))
                                                    ShowUnit(spawned, true)
                                                    GroupAddUnit(guard_group, spawned)
                                                    last_pack_count = BlzGroupGetSize(guard_group)
                                                    local teleport_sfx = AddSpecialEffect("Effect\\Void Teleport Red Caster.mdx", new_x, new_y)
                                                    BlzSetSpecialEffectScale(teleport_sfx, 0.7)
                                                    DestroyEffect(teleport_sfx)
                                                else
                                                    KillUnit(spawned)
                                                end
                                                DestroyEffect(sfx)
                                            end)

                                    end)

                                bonus_chance = 0.
                                safe_time = 25. + Current_Wave
                                DestroyGroup(new_group)
                            end

                        else
                            bonus_chance = 80.
                            safe_time = 2.
                            SetUnitState(curse_totem, UNIT_STATE_LIFE, BlzGetUnitMaxHP(curse_totem))
                        end
                    else
                        ShowQuestAlert(GetLocalString("Проклятие ", "The curse ") .. "|c00FF1818" .. curse.name .. "|r" .. GetLocalString(" было снято!", " was removed!"))
                        RemoveCurse(curse.curse_id)
                        for i = 1, #ActiveCurses do
                            if ActiveCurses[i] == curse.curse_id then
                                table.remove(ActiveCurses, i)
                                break
                            end
                        end
                        RemoveLocationClaim(rect)
                        curse.active = false
                        DestroyMinimapIcon(minimap_icon)
                        DestroyTimer(timer)
                        ForGroup(guard_group, function() KillUnit(GetEnumUnit()) end)
                        DestroyGroup(guard_group)
                        if CURRENT_CURSES == MAX_CURSES then TimerStart(CurseTimer, I2R(GetRandomInt(CURSE_MIN_TIME, CURSE_MAX_TIME)), true, SpawnCurse) end
                        CURRENT_CURSES = CURRENT_CURSES - 1
                    end

            end)



            CURRENT_CURSES = CURRENT_CURSES + 1
            if CURRENT_CURSES == MAX_CURSES then TimerStart(CurseTimer, 0., false, nil) end
        end

    end


    function InitCurses()
        curse_totems = {}
        ActiveCurses = {}
        CurseData = {
            locations = {
                { rect = gg_rct_curse_1 }, { rect = gg_rct_curse_2 }, { rect = gg_rct_curse_3 }, { rect = gg_rct_curse_4 }, { rect = gg_rct_curse_5 },
                { rect = gg_rct_curse_6 }, { rect = gg_rct_curse_7 }, { rect = gg_rct_curse_8 }, { rect = gg_rct_curse_9 }, { rect = gg_rct_curse_10 }, { rect = gg_rct_curse_11 }
            },
            curses = {
                { curse_id = "ACWK", name = GetLocalString("Слабостью", "Weakness"), desc = GetLocalString("Весь ваш урон уменьшен.", "All your damage has been reduced.") },
                { curse_id = "ACIN", name = GetLocalString("Нерешительностью", "Indecisiveness"), desc = GetLocalString("Крит шанс и крит урон уменьшены.", "Crit chance and crit damage has been reduced.") },
                { curse_id = "ACVN", name = GetLocalString("Уязвимостью", "Vulnerability"), desc = GetLocalString("Сопротивление стихиям уменьшено.", "Resistance to all elements has been reduced.") },
                { curse_id = "ACWT", name = GetLocalString("Увяданием", "Withering"), desc = GetLocalString("Восстановление здоровья и маны уменьшено.", "Health and mana regeneration has been reduced.") }
            },
            totems = { FourCC("o000"), FourCC("o001"), FourCC("o002"), FourCC("o003"), FourCC("o004") }
        }


        CurseTimer = CreateTimer()
        TimerStart(CurseTimer, I2R(GetRandomInt(CURSE_MIN_TIME, CURSE_MAX_TIME)), true, SpawnCurse)


    end


end