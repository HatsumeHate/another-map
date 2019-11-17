
    ItemsTemplateData = {}

    ITEM_TYPE_WEAPON    = 1
    ITEM_TYPE_ARMOR     = 2
    ITEM_TYPE_JEWELRY   = 3


    FIST_WEAPON         = 1
    BOW_WEAPON          = 2
    BLUNT_WEAPON        = 3
    GREATBLUNT_WEAPON   = 4
    SWORD_WEAPON        = 5
    GREATSWORD_WEAPON   = 6
    AXE_WEAPON          = 7
    GREATAXE_WEAPON     = 8
    DAGGER_WEAPON       = 9
    STAFF_WEAPON        = 10
    JAWELIN_WEAPON      = 11
    HEAD_ARMOR          = 12
    CHEST_ARMOR         = 13
    LEGS_ARMOR          = 14
    HANDS_ARMOR         = 15
    RING_1_JEWELRY      = 16
    RING_2_JEWELRY      = 17
    NECKLACE_JEWELRY    = 18


    COMMON_ITEM = 1
    RARE_ITEM = 2
    MAGIC_ITEM = 3
    SET_ITEM = 4
    UNIQUE_ITEM = 5







    ---@param new_item table
    function DefineItemTemplate(new_item)
        if new_item.item_subtype == FIST_WEAPON then
            new_item.damage = 4
            new_item.attack_speed = 1.8
            new_item.critical_chance = 0.
            new_item.critical_multiplier = 1.5
            new_item.range = 90.
            new_item.dispersion[1] = 0.9
            new_item.dispersion[2] = 1.1
            new_item.weapon_sound = WEAPON_TYPE_WOOD_LIGHT_BASH
        elseif new_item.item_subtype == SWORD_WEAPON then
            new_item.attack_speed = 1.6
            new_item.critical_chance = 4.
            new_item.critical_multiplier = 2.1
            new_item.range = 90.
            new_item.dispersion[1] = 0.9
            new_item.dispersion[2] = 1.1
            new_item.weapon_sound = WEAPON_TYPE_METAL_MEDIUM_SLICE
        elseif new_item.item_subtype == GREATSWORD_WEAPON then
            new_item.attack_speed = 2.3
            new_item.critical_chance = 5.
            new_item.critical_multiplier = 1.6
            new_item.range = 100.
            new_item.angle = 35.
            new_item.dispersion[1] = 0.9
            new_item.dispersion[2] = 1.1
            new_item.weapon_sound = WEAPON_TYPE_METAL_HEAVY_SLICE
        elseif new_item.item_subtype == AXE_WEAPON then
            new_item.attack_speed = 1.5
            new_item.critical_chance = 6.
            new_item.critical_multiplier = 1.7
            new_item.range = 100.
            new_item.dispersion[1] = 0.85
            new_item.dispersion[2] = 1.15
            new_item.weapon_sound = WEAPON_TYPE_METAL_MEDIUM_CHOP
        elseif new_item.item_subtype == GREATAXE_WEAPON then
            new_item.attack_speed = 2.2
            new_item.critical_chance = 6.
            new_item.critical_multiplier = 1.7
            new_item.range = 110.
            new_item.dispersion[1] = 0.85
            new_item.dispersion[2] = 1.15
            new_item.weapon_sound = WEAPON_TYPE_METAL_HEAVY_CHOP
        elseif new_item.item_subtype == DAGGER_WEAPON then
            new_item.attack_speed = 1.4
            new_item.critical_chance = 9.
            new_item.critical_multiplier = 2.3
            new_item.range = 90.
            new_item.angle = 25.
            new_item.dispersion[1] = 0.9
            new_item.dispersion[2] = 1.1
            new_item.weapon_sound = WEAPON_TYPE_METAL_LIGHT_SLICE
        elseif new_item.item_subtype == STAFF_WEAPON then
            new_item.attack_speed = 2.4
            new_item.critical_chance = 9.
            new_item.critical_multiplier = 2.3
            new_item.range = 100.
            new_item.dispersion[1] = 0.85
            new_item.dispersion[2] = 1.15
            new_item.weapon_sound = WEAPON_TYPE_WOOD_MEDIUM_BASH
        elseif new_item.item_subtype == JAWELIN_WEAPON then
            new_item.attack_speed = 2.3
            new_item.critical_chance = 5.
            new_item.critical_multiplier = 1.7
            new_item.range = 110.
            new_item.dispersion[1] = 0.85
            new_item.dispersion[2] = 1.15
            new_item.weapon_sound = WEAPON_TYPE_METAL_HEAVY_BASH
        elseif new_item.item_subtype == BLUNT_WEAPON then
            new_item.attack_speed = 1.7
            new_item.critical_chance = 5.
            new_item.critical_multiplier = 1.6
            new_item.range = 90.
            new_item.dispersion[1] = 0.8
            new_item.dispersion[2] = 1.2
            new_item.weapon_sound = WEAPON_TYPE_METAL_MEDIUM_BASH
        elseif new_item.item_subtype == GREATBLUNT_WEAPON then
            new_item.attack_speed = 2.4
            new_item.critical_chance = 5.
            new_item.critical_multiplier = 1.7
            new_item.range = 100.
            new_item.dispersion[1] = 0.8
            new_item.dispersion[2] = 1.2
            new_item.weapon_sound = WEAPON_TYPE_METAL_HEAVY_BASH
        elseif new_item.item_subtype == BOW_WEAPON then
            new_item.attack_speed = 2.6
            new_item.critical_chance = 7.
            new_item.critical_multiplier = 2.2
            new_item.range = 1000.
            new_item.dispersion[1] = 0.75
            new_item.dispersion[2] = 1.25
            new_item.weapon_sound = nil
        end

    end


    ---@param name string
    ---@param item_type integer
    ---@param subtype integer
    function DefineNewItem(name, item_type, subtype)
        local new_item

        if item_type == ITEM_TYPE_WEAPON then
            new_item = {
                name = name,
                item_type = item_type,
                item_subtype = subtype,

                damage = 1.,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                attribute = PHYSICAL_ATTRIBUTE,
                attribute_bonus = 0,

                attack_speed = 1.,
                critical_chance = 5.,
                critical_multiplier = 1.5,

                dispersion = { 1., 1.},
                range = 100,
                angle = 30.,
                max_targets = 1,

                missile_on_attack = 0,
                effect_on_attack = 0,
                weapon_sound = nil,
                model = '',

                quality = COMMON_ITEM,
                bonus_parameters = {},
                max_slots = 0,
                stone_slots = {}
            }

            DefineItemTemplate(new_item)

        elseif item_type == ITEM_TYPE_ARMOR then
            new_item = {
                name = name,
                item_type = item_type,
                item_subtype = subtype,

                defence = 0,

                model = '',

                quality = COMMON_ITEM,
                bonus_parameters = {},
                max_slots = 0,
                stone_slots = {}
            }
        elseif item_type == ITEM_TYPE_JEWELRY then
            new_item = {
                name = name,
                item_type = item_type,
                item_subtype = subtype,

                suppression = 0,

                model = '',

                quality = COMMON_ITEM,
                bonus_parameters = {},
                max_slots = 0,
                stone_slots = {}
            }
        end

        return new_item
    end


    function DefineItems()

        ItemsTemplateData['I000'] = DefineNewItem('test sword', ITEM_TYPE_WEAPON, SWORD_WEAPON)
        ItemsTemplateData['I000'].damage = 100
        ItemsTemplateData['I000'].quality = RARE_ITEM
        ItemsTemplateData['I000'].bonus_parameters[1] = { PHYSICAL_BONUS, 20, STRAIGHT_BONUS }
        ItemsTemplateData['I000'].bonus_parameters[2] = { CRIT_CHANCE, 1.25, MULTIPLY_BONUS }

        ItemsTemplateData['I001'] = DefineNewItem('test armor piece', ITEM_TYPE_ARMOR, CHEST_ARMOR)
        ItemsTemplateData['I001'].defence = 50
        ItemsTemplateData['I001'].quality = MAGIC_ITEM

    end