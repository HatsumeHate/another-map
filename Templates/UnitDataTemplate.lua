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

    function Update(unit_data)

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
        function NewUnitData(source, class)
            local data                 = {
                Owner        = source,

                class        = class,
                stats        = CreateParametersData(),

                equip_points = { }
            }

            local base_stats       = BASE_STATS[class]
            data.stats[STR_STAT].value = base_stats[1]
            data.stats[VIT_STAT].value = base_stats[2]
            data.stats[AGI_STAT].value = base_stats[3]
            data.stats[INT_STAT].value = base_stats[4]

            --FIXME присваивать nil бессмысленно ибо отсутствие значение равно nil. Поэтому этот блок смело можно удалить.
            for i = 1, 9 do
                data.equip_points[i] = nil
            end

            UnitsData[GetHandleId(source)] = data
            return data
        end

    end