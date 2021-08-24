do


    KEY_Q = 1
    KEY_W = 2
    KEY_E = 3
    KEY_R = 4
    KEY_D = 5
    KEY_F = 6


    KEYBIND_LIST = 0


    function UnbindAbilityKey(unit, id)
        local player = GetPlayerId(GetOwningPlayer(unit)) + 1

            for i = KEY_Q, KEY_F do
                if KEYBIND_LIST[i].player_skill_bind[player] == FourCC(id) then
                    UnitRemoveAbility(unit, KEYBIND_LIST[i].ability)
                    KEYBIND_LIST[i].player_skill_bind[player] = 0
                    break
                end
            end

    end


    local function GetStringEnding(string, from)

        for i = from, StringLength(string) do
            if SubString(string, i, i + 1) == "#" then
                return i + 1
            end
        end

        return StringLength(string)
    end


    function ParseString(str, tag, lvl)
        local value_str = SubString(str, 8, GetStringEnding(str, 8)-1)
        local id = SubString(str, 3,  7)

            if tag == "e" then
                local effect = GetEffectData(id)

                if effect == nil then
                    return "invalid effect"
                end

                GenerateEffectLevelData(effect, lvl)

                    if value_str == "pwr" then return "|c00FF7600" .. (effect.level[lvl].power or 0) .. "|r"
                    elseif value_str == "dmg" then return "|c00FF7600" .. (effect.level[lvl].power or 0) .. " + " .. S2I(R2S((effect.level[lvl].attack_percent_bonus or 1.) * 100.)) .. "%%|r " .. LOCALE_LIST[my_locale].GENERATED_TOOLTIP
                    elseif value_str == "atr" then return "|c007AB3FF" .. GetItemAttributeName(effect.level[lvl].attribute) .. "|r"
                    elseif value_str == "ap" then return math.floor((effect.level[lvl].attack_percent_bonus or 1.) * 100.)
                    elseif value_str == "ab" then return "|c007AB3FF" ..  (effect.level[lvl].attribute_bonus or 0) .. "|r"
                    elseif value_str == "wdpb" then return math.floor((effect.level[lvl].weapon_damage_percent_bonus or 1.) * 100.)
                    elseif value_str == "aoe" then return R2I(effect.level[lvl].area_of_effect or 0.)
                    elseif value_str == "bcc" then return "|c00FFD900" .. R2I(effect.level[lvl].bonus_crit_chance or 0.) .. "%%|r"
                    elseif value_str == "bcm" then return "|c00FFD900" .. (effect.level[lvl].bonus_crit_multiplier or 0.) .. "|r"
                    elseif value_str == "hp_perc" then return "|c0000FF00" .. string.format('%%.1f', (effect.level[lvl].life_percent_restored or 0.) * 100.) .. "%%|r"
                    elseif value_str == "mp_perc" then return "|c000066FF" .. string.format('%%.1f', (effect.level[lvl].resource_percent_restored or 0.) * 100.) .. "%%|r"
                    elseif value_str == "hp" then return "|c0000FF00" .. (effect.level[lvl].life_restored or 0.) .. "|r"
                    elseif value_str == "mp" then return "|c000066FF" .. (effect.level[lvl].resource_restored or 0.) .. "|r" end

            elseif tag == "s" then
                local skill = GetSkillData(FourCC(id))

                GenerateSkillLevelData(skill, lvl)

                    if value_str == "rc" then return R2I(skill.level[lvl].resource_cost or 0)
                    elseif value_str == "cld" then return skill.level[lvl].cooldown or 0.1
                    elseif value_str == "rng" then return "|c0000DBA4" .. R2I(skill.level[lvl].range or 0.) .. "|r" end

            elseif tag == "b" then
                local buff = GetBuffData(id)

                if buff == nil then
                    return "invalid buff"
                end

                    GenerateBuffLevelData(buff, lvl)

                    if value_str == "time" then return buff.level[lvl].time or 0.1
                    elseif SubString(value_str, 0,  2) == "va" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return "|c00FF7600" .. GetCorrectParamText(param.PARAM, param.VALUE, param.METHOD) .. "|r"
                    elseif SubString(value_str, 0,  2) == "pa" then
                        local param = buff.level[lvl].bonus[S2I(SubString(value_str, 2, 3))]
                        return GetParameterName(param.PARAM)
                    end

            elseif tag == "m" then
                local missile = GetMissileData(id)

                    if value_str == "rad" then return "|c0000DBA4" .. (R2I(missile.radius or 0)) .. "|r"
                    elseif value_str == "maxd" then return R2I(missile.max_distance) or 0 end

            end

        return ""
    end




    function ParseLocalizationSkillTooltipString(str, level)
        local last_sector = 0
        local result_string = ""
        local my_string_table = {}
        local ending_number = 0

            for i = 0, StringLength(str) do
                if SubString(str, i, i+1) == "@" then
                    ending_number = GetStringEnding(str, i)
                    local value_string = SubString(str, i, ending_number)
                    my_string_table[#my_string_table+1] = SubString(str, last_sector, i) .. ParseString(value_string, SubString(str, i+1, i+2), level)
                    i = ending_number
                    last_sector = i
                end
            end

        my_string_table[#my_string_table+1] = SubString(str, last_sector, StringLength(str))
        for i = 1, #my_string_table do result_string = result_string .. my_string_table[i] end

        return result_string
    end


    ---@param unit unit
    ---@param id string
    ---@param player number
    function SetAbilityExtendedTooltip(unit, id, player)
        local true_id = FourCC(id)
        local ability = GetKeybindKeyAbility(true_id, player)

        --print("================================")
        --print("SetAbilityExtendedTooltip - ability " .. ability)
        --print("SetAbilityExtendedTooltip - id " .. true_id)


            if ability == 0 then return end
            local lvl = UnitGetAbilityLevel(unit, id)
            --print("SetAbilityExtendedTooltip - ability level " .. lvl)

                if LOCALE_LIST[my_locale][true_id] then
                    --local proper_level_data = lvl

                    if LOCALE_LIST[my_locale][true_id][lvl] then
                        --print("SetAbilityExtendedTooltip - exists")
                        local description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][lvl], lvl)
                        --print("SetAbilityExtendedTooltip - description " .. description)
                        if GetLocalPlayer() == Player(player-1) then
                            BlzSetAbilityExtendedTooltip(ability, description, 0)
                        end
                    else
                        --print("has " .. lvl .. " elemets")
                        for i = lvl, 1, -1 do
                            --print("checking ".. i)
                            if LOCALE_LIST[my_locale][true_id][i] then
                                --print("SetAbilityExtendedTooltip - local string" .. LOCALE_LIST[my_locale][true_id][i])
                                local description = ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id][i], lvl)
                                --print("SetAbilityExtendedTooltip - description " .. description)
                                if GetLocalPlayer() == Player(player-1) then
                                    BlzSetAbilityExtendedTooltip(ability, description, 0)
                                end
                                break
                            end
                        end
                    end
                    --BlzSetAbilityExtendedTooltip(ability, ParseLocalizationSkillTooltipString(LOCALE_LIST[my_locale][true_id].bind, lvl), 0)
                end


    end


    function UpdateBindedSkillsData(player)

            for key = KEY_Q, KEY_F do
                if KEYBIND_LIST[key].player_skill_bind[player] and KEYBIND_LIST[key].player_skill_bind[player] ~= 0 then
                    local skill = GetSkillData(KEYBIND_LIST[key].player_skill_bind[player])
                    local ability = BlzGetUnitAbility(PlayerHero[player], KEYBIND_LIST[key].ability)
                    local level = UnitGetAbilityLevel(PlayerHero[player], skill.Id)

                        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
                        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
                        BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)
                        BlzSetUnitAbilityManaCost(PlayerHero[player], KEYBIND_LIST[key].ability, 0, R2I(skill.level[level].resource_cost or 0.))
                        SetAbilityExtendedTooltip(PlayerHero[player], skill.Id, player)
                end
            end

    end


    ---@param id integer
    ---@param player number
    function UpdateBindedSkillData(id, player)

        if IsAbilityKeybinded(FourCC(id), player) then
            --print("UpdateBindedSkillData - ability keybinded!")
            --print("UpdateBindedSkillData - id " .. FourCC(id))
            local skill = GetUnitSkillData(PlayerHero[player], id)
            --print("UpdateBindedSkillData - skill id " .. skill.Id)
            local ability_id = GetKeybindKeyAbility(FourCC(id), player)
            --print("UpdateBindedSkillData - ability id " .. ability_id)
            local ability = BlzGetUnitAbility(PlayerHero[player], ability_id)
            --print("UpdateBindedSkillData - ability handle " .. GetHandleId(ability))
            local level = UnitGetAbilityLevel(PlayerHero[player], id)
            --print("UpdateBindedSkillData - ability level " .. level)

                BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
                --print("UpdateBindedSkillData - cast range done " .. skill.level[level].range)
                BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
                --print("UpdateBindedSkillData - radius done " .. skill.level[level].radius)
                BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)
                --print("UpdateBindedSkillData - activation type done " .. skill.activation_type)
                BlzSetUnitAbilityManaCost(PlayerHero[player], ability_id, 0, R2I(skill.level[level].resource_cost or 0.))
                --print("UpdateBindedSkillData - mana cost done " .. R2I(skill.level[level].resource_cost))
                SetAbilityExtendedTooltip(PlayerHero[player], id, player)
                --print("UpdateBindedSkillData - SetAbilityExtendedTooltip done")
        end

    end

    ---@param unit unit
    ---@param id string
    ---@param key integer
    function BindAbilityKey(unit, id, key)
        local skill = GetAbilityFromUnit(unit, id)--GetSkillData(FourCC(id))
        local ability_id = KEYBIND_LIST[key].ability
        local ability


            if GetUnitAbilityLevel(unit, ability_id) == 0 then
                UnitAddAbility(unit, ability_id)
            end

            ability = BlzGetUnitAbility(unit, ability_id)
            local level = UnitGetAbilityLevel(unit, id)


            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_CAST_RANGE, 0, skill.level[level].range or 0.)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, skill.level[level].radius or 0.)
            BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_TARGET_TYPE, 0, skill.activation_type)
            BlzSetUnitAbilityManaCost(unit, ability_id, 0, R2I(skill.level[level].resource_cost or 0.))

            --print("BindAbilityKey - start")
            --print("BindAbilityKey - id ".. ability_id)
            --print("BindAbilityKey - name ".. skill.name)
            --print("BindAbilityKey - bind name ".. KEYBIND_LIST[key].name_string)
            --print("BindAbilityKey - icon ".. skill.icon)

                if GetLocalPlayer() == GetOwningPlayer(unit) then
                    BlzSetAbilityTooltip(ability_id, skill.name .. KEYBIND_LIST[key].name_string, 0)
                    BlzSetAbilityIcon(ability_id, skill.icon)
                end


        KEYBIND_LIST[key].player_skill_bind[GetPlayerId(GetOwningPlayer(unit)) + 1] = FourCC(id)
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
    function GetKeybindAbility(id, player)

        for key = KEY_Q, KEY_F do
            if KEYBIND_LIST[key].ability == id then
                return KEYBIND_LIST[key].player_skill_bind[player]
            end
        end

        return 0
    end


    ---@param unit unit
    ---@param id string
    ---@param amount integer
    function UnitAddAbilityLevel(unit, id, amount)
        local unit_data = GetUnitData(unit)

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
    function UnitGetAbilityLevel(unit, id)
        local unit_data = GetUnitData(unit)
        local ability_level = 0
        local skill

            for i = 1, #unit_data.skill_list do
                if unit_data.skill_list[i].Id == id then
                    ability_level = unit_data.skill_list[i].current_level
                    skill = unit_data.skill_list[i]
                    break
                end
            end

            for i = WEAPON_POINT, NECKLACE_POINT do
                if unit_data.equip_point[i] and unit_data.equip_point[i].SKILL_BONUS then
                    for skill_bonus = 1, #unit_data.equip_point[i].SKILL_BONUS do
                        if (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id and unit_data.equip_point[i].SKILL_BONUS[skill_bonus].id == id) or
                                (unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category and skill.category == unit_data.equip_point[i].SKILL_BONUS[skill_bonus].category) then
                            ability_level = ability_level + unit_data.equip_point[i].SKILL_BONUS[skill_bonus].bonus_levels
                        end
                    end
                end
            end

        if skill[ability_level] == nil then
            GenerateSkillLevelData(skill, ability_level)
        end

        --UpdateBindedSkillData(id, GetPlayerId(GetOwningPlayer(unit)) + 1)

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

    local function PlayCastSfx(unit_data, pack)

        if pack then

            unit_data.cast_effect_pack = {}
            unit_data.cast_effect_permanent_pack = {}

                if pack.on_caster then
                    for i = 1, #pack.on_caster do

                        if not pack.on_caster[i].conditional_weapon or HasConditionalWeapon(pack.on_caster[i], unit_data.equip_point[WEAPON_POINT].SUBTYPE) then
                            local casteffect = AddSpecialEffectTarget(pack.on_caster[i].effect, unit_data.Owner, pack.on_caster[i].point or "chest")
                            BlzSetSpecialEffectScale(casteffect, pack.on_caster[i].scale or 1.)

                                if pack.on_caster[i].duration and pack.on_caster[i].duration > 0. then
                                    local timer = CreateTimer()
                                    TimerStart(timer, pack.on_caster[i].duration, false, function()
                                        DestroyEffect(casteffect)
                                        DestroyTimer(GetExpiredTimer())
                                    end)
                                elseif pack.on_caster[i].permanent then
                                    unit_data.cast_effect_pack[#unit_data.cast_effect_pack+1] = casteffect
                                else
                                    unit_data.cast_effect_permanent_pack[#unit_data.cast_effect_permanent_pack+1] = casteffect
                                end

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
            end

            BlzUnitInterruptAttack(unit)

            SafePauseUnit(unit, false)

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
                    DestroyEffect(unit_data.cast_effect_permanent_pack[i])
                end
                unit_data.cast_effect_permanent_pack = nil
            end

            TimerStart(unit_data.action_timer, 0., false, nil)
            --PauseTimer(unit_data.action_timer)

                if unit_data.castsound then
                    StopSound(unit_data.castsound, true, true)
                end

                if unit_data.cast_skill > 0 then
                    BlzEndUnitAbilityCooldown(unit, unit_data.cast_skill)
                    SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + BlzGetUnitAbilityManaCost(unit, GetKeybindAbility(unit_data.cast_skill, GetPlayerId(GetOwningPlayer(unit)) + 1), 0))
                end

            unit_data.cast_skill = 0
    end


    ---@param unit unit
    function SpellBackswing(unit)
        local unit_data = GetUnitData(unit)

            SafePauseUnit(unit, false)
            IssueImmediateOrderById(unit, order_stop)
            SetUnitAnimation(unit, "Stand Ready")
            SetUnitTimeScale(unit, 1.)

            if unit_data.cast_effect_permanent_pack then
                for i = 1, #unit_data.cast_effect_permanent_pack do
                    DestroyEffect(unit_data.cast_effect_permanent_pack[i])
                end
                unit_data.cast_effect_permanent_pack = nil
            end

    end


    function CanCastSkillWithWeapon(skill, level, weapontype)

        for i = 1, #skill.level[level].required_weapon do
            if skill.level[level].required_weapon[i] == weapontype then return true end
        end

        return false
    end


    function InitializeSkillEngine()
        local timer = CreateTimer()
        TimerStart(timer, 1., false, function()


            KEYBIND_LIST = {
                [KEY_Q] =  {
                    ability = FourCC('A016'),
                    name_string = " (|cffffcc00Q|r)",
                    bind_name = "[Q]",
                    player_skill_bind = {}
                },
                [KEY_W] =  {
                    ability = FourCC('A01A'),
                    name_string = " (|cffffcc00W|r)",
                    bind_name = "[W]",
                    player_skill_bind = {}
                },
                [KEY_E] =  {
                    ability = FourCC('A01E'),
                    name_string = " (|cffffcc00E|r)",
                    bind_name = "[E]",
                    player_skill_bind = {}
                },
                [KEY_R] =  {
                    ability = FourCC('A01I'),
                    name_string = " (|cffffcc00R|r)",
                    bind_name = "[R]",
                    player_skill_bind = {}
                },
                [KEY_D] =  {
                    ability = FourCC('A017'),
                    name_string = " (|cffffcc00D|r)",
                    bind_name = "[D]",
                    player_skill_bind = {}
                },
                [KEY_F] =  {
                    ability = FourCC('A018'),
                    name_string = " (|cffffcc00F|r)",
                    bind_name = "[F]",
                    player_skill_bind = {}
                }
            }

            for i = 1, 6 do
                for key = KEY_Q, KEY_F do
                    KEYBIND_LIST[key].player_skill_bind[i] = 0
                end
            end

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

                    local ability_level = UnitGetAbilityLevel(unit_data.Owner, skill.Id)
                    GenerateSkillLevelData(skill, ability_level)


                    if skill.level[ability_level].required_weapon then
                        if not CanCastSkillWithWeapon(skill, ability_level, unit_data.equip_point[WEAPON_POINT].SUBTYPE) then
                            local unit = GetTriggerUnit()
                            local player = GetPlayerId(GetOwningPlayer(unit))
                            IssueImmediateOrderById(unit, order_stop)
                            SetUnitState(unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + skill.level[ability_level].resource_cost)
                            SimError(LOCALE_LIST[my_locale].INVALID_WEAPON_FEEDBACK, player)
                            Feedback_CantUse(player + 1)
                            return
                        end
                    end


                    if not skill.channel then
                        if unit_data.channeled_destructor then
                            unit_data.channeled_destructor(unit_data.Owner)
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
                            time_reduction = time_reduction * (1. - unit_data.stats[ATTACK_SPEED].bonus * 0.01)
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
                    SetUnitTimeScale(unit_data.Owner, scale)

                    --print("result cast time is " .. (skill.level[ability_level].animation_point or 0.) * time_reduction)
                    --print("skill cooldown is " .. R2S(skill.level[ability_level].cooldown))
                    --print("ability level is " .. I2S(ability_level))
                    -- 0.4 * 2. -> 0.8 /// 0.4 * 0.5 -> 0.2
                    BlzSetUnitAbilityCooldown(unit_data.Owner, id, 0, (skill.level[ability_level].cooldown or 0.1) + ((sequence.animation_point or 0.) * time_reduction))
                    BlzSetUnitAbilityManaCost(unit_data.Owner, id, 0, skill.level[ability_level].resource_cost or 0)


                    local target = GetSpellTargetUnit()
                    local spell_x = GetSpellTargetX()
                    local spell_y = GetSpellTargetY()


                    unit_data.cast_skill = id
                    unit_data.cast_skill_level = ability_level

                    SafePauseUnit(unit_data.Owner, true)
                    --BlzPauseUnitEx(unit_data.Owner, true)
                    SetUnitAnimationByIndex(unit_data.Owner, sequence.animation or 0)

                    --local cast_effect_pack


                    PlayCastSfx(unit_data, skill.sfx_pack)


                        if skill.level[ability_level].effect_on_caster then
                            unit_data.cast_effect = AddSpecialEffectTarget(skill.level[ability_level].effect_on_caster, unit_data.Owner, skill.level[ability_level].effect_on_caster_point)
                            BlzSetSpecialEffectScale(unit_data.cast_effect, skill.level[ability_level].effect_on_caster_scale or 1.)
                        end

                        if skill.level[ability_level].start_effect_on_cast_point then
                            bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].start_effect_on_cast_point, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner))
                            BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].start_effect_on_cast_point_scale or 1.)
                            DestroyEffect(bj_lastCreatedEffect)
                        end

                        if skill.sound and skill.sound.pack then
                            unit_data.castsound = AddSoundVolumeZ(skill.sound.pack[GetRandomInt(1, #skill.sound.pack)], GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), 35., skill.sound.volume, skill.sound.cutoff)
                        end


                    OnSkillCast(unit_data.Owner, target, spell_x, spell_y, skill, ability_level)

                    if GetUnitState(unit_data.Owner, UNIT_STATE_LIFE) < 0.045 or HasAnyDisableState(unit_data.Owner) then return end

                        TimerStart(unit_data.action_timer, (sequence.animation_point or 0.) * time_reduction, false, function()
                            unit_data.cast_skill = 0
                            DestroyEffect(unit_data.cast_effect)

                            if unit_data.cast_effect_pack then
                                for i = 1, #unit_data.cast_effect_pack do DestroyEffect(unit_data.cast_effect_pack[i]) end
                                unit_data.cast_effect_pack = nil
                            end

                            if skill.level[ability_level].end_effect_on_cast_point ~= nil then
                                bj_lastCreatedEffect = AddSpecialEffect(skill.level[ability_level].end_effect_on_cast_point, spell_x, spell_y)
                                BlzSetSpecialEffectScale(bj_lastCreatedEffect, skill.level[ability_level].end_effect_on_cast_point_scale or 1.)
                                DestroyEffect(bj_lastCreatedEffect)
                            end

                                if skill.autotrigger then
                                    if skill.level[ability_level].missile then
                                        if target then
                                            if target == unit_data.Owner then
                                                ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target), GetUnitFacing(unit_data.Owner), skill.level[ability_level].from_unit)
                                            else
                                                local angle = AngleBetweenUnits(unit_data.Owner, target)
                                                SetUnitFacing(unit_data.Owner, angle)
                                                ThrowMissile(unit_data.Owner, target, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), GetUnitX(target), GetUnitY(target), angle, skill.level[ability_level].from_unit)
                                            end
                                        else
                                            ThrowMissile(unit_data.Owner, nil, skill.level[ability_level].missile, { effect = skill.level[ability_level].effect, level = ability_level },
                                                    GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), spell_x, spell_y, AngleBetweenUnitXY(unit_data.Owner, spell_x, spell_y), skill.level[ability_level].from_unit)
                                        end

                                    elseif skill.level[ability_level].effect then
                                        if target and target ~= unit_data.Owner then
                                            SetUnitFacing(unit_data.Owner, AngleBetweenUnits(unit_data.Owner, target))
                                            ApplyEffect(unit_data.Owner, target, 0.,0., skill.level[ability_level].effect, ability_level)
                                        elseif target and target == unit_data.Owner then
                                            ApplyEffect(unit_data.Owner, nil, GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), skill.level[ability_level].effect, ability_level)
                                        else
                                            ApplyEffect(unit_data.Owner, nil, spell_x, spell_y, skill.level[ability_level].effect, ability_level)
                                        end
                                    end
                                end

                            TimerStart(unit_data.action_timer, (sequence.animation_backswing or 0.) * time_reduction, false, function ()
                                SpellBackswing(unit_data.Owner)
                            end)

                            OnSkillCastEnd(unit_data.Owner, target, spell_x, spell_y, skill, ability_level)

                            --print("cast")
                        end)

                end

            end)

            DestroyTimer(GetExpiredTimer())
        end)
    end


end