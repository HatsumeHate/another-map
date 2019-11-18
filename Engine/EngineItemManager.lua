
    ItemsData = {}






    function CreateCustomItem(item_id, x, y)
        bj_lastCreatedItem = CreateItem(item_id, x, y)
        local handle = GetHandleId(bj_lastCreatedItem)


        ItemsData[handle] = {
            name = ItemsTemplateData[item_id].name,
            item_type = ItemsTemplateData[item_id].item_type,
            item_subtype = ItemsTemplateData[item_id].subtype,

            damage = ItemsTemplateData[item_id].damage,
            damage_type = ItemsTemplateData[item_id].damage_type,
            attribute = ItemsTemplateData[item_id].attribute,
            attribute_bonus = ItemsTemplateData[item_id].attribute_bonus,

            defence = ItemsTemplateData[item_id].defence,
            suppression = ItemsTemplateData[item_id].suppression,

            attack_speed = ItemsTemplateData[item_id].attack_speed,
            critical_chance = ItemsTemplateData[item_id].critical_chance,
            critical_multiplier = ItemsTemplateData[item_id].critical_multiplier,

            dispersion = { [1] = ItemsTemplateData[item_id].dispersion[1], [2] = ItemsTemplateData[item_id].dispersion[2] },
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


        local i = 1
        while(true) do
            if ItemsTemplateData[item_id].bonus_parameters[i] == nil then
                break
            else
                ItemsData[handle].bonus_parameters[i].param_type = ItemsTemplateData[item_id].bonus_parameters[i].param_type
                ItemsData[handle].bonus_parameters[i].param_value = ItemsTemplateData[item_id].bonus_parameters[i].param_value
                ItemsData[handle].bonus_parameters[i].modificator = ItemsTemplateData[item_id].bonus_parameters[i].modificator
                i = i + 1
            end
        end

        return bj_lastCreatedItem
    end