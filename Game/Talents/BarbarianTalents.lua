---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 30.09.2021 4:46
---
do


    function BladeDanceTalentEffect(unit)
        local unit_data = GetUnitData(unit)

        if unit_data.blade_dance_bonus then
            ModifyStat(unit, PHYSICAL_DEFENCE, unit_data.blade_dance_bonus, MULTIPLY_BONUS, false)
        end

        local main_hand = GetUnitPointItem(unit, WEAPON_POINT)
        local offhand = GetUnitPointItem(unit, OFFHAND_POINT)

        if main_hand and GetUnitTalentLevel(unit, "talent_blade_dance") > 0 then

            if offhand and IsItemType(offhand, ITEM_TYPE_WEAPON) then
                unit_data.blade_dance_bonus = 1.02 + 0.04 * GetUnitTalentLevel(unit, "talent_blade_dance")
            else
                unit_data.blade_dance_bonus = 1.01 + 0.02 * GetUnitTalentLevel(unit, "talent_blade_dance")
            end

            ModifyStat(unit, PHYSICAL_DEFENCE, unit_data.blade_dance_bonus, MULTIPLY_BONUS, true)

        else
            unit_data.blade_dance_bonus = nil
        end

    end

    
    function ReflexesTalentEffect(unit) 
        local unit_data = GetUnitData(unit)

            if not unit_data.reflexes_cooldown then
                unit_data.reflexes_cooldown = true
                DelayAction(8.,function() unit_data.reflexes_cooldown = nil end)
                return true
            end

        return false
    end


    function RageTalentEffect(source)
        local max = GetUnitTalentLevel(source, "talent_rage") * 3
        local level = GetBuffLevel(source, "ATRG")
        local min = max - 3
        local current = 1

            if level == 0 then current = min + 1
            else current = min + (3 - max + level) + 1 end

            if current <= max then ApplyBuff(source, source, "ATRG", current) end
            SetBuffExpirationTime(source, "ATRG", -1.)
            local val = 3 - (max - current)
            if val > 3 then val = 3 end
            SetStatusBarValue("ATRG", val, GetPlayerId(GetOwningPlayer(source))+1)

    end


    function MomentumTalentEffect(unit)
        local unit_data = GetUnitData(unit)

        if unit_data.momentum_damage_bonus then
            ModifyStat(unit, DAMAGE_BOOST, unit_data.momentum_damage_bonus, STRAIGHT_BONUS, false)
            ModifyStat(unit, ATTACK_SPEED, unit_data.momentum_speed_bonus, STRAIGHT_BONUS, false)
        end

        if IsWeaponTypeTwohanded(unit_data.equip_point[WEAPON_POINT].SUBTYPE) and GetUnitTalentLevel(unit, "talent_momentum") > 0 then
            local level = GetUnitTalentLevel(unit, "talent_momentum")
            unit_data.momentum_damage_bonus = 4 * level
            unit_data.momentum_speed_bonus = 2 + 3 * level

            ModifyStat(unit, DAMAGE_BOOST, unit_data.momentum_damage_bonus, STRAIGHT_BONUS, true)
            ModifyStat(unit, ATTACK_SPEED, unit_data.momentum_speed_bonus, STRAIGHT_BONUS, true)
        else
            unit_data.momentum_damage_bonus = nil
        end

    end


    function SharpenedBladeTalentEffect(source)
        local unit_data = GetUnitData(source)
        unit_data.sharpened_blade_counter = 0
        unit_data.sharpened_blade_charge_time = 15.
        unit_data.sharpened_blade_charge_timer = CreateTimer()
        local update_func = function()

                if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then

                    if unit_data.sharpened_blade_charge_time <= 0. then
                        unit_data.sharpened_blade_counter = 3 + (GetUnitTalentLevel(source, "talent_sharpened_blade")-1) * 2
                        ApplyBuff(source, source, "ATSB", 1)
                        SetStatusBarValue("ATSB", unit_data.sharpened_blade_counter, GetPlayerId(GetOwningPlayer(source))+1)
                        unit_data.sharpened_blade_time = 15.
                        DelayAction(0., function() PauseTimer(unit_data.sharpened_blade_charge_timer); unit_data.sharpened_blade_charge_time = 15. end)
                    else
                        unit_data.sharpened_blade_charge_time = unit_data.sharpened_blade_charge_time - 0.1
                    end

                else
                    RemoveBuff(source, "ATSB")
                    unit_data.sharpened_blade_counter = 0
                end

                ResumeTimer(GetExpiredTimer())
            end


            TimerStart(unit_data.sharpened_blade_charge_timer, 0.1, true, update_func)

    end



    function HerbsTalentEffect(source)
        local unit_data = GetUnitData(source)
        unit_data.herbs_charge_time = 7.
        unit_data.herbs_charge_timer = CreateTimer()
        local update_func = function()

                if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then

                    if unit_data.herbs_charge_time <= 0. then
                        local heal = math.floor(BlzGetUnitMaxHP(source) * (0.01 * GetUnitTalentLevel(source, "talent_herbs")))
                        SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) + heal)
                        CreateHitnumber(heal, source, source, HEAL_STATUS)
                        unit_data.herbs_charge_time = 7.
                        local sfx = AddSpecialEffectTarget("Abilities\\Spells\\Other\\ANrm\\ANrmTarget.mdx", source, "origin")
                        DelayAction(0.5, function() DestroyEffect(sfx) end)
                    else
                        unit_data.herbs_charge_time = unit_data.herbs_charge_time - 0.1
                    end

                end

                ResumeTimer(GetExpiredTimer())
            end


            TimerStart(unit_data.herbs_charge_timer, 0.1, true, update_func)

    end


    function DisadvantageTalentEffect(source)
        local unit_data = GetUnitData(source)
        unit_data.disadvantage_timer = CreateTimer()
        local update_func = function()

                if GetUnitState(source, UNIT_STATE_LIFE) > 0.045 then
                    local group = CreateGroup()

                        GroupEnumUnitsInRange(group, GetUnitX(source), GetUnitY(source), 400., nil)

                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(group, index)

                                if GetUnitState(picked, UNIT_STATE_LIFE) <= 0.045 or IsUnitAlly(picked, Player(8)) or GetUnitAbilityLevel(picked, FourCC("Avul")) > 0 then
                                    GroupRemoveUnit(group, picked)
                                end

                            end

                        if BlzGroupGetSize(group) >= 3 and GetUnitAbilityLevel(source, FourCC("ATDA")) == 0 then
                            ApplyBuff(source, source, "ATDA", GetUnitTalentLevel(source, "talent_disadvantage"))
                        elseif BlzGroupGetSize(group) < 3 and GetUnitAbilityLevel(source, FourCC("ATDA")) > 0 then
                            RemoveBuff(source, "ATDA")
                        end

                    DestroyGroup(group)
                end


            end


            TimerStart(unit_data.disadvantage_timer, 0.3, true, update_func)

    end



end