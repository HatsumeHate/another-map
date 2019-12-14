do




    function OnJumpExpire(target, sign)

    end


    function OnPushExpire(source, data)
        if data.sign == 'EUPP' then
            ApplyBuff(data.source, source, 'A012', 1)
        end
    end


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
        if missile.id == 'MBLB' then
            LightningBall_VisualEffect(target, missile)
        end
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

        if effect.id == 'EUPP' then
            PushUnit(source, target, AngleBetweenUnits(source,target), 200., 1.25, effect.id)
        end

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
        elseif skill.Id == 'A00I' then
            local unit_data = GetUnitData(source)

            if unit_data.spawned_hydra ~= nil then
                KillUnit(unit_data.spawned_hydra)
            end

            unit_data.spawned_hydra = CreateUnit(Player(GetOwningPlayer(source)), FourCC('shdr'), x, y, GetRandomReal(0.,359.))
            UnitApplyTimedLife(unit_data.spawned_hydra, 0, 7.)
        elseif skill.Id == 'A00J' then
            SparkCast(source, target, x, y)
        elseif skill.Id == 'A00O' then
            MakeUnitJump(source, AngleBetweenUnitXY(source, x, y), x, y, 720., 0.6, 'A00O')
        elseif skill.Id == 'A010' then
            WhirlwindActivate(source)
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



