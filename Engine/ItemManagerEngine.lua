do



    local QUALITY_COLOR = {
        [COMMON_ITEM] = '|c00FFFFFF',
        [RARE_ITEM] = '|c00669FFF',
        [MAGIC_ITEM] = '|c00FFFF00',
        [SET_ITEM] = '|c0000FF00',
        [UNIQUE_ITEM] = '|c00FFD574'
    }

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

		ITEM_DATA[handle] = data
		return item
	end


    function EquipItem(unit, item, flag)
        local unit_data = GetUnitData(unit)
        local item_data = GetItemData(item)
        local point

        if item_data.TYPE == ITEM_TYPE_WEAPON then
            point = WEAPON_POINT
        elseif item_data.TYPE == ITEM_TYPE_ARMOR then
            if item_data.SUBTYPE == CHEST_ARMOR then point = CHEST_POINT
            elseif item_data.SUBTYPE == HANDS_ARMOR then point = HANDS_POINT
            elseif item_data.SUBTYPE == LEGS_ARMOR then point = LEGS_POINT
            elseif item_data.SUBTYPE == HEAD_ARMOR then point = HEAD_POINT end
        end

        if (unit_data.equip_point[point] ~= nil and unit_data.equip_point[point].SUBTYPE ~= FIST_WEAPON) and flag then
            EquipItem(unit, unit_data.equip_point[point], false)
        else
            if flag then
                unit_data.equip_point[point] = item_data
            else
                unit_data.equip_point[point] = point == WEAPON_POINT and unit_data.default_weapon or nil
            end
        end

        for i = 1, #item_data.BONUS do
            ModifyStat(unit, item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD, flag)
        end

        UpdateParameters(unit_data)
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
            local angle = AngleBetweenUnitXY(unit, GetItemX(item), GetItemY(item)) - 180.

            if DistanceBetweenUnitXY(unit, GetItemX(item), GetItemY(item)) <= 200. then
                UnitRemoveItem(unit, item)
                AddToInventory(1, item)
                IssuePointOrderById(unit, order_move, GetUnitX(unit) + 0.1, GetUnitY(unit) + 0.1)
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


end