do
    MAX_CRITICAL = 70.
    MIN_CRITICAL = 0.




    function GetAttributeBonus(a, b)
        local source = GetUnitData(a)
        local victim = GetUnitData(b)
        local attribute = source.equip_point[WEAPON_POINT].ATTRIBUTE
        --стихия оружия
        return 1. + ((source.stats[attribute].value - victim.stats[attribute].value) * 0.01)
    end


    function  GetCriticalChance(a, bonus)
        local source = GetUnitData(a)
        local chance = 0. + bonus + source.stats[CRIT_CHANCE].value

            if chance > MAX_CRITICAL then
                return MAX_CRITICAL
            elseif chance < MIN_CRITICAL then
                return MIN_CRITICAL
            end

        return chance
    end



    function DamageUnit(source, target, amount, attribute, damage_type, can_crit, is_sound, eff)
        local attacker = GetUnitData(source)
        local victim = GetUnitData(target)
        local critical_rate = 1.
        local damage = amount
        local attribute_bonus = 1.
        local defence = 1.


            if target == nil then return 0 end


            if can_crit then
                if Chance(GetCriticalChance(source, 0)) then
                    critical_rate = attacker.stats[CRIT_MULTIPLIER].value
                    if critical_rate < 1.1 then critical_rate = 1.1 end
                end

            end



        if victim == nil then
            attribute_bonus = 1. + (attacker.stats[attribute].value * 0.01)

                if damage_type == DAMAGE_TYPE_MAGICAL then
                    damage = damage * (1. + (MagicAttackToPercent(attacker.stats[MAGICAL_ATTACK].value) * 0.01))
                end

            damage = damage * critical_rate
        else
            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (DefenceToPercent(victim.stats[PHYSICAL_DEFENCE].value) * 0.01)
            else if damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker.stats[MAGICAL_ATTACK].value - victim.stats[MAGICAL_SUPPRESSION].value
                if boost < 0 then boost = 0 end

                damage = damage * (1. + (MagicAttackToPercent(boost) * 0.01))
            end
        end

                attribute_bonus = 1. + ((attacker.stats[attribute].value - victim.stats[attribute].value) * 0.01)
                damage = ((damage * attribute_bonus) * critical_rate) * defence
            end

            if damage < 0. then damage = 0 end

            damage = GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2])


            UnitDamageTarget(source, target, damage, false, false, nil, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)


            print(damage)

        return 0
    end



    function MainEngineInit()
        local trg = CreateTrigger()

            TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DAMAGED)
            TriggerAddAction(trg, function()

                if BlzGetEventAttackType() == ATTACK_TYPE_MELEE and GetEventDamage() > 0. then
                    local data = GetUnitData(GetEventDamageSource())
                    DamageUnit(GetEventDamageSource(), GetTriggerUnit(), data.equip_point[WEAPON_POINT].DAMAGE, data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, true, true, true, 0)
                    BlzSetEventDamage(0.)
                end

            end)

    end

end