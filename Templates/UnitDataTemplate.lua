    UnitsData       = { }

    BARBARIAN_CLASS = 1
    SORCERESS_CLASS = 2
    NO_CLASS = 0

    WEAPON_POINT    = 1
    OFFHAND_POINT   = 2
    HEAD_POINT      = 3
    CHEST_POINT     = 4
    LEGS_POINT      = 5
    HANDS_POINT     = 6
    RING_1_POINT    = 7
    RING_2_POINT    = 8
    NECKLACE_POINT  = 9



    function UpdateParameters(unit_data)
        for i = 1, 36 do
            unit_data.stats[i].update(unit_data, i)
        end
    end

    do
        --TODO MAKE THIS WORK
        function SetUnitData(attached)
            local data = UnitsData[GetHandleId(attached)]

            return data
        end

        -- STR_STAT, VIT_STAT, AGI_STAT, INT_STAT
        local BASE_STATS = {
            [BARBARIAN_CLASS] = { 10, 9, 6, 5 },
            [SORCERESS_CLASS] = { 5, 6, 5, 10 },
            [NO_CLASS] = { 10, 10, 10, 10 }
        }




        ---@param source unit
        ---@param class integer
        ---@param reference_base table
        ---@param reference_weapon table
        function NewUnitData(source, class, reference_base, reference_weapon)
            local class_base_stats = BASE_STATS[class]

            print("unit create init ok")

            local data                 = {
                Owner        = source,
                unit_class        = class,

                base_stats = {
                    strength = class_base_stats[1], vitality = class_base_stats[2], agility = class_base_stats[3], intellect = class_base_stats[4],
                    health = 100, mana = 100, hp_regen = 1, mp_regen = 1, moving_speed = 300
                },

                is_hp_static = false,
                is_mp_static = false,

                equip_point = {},
                stats = {}
            }

            data.equip_point[WEAPON_POINT] = CreateDefaultWeapon()

            data.stats = CreateParametersData()
            print("stats ok")

            print("crit chance on unit? " .. data.equip_point[WEAPON_POINT].CRIT_CHANCE)
            print("name on unit? " .. data.equip_point[WEAPON_POINT].NAME)

            MergeTables(data.base_stats, reference_base)
            MergeTables(data.equip_point[WEAPON_POINT], reference_weapon)
            print("merge ok")

            UpdateParameters(data)
            print("update ok")

            UnitsData[GetHandleId(source)] = data
            print("done")
            return data
        end

    end

    --data.equip_points[CHEST_POINT].defence + data.equip_points[LEGS_POINT].defence