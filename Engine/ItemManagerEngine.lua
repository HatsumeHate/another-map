do



    local QUALITY_COLOR = 0
    QUALITY_LIGHT_COLOR = nil
    local EFFECT_QUALITY_COLOR = 0

    ITEMSUBTYPES_EFFECT_SCALE = 0
    ITEMSUBTYPES_MODELS = 0
    PlayerPickUpItemFlag = 0

    local ITEMTYPES_NAMES = 0
    local ITEMSUBTYPES_NAMES = 0
    local ATTRIBUTE_NAMES = 0
    local ATTRIBUTE_COLOR = 0
    local TWOHANDED_LIST = 0
    local AffixTable = 0

    MIN_GOLD_SCALE = 0.6
    MAX_GOLD_SCALE = 1.
    MIN_GOLD_SCALE_AMOUNT = 25
    MAX_GOLD_SCALE_AMOUNT = 150




    function GetRandomWeaponType()
        return GetRandomInt(BOW_WEAPON, STAFF_WEAPON)
    end

    --ATTACK_SPEED

    function GetAttributeName(attribute)
        return ATTRIBUTE_NAMES[attribute]
    end

    function GetAttributeColor(attribute)
        return ATTRIBUTE_COLOR[attribute]
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
        local item_data = GetItemData(my_item)
        return QUALITY_COLOR[item_data.QUALITY] .. item_data.NAME .. '|r'
    end


    ---@param my_item item
    function GetItemData(my_item)
        return ITEM_DATA[my_item] or nil
    end


    function RemoveCustomItem(item)
        if item == nil then return end
        if ITEM_DATA[item].quality_effect then DestroyEffect(ITEM_DATA[item].quality_effect) end
        if ITEM_DATA[item].quality_effect_light then DestroyEffect(ITEM_DATA[item].quality_effect_light) end
        if ITEM_DATA[item].model_effect then DestroyEffect(ITEM_DATA[item].model_effect) end
        ITEM_DATA[item] = nil
        RemoveItem(item)
    end






    function CreateQualityEffect(item)
        local data = GetItemData(item)
        local color_table = GetQualityEffectColor(data.QUALITY)
        local ix, iy = GetItemX(item), GetItemY(item)

            if data.owner then
                if GetLocalPlayer() == Player(data.owner) then
                    data.quality_effect = AddSpecialEffect("QualityGlow.mdx", ix, iy)
                    BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                    BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                    data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[data.QUALITY], ix, iy)
                    BlzSetSpecialEffectZ(data.quality_effect_light, GetZ(ix, iy) + 10.)
                else
                    data.quality_effect = AddSpecialEffect("", ix, iy)
                    data.quality_effect_light = AddSpecialEffect("", ix, iy)
                end
            elseif not data.picked_up then
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", ix, iy)
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[data.QUALITY], ix, iy)
                BlzSetSpecialEffectZ(data.quality_effect_light, GetZ(ix, iy) + 10.)
            end



    end

    function ApplyQualityGlowColour(item)
        local item_data = GetItemData(item)
        local color_table = GetQualityEffectColor(item_data.QUALITY)

            BlzSetSpecialEffectColor(item_data.quality_effect, color_table.r, color_table.g, color_table.b)
            BlzSetSpecialEffectScale(item_data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[item_data.SUBTYPE])
            --item_data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[item_data.QUALITY], GetItemX(item), GetItemY(item))
            --BlzSetSpecialEffectZ(item_data.quality_effect_light, GetZ(GetItemX(item), GetItemY(item)) + 10.)
        --print("apply colour")
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
            BlzSetSpecialEffectOrientation(effect, GetRandomInt(1, 360) * bj_DEGTORAD, 0.,0.)
            --BlzSetSpecialEffectYaw(effect, GetRandomInt(1, 360) * bj_DEGTORAD)

            local result_scale = (amount  / MAX_GOLD_SCALE_AMOUNT) + MIN_GOLD_SCALE

            if result_scale < MIN_GOLD_SCALE then result_scale = MIN_GOLD_SCALE
            elseif result_scale > MAX_GOLD_SCALE then result_scale = MAX_GOLD_SCALE end

            AddSoundForPlayerVolumeZ("Sound\\gold.wav", x, y, 35., 117, 2100., 4200., player)

            local trg = CreateTrigger()
            TriggerRegisterEnterRegionSimple(trg, region)
            TriggerAddAction(trg, function()

                if GetOwningPlayer(GetTriggerUnit()) == Player(player) then
                    DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdx", GetTriggerUnit(), "origin"))
                    SetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD) + amount)
                    AddSoundForPlayerVolumeZ("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", x, y, 35., 127, 2200., 4200., player)
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
    ---@param drop_animation boolean
    ---@param owner number
    ---@return item
    ---owner is 0 indexed
	function CreateCustomItem(raw, x, y, drop_animation, owner)
        if raw == 0 or not ITEM_TEMPLATE_DATA[FourCC(raw)] then return nil end
		local id     = FourCC(raw)
		local item   = CreateItem(id, x, y)
		local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            data.item = item
            data.actual_name = GetQualityColor(data.QUALITY) .. data.NAME .. '|r'
            BlzSetItemName(item, data.actual_name)
            data.owner = owner or nil

            x = GetItemX(item)
            y = GetItemY(item)
            local z = GetZ(x, y)


            if data.flippy then
                local color_table = GetQualityEffectColor(data.QUALITY)
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", x, y)
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                BlzSetSpecialEffectAlpha(data.quality_effect, 0)
            end


            ITEM_DATA[item] = data


            DelayAction(0., function()

                if owner then BlzSetItemSkin(item, FourCC("I01X")) end

                if drop_animation then
                    if data.flippy then

                        local model_path = ITEMSUBTYPES_MODELS[data.SUBTYPE].model

                        if data.owner then
                            if GetLocalPlayer() ~= Player(data.owner) then
                                model_path = ""
                            end
                        end

                        local item_effect = AddSpecialEffect(model_path, x, y)
                        BlzPlaySpecialEffect(item_effect, ANIM_TYPE_BIRTH)
                        BlzSetSpecialEffectScale(item_effect, ITEMSUBTYPES_MODELS[data.SUBTYPE].scale)
                        BlzSetSpecialEffectOrientation(item_effect, 270. * bj_DEGTORAD, 0., 0.)

                        if data.owner then AddSoundForPlayerVolumeZ("Sound\\flippy.wav", x, y, 35., 128, 2100., 4400., data.owner)
                        else AddSoundVolume("Sound\\flippy.wav", x, y, 128, 2100.) end
                        local timer = CreateTimer()
                        TimerStart(timer, 0.48, false, function()

                            if data.owner then
                                local s = ""

                                    if GetLocalPlayer() == Player(data.owner) then
                                        if data.quality_effect then
                                            BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                                            s = QUALITY_LIGHT_COLOR[data.QUALITY]
                                            BlzSetSpecialEffectPosition(data.quality_effect, x, y, z)
                                        end
                                        BlzSetItemSkin(item, GetItemTypeId(item))
                                    end

                                if data.quality_effect then
                                    data.quality_effect_light = AddSpecialEffect(s, x, y)
                                    BlzSetSpecialEffectZ(data.quality_effect_light, z + 10.)
                                end
                                if data.soundpack then AddSoundForPlayerVolumeZ(data.soundpack.drop, x, y, 35., 128, 2100., 4400., data.owner) end
                            else
                                if not data.picked_up then
                                    if data.quality_effect then
                                        BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                                        data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[data.QUALITY], x, y)
                                        BlzSetSpecialEffectZ(data.quality_effect_light, z + 10.)
                                    end
                                    BlzSetItemSkin(item, GetItemTypeId(item))
                                    if data.soundpack then AddSoundVolume(data.soundpack.drop, x, y, 128, 2100.) end
                                end
                            end

                            BlzSetSpecialEffectAlpha(item_effect, 0)
                            DestroyEffect(item_effect)
                            DestroyTimer(GetExpiredTimer())
                        end)

                    else

                        if data.owner then
                            AddSoundForPlayerVolumeZ(data.soundpack.drop, x, y, 35., 128, 2100., 4400., data.owner)
                            if GetLocalPlayer() == Player(data.owner) then BlzSetItemSkin(item, GetItemTypeId(item)) end
                        else
                            AddSoundVolume(data.soundpack.drop, x, y, 128, 2100.)
                            BlzSetItemSkin(item, GetItemTypeId(item))
                        end

                    end
                else
                    if data.owner then
                        if data.quality_effect then
                            local s = QUALITY_LIGHT_COLOR[data.QUALITY]

                            BlzSetSpecialEffectPosition(data.quality_effect, x, y, z + 10.)

                                if GetLocalPlayer() == Player(data.owner) then
                                    BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                                else
                                    BlzSetSpecialEffectAlpha(data.quality_effect, 0)
                                    s = ""
                                end

                            data.quality_effect_light = AddSpecialEffect(s, x, y)
                            BlzSetSpecialEffectZ(data.quality_effect_light, z + 10.)
                        end

                        if GetLocalPlayer() == Player(data.owner) then
                            BlzSetItemSkin(item, GetItemTypeId(item))
                        end

                    else
                        if not data.picked_up then

                            if data.quality_effect then
                                BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                                data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[data.QUALITY], x, y)
                                BlzSetSpecialEffectZ(data.quality_effect_light, z + 10.)
                            end

                            BlzSetItemSkin(item, GetItemTypeId(item))
                        end
                    end
                end
            end)

            GenerateItemLevel(item, 1)
            if data.TYPE == ITEM_TYPE_SKILLBOOK then GenerateItemBookSkill(item)
            elseif data.TYPE == ITEM_TYPE_CONSUMABLE and data.cooldown_type then BlzSetItemIntegerField(item, ITEM_IF_COOLDOWN_GROUP, data.cooldown_type) end


		return item
	end

    ---@param id integer
    ---@param x real
    ---@param y real
    function CreateCustomItem_Id(id, x, y)
        local item   = CreateItem(id, x, y)
        local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            ITEM_DATA[item] = data
            data.item = item

            x = GetItemX(item)
            y = GetItemY(item)

            if IsRandomGeneratedId(id) then GenerateItemStats(item, 1, COMMON_ITEM)
            else GenerateItemLevel(item, 1) end

            if data.flippy then
                local color_table = GetQualityEffectColor(data.QUALITY)
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", x, y)
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                data.quality_effect_light = AddSpecialEffect(QUALITY_LIGHT_COLOR[data.QUALITY], x, y)
            end

            if data.TYPE == ITEM_TYPE_SKILLBOOK then GenerateItemBookSkill(item)
            elseif data.TYPE == ITEM_TYPE_CONSUMABLE and data.cooldown_type then BlzSetItemIntegerField(item, ITEM_IF_COOLDOWN_GROUP, data.cooldown_type) end


            data.actual_name = GetQualityColor(data.QUALITY) .. data.NAME .. '|r'
            BlzSetItemName(item, GetQualityColor(data.QUALITY) .. data.actual_name .. "|r")

        return item
    end




    local function GetParameterPreset(param)
        if param.type == SINGLE_PARAMETER then
            return param
        else
            return GetParameterPreset(param.parameters[GetRandomInt(1, #param.parameters)])
        end
    end


    ---@param item item
    function GenerateItemBookSkill(item)
        local item_data = GetItemData(item)

        --item_data.improving_skill = "invalid"
        --item_data.item_description = "invalid"

        if item_data.skill_category then
            item_data.improving_skill = item_data.skill_category[GetRandomInt(1, #item_data.skill_category)]
            item_data.item_description = item_data.item_description .. "|n" .. GetSkillName(item_data.improving_skill)
        end

    end



    function GenerateItemSuffix(item, variation, quality)
        local item_data = GetItemData(item)

        --print("item type is " .. GetItemSubTypeName(item_data.SUBTYPE) .. " quality " .. item_data.QUALITY)

        local suffix = ITEM_QUALITY_SUFFIX_LIST[quality][item_data.SUBTYPE][GetRandomInt(1, #ITEM_QUALITY_SUFFIX_LIST[quality][item_data.SUBTYPE])]
        --print("suffix number " .. (suffix or "invalid"))
        local affix = ITEM_AFFIX_WORN

        for i = 1, #AffixTable[quality] do
            if Chance(AffixTable[quality][i].chance) then
                affix = AffixTable[quality][i].affix
                break
            end
        end

        --print("affix number " .. (affix or "invalid"))
        local preset = ITEM_SUFFIX_LIST[suffix].affix_bonus[affix]
        local min = QUALITY_ITEM_BONUS_COUNT[quality].min
        local bonus_parameters_count = GetRandomInt(min, QUALITY_ITEM_BONUS_COUNT[quality].max) + preset.additional_parameter

        if bonus_parameters_count > #preset.parameter_bonus then bonus_parameters_count = #preset.parameter_bonus end
        if bonus_parameters_count <= min then bonus_parameters_count = min end

        local parameters_list = GetRandomIntTable(1, #preset.parameter_bonus, bonus_parameters_count)
        local exclude_list = { }

        --print("ok")
        --print("affix " .. ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. " + " .. item_data.NAME .." + suffix " .. ITEM_SUFFIX_LIST[suffix].name)

        item_data.BONUS = {}

            for i = 1, #parameters_list do
                local skip = false
                local parameter = GetParameterPreset(preset.parameter_bonus[parameters_list[i]])

                    if #exclude_list > 0 then
                        for k = 1, #exclude_list do if parameter.PARAM == exclude_list[k] then skip = true; break end end
                    end

                    if parameter.exclude then
                        for v = 1, #parameter.exclude do exclude_list[#exclude_list+1] = parameter.exclude[v] end
                    end

                        if (GetRandomInt(0, 100) <= parameter.probability or #item_data.BONUS < min) and not skip then

                            --print("found " .. GetParameterName(parameter.PARAM) .. " method " .. parameter.METHOD)

                            local index = #item_data.BONUS + 1

                            item_data.BONUS[index] = {
                                PARAM = parameter.PARAM,
                                METHOD = parameter.METHOD,
                                delta = parameter.delta or nil,
                                delta_level = parameter.delta_level or nil,
                                delta_level_max = parameter.delta_level_max or nil
                            }
                            
                            local bonus = item_data.BONUS[index]

                            if bonus.METHOD == STRAIGHT_BONUS and not (bonus.PARAM == CRIT_MULTIPLIER or bonus.PARAM == HP_REGEN or bonus.PARAM == MP_REGEN) then
                                --print("straight start")
                                bonus.VALUE = GetRandomInt(parameter.value_min, parameter.value_max)
                                --print("straight end .. " .. item_data.BONUS[#item_data.BONUS].VALUE)
                            else
                                --print("mult start")
                                bonus.VALUE = GetRandomInt(math.floor((parameter.value_min * 100.) + 0.5), math.floor((parameter.value_max * 100.) + 0.5)) / 100.

                                if bonus.VALUE < parameter.value_min then bonus.VALUE = parameter.value_min
                                elseif bonus.VALUE > parameter.value_max then bonus.VALUE = parameter.value_max end

                            end

                            bonus.base = bonus.VALUE

                            if bonus.METHOD == STRAIGHT_BONUS and not bonus.delta and GeneratedScaling[bonus.PARAM] then
                                bonus.delta = GeneratedScaling[bonus.PARAM].delta
                                bonus.delta_level = GeneratedScaling[bonus.PARAM].delta_level
                                bonus.delta_level_max = GeneratedScaling[bonus.PARAM].delta_level_max
                            end

                            if bonus.delta then
                                local delta_level_bonus = math.floor(Current_Wave / bonus.delta_level)

                                if bonus.delta_level_max and delta_level_bonus > bonus.delta_level_max then
                                    delta_level_bonus = bonus.delta_level_max
                                end

                                bonus.VALUE = (bonus.base or 1) + bonus.delta * delta_level_bonus

                                    if IsWeaponTypeTwohanded(item_data.SUBTYPE) then
                                        bonus.VALUE = bonus.VALUE * 1.5

                                        if bonus.METHOD == STRAIGHT_BONUS and not (bonus.PARAM == CRIT_MULTIPLIER or bonus.PARAM == HP_REGEN or bonus.PARAM == MP_REGEN) then
                                            bonus.VALUE = math.floor(bonus.VALUE + 0.5)
                                        end

                                    end

                            end

                            bonus_parameters_count = bonus_parameters_count - 1
                        end

            end


            item_data.affix = affix
            item_data.suffix = suffix
            item_data.NAME = ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. item_data.NAME .. ITEM_SUFFIX_LIST[suffix].name

        --print("generator parameters done")

        item_data.SKILL_BONUS = {}

            if bonus_parameters_count > 0 and preset.skill_bonus and #preset.skill_bonus.can_generate_for > 0 then
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

                            bonus_parameters_count = bonus_parameters_count - 2
                        else
                            bonus_parameters_count = bonus_parameters_count - 1
                        end

                    elseif GetRandomInt(0, 100) <= class.category_bonus_probability then

                        item_data.SKILL_BONUS[#item_data.SKILL_BONUS + 1] = {
                            bonus_levels = GetRandomInt(class.min_level_category, class.max_level_category),
                            category = category
                        }

                        bonus_parameters_count = bonus_parameters_count - 1

                    end

            end

            if bonus_parameters_count > 0 and preset.effect_bonus and preset.effect_bonus[item_data.TYPE] then
                local effect_list = preset.effect_bonus[item_data.TYPE]
                local list_vars = #effect_list
                local random_list = GetRandomIntTable(1, list_vars, list_vars)

                    for i = 1, list_vars do
                        if Chance(effect_list[random_list[i]].chance) then
                            if not item_data.effect_bonus then item_data.effect_bonus = {} end
                            item_data.effect_bonus[#item_data.effect_bonus+1] = effect_list[random_list[i]].id
                            break
                        end
                    end
            end
            --print("generator skills done")

            item_data.actual_name = GetQualityColor(quality) .. item_data.NAME .. '|r'
            BlzSetItemName(item, item_data.actual_name)

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


    ---@param item item
    ---@param level number
    function GenerateItemCost(item, level)
        local item_data = GetItemData(item)
        local stats_bonus = 0
        local stone_bonus = 0
        local skill_bonus = 0
        local effect_bonus = 0
        local quality_modificator = 1.

            if item_data.BONUS then stats_bonus = #item_data.BONUS * 75 end
            if item_data.MAX_SLOTS then stone_bonus = 50 * item_data.MAX_SLOTS end
            if item_data.SKILL_BONUS and #item_data.SKILL_BONUS > 0 then
                for i = 1, #item_data.SKILL_BONUS do
                    if item_data.SKILL_BONUS[i].category then skill_bonus = skill_bonus + 100
                    else skill_bonus = skill_bonus + (40 * item_data.SKILL_BONUS[i].bonus_levels) end
                end
            end
            if item_data.effect_bonus and #item_data.effect_bonus > 0 then
                for i = 1, #item_data.effect_bonus do
                    effect_bonus = effect_bonus + 100
                end
            end

            if item_data.QUALITY == RARE_ITEM then quality_modificator = 1.1
            elseif item_data.QUALITY == MAGIC_ITEM then quality_modificator = 1.2 end

            item_data.level = level

            if stats_bonus > 0 or stone_bonus > 0 then
                item_data.cost = R2I((level * 30 + stats_bonus + stone_bonus + skill_bonus + effect_bonus) * item_data.stat_modificator * quality_modificator)
            end

            if item_data.legendary_effect then item_data.cost = item_data.cost * 2 end

    end


    ---@param item item
    ---@param value number
    function GenerateItemStatPreset(item, value)
        local item_data = GetItemData(item)

            if item_data.TYPE == ITEM_TYPE_WEAPON then
                item_data.DAMAGE = math.ceil(item_data.DAMAGE * value)
            elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                item_data.DEFENCE = math.ceil(item_data.DEFENCE * value)
                if item_data.SUBTYPE == BELT_ARMOR then item_data.SUPPRESSION = math.ceil(item_data.SUPPRESSION * value) end
            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                item_data.SUPPRESSION = math.ceil(item_data.SUPPRESSION * value)
            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                if item_data.SUBTYPE == SHIELD_OFFHAND then
                    item_data.DEFENCE = math.ceil(item_data.DEFENCE * value)
                    item_data.BLOCK = math.ceil(item_data.BLOCK * value)
                end
            end
    end


    ---@param item item
    ---@param level number
    function GenerateItemLevel(item, level)
        local item_data = GetItemData(item)

            item_data.level = level

                if item_data.TYPE == ITEM_TYPE_WEAPON then
                    item_data.DAMAGE = R2I(20 * GetRandomReal(0.75, 1.25)) + 2 * level
                elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                    item_data.DEFENCE = R2I(15 * GetRandomReal(0.75, 1.25)) + 1 * level
                    if item_data.SUBTYPE == BELT_ARMOR then
                        item_data.DEFENCE = math.ceil(item_data.DEFENCE * 0.5)
                        item_data.SUPPRESSION = math.ceil((R2I(7 * GetRandomReal(0.75, 1.25)) + 1 * level) * 0.5)
                    end
                elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                    item_data.SUPPRESSION = R2I(7 * GetRandomReal(0.75, 1.25)) + 1 * level
                elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                    if item_data.SUBTYPE == SHIELD_OFFHAND then
                        item_data.BLOCK = GetRandomInt(20, 35)
                        item_data.DEFENCE = R2I(15 * GetRandomReal(0.75, 1.25)) + 1 * level
                    else
                        item_data.ALLRESIST = GetRandomInt(3, 7) + math.floor((level * 0.5) + 0.5)
                    end
                end

        if item_data.BONUS then
            for i = 1, #item_data.BONUS do
                if item_data.BONUS[i].delta then
                    local delta_level_bonus = math.floor(Current_Wave / item_data.BONUS[i].delta_level)

                    if item_data.BONUS[i].delta_level_max and delta_level_bonus > item_data.BONUS[i].delta_level_max then
                        delta_level_bonus = item_data.BONUS[i].delta_level_max
                    end

                    item_data.BONUS[i].VALUE = (item_data.BONUS[i].base or 1) + item_data.BONUS[i].delta * delta_level_bonus
                end
            end
        end

            GenerateItemCost(item, level)
            if item_data.stat_modificator then GenerateItemStatPreset(item, item_data.stat_modificator) end
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
            item_data.stat_modificator = item_preset.modificator
            item_data.model = item_preset.model or nil
            item_data.texture = item_preset.texture or nil
            item_data.assassin_texture = item_preset.assassin_texture or nil
            item_data.item_variation = item_variation
            --print("1")
            ApplyQualityGlowColour(item)

                if item_data.TYPE == ITEM_TYPE_WEAPON then

                    if item_data.SUBTYPE ~= BOW_WEAPON then
                        local physical_archetype = 70

                        if item_data.SUBTYPE == STAFF_WEAPON then physical_archetype = 30
                        elseif item_data.SUBTYPE == AXE_WEAPON or item_data.SUBTYPE == GREATAXE_WEAPON or item_data.SUBTYPE == GREATSWORD_WEAPON or item_data.SUBTYPE == GREATBLUNT_WEAPON then physical_archetype = 80
                        elseif item_data.SUBTYPE == SWORD_WEAPON or item_data.SUBTYPE == DAGGER_WEAPON or item_data.SUBTYPE == BLUNT_WEAPON then physical_archetype = 60 end

                        if GetRandomInt(0, 100) <= physical_archetype then
                            item_data.DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL
                            local attribute_roll = GetRandomInt(1, 8)

                                if attribute_roll == 1 or attribute_roll > 4 then item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                                elseif attribute_roll == 2 then item_data.ATTRIBUTE = HOLY_ATTRIBUTE
                                elseif attribute_roll == 3 then item_data.ATTRIBUTE = POISON_ATTRIBUTE
                                elseif attribute_roll == 4 then item_data.ATTRIBUTE = DARKNESS_ATTRIBUTE end

                        else
                            item_data.DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL
                            item_data.ATTRIBUTE = GetRandomInt(FIRE_ATTRIBUTE, DARKNESS_ATTRIBUTE)
                        end

                        item_data.ATTRIBUTE_BONUS = GetRandomInt(0, 5)

                    else
                        local rnd = GetRandomInt(1, 5)
                        if rnd <= 3 then item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                        elseif rnd == 4 then item_data.ATTRIBUTE = ICE_ATTRIBUTE
                        elseif rnd == 5 then item_data.ATTRIBUTE = POISON_ATTRIBUTE end
                    end

                end

            GenerateItemLevel(item, level)
            --print("generate level")
            GenerateItemStoneSlots(item)
            --print("generate slots")
            GenerateItemSuffix(item, item_variation, quality)
            --print("generate affix suffix")
            GenerateItemCost(item, level)
            --print("generate cost")
            --GenerateItemStatPreset(item, item_preset.modificator)

            --item_data.NAME =
            --DelayAction(0.01, function()   end)

            item_data.actual_name = GetQualityColor(quality) .. item_data.NAME .. '|r'
            BlzSetItemName(item, item_data.actual_name)
            --print("generator done")
    end




    ---@param itemtype number
    function IsWeaponTypeTwohanded(itemtype)
        return TWOHANDED_LIST[itemtype] or false
    end



    ---@param unit unit
    ---@param item item
    ---@return boolean
    function IsItemEquipped(unit, item)
        local unit_data = GetUnitData(unit)

            for point = 1, NECKLACE_POINT do
                if unit_data.equip_point[point] and unit_data.equip_point[point].item == item then
                    return true
                end
            end

        return false
    end


    TraceBug = false


    ---@param unit unit
    ---@param item item
    ---@param flag boolean
    ---@returns item
    function EquipItem(unit, item, flag, offhand)
        local unit_data = GetUnitData(unit)
        local item_data = GetItemData(item)
        local point
        local disarmed_item

           --print("equip item is ".. GetItemName(item).. " state is " .. (flag and "equip" or "unequip"))

            if item_data.TYPE == ITEM_TYPE_OFFHAND or (offhand and item_data.TYPE == ITEM_TYPE_WEAPON) then
                point = OFFHAND_POINT
            elseif item_data.TYPE == ITEM_TYPE_WEAPON then
                point = WEAPON_POINT
            elseif item_data.TYPE == ITEM_TYPE_ARMOR and item_data.SUBTYPE ~= BELT_ARMOR then

                if item_data.SUBTYPE == CHEST_ARMOR then point = CHEST_POINT
                elseif item_data.SUBTYPE == HANDS_ARMOR then point = HANDS_POINT
                elseif item_data.SUBTYPE == LEGS_ARMOR then point = LEGS_POINT
                elseif item_data.SUBTYPE == HEAD_ARMOR then point = HEAD_POINT end

            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then

                if item_data.SUBTYPE == RING_JEWELRY then

                    if flag then
                        if unit_data.equip_point[RING_1_POINT] then point = RING_2_POINT
                        else point = RING_1_POINT end
                    else
                        if unit_data.equip_point[RING_1_POINT] and unit_data.equip_point[RING_1_POINT].item == item then point = RING_1_POINT
                        elseif unit_data.equip_point[RING_2_POINT] and unit_data.equip_point[RING_2_POINT].item == item then point = RING_2_POINT end
                    end

                    --if flag then point = unit_data.equip_point[RING_1_POINT] ~= nil and RING_2_POINT or RING_1_POINT
                    --else point = unit_data.equip_point[RING_1_POINT].item == item and RING_1_POINT or RING_2_POINT end
                else point = NECKLACE_POINT end

            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then point = OFFHAND_POINT
            else point = BELT_POINT end

            if not point then
                print("Warning: no equip point")
                return nil
            end

            if not flag and (unit_data.equip_point[point] and unit_data.equip_point[point].item ~= item) then
                print("Warning: trying to disarm an item that wasn't equipped in first place")
                return nil
            end


            if (unit_data.equip_point[point] and unit_data.equip_point[point].SUBTYPE ~= FIST_WEAPON) and flag then
                disarmed_item = unit_data.equip_point[point].item
                EquipItem(unit, unit_data.equip_point[point].item, false, point == OFFHAND_POINT and unit_data.equip_point[point].TYPE == ITEM_TYPE_WEAPON)
            end


            if item_data.set_bonus then
                ApplySetBonus(unit, item_data.set_bonus, flag)
            end


                if flag then unit_data.equip_point[point] = item_data
                else unit_data.equip_point[point] = point == WEAPON_POINT and unit_data.default_weapon or nil end


            if (item_data.model or item_data.texture) and not unit_data.classic_model then
                if flag then

                    if point == CHEST_POINT then
                        if GetUnitClass(unit) == ASSASSIN_CLASS then
                            SetTexture(unit, item_data.assassin_texture or TEXTURE_ID_ASSASSIN_BASE)
                        else
                            SetTexture(unit, item_data.texture or TEXTURE_ID_EMPTY)
                        end
                    else
                        local ref_point = "chest"

                        if point == OFFHAND_POINT then ref_point = "hand left"
                        elseif point == WEAPON_POINT then ref_point = "hand right" end

                        if GetUnitClass(unit) == ASSASSIN_CLASS and item_data.SUBTYPE == BOW_WEAPON then
                            ref_point = "hand left"
                        end

                        item_data.model_effect = AddSpecialEffectTarget(item_data.model, unit, ref_point)
                        BlzSetSpecialEffectScale(item_data.model_effect, 0.88)
                    end

                else

                    if point == CHEST_POINT then
                        if GetUnitClass(unit) == ASSASSIN_CLASS then
                            SetTexture(unit, TEXTURE_ID_ASSASSIN_BASE)
                        else
                            if item_data.texture then SetTexture(unit, TEXTURE_ID_EMPTY) end
                        end
                    end

                    if item_data.model_effect then BlzSetSpecialEffectScale(item_data.model_effect, 1.); DestroyEffect(item_data.model_effect) end
                end
            end

            if unit_data.equip_point[point] and unit_data.equip_point[point].TYPE == ITEM_TYPE_WEAPON then
                local old_range = BlzGetUnitWeaponRealField(unit, UNIT_WEAPON_RF_ATTACK_RANGE, 0)
                local new_range = unit_data.equip_point[point].RANGE or 100.
                local new_aquis_range = new_range

                    BlzUnitInterruptAttack(unit)

                    --if new_range < old_range then new_range = (old_range - new_range) * -1.
                    --else new_range = new_range - old_range end

                    BlzSetUnitRealField(unit, UNIT_RF_ACQUISITION_RANGE, new_aquis_range)
                    BlzSetUnitWeaponRealField(unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, new_range - BlzGetUnitWeaponRealField(unit, UNIT_WEAPON_RF_ATTACK_RANGE, 0))--new_range + 100.)

            end

            if item_data.legendary_effect then
                ApplyLegendaryEffect(unit, item_data.legendary_effect, flag)
            end


            if item_data.runeword then

                for i = 1, #item_data.STONE_SLOTS do
                    if not IsPartOfRuneword(item_data.runeword, item_data.STONE_SLOTS[i].raw) then
                        ModifyStat(unit, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].METHOD, flag)
                    end
                end

                local runeword_data = GetRunewordData(item_data.runeword)

                if runeword_data[item_data.TYPE] then

                    if runeword_data[item_data.TYPE].BONUS then
                        for i = 1, #runeword_data[item_data.TYPE].BONUS do
                            ModifyStat(unit, runeword_data[item_data.TYPE].BONUS[i].PARAM, runeword_data[item_data.TYPE].BONUS[i].VALUE, runeword_data[item_data.TYPE].BONUS[i].METHOD, flag)
                        end
                    end

                    if runeword_data[item_data.TYPE].EFFECT then
                        for i = 1, #runeword_data[item_data.TYPE].EFFECT do
                            if flag then UnitAddEffect(unit, runeword_data[item_data.TYPE].EFFECT[i])
                            else UnitRemoveEffect(unit, runeword_data[item_data.TYPE].EFFECT[i]) end
                        end
                    end

                end

            else
                for i = 1, #item_data.STONE_SLOTS do
                    ModifyStat(unit, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].METHOD, flag)
                end
            end


            for i = 1, #item_data.BONUS do
                ModifyStat(unit, item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD, flag)
            end

            if item_data.SUBTYPE == ORB_OFFHAND then
                ModifyStat(unit, ALL_RESIST, item_data.ALLRESIST or 0, STRAIGHT_BONUS, flag)
            end

            if item_data.SKILL_BONUS and #item_data.SKILL_BONUS > 0 then
                UpdateBindedSkillsData(GetPlayerId(GetOwningPlayer(unit)) + 1)
            end

            if item_data.effect_bonus and #item_data.effect_bonus > 0 then
                for i = 1, #item_data.effect_bonus do
                    if flag then UnitAddEffect(unit, item_data.effect_bonus[i])
                    else UnitRemoveEffect(unit, item_data.effect_bonus[i]) end
                end
            end

            UpdateParameters(unit_data)
            OnItemEquip(unit, item, disarmed_item, flag)

        return disarmed_item
    end



    function GiveItemToPlayerByUnit(unit, item)
        SetItemVisible(item, false)
        AddToInventory(GetPlayerId(GetOwningPlayer(unit))+1, item)
    end



    function RegisterItemPickUp(unit)
        local trg = CreateTrigger()

        TriggerRegisterUnitEvent(trg, unit, EVENT_UNIT_ISSUED_TARGET_ORDER)
        TriggerAddAction(trg, function()

            if GetOrderTargetItem() == nil or IsItemInvulnerable(GetOrderTargetItem()) then
                return
            end

            if GetItemType(GetOrderTargetItem()) ~= ITEM_TYPE_POWERUP then
                local player = GetPlayerId(GetOwningPlayer(unit)) + 1
                local item = GetOrderTargetItem()
                local item_data = GetItemData(item)

                if not item_data.picked_up then
                    local angle = AngleBetweenXY_DEG(GetItemX(item), GetItemY(item), GetUnitX(unit), GetUnitY(unit))

                        if IsUnitInRangeXY(unit, GetItemX(item), GetItemY(item), 150.) then
                            item_data.last_x = GetItemX(item)
                            item_data.last_y = GetItemY(item)
                            AddToInventory(player, item)
                            DelayAction(0., function() IssueImmediateOrderById(unit, order_stop) end)
                            SetUnitFacingTimed(unit, angle+180.,0.)
                            --print("c1")
                        else
                            local proximity_timer = CreateTimer()
                            local proximity_trigger = CreateTrigger()
                            local x, y = GetItemX(item), GetItemY(item)

                            IssuePointOrderById(unit, order_move, GetItemX(item) + Rx(25., angle), GetItemY(item) + Ry(25., angle))
                            TriggerRegisterUnitEvent(proximity_trigger, unit, EVENT_UNIT_ISSUED_POINT_ORDER)
                            TriggerRegisterUnitEvent(proximity_trigger, unit, EVENT_UNIT_ISSUED_ORDER)
                            TriggerRegisterUnitEvent(proximity_trigger, unit, EVENT_UNIT_ISSUED_TARGET_ORDER)

                            TriggerAddAction(proximity_trigger, function()
                                DestroyTimer(proximity_timer)
                                DestroyTrigger(proximity_trigger)
                            end)

                            TimerStart(proximity_timer, 0.025, true, function()
                                if DistanceBetweenUnitXY(unit, x, y) < 150. and not item_data.picked_up then
                                    item_data.last_x = GetItemX(item)
                                    item_data.last_y = GetItemY(item)
                                    AddToInventory(player, item)
                                    SetUnitFacingTimed(unit, angle+180.,0.)
                                    DestroyTimer(proximity_timer)
                                    DestroyTrigger(proximity_trigger)
                                    AddSoundVolume("Sound\\Interface\\PickUpItem.wav", x, y, 85, 1200.)
                                    IssueImmediateOrderById(unit, order_stop)
                                elseif item_data.picked_up then
                                    DestroyTimer(proximity_timer)
                                    DestroyTrigger(proximity_trigger)
                                    IssueImmediateOrderById(unit, order_stop)
                                end
                            end)
                            --BlzQueueTargetOrderById(unit, order_smart, item)
                            --EnableTrigger(trg)
                            --print("c2")
                        end

                end

            elseif GetItemType(GetOrderTargetItem()) == ITEM_TYPE_POWERUP then
                --print("powerup")
                if IsUnitInRangeXY(unit, GetItemX(GetOrderTargetItem()), GetItemY(GetOrderTargetItem()), 200.) then
                    --print("use")
                    UnitAddItem(unit, GetOrderTargetItem())
                end
            end

        end)

        local trg2 = CreateTrigger()
        TriggerRegisterUnitEvent(trg2, unit, EVENT_UNIT_PICKUP_ITEM)
        TriggerAddAction(trg2, function()
            local item = GetManipulatedItem()
            local item_data = GetItemData(item)
            --print("pick up trigger")

                if GetItemType(item) ~= ITEM_TYPE_POWERUP then
                    if item_data.picked_up and not IsItemInvulnerable(item) then
                        UnitRemoveItem(unit, item)
                        SetItemVisible(item, false)
                    elseif not item_data.picked_up and not IsItemInvulnerable(item) then
                        UnitRemoveItem(unit, item)
                        SetItemPosition(item, item_data.last_x, item_data.last_y)
                    end
                end


        end)

        local trg3 = CreateTrigger()
        TriggerRegisterUnitEvent(trg3, unit, EVENT_UNIT_USE_ITEM)
        TriggerAddAction(trg3, function()
            local player = GetPlayerId(GetOwningPlayer(unit)) + 1
            local item = GetManipulatedItem()
                OnItemUse(unit, item, GetEventTargetUnit() or nil)

                if PlayerInventoryFrameState[player] or GetItemType(item) == ITEM_TYPE_CHARGED then
                    UpdateInventoryWindow(player)
                end

        end)

    end


    function EnumItemsOnInit()

        PlayerPickUpItemFlag = {  }

        QUALITY_COLOR = {
            [COMMON_ITEM] = '|c00FFFFFF',
            [RARE_ITEM] = '|c00669FFF',
            [MAGIC_ITEM] = '|c00FFFF00',
            [SET_ITEM] = '|c0000FF00',
            [UNIQUE_ITEM] = '|c00FFD574'
        }

        QUALITY_LIGHT_COLOR = {
            [COMMON_ITEM] = 'QualityLight_Common.mdl',
            [RARE_ITEM] = 'QualityLight_Rare.mdl',
            [MAGIC_ITEM] = 'QualityLight_Magic.mdl',
            [SET_ITEM] = 'QualityLight_Set.mdl',
            [UNIQUE_ITEM] = 'QualityLight_Unique.mdl'
        }

        ATTRIBUTE_COLOR = {
            [PHYSICAL_ATTRIBUTE]    = "|c00FFA582",
            [FIRE_ATTRIBUTE]        = "|c00FF5454",
            [ICE_ATTRIBUTE]         = "|c00D3D6FF",
            [LIGHTNING_ATTRIBUTE]   = "|c00CBD0FF",
            [POISON_ATTRIBUTE]      = "|c006CFF76",
            [HOLY_ATTRIBUTE]        = "|c00FFFF5B",
            [DARKNESS_ATTRIBUTE]    = "|c006944C4",
            [ARCANE_ATTRIBUTE]      = "|c00FF93FF",
        }

        EFFECT_QUALITY_COLOR = {
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
            [DAGGER_WEAPON]         = 0.65,
            [STAFF_WEAPON]          = 0.85,
            [JAWELIN_WEAPON]        = 1.,
            [HEAD_ARMOR]            = 0.5,
            [CHEST_ARMOR]           = 0.65,
            [LEGS_ARMOR]            = 0.55,
            [HANDS_ARMOR]           = 0.55,
            [BELT_ARMOR]            = 0.55,
            [RING_JEWELRY]          = 0.5,
            [NECKLACE_JEWELRY]      = 0.7,
            [THROWING_KNIFE_WEAPON] = 0.7,
            [SHIELD_OFFHAND]        = 0.7,
            [ORB_OFFHAND]           = 0.65,
            [QUIVER_OFFHAND]        = 0.65,
        }

        ITEMSUBTYPES_MODELS = {
            [BOW_WEAPON]            = { model = "FlippyBow.mdx", scale = 0.8  },
            [BLUNT_WEAPON]          = { model = "FlippyBlunt.mdx", scale = 0.8  },
            [GREATBLUNT_WEAPON]     = { model = "FlippyGreatBlunt.mdx", scale = 0.8  },
            [SWORD_WEAPON]          = { model = "FlippySword.mdx", scale = 0.7  },
            [GREATSWORD_WEAPON]     = { model = "FlippyGreatSword.mdx", scale = 0.6  },
            [AXE_WEAPON]            = { model = "FlippyAxe.mdx", scale = 0.9  },
            [GREATAXE_WEAPON]       = { model = "FlippyGreatAxe.mdx", scale = 0.7  },
            [DAGGER_WEAPON]         = { model = "FlippyDagger.mdx", scale = 0.7  },
            [STAFF_WEAPON]          = { model = "FlippyStaff.mdx", scale = 0.8  },
            [JAWELIN_WEAPON]        = { model = "FlippyAmulet.mdx", scale = 0.9  },
            [HEAD_ARMOR]            = { model = "FlippyHelmet.mdx", scale = 1.  },
            [CHEST_ARMOR]           = { model = "FlippyChest.mdx", scale = 1.  },
            [LEGS_ARMOR]            = { model = "FlippyBoots.mdx", scale = 1.  },
            [HANDS_ARMOR]           = { model = "FlippyHands.mdx", scale = 0.8  },
            [BELT_ARMOR]            = { model = "FlippyBelt.mdx", scale = 0.8  },
            [RING_JEWELRY]          = { model = "FlippyRing.mdx", scale = 1.  },
            [NECKLACE_JEWELRY]      = { model = "FlippyAmulet.mdx", scale = 1.  },
            [THROWING_KNIFE_WEAPON] = { model = "FlippyAmulet.mdx", scale = 0.9  },
            [SHIELD_OFFHAND]        = { model = "FlippyShield.mdx", scale = 0.8  },
            [ORB_OFFHAND]           = { model = "FlippyOrb.mdx", scale = 0.9  },
            [QUIVER_OFFHAND]        = { model = "FlippyQuiver.mdx", scale = 1.  },
        }



        AffixTable = {
            [COMMON_ITEM] = {
                { affix = ITEM_AFFIX_IDEAL, chance = 17. },
                { affix = ITEM_AFFIX_EXCELLENT, chance = 33. },
                { affix = ITEM_AFFIX_FINE, chance = 50. },
            },
            [RARE_ITEM] = {
                { affix = ITEM_AFFIX_IDEAL, chance = 33. },
                { affix = ITEM_AFFIX_EXCELLENT, chance = 50. },
                { affix = ITEM_AFFIX_FINE, chance = 66. },
            },
            [MAGIC_ITEM] = {
                { affix = ITEM_AFFIX_IDEAL, chance = 50. },
                { affix = ITEM_AFFIX_EXCELLENT, chance = 50. },
                { affix = ITEM_AFFIX_FINE, chance = 66. },
            },
        }



        ITEMTYPES_NAMES = {
            [ITEM_TYPE_WEAPON]     = LOCALE_LIST[my_locale].ITEM_TYPE_WEAPON_NAME,
            [ITEM_TYPE_ARMOR]      = LOCALE_LIST[my_locale].ITEM_TYPE_ARMOR_NAME,
            [ITEM_TYPE_JEWELRY]    = LOCALE_LIST[my_locale].ITEM_TYPE_JEWELRY_NAME,
            [ITEM_TYPE_OFFHAND]    = LOCALE_LIST[my_locale].ITEM_TYPE_OFFHAND_NAME,
            [ITEM_TYPE_CONSUMABLE] = LOCALE_LIST[my_locale].ITEM_TYPE_CONSUMABLE_NAME,
            [ITEM_TYPE_GEM]        = LOCALE_LIST[my_locale].ITEM_TYPE_GEM_NAME,
            [ITEM_TYPE_SKILLBOOK]  = LOCALE_LIST[my_locale].ITEM_TYPE_SKILLBOOK,
            [ITEM_TYPE_OTHER]      = LOCALE_LIST[my_locale].ITEM_TYPE_OTHER,
            [ITEM_TYPE_GIFT]       = LOCALE_LIST[my_locale].ITEM_TYPE_GIFT,
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
            [BELT_ARMOR]            = LOCALE_LIST[my_locale].BELT_ARMOR_NAME,
            [RING_JEWELRY]          = LOCALE_LIST[my_locale].RING_JEWELRY_NAME,
            [NECKLACE_JEWELRY]      = LOCALE_LIST[my_locale].NECKLACE_JEWELRY_NAME,
            [THROWING_KNIFE_WEAPON] = LOCALE_LIST[my_locale].THROWING_KNIFE_WEAPON_NAME,
            [SHIELD_OFFHAND]        = LOCALE_LIST[my_locale].SHIELD_OFFHAND_NAME,
            [ORB_OFFHAND]           = LOCALE_LIST[my_locale].ORB_OFFHAND_NAME,
            [QUIVER_OFFHAND]        = LOCALE_LIST[my_locale].QUIVER_OFFHAND_NAME,
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

        TWOHANDED_LIST = {
            [FIST_WEAPON]           = false,
            [BOW_WEAPON]            = true,
            [BLUNT_WEAPON]          = false,
            [GREATBLUNT_WEAPON]     = true,
            [SWORD_WEAPON]          = false,
            [GREATSWORD_WEAPON]     = true,
            [AXE_WEAPON]            = false,
            [GREATAXE_WEAPON]       = true,
            [DAGGER_WEAPON]         = false,
            [STAFF_WEAPON]          = true,
            [JAWELIN_WEAPON]        = false,
            [THROWING_KNIFE_WEAPON] = false,
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

        for i = 1, 6 do
            PlayerPickUpItemFlag[i] = false
        end

    end


end