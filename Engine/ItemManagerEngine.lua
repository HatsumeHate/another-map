do



    local QUALITY_COLOR = 0
    local EFFECT_QUALITY_COLOR = 0

    ITEMSUBTYPES_EFFECT_SCALE = 0
    ITEMSUBTYPES_MODELS = 0
    PlayerPickUpItemFlag = 0

    local ITEMTYPES_NAMES = 0
    local ITEMSUBTYPES_NAMES = 0
    local ATTRIBUTE_NAMES = 0
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
        if ITEM_DATA[item].model_effect then DestroyEffect(ITEM_DATA[item].model_effect) end
        ITEM_DATA[item] = nil
        RemoveItem(item)
    end






    function CreateQualityEffect(item)
        local data = GetItemData(item)
        local color_table = GetQualityEffectColor(data.QUALITY)

            if data.owner then
                if GetLocalPlayer() == Player(data.owner) then
                    data.quality_effect = AddSpecialEffect("QualityGlow.mdx", GetItemX(item), GetItemY(item))
                    BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                    BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                else
                    data.quality_effect = AddSpecialEffect("", GetItemX(item), GetItemY(item))
                end
            elseif not data.picked_up then
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", GetItemX(item), GetItemY(item))
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
            end



    end

    function ApplyQualityGlowColour(item)
        local item_data = GetItemData(item)
        local color_table = GetQualityEffectColor(item_data.QUALITY)
        BlzSetSpecialEffectColor(item_data.quality_effect, color_table.r, color_table.g, color_table.b)
        BlzSetSpecialEffectScale(item_data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[item_data.SUBTYPE])
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

            AddSoundForPlayerVolumeZ("Sound\\gold.wav", x, y, 35., 110, 2100., player)

            local trg = CreateTrigger()
            TriggerRegisterEnterRegionSimple(trg, region)
            TriggerAddAction(trg, function()

                if GetOwningPlayer(GetTriggerUnit()) == Player(player) then
                    DestroyEffect(AddSpecialEffectTarget("UI\\Feedback\\GoldCredit\\GoldCredit.mdx", GetTriggerUnit(), "origin"))
                    SetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(player), PLAYER_STATE_RESOURCE_GOLD) + amount)
                    AddSoundForPlayerVolumeZ("Abilities\\Spells\\Items\\ResourceItems\\ReceiveGold.wav", x, y, 35., 127, 2200., player)
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
	function CreateCustomItem(raw, x, y, drop_animation, owner)
        if raw == 0 then return end
		local id     = FourCC(raw)
		local item   = CreateItem(id, x, y)
		local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            data.item = item
            --print(GetQualityColor(data.QUALITY) .. data.NAME .. "|r")
            BlzSetItemName(item, GetQualityColor(data.QUALITY) .. data.NAME .. "|r")
            data.actual_name = GetQualityColor(data.QUALITY) .. data.NAME .. '|r'

            data.owner = owner or nil


            if owner then
                if GetLocalPlayer() ~= Player(owner) then
                    BlzSetItemSkin(item, FourCC("I01X"))
                end
            end

            if data.flippy then
                local color_table = GetQualityEffectColor(data.QUALITY)
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", x, y)
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
                BlzSetSpecialEffectAlpha(data.quality_effect, 0)
            end


            ITEM_DATA[item] = data


            if drop_animation then
                DelayAction(0., function()

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

                        if data.owner then AddSoundForPlayerVolumeZ("Sound\\flippy.wav", x, y, 35., 128, 2100., data.owner)
                        else AddSoundVolume("Sound\\flippy.wav", x, y, 128, 2100.) end
                        local timer = CreateTimer()
                        TimerStart(timer, 0.48, false, function()

                            if data.owner then
                                if GetLocalPlayer() == Player(data.owner) then
                                    if data.quality_effect then BlzSetSpecialEffectAlpha(data.quality_effect, 255) end
                                    BlzSetSpecialEffectPosition(data.quality_effect, GetItemX(item), GetItemY(item), GetZ(GetItemX(item), GetItemY(item)))
                                    BlzSetItemSkin(item, GetItemTypeId(item))
                                end
                                if data.soundpack then AddSoundForPlayerVolumeZ(data.soundpack.drop, x, y, 35., 128, 2100., data.owner) end
                            else
                                if not data.picked_up then
                                    if data.quality_effect then BlzSetSpecialEffectAlpha(data.quality_effect, 255) end
                                    BlzSetItemSkin(item, GetItemTypeId(item))
                                    if data.soundpack then AddSoundVolume(data.soundpack.drop, x, y, 128, 2100.) end
                                end
                            end

                            BlzSetSpecialEffectAlpha(item_effect, 0)
                            DestroyEffect(item_effect)
                            DestroyTimer(GetExpiredTimer())
                        end)

                    else

                        if data.owner then AddSoundForPlayerVolumeZ(data.soundpack.drop, x, y, 35., 128, 2100., data.owner)
                        else AddSoundVolume(data.soundpack.drop, x, y, 128, 2100.) end

                    end

                end)
            else
                if data.owner then

                    if data.quality_effect then
                        BlzSetSpecialEffectPosition(data.quality_effect, GetItemX(item), GetItemY(item), GetZ(GetItemX(item), GetItemY(item)))

                        if GetLocalPlayer() == Player(data.owner) then
                            BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                            BlzSetItemSkin(item, GetItemTypeId(item))
                        else
                            BlzSetSpecialEffectAlpha(data.quality_effect, 0)
                        end

                    end

                else
                    if not data.picked_up then

                        if data.quality_effect then
                            BlzSetSpecialEffectAlpha(data.quality_effect, 255)
                            DelayAction(0., function()
                                BlzSetSpecialEffectPosition(data.quality_effect, GetItemX(item), GetItemY(item), GetZ(GetItemX(item), GetItemY(item)))
                            end)
                        end

                        BlzSetItemSkin(item, GetItemTypeId(item))
                    end
                end
            end

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
        --local handle = GetHandleId(item)
        local data   = MergeTables({}, ITEM_TEMPLATE_DATA[id])

            ITEM_DATA[item] = data

            data.item = item
            BlzSetItemName(item, GetQualityColor(data.QUALITY) .. data.NAME .. "|r")

            data.actual_name = GetQualityColor(data.QUALITY) .. data.NAME .. '|r'


            if IsRandomGeneratedId(id) then GenerateItemStats(item, 1, COMMON_ITEM)
            else GenerateItemLevel(item, 1) end

            if data.flippy then
                local color_table = GetQualityEffectColor(data.QUALITY)
                data.quality_effect = AddSpecialEffect("QualityGlow.mdx", x, y)
                BlzSetSpecialEffectColor(data.quality_effect, color_table.r, color_table.g, color_table.b)
                BlzSetSpecialEffectScale(data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[data.SUBTYPE])
            end

            if data.TYPE == ITEM_TYPE_SKILLBOOK then GenerateItemBookSkill(item)
            elseif data.TYPE == ITEM_TYPE_CONSUMABLE and data.cooldown_type then BlzSetItemIntegerField(item, ITEM_IF_COOLDOWN_GROUP, data.cooldown_type) end


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
        --local affix = GetRandomInt(ITEM_SUFFIX_LIST[suffix].min_affix, ITEM_SUFFIX_LIST[suffix].max_affix)
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

        --print("rolled suffix id " .. )
        --print("ok")
        --print("affix " .. ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. " + " .. item_data.NAME .." + suffix " .. ITEM_SUFFIX_LIST[suffix].name)

        item_data.BONUS = {}

            for i = 1, #parameters_list do
                local parameter = GetParameterPreset(preset.parameter_bonus[parameters_list[i]])

                        if GetRandomInt(0, 100) <= parameter.probability or #item_data.BONUS < min then

                            --print("found " .. GetParameterName(parameter.PARAM) .. " method " .. parameter.METHOD)

                            item_data.BONUS[#item_data.BONUS + 1] = {
                                PARAM = parameter.PARAM,
                                METHOD = parameter.METHOD
                            }

                            if item_data.BONUS[#item_data.BONUS].METHOD == STRAIGHT_BONUS and not (item_data.BONUS[#item_data.BONUS].PARAM == CRIT_MULTIPLIER or item_data.BONUS[#item_data.BONUS].PARAM == HP_REGEN or item_data.BONUS[#item_data.BONUS].PARAM == MP_REGEN) then
                                --print("straight start")
                                item_data.BONUS[#item_data.BONUS].VALUE = GetRandomInt(parameter.value_min, parameter.value_max)
                                --print("straight end .. " .. item_data.BONUS[#item_data.BONUS].VALUE)
                            else
                                --print("mult start")
                                item_data.BONUS[#item_data.BONUS].VALUE = I2R(GetRandomInt(R2I(parameter.value_min * 100.), R2I(parameter.value_max * 100.))) / 100.
                                --print("mult end " .. item_data.BONUS[#item_data.BONUS].VALUE)
                            end

                            bonus_parameters_count = bonus_parameters_count - 1
                        end

            end



            item_data.NAME = ITEM_AFFIX_NAME_LIST[affix][QUALITY_ITEM_LIST[quality][item_data.SUBTYPE][variation].decl] .. item_data.NAME .. ITEM_SUFFIX_LIST[suffix].name

        --print("generator parameters done")

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
            --print("generator skills done")

            item_data.actual_name = GetQualityColor(quality) .. item_data.NAME .. '|r'
            BlzSetItemName(item, GetQualityColor(quality) .. item_data.NAME .. '|r')

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

            if item_data.BONUS then stats_bonus = #item_data.BONUS * 75 end
            if item_data.MAX_SLOTS then stone_bonus = 50 * item_data.MAX_SLOTS end

            item_data.level = level

            if stats_bonus > 0 or stone_bonus > 0 then
                item_data.cost = R2I((level * 30 + stats_bonus + stone_bonus) * item_data.stat_modificator)
            end

            if item_data.legendary_effect then item_data.cost = item_data.cost * 2 end

    end


    ---@param item item
    ---@param value number
    function GenerateItemStatPreset(item, value)
        local item_data = GetItemData(item)

            if item_data.TYPE == ITEM_TYPE_WEAPON then
                item_data.DAMAGE = item_data.DAMAGE * value
            elseif item_data.TYPE == ITEM_TYPE_ARMOR then
                item_data.DEFENCE = item_data.DEFENCE * value
            elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                item_data.SUPPRESSION = item_data.SUPPRESSION * value
            elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                if item_data.SUBTYPE == SHIELD_OFFHAND then
                    item_data.DEFENCE = item_data.DEFENCE * value
                    item_data.BLOCK = item_data.BLOCK * value
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
                        item_data.DEFENCE = item_data.DEFENCE * 0.5
                        item_data.SUPPRESSION = (R2I(7 * GetRandomReal(0.75, 1.25)) + 1 * level) * 0.5
                    end
                elseif item_data.TYPE == ITEM_TYPE_JEWELRY then
                    item_data.SUPPRESSION = R2I(7 * GetRandomReal(0.75, 1.25)) + 1 * level
                elseif item_data.TYPE == ITEM_TYPE_OFFHAND then
                    if item_data.SUBTYPE == SHIELD_OFFHAND then
                        item_data.BLOCK = GetRandomInt(20, 30)
                        item_data.DEFENCE = R2I(15 * GetRandomReal(0.75, 1.25)) + 1 * level
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
            --print("1")
            ApplyQualityGlowColour(item)

                if item_data.TYPE == ITEM_TYPE_WEAPON then

                    if item_data.SUBTYPE ~= BOW_WEAPON then
                        local physical_archetype = 65

                        if item_data.SUBTYPE == STAFF_WEAPON then physical_archetype = 35
                        elseif item_data.SUBTYPE == AXE_WEAPON or item_data.SUBTYPE == GREATAXE_WEAPON or item_data.SUBTYPE == GREATSWORD_WEAPON or item_data.SUBTYPE == GREATBLUNT_WEAPON then physical_archetype = 75
                        elseif item_data.SUBTYPE == SWORD_WEAPON or item_data.SUBTYPE == DAGGER_WEAPON or item_data.SUBTYPE == BLUNT_WEAPON then physical_archetype = 50 end

                        if GetRandomInt(0, 100) <= physical_archetype then
                            item_data.DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL
                            local attribute_roll = GetRandomInt(1, 6)

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
                        if GetRandomInt(1, 2) == 1 then item_data.ATTRIBUTE = PHYSICAL_ATTRIBUTE
                        else item_data.ATTRIBUTE = POISON_ATTRIBUTE end
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
            BlzSetItemName(item, GetQualityColor(quality) .. item_data.NAME .. '|r')
            item_data.actual_name = GetQualityColor(quality) .. item_data.NAME .. '|r'

            --print("generator done")
    end




    ---@param itemtype number
    function IsWeaponTypeTwohanded(itemtype)
        return TWOHANDED_LIST[itemtype] or false
    end

    
    ---@param point number
    function PointToReference(point)

    end



    function IsItemEquipped(unit, item)
        local unit_data = GetUnitData(unit)

            for point = 1, NECKLACE_POINT do
                if unit_data.equip_point[point] and unit_data.equip_point[point].item == item then
                    return true
                end
            end

        return false
    end

    ---@param unit unit
    ---@param item item
    ---@param flag boolean
    ---@returns item
    function EquipItem(unit, item, flag, offhand)
        local unit_data = GetUnitData(unit)
        local item_data = GetItemData(item)
        local point
        local disarmed_item

           --print("eqip item is ".. GetItemName(item).. " state is " .. (flag and "equip" or "unequip"))

            if item_data.TYPE == ITEM_TYPE_OFFHAND or (offhand and item_data.TYPE == ITEM_TYPE_WEAPON) then
                point = OFFHAND_POINT
                --print("offhand point")
            elseif item_data.TYPE == ITEM_TYPE_WEAPON then
                point = WEAPON_POINT
                --print("weapon point")
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
            else point = BELT_POINT
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



            if (unit_data.equip_point[point] and unit_data.equip_point[point].item) and item_data.model then
                if flag then
                    local ref_point = "chest"

                    if point == OFFHAND_POINT then ref_point = "hand left"
                    elseif point == WEAPON_POINT then ref_point = "hand right" end

                    item_data.model_effect = AddSpecialEffectTarget(item_data.model, unit, ref_point)
                else
                    if item_data.model_effect then DestroyEffect(item_data.model_effect) end
                end
            end


            if unit_data.equip_point[point] and unit_data.equip_point[point].TYPE == ITEM_TYPE_WEAPON then
                BlzUnitInterruptAttack(unit)
                BlzSetUnitRealField(unit, UNIT_RF_ACQUISITION_RANGE, (unit_data.equip_point[point].RANGE or 90.))
                BlzSetUnitWeaponRealField(unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, (unit_data.equip_point[point].RANGE or 90.))
                --BlzSetUnitWeaponRealField(unit, UNIT_WEAPON_RF_BA
            end

            if item_data.legendary_effect then
                ApplyLegendaryEffect(unit, item_data.legendary_effect, flag)
            end


            for i = 1, #item_data.STONE_SLOTS do
                ModifyStat(unit, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].PARAM, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].VALUE, item_data.STONE_SLOTS[i].point_bonus[item_data.TYPE].METHOD, flag)
            end

            for i = 1, #item_data.BONUS do
                ModifyStat(unit, item_data.BONUS[i].PARAM, item_data.BONUS[i].VALUE, item_data.BONUS[i].METHOD, flag)
            end


            if item_data.SKILL_BONUS and #item_data.SKILL_BONUS > 0 then
                UpdateBindedSkillsData(GetPlayerId(GetOwningPlayer(unit)) + 1)
            end


            UpdateParameters(unit_data)

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

                        if IsUnitInRangeXY(unit, GetItemX(item), GetItemY(item), 200.) then
                            item_data.last_x = GetItemX(item)
                            item_data.last_y = GetItemY(item)
                            AddToInventory(player, item)
                            SetUnitFacingTimed(unit, angle+180.,0.)
                        else
                            IssuePointOrderById(unit, order_move, GetItemX(item) + Rx(25., angle), GetItemY(item) + Ry(25., angle))
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
                OnItemUse(unit, GetManipulatedItem(), GetEventTargetUnit() or nil)
                if PlayerInventoryFrameState[player] or GetItemType(GetManipulatedItem()) == ITEM_TYPE_CHARGED then
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
                { affix = ITEM_AFFIX_FINE, chance = 50. },
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
            [ITEM_TYPE_OTHER]      = LOCALE_LIST[my_locale].ITEM_TYPE_OTHER
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


        RegisterTestCommand("dd", function()
            local item = CreateCustomItem(GetRandomGeneratedItemId(), GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1]), true)
            GenerateItemStats(item, 1, GetRandomInt(COMMON_ITEM, MAGIC_ITEM))
        end)

        RegisterTestCommand("dd1", function()
            local item = CreateCustomItem(GetRandomGeneratedItemId(), GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1]), true, 0)
            GenerateItemStats(item, 1, GetRandomInt(COMMON_ITEM, MAGIC_ITEM))
        end)

        RegisterTestCommand("dd2", function()
            local item = CreateCustomItem(GetRandomGeneratedItemId(), GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1]), true, 1)
            GenerateItemStats(item, 1, GetRandomInt(COMMON_ITEM, MAGIC_ITEM))

            DelayAction(10., function()
                BlzSetItemSkin(item, GetItemTypeId(item))
            end)
        end)

        RegisterTestCommand("db", function()
            local item = CreateCustomItem(GetRandomBookItemId(), GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1]), true)
        end)

    end

end