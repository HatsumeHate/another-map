do


    function CuttingSlashEffect(source, target, x, y)
        local angle = target and AngleBetweenUnits(source, target) or AngleBetweenUnitXY(source, x, y)
        local effect_x = GetUnitX(source); local effect_y = GetUnitY(source)
        local time = 0.3
        local effect = AddSpecialEffect("Spell\\Coup de Grace.mdx", GetUnitX(source), GetUnitY(source))
        local z = GetUnitZ(source) + 70.

            BlzSetSpecialEffectOrientation(effect, angle * bj_DEGTORAD, 0., 0.)
            local timer = CreateTimer()
            TimerStart(timer, 0.025, true, function()
                if time > 0. then
                    effect_x = effect_x + Rx(17., angle)
                    effect_y = effect_y + Ry(17., angle)
                    BlzSetSpecialEffectPosition(effect, effect_x, effect_y, z)
                else
                    DestroyEffect(effect)
                    DestroyTimer(timer)
                end
                time = time - 0.025
            end)

    end


    function WhirlwindDeactivate(unit)
        local unit_data = GetUnitData(unit)

            UnitRemoveAbility(unit, FourCC('Abun'))
            AddUnitAnimationProperties(unit, "channel", false)
            AddUnitAnimationProperties(unit, unit_data.animation_tag or "", true)
            PauseTimer(unit_data.action_timer)
            DestroyTimer(unit_data.whirlwind_effect_timer)
            --BlzSetSpecialEffectScale(unit_data.whirlwind_sfx, 1.)
            DestroyEffect(unit_data.whirlwind_sfx)
            DestroyLoopingSound(unit_data.looping_sound, 0.2)
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil

            ModifyStat(unit, MOVING_SPEED, 0.75, MULTIPLY_BONUS, false)

    end


    function WhirlwindActivate(unit, ability_instance)
        local unit_data = GetUnitData(unit)

        if unit_data.channeled_destructor ~= nil then
            unit_data.channeled_destructor(unit)
        else

            ResetUnitSpellCast(unit)

            unit_data.channeled_destructor = WhirlwindDeactivate
            unit_data.channeled_ability = "A010"

            AddUnitAnimationProperties(unit, unit_data.animation_tag, false)
            AddUnitAnimationProperties(unit, "channel", true)
            UnitAddAbility(unit, FourCC('Abun'))

            ModifyStat(unit, MOVING_SPEED, 0.75, MULTIPLY_BONUS, true)

            unit_data.looping_sound = AddLoopingSoundOnUnit({"Sounds\\Spells\\whirlwind_1.wav", "Sounds\\Spells\\whirlwind_2.wav", "Sounds\\Spells\\whirlwind_3.wav", "Sounds\\Spells\\whirlwind_4.wav"}, unit, 200, 200, -0.15, 110, 1700., 4200.)
            unit_data.whirlwind_effect_timer = CreateTimer()
            TimerStart(unit_data.whirlwind_effect_timer, 0.05, true, function()
                local whirlwind_sfx = AddSpecialEffect("Effect\\Ephemeral Slash Orange.mdx", GetUnitX(unit), GetUnitY(unit))
                local effect_move_timer = CreateTimer()
                local bonus_z = 120. + GetRandomReal(-15., 15.)
                local timescale = GetRandomReal(0.8, 1.2)
                local duration = 1. * timescale

                BlzSetSpecialEffectZ(whirlwind_sfx, GetUnitZ(unit) + bonus_z)
                BlzSetSpecialEffectYaw(whirlwind_sfx, GetRandomReal(0., 359.) * bj_DEGTORAD)
                BlzSetSpecialEffectRoll(whirlwind_sfx, 180. * bj_DEGTORAD)
                BlzSetSpecialEffectTimeScale(whirlwind_sfx, timescale)
                BlzSetSpecialEffectScale(whirlwind_sfx, 0.9)

                    TimerStart(effect_move_timer, 0.025, true, function()
                        if duration <= 0. then
                            DestroyEffect(whirlwind_sfx)
                            DestroyTimer(effect_move_timer)
                        else
                            BlzSetSpecialEffectPosition(whirlwind_sfx, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit) + bonus_z)
                            duration = duration - 0.025
                        end
                    end)

            end)

            --local attack_speed_bonus = (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01)

            --print((1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01))
            local function WhirlwindEffect()
                local mp = GetUnitState(unit, UNIT_STATE_MANA)
                local manacost = (9. + math.ceil(UnitGetAbilityLevel(unit, "A010") / 5)) / 3.

                    if mp >= manacost then
                        ApplyEffect(unit, nil, GetUnitX(unit), GetUnitY(unit), 'EWHW', 1, ability_instance)
                        ability_instance.is_attack = false
                        SetUnitState(unit, UNIT_STATE_MANA, mp - manacost)
                        TimerStart(unit_data.action_timer, 0.33 * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01), false, function() WhirlwindEffect() end)
                    else
                        WhirlwindDeactivate(unit)
                        Feedback_NoResource(GetPlayerId(GetOwningPlayer(unit))+1)
                    end
            end

            TimerStart(unit_data.action_timer, 0.33 * (1. - unit_data.stats[ATTACK_SPEED].actual_bonus * 0.01), false, function()
                WhirlwindEffect()
                --TimerStart(unit_data.action_timer, 0.33 * attack_speed_bonus, false, WhirlwindEffect)
            end)
        end
    end



    ---@param chain table
    function DestroyVisualChain(chain)

        for i = 1, #chain do DestroyEffect(chain[i]) end
        if chain.ending_model then DestroyEffect(chain.ending_model) end
        DestroyTimer(chain.update_timer)
        chain = nil

    end


    function AddVisualChainEndingModel(path, chain, yaw_angle, pitch_angle, roll_angle)

        chain.ending_model = AddSpecialEffect(path, chain.end_x, chain.end_y)
        chain.ending_model_yaw = yaw_angle
        chain.ending_model_pitch = pitch_angle
        chain.ending_model_roll = roll_angle

    end

    ---@param distance real
    ---@return table
    ---@param start_x real
    ---@param start_y real
    ---@param start_z real
    ---@param angle real
    ---@param distance real
    ---@param max_distance real
    function BuildVisualChain(start_x, start_y, start_z, bonus_z, angle, distance, max_distance)
        local chain = {}
        local offset = 26.
        local elements = max_distance / offset

            for i = 1, elements do chain[i] = AddSpecialEffect("Spell\\ChainElement.mdx", start_y, start_z) end

            chain.start_x, chain.start_y, chain.start_z = start_x, start_y, start_z
            chain.end_x, chain.end_y, chain.end_z = start_x + (distance * math.cos(angle)), start_y + (distance * math.sin(angle)), start_z
            chain.angle = angle --AngleBetweenXY(start_x, start_y, end_x, end_y)
            chain.distance = distance

            chain.update_timer = CreateTimer()

            TimerStart(chain.update_timer, 0.025, true, function()
                --chain.distance = DistanceBetweenXY(chain.start_x, chain.start_y, chain.end_x, chain.end_y)

                if chain.distance > max_distance then chain.distance = max_distance
                elseif chain.distance < 0. then chain.distance = 0 end

                local spacing = chain.distance / elements
                local current_angle = chain.angle * bj_DEGTORAD
                chain.end_x, chain.end_y, chain.end_z = chain.start_x + (chain.distance * math.cos(current_angle)), chain.start_y + (chain.distance * math.sin(current_angle)), chain.start_z

                    for i = 1, elements do
                        local effect_x = chain.start_x + (spacing * i) * math.cos(current_angle)
                        local effect_y = chain.start_y + (spacing * i) * math.sin(current_angle)
                        local effect_z = (GetZ(effect_x, effect_y) - chain.start_z) + chain.start_z + bonus_z

                            BlzSetSpecialEffectX(chain[i], effect_x)
                            BlzSetSpecialEffectY(chain[i], effect_y)
                            BlzSetSpecialEffectZ(chain[i], effect_z)
                            BlzSetSpecialEffectOrientation(chain[i], current_angle, 0., 0.)
                    end

                if chain.ending_model then
                    BlzSetSpecialEffectX(chain.ending_model, chain.end_x)
                    BlzSetSpecialEffectY(chain.ending_model, chain.end_y)
                    BlzSetSpecialEffectZ(chain.ending_model, (GetZ(chain.end_x, chain.end_y) - chain.start_z) + chain.start_z + bonus_z)
                    BlzSetSpecialEffectOrientation(chain.ending_model, current_angle + chain.ending_model_yaw, chain.ending_model_pitch, chain.ending_model_roll)
                end

            end)

        return chain
    end





    function RavageDeactivate(unit)
        local unit_data = GetUnitData(unit)

            --SafePauseUnit(unit, false)
            unit_data.ravage_duration = 0.
            SetUnitTimeScale(unit, 1.)
            UnitRemoveAbility(unit, FourCC('Abun'))
            UnitRemoveAbility(unit, FourCC("A002"))
            UnitRemoveAbility(unit, FourCC("B000"))
            UnitRemoveAbility(unit, FourCC("ARal"))
            SpellBackswing(unit)
            unit_data.channeled_destructor = nil
            unit_data.channeled_ability = nil

    end


    function RavageCast(caster, ability_instance)
        local unit_data = GetUnitData(caster)

            if unit_data.channeled_destructor then unit_data.channeled_destructor(caster) else

                local x, y, z = GetUnitX(caster) + Rx(50., GetUnitFacing(caster) - 27.), GetUnitY(caster) + Ry(50., GetUnitFacing(caster) - 27.), GetUnitZ(caster)
                local chain = BuildVisualChain(x, y, z, 140., GetUnitFacing(caster) - 45., 0., 325.)
                local chain_offhand
                local weapon_sfx = AddSpecialEffect(unit_data.equip_point[WEAPON_POINT].model, x, y)
                local offhand_weapon_sfx
                local sweep_sfx
                local sweep_sfx2
                local offhand_sweep_sfx
                local offhand_sweep_sfx2
                local sound_delay = 0.
                local chain_sound_delay = GetRandomReal(0.17, 0.21)
                local swing_sound_delay = GetRandomReal(0.17, 0.21)
                local sound_pack = { "Sounds\\Spells\\IronMaelstrom_Whoosh_Fast_1.wav", "Sounds\\Spells\\IronMaelstrom_Whoosh_Fast_2.wav", "Sounds\\Spells\\IronMaelstrom_Whoosh_Fast_3.wav", "Sounds\\Spells\\IronMaelstrom_Whoosh_Fast_4.wav", "Sounds\\Spells\\IronMaelstrom_Whoosh_Fast_5.wav" }
                local twohanded = IsWeaponTypeTwohanded(unit_data.equip_point[WEAPON_POINT].SUBTYPE)
                local player = GetOwningPlayer(caster)

                    if twohanded then
                        sweep_sfx = AddSpecialEffect("Spell\\Sweep_Chaos_Large.mdx", x, y)
                        sweep_sfx2 = AddSpecialEffect("Spell\\Sweep_Chaos_Large.mdx", x, y)
                    else
                        sweep_sfx = AddSpecialEffect("Spell\\Sweep_Chaos_Large.mdx", x, y)

                        if unit_data.equip_point[OFFHAND_POINT] and IsItemType(unit_data.equip_point[OFFHAND_POINT].item, ITEM_TYPE_WEAPON) then
                            chain_offhand = BuildVisualChain(x, y, z, 140., (GetUnitFacing(caster) - 45.) + 180., 0., 325.)
                            offhand_weapon_sfx = AddSpecialEffect(unit_data.equip_point[OFFHAND_POINT].model, x, y)
                            offhand_sweep_sfx = AddSpecialEffect("Spell\\Sweep_Chaos_Large.mdx", x, y)
                        end

                    end

                local real_facing = GetUnitFacing(caster)
                local facing = real_facing - 45.
                local as_negative_bonus = 1. - unit_data.stats[ATTACK_SPEED].actual_bonus / 100.
                local as_bonus =  1. + unit_data.stats[ATTACK_SPEED].actual_bonus / 100.
                local breakpoint = 0.66 * as_negative_bonus
                unit_data.ravage_duration = 1.65 * as_negative_bonus
                local distance_bonus = 37. * as_bonus
                local group = CreateGroup()


                --print(unit_data.ravage_duration)

                    ResetUnitSpellCast(caster)

                    unit_data.channeled_destructor = RavageDeactivate
                    unit_data.channeled_ability = "ABRV"
                    UnitAddAbility(caster, FourCC('Abun'))
                    UnitAddAbility(caster, FourCC("A002"))
                    UnitAddAbility(caster, FourCC("ARal"))

                    DestroyEffect(unit_data.equip_point[WEAPON_POINT].model_effect)

                    AddSoundVolume("Sounds\\Spells\\chains_throw_".. GetRandomInt(1,2) ..".wav", GetUnitX(caster), GetUnitY(caster), 130, 1600.)
                    AddSoundVolume(sound_pack[GetRandomInt(1, #sound_pack)], GetUnitX(caster), GetUnitY(caster), 175, 1600.)
                    local sndlooppack = {
                        "Sounds\\Spells\\IronMaelstrom_Chain_1.wav", "Sounds\\Spells\\IronMaelstrom_Chain_2.wav", "Sounds\\Spells\\IronMaelstrom_Chain_3.wav",
                        "Sounds\\Spells\\IronMaelstrom_Chain_4.wav", "Sounds\\Spells\\IronMaelstrom_Chain_5.wav", "Sounds\\Spells\\IronMaelstrom_Chain_6.wav",
                    }

                        if chain_offhand then

                            DestroyEffect(unit_data.equip_point[OFFHAND_POINT].model_effect)

                            BlzSetSpecialEffectX(offhand_weapon_sfx, chain_offhand.end_x)
                            BlzSetSpecialEffectY(offhand_weapon_sfx, chain_offhand.end_y)
                            BlzSetSpecialEffectZ(offhand_weapon_sfx, chain_offhand.end_z + 140.)
                            BlzSetSpecialEffectOrientation(offhand_weapon_sfx, (chain_offhand.angle + 20.) * bj_DEGTORAD, 0., 90. * bj_DEGTORAD)

                            BlzSetSpecialEffectX(offhand_sweep_sfx, chain_offhand.end_x + Rx(40., chain_offhand.angle))
                            BlzSetSpecialEffectY(offhand_sweep_sfx, chain_offhand.end_y + Ry(40., chain_offhand.angle))
                            BlzSetSpecialEffectZ(offhand_sweep_sfx, chain_offhand.end_z + 140.)
                            BlzSetSpecialEffectOrientation(offhand_sweep_sfx, facing + 180. * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)

                        end

                    BlzSetSpecialEffectX(weapon_sfx, chain.end_x)
                    BlzSetSpecialEffectY(weapon_sfx, chain.end_y)
                    BlzSetSpecialEffectZ(weapon_sfx, chain.end_z + 140.)
                    BlzSetSpecialEffectOrientation(weapon_sfx, (chain.angle - 20.) * bj_DEGTORAD, 0., 90. * bj_DEGTORAD)

                    BlzSetSpecialEffectX(sweep_sfx, chain.end_x + Rx(40., chain.angle))
                    BlzSetSpecialEffectY(sweep_sfx, chain.end_y + Ry(40., chain.angle))
                    BlzSetSpecialEffectZ(sweep_sfx, chain.end_z + 140.)
                    BlzSetSpecialEffectOrientation(sweep_sfx, (chain.angle - 20.) * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)

                    if twohanded then
                        BlzSetSpecialEffectX(sweep_sfx2, chain.end_x + Rx(90., chain.angle))
                        BlzSetSpecialEffectY(sweep_sfx2, chain.end_y + Ry(90., chain.angle))
                        BlzSetSpecialEffectZ(sweep_sfx2, chain.end_z + 140.)
                        BlzSetSpecialEffectOrientation(sweep_sfx2, (chain.angle - 20.) * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)
                    end

                    SetUnitTimeScale(caster, 0.05)

                    --print(24.45 * as_bonus)

                    TimerStart(CreateTimer(), 0.025, true, function()

                        BlzSetUnitFacingEx(caster, real_facing)

                        chain.distance = chain.distance + distance_bonus
                        --chain.start_x, chain.start_y, chain.start_z = x, y, z
                        chain.angle = chain.angle + 24.45 * as_bonus

                            if chain_offhand then
                                chain_offhand.distance = chain_offhand.distance + distance_bonus
                                chain_offhand.angle = chain_offhand.angle + 24.45 * as_bonus
                            end

                            if sound_delay <= 0. then
                                AddSoundVolume(sndlooppack[GetRandomInt(1, #sound_pack)], GetUnitX(caster), GetUnitY(caster), 175, 1600.)
                                sound_delay = GetRandomReal(0.23, 0.32)
                            end

                            if chain_sound_delay <= 0. then
                                AddSoundVolume("Sounds\\Spells\\chains_throw_".. GetRandomInt(1,2) ..".wav", GetUnitX(caster), GetUnitY(caster), 130, 1600.)
                                chain_sound_delay = GetRandomReal(0.17, 0.21)
                            end

                            if swing_sound_delay <= 0. then
                                AddSoundVolume(sound_pack[GetRandomInt(1, #sound_pack)], GetUnitX(caster), GetUnitY(caster), 175, 1600.)
                                swing_sound_delay = GetRandomReal(0.23, 0.32)
                            end

                        BlzSetSpecialEffectX(weapon_sfx, chain.end_x)
                        BlzSetSpecialEffectY(weapon_sfx, chain.end_y)
                        BlzSetSpecialEffectZ(weapon_sfx, chain.end_z + 140.)
                        BlzSetSpecialEffectOrientation(weapon_sfx, (chain.angle - 20.) * bj_DEGTORAD, 0., 90. * bj_DEGTORAD)

                        BlzSetSpecialEffectX(sweep_sfx, chain.end_x + Rx(40., chain.angle))
                        BlzSetSpecialEffectY(sweep_sfx, chain.end_y + Ry(40., chain.angle))
                        BlzSetSpecialEffectZ(sweep_sfx, chain.end_z + 140.)
                        BlzSetSpecialEffectOrientation(sweep_sfx, (chain.angle - 20.) * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)

                        if twohanded then
                            BlzSetSpecialEffectX(sweep_sfx2, chain.end_x + Rx(90., chain.angle))
                            BlzSetSpecialEffectY(sweep_sfx2, chain.end_y + Ry(90., chain.angle))
                            BlzSetSpecialEffectZ(sweep_sfx2, chain.end_z + 140.)
                            BlzSetSpecialEffectOrientation(sweep_sfx2, (chain.angle - 20.) * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)
                        end

                            if chain_offhand then
                                BlzSetSpecialEffectX(offhand_weapon_sfx, chain_offhand.end_x)
                                BlzSetSpecialEffectY(offhand_weapon_sfx, chain_offhand.end_y)
                                BlzSetSpecialEffectZ(offhand_weapon_sfx, chain_offhand.end_z + 140.)
                                BlzSetSpecialEffectOrientation(offhand_weapon_sfx, (chain_offhand.angle - 20.) * bj_DEGTORAD, 0., 90. * bj_DEGTORAD)

                                BlzSetSpecialEffectX(offhand_sweep_sfx, chain_offhand.end_x + Rx(90., chain_offhand.angle))
                                BlzSetSpecialEffectY(offhand_sweep_sfx, chain_offhand.end_y + Ry(90., chain_offhand.angle))
                                BlzSetSpecialEffectZ(offhand_sweep_sfx, chain_offhand.end_z + 140.)
                                BlzSetSpecialEffectOrientation(offhand_sweep_sfx, (chain_offhand.angle - 20.) * bj_DEGTORAD, 0., -90. * bj_DEGTORAD)
                            end


                        GroupEnumUnitsInRange(group, chain.end_x, chain.end_y, 250., nil)

                            for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                local picked = BlzGroupUnitAt(group, index)

                                    if picked ~= caster and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 and IsUnitEnemy(picked, player) then
                                        ApplyEffect(caster, picked, 0.,0., "ravage_effect", 1, ability_instance)
                                    end

                            end

                            if chain_offhand then
                                GroupEnumUnitsInRange(group, chain_offhand.end_x, chain_offhand.end_y, 250., nil)

                                    for index = BlzGroupGetSize(group) - 1, 0, -1 do
                                        local picked = BlzGroupUnitAt(group, index)

                                            if picked ~= caster and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 then
                                                ApplyEffect(caster, picked, 0.,0., "ravage_effect", 1, ability_instance)
                                            end

                                    end

                            end

                        GroupClear(group)


                        unit_data.ravage_duration = unit_data.ravage_duration - 0.025
                        sound_delay = sound_delay - 0.025
                        chain_sound_delay = chain_sound_delay - 0.025
                        swing_sound_delay = swing_sound_delay - 0.025

                        if unit_data.ravage_duration < breakpoint then distance_bonus = -57. end

                            if unit_data.ravage_duration <= 0. or chain.distance < 0. then
                                unit_data.equip_point[WEAPON_POINT].model_effect = AddSpecialEffectTarget(unit_data.equip_point[WEAPON_POINT].model, caster, "hand right")

                                    if chain_offhand then
                                        unit_data.equip_point[OFFHAND_POINT].model_effect = AddSpecialEffectTarget(unit_data.equip_point[OFFHAND_POINT].model, caster, "left right")
                                        DestroyEffect(offhand_weapon_sfx)
                                        DestroyEffect(offhand_sweep_sfx)
                                        DestroyVisualChain(chain_offhand)
                                    end

                                --DestroyLoopingSound(chain_swing_loop, 0.2)
                                RavageDeactivate(caster)
                                DestroyGroup(group)
                                DestroyVisualChain(chain)
                                DestroyTimer(GetExpiredTimer())
                                DestroyEffect(weapon_sfx)
                                DestroyEffect(sweep_sfx)
                                if twohanded then DestroyEffect(sweep_sfx2) end
                            end

                    end)

            end


    end



    function HarpoonCast(caster, target, x, y)
        local angle = target and AngleBetweenUnits(caster, target) or AngleBetweenUnitXY(caster, x, y)
        local chains = {}
        local start_x, start_y = GetUnitX(caster), GetUnitY(caster)
        local starting_angle = angle - 25.
        local distance = 10.
        local distance_bonus = 50.
        local pull_group = CreateGroup()
        local hit_group = CreateGroup()
        local player = GetOwningPlayer(caster)
        local pack = { "Sounds\\Spells\\chain_launch_1.wav", "Sounds\\Spells\\chain_launch_2.wav", "Sounds\\Spells\\chain_launch_3.wav", "Sounds\\Spells\\chain_launch_4.wav", "Sounds\\Spells\\chain_launch_5.wav" }

            AddSoundVolume(pack[GetRandomInt(1, #pack)], GetUnitX(caster), GetUnitY(caster), 100, 1600.)
            AddSoundVolume("Sounds\\Spells\\chains_throw_".. GetRandomInt(1,2) ..".wav", GetUnitX(caster), GetUnitY(caster), 135, 1600.)


            for i = 1, 3 do
                chains[i] = BuildVisualChain(start_x + Rx(50., starting_angle), start_y + Ry(50., starting_angle), GetUnitZ(caster), 100., starting_angle, 10., 500.)
                AddVisualChainEndingModel("Effect\\spearhead.mdx", chains[i], 0., 0., 0.)
                starting_angle = starting_angle + 25.
            end

            TimerStart(CreateTimer(), 0.025, true, function()
                distance = distance + distance_bonus

                for i = 1, 3 do chains[i].distance = chains[i].distance + distance_bonus end

                for i = 1, 3 do
                    GroupEnumUnitsInRange(hit_group, chains[i].end_x, chains[i].end_y, 75., nil)
                    for index = BlzGroupGetSize(hit_group) - 1, 0, -1 do
                        local picked = BlzGroupUnitAt(hit_group, index)
                        if GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) == 0 and IsUnitEnemy(picked, player) and not IsUnitInGroup(picked, pull_group) then
                            GroupAddUnit(pull_group, picked)
                            ApplyBuff(caster, picked, "A013", 1, nil)
                            AddSoundVolume("Sounds\\Spells\\Chain_Impact_".. GetRandomInt(1,3) ..".wav", GetUnitX(caster), GetUnitY(caster), 135, 1600.)
                        end
                    end
                end


                if distance >= 500. then
                    distance_bonus = distance_bonus * -1.
                    distance = 499.

                    AddSoundVolume("Sounds\\Spells\\chains_throw_".. GetRandomInt(1,2) ..".wav", GetUnitX(caster), GetUnitY(caster), 135, 1600.)
                    ForGroup(pull_group, function()
                        PullUnitToUnit(GetEnumUnit(), caster, 1000., 125., 15, "EBCH")
                    end)

                elseif distance <= 0. then
                    DestroyTimer(GetExpiredTimer())
                    for i = 1, 3 do DestroyVisualChain(chains[i]) end
                    DestroyGroup(pull_group)
                    DestroyGroup(hit_group)
                end

            end)

    end


    function BuildChain(caster, missile)
        local unit_data = GetUnitData(caster)
        local target
        unit_data.chain = { element = {} }
        local x, y, z = GetUnitX(caster), GetUnitY(caster), missile.end_z

        unit_data.chain.group = CreateGroup()

        for i = 1, 25 do
            if i == 25 then
                unit_data.chain.element[i] = AddSpecialEffect("Spell\\TimberChainHead.mdx", x, y)
            else
                unit_data.chain.element[i] = AddSpecialEffect("Spell\\ChainElement.mdx", x, y)
            end
        end

        local timer = CreateTimer()
        TimerStart(timer, 0.025, true, function()

            if GetUnitState(caster, UNIT_STATE_LIFE) < 0.045 or (target ~= nil and IsUnitInRange(caster, target, 125.)) then

                for i = 1, 25 do
                    DestroyEffect(unit_data.chain.element[i])
                end

                DestroyGroup(unit_data.chain.group)
                unit_data.chain = nil
                DestroyTimer(GetExpiredTimer())

            end


           if missile and missile.time <= 0. then
                if BlzGroupGetSize(unit_data.chain.group) > 0 then
                    ForGroup(unit_data.chain.group, function()
                        PullUnitToUnit(GetEnumUnit(), caster, 1000., 125., 15, "EBCH")
                    end)
                    target = BlzGroupUnitAt(unit_data.chain.group, BlzGroupGetSize(unit_data.chain.group) - 1)
                    missile = nil
                else
                    for i = 1, 25 do
                        DestroyEffect(unit_data.chain.element[i])
                    end

                    DestroyGroup(unit_data.chain.group)
                    unit_data.chain = nil
                    DestroyTimer(GetExpiredTimer())
                end
            end

            x, y = GetUnitX(caster), GetUnitY(caster)
            local distance
            local angle

                if target then
                    distance = DistanceBetweenUnits(caster, target) / 25
                    angle = AngleBetweenXY(x, y, GetUnitX(target), GetUnitY(target))
                    BlzSetSpecialEffectX(unit_data.chain.element[25], GetUnitX(target))
                    BlzSetSpecialEffectY(unit_data.chain.element[25], GetUnitY(target))
                    BlzSetSpecialEffectZ(unit_data.chain.element[25], GetUnitZ(target) + z)
                else
                    distance = DistanceBetweenUnitXY(caster, missile.current_x, missile.current_y) / 25
                    angle = AngleBetweenXY(x, y, missile.current_x, missile.current_y)
                    BlzSetSpecialEffectX(unit_data.chain.element[25], missile.current_x)
                    BlzSetSpecialEffectY(unit_data.chain.element[25], missile.current_y)
                    BlzSetSpecialEffectZ(unit_data.chain.element[25], missile.current_z)
                end

                    for i = 1, 24 do
                        local effect_x = x + (distance * i) * Cos(angle)
                        local effect_y = y + (distance * i) * Sin(angle)
                        local effect_z = GetZ(effect_x, effect_y) + z

                        BlzSetSpecialEffectX(unit_data.chain.element[i], effect_x)
                        BlzSetSpecialEffectY(unit_data.chain.element[i], effect_y)
                        BlzSetSpecialEffectZ(unit_data.chain.element[i], effect_z)
                        --BlzSetSpecialEffectYaw(unit_data.chain.element[i], angle)
                        BlzSetSpecialEffectOrientation(unit_data.chain.element[i], angle, 0., 0.)
                    end

                --BlzSetSpecialEffectYaw(unit_data.chain.element[25], angle)
                BlzSetSpecialEffectOrientation(unit_data.chain.element[25], angle, 0., 0.)


        end)

    end


    function CastShatterGround(source, missile)
        local timer = CreateTimer()
        local max = 400.
        local delta_radius = (max - 100.) / (missile.time / 0.025)
        local effect = AddSpecialEffect("Spell\\arc_fire.mdx", GetUnitX(source), GetUnitY(source))

            BlzSetSpecialEffectTimeScale(effect, 1.4)
            BlzSetSpecialEffectScale(effect, 0.7)
            BlzSetSpecialEffectYaw(effect, GetUnitFacing(source) * bj_DEGTORAD)
            ShakeByCoords(GetUnitX(source), GetUnitY(source), 1.6, missile.time, 1450.)


                TimerStart(timer, 0.025, true, function()
                    if missile and missile.time > 0. then
                        if missile.radius < max then missile.radius = missile.radius + delta_radius end
                    else
                        DestroyTimer(timer)
                    end
                end)

    end



    function CallOfTheAncientsCast(hero)
        local unit_data = GetUnitData(hero)
        local ability_level = UnitGetAbilityLevel(hero, "ABCA")
        local percent = 0.7 * GetUnitParameterValue(hero, MINION_POWER)
        local x, y, angle = GetUnitX(hero), GetUnitY(hero), GetUnitFacing(hero)
        local summon_id = FourCC('bran')
        local heroes = {}
        local soundpack = {"Sounds\\Spells\\barbarian_howl_5.wav", "Sounds\\Spells\\barbarian_howl_6.wav"}

                if unit_data.spawned_hero_1 then KillUnit(unit_data.spawned_hero_1) end
                if unit_data.spawned_hero_2 then KillUnit(unit_data.spawned_hero_2) end

            AddSoundVolume(soundpack[GetRandomInt(1, 2)], x, y, 115, 1600.)

            local max_dist = GetMaxAvailableDistance(x, y, angle - 90., 150.)
            heroes[1] = CreateUnit(GetOwningPlayer(hero), summon_id, x + Rx(max_dist, angle - 90.), y + Ry(max_dist, angle - 90.), angle)
            AddSoundVolume("Sounds\\Spells\\CallOfTheAncients_Ancients_Spawn_Impact_" .. GetRandomInt(1, 3) .. ".wav", GetUnitX(heroes[1] ), GetUnitY(heroes[1] ), 120, 1600.)

            max_dist = GetMaxAvailableDistance(x, y, angle + 90., 150.)
            heroes[2] = CreateUnit(GetOwningPlayer(hero), summon_id, x + Rx(max_dist, angle + 90.), y + Ry(max_dist, angle + 90.), angle)
            AddSoundVolume("Sounds\\Spells\\CallOfTheAncients_Ancients_Spawn_Impact_" .. GetRandomInt(1, 3) .. ".wav", GetUnitX(heroes[2] ), GetUnitY(heroes[2] ), 120, 1600.)


            unit_data.spawned_hero_1 = heroes[1]
            unit_data.spawned_hero_2 = heroes[2]

            for i = 1, 2 do
                local trigger = CreateTrigger()
                TriggerRegisterDeathEvent(trigger, heroes[i])
                TriggerAddAction(trigger, function()
                    local x,y = GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit())
                    DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdx", x, y))
                    ShowUnit(GetTriggerUnit(), false)
                    DestroyTrigger(trigger)
                    AddSoundVolume("Sounds\\Spells\\CallOfTheAncients_Ancients_Despawn_" .. GetRandomInt(1, 6) .. ".wav", x, y, 120, 1600.)
                end)
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdx", GetUnitX(heroes[i]), GetUnitY(heroes[i])))
                UnitApplyTimedLife(heroes[i], 0, 6.75 + (ability_level * 0.25))
                SetUnitVertexColor(heroes[i], 255, 150, 0, 128)
            end


            DelayAction(0., function()
                for i = 1, 2 do
                    local ancient_hero = GetUnitData(heroes[i])

                        for param = PHYSICAL_ATTACK, HOLY_RESIST do ancient_hero.stats[param].value = R2I(unit_data.stats[param].value * percent) end
                        ancient_hero.stats[CRIT_CHANCE].value = unit_data.stats[CRIT_CHANCE].value * percent
                        ancient_hero.equip_point[WEAPON_POINT].DAMAGE = unit_data.equip_point[WEAPON_POINT].DAMAGE * percent
                        ancient_hero.equip_point[WEAPON_POINT].ATTACK_SPEED = unit_data.stats[ATTACK_SPEED].value * percent
                        ancient_hero.equip_point[WEAPON_POINT].DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL
                        ancient_hero.equip_point[WEAPON_POINT].ATTRIBUTE = PHYSICAL_ATTRIBUTE
                        ancient_hero.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS = R2I((ancient_hero.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0) * percent)
                        ancient_hero.equip_point[WEAPON_POINT].MAX_TARGETS = 300
                        for param = STR_STAT, VIT_STAT do ancient_hero.stats[param].value = R2I(unit_data.stats[param].value * percent) end
                        ancient_hero.stats[PHYSICAL_BONUS].value = R2I(unit_data.stats[PHYSICAL_BONUS].value * percent)
                        ancient_hero.stats[HP_VALUE].value = R2I(unit_data.stats[HP_VALUE].value * percent)
                        ancient_hero.stats[HP_REGEN].value = R2I(unit_data.stats[HP_REGEN].value * percent)

                        for param = BONUS_DEMON_DAMAGE, BONUS_HUMAN_DAMAGE do ancient_hero.stats[param].value = R2I(unit_data.stats[param].value * percent) end
                        for param = BONUS_MELEE_DAMAGE, DAMAGE_TO_CC_ENEMIES do ancient_hero.stats[param].value = R2I(unit_data.stats[param].value * percent) end

                        UpdateParameters(ancient_hero)

                end

            end)

    end

end