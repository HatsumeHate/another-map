---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 15.01.2020 23:16
---
do

    ActivePlayers = 0
    SPAWN_POINTS = 0
    MAIN_POINT = 0
    MONSTER_PLAYER = 0
    SECOND_MONSTER_PLAYER = 0
    WaveGroup = 0
    local WaveWaypointTimer = 0

    local WaveDifficultyModificator = 1.
    local WavePlayerCountModificator = 1.

    local COMMON_MONSTER_RATE = 0.65
    local MELEE_MONSTER_CHANCE = 60.

    local WAVE_MINIMUM_COUNT = 5
    local WAVE_MAXIMUM_COUNT = 7
    local WAVE_PLAYER_BONUS = 2


    local MONSTER_TAG_MELEE = 1
    local MONSTER_TAG_RANGE = 2

    MONSTERPACK_SUCCUBUS = 1
    MONSTERPACK_SKELETONS = 2
    MONSTERPACK_ZOMBIES = 3
    MONSTERPACK_DEMONS = 4
    MONSTERPACK_GHOSTS = 5
    MONSTERPACK_BANDITS = 6
    MONSTERPACK_ARACHNIDS = 7
    MONSTERPACK_SPIDERS = 8
    MONSTERPACK_BEASTS = 9
    MONSTERPACK_SWARM = 10
    MONSTERPACK_SATYRS = 11
    MONSTERPACK_BOSS = 12



    MONSTER_ID_ZOMBIE = "n00C"
    MONSTER_ID_ZOMBIE_N = "n01G"
    MONSTER_ID_ZOMBIE_MUTANT = "n00E"
    MONSTER_ID_FIEND = "u007"
    MONSTER_ID_GHOUL = "u00J"
    MONSTER_ID_MEAT_GOLEM = "e000"
    MONSTER_ID_ABOMINATION = "u00M"
    MONSTER_ID_DEMON_ASSASSIN = "u009"
    MONSTER_ID_DEMON_WIZARD = "n003"
    MONSTER_ID_DEMON_HELL_GUARD = "u00A"
    MONSTER_ID_FALLEN_ANGEL = "u008"
    MONSTER_ID_SUCCUBUS = "n002"
    MONSTER_ID_SUCCUBUS_ADVANCED = "n00B"
    MONSTER_ID_BLOOD_SUCCUBUS = "n01Q"
    MONSTER_ID_HELL_BEAST = "n01T"
    MONSTER_ID_REVENANT_MELEE = "n01U"
    MONSTER_ID_REVENANT = "n01I"
    MONSTER_ID_BANSHEE = "u00C"
    MONSTER_ID_BANSHEE_N = "u00K"
    MONSTER_ID_GHOST = "n006"
    MONSTER_ID_VOIDWALKER = "n008"
    MONSTER_ID_ANCIENT_VOIDWALKER = "n009"
    MONSTER_ID_SKELETON = "u00D"
    MONSTER_ID_SKELETON_IMPROVED = "n00D"
    MONSTER_ID_SKELETON_ARMORED = "u00B"
    MONSTER_ID_SKELETON_ARCHER = "n005"
    MONSTER_ID_SKELETON_MAGE = "u00E"
    MONSTER_ID_SKELETON_N = "u00O"
    MONSTER_ID_SKELETON_ARCHER_N = "n01P"
    MONSTER_ID_SKELETON_HELL_ARCHER = "n004"
    MONSTER_ID_SKELETON_SNIPER = "n007"
    MONSTER_ID_NECROMANCER = "u00F"
    MONSTER_ID_NECROMANCER_N = "u00L"
    MONSTER_ID_SORCERESS = "h002"
    MONSTER_ID_BLOODSUCKER = "n01O"
    MONSTER_ID_VAMPIRE = "u00N"
    MONSTER_ID_SPIDER = "n00Y"
    MONSTER_ID_BLACK_SPIDER = "n00Z"
    MONSTER_ID_BLACK_SPIDER_N = "n01H"
    MONSTER_ID_SPIDER_HUNTER = "n010"
    MONSTER_ID_GIGANTIC_SPIDER = "n011"
    MONSTER_ID_ARACHNID_THROWER = "n00O"
    MONSTER_ID_ARACHNID = "n00P"
    MONSTER_ID_ARACHNID_WARRIOR = "n00Q"
    MONSTER_ID_ARACHNID_GROUNDER = "n00R"
    MONSTER_ID_BANDIT_BASIC = "n00T"
    MONSTER_ID_BANDIT_ROBBER = "n00U"
    MONSTER_ID_BANDIT_ROGUE = "n00V"
    MONSTER_ID_BANDIT_ASSASSIN = "n00W"
    MONSTER_ID_QUILLBEAST = "n01N"
    MONSTER_ID_WOLF = "n01J"
    MONSTER_ID_SATYR = "n01K"
    MONSTER_ID_SATYR_TRICKSTER = "n01L"
    MONSTER_ID_SATYR_HELL = "n01M"


    MONSTER_ID_BUTCHER = "U003"
    MONSTER_ID_BAAL = "U001"
    MONSTER_ID_MEPHISTO = "U000"
    MONSTER_ID_DEMONESS = "U006"
    MONSTER_ID_DEMONKING = "U005"
    MONSTER_ID_UNDERWORLD_QUEEN = "U002"
    MONSTER_ID_REANIMATED = "U004"
    MONSTER_ID_SKELETON_KING = "n015"
    MONSTER_ID_SPIDER_QUEEN = "n012"
    MONSTER_ID_ARACHNID_BOSS = "n00S"
    MONSTER_ID_BANDIT_BOSS = "n00X"




    MONSTER_WAYPOINTS = 0
    MONSTER_EXP_RATES = 0
    MONSTER_LIST = 0


    -- attack type focus (melee/range ratio) => monster type =>




    function GetRandomMonsterPack(rank)
        local pack = GetRandomInt(1, #MONSTER_LIST-1)

            while true do
                if MONSTER_LIST[pack][rank] ~= nil then return MONSTER_LIST[pack] end
                pack = GetRandomInt(1, #MONSTER_LIST-1)
            end

        return MONSTER_LIST[pack]
    end


    function GetRandomMonsterPackTag(rank, tag)
        local pack = GetRandomInt(1, #MONSTER_LIST-1)
        local num = 10

            while num > 0 do
                pack = GetRandomInt(1, #MONSTER_LIST-1)
                    if MONSTER_LIST[pack][rank] ~= nil and MONSTER_LIST[pack][rank][tag] ~= nil then
                        return MONSTER_LIST[pack]
                    end
                num = num - 1
            end

        return MONSTER_LIST[pack]
    end


    
    ---@param pack number
    ---@param rect rect
    ---@param amount number
    ---@param group group
    function CreateUnits_Pack(pack, rect, amount, group)
        if pack == nil then return 0 end

        local id
        local newunit

        if amount <= 0 then return end

            for i = 1, amount do
                for k = 1, #pack do if GetRandomReal(0.,100.) <= pack[k].chance then id = FourCC(pack[k].id); break end end
                newunit = CreateUnit(SECOND_MONSTER_PLAYER, id, GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect)), GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect)), GetRandomInt(0, 359))
                GroupAddUnit(group, newunit)
            end

        return amount
    end
    

    ---@param pack number
    ---@param rect rect
    ---@param amount number
    function CreateUnits(pack, rect, amount)
        if pack == nil then return 0 end

        local id
        local newunit

        if amount <= 0 then return end

            for i = 1, amount do
                for k = 1, #pack do if GetRandomReal(0.,100.) <= pack[k].chance then id = FourCC(pack[k].id); break end end
                newunit = CreateUnit(MONSTER_PLAYER, id, GetRandomReal(GetRectMinX(rect), GetRectMaxX(rect)), GetRandomReal(GetRectMinY(rect), GetRectMaxY(rect)), GetRandomInt(0, 359))
                GroupAddUnit(WaveGroup, newunit)
            end

        return amount
    end





    local function GetProperAttackTypeSwitch(current_type, pack_attack_type)
        local monster_attack_type = current_type == MONSTER_TAG_MELEE and MONSTER_TAG_RANGE or MONSTER_TAG_MELEE

        if pack_attack_type == nil then
            monster_attack_type = monster_attack_type == MONSTER_TAG_MELEE and MONSTER_TAG_RANGE or MONSTER_TAG_MELEE
        end

        return monster_attack_type
    end



    ---@param point rect
    ---@param monster_pack number
    ---@param min number
    ---@param max number
    ---@param bonus_elite number
    ---@param range_type_chance_delta number
    function SpawnMonsterPack(point, monster_pack, min, max, bonus_elite, range_type_chance_delta)
        if point == nil or monster_pack == nil then return end
        local total_monster_count = GetRandomInt(min, max) + math.floor(Current_Wave / 3.)
        local first_pack_count = math.ceil(total_monster_count * COMMON_MONSTER_RATE)
        local monster_attack_type = GetRandomReal(0., 100.) <= (MELEE_MONSTER_CHANCE + (range_type_chance_delta or 0.)) and MONSTER_TAG_MELEE or MONSTER_TAG_RANGE
        local monster_group = CreateGroup()

        monster_pack = MONSTER_LIST[monster_pack]
        local original_pack = monster_pack

        local last_attack_type = monster_attack_type
        local rank = MONSTER_RANK_COMMON
        local to_spawn = first_pack_count
        local rank_switch = 0


        while total_monster_count > 0 do
            monster_pack = original_pack
            --print("begin")
            --print("total now is " .. total_monster_count)
            if not monster_pack[rank] or not monster_pack[rank][last_attack_type] then
                monster_pack = GetRandomMonsterPack(rank)
                --print("total remaining " .. total_monster_count)
            end

            total_monster_count = total_monster_count - CreateUnits_Pack(monster_pack[rank][last_attack_type] or nil, point, to_spawn, monster_group)

            rank_switch = rank_switch + 1

            if last_attack_type == MONSTER_TAG_MELEE then last_attack_type = MONSTER_TAG_RANGE
            else last_attack_type = MONSTER_TAG_MELEE end

            if rank_switch == 2 then
                if rank == MONSTER_RANK_COMMON then rank = MONSTER_RANK_ADVANCED; to_spawn = GetRandomInt(1, 3)
                else rank = MONSTER_RANK_COMMON; to_spawn = GetRandomInt(1, 5) end
                rank_switch = 0
            end



        end

        return monster_group
    end


    local BossCounter = 0

    function RemoveGuardPosition(hUnit) end


    local function CreateSpecialUnits(pack, rank, attack_type, amount, where)
        return CreateUnits(pack[rank][attack_type] or nil, where, amount)
    end


    ---@param point rect
    function SpawnMonstersWave(point)
        local monster_pack = GetRandomMonsterPack(MONSTER_RANK_COMMON)
        --local point = SPAWN_POINTS[1]
        local total_monster_count = math.floor((GetRandomInt(WAVE_MINIMUM_COUNT, WAVE_MAXIMUM_COUNT) + Current_Wave + (ActivePlayers-1 * WAVE_PLAYER_BONUS)) * WaveDifficultyModificator)
        --print("total is "..total_monster_count)
        local first_pack_count = math.floor(total_monster_count * COMMON_MONSTER_RATE)
        --print("first pack counter is "..first_pack_count)
        local monster_attack_type = GetRandomReal(0., 100.) <= MELEE_MONSTER_CHANCE and MONSTER_TAG_MELEE or MONSTER_TAG_RANGE

        BossCounter = BossCounter + 1
        --print("monster attack type is "..(monster_attack_type == MONSTER_TAG_MELEE and "melee" or "range"))
        --print("pack is "..monster_pack)

        local last_attack_type = monster_attack_type
        local rank = MONSTER_RANK_COMMON
        local to_spawn = first_pack_count
        local rank_switch = 0


        while total_monster_count > 0 do
            --print("begin")
            --print("total now is " .. total_monster_count)
            if monster_pack[rank] and monster_pack[rank][last_attack_type] then
                total_monster_count = total_monster_count - CreateUnits(monster_pack[rank][last_attack_type] or nil, point, to_spawn)
                --print("total remaining " .. total_monster_count)
            end

            rank_switch = rank_switch + 1

            if last_attack_type == MONSTER_TAG_MELEE then last_attack_type = MONSTER_TAG_RANGE
            else last_attack_type = MONSTER_TAG_MELEE end

            if rank_switch == 2 then
                if rank == MONSTER_RANK_COMMON then rank = MONSTER_RANK_ADVANCED; to_spawn = GetRandomInt(1, 3)
                else rank = MONSTER_RANK_COMMON; to_spawn = GetRandomInt(1, 5) end
                rank_switch = 0
            end



        end

        if BossCounter == 5 then
            local boss

            if monster_pack[MONSTER_RANK_BOSS] then
                boss = CreateUnit(MONSTER_PLAYER, FourCC(monster_pack[MONSTERPACK_BOSS][GetRandomInt(1, #monster_pack[MONSTERPACK_BOSS])]), GetRectCenterX(point), GetRectCenterY(point), 270.)
            else
                boss = CreateUnit(MONSTER_PLAYER, FourCC(MONSTER_LIST[MONSTERPACK_BOSS][GetRandomInt(1, #MONSTER_LIST[MONSTERPACK_BOSS])]), GetRectCenterX(point), GetRectCenterY(point), 270.)
            end

            GroupAddUnit(WaveGroup, boss)
            BossCounter = 0
        end


        local waypoint = 2
        --local switch_waypoint = false
        local waypoint_type = 1
        local guard_group = CreateGroup()

        for i = 1, #MONSTER_WAYPOINTS do
            if MONSTER_WAYPOINTS[i][1] == point then
                waypoint_type = i
                break
            end
        end
        
        TimerStart(WaveWaypointTimer, 3., true, function()
            if BlzGroupGetSize(WaveGroup) <= 0 then
                TimerStart(WaveWaypointTimer, 0., false, nil)
                DestroyGroup(guard_group)
            else

                if MONSTER_WAYPOINTS[waypoint_type][waypoint] ~= MAIN_POINT then
                    --switch_waypoint = true
                    local counter = 0
                    local x = GetRectCenterX(MONSTER_WAYPOINTS[waypoint_type][waypoint]); local y = GetRectCenterY(MONSTER_WAYPOINTS[waypoint_type][waypoint])

                    ForGroup(WaveGroup, function()
                        if IsUnitInRangeXY(GetEnumUnit(), x, y, 650.) and not IsUnitInGroup(GetEnumUnit(), guard_group) then
                            local unit = GetEnumUnit()
                            DelayAction(GetRandomReal(0.15, 1.), function()
                                IssueImmediateOrderById(unit, order_stop)
                                GroupAddUnit(guard_group, unit)
                                --print("stop")
                            end)
                        end

                        if IsUnitInRangeXY(GetEnumUnit(), x, y, 650.) then
                            counter = counter + 1
                            --switch_waypoint = false
                        end
                    end)

                    if counter / BlzGroupGetSize(WaveGroup) >= 0.65 then
                        waypoint = waypoint + 1
                        GroupClear(guard_group)
                    end

                    --print(counter / BlzGroupGetSize(WaveGroup))

                end


                ForGroup(WaveGroup, function()
                    RemoveGuardPosition(GetEnumUnit())
                    IssuePointOrderById(GetEnumUnit(), order_attack, GetRectCenterX(MONSTER_WAYPOINTS[waypoint_type][waypoint]), GetRectCenterY(MONSTER_WAYPOINTS[waypoint_type][waypoint]))
                end)
                PingMinimap(GetRectCenterX(MONSTER_WAYPOINTS[waypoint_type][waypoint]), GetRectCenterY(MONSTER_WAYPOINTS[waypoint_type][waypoint]), 5.)

            end
        end)


        PingMinimap(GetRectCenterX(point), GetRectCenterY(point), 7.)

        local penta = AddSpecialEffect("Other\\MagicCircle_Fire.mdx", GetRectCenterX(point), GetRectCenterY(point))
        BlzSetSpecialEffectScale(penta, 3.)
        DestroyEffect(penta)

    end


    function GetRandomMonsterSpawnPoint()
        return SPAWN_POINTS[GetRandomInt(1, #SPAWN_POINTS)]
    end


    function InitMonsterData()

        MONSTER_PLAYER = Player(10)
        SECOND_MONSTER_PLAYER = Player(11)


        MONSTER_EXP_RATES = {
            [MONSTER_RANK_COMMON] = 1.,
            [MONSTER_RANK_ADVANCED] = 1.25,
            [MONSTER_RANK_BOSS] = 1.,
            const_per_level = 5,
            modf_per_level = 0.02
        }

        MONSTER_LIST = {
            [MONSTERPACK_SUCCUBUS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SUCCUBUS, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SUCCUBUS_ADVANCED, chance = 100. } ,
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_BLOOD_SUCCUBUS, chance = 100. }
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_DEMONESS,
                    MONSTER_ID_UNDERWORLD_QUEEN
                }
            },
            [MONSTERPACK_BEASTS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_WOLF, chance = 35. },
                        { id = MONSTER_ID_QUILLBEAST, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_ARACHNID_THROWER, chance = 50., max = 3 } ,
                        { id = MONSTER_ID_SPIDER_HUNTER, chance = 100., max = 3 } ,
                    }
                }
            },
            [MONSTERPACK_SWARM] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_BLOODSUCKER, chance = 100. },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_VAMPIRE, chance = 100. },
                    }
                }
            },
            [MONSTERPACK_SATYRS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SATYR, chance = 100., max = 3 },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SATYR_TRICKSTER, chance = 100., max = 3 },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SATYR_HELL, chance = 100. },
                    }
                }
            },
            [MONSTERPACK_BANDITS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_BANDIT_BASIC, chance = 100. }
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_BANDIT_ROBBER, chance = 100. }
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_BANDIT_ROGUE, chance = 100. }
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_BANDIT_ASSASSIN, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_BANDIT_BOSS
                }
            },
            [MONSTERPACK_ARACHNIDS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_ARACHNID, chance = 100. }
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_ARACHNID_THROWER, chance = 100. }
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_ARACHNID_WARRIOR, chance = 100. }
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_ARACHNID_GROUNDER, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_ARACHNID_BOSS
                }
            },
            [MONSTERPACK_SPIDERS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_BLACK_SPIDER_N, chance = 10., max = 1 },
                        { id = MONSTER_ID_BLACK_SPIDER, chance = 20. },
                        { id = MONSTER_ID_SPIDER, chance = 100. }
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_GIGANTIC_SPIDER, chance = 100. }
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SPIDER_HUNTER, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_SPIDER_QUEEN
                }
            },
            [MONSTERPACK_SKELETONS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SKELETON_ARMORED, chance = 22.5 },
                        { id = MONSTER_ID_SKELETON_N, chance = 20., max = 4 },
                        { id = MONSTER_ID_SKELETON_IMPROVED, chance = 32.5 },
                        { id = MONSTER_ID_SKELETON, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SKELETON_ARCHER, chance = 40. },
                        { id = MONSTER_ID_SKELETON_ARCHER_N, chance = 20., max = 2 },
                        { id = MONSTER_ID_SKELETON_MAGE, chance = 40. },
                        { id = MONSTER_ID_SORCERESS, chance = 40., max = 2 },
                        { id = MONSTER_ID_NECROMANCER_N, chance = 20., max = 2 },
                        { id = MONSTER_ID_NECROMANCER, chance = 100. },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SKELETON_HELL_ARCHER, chance = 50. },
                        { id = MONSTER_ID_SKELETON_SNIPER, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_REANIMATED,
                    MONSTER_ID_SKELETON_KING
                }
            },
            [MONSTERPACK_ZOMBIES] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SKELETON_N, chance = 10., max = 2 },
                        { id = MONSTER_ID_SKELETON, chance = 20., max = 3 },
                        { id = MONSTER_ID_ZOMBIE_N, chance = 35., max = 3 },
                        { id = MONSTER_ID_ZOMBIE, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_NECROMANCER_N, chance = 20., max = 2 },
                        { id = MONSTER_ID_NECROMANCER, chance = 100. },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_ZOMBIE_MUTANT, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_BUTCHER
                }
            },
            [MONSTERPACK_DEMONS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_SKELETON_ARMORED, chance = 21.5, max = 2 },
                        { id = MONSTER_ID_SUCCUBUS, chance = 33.5, max = 3 },
                        { id = MONSTER_ID_GHOUL, chance = 33.5, max = 3 },
                        { id = MONSTER_ID_HELL_BEAST, chance = 33.5, max = 3 },
                        { id = MONSTER_ID_FIEND, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_NECROMANCER_N, chance = 23., max = 3 },
                        { id = MONSTER_ID_NECROMANCER, chance = 23. },
                        { id = MONSTER_ID_SUCCUBUS_ADVANCED, chance = 40. },
                        { id = MONSTER_ID_VOIDWALKER, chance = 100. },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_DEMON_ASSASSIN, chance = 40.5 },
                        { id = MONSTER_ID_FALLEN_ANGEL, chance = 30.5, max = 3 },
                        { id = MONSTER_ID_MEAT_GOLEM, chance = 15., max = 1 },
                        { id = MONSTER_ID_ABOMINATION, chance = 25.5, max = 2 },
                        { id = MONSTER_ID_DEMON_HELL_GUARD, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_REVENANT, chance = 33.5, max = 3 },
                        { id = MONSTER_ID_DEMON_WIZARD, chance = 33.5, max = 2 },
                        { id = MONSTER_ID_ANCIENT_VOIDWALKER, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_DEMONESS,
                    MONSTER_ID_DEMONKING,
                    MONSTER_ID_UNDERWORLD_QUEEN,
                    MONSTER_ID_BUTCHER,
                    MONSTER_ID_BAAL,
                    MONSTER_ID_MEPHISTO
                }
            },
            [MONSTERPACK_GHOSTS] = {
                [MONSTER_RANK_COMMON] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_REVENANT_MELEE, chance = 100. },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_SORCERESS, chance = 25., max = 2 },
                        { id = MONSTER_ID_BANSHEE, chance = 100. },
                    }
                },
                [MONSTER_RANK_ADVANCED] = {
                    [MONSTER_TAG_MELEE] = {
                        { id = MONSTER_ID_REVENANT, chance = 100., max = 3 },
                    },
                    [MONSTER_TAG_RANGE] = {
                        { id = MONSTER_ID_GHOST, chance = 100. },
                    }
                },
                [MONSTERPACK_BOSS] = {
                    MONSTER_ID_MEPHISTO
                }
            },
            [MONSTERPACK_BOSS] = {
                MONSTER_ID_BUTCHER,
                MONSTER_ID_BAAL,
                MONSTER_ID_MEPHISTO,
                MONSTER_ID_DEMONESS ,
                MONSTER_ID_DEMONKING,
                MONSTER_ID_UNDERWORLD_QUEEN,
                MONSTER_ID_REANIMATED,
                MONSTER_ID_SPIDER_QUEEN,
                MONSTER_ID_ARACHNID_BOSS,
                MONSTER_ID_BANDIT_BOSS,
                MONSTER_ID_SKELETON_KING
            }
        }


        MONSTER_STATS_RATES = {
            { stat = PHYSICAL_ATTACK,       initial = 0,      delta = 1,     delta_level = 1, method = STRAIGHT_BONUS },
            { stat = MAGICAL_ATTACK,        initial = 0,      delta = 1,     delta_level = 1, method = STRAIGHT_BONUS },
            { stat = PHYSICAL_DEFENCE,      initial = 0,      delta = 3,     delta_level = 1, method = STRAIGHT_BONUS, per_player = 5 },
            { stat = MAGICAL_SUPPRESSION,   initial = 0,      delta = 2,     delta_level = 1, method = STRAIGHT_BONUS, per_player = 3 },
            { stat = PHYSICAL_ATTACK,       initial = 1.,   delta = 0.011,  delta_level = 1, method = MULTIPLY_BONUS },
            { stat = PHYSICAL_DEFENCE,      initial = 1.,   delta = 0.01,  delta_level = 1, method = MULTIPLY_BONUS },
            { stat = MAGICAL_ATTACK,        initial = 1.,   delta = 0.011,  delta_level = 1, method = MULTIPLY_BONUS },
            { stat = MAGICAL_SUPPRESSION,   initial = 1.,   delta = 0.01,  delta_level = 1, method = MULTIPLY_BONUS },
            { stat = CRIT_CHANCE,           initial = 0,      delta = 1.,    delta_level = 5, method = STRAIGHT_BONUS },
            { stat = ALL_RESIST,            initial = 0,      delta = 1,     delta_level = 5, method = STRAIGHT_BONUS },
            { stat = PHYSICAL_BONUS,        initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = ICE_BONUS,             initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = LIGHTNING_BONUS,       initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = FIRE_BONUS,            initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = DARKNESS_BONUS,        initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = HOLY_BONUS,            initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = POISON_BONUS,          initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = ARCANE_BONUS,          initial = 0,      delta = 1,     delta_level = 3, method = STRAIGHT_BONUS },
            { stat = HP_VALUE,              initial = 0,      delta = 7,    delta_level = 1, method = STRAIGHT_BONUS, per_player = 45 },
            { stat = HP_VALUE,              initial = 1.,   delta = 0.04,  delta_level = 1, method = MULTIPLY_BONUS },
        }

        BONUS_MONSTER_STAT_RATES = {
            [FourCC("abcd")] = {
                [PHYSICAL_ATTACK] = 0.
            },
            [FourCC("U003")] = {
                scaling = {
                    { stat = HP_PER_HIT,              initial = 0,   delta = 1,  delta_level = 1, method = STRAIGHT_BONUS },
                }
            },
            [FourCC("n01O")] = {
                scaling = {
                    { stat = HP_PER_HIT,              initial = 0,   delta = 1,  delta_level = 1, method = STRAIGHT_BONUS },
                }
            },
            [FourCC("u00N")] = {
                scaling = {
                    { stat = HP_PER_HIT,              initial = 0,   delta = 1,  delta_level = 1, method = STRAIGHT_BONUS },
                }
            }
        }



        SPAWN_POINTS = {
            gg_rct_spawn_left,
            gg_rct_spawn_down,
            gg_rct_spawn_right,
            gg_rct_spawn_wave_top_righ
        }

        MAIN_POINT = gg_rct_captain_guard_rect

        MONSTER_WAYPOINTS = {
            [1] = {
                gg_rct_spawn_left,
                gg_rct_monster_waypoint_1,
                gg_rct_monster_waypoint_2,
                gg_rct_monster_waypoint_3,
                gg_rct_monster_waypoint_4,
                MAIN_POINT
            },
            [2] = {
                gg_rct_spawn_down,
                gg_rct_monster_waypoint_5,
                gg_rct_monster_waypoint_6,
                MAIN_POINT
            },
            [3] = {
                gg_rct_spawn_right,
                gg_rct_monster_waypoint_7,
                gg_rct_monster_waypoint_4,
                MAIN_POINT
            },
            [4] = {
                gg_rct_spawn_wave_top_righ,
                gg_rct_monster_waypoint_8,
                gg_rct_monster_waypoint_9,
                gg_rct_monster_waypoint_4,
                MAIN_POINT
            }
        }
        WaveWaypointTimer = CreateTimer()

        WaveGroup = CreateGroup()

        local trg = CreateTrigger()
        DelayAction(1., function()

            --for i = 0, 5 do if IsPlayerSlotState(Player(i), PLAYER_SLOT_STATE_PLAYING) then ActivePlayers = ActivePlayers + 1 end end

                --print("a")
                InitMonsterPacks()
                --print("a2")
                TriggerRegisterPlayerUnitEvent(trg, MONSTER_PLAYER, EVENT_PLAYER_UNIT_DEATH, nil)
                TriggerRegisterPlayerUnitEvent(trg, SECOND_MONSTER_PLAYER, EVENT_PLAYER_UNIT_DEATH, nil)
                --print("a3")
                TriggerAddAction(trg, function()
                    local unit = GetTriggerUnit()
                    --print("killer is " .. GetUnitName(GetKillingUnit()))
                        --print("ded")

                        if IsUnitInGroup(unit, WaveGroup) then
                            GroupRemoveUnit(WaveGroup, unit)
                            if BlzGroupGetSize(WaveGroup) <= 0 then EndWave() end
                        end

                    if GetKillingUnit() ~= nil then
                        local unit_Data = GetUnitData(unit)

                        --print("pre drop")
                        for i = 1, 6 do
                            if PlayerHero[i] and IsUnitInRangeXY(PlayerHero[i], GetUnitX(unit), GetUnitY(unit), 2700.) then
                                DropForPlayer(unit, i-1)
                            end
                        end

                        if unit_Data.xp and unit_Data.xp > 0 then
                            local bonus = MONSTER_EXP_RATES.const_per_level * Current_Wave
                            local mult = 1. + (MONSTER_EXP_RATES.modf_per_level * Current_Wave)
                            GiveExpForKill((unit_Data.xp + bonus) * MONSTER_EXP_RATES[unit_Data.classification or MONSTER_RANK_COMMON] * mult, GetUnitX(unit), GetUnitY(unit))
                        end

                        unit = nil
                        unit_Data = nil
                    end

            end)

            InitSpiderQueenData()

        end)


        RegisterTestCommand("endw", function()
            print("kill current wave")
            ForGroup(WaveGroup, function ()
                KillUnit(GetEnumUnit())
            end)
        end)

        RegisterTestCommand("extreme", function()
            Current_Wave = 48
        end)

    end

end

