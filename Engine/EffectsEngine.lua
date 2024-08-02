do




    ---@param sfx string
    ---@param target unit
    ---@param point string
    local function PlaySpecialEffect(sfx, target, point, scale, duration)

        if sfx then
            local new_effect = AddSpecialEffectTarget(sfx, target, point or "chest")

                BlzSetSpecialEffectScale(new_effect, scale or 1.)
                if duration then DelayAction(duration, function() DestroyEffect(new_effect) end)
                else DestroyEffect(new_effect) end

        end

    end

    local function PlaySpecialEffectPack(pack, target)
        if pack then
            for i = 1, #pack do
                local new_effect = AddSpecialEffectTarget(pack[i].effect, target, pack[i].point or "chest")
                BlzSetSpecialEffectScale(new_effect, pack[i].scale or 1.)
                if pack[i].duration then DelayAction(pack[i].duration, function() DestroyEffect(new_effect) end)
                else DestroyEffect(new_effect) end
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

        if myeffect_leveldata.applied_buff == nil or GetUnitState(target, UNIT_STATE_LIFE) <= 0.045 then return end

            for i = 1, #myeffect_leveldata.applied_buff do
                local myeffect = myeffect_leveldata.applied_buff[i]

                    if myeffect.target_type == target_type then
                        if myeffect.modificator == ADD_BUFF then
                            ApplyBuff(source, target, myeffect.buff_id, lvl, effect_data.ability_instance)
                        elseif myeffect.modificator == REMOVE_BUFF then
                            RemoveBuff(target, myeffect.buff_id)
                        elseif myeffect.modificator == INCREASE_BUFF_LEVEL then
                            local l = GetBuffLevel(target, myeffect.buff_id)
                            if l == 0 then
                                ApplyBuff(source, target, myeffect.buff_id, lvl, effect_data.ability_instance)
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

            if data then
                for i = 1, #data do
                    if data[i].target_type == target_type then
                        count = count + 1
                    end
                end
            end

        return count
    end


    ---@param myeffect table
    ---@param target unit
    ---@param source unit
    ---@param data table
    ---@param lvl integer
    ---@return boolean
    ---If target has same effect triggered from the source return true
    local function EffectHitOnceTrigger(myeffect, data, lvl, target, source)
        local unit_data = GetUnitData(target)

            if not unit_data.effectstacks then unit_data.effectstacks = {} end
            if not source then source = "no_source" end

            if not unit_data.effectstacks[source] or not unit_data.effectstacks[source][data.id] then
                if not unit_data.effectstacks[source] then unit_data.effectstacks[source] = {} end
                unit_data.effectstacks[source][data.id] = true
                local timer = CreateTimer()
                TimerStart(timer, data.hit_once_in, false, function()
                    unit_data.effectstacks[source][data.id] = nil
                    DestroyTimer(timer)
                end)
                return false
            else
                return true
            end

    end


    function ApplyRestoreEffect(source, target, data, lvl)
        local myeffect = data.level[lvl]

            if myeffect.life_restored and myeffect.life_restored > 0 then
                local healing = myeffect.life_restored * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01)

                    if healing < 0 then healing = 0 end
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + healing)
                    CreateHitnumber(R2I(myeffect.life_restored), source, target, HEAL_STATUS)

            elseif myeffect.life_percent_restored and myeffect.life_percent_restored > 0 then
                local healing = myeffect.life_percent_restored * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01)
                if healing < 0 then healing = 0 end
                local value = BlzGetUnitMaxHP(target) * healing

                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + value)
                    CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
            end

            if myeffect.resource_restored and myeffect.resource_restored > 0 then
                local mp = myeffect.resource_restored * (1. + GetUnitParameterValue(target, RESOURCE_GENERATION) * 0.01)

                if mp < 0 then mp = 0 end
                SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + mp)
                CreateHitnumber(R2I(myeffect.resource_restored), source, target, RESOURCE_STATUS)
            elseif myeffect.resource_percent_restored ~= nil and myeffect.resource_percent_restored > 0 then
                local mp = myeffect.resource_percent_restored * (1. + GetUnitParameterValue(target, RESOURCE_GENERATION) * 0.01)
                local value = BlzGetUnitMaxMana(target) * mp

                if mp < 0 then mp = 0 end

                SetUnitState(target, UNIT_STATE_MANA, GetUnitState(target, UNIT_STATE_MANA) + value)
                CreateHitnumber(R2I(value), source, target, RESOURCE_STATUS)
            end

            if data.sfx_pack then PlaySpecialEffectPack(data.sfx_pack.on_caster_restore, source) end
            --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_unit, target) end

    end


    ---@param source unit
    ---@param target unit
    ---@param data table
    ---@param lvl integer
    ---@param target_type integer
    function ApplyBuffEffect(source, target, data, lvl, target_type)
        local myeffect = data.level[lvl]

        if data.hit_once_in and EffectHitOnceTrigger(myeffect, data, lvl, target, source) then
            return
        end

        PlaySpecialEffect(data.SFX_on_unit, target, data.SFX_on_unit_point, data.SFX_on_unit_scale, data.SFX_on_unit_duration)
        if data.sfx_pack then PlaySpecialEffectPack(data.sfx_pack.on_unit, target) end
        if data.sound_on_hit then
            AddSoundVolumeZ(data.sound_on_hit.pack[GetRandomInt(1, #data.sound_on_hit.pack)], GetUnitX(target), GetUnitY(target), 35., data.sound_on_hit.volume, data.sound_on_hit.cutoff)
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

        if myeffect.hit_once_in and EffectHitOnceTrigger(myeffect, data, lvl, target, source) then
            return
        end

        PlaySpecialEffect(data.SFX_on_unit, target, data.SFX_on_unit_point, data.SFX_on_unit_scale, data.SFX_on_unit_duration)
        if data.sfx_pack then PlaySpecialEffectPack(data.sfx_pack.on_unit, target) end

        --print("healing effect")
            -- delay for effect animation
            local timer = CreateTimer()
            TimerStart(timer, myeffect.hit_delay or 0., false, function()
                --print("???????")
                if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                    if myeffect.heal_amount then
                        local healing = myeffect.heal_amount * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01)

                            if healing < 0 then healing = 0 end
                            SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + healing)
                            CreateHitnumber(R2I(myeffect.heal_amount), source, target, HEAL_STATUS)
                            ModifyBuffsEffect(source, target, data, lvl, ON_ALLY)
                            OnEffectApply(source, target, data)
                    end
                    if myeffect.heal_amount_max_hp then
                        local healing = myeffect.heal_amount_max_hp * (1. + GetUnitParameterValue(target, HEALING_BONUS) * 0.01)

                            if healing < 0 then healing = 0 end
                            local value = GetUnitParameterValue(target, HP_VALUE) * healing

                            SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + value)
                            CreateHitnumber(R2I(value), source, target, HEAL_STATUS)
                            ModifyBuffsEffect(source, target, data, lvl, ON_ALLY)
                            OnEffectApply(source, target, data)
                    end
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

        if data.hit_once_in and EffectHitOnceTrigger(myeffect, data, lvl, target, source) then return end

            PlaySpecialEffect(data.SFX_on_unit, target, data.SFX_on_unit_point, data.SFX_on_unit_scale, data.SFX_on_unit_duration)
            if data.sfx_pack then PlaySpecialEffectPack(data.sfx_pack.on_unit, target) end
            -- delay for effect animation
            local timer = CreateTimer()
            TimerStart(timer, myeffect.hit_delay or 0., false, function()
                if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                    --print("effect level data : ".. "attribute " .. GetItemAttributeName(myeffect.attribute) .. " damage type " .. I2S(myeffect.damage_type) .. " power " .. I2S(myeffect.power))
                    DamageUnit(source, target,
                            myeffect.power or 0,
                            data.attribute or PHYSICAL_ATTRIBUTE,
                            data.damage_type or DAMAGE_TYPE_NONE,
                            data.attack_type or nil,
                            data.can_crit or false,
                            data.is_direct or false,
                            data.is_sound or false,
                            { eff = data, l = lvl }
                    )

                    ModifyBuffsEffect(source, target, data, lvl, ON_ENEMY)

                    if data.sound_on_hit then
                        AddSoundVolumeZ(data.sound_on_hit.pack[GetRandomInt(1, #data.sound_on_hit.pack)], GetUnitX(target), GetUnitY(target), 35., data.sound_on_hit.volume, data.sound_on_hit.cutoff)
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


    ---@param effect table
    ---@return integer
    function GetEffectHitTargetCount(effect)
        local count = 0

            for k, v in pairs(effect.enemies_hit) do
                count = count + 1
            end

        return count
    end


    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param effect_id integer
    ---@param lvl integer
    ---@param ability_instance table
    ---@return table
    function ApplyEffect(source, target, x, y, effect_id, lvl, ability_instance)
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


        --if ability_instance and ability_instance.tags then data.tags = ability_instance.tags end

        local myeffect = data.level[data.current_level]

        if ability_instance then
            if ability_instance.tags then data.tags = ability_instance.tags end

            if ability_instance.power_multiplier and myeffect.power then
                myeffect.power = myeffect.power * (1. + ability_instance.power_multiplier)
            end

            if ability_instance.attack_multiplier and myeffect.attack_percent_bonus then
                myeffect.attack_percent_bonus = myeffect.attack_percent_bonus * (1. + ability_instance.attack_multiplier)
            end

            if ability_instance.weapon_multiplier and myeffect.weapon_damage_percent_bonus then
                myeffect.weapon_damage_percent_bonus = myeffect.weapon_damage_percent_bonus * ( 1. + ability_instance.weapon_multiplier)
            end

            if ability_instance.bonus_crit_chance and myeffect.bonus_crit_chance then
                myeffect.bonus_crit_chance = myeffect.bonus_crit_chance + ability_instance.bonus_crit_chance
            end

            if ability_instance.bonus_crit_multiplier and myeffect.bonus_crit_multiplier then
                myeffect.bonus_crit_multiplier = myeffect.bonus_crit_chance + ability_instance.bonus_crit_multiplier
            end

            if ability_instance.attribute_bonus and myeffect.attribute_bonus then
                myeffect.attribute_bonus = myeffect.attribute_bonus + ability_instance.attribute_bonus
            end

            if ability_instance.bonus_radius and myeffect.area_of_effect then
                myeffect.area_of_effect = myeffect.area_of_effect + ability_instance.bonus_radius
            end
        end

        data.ability_instance = ability_instance or nil
        data.enemies_hit = {}

        OnEffectPrecast(source, target, x, y, data)

        if current_level ~= data.current_level then
            GenerateEffectLevelData(data, data.current_level)
        end

        myeffect = data.level[data.current_level]


        --print("EFFECT START -> " .. data.name .. " with level " .. data.current_level)

        data.remove_timer = CreateTimer()
            TimerStart(data.remove_timer, (data.delay or 0.) + (myeffect.hit_delay or 0.) + 1., false, function()
                DestroyTimer(data.remove_timer)
                data = nil
                myeffect = nil
            end)


        if target then x = GetUnitX(target); y = GetUnitY(target)
        elseif target == nil and (x == 0 or y == 0) then x = GetUnitX(source); y = GetUnitY(source) end

        if data.force_from_caster_position then
            x = GetUnitX(source)
            y = GetUnitY(source)
        end

        data.effect_x = x
        data.effect_y = y

            local timer = CreateTimer()
            TimerStart(timer, data.SFX_delay or 0., false, function()
                --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_point, target or source) end
                if data.SFX_used then
                    local effect = AddSpecialEffect(data.SFX_used, x, y)

                    BlzSetSpecialEffectScale(effect, 1.)
                    BlzSetSpecialEffectScale(effect, data.SFX_used_scale or 1.)

                        if data.timescale then BlzSetSpecialEffectTimeScale(effect, 1. + (1. - data.timescale)) end

                        if data.SFX_inherit_angle then
                            BlzSetSpecialEffectOrientation(effect, GetUnitFacing(source) * bj_DEGTORAD, 0., 0.)
                        elseif data.SFX_facing then
                            BlzSetSpecialEffectOrientation(effect, data.SFX_facing * bj_DEGTORAD, 0., 0.)
                        elseif data.SFX_random_angle then
                            BlzSetSpecialEffectOrientation(effect, GetRandomReal(0., 360.) * bj_DEGTORAD, 0., 0.)
                        end

                        if data.SFX_bonus_z then BlzSetSpecialEffectZ(effect, GetZ(x, y) + data.SFX_bonus_z) end


                    if data.SFX_lifetime then DelayAction(data.SFX_lifetime, function() DestroyEffect(effect) end)
                    else DestroyEffect(effect) end


                end
                DestroyTimer(GetExpiredTimer())
            end)

        PlaySpecialEffect(data.SFX_on_caster, source, data.SFX_on_caster_point, data.SFX_on_caster_scale, data.SFX_on_caster_duration)
        if data.sfx_pack then PlaySpecialEffectPack(data.sfx_pack.on_caster, source) end

        if data.sound then
            for i = 1, #data.sound do
                if data.sound[i].delay then
                    DelayAction(data.sound[i].delay, function()
                        local sound = data.sound[i]
                        AddSoundVolumeZ(sound.pack[GetRandomInt(1, #sound.pack)], x, y, 35., sound.volume, sound.cutoff)
                    end)
                else
                    local sound = data.sound[i]
                    AddSoundVolumeZ(sound.pack[GetRandomInt(1, #sound.pack)], x, y, 35., sound.volume, sound.cutoff)
                end
            end
        end


            local timer = CreateTimer()
            TimerStart(timer, (data.delay or 0.) * (data.timescale or 1.), false, function()


                if data.sound_timed and data.sound_timed.pack then AddSoundVolumeZ(data.sound.pack[GetRandomInt(1, #data.sound_timed.pack)], x, y, 35., data.sound_timed.volume, data.sound_timed.cutoff) end
                if myeffect.shake_magnitude then ShakeByCoords(x, y, myeffect.shake_magnitude, myeffect.shake_duration, myeffect.shake_distance) end

                if (myeffect.life_percent_restored and myeffect.life_percent_restored > 0.) or (myeffect.resource_percent_restored and myeffect.resource_percent_restored > 0.) then
                    --PlaySpecialEffect(myeffect.SFX_on_caster, source, myeffect.SFX_on_caster_point, myeffect.SFX_on_caster_scale, myeffect.SFX_on_caster_duration)
                    --if myeffect.sfx_pack then PlaySpecialEffectPack(myeffect.sfx_pack.on_caster, source) end

                    local timer = CreateTimer()
                    TimerStart(timer, myeffect.hit_delay or 0., false, function()
                        ApplyRestoreEffect(source, source, data, lvl)
                        DestroyTimer(timer)
                    end)

                end

                -- damaging
                if (myeffect.power and myeffect.power > 0) or (myeffect.attack_percent_bonus and myeffect.attack_percent_bonus > 0.) or (myeffect.weapon_damage_percent_bonus and myeffect.weapon_damage_percent_bonus > 0.) then
                    -- multiple target damage
                    --print("power > 0")

                    if data.global_crit and ability_instance and not ability_instance.critical_strike_flag then
                        local bonus_critical = myeffect.bonus_crit_chance and myeffect.bonus_crit_chance or 0.

                            if GetRandomInt(1, 100) <= GetCriticalChance(source, bonus_critical) then ability_instance.critical_strike_flag = true
                            else data.can_crit = false end

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
                        local limit_range = myeffect.area_of_effect * 0.3
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

                                                if myeffect.angle_window and myeffect.angle_window > 0. then
                                                    if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                        ApplyEffectDamage(source, picked, data, lvl)
                                                        GroupAddUnit(damaged_group, picked)
                                                    elseif IsUnitInRange(source, picked, limit_range) then
                                                        if IsAngleInFace(source, myeffect.angle_window * 1.35, GetUnitX(picked), GetUnitY(picked), false) then
                                                            ApplyEffectDamage(source, picked, data, lvl)
                                                            GroupAddUnit(damaged_group, picked)
                                                        end
                                                    end
                                                else
                                                    ApplyEffectDamage(source, picked, data, lvl)
                                                    GroupAddUnit(damaged_group, picked)
                                                end

                                                targets = targets - 1
                                                if targets <= 0 then break end
                                                data.enemies_hit[picked] = true
                                            end

                                        end

                                    if radius >= myeffect.area_of_effect then
                                        DestroyTimer(timer)
                                        DestroyGroup(damaged_group)
                                        DestroyGroup(enemy_group)
                                    end

                                end)


                        else
                            local limit_range = myeffect.area_of_effect * 0.3

                            GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)

                                for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(enemy_group, index)

                                    if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                        if myeffect.angle_window and myeffect.angle_window > 0. then
                                            if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                ApplyEffectDamage(source, picked, data, lvl)
                                            elseif IsUnitInRange(source, picked, limit_range) then
                                                if IsAngleInFace(source, myeffect.angle_window * 1.35, GetUnitX(picked), GetUnitY(picked), false) then
                                                    ApplyEffectDamage(source, picked, data, lvl)
                                                end
                                            end
                                        else
                                            ApplyEffectDamage(source, picked, data, lvl)
                                        end

                                        targets = targets - 1
                                        if targets <= 0 then break end
                                        data.enemies_hit[picked] = true
                                    end

                                end

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        end

                    else
                        --print("single target")
                        -- single target damage
                        if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and IsUnitEnemy(target, player_entity) and GetUnitAbilityLevel(target, FourCC("Avul")) == 0 then

                            if myeffect.angle_window and myeffect.angle_window > 0. then
                                if IsAngleInFace(source, myeffect.angle_window, GetUnitX(target), GetUnitY(target), false) then
                                    ApplyEffectDamage(source, target, data, lvl)
                                end
                            else
                                --print("apply damage effect - " .. GetUnitName(source) .. " to " .. GetUnitName(target) .. " with effect " .. data.name .. " with level " .. I2S(lvl))
                                ApplyEffectDamage(source, target, data, lvl)
                            end

                            data.enemies_hit[target] = true

                            if myeffect.hit_delay then
                                DelayAction(myeffect.hit_delay, function() myeffect = nil; data = nil end)
                            else
                                myeffect = nil
                                data = nil
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
                            local limit_range = myeffect.area_of_effect * 0.3

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

                                            if myeffect.angle_window and myeffect.angle_window > 0. then
                                                if IsAngleInFace(source, myeffect.angle_window, GetUnitX(picked), GetUnitY(picked), false) then
                                                    ApplyBuffEffect(source, picked, data, lvl, ON_ENEMY)
                                                    GroupAddUnit(damaged_group, picked)
                                                elseif IsUnitInRange(source, picked, limit_range) then
                                                    if IsAngleInFace(source, myeffect.angle_window * 1.35, GetUnitX(picked), GetUnitY(picked), false) then
                                                        ApplyBuffEffect(source, picked, data, lvl, ON_ENEMY)
                                                        GroupAddUnit(damaged_group, picked)
                                                    end
                                                end
                                            else
                                                ApplyBuffEffect(source, picked, data, lvl, ON_ENEMY)
                                                GroupAddUnit(damaged_group, picked)
                                            end

                                            targets = targets - 1
                                            if targets <= 0 then break end
                                            data.enemies_hit[picked] = true
                                        end

                                    end

                                    if radius >= myeffect.area_of_effect then
                                        DestroyTimer(timer)
                                        DestroyGroup(damaged_group)
                                        DestroyGroup(enemy_group)
                                        if myeffect.hit_delay then
                                            DelayAction(myeffect.hit_delay, function() myeffect = nil; data = nil end)
                                        else
                                            myeffect = nil
                                            data = nil
                                        end
                                    end

                                end)


                            else
                                local result_group = CreateGroup()

                                --print("no wave")
                                    GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)


                                        for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                            local picked = BlzGroupUnitAt(enemy_group, index)

                                            if IsUnitEnemy(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                                --print("enemy")
                                                GroupRemoveUnit(enemy_group, picked)
                                                GroupAddUnit(result_group, picked)
                                                targets = targets - 1
                                                if targets <= 0 then break end
                                                data.enemies_hit[picked] = true
                                            end

                                        end

                                        ForGroup(result_group, function()
                                            --print("????")
                                            ApplyBuffEffect(source, GetEnumUnit(), data, lvl, ON_ENEMY)
                                            data.enemies_hit[GetEnumUnit()] = true
                                        end)

                                    GroupClear(result_group)
                                    DestroyGroup(result_group)
                                    GroupClear(enemy_group)
                                    DestroyGroup(enemy_group)

                            end

                        else
                            if IsUnitEnemy(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(target, FourCC("Avul")) == 0 then
                                ApplyBuffEffect(source, target, data, lvl, ON_ENEMY)
                                data.enemies_hit[target] = true
                            end
                        end
                    end

                end
                -- healing
                --print(myeffect.heal_amount_max_hp or 0)
                if (myeffect.heal_amount and myeffect.heal_amount > 0) or (myeffect.heal_amount_max_hp and myeffect.heal_amount_max_hp > 0) then
                    --print("HEALING")
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
                        --print("single target healing")
                        if IsUnitAlly(target, player_entity) and GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                            --print("apply healing")
                            ApplyEffectHealing(source, target, data, lvl)
                        end
                    end
                else
                    -- positive buffs
                    if myeffect.applied_buff then

                        if CountBuffEffects(myeffect.applied_buff, ON_ALLY) > 0 then

                           if myeffect.area_of_effect and myeffect.area_of_effect > 0. then
                                local targets = myeffect.max_targets or 1
                                local enemy_group = CreateGroup()
                                local result_group = CreateGroup()

                                GroupEnumUnitsInRange(enemy_group, x, y, myeffect.area_of_effect, nil)

                                    for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(enemy_group, index)

                                        if (IsUnitAlly(picked, player_entity) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0) then
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

                        elseif CountBuffEffects(myeffect.applied_buff, ON_HEROES) > 0 then
                            for i = 1, 6 do
                                if PlayerHero[i] and GetUnitState(PlayerHero[i], UNIT_STATE_LIFE) > 0.045 and IsUnitInRange(source, PlayerHero[i], myeffect.area_of_effect or 10.) then
                                    ApplyBuffEffect(source, PlayerHero[i], data, lvl, ON_HEROES)
                                end
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
