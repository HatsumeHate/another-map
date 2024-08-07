do

    --- index 1
    KEY_Q = 1
    --- index 2
    KEY_W = 2
    --- index 3
    KEY_E = 3
    --- index 4
    KEY_R = 4
    --- index 5
    KEY_D = 5
    --- index 6
    KEY_F = 6


    KEYBIND_LIST = 0
    PlayerSkillQueue = 0





    function GetClosestUnitToCursor(player)
        local group = CreateGroup()
        local distance = 64.
        local cx, cy = PlayerMousePosition[player].x, PlayerMousePosition[player].y-32
        local target = nil

            GroupEnumUnitsInRange(group, cx, cy, 64., nil)

            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                local picked = BlzGroupUnitAt(group, index)

                if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                    local d = DistanceBetweenUnitXY(picked, cx, cy)

                        if d < distance then
                            target = picked
                            distance = d
                        end

                end

                GroupRemoveUnit(group, picked)

            end

        DestroyGroup(group)

        return target
    end


    function ToggleQuickcast(player, flag)
        for key = KEY_Q, KEY_F do
            if flag then EnableTrigger(KEYBIND_LIST[key].trigger)
            else DisableTrigger(KEYBIND_LIST[key].trigger) end
        end
    end

    function ResetAbilityCooldown(source, ability_id)
        local player = GetPlayerId(GetOwningPlayer(source)) + 1
        local skill = GetUnitSkillData(source, ability_id)
        local level = UnitGetAbilityLevel(source, ability_id)
        local key = GetKeybindKey(FourCC(ability_id), player)

            if skill and skill.current_max_charges then

                for i = 1, #skill.charges_timers do
                    DestroyTimer(skill.charges_timers[i])
                end

                skill.charges_timers = {}
                skill.current_charges = skill.current_max_charges

                if IsAbilityKeybinded(FourCC(ability_id), player) then
                    BlzFrameSetText(KEYBIND_LIST[key].player_charges_frame[player].text, skill.current_charges)
                end

            end

        BlzEndUnitAbilityCooldown(source, KEYBIND_LIST[key].ability)
    end

    ---@param unit unit
    ---@param abilityid integer
    function StartAbilityCharge(unit, abilityid)
        local unit_data = GetUnitData(unit)
        local timer = CreateTimer()
        local skill = GetUnitSkillData(unit, abilityid)
        local player = GetPlayerId(GetOwningPlayer(unit))

            skill.charges_timers[#skill.charges_timers+1] = timer
            TimerStart(timer, skill.cooldown, false, function()
                for i = 1, #skill.charges_timers do
                    if skill.charges_timers[i] == timer then
                        DestroyTimer(skill.charges_timers[i])
                        table.remove(skill.charges_timers, i)
                        break
                    end
                end

                skill.current_charges = skill.current_charges + 1
                if skill.current_charges > skill.current_max_charges then skill.current_charges = skill.current_max_charges end
                if IsAbilityKeybinded(FourCC(skill.Id), player) then
                    BlzFrameSetText(KEYBIND_LIST[GetKeybindKey(FourCC(skill.Id), player)].player_charges_frame[player].text, skill.current_charges)
                    if BlzGetUnitAbilityCooldownRemaining(unit_data.Owner, GetKeybindKeyAbility(FourCC(skill.Id), player)) > 0. then
                        BlzEndUnitAbilityCooldown(unit_data.Owner, GetKeybindKeyAbility(FourCC(skill.Id), player))
                    end
                end
            end)
    end


    function UnbindAbilityKey(unit, id)
        local player = GetPlayerId(GetOwningPlayer(unit)) + 1

            for i = KEY_Q, KEY_F do
                if KEYBIND_LIST[i].player_skill_bind[player] == FourCC(id) then
                    UnitRemoveAbility(unit, KEYBIND_LIST[i].ability)
                    KEYBIND_LIST[i].player_skill_bind[player] = 0
                    KEYBIND_LIST[i].player_skill_bind_string_id[player] = nil
                    BlzFrameSetVisible(KEYBIND_LIST[i].player_charges_frame[player].border, false)
                    break
                end
            end

    end


    function ParseString(str, lvl)
        local tag = string.sub(str, 2, 2)
        local value_str = string.sub(str, string.find(str, ".", 1, true)+1, string.find(str, "#", 1, true)-1)
        local id = string.sub(str, string.find(str, "!", 1, true)+1,  string.find(str, ".", 1, true)-1)

            if tag == "e" then
                local effect = GetEffectData(id)

                if effect == nil then
                    return "invalid effect"
                end

                GenerateEffectLevelData(effect, lvl)

                    if value_str == "pwr" then return "|c00FF7600" .. (effect.level[lvl].power or 0) .. "|r"
                    elseif value_str == "dmg" then return "|c00FF7600" .. (effect.level[lvl].power or 0) .. " + " .. S2I(R2S((effect.level[lvl].attack_percent_bonus or 1.) * 100.)) .. "%%|r " .. LOCALE_LIST[my_locale].GENERATED_TOOLTIP
                    elseif value_str == "atr" then return GetAttributeColor(effect.attribute) .. GetAttributeName(effect.attribute) .. "|r"
                    elseif value_str == "ap" then return math.floor((effect.level[lvl].attack_percent_bonus or 1.) * 100.)
                    elseif value_str == "ab" then return "|c007AB3FF" ..  (effect.level[lvl].attribute_bonus or 0) .. "|r"
                    elseif value_str == "wdpb" then return math.floor((effect.level[lvl].weapon_damage_percent_bonus or 1.) * 100.)
                    elseif value_str == "aoe" then return R2I(effect.level[lvl].area_of_effect or 0.)
                    elseif value_str == "bcc" then return "|c00FFD900" .. R2I(effect.level[lvl].bonus_crit_chance or 0.) .. "%%|r"
                    elseif value_str == "bcm" then return "|c00FFD900" .. (effect.level[lvl].bonus_crit_multiplier or 0.) .. "|r"
                    elseif value_str == "hp_perc" then return "|c0000FF00" .. string.format('%%.1f', (effect.level[lvl].life_percent_restored or 0.) * 100.) .. "%%|r"
                    elseif value_str == "mp_perc" then return "|c000066FF" .. string.format('%%.1f', (effect.level[lvl].resource_percent_restored or 0.) * 100.) .. "%%|r"
                    elseif value_str == "hp" then return "|c0000FF00" .. (effect.level[lvl].life_restored or 0.) .. "|r"
                    elseif value_str == "mp" then return "|c000066FF" .. (effect.level[lvl].resource_restored or 0.) .. "|r"
                    elseif value_str == "hphitmax" then return "|c0000FF00" .. (effect.level[lvl].life_restored_from_hit_max or 0.) .. "|r"
                    elseif value_str == "mphitmax" then return "|c000066FF" .. (effect.level[lvl].resource_restored_from_hit_max or 0.) .. "|r"
                    elseif value_str == "heal_max_hp" then return "|c0000FF00" .. string.format('%%.1f', (effect.level[lvl].heal_amount_max_hp or 0.) * 100.) .. "%%|r"
                    end


            elseif tag == "s" then
                local skill = GetSkillData(FourCC(id))

                GenerateSkillLevelData(skill, lvl)

                    if value_str == "rc" then return R2I(skill.level[lvl].resource_cost or 0)
                    elseif value_str == "cld" then return skill.level[lvl].cooldown or 0.1
                    elseif value_str == "rng" then return "|c0000DBA4" .. R2I(skill.level[lvl].range or 0.) .. "|r" end

            elseif tag == "b" then
                local buff = GetBuffData(id)
                local sub = SubString(value_str, 0,  2)

                if buff == nil then
                    return "invalid buff"
                end

                    GenerateBuffLevelData(buff, lvl)

                    if value_str == "time" then return buff.level[lvl].time or 0.1
                    elseif sub == "va" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return "|c00FF7600" .. GetCorrectParamText(param.PARAM, param.VALUE, param.METHOD) .. "|r"
                    elseif sub == "pa" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return GetParameterName(param.PARAM)
                    elseif sub == "en" then
                        return "|c00FF862F" .. (buff.level[lvl].endurance or 0) .. "|r"
                    elseif sub == "eh" then
                        return "|c00FF862F" .. math.floor((buff.level[lvl].endurance_hp or 0) * 100) .. "%%|r"
                    end

            elseif tag == "m" then
                local missile = GetMissileData(id)

                    if value_str == "rad" then return "|c0000DBA4" .. (R2I(missile.radius or 0)) .. "|r"
                    elseif value_str == "maxd" then return R2I(missile.max_distance) or 0 end

            else
                tag = string.sub(str, 2, string.find(str, "!", 1, true)-1)

                    if tag == "FM_DIV" then
                       return math.floor(id + math.floor(lvl / value_str))
                    elseif tag == "FM_PER" then
                      return math.floor(id + lvl * value_str)
                    end

            end

        return ""
    end


    function ParseLocalizationSkillTooltipString(str, level)
        local new_block = 0
        local last_sector = 0
        local result_string = ""


            while(true) do
                local new_parse_block = string.find(str, "@", last_sector)

                if new_parse_block then
                    local parse_block_ending = string.find(str, "#", last_sector)
                    result_string = result_string .. string.sub(str, new_block, new_parse_block-1) .. ParseString(string.sub(str, new_parse_block, parse_block_ending), level)
                    last_sector = parse_block_ending + 1
                    new_block = last_sector
                else
                    result_string = result_string .. string.sub(str, last_sector, #str)
                    break
                end

            end

        return result_string
    end


    ---@param unit unit
    ---@param id string
    ---@param player number
    function SetAbilityExtendedTooltip(unit, id, player)
        local true_id = FourCC(id)
        local ability = GetKeybindKeyAbility(true_id, player)

            if ability == 0 then return end
            local lvl = UnitGetAbilityLevel(unit, id)

                if LOCALE_LIST[my_locale][true_id] then

                    if LOCALE_LIST[my_locale][true_id][lvl] then
                        local description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][lvl], lvl)
                        if GetLocalPlayer() == Player(player-1) then
                            BlzSetAbilityExtendedTooltip(ability, description, 0)
                        end
                    else
                        for i = lvl, 1, -1 do
                            if LOCALE_LIST[my_locale][true_id][i] then
                                local description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][i], lvl)
                                if GetLocalPlayer() == Player(player-1) then
                                    BlzSetAbilityExtendedTooltip(ability, description, 0)
                                end
                                break
                            end
                        end
                    end
                end

    end


    function UpdateBindedSkillsManacosts(unit)
        local unit_data = GetUnitData(unit)
        local player = GetPlayerId(GetOwningPlayer(unit)) + 1
            for key = KEY_Q, KEY_F do
                if KEYBIND_LIST[key].player_skill_bind[player] and KEYBIND_LIST[key].player_skill_bind[player] > 0 then
                    local skill = GetUnitSkillData(PlayerHero[player], KEYBIND_LIST[key].player_skill_bind_string_id[player])
                    local level = UnitGetAbilityLevel(PlayerHero[player], skill.Id)
                    local manacost = ((skill.level[level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier

                        if manacost < 0. then manacost = 0 end

                        BlzSetUnitAbilityManaCost(PlayerHero[player], KEYBIND_LIST[key].ability, 0, math.floor(manacost + 0.5))
                end
            end
    end


    function UpdateBindedSkillsData(player)
        local unit_data = GetUnitData(PlayerHero[player])

            for key = KEY_Q, KEY_F do
                if KEYBIND_LIST[key].player_skill_bind[player] and KEYBIND_LIST[key].player_skill_bind[player] > 0 then
                    local skill = GetUnitSkillData(PlayerHero[player], KEYBIND_LIST[key].player_skill_bind_string_id[player])
                    local ability = BlzGetUnitAbility(PlayerHero[player], KEYBIND_LIST[key].ability)
                    local level = UnitGetAbilityLevel(PlayerHero[player], skill.Id)

                        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
                        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
                        BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)

                        local manacost = ((skill.level[level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier
                        if manacost < 0. then manacost = 0 end

                        if skill.level[level].charges then
                            if GetLocalPlayer() == GetOwningPlayer(PlayerHero[player]) then
                                BlzFrameSetVisible(KEYBIND_LIST[key].player_charges_frame[player].border, true)
                            end
                        end

                        BlzSetUnitAbilityManaCost(PlayerHero[player], KEYBIND_LIST[key].ability, 0, math.floor(manacost + 0.5))
                        SetAbilityExtendedTooltip(PlayerHero[player], skill.Id, player)
                end
            end

    end


    ---@param id integer
    ---@param player number
    function UpdateBindedSkillData(id, player)
        local unit_data = GetUnitData(PlayerHero[player])

            if IsAbilityKeybinded(FourCC(id), player) then
                local skill = GetUnitSkillData(PlayerHero[player], id)
                local ability_id = GetKeybindKeyAbility(FourCC(id), player)
                local ability = BlzGetUnitAbility(PlayerHero[player], ability_id)
                local level = UnitGetAbilityLevel(PlayerHero[player], id)

                    BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
                    BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
                    BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)
                    local manacost = ((skill.level[level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier
                    if manacost < 0. then manacost = 0 end

                    if skill.level[level].charges and (skill.current_max_charges or 1) > skill.level[level].charges and not skill.separate_recharge then
                        local difference = skill.current_max_charges - skill.level[level].charges
                        for i = 1, difference do StartAbilityCharge(PlayerHero[player], id) end
                    end

                    BlzSetUnitAbilityManaCost(PlayerHero[player], ability_id, 0, math.floor(manacost + 0.5))
                    SetAbilityExtendedTooltip(PlayerHero[player], id, player)
            end

    end

    ---@param unit unit
    ---@param id string
    ---@param key integer
    function BindAbilityKey(unit, id, key)
        local skill = GetUnitSkillData(unit, id)--GetSkillData(FourCC(id))
        local ability_id = KEYBIND_LIST[key].ability
        local ability
        local unit_data = GetUnitData(unit)


            if GetUnitAbilityLevel(unit, ability_id) == 0 then
                UnitAddAbility(unit, ability_id)
            end

            ability = BlzGetUnitAbility(unit, ability_id)
            local level = UnitGetAbilityLevel(unit, id)

            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
            BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)

            local manacost = ((skill.level[level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier
            if manacost < 0. then manacost = 0 end
            BlzSetUnitAbilityManaCost(unit, ability_id, 0, math.floor(manacost + 0.5))

            if skill.level[level].charges then
                if GetLocalPlayer() == GetOwningPlayer(unit) then
                    BlzFrameSetVisible(KEYBIND_LIST[key].player_charges_frame[GetPlayerId(GetOwningPlayer(unit))+1].border, true)
                end
                BlzFrameSetText(KEYBIND_LIST[key].player_charges_frame[GetPlayerId(GetOwningPlayer(unit))+1].text, skill.current_charges or skill.level[level].charges)
                if not skill.current_charges then skill.current_charges = skill.level[level].charges end
                skill.current_max_charges = skill.level[level].charges
            end

                if GetLocalPlayer() == GetOwningPlayer(unit) then
                    BlzSetAbilityTooltip(ability_id, skill.name, 0)
                    BlzSetAbilityIcon(ability_id, skill.icon)
                end


        KEYBIND_LIST[key].player_skill_bind[GetPlayerId(GetOwningPlayer(unit)) + 1] = FourCC(id)
        KEYBIND_LIST[key].player_skill_bind_string_id[GetPlayerId(GetOwningPlayer(unit)) + 1] = id
        --print("keybind done")
        SetAbilityExtendedTooltip(unit, id, GetPlayerId(GetOwningPlayer(unit)) + 1)
    end


    ---@param id integer
    ---@param player integer
    function IsAbilityKeybinded(id, player)

        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].player_skill_bind[player] == id then
                return true
            end
        end

        return false
    end

    ---@param id integer
    ---@param player integer
    ---@return integer
    function GetKeybindKey(id, player)
        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].player_skill_bind[player] == id then
                return key
            end
        end
        return KEY_Q
    end

    ---@param id integer
    ---@param player integer
    ---@return integer
    function GetKeybindKeyAbility(id, player)

        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].player_skill_bind[player] == id then
                return KEYBIND_LIST[key].ability
            end
        end

        return 0
    end

    ---@param id integer
    ---@param player integer
    ---@return integer
    function GetKeybindAbility(id, player)

        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].ability == id then
                return KEYBIND_LIST[key].player_skill_bind[player]
            end
        end

        return 0
    end

    ---@param id integer
    ---@param player integer
    ---@return string
    function GetKeybindAbilityString(id, player)

        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].ability == id then
                return KEYBIND_LIST[key].player_skill_bind_string_id[player]
            end
        end

        return "0"
    end


    ---@param unit unit
    ---@param id string
    ---@param amount integer
    ---@return boolean
    function UnitAddAbilityLevel(unit, id, amount)
        local unit_data = GetUnitData(unit)

        if amount <= 0 then return false end

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    unit_data.skill_list[i].current_level = unit_data.skill_list[i].current_level + amount
                    GenerateSkillLevelData(unit_data.skill_list[i], unit_data.skill_list[i].current_level)
                    UpdateBindedSkillData(id, GetPlayerId(GetOwningPlayer(unit)) + 1)
                    --print("current unit ability level " .. unit_data.skill_list[i].current_level)
                    return true
                end
            end

        return false
    end


    ---@param unit unit
    ---@param id string
    ---@param lvl integer
    ---@return boolean
    function UnitSetAbilityLevel(unit, id, lvl)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    unit_data.skill_list[i].current_level = lvl
                    UpdateBindedSkillData(id, GetPlayerId(GetOwningPlayer(unit)) + 1)
                    --print("set unit ability level " .. unit_data.skill_list[i].current_level)
                    return true
                end
            end

        return false
    end

    ---@param unit unit
    ---@param id string
    ---@return integer
    function UnitGetAbilityLevel(unit, id)
        local unit_data = GetUnitData(unit)
        local skill = GetUnitSkillData(unit, id)
        local ability_level = skill and skill.current_level or 1

            for i = WEAPON_POINT, NECKLACE_POINT do
                if unit_data.equip_point[i] and unit_data.equip_point[i].SKILL_BONUS and #unit_data.equip_point[i].SKILL_BONUS > 0 then
                    for skill_bonus = 1, #unit_data.equip_point[i].SKILL_BONUS do
                        if (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id and unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id == id) or
                                (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category and skill.category == unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category) then
                            ability_level = ability_level + (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].bonus_levels or 1)
                        end
                    end
                end
            end

           GenerateSkillLevelData(skill, ability_level)

        return ability_level
    end


    ---@param unit unit
    ---@param id integer
    function UnitAddMyAbility(unit, id)
        local unit_data = GetUnitData(unit)
        local skill_data = GetSkillData(FourCC(id))

        if unit_data == nil or skill_data == nil then return end

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    --print("ability ".. unit_data.skill_list[i].name .. " exists!")
                    return false
                end
            end

            unit_data.skill_list[#unit_data.skill_list + 1] = MergeTables({}, skill_data)

            --print("new skill added ".. unit_data.skill_list[#unit_data.skill_list].name)

        return true
    end


    function UnitRemoveMyAbility(unit, id)
        local unit_data = GetUnitData(unit)

        if unit_data == nil then return end

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    unit_data.skill_list[i] = nil
                end
            end

    end


    ---@param unit unit
    ---@param skill string
    function GetAbilityFromUnit(unit, skill)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == skill then
                    return unit_data.skill_list[i]
                end
            end

        return nil
    end


    local function HasConditionalWeapon(pack, weapontype)

        for i = 1, #pack.conditional_weapon do
            if pack.conditional_weapon[i] == weapontype then
                return true
            end
        end

        return false
    end

    local function PlayCastSfx(unit_data, pack, animation_timescale, target, x, y)

        if pack then

            if unit_data.cast_effect_pack then
                for i = 1, #unit_data.cast_effect_pack do
                    DestroyEffect(unit_data.cast_effect_pack[i])
                end
            end

            if unit_data.cast_effect_permanent_pack then
                for i = 1, #unit_data.cast_effect_permanent_pack do
                    BlzSetSpecialEffectScale(unit_data.cast_effect_permanent_pack[i], 1.)
                    DestroyEffect(unit_data.cast_effect_permanent_pack[i])
                end
            end

            unit_data.cast_effect_pack = {}
            unit_data.cast_effect_permanent_pack = {}

                if pack.on_caster then
                    for i = 1, #pack.on_caster do
                        local effect = pack.on_caster[i]

                        if not effect.conditional_weapon or HasConditionalWeapon(effect, unit_data.equip_point[WEAPON_POINT].SUBTYPE) and not unit_data.dashing and not IsUnitDisabled(unit_data.Owner) then
                            local casteffect = AddSpecialEffectTarget(effect.effect, unit_data.Owner, effect.point or "chest")
                            BlzSetSpecialEffectScale(casteffect, effect.scale or 1.)

                            if effect.animation_time_influence then
                                BlzSetSpecialEffectTimeScale(casteffect, (effect.timescale or 1.) * animation_timescale)
                            else
                                BlzSetSpecialEffectTimeScale(casteffect, effect.timescale or 1.)
                            end

                                if effect.duration and effect.duration > 0. then
                                    local timer = CreateTimer()
                                    TimerStart(timer, effect.duration, false, function()
                                        DestroyEffect(casteffect)
                                        DestroyTimer(timer)
                                    end)
                                elseif effect.permanent then
                                    unit_data.cast_effect_permanent_pack[#unit_data.cast_effect_permanent_pack+1] = casteffect
                                else
                                    unit_data.cast_effect_pack[#unit_data.cast_effect_pack+1] = casteffect
                                end

                        end

                    end
                end

                if pack.on_target then
                    for i = 1, #pack.on_target do
                        local effect = pack.on_target[i]

                        if not effect.conditional_weapon or HasConditionalWeapon(effect, unit_data.equip_point[WEAPON_POINT].SUBTYPE) and not unit_data.dashing and not IsUnitDisabled(unit_data.Owner) then
                            local casteffect = AddSpecialEffectTarget(effect.effect, target, effect.point or "chest")
                            BlzSetSpecialEffectScale(casteffect, effect.scale or 1.)

                            if effect.animation_time_influence then
                                BlzSetSpecialEffectTimeScale(casteffect, (effect.timescale or 1.) * animation_timescale)
                            else
                                BlzSetSpecialEffectTimeScale(casteffect, effect.timescale or 1.)
                            end

                                if effect.duration and effect.duration > 0. then
                                    local timer = CreateTimer()
                                    TimerStart(timer, effect.duration, false, function()
                                        DestroyEffect(casteffect)
                                        DestroyTimer(timer)
                                    end)
                                elseif effect.permanent then
                                    unit_data.cast_effect_permanent_pack[#unit_data.cast_effect_permanent_pack+1] = casteffect
                                else
                                    unit_data.cast_effect_pack[#unit_data.cast_effect_pack+1] = casteffect
                                end

                        end

                    end
                end


            if pack.on_terrain then

                for i = 1, #pack.on_terrain do
                    local effect = pack.on_terrain[i]

                    if not effect.conditional_weapon or HasConditionalWeapon(effect, unit_data.equip_point[WEAPON_POINT].SUBTYPE) and not unit_data.dashing and not IsUnitDisabled(unit_data.Owner) then

                        DelayAction(effect.appear_delay and (effect.appear_delay * animation_timescale) or 0., function()

                            if unit_data.dashing or IsUnitDisabled(unit_data.Owner) or unit_data.skip_sfx_effects then return end

                            local casteffect = AddSpecialEffect(effect.effect, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner))
                            local orientation = target and AngleBetweenUnits(unit_data.Owner, target) or AngleBetweenUnitXY(unit_data.Owner, x, y)

                            if target == unit_data.Owner then
                                orientation = GetUnitFacing(unit_data.Owner)
                            end

                            if effect.random_orientation_angle then
                                orientation = GetRandomReal(0., 360.)
                            end

                                BlzSetSpecialEffectScale(casteffect, effect.scale or 1.)
                                BlzSetSpecialEffectOrientation(casteffect, (effect.yaw or orientation * bj_DEGTORAD), 0., (effect.roll or 0.) * bj_DEGTORAD)

                                    if effect.animation_time_influence then
                                        BlzSetSpecialEffectTimeScale(casteffect, (effect.timescale or 1.) * animation_timescale)
                                    else
                                        BlzSetSpecialEffectTimeScale(casteffect, effect.timescale or 1.)
                                    end

                                    if effect.plane_offset then
                                        BlzSetSpecialEffectPosition(casteffect,
                                                GetUnitX(unit_data.Owner) + Rx(effect.plane_offset, effect.plane_offset_angle and effect.plane_offset_angle or orientation),
                                                GetUnitY(unit_data.Owner) + Ry(effect.plane_offset, effect.plane_offset_angle and effect.plane_offset_angle or orientation),
                                                GetUnitZ(unit_data.Owner) + (effect.height or 0.))
                                    elseif effect.height then
                                        BlzSetSpecialEffectZ(casteffect, GetUnitZ(unit_data.Owner) + (effect.height or 0.))
                                    end

                                    if effect.duration and effect.duration > 0. then
                                        local timer = CreateTimer()
                                        TimerStart(timer, effect.duration, false, function()
                                            DestroyEffect(casteffect)
                                            DestroyTimer(timer)
                                        end)
                                    elseif effect.permanent then
                                        unit_data.cast_effect_permanent_pack[#unit_data.cast_effect_permanent_pack+1] = casteffect
                                    else
                                        unit_data.cast_effect_pack[#unit_data.cast_effect_pack+1] = casteffect
                                    end

                        end)

                    end

                end
            end

        end

    end


    ---@param unit unit
    function ResetUnitSpellCast(unit)
        local unit_data = GetUnitData(unit)


            if unit_data.channeled_destructor then
                unit_data.channeled_destructor(unit)
                unit_data.channeled_destructor = nil
            end

            BlzUnitInterruptAttack(unit)

            SafePauseUnit(unit, false)

            if IsAHero(unit) then
                PlayerSkillQueue[GetPlayerId(GetOwningPlayer(unit))+1].is_casting_skill = false
                PlayerSkillQueue[GetPlayerId(GetOwningPlayer(unit))+1].queue_skill = nil
            end

            IssueImmediateOrderById(unit, order_stop)
            SetUnitTimeScale(unit, 1.)
            DestroyEffect(unit_data.cast_effect)

            if unit_data.cast_effect_pack then
                for i = 1, #unit_data.cast_effect_pack do
                    DestroyEffect(unit_data.cast_effect_pack[i])
                end
                unit_data.cast_effect_pack = nil
            end

            if unit_data.cast_effect_permanent_pack then
                for i = 1, #unit_data.cast_effect_permanent_pack do
                    BlzSetSpecialEffectScale(unit_data.cast_effect_permanent_pack[i], 1.)
                    DestroyEffect(unit_data.cast_effect_permanent_pack[i])
                end
                unit_data.cast_effect_permanent_pack = nil
            end

            TimerStart(unit_data.action_timer, 0., false, nil)
            if unit_data.nudge_timer then DestroyTimer(unit_data.nudge_timer); unit_data.nudge_timer = nil end
            --PauseTimer(unit_data.action_timer)

                if unit_data.castsound then
                    for i = 1, #unit_data.castsound do
                        DestroyTimer(unit_data.sound_delay_timer[i])
                        StopSound(unit_data.castsound[i], true, true)
                    end
                    unit_data.castsound = nil
                end

                if unit_data.cast_skill > 0 then
                    local skill = GetUnitSkillData(unit, unit_data.cast_skill_id)

                        if skill.level[1].charges then
                            skill.current_charges = skill.current_charges + 1
                            if skill.current_charges > skill.current_max_charges then skill.current_charges = skill.current_max_charges end
                            DestroyTimer(skill.charges_timers[#skill.charges_timers])
                            table.remove(skill.charges_timers, #skill.charges_timers)
                            local player = GetPlayerId(GetOwningPlayer(unit)) + 1
                            if IsAbilityKeybinded(FourCC(skill.Id), player) then
                                BlzFrameSetText(KEYBIND_LIST[GetKeybindKey(FourCC(skill.Id), player)].player_charges_frame[player].text, skill.current_charges)
                            end
                        end

                    BlzEndUnitAbilityCooldown(unit, unit_data.cast_skill)
                    SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + unit_data.cast_skill_mana)
                    unit_data.cast_skill_mana = 0
                end

            unit_data.skip_sfx_effects = true
            unit_data.cast_skill = 0
    end


    ---@param unit unit
    function SpellBackswing(unit)
        local unit_data = GetUnitData(unit)

            SafePauseUnit(unit, false)
            IssueImmediateOrderById(unit, order_stop)

            if unit_data.animation_tag then SetUnitAnimation(unit, "Stand Ready " .. unit_data.animation_tag)
            else SetUnitAnimation(unit, "Stand Ready") end

            SetUnitTimeScale(unit, 1.)

            if IsAHero(unit) then
                PlayerSkillQueue[GetPlayerId(GetOwningPlayer(unit))+1].is_casting_skill = false
                PlayerSkillQueue[GetPlayerId(GetOwningPlayer(unit))+1].queue_skill = nil
            end

            if unit_data.nudge_timer then DestroyTimer(unit_data.nudge_timer); unit_data.nudge_timer = nil end
            --DestroyTimer(unit_data.sound_delay_timer)

            if unit_data.cast_effect_permanent_pack then
                for i = 1, #unit_data.cast_effect_permanent_pack do
                    BlzSetSpecialEffectScale(unit_data.cast_effect_permanent_pack[i], 1.)
                    DestroyEffect(unit_data.cast_effect_permanent_pack[i])
                end
                unit_data.cast_effect_permanent_pack = nil
            end
        --print("backswing end")

    end


    function CanCastSkillWithWeapon(skill, weapontype)

        for i = 1, #skill.required_weapon do
            if skill.required_weapon[i] == weapontype then return true end
        end

        return false
    end



    function EnableHeroSkills(player)
        local unit_data = GetUnitData(PlayerHero[player])

            if IsUnitFeared(PlayerHero[player]) then return end

            for key = 1, 6 do BlzUnitDisableAbility(PlayerHero[player], KEYBIND_LIST[key].ability, false, false) end
            UnitRemoveAbility(PlayerHero[player], FourCC("ARal"))

    end

    function DisableHeroSkills(player)
        local unit_data = GetUnitData(PlayerHero[player])

            if unit_data.channeled_destructor then unit_data.channeled_destructor(PlayerHero[player]); unit_data.channeled_destructor = nil end
            for key = 1, 6 do BlzUnitDisableAbility(PlayerHero[player], KEYBIND_LIST[key].ability, true, false) end
            UnitAddAbility(PlayerHero[player], FourCC("ARal"))
    end


    ---@param source unit
    ---@param target unit
    ---@param action_id string
    ---@param point_x real
    ---@param point_y real
    ---@param ability_instance table
    function DoAction(source, target, action_id, point_x, point_y, ability_instance)
        local unit_data = GetUnitData(source)
        local action = GetActionData(action_id)
        local angle = 0


        if not target and (not point_x or point_x == 0) then
            point_x = GetUnitX(source)
            point_y = GetUnitY(source)
            angle = GetUnitFacing(source)
        else
            angle = target and AngleBetweenUnits(source, target) or AngleBetweenUnitXY(source, point_x, point_y)
        end

            if unit_data.channeled_destructor then
                unit_data.channeled_destructor(source)
                unit_data.channeled_destructor = nil
            end


            local animation = nil
            local sequence = nil

            unit_data.skip_sfx_effects = false

            if action.animation then
                animation = action.animation
                sequence = animation.sequence
            end

            if sequence and sequence.tags and unit_data.animation_tag then
                sequence = sequence.tags[unit_data.animation_tag] or animation.sequence
            end

            --print(animation.timescale or 1.)
            local time_reduction = (animation.timescale or 1.) + (sequence.bonus_timescale or 0.)

            if action.action_type == SKILL_PHYSICAL then
                time_reduction = time_reduction * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01)
            elseif action.action_type == SKILL_MAGICAL then
                time_reduction = time_reduction * (1. - unit_data.stats[CAST_SPEED].value * 0.01)
            end

            if time_reduction <= 0. then time_reduction = 0. end

            SetUnitAnimationByIndex(source, 0)
            ResetUnitAnimation(source)


            local scale = 1. / time_reduction

            if scale <= 0.01 then scale = 0.01 end
            SetUnitTimeScale(source, scale * (sequence.animation_bonus_timescale or 1.))

            local additional_data = {
                time_reduction = time_reduction,
                action_id = action_id,
                level = 1,
                tags = {}
            }


            OnAction(source, target, additional_data, ability_instance)
            if GetUnitState(source, UNIT_STATE_LIFE) < 0.045 or (IsUnitStunned(source) or IsUnitFeared(source) or IsUnitFrozen(source)) then return end

            SetUnitFacing(source, angle)
            SafePauseUnit(source, true)
            SetUnitAnimationByIndex(source, sequence.animation or 0)
            if IsAHero(source) then PlayerCanChangeEquipment[GetPlayerId(GetOwningPlayer(source))+1] = false end

            PlayCastSfx(unit_data, action.sfx_pack or nil, time_reduction, target or nil, point_x, point_y)

                if action.sound then
                    local unit_x, unit_y = GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner)

                    if not unit_data.castsound then
                        unit_data.castsound = { }
                        unit_data.sound_delay_timer = { }
                    end

                    for i = 1, #action.sound do
                        local pack = action.sound[i]
                        local num = #unit_data.castsound + 1

                        unit_data.castsound[num] = CreateNew3DSound(pack[GetRandomInt(1, #pack)], unit_x, unit_y, 35., pack.volume or 128, pack.cutoff or 1600., pack.distance or 4000., false)
                        unit_data.sound_delay_timer[num] = CreateTimer()
                        local delay = (pack.delay or 0.) * time_reduction
                        if delay < 0. then delay = 0. end

                        TimerStart(unit_data.sound_delay_timer[num], delay, false, function()
                            StartSound(unit_data.castsound[num])
                            DestroyTimer(GetExpiredTimer())
                        end)
                    end

                end


            if action.motion then
                local angle

                    if not unit_data.nudge_timer then unit_data.nudge_timer = CreateTimer() end

                    if target and target ~= unit_data.Owner then angle = AngleBetweenUnits(unit_data.Owner, target)
                    elseif point_x ~= 0 then angle = AngleBetweenUnitXY(unit_data.Owner, point_x, point_y)
                    else angle = AngleBetweenUnitXY(unit_data.Owner, PlayerMousePosition[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1].x, PlayerMousePosition[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1].y) end

                    TimerStart(unit_data.nudge_timer, action.motion.delay * time_reduction, false, function()
                        NudgeUnit(unit_data.Owner, angle + (action.motion.bonus_angle or 0.), action.motion.power, action.motion.time * time_reduction, true)
                    end)

            end


            TimerStart(unit_data.action_timer, (sequence.animation_point or 0.) * time_reduction, false, function()

                if unit_data.cast_effect_pack then
                    for i = 1, #unit_data.cast_effect_pack do DestroyEffect(unit_data.cast_effect_pack[i]) end
                    unit_data.cast_effect_pack = nil
                end

                    if action.missile then
                        if target then
                            if target == source then
                                ThrowMissile(source, nil, action.missile, { effect = action.effect, additional_data.level, ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), 0., 0., GetUnitFacing(source), action.from_unit)
                            else
                                local angle = AngleBetweenUnits(source, target)
                                SetUnitFacing(source, angle)
                                ThrowMissile(source, target, action.missile, { effect = action.effect, additional_data.level, ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target), angle, action.from_unit) end
                        else
                            ThrowMissile(source, nil, action.missile, { effect = action.effect, additional_data.level, ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), point_x, point_y, AngleBetweenUnitXY(source, point_x, point_y), action.from_unit)
                        end
                    elseif action.effect then
                        if target and target ~= source then
                            SetUnitFacing(source, AngleBetweenUnits(source, target))
                            ApplyEffect(source, target, 0.,0., action.effect, additional_data.level, ability_instance)
                        elseif target and target == source then
                            ApplyEffect(source, target, GetUnitX(source), GetUnitY(source), action.effect, additional_data.level, ability_instance)
                        else
                            ApplyEffect(source, nil, point_x, point_y, action.effect, additional_data.level, ability_instance)
                        end

                    elseif action.aura then
                        ToggleAuraOnUnit(unit_data.Owner, action.aura, additional_data.level, true, ability_instance)
                    end

                TimerStart(unit_data.action_timer, (sequence.animation_backswing or 0.) * time_reduction, false, function ()
                    --print("start backswing")
                    SpellBackswing(source)
                end)

                OnActionEnd(source, target, point_x, point_y, action_id, ability_instance)

                if IsAHero(source) then PlayerCanChangeEquipment[GetPlayerId(GetOwningPlayer(source))+1] = true end

            end)

    end


    ---@param ability_instance table
    ---@param effect string
    ---@return boolean
    function AbilityInstanceHasEffect(ability_instance, effect)

        if ability_instance and ability_instance.proc_list[effect] then
            return true
        end

        return false
    end

    ---@param ability_instance table
    ---@param effect string
    function AbilityInstanceAddEffectProc(ability_instance, effect)
        if ability_instance.proc_list then
            ability_instance.proc_list[effect] = true
        end
    end

    ---@param ability_instance table
    ---@param instance string
    ---@param value real
    ---@param value_delta real
    ---@param modifier integer
    function ModifyAbilityInstance(ability_instance, instance, value, value_delta, modifier)
        if not ability_instance then return end

        if modifier == STRAIGHT_BONUS then ability_instance[instance] = (ability_instance[instance] or 0.) + value or 0.
        else ability_instance[instance] = (ability_instance[instance] or 0.) + ((value_delta or 0.) * (value or 0.)) end

    end


    function InitializeSkillEngine()
        local timer = CreateTimer()
        TimerStart(timer, 1., false, function()


            KEYBIND_LIST = {
                [KEY_Q] =  {
                    ability = FourCC('A016'),
                    name_string = " (|cffffcc00Q|r)",
                    bind_name = "[Q]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_web
                },
                [KEY_W] =  {
                    ability = FourCC('A01A'),
                    name_string = " (|cffffcc00W|r)",
                    bind_name = "[W]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_unholyfrenzy
                },
                [KEY_E] =  {
                    ability = FourCC('A01E'),
                    name_string = " (|cffffcc00E|r)",
                    bind_name = "[E]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_volcano
                },
                [KEY_R] =  {
                    ability = FourCC('A01I'),
                    name_string = " (|cffffcc00R|r)",
                    bind_name = "[R]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_voodoo
                },
                [KEY_D] =  {
                    ability = FourCC('A017'),
                    name_string = " (|cffffcc00D|r)",
                    bind_name = "[D]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_ward
                },
                [KEY_F] =  {
                    ability = FourCC('A018'),
                    name_string = " (|cffffcc00F|r)",
                    bind_name = "[F]",
                    player_skill_bind = {},
                    player_skill_bind_string_id = {},
                    order = order_undefend
                }
            }

            for i = 1, 6 do
                for key = KEY_Q, KEY_F do
                    KEYBIND_LIST[key].player_skill_bind[i] = 0
                end
            end

            PlayerSkillQueue = {}
            for i = 1, 6 do
                PlayerSkillQueue[i] = {}
            end

            for key = KEY_Q, KEY_F do
                KEYBIND_LIST[key].player_charges_frame = {}
                KEYBIND_LIST[key].trigger = CreateTrigger()
                for i = 1, 6 do KEYBIND_LIST[key].player_charges_frame[i] = {} end
                TriggerAddAction(KEYBIND_LIST[key].trigger, function()
                    local player = GetPlayerId(GetTriggerPlayer()) + 1

                    if SkillPanelKeybindActive[player] then return end

                        if KEYBIND_LIST[key].player_skill_bind[player] ~= 0 and not IsUnitDisabled(PlayerHero[player]) then
                            if BlzGetUnitAbilityManaCost(PlayerHero[player], KEYBIND_LIST[key].ability, 0) > GetUnitState(PlayerHero[player], UNIT_STATE_MANA) then
                                Feedback_NoResource(player)
                            else
                                local skill = GetUnitSkillData(PlayerHero[player], KEYBIND_LIST[key].player_skill_bind_string_id[player])

                                if skill then

                                    if skill.activation_type == SELF_CAST then
                                        if PlayerSkillQueue[player].is_casting_skill then
                                            PlayerSkillQueue[player].queue_skill = KEYBIND_LIST[key].order
                                            PlayerSkillQueue[player].queue_skill_activation_type = skill.activation_type
                                        else
                                            IssueImmediateOrderById(PlayerHero[player], KEYBIND_LIST[key].order)
                                        end
                                    else
                                        local range
                                        local target = GetClosestUnitToCursor(player)
                                        local angle = AngleBetweenUnitXY(PlayerHero[player], PlayerMousePosition[player].x, PlayerMousePosition[player].y)

                                            if skill.always_max_range_cast then range = skill.level[UnitGetAbilityLevel(PlayerHero[player], skill.Id)].range
                                            else range = math.min(DistanceBetweenUnitXY(PlayerHero[player], PlayerMousePosition[player].x, PlayerMousePosition[player].y), (skill.level[UnitGetAbilityLevel(PlayerHero[player], skill.Id)].range or 99999.)) end


                                            if PlayerSkillQueue[player].is_casting_skill then
                                                PlayerSkillQueue[player].queue_skill = KEYBIND_LIST[key].order
                                                PlayerSkillQueue[player].queue_skill_activation_type = skill.activation_type
                                                PlayerSkillQueue[player].queue_skill_range = range

                                                    if target and (skill.activation_type == TARGET_CAST or skill.activation_type == POINT_AND_TARGET_CAST) and IsUnitInRange(PlayerHero[player], target, range) then
                                                        PlayerSkillQueue[player].queue_skill_target = target
                                                    else
                                                        PlayerSkillQueue[player].queue_skill_x = GetUnitX(PlayerHero[player]) + Rx(range, angle)
                                                        PlayerSkillQueue[player].queue_skill_y = GetUnitY(PlayerHero[player]) + Ry(range, angle)
                                                    end

                                            else
                                                if target and (skill.activation_type == TARGET_CAST or skill.activation_type == POINT_AND_TARGET_CAST) and IsUnitInRange(PlayerHero[player], target, range) then
                                                    IssueTargetOrderById(PlayerHero[player], KEYBIND_LIST[key].order, target)
                                                else
                                                    IssuePointOrderById(PlayerHero[player], KEYBIND_LIST[key].order, GetUnitX(PlayerHero[player]) + Rx(range, angle), GetUnitY(PlayerHero[player]) + Ry(range, angle))
                                                end
                                            end


                                    end
                                end

                            end
                        end
                end)
            end

            local attack_trigger_quickcast = CreateTrigger()
            for i = 0, 5 do BlzTriggerRegisterPlayerKeyEvent(attack_trigger_quickcast, Player(i), OSKEY_A, 0, true) end

            TriggerAddAction(attack_trigger_quickcast, function()
                local player = GetPlayerId(GetTriggerPlayer()) + 1
                local target = GetClosestUnitToCursor(player)

                    if target then
                        IssueTargetOrderById(PlayerHero[player], order_attack, target)
                    else
                        IssuePointOrderById(PlayerHero[player], order_attack, PlayerMousePosition[player].x, PlayerMousePosition[player].y)
                    end

                    if GetLocalPlayer() == Player(player-1) then ForceUICancel() end

            end)



            for i = 1, 6 do
                PlayerUI.skill_button_charges[i] = {}
                PlayerUI.skill_button_charges[i].button = {}
                for key = 1, 6 do
                    PlayerUI.skill_button_charges[i].button[key] = CreateUIChargesBorder(PlayerUI.skill_button_borders[key])
                end
            end


            for i = 1, 6 do
                KEYBIND_LIST[KEY_Q].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[3]
                KEYBIND_LIST[KEY_W].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[2]
                KEYBIND_LIST[KEY_E].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[1]
                KEYBIND_LIST[KEY_R].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[4]
                KEYBIND_LIST[KEY_D].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[5]
                KEYBIND_LIST[KEY_F].player_charges_frame[i] = PlayerUI.skill_button_charges[i].button[6]
            end

            for player = 0, 5 do
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_Q].trigger, Player(player), OSKEY_Q, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_W].trigger, Player(player), OSKEY_W, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_E].trigger, Player(player), OSKEY_E, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_R].trigger, Player(player), OSKEY_R, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_D].trigger, Player(player), OSKEY_D, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(KEYBIND_LIST[KEY_F].trigger, Player(player), OSKEY_F, 0, true)
            end


            local track_skill_bug = false

            local SkillCastTrigger = CreateTrigger()
            TriggerRegisterAnyUnitEventBJ(SkillCastTrigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            TriggerAddAction(SkillCastTrigger, function()

                local id = GetSpellAbilityId()
                local skill = GetKeybindAbility(id, GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1)

                if skill == 0 then skill = GetSkillData(id)
                else skill = GetSkillData(skill) end


                if skill then

                    local unit_data = GetUnitData(GetTriggerUnit())
                    skill = GetUnitSkillData(unit_data.Owner, skill.Id)

                    if skill == nil then return end

                    unit_data.skip_sfx_effects = false
                    unit_data.cast_skill_id = skill.Id

                    local ability_level = UnitGetAbilityLevel(unit_data.Owner, skill.Id)
                    local manacost = SuperRound(((skill.level[ability_level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier)

                    local target = GetSpellTargetUnit()
                    local spell_x = GetSpellTargetX()
                    local spell_y = GetSpellTargetY()


                    if skill.required_weapon then
                        if not CanCastSkillWithWeapon(skill, unit_data.equip_point[WEAPON_POINT].SUBTYPE) then
                            local player_id = GetPlayerId(GetOwningPlayer(unit_data.Owner))+1
                            local alt_weapon = GetAlternateWeaponSlotItem(player_id)
                            local alt_weapon_data = GetItemData(alt_weapon)

                                if alt_weapon and CanCastSkillWithWeapon(skill, alt_weapon_data.SUBTYPE) then
                                    SwitchHeroWeapon(player_id)
                                else
                                    local unit = GetTriggerUnit()
                                    local player = GetPlayerId(GetOwningPlayer(unit))

                                        IssueImmediateOrderById(unit, order_stop)
                                        DelayAction(0.0, function() SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + manacost) end)
                                        SimError(LOCALE_LIST[my_locale].INVALID_WEAPON_FEEDBACK, player)
                                        Feedback_CantUse(player + 1)
                                        return
                                end

                        end
                    end

                    if (target and GetWidgetLife(target) <= 0.045) then
                        if skill.activation_type == POINT_AND_TARGET_CAST then
                            spell_x, spell_y = GetUnitX(target), GetUnitY(target)
                        elseif skill.activation_type == TARGET_CAST then
                            IssueImmediateOrderById(unit_data.Owner, order_stop)
                            DelayAction(0.0, function() SetUnitState(unit_data.Owner, UNIT_STATE_MANA, GetUnitState(unit_data.Owner, UNIT_STATE_MANA) + manacost) end)
                            return
                        end
                    end

                    if skill.custom_condition then
                        local x, y

                        if target == nil or (target and GetWidgetLife(target) <= 0.045) then x, y = spell_x, spell_y
                        else x, y = GetUnitX(target), GetUnitY(target) end

                            if not skill.custom_condition(unit_data.Owner, x, y, target) then
                                IssueImmediateOrderById(unit_data.Owner, order_stop)
                                DelayAction(0.0, function() SetUnitState(unit_data.Owner, UNIT_STATE_MANA, GetUnitState(unit_data.Owner, UNIT_STATE_MANA) + manacost) end)
                                Feedback_CantUse(GetPlayerId(GetOwningPlayer(unit_data.Owner)) + 1)
                                return
                            end

                    end


                    if not skill.channel then
                        if unit_data.channeled_destructor then
                            unit_data.channeled_destructor(unit_data.Owner)
                            unit_data.channeled_destructor = nil
                        end
                    end


                    local animation = nil
                    local sequence = nil

                    if skill.animation then
                        animation = skill.animation
                        sequence = animation.sequence
                    end

                    if sequence and sequence.tags and unit_data.animation_tag then
                        sequence = sequence.tags[unit_data.animation_tag] or skill.animation.sequence
                    end

                    local time_reduction = (animation.timescale or 1.) + (sequence.bonus_timescale or 0.)

                        if skill.type == SKILL_PHYSICAL then
                            time_reduction = time_reduction * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01)
                        elseif skill.type == SKILL_MAGICAL then
                            time_reduction = time_reduction * (1. - unit_data.stats[CAST_SPEED].value * 0.01)
                        end

                        if time_reduction <= 0. then time_reduction = 0. end

                    SetUnitAnimationByIndex(unit_data.Owner, 0)
                    ResetUnitAnimation(unit_data.Owner)


                    local scale = 1. / time_reduction
                    --if time_reduction < 1. then scale = 1. / time_reduction
                    --else scale = 1. + (1. - time_reduction) end

                    if scale <= 0.01 then scale = 0.01 end
                    SetUnitTimeScale(unit_data.Owner, scale * (sequence.animation_bonus_timescale or 1.))

                    --print("result cast time is " .. ((sequence.animation_point or 0.) * time_reduction))
                    --print("skill cooldown is " .. R2S(skill.level[ability_level].cooldown))
                    --print("ability level is " .. I2S(ability_level))
                    -- 0.4 * 2. -> 0.8 /// 0.4 * 0.5 -> 0.2


                    local skill_additional_data = {
                        time_reduction = time_reduction,
                        ability_level = ability_level,
                        cooldown = ((skill.level[ability_level].cooldown or 0.1) + ((sequence.animation_point or 0.) * time_reduction)) * GetUnitParameterValue(unit_data.Owner, COOLDOWN_REDUCTION),
                        manacost = manacost,
                        proc_list = {},
                        proc_rate = skill.proc_rate or 1.,
                        tags = {},
                    }

                    if skill_additional_data.manacost < 0. then skill_additional_data.manacost = 0 end
                    --local manacost = ((skill.level[ability_level].resource_cost or 0.) + unit_data.stats[MANACOST].bonus) * unit_data.stats[MANACOST].multiplier


                    if IsAHero(unit_data.Owner) then PlayerCanChangeEquipment[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1] = false end

                    local player_id = GetPlayerId(GetOwningPlayer(unit_data.Owner)) + 1

                    if IsAHero(unit_data.Owner) then
                        PlayerSkillQueue[player_id].is_casting_skill = true
                    end

                    OnSkillPrecast(unit_data.Owner, target, skill, ability_level, skill_additional_data)


                    if skill.classification == SKILL_CLASS_ATTACK and unit_data.attack_status[ATTACK_STATUS_CRITICAL][1] then
                        unit_data.attack_status[ATTACK_STATUS_CRITICAL][1].amount = unit_data.attack_status[ATTACK_STATUS_CRITICAL][1].amount - 1
                        if unit_data.attack_status[ATTACK_STATUS_CRITICAL][1].amount <= 0 then RemoveBuff(unit_data.Owner, unit_data.attack_status[ATTACK_STATUS_CRITICAL][1].buff_id) end
                        skill_additional_data.critical_strike_flag = true
                    end


                    if skill.current_charges then
                        local player = GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1
                        skill.current_charges = skill.current_charges - 1

                        if not skill.charges_timers then skill.charges_timers = {} end

                            if skill.current_charges > 0 then
                                BlzSetUnitAbilityCooldown(unit_data.Owner, id, 0, 0.)
                            else
                                local lowest = skill_additional_data.cooldown

                                    if #skill.charges_timers > 0 then
                                        for i = 1, #skill.charges_timers do
                                            if TimerGetRemaining(skill.charges_timers[i]) > 0. and TimerGetRemaining(skill.charges_timers[i]) < lowest then
                                                lowest = TimerGetRemaining(skill.charges_timers[i])
                                            end
                                        end
                                    end

                                BlzSetUnitAbilityCooldown(unit_data.Owner, id, 0, lowest)
                            end



                        if skill.separate_recharge then
                            local timer = skill.charges_timers[1] or nil

                                if not timer then
                                    timer = CreateTimer()
                                    skill.charges_timers[1] = timer

                                        TimerStart(timer, skill_additional_data.cooldown, true, function()
                                            skill.current_charges = skill.current_charges + 1

                                            if skill.current_charges >= skill.current_max_charges then
                                                skill.current_charges = skill.current_max_charges
                                                DestroyTimer(skill.charges_timers[1])
                                                skill.charges_timers[1] = nil
                                            end

                                            if IsAbilityKeybinded(FourCC(skill.Id), player) then
                                                BlzFrameSetText(KEYBIND_LIST[GetKeybindKey(FourCC(skill.Id), player)].player_charges_frame[player].text, skill.current_charges)
                                            end

                                        end)
                                end


                        else
                            local timer = CreateTimer()
                            skill.charges_timers[#skill.charges_timers+1] = timer

                                TimerStart(timer, skill_additional_data.cooldown, false, function()

                                    for i = 1, #skill.charges_timers do
                                        if skill.charges_timers[i] == timer then
                                            DestroyTimer(skill.charges_timers[i])
                                            table.remove(skill.charges_timers, i)
                                            break
                                        end
                                    end

                                    skill.current_charges = skill.current_charges + 1
                                    if skill.current_charges > skill.current_max_charges then skill.current_charges = skill.current_max_charges end
                                    if IsAbilityKeybinded(FourCC(skill.Id), player) then
                                        BlzFrameSetText(KEYBIND_LIST[GetKeybindKey(FourCC(skill.Id), player)].player_charges_frame[player].text, skill.current_charges)
                                        if BlzGetUnitAbilityCooldownRemaining(unit_data.Owner, GetKeybindKeyAbility(FourCC(skill.Id), player)) > 0. then
                                            BlzEndUnitAbilityCooldown(unit_data.Owner, GetKeybindKeyAbility(FourCC(skill.Id), player))
                                        end
                                    end
                                end)

                        end

                        BlzFrameSetText(KEYBIND_LIST[GetKeybindKey(FourCC(skill.Id), player)].player_charges_frame[player].text, skill.current_charges)

                    else
                        BlzSetUnitAbilityCooldown(unit_data.Owner, id, 0, skill_additional_data.cooldown)
                    end


                    BlzSetUnitAbilityManaCost(unit_data.Owner, id, 0, skill_additional_data.manacost)


                    unit_data.cast_skill = id
                    unit_data.cast_skill_level = ability_level
                    unit_data.cast_skill_mana = skill_additional_data.manacost

                    SafePauseUnit(unit_data.Owner, true)
                    SetUnitAnimationByIndex(unit_data.Owner, sequence.animation or 0)

                    if skill.motion and not IsUnitRooted(unit_data.Owner) then
                        if not unit_data.nudge_timer then unit_data.nudge_timer = CreateTimer() end
                        local angle

                            if target and target ~= unit_data.Owner then angle = AngleBetweenUnits(unit_data.Owner, target)
                            elseif spell_x ~= 0 then angle = AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y)
                            else angle = AngleBetweenUnitXY(unit_data.Owner, PlayerMousePosition[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1].x, PlayerMousePosition[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1].y) end

                        TimerStart(unit_data.nudge_timer, skill.motion.delay * time_reduction, false, function()
                            NudgeUnit(unit_data.Owner, angle + (skill.motion.bonus_angle or 0.), skill.motion.power, skill.motion.time * time_reduction, true)
                        end)
                    end

                    PlayCastSfx(unit_data, skill.sfx_pack, time_reduction, target, spell_x, spell_y)

                        if skill.level[ability_level].effect_on_caster then
                            unit_data.cast_effect = AddSpecialEffectTarget(skill.level[ability_level].effect_on_caster, unit_data.Owner, skill.level[ability_level].effect_on_caster_point)
                            BlzSetSpecialEffectScale(unit_data.cast_effect, skill.level[ability_level].effect_on_caster_scale or 1.)
                        end

                        if skill.level[ability_level].start_effect_on_cast_point then
                            bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].start_effect_on_cast_point, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner))
                            BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].start_effect_on_cast_point_scale or 1.)
                            DestroyEffect(bj_lastCreatedEffect)
                        end


                        if skill.sound and #skill.sound > 0 then
                            local unit_x, unit_y = GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner)

                            if not unit_data.castsound then
                                unit_data.castsound = { }
                                unit_data.sound_delay_timer = { }
                            end

                            for i = 1, #skill.sound do
                                local pack = skill.sound[i]
                                local num = #unit_data.castsound + 1

                                unit_data.castsound[num] = CreateNew3DSound(pack[GetRandomInt(1, #pack)], unit_x, unit_y, 35., pack.volume or 128., pack.cutoff or 1600., pack.distance or 4000., false)
                                unit_data.sound_delay_timer[num] = CreateTimer()
                                local delay = (pack.delay or 0.) * time_reduction
                                if delay < 0. then delay = 0. end

                                    TimerStart(unit_data.sound_delay_timer[num], delay, false, function()
                                        StartSound(unit_data.castsound[num])
                                        DestroyTimer(GetExpiredTimer())
                                    end)
                            end

                        end

                    if GetUnitState(unit_data.Owner, UNIT_STATE_LIFE) < 0.045 or HasAnyDisableState(unit_data.Owner) then return end

                    OnSkillCast(unit_data.Owner, target, spell_x, spell_y, skill, ability_level, skill_additional_data)


                        TimerStart(unit_data.action_timer, (sequence.animation_point or 0.) * time_reduction, false, function()
                            --print("cast action")
                            unit_data.cast_skill = 0
                            DestroyEffect(unit_data.cast_effect)

                            if unit_data.cast_effect_pack then
                                for i = 1, #unit_data.cast_effect_pack do DestroyEffect(unit_data.cast_effect_pack[i]) end
                                unit_data.cast_effect_pack = nil
                            end

                            if skill.level[ability_level].end_effect_on_cast_point then
                                bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].end_effect_on_cast_point, spell_x, spell_y)
                                BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].end_effect_on_cast_point_scale or 1.)
                                DestroyEffect(bj_lastCreatedEffect)
                            end

                                if skill.autotrigger then
                                    if skill.level[ability_level].missile then
                                        if target then
                                            if target == unit_data.Owner then
                                                --print("throw missile")
                                                ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level, ability_instance = skill_additional_data },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), 0., 0., GetUnitFacing(unit_data.Owner), skill.level[ability_level].from_unit)
                                                --print("throw missile end")
                                            else
                                                --print("throw missile")
                                                local angle = AngleBetweenUnits(unit_data.Owner, target)
                                                SetUnitFacing(unit_data.Owner, angle)
                                                ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level, ability_instance = skill_additional_data },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target), angle, skill.level[ability_level].from_unit)
                                                --print("throw missile end")
                                            end
                                        else
                                            --print("throw missile")
                                            ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level, ability_instance = skill_additional_data },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), spell_x, spell_y, AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y), skill.level[ability_level].from_unit)
                                            --print("throw missile end")
                                        end

                                    elseif skill.level[ability_level].effect then
                                        if target and target ~= unit_data.Owner then
                                            SetUnitFacing(unit_data.Owner, AngleBetweenUnits(unit_data.Owner, target))
                                            ApplyEffect(unit_data.Owner, target, 0.,0., skill.level[ability_level].effect, ability_level, skill_additional_data)
                                        elseif target and target == unit_data.Owner then
                                            ApplyEffect(unit_data.Owner, target, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), skill.level[ability_level].effect, ability_level, skill_additional_data)
                                        else
                                            ApplyEffect(unit_data.Owner, nil, spell_x, spell_y, skill.level[ability_level].effect, ability_level, skill_additional_data)
                                        end

                                    elseif skill.level[ability_level].aura then
                                        ToggleAuraOnUnit(unit_data.Owner, skill.level[ability_level].aura, ability_level, true, skill_additional_data)
                                    end
                                end

                            TimerStart(unit_data.action_timer, (sequence.animation_backswing or 0.) * time_reduction, false, function ()
                                --print("backswing start")
                                local casting_queue_skill

                                    if IsAHero(unit_data.Owner) then casting_queue_skill = PlayerSkillQueue[player_id].queue_skill end

                                SpellBackswing(unit_data.Owner)

                                    if casting_queue_skill then

                                         if GetUnitState(PlayerHero[player_id], UNIT_STATE_LIFE) > 0.045 and not IsUnitDisabled(PlayerHero[player_id]) then

                                            if (PlayerSkillQueue[player_id].queue_skill_activation_type == TARGET_CAST or PlayerSkillQueue[player_id].queue_skill_activation_type == POINT_AND_TARGET_CAST) and PlayerSkillQueue[player_id].queue_skill_target and IsUnitInRange(PlayerHero[player_id], PlayerSkillQueue[player_id].queue_skill_target, PlayerSkillQueue[player_id].queue_skill_range) then

                                                if GetUnitState(PlayerSkillQueue[player_id].queue_skill_target, UNIT_STATE_LIFE) > 0.045 then
                                                    IssueTargetOrderById(PlayerHero[player_id], casting_queue_skill, PlayerSkillQueue[player_id].queue_skill_target)
                                                end

                                            elseif PlayerSkillQueue[player_id].queue_skill_activation_type == POINT_CAST or PlayerSkillQueue[player_id].queue_skill_activation_type == POINT_AND_TARGET_CAST then
                                                IssuePointOrderById(PlayerHero[player_id], casting_queue_skill, PlayerSkillQueue[player_id].queue_skill_x, PlayerSkillQueue[player_id].queue_skill_y)
                                            else
                                               IssueImmediateOrderById(PlayerHero[player_id], casting_queue_skill)
                                            end
                                        end
                                    end

                            end)

                            OnSkillCastEnd(unit_data.Owner, target, spell_x, spell_y, skill, ability_level, skill_additional_data)

                            if skill.sound and skill.sound.on_cast_end then
                                AddSoundVolume(skill.sound.on_cast_end[GetRandomInt(1, #skill.sound.on_cast_end)], GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), skill.sound.on_cast_end.volume or 128, skill.sound.on_cast_end.cutoff or 1600., skill.sound.on_cast_end.distance or 4000.)
                            end

                            if IsAHero(unit_data.Owner) then PlayerCanChangeEquipment[GetPlayerId(GetOwningPlayer(unit_data.Owner))+1] = true end

                        end)

                end

            end)



            DestroyTimer(GetExpiredTimer())
        end)


    end


end