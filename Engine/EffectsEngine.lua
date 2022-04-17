do




    ---@param sfx string
    ---@param target unit
    ---@param point string
    local function PlaySpecialEffect(sfx, target, point, scale, duration)

        if sfx then
            local new_effect = AddSpecialEffectTarget(sfx, target, point or "chest")
                BlzSetSpecialEffectScale(new_effect, scale or 1.)
                DelayAction(duration or 0., function() DestroyEffect(new_effect) end)
        end

    end

    local function PlaySpecialEffectPack(pack, target)
        if pack then
            for i = 1, #pack do
                local new_effect = AddSpecialEffectTarget(pack[i].effect, target, pack[i].point or "chest")
                BlzSetSpecialEffectScale(new_effect, pack[i].scale or 1.)
                DelayAction(pack[i].duration or 0., function() DestroyEffect(new_effect) end)
            end
        end
    end


    ---@param source unit
    ---@param target unit
    ---@param effect_data table
    ---@param lvl integer
    ---@param target_type integer
    local function ModifyBuffsEffect(source, target, effect_data, lvl, target_type)
        local myeffect_leveldata = effect_data.level[lvl]

        if myeffect_leveldata.applied_buff == nil then return end

            for i = 1, #myeffect_leveldata.applied_buff do
                local myeffect = myeffect_leveldata.applied_buff[i]

                    if myeffect.target_type == target_type then
                        if myeffect.modificator == ADD_BUFF then
                            ApplyBuff(source, target, myeffect.buff_id, lvl)
                        elseif myeffect.modificator == REMOVE_BUFF then
                            RemoveBuff(target, myeffect.buff_id)
                        elseif myeffect.modificator == INCREASE_BUFF_LEVEL then
                            local l = GetBuffLevel(target, myeffect.buff_id)
                            if l == 0 then
                                ApplyBuff(source, target, myeffect.buff_id, lvl)
                            else
                                SetBuffLevel(target, myeffect.buff_id, l + 1)
                            end
                        elseif myeffect.modificator == DECREASE_BUFF_LEVEL then
                            SetBuffLevel(target, myeffect.buff_id, GetBuffLevel(target, myeffect.buff_id) - 1)
                        elseif myeffect.modificator == SET_BUFF_LEVEL then
                            SetBuffLevel(target, myeffect.buff_id, myeffect.value)
                        elseif myeffect.modificator == SET_BUFF_TIME then
                            SetBuffExpirationTime(target, myeffect.buff_id, myeffect.value)
                        end
                    end

            end

    end


    ---@param data table
    ---@param target_type integer
    local function CountBuffEffects(data, target_type)
        local count = 0
            for i = 1, #data do
                if data[i].target_type == target_type then
                    count = count + 1
                end
            end
        return count
    end



    function ApplyRestoreEffect(source, target, data, lvl)
        local myeffect = data.level[lvl]

            if myeffect.life_restored and myeffect.life_restored > 0 then
                SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + (myeffect.life_restored * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01)))
                CreateHitnumber(R2I(myeffect.life_restored), source, target, HEAL_STATUS)
            elseif myeffect.life_percent_restored and myeffect.life_percent_restored > 0 then
                local value = BlzGetUnitMaxHP(target) * (myeffect.life_percent_restored * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01))
                SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + value)
                CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
            end

            if myeffect.resource_restored and myeffect.resource_restored > 0 then
                SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + myeffect.resource_restored)
                CreateHitnumber(R2I(myeffect.resource_restored), source, target, RESOURCE_STATUS)
            elseif myeffect.resource_percent_restored ~= nil and myeffect.resource_percent_restored > 0 then
                local value = BlzGetUnitMaxMana(target) * myeffect.resource_percent_restored
                SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + value)
                CreateHitnumber(R2I(value), source, target, RESOURCE_STATUS)
            end

            if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_caster_restore, source) end
            --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_unit, target) end

    end


    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    ---@param target_type integer
    function ApplyBuffEffect(source, target, data, lvl, target_type)
        local myeffect = data.level[lvl]

        if myeffect.hit_once_in then
            local unit_data = GetUnitData(target)

                if unit_data.effectstacks then
                    if unit_data.effectstacks[data.id] and unit_data.effectstacks[data.id] <= lvl then
                        return
                    else
                        unit_data.effectstacks[data.id] = lvl
                        DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                    end
                else
                    unit_data.effectstacks = {}
                    unit_data.effectstacks[data.id] = lvl
                    DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                end

        end

        PlaySpecialEffect(myeffect.SFX_on_unit, target, myeffect.SFX_on_unit_point, myeffect.SFX_on_unit_scale, myeffect.SFX_on_unit_duration)
        if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_unit, target) end
        if myeffect.sound_on_hit then
            AddSoundVolumeZ(myeffect.sound_on_hit.pack[GetRandomInt(1, #myeffect.sound_on_hit.pack)], GetUnitX(target), GetUnitY(target), 35., myeffect.sound_on_hit.volume, myeffect.sound_on_hit.cutoff)
        end
        --print("add buff")
        -- delay for effect animation
            local timer = CreateTimer()
            TimerStart(timer, myeffect.hit_delay or 0., false, function()
                ModifyBuffsEffect(source, target, data, lvl, target_type)
                OnEffectApply(source, target, data)
                DestroyTimer(timer)
            end)
    end

    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    function ApplyEffectHealing(source, target, data, lvl)
        local myeffect = data.level[lvl]

        if myeffect.hit_once_in then
            local unit_data = GetUnitData(target)

                if unit_data.effectstacks then
                    if unit_data.effectstacks[data.id] and unit_data.effectstacks[data.id] <= lvl then
                        return
                    else
                        unit_data.effectstacks[data.id] = lvl
                        DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                    end
                else
                    unit_data.effectstacks = {}
                    unit_data.effectstacks[data.id] = lvl
                    DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                end

        end

        PlaySpecialEffect(myeffect.SFX_on_unit, target, myeffect.SFX_on_unit_point, myeffect.SFX_on_unit_scale, myeffect.SFX_on_unit_duration)
        if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_unit, target) end

        --print("healing effect")
            -- delay for effect animation
            local timer = CreateTimer()
            TimerStart(timer, myeffect.hit_delay or 0., false, function()
                if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                    local value = GetUnitState(target, UNIT_STATE_LIFE) + myeffect.heal_amount
                    SetUnitState(target, value)
                    CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
                    ModifyBuffsEffect(source, target, data, lvl, ON_ALLY)
                    OnEffectApply(source, target, data)
                end
                DestroyTimer(timer)
            end)

    end

    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    function ApplyEffectDamage(source, target, data, lvl)
        local myeffect = data.level[lvl]

        if myeffect.hit_once_in then
            local unit_data = GetUnitData(target)

                if unit_data.effectstacks then
                    if unit_data.effectstacks[data.id] and unit_data.effectstacks[data.id] <= lvl then
                        return
                    else
                        unit_data.effectstacks[data.id] = lvl
                        DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                    end
                else
                    unit_data.effectstacks = {}
                    unit_data.effectstacks[data.id] = lvl
                    DelayAction(myeffect.hit_once_in, function() unit_data.effectstacks[data.id] = nil end)
                end

        end

            PlaySpecialEffect(myeffect.SFX_on_unit, target, myeffect.SFX_on_unit_point, myeffect.SFX_on_unit_scale, myeffect.SFX_on_unit_duration)
            if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_unit, target) end
            -- delay for effect animation
            local timer = CreateTimer()
            TimerStart(timer, myeffect.hit_delay or 0., false, function()
                if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                    --print("effect level data : ".. "attribute " .. GetItemAttributeName(myeffect.attribute) .. " damage type " .. I2S(myeffect.damage_type) .. " power " .. I2S(myeffect.power))

                    DamageUnit(source, target,
                            myeffect.power or 0,
                            myeffect.attribute or PHYSICAL_ATTRIBUTE,
                            myeffect.damage_type or DAMAGE_TYPE_NONE,
                            myeffect.attack_type or nil,
                            myeffect.can_crit or false,
                            myeffect.is_direct or false,
                            myeffect.is_sound or false,
                            { eff = data, l = lvl }
                    )

                    ModifyBuffsEffect(source, target, data, lvl, ON_ENEMY)

                    if myeffect.sound_on_hit then
                        AddSoundVolumeZ(myeffect.sound_on_hit.pack[GetRandomInt(1, #myeffect.sound_on_hit.pack)], GetUnitX(target), GetUnitY(target), 35., myeffect.sound_on_hit.volume, myeffect.sound_on_hit.cutoff)
                        --AddSound(myeffect.sound, x, y)
                    end

                    if myeffect.life_restored_from_hit or myeffect.resource_restored_from_hit then
                        ApplyRestoreEffect(source, source, data, lvl)
                    end


                    OnEffectApply(source, target, data)
                end
                DestroyTimer(timer)
            end)

    end

    function HasTag(tags, tag)

        if not tags then return false end

        for i = 1, #tags do
            if tags[i] == tag then
                return true
            end
        end
        return false
    end

    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param effect_id integer
    ---@param lvl integer
    ---@return table
    function ApplyEffect(source, target, x, y, effect_id, lvl, tags)
        local data = GetEffectData(effect_id)
        local player_entity = GetOwningPlayer(source)

            if data then data = MergeTables({}, data)
            else return end


        data.current_level = lvl

            if data.get_level_from_skill then
                data.current_level = UnitGetAbilityLevel(source, data.get_level_from_skill)
            elseif data.get_level_from_wave then
                data.current_level = Current_Wave
            end


        GenerateEffectLevelData(data, data.current_level)
        local current_level = data.current_level

        if tags then data.tags = tags end

        OnEffectPrecast(source, target, x, y, data)

        if current_level ~= data.current_level then
            GenerateEffectLevelData(data, data.current_level)
        end

        local myeffect = data.level[data.current_level]

        --print("EFFECT START -> " .. data.name .. " with level " .. data.current_level)

        data.remove_timer = CreateTimer()
            TimerStart(data.remove_timer, (myeffect.delay or 0.) + (myeffect.hit_delay or 0.) + 1., false, function()
                DestroyTimer(data.remove_timer)
                data = nil
            end)


        if target then x = GetUnitX(target); y = GetUnitY(target)
        elseif target == nil and (x == 0 or y == 0) then x = GetUnitX(source); y = GetUnitY(source) end

        if myeffect.force_from_caster_position then
            x = GetUnitX(source)
            y = GetUnitY(source)
        end

        data.effect_x = x
        data.effect_y = y

            local timer = CreateTimer()
            TimerStart(timer, myeffect.SFX_delay or 0., false, function()
                --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_point, target or source) end
                if myeffect.SFX_used then
                    local effect = AddSpecialEffect(myeffect.SFX_used, x, y)

                    BlzSetSpecialEffectScale(effect, 1.)
                    BlzSetSpecialEffectScale(effect, myeffect.SFX_used_scale or 1.)

                        if myeffect.timescale then BlzSetSpecialEffectTimeScale(effect, 1. + (1. - myeffect.timescale)) end

                        if myeffect.SFX_inherit_angle then
                            BlzSetSpecialEffectOrientation(effect, GetUnitFacing(source) * bj_DEGTORAD, 0., 0.)
                        elseif myeffect.SFX_facing then
                            BlzSetSpecialEffectOrientation(effect, myeffect.SFX_facing * bj_DEGTORAD, 0., 0.)
                        elseif myeffect.SFX_random_angle then
                            BlzSetSpecialEffectOrientation(effect, GetRandomReal(0., 360.) * bj_DEGTORAD, 0., 0.)
                        end

                        if myeffect.SFX_bonus_z then BlzSetSpecialEffectZ(effect, GetZ(x, y) + myeffect.SFX_bonus_z) end
                        DelayAction(myeffect.SFX_lifetime or 0., function() DestroyEffect(effect) end)

                end
                DestroyTimer(GetExpiredTimer())
            end)


        PlaySpecialEffect(myeffect.SFX_on_caster, source, myeffect.SFX_on_caster_point, myeffect.SFX_on_caster_scale, myeffect.SFX_on_caster_duration)
        if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_caster, source) end

        if myeffect.sound then
            for i = 1, #myeffect.sound do
                DelayAction(myeffect.sound[i].delay or 0., function()
                    local sound = myeffect.sound[i]
                    AddSoundVolumeZ(sound.pack[GetRandomInt(1, #sound.pack)], x, y, 35., sound.volume, sound.cutoff)
                end)
            end
        end

            local timer = CreateTimer()
            TimerStart(timer, (myeffect.delay or 0.) * (myeffect.timescale or 1.), false, function()

                if myeffect.sound_timed and myeffect.sound_timed.pack then AddSoundVolumeZ(myeffect.sound.pack[GetRandomInt(1, #myeffect.sound_timed.pack)], x, y, 35., myeffect.sound_timed.volume, myeffect.sound_timed.cutoff) end
                if myeffect.shake_magnitude then ShakeByCoords(x, y, myeffect.shake_magnitude, myeffect.shake_duration, myeffect.shake_distance) end

                if (myeffect.life_percent_restored and myeffect.life_percent_restored > 0.) or (myeffect.resource_percent_restored and myeffect.resource_percent_restored > 0.) then
                    --PlaySpecialEffect(myeffect.SFX_on_caster, source, myeffect.SFX_on_caster_point, myeffect.SFX_on_caster_scale, myeffect.SFX_on_caster_duration)
                    --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_caster, source) end

                    local timer = CreateTimer()
                    TimerStart(timer, myeffect.hit_delay or 0., false, function()
                        ApplyRestoreEffect(source, source, data, lvl)
                        DestroyTimer(GetExpiredTimer())
                    end)

                end

                --print("1")
                -- damaging
                if (myeffect.power and myeffect.power > 0) or (myeffect.attack_percent_bonus and myeffect.attack_percent_bonus > 0.) or (myeffect.weapon_damage_percent_bonus and myeffect.weapon_damage_percent_bonus > 0.) then
                    -- multiple target damage
                    --print("power > 0")

                    if myeffect.global_crit then
                        local bonus_critical = myeffect.bonus_crit_chance and myeffect.bonus_crit_chance or 0.

                            if GetRandomInt(1, 100) <= GetCriticalChance(source, bonus_critical) then myeffect.critical_strike_flag = true
                            else myeffect.can_crit = false end

                        end

                    if data.single_attack then
                        local attacker = GetUnitData(source)
                            if not (TimerGetRemaining(attacker.attack_timer) > 0.) then
                                data.single_attack_instance = true
                            end
                    end

                    local targets = myeffect.max_targets or 1

                    if myeffect.area_of_effect and myeffect.area_of_effect > 0. then
                        --print("multiple targets")
                        local enemy_group = CreateGroup()

                        if myeffect.wave_speed then
                            local damaged_group = CreateGroup()
                            local timer = CreateTimer()
                            local radius = 5.
                            local step = myeffect.wave_speed / ((myeffect.area_of_effect / myeffect.wave_speed) / 0.025)

                                TimerStart(timer, 0.025, true, function()

                                    radius = radius + step
                                    if radius > myeffect.area_of_effect then radius = myeffect.area_of_effect end

                                    GroupEnumUnitsInRange(enemy_group, x, y, radius, nil)

                                        for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                            local picked = BlzGroupUnitAt(enemy_group, index)

                                            if IsUnitEnemy(picked, player_entity) and not IsUnitInGroup(picked, damaged_group) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                                if myeffect.angle_window ~= nil and myeffect.angle_window > 0. then
                                                    if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                        ApplyEffectDamage(source, picked, data, lvl)
                                                        GroupAddUnit(damaged_group, picked)
                                                    end
                                                else
                                                    ApplyEffectDamage(source, picked, data, lvl)
                                                    GroupAddUnit(damaged_group, picked)
                                                end

                                                targets = targets - 1
                                                if targets <= 0 then break end
                                            end

                                        end

                                    if radius >= myeffect.area_of_effect then
                                        DestroyTimer(timer)
                                        DestroyGroup(damaged_group)
                                        DestroyGroup(enemy_group)
                                    end

                                end)


                        else
                            GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)
                            --print("targets - " .. I2S(BlzGroupGetSize(enemy_group)))

                                for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(enemy_group, index)

                                    if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                        if myeffect.angle_window ~= nil and myeffect.angle_window > 0. then
                                            if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                ApplyEffectDamage(source, picked, data, lvl)
                                            end
                                        else
                                            ApplyEffectDamage(source, picked, data, lvl)
                                        end

                                        targets = targets - 1
                                        if targets <= 0 then break end
                                    end

                                end

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        end

                    else
                        --print("single target")
                        -- single target damage
                        if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and IsUnitEnemy(target, player_entity) and GetUnitAbilityLevel(target, FourCC("Avul")) == 0 then
                            if myeffect.angle_window ~= nil and myeffect.angle_window > 0. then
                                if IsAngleInFace(source, myeffect.angle_window, GetUnitX(target), GetUnitY(target), false) then
                                    ApplyEffectDamage(source, target, data, lvl)
                                end
                            else
                                --print("apply damage effect - " .. GetUnitName(source) .. " to " .. GetUnitName(target) .. " with effect " .. data.name .. " with level " .. I2S(lvl))
                                ApplyEffectDamage(source, target, data, lvl)
                            end
                        end
                    end

                else
                    -- multiple target debuff
                    --print("no power")
                    if CountBuffEffects(myeffect.applied_buff, ON_ENEMY) > 0 then
                        --print("have negative buffs on enemy")
                        if myeffect.area_of_effect and myeffect.area_of_effect > 0. then
                            local enemy_group = CreateGroup()
                            local targets = myeffect.max_targets or 1

                            if myeffect.wave_speed then
                                local damaged_group = CreateGroup()
                                local timer = CreateTimer()
                                local radius = 5.
                                local step = myeffect.wave_speed / ((myeffect.area_of_effect / myeffect.wave_speed) / 0.025)

                                TimerStart(timer, 0.025, true, function()

                                    radius = radius + step
                                    if radius > myeffect.area_of_effect then radius = myeffect.area_of_effect end

                                    GroupEnumUnitsInRange(enemy_group, x, y, radius, nil)

                                    for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(enemy_group, index)

                                        if IsUnitEnemy(picked, player_entity) and not IsUnitInGroup(picked, damaged_group) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                            if myeffect.angle_window ~= nil and myeffect.angle_window > 0. then
                                                if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                    ApplyBuffEffect(source, picked, data, lvl, ON_ENEMY)
                                                    GroupAddUnit(damaged_group, picked)
                                                end
                                            else
                                                ApplyBuffEffect(source, picked, data, lvl, ON_ENEMY)
                                                GroupAddUnit(damaged_group, picked)
                                            end

                                            targets = targets - 1
                                            if targets <= 0 then break end
                                        end

                                    end

                                    if radius >= myeffect.area_of_effect then
                                        DestroyTimer(timer)
                                        DestroyGroup(damaged_group)
                                        DestroyGroup(enemy_group)
                                    end

                                end)


                            else
                                local result_group = CreateGroup()

                                    GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)

                                        for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                            local picked = BlzGroupUnitAt(enemy_group, index)

                                            if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                                GroupRemoveUnit(enemy_group, picked)
                                                GroupAddUnit(result_group, picked)
                                                targets = targets - 1
                                                if targets <= 0 then break end
                                            end

                                        end

                                        ForGroup(result_group, function()
                                            ApplyBuffEffect(source, GetEnumUnit(), data, lvl, ON_ENEMY)
                                        end)

                                    GroupClear(result_group)
                                    DestroyGroup(result_group)
                                    GroupClear(enemy_group)
                                    DestroyGroup(enemy_group)

                            end

                        else
                            if IsUnitEnemy(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(target, FourCC("Avul")) == 0 then
                                ApplyBuffEffect(source, target, data, lvl, ON_ENEMY)
                            end
                        end
                    end

                end
                --print("2")
                -- healing
                if myeffect.heal_amount and myeffect.heal_amount > 0 then
                    -- multiple target healing
                    if myeffect.area_of_effect and myeffect.area_of_effect > 0. then
                        local targets = myeffect.max_targets or 1
                        local enemy_group = CreateGroup()
                        GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)

                            for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(enemy_group, index)

                                if IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                    ApplyEffectHealing(source, picked, data, lvl)
                                    targets = targets - 1
                                    if targets <= 0 then break end
                                end

                            end

                        GroupClear(enemy_group)
                        DestroyGroup(enemy_group)
                    else
                        -- single target healing
                        if IsUnitAlly(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                            ApplyEffectHealing(source, target, data, lvl)
                        end
                    end
                else
                    -- positive buffs
                    if myeffect.applied_buff and CountBuffEffects(myeffect.applied_buff, ON_ALLY) > 0 then
                        if myeffect.area_of_effect ~= nil and myeffect.area_of_effect > 0. then
                            local targets = myeffect.max_targets or 1
                            local enemy_group = CreateGroup()
                            local result_group = CreateGroup()
                            GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)

                                for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(enemy_group, index)

                                    if not (IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0) then
                                        GroupRemoveUnit(enemy_group, picked)
                                        GroupAddUnit(result_group, picked)
                                        targets = targets - 1
                                        if targets <= 0 then break end
                                    end

                                end

                            ForGroup(result_group, function()
                                ApplyBuffEffect(source, GetEnumUnit(), data, lvl, ON_ALLY)
                            end)

                            GroupClear(result_group)
                            DestroyGroup(result_group)
                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        else
                            if IsUnitAlly(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(target, FourCC("Avul")) == 0 then
                                ApplyBuffEffect(source, target, data, lvl, ON_ALLY)
                            end
                        end
                    end
                end


                ModifyBuffsEffect(source, source, data, lvl, ON_SELF)
                OnEffectTrigger(source, target, x, y, data, lvl)
                DestroyTimer(GetExpiredTimer())
            end)


        --print("EFFECT END -> " .. data.name .. " with level " .. data.current_level)
        return data
    end

end
