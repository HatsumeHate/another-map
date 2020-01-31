do



    local QUALITY_COLOR = {
        [COMMON_ITEM] = '|c00FFFFFF',
        [RARE_ITEM] = '|c00669FFF',
        [MAGIC_ITEM] = '|c00FFFF00',
        [SET_ITEM] = '|c0000FF00',
        [UNIQUE_ITEM] = '|c00FFD574'
    }

    local EFFECT_QUALITY_COLOR = {
        [COMMON_ITEM]   = { r = 255, g = 255, b = 255 },
        [RARE_ITEM]     = { r = 102, g = 159, b = 255 },
        [MAGIC_ITEM]    = { r = 255, g = 255, b = 0 },
        [SET_ITEM]      = { r = 0, g = 255, b = 0 },
        [UNIQUE_ITEM]   = { r = 255, g = 213, b = 116 },
    }

    ITEMSUBTYPES_EFFECT_SCALE = {
        [BOW_WEAPON]            = 0.85,
        [BLUNT_WEAPON]          = 0.75,
        [GREATBLUNT_WEAPON]     = 0.85,
        [SWORD_WEAPON]          = 0.75,
        [GREATSWORD_WEAPON]     = 0.85,
        [AXE_WEAPON]            = 0.75,
        [GREATAXE_WEAPON]       = 0.85,
        [DAGGER_WEAPON]         = 0.7,
        [STAFF_WEAPON]          = 0.85,
        [JAWELIN_WEAPON]        = 1.,
        [HEAD_ARMOR]            = 0.5,
        [CHEST_ARMOR]           = 0.65,
        [LEGS_ARMOR]            = 0.55,
        [HANDS_ARMOR]           = 0.55,
        [RING_JEWELRY]          = 0.5,
        [NECKLACE_JEWELRY]      = 0.7,
        [THROWING_KNIFE_WEAPON] = 0.7,
        [SHIELD_OFFHAND]        = 0.65,
        [ORB_OFFHAND]           = 0.65,
    }

    local ITEMTYPES_NAMES = {

    }

    local ITEMSUBTYPES_NAMES = {

    }

    local ATTRIBUTE_NAMES = {

    }


    function GetRandomWeaponType()
        return GetRandomInt(BOW_WEAPON, STAFF_WEAPON)
    end

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

    ---@param quality number
    function GetQualityEffectColor(quality)
        return EFFECT_QUALITY_COLOR[quality]
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




    MIN_GOLD_SCALE = 0.6
    MAX_GOLD_SCALE = 1.
    MIN_GOLD_SCALE_AMOUNT = 25
    MAX_GOLD_SCALE_AMOUNT = 150


    function CreateQualityEffect(item)
        local data = GetItemData(item)
        local string = "QualityGlow.mdx"

            for i = 1, 6 do
                if GetLocalPlayer() == Player(i-1) then
                    if not IsItemVisible(item) then
                        string = ""
                    end
                end
            end

            local color_table = GetQualityEffectColor(data.QUALITY)
            data.quality_effect = AddSpecialEffect(string, GetItemX(item), GetItemY(item))
            BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
            BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
    end


    ---@param player integer
    ---@param amount integer
    ---@param x real
    ---@param y real
    function CreateGoldStack(amount, x, y, player)
        local str = ""

        if GetLocalPlayer() == Player(player) then
            str = "Items\\Money.mdl"
        end

        local effect = AddSpecialEffect(str, x, y)
        local rect = Rect(x - 45., y - 45., x + 45., y + 45.)
        local region = CreateRegion()
        local timer = CreateTimer()

            RegionAddRect(region, rect)
            BlzSetSpecialEffectYaw(effect, GetRandomInt(1, 360) * bj_DEGTORAD)

            local result_scale = (amount  / MAX_GOLD_SCALE_AMOUNT) + MIN_GOLD_SCALE

            if result_scale < MIN_GOLD_SCALE then result_scale = MIN_GOLD_SCALE
            elseif result_scale > MAX_GOLD_SCALE then result_scale = MAX_GOLD_SCALE end


            AddSoundForPlayerVolumeZ("Sound\\gold.wav", x, y, BlzGetLocalSpecialEffectZ(effect), 110, 2100., player)

            local trg = CreateTrigger()
            TriggerRegisterEnterRegionSimple(trg, region)
            TriggerAddAction(trg, function()

                if GetOwningPlayer(GetTriggerUnit()) == Player(player) then
                    SetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD) + amount)
                    AddSoundForPlayerVolumeZ("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", x, y, BlzGetLocalSpecialEffectZ(effect), 127, 2200., player)
                    GoldText(x, y, amount)
                    DestroyEffect(effect)
                    RemoveRegion(region)
                    DestroyTrigger(trg)
                    RemoveRect(rect)
                    DestroyTimer(timer)
                end

            end)

            TimerStart(timer, 70., false, function()
                DestroyEffect(effect)
                RemoveRegion(region)
                DestroyTrigger(trg)
                RemoveRect(rect)
                DestroyTimer(timer)
            end)

    end

    ---@param raw string
    ---@param x real
    ---@param y real
	function CreateCustomItem(raw, x, y)
        if raw == 0 then return end
		local id     = FourCC(raw)
		local item   = CreateItem(id, x, y)
		local handle = GetHandleId(item)
		local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            data.item = item
            BlzSetItemName(item, data.NAME)

            ITEM_DATA[handle] = data

            DelayAction(0.001, function()

                if data.model ~= nil then
                    BlzSetItemStringField(item, ITEM_SF_MODEL_USED, data.model)
                end

                if data.flippy ~= nil and data.flippy then
                    local volume = 128

                        for i = 1, 6 do
                            if GetLocalPlayer() == Player(i-1) then
                                if not IsItemVisible(item) then
                                    volume = 0
                                end
                            end
                        end

                        AddSoundVolume("Sound\\flippy.wav", x, y, volume, 2100.)
                        TimerStart(CreateTimer(), 0.48, false, function()
                            if data.soundpack ~= nil then AddSoundVolume(data.soundpack.drop, x, y, volume, 2100.) end
                            CreateQualityEffect(item)
                        end)

                else
                    local volume = 128

                        for i = 1, 6 do
                            if GetLocalPlayer() == Player(i-1) then
                                if not IsItemVisible(item) then
                                    volume = 0
                                end
                            end
                        end

                        if data.soundpack ~= nil then
                            AddSoundVolume(data.soundpack.drop, x, y, volume, 2100.)
                        end

                end
            end)


            GenerateItemLevel(item, 1)
            if data.TYPE == ITEM_TYPE_SKILLBOOK then GenerateItemBookSkill(item) end

		return item
	end

    ---@param id integer
    ---@param x real
    ---@param y real
    function CreateCustomItem_Id(id, x, y)
        local item   = CreateItem(id, x, y)
        local handle = GetHandleId(item)
        local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            data.item = item
            BlzSetItemName(item, data.NAME)

            ITEM_DATA[handle] = data
            GenerateItemLevel(item, 1)
            if data.TYPE == ITEM_TYPE_SKILLBOOK then GenerateItemBookSkill(item) end

                if data.flippy ~= nil and data.flippy then
                    CreateQualityEffect(item)
                end

        return item
    end




    local function GetParameterPreset(param)
        if param.type == SINGLE_PARAMETER then
            return param
        else
            return GetParameterPreset(param.parameters[GetRandomInt(1, #param.parameters)])
        end
    end


    function GenerateItemBookSkill(item)
        local item_data = GetItemData(item)

            item_data.improving_skill = item_data.skill_category[GetRandomInt(1, #item_data.skill_category)]
            item_data.item_description = item_data.item_description .. "|n" .. GetSkillName(item_data.improving_skill)

    end


    function GenerateItemSuffix(item, variation, quality)
        local item_data = GetItemData(item)
        local suffix = ITEM_QUALITY_SUFFIX_LIST[quality][item_data.SUBTYPE][GetRandomInt(1, #ITEM_QUALITY_SUFFIX_LIST[quality][item_data.SUBTYPE])]
        local affix = GetRandomInt(ITEM_SUFFIX_LIST[suffix].min_affix, ITEM_SUFFIX_LIST[suffix].max_affix)
        local preset = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix]
        local min = QUALITY_ITEM_BONUS_COUNT[quality].min
        local bonus_parameters_count = GetRandomInt(min, QUALITY_ITEM_BONUS_COUNT[quality].max) + preset.additional_parameter

        if bonus_parameters_count > #preset.parameter_bonus then bonus_parameters_count = #preset.parameter_bonus end
        local parameters_list = GetRandomIntTable(1, #preset.parameter_bonus, bonus_parameters_count)


        item_data.BONUS = {}

            for i = 1, #parameters_list do
                local parameter = GetParameterPreset(preset.parameter_bonus[parameters_list[i]])

                        if GetRandomInt(0, 100) <= parameter.probability or #item_data.BONUS < min then

                            item_data.BONUS[#item_data.BONUS + 1] = {
                                PARAM = parameter.PARAM,
                                METHOD = parameter.METHOD
                            }

                            if item_data.BONUS[#item_data.BONUS].METHOD == STRAIGHT_BONUS and item_data.BONUS[#item_data.BONUS].PARAM ~= CRIT_MULTIPLIER then
                                item_data.BONUS[#item_data.BONUS].VALUE = GetRandomInt(parameter.value_min, parameter.value_max)
                            else
                                item_data.BONUS[#item_data.BONUS].VALUE = GetRandomReal(parameter.value_min, parameter.value_max)
                                item_data.BONUS[#item_data.BONUS].VALUE = math.floor(item_data.BONUS[#item_data.BONUS].VALUE * 1000.) / 1000.
                            end

                            bonus_parameters_count = bonus_parameters_count - 1
                        end

            end



            item_data.NAME = ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. item_data.NAME .. ITEM_SUFFIX_LIST[suffix].name


        item_data.SKILL_BONUS = {}

            if bonus_parameters_count > 0 and preset.skill_bonus ~= nil and #preset.skill_bonus.can_generate_for > 0 then
                local gen = preset.skill_bonus.can_generate_for[GetRandomInt(1, #preset.skill_bonus.can_generate_for)]
                local class = preset.skill_bonus[gen]
                local category = class.available_category[GetRandomInt(1, #class.available_category)]

                    if GetRandomInt(0, 100) <= class.skill_bonus_probability then

                            item_data.SKILL_BONUS[#item_data.SKILL_BONUS + 1] = {
                                bonus_levels = GetRandomInt(class.min_level_skill, class.max_level_skill),
                                id = CLASS_SKILL_LIST[gen][category][GetRandomInt(1, #CLASS_SKILL_LIST[gen][category])]
                            }


                            if bonus_parameters_count > 1 then
                                category = class.available_category[GetRandomInt(1, #class.available_category)]
                                local skill_id = CLASS_SKILL_LIST[gen][category][GetRandomInt(1, #CLASS_SKILL_LIST[gen][category])]

                                if skill_id == item_data.SKILL_BONUS[#item_data.SKILL_BONUS].id then
                                    item_data.SKILL_BONUS[#item_data.SKILL_BONUS].bonus_levels = item_data.SKILL_BONUS[#item_data.SKILL_BONUS].bonus_levels + 1
                                else
                                    item_data.SKILL_BONUS[#item_data.SKILL_BONUS + 1] = {
                                        bonus_levels = GetRandomInt(class.min_level_skill, class.max_level_skill),
                                        id = skill_id
                                    }
                                end

                            end

                    elseif GetRandomInt(0, 100) <= class.category_bonus_probability then

                        item_data.SKILL_BONUS[#item_data.SKILL_BONUS + 1] = {
                            bonus_levels = GetRandomInt(class.min_level_category, class.max_level_category),
                            category = category
                        }

                    end

            end


            BlzSetItemName(item, item_data.NAME)

    end


    function GenerateItemStoneSlots(item)
        local item_data = GetItemData(item)
        local stone = #QUALITY_STONE_COUNT[item_data.QUALITY].rolls

            while(stone > 0) do
                local stone_roll = GetRandomInt(0, 100)

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
                    item_data.DAMAGE = R2I(20 * GetRandomReal(0.75, 1.25)) + 2 * level
                elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                    item_data.DEFENCE = R2I(15 * GetRandomReal(0.75, 1.25)) + 1 * level
                elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                    item_data.SUPPRESSION = R2I(7 * GetRandomReal(0.75, 1.25)) + 1 * level
                end

            GenerateItemCost(item, level)
    end


    function GenerateItemStats(item, level, quality)
        local item_data = GetItemData(item)
        local item_variation = GetRandomInt(1, #QUALITY_ITEM_LIST[quality][item_data.SUBTYPE])
        local item_preset = QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][item_variation]


            item_data.QUALITY = quality
            item_data.frame_texture = item_preset.icon
            item_data.NAME = item_preset.name
            item_data.level = level
            item_data.soundpack = item_preset.soundpack


                if item_data.TYPE == ITEM_TYPE_WEAPON then

                    if item_data.SUBTYPE ~= BOW_WEAPON then
                        local physical_archetype = 65

                        if item_data.SUBTYPE == STAFF_WEAPON then physical_archetype = 35
                        elseif item_data.SUBTYPE == AXE_WEAPON or item_data.SUBTYPE == GREATAXE_WEAPON or item_data.SUBTYPE == GREATSWORD_WEAPON or item_data.SUBTYPE == GREATBLUNT_WEAPON then physical_archetype = 75
                        elseif item_data.SUBTYPE == SWORD_WEAPON or item_data.SUBTYPE == DAGGER_WEAPON or item_data.SUBTYPE == BLUNT_WEAPON then physical_archetype = 50 end

                        if GetRandomInt(0, 100) <= physical_archetype then
                            item_data.DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL
                            local attribute_roll = GetRandomInt(1, 6)

                                if attribute_roll == 1 or attribute_roll > 4 then
                                    item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                                elseif attribute_roll == 2 then
                                    item_data.ATTRIBUTE = HOLY_ATTRIBUTE
                                elseif attribute_roll == 3 then
                                    item_data.ATTRIBUTE = POISON_ATTRIBUTE
                                elseif attribute_roll == 4 then
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

                if item_data.TYPE == ITEM_TYPE_WEAPON then
                    item_data.DAMAGE = item_data.DAMAGE * item_preset.modificator
                elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                    item_data.DEFENCE = item_data.DEFENCE * item_preset.modificator
                elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                    item_data.SUPPRESSION = item_data.SUPPRESSION * item_preset.modificator
                end

            BlzSetItemName(item, item_data.NAME)
    end


    local TWOHANDED_LIST = {
        FIST_WEAPON           = false,
        BOW_WEAPON            = true,
        BLUNT_WEAPON          = false,
        GREATBLUNT_WEAPON     = true,
        SWORD_WEAPON          = false,
        GREATSWORD_WEAPON     = true,
        AXE_WEAPON            = false,
        GREATAXE_WEAPON       = true,
        DAGGER_WEAPON         = false,
        STAFF_WEAPON          = true,
        JAWELIN_WEAPON        = false,
        THROWING_KNIFE_WEAPON = false,
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
                        disarmed_item = item_data.equip_point[OFFHAND_POINT].item
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

            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                point = OFFHAND_POINT
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

        if GetOrderTargetItem() ~= nil and GetItemType(GetOrderTargetItem()) ~= ITEM_TYPE_POWERUP then
            local item = GetOrderTargetItem()
            local unit = GetTriggerUnit()
            local angle = AngleBetweenXY_DEG(GetItemX(item), GetItemY(item), GetUnitX(unit), GetUnitY(unit))

                if DistanceBetweenUnitXY(unit, GetItemX(item), GetItemY(item)) <= 200. then
                    local item_data = GetItemData(item)

                    UnitRemoveItem(unit, item)
                    IssuePointOrderById(unit, order_move, GetUnitX(unit) + 0.01, GetUnitY(unit) - 0.01)
                    local done =  AddToInventory(GetPlayerId(GetOwningPlayer(unit)) + 1, item)

                        if done and item_data.quality_effect ~= nil then
                            DestroyEffect(item_data.quality_effect)
                        end
                else
                    IssuePointOrderById(unit, order_move, GetItemX(item) + Rx(25., angle), GetItemY(item) + Ry(25., angle))
                end

            item = nil
            unit = nil
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



    trg = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_USE_ITEM)
    TriggerAddAction(trg, function()
        local player = GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1
            OnItemUse(GetTriggerUnit(), GetManipulatedItem(), GetEventTargetUnit())

            if BlzFrameIsVisible(PlayerInventoryFrame[player]) or GetItemTypeId(GetManipulatedItem()) == ITEM_TYPE_CHARGED then
                UpdateInventoryWindow(player)
            end

    end)



    function EnumItemsOnInit()

        ITEMTYPES_NAMES = {
            [ITEM_TYPE_WEAPON]     = LOCALE_LIST[my_locale].ITEM_TYPE_WEAPON_NAME,
            [ITEM_TYPE_ARMOR]      = LOCALE_LIST[my_locale].ITEM_TYPE_ARMOR_NAME,
            [ITEM_TYPE_JEWELRY]    = LOCALE_LIST[my_locale].ITEM_TYPE_JEWELRY_NAME,
            [ITEM_TYPE_OFFHAND]    = LOCALE_LIST[my_locale].ITEM_TYPE_OFFHAND_NAME,
            [ITEM_TYPE_CONSUMABLE] = LOCALE_LIST[my_locale].ITEM_TYPE_CONSUMABLE_NAME,
            [ITEM_TYPE_GEM]        = LOCALE_LIST[my_locale].ITEM_TYPE_GEM_NAME,
            [ITEM_TYPE_SKILLBOOK]  = LOCALE_LIST[my_locale].ITEM_TYPE_SKILLBOOK
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
            [SHIELD_OFFHAND]        = LOCALE_LIST[my_locale].SHIELD_OFFHAND_NAME,
            [ORB_OFFHAND]           = LOCALE_LIST[my_locale].ORB_OFFHAND_NAME,
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


        EnumItemsInRect(bj_mapInitialPlayableArea, nil, function()
            local item = GetEnumItem()

                if ITEM_TEMPLATE_DATA[GetItemTypeId(item)] ~= nil then
                    local my_item = CreateCustomItem_Id(GetItemTypeId(item), GetItemX(item), GetItemY(item))
                    GenerateItemLevel(my_item, 1)
                    RemoveItem(item)
                end

            item = nil
        end)

    end


end