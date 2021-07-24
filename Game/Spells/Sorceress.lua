do



    function SummonHydra(hero, x, y)
        local unit_data = GetUnitData(hero)

                if unit_data.spawned_hydra then
                    KillUnit(unit_data.spawned_hydra)
                end

            unit_data.spawned_hydra = CreateUnit(GetOwningPlayer(hero), FourCC('shdr'), x, y, GetRandomReal(0.,359.))
            UnitApplyTimedLife(unit_data.spawned_hydra, 0, 6.75 + (UnitGetAbilityLevel(hero, "A00I") * 0.25))

            DelayAction(0.001, function()
                local hydra = GetUnitData(unit_data.spawned_hydra)

                    hydra.stats[PHYSICAL_ATTACK].value = unit_data.stats[PHYSICAL_ATTACK].value * 0.7
                    hydra.stats[MAGICAL_ATTACK].value = unit_data.stats[MAGICAL_ATTACK].value * 0.7
                    hydra.stats[CRIT_CHANCE].value = unit_data.stats[CRIT_CHANCE].value * 0.7
                    hydra.equip_point[WEAPON_POINT].DAMAGE = unit_data.equip_point[WEAPON_POINT].DAMAGE * 0.7
                    hydra.equip_point[WEAPON_POINT].ATTACK_SPEED = unit_data.stats[ATTACK_SPEED].value * 0.7
                    hydra.equip_point[WEAPON_POINT].DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL
                    hydra.equip_point[WEAPON_POINT].ATTRIBUTE = FIRE_ATTRIBUTE
                    hydra.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS = R2I((hydra.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0) * 0.7)
                    hydra.stats[INT_STAT].value = R2I(unit_data.stats[INT_STAT].value * 0.7)
                    hydra.stats[FIRE_BONUS].value = R2I(unit_data.stats[FIRE_BONUS].value * 0.7)
                    UpdateParameters(hydra)

            end)
    end


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
        local bolt = AddLightningEx("BLNL", true, missile.current_x, missile.current_y, missile.current_z, target_x, target_y, target_z + missile.end_z)
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

                        MoveLightningEx(bolt, true, missile.current_x, missile.current_y, missile.current_z, target_x, target_y, target_z + missile.end_z)
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

    function ChainLightningCast(source, target)
        local from = source

        LightningEffect_Units(from, target, "BLNL", 0.45, 50., 50.)
        ApplyEffect(source, target, 0., 0.,"ECHL", 1)

        local damaged_group = CreateGroup()
        GroupAddUnit(damaged_group, target)

        from = target
        local next_target = GetChainLightningVictim(source, target, 500., damaged_group)


            if next_target then
                local rebounds = 2 + math.floor(UnitGetAbilityLevel(source, "A019") / 10)
                GroupAddUnit(damaged_group, next_target)

                local timer = CreateTimer()
                TimerStart(timer, 0.25, true, function()

                    LightningEffect_Units(from, next_target, "BLNL", 0.45, 50., 50.)
                    ApplyEffect(source, next_target, 0., 0.,"ECHL", 1)
                    rebounds = rebounds - 1


                    from = next_target
                    next_target = GetChainLightningVictim(source, next_target, 500., damaged_group)

                        if rebounds <= 0 or not next_target then
                            DestroyTimer(GetExpiredTimer())
                            DestroyGroup(damaged_group)
                        else
                            GroupAddUnit(damaged_group, next_target)
                        end

                end)

            end
    end


    function SparkCast_Legendary(source)
        local discharge = {}
        local spark_amount = 12
        local angle = 360. / spark_amount
        local current_angle = 0.01


        for i = 1, spark_amount do
            discharge[i] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), 0, 0, current_angle), a = current_angle }
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


    function SparkCast(source, target, x, y)
        local angle
        local discharge = {}
        local amount = 3 + math.floor(UnitGetAbilityLevel(source, "A00J") / 10)
        local angle_dispersion = 15.
        local breakpoint = math.floor(amount / 2)


            if target and target == source then
                angle = GetUnitFacing(source)
            elseif target then
                angle = AngleBetweenUnitXY(source, GetUnitX(target), GetUnitY(target))
            else
                angle = AngleBetweenUnitXY(source, x, y)
            end
        --print("unit angle " .. angle)

        if amount % 2 == 0 then angle = angle + (((amount - 1) * angle_dispersion) / 2)
        else angle = angle + (breakpoint * angle_dispersion) end


        for i = 1, amount do
            --print("launch angle is " .. angle)
            discharge[i] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle, true), a = angle }
            angle = angle - angle_dispersion
        end

        --discharge[1] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, 0.), a = angle }
        --discharge[2] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle + 15.), a = angle + 15. }
        --discharge[3] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle - 15.), a = angle - 15. }


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
        local distance = GetMaxAvailableDistance(caster_x, caster_y, angle, skill.level[UnitGetAbilityLevel(caster, "A00L")].range or 0.)

            x = caster_x + Rx(distance, angle)
            y = caster_y + Ry(distance, angle)
            AddSoundVolumeZ("Sounds\\Spells\\blink_launch_".. GetRandomInt(1, 3) ..".wav", caster_x, caster_y, 35., 120, 1700.)
            SetUnitPosition(caster, x, y)
            DestroyEffect(AddSpecialEffect("Spell\\Blink Blue Target.mdx", x, y))

    end


    function CastFrostbolt_Legendary(caster, target, x, y)
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

        frostbolts[1] = ThrowMissile(caster, nil, 'MFRB', nil, GetUnitX(caster) - offsets[1].x, GetUnitY(caster) - offsets[1].y, x, y, 0.)
        frostbolts[2] = ThrowMissile(caster, nil, 'MFRB', nil, GetUnitX(caster) - offsets[2].x, GetUnitY(caster) - offsets[2].y, x, y, angle + 15.)
        frostbolts[3] = ThrowMissile(caster, nil, 'MFRB', nil, GetUnitX(caster) - offsets[3].x, GetUnitY(caster) - offsets[3].y, x, y, angle - 15.)

        frostbolts[1].pause = true; frostbolts[2].pause = true; frostbolts[3].pause = true


        local timeouts = { 1., 0.7, 0.85 }

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

        --[[
        TimerStart(CreateTimer(), 0.02, true, function()

            if timeout <= 0. then
                for i = 1, 3 do
                    if target and target == caster then angle = GetUnitFacing(caster)
                    elseif target then angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, GetUnitX(target), GetUnitY(target))
                    else angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, x, y) end
                    RedirectMissile_Deg(frostbolts[i], angle)
                    frostbolts[i].pause = nil
                end
                DestroyTimer(GetExpiredTimer())
            else
                --facing = GetUnitFacing(caster)

                RepositionMissile(frostbolts[1], GetUnitX(caster) - Rx(55., facing), GetUnitY(caster) - Ry(55., facing), 40.)
                RepositionMissile(frostbolts[2], GetUnitX(caster) - Rx(110., facing + 30.), GetUnitY(caster) - Ry(110., facing + 30.), 0)
                RepositionMissile(frostbolts[3], GetUnitX(caster) - Rx(110., facing - 30.), GetUnitY(caster) - Ry(110., facing - 30.), 0)

                for i = 1, 3 do
                    if target and target == caster then angle = GetUnitFacing(caster) * bj_DEGTORAD
                    elseif target then angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, GetUnitX(target), GetUnitY(target)) * bj_DEGTORAD
                    else angle = AngleBetweenXY_DEG(frostbolts[i].current_x, frostbolts[i].current_y, x, y) * bj_DEGTORAD end
                    BlzSetSpecialEffectYaw(frostbolts[i].my_missile, angle)
                end

                --BlzSetSpecialEffectYaw(frostbolts[1].my_missile, angle); BlzSetSpecialEffectYaw(frostbolts[2].my_missile, angle); BlzSetSpecialEffectYaw(frostbolts[3].my_missile, angle)
                timeout = timeout - 0.02
                first_timeout = first_timeout - 0.02
                second_timeout = second_timeout - 0.02
            end

        end)]]


    end



    function MeltdownDeactivate(unit)
        local unit_data = GetUnitData(unit)
        local skill = GetUnitSkillData(unit, "AMLT")
        local ability_level = UnitGetAbilityLevel(unit, "AMLT")

            --BlzSetUnitAbilityCooldown(unit, GetKeybindKeyAbility(FourCC("AMLT"), GetPlayerId(GetOwningPlayer(unit)) + 1), 0, skill.level[ability_level].cooldown)
            UnitRemoveAbility(unit, FourCC('Abun'))
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil
            TimerStart(unit_data.action_timer, 0., false, nil)
            --SetSoundVolume(unit_data.channel_sound, 0)
            StopSound(unit_data.channel_sound, true, true)
            DestroyEffect(unit_data.weapon_sfx); DestroyEffect(unit_data.hand_sfx)
            UnitRemoveAbility(unit, FourCC("A002")); UnitRemoveAbility(unit, FourCC("B000"))
            DestroyTrigger(unit_data.channel_trigger)
            SetUnitTimeScale(unit, 1.)
            --SafePauseUnit(unit, false)

    end


    function CastMeltdown(unit)
        local unit_data = GetUnitData(unit)

        if unit_data.channeled_destructor then
            unit_data.channeled_destructor(unit)
        else

            ResetUnitSpellCast(unit)

            unit_data.channeled_destructor = MeltdownDeactivate
            unit_data.channeled_ability = "AMLT"

            UnitAddAbility(unit, FourCC('Abun'))
            local player_id = GetPlayerId(GetOwningPlayer(unit)) + 1
            --local myability = GetKeybindKeyAbility(FourCC("AMLT"), player_id)

            --BlzEndUnitAbilityCooldown(unit, myability)
            --DelayAction(0., function() BlzSetUnitAbilityCooldown(unit, myability, 0, 30.) end)


            AddSoundVolumeZ("Sounds\\Spells\\disintegration_launch_"..GetRandomInt(1,2)..".wav", GetUnitX(unit), GetUnitY(unit), 65., 120, 1500.)
            unit_data.channel_sound = CreateNew3DSound("Sounds\\Spells\\disintegration_loop_1.wav", GetUnitX(unit), GetUnitY(unit), 65., 120, 1500., true)
            StartSound(unit_data.channel_sound)
            UnitAddAbility(unit, FourCC("A002"))
            unit_data.weapon_sfx = AddSpecialEffectTarget("Spell\\Sweep_Fire_Medium.mdx", unit, "weapon")
            unit_data.hand_sfx = AddSpecialEffectTarget("Spell\\Fire Uber.mdx", unit, "hand")

            --SafePauseUnit(unit, true)

            unit_data.channel_trigger = CreateTrigger()
            TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_POINT_ORDER)
            TriggerRegisterUnitEvent(unit_data.channel_trigger, unit, EVENT_UNIT_ISSUED_ORDER)


            local duration = 1.25 + UnitGetAbilityLevel(unit, "AMLT") * 0.05
            local breakpoint = duration - 0.25

            TriggerAddAction(unit_data.channel_trigger, function()
                if duration <= breakpoint then MeltdownDeactivate(unit) end
            end)

            SetUnitTimeScale(unit, 0.05)
            SetUnitFacingTimed(unit, AngleBetweenUnitXY(unit, PlayerMousePosition[player_id].x or 0., PlayerMousePosition[player_id].y or 0.), 0.1)

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
                    ThrowMissile(unit, nil, "MMLT", nil, GetUnitX(unit), GetUnitY(unit), 0.,0., facing, true)
                else
                    MeltdownDeactivate(unit)
                    --TimerStart(GetExpiredTimer(), 0., false, nil)
                    --DestroyTimer(GetExpiredTimer())
                end
                duration = duration - 0.05
            end)

        end
    end


end


