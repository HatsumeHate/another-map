---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 20.03.2022 17:37
---
do


    function GetRandomEnemyInRangeCaster(caster, range)
        local group = CreateGroup()
        local unit

            GroupEnumUnitsInRange(group, GetUnitX(caster), GetUnitY(caster), range, nil)
            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                local picked = BlzGroupUnitAt(group, index)

                    if IsUnitEnemy(picked, GetOwningPlayer(caster)) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                        unit = picked
                        break
                    end

                GroupRemoveUnit(group, picked)
            end

        DestroyGroup(group)
        return unit
    end


    function LaunchPursuer(caster)
        local trigger = CreateTrigger()
        local target = GetRandomEnemyInRangeCaster(caster, 850.)

            if target then
                local pursuer = ThrowMissile(caster, target, "MPRS", nil, GetUnitX(caster), GetUnitY(caster), 0., 0., 0., true)
                TriggerRegisterDeathEvent(trigger, target)
                TriggerAddAction(trigger, function()
                    if pursuer and pursuer.time > 0. then
                        target = GetRandomEnemyInRangeCaster(caster, 850.)

                            if target then
                                SetMissileTarget(pursuer, target)
                                TriggerRegisterDeathEvent(trigger, target)
                            else
                                pursuer.time = 0.
                            end

                    else
                        DestroyTrigger(trigger)
                    end
                end)
            end


    end

    function SpiritTalent(caster)
        local unit_data = GetUnitData(caster)


        if unit_data.spirit_talent then

            if not unit_data.spirit or (unit_data.spirit and GetUnitState(unit_data.spirit, UNIT_STATE_LIFE) <= 0.045) then
                unit_data.spirit_talent = unit_data.spirit_talent + 1

                if unit_data.spirit_talent >= 10 then
                    local power = GetUnitParameterValue(caster, MINION_POWER)
                    unit_data.spirit_talent = nil
                    local angle = GetRandomReal(0., 360.)
                    local range = GetMaxAvailableDistance(GetUnitX(caster), GetUnitY(caster), angle, 400.)
                    local x, y = GetUnitX(caster) + Rx(range, angle), GetUnitY(caster) + Ry(range, angle)

                    local effect = AddSpecialEffect("Effect\\Ghost Strike.mdx", x, y)
                    BlzSetSpecialEffectTimeScale(effect, 3.)

                    DestroyEffect(unit_data.spirit_sfx)

                    DelayAction(1.333, function()
                        DestroyEffect(effect)
                        local summoned = CreateUnit(GetOwningPlayer(caster), FourCC("u00U"), x, y, GetRandomReal(0., 360.))

                        if unit_data.summoned_group then
                            GroupAddUnit(unit_data.summoned_group, summoned)
                        else
                            unit_data.summoned_group = CreateGroup()
                            GroupAddUnit(unit_data.summoned_group, summoned)
                        end

                        UnitApplyTimedLife(summoned, 0, 24. * GetUnitTalentLevel(caster, "talent_spirit"))
                        unit_data.spirit = summoned

                        DelayAction(0., function()
                            local summon_data = GetUnitData(summoned)
                                summon_data.minion_owner = caster
                                CreateLeashForSummonedUnit(summoned, caster, 700.)
                                ModifyStat(summoned, HP_VALUE, math.floor((50 * Current_Wave) * power), STRAIGHT_BONUS, true)
                                ModifyStat(summoned, HP_REGEN, (1. + (0.01 * Current_Wave)) * power, MULTIPLY_BONUS, true)
                                ModifyStat(summoned, PHYSICAL_ATTACK, math.floor((3 * Current_Wave) * power), STRAIGHT_BONUS, true)
                                ModifyStat(summoned, MAGICAL_ATTACK, math.floor((4 * Current_Wave) * power), STRAIGHT_BONUS, true)

                                    if GetUnitTalentLevel(caster, "talent_experienced_summoner") > 0 then
                                        if GetUnitTalentLevel(caster, "talent_experienced_summoner") == 1 then ModifyStat(summoned, HP_VALUE, 1.1, MULTIPLY_BONUS, true)
                                        else ModifyStat(summoned, HP_VALUE, 1.2, MULTIPLY_BONUS, true) end
                                    end

                                    if GetUnitTalentLevel(caster, "talent_tenacity_of_undead") > 0 then
                                        SetUnitTalentLevel(summoned, "talent_tenacity_of_undead", GetUnitTalentLevel(caster, "talent_tenacity_of_undead"))
                                    end

                                    if GetUnitTalentLevel(caster, "talent_bone_spikes") > 0 then
                                        ModifyStat(summoned, REFLECT_DAMAGE, 35 * GetUnitTalentLevel(caster, "talent_bone_spikes"), STRAIGHT_BONUS, true)
                                    end

                        end)

                    end)


                end
            end


        else
            unit_data.spirit_talent = 1
            unit_data.spirit_sfx = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\SpiritOfVengeance\\SpiritOfVengeanceOrbs1.mdx", caster, "chest")
            unit_data.spirit = nil
        end


    end


    function CreateNecromorph(caster, x, y)
        local necro = CreateUnit(GetOwningPlayer(caster), FourCC("u00V"), x, y, GetRandomReal(0., 360.))
        local trigger = CreateTrigger()
        local death_trigger = CreateTrigger()

            UnitApplyTimedLife(necro, 0, 5.)

            TriggerRegisterDeathEvent(death_trigger, necro)
            TriggerAddAction(death_trigger, function()
                ApplyEffect(caster, nil, GetUnitX(necro), GetUnitY(necro), "effect_necromorph", GetUnitTalentLevel(caster, "talent_necromorph"))
                RemoveUnit(necro)
                DestroyTrigger(trigger)
                DestroyTrigger(death_trigger)
            end)


            TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_ATTACKED)
            TriggerAddAction(trigger, function()
                if GetAttacker() == necro then
                    KillUnit(necro)
                end
            end)


    end


    function DeathEmbraceTalent(caster)
        local unit_data = GetUnitData(caster)

        unit_data.death_embrace_timer = CreateTimer()
        unit_data.death_embrace_bonus = 5
        unit_data.death_embrace_current_bonus = 0

        TimerStart(unit_data.death_embrace_timer, 0.05, true, function()
            local health = GetUnitState(caster, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(caster)

                if health < 0.25 then
                    local bonus = unit_data.death_embrace_bonus * 3

                        if bonus ~= unit_data.death_embrace_current_bonus then
                            if unit_data.death_embrace_current_bonus > 0 then ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, false) end
                            unit_data.death_embrace_current_bonus = bonus
                            ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, true)
                        end

                elseif health < 0.5 then
                    local bonus = unit_data.death_embrace_bonus * 2

                        if bonus ~= unit_data.death_embrace_current_bonus then
                            if unit_data.death_embrace_current_bonus > 0 then ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, false) end
                            unit_data.death_embrace_current_bonus = bonus
                            ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, true)
                        end

                elseif health < 0.75 then
                    local bonus = unit_data.death_embrace_bonus * 1

                        if bonus ~= unit_data.death_embrace_current_bonus then
                            if unit_data.death_embrace_current_bonus > 0 then ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, false) end
                            unit_data.death_embrace_current_bonus = bonus
                            ModifyStat(caster, MAGICAL_ATTACK, 1. + (unit_data.death_embrace_current_bonus * 0.01), MULTIPLY_BONUS, true)
                        end

                end

        end)

    end


    function BloodPactTalent(caster)
        local unit_data = GetUnitData(caster)

            if not unit_data.blood_pact_cooldown then
                unit_data.blood_pact_cooldown = true
                ApplyEffect(caster, caster, 0.,0., "effect_blood_pact", GetUnitTalentLevel(caster, "talent_blood_pact"))
                DelayAction(14., function()
                    unit_data.blood_pact_cooldown = nil
                end)
            end

    end


    function AbyssAwakensTalent(caster)
        local max_level = GetUnitTalentLevel(caster, "talent_abyss_awakens")
        local buff_level = GetBuffLevel(caster, "AABS")

            if buff_level < max_level then
                ApplyBuff(caster, caster, "AABS", buff_level + 1)
            elseif buff_level == max_level then
                SetBuffExpirationTime(caster, "AABS", -1)
            end

        
    end


    function GetMaxDurationFear(source, target)
        local unit_data = GetUnitData(target)
        local duration = 0

            for i = 1, #unit_data.buff_list do
                if unit_data.buff_list[i].buff_source == source and unit_data.buff_list[i].level[unit_data.buff_list[i].current_level].negative_state == STATE_FEAR then
                    if unit_data.buff_list[i].expiration_time > duration then
                        duration = unit_data.buff_list[i].expiration_time
                    end
                end
            end

        return math.floor(duration / 1000)
    end

    function GetMaxDurationCurse(source, target)
        local unit_data = GetUnitData(target)
        local duration = 0

            for i = 1, #unit_data.buff_list do
                if unit_data.buff_list[i].buff_source == source and HasTag(unit_data.buff_list[i].tags, "curse") then
                    if unit_data.buff_list[i].expiration_time > duration then
                        duration = unit_data.buff_list[i].expiration_time
                    end
                end
            end

        return math.floor(duration / 1000)
    end


    function VileMaledictionStack(caster, target, flag)
        local unit_data = GetUnitData(caster)
        local bonus
        local level = GetUnitTalentLevel(caster, "talent_vile_malediction")
        local max

            if level == 1 then bonus = 4; max = 125
            elseif level == 2 then bonus = 7; max = 140
            else bonus = 15; max = 165 end

            if flag then GroupAddUnit(unit_data.malediction_group, target)
            else GroupRemoveUnit(unit_data.malediction_group, target) end

            local result = BlzGroupGetSize(unit_data.malediction_group) * bonus
            if result > max then result = max end

            ModifyStat(caster, MAGICAL_ATTACK, unit_data.malediction_stacks, STRAIGHT_BONUS, false)
            ModifyStat(caster, MAGICAL_ATTACK, result, STRAIGHT_BONUS, true)
            unit_data.malediction_stacks = result


    end

end