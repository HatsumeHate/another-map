---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 30.08.2021 15:07
---
do

    local RiftTimer
    local RIFT_MIN_TIME = 180
    local RIFT_MAX_TIME = 560
    local RiftData
    local DeathTrigger
    ActiveRift = nil


    function RiftMonstersWander()

        for index = BlzGroupGetSize(ActiveRift.group) - 1, 0, -1 do
            local picked = BlzGroupUnitAt(ActiveRift.group, index)
            local current_order = GetUnitCurrentOrder(picked)

            if current_order == 0 and Chance(12.) then
                local rect = ActiveRift.wander_region[GetRandomInt(1, #ActiveRift.wander_region)]
                IssuePointOrderById(picked, order_attack, GetRandomRectX(rect), GetRandomRectY(rect))
                rect = nil
            elseif current_order == order_attack and not IsUnitInRangeXY(picked, GetRectCenterX(ActiveRift.spawner), GetRectCenterY(ActiveRift.spawner), 3300.) then
                IssuePointOrderById(picked, order_move, GetRectCenterX(ActiveRift.spawner), GetRectCenterY(ActiveRift.spawner))
            end

        end

        if not ActiveRift.group or BlzGroupGetSize(ActiveRift.group) <= 0 then
            DestroyTimer(GetExpiredTimer())
        end

    end


    function SpawnRift()
        local rift = RiftData[GetRandomInt(1, #RiftData)]
        local boss_id
        local pack_tag = GetRandomInt(1, #MONSTER_LIST-1)

            PingMinimap(GetRectCenterX(rift.spawner), GetRectCenterY(rift.spawner), 5.)
            ShowQuestAlert(LOCALE_LIST[my_locale].RIFT_FORMED_MSG)


            if MONSTER_LIST[pack_tag][MONSTER_RANK_BOSS] then boss_id = FourCC(MONSTER_LIST[pack_tag][MONSTERPACK_BOSS][GetRandomInt(1, #MONSTER_LIST[pack_tag][MONSTERPACK_BOSS])])
            else boss_id = FourCC(MONSTER_LIST[MONSTERPACK_BOSS][GetRandomInt(1, #MONSTER_LIST[MONSTERPACK_BOSS])]) end

            rift.boss = CreateUnit(MONSTER_PLAYER, boss_id, GetRectCenterX(rift.spawner), GetRectCenterY(rift.spawner), 270.)

                if rift.use_pack then
                    local pack = MonsterPack[rift.use_pack]

                    if BlzGroupGetSize(pack.group) < pack.pack_count then
                        ForGroup(pack.group, function() KillUnit(GetEnumUnit()); ShowUnit(GetEnumUnit(), false) end)
                        pack.group = SpawnMonsterPack(rift.spawner, pack_tag, pack.min, pack.max, pack.elite or 0, 0.)
                        ForGroup(pack.group, function() TriggerRegisterUnitEvent(pack.death_trigger, GetEnumUnit(), EVENT_UNIT_DEATH) end)
                        pack.pack_count = BlzGroupGetSize(pack.group)
                    end

                    rift.group = CopyGroup(pack.group)
                else
                    if rift.group and BlzGroupGetSize(rift.group) > 0 then ForGroup(rift.group, function() KillUnit(GetEnumUnit()); ShowUnit(GetEnumUnit(), false) end); DestroyGroup(rift.group) end
                    rift.group = SpawnMonsterPack(rift.spawner, pack_tag, rift.min, rift.max, rift.elite or 0, 0., MONSTER_PLAYER)
                    local timer = CreateTimer()
                    TimerStart(timer, 2.25, true, RiftMonstersWander)
                end

            DelayAction(0., function()
                local pos = RemoveDropList(rift.boss, "shard")
                AddDropList(rift.boss, "shard_event", 100., pos)
            end)

            CreateLeashForUnit(rift.boss, 1450.)
            GroupAddUnit(rift.group, rift.boss)

            rift.minimap_icon = CreateMinimapIcon(GetRectCenterX(rift.spawner), GetRectCenterY(rift.spawner), 255, 255, 255, "Marker\\MarkDemonGate.mdx", FOG_OF_WAR_MASKED)
            rift.sfx = AddSpecialEffect("Effect\\Effect_RiftRed.mdx", GetRectCenterX(rift.spawner), GetRectCenterY(rift.spawner))
            BlzSetSpecialEffectScale(rift.sfx, 2.5)
            BlzSetSpecialEffectZ(rift.sfx, GetZ(GetRectCenterX(rift.spawner), GetRectCenterY(rift.spawner)) + 50.)

            for index = BlzGroupGetSize(rift.group) - 1, 0, -1 do
                TriggerRegisterUnitEvent(DeathTrigger, BlzGroupUnitAt(rift.group, index), EVENT_UNIT_DEATH)
            end

            ActiveRift = rift
    end


    function InitRifts()

        RiftData = {}

        --##########################################################
        RiftData[1] = {
            spawner = gg_rct_rift_loc_1,
            wander_region = { gg_rct_rift_wander_1_1, gg_rct_rift_wander_1_2 },
            min = 4, max = 7, elite = 2
        }
        --##########################################################
        RiftData[2] = {
            spawner = gg_rct_rift_loc_2,
            wander_region = { gg_rct_rift_wander_2_1, gg_rct_rift_wander_2_2, gg_rct_rift_wander_2_3, gg_rct_rift_wander_2_4 },
            min = 4, max = 7, elite = 2
        }
        --##########################################################
        RiftData[3] = {
            spawner = gg_rct_rift_loc_3,
            use_pack = 2,
        }
        --##########################################################
        RiftData[4] = {
            spawner = gg_rct_rift_loc_4,
            wander_region = { gg_rct_rift_wander_4_1, gg_rct_rift_wander_4_2 },
            min = 5, max = 8, elite = 2
        }
        --##########################################################
        RiftData[5] = {
            spawner = gg_rct_rift_loc_5,
            wander_region = { gg_rct_rift_wander_5_1, gg_rct_rift_wander_5_2 },
            min = 5, max = 9, elite = 3
        }
        --##########################################################
        RiftData[6] = {
            spawner = gg_rct_rift_loc_6,
            use_pack = 15,
        }
        --##########################################################
        RiftData[7] = {
            spawner = gg_rct_rift_loc_7,
            wander_region = { gg_rct_rift_wander_7_1 },
            min = 5, max = 9, elite = 3,
        }
        --##########################################################
        RiftData[8] = {
            spawner = gg_rct_rift_loc_8,
            wander_region = { gg_rct_rift_wander_8_1 },
            min = 5, max = 9, elite = 3,
        }
        --##########################################################
        RiftData[9] = {
            spawner = gg_rct_rift_loc_9,
            use_pack = 17,
        }
        --##########################################################
        RiftData[10] = {
            spawner = gg_rct_rift_loc_10,
            use_pack = 5,
        }
        --##########################################################
        RiftData[11] = {
            spawner = gg_rct_rift_loc_11,
            use_pack = 6,
        }
        --##########################################################
        RiftData[12] = {
            spawner = gg_rct_rift_loc_12,
            wander_region = { gg_rct_rift_wander_12_1 },
            min = 6, max = 10, elite = 3,
        }
        --##########################################################


        for i = 1, #RiftData do
            if RiftData[i].use_pack then
                RiftData[i].wander_region = MergeTables({}, MonsterPack[RiftData[i].use_pack].wander_region)
            end
        end

        DeathTrigger = CreateTrigger()
        RiftTimer = CreateTimer()

        TimerStart(RiftTimer, I2R(GetRandomInt(RIFT_MIN_TIME, RIFT_MAX_TIME)), false, SpawnRift)


        TriggerAddAction(DeathTrigger, function()
            local unit = GetTriggerUnit()

            GroupRemoveUnit(ActiveRift.group, unit)
            if BlzGroupGetSize(ActiveRift.group) <= 0 then DestroyGroup(ActiveRift.group); ActiveRift.group = nil end

            if unit == ActiveRift.boss then
                DestroyMinimapIcon(ActiveRift.minimap_icon)
                ShowQuestAlert(LOCALE_LIST[my_locale].RIFT_CLOSED_MSG)
                DestroyEffect(ActiveRift.sfx)

                    if BlzGroupGetSize(ActiveRift.group) > 0 then
                        local group = CopyGroup(ActiveRift.group)
                        local timer = CreateTimer()
                        local wander_rects = MergeTables({}, ActiveRift.wander_region)
                        local center_x, center_y = GetRectCenterX(ActiveRift.spawner), GetRectCenterY(ActiveRift.spawner)

                            TimerStart(timer, 1., true, function()

                                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(group, index)
                                    local current_order = GetUnitCurrentOrder(picked)

                                        if GetUnitState(picked, UNIT_STATE_LIFE) <= 0.045 then
                                            GroupRemoveUnit(group, picked)
                                        elseif current_order == 0 and Chance(12.) then
                                            local rect = wander_rects[GetRandomInt(1, #wander_rects)]
                                            IssuePointOrderById(picked, order_attack, GetRandomRectX(rect), GetRandomRectY(rect))
                                            rect = nil
                                        elseif current_order == order_attack and not IsUnitInRangeXY(picked, center_x, center_y, 3300.) then
                                            IssuePointOrderById(picked, order_move, center_x, center_y)
                                        end

                                end

                                if BlzGroupGetSize(group) <= 0 then
                                    DestroyTimer(timer)
                                end
                            end)

                    end

                GroupClear(ActiveRift.group)
                DestroyGroup(ActiveRift.group)
                ActiveRift.group = nil
                TimerStart(RiftTimer, GetRandomInt(RIFT_MIN_TIME, RIFT_MAX_TIME), false, SpawnRift)
            end

        end)


    end

end