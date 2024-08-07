do


    function SummonHydra(hero, x, y)
        local unit_data = GetUnitData(hero)
        local ability_level = UnitGetAbilityLevel(hero, "A00I")
        local level = 1 + math.floor(ability_level / 15)


            if unit_data.spawned_hydra then KillUnit(unit_data.spawned_hydra) end
            unit_data.spawned_hydra = CreateUnit(GetOwningPlayer(hero), FourCC('shdr'), x, y, GetRandomReal(0.,359.))


            AddSpecialEffectTargetEx("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdx", unit_data.spawned_hydra, "overhead rear", 1.)

            if level > 1 then
                AddUnitAnimationProperties(unit_data.spawned_hydra, "upgrade", true)
            end

            if level == 2 then
                AddUnitAnimationProperties(unit_data.spawned_hydra, "first", true)
                AddSpecialEffectTargetEx("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdx", unit_data.spawned_hydra, "overhead right", 1.)
            elseif level >= 3 then
                AddUnitAnimationProperties(unit_data.spawned_hydra, "second", true)
                AddSpecialEffectTargetEx("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdx", unit_data.spawned_hydra, "overhead right", 1.)
                AddSpecialEffectTargetEx("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdx", unit_data.spawned_hydra, "overhead left", 1.)
            end

            UnitApplyTimedLife(unit_data.spawned_hydra, 0, 6.75 + (ability_level * 0.25))
            DestroyEffect(AddSpecialEffect("Effect\\Flamestrike I.mdx", x, y))


            local percent = 0.7 * GetUnitParameterValue(hero, MINION_POWER)

                if unit_data.boost_overflow then
                    percent = percent + 0.3 * GetUnitTalentLevel(hero, "talent_overflow")
                    unit_data.boost_overflow = nil
                end

                if unit_data.heating_up_boost then percent = percent + 0.4 end

            AddSoundVolume("Sounds\\Spells\\Hydra_Roar_" .. GetRandomInt(1,3).. ".wav", x, y, 300, 1600., 4000.)


            DelayAction(0., function()
                local hydra = GetUnitData(unit_data.spawned_hydra)

                    hydra.powerlevel = level
                    hydra.stats[PHYSICAL_ATTACK].value = unit_data.stats[PHYSICAL_ATTACK].value * percent
                    hydra.stats[MAGICAL_ATTACK].value = unit_data.stats[MAGICAL_ATTACK].value * percent
                    hydra.stats[CRIT_CHANCE].value = unit_data.stats[CRIT_CHANCE].value * percent
                    hydra.equip_point[WEAPON_POINT].DAMAGE = unit_data.equip_point[WEAPON_POINT].DAMAGE * percent
                    hydra.equip_point[WEAPON_POINT].ATTACK_SPEED = unit_data.stats[ATTACK_SPEED].value * percent
                    hydra.equip_point[WEAPON_POINT].DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL
                    hydra.equip_point[WEAPON_POINT].ATTRIBUTE = FIRE_ATTRIBUTE
                    hydra.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS = R2I((hydra.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0) * percent)
                    hydra.stats[INT_STAT].value = R2I(unit_data.stats[INT_STAT].value * percent)
                    hydra.stats[FIRE_BONUS].value = R2I(unit_data.stats[FIRE_BONUS].value * percent)
                    UpdateParameters(hydra)
                    ToggleAuraOnUnit(unit_data.spawned_hydra, "hydra_aura", ability_level, true)
            end)
    end


    ---@param source unit
    ---@param target unit
    ---@param id string
    ---@param faderate real
    ---@param bonus_start_z real
    ---@param bonus_end_z real
    ---@param bonus_range real
    ---@param bonus_angle real
    function LightningEffect_Units(source, target, id, faderate, bonus_start_z, bonus_end_z, bonus_range, bonus_angle)
        local source_x = GetUnitX(source); local source_y = GetUnitY(source); local source_z = GetUnitZ(source) + bonus_start_z
        local unit_data = GetUnitData(source)
        if unit_data.exploded then
            source_x = unit_data.death_x; source_y = unit_data.death_y; source_z = unit_data.death_z + bonus_start_z
        end

        if bonus_range then
            bonus_angle = GetUnitFacing(source) + bonus_angle
            source_x = source_x + (bonus_range * Cos(bonus_angle * bj_DEGTORAD))
            source_y = source_y + (bonus_range * Sin(bonus_angle * bj_DEGTORAD))
        end


        local target_x = GetUnitX(target); local target_y = GetUnitY(target); local target_z = GetUnitZ(target) + bonus_end_z
        unit_data = GetUnitData(target)
        if unit_data.exploded then
            target_x = unit_data.death_x; target_y = unit_data.death_y; target_z = unit_data.death_z + bonus_end_z
        end
        local bolt = AddLightningEx(id, true, source_x, source_y, source_z, target_x, target_y, target_z)
        local fade_time = faderate

            local timer = CreateTimer()
            TimerStart(timer, 0.025, true, function()
                if faderate <= 0. then
                    DestroyLightning(bolt)
                    DestroyTimer(GetExpiredTimer())
                else
                    SetLightningColor(bolt, 1, 1, 1, faderate / fade_time)

                    unit_data = GetUnitData(source)
                    if unit_data.exploded then source_x = unit_data.death_x; source_y = unit_data.death_y; source_z = unit_data.death_z + bonus_start_z
                    else source_x = GetUnitX(source); source_y = GetUnitY(source); source_z = GetUnitZ(source) + bonus_start_z end

                    unit_data = GetUnitData(target)
                    if unit_data.exploded then target_x = unit_data.death_x; target_y = unit_data.death_y; target_z = unit_data.death_z + bonus_end_z
                    else target_x = GetUnitX(target); target_y = GetUnitY(target); target_z = GetUnitZ(target) + bonus_end_z end

                    MoveLightningEx(bolt, true, source_x, source_y, source_z, target_x, target_y, target_z)
                    faderate = faderate - 0.025
                end
            end)

    end


    function LightningBall_VisualEffect(target, missile)
        if not target or not missile then
            return
        end

        local target_x = GetUnitX(target); local target_y = GetUnitY(target); local target_z = GetUnitZ(target)
        local unit_data = GetUnitData(target)
        if unit_data.exploded then
            target_x = unit_data.death_x; target_y = unit_data.death_y; target_z = unit_data.death_z
        end

        local faderate = 0.55
        local bolt = AddLightningEx("BLNL", true, missile.current_x, missile.current_y, missile.current_z + 50., target_x, target_y, target_z + missile.end_z)
        local missile_x = missile.current_x
        local missile_y = missile.current_y
        local missile_z = missile.current_z
        local missile_end_z = missile.end_z

            local timer = CreateTimer()
            TimerStart(timer, 0.025, true, function()
                if faderate <= 0. then
                    DestroyLightning(bolt)
                    DestroyTimer(GetExpiredTimer())
                else
                    SetLightningColor(bolt, 1, 1, 1, faderate / 0.55)

                    if missile == nil then
                        MoveLightningEx(bolt, true, missile_x, missile_y, missile_z, target_x, target_y, target_z + missile_end_z)
                    else
                        missile_x = missile.current_x
                        missile_y = missile.current_y
                        missile_z = missile.current_z
                        missile_end_z = missile.end_z

                        if unit_data.exploded then target_x = unit_data.death_x; target_y = unit_data.death_y; target_z = unit_data.death_z
                        else target_x = GetUnitX(target); target_y = GetUnitY(target); target_z = GetUnitZ(target) end

                        MoveLightningEx(bolt, true, missile.current_x, missile.current_y, missile.current_z + 50., target_x, target_y, target_z + missile.end_z)
                    end

                    faderate = faderate - 0.025
                end
            end)

    end



    function GetChainLightningVictim(source, target, range, damaged_group)
        local group = CreateGroup()
        local victim
        local owner = GetOwningPlayer(source)

            GroupEnumUnitsInRange(group, GetUnitX(target), GetUnitY(target), range, nil)

            if BlzGroupGetSize(group) > 0 then
                for index = BlzGroupGetSize(group) - 1, 0, -1 do
                    local picked = BlzGroupUnitAt(group, index)

                        if IsUnitEnemy(picked, owner) and GetWidgetLife(picked) > 0.045 and not IsUnitInGroup(picked, damaged_group) then
                            victim = picked
                            break
                        end

                end
            end

        DestroyGroup(group)
        return victim
    end

    function ChainLightningCast(source, target, ability_instance)
        local from = source
        local unit_data = GetUnitData(source)
        local rebounds = 2 + math.floor(UnitGetAbilityLevel(source, "A019") / 10)


        if UnitHasEffect(source, "infinity_chain_effect_Legendary") then
            rebounds = rebounds * 2
        end


        AddSoundVolume("Sounds\\Spells\\lightning_launch_" .. GetRandomInt(1, 3) .. ".wav", GetUnitX(from), GetUnitY(from), 120., 1600., 4000.)
        LightningEffect_Units(from, target, "BLNL", 0.45, 50., 50.)
        ApplyEffect(source, target, 0., 0.,"ECHL", 1, ability_instance)

        local damaged_group = CreateGroup()
        GroupAddUnit(damaged_group, target)

        from = target
        local next_target = GetChainLightningVictim(source, target, 500., damaged_group)

            if next_target or IsUnitInRange(source, target, 800.) then
                local timer = CreateTimer()

                    TimerStart(timer, 0.25, true, function()

                        if next_target then
                            -- there is a next target
                            GroupAddUnit(damaged_group, next_target)
                            --print("next target exists")
                        elseif from ~= source and IsUnitInRange(source, from, 800.) and GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then
                            -- no next target, caster within range
                            next_target = source
                            GroupRemoveUnit(damaged_group, from)
                            --print("jump to caster")
                        elseif from == source then
                            -- next target isnt a caster, but caster is within range
                            --print("from caster to next target")
                            next_target = GetChainLightningVictim(source, from, 800., damaged_group)
                        end

                        if not next_target then
                            DestroyTimer(GetExpiredTimer())
                            DestroyGroup(damaged_group)
                            --print("no next target")
                        end

                        --print("a")


                        AddSoundVolume("Sounds\\Spells\\lightning_launch_" .. GetRandomInt(1, 3) .. ".wav", GetUnitX(from), GetUnitY(from), 120., 1600., 4000.)
                        LightningEffect_Units(from, next_target, "BLNL", 0.45, 50., 50.)
                           -- print("b")
                        if next_target ~= source then
                            ApplyEffect(source, next_target, 0., 0.,"ECHL", 1, ability_instance)
                            rebounds = rebounds - 1
                        end
                        --print("c")
                        from = next_target
                        next_target = GetChainLightningVictim(source, next_target, 500., damaged_group)
                        --print("d")
                        if rebounds <= 0 then
                            DestroyTimer(GetExpiredTimer())
                            DestroyGroup(damaged_group)
                        end

                    end)

            end

    end


    function SparkCast_Legendary(source, ability_instance)
        local discharge = {}
        local spark_amount = 12
        local angle = 360. / spark_amount
        local current_angle = 0.01
        local unit_data = GetUnitData(source)

        for i = 1, spark_amount do
            discharge[i] = { missile = ThrowMissile(source, nil, 'MDSC', { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), 0, 0, current_angle), a = current_angle }
            BlzSetSpecialEffectScale(discharge[i].missile.missile_effect, 1.15)
            current_angle = current_angle + angle
        end

            for i = 1, spark_amount do
                local timer = CreateTimer()
                local timeout = GetRandomReal(0.22, 0.65)

                    TimerStart(timer, 0.05, true, function()
                        if discharge[i].missile.time > 0. then
                            if timeout <= 0. then
                                RedirectMissile_Deg(discharge[i].missile, discharge[i].a + GetRandomReal(-15., 15.))
                                timeout = GetRandomReal(0.22, 0.65)
                            end
                            timeout = timeout - 0.05
                        else
                            discharge[i] = nil
                            DestroyTimer(timer)
                        end
                    end)

            end

    end


    function SparkCast(source, target, x, y, ability_instance)
        local angle
        local discharge = {}
        local amount = 3 + math.floor(UnitGetAbilityLevel(source, "A00J") / 10)
        local angle_dispersion = 15.
        local breakpoint = math.floor(amount / 2)
        local unit_data = GetUnitData(source)

            if target and target == source then angle = GetUnitFacing(source)
            elseif target then angle = AngleBetweenUnitXY(source, GetUnitX(target), GetUnitY(target))
            else angle = AngleBetweenUnitXY(source, x, y) end

            if amount % 2 == 0 then angle = angle + (((amount - 1) * angle_dispersion) / 2)
            else angle = angle + (breakpoint * angle_dispersion) end


            for i = 1, amount do
                discharge[i] = { missile = ThrowMissile(source, nil, 'MDSC', { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), x, y, angle, true), a = angle }
                angle = angle - angle_dispersion
            end


            for i = 1, amount do
                local timer = CreateTimer()
                local timeout = GetRandomReal(0.08, 0.14)

                    TimerStart(timer, 0.01, true, function()
                        if discharge[i].missile.time > 0. then
                            if timeout <= 0. then
                                RedirectMissile_Deg(discharge[i].missile, discharge[i].a + GetRandomReal(-22., 22.))
                                timeout = GetRandomReal(0.08, 0.14)
                            end
                            timeout = timeout - 0.01
                        else
                            discharge[i] = nil
                            DestroyTimer(timer)
                        end
                    end)

            end

    end


    function CastSorceressBlink(caster, x, y, skill)
        local caster_x = GetUnitX(caster)
        local caster_y = GetUnitY(caster)
        local angle = AngleBetweenUnitXY(caster, x, y)
        local distance = GetMaxAvailableDistance(caster_x, caster_y, angle, DistanceBetweenUnitXY(caster, x, y))

            x = caster_x + Rx(distance, angle)
            y = caster_y + Ry(distance, angle)
            AddSoundVolumeZ("Sounds\\Spells\\blink_launch_".. GetRandomInt(1, 3) ..".wav", caster_x, caster_y, 35., 120, 1700., 4000.)
            SetUnitPosition(caster, x, y)
            DestroyEffect(AddSpecialEffect("Spell\\Blink Blue Target.mdx", GetUnitX(caster), GetUnitY(caster)))

        -- effect
            if UnitHasEffect(caster, "illusion_legendary") then
                local illusion = CreateUnit(GetOwningPlayer(caster), FourCC("srci"), caster_x, caster_y, angle)
                UnitApplyTimedLife(illusion, 0, 5.)
                local hair_sfx = AddSpecialEffectTarget("Model\\Sorceress_Hair.mdx", illusion, "head")
                local weapon_sfx
                local offhand_sfx

                DelayAction(0., function()
                    local unit_data = GetUnitData(caster)
                    local illusion_data = GetUnitData(illusion)

                        for i = 1, #illusion_data.stats do illusion_data.stats[i].value = unit_data.stats[i].value end
                        UpdateParameters(illusion_data)
                        SetTexture(illusion, unit_data.equip_point[CHEST_POINT] and unit_data.equip_point[CHEST_POINT].texture or TEXTURE_ID_EMPTY)
                        weapon_sfx = AddSpecialEffectTarget(unit_data.equip_point[WEAPON_POINT].model or "", illusion, "hand right")
                        offhand_sfx = AddSpecialEffectTarget(unit_data.equip_point[OFFHAND_POINT] and unit_data.equip_point[OFFHAND_POINT].model or "", illusion, "hand left")
                end)

                local timer = CreateTimer()
                local trg = CreateTrigger()
                TriggerRegisterUnitEvent(trg, illusion, EVENT_UNIT_DEATH)
                TriggerAddAction(trg, function()
                    AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdx", GetUnitX(illusion), GetUnitY(illusion))
                    ShowUnit(illusion, false)
                    DestroyEffect(weapon_sfx)
                    DestroyEffect(hair_sfx)
                    DestroyEffect(offhand_sfx)
                    DestroyTrigger(trg)
                    DestroyTimer(timer)
                end)

                UnitAddAbility(illusion, FourCC("Abun"))
                local dummy = CreateUnit(GetOwningPlayer(caster), FourCC("dmcs"), GetUnitX(caster), GetUnitY(caster), angle)
                UnitAddAbility(dummy, FourCC("AINV"))
                IssueTargetOrderById(dummy, order_invisibility, caster)
                DelayAction(0.5, function() RemoveUnit(dummy) end)
                IssuePointOrderById(illusion, order_move, GetUnitX(illusion) + GetRandomReal(-300., 300.), GetUnitY(illusion) + GetRandomReal(-300., 300.))

                TimerStart(timer, 0.75, true, function()
                    IssuePointOrderById(illusion, order_move, GetUnitX(illusion) + GetRandomReal(-300., 300.), GetUnitY(illusion) + GetRandomReal(-300., 300.))
                end)
            end


    end


    function CastFrostbolt_Legendary(caster, target, x, y, ability_instance)
        local frostbolts = {}
        local angle
        local facing

            if target and target == caster then angle = GetUnitFacing(caster)
            elseif target then angle = AngleBetweenUnitXY(caster, GetUnitX(target), GetUnitY(target))
            else angle = AngleBetweenUnitXY(caster, x, y) end

        facing = angle

        local offsets = {
            [1] = { x = Rx(55., facing), y = Ry(55., facing) },
            [2] = { x = Rx(110., facing + 30.), y = Ry(110., facing + 30.) },
            [3] = { x = Rx(110., facing - 30.), y = Ry(110., facing - 30.) },
        }

        frostbolts[1] = ThrowMissile(caster, nil, 'MFRB', { ability_instance = ability_instance }, GetUnitX(caster) - offsets[1].x, GetUnitY(caster) - offsets[1].y, x, y, 0.)
        frostbolts[2] = ThrowMissile(caster, nil, 'MFRB', { ability_instance = ability_instance }, GetUnitX(caster) - offsets[2].x, GetUnitY(caster) - offsets[2].y, x, y, angle + 15.)
        frostbolts[3] = ThrowMissile(caster, nil, 'MFRB', { ability_instance = ability_instance }, GetUnitX(caster) - offsets[3].x, GetUnitY(caster) - offsets[3].y, x, y, angle - 15.)

        frostbolts[1].pause = true; frostbolts[2].pause = true; frostbolts[3].pause = true


        local timeouts = { 0.5, 0.2, 0.35 }

        local timer = CreateTimer()
        TimerStart(timer, 0.02, true, function()
            for i = 1, 3 do
                if timeouts[i] then
                    if timeouts[i] <= 0. then
                        if target and target == caster then angle = GetUnitFacing(caster)
                        elseif target then angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, GetUnitX(target), GetUnitY(target))
                        else angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, x, y) end
                        RedirectMissile_Deg(frostbolts[i], angle)
                        frostbolts[i].pause = nil
                        timeouts[i] = nil
                    else
                        RepositionMissile(frostbolts[i], GetUnitX(caster) - offsets[i].x, GetUnitY(caster) - offsets[i].y, 0)
                        if target and target == caster then angle = GetUnitFacing(caster) * bj_DEGTORAD
                        elseif target then angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, GetUnitX(target), GetUnitY(target)) * bj_DEGTORAD
                        else angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, x, y) * bj_DEGTORAD end
                        BlzSetSpecialEffectOrientation(frostbolts[i].my_missile, angle, 0., 0.)
                        --BlzSetSpecialEffectYaw(frostbolts[i].my_missile, angle)
                        timeouts[i] = timeouts[i] - 0.02
                    end
                end
            end

            if not timeouts[1] and not timeouts[2] and not timeouts[3] then
                DestroyTimer(GetExpiredTimer())
            end

        end)


    end



    function MeltdownDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil
            TimerStart(unit_data.action_timer, 0., false, nil)
            StopSound(unit_data.channel_sound, true, true)
            DestroyEffect(unit_data.hand_right_sfx); DestroyEffect(unit_data.hand_left_sfx)
            UnitRemoveAbility(unit, FourCC("A002")); UnitRemoveAbility(unit, FourCC("B000"))
            DestroyTrigger(unit_data.channel_trigger)
            SetUnitTimeScale(unit, 1.)
            unit_data.boost_overflow = nil

    end


    function CastMeltdown(unit, ability_instance)
        local unit_data = GetUnitData(unit)

            if unit_data.channeled_destructor then unit_data.channeled_destructor(unit) else

                ResetUnitSpellCast(unit)
                unit_data.channeled_destructor = MeltdownDeactivate
                unit_data.channeled_ability = "AMLT"

                UnitAddAbility(unit, FourCC('Abun'))
                local player_id = GetPlayerId(GetOwningPlayer(unit)) + 1


                AddSoundVolumeZ("Sounds\\Spells\\disintegration_launch_"..GetRandomInt(1,2)..".wav", GetUnitX(unit), GetUnitY(unit), 65., 120, 1500., 4000.)
                unit_data.channel_sound = CreateNew3DSound("Sounds\\Spells\\disintegration_loop_1.wav", GetUnitX(unit), GetUnitY(unit), 65., 120, 1500., 4000., true)
                StartSound(unit_data.channel_sound)
                SetSoundPlayPosition(unit_data.channel_sound, GetRandomInt(0, GetSoundDuration(unit_data.channel_sound)))
            UnitAddAbility(unit, FourCC("A002"))
            unit_data.hand_right_sfx = AddSpecialEffectTarget("Spell\\Fire Uber.mdx", unit, "hand right")
            unit_data.hand_left_sfx = AddSpecialEffectTarget("Spell\\Fire Uber.mdx", unit, "hand left")


            unit_data.channel_trigger = CreateTrigger()
            TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_POINT_ORDER)
            TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_ORDER)


            local duration = 1.25 + UnitGetAbilityLevel(unit, "AMLT") * 0.05
            local breakpoint = duration - 0.25

            TriggerAddAction(unit_data.channel_trigger, function()
                if not IsItemOrder(GetIssuedOrderId()) and duration <= breakpoint then MeltdownDeactivate(unit) end
            end)

            SetUnitTimeScale(unit, 0.05)
            SetUnitFacingTimed(unit, AngleBetweenUnitXY(unit, PlayerMousePosition[player_id].x or 0., PlayerMousePosition[player_id].y or 0.), 0.1)

            --local boost = { tags = {}}

            --if unit_data.boost_overflow then boost.tags[#boost.tags+1] = "talent_overflow" end
            --if unit_data.heating_up_boost then boost.tags[#boost.tags+1] = "talent_heating_up" end

            TimerStart(unit_data.action_timer, 0.05, true, function()
                if duration > 0. and GetUnitState(unit, UNIT_STATE_LIFE) > 0.045 and unit_data.channeled_ability == "AMLT" then
                    --BlzEndUnitAbilityCooldown(unit, myability)
                    local facing = GetUnitFacing(unit)
                    local x = GetUnitX(unit) + Rx(unit_data.missile_eject_range, facing); local y = GetUnitY(unit) + Ry(unit_data.missile_eject_range, facing)
                    SetUnitFacingTimed(unit, AngleBetweenUnitXY(unit, PlayerMousePosition[player_id].x or 0., PlayerMousePosition[player_id].y or 0.), 0.2)
                    local effect = AddSpecialEffect("Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdx", x, y)
                    BlzSetSpecialEffectOrientation(effect, facing * bj_DEGTORAD, 0., 0.)
                    --BlzSetSpecialEffectYaw(effect, facing * bj_DEGTORAD)
                    BlzSetSpecialEffectZ(effect, GetZ(x, y) + 75.)
                    DestroyEffect(effect)
                    ThrowMissile(unit, nil, "MMLT", { ability_instance = ability_instance }, GetUnitX(unit), GetUnitY(unit), 0.,0., facing, true)
                else
                    MeltdownDeactivate(unit)
                    --TimerStart(GetExpiredTimer(), 0., false, nil)
                    --DestroyTimer(GetExpiredTimer())
                end
                duration = duration - 0.05
            end)

        end
    end



    function BlizzardDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil
            TimerStart(unit_data.action_timer, 0., false, nil)
            DestroyLoopingSound(unit_data.channel_sound, 0.3)
            DestroyEffect(unit_data.hand_left_sfx); DestroyEffect(unit_data.hand_right_sfx); DestroyEffect(unit_data.channel_sfx); DestroyEffect(unit_data.ground_sfx)
            UnitRemoveAbility(unit, FourCC("A002")); UnitRemoveAbility(unit, FourCC("B000"))
            DestroyTrigger(unit_data.channel_trigger)
            SetUnitTimeScale(unit, 1.)

    end

    function IsItemOrder(order_id)
        return order_id == order_itemuse00 or order_id == order_itemuse01 or order_id == order_itemuse02 or order_id == order_itemuse03 or order_id == order_itemuse04 or order_id == order_itemuse05
    end

    function CastBlizzard(unit, ability_instance)
        local unit_data = GetUnitData(unit)

            if unit_data.channeled_destructor then unit_data.channeled_destructor(unit) else

                ResetUnitSpellCast(unit)

                local time_point = 0.3
                local start_scale = 1.3

                unit_data.channeled_destructor = BlizzardDeactivate
                unit_data.channeled_ability = "ABLZ"

                UnitAddAbility(unit, FourCC('Abun'))
                local player_id = GetPlayerId(GetOwningPlayer(unit)) + 1

                unit_data.channel_sound = AddLoopingSoundOnUnit({ "Sounds\\Spells\\blizzard_loop_1.wav", "Sounds\\Spells\\blizzard_loop_2.wav", "Sounds\\Spells\\blizzard_loop_3.wav", }, unit, 150, 150, -0.15, 100, 1500., 4000.) --CreateNew3DSound("Sounds\\Spells\\disintegration_loop_1.wav", GetUnitX(unit), GetUnitY(unit), 65., 120, 1500., true)
                UnitAddAbility(unit, FourCC("A002"))

                unit_data.hand_right_sfx = AddSpecialEffectTarget("Spell\\FrostHands.mdx", unit, "hand right")
                unit_data.hand_left_sfx = AddSpecialEffectTarget("Spell\\FrostHands.mdx", unit, "hand left")
                unit_data.channel_sfx = AddSpecialEffect("Spell\\Sleet Storm.mdx", GetUnitX(unit), GetUnitY(unit))
                unit_data.ground_sfx = AddSpecialEffect("Effect\\Effect 1xeshteg1.mdx", GetUnitX(unit), GetUnitY(unit))
                BlzSetSpecialEffectZ(unit_data.channel_sfx, GetUnitZ(unit) + 100.)


                unit_data.channel_trigger = CreateTrigger()
                TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_POINT_ORDER)
                TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_ORDER)

                local level = UnitGetAbilityLevel(unit, "ABLZ")
                local duration = 2. + level * 0.1
                local breakpoint = duration - 0.25
                local scale = start_scale
                local max_scale = RMinBJ(2., 1.3 + level * 0.02)
                BlzSetSpecialEffectScale(unit_data.channel_sfx, scale)
                BlzSetSpecialEffectScale(unit_data.ground_sfx, RMinBJ(2.75, 1.75 + level * 0.02))
                unit_data.blz_scale = scale


                TriggerAddAction(unit_data.channel_trigger, function()
                    if not IsItemOrder(GetIssuedOrderId()) and duration <= breakpoint then BlizzardDeactivate(unit) end
                end)

                SetUnitTimeScale(unit, 0.05)
                SetUnitFacingTimed(unit, AngleBetweenUnitXY(unit, PlayerMousePosition[player_id].x or 0., PlayerMousePosition[player_id].y or 0.), 0.1)

                TimerStart(unit_data.action_timer, 0.025, true, function()

                    if duration > 0. and GetUnitState(unit, UNIT_STATE_LIFE) > 0.045 and unit_data.channeled_ability == "ABLZ" then
                        time_point = time_point - 0.025

                        if time_point <= 0. then
                            local effect = ApplyEffect(unit, nil, GetUnitX(unit), GetUnitY(unit), "EBLZ", 1, ability_instance)
                            ability_instance.is_attack = false
                            time_point = 0.3
                        end

                        if scale < max_scale then
                            scale = scale + 0.005
                            BlzSetSpecialEffectScale(unit_data.channel_sfx, scale)
                            unit_data.blz_scale = scale
                        end

                        SetUnitFacingTimed(unit, AngleBetweenUnitXY(unit, PlayerMousePosition[player_id].x or 0., PlayerMousePosition[player_id].y or 0.), 0.1)

                    else
                        BlizzardDeactivate(unit)
                    end

                    duration = duration - 0.025
                end)

            end
    end



    function IcicleRainCast(caster, x, y, ability_instance)
        local level = UnitGetAbilityLevel(caster, "ASIR")
        local amount = 3 + math.floor(level / 3)
        local halfarea = (250. + level * 5.) * 0.5
        local timer = CreateTimer()

        if halfarea > 450. then halfarea = 450. end
        if amount > 30 then amount = 30 end

            AddSoundVolume("Sounds\\Spells\\IcicleRain_Spawn_" .. GetRandomInt(1,3)..".wav", x, y, 150, 1500., 4000.)

            TimerStart(timer, 0.26, true, function()

                if amount > 0 then
                    local point_x = x + GetRandomReal(-halfarea, halfarea)
                    local point_y = y + GetRandomReal(-halfarea, halfarea)
                    local effect = AddSpecialEffect("Effect\\Blizzard II.mdx", point_x, point_y)

                        BlzSetSpecialEffectTimeScale(effect, 1.5)
                        DestroyEffect(effect)
                        AddSoundVolume("Sounds\\Spells\\IcicleRain_Ice_".. GetRandomInt(1,4) .. ".wav", point_x, point_y, 150, 1500.)
                        DelayAction(0.405, function() ApplyEffect(caster, nil, point_x, point_y, "EICR", 1, ability_instance) end) --0.81
                        amount = amount - 1
                else
                    DestroyTimer(timer)
                end

            end)

    end


    function FireWaveCast(caster, x, y, ability_instance)
        local missiles = {}
        local amount = 6
        local arc = 30. / amount
        local angle = AngleBetweenUnitXY(caster, x, y)
        local unit_data = GetUnitData(caster)
        local boost = { tags = {}}

            amount = math.floor(amount * 0.5)

            local bonus_angle = arc
                for i = 1, amount do
                    missiles[#missiles+1] = ThrowMissile(caster, nil, "fire_wall_missile", { ability_instance = ability_instance }, GetUnitX(caster), GetUnitY(caster), 0., 0., angle + bonus_angle, true)
                    missiles[#missiles+1] = ThrowMissile(caster, nil, "fire_wall_missile", { ability_instance = ability_instance }, GetUnitX(caster), GetUnitY(caster), 0., 0., angle - bonus_angle, true)
                    bonus_angle = bonus_angle + arc
                end

            missiles[#missiles+1] = ThrowMissile(caster, nil, "fire_wall_missile", { ability_instance = ability_instance }, GetUnitX(caster), GetUnitY(caster), 0., 0., angle, true)

            local volume = 90
            local flame_sound = CreateNew3DSound("Sounds\\Spells\\flame_wave_loop.wav", x, y, 10., volume, 1700., 4000., true)
            StartSound(flame_sound)
            SetSoundPlayPosition(flame_sound, GetRandomInt(0, GetSoundDuration(flame_sound)))

            local timer = CreateTimer()
            TimerStart(timer, 0.025, true, function()
                if missiles[1] and missiles[1].time <= 0. then
                    local delta = volume / 40
                    TimerStart(timer, 0.025, true, function()
                        volume = math.floor(volume - delta)
                        SetSoundVolume(flame_sound, volume)
                        if volume <= 0 then
                            StopSound(flame_sound, true, false)
                            DestroyTimer(timer)
                        end
                    end)
                else
                    SetSoundPosition(flame_sound, missiles[1].current_x, missiles[1].current_y, 10.)
                end
            end)

    end



    function FrostNovaVisual(source)
        local x,y = GetUnitX(source), GetUnitY(source)
        local timer = CreateTimer()
        local radius = 5.
        local step = 500. / ((320. / 500) / 0.025)

            TimerStart(timer, 0.025, true, function()
                radius = radius + step
                local amount = math.floor(radius / 10)

                for i = 1, amount do
                    local angle = GetRandomReal(0., 360.)
                    local tx,ty = x + Rx(radius, angle), y + Ry(radius, angle)
                    local effect = AddSpecialEffect("Effect\\Ice Shard.mdx", tx, ty)

                        BlzSetSpecialEffectTimeScale(effect, 1.5)
                        BlzSetSpecialEffectScale(effect, GetRandomReal(0.1, 0.4))
                        BlzSetSpecialEffectYaw(effect, AngleBetweenXY(x,y,tx,ty))
                        local anglemod = 1. + (radius / 450.)
                        if anglemod > 1.8 then anglemod = 1.8 end
                        BlzSetSpecialEffectPitch(effect, math.rad(45. * anglemod))
                        DelayAction(2. + GetRandomReal(0.03, 0.07), function() DestroyEffect(effect) end)
                end


                if radius >= 300. then DestroyTimer(timer) end
            end)

    end


    function FireWallCast(caster, x, y, ability_instance)
        local level = UnitGetAbilityLevel(caster, "AFWL")
        local angle = AngleBetweenUnitXY(caster, x, y)
        local time = 6.
        local timer = CreateTimer()
        local amount = 1 * math.floor(level / 10)
        local fires = { [1] = { sfx = AddSpecialEffect("Effect\\FireMedium.mdx", x, y), x = x, y = y } }

        BlzSetSpecialEffectYaw(fires[1].sfx, math.rad(GetRandomReal(0., 360.)))

        if amount > 4 then amount = 4 end

        local start_index = 1
        local offset = 100.
        local delay = 0.15
            for c = 1, amount do
                local of = offset
                local ind = start_index
                DelayAction(delay, function()
                    local nx,ny = x + Rx(of, angle - 90.), y + Ry(of, angle - 90.)
                    fires[ind+1] = { sfx = AddSpecialEffect("Effect\\FireMedium.mdx", nx, ny), x = nx, y = ny }
                    BlzSetSpecialEffectYaw(fires[ind+1].sfx, math.rad(GetRandomReal(0., 360.)))
                    --DestroyEffect(AddSpecialEffect("Effect\\Pillar of Flame Orange.mdx", nx, ny))
                    nx,ny = x + Rx(of, angle + 90.), y + Ry(of, angle + 90.)
                    fires[ind+2] = { sfx = AddSpecialEffect("Effect\\FireMedium.mdx", nx, ny), x = nx, y = ny }
                    BlzSetSpecialEffectYaw(fires[ind+2].sfx, math.rad(GetRandomReal(0., 360.)))
                    --DestroyEffect(AddSpecialEffect("Effect\\Pillar of Flame Orange.mdx", nx, ny))
                end)
                start_index = start_index + 2
                offset = offset + 100.
                delay = delay + 0.15
            end

            AddSoundVolume("Sounds\\Spells\\Firewall_Deploy_".. GetRandomInt(1,4) ..".wav", x, y, 128, 1700.)
            local snd = CreateNew3DSound("Sounds\\Spells\\Firewall_Loop.wav", x, y, GetZ(x,y), 128, 1600., 4000., true)
            StartSound(snd)
            SetSoundPlayPosition(snd, GetRandomInt(0, GetSoundDuration(snd)))


            TimerStart(timer, 0.1, true, function()

                if time > 0. then
                    time = time - 0.1
                    for i = 1, #fires do ApplyEffect(caster, nil, fires[i].x, fires[i].y, "fire_wall_effect", level, ability_instance) end
                else
                    StopSound(snd, true, true)
                    DestroyTimer(timer)
                    for i = 1, #fires do DestroyEffect(fires[i].sfx) end
                end

            end)


            if amount > 0 then
                local distance = 0.
                local move_timer = CreateTimer()
                local effect_data = {}
                local step = offset / ((offset / 700.) / 0.025)

                    for i = 1, 2 do
                        effect_data[i] = { sfx = AddSpecialEffect("Abilities\\Spells\\Orc\\Shockwave\\ShockwaveMissile.mdx", x, y), x = x, y = y  }
                        BlzSetSpecialEffectScale(effect_data[i].sfx, 0.7)
                    end

                    effect_data[1].a = angle - 90.
                    effect_data[2].a = angle + 90.
                    BlzSetSpecialEffectYaw(effect_data[1].sfx, math.rad(effect_data[1].a))
                    BlzSetSpecialEffectYaw(effect_data[2].sfx, math.rad(effect_data[2].a))

                    TimerStart(move_timer, 0.025, true, function()

                        if distance >= offset then
                            DestroyEffect(effect_data[1].sfx)
                            DestroyEffect(effect_data[2].sfx)
                            DestroyTimer(move_timer)
                        else

                            for i = 1, 2 do
                                effect_data[i].x = effect_data[i].x + Rx(step, effect_data[i].a)
                                effect_data[i].y = effect_data[i].y + Ry(step, effect_data[i].a)
                                BlzSetSpecialEffectX(effect_data[i].sfx, effect_data[i].x)
                                BlzSetSpecialEffectY(effect_data[i].sfx, effect_data[i].y)
                                BlzSetSpecialEffectZ(effect_data[i].sfx, GetZ(effect_data[i].x, effect_data[i].y))
                            end

                            distance = distance + step

                        end

                    end)

            end

    end



    function ArcaneRiftCast(caster)
        local level = UnitGetAbilityLevel(caster, "AARF")
        local amount = 1 + math.floor(level / 10)
        local cx, cy = GetUnitX(caster), GetUnitY(caster)

            if amount > 5 then amount = 5 end

            for i = 1, amount do
                local angle = GetRandomReal(0., 360.)
                local range = GetMaxAvailableDistance(cx, cy, angle, GetRandomReal(150, 500))
                local x,y = cx + Rx(range, angle), cy + Ry(range, angle)


                    DestroyEffect(AddSpecialEffect("Effect\\Flamestrike Starfire I.mdx", x, y))
                    CreateAuraOnPoint(caster, x, y, "arcane_rift_aura", level, nil)
            end

    end

    function ArcaneBarrageCast(source, x, y, ability_instance)
        local timer = CreateTimer()
        local arc_side = GetRandomInt(1, 2) == 1 and 1. or -1.
        local distance = DistanceBetweenUnitXY(source, x, y) + GetRandomReal(-150., 150.)
        if distance < 400. then distance = 400. end
        local distance_first = distance + GetRandomReal(-150., 150.)
        local distance_second = distance + GetRandomReal(-150., 150.)

            ThrowMissile(source, nil, "arcane_barrage_missile", { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), x, y, 0., true)

            TimerStart(timer, 0.12, false, function()
                local missile = ThrowMissile(source, nil, "arcane_barrage_missile_side", { ability_instance = ability_instance, geo_arc_side = arc_side, geo_arc_length = distance_first }, GetUnitX(source), GetUnitY(source), x, y, 0., true)
                TimerStart(timer, 0.12, false, function()
                    missile = ThrowMissile(source, nil, "arcane_barrage_missile_side", { ability_instance = ability_instance, geo_arc_side = arc_side > 0 and -1. or 1., geo_arc_length = distance_second }, GetUnitX(source), GetUnitY(source), x, y, 0., true)
                    DestroyTimer(timer)
                end)
            end)

    end


    function LightningSpearSubEffect(caster, x, y, target, ability_instance)
        local group = CreateGroup()

            GroupEnumUnitsInRange(group, x, y, 250., nil)

                if BlzGroupGetSize(group) > 0 then
                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                        local picked = BlzGroupUnitAt(group, index)

                            if IsUnitEnemy(picked, Player(0)) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 and picked ~= target then
                                ApplyEffect(caster, picked, 0, 0, "lightning_spear_sub_effect", 1, ability_instance)
                                LightningEffect_Units(target, picked, "BLNL", 0.27, 80., 80.)
                            end

                    end
                end

            DestroyGroup(group)

    end


    function PermafrostEffect(caster, x, y, ability_instance)
        local timer = CreateTimer()
        local angle = AngleBetweenUnitXY(caster, x, y)
        local angle_mod = GetRandomReal(-6.,6.)
        local scale = 0.75
        local distance = 90.
        local distance_mod = 75.
        local start_x, start_y = GetUnitX(caster), GetUnitY(caster)

            local new_x, new_y = start_x + Rx(distance, angle + angle_mod), start_y + Ry(distance, angle + angle_mod)
            bj_lastCreatedEffect = AddSpecialEffect("Effect\\NNmodel (59).mdx", new_x, new_y)
            BlzSetSpecialEffectYaw(bj_lastCreatedEffect, (angle + angle_mod) * bj_DEGTORAD)
            BlzSetSpecialEffectScale(bj_lastCreatedEffect, scale)
            DestroyEffect(bj_lastCreatedEffect)
            ApplyEffect(caster, nil, new_x, new_y, "permafrost_effect", 1, ability_instance)
            ability_instance.bonus_radius = 15.

            TimerStart(timer, 0.07, true, function()

                distance_mod = distance_mod * 1.12
                distance = distance + distance_mod
                scale = scale * 1.12
                ability_instance.bonus_radius = ability_instance.bonus_radius * 1.14
                angle_mod = GetRandomReal(-6.,6.)


                new_x, new_y = start_x + Rx(distance, angle + angle_mod), start_y + Ry(distance, angle + angle_mod)
                bj_lastCreatedEffect = AddSpecialEffect("Effect\\NNmodel (59).mdx", new_x, new_y)
                BlzSetSpecialEffectYaw(bj_lastCreatedEffect, (angle + angle_mod) * bj_DEGTORAD)
                BlzSetSpecialEffectScale(bj_lastCreatedEffect, scale)
                DestroyEffect(bj_lastCreatedEffect)
                ApplyEffect(caster, nil, new_x, new_y, "permafrost_effect", 1, ability_instance)

                if distance > 600. then DestroyTimer(timer) end
            end)


    end


    function EnflameEffect(source)

        for i = 1, 6 do
            if PlayerHero[i] and GetWidgetLife(PlayerHero[i]) > 0.045 and IsUnitInRange(PlayerHero[i], source, 800.) then
                ApplyBuff(source, PlayerHero[i], "ABEF", UnitGetAbilityLevel(source, "ASEF"))
            end
        end

    end

    function ApplyEnflameWeaponEffect(target, flag)
        local point = "hand right"
            local unit_data = GetUnitData(target)

                if IsWeaponTypeTwohanded(unit_data.equip_point[WEAPON_POINT].SUBTYPE) and unit_data.equip_point[WEAPON_POINT].SUBTYPE ~= STAFF_WEAPON and unit_data.equip_point[WEAPON_POINT].SUBTYPE ~= BOW_WEAPON then
                    point = "weapon"
                end

                if GetUnitClass(target) == ASSASSIN_CLASS and unit_data.equip_point[WEAPON_POINT].SUBTYPE == BOW_WEAPON then
                    point = "hand left"
                end

            if unit_data.enflame then
                DestroyEffect(unit_data.enflame)
            end

            unit_data.enflame = AddSpecialEffectTarget("Buffs\\Ember Sword FX 5.mdx", target, point)
    end


end


