---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hatsu.
--- DateTime: 20.05.2023 23:17
---
do



    function CurvedStrikeEffect(source)
        local unit_data = GetUnitData(source)
        local player = GetPlayerId(GetOwningPlayer(source))+1

            if unit_data.curved_strike_stacks then
                if unit_data.curved_strike_stacks < 3 then
                    unit_data.curved_strike_stacks = unit_data.curved_strike_stacks + 1
                    SetStatusBarValue("curved_strike_stacks", unit_data.curved_strike_stacks, player)
                end
            else
                unit_data.curved_strike_stacks = 1
                AddStatusBarState("curved_strike_stacks", "Spell\\BTNcurved_strike.blp", POSITIVE_BUFF, player)
                SetStatusBarValue("curved_strike_stacks", 1, player)
                SetStatusBarHeaderName("curved_strike_stacks", LOCALE_LIST[my_locale].SKILL_CURVED_STRIKE, player)
            end

    end


    function BreakthroughEffect(caster, target, point_x, point_y, ability_instance)
        local unit_data = GetUnitData(caster)
        local angle  = target and AngleBetweenUnits(caster, target) or AngleBetweenUnitXY(caster, point_x, point_y)
        local max_range = GetMaxAvailableDistance(GetUnitX(caster), GetUnitY(caster), angle, 500.)
        local timer = CreateTimer()
        local duration = 1700. / 3000.

            unit_data.breakthrough_ability_instance = ability_instance
            ChargeUnit(caster, 1700., max_range, angle, 3000, 75., "stand", "BreakthroughEffect", { effect = "Effect\\ChargerRedCasterArt.mdx", point = "origin", scale = 0.7 }, { index = 54, timescale = 1. })
            unit_data.breakthrough_charge_sfx = AddSpecialEffectTarget(".mdx", caster, "origin")

            TimerStart(timer, 0.015, true, function()
                local sfx = AddSpecialEffect("Units\\Hero\\SlayerFade.mdx", GetUnitX(caster), GetUnitY(caster))
                BlzSetSpecialEffectYaw(sfx, angle * bj_DEGTORAD)
                DestroyEffect(sfx)
                duration = duration - 0.015
                if duration <= 0. then
                    DestroyTimer(timer)
                end
            end)
    end


    function LockedAndLoadedEffect(source)
        local player = GetPlayerId(GetOwningPlayer(source))+1

            for key = KEY_Q, KEY_F do
                if KEYBIND_LIST[key].player_skill_bind[player] and KEYBIND_LIST[key].player_skill_bind[player] > 0 and KEYBIND_LIST[key].player_skill_bind[player] ~= FourCC("AALL") then
                    ResetAbilityCooldown(source, KEYBIND_LIST[key].player_skill_bind_string_id[player])
                end
            end

            ApplyBuff(source, source, "ABLL", UnitGetAbilityLevel(source, "AALL"))
            DestroyEffect(AddSpecialEffectTarget("Effect\\Singularity I Red.mdx", source, "origin"))

    end


    function NightShroudEffect(source)
        local nova = AddSpecialEffect("Effect\\DarkLightningNova.mdx", GetUnitX(source), GetUnitY(source))

            DestroyEffect(AddSpecialEffect("Effect\\DarkLightning.mdx", GetUnitX(source), GetUnitY(source)))
            BlzSetSpecialEffectScale(nova, 0.5)
            DestroyEffect(nova)
            ApplyBuff(source, source, "ABNS", UnitGetAbilityLevel(source, "AANS"))

    end


    function StackBladeOfDarkness(source)
        local unit_data = GetUnitData(source)
        local player = GetPlayerId(GetOwningPlayer(source))+1

            if unit_data.blade_of_darkness_stacks then
                if unit_data.blade_of_darkness_stacks < 10 then
                    unit_data.blade_of_darkness_stacks = unit_data.blade_of_darkness_stacks + 1
                    SetStatusBarValue("blade_of_darkness_stacks", unit_data.blade_of_darkness_stacks, player)
                end
            else
                unit_data.blade_of_darkness_stacks = 1
                AddStatusBarState("blade_of_darkness_stacks", "Spell\\BTNblade of darkness.blp", POSITIVE_BUFF, player)
                SetStatusBarValue("blade_of_darkness_stacks", 1, player)
                SetStatusBarHeaderName("blade_of_darkness_stacks", LOCALE_LIST[my_locale].SKILL_BLADE_OF_DARKNESS, player)
            end

            --print(unit_data.blade_of_darkness_stacks)
    end


    function ShadowstepBlinkEffect(source, target)
        local facing = GetUnitFacing(target) + 180.
        local x, y = GetUnitX(target) + Rx(100., facing), GetUnitY(target) + Ry(100., facing)

            SetUnitX(source, x)
            SetUnitY(source, y)
            SetUnitPositionSmooth(source, x, y)
            BlzSetUnitFacingEx(source, facing - 180.)
            DestroyEffect(AddSpecialEffect("Effect\\WarpStrike.mdx", x, y))
            UnitAddAbility(source, FourCC("Avul"))
            DestroyEffect(AddSpecialEffect("Effect\\BlinkTargetPurple.mdx", GetUnitX(source), GetUnitY(source)))

    end

    function ShadowstepEffect(source)
            UnitRemoveAbility(source, FourCC("Avul"))
            ApplyBuff(source, source, "ABST", UnitGetAbilityLevel(source, "AAST"))
            AddSoundVolume("Sounds\\Spells\\Shadowstep_Reappear_".. GetRandomInt(1, 2) ..".wav", GetUnitX(source), GetUnitY(source), 150, 1500.)
            DestroyEffect(AddSpecialEffect("Effect\\warpimpact.mdx", GetUnitX(source), GetUnitY(source)))

            if UnitHasEffect(source, "nightwalkers_effect_Legendary") then
                ApplyBuff(source, source, "A03C", 1)
            end

    end


    function CaltropsEffect(source, ability_instance)
        local x, y = GetUnitX(source), GetUnitY(source)
        local caltrops = {}
        local amount = GetRandomInt(20, 26)

            for i = 1, amount do
                local num = i
                    DelayAction(GetRandomReal(0., 0.12), function()
                        local range = GetRandomReal(10., 300.)
                        local angle = GetRandomReal(0., 360.)

                            caltrops[num] = AddSpecialEffect("Effect\\Caltrops.mdx", x + Rx(range, angle), y + Ry(range, angle))
                            BlzSetSpecialEffectYaw(caltrops[num], GetRandomReal(0., 360.) * bj_DEGTORAD)
                    end)

            end

            DelayAction(0.2, function()
                CreateAuraOnPoint(source, x, y, "caltrops_aura", 1, ability_instance)

                DelayAction(5., function()
                    for i = 1, #caltrops do
                        DestroyEffect(caltrops[i])
                    end
                end)

            end)

    end


    function ShockingTrapEffect(source, ability_instance)
        local timer = CreateTimer()
        local group = CreateGroup()
        local x,y = GetUnitX(source), GetUnitY(source)
        local player = GetOwningPlayer(source)
        local effect = AddSpecialEffect("Effect\\Crystal Beartrap SD.mdx", x, y)
        local duration = 16.

            BlzSetSpecialEffectScale(effect, 0.35)

            DelayAction(1., function()
                TimerStart(timer, 0.1, true, function()
                    GroupEnumUnitsInRange(group, x, y, 150., nil)

                        for index = BlzGroupGetSize(group) - 1, 0, -1 do
                            local picked = BlzGroupUnitAt(group, index)

                                if IsUnitEnemy(picked, player) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) then
                                    ApplyEffect(source, nil, x, y, "shocking_trap_effect", 1, ability_instance)
                                    BlzSpecialEffectAddSubAnimation(effect, SUBANIM_TYPE_ALTERNATE_EX)
                                    DestroyTimer(timer)
                                    DestroyGroup(group)
                                    DestroyEffect(effect)
                                    break
                                end

                        end

                    GroupClear(group)

                    duration = duration - 0.1

                    if duration <= 0. then
                        DestroyTimer(timer)
                        DestroyGroup(group)
                        DestroyEffect(effect)
                    end

                end)
            end)



    end


    function BladeTrapEffect(source, ability_instance)
        local timer = CreateTimer()
        local group = CreateGroup()
        local x,y = GetUnitX(source), GetUnitY(source)
        local player = GetOwningPlayer(source)
        local effect = AddSpecialEffect("Effect\\Crystal Beartrap SD.mdx", x, y)
        local duration = 16.

            BlzSetSpecialEffectScale(effect, 0.35)

            DelayAction(1., function()
                TimerStart(timer, 0.1, true, function()
                    GroupEnumUnitsInRange(group, x, y, 150., nil)

                        for index = BlzGroupGetSize(group) - 1, 0, -1 do
                            local picked = BlzGroupUnitAt(group, index)

                                if IsUnitEnemy(picked, player) and GetUnitState(picked, UNIT_STATE_LIFE) > 0.045 and GetUnitAbilityLevel(picked, FourCC("Avul")) then
                                    local sfx = AddSpecialEffect("Abilities\\Spells\\NightElf\\FanOfKnives\\FanOfKnivesCaster.mdx", x, y)
                                    local sfx45 = AddSpecialEffect("Abilities\\Spells\\NightElf\\FanOfKnives\\FanOfKnivesCaster.mdx", x, y)

                                        BlzSetSpecialEffectScale(sfx, 0.5)
                                        BlzSetSpecialEffectScale(sfx45, 0.5)
                                        BlzSetSpecialEffectYaw(sfx45, 45.)
                                        DelayAction(1.6, function()  DestroyEffect(sfx); DestroyEffect(sfx45) end)
                                        ApplyEffect(source, nil, x, y, "blade_trap_effect", 1, ability_instance)
                                        BlzSpecialEffectAddSubAnimation(effect, SUBANIM_TYPE_ALTERNATE_EX)
                                        DestroyTimer(timer)
                                        DestroyGroup(group)
                                        DestroyEffect(effect)

                                    break
                                end

                        end

                    GroupClear(group)

                    duration = duration - 0.1

                        if duration <= 0. then
                            DestroyTimer(timer)
                            DestroyGroup(group)
                            DestroyEffect(effect)
                        end

                end)
            end)



    end

    function SteelRainImpactArrow(missile, path)
        local arrow = AddSpecialEffect(path, missile.current_x, missile.current_y)

            BlzSetSpecialEffectZ(arrow, GetZ(missile.current_x, missile.current_y) + 25. + GetRandomReal(-10., 5.))
            BlzSetSpecialEffectYaw(arrow, missile.heading_angle * bj_DEGTORAD)
            BlzSetSpecialEffectPitch(arrow, missile.last_pitch)

                DelayAction(3., function()
                    DestroyEffect(arrow)
                end)

    end

    function SteelRainMainEffect(caster, throw_angle, ability_instance)
        local dummy_arrow = ThrowMissile(caster, nil, "steel_rain_arrow", { ability_instance = ability_instance }, GetUnitX(caster), GetUnitY(caster), 0, 0, throw_angle, true)
        local timer = CreateTimer()
        local impact_offset = 100.
        local impact_radius = 200
        local grace_period = 0.15
        local missile = "steel_rain_impact_arrow"

            if ability_instance.frost_ailment then missile = "steel_rain_impact_arrow_cold"
            elseif ability_instance.poison_ailment then missile = "steel_rain_impact_arrow_poison" end

            TimerStart(timer, 0.03, true, function()

                if dummy_arrow.time <= 0. then
                    DestroyTimer(timer)
                elseif grace_period <= 0. then
                    local range = GetRandomInt(0, impact_radius)
                    local angle = GetRandomReal(0., 360.)
                    local impact_x, impact_y = dummy_arrow.current_x + Rx(range, angle), dummy_arrow.current_y + Ry(range, angle)
                    local start_x, start_y = impact_x - Rx(impact_offset, dummy_arrow.heading_angle), impact_y - Ry(impact_offset, dummy_arrow.heading_angle)
                    local impact_arrow = ThrowMissile(caster, nil, missile, { ability_instance = ability_instance }, start_x, start_y, impact_x, impact_y, dummy_arrow.heading_angle, false)

                        impact_arrow.last_pitch = (AngleBetweenXY_DEG(impact_offset, 700., 0., 0.) - 180.) * bj_DEGTORAD
                        BlzSetSpecialEffectPitch(impact_arrow.my_missile, impact_arrow.last_pitch)

                else
                    grace_period = grace_period - 0.03
                end

            end)

    end


    function SteelRainEffect(caster, x, y, ability_instance)
        local angle = AngleBetweenUnitXY(caster, x, y)
        local timer = CreateTimer()
        local duration = 0.15
        local facing = GetUnitFacing(caster)
        local missile_id = "steel_rain_cast_arrow"

            if ability_instance.frost_ailment then missile_id = "steel_rain_cast_arrow_cold"
            elseif ability_instance.poison_ailment then missile_id = "steel_rain_cast_arrow_poison" end

            TimerStart(timer, 0.03, true, function()
                if duration < 0. then
                    DestroyTimer(timer)
                else
                    duration = duration - 0.03
                    local range = GetRandomInt(75, 225)
                    local iangle = facing + GetRandomReal(-15., 15.)
                    local impact_x, impact_y = GetUnitX(caster) + Rx(range, iangle), GetUnitY(caster) + Ry(range, iangle)
                    local missile = ThrowMissile(caster, nil, missile_id, nil, GetUnitX(caster), GetUnitY(caster), impact_x, impact_y, iangle, true)

                        BlzSetSpecialEffectPitch(missile.my_missile, (0. - AngleBetweenXY_DEG(range, 700., 0., 0.) - 180.) * bj_DEGTORAD)
                end
            end)

            SteelRainMainEffect(caster, angle, ability_instance)

            if GetUnitAbilityLevel(caster, FourCC("A02K")) > 0 then
                SteelRainMainEffect(caster, angle - 12., ability_instance)
                SteelRainMainEffect(caster, angle + 12., ability_instance)
            end
    end


    function SuppressionFireEffect(caster, x, y, ability_instance)
        local timer = CreateTimer()
        local angle = AngleBetweenUnitXY(caster, x, y)
        local max_arc_angle = 15.
        local time = 0.3
        local missile = "suppression_fire_arrow"

            if GetUnitAbilityLevel(caster, FourCC("A02K")) > 0 then
                time = time + 0.1
            end

            if ability_instance.frost_ailment then missile = "suppression_fire_cold_arrow"
            elseif ability_instance.poison_ailment then missile = "suppression_fire_poison_arrow" end

            TimerStart(timer, 0.05, true, function()

                if time < 0. then
                    DestroyTimer(timer)
                else
                    ThrowMissile(caster, nil, missile, { ability_instance = ability_instance }, GetUnitX(caster), GetUnitY(caster), 0., 0., angle + GetRandomReal(-max_arc_angle, max_arc_angle), true)
                    time = time - 0.05
                end

            end)


    end




end