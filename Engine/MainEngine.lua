do

    MAX_CRITICAL = 70.
    MIN_CRITICAL = 0.

    MAX_BLOCK_CHANCE = 60.
    MIN_ATTACK_DAMAGE_REDUCTION = 0.4
    MIN_ATTRIBUTE_DAMAGE_REDUCTION = 0.35

    MELEE_ATTACK = 1
    RANGE_ATTACK = 2

    ATTACK_STATUS_USUAL = 1
    ATTACK_STATUS_CRITICAL = 2
    ATTACK_STATUS_CRITICAL_BLOCKED = 5
    ATTACK_STATUS_BLOCKED = 6
    ATTACK_STATUS_EVADE = 7
    HEAL_STATUS = 3
    RESOURCE_STATUS = 4


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
    ---@param myeffect table
    ---@param direct boolean
    function DamageUnit(source, target, amount, attribute, damage_type, attack_type, can_crit, direct, is_sound, myeffect)
        local attacker = GetUnitData(source)
        local victim = GetUnitData(target)
        local critical_rate = 1.
        local bonus_critical_rate = 0.
        local bonus_critical = 0.
        local damage = amount
        local attribute_bonus = 1.
        local defence = 1.
        local attack_modifier = 1.
        local block_reduction = 1.
        local attack_status = ATTACK_STATUS_USUAL

            if target == nil then return 0 end


        if myeffect ~= nil then
            local effect_data = myeffect.eff.level[myeffect.l]

                if effect_data.bonus_crit_chance ~= nil then
                    bonus_critical = effect_data.bonus_crit_chance
                end

                if effect_data.bonus_crit_multiplier ~= nil then
                    bonus_critical_rate = effect_data.bonus_crit_multiplier
                end

                if effect_data.weapon_damage_percent_bonus ~= nil then
                    damage = damage + (attacker.equip_point[WEAPON_POINT].DAMAGE * effect_data.weapon_damage_percent_bonus)
                end

                if effect_data.attack_percent_bonus > 0. then
                    if damage_type == DAMAGE_TYPE_PHYSICAL then
                        damage = damage + attacker.stats[PHYSICAL_ATTACK].value * effect_data.attack_percent_bonus
                    elseif damage_type == DAMAGE_TYPE_MAGICAL then
                        damage = damage + attacker.stats[MAGICAL_ATTACK].value * effect_data.attack_percent_bonus
                    end
                end

        end

            if can_crit then
                if GetRandomInt(1, 100) <= GetCriticalChance(source, bonus_critical) then
                    critical_rate = attacker.stats[CRIT_MULTIPLIER].value + bonus_critical_rate
                    attack_status = ATTACK_STATUS_CRITICAL
                    if critical_rate < 1.1 then critical_rate = 1.1 end
                end
            end


        if victim == nil then

                if attribute ~= nil then
                    attribute_bonus = 1. + (attacker.stats[attribute].value * 0.01)
                end

                if damage_type == DAMAGE_TYPE_MAGICAL then
                    damage = damage * (1. + (ParamToPercent(attacker.stats[MAGICAL_ATTACK].value, MAGICAL_ATTACK) * 0.01))
                end

            damage = (damage * attribute_bonus) * critical_rate

        else

            if direct and victim.equip_point[OFFHAND_POINT] ~= nil and victim.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND then
                local block_chance = victim.stats[BLOCK_CHANCE].value

                if block_chance > MAX_BLOCK_CHANCE then block_chance = MAX_BLOCK_CHANCE end

                if GetRandomInt(1, 100) <= block_chance then
                    attack_status = attack_status == ATTACK_STATUS_CRITICAL and ATTACK_STATUS_CRITICAL_BLOCKED or ATTACK_STATUS_BLOCKED
                    block_reduction = 1. - victim.stats[BLOCK_ABSORB].value * 0.01
                end

            end


            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (ParamToPercent(victim.stats[PHYSICAL_DEFENCE].value, PHYSICAL_DEFENCE) * 0.01)
            elseif damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker.stats[MAGICAL_ATTACK].value - victim.stats[MAGICAL_SUPPRESSION].value
                if boost < 0 then boost = 0 end

                damage = damage * (1. + (ParamToPercent(boost, MAGICAL_ATTACK) * 0.01))
            end


            if attack_type ~= nil and direct then
                attack_modifier = attack_type == MELEE_ATTACK and victim.stats[MELEE_DAMAGE_REDUCTION].value or victim.stats[RANGE_DAMAGE_REDUCTION].value
                attack_modifier = 1. - (attack_modifier * 0.01)
                if attack_modifier < MIN_ATTACK_DAMAGE_REDUCTION then attack_modifier = MIN_ATTACK_DAMAGE_REDUCTION end
            end


            if attribute ~= nil then
                local attribute_value = attacker.equip_point[WEAPON_POINT].ATTRIBUTE == attribute and attacker.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0

                    attribute_bonus = 1. + (((attacker.stats[attribute].value + attribute_value) - victim.stats[attribute].value) * 0.01)
                    if attribute_bonus < MIN_ATTRIBUTE_DAMAGE_REDUCTION then attribute_bonus = MIN_ATTRIBUTE_DAMAGE_REDUCTION end

            end

            damage = ((damage * attribute_bonus) * critical_rate * block_reduction) * defence * attack_modifier
        end


        --print("attrib "..attribute_bonus)
        --print("rate "..critical_rate)
        --print("defence "..defence)
        --print("modifier "..attack_modifier)
        --print(TimerGetRemaining(attacker.attack_timer))


        if not (TimerGetRemaining(attacker.attack_timer) > 0.) and direct then

            if attacker.stats[HP_PER_HIT].value > 0 then
                SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + attacker.stats[HP_PER_HIT].value)
                CreateHitnumber(attacker.stats[HP_PER_HIT].value, source, source, HEAL_STATUS)
            end

            if attacker.stats[MP_PER_HIT].value > 0 then
                SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker.stats[MP_PER_HIT].value)
                CreateHitnumber(attacker.stats[MP_PER_HIT].value, source, source, RESOURCE_STATUS)
            end

            TimerStart(attacker.attack_timer, attacker.stats[ATTACK_SPEED].value - 0.01, false, nil)
        end

            damage = GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2])

            damage = R2I(damage)
            if damage < 0. then damage = 0 end
            UnitDamageTarget(source, target, damage, false, false, nil, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)

            print(damage)
            CreateHitnumber(damage, source, target, attack_status)


        return damage
    end



    function MainEngineInit()
        local trg = CreateTrigger()

            TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DAMAGED)
            TriggerAddAction(trg, function()

                if BlzGetEventAttackType() == ATTACK_TYPE_MELEE and GetEventDamage() > 0. and GetUnitData(GetEventDamageSource()) ~= nil then
                    local data = GetUnitData(GetEventDamageSource())
                    local target =  GetTriggerUnit()

                    if data.equip_point[WEAPON_POINT].ranged then
                        ThrowMissile(data.Owner, target, data.equip_point[WEAPON_POINT].missile, nil, GetUnitX(data.Owner), GetUnitY(data.Owner), GetUnitX(target), GetUnitY(target), 0.)
                    else
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
                                                DamageUnit(data.Owner, picked, data.equip_point[WEAPON_POINT].DAMAGE + data.stats[PHYSICAL_ATTACK].value,
                                                        data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, true, nil)
                                            end
                                        end
                                    end

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        else
                            DamageUnit(data.Owner, GetTriggerUnit(), data.equip_point[WEAPON_POINT].DAMAGE + data.stats[PHYSICAL_ATTACK].value,
                                    data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, true, nil)
                        end

                    end

                    BlzSetEventDamage(0.)
                end

            end)

    end

end