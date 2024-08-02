---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 23.09.2021 22:04
---
do


    function StackHeatingUp(source)
        local unit_data = GetUnitData(source)
        local max_stacks = GetUnitTalentLevel(source, "talent_heating_up") == 1 and 5 or 3
        local player = GetPlayerId(GetOwningPlayer(source))+1


            if unit_data.heating_up_stacks and unit_data.heating_up_stacks < max_stacks then
                unit_data.heating_up_stacks = unit_data.heating_up_stacks + 1

                SetStatusBarValue("talent_heating_up", unit_data.heating_up_stacks, player)

                    if unit_data.heating_up_stacks >= max_stacks then
                        unit_data.heating_up_boost = true
                        unit_data.heating_up_effect = AddSpecialEffectTarget("Effect\\heating_up.mdx", source, "origin")
                        EnableAbilitySpriteOverlay("fire", 1)
                    end

            elseif unit_data.heating_up_boost then
                unit_data.heating_up_boost = nil
                DestroyEffect(unit_data.heating_up_effect)
                RemoveStatusBarState("talent_heating_up", player)
                DisableAbilitySpriteOverlay("fire", 1)
            else
                AddStatusBarState("talent_heating_up", "Talents\\BTNFireSpell1.blp", POSITIVE_BUFF, player)
                SetStatusBarValue("talent_heating_up", 1, player)
                SetStatusBarHeaderName("talent_heating_up", LOCALE_LIST[my_locale].TALENTS["talent_heating_up"].name, GetPlayerId(GetOwningPlayer(source))+1)
                unit_data.heating_up_stacks = 1
            end

    end


    function NapalmTalentEffect(source, x, y, effect)
        local timer = CreateTimer()
        local duration = 8.
        local area = effect.level[effect.current_level].area_of_effect
        local sfx = {}
        local flame_sfx = {}
        local flame_timer = CreateTimer()
        local circle_amount = math.floor((area / 50.) + 0.5)
        local delay = 0.07


        sfx[1] = AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeEmbers.mdx", x, y)

        for i = 1, ((7 + circle_amount) * circle_amount) do
            flame_sfx[i] = AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeDamageTarget.mdx", x, y)
        end

        AddSoundVolume("Sounds\\Spells\\sizzle"..GetRandomInt(1,3)..".wav", x, y, 120, 1600.)

        local fire_move_delta = (area / (delay + (circle_amount * delay))) / 40
        local current_range = 0.
        local angle_delta = (360. / #flame_sfx)
        TimerStart(flame_timer, 0.025, true, function()
            if current_range >= area then
                for i = 1, #flame_sfx do
                    DestroyEffect(flame_sfx[i])
                end
                DestroyTimer(flame_timer)
            else
                current_range = current_range + fire_move_delta
                for i = 1, #flame_sfx do
                    local angle = angle_delta * i
                    local new_x = BlzGetLocalSpecialEffectX(flame_sfx[i]) + Rx(fire_move_delta, angle)
                    local new_y = BlzGetLocalSpecialEffectY(flame_sfx[i]) + Ry(fire_move_delta, angle)
                    BlzSetSpecialEffectYaw(flame_sfx[i], angle * bj_DEGTORAD)
                    BlzSetSpecialEffectPosition(flame_sfx[i], new_x, new_y, GetZ(new_x, new_y))
                end
            end
        end)

        local counter = {}
        local angle_table = {}
        local myindex = 0


        for i = 1, circle_amount do
            angle_table[i] = 360. / ((7 + i) * i)
            counter[i] = ((7 + i) * i)
            DelayAction(delay, function()
                myindex = myindex + 1
                local angle = GetRandomReal(0., 359.)
                for k = 1, counter[myindex] do
                    sfx[#sfx+1] = AddSpecialEffect("Abilities\\Spells\\Human\\FlameStrike\\FlameStrikeEmbers.mdx",
                            x + GetRandomReal(-10., 10.) + Rx((50. + GetRandomReal(-7., 7.)) * i, angle),
                            y + GetRandomReal(-10., 10.) + Ry((50. + GetRandomReal(-7., 7.)) * i, angle))
                    angle = angle + angle_table[i]
                end
            end)
            delay = delay + 0.07
        end


        DelayAction(6.5, function()
            local diss_timer = CreateTimer()
            TimerStart(diss_timer, 0.01, true, function()
                local num = GetRandomInt(1, #sfx)
                DestroyEffect(sfx[num])
                table.remove(sfx, num)
                if #sfx <= 0 then DestroyTimer(diss_timer) end
            end)
        end)


            TimerStart(timer, 0.33, true, function()
                if duration <= 0. then
                    DestroyTimer(timer)
                else
                    duration = duration - 0.33
                    local myeffect = ApplyEffect(source, nil, x, y, "napalm_effect", GetUnitTalentLevel(source, "talent_napalm"))
                    myeffect.level[myeffect.current_level].area_of_effect = area
                end
            end)


    end

    
    function HellFlamesTalentEffect(unit)
        local missiles = GetMissilesWithinUnit(unit, 700.)

        DestroyEffect(AddSpecialEffect("Effect\\Damnation Orange.mdx", GetUnitX(unit), GetUnitY(unit)))

            for i = 1, #missiles do
                if IsUnitEnemy(missiles[i].missile_owner, Player(8)) then
                    missiles[i].time = 0.
                    DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Items\\AIfb\\AIfbSpecialArt.mdx", missiles[i].current_x, missiles[i].current_y))
                end
            end
    end


    function LightningRodTalentEffect(source, target)
        local caster_data = GetUnitData(source)
        local hit_amount = 3

            if caster_data.lightning_rod then
                for i = 1, #caster_data.lightning_rod do
                    if caster_data.lightning_rod[i] == target then
                        return
                    end
                end
                caster_data.lightning_rod[#caster_data.lightning_rod+1] = target
            else
                caster_data.lightning_rod = {}
                caster_data.lightning_rod[#caster_data.lightning_rod+1] = target
            end

            DestroyEffect(AddSpecialEffectTarget("Effect\\az_zeusking_impact-blue.mdx", target, "origin"))

            local timer = CreateTimer()
            TimerStart(timer, 1., true, function()
                if hit_amount <= 0 or GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                    for i = 1, #caster_data.lightning_rod do
                        if caster_data.lightning_rod[i] == target then
                            table.remove(caster_data.lightning_rod, i)
                            break
                        end
                    end
                    DestroyTimer(timer)
                else
                    hit_amount = hit_amount - 1
                    LightningEffect_Units(source, target, "BLNL", 0.45, 50., 50.)
                    local group = EnumUnitsInLine(GetUnitX(source), GetUnitY(source), AngleBetweenUnits(source, target), DistanceBetweenUnits(source, target), 50.)

                        for index = BlzGroupGetSize(group) - 1, 0, -1 do
                            local picked = BlzGroupUnitAt(group, index)
                            if IsUnitEnemy(picked, Player(8)) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                ApplyEffect(source, picked, 0.,0., "lightning_rod_effect", 1)
                            end
                        end

                    DestroyGroup(group)
                end
            end)

    end


    function InductionTalentEffect(source)
        local level = GetBuffLevel(source, "ATID")
        local max = GetUnitTalentLevel(source, "talent_induction") + 1

            if level == 0 then
                ApplyBuff(source, source, "ATID", 1)
            elseif level < max then
                SetBuffLevel(source, "ATID", level + 1)
                SetBuffExpirationTime(source, "ATID", -1)
            elseif level == max  then
                SetBuffExpirationTime(source, "ATID", -1)
            end

    end


    function ExtraChargeTalentEffect(source, damage)
        local unit_data = GetUnitData(source)
        local max_orbs = GetUnitTalentLevel(source, "talent_extra_charge")
        local timer
        local extra_charge

        if not unit_data.extra_charge then
            extra_charge = {
                charge = 0.,
                current_angle = GetRandomReal(0., 359.),
                orbs = {}
            }
        else
            extra_charge = unit_data.extra_charge
        end


        if #extra_charge.orbs < max_orbs then
            extra_charge.charge = extra_charge.charge + damage

                if extra_charge.charge >= 300 + (25 * Current_Wave) then
                    extra_charge.charge = 0
                    extra_charge.orbs[#extra_charge.orbs+1] = AddSpecialEffect("Effect\\OrbOfLightning.mdx", 0.,0.)
                    BlzSetSpecialEffectScale(extra_charge.orbs[#extra_charge.orbs], 0.6)
                    ApplyBuff(source, source, "ATEE", #extra_charge.orbs)
                end

        end

        if not unit_data.extra_charge then
            timer = CreateTimer()
            unit_data.extra_charge = extra_charge

            TimerStart(timer, 0.025, true, function()
                if GetUnitState(source, UNIT_STATE_LIFE) < 0.045 then
                    for i = 1, #extra_charge.orbs do
                        DestroyEffect(extra_charge.orbs[i])
                    end
                    extra_charge.charge = 0.
                elseif GetUnitTalentLevel(source, "talent_extra_charge") == 0 then
                    DestroyTimer(timer)
                    for i = 1, #extra_charge.orbs do
                        DestroyEffect(extra_charge.orbs[i])
                    end
                    RemoveBuff(source, "ATEE")
                    unit_data.extra_charge = nil
                elseif #extra_charge.orbs > 0 then
                    local delta_angle = 360. / #extra_charge.orbs
                    local bonus_angle = 0.
                    for i = 1, #extra_charge.orbs do
                        BlzSetSpecialEffectPosition(extra_charge.orbs[i], GetUnitX(source) + Rx(100., extra_charge.current_angle + bonus_angle), GetUnitY(source) + Ry(100., extra_charge.current_angle + bonus_angle), GetZ(GetUnitX(source), GetUnitY(source)) + 60.)
                        BlzSetSpecialEffectYaw(extra_charge.orbs[i], (extra_charge.current_angle + bonus_angle) * bj_DEGTORAD)
                        bonus_angle = bonus_angle + delta_angle
                    end
                    extra_charge.current_angle = extra_charge.current_angle + 0.25
                end
            end)

        end
        
    end


    function ExtraChargeShockTalentEffect(source, target)
        local unit_data = GetUnitData(target)

            if #unit_data.extra_charge.orbs > 0 then
                DestroyEffect(unit_data.extra_charge.orbs[#unit_data.extra_charge.orbs])
                table.remove(unit_data.extra_charge.orbs, #unit_data.extra_charge.orbs)
                ApplyBuff(target, source, "ATEC", 1)
                SetBuffLevel(target, "ATEE", #unit_data.extra_charge.orbs)
            end
        
    end


    function ArcDischargeRemoveCharge(source)
        local unit_data = GetUnitData(source)

            if unit_data.arc_discharge_boost > 0 then
                unit_data.arc_discharge_boost = 0
                DestroyEffect(unit_data.arc_discharge_boost_effect)
                unit_data.arc_discharge_boost_effect = nil
                unit_data.arc_discharge_boost_time = 2.
                RemoveStatusBarState("talent_arc_discharge", GetPlayerId(GetOwningPlayer(source))+1)
            end

    end

    function ArcDischargeCharge(source)
        local unit_data = GetUnitData(source)

            if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then
                if unit_data.arc_discharge_boost < GetUnitTalentLevel(source, "talent_arc_discharge") then
                    unit_data.arc_discharge_boost = unit_data.arc_discharge_boost + 1

                    if not unit_data.arc_discharge_boost_effect then
                        unit_data.arc_discharge_boost_effect = AddSpecialEffectTarget("Effect\\lightning_arc_discharge.mdx", source, "origin")
                    end

                    AddStatusBarState("talent_arc_discharge", "Talents\\BTNLightningSpell14.blp", POSITIVE_BUFF, GetPlayerId(GetOwningPlayer(source))+1)
                    SetStatusBarValue("talent_arc_discharge", unit_data.arc_discharge_boost, GetPlayerId(GetOwningPlayer(source))+1)
                    SetStatusBarHeaderName("talent_arc_discharge", LOCALE_LIST[my_locale].TALENTS["talent_arc_discharge"].name, GetPlayerId(GetOwningPlayer(source))+1)

                    if unit_data.arc_discharge_boost == 1 then BlzPlaySpecialEffect(unit_data.arc_discharge_boost_effect, ANIM_TYPE_STAND)
                    elseif unit_data.arc_discharge_boost == 2 then BlzPlaySpecialEffect(unit_data.arc_discharge_boost_effect, ANIM_TYPE_SPELL)
                    else BlzPlaySpecialEffect(unit_data.arc_discharge_boost_effect, ANIM_TYPE_SLEEP) end

                    if unit_data.arc_discharge_boost == GetUnitTalentLevel(source, "talent_arc_discharge") then
                        unit_data.arc_discharge_boost_time = 2.
                    else
                        unit_data.arc_discharge_boost_time = 1.5
                    end
                end
            end

    end


    function ArcDischargeTalentEffect(source)
        local unit_data = GetUnitData(source)
        unit_data.arc_discharge_boost = 0
        unit_data.arc_discharge_boost_time = 2.
        unit_data.arc_discharge_boost_timer = CreateTimer()
        local update_func = function()

                if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then

                    if unit_data.arc_discharge_boost_time <= 0. and unit_data.arc_discharge_boost < GetUnitTalentLevel(source, "talent_arc_discharge") then
                        ArcDischargeCharge(source)
                    else
                        unit_data.arc_discharge_boost_time = unit_data.arc_discharge_boost_time - 0.1
                    end

                else
                    DestroyEffect(unit_data.arc_discharge_boost_effect)
                    unit_data.arc_discharge_boost_effect = nil
                    unit_data.arc_discharge_boost = 0
                    RemoveStatusBarState("talent_arc_discharge", GetPlayerId(GetOwningPlayer(source))+1)
                end

                ResumeTimer(GetExpiredTimer())
            end


            TimerStart(unit_data.arc_discharge_boost_timer, 0.1, true, update_func)

    end


    function ShockTalentEffect(source, target)
        local unit_data = GetUnitData(target)

        if not unit_data.shock_cooldown then
            ApplyBuff(source, target, "ATSH", 1)
            unit_data.shock_cooldown = true
            DelayAction(5., function() unit_data.shock_cooldown = nil end)
        end
    end


    function DisintegrationTalentEffect(source, target)
        local unit_data = GetUnitData(target)

            if (not unit_data.classification or unit_data.classification == MONSTER_RANK_COMMON) and GetUnitLifePercent(target) < 50. then
                if Chance(GetUnitParameterValue(source, CRIT_CHANCE) / 4.) then
                    CreateHitnumberSpecial(math.floor(GetUnitState(target, UNIT_STATE_LIFE)), source, target, LIGHTNING_ATTRIBUTE, ATTACK_STATUS_USUAL)
                    --CreateHitnumber(math.floor(GetUnitState(target, UNIT_STATE_LIFE)), source, target, ATTACK_STATUS_USUAL)
                    --SetUnitExploded(target, true)
                    UnitDamageTarget(source, target, 999999999999., true, false, ATTACK_TYPE_NORMAL, nil, WEAPON_TYPE_WHOKNOWS)
                    DestroyEffect(AddSpecialEffect("Effect\\disintegration.mdx", GetUnitX(target), GetUnitY(target)))
                end
            end

    end


    function GlaciationTalentEffect(source)
        local unit_data = GetUnitData(source)
        unit_data.glaciation_charge = 0
        unit_data.glaciation_charge_time = 3.
        unit_data.glaciation_charge_timer = CreateTimer()
        local update_func = function()

                if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then

                    if unit_data.glaciation_charge_time <= 0. then
                        if unit_data.glaciation_charge < GetUnitTalentLevel(source, "talent_glaciation") then
                            unit_data.glaciation_charge = unit_data.glaciation_charge + 1
                            ApplyBuff(source, source, "ATGL", unit_data.glaciation_charge)
                            unit_data.glaciation_charge_time = 2.

                            if unit_data.glaciation_charge == GetUnitTalentLevel(source, "talent_glaciation") then
                                DelayAction(0., function() PauseTimer(unit_data.glaciation_charge_timer); unit_data.glaciation_charge_time = 3. end)
                            end
                        end
                    else
                        unit_data.glaciation_charge_time = unit_data.glaciation_charge_time - 0.1
                    end

                else
                    RemoveBuff(source, "ATGL")
                    unit_data.glaciation_charge = 0
                end

                ResumeTimer(GetExpiredTimer())
            end


            TimerStart(unit_data.glaciation_charge_timer, 0.1, true, update_func)

    end


    function BreathOfFrostTalentEffect(source, target)
        local unit_data = GetUnitData(target)

            if not unit_data.bof_cooldown then
                ApplyBuff(source, target, "ATBF", GetUnitTalentLevel(source, "talent_breath_of_frost"))
                unit_data.bof_cooldown = true
                DelayAction(6., function() unit_data.bof_cooldown = nil end)
            end

    end


    ---@return boolean
    function FragilityBuffTalentCheck(target)
        local unit_data = GetUnitData(target)

        for i = 1, #unit_data.buff_list do
            if unit_data.buff_list[i].buff_type == NEGATIVE_BUFF and unit_data.buff_list[i].attribute and  unit_data.buff_list[i].attribute == ICE_ATTRIBUTE then
                return true
            end
        end

        return false
    end


end