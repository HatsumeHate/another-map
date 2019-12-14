do






    ---@param source unit
    ---@param missile table
    function OnMissileImpact(source, missile)

    end

    ---@param source unit
    ---@param target unit
    ---@param missile table
    function OnMissileExpire(source, target, missile)

    end

    ---@param source unit
    ---@param target unit
    ---@param missile table
    function OnMissileHit(source, target, missile)

    end

    function OnMissileLaunch(source, target, missile)
        if missile.id == 'M001' then
            TimerStart(CreateTimer(), 0.25, true, function ()
                RedirectMissile_Deg(missile, GetRandomReal(0., 359.))
                if missile == nil then
                    DestroyTimer(GetExpiredTimer())
                end
            end)
        end
    end

    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param effect table
    function OnEffectPrecast(source, target, x, y, effect)

    end

    ---@param source unit
    ---@param target unit
    ---@param effect table
    function OnEffectApply(source, target , effect)

    end



    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffExpire(source, target, buff)

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffOverTimeTrigger(source, target, buff)

    end

    ---@param source unit
    ---@param buff table
    function OnBuffApply(source, target, buff)

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffPrecast(source, target, buff)

    end



    ---@param source unit
    ---@param target unit
    ---@param damage table
    function OnDamage_End(source, target, damage)

    end

    ---@param source unit
    ---@param damage table
    function OnDamage_PreHit(source, target, damage)

    end


    ---@param source unit
    ---@param target unit
    function OnAttackEnd(source, target)

    end

    ---@param source unit
    ---@param target unit
    function OnAttackStart(source, target)

    end


    ---@param source unit
    ---@param target unit
    ---@param skill table
    ---@param x real
    ---@param y real
    function OnSkillCastEnd(source, target, x, y, skill)
        if skill.Id == 'A00L' then
            SetUnitPosition(source, x, y)
        elseif skill.Id == 'A00J' then
            local angle

            if target ~= nil then
                angle = AngleBetweenUnitXY(source, GetUnitX(target), GetUnitY(target))
            else
                angle = AngleBetweenUnitXY(source, x, y)
            end


            local discharge = {}

                discharge[1] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, 0.), a = angle }
                discharge[2] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle + 15.), a = angle + 15. }
                discharge[3] = { missile = ThrowMissile(source, nil, 'MDSC', nil, GetUnitX(source), GetUnitY(source), x, y, angle - 15.), a = angle - 15. }

            for i = 1, 3 do
                local timer = CreateTimer()
                local timeout = GetRandomReal(0.25, 0.65)
                TimerStart(timer, 0.05, true, function()
                    if discharge[i].missile.time > 0. then
                        if timeout <= 0. then
                            RedirectMissile_Deg(discharge[i].missile, discharge[i].a + GetRandomReal(-15., 15.))
                            timeout = GetRandomReal(0.25, 0.65)
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

    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param skill table
    function OnSkillCast(source, target, x, y, skill)

    end



end



