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

    OrderInterceptionTrigger = 0


    --call AddUnitAnimationProperties(gg_unit_H003_0009, "lumber", true)


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
            AddSoundVolume("Sound\\Evade".. GetRandomInt(1,3) ..".wav", GetUnitX(target), GetUnitY(target), 120, 1400.)
        else
            local crit_overwrite
        --print("1")
        if myeffect then
            local effect_data = myeffect.eff.level[myeffect.l]

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

            if effect_data.critical_strike_flag then
                crit_overwrite = true
            end

        end

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

                if attribute then
                    attribute_bonus = 1. + (attacker.stats[GetAttributeBonusParam(attribute)].value * 0.01)
                end

                if damage_type == DAMAGE_TYPE_MAGICAL then
                    damage = damage * (1. + (ParamToPercent(attacker.stats[MAGICAL_ATTACK].value, MAGICAL_ATTACK) * 0.01))
                end

            damage = (damage * attribute_bonus) * critical_rate

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
                    if boost < -70. then boost = -70. end
                end

                --if boost < 0 then boost = 0 end

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

        damage = R2I(GetRandomReal(damage * attacker.equip_point[WEAPON_POINT].DISPERSION[1], damage * attacker.equip_point[WEAPON_POINT].DISPERSION[2]))


        --damage_table = { damage = damage, attribute = attribute, attack_status = attack_status, damage_type = damage_type, attack_type = attack_type, is_direct = direct, effect = myeffect }
        damage_table.damage = damage
        damage_table.attribute = attribute
        damage_table.attack_status = attack_status
        damage_table.damage_type = damage_type
        damage_table.attack_type = attack_type
        damage_table.is_direct = direct
        damage_table.effect = myeffect


        if direct then
            if not (TimerGetRemaining(attacker.attack_timer) > 0.) then
                --print("atttack " .. GetUnitName(source))
                if attacker.stats[HP_PER_HIT].value > 0 then
                    --print("attacker.stats[HP_PER_HIT].value > 0")
                    SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + attacker.stats[HP_PER_HIT].value)
                    CreateHitnumber(R2I(attacker.stats[HP_PER_HIT].value), source, source, HEAL_STATUS)
                    DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", source, "chest"))
                    --print("attacker.stats[HP_PER_HIT].value > 0 done")
                end

                if attacker.stats[MP_PER_HIT].value > 0 then
                    --print("attacker.stats[MP_PER_HIT].value > 0")
                    SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + attacker.stats[MP_PER_HIT].value)
                    CreateHitnumber(R2I(attacker.stats[MP_PER_HIT].value), source, source, RESOURCE_STATUS)
                    DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", source,"chest"))
                    --print("attacker.stats[MP_PER_HIT].value > 0 done")
                end

                local attack_cooldown = BlzGetUnitAttackCooldown(source, 0) - 0.01

                if myeffect and myeffect.eff.level[myeffect.l].attack_cooldown then
                    attack_cooldown = (myeffect.eff.level[myeffect.l].attack_cooldown * (1. - attacker.stats[ATTACK_SPEED].value * 0.01)) - 0.01
                    --print("was effect cd")
                end

                TimerStart(attacker.attack_timer, attack_cooldown, false, nil)
                damage_table = OnMyAttack(source, target, damage_table)
                damage = damage_table.damage
                attribute = damage_table.attribute
                attack_status = damage_table.attack_status
                damage_type = damage_table.damage_type
                attack_type = damage_table.attack_type
                direct = damage_table.is_direct
                myeffect = damage_table.effect
                --print("attack done " .. GetUnitName(source))
            elseif myeffect and myeffect.eff and myeffect.eff.single_attack_instance then
                --print("aaaa")
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


        if HasAnyDisableState(source) then
            return 0
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


            if damage < 1 then damage = 1 end


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

                if IsUnitType(target, UNIT_TYPE_HERO) and IsAHero(target) and direct and damage > 0 and not victim.groan_cd then
                    if Chance(12.) then
                        PlayGroanSound(victim, (damage / BlzGetUnitMaxHP(target) > 0.15))
                    end
                end

                UnitDamageTarget(source, target, damage, true, false, ATTACK_TYPE_NORMAL, nil, is_sound and attacker.equip_point[WEAPON_POINT].WEAPON_SOUND or nil)
                OnDamage_End(source, target, damage, damage_table)

                --print("17")
                --print(damage)
                if myeffect and myeffect.eff.stack_hitnumbers then
                    CreateHitnumber2(damage, source, target, attack_status, myeffect and myeffect.eff.id or nil)
                else
                    CreateHitnumber(damage, source, target, attack_status)
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
                    elseif IsUnitInRange(GetEventDamageSource(), GetTriggerUnit(), weapon.RANGE + 125.) then

                        local actual_damage = 0
                        if weapon.DAMAGE_TYPE == DAMAGE_TYPE_PHYSICAL then actual_damage = data.stats[PHYSICAL_ATTACK].value
                        else actual_damage = weapon.DAMAGE end
                        local attack_data = { damage = actual_damage, damage_type = weapon.DAMAGE_TYPE, attack_type = MELEE_ATTACK, attribute = weapon.ATTRIBUTE, max_targets = weapon.MAX_TARGETS, attack_wide_angle = weapon.ANGLE or 30. }

                        OnAttackStart(data.Owner, target, attack_data)

                        if attack_data.max_targets > 1 then
                            local enemy_group = CreateGroup()
                            local facing = AngleBetweenUnits(data.Owner, target) * bj_DEGTORAD
                            local player = GetOwningPlayer(data.Owner)
                            local attack_effect = nil

                            if GetRandomInt(1, 100) <= GetCriticalChance(data.Owner, 0.) then
                                attack_effect = { eff = GetEffectData("critical_strike_effect"), l = 1 }
                            end

                            GroupEnumUnitsInRange(enemy_group, GetUnitX(target), GetUnitY(target), weapon.RANGE + 15., nil)

                            if weapon.LIGHTNING then
                                LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.)
                            end
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
                            if weapon.LIGHTNING then
                                LightningEffect_Units(data.Owner, target, weapon.LIGHTNING.id, weapon.LIGHTNING.fade, 60., 60.)
                            end

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

    end

end