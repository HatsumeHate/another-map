---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 07.10.2021 19:35
---
do

    local Droplists



    ---@param id string
    function GetDropList(id)
        return Droplists[id] or nil
    end


    ---@param id string
    ---@param list table
    function NewDropList(id, list)
        Droplists[id] = list
    end


    ---@param unit unit
    ---@param droplist string
    ---@param chance real
    ---@param position integer
    function AddDropList(unit, droplist, chance, position)
        local unit_data = GetUnitData(unit)
        local new_droplist = { id = droplist, chance = chance }

            position = position and position or #unit_data.droplist.list-1
            table.insert(unit_data.droplist.list, position, MergeTables({}, new_droplist))

    end


    ---@param unit unit
    ---@param droplist string
    function SetDropList(unit, droplist)
        local unit_data = GetUnitData(unit)

        if not unit_data then
            UnitsList[unit] = {}
            unit_data = UnitsList[unit]
        end

        unit_data.droplist = MergeTables({}, GetDropList(droplist))
    end


    ---@param unit unit
    ---@param droplist string
    ---@return integer
    function RemoveDropList(unit, droplist)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.droplist.list do
                if unit_data.droplist.list[i].id == droplist then
                    table.remove(unit_data.droplist.list, i)
                    return i
                end
            end

    end

    ---@param unit unit
    ---@param droplist string
    ---@param chance real
    function SetDropChance(unit, droplist, chance)
         local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.droplist.list do
                if unit_data.droplist.list[i].id == droplist then
                    unit_data.droplist.list[i].chance = chance
                    break
                end
            end
    end

    ---@param id string
    local function GetProperDropList(id)
        local droplist = GetDropList(id)

            if droplist.template then
                for i = 1, #droplist.list do
                    if Chance(droplist.list[i].chance or 100.) then
                        return GetProperDropList(droplist.list[i].id)
                    end
                end
            else
                return droplist
            end


    end

    ---@param droplist table
    ---@param bundle table
    ---@param min integer
    ---@param max integer
    local function AddItemsToDropBundle(droplist, bundle, bonus_drop_chance)
        local list = droplist.list
        local min = droplist.min or 1
        local max = droplist.max or 1
        local rolls = droplist.rolls or 1
        local random = GetRandomIntTable(min, #list, #list)
        local current_item_count = 0

            for i = 1, #list do
                local chance = current_item_count < min and 126. or (list[random[i]].chance or 100.)

                if Chance(chance * bonus_drop_chance) then

                    if list[random[i]].generate then
                        list[random[i]].quality_list = droplist.quality
                    end

                    bundle[#bundle + 1] = list[random[i]]
                    if current_item_count >= min then rolls = rolls - 1 end
                end

                current_item_count = current_item_count + 1
                if current_item_count >= max or rolls <= 0 then break end
            end

    end


    ---@param player number
    ---@param x real
    ---@param y real
    ---@param min_offset real
    ---@param max_offset real
    ---@param droplist table
    function DropDroplistForPlayer(player, x, y, min_offset, max_offset, droplist)
        local item_drop = {}
        local min = droplist.min or 1
        local max = droplist.max or 1
        local current = 0
        local initial_time_offset = 0.45
        local time_offset = 0.
        local bonus_drop_chance = 1. + GetUnitParameterValue(PlayerHero[player], DROP_BONUS) * 0.01

            for i = 1, #droplist.list do
                if Chance(droplist.list[i].chance * bonus_drop_chance) then
                    local inner_droplist = GetProperDropList(droplist.list[i].id)

                    AddItemsToDropBundle(inner_droplist, item_drop, bonus_drop_chance)

                end
            end

            --print(#item_drop)
            for i = 1, #item_drop do
                if current < max or item_drop[i].ignore_max then

                    DelayAction(initial_time_offset + time_offset, function()
                        local angle = GetRandomReal(0., 359.)
                        local drop_offset = GetMaxAvailableDistance(x, y, angle, GetRandomReal(min_offset or 45., max_offset or 65.))
                        local new_x = x + Rx(drop_offset, angle)
                        local new_y = y + Ry(drop_offset, angle)


                            if item_drop[i].id == "gold" then
                                CreateGoldStack(math.floor(GetRandomInt(item_drop[i].min, item_drop[i].max) * (1. + GetUnitParameterValue(PlayerHero[player], GOLD_BONUS) * 0.01)), new_x, new_y, player-1)
                            else
                                local item = CreateCustomItem(item_drop[i].id, new_x, new_y, true, player-1)

                                    if item_drop[i].generate then
                                        local item_data = GetItemData(item)

                                        if item_data.QUALITY == SET_ITEM or item_data.QUALITY == UNIQUE_ITEM then
                                            GenerateItemLevel(item, Current_Wave + GetRandomInt(0, 2))
                                        else
                                            local quality = COMMON_ITEM

                                            for k = 1, #item_drop[i].quality_list do
                                                if Chance(item_drop[i].quality_list[k].chance) then
                                                    quality = item_drop[i].quality_list[k].quality
                                                    break
                                                end
                                            end

                                            GenerateItemStats(item, Current_Wave + GetRandomInt(0, 2), quality)
                                        end

                                    elseif GetItemType(item) == ITEM_TYPE_CHARGED then
                                        SetItemCharges(item, GetRandomInt(item_drop[i].min or 1, item_drop[i].max or 1))
                                    end

                                DelayAction(480., function()
                                    local item_data = GetItemData(item)
                                    if item and item_data and item_data.item and item_data.owner then
                                        RemoveCustomItem(item)
                                    end
                            end)

                            end

                        --print(item_drop[i].id)
                    end)

                    time_offset = time_offset + 0.347
                    current = current + 1
                end

            end
            --print("done")
    end


    ---@param dying_unit unit
    ---@param player integer
    function DropForPlayer(dying_unit, player)
        local x = GetUnitX(dying_unit)
        local y = GetUnitY(dying_unit)
        local unit_data = GetUnitData(dying_unit)

            DropDroplistForPlayer(player+1, x, y, unit_data.drop_offset_min or nil, unit_data.drop_offset_max or nil, unit_data.droplist)


    end


    function InitDroplist()
        Droplists = {}


        NewDropList("common_item", {
            quality = {
                { quality = MAGIC_ITEM, chance = 5. },
                { quality = RARE_ITEM, chance = 25. },
                { quality = COMMON_ITEM, chance = 100. },
            },
            list = {
                { id = GetGeneratedItemId(SWORD_WEAPON), generate = true  },
                { id = GetGeneratedItemId(GREATSWORD_WEAPON), generate = true },
                { id = GetGeneratedItemId(AXE_WEAPON), generate = true },
                { id = GetGeneratedItemId(GREATAXE_WEAPON), generate = true },
                { id = GetGeneratedItemId(BLUNT_WEAPON), generate = true },
                { id = GetGeneratedItemId(GREATBLUNT_WEAPON), generate = true },
                { id = GetGeneratedItemId(STAFF_WEAPON), generate = true },
                { id = GetGeneratedItemId(DAGGER_WEAPON), generate = true },
                { id = GetGeneratedItemId(BOW_WEAPON), generate = true },
                { id = GetGeneratedItemId(CHEST_ARMOR), generate = true },
                { id = GetGeneratedItemId(HEAD_ARMOR), generate = true },
                { id = GetGeneratedItemId(HANDS_ARMOR), generate = true },
                { id = GetGeneratedItemId(LEGS_ARMOR), generate = true },
                { id = GetGeneratedItemId(NECKLACE_JEWELRY), generate = true },
                { id = GetGeneratedItemId(RING_JEWELRY), generate = true },
                { id = GetGeneratedItemId(SHIELD_OFFHAND), generate = true },
                { id = GetGeneratedItemId(ORB_OFFHAND), generate = true },
                { id = GetGeneratedItemId(BELT_ARMOR), generate = true },
                { id = GetGeneratedItemId(QUIVER_OFFHAND), generate = true },
            }
        })

        NewDropList("set_items", {
            list = {
                { id = "I01B", generate = true }, --queen
                { id = "I01A", generate = true }, --princess
                { id = "I01E", generate = true }, --bootpain
                { id = "I01F", generate = true }, --chestpain
                { id = "I01G", generate = true }, --headpain
                { id = "I01H", generate = true }, --king
                { id = "I01I", generate = true }, --jester
                { id = "I02J", generate = true }, --crimson
                { id = "I02K", generate = true }, --crimson
                { id = "I02L", generate = true }, --crimson
                { id = "I02I", generate = true }, --crimson
            }
        })

        NewDropList("unique_items", {
            list = {
                { id = "I00O", generate = true }, --COWARD
                { id = "I00P", generate = true }, --witch
                { id = "I00Q", generate = true }, --crown
                { id = "I00R", generate = true }, --ritual
                { id = "I00S", generate = true }, --acolyte
                { id = "I00T", generate = true }, --smorc
                { id = "I018", generate = true }, --boosters
                { id = "I019", generate = true }, --storm
                { id = "I01A", generate = true }, --princess
                { id = "I01B", generate = true }, --queen
                { id = "I01C", generate = true }, --pain
                { id = "I01D", generate = true }, --axe
                { id = "I01E", generate = true }, --bootpain
                { id = "I01F", generate = true }, --chestpain
                { id = "I01G", generate = true }, --headpain
                { id = "I01H", generate = true }, --king
                { id = "I01I", generate = true }, --jester
                { id = "I02J", generate = true }, --crimson
                { id = "I02K", generate = true }, --crimson
                { id = "I02L", generate = true }, --crimson
                { id = "I02I", generate = true }, --crimson
                { id = "I01J", generate = true }, --master
                { id = "I01W", generate = true }, --ice touch
                { id = "I02E", generate = true }, --blood drinker
                { id = "I02G", generate = true }, --primal tome
            }
        })


        --NewDropList("unique_items_supply", MergeTables({}, GetDropList("unique_items"))

        NewDropList("gems", {
            max = 2,
            rolls = 3,
            list = {
                { id = ITEM_STONE_DIAMOND, chance = 30. },
                { id = ITEM_STONE_AMETHYST, chance = 30. },
                { id = ITEM_STONE_TURQUOISE, chance = 30. },
                { id = ITEM_STONE_EMERALD, chance = 30. },
                { id = ITEM_STONE_MALACHITE, chance = 30. },
                { id = ITEM_STONE_JADE, chance = 30. },
                { id = ITEM_STONE_OPAL, chance = 30. },
                { id = ITEM_STONE_RUBY, chance = 30. },
                { id = ITEM_STONE_SAPPHIRE, chance = 30. },
                { id = ITEM_STONE_TOPAZ, chance = 30. },
                { id = ITEM_STONE_AMBER, chance = 30. },
                { id = ITEM_STONE_AQUAMARINE, chance = 30. },
            }
        })

        NewDropList("gems_supply", {
            max = 4,
            rolls = 5,
            list = {
                { id = ITEM_STONE_DIAMOND, chance = 30., max = 5 },
                { id = ITEM_STONE_AMETHYST, chance = 30., max = 5 },
                { id = ITEM_STONE_TURQUOISE, chance = 30., max = 5 },
                { id = ITEM_STONE_EMERALD, chance = 30., max = 5 },
                { id = ITEM_STONE_MALACHITE, chance = 30., max = 5 },
                { id = ITEM_STONE_JADE, chance = 30., max = 5 },
                { id = ITEM_STONE_OPAL, chance = 30., max = 5 },
                { id = ITEM_STONE_RUBY, chance = 30., max = 5 },
                { id = ITEM_STONE_SAPPHIRE, chance = 30., max = 5 },
                { id = ITEM_STONE_TOPAZ, chance = 30., max = 5 },
                { id = ITEM_STONE_AMBER, chance = 30., max = 5 },
                { id = ITEM_STONE_AQUAMARINE, chance = 30., max = 5 },
            }
        })

        NewDropList("consumables", {
            max = 2,
            rolls = 3,
            list = {
                { id = ITEM_POTION_HEALTH_WEAK, chance = 10.7, max = 3 },
                { id = ITEM_POTION_MANA_WEAK, chance = 10.7, max = 3 },
                { id = ITEM_POTION_HEALTH_HALF, chance = 8.3, max = 3 },
                { id = ITEM_POTION_MANA_HALF, chance = 8.3, max = 3 },
                { id = ITEM_POTION_ANTIDOTE, chance = 5.9 },
                { id = ITEM_POTION_ADRENALINE, chance = 6.5 },
                { id = ITEM_SCROLL_OF_TOWN_PORTAL, chance = 8.3 },
                { id = ITEM_SCROLL_OF_PROTECTION, chance = 7.4 },
            }
        })

        NewDropList("consumables_supply", {
            max = 3,
            rolls = 5,
            list = {
                { id = ITEM_POTION_HEALTH_WEAK, chance = 30., max = 5 },
                { id = ITEM_POTION_MANA_WEAK, chance = 30., max = 5 },
                { id = ITEM_POTION_HEALTH_HALF, chance = 30., max = 5 },
                { id = ITEM_POTION_MANA_HALF, chance = 30., max = 5 },
                { id = ITEM_POTION_ANTIDOTE, chance = 15., max = 5 },
                { id = ITEM_POTION_ADRENALINE, chance = 15., max = 5 },
                { id = ITEM_SCROLL_OF_PROTECTION, chance = 10., max = 5 },
            }
        })

        NewDropList("special_items", {
            list = {
                { id = "I027", chance = 50. },
                { id = "I01V", chance = 50. },
            }
        })

        NewDropList("shard", {
            list = {
                { id = "I01O", min = 1, max = 2, ignore_max = true },
            }
        })

        NewDropList("shard_event", {
            list = {
                { id = "I01O", min = 1, max = 3, ignore_max = true },
            }
        })

        NewDropList("gold_common", {
            list = {
                { id = "gold", min = 11, max = 37, ignore_max = true },
            }
        })

        NewDropList("gold_adv", {
            list = {
                { id = "gold", min = 20, max = 45, ignore_max = true },
            }
        })

        NewDropList("gold_chest", {
            list = {
                { id = "gold", min = 33, max = 100, ignore_max = true },
            }
        })

        NewDropList("gold_supply", {
            list = {
                { id = "gold", min = 75, max = 215, ignore_max = true },
            }
        })

        NewDropList("gold_boss", {
            list = {
                { id = "gold", min = 250, max = 1250, ignore_max = true },
            }
        })

        NewDropList("common_books", {
            list = {
                { id = "I017" },
                { id = "I016" },
                { id = "I015" },
                { id = "I014" },
                { id = "I013" },
                { id = "I00V" },
                { id = "I00U" },
                { id = "I028" },
                { id = "I029" },
                { id = "I02A" }
            }
        })

        NewDropList("rare_books", {
            list = {
                { id = "I023" },
                { id = "I024" },
                { id = "I025" },
                { id = "I021" },
                { id = "I020" },
                { id = "I01Z" },
                { id = "I022" },
                { id = "I02B" },
                { id = "I02C" },
                { id = "I02D" }
            }
        })


        NewDropList("books", {
            template = true,
            list = {
                { id = "rare_books", chance = 30. },
                { id = "common_books", chance = 70. }
            }
        })

        NewDropList("common_enemy", {
            template = true,
            max = 2,
            list = {
                { id = "common_item", chance = 10.5 },
                { id = "gems", chance = 15.5 },
                { id = "consumables", chance = 11. },
                { id = "books", chance = 33. },
                { id = "gold_common", chance = 70. }
            }
        })

        local new_items = MergeTables({}, GetDropList("common_item"))
        NewDropList("adv_item", new_items)
        new_items.quality[1].chance = 15.
        new_items.quality[2].chance = 35.

        NewDropList("adv_enemy", {
            template = true,
            max = 3,
            list = {
                { id = "adv_item", chance = 14.7 },
                { id = "gems", chance = 17.7 },
                { id = "consumables", chance = 11. },
                { id = "books", chance = 37. },
                { id = "special_items", chance = 5. },
                { id = "gold_adv", chance = 70. }
            }
        })


        NewDropList("magic_drop", {
            max = 1,
            rolls = 1,
            quality = {
                { quality = MAGIC_ITEM, chance = 100. },
                { quality = MAGIC_ITEM, chance = 100. },
                { quality = MAGIC_ITEM, chance = 100. },
            },
            list = {
                { id = GetGeneratedItemId(SWORD_WEAPON), chance = 30., generate = true  },
                { id = GetGeneratedItemId(GREATSWORD_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(AXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATAXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATBLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(STAFF_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(DAGGER_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BOW_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(CHEST_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HEAD_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HANDS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(LEGS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(NECKLACE_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(RING_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(SHIELD_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(ORB_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(BELT_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(QUIVER_OFFHAND), chance = 30., generate = true },
            }
        })

        NewDropList("boss_item", {
            min = 2,
            max = 4,
            rolls = 5,
            quality = {
                { quality = MAGIC_ITEM, chance = 50. },
                { quality = RARE_ITEM, chance = 50. },
                { quality = COMMON_ITEM, chance = 100. },
            },
            list = {
                { id = GetGeneratedItemId(SWORD_WEAPON), chance = 30., generate = true  },
                { id = GetGeneratedItemId(GREATSWORD_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(AXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATAXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATBLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(STAFF_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(DAGGER_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BOW_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(CHEST_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HEAD_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HANDS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(LEGS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(NECKLACE_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(RING_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(SHIELD_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(ORB_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(BELT_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(QUIVER_OFFHAND), chance = 30., generate = true },
            }
        })

        NewDropList("boss_enemy", {
            template = true,
            max = 5,
            list = {
                { id = "boss_item", chance = 38.5 },
                { id = "unique_items", chance = 7. },
                { id = "gems", chance = 11.3 },
                { id = "consumables", chance = 11. },
                { id = "books", chance = 37. },
                { id = "shard", chance = 10. },
                { id = "special_items", chance = 10. },
                { id = "gold_boss", chance = 70.}
            }
        })


        NewDropList("chest_item", {
            max = 5,
            rolls = 4,
            quality = {
                { quality = MAGIC_ITEM, chance = 15. },
                { quality = RARE_ITEM, chance = 40. },
                { quality = COMMON_ITEM, chance = 100. },
            },
            list = {
                { id = GetGeneratedItemId(SWORD_WEAPON), chance = 30., generate = true  },
                { id = GetGeneratedItemId(GREATSWORD_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(AXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATAXE_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(GREATBLUNT_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(STAFF_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(DAGGER_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(BOW_WEAPON), chance = 30., generate = true },
                { id = GetGeneratedItemId(CHEST_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HEAD_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(HANDS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(LEGS_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(NECKLACE_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(RING_JEWELRY), chance = 30., generate = true },
                { id = GetGeneratedItemId(SHIELD_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(ORB_OFFHAND), chance = 30., generate = true },
                { id = GetGeneratedItemId(BELT_ARMOR), chance = 30., generate = true },
                { id = GetGeneratedItemId(QUIVER_OFFHAND), chance = 30., generate = true },
            }
        })

        NewDropList("chest", {
            template = true,
            max = 4,
            list = {
                { id = "chest_item", chance = 47.5 },
                { id = "set_items", chance = 5. },
                { id = "gems", chance = 11.3 },
                { id = "consumables", chance = 11. },
                { id = "special_items", chance = 7. },
                { id = "gold_chest", chance = 90.}
            }
        })

        NewDropList("supply_crate", {
            template = true,
            max = 5,
            list = {
                { id = "chest_item", chance = 65.5 },
                { id = "unique_items", chance = 1. },
                { id = "gems_supply", chance = 20.3 },
                { id = "consumables_supply", chance = 20. },
                { id = "gold_supply", chance = 100.}
            }
        })



        RegisterTestCommand("D", function()
            local unit = CreateUnit(MONSTER_PLAYER, FourCC("u00D"), GetUnitX(PlayerHero[1]), GetUnitX(PlayerHero[1]), 0.)
            DelayAction(0., function() UnitDamageTarget(PlayerHero[1], unit, 99999999., true, false, ATTACK_TYPE_MAGIC, nil, nil) end)
            --DropForPlayer(, GetDropList("common_enemy"), 0)
        end)

    end

end