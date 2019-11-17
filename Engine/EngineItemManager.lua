
    ItemsData = {}






    function CreateCustomItem(item_id, x, y)

        bj_lastCreatedItem = CreateItem(item_id, x, y)


        if ItemsTemplateData[item_id].item_type == ITEM_TYPE_WEAPON then
            ItemsData[GetHandleId(bj_lastCreatedItem)] = {
                name = ItemsTemplateData[item_id].name,
                item_type = ItemsTemplateData[item_id].item_type,
                item_subtype = ItemsTemplateData[item_id].subtype,

                damage = ItemsTemplateData[item_id].damage,
                damage_type = ItemsTemplateData[item_id].damage_type,
                attribute = ItemsTemplateData[item_id].attribute,
                attribute_bonus = ItemsTemplateData[item_id].attribute_bonus,

                attack_speed = ItemsTemplateData[item_id].attack_speed,
                critical_chance = ItemsTemplateData[item_id].critical_chance,
                critical_multiplier = ItemsTemplateData[item_id].critical_multiplier,

                dispersion = { ItemsTemplateData[item_id].dispersion[1], ItemsTemplateData[item_id].dispersion[2]},
                range = ItemsTemplateData[item_id].range,
                angle = ItemsTemplateData[item_id].angle,
                max_targets = ItemsTemplateData[item_id].max_targets,

                missile_on_attack = ItemsTemplateData[item_id].missile_on_attack,
                effect_on_attack = ItemsTemplateData[item_id].effect_on_attack,
                weapon_sound = ItemsTemplateData[item_id].weapon_sound,
                model = ItemsTemplateData[item_id].model,

                quality = ItemsTemplateData[item_id].quality,
                bonus_parameters = {},
                max_slots = ItemsTemplateData[item_id].max_slots,
                stone_slots = {}
            }
        elseif ItemsTemplateData[item_id].item_type == ITEM_TYPE_ARMOR then
            ItemsData[GetHandleId(bj_lastCreatedItem)] = {
                name = ItemsTemplateData[item_id].name,
                item_type = ItemsTemplateData[item_id].item_type,
                item_subtype = ItemsTemplateData[item_id].subtype,

                defence = ItemsTemplateData[item_id].defence,

                model = ItemsTemplateData[item_id].model,

                quality = ItemsTemplateData[item_id].quality,
                bonus_parameters = {},
                max_slots = ItemsTemplateData[item_id].max_slots,
                stone_slots = {}

            }
        elseif ItemsTemplateData[item_id].item_type == ITEM_TYPE_JEWELRY then
            ItemsData[GetHandleId(bj_lastCreatedItem)] = {
                name = ItemsTemplateData[item_id].name,
                item_type = ItemsTemplateData[item_id].item_type,
                item_subtype = ItemsTemplateData[item_id].subtype,

                suppression = ItemsTemplateData[item_id].suppression,

                model = ItemsTemplateData[item_id].model,

                quality = ItemsTemplateData[item_id].quality,
                bonus_parameters = {},
                max_slots = ItemsTemplateData[item_id].max_slots,
                stone_slots = {}
            }
        end


        local i = 1
        while(ItemsTemplateData[item_id].bonus_parameters[i] ~= nil) do
            for index = 1, 3 do
                ItemsData[GetHandleId(bj_lastCreatedItem)].bonus_parameters[i][index] = ItemsTemplateData[item_id].bonus_parameters[i][index]
            end
            i = i + 1
        end

        return bj_lastCreatedItem
    end