do
    MAX_CRITICAL = 70.
    MIN_CRITICAL = 0.

    MELEE_ATTACK = 1
    RANGE_ATTACK = 2


    --TODO probably legacy
    function GetAttributeBonus(a, b)
        local source = GetUnitData(a)
        local victim = GetUnitData(b)
        local attribute = source.equip_point[WEAPON_POINT].ATTRIBUTE
        --стихия оружия
        return 1. + ((source.stats[attribute].value - victim.stats[attribute].value) * 0.01)
    end


    ---@param a unit
    ---@param bonus real
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



    ---@param source unit
    ---@param target unit
    ---@param amount real
    ---@param attribute integer
    ---@param damage_type number
    ---@param attack_type number
    ---@param can_crit boolean
    ---@param is_sound boolean
    function DamageUnit(source, target, amount, attribute, damage_type, attack_type, can_crit, is_sound, eff)
        local attacker = GetUnitData(source)
        local victim = GetUnitData(target)
        local critical_rate = 1.
        local damage = amount
        local attribute_bonus = 1.
        local defence = 1.
        local attack_modifier = 1.

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

            damage = (damage * attribute_bonus) * critical_rate
        else
            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (DefenceToPercent(victim.stats[PHYSICAL_DEFENCE].value) * 0.01)
            elseif damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker.stats[MAGICAL_ATTACK].value - victim.stats[MAGICAL_SUPPRESSION].value
                if boost < 0 then boost = 0 end

                damage = damage * (1. + (MagicAttackToPercent(boost) * 0.01))
             end


            attack_modifier = attack_type == MELEE_ATTACK and victim.stats[MELEE_DAMAGE_REDUCTION].value or victim.stats[RANGE_DAMAGE_REDUCTION].value
            attack_modifier = 1. - (attack_modifier * 0.01)

            attribute_bonus = 1. + ((attacker.stats[attribute].value - victim.stats[attribute].value) * 0.01)

            damage = ((damage * attribute_bonus) * critical_rate) * defence * attack_modifier
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

                if BlzGetEventAttackType() == ATTACK_TYPE_MELEE and GetEventDamage() > 0. and GetUnitData(GetEventDamageSource()) ~= nil then
                    local data = GetUnitData(GetEventDamageSource())

                    if data.equip_point[WEAPON_POINT].MAX_TARGETS > 1 then
                        local enemy_group = CreateGroup()
                        local facing = GetUnitFacing(data.Owner)
                        local player = GetOwningPlayer(data.Owner)

                            GroupEnumUnitsInRange(enemy_group,
                                    GetUnitX(data.Owner) + (data.equip_point[WEAPON_POINT].RANGE * Cos(facing * bj_DEGTORAD)),
                                    GetUnitY(data.Owner) + (data.equip_point[WEAPON_POINT].RANGE * Sin(facing * bj_DEGTORAD)),
                                    data.equip_point[WEAPON_POINT].RANGE, nil)


                            for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(enemy_group, index)
                                    if IsUnitEnemy(picked, player) then
                                        if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and IsAngleInFace(data.Owner, data.equip_point[WEAPON_POINT].ANGLE, GetUnitX(picked), GetUnitY(picked), false) then
                                            DamageUnit(data.Owner, picked, data.equip_point[WEAPON_POINT].DAMAGE, data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, 0)
                                        end
                                    end
                                GroupRemoveUnit(enemy_group, picked)
                            end

                            DestroyGroup(enemy_group)

                    else
                        DamageUnit(data.Owner, GetTriggerUnit(), data.equip_point[WEAPON_POINT].DAMAGE + data.stats[PHYSICAL_ATTACK].value,
                                data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, 0)
                    end

                    BlzSetEventDamage(0.)
                end

            end)

    end

end