---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 11.05.2021 17:44
---
do

    MonsterPack = 0
    BossPack = 0
    ScaleMonstersGroup = 0
    local RESPAWN_TYPE_RANDOM = 1
    local RESPAWN_TYPE_SAME = 1
    local BASE_SPAWN_TIME = 30.



    local function RespawnMonsterPack(i)

        if IsAnyHeroInRange(GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 1550.) then
            local timer = CreateTimer()
            TimerStart(timer, 15., false, function()
                DestroyTimer(GetExpiredTimer())
                RespawnMonsterPack(i)
            end)
        else
            MonsterPack[i].respawn_executed = nil
            GroupClear(MonsterPack[i].group)
            DestroyGroup(MonsterPack[i].group)
            MonsterPack[i].group = SpawnMonsterPack(MonsterPack[i].spawner, MonsterPack[i].tags[GetRandomInt(1, #MonsterPack[i].tags)], MonsterPack[i].min, MonsterPack[i].max, MonsterPack[i].elite or 0, 0.)

            ForGroup(MonsterPack[i].group, function()
                TriggerRegisterUnitEvent(MonsterPack[i].death_trigger, GetEnumUnit(), EVENT_UNIT_DEATH)
            end)

            MonsterPack[i].pack_count = BlzGroupGetSize(MonsterPack[i].group)
            --print("respawn")
        end

    end


    function ScaleMonsterPacks()

        --QuestMonsters

        ForGroup(ScaleMonstersGroup, function()
            if GetUnitState(GetEnumUnit(), UNIT_STATE_LIFE) <= 0.045 then GroupRemoveUnit(ScaleMonstersGroup, GetEnumUnit())
            else ScaleMonsterUnit(GetEnumUnit(), Current_Wave) end
        end)

        --[[
        for i = 1, #MonsterPack do
            if BlzGroupGetSize(MonsterPack[i].group) > 0 then
                ScaleMonsterGroup(MonsterPack[i].group, Current_Wave)
            end
        end

        for i = 1, #BossPack do
            ScaleMonsterUnit(BossPack[i].boss, Current_Wave)
        end



        if ActiveRift and ActiveRift.group and BlzGroupGetSize(ActiveRift.group) > 0 then
            ForGroup(ActiveRift.group, function() ScaleMonsterUnit(GetEnumUnit(), Current_Wave) end)
        end
]]
    end




    function MonsterWandering()

        for i = 1, #MonsterPack do

            for index = BlzGroupGetSize(MonsterPack[i].group) - 1, 0, -1 do
                local picked = BlzGroupUnitAt(MonsterPack[i].group, index)
                local current_order = GetUnitCurrentOrder(picked)

                    if current_order == 0 and Chance(12.) then
                        local rect = MonsterPack[i].wander_region[GetRandomInt(1, #MonsterPack[i].wander_region)]
                        IssuePointOrderById(picked, order_attack, GetRandomRectX(rect), GetRandomRectY(rect))
                        rect = nil
                    elseif current_order == order_attack and not IsUnitInRangeXY(picked, GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 3300.) then
                        IssuePointOrderById(picked, order_move, GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner))
                    end

            end


            if MonsterPack[i].respawn then

                if not MonsterPack[i].respawn_executed and BlzGroupGetSize(MonsterPack[i].group) < MonsterPack[i].pack_count and not IsAnyHeroInRange(GetRectCenterX(MonsterPack[i].spawner), GetRectCenterY(MonsterPack[i].spawner), 1750.) then
                    --print("group with less")
                    if BlzGroupGetSize(MonsterPack[i].group) <= 0 then
                        MonsterPack[i].respawn_executed = true
                        --print("respawn start")
                        local timer = CreateTimer()
                        TimerStart(timer, MonsterPack[i].respawn, false, function()
                            DestroyTimer(GetExpiredTimer())
                            RespawnMonsterPack(i)
                        end)
                    elseif BlzGroupGetSize(MonsterPack[i].group) < MonsterPack[i].pack_count then
                            --print("despawn start")
                        local respawn_chance = ((1. - (BlzGroupGetSize(MonsterPack[i].group) / MonsterPack[i].pack_count)) * 100.) * 0.04
                            --print("respawn chance is " .. respawn_chance)

                        if respawn_chance > 0. and Chance(respawn_chance) then
                            --print("despawn")
                            for index = BlzGroupGetSize(MonsterPack[i].group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(MonsterPack[i].group, index)
                                KillUnit(picked)
                                ShowUnit(picked, false)
                            end
                        end

                    end

                end
            end
        end

    end


    function InitMonsterPacks()

        InitMonsterTraits()
        MonsterPack = {}
        BossPack = {}

        --##########################################################
        --#######################SPAWNER_DATA#######################
        --ScaleMonstersGroup = CreateGroup()
        MonsterPack[1] = { initial_spawn_time = 10. }
        MonsterPack[1].spawner = gg_rct_monster_pack_1_spawner
        MonsterPack[1].wander_region = {
            [1] = gg_rct_monster_pack_1_1,
            [2] = gg_rct_monster_pack_1_2,
            [3] = gg_rct_monster_pack_1_3
        }
        MonsterPack[1].tags = { MONSTERPACK_SKELETONS, MONSTERPACK_ZOMBIES, MONSTERPACK_SWARM, MONSTERPACK_DEMONS, MONSTERPACK_GHOSTS, MONSTERPACK_GNOLLS }
        MonsterPack[1].respawn = 385.
        MonsterPack[1].respawn_type = RESPAWN_TYPE_RANDOM
        MonsterPack[1].min = 5; MonsterPack[1].max = 10; MonsterPack[1].elite = 2
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[2] = { initial_spawn_time = 11. }
        MonsterPack[2].spawner = gg_rct_monster_pack_2_spawner
        MonsterPack[2].wander_region = {
            [1] = gg_rct_monster_pack_2_1,
            [2] = gg_rct_monster_pack_2_2,
            [3] = gg_rct_monster_pack_2_3
        }
        MonsterPack[2].tags = { MONSTERPACK_SKELETONS, MONSTERPACK_DEMONS, MONSTERPACK_GHOSTS, MONSTERPACK_ZOMBIES, MONSTERPACK_SWARM, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_DEMONS, MONSTERPACK_GNOLLS }
        MonsterPack[2].respawn = 445.
        MonsterPack[2].min = 7; MonsterPack[2].max = 15; MonsterPack[2].elite = 1
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[3] = { initial_spawn_time = 15. }
        MonsterPack[3].spawner = gg_rct_monster_pack_3_spawner
        MonsterPack[3].wander_region = {
            [1] = gg_rct_monster_pack_3_1,
            [2] = gg_rct_monster_pack_3_2,
            [3] = gg_rct_monster_pack_3_3
        }
        MonsterPack[3].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_BEASTS, MONSTERPACK_DEMONS, MONSTERPACK_SATYRS, MONSTERPACK_BANDITS, MONSTERPACK_GNOLLS }
        MonsterPack[3].respawn = 380.
        MonsterPack[3].min = 3; MonsterPack[3].max = 5
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[4] = { initial_spawn_time = 5. }
        MonsterPack[4].spawner = gg_rct_monster_pack_4_spawner
        MonsterPack[4].wander_region = {
            [1] = gg_rct_monster_pack_4_1
        }
        MonsterPack[4].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SKELETONS, MONSTERPACK_BEASTS, MONSTERPACK_GNOLLS }
        MonsterPack[4].respawn = 380.
        MonsterPack[4].min = 3; MonsterPack[4].max = 6
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[5] = { initial_spawn_time = 20. }
        MonsterPack[5].spawner = gg_rct_monster_pack_5_spawner
        MonsterPack[5].wander_region = {
            [1] = gg_rct_monster_pack_5_1
        }
        MonsterPack[5].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SKELETONS, MONSTERPACK_DEMONS, MONSTERPACK_SUCCUBUS, MONSTERPACK_SWARM, MONSTERPACK_SATYRS, MONSTERPACK_GNOLLS }
        MonsterPack[5].respawn = 445.
        MonsterPack[5].min = 7; MonsterPack[5].max = 15; MonsterPack[5].elite = 3
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[6] = { initial_spawn_time = 30. }
        MonsterPack[6].spawner = gg_rct_monster_pack_6_spawner
        MonsterPack[6].wander_region = {
            [1] = gg_rct_monster_pack_6_1,
            [2] = gg_rct_monster_pack_6_2
        }
        MonsterPack[6].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SKELETONS, MONSTERPACK_DEMONS, MONSTERPACK_SUCCUBUS, MONSTERPACK_SWARM, MONSTERPACK_GNOLLS }
        MonsterPack[6].respawn = 380.
        MonsterPack[6].min = 6; MonsterPack[6].max = 10; MonsterPack[6].elite = 3
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[7] = { initial_spawn_time = 30. }
        MonsterPack[7].spawner = gg_rct_monster_pack_7_spawner
        MonsterPack[7].wander_region = {
            [1] = gg_rct_monster_pack_7_1,
            [2] = gg_rct_monster_pack_7_2,
            [3] = gg_rct_monster_pack_7_3
        }
        MonsterPack[7].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SKELETONS, MONSTERPACK_DEMONS, MONSTERPACK_SUCCUBUS, MONSTERPACK_SWARM, MONSTERPACK_BEASTS, MONSTERPACK_BANDITS, MONSTERPACK_GNOLLS }
        MonsterPack[7].respawn = 380.
        MonsterPack[7].min = 5; MonsterPack[7].max = 8; MonsterPack[7].elite = 1
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[8] = { initial_spawn_time = 27. }
        MonsterPack[8].spawner = gg_rct_monster_pack_8_spawner
        MonsterPack[8].wander_region = {
            [1] = gg_rct_monster_pack_8_1,
            [2] = gg_rct_monster_pack_8_2
        }
        MonsterPack[8].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SKELETONS, MONSTERPACK_DEMONS, MONSTERPACK_SUCCUBUS, MONSTERPACK_SWARM, MONSTERPACK_BEASTS, MONSTERPACK_GNOLLS }
        MonsterPack[8].respawn = 445.
        MonsterPack[8].min = 7; MonsterPack[8].max = 15; MonsterPack[8].elite = 2
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[9] = { initial_spawn_time = 22. }
        MonsterPack[9].spawner = gg_rct_monster_pack_9_spawner
        MonsterPack[9].wander_region = {
            [1] = gg_rct_monster_pack_9_1,
            [2] = gg_rct_monster_pack_9_2,
            [3] = gg_rct_monster_pack_9_3
        }
        MonsterPack[9].tags = { MONSTERPACK_GHOSTS, MONSTERPACK_SWARM }
        MonsterPack[9].respawn = 445.
        MonsterPack[9].min = 7; MonsterPack[9].max = 15; MonsterPack[9].elite = 1
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[10] = {
            spawner = gg_rct_monster_pack_10_spawner,
            wander_region = {
                gg_rct_monster_pack_10_1,
                gg_rct_monster_pack_10_2
            },
            tags = { MONSTERPACK_BANDITS },
            respawn = 445., min = 3, max = 5, elite = 1, initial_spawn_time = 33.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[11] = {
            spawner = gg_rct_monster_pack_11_spawner,
            wander_region = {
                gg_rct_monster_pack_11_1,
                gg_rct_monster_pack_11_2
            },
            tags = { MONSTERPACK_ARACHNIDS },
            respawn = 445., min = 5, max = 10, elite = 2, initial_spawn_time = 13.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[12] = {
            spawner = gg_rct_monster_pack_12_spawner,
            wander_region = {
                gg_rct_monster_pack_12_1
            },
            tags = { MONSTERPACK_ARACHNIDS, MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_GNOLLS },
            respawn = 455., min = 7, max = 12, elite = 2, initial_spawn_time = 14.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[13] = {
            spawner = gg_rct_monster_pack_13_spawner,
            wander_region = {
                gg_rct_monster_pack_13_1
            },
            tags = { MONSTERPACK_ARACHNIDS, MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_GNOLLS },
            respawn = 445., min = 7, max = 12, elite = 2, initial_spawn_time = 18.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[14] = {
            spawner = gg_rct_monster_pack_14_spawner,
            wander_region = { gg_rct_monster_pack_14_1 },
            tags = { MONSTERPACK_ARACHNIDS, MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_SWARM, MONSTERPACK_DEMONS, MONSTERPACK_GNOLLS },
            respawn = 445., min = 5, max = 7, elite = 2, initial_spawn_time = 15.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[15] = {
            spawner = gg_rct_monster_pack_15_spawner,
            wander_region = { gg_rct_monster_pack_15_1 },
            tags = { MONSTERPACK_ARACHNIDS, MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_SWARM, MONSTERPACK_DEMONS, MONSTERPACK_GHOSTS, MONSTERPACK_GNOLLS },
            respawn = 440., min = 7, max = 12, elite = 2, initial_spawn_time = 16.
        }
        --##########################################################
        --#######################SPAWNER_DATA#######################
        MonsterPack[16] = {
            spawner = gg_rct_monster_pack_16_spawner,
            wander_region = { gg_rct_monster_pack_16_1, gg_rct_monster_pack_16_2 },
            tags = { MONSTERPACK_SPIDERS },
            respawn = 440., min = 1, max = 3, elite = 1, initial_spawn_time = 24.
        }
        --#######################SPAWNER_DATA#######################
        MonsterPack[17] = {
            spawner = gg_rct_monster_pack_17_spawner,
            wander_region = { gg_rct_monster_pack_17_1, gg_rct_monster_pack_17_2, gg_rct_monster_pack_17_3 },
            tags = { MONSTERPACK_ARACHNIDS, MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_SWARM, MONSTERPACK_DEMONS, MONSTERPACK_GHOSTS, MONSTERPACK_GNOLLS },
            respawn = 520., min = 7, max = 14, elite = 1, initial_spawn_time = 27.
        }
        --#######################SPAWNER_DATA#######################
        MonsterPack[18] = {
            spawner = gg_rct_monster_pack_18_spawner,
            wander_region = { gg_rct_monster_pack_18_1, gg_rct_monster_pack_18_2, gg_rct_monster_pack_18_3, gg_rct_monster_pack_18_4 },
            tags = { MONSTERPACK_SPIDERS, MONSTERPACK_BEASTS, MONSTERPACK_SATYRS, MONSTERPACK_SWARM, MONSTERPACK_DEMONS, MONSTERPACK_GHOSTS, MONSTERPACK_GNOLLS, MONSTERPACK_BANDITS, MONSTERPACK_SUCCUBUS },
            respawn = 440., min = 4, max = 6, elite = 2, initial_spawn_time = 30.
        }
        --##########################################################


        BossPack[1] = {
            spawner = gg_rct_arachnid_boss,
            boss_types = { MONSTER_ID_ARACHNID_BOSS },
            leash_range = 1000.,
            respawn = 560.,
            respawn_type = RESPAWN_TYPE_SAME
        }
        --##########################################################
        BossPack[2] = {
            spawner = gg_rct_bandit_boss,
            boss_types = { MONSTER_ID_BANDIT_BOSS },
            leash_range = 1500.,
            respawn = 560.,
            respawn_type = RESPAWN_TYPE_SAME
        }
        --##########################################################
        BossPack[3] = {
            spawner = gg_rct_spider_boss,
            boss_types = { MONSTER_ID_SPIDER_QUEEN },
            leash_range = 1000.,
            respawn = 560.,
            respawn_type = RESPAWN_TYPE_SAME
        }
        --##########################################################
        BossPack[4] = {
            spawner = gg_rct_skeleton_boss,
            boss_types = { MONSTER_ID_SKELETON_KING },
            leash_range = 1700.,
            respawn = 540.,
            respawn_type = RESPAWN_TYPE_SAME
        }

        DelayAction(BASE_SPAWN_TIME, function()
            for i = 1, #MonsterPack do
                DelayAction(MonsterPack[i].initial_spawn_time, function()
                    MonsterPack[i].group = SpawnMonsterPack(MonsterPack[i].spawner, MonsterPack[i].tags[GetRandomInt(1, #MonsterPack[i].tags)], MonsterPack[i].min, MonsterPack[i].max, MonsterPack[i].elite or 0, 0.)
                    MonsterPack[i].pack_count = BlzGroupGetSize(MonsterPack[i].group)

                        if MonsterPack[i].respawn then
                            MonsterPack[i].death_trigger = CreateTrigger()

                            TriggerAddAction(MonsterPack[i].death_trigger, function()
                                GroupRemoveUnit(MonsterPack[i].group, GetTriggerUnit())
                            end)


                            for index = BlzGroupGetSize(MonsterPack[i].group) - 1, 0, -1 do
                                TriggerRegisterUnitEvent(MonsterPack[i].death_trigger, BlzGroupUnitAt(MonsterPack[i].group, index), EVENT_UNIT_DEATH)
                            end

                        end
                end)

            end

            local timer = CreateTimer()
            TimerStart(timer, 2.25, true, MonsterWandering)
        end)

        --print("bosses ok")
        for i = 1, #BossPack do
            local x = GetRectCenterX(BossPack[i].spawner); local y = GetRectCenterY(BossPack[i].spawner)
            BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, FourCC(BossPack[i].boss_types[GetRandomInt(1, #BossPack[i].boss_types)]), x, y, GetRandomReal(0.,359.))

            CreateLeashForUnit(BossPack[i].boss, BossPack[i].leash_range)

                if BossPack[i].respawn then
                    local trg = CreateTrigger()
                    TriggerRegisterUnitEvent(trg, BossPack[i].boss, EVENT_UNIT_DEATH)
                    TriggerAddAction(trg, function()
                        local id = GetUnitTypeId(GetTriggerUnit())
                            local timer = CreateTimer()
                            TimerStart(timer, BossPack[i].respawn, false, function()

                                    if BossPack[i].respawn_type == RESPAWN_TYPE_SAME then
                                        BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, id, x, y, GetRandomReal(0.,359.))
                                    else
                                        BossPack[i].boss = CreateUnit(SECOND_MONSTER_PLAYER, FourCC(BossPack[i].boss_types[GetRandomInt(1, #BossPack[i].boss_types)]), x, y, GetRandomReal(0.,359.))
                                    end

                                CreateLeashForUnit(BossPack[i].boss, BossPack[i].leash_range)
                                TriggerRegisterUnitEvent(trg, BossPack[i].boss, EVENT_PLAYER_UNIT_DEATH)
                                DestroyTimer(GetExpiredTimer())
                                --DelayAction(0.001, function() ScaleMonsterUnit(BossPack[i].boss) end)
                            end)
                        end)
                end
        end


        InitRifts()
        InitCurses()

        --print("aaaaaaa")
        local test_group = CreateGroup()

        RegisterTestCommand("und", function()
            TimerStart(CreateTimer(), 0.3, true, function()
                SetUnitState(PlayerHero[1], UNIT_STATE_LIFE, 3000000.)
                SetUnitState(PlayerHero[1], UNIT_STATE_MANA, 3000000.)
            end)
        end)

        RegisterTestCommand("band", function()
            SetUnitX(PlayerHero[1], GetRectCenterX(gg_rct_band_test))
            SetUnitY(PlayerHero[1], GetRectCenterY(gg_rct_band_test))
        end)

        RegisterTestCommand("spd", function()
            SetUnitX(PlayerHero[1], GetRectCenterX(gg_rct_spd_test))
            SetUnitY(PlayerHero[1], GetRectCenterY(gg_rct_spd_test))
        end)

        RegisterTestCommand("arch", function()
            SetUnitX(PlayerHero[1], GetRectCenterX(gg_rct_arch_test))
            SetUnitY(PlayerHero[1], GetRectCenterY(gg_rct_arch_test))
        end)

        RegisterTestCommand("vamp", function()
            local unit = CreateUnit(Player(0), FourCC("u00N"), GetRectCenterX(gg_rct_rectaaa), GetRectCenterY(gg_rct_rectaaa), 0.)
            DelayAction(0., function() ScaleMonsterUnit(unit, Current_Wave)  end)
            GroupAddUnit(test_group, unit)
        end)

        RegisterTestCommand("zmb", function()
            local unit = CreateUnit(Player(0), FourCC("n00E"), GetRectCenterX(gg_rct_rectaaa), GetRectCenterY(gg_rct_rectaaa), 0.)
            DelayAction(0., function() ScaleMonsterUnit(unit, Current_Wave)  end)
            GroupAddUnit(test_group, unit)
        end)

        RegisterTestCommand("rvn", function()
            local unit = CreateUnit(Player(0), FourCC("n01N"), GetRectCenterX(gg_rct_rectaaa), GetRectCenterY(gg_rct_rectaaa), 0.)
            DelayAction(0., function() ScaleMonsterUnit(unit, Current_Wave)  end)
            GroupAddUnit(test_group, unit)
        end)

        RegisterTestCommand("outscale", function()
            ScaleMonsterGroup(test_group, Current_Wave)
        end)

        RegisterTestCommand("inspect", function()
            ForGroup(test_group, function()
                local unit_data = GetUnitData(GetEnumUnit())
                print("========")
                print(GetUnitName(GetEnumUnit()))
                for i = 1, #unit_data.stats do
                    print(GetParameterName(i) .. " value " .. unit_data.stats[i].value .. " bonus " .. unit_data.stats[i].bonus .. " mult " .. unit_data.stats[i].multiplier)
                end
            end)
        end)

        RegisterTestCommand("re", function()
            Current_Wave = Current_Wave + 1
            ScaleMonsterGroup(test_group, Current_Wave)
        end)

        RegisterTestCommand("level8", function()
            Current_Wave = 8
        end)

        RegisterTestCommand("level15", function()
            Current_Wave = 15
        end)

        RegisterTestCommand("level25", function()
            Current_Wave = 25
        end)

        RegisterTestCommand("level35", function()
            Current_Wave = 35
        end)
--print("aaaaaaa2")
    end

end