do



    local QUALITY_COLOR = {
        [COMMON_ITEM] = '|c00FFFFFF',
        [RARE_ITEM] = '|c00669FFF',
        [MAGIC_ITEM] = '|c00FFFF00',
        [SET_ITEM] = '|c0000FF00',
        [UNIQUE_ITEM] = '|c00FFD574'
    }


    local ITEMTYPES_NAMES = {

    }

    local ITEMSUBTYPES_NAMES = {

    }

    local ATTRIBUTE_NAMES = {

    }


    --ATTACK_SPEED

    function GetItemAttributeName(attribute)
        return ATTRIBUTE_NAMES[attribute]
    end

    function GetItemSubTypeName(my_itemtype)
        return ITEMSUBTYPES_NAMES[my_itemtype]
    end

    function GetItemTypeName(my_itemtype)
        return ITEMTYPES_NAMES[my_itemtype]
    end

    ---@param quality number
    function GetQualityColor(quality)
        return QUALITY_COLOR[quality]
    end

    ---@param my_item item
    function GetItemNameColorized(my_item)
        local item_data = ITEM_DATA[GetHandleId(my_item)]
        return QUALITY_COLOR[item_data.QUALITY] .. item_data.NAME .. '|r'
    end


    ---@param my_item item
    function GetItemData(my_item)
        return ITEM_DATA[GetHandleId(my_item)]
    end


    function RemoveCustomItem(item)
        ITEM_DATA[GetHandleId(item)] = nil
        RemoveItem(item)
    end

    ---@param raw string
    ---@param x real
    ---@param y real
	function CreateCustomItem(raw, x, y)
		local id     = FourCC(raw)
		local item   = CreateItem(id, x, y)
		local handle = GetHandleId(item)
		local data   = {}

		for k, v in pairs(ITEM_TEMPLATE_DATA[id]) do
			data[k] = v
		end
		
		-- data это уже данные конкретного предмета с которыми можно делать что угодно
        data.item = item
        BlzSetItemName(item, data.NAME)

		ITEM_DATA[handle] = data
		return item
	end

    ---@param id integer
    ---@param x real
    ---@param y real
    function CreateCustomItem_Id(id, x, y)
        local item   = CreateItem(id, x, y)
        local handle = GetHandleId(item)
        local data   = {}

        for k, v in pairs(ITEM_TEMPLATE_DATA[id]) do
            data[k] = v
        end

        -- data это уже данные конкретного предмета с которыми можно делать что угодно
        data.item = item
        BlzSetItemName(item, data.NAME)

        ITEM_DATA[handle] = data
        return item
    end






    local DECLENSION_LIST = {
        [SWORD_WEAPON] = DECL_HE,
        [GREATSWORD_WEAPON] = DECL_HE,
        [BLUNT_WEAPON] = DECL_SHE,
        [GREATBLUNT_WEAPON] = DECL_SHE,
        [AXE_WEAPON] = DECL_HE,
        [GREATAXE_WEAPON] = DECL_HE,
        [DAGGER_WEAPON] = DECL_HE,
        [STAFF_WEAPON] = DECL_HE,
        [BOW_WEAPON] = DECL_HE,
        [NECKLACE_JEWELRY] = DECL_THEY,
        [RING_JEWELRY] = DECL_IT,
    }





    function GenerateItemSuffix(item, variation, quality)
        local item_data = GetItemData(item)
        local suffix = GetRandomInt(1, #ITEM_QUALITY_SUFFIX_LIST[quality][item_data.SUBTYPE])
        local affix = GetRandomInt(1, #ITEM_SUFFIX_LIST[suffix].affix_bonus)
        local max = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].max_bonuses

            item_data.NAME = ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. item_data.NAME .. ITEM_SUFFIX_LIST[suffix].name


            for i = 1, #ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus do
                if GetRandomInt(0, 100) <= ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].probability then

                        item_data.BONUS[#item_data.BONUS + 1] = {
                            PARAM = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].PARAM,
                            --VALUE = GetRandomReal(ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_min, ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_max),
                            METHOD = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].METHOD
                        }

                    if item_data.BONUS[#item_data.BONUS].METHOD == STRAIGHT_BONUS and item_data.BONUS[#item_data.BONUS].PARAM ~= CRIT_MULTIPLIER then
                        item_data.BONUS[#item_data.BONUS].VALUE = GetRandomInt(ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_min, ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_max)
                    else
                        item_data.BONUS[#item_data.BONUS].VALUE = GetRandomReal(ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_min, ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].parameter_bonus[i].value_max)
                    end

                    print(#item_data.BONUS)
                    print(GetParameterName(item_data.BONUS[#item_data.BONUS].PARAM))
                    print(item_data.BONUS[#item_data.BONUS].VALUE)

                    max = max - 1
                    if max <= 0 then break end
                end
            end

            for i = 1, #ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus do
                if GetRandomInt(0, 100) <= ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].probability and max > 0 then

                        item_data.SKILL_BONUS[#item_data.SKILL_BONUS + 1] = {
                            bonus_levels = GetRandomInt(ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].bonus_levels_min, ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].bonus_levels_max)
                        }

                        if ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].id ~= nil then
                            item_data.SKILL_BONUS[#item_data.SKILL_BONUS].id = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].id
                        elseif ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].category ~= nil then
                            item_data.SKILL_BONUS[#item_data.SKILL_BONUS].category = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix].skill_bonus[i].category
                        end

                    max = max - 1
                    if max <= 0 then break end

                end
            end

            BlzSetItemName(item, item_data.NAME)

    end


    function GenerateItemStoneSlots(item)
        local item_data = GetItemData(item)
        local stone_roll = GetRandomInt(0, 100)
        local stone = #QUALITY_STONE_COUNT[item_data.QUALITY].rolls

            while(stone > 0) do
                if QUALITY_STONE_COUNT[item_data.QUALITY].rolls[stone] ~= nil then
                        if stone_roll <= QUALITY_STONE_COUNT[item_data.QUALITY].rolls[stone] then
                            item_data.MAX_SLOTS = stone
                        end
                    stone = stone - 1
                else
                    break
                end
            end

    end


    function GenerateItemCost(item, level)
        local item_data = GetItemData(item)
        local stats_bonus = 0
        local stone_bonus = 0

                if item_data.BONUS ~= nil then
                    stats_bonus = #item_data.BONUS * 50
                end

                if item_data.MAX_SLOTS ~= nil then
                    stone_bonus = 30 * item_data.MAX_SLOTS
                end

            item_data.level = level
            item_data.cost = level * 30 + stats_bonus + stone_bonus
    end


    function GenerateItemLevel(item, level)
        local item_data = GetItemData(item)

            item_data.level = level

                if item_data.TYPE == ITEM_TYPE_WEAPON then
                    item_data.DAMAGE = 20 + GetRandomInt(-6, 6) + 2 * level
                elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                    item_data.DEFENCE = 15 + GetRandomInt(-6, 6) + 2 * level
                elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                    item_data.SUPPRESSION = 7 + GetRandomInt(-4, 4) + 2 * level
                end

            GenerateItemCost(item, level)
    end

    function GenerateItemStats(item, level, quality)
        local item_data = GetItemData(item)

            item_data.QUALITY = quality

        local item_variation = GetRandomInt(1, #QUALITY_ITEM_LIST[quality][item_data.SUBTYPE])

            item_data.frame_texture = QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][item_variation].icon
            item_data.NAME = QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][item_variation].name
            item_data.level = level

        if item_data.TYPE == ITEM_TYPE_WEAPON then
            if item_data.SUBTYPE ~= BOW_WEAPON then
                local physical_archetype = 65

                if item_data.SUBTYPE == STAFF_WEAPON then physical_archetype = 35
                elseif item_data.SUBTYPE == AXE_WEAPON or item_data.SUBTYPE == GREATAXE_WEAPON or item_data.SUBTYPE == GREATSWORD_WEAPON or item_data.SUBTYPE == GREATBLUNT_WEAPON then physical_archetype = 75
                elseif item_data.SUBTYPE == SWORD_WEAPON or item_data.SUBTYPE == DAGGER_WEAPON or item_data.SUBTYPE == BLUNT_WEAPON then physical_archetype = 50 end

                if GetRandomInt(0, 100) <= physical_archetype then
                    item_data.DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL
                    local attribute = GetRandomInt(1, 6)

                        if attribute == 1 or attribute > 4 then
                            item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                        elseif attribute == 2 then
                            item_data.ATTRIBUTE = HOLY_ATTRIBUTE
                        elseif attribute == 3 then
                            item_data.ATTRIBUTE = POISON_ATTRIBUTE
                        elseif attribute == 4 then
                            item_data.ATTRIBUTE = DARKNESS_ATTRIBUTE
                        end

                else
                    item_data.DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL
                    item_data.ATTRIBUTE = GetRandomInt(FIRE_ATTRIBUTE, DARKNESS_ATTRIBUTE)
                end
            else
                if GetRandomInt(1, 2) == 1 then
                    item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                else
                    item_data.ATTRIBUTE = POISON_ATTRIBUTE
                end
            end
        end

            GenerateItemLevel(item, level)
            GenerateItemStoneSlots(item)
            GenerateItemSuffix(item, item_variation, quality)
            GenerateItemCost(item, level)

            BlzSetItemName(item, item_data.NAME)
    end


    local TWOHANDED_LIST = {
        FIST_WEAPON           = false,
        BOW_WEAPON            = false,
        BLUNT_WEAPON          = false,
        GREATBLUNT_WEAPON     = true,
        SWORD_WEAPON          = false,
        GREATSWORD_WEAPON     = true,
        AXE_WEAPON            = false,
        GREATAXE_WEAPON       = true,
        DAGGER_WEAPON         = false,
        STAFF_WEAPON          = true,
        JAWELIN_WEAPON        = false,
        THROWING_KNIFE_WEAPON = true,
    }


    function IsWeaponTypeTwohanded(itemtype)
        return TWOHANDED_LIST[itemtype]
    end



    ---@param unit unit
    ---@param item item
    ---@param flag boolean
    ---@returns item
    function EquipItem(unit, item, flag)
        local unit_data = GetUnitData(unit)
        local item_data = GetItemData(item)
        local point
        local disarmed_item


            if item_data.TYPE == ITEM_TYPE_WEAPON then
                point = WEAPON_POINT

                if IsWeaponTypeTwohanded(item_data.SUBTYPE) and flag then
                    if item_data.equip_point[OFFHAND_POINT] ~= nil then
                        EquipItem(unit, unit_data.equip_point[OFFHAND_POINT], false)
                    end
                end

            elseif item_data.TYPE == ITEM_TYPE_ARMOR then

                if item_data.SUBTYPE == CHEST_ARMOR then point = CHEST_POINT
                elseif item_data.SUBTYPE == HANDS_ARMOR then point = HANDS_POINT
                elseif item_data.SUBTYPE == LEGS_ARMOR then point = LEGS_POINT
                elseif item_data.SUBTYPE == HEAD_ARMOR then point = HEAD_POINT end

            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then

                if item_data.SUBTYPE == RING_JEWELRY then
                    if flag then
                        point = unit_data.equip_point[RING_1_POINT] ~= nil and RING_2_POINT or RING_1_POINT
                    else
                        point = unit_data.equip_point[RING_1_POINT].item == item and RING_1_POINT or RING_2_POINT
                    end
                else
                    point = NECKLACE_POINT
                end

            end


            if (unit_data.equip_point[point] ~= nil and unit_data.equip_point[point].SUBTYPE ~= FIST_WEAPON) and flag then
                disarmed_item = unit_data.equip_point[point].item
                EquipItem(unit, unit_data.equip_point[point].item, false)
            end

                if flag then
                    unit_data.equip_point[point] = item_data
                else
                    unit_data.equip_point[point] = point == WEAPON_POINT and unit_data.default_weapon or nil
                end


            for i = 1, #item_data.STONE_SLOTS do
                ModifyStat(unit, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].METHOD, flag)
            end

            for i = 1, #item_data.BONUS do
                ModifyStat(unit, item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD, flag)
            end

            UpdateParameters(unit_data)

        return disarmed_item
    end




    function GiveItemToPlayerByUnit(unit, item)
        SetItemVisible(item, false)
        AddToInventory(GetPlayerId(GetOwningPlayer(unit))+1, item)
    end




    local trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerAddAction(trg, function()

        if GetOrderTargetItem() ~= nil then
            local item = GetOrderTargetItem()
            local unit = GetTriggerUnit()
            local angle = AngleBetweenXY_DEG(GetItemX(item), GetItemY(item), GetUnitX(unit), GetUnitY(unit))

            if DistanceBetweenUnitXY(unit, GetItemX(item), GetItemY(item)) <= 200. then
                UnitRemoveItem(unit, item)
                AddToInventory(1, item)
                IssuePointOrderById(unit, order_move, GetUnitX(unit) + 0.01, GetUnitY(unit) - 0.01)
            else
                IssuePointOrderById(unit, order_move, GetUnitX(unit) + Rx(50., angle), GetUnitY(unit) + Ry(50., angle))
            end

        end

    end)


    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_PICKUP_ITEM)
    TriggerAddAction(trg, function()
        if not IsItemInvulnerable(GetManipulatedItem()) then
            UnitRemoveItem(GetTriggerUnit(), GetManipulatedItem())
            SetItemVisible(GetManipulatedItem(), false)
        end
    end)




    function EnumItemsOnInit()

        ITEMTYPES_NAMES = {
            [ITEM_TYPE_WEAPON]     = LOCALE_LIST[my_locale].ITEM_TYPE_WEAPON_NAME,
            [ITEM_TYPE_ARMOR]      = LOCALE_LIST[my_locale].ITEM_TYPE_ARMOR_NAME,
            [ITEM_TYPE_JEWELRY]    = LOCALE_LIST[my_locale].ITEM_TYPE_JEWELRY_NAME,
            [ITEM_TYPE_OFFHAND]    = LOCALE_LIST[my_locale].ITEM_TYPE_OFFHAND_NAME,
            [ITEM_TYPE_CONSUMABLE] = LOCALE_LIST[my_locale].ITEM_TYPE_CONSUMABLE_NAME,
            [ITEM_TYPE_GEM]        = LOCALE_LIST[my_locale].ITEM_TYPE_GEM_NAME
        }

         ITEMSUBTYPES_NAMES = {
            [BOW_WEAPON]            = LOCALE_LIST[my_locale].BOW_WEAPON_NAME,
            [BLUNT_WEAPON]          = LOCALE_LIST[my_locale].BLUNT_WEAPON_NAME,
            [GREATBLUNT_WEAPON]     = LOCALE_LIST[my_locale].GREATBLUNT_WEAPON_NAME,
            [SWORD_WEAPON]          = LOCALE_LIST[my_locale].SWORD_WEAPON_NAME,
            [GREATSWORD_WEAPON]     = LOCALE_LIST[my_locale].GREATSWORD_WEAPON_NAME,
            [AXE_WEAPON]            = LOCALE_LIST[my_locale].AXE_WEAPON_NAME,
            [GREATAXE_WEAPON]       = LOCALE_LIST[my_locale].GREATAXE_WEAPON_NAME,
            [DAGGER_WEAPON]         = LOCALE_LIST[my_locale].DAGGER_WEAPON_NAME,
            [STAFF_WEAPON]          = LOCALE_LIST[my_locale].STAFF_WEAPON_NAME,
            [JAWELIN_WEAPON]        = LOCALE_LIST[my_locale].JAWELIN_WEAPON_NAME,
            [HEAD_ARMOR]            = LOCALE_LIST[my_locale].HEAD_ARMOR_NAME,
            [CHEST_ARMOR]           = LOCALE_LIST[my_locale].CHEST_ARMOR_NAME,
            [LEGS_ARMOR]            = LOCALE_LIST[my_locale].LEGS_ARMOR_NAME,
            [HANDS_ARMOR]           = LOCALE_LIST[my_locale].HANDS_ARMOR_NAME,
            [RING_JEWELRY]          = LOCALE_LIST[my_locale].RING_JEWELRY_NAME,
            [NECKLACE_JEWELRY]      = LOCALE_LIST[my_locale].NECKLACE_JEWELRY_NAME,
            [THROWING_KNIFE_WEAPON] = LOCALE_LIST[my_locale].THROWING_KNIFE_WEAPON_NAME,
        }

         ATTRIBUTE_NAMES = {
             [PHYSICAL_ATTRIBUTE]     = LOCALE_LIST[my_locale].PHYSICAL_ATTRIBUTE_NAME,
             [FIRE_ATTRIBUTE]         = LOCALE_LIST[my_locale].FIRE_ATTRIBUTE_NAME,
             [ICE_ATTRIBUTE]          = LOCALE_LIST[my_locale].ICE_ATTRIBUTE_NAME,
             [LIGHTNING_ATTRIBUTE]    = LOCALE_LIST[my_locale].LIGHTNING_ATTRIBUTE_NAME,
             [POISON_ATTRIBUTE]       = LOCALE_LIST[my_locale].POISON_ATTRIBUTE_NAME,
             [ARCANE_ATTRIBUTE]       = LOCALE_LIST[my_locale].ARCANE_ATTRIBUTE_NAME,
             [DARKNESS_ATTRIBUTE]     = LOCALE_LIST[my_locale].DARKNESS_ATTRIBUTE_NAME,
             [HOLY_ATTRIBUTE]         = LOCALE_LIST[my_locale].HOLY_ATTRIBUTE_NAME
         }



        --QUALITY_ITEM_LIST[COMMON_ITEM][SWORD_WEAPON][1].name = LOCALE_LIST[my_locale].GENERIC_SWORD_NAME_1
       -- QUALITY_ITEM_LIST[COMMON_ITEM][SWORD_WEAPON][2].name = LOCALE_LIST[my_locale].GENERIC_SWORD_NAME_2
        --QUALITY_ITEM_LIST[COMMON_ITEM][SWORD_WEAPON][3].name = LOCALE_LIST[my_locale].GENERIC_SWORD_NAME_3

        EnumItemsInRect(bj_mapInitialPlayableArea, nil, function()

            if ITEM_TEMPLATE_DATA[GetItemTypeId(GetEnumItem())] ~= nil then
                local my_item = CreateCustomItem_Id(GetItemTypeId(GetEnumItem()), GetItemX(GetEnumItem()), GetItemY(GetEnumItem()))
                GenerateItemLevel(my_item, 1)
                RemoveItem(GetEnumItem())
            end

        end)

    end


end