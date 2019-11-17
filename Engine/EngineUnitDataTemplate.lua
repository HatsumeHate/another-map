

    UnitsData = { }



    function Update(unit_data)

    end

    --TODO MAKE THIS WORK
    function SetUnitData(attached)
        local new_unit_data = UnitsData[GetHandleId(attached)]


        return new_unit_data
    end