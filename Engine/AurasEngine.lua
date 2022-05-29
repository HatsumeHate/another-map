---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 23.03.2022 20:41
---
do


    function GetUnitAuraData(target, id)

        if AuraList[target] and AuraList[target][id] then
            --print("everything exists")
            return AuraList[target][id]
        else
            if AuraList[target] and not AuraList[target][id] then
                --print("aura doesnt exist, create new")
                --AuraList[target][id] = MergeTables({}, GetAuraData(id))
                return nil
            else
                --print("nothing exists")
                AuraList[target] = {}
                --AuraList[target][id] = MergeTables({}, GetAuraData(id))
                return nil
            end
        end
    end


    function GetUnitAuras(target)
        if AuraList[target] then return AuraList[target]
        else return nil end
    end


    function GetUnitAuraLevel(target, id)
        local aura = GetUnitAuraData(target, id)
        if aura then return aura.current_level end
        return 0
    end

    function SetUnitAuraLevel(target, id, level)
        local aura = GetUnitAuraData(target, id)
        if aura then aura.current_level = level end
        return aura.current_level
    end

    function SetAuraDuration(target, id, duration)
        local aura = GetUnitAuraData(target, id)

            if aura then
                if duration == -1 then aura.time = aura.level[aura.current_level].duration
                else aura.time = duration end
            end

    end


    ---@param target unit
    ---@param id string
    ---@param level integer
    ---@param flag boolean
    function ToggleAuraOnUnit(target, id, level, flag)
        local aura = GetUnitAuraData(target, id)


            if flag then

                if aura then
                    aura.current_level = level
                    if aura.level[aura.current_level].duration then aura.time = aura.level[aura.current_level].duration end
                else

                    local player = GetOwningPlayer(target)
                    aura = MergeTables({}, GetAuraData(id))
                    AuraList[target][id] = aura
                    aura.timer = CreateTimer()
                    aura.group = CreateGroup()
                    aura.current_level = level
                    aura.time = aura.level[aura.current_level].duration or nil
                    aura.sfx = AddSpecialEffectTarget(aura.sfx_path, target, aura.sfx_point)
                    BlzSetSpecialEffectScale(aura.sfx, aura.level[aura.current_level].sfx_scale or 1.)
                    TimerStart(aura.timer, aura.tickrate, true, function()

                        if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 or (aura.time and aura.time <= 0.) then
                            DestroyGroup(aura.group)
                            DestroyTimer(aura.timer)
                            DestroyEffect(aura.sfx)
                            AuraList[target][id] = nil
                        else
                            GroupEnumUnitsInRange(aura.group, GetUnitX(target), GetUnitY(target), aura.level[aura.current_level].radius, nil)

                                for index = BlzGroupGetSize(aura.group) - 1, 0, -1 do
                                    local picked = BlzGroupUnitAt(aura.group, index)

                                        if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then

                                            if aura.level[aura.current_level][ON_ENEMY] and IsUnitEnemy(picked, player) then

                                                if aura.level[aura.current_level][ON_ENEMY].applied_effect then
                                                    ApplyEffect(target, picked, 0.,0., aura.level[aura.current_level][ON_ENEMY].applied_effect, aura.current_level)
                                                elseif aura.level[aura.current_level][ON_ENEMY].applied_buff then
                                                    ApplyBuff(target, picked, aura.level[aura.current_level][ON_ENEMY].applied_buff, aura.current_level)
                                                end

                                            elseif aura.level[aura.current_level][ON_ALLY] and not IsUnitEnemy(picked, player) and picked ~= target then

                                                if aura.level[aura.current_level][ON_ALLY].applied_effect then
                                                    ApplyEffect(target, picked, 0.,0., aura.level[aura.current_level][ON_ALLY].applied_effect, aura.current_level)
                                                elseif aura.level[aura.current_level][ON_ALLY].applied_buff then
                                                    ApplyBuff(target, picked, aura.level[aura.current_level][ON_ALLY].applied_buff, aura.current_level)
                                                end

                                            end
                                        end

                                    GroupRemoveUnit(aura.group, picked)
                                end

                            if aura.level[aura.current_level][ON_SELF] then
                                if aura.level[aura.current_level][ON_SELF].applied_effect then
                                    ApplyEffect(target, target, 0.,0., aura.level[aura.current_level][ON_SELF].applied_effect, aura.current_level)
                                elseif aura.level[aura.current_level][ON_SELF].applied_buff then
                                    ApplyBuff(target, target, aura.level[aura.current_level][ON_SELF].applied_buff, aura.current_level)
                                end
                            end

                            if aura.time then aura.time = aura.time - aura.tickrate end
                        end
                    end)
                end


            else
                AuraList[target][id] = nil
                DestroyGroup(aura.group)
                DestroyTimer(aura.timer)
                DestroyEffect(aura.sfx)
            end


    end

end