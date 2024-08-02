do

    MAX_CRITICAL = 60.
    MIN_CRITICAL = 0.

    MAX_BLOCK_CHANCE = 60.
    MIN_ATTACK_DAMAGE_REDUCTION = 0.22
    MIN_ATTRIBUTE_DAMAGE_REDUCTION = 0.3

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
    ATTACK_STATUS_MISS = 9
    ATTACK_STATUS_SHIELD = 10

    OrderInterceptionTrigger = 0


    --call AddUnitAnimationProperties(gg_unit_H003_0009, "lumber", true)



    ---@param unit unit
    function UpdateEndurance(unit)
        local source = GetUnitData(unit)
        local endurance_current = 0
        local endurance_max = 0

            for i = 1, #source.endurance_stack do
                if source.endurance_stack[i].current < 0 then source.endurance_stack[i].current = 0 end
                endurance_current = endurance_current + source.endurance_stack[i].current
                endurance_max = endurance_max + source.endurance_stack[i].max
            end

            source.endurance_current = endurance_current
            source.endurance_max = endurance_max


            if endurance_current <= 0 then
                --DestroyEffect(source.endurance_effect)
                --source.endurance_effect = nil
            elseif endurance_current > 0 then
                --source.endurance_effect = AddSpecialEffectTarget("Effect\\Safeguard.mdx", unit, "origin")
                CreateShieldBarOnUnit(unit)
            end

    end

    ---@param unit unit
    ---@param buffid string
    ---@param check_permanency boolean
    function RemoveEndurance(unit, buffid, check_permanency)
        local source = GetUnitData(unit)
        local index = #source.endurance_stack


            for i = 1, index do
                if source.endurance_stack[i].buffid and source.endurance_stack[i].buffid == buffid then
                    if not source.endurance_stack[i].permanent or (check_permanency and source.endurance_stack[i].permanent) then
                        table.remove(source.endurance_stack, i)
                    end
                    break
                end
            end

            UpdateEndurance(unit)

    end


    ---@param unit unit
    ---@param amount integer
    ---@param buffid string
    function AddEndurance(unit, amount, buffid)
        local source = GetUnitData(unit)

            for i = 1, #source.endurance_stack do
                if source.endurance_stack[i].buffid and source.endurance_stack[i].buffid == buffid then
                    source.endurance_stack[i].current = source.endurance_stack[i].current + amount * GetUnitParameterValue(unit, ENDURANCE_POWER)
                    if source.endurance_stack[i].max > source.endurance_stack[i].current then source.endurance_stack[i].current = source.endurance_stack[i].max end
                    break
                end
            end

            UpdateEndurance(unit)

    end


    function SetMaxEndurance(unit, amount, buffid)
        local source = GetUnitData(unit)

            for i = 1, source.endurance_stack do
                if source.endurance_stack[i].buffid and source.endurance_stack[i].buffid == buffid then
                    source.endurance_stack[i].max = amount * GetUnitParameterValue(unit, ENDURANCE_POWER)
                    UpdateEndurance(unit)
                    break
                end
            end

    end

    ---@param unit unit
    ---@param amount integer
    ---@param buffid string
    ---@param permanent boolean
    function AddMaxEnduranceUnit(unit, amount, buffid, permanent)
        local source = GetUnitData(unit)
        local index = #source.endurance_stack+1

           amount = amount * GetUnitParameterValue(unit, ENDURANCE_POWER)

            for i = 1, index-1 do
                if source.endurance_stack[i].buffid and source.endurance_stack[i].buffid == buffid then
                    source.endurance_stack[i].current = amount
                    UpdateEndurance(unit)
                    return
                end
            end

            source.endurance_stack[index] = { current = amount or 1, max = amount or 1, buffid = buffid or nil, permanent = permanent or nil }
            UpdateEndurance(unit)

    end


    ---@param a unit
    ---@param bonus real
    function  GetCriticalChance(a, bonus)
        local source = GetUnitData(a)
        local chance = 0. + math.floor(ParamToPercent(bonus + source.stats[CRIT_CHANCE].value, CRIT_CHANCE))

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
        local attacker_stats = attacker.stats
        local target_stats =  victim.stats

        if attacker == nil then print("Warning: " .. GetUnitName(source) .. " doesn't have unit data.") end
        if victim == nil then print("Warning: " .. GetUnitName(target) .. " doesn't have unit data.") end

            if target == nil then return 0 end

        if GetUnitState(target, UNIT_STATE_LIFE) <= 0.045 then
            return
        end

        if damage_type == DAMAGE_TYPE_PHYSICAL and direct and IsUnitBlinded(source) then
            CreateHitnumber("", source, target, ATTACK_STATUS_MISS)
            AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 115, 1400., 3800.)
            return 0
        else

            if damage_type == DAMAGE_TYPE_PHYSICAL and direct  then

                if victim.attack_status[ATTACK_STATUS_EVADE][1] then
                    victim.attack_status[ATTACK_STATUS_EVADE][1].amount = victim.attack_status[ATTACK_STATUS_EVADE][1].amount - 1
                    if victim.attack_status[ATTACK_STATUS_EVADE][1].amount <= 0 then RemoveBuff(target, victim.attack_status[ATTACK_STATUS_EVADE][1].buff_id) end
                    CreateHitnumber("", source, target, ATTACK_STATUS_MISS)
                    AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 115, 1400., 3800.)
                    OnEvade(source, target)
                    return 0
                elseif target_stats[DODGE_CHANCE].value > 0 then
                    local dodge = target_stats[DODGE_CHANCE].value <= 50 and target_stats[DODGE_CHANCE].value or 50

                    if IsUnitDisabled(target) or IsUnitRooted(target) then
                        dodge = 0.
                    end

                    if Chance(dodge) then
                        CreateHitnumber("", source, target, ATTACK_STATUS_MISS)
                        AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 115, 1400., 3800.)
                        OnEvade(source, target)
                        return 0
                    end
                end

            end

            local crit_overwrite = false
        --print("1")
        if myeffect and myeffect.eff then
            local effect_data = myeffect.eff.level[myeffect.l or 1]

                if effect_data.bonus_crit_chance then bonus_critical = effect_data.bonus_crit_chance end
                if effect_data.bonus_crit_multiplier then bonus_critical_rate = effect_data.bonus_crit_multiplier end
                if effect_data.weapon_damage_percent_bonus then damage = damage + (attacker.equip_point[WEAPON_POINT].DAMAGE * effect_data.weapon_damage_percent_bonus) end

                if effect_data.attack_percent_bonus and effect_data.attack_percent_bonus > 0. then
                    if damage_type == DAMAGE_TYPE_PHYSICAL then
                        damage = damage + attacker_stats[PHYSICAL_ATTACK].value * effect_data.attack_percent_bonus
                    elseif damage_type == DAMAGE_TYPE_MAGICAL then
                        damage = damage + attacker_stats[MAGICAL_ATTACK].value * effect_data.attack_percent_bonus
                    end
                end

                if myeffect.eff.tags then
                    local mod = 1.

                    if HasTag(myeffect.eff.tags, "bleeding") then mod = 1. + (attacker_stats[BLEEDING_DAMAGE_BOOST].value - target_stats[BLEEDING_DAMAGE_REDUCTION].value)
                    elseif HasTag(myeffect.eff.tags, "burning") then mod = 1. + (attacker_stats[BURNING_DAMAGE_BOOST].value - target_stats[BURNING_DAMAGE_REDUCTION].value)
                    elseif HasTag(myeffect.eff.tags, "poisoning") then mod = 1. + (attacker_stats[POISONING_DAMAGE_BOOST].value - target_stats[POISONING_DAMAGE_REDUCTION].value)
                    elseif HasTag(myeffect.eff.tags, "decaying") then mod = 1. + (attacker_stats[DECAYING_DAMAGE_BOOST].value - target_stats[DECAYING_DAMAGE_REDUCTION].value) end

                    if mod < 0.1 then mod = 0.1 end
                    damage = damage * mod
                end

            if myeffect.eff.ability_instance and myeffect.eff.ability_instance.critical_strike_flag then crit_overwrite = true end

        end

        --print("2")

        local damage_table = { damage = damage, bonus_critical = bonus_critical, attribute = attribute or 0, attack_status = attack_status, damage_type = damage_type or nil, attack_type = attack_type or nil, is_direct = direct, effect = myeffect or nil, proc_rate = 1. }

        damage_table = OnDamageStart(source, target, damage_table)

        damage = damage_table.damage
        attribute = damage_table.attribute
        attack_status = damage_table.attack_status
        damage_type = damage_table.damage_type
        attack_type = damage_table.attack_type
        direct = damage_table.is_direct
        myeffect = damage_table.effect
        bonus_critical = damage_table.bonus_critical


            if can_crit then
                if crit_overwrite or GetRandomInt(1, 100) <= GetCriticalChance(source, bonus_critical) then
                    critical_rate = attacker_stats[CRIT_MULTIPLIER].value + bonus_critical_rate
                    attack_status = ATTACK_STATUS_CRITICAL
                    if critical_rate < 1.1 then critical_rate = 1.1 end
                end
            end


        damage = damage * (1. + attacker_stats[DAMAGE_BOOST].value * 0.01) * (1. + target_stats[VULNERABILITY].value * 0.01)

        --print("3")
        if victim == nil then
            local distance_bonus = 1.
            local impaired_bonus = 1.

                if attribute then attribute_bonus = 1. + (attacker_stats[GetAttributeBonusParam(attribute)].value * 0.01) end

                if damage_type == DAMAGE_TYPE_MAGICAL then damage = damage * (1. + (ParamToPercent(attacker_stats[MAGICAL_ATTACK].value, MAGICAL_ATTACK) * 0.01)) end

                if attack_type and direct then
                    local bonus_attack_modifier = attack_type == MELEE_ATTACK and attacker_stats[BONUS_MELEE_DAMAGE].value or attacker_stats[BONUS_RANGE_DAMAGE].value

                        attack_modifier = 1. + (bonus_attack_modifier * 0.01)

                end

                if IsUnitInRange(source, target, 250.) then distance_bonus = distance_bonus + (attacker_stats[DAMAGE_TO_CLOSE_ENEMIES].value * 0.01)
                else distance_bonus = distance_bonus + (attacker_stats[DAMAGE_TO_DISTANT_ENEMIES].value * 0.01) end

                if IsUnitDisabled(target) or IsUnitRooted(target) then impaired_bonus = impaired_bonus + (attacker_stats[DAMAGE_TO_CC_ENEMIES].value * 0.01) end

            damage = (((damage * attribute_bonus) * critical_rate) * attack_modifier) * distance_bonus * impaired_bonus

        else

            --print("4")
            if victim.unit_trait then
                local traits = victim.unit_trait
                for i = 1, #traits do
                    if traits[i] == TRAIT_BEAST then trait_modifier = trait_modifier + (attacker_stats[BONUS_BEAST_DAMAGE].value * 0.01)
                    elseif traits[i] == TRAIT_UNDEAD then trait_modifier = trait_modifier + (attacker_stats[BONUS_UNDEAD_DAMAGE].value * 0.01)
                    elseif traits[i] == TRAIT_HUMAN then trait_modifier = trait_modifier + (attacker_stats[BONUS_HUMAN_DAMAGE].value * 0.01)
                    elseif traits[i] == TRAIT_DEMON then trait_modifier = trait_modifier + (attacker_stats[BONUS_DEMON_DAMAGE].value * 0.01) end
                end
            end
            --print("5")

            if direct and (damage_type  and damage_type == DAMAGE_TYPE_PHYSICAL) and (victim.equip_point[OFFHAND_POINT] and victim.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND) then
                local block_chance = target_stats[BLOCK_CHANCE].value

                    if block_chance > MAX_BLOCK_CHANCE then block_chance = MAX_BLOCK_CHANCE end

                    if IsUnitDisabled(target) then
                        block_chance = 0
                    end

                    if victim.attack_status[ATTACK_STATUS_BLOCKED][1] then
                        block_chance = 127.
                        victim.attack_status[ATTACK_STATUS_BLOCKED][1].amount = victim.attack_status[ATTACK_STATUS_BLOCKED][1].amount - 1
                        if victim.attack_status[ATTACK_STATUS_BLOCKED][1].amount <= 0 then RemoveBuff(target, victim.attack_status[ATTACK_STATUS_BLOCKED][1].buff_id) end
                    end

                    if GetRandomInt(1, 100) <= block_chance then
                        attack_status = attack_status == ATTACK_STATUS_CRITICAL and ATTACK_STATUS_CRITICAL_BLOCKED or ATTACK_STATUS_BLOCKED
                        block_reduction = 1. - target_stats[BLOCK_ABSORB].value * 0.01
                        if block_reduction > 0.8 then block_reduction = 0.8 end
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdx", target, "origin"))
                    end

            end
            --print("6")

            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (ParamToPercent(target_stats[PHYSICAL_DEFENCE].value, PHYSICAL_DEFENCE) * 0.01)
                if defence < 0.25 then defence = 0.25 end
            elseif damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker_stats[MAGICAL_ATTACK].value - target_stats[MAGICAL_SUPPRESSION].value

                if boost < 0 then
                    boost = boost / 5.
                    if boost < -200. then boost = -200. end
                end

                damage = damage * (1. + (ParamToPercent(boost, MAGICAL_ATTACK) * 0.01))
                if damage < 1 then damage = 1 end
            end

            --print("7")

            if attack_type and direct then
                local bonus_attack_modifier = attack_type == MELEE_ATTACK and attacker_stats[BONUS_MELEE_DAMAGE].value or attacker_stats[BONUS_RANGE_DAMAGE].value

                    attack_modifier = attack_type == MELEE_ATTACK and target_stats[MELEE_DAMAGE_REDUCTION].value or target_stats[RANGE_DAMAGE_REDUCTION].value
                    attack_modifier = 1. - (ParamToPercent(attack_modifier - bonus_attack_modifier, MELEE_DAMAGE_REDUCTION) * 0.01)

                if attack_modifier < MIN_ATTACK_DAMAGE_REDUCTION then attack_modifier = MIN_ATTACK_DAMAGE_REDUCTION end
            end
