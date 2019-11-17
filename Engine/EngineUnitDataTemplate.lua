

    UnitsData = { }


    BARBARIAN_CLASS = 1
    SORCERESS_CLASS = 2

    WEAPON_POINT = 1
    OFFHAND_POINT = 2
    HEAD_POINT = 3
    CHEST_POINT = 4
    LEGS_POINT = 5
    HANDS_POINT = 6
    RING_1_POINT = 7
    RING_2_POINT = 8
    NECKLACE_POINT = 9



    function Update(unit_data)

    end

    --TODO MAKE THIS WORK
    function SetUnitData(attached)
        local new_unit_data = UnitsData[GetHandleId(attached)]


        return new_unit_data
    end


    ---@param source unit
    function NewUnitData(source, class)
        local new_unit_data = {
            Owner = source,

            class = class,
            stats = CreateParametersData(),

            equip_points = { }


        }

        if class == BARBARIAN_CLASS then
            new_unit_data.stats[STR_STAT].value = 10
            new_unit_data.stats[VIT_STAT].value = 9
            new_unit_data.stats[AGI_STAT].value = 6
            new_unit_data.stats[INT_STAT].value = 5
        elseif class == SORCERESS_CLASS then
            new_unit_data.stats[STR_STAT].value = 5
            new_unit_data.stats[VIT_STAT].value = 6
            new_unit_data.stats[AGI_STAT].value = 5
            new_unit_data.stats[INT_STAT].value = 10
        end


        for i = 1, 9 do
            new_unit_data.equip_points[i] = nil
        end

        UnitsData[GetHandleId(source)] = new_unit_data
        return new_unit_data
    end