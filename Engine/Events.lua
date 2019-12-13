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



