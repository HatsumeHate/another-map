do

    MAX_CRITICAL = 60.
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
    REFLECT_STATUS = 8



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



    function GetAttributeResistParam(attribute)
        if attribute == FIRE_ATTRIBUTE then return FIRE_RESIST
        elseif attribute == ICE_ATTRIBUTE then return ICE_RESIST
        elseif attribute == LIGHTNING_ATTRIBUTE then return LIGHTNING_RESIST
        elseif attribute == HOLY_ATTRIBUTE then return HOLY_RESIST
        elseif attribute == DARKNESS_ATTRIBUTE then return DARKNESS_RESIST
        elseif attribute == POISON_ATTRIBUTE then return POISON_RESIST
        elseif attribute == ARCANE_ATTRIBUTE then return ARCANE_RESIST
        else return PHYSICAL_RESIST end
    end

    function GetAttributeBonusParam(attribute)
        if attribute == FIRE_ATTRIBUTE then return FIRE_BONUS
        elseif attribute == ICE_ATTRIBUTE then return ICE_BONUS
        elseif attribute == LIGHTNING_ATTRIBUTE then return LIGHTNING_BONUS
        elseif attribute == HOLY_ATTRIBUTE then return HOLY_BONUS
        elseif attribute == DARKNESS_ATTRIBUTE then return DARKNESS_BONUS
        elseif attribute == POISON_ATTRIBUTE then return POISON_BONUS
        elseif attribute == ARCANE_ATTRIBUTE then return ARCANE_BONUS
        else return PHYSICAL_BONUS end
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
        local trait_modifier = 1.
        local attack_status = ATTACK_STATUS_USUAL

        if attacker == nil then print("Warning: " .. GetUnitName(source) .. " doesn't have unit data.") end
        if victim == nil then print("Warning: " .. GetUnitName(target) .. " doesn't have unit data.") end
        --if source == nil then print("DAMAGE - SOURCE NULL") end

            if target == nil then return 0 end

        --print("1")
        if myeffect ~= nil then
            local effect_data = myeffect.eff.level[myeffect.l]

                if effect_data.bonus_crit_chance ~= nil then bonus_critical = effect_data.bonus_crit_chance end
                if effect_data.bonus_crit_multiplier ~= nil then bonus_critical_rate = effect_data.bonus_crit_multiplier end
                if effect_data.weapon_damage_percent_bonus ~= nil then damage = damage + (attacker.equip_point[WEAPON_POINT].DAMAGE * effect_data.weapon_damage_percent_bonus) end

                if effect_data.attack_percent_bonus ~= nil and effect_data.attack_percent_bonus > 0. then
                    if damage_type == DAMAGE_TYPE_PHYSICAL then
                        damage = damage + attacker.stats[PHYSICAL_ATTACK].value * effect_data.attack_percent_bonus
                    elseif damage_type == DAMAGE_TYPE_MAGICAL then
                        damage = damage + attacker.stats[MAGICAL_ATTACK].value * effect_data.attack_percent_bonus
                    end
                end

        end

       -- print("2")

            if can_crit then
                if GetRandomInt(1, 100) <= GetCriticalChance(source, bonus_critical) then
                    critical_rate = attacker.stats[CRIT_MULTIPLIER].value + bonus_critical_rate
                    attack_status = ATTACK_STATUS_CRITICAL
                    if critical_rate < 1.1 then critical_rate = 1.1 end
                end
            end

        --print("3")
        if victim == nil then

                if attribute ~= nil then
                    attribute_bonus = 1. + (attacker.stats[GetAttributeBonusParam(attribute)].value * 0.01)
                end

                if damage_type == DAMAGE_TYPE_MAGICAL then
                    damage = damage * (1. + (ParamToPercent(attacker.stats[MAGICAL_ATTACK].value, MAGICAL_ATTACK) * 0.01))
                end

            damage = (damage * attribute_bonus) * critical_rate

        else

           -- print("4")
            --print(I2S(attacker.stats[BONUS_BEAST_DAMAGE].value))
            --print(I2S(attacker.stats[BONUS_UNDEAD_DAMAGE].value))
            --print(I2S(attacker.stats[BONUS_HUMAN_DAMAGE].value))
            --print(I2S(attacker.stats[BONUS_DEMON_DAMAGE].value))
            if victim.trait then
                if victim.trait == TRAIT_BEAST then trait_modifier = 1. + (attacker.stats[BONUS_BEAST_DAMAGE].value * 0.01)
                elseif victim.trait == TRAIT_UNDEAD then trait_modifier = 1. + (attacker.stats[BONUS_UNDEAD_DAMAGE].value * 0.01)
                elseif victim.trait == TRAIT_HUMAN then trait_modifier = 1. + (attacker.stats[BONUS_HUMAN_DAMAGE].value * 0.01)
                elseif victim.trait == TRAIT_DEMON then trait_modifier = 1. + (attacker.stats[BONUS_DEMON_DAMAGE].value * 0.01)
                end
            end
           -- print("5")

            if direct and (damage_type  and damage_type == DAMAGE_TYPE_PHYSICAL) and (victim.equip_point[OFFHAND_POINT]  and victim.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND) then
                local block_chance = victim.stats[BLOCK_CHANCE].value

                if block_chance > MAX_BLOCK_CHANCE then block_chance = MAX_BLOCK_CHANCE end

                    if GetRandomInt(1, 100) <= block_chance then
                        attack_status = attack_status == ATTACK_STATUS_CRITICAL and ATTACK_STATUS_CRITICAL_BLOCKED or ATTACK_STATUS_BLOCKED
                        block_reduction = 1. - victim.stats[BLOCK_ABSORB].value * 0.01
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdx", target, "origin"))
                    end

            end
           -- print("6")

            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (ParamToPercent(victim.stats[PHYSICAL_DEFENCE].value, PHYSICAL_DEFENCE) * 0.01)
            elseif damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker.stats[MAGICAL_ATTACK].value - victim.stats[MAGICAL_SUPPRESSION].value
                if boost < 0 then boost = 0 end

                damage = damage * (1. + (ParamToPercent(boost, MAGICAL_ATTACK) * 0.01))
            end
            --print("7")

            if attack_type and direct then
                attack_modifier = attack_type == MELEE_ATTACK and victim.stats[MELEE_DAMAGE_REDUCTION].value or victim.stats[RANGE_DAMAGE_REDUCTION].value
                attack_modifier = 1. - (attack_modifier * 0.01)
                if attack_modifier < MIN_ATTACK_DAMAGE_REDUCTION then attack_modifier = MIN_ATTACK_DAMAGE_REDUCTION end
            end

            --print("8")
            if attribute then
                local attribute_value = attacker.equip_point[WEAPON_POINT].ATTRIBUTE == attribute and attacker.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0

                    attribute_bonus = 1. + (((attacker.stats[GetAttributeBonusParam(attribute)].value + attribute_value) - victim.stats[GetAttributeResistParam(attribute)].value) * 0.01)
                    if attribute_bonus < MIN_ATTRIBUTE_DAMAGE_REDUCTION then attribute_bonus = MIN_ATTRIBUTE_DAMAGE_REDUCTION end

            end
            --print("9")
            damage = ((damage * attribute_bonus * trait_modifier) * critical_rate * block_reduction) * defence * attack_modifier
            --print("10")
        end


        --print("attrib "..attribute_bonus)
        --print("rate "..critical_rate)
        --print("defence "..defence)
        --print("modifier "..attack_modifier)
        --print(TimerGetRemaining(attacker.attack_timer))
        --print("total raw damage "..damage)
        --print("dispersion "..attacker.equip_point[WEAPON_POINT].DISPERSION[1] .. "/" .. attacker.equip_point[WEAPON_POINT].DISPERSION[2])
        --print("11")
        if not (TimerGetRemaining(attacker.attack_timer) > 0.) and direct then

            if attacker.stats[HP_PER_HIT].value > 0 then
                SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + attacker.stats[HP_PER_HIT].value)
                CreateHitnumber(attacker.stats[HP_PER_HIT].value, source, source, HEAL_STATUS)
            end

            if attacker.stats[MP_PER_HIT].value > 0 then
                SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker.stats[MP_PER_HIT].value)
                CreateHitnumber(attacker.stats[MP_PER_HIT].value, source, source, RESOURCE_STATUS)
            end

            TimerStart(attacker.attack_timer, BlzGetUnitAttackCooldown(source, 0) - 0.01, false, nil)
            OnMyAttack(source, target)
        end
            --print("12")
            damage = R2I(GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2]))
           -- print("13")
            if direct and damage > 0 and victim then
                local reflect = 0

                if attack_type then
                     reflect = attack_type == MELEE_ATTACK and victim.stats[REFLECT_MELEE_DAMAGE].value or victim.stats[REFLECT_RANGE_DAMAGE].value
                end


                    reflect = damage * ParamToPercent(reflect, REFLECT_DAMAGE)

                    if reflect >= 1 then
                        UnitDamageTarget(target, source, reflect, false, false, nil, nil, nil)
                        CreateHitnumber(R2I(reflect), source, source, REFLECT_STATUS)
                    end

                if damage_type == DAMAGE_TYPE_PHYSICAL then
                    local damage_effect = AddSpecialEffect("DamageEffect.mdx", GetUnitX(target), GetUnitY(target))

                        BlzSetSpecialEffectYaw(damage_effect, AngleBetweenUnits(target, source) * bj_DEGTORAD)
                        BlzSetSpecialEffectZ(damage_effect, GetUnitZ(target) + 55.)

                    DestroyEffect(damage_effect)
                end

            end
            --print("14")

            if damage >= BlzGetUnitMaxHP(target) * 0.18 and damage >= GetUnitState(target, UNIT_STATE_LIFE) then SetUnitExploded(target, true) end
            --print("15")
            OnDamage_PreHit(source, target, damage)
            if damage < 0 then damage = 0 end
            --print("16")
            UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_NORMAL, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)
            OnDamage_End(source, target, damage)
            --print("17")
            --print(damage)
            CreateHitnumber(damage, source, target, attack_status)
            --print("18")

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
                        ThrowMissile(data.Owner, target, nil, nil, GetUnitX(data.Owner), GetUnitY(data.Owner), GetUnitX(target), GetUnitY(target), 0.)
                    else
                        local actual_damage = 0
                        if data.equip_point[WEAPON_POINT].DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL then actual_damage = data.stats[PHYSICAL_ATTACK].value
                        else actual_damage = data.equip_point[WEAPON_POINT].DAMAGE end


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
                                                DamageUnit(data.Owner, picked, actual_damage, data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, true, nil)
                                            end
                                        end
                                    end

                            GroupClear(enemy_group)
                            DestroyGroup(enemy_group)
                        else
                            DamageUnit(data.Owner, GetTriggerUnit(), actual_damage, data.equip_point[WEAPON_POINT].ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, true, true, true, nil)
                        end

                    end

                    BlzSetEventDamage(0.)
                end

            end)

    end

end