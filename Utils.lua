
	hash = InitHashtable()
	local udg_SimError
	local Stop        = false
	ForFilter1        = nil
	ForFilter2        = nil
	IGNORE_ID = 'A00Z'
	local SOURCE_UNIT



	-- cjass legacy support
	function GetHp(u)
		return GetUnitState(u, ConvertUnitState(0))
	end

	function GetMp(u)
		return GetUnitState(u, ConvertUnitState(2))
	end

	function SetHp(u,n)
		SetUnitState(u, ConvertUnitState(0), n)
	end

	function SetMp(u,n)
		SetUnitState(u, ConvertUnitState(2), n)
	end

	function GetMaxHp(u)
		return GetUnitState(u, ConvertUnitState(1))
	end

	function GetMaxMp(u)
		return GetUnitState(u, ConvertUnitState(3))
	end

	function SetMaxHp(u,n)
		SetUnitState(u, ConvertUnitState(1), n)
	end

	function SetMaxMp(u,n)
		SetUnitState(u, ConvertUnitState(3), n)
	end

	function Chance(ch)
		return GetRandomReal(0.01, 100.) <= ch
	end

	function Clear(h)
		FlushChildHashtable(hash, GetHandleId(h))
	end

	function GetData(v)
		return GetUnitUserData(v)
	end

	function SetData(v,d)
		return SetUnitUserData(v, d)
	end

	function GetTimerAttach(h)
		return LoadInteger(hash, GetHandleId(h), 0)
	end

	function TimerStartEx(whichTimer, period, handlefunc, userdata)
		SaveInteger(hash, GetHandleId(whichTimer), userdata)
		TimerStart(whichTimer, period, false, handlefunc)
	end

	function SaveUnit(h,d)
		return SaveUnitHandle(hash, GetHandleId(h), 0, d)
	end

	function LoadUnit(h)
		return LoadUnitHandle(hash, GetHandleId(h), 0)
	end

	function SaveEffect(h, d)
		return SaveEffectHandle(hash, GetHandleId(h), 0, d)
	end

	function LoadEffect(h)
		return LoadEffectHandle(hash, GetHandleId(h), 0)
	end

	function Erase(h)
		FlushChildHashtable(hash, GetHandleId(h))
	end

	function H2I(h)
		return GetHandleId(h)
	end

	function CT()
		return CreateTimer()
	end

	function CG()
		return CreateGroup()
	end

	function DG(g)
		DestroyGroup(g)
	end

	function GC()
		GroupClear(g)
	end

	function PT(t)
		PauseTimer(t)
	end

	function DT(t)
		DestroyTimer(t)
	end

	function GC()
		GroupClear(g)
	end

	function Gx(a)
		return GetUnitX(a)
	end

	function Gy(a)
		return GetUnitY(a)
	end

	function Ga(a)
		return GetUnitFacing(a)
	end

	function Rx(x, a)
		return x * Cos(a * bj_DEGTORAD)
	end

	function Ry(x, a)
		return x * Sin(a * bj_DEGTORAD)
	end

	function RndAng()
		return GetRandomReal(0., 360.)
	end

	function RndR(l,h)
		return  GetRandomReal(l,h)
	end

	function RndI(l,h)
		return  GetRandomInt(l,h)
	end



	function AllFilter()
		return (GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 0.045)
	end

	function EnemiesFilter()
		bj_lastReplacedUnit = GetFilterUnit()
		return (IsUnitEnemy(bj_lastReplacedUnit, GetOwningPlayer(ForFilter1)) and IsUnitVisible(bj_lastReplacedUnit, GetOwningPlayer(ForFilter1)) and GetUnitState(bj_lastReplacedUnit, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(bj_lastReplacedUnit, 'Avul') == 0)
	end

	function EnemiesFilterEx()
		return (IsUnitEnemy(GetFilterUnit(), GetOwningPlayer(ForFilter1)) and GetUnitState(GetFilterUnit(), UNIT_STATE_LIFE) > 1. and IsUnitVisible(GetFilterUnit(), GetOwningPlayer(ForFilter1)) and not IsUnitInvisible(GetFilterUnit(), GetOwningPlayer(ForFilter1)))
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
		local steps         = R2I(range / 25.)
		local current_range = 25.
		local x             = GetUnitX(a)
		local y             = GetUnitY(a)
		local rct           = Rect(x - 50., y - 50., x + 50., y + 50.)

		while (steps ~= 0) do
			MoveRectTo(rct, GetPolarOffsetX(GetRectCenterX(rct), 25., ang), GetPolarOffsetY(GetRectCenterY(rct), 25., ang))
			Stop = false
			EnumDestructablesInRect(rct, Filter(GetMaxAvailableDistanceFilter), nil)

			if Stop then
				break
			end

			current_range = current_range + 25.
			steps         = steps - 1
		end

		Stop = false
		RemoveRect(rct)

		if steps == 0 then
			current_range = range
		end

		return current_range
	end


	---@param A unit
	---@param B unit
	function AngleBetweenUnits (A, B)
		return Atan2(GetUnitY(B) - GetUnitY(A), GetUnitX(B) - GetUnitX(A)) * bj_RADTODEG
	end

	---@param A unit
	---@param B_x real
	---@param B_y real
	function AnglebetweenUnitXY (A, B_x, B_y)
		return Atan2(B_y - GetUnitY(A), B_x - GetUnitX(A)) * bj_RADTODEG
	end

	---@param A unit
	---@param B unit
	function DistanceBetweenUnits (A, B)
		local dx = GetUnitX(B) - GetUnitX(A)
		local dy = GetUnitY(B) - GetUnitY(A)
		return SquareRoot((dx * dx) + (dy * dy))
	end

	---@param A unit
	---@param B_x real
	---@param B_y real
	function DistanceBetweenUnitXY (A, B_x, B_y)
		local dx = B_x - GetUnitX(A)
		local dy = B_y - GetUnitY(A)
		return SquareRoot((dx * dx) + (dy * dy))
	end

	---@param A unit
	---@param B_x real
	---@param B_y real
	function DistanceBetweenUnitXY_Ex (A, B_x, B_y)
		local dx = B_x - GetUnitX(A)
		local dy = B_y - GetUnitY(A)
		return GetMaxAvailableDistanceEx(A, SquareRoot((dx * dx) + (dy * dy)), AnglebetweenUnitXY(A, B_x, B_y))
	end

	---@param A_x real
	---@param A_y real
	---@param A_z real
	---@param B_x real
	---@param B_y real
	---@param B_z real
	function GetDistance3D(A_x, A_y, A_z, B_x, B_y, B_z)
		local dx = B_x - A_x
		local dy = B_y - A_y
		local dz = B_z - A_z
		return SquareRoot((dx * dx) + (dy * dy) + (dz * dz))
	end

	---@param A unit
	---@param B unit
	---@param speed real
	function TimeBetweenUnits (A, B, speed)
		local dx = GetUnitX(B) - GetUnitX(A)
		local dy = GetUnitY(B) - GetUnitY(A)
		return (SquareRoot((dx * dx) + (dy * dy)) / speed)
	end

	function TimeBetweenUnitXY (A, B_x, B_y, speed)
		local dx = B_x - GetUnitX(A)
		local dy = B_y - GetUnitY(A)
		return (SquareRoot((dx * dx) + (dy * dy)) / speed)
	end

	---@param A unit
	---@param B_x real
	---@param B_y real
	---@param speed real
	function TimeBetweenUnitXY_Ex (A, B_x, B_y, speed)
		local dx = B_x - GetUnitX(A)
		local dy = B_y - GetUnitY(A)
		return (GetMaxAvailableDistanceEx(A, SquareRoot((dx * dx) + (dy * dy)), AnglebetweenUnitXY(A, B_x, B_y)) / speed)
	end

	function ParabolaZ(h, d, x)
		return (4 * h / d) * (d - x) * (x / d)
	end

	---@param current_angle real
	---@param angle_between_unit_and_bound real
	---@param range real
	function GetAngleOfRebound(current_angle, angle_between_unit_and_bound, range)
		return (-current_angle + 180. + 2. * angle_between_unit_and_bound) + GetRandomReal(-range, range)
	end


	---@param uF unit
	---@param uWhichBack unit
	function IsUnitBack (uF, uWhichBack)
		local r1 = bj_RADTODEG * Atan2(GetUnitY(uWhichBack) - GetUnitY(uF), GetUnitX(uWhichBack) - GetUnitX(uF)) + 360.
		local r2 = GetUnitFacing(uWhichBack) + 360.
			if GetUnitY(uWhichBack) < GetUnitY(uF) then
				r1 = r1 + 360.
			end
		return r1<=(r2+45.) and r1>=(r2-45.)
	end


	---@param ataker unit
	---@param victim unit
	function IsUnitAtSide(ataker, victim)
		local angle1 = GetUnitFacing(victim)
		local angle2 = AngleBetweenUnits(ataker,victim)

		if not (GetUnitY(victim) > GetUnitY(ataker)) then
			angle1 = angle1 - 360
		end

		if (angle2 <= ( angle1 + 135.00 ) and angle2 >= ( angle1 + 45.00 ))
				or (angle2 <= ( angle1 - 45.00 ) and angle2 >= ( angle1 - 135.00 ))
				or (GetUnitY(victim) > GetUnitY(ataker) and GetUnitX(victim) > GetUnitX(ataker) and angle2 <= ( angle1 - 225.00 ) and angle2 >= ( angle1 - 315.00 ))
				or (GetUnitY(victim) < GetUnitY(ataker) and GetUnitX(victim) > GetUnitX(ataker) and angle2 >= ( angle1 + 225.00 ) and angle2 <= ( angle1 + 315.00 )) then
			return true
		end
		return false
	end

	---@param x real
	---@param y real
	---@param victim unit
	function IsUnitAtSideXY(x, y, victim)
		local angle1 = GetUnitFacing(victim)
		local angle2 = AnglebetweenUnitXY(x, y, Gx(victim), Gy(victim))

		if not (GetUnitY(victim) > y) then angle1 = angle1 - 360. end

		if (angle2 <= ( angle1 + 180.00 ) and angle2 >= ( angle1 + 90.00 )) or (GetUnitY(victim) > y and GetUnitX(victim) > x and angle2 <= ( angle1 - 180.00 ) and angle2 >= ( angle1 - 360.00 )) then
		 	return 1
		elseif (angle2 <= ( angle1 - 90.00 ) and angle2 >= ( angle1 - 180.00 )) or (GetUnitY(victim) < y and GetUnitX(victim) > x and angle2 >= ( angle1 + 180.00 ) and angle2 <= ( angle1 + 360.00 )) then
			return 2
		end

		return 0
	end

	---@param b unit
	---@param a unit
	function IsRight(b, a)
		local f = GetUnitFacing(a)
		local ang = AngleBetweenUnits(a, b)

			if not(GetUnitY(b) > GetUnitY(a)) then f =  f - 360. end

			if ((ang <= ( f + 135.00 ) and ang >= ( f + 45.00 )) or (GetUnitY(b) > GetUnitY(a) and GetUnitX(b) > GetUnitX(a) and ang <= ( f - 225.00 ) and ang >= ( f - 315.00 ))) then
				return false
			end

		return true
	end

	---@param a unit
	---@param x real
	---@param y real
	function WhichSide(a, x, y)
		local facing = GetUnitFacing(a)
		local angle = AnglebetweenUnitXY(a, x, y)
		local float_angle

				if angle < 0. then
					angle = angle + 360.
				end

				float_angle = facing - angle

				if float_angle < 0. then
					float_angle = float_angle + 360.
				end

			return float_angle < 180.
		end


	---@param a unit
	---@param x real
	---@param y real
	function IsFront(a, x, y)
		local left = (GetUnitFacing(a) - 90.) + 360.
		local right = (GetUnitFacing(a) + 90.) + 360.
		local angle = AnglebetweenUnitXY(a, x, y)

			if angle < 0. then angle = angle + 360. end
			angle = angle + 360.

		return (angle >= left and angle <= right)
	end


	---@param a real
	---@param w real
	---@param x real
	---@param y real
	---@param logic boolean
	function IsAngleInFace(a,  w,  x,  y,  logic)
		local facing = GetUnitFacing(a)
		local angle = AnglebetweenUnitXY(a, x, y)
		local float_angle

			if angle < 0. then angle = angle + 360. end

			if logic then
				facing = facing + 180.
				if facing > 360. then facing = facing - 360. end
			end

			if facing < angle then
				float_angle = angle - facing
				if float_angle > 180. then float_angle = (facing - angle + 360.) end
			else
				float_angle = facing - angle
				if float_angle > 180. then float_angle = (angle - facing + 360.) end
			end

			return float_angle <= w
		end