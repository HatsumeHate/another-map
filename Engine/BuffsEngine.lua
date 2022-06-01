do

    local BUFF_UPDATE = 0.1
    local StunGroup
    local FearGroup
    local BlindGroup
    local FreezeGroup
    local RootGroup



    ---@param unit_data table
    ---@param buff_data table
    local function DeleteBuff(unit_data, buff_data)
        --print("DELETE BUFF")
            for i = 1, #unit_data.buff_list do
                if unit_data.buff_list[i] == buff_data then
                    UnitRemoveAbility(unit_data.Owner, FourCC(buff_data.buff_id))
                    UnitRemoveAbility(unit_data.Owner, FourCC(buff_data.id))

                    if buff_data.level[buff_data.current_level].bonus ~= nil then
                        for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                            ModifyStat(unit_data.Owner, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, false)
                        end
                    end

                    if buff_data.level[buff_data.current_level].effects then
                        for i = 1, #buff_data.level[buff_data.current_level].effects do
                            UnitRemoveEffect(unit_data.Owner, buff_data.level[buff_data.current_level].effects[i])
                        end
                    end

                    if buff_data.level[buff_data.current_level].negative_state and buff_data.level[buff_data.current_level].negative_state > 0 then

                        local state = buff_data.level[buff_data.current_level].negative_state
                        buff_data.level[buff_data.current_level].negative_state = nil

                            if state == STATE_FREEZE and not HasNegativeState(unit_data.Owner, STATE_FREEZE) then
                                SetUnitVertexColor(unit_data.Owner, unit_data.colours.r or 255, unit_data.colours.g or 255, unit_data.colours.b or 255, unit_data.colours.a or 255)
                                SetUnitTimeScale(unit_data.Owner, 1.)
                                GroupRemoveUnit(FreezeGroup, unit_data.Owner)
                            elseif state == STATE_FEAR and not HasNegativeState(unit_data.Owner, STATE_FEAR) then
                                for key = 1, 6 do BlzUnitDisableAbility(unit_data.Owner, KEYBIND_LIST[key].ability, false, false) end
                                UnitRemoveAbility(unit_data.Owner, FourCC("ARal"))
                                ModifyStat(unit_data.Owner, MOVING_SPEED, 0.5, MULTIPLY_BONUS, false)
                                GroupRemoveUnit(FearGroup, unit_data.Owner)
                            elseif state == STATE_STUN and not HasNegativeState(unit_data.Owner, STATE_STUN) then
                                GroupRemoveUnit(StunGroup, unit_data.Owner)
                            elseif state == STATE_BLIND and not HasNegativeState(unit_data.Owner, STATE_BLIND) then
                                GroupRemoveUnit(BlindGroup, unit_data.Owner)
                            elseif state == STATE_ROOT and not HasNegativeState(unit_data.Owner, STATE_ROOT) then
                                GroupRemoveUnit(RootGroup, unit_data.Owner)
                            end

                        if (state == STATE_STUN or state == STATE_FREEZE) and not (IsUnitStunned(unit_data.Owner) or IsUnitFrozen(unit_data.Owner)) then
                            SafePauseUnit(unit_data.Owner, false)
                        end

                    end

                    DestroyTimer(buff_data.update_timer)
                    table.remove(unit_data.buff_list, i)
                    buff_data = nil
                    break
                end
            end

    end

    ---@param target unit
    ---@param buff_id integer
    function GetBuffDataFromUnit(target, buff_id)
        local target_data = GetUnitData(target)

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #target_data.buff_list do
                    if target_data.buff_list[i].id == buff_id then
                        return target_data.buff_list[i]
                    end
                end
            end

        return nil
    end

    ---@param target unit
    ---@param buff_id integer
    function GetBuffLevel(target, buff_id)
        local target_data = GetUnitData(target)

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #target_data.buff_list do
                    if target_data.buff_list[i].id == buff_id then
                        return target_data.buff_list[i].current_level
                    end
                end
            end

        return 0
    end



    ---@param unit unit
    ---@param buff_type number
    ---@param attribute number
    ---@param rank integer
    function RemoveBuffsByType(unit, buff_type, attribute, rank)
        local target_data = GetUnitData(unit)
        local buff

            for i = 1, #target_data.buff_list do
                buff = target_data.buff_list[i]
                if buff.buff_type == buff_type then
                    if (not rank or rank >= buff.rank) and (not attribute or buff.attribute == attribute) then
                        OnBuffExpire(buff.buff_source or nil, unit, buff)
                        DeleteBuff(target_data, buff)
                    end
                end
            end

    end


    ---@param unit unit
    ---@param attribute number
    ---@param rank integer
    function RemoveBuffsByAttribute(unit, attribute, rank)
        local target_data = GetUnitData(unit)
        local buff

            for i = 1, #target_data.buff_list do
                buff = target_data.buff_list[i]
                if buff.attribute == attribute then
                    if not rank or (rank and rank >= buff.rank) then
                        OnBuffExpire(buff.buff_source or nil, unit, buff)
                        DeleteBuff(target_data, buff)
                    end
                end
            end

    end

    ---@param target unit
    ---@param buff_id string
    function RemoveBuff(target, buff_id)
        local target_data = GetUnitData(target)
        local buff_data

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #target_data.buff_list do
                    if target_data.buff_list[i].id == buff_id then
                        buff_data = target_data.buff_list[i]
                    end
                end

                OnBuffExpire(buff_data.buff_source or nil, target, buff_data)
                DeleteBuff(target_data, buff_data)
                return true
            end

        return false
    end



    ---@param target unit
    ---@param buff_id integer
    ---@param time real
    function SetBuffExpirationTime(target, buff_id, time)
        local unit_data = GetUnitData(target)

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #unit_data.buff_list do
                    if unit_data.buff_list[i].id == buff_id then
                        local buff_data = unit_data.buff_list[i]

                        if time == -1 then
                            buff_data.expiration_time = math.floor((buff_data.level[buff_data.current_level].time * 1000) + 0.5)
                        else
                            buff_data.expiration_time = math.floor((time * 1000) + 0.5)
                        end

                        if buff_data.level[buff_data.current_level].negative_state and buff_data.level[buff_data.current_level].negative_state > 0 then
                            buff_data.expiration_time = math.floor((buff_data.expiration_time * ((100. - unit_data.stats[CONTROL_REDUCTION].value) / 100.)) + 0.5)
                        end

                        break
                    end
                end
            end

    end

    ---@param target unit
    ---@param buff_id integer
    ---@return real
    function GetBuffExpirationTime(target, buff_id)
        local unit_data = GetUnitData(target)

            if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                for i = 1, #unit_data.buff_list do
                    if unit_data.buff_list[i].id == buff_id then
                        return unit_data.buff_list[i].expiration_time / 1000.
                    end
                end

            end

        return 0.
    end

    ---@param target unit
    ---@param buff_id integer
    ---@param lvl integer
    function SetBuffLevel(target, buff_id, lvl)
        local unit_data = GetUnitData(target)

            for i = 1, #unit_data.buff_list do
                if unit_data.buff_list[i].id == buff_id then
                    local buff_data = unit_data.buff_list[i]


                    if lvl <= 0 then
                        RemoveBuff(target, buff_id)
                        return
                    elseif lvl >= (buff_data.max_level or 1) then
                        if (buff_data.current_level or 1) == (buff_data.max_level or 1) then
                            return
                        else
                            lvl = (buff_data.max_level or 1)
                        end
                    end


                    if buff_data.level[buff_data.current_level].bonus then
                        for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                            ModifyStat(target, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, false)
                        end
                    end

                    if buff_data.level[buff_data.current_level].effects then
                        for i = 1, #buff_data.level[buff_data.current_level].effects do
                            UnitRemoveEffect(target, buff_data.level[buff_data.current_level].effects[i])
                        end
                    end

                    local logic = lvl >= buff_data.current_level

                    buff_data.current_level = lvl

                        if buff_data.level[lvl].negative_state and buff_data.level[lvl].negative_state > 0 then

                            if buff_data.level[lvl].negative_state == STATE_FREEZE then
                                --if unit_data.channeled_destructor then unit_data.channeled_destructor(target); unit_data.channeled_destructor = nil end
                                SetUnitVertexColor(target, 57, 57, 255, 255)
                                ResetUnitSpellCast(target)
                                SafePauseUnit(target, true)
                                SetUnitTimeScale(target, 0.)
                                GroupAddUnit(FreezeGroup, target)
                            elseif buff_data.level[lvl].negative_state == STATE_STUN then
                                --if unit_data.channeled_destructor then unit_data.channeled_destructor(target); unit_data.channeled_destructor = nil end
                                ResetUnitSpellCast(target)
                                SafePauseUnit(target, true)
                                GroupAddUnit(StunGroup, target)
                                SetUnitAnimation(target, "stand ready")
                            elseif buff_data.level[lvl].negative_state == STATE_FEAR then
                                if unit_data.channeled_destructor then unit_data.channeled_destructor(target); unit_data.channeled_destructor = nil end
                                for key = 1, 6 do BlzUnitDisableAbility(target, KEYBIND_LIST[key].ability, true, false) end
                                UnitAddAbility(target, FourCC("ARal"))
                                ModifyStat(target, MOVING_SPEED, 0.5, MULTIPLY_BONUS, true)
                                GroupAddUnit(FearGroup, target)
                            elseif buff_data.level[lvl].negative_state == STATE_BLIND then
                                GroupAddUnit(BlindGroup, target)
                            elseif buff_data.level[lvl].negative_state == STATE_ROOT then
                                GroupAddUnit(RootGroup, target)
                            end

                            buff_data.expiration_time = math.floor((buff_data.expiration_time * ((100. - unit_data.stats[CONTROL_REDUCTION].value) / 100.)) + 0.5)

                            if buff_data.expiration_time <= 0 then
                                OnBuffExpire(buff_data.buff_source or nil, target, buff_data)
                                DeleteBuff(unit_data, buff_data)
                            end

                        end

                    if buff_data.level[lvl].buff_sfx then
                        local new_effect
                            if buff_data.level[lvl].buff_sfx_point and StringLength(buff_data.level[lvl].buff_sfx_point) > 0 then
                                new_effect = AddSpecialEffectTarget(buff_data.level[lvl].buff_sfx, target, buff_data.level[lvl].buff_sfx_point)
                            else
                                new_effect = AddSpecialEffect(buff_data.level[lvl].buff_sfx, GetUnitX(target), GetUnitY(target))
                            end
                        BlzSetSpecialEffectScale(new_effect, buff_data.level[lvl].buff_sfx_scale or 1.)
                        DestroyEffect(new_effect)
                    end

                    if buff_data.level[buff_data.current_level].bonus then
                        for i2 = 1, #buff_data.level[buff_data.current_level].bonus do
                            --print(GetParameterName(buff_data.level[lvl].bonus[i2].PARAM))
                            --print(buff_data.level[lvl].bonus[i2].VALUE)
                            ModifyStat(target, buff_data.level[buff_data.current_level].bonus[i2].PARAM, buff_data.level[buff_data.current_level].bonus[i2].VALUE, buff_data.level[buff_data.current_level].bonus[i2].METHOD, true)
                        end
                    end

                    if buff_data.level[buff_data.current_level].effects then
                        for i = 1, #buff_data.level[buff_data.current_level].effects do
                            UnitAddEffect(target, buff_data.level[buff_data.current_level].effects[i])
                        end
                    end

                    OnBuffLevelChange(buff_data.buff_source or nil, target, buff_data, logic)

                    break
                end
            end

    end


    ---@param unit unit
    ---@return boolean
    function IsUnitStunned(unit)
        return IsUnitInGroup(unit, StunGroup)
    end

    ---@param unit unit
    ---@return boolean
    function IsUnitFeared(unit)
        return IsUnitInGroup(unit, FearGroup)
    end

    ---@param unit unit
    ---@return boolean
    function IsUnitFrozen(unit)
        return IsUnitInGroup(unit, FreezeGroup)
    end

    ---@param unit unit
    ---@return boolean
    function IsUnitBlinded(unit)
        return IsUnitInGroup(unit, BlindGroup)
    end

    ---@param unit unit
    ---@return boolean
    function IsUnitRooted(unit)
        return IsUnitInGroup(unit, RootGroup)
    end


    ---@param unit unit
    ---@param state integer
    ---@return boolean
    function HasNegativeState(unit, state)
        local data = GetUnitData(unit)

            for i = 1, #data.buff_list do
                local buff_state = data.buff_list[i].level[data.buff_list[i].current_level].negative_state or nil

                    if buff_state and buff_state == state then
                        return true
                    end

            end

        return false
    end

    ---@param unit unit
    ---@return boolean
    function HasAnyDisableState(unit)
        local data = GetUnitData(unit)

            for i = 1, #data.buff_list do

                local state = data.buff_list[i].level[data.buff_list[i].current_level].negative_state or nil

                    if state then
                        if state == STATE_STUN or state == STATE_FREEZE or state == STATE_FEAR then
                            return true
                        end
                    end

            end

        return false
    end


    --TODO infinite bug
    ---@param target unit
    ---@param buff_id string
    ---@param lvl integer
    ---@return table
    function ApplyBuff(source, target, buff_id, lvl)
        if lvl <= 0 then return end
        local buff_data = MergeTables({}, GetBuffData(buff_id))
        local target_data = GetUnitData(target)
        local existing_buff

            buff_data.buff_source = source
            buff_data.current_level = lvl


        if buff_data.level_penalty then
            buff_data.current_level = buff_data.current_level - buff_data.level_penalty
            if buff_data.current_level < 1 then buff_data.current_level = 1 end
        end

            if buff_data.inherit_level == nil or not buff_data.inherit_level then buff_data.current_level = 1
            elseif buff_data.current_level > buff_data.max_level then buff_data.current_level = buff_data.max_level end

            GenerateBuffLevelData(buff_data, buff_data.current_level)
            buff_data.expiration_time = math.floor((buff_data.level[lvl].time * 1000) + 0.5)

            OnBuffPrecast(source, target, buff_data)


                if GetUnitAbilityLevel(target, FourCC(buff_id)) > 0 then
                    for i = 1, #target_data.buff_list do

                        if target_data.buff_list[i].id == buff_id then
                            existing_buff = target_data.buff_list[i]
                            if lvl > existing_buff.current_level then
                                DeleteBuff(target_data, existing_buff)
                            else
                                existing_buff.expiration_time = math.floor((existing_buff.level[existing_buff.current_level].time * 1000) + 0.5)
                                OnBuffSourceChange(existing_buff.buff_source or nil, source, target, existing_buff)
                                existing_buff.buff_source = source
                                buff_data = nil
                                return false
                            end
                            break
                        end

                    end
                end

                if #buff_data.buff_replacer > 0 then
                    for b = 1, #buff_data.buff_replacer do
                        for i = 1, #target_data.buff_list do
                            if buff_data.buff_replacer[b] == target_data.buff_list[i].id then
                                DeleteBuff(target_data, target_data.buff_list[i])
                            end
                        end
                    end
                end


                if buff_data.level[lvl].buff_sfx then
                    local new_effect
                        if buff_data.level[lvl].buff_sfx_point and StringLength(buff_data.level[lvl].buff_sfx_point) > 0 then
                            new_effect = AddSpecialEffectTarget(buff_data.level[lvl].buff_sfx, target, buff_data.level[lvl].buff_sfx_point)
                        else
                            new_effect = AddSpecialEffect(buff_data.level[lvl].buff_sfx, GetUnitX(target), GetUnitY(target))
                        end
                    BlzSetSpecialEffectScale(new_effect, buff_data.level[lvl].buff_sfx_scale or 1.)
                    DestroyEffect(new_effect)
                end


                if buff_data.level[lvl].negative_state and buff_data.level[lvl].negative_state > 0 then

                    buff_data.expiration_time = math.floor((buff_data.expiration_time * ((100. - target_data.stats[CONTROL_REDUCTION].value) / 100.)) + 0.5)

                    if buff_data.expiration_time <= 0 then
                        buff_data = nil
                        return false
                    end

                    if buff_data.level[lvl].negative_state == STATE_FREEZE then
                        --if target_data.channeled_destructor then target_data.channeled_destructor(target); target_data.channeled_destructor = nil end
                        SetUnitVertexColor(target, 57, 57, 255, 255)
                        ResetUnitSpellCast(target)
                        SafePauseUnit(target, true)
                        SetUnitTimeScale(target, 0.)
                        GroupAddUnit(FreezeGroup, target)
                    elseif buff_data.level[lvl].negative_state == STATE_STUN then
                        --if target_data.channeled_destructor then target_data.channeled_destructor(target); target_data.channeled_destructor = nil end
                        ResetUnitSpellCast(target)
                        SafePauseUnit(target, true)
                        GroupAddUnit(StunGroup, target)
                        SetUnitAnimation(target, "stand ready")
                    elseif buff_data.level[lvl].negative_state == STATE_FEAR then
                        if target_data.channeled_destructor then target_data.channeled_destructor(target); target_data.channeled_destructor = nil end
                        for key = 1, 6 do BlzUnitDisableAbility(target, KEYBIND_LIST[key].ability, true, false) end
                        UnitAddAbility(target, FourCC("ARal"))
                        ModifyStat(target, MOVING_SPEED, 0.5, MULTIPLY_BONUS, true)
                        GroupAddUnit(FearGroup, target)
                    elseif buff_data.level[lvl].negative_state == STATE_BLIND then
                        GroupAddUnit(BlindGroup, target)
                    elseif buff_data.level[lvl].negative_state == STATE_ROOT then
                        GroupAddUnit(RootGroup, target)
                    end


                end

            UnitAddAbility(target, FourCC(buff_data.id))
            table.insert(target_data.buff_list, buff_data)


                if buff_data.level[lvl].bonus then
                    for i = 1, #buff_data.level[lvl].bonus do
                        ModifyStat(target, buff_data.level[lvl].bonus[i].PARAM, buff_data.level[lvl].bonus[i].VALUE, buff_data.level[lvl].bonus[i].METHOD, true)
                    end
                end


                if buff_data.level[lvl].effects then
                    for i = 1, #buff_data.level[lvl].effects do
                        UnitAddEffect(target, buff_data.level[lvl].effects[i])
                    end
                end

            local over_time_effect_delay
            if buff_data.level[lvl].effect_delay and buff_data.level[lvl].effect_delay > 0. then
                over_time_effect_delay = math.floor((buff_data.level[buff_data.current_level].effect_delay * 1000.) + 0.5)
            end

            if buff_data.level[lvl].effect_initial_delay then
                over_time_effect_delay = math.floor((buff_data.level[buff_data.current_level].effect_initial_delay * 1000.) + 0.5)
            end


            OnBuffApply(buff_data.buff_source or nil, target, buff_data)

            buff_data.update_timer = CreateTimer()
            TimerStart(buff_data.update_timer, BUFF_UPDATE, true, function()
                if buff_data.expiration_time <= 0 or GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                    OnBuffExpire(buff_data.buff_source or nil, target, buff_data)
                    DeleteBuff(target_data, buff_data)
                else

                    if over_time_effect_delay then
                        if over_time_effect_delay <= 0 then

                            OnBuffOverTimeTrigger(buff_data.buff_source or nil, target, buff_data)

                                if buff_data.level[buff_data.current_level].effect then
                                    ApplyEffect(buff_data.buff_source or nil, target, 0.,0., buff_data.level[buff_data.current_level].effect, buff_data.current_level)
                                end

                            over_time_effect_delay = math.floor((buff_data.level[buff_data.current_level].effect_delay * 1000.) + 0.5)

                        else
                            over_time_effect_delay = over_time_effect_delay - 100
                        end
                    end

                    if not buff_data.infinite then
                        buff_data.expiration_time = buff_data.expiration_time - 100
                    end

                    local state = buff_data.level[buff_data.current_level].negative_state
                    if state and state == STATE_FEAR then
                        if Chance(55.) then
                            local angle
                            local new_x, new_y = GetUnitX(target), GetUnitY(target)

                            if not buff_data.buff_source or buff_data.buff_source == target then angle = GetRandomReal(0., 359.)
                            else angle = AngleBetweenUnits(buff_data.buff_source or nil, target) end
                            
                            new_x = new_x + Rx(150., angle)
                            new_y = new_y + Ry(150., angle)
                            IssuePointOrderById(target, order_move, new_x, new_y)
                        end
                    end
                end

            end)

        return true
    end


    function BuffsInit()
        StunGroup = CreateGroup()
        FreezeGroup = CreateGroup()
        FearGroup = CreateGroup()
        BlindGroup = CreateGroup()
        RootGroup = CreateGroup()
    end

end
