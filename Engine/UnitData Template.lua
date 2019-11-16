

    UnitData = {


    }



    function Update(unit_data)

    end


    function SetUnitData(attached)
        local new_unit_data = UnitData[GetHandleId(attached)]


        return new_unit_data
    end