--print("8")

            local distance_bonus = 1.

                if IsUnitInRange(source, target, 250.) then distance_bonus = distance_bonus + (attacker_stats[DAMAGE_TO_CLOSE_ENEMIES].value * 0.01)
                else distance_bonus = distance_bonus + (attacker_stats[DAMAGE_TO_DISTANT_ENEMIES].value * 0.01) end


            local impaired_bonus = 1.
            if IsUnitDisabled(target) or IsUnitRooted(target) or IsUnitSlowed(target) then impaired_bonus = impaired_bonus + (attacker_stats[DAMAGE_TO_CC_ENEMIES].value * 0.01) end

            if attribute then
                local attribute_value = attacker.equip_point[WEAPON_POINT].ATTRIBUTE == attribute and attacker.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0

                    if myeffect and myeffect.eff and myeffect.eff.level[myeffect.l].attribute == attribute and (myeffect.eff.level[myeffect.l].attribute_bonus and myeffect.eff.level[myeffect.l].attribute_bonus > 0) then
                        attribute_value = attribute_value + myeffect.eff.level[myeffect.l].attribute_bonus
                    end

                    attribute_bonus = 1. + (((attacker_stats[GetAttributeBonusParam(attribute)].value + attribute_value + (damage_table.attribute_bonus or 0)) - target_stats[GetAttributeResistParam(attribute)].value) * 0.01)
                    if attribute_bonus < MIN_ATTRIBUTE_DAMAGE_REDUCTION then attribute_bonus = MIN_ATTRIBUTE_DAMAGE_REDUCTION end

            end

            damage = ((damage * attribute_bonus * trait_modifier) * critical_rate * block_reduction) * defence * attack_modifier * distance_bonus * impaired_bonus
        end

        damage = math.floor(GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2]))

            damage_table.damage = damage
            damage_table.attribute = attribute
            damage_table.attack_status = attack_status
            damage_table.damage_type = damage_type
            damage_table.attack_type = attack_type
            damage_table.is_direct = direct
            damage_table.effect = myeffect


        if direct then

            if myeffect and myeffect.eff then
                local ability_instance = myeffect.eff.ability_instance or { is_attack = false }
                local is_attack = ability_instance and ability_instance.is_attack or false
                local id = myeffect.eff.id

                    damage_table.proc_rate = ability_instance.proc_rate or 1.

                    if not attacker.attack_instances[id] then
                        attacker.attack_instances[id] = true
                        ability_instance.is_attack = true
                        if attacker_stats[HP_PER_HIT].value > 0 then
                            local amount = math.floor(attacker_stats[HP_PER_HIT].value * (1. + GetUnitParameterValue(source, HEALING_BONUS) * 0.01) + 0.5)
                            if amount < 0 then amount = 0 end
                            SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + amount)
                            CreateHitnumber(amount, source, source, HEAL_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", source, "chest"))
                        end

                        if attacker_stats[MP_PER_HIT].value > 0 then
                            local amount = math.floor(attacker_stats[MP_PER_HIT].value * (1. + GetUnitParameterValue(source, RESOURCE_GENERATION) * 0.01) + 0.5)
                            if amount < 0 then amount = 0 end
                            SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + amount)
                            CreateHitnumber(amount, source, source, RESOURCE_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", source,"chest"))
                        end

                        local attack_cooldown = BlzGetUnitAttackCooldown(source, 0) - 0.01
                        if myeffect.eff.level[myeffect.l].attack_cooldown then attack_cooldown = (myeffect.eff.level[myeffect.l].attack_cooldown * (1. - attacker_stats[ATTACK_SPEED].value / 100.)) - 0.01 end
                        TimerStart(attacker.attack_timer, attack_cooldown, false, function()
                            attacker.proc_list = nil
                            attacker.proc_list = { }
                        end)

                        local timer = CreateTimer()
                        ability_instance.attack_timer = timer
                        TimerStart(timer, attack_cooldown, false, function()
                            attacker.attack_instances[id] = nil
                            ability_instance.proc_list = nil
                            ability_instance.proc_list = {}
                            ability_instance.is_attack = false
                            DestroyTimer(timer)
                        end)
                        damage_table.proc_list = ability_instance.proc_list
                        damage_table = OnMyAttack(source, target, damage_table)
                        damage = damage_table.damage
                        attribute = damage_table.attribute
                        attack_status = damage_table.attack_status
                        damage_type = damage_table.damage_type
                        attack_type = damage_table.attack_type
                        direct = damage_table.is_direct
                        myeffect = damage_table.effect
                    elseif is_attack then
                        damage_table.proc_list = ability_instance.proc_list
                        damage_table = OnMyAttack(source, target, damage_table)
                        damage = damage_table.damage
                        attribute = damage_table.attribute
                        attack_status = damage_table.attack_status
                        damage_type = damage_table.damage_type
                        attack_type = damage_table.attack_type
                        direct = damage_table.is_direct
                        myeffect = damage_table.effect
                    end
            else
                if not (TimerGetRemaining(attacker.attack_timer) > 0.) then

                    if attacker_stats[HP_PER_HIT].value > 0 then
                        local amount = math.floor(attacker_stats[HP_PER_HIT].value * (1. + GetUnitParameterValue(source, HEALING_BONUS) * 0.01) + 0.5)
                        if amount < 0 then amount = 0 end
                        SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + amount)
                        CreateHitnumber(amount, source, source, HEAL_STATUS)
                        DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", source, "chest"))
                    end
                    if attacker_stats[MP_PER_HIT].value > 0 then
                        SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker_stats[MP_PER_HIT].value)
                        CreateHitnumber(R2I(attacker_stats[MP_PER_HIT].value), source, source, RESOURCE_STATUS)
                        DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", source,"chest"))
                    end
                    local attack_cooldown = BlzGetUnitAttackCooldown(source, 0) - 0.01

                    TimerStart(attacker.attack_timer, attack_cooldown, false, function()
                        attacker.proc_list = nil
                        attacker.proc_list = { }
                    end)

                    if not attacker.proc_list then attacker.proc_list = {} end
                    damage_table.proc_list = attacker.proc_list
                    damage_table = OnMyAttack(source, target, damage_table)
                    damage = damage_table.damage
                    attribute = damage_table.attribute
                    attack_status = damage_table.attack_status
                    damage_type = damage_table.damage_type
                    attack_type = damage_table.attack_type
                    direct = damage_table.is_direct
                    myeffect = damage_table.effect
                end
            end

        end


            if damage < 1 then damage = 1 end

            if victim.endurance_stack[1] then

                local expected_barrier_damage = math.floor(damage * GetUnitParameterValue(source, DAMAGE_TO_ENDURANCE) + 0.5)
                local total_blocked = damage

                    for i = 1, #victim.endurance_stack do

                        if victim.endurance_stack[i].current >= 0 then
                            if victim.endurance_stack[i].current >= expected_barrier_damage then
                                victim.endurance_stack[i].current = victim.endurance_stack[i].current - expected_barrier_damage
                                damage = 0
                                break
                            else
                                damage = (expected_barrier_damage - victim.endurance_stack[i].current) - (expected_barrier_damage - damage)
                                victim.endurance_stack[i].current = 0
                            end
                        end

                    end


                    for k, v in ipairs(victim.endurance_stack) do
                        if victim.endurance_stack[k].current <= 0 then
                            RemoveBuff(target, victim.endurance_stack[k].buffid)
                            RemoveEndurance(target, victim.endurance_stack[k].buffid, false)
                        end
                    end


                total_blocked = total_blocked - damage
                if total_blocked > 0 then

                    if direct then
                        local offset = BlzGetUnitCollisionSize(target) * (BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE) * 1.1)
                        local angle = AngleBetweenUnits(target, source)
                        local effect = AddSpecialEffect("Effect\\Shield.mdx", GetUnitX(target) + Rx(offset, angle), GetUnitY(target) + Ry(offset, angle))

                            BlzSetSpecialEffectColor(effect, 255, 100, 0)
                            BlzSetSpecialEffectZ(effect, GetUnitFlyHeight(target) + BlzGetUnitZ(target))
                            BlzSetSpecialEffectYaw(effect, angle * bj_DEGTORAD)
                            DestroyEffect(effect)
                            AddSoundVolume("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav", GetUnitX(target), GetUnitY(target), 100, 1900., 4000.)
                    end

                        UpdateEndurance(target)
                        CreateHitnumberSpecial(total_blocked, source, target, attribute, ATTACK_STATUS_SHIELD)
                        --CreateHitnumber(total_blocked, source, target, ATTACK_STATUS_SHIELD)

                end

            end


            if direct and damage > 0 and victim then
                local reflect = 0

                if attack_type then
                     reflect = attack_type == MELEE_ATTACK and target_stats[REFLECT_MELEE_DAMAGE].value or target_stats[REFLECT_RANGE_DAMAGE].value

                    if reflect > 0 then
                        reflect = damage * (ParamToPercent(reflect, REFLECT_DAMAGE) * 0.01)
                            if reflect >= 1 then
                                local reflect_effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAuraDamage.mdx", source,"origin")
                                DelayAction(0.534, function() DestroyEffect(reflect_effect) end)
                                UnitDamageTarget(target, source, reflect, false, false, nil, nil, nil)
                                CreateHitnumber(R2I(reflect), source, source, REFLECT_STATUS)
                            end
                    end

                end


                if damage_type == DAMAGE_TYPE_PHYSICAL then
                    local damage_effect = AddSpecialEffect("DamageEffect.mdx", GetUnitX(target), GetUnitY(target))
                        BlzSetSpecialEffectOrientation(damage_effect, AngleBetweenUnits(target, source) * bj_DEGTORAD, 0., 0.)
                        BlzSetSpecialEffectZ(damage_effect, GetUnitZ(target) + 55.)
                        DestroyEffect(damage_effect)
                elseif not myeffect or not myeffect.eff then
                    if attribute == FIRE_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdx", target, "chest"))
                    elseif attribute == ICE_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIob\\AIobSpecialArt.mdx", target, "chest"))
                    elseif attribute == LIGHTNING_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIlb\\AIlbSpecialArt.mdx", target, "chest"))
                    elseif attribute == ARCANE_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdx", target, "chest"))
                    elseif attribute == POISON_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\OrbVenom\\OrbVenomSpecialArt.mdx", target, "chest"))
                    elseif attribute == HOLY_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdx", target, "chest"))
                    elseif attribute == DARKNESS_ATTRIBUTE then
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayDamage.mdx", target, "chest"))
                    end
                end

            end

                if damage >= BlzGetUnitMaxHP(target) * 0.16 and damage >= GetUnitState(target, UNIT_STATE_LIFE) and not IsAHero(target) then
                    SetUnitExploded(target, true)
                    victim.death_x = GetUnitX(target)
                    victim.death_y = GetUnitY(target)
                    victim.death_z = GetUnitZ(target)
                    victim.exploded = true
                    --SafePauseUnit(target, false)

                        if attribute == ICE_ATTRIBUTE then
                            local effect = AddSpecialEffect("Effect\\Ice Cracks.mdx", victim.death_x, victim.death_y)
                            BlzSetSpecialEffectScale(effect, 0.9 * BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE))
                            BlzSetSpecialEffectYaw(effect, GetRandomReal(0., 360.) * bj_DEGTORAD)
                            DestroyEffect(effect)
                            AddSoundVolume("Sound\\shatter".. GetRandomInt(1,3) .. ".wav", victim.death_x, victim.death_y, 120, 1500., 4000.)
                        elseif attribute == LIGHTNING_ATTRIBUTE then
                            local effect = AddSpecialEffect("Effect\\shandian-wave-xiao.mdx", victim.death_x, victim.death_y)
                            BlzSetSpecialEffectScale(effect, 0.9 * BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE))
                            BlzSetSpecialEffectYaw(effect, GetRandomReal(0., 360.) * bj_DEGTORAD)
                            BlzSetSpecialEffectZ(effect, GetZ(victim.death_x, victim.death_y) + 65. + GetUnitFlyHeight(target))
                            DestroyEffect(effect)
                        elseif attribute == FIRE_ATTRIBUTE then
                            local effect = AddSpecialEffect("Effect\\by_wood_effect_yuzhiboyou_fire_fengxianhuo_2.mdx", victim.death_x, victim.death_y)
                            BlzSetSpecialEffectScale(effect, 0.9 * BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE))
                            BlzSetSpecialEffectYaw(effect, GetRandomReal(0., 360.) * bj_DEGTORAD)
                            BlzSetSpecialEffectZ(effect, GetZ(victim.death_x, victim.death_y) + 75. + GetUnitFlyHeight(target))
                            DestroyEffect(effect)
                        elseif attribute == POISON_ATTRIBUTE then
                            local effect = AddSpecialEffect("Effect\\plaguebomb_bigger_002.mdx", victim.death_x, victim.death_y)
                            BlzSetSpecialEffectScale(effect, 1. * BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE))
                            BlzSetSpecialEffectYaw(effect, GetRandomReal(0., 360.) * bj_DEGTORAD)
                            BlzSetSpecialEffectZ(effect, GetZ(victim.death_x, victim.death_y) + 35. + GetUnitFlyHeight(target))
                            DestroyEffect(effect)
                        end

                end


                damage_table.damage = damage
                OnDamage_PreHit(source, target, damage, damage_table)
                damage = damage_table.damage

                if damage > 0  then

                    UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_NORMAL, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)
                    OnDamage_End(source, target, damage, damage_table)

                        if myeffect and myeffect.eff and myeffect.eff.stack_hitnumbers then
                            CreateHitnumberSpecialStacked(damage, source, target, myeffect.eff.id, attribute, attack_status)
                            --CreateHitnumber2(damage, source, target, attack_status, myeffect and myeffect.eff.id or nil)
                        else
                            CreateHitnumberSpecial(damage, source, target, attribute, attack_status)
                            --CreateHitnumber(damage, source, target, attack_status)
                        end

                end

            damage_table = nil
        end



        return damage
    end



    function MainEngineInit()
        local trg = CreateTrigger()

            TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DAMAGED)
            TriggerAddAction(trg, function()

                if BlzGetEventAttackType() == ATTACK_TYPE_MELEE and GetEventDamage() > 0. and GetUnitData(GetEventDamageSource()) then
                    local data = GetUnitData(GetEventDamageSource())
                    local target =  GetTriggerUnit()
                    local weapon = data.equip_point[WEAPON_POINT]


                    if data.on_attack_sound then
                        if Chance(data.on_attack_sound.chance or 100.) then
                            AddSoundVolume(data.on_attack_sound.pack[GetRandomInt(1, #data.on_attack_sound.pack)], GetUnitX(data.Owner), GetUnitY(data.Owner), data.on_attack_sound.volume, data.on_attack_sound.cutoff, data.on_attack_sound.distance or 4000.)
                        end
                    end

                    if weapon.sound and weapon.sound.pack then
                        AddSoundVolume(weapon.sound.pack[GetRandomInt(1, #weapon.sound.pack)], GetUnitX(data.Owner), GetUnitY(data.Owner), weapon.sound.volume, weapon.sound.cutoff or 1600., weapon.sound.distance or 4000.)
                    end

                    if weapon.missile or weapon.ranged then

                        if weapon.LIGHTNING then
                            local actual_damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or weapon.DAMAGE

                            LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, weapon.LIGHTNING.bonus_z or 60., 60., weapon.LIGHTNING.range, weapon.LIGHTNING.angle)
                            DamageUnit(data.Owner, GetTriggerUnit(), actual_damage, weapon.ATTRIBUTE, weapon.DAMAGE_TYPE, RANGE_ATTACK, true, true, false, nil)
                        else

                            if weapon.angle_deviation then
                                ThrowMissile(data.Owner, nil, nil, nil, GetUnitX(data.Owner), GetUnitY(data.Owner), 0, 0, AngleBetweenUnits(data.Owner, target) + GetRandomReal(-weapon.angle_deviation, weapon.angle_deviation), true)
                            else
                                ThrowMissile(data.Owner, target, nil, nil, GetUnitX(data.Owner), GetUnitY(data.Owner), GetUnitX(target), GetUnitY(target), 0., true)
                            end

                        end

                        OnAttackStart(data.Owner, target, { damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or weapon.DAMAGE, damage_type = weapon.DAMAGE_TYPE, attack_type = RANGE_ATTACK, attribute = weapon.ATTRIBUTE })
                    elseif IsUnitInRange(GetEventDamageSource(), GetTriggerUnit(), weapon.RANGE + 125.) then
                        local actual_damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or (weapon.DAMAGE or 0)
                        local attack_data = { damage = actual_damage, damage_type = weapon.DAMAGE_TYPE, attack_type = MELEE_ATTACK, attribute = weapon.ATTRIBUTE, max_targets = weapon.MAX_TARGETS, attack_wide_angle = weapon.ANGLE or 60. }

                        OnAttackStart(data.Owner, target, attack_data)

                            if attack_data.max_targets > 1 then
                                local attack_effect = { regular_attack = true }
                                local enemy_group = CreateGroup()
                                local facing = AngleBetweenUnits(data.Owner, target) * bj_DEGTORAD
                                local player = GetOwningPlayer(data.Owner)

                                    if GetRandomInt(1, 100) <= GetCriticalChance(data.Owner, 0.) then attack_effect.critical_strike_flag = true end
                                    GroupEnumUnitsInRange(enemy_group, GetUnitX(target), GetUnitY(target), weapon.RANGE + (weapon.RANGE / 4), nil)
                                    if weapon.LIGHTNING then LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.) end
                                    DamageUnit(data.Owner, target, attack_data.damage, attack_data.attribute, attack_data.damage_type, MELEE_ATTACK, true, true, true, attack_effect)

                                        for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                            local picked = BlzGroupUnitAt(enemy_group, index)
                                            if picked ~= target and IsUnitEnemy(picked, player) and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                                if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and IsAngleInFace(data.Owner, attack_data.attack_wide_angle, GetUnitX(picked), GetUnitY(picked), false) then
                                                    if weapon.LIGHTNING then
                                                        LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.)
                                                    end
                                                    DamageUnit(data.Owner, picked, attack_data.damage, attack_data.attribute, attack_data.damage_type, MELEE_ATTACK, true, true, true, attack_effect)
                                                end
                                            end
                                        end

                                GroupClear(enemy_group)
                                DestroyGroup(enemy_group)
                            else
                                if weapon.LIGHTNING then LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.) end
                                DamageUnit(data.Owner, target, attack_data.damage, attack_data.attribute, attack_data.damage_type, MELEE_ATTACK, true, true, true, nil)
                            end

                    end

                    BlzSetEventDamage(0.)
                end

            end)


        OrderInterceptionTrigger = CreateTrigger()


        TriggerAddAction(OrderInterceptionTrigger, function()
            if IsUnitAlly(GetTriggerUnit(), Player(8)) and IsAHero(GetAttacker()) then
                BlzUnitInterruptAttack(GetAttacker())
                --DelayAction(0., function() IssueImmediateOrderById(GetAttacker(), order_stop) end)
            end
        end)

        BuffsInit()

    end


end