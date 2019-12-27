do




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


