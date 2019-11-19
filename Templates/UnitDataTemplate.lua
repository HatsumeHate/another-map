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
            BARBARIAN_CLASS = { 10, 9, 6, 5 },
            SORCERESS_CLASS = { 5, 6, 5, 10 },
            NO_CLASS = { 10, 10, 10, 10 }
        }




        ---@param source unit
        ---@param class integer
        ---@param reference_table table
        function NewUnitData(source, class, reference_table)
            local base_stats = BASE_STATS[class]

            print("1")

            local data                 = {
                Owner        = source,

                class        = class,

                base_stats = {
                    STR = base_stats[1], VIT = base_stats[2], AGI = base_stats[3], INT = base_stats[4],
                    HP = 100, MP = 100, hp_regen = 1, mp_regen = 1,
                    moving_speed = 300
                },

                is_hp_static = false,
                is_mp_static = false,

                stats        = CreateParametersData(),

                equip_point = {
                    [WEAPON_POINT] = CreateDefaultWeapon()
                }
            }

            print("2")
            MergeTables(data, reference_table)
            UnitsData[GetHandleId(source)] = data
            print("3")
            return data
        end

    end

    --data.equip_points[CHEST_POINT].defence + data.equip_points[LEGS_POINT].defence