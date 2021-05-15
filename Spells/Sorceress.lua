do



    function LightningEffect_Units(source, target, id, faderate, bonus_start_z, bonus_end_z)
        local bolt = AddLightningEx(id, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + bonus_start_z, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + bonus_end_z)
        local fade_time = faderate

            TimerStart(CreateTimer(), 0.025, true, function()
                if faderate <= 0. then
                    DestroyLightning(bolt)
                    DestroyTimer(GetExpiredTimer())
                else
                    SetLightningColor(bolt, 1, 1, 1, faderate / fade_time)
                    MoveLightningEx(bolt, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + bonus_start_z, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + bonus_end_z)
                    faderate = faderate - 0.025
                end
            end)

    end


    function LightningBall_VisualEffect(target, missile)
        local faderate = 0.55
        local bolt = AddLightningEx("BLNL", true, missile.current_x, missile.current_y, missile.current_z, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + BlzGetLocalUnitZ(target) + missile.end_z)
        local missile_x = missile.current_x
        local missile_y = missile.current_y
        local missile_z = missile.current_z
        local missile_end_z = missile.end_z

            TimerStart(CreateTimer(), 0.025, true, function()
                if faderate <= 0. then
                    DestroyLightning(bolt)
                    DestroyTimer(GetExpiredTimer())
                else
                    SetLightningColor(bolt, 1, 1, 1, faderate / 0.55)

                    if missile == nil then
                        MoveLightningEx(bolt, true, missile_x, missile_y, missile_z, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + BlzGetLocalUnitZ(target) + missile_end_z)
                    else
                        missile_x = missile.current_x
                        missile_y = missile.current_y
                        missile_z = missile.current_z
                        missile_end_z = missile.end_z

                        MoveLightningEx(bolt, true, missile.current_x, missile.current_y, missile.current_z, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + BlzGetLocalUnitZ(target) + missile.end_z)
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

        LightningEffect_Units(source, target, "BLNL", 0.45, 50., 50.)
        ApplyEffect(source, target, 0., 0.,"ECHL", 1)

        local damaged_group = CreateGroup()
        GroupAddUnit(damaged_group, target)

        local next_target = GetChainLightningVictim(source, target, 500., damaged_group)


            if next_target then
                local rebounds = 2 + math.floor(UnitGetAbilityLevel(source, "A019") / 15)
                GroupAddUnit(damaged_group, next_target)

                TimerStart(CreateTimer(), 0.45, true, function()

                    LightningEffect_Units(source, next_target, "BLNL", 0.45, 50., 50.)
                    ApplyEffect(source, next_target, 0., 0.,"ECHL", 1)
                    rebounds = rebounds - 1

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


    function SparkCast(source, target, x, y)
        local angle
        local discharge = {}

            if target ~= nil then
                angle = AngleBetweenUnitXY(source, GetUnitX(target), GetUnitY(target))
            else
                angle = AngleBetweenUnitXY(source, x, y)
            end


        discharge[1] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, 0.), a = angle }
        discharge[2] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle + 15.), a = angle + 15. }
        discharge[3] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle - 15.), a = angle - 15. }


            for i = 1, 3 do
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


end


