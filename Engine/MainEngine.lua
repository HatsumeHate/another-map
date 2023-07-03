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
                    source.endurance_stack[i].current = source.endurance_stack[i].current + amount
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
                    source.endurance_stack[i].max = amount
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

        if attacker == nil then print("Warning: " .. GetUnitName(source) .. " doesn't have unit data.") end
        if victim == nil then print("Warning: " .. GetUnitName(target) .. " doesn't have unit data.") end
        --if source == nil then print("DAMAGE - SOURCE NULL") end

            if target == nil then return 0 end

        if GetUnitState(target, UNIT_STATE_LIFE) <= 0.045 then
            return
        end

        if damage_type == DAMAGE_TYPE_PHYSICAL and direct and IsUnitBlinded(source) then
            CreateHitnumber("", source, target, ATTACK_STATUS_MISS)
            AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 115, 1400.)
        else

            if damage_type == DAMAGE_TYPE_PHYSICAL and direct and victim.stats[DODGE_CHANCE].value > 0 then
                local dodge = victim.stats[DODGE_CHANCE].value <= 50 and victim.stats[DODGE_CHANCE].value or 50

                    if IsUnitDisabled(target) or IsUnitRooted(target) then
                        dodge = 0.
                    end

                    if Chance(dodge) then
                        CreateHitnumber("", source, target, ATTACK_STATUS_MISS)
                        AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 115, 1400.)
                        return 0
                    end

            end

            local crit_overwrite
        --print("1")
        if myeffect and myeffect.eff then
            local effect_data = myeffect.eff.level[myeffect.l or 1]

                if effect_data.bonus_crit_chance then bonus_critical = effect_data.bonus_crit_chance end
                if effect_data.bonus_crit_multiplier then bonus_critical_rate = effect_data.bonus_crit_multiplier end
                if effect_data.weapon_damage_percent_bonus then damage = damage + (attacker.equip_point[WEAPON_POINT].DAMAGE * effect_data.weapon_damage_percent_bonus) end

                if effect_data.attack_percent_bonus and effect_data.attack_percent_bonus > 0. then
                    if damage_type == DAMAGE_TYPE_PHYSICAL then
                        damage = damage + attacker.stats[PHYSICAL_ATTACK].value * effect_data.attack_percent_bonus
                    elseif damage_type == DAMAGE_TYPE_MAGICAL then
                        damage = damage + attacker.stats[MAGICAL_ATTACK].value * effect_data.attack_percent_bonus
                    end
                end

        end

            if myeffect and myeffect.critical_strike_flag then crit_overwrite = true end

        --print("2")

        local damage_table = { damage = damage, bonus_critical = bonus_critical, attribute = attribute or 0, attack_status = attack_status, damage_type = damage_type or nil, attack_type = attack_type or nil, is_direct = direct, effect = myeffect or nil }

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
                    critical_rate = attacker.stats[CRIT_MULTIPLIER].value + bonus_critical_rate
                    attack_status = ATTACK_STATUS_CRITICAL
                    if critical_rate < 1.1 then critical_rate = 1.1 end
                end
            end


        damage = damage * (1. + attacker.stats[DAMAGE_BOOST].value * 0.01) * (1. + victim.stats[VULNERABILITY].value * 0.01)

        --print("3")
        if victim == nil then
            local distance_bonus = 1.
            local impaired_bonus = 1.

                if attribute then attribute_bonus = 1. + (attacker.stats[GetAttributeBonusParam(attribute)].value * 0.01) end

                if damage_type == DAMAGE_TYPE_MAGICAL then damage = damage * (1. + (ParamToPercent(attacker.stats[MAGICAL_ATTACK].value, MAGICAL_ATTACK) * 0.01)) end

                if attack_type and direct then
                    local bonus_attack_modifier = attack_type == MELEE_ATTACK and attacker.stats[BONUS_MELEE_DAMAGE].value or attacker.stats[BONUS_RANGE_DAMAGE].value

                        attack_modifier = 1. - (bonus_attack_modifier * 0.01)

                end

                if IsUnitInRange(source, target, 250.) then distance_bonus = distance_bonus + (attacker.stats[DAMAGE_TO_CLOSE_ENEMIES].value * 0.01)
                else distance_bonus = distance_bonus + (attacker.stats[DAMAGE_TO_DISTANT_ENEMIES].value * 0.01) end

                if IsUnitDisabled(target) then impaired_bonus = impaired_bonus + (attacker.stats[DAMAGE_TO_CC_ENEMIES].value * 0.01) end

            damage = (((damage * attribute_bonus) * critical_rate) * attack_modifier) * distance_bonus * impaired_bonus

        else

            --print("4")
            if victim.unit_trait then
                for i = 1, #victim.unit_trait do
                    if victim.unit_trait[i] == TRAIT_BEAST then trait_modifier = trait_modifier + (attacker.stats[BONUS_BEAST_DAMAGE].value * 0.01)
                    elseif victim.unit_trait[i] == TRAIT_UNDEAD then trait_modifier = trait_modifier + (attacker.stats[BONUS_UNDEAD_DAMAGE].value * 0.01)
                    elseif victim.unit_trait[i] == TRAIT_HUMAN then trait_modifier = trait_modifier + (attacker.stats[BONUS_HUMAN_DAMAGE].value * 0.01)
                    elseif victim.unit_trait[i] == TRAIT_DEMON then trait_modifier = trait_modifier + (attacker.stats[BONUS_DEMON_DAMAGE].value * 0.01) end
                end
            end
            --print("5")

            if direct and (damage_type  and damage_type == DAMAGE_TYPE_PHYSICAL) and (victim.equip_point[OFFHAND_POINT] and victim.equip_point[OFFHAND_POINT].SUBTYPE == SHIELD_OFFHAND) then
                local block_chance = victim.stats[BLOCK_CHANCE].value

                    if block_chance > MAX_BLOCK_CHANCE then block_chance = MAX_BLOCK_CHANCE end

                    if IsUnitDisabled(target) then
                        block_chance = 0
                    end

                    if GetRandomInt(1, 100) <= block_chance then
                        attack_status = attack_status == ATTACK_STATUS_CRITICAL and ATTACK_STATUS_CRITICAL_BLOCKED or ATTACK_STATUS_BLOCKED
                        block_reduction = 1. - victim.stats[BLOCK_ABSORB].value * 0.01
                        if block_reduction > 0.8 then block_reduction = 0.8 end
                        DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdx", target, "origin"))
                    end

            end
            --print("6")

            if damage_type == DAMAGE_TYPE_PHYSICAL then
                defence = 1. - (ParamToPercent(victim.stats[PHYSICAL_DEFENCE].value, PHYSICAL_DEFENCE) * 0.01)
                if defence < 0.25 then defence = 0.25 end
            elseif damage_type == DAMAGE_TYPE_MAGICAL then
                local boost = attacker.stats[MAGICAL_ATTACK].value - victim.stats[MAGICAL_SUPPRESSION].value

                if boost > 0 then
                    boost = ParamToPercent(boost, MAGICAL_ATTACK)
                else
                    boost = boost / 5.
                    if boost < -200. then boost = -200. end
                end

                --if boost < 0 then boost = 0 end

                damage = damage * (1. + (ParamToPercent(boost, MAGICAL_ATTACK) * 0.01))
            end
            --print("7")

            if attack_type and direct then
                local bonus_attack_modifier = attack_type == MELEE_ATTACK and attacker.stats[BONUS_MELEE_DAMAGE].value or attacker.stats[BONUS_RANGE_DAMAGE].value

                    attack_modifier = attack_type == MELEE_ATTACK and victim.stats[MELEE_DAMAGE_REDUCTION].value or victim.stats[RANGE_DAMAGE_REDUCTION].value
                    attack_modifier = 1. - ((attack_modifier - bonus_attack_modifier) * 0.01)

                if attack_modifier < MIN_ATTACK_DAMAGE_REDUCTION then attack_modifier = MIN_ATTACK_DAMAGE_REDUCTION end
            end


            local distance_bonus = 1.

                if IsUnitInRange(source, target, 250.) then distance_bonus = distance_bonus + (attacker.stats[DAMAGE_TO_CLOSE_ENEMIES].value * 0.01)
                else distance_bonus = distance_bonus + (attacker.stats[DAMAGE_TO_DISTANT_ENEMIES].value * 0.01) end


            local impaired_bonus = 1.
            if IsUnitDisabled(target) then impaired_bonus = impaired_bonus + (attacker.stats[DAMAGE_TO_CC_ENEMIES].value * 0.01) end

            --print("8")
            if attribute then
                local attribute_value = attacker.equip_point[WEAPON_POINT].ATTRIBUTE == attribute and attacker.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0

                    if myeffect and myeffect.eff and myeffect.eff.level[myeffect.l].attribute == attribute and (myeffect.eff.level[myeffect.l].attribute_bonus and myeffect.eff.level[myeffect.l].attribute_bonus > 0) then
                        attribute_value = attribute_value + myeffect.eff.level[myeffect.l].attribute_bonus
                    end

                    attribute_bonus = 1. + (((attacker.stats[GetAttributeBonusParam(attribute)].value + attribute_value) - victim.stats[GetAttributeResistParam(attribute)].value) * 0.01)
                    if attribute_bonus < MIN_ATTRIBUTE_DAMAGE_REDUCTION then attribute_bonus = MIN_ATTRIBUTE_DAMAGE_REDUCTION end

            end
            --print("9")
            damage = ((damage * attribute_bonus * trait_modifier) * critical_rate * block_reduction) * defence * attack_modifier * distance_bonus * impaired_bonus
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

        damage = R2I(GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2]))


        --damage_table = { damage = damage, attribute = attribute, attack_status = attack_status, damage_type = damage_type, attack_type = attack_type, is_direct = direct, effect = myeffect }
        damage_table.damage = damage
        damage_table.attribute = attribute
        damage_table.attack_status = attack_status
        damage_table.damage_type = damage_type
        damage_table.attack_type = attack_type
        damage_table.is_direct = direct
        damage_table.effect = myeffect

           -- myeffect.eff.single_attack_instance

        if direct then

            if myeffect and myeffect.eff then
                local ability_instance = myeffect.eff.ability_instance or nil
                local is_attack = ability_instance and ability_instance.is_attack or false
                --print("effect")

                    if not attacker.attack_instances[myeffect.eff.id] then
                        --print("effect attack not in cd")

                        attacker.attack_instances[myeffect.eff.id] = true
                        ability_instance.is_attack = true
                        --if myeffect.eff.single_attack_instance then  end

                        if attacker.stats[HP_PER_HIT].value > 0 then
                            SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + attacker.stats[HP_PER_HIT].value)
                            CreateHitnumber(R2I(attacker.stats[HP_PER_HIT].value), source, source, HEAL_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", source, "chest"))
                        end

                        if attacker.stats[MP_PER_HIT].value > 0 then
                            SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker.stats[MP_PER_HIT].value)
                            CreateHitnumber(R2I(attacker.stats[MP_PER_HIT].value), source, source, RESOURCE_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", source,"chest"))
                        end

                        local attack_cooldown = BlzGetUnitAttackCooldown(source, 0) - 0.01
                        if myeffect.eff.level[myeffect.l].attack_cooldown then attack_cooldown = (myeffect.eff.level[myeffect.l].attack_cooldown * (1. - attacker.stats[ATTACK_SPEED].value / 100.)) - 0.01 end

                        TimerStart(attacker.attack_timer, attack_cooldown, false, function()
                            attacker.proc_list = nil
                            attacker.proc_list = { }
                        end)

                        local id = myeffect.eff.id

                        local timer = CreateTimer()
                        ability_instance.attack_timer = timer
                        TimerStart(timer, attack_cooldown, false, function()
                            attacker.attack_instances[id] = nil
                            ability_instance.proc_list = nil
                            ability_instance.proc_list = {}
                            ability_instance.is_attack = false
                            DestroyTimer(timer)
                        end)

                        --print("launch effect attack cd")

                        damage_table.proc_list = ability_instance.proc_list
                        damage_table = OnMyAttack(source, target, damage_table)
                        damage = damage_table.damage
                        attribute = damage_table.attribute
                        attack_status = damage_table.attack_status
                        damage_type = damage_table.damage_type
                        attack_type = damage_table.attack_type
                        direct = damage_table.is_direct
                        myeffect = damage_table.effect
                       -- print("main attack done")
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
                        --print("is attack done")
                    end

            else
                if not (TimerGetRemaining(attacker.attack_timer) > 0.) then

                    if attacker.stats[HP_PER_HIT].value > 0 then
                        SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + attacker.stats[HP_PER_HIT].value)
                        CreateHitnumber(R2I(attacker.stats[HP_PER_HIT].value), source, source, HEAL_STATUS)
                        DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", source, "chest"))
                    end

                    if attacker.stats[MP_PER_HIT].value > 0 then
                        SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker.stats[MP_PER_HIT].value)
                        CreateHitnumber(R2I(attacker.stats[MP_PER_HIT].value), source, source, RESOURCE_STATUS)
                        DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", source,"chest"))
                    end

                    local attack_cooldown = BlzGetUnitAttackCooldown(source, 0) - 0.01

                    TimerStart(attacker.attack_timer, attack_cooldown, false, function()
                        attacker.proc_list = nil
                        attacker.proc_list = { }
                    end)

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


        if HasAnyDisableState(source) then
            return 0
        end

            if damage < 1 then damage = 1 end

            if victim.endurance_stack[1] then
                --print("has shield")
                local total_blocked = damage

                    for i = 1, #victim.endurance_stack do

                        if victim.endurance_stack[i].current >= 0 then
                            if victim.endurance_stack[i].current >= damage then
                                victim.endurance_stack[i].current = victim.endurance_stack[i].current - damage
                                damage = 0
                                --print("stop")
                                break
                            else
                                damage = damage - victim.endurance_stack[i].current
                                victim.endurance_stack[i].current = 0
                                --print("pass next")
                            end
                        end

                    end


                    for k, v in ipairs(victim.endurance_stack) do
                        if victim.endurance_stack[k].current <= 0 then
                            --print("got one " .. k)
                            RemoveBuff(target, victim.endurance_stack[k].buffid)
                            RemoveEndurance(target, victim.endurance_stack[k].buffid, false)
                            --print("removed")
                        end
                    end



                --print("absorb done")
                total_blocked = total_blocked - damage
                --print(total_blocked)
                if total_blocked > 0 then

                    if direct then
                        local offset = BlzGetUnitCollisionSize(target) * (BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE) * 1.1)
                        local angle = AngleBetweenUnits(target, source)
                        local effect = AddSpecialEffect("Effect\\Shield.mdx", GetUnitX(target) + Rx(offset, angle), GetUnitY(target) + Ry(offset, angle))

                            BlzSetSpecialEffectColor(effect, 255, 100, 0)
                            BlzSetSpecialEffectZ(effect, GetUnitFlyHeight(target) + BlzGetUnitZ(target))
                            BlzSetSpecialEffectYaw(effect, angle * bj_DEGTORAD)
                            DestroyEffect(effect)
                            AddSoundVolume("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTargetBirth1.wav", GetUnitX(target), GetUnitY(target), 100, 1900.)
                    end

                        UpdateEndurance(target)
                        CreateHitnumber(total_blocked, source, target, ATTACK_STATUS_SHIELD)

                end

            end

            if direct and damage > 0 and victim then
                local reflect = 0

                if attack_type then
                     reflect = attack_type == MELEE_ATTACK and victim.stats[REFLECT_MELEE_DAMAGE].value or victim.stats[REFLECT_RANGE_DAMAGE].value

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


                if damage_type == DAMAGE_TYPE_PHYSICAL and direct then
                    local damage_effect = AddSpecialEffect("DamageEffect.mdx", GetUnitX(target), GetUnitY(target))
                        BlzSetSpecialEffectOrientation(damage_effect, AngleBetweenUnits(target, source) * bj_DEGTORAD, 0., 0.)
                        BlzSetSpecialEffectZ(damage_effect, GetUnitZ(target) + 55.)
                        DestroyEffect(damage_effect)
                end

            end
            --print("14")

            --if damage == 0 then damage = 1 end

            --print("16")
            if GetUnitState(target, UNIT_STATE_LIFE) > 0.045 then
                --SetUnitState(unit, UNIT_STATE_LIFE, BlzGetUnitMaxHP(unit))
                if damage >= BlzGetUnitMaxHP(target) * 0.16 and damage >= GetUnitState(target, UNIT_STATE_LIFE) and not IsAHero(target) then
                    SetUnitExploded(target, true)
                    victim.death_x = GetUnitX(target)
                    victim.death_y = GetUnitY(target)
                    victim.death_z = GetUnitZ(target)
                    victim.exploded = true
                    if attribute == ICE_ATTRIBUTE then
                        local effect = AddSpecialEffect("Effect\\Ice Cracks.mdx", victim.death_x, victim.death_y)
                        BlzSetSpecialEffectScale(effect, 0.9 * BlzGetUnitRealField(target, UNIT_RF_SCALING_VALUE))
                        BlzSetSpecialEffectYaw(effect, GetRandomReal(0., 360.) * bj_DEGTORAD)
                        DestroyEffect(effect)
                        AddSoundVolume("Sound\\shatter".. GetRandomInt(1,3) .. ".wav", victim.death_x, victim.death_y, 120, 1500.)
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
                    end
                end
                --print("15")

                damage_table.damage = damage
                OnDamage_PreHit(source, target, damage, damage_table)
                damage = damage_table.damage

                --print("17")
                --print(damage)
                if damage > 0  then

                    if IsUnitType(target, UNIT_TYPE_HERO) and IsAHero(target) and direct and damage > 0 and not victim.groan_cd then
                        if Chance(12.) then
                            PlayGroanSound(victim, (damage / BlzGetUnitMaxHP(target) > 0.15))
                        end
                    end

                    UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_NORMAL, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)
                    OnDamage_End(source, target, damage, damage_table)

                    if myeffect and myeffect.eff.stack_hitnumbers then
                        CreateHitnumber2(damage, source, target, attack_status, myeffect and myeffect.eff.id or nil)
                    else
                        CreateHitnumber(damage, source, target, attack_status)
                    end
                end
                --CreateHitnumber2(damage, source, target, attack_status, myeffect and myeffect.eff.id or nil)
            end

            --print("18")
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

                    if weapon.missile or weapon.ranged then

                        if weapon.LIGHTNING then
                            local actual_damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or weapon.DAMAGE

                            LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, weapon.LIGHTNING.bonus_z or 60., 60., weapon.LIGHTNING.range, weapon.LIGHTNING.angle)
                            DamageUnit(data.Owner, GetTriggerUnit(), actual_damage, weapon.ATTRIBUTE, weapon.DAMAGE_TYPE, RANGE_ATTACK, true, true, false, nil)
                        else
                            ThrowMissile(data.Owner, target, nil, nil, GetUnitX(data.Owner), GetUnitY(data.Owner), GetUnitX(target), GetUnitY(target), 0., true)
                        end

                        OnAttackStart(data.Owner, target, { damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or weapon.DAMAGE, damage_type = weapon.DAMAGE_TYPE, attack_type = RANGE_ATTACK, attribute = weapon.ATTRIBUTE })
                    elseif IsUnitInRange(GetEventDamageSource(), GetTriggerUnit(), weapon.RANGE + 125.) then
                        local actual_damage = weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL and data.stats[PHYSICAL_ATTACK].value or (weapon.DAMAGE or 0)
                        local attack_data = { damage = actual_damage, damage_type = weapon.DAMAGE_TYPE, attack_type = MELEE_ATTACK, attribute = weapon.ATTRIBUTE, max_targets = weapon.MAX_TARGETS, attack_wide_angle = weapon.ANGLE or 50. }

                        OnAttackStart(data.Owner, target, attack_data)

                        if attack_data.max_targets > 1 then
                            local attack_effect = {  }
                            local enemy_group = CreateGroup()
                            local facing = AngleBetweenUnits(data.Owner, target) * bj_DEGTORAD
                            local player = GetOwningPlayer(data.Owner)

                                if GetRandomInt(1, 100) <= GetCriticalChance(data.Owner, 0.) then attack_effect.critical_strike_flag = true end
                                GroupEnumUnitsInRange(enemy_group, GetUnitX(target), GetUnitY(target), weapon.RANGE + (weapon.RANGE / 4), nil)
                                if weapon.LIGHTNING then LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.) end
                                DamageUnit(data.Owner, target, attack_data.damage, attack_data.attribute, attack_data.damage_type, MELEE_ATTACK, attack_effect and true or false, true, true, attack_effect)

                                    for index = BlzGroupGetSize(enemy_group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(enemy_group, index)
                                        if picked ~= target and IsUnitEnemy(picked, player) and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                            if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and IsAngleInFace(data.Owner, attack_data.attack_wide_angle, GetUnitX(picked), GetUnitY(picked), false) then
                                                if weapon.LIGHTNING then
                                                    LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.)
                                                end
                                                DamageUnit(data.Owner, picked, attack_data.damage, attack_data.attribute, attack_data.damage_type, MELEE_ATTACK, attack_effect and true or false, true, true, attack_effect)
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

        RegisterTestCommand("m100", function()
            print(ParamToPercent(100, MAGICAL_ATTACK))
        end)

        RegisterTestCommand("m250", function()
            print(ParamToPercent(250, MAGICAL_ATTACK))
        end)

        RegisterTestCommand("m500", function()
            print(ParamToPercent(500, MAGICAL_ATTACK))
        end)

        RegisterTestCommand("m750", function()
            print(ParamToPercent(750, MAGICAL_ATTACK))
        end)

        RegisterTestCommand("m1000", function()
            print(ParamToPercent(1000, MAGICAL_ATTACK))
        end)

        RegisterTestCommand("m1250", function()
            print(ParamToPercent(1250, MAGICAL_ATTACK))
        end)


        RegisterTestCommand("hurt", function() DamageUnit(PlayerHero[1], PlayerHero[1], 5, PHYSICAL_ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, false, true, true, nil) end)

        RegisterTestCommand("shl", function()
            AddMaxEnduranceUnit(PlayerHero[1], 300, "test_shield", false)
        end)

        RegisterTestCommand("d300", function() DamageUnit(PlayerHero[1], PlayerHero[1], 300, PHYSICAL_ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, false, true, true, nil) end)

        RegisterTestCommand("d50", function() DamageUnit(PlayerHero[1], PlayerHero[1], 50, PHYSICAL_ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, false, true, true, nil) end)

        RegisterTestCommand("d350", function() DamageUnit(PlayerHero[1], PlayerHero[1], 350, PHYSICAL_ATTRIBUTE, DAMAGE_TYPE_PHYSICAL, MELEE_ATTACK, false, true, true, nil) end)

    end

end