
    local udg_SimError
    local Stop = false
    ForFilter1 = nil
    ForFilter2 = nul
    local SOURCE_UNIT = nil



    function AllFilter()
        return (GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 0.045)
    end

    function EnemiesFilter()
        bj_lastReplacedUnit = GetFilterUnit()
        return (IsUnitEnemy(bj_lastReplacedUnit, GetOwningPlayer(ForFilter1)) and IsUnitVisible(bj_lastReplacedUnit, GetOwningPlayer(ForFilter1)) and GetUnitState(bj_lastReplacedUnit, UNIT_STATE_LIFE ) > 0.045 and GetUnitAbilityLevel(bj_lastReplacedUnit, 'Avul') == 0)
    end

    function EnemiesFilterEx()
        return (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(ForFilter1)) and GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 1. and IsUnitVisible(GetFilterUnit(), GetOwningPlayer(ForFilter1))and not IsUnitInvisible(GetFilterUnit(), GetOwningPlayer(ForFilter1)))
    end
    
    function AllyFilter()
        return (not IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(ForFilter1)) and GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 0.045 and ForFilter1 ~= GetFilterUnit() and GetUnitAbilityLevel(GetFilterUnit(), IGNORE_ID) == 0)
    end


    function nearest_filt()
        return (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(SOURCE_UNIT)) and GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 0.045)
    end


    function GetMaxAvailableDistanceFilter()
        if (GetDestructableTypeId(GetFilterDestructable()) == 'YTfb' or GetDestructableTypeId(GetFilterDestructable()) == 'YTab' or GetDestructableTypeId(GetFilterDestructable()) == 'YTpc' or GetDestructableTypeId(GetFilterDestructable()) == 'CTtr' or GetDestructableTypeId(GetFilterDestructable()) == 'CTtc' or GetDestructableTypeId(GetFilterDestructable()) == 'ATtr' or GetDestructableTypeId(GetFilterDestructable()) == 'ATtc') then
            Stop = true
        end
        return false
    end


    function GetMaxAvailableDistanceEx(a, range, ang)
        local steps = R2I(range / 25.)
        local current_range = 25.
        local x = GetUnitX(a)
        local y = GetUnitY(a)
        local rct = Rect(x - 50., y - 50., x + 50., y + 50.)

            while(steps ~= 0) do
                MoveRectTo(rct, GetRectCenterX(rct) + Rx(25.,ang), GetRectCenterY(rct) + Ry(25.,ang))
                Stop = false
                EnumDestructablesInRect(rct, Filter(GetMaxAvailableDistanceFilter), null)

                    if Stop then 
                        break
                    end

                current_range = current_range + 25.
                steps = steps - 1
            end
            
            Stop = false
            RemoveRect(rct)

            if steps == 0 then 
                current_range = range
            end

        return current_range
    end


    function ABU (A, B)
        return Atan2(GetUnitY(B)-GetUnitY(A), GetUnitX(B)-GetUnitX(A))*bj_RADTODEG
    end

    function ABUC (A, B_x, B_y)
        return Atan2(B_y-GetUnitY(A), B_x-GetUnitX(A))*bj_RADTODEG
    end

    function ABUC2 (A_x, A_y, B_x, B_y)
        return Atan2(B_y - A_y, B_x - A_x) * bj_RADTODEG
    end

    function DBU (A, B)
        local dx = GetUnitX(B) - GetUnitX(A)
        local dy = GetUnitY(B) - GetUnitY(A)
            return SquareRoot((dx * dx) + (dy * dy))
    end

    function DBC ( A, B_x, B_y)
        local dx = B_x - GetUnitX(A)
        local dy = B_y - GetUnitY(A)
              return SquareRoot((dx * dx) + (dy * dy))
    end

    function DBC2 (A_x, A_y, B_x, B_y)
        local dx = B_x - A_x
        local dy = B_y - A_y
            return SquareRoot((dx * dx) + (dy * dy))
    end
    
    function Distance_3D( A_x, A_y, B_x, B_y, A_z, B_z) 
        local ldx = B_x - A_x
        local dy = B_y - A_y
        local dz = B_z - A_z
            return SquareRoot((dx * dx) + (dy * dy) + (dz * dz))
    end

    function DBC_Ex (A, B_x, B_y)
        local dx = B_x - GetUnitX(A)
        local dy = B_y - GetUnitY(A)
            return GetMaxAvailableDistanceEx(A, SquareRoot((dx * dx) + (dy * dy)), ABUC(A, B_x, B_y))
    end
    
    function GetDistance3D( A_x,  A_y,  A_z,  B_x,  B_y,  B_z)
        local dx = B_x - A_x
        local dy = B_y - A_y
        local dz = B_z - A_z
            return SquareRoot((dx * dx) + (dy * dy) + (dz * dz))
    end

    function TBU (A, B, speed) 
        local dx = GetUnitX(B) - GetUnitX(A)
        local dy = GetUnitY(B) - GetUnitY(A)
            return (SquareRoot((dx * dx) + (dy * dy)) / speed)
    end

    function TBC (A, B_x, B_y, speed)
        local dx = B_x - GetUnitX(A)
        local dy = B_y - GetUnitY(A)
            return (SquareRoot((dx * dx) + (dy * dy)) / speed)
    end

    function TBC_Ex (A, B_x, B_y, speed)
        local dx = B_x - GetUnitX(A)
        local dy = B_y - GetUnitY(A)
            return (GetMaxAvailableDistanceEx(A, SquareRoot((dx * dx) + (dy * dy)), ABUC(A, B_x, B_y))/speed)
    end

    function ParabolaZ(h, d, x)
        return (4 * h / d) * (d - x) * (x / d)
    end

    function GetAngleOfRebound(current_angle, angle_between_unit_and_bound, range)
        return (-current_angle + 180. + 2. * angle_between_unit_and_bound) + GetRandomReal(-range, range)
    end
