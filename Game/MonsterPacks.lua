---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 11.05.2021 17:44
---
do

    local MonsterPack = {}
    local BossPack = {}
    QuestMonsters = nil
    local RESPAWN_TYPE_RANDOM = 1
    local RESPAWN_TYPE_SAME = 1



    local function RespawnMonsterPack(i)

        if IsAnyHeroInRange(GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 1550.) then
            TimerStart(CreateTimer(), 15., false, function()
                DestroyTimer(GetExpiredTimer())
                RespawnMonsterPack(i)
            end)
        else
            GroupClear(MonsterPack[i].group)
            DestroyGroup(MonsterPack[i].group)
            MonsterPack[i].group = SpawnMonsterPack(MonsterPack[i].spawner, MonsterPack[i].tags[GetRandomInt(1, #MonsterPack[i].tags)], MonsterPack[i].min, MonsterPack[i].max, MonsterPack[i].elite or 0, 0.)

            ForGroup(MonsterPack[i].group, function()
                TriggerRegisterUnitEvent(MonsterPack[i].death_trigger, GetEnumUnit(), EVENT_UNIT_DEATH)
            end)

            MonsterPack[i].pack_count = BlzGroupGetSize(MonsterPack[i].group)
        end

    end


    function ScaleMonsterPacks()

        for i = 1, #MonsterPack do
            if BlzGroupGetSize(MonsterPack[i].group) > 0 then
                ScaleMonsterGroup(MonsterPack[i].group)
            end
        end

        for i = 1, #BossPack do
            ScaleMonsterUnit(BossPack[i].boss)
        end

        ForGroup(QuestMonsters, function()
            if GetUnitState(GetEnumUnit(), UNIT_STATE_LIFE) <= 0.045 then GroupRemoveUnit(QuestMonsters, GetEnumUnit())
            else ScaleMonsterUnit(GetEnumUnit()) end
        end)

        end



    function InitMonsterPacks()

        --##########################################################
        --#######################SPAWNER_DATA#######################
        QuestMonsters = CreateGroup()
        MonsterPack[1] = {}
        MonsterPack[1].spawner = gg_rct_monster_pack_1_spawner
        MonsterPack[1].wander_region = {
            [1] = gg_rct_monster_pack_1_1,
            [2] = gg_rct_monster_pack_1_2,
            [3] = gg_rct_monster_pack_1_3
        }
        MonsterPack[1].tags = { [1] = MONSTERPACK_SKELETONS, [2] = MONSTERPACK_ZOMBIES }
        MonsterPack[1].respawn = 145.
        MonsterPack[1].respawn_type = RESPAWN_TYPE_RANDOM
        MonsterPack[1].min = 5; MonsterPack[1].max = 10; MonsterPack[1].elite = 2
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[2] = {}
        MonsterPack[2].spawner = gg_rct_monster_pack_2_spawner
        MonsterPack[2].wander_region = {
            [1] = gg_rct_monster_pack_2_1,
            [2] = gg_rct_monster_pack_2_2,
            [3] = gg_rct_monster_pack_2_3
        }
        MonsterPack[2].tags = { [1] = MONSTERPACK_SKELETONS, [2] = MONSTERPACK_GHOSTS, [3] = MONSTERPACK_ZOMBIES  }
        MonsterPack[2].respawn = 165.
        MonsterPack[2].min = 7; MonsterPack[2].max = 15; MonsterPack[2].elite = 3
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[3] = {}
        MonsterPack[3].spawner = gg_rct_monster_pack_3_spawner
        MonsterPack[3].wander_region = {
            [1] = gg_rct_monster_pack_3_1,
            [2] = gg_rct_monster_pack_3_2,
            [3] = gg_rct_monster_pack_3_3
        }
        MonsterPack[3].tags = { [1] = MONSTERPACK_GHOSTS }
        MonsterPack[3].respawn = 140.
        MonsterPack[3].min = 3; MonsterPack[3].max = 5
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[4] = {}
        MonsterPack[4].spawner = gg_rct_monster_pack_4_spawner
        MonsterPack[4].wander_region = {
            [1] = gg_rct_monster_pack_4_1
        }
        MonsterPack[4].tags = { [1] = MONSTERPACK_GHOSTS, [2] = MONSTERPACK_SKELETONS }
        MonsterPack[4].respawn = 140.
        MonsterPack[4].min = 3; MonsterPack[4].max = 6
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[5] = {}
        MonsterPack[5].spawner = gg_rct_monster_pack_5_spawner
        MonsterPack[5].wander_region = {
            [1] = gg_rct_monster_pack_5_1
        }
        MonsterPack[5].tags = { [1] = MONSTERPACK_GHOSTS, [2] = MONSTERPACK_SKELETONS, [3] = MONSTERPACK_DEMONS, [4] = MONSTERPACK_SUCCUBUS }
        MonsterPack[5].respawn = 165.
        MonsterPack[5].min = 7; MonsterPack[5].max = 15; MonsterPack[5].elite = 4
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[6] = {}
        MonsterPack[6].spawner = gg_rct_monster_pack_6_spawner
        MonsterPack[6].wander_region = {
            [1] = gg_rct_monster_pack_6_1,
            [2] = gg_rct_monster_pack_6_2
        }
        MonsterPack[6].tags = { [1] = MONSTERPACK_GHOSTS, [2] = MONSTERPACK_SKELETONS, [3] = MONSTERPACK_DEMONS, [4] = MONSTERPACK_SUCCUBUS }
        MonsterPack[6].respawn = 140.
        MonsterPack[6].min = 3; MonsterPack[6].max = 6; MonsterPack[6].elite = 3
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[7] = {}
        MonsterPack[7].spawner = gg_rct_monster_pack_7_spawner
        MonsterPack[7].wander_region = {
            [1] = gg_rct_monster_pack_7_1,
            [2] = gg_rct_monster_pack_7_2,
            [3] = gg_rct_monster_pack_7_3
        }
        MonsterPack[7].tags = { [1] = MONSTERPACK_GHOSTS, [2] = MONSTERPACK_SKELETONS, [3] = MONSTERPACK_DEMONS, [4] = MONSTERPACK_SUCCUBUS }
        MonsterPack[7].respawn = 140.
        MonsterPack[7].min = 5; MonsterPack[7].max = 8; MonsterPack[7].elite = 1
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[8] = {}
        MonsterPack[8].spawner = gg_rct_monster_pack_8_spawner
        MonsterPack[8].wander_region = {
            [1] = gg_rct_monster_pack_8_1,
            [2] = gg_rct_monster_pack_8_2
        }
        MonsterPack[8].tags = { [1] = MONSTERPACK_GHOSTS, [2] = MONSTERPACK_SKELETONS, [3] = MONSTERPACK_DEMONS, [4] = MONSTERPACK_SUCCUBUS }
        MonsterPack[8].respawn = 165.
        MonsterPack[8].min = 7; MonsterPack[8].max = 15; MonsterPack[8].elite = 3
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[9] = {}
        MonsterPack[9].spawner = gg_rct_monster_pack_9_spawner
        MonsterPack[9].wander_region = {
            [1] = gg_rct_monster_pack_9_1,
            [2] = gg_rct_monster_pack_9_2,
            [3] = gg_rct_monster_pack_9_3
        }
        MonsterPack[9].tags = { [1] = MONSTERPACK_GHOSTS }
        MonsterPack[9].respawn = 165.
        MonsterPack[9].min = 7; MonsterPack[9].max = 15; MonsterPack[9].elite = 2
        --##########################################################
        BossPack[1] = {
            spawner = gg_rct_arachnid_boss,
            boss_types = { MONSTER_ID_ARACHNID_BOSS },
            leash_range = 600.,
            respawn = 480.,
            respawn_type = RESPAWN_TYPE_SAME
        }
        --##########################################################
        BossPack[2] = {
            spawner = gg_rct_bandit_boss,
            boss_types = { MONSTER_ID_BANDIT_BOSS },
            leash_range = 600.,
            respawn = 480.,
            respawn_type = RESPAWN_TYPE_SAME
        }
        --##########################################################
        BossPack[3] = {
            spawner = gg_rct_spider_boss,
            boss_types = { MONSTER_ID_SPIDER_QUEEN },
            leash_range = 600.,
            respawn = 480.,
            respawn_type = RESPAWN_TYPE_SAME
        }


        for i = 1, #MonsterPack do

            MonsterPack[i].group = SpawnMonsterPack(MonsterPack[i].spawner, MonsterPack[i].tags[GetRandomInt(1, #MonsterPack[i].tags)], MonsterPack[i].min, MonsterPack[i].max, MonsterPack[i].elite or 0, 0.)
            --print("pack spawned " .. I2S(i))
            --CreateUnits_Pack(, MonsterPack[i].spawner, MonsterPack[i].amount, MonsterPack[i].group)

            TimerStart(CreateTimer(), 2.25, true, function()
                ForGroup(MonsterPack[i].group, function()
                    if Chance(12.) and GetUnitCurrentOrder(GetEnumUnit()) == 0 then
                        local rect = MonsterPack[i].wander_region[GetRandomInt(1, #MonsterPack[i].wander_region)]
                        IssuePointOrderById(GetEnumUnit(), order_attack, GetRandomRectX(rect), GetRandomRectY(rect))
                        rect = nil
                    end
                end)


                if BlzGroupGetSize(MonsterPack[i].group) < MonsterPack[i].pack_count and not IsAnyHeroInRange(GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 1550.)then
                    local respawn_chance = ((1. - (BlzGroupGetSize(MonsterPack[i].group) / MonsterPack[i].pack_count)) * 100.) * 0.15

                        if respawn_chance > 0. and Chance(respawn_chance) then
                            ForGroup(MonsterPack[1].group, function()
                                KillUnit(GetEnumUnit())
                                ShowUnit(GetEnumUnit(), false)
                            end)
                        end

                end

            end)

            --print("pack wander created")

            if MonsterPack[i].respawn ~= nil then
                MonsterPack[i].death_trigger = CreateTrigger()

                    TriggerAddAction(MonsterPack[i].death_trigger, function()
                        local alive_count = 0

                            ForGroup(MonsterPack[i].group, function()
                                if GetUnitState(GetEnumUnit(), UNIT_STATE_LIFE) > 0.045 then
                                    alive_count = alive_count + 1
                                end
                            end)

                            if alive_count == 0 or BlzGroupGetSize(MonsterPack[i].group) == 0 then
                                TimerStart(CreateTimer(), MonsterPack[i].respawn, false, function()
                                    DestroyTimer(GetExpiredTimer())
                                    RespawnMonsterPack(i)
                                end)
                            end

                    end)

                    ForGroup(MonsterPack[i].group, function()
                        TriggerRegisterUnitEvent(MonsterPack[i].death_trigger, GetEnumUnit(), EVENT_UNIT_DEATH)
                    end)

                MonsterPack[i].pack_count = BlzGroupGetSize(MonsterPack[i].group)

            end
           --print("pack initialized")
        end

        for i = 1, #BossPack do
            local x = GetRectCenterX(BossPack[i].spawner); local y = GetRectCenterY(BossPack[i].spawner)
            BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, FourCC(BossPack[i].boss_types[GetRandomInt(1, #BossPack[i].boss_types)]), x, y, GetRandomReal(0.,359.))

            TimerStart(CreateTimer(), 3.25, true, function()
                local state = GetUnitState(BossPack[i].boss, UNIT_STATE_LIFE) > 0.045

                    if state and not IsUnitInRangeXY(BossPack[i].boss, x, y, BossPack[i].leash_range) then
                        IssuePointOrderById(BossPack[i].boss, order_move, x, y)
                    elseif IsUnitInRangeXY(BossPack[i].boss, x, y, 35.) and state then
                        SetUnitState(BossPack[i].boss, UNIT_STATE_LIFE, GetUnitState(BossPack[i].boss, UNIT_STATE_MAX_LIFE))
                    end

            end)

                if BossPack[i].respawn then
                    local trg = CreateTrigger()
                    TriggerRegisterUnitEvent(trg, BossPack[i].boss, EVENT_UNIT_DEATH)
                    TriggerAddAction(trg, function()
                        local id = GetUnitTypeId(GetTriggerUnit())

                            TimerStart(CreateTimer(), BossPack[i].respawn, false, function()

                                    if BossPack[i].respawn_type == RESPAWN_TYPE_SAME then
                                        BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, id, x, y, GetRandomReal(0.,359.))
                                    else
                                        BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, FourCC(BossPack[i].boss_types[GetRandomInt(1, #BossPack[i].boss_types)]), x, y, GetRandomReal(0.,359.))
                                    end

                                TriggerRegisterUnitEvent(trg, BossPack[i].boss, EVENT_PLAYER_UNIT_DEATH)
                                DestroyTimer(GetExpiredTimer())
                                --DelayAction(0.001, function() ScaleMonsterUnit(BossPack[i].boss) end)
                            end)
                        end)
                end
        end


        RegisterTestCommand("kill a", function()
            KillUnit(BossPack[1].boss)
        end)

        RegisterTestCommand("kill b", function()
            KillUnit(BossPack[2].boss)
        end)

        RegisterTestCommand("kill s", function()
            KillUnit(BossPack[3].boss)
        end)


        RegisterTestCommand("wipe", function()
            ForGroup(MonsterPack[1].group, function()
                KillUnit(GetEnumUnit())
            end)
        end)

        RegisterTestCommand("wipe1", function()
            KillUnit(FirstOfGroup(MonsterPack[1].group))
            GroupRemoveUnit(MonsterPack[1].group, FirstOfGroup(MonsterPack[1].group))
        end)


        RegisterTestCommand("inspect", function()

            ForGroup(MonsterPack[1].group, function()
                local data = GetUnitData(GetEnumUnit())
                print("#####################")
                print(GetUnitName(GetEnumUnit()))
                for i = 1, #data.stats do
                    if data.stats[i].value > 0 then
                        print(GetParameterName(i) .. " " .. data.stats[i].value)
                    end
                end

            end)

        end)

    end

end