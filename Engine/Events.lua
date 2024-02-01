do


    function OnSkillUnbind(unit, skill)


            if skill.Id == "AABD" then
                local unit_data = GetUnitData(unit)
                unit_data.blade_of_darkness_stacks = nil
            elseif skill.Id == "AACS" then
                local unit_data = GetUnitData(unit)
                unit_data.curved_strike_stacks = nil
            end

            if skill.minions then
                local player = GetPlayerId(GetOwningPlayer(unit))+1

                    for key = 1, 6 do
                        if KEYBIND_LIST[key].player_skill_bind_string_id[player] then
                            local keyskill = GetUnitSkillData(unit, KEYBIND_LIST[key].player_skill_bind_string_id[player])
                            if keyskill and keyskill.minions then
                                return
                            end
                        end

                    end


                    if GetLocalPlayer() == Player(player-1) then
                        BlzFrameSetVisible(GlobalButton[player].minion_command_button, false)
                        BlzFrameSetVisible(PlayerUI.button_borders[8], false)
                    end

            end

    end


    function OnSkillBind(unit, skill)

        if skill.minions then
            local player = GetPlayerId(GetOwningPlayer(unit))+1

            if GetLocalPlayer() == Player(player-1) then
                BlzFrameSetVisible(PlayerUI.button_borders[8], true)
                BlzFrameSetVisible(GlobalButton[player].minion_command_button, true)
            end

        end

    end


    function OnUnitCreated(new_unit)
        local unit_data = GetUnitData(new_unit)


        if GetUnitTypeId(new_unit) == FourCC("n00N") then
            SetDropList(new_unit, "chest")
        elseif GetUnitTypeId(new_unit) == FourCC(MONSTER_ID_MEPHISTO) then
            MephistoSouls(new_unit)
        end


        if unit_data.classification and unit_data.classification == MONSTER_RANK_BOSS  then
            unit_data.minimap_icon = CreateMinimapIconOnUnit(new_unit, 255, 255, 255, "Marker\\MarkBoss.mdx", FOG_OF_WAR_VISIBLE)
        end

        if GetOwningPlayer(new_unit) == SECOND_MONSTER_PLAYER or GetOwningPlayer(new_unit) == MONSTER_PLAYER or GetOwningPlayer(new_unit) == Player(12) then
            ScaleMonsterUnit(new_unit, Current_Wave)
            GroupAddUnit(ScaleMonstersGroup, new_unit)
            --if not unit_data.classification or unit_data.classification ~= MONSTER_RANK_BOSS and GetUnitAbilityLevel(new_unit, FourCC("Avul")) == 0 then
               --CreateBarOnUnit(new_unit)
            --end

            if unit_data.classification then
                if unit_data.classification == MONSTER_RANK_COMMON then SetDropList(new_unit, "common_enemy")
                elseif unit_data.classification == MONSTER_RANK_ADVANCED then SetDropList(new_unit, "adv_enemy")
                elseif unit_data.classification == MONSTER_RANK_BOSS then SetDropList(new_unit, "boss_enemy") end
            end

            unit_data.attack_speed_deviation = GetRandomInt(0, 15)
            ModifyStat(new_unit, ATTACK_SPEED, -unit_data.attack_speed_deviation, STRAIGHT_BONUS, true)

        end

    end


    function OnMinionDeath(unit, owner)
        local dead_unit_data = GetUnitData(unit)
        local unit_data = GetUnitData(owner)

            if dead_unit_data.minion_owner and GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_final_favor") > 0 then
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdx", GetUnitX(unit), GetUnitY(unit)))
                ApplyEffect(dead_unit_data.minion_owner, dead_unit_data.minion_owner, 0.,0., "effect_final_favor", GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_final_favor"))
            end

            if dead_unit_data.minion_owner and GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_eternal_service") > 0 then
                if Chance(70.) then
                    CreateNecromancerCorpse(GetOwningPlayer(dead_unit_data.minion_owner), GetUnitX(unit), GetUnitY(unit))
                end
            end
    end


    function OnUnitDeath(unit, killer)

        if killer then

            local dead_unit_data = GetUnitData(unit)

            if IsUnitType(killer, UNIT_TYPE_HERO) and GetPlayerId(GetOwningPlayer(killer)) <= 5 then
                for i = 1, 6 do
                    if PlayerHero[i] and IsUnitInRange(PlayerHero[i], unit, 1000.) then

                        if GetUnitTalentLevel(PlayerHero[i], "talent_crystallization") > 0 and IsUnitFrozen(unit) then
                            ApplyEffect(PlayerHero[i], nil, GetUnitX(unit), GetUnitY(unit), "crystallization_effect", GetUnitTalentLevel(killer, "talent_crystallization"))
                        end

                        if GetUnitTalentLevel(PlayerHero[i], "talent_incinerate") > 0 then
                            ApplyBuff(PlayerHero[i], PlayerHero[i], "ATIN", GetUnitTalentLevel(killer, "talent_incinerate"))
                        end

                        if GetUnitTalentLevel(PlayerHero[i], "talent_carnage") > 0 then
                            ApplyBuff(PlayerHero[i], PlayerHero[i], "ATCR", GetBuffLevel(killer, "ATCR") + 1)
                        end

                        if GetUnitTalentLevel(PlayerHero[i], "talent_leeches") > 0 then
                            for i = 1, GetUnitTalentLevel(PlayerHero[i], "talent_leeches") do
                                local leech = CreateUnit(GetOwningPlayer(PlayerHero[i]), FourCC("u00T"), GetUnitX(unit) + GetRandomReal(-50., 50.), GetUnitY(unit) + GetRandomReal(-50., 50.), GetRandomReal(0.,360.))
                                UnitApplyTimedLife(leech, 0, 5.)
                                DelayAction(0., function()
                                    local unit_data = GetUnitData(leech)
                                    ModifyStat(leech, PHYSICAL_ATTACK, math.floor(Current_Wave * GetUnitParameterValue(PlayerHero[i], MINION_POWER)), STRAIGHT_BONUS, true)
                                end)
                            end
                        end

                        if GetUnitTalentLevel(PlayerHero[i], "talent_ritual") > 0 then
                            ApplyBuff(PlayerHero[i], PlayerHero[i], "ARTL", GetUnitTalentLevel(killer, "talent_ritual"))
                        end

                        if GetUnitParameterValue(PlayerHero[i], HP_PER_KILL) > 0 then
                            local amount = GetUnitParameterValue(PlayerHero[i], HP_PER_KILL) * (1 + GetUnitParameterValue(PlayerHero[i], HEALING_BONUS) * 0.01)
                            SetUnitState(PlayerHero[i], UNIT_STATE_LIFE, GetUnitState(PlayerHero[i], UNIT_STATE_LIFE) + amount)
                            CreateHitnumber(R2I(amount), PlayerHero[i], PlayerHero[i], HEAL_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainHealth.mdx", PlayerHero[i], "chest"))
                        end

                        if GetUnitParameterValue(PlayerHero[i], MP_PER_KILL) > 0 then
                            local amount = GetUnitParameterValue(PlayerHero[i], MP_PER_KILL)
                            SetUnitState(PlayerHero[i], UNIT_STATE_MANA, GetUnitState(PlayerHero[i], UNIT_STATE_MANA) + amount)
                            CreateHitnumber(R2I(amount), PlayerHero[i], PlayerHero[i], RESOURCE_STATUS)
                            DestroyEffect(AddSpecialEffectTarget("Effect\\DrainMana.mdx", PlayerHero[i], "chest"))
                        end

                    end
                end

            end

            if not IsUnitType(unit, UNIT_TYPE_HERO) and not dead_unit_data.minion_owner and not dead_unit_data.rune then
                dead_unit_data.rune = true

                if Chance(20.) then
                    local angle = GetRandomReal(0., 359.)
                    local range = GetMaxAvailableDistance(GetUnitX(unit), GetUnitY(unit), angle, GetRandomReal(175., 270.))

                        if GetRandomInt(1, 3) == 1 then
                            ThrowMissile(killer, nil, 'flying_rune_mp', nil, GetUnitX(unit), GetUnitY(unit), GetUnitX(unit) + Rx(range, angle), GetUnitY(unit) + Ry(range, angle), angle)
                        else
                            ThrowMissile(killer, nil, 'flying_rune', nil, GetUnitX(unit), GetUnitY(unit), GetUnitX(unit) + Rx(range, angle), GetUnitY(unit) + Ry(range, angle), angle)
                        end

                end
            end

            local unit_data = GetUnitData(killer)

            if dead_unit_data.minion_owner and GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_final_favor") > 0 then
                DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdx", GetUnitX(unit), GetUnitY(unit)))
                ApplyEffect(dead_unit_data.minion_owner, dead_unit_data.minion_owner, 0.,0., "effect_final_favor", GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_final_favor"))
            end

            if dead_unit_data.minion_owner and GetUnitTalentLevel(dead_unit_data.minion_owner, "talent_eternal_service") > 0 then
                if Chance(70.) then
                    CreateNecromancerCorpse(GetOwningPlayer(dead_unit_data.minion_owner), GetUnitX(unit), GetUnitY(unit))
                end
            end

            if unit_data.minion_owner then
                OnMinionDeath(unit, unit_data.minion_owner)
            end

        end

    end


    function OnUnitEffectApply(unit, effect_id)

    end

    function OnUnitEffectEnd(unit, effect_id)

    end


    function OnChargeEnd(source, targets_hit, sign, negative_state)

        if sign == "BreakthroughEffect" then
            local unit_data = GetUnitData(source)
            DestroyEffect(unit_data.breakthrough_charge_sfx)
        elseif sign == "butcher_charge" then
            ModifyStat(source, CONTROL_REDUCTION, 1000, STRAIGHT_BONUS, false)
        end

    end


    function OnChargeHit(source, target, sign)
        if sign == "abch" then
            ApplyEffect(source, target, 0.,0., "EBCS", Current_Wave)
        elseif sign == "aach" then
            ApplyEffect(source, target, 0.,0., "EACH", Current_Wave)
            PushUnit(source, target, AngleBetweenUnits(source,target), 150., 0.7, "aach")
        elseif sign == "brch" then
            ApplyBuff(source, target, "ABRS", 1)
        elseif sign == "butcher_charge" then
            ApplyEffect(source, target, 0, 0, "butcher_charge_effect", 1)
        elseif sign == "diach" then
            ApplyEffect(source, target, 0., 0., "diablo_charge_effect", Current_Wave)
            PushUnit(source, target, AngleBetweenUnits(source, target), 250., 0.7, "diach")
        elseif sign == "BreakthroughEffect" then
            local unit_data = GetUnitData(source)
            ApplyEffect(source, target, 0., 0., "effect_breakthrough", 1, unit_data.breakthrough_ability_instance)
        end
        return false
    end


    function OnJumpExpire(target, sign)
        if sign == "A00O" then
            if not IsUnitDisabled(target) then SpellBackswing(target) end
            if UnitHasEffect(target, "BSTR") then ApplyEffect(target, nil, 0., 0., "ELBS", 1) end
            ModifyStat(target, CONTROL_REDUCTION, 200, STRAIGHT_BONUS, false)
        end
    end


    function OnPullRelease(source, target, sign)
        if sign == 'EBCH' then
            ApplyBuff(target, source, "ACHA", UnitGetAbilityLevel(target, "A00A"))
            RemoveBuff(source, "A013")
        end
    end


    function OnPushExpire(target, data)
        if data.sign == 'EUPP' then
            ApplyBuff(data.source, target, 'A012', UnitGetAbilityLevel(data.source, "ABUP"))
        end

        if GetUnitTalentLevel(data.source, "talent_disorientation") > 0 then
            ApplyBuff(data.source, target, "ATDS", GetUnitTalentLevel(data.source, "talent_disorientation"))
        end
    end


    ---@param source unit
    ---@param missile table
    function OnMissileImpact(source, missile)
        --print("missile.id")
        if missile.id == "MSSK" then
            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdx", missile.current_x, missile.current_y))
            local reanimated = CreateUnit(MONSTER_PLAYER, FourCC("u00G"), missile.current_x, missile.current_y, GetRandomReal(0., 359.))
            SetUnitAnimation(reanimated, "birth")
            SafePauseUnit(reanimated, true)
            UnitAddAbility(reanimated, FourCC("Avul"))
            DelayAction(2.33, function()
                SafePauseUnit(reanimated, false)
                UnitRemoveAbility(reanimated, FourCC("Avul"))
                SetUnitAnimation(reanimated, "stand")
            end)
        elseif missile.id == "flying_rune" then
            local rune = CreateItem(FourCC("I02U"), missile.current_x, missile.current_y)
            DelayAction(60., function() RemoveItem(rune) end)
        elseif missile.id == "flying_rune_mp" then
            local rune = CreateItem(FourCC("I02V"), missile.current_x, missile.current_y)
            DelayAction(60., function() RemoveItem(rune) end)
        end
    end

    ---@param source unit
    ---@param target unit
    ---@param missile table
    function OnMissileExpire(source, target, missile)

    end

    ---@param source unit
    ---@param target unit
    ---@param missile table
    function OnMissileHit(source, target, missile)
        if missile.id == 'MBLB' then
            LightningBall_VisualEffect(target, missile)
        elseif missile.id == 'MSCN' then
            ApplyBuff(source, target, "ASCB", 1)
        elseif missile.id == 'MNBS' and UnitHasEffect(source, "splitter_legendary") then
            SplitterLegendaryEffect(source, target)
        elseif missile.id == "MNWS" and UnitHasEffect(source, "death_cry_Legendary") then
            ModifyStat(target, MOVING_SPEED, 0.2, MULTIPLY_BONUS, true)
            DelayAction(0.5, function() ModifyStat(target, MOVING_SPEED, 0.2, MULTIPLY_BONUS, false) end)
        end
    end


    ---@param missile table
    ---@param source unit
    ---@param target unit
    function OnMissileLaunch(source, target, missile)

        if missile.id == 'M001' then
            local timer = CreateTimer()
            TimerStart(timer, 0.25, true, function ()
                if missile.time <= 0. then DestroyTimer(GetExpiredTimer())
                else RedirectMissile_Deg(missile, GetRandomReal(0., 359.)) end
            end)
        elseif missile.id == "MBCH" then BuildChain(source, missile)
        elseif missile.id == "MSHG" then CastShatterGround(source, missile)
        elseif missile.id == "MSCN" then SummonCurse(missile)
        elseif missile.id == "MRLR" then RevenantLaserMissile(source, missile)
        elseif missile.id == "MNBS" then BoneSpearCast(source, missile)
        elseif missile.id == "MNWS" then WanderingSpiritCast(source, missile)
        elseif missile.id == "MMLT" then
            if UnitHasEffect(source, "catalyst_Legendary") then
                missile.penetrate = true
                missile.hit_once_in = 5.
                missile.max_targets = 300
            end
        elseif missile.id == "baal_hoarfrost_missile" then
            local timer = CreateTimer()
                TimerStart(timer, 0.05, true, function ()
                    if missile.time <= 0. then DestroyTimer(GetExpiredTimer())
                    else missile.radius = missile.radius + 15. end
                end)
        end

    end


    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param effect table
    function OnEffectPrecast(source, target, x, y, effect)
        local leveled_effect = effect.level[effect.current_level]


            if effect.id == "EEXC" then
                if GetUnitState(target, UNIT_STATE_LIFE) / GetUnitState(target, UNIT_STATE_MAX_LIFE) <= 0.33  then
                    leveled_effect.power = R2I(leveled_effect.power * 3)
                    leveled_effect.bonus_crit_chance = 15.
                end
            elseif effect.id == "ELST" then
                DelayAction(0.25, function()
                    local speceffect

                    if target then speceffect = AddSpecialEffect("Spell\\Lightnings Long_".. GetRandomInt(1,5) ..".mdl", GetUnitX(target), GetUnitY(target))
                    else speceffect = AddSpecialEffect("Spell\\Lightnings Long_".. GetRandomInt(1,5) ..".mdl", x, y) end

                    BlzPlaySpecialEffect(speceffect, ANIM_TYPE_BIRTH)
                    BlzSetSpecialEffectScale(speceffect, 0.6)
                    DelayAction(0.5, function() DestroyEffect(speceffect) end)
                end)
            elseif effect.id == "ECSP" then
                if UnitHasEffect(source, "PNEC") then
                    leveled_effect.can_crit = true
                    leveled_effect.bonus_crit_chance = 25.
                end
            elseif effect.id == "EBLZ" then
                local unit_data = GetUnitData(source)
                effect.level[effect.current_level].area_of_effect = effect.level[effect.current_level].area_of_effect * unit_data.blz_scale
            elseif effect.id == "effect_backstab" then
                if IsUnitBack(source, target) then
                    leveled_effect.power = leveled_effect.power * 2.
                elseif IsUnitAtSide(source, target) then
                    leveled_effect.power = leveled_effect.power * 1.5
                end
            elseif effect.id == "effect_blade_of_darkness" then
                local unit_data = GetUnitData(source)

                    if unit_data.blade_of_darkness_stacks and unit_data.blade_of_darkness_stacks > 0 then
                        leveled_effect.power = leveled_effect.power * (1. + (unit_data.blade_of_darkness_stacks * 0.15))
                        print("boosted by effect_blade_of_darkness")
                    end

            elseif effect.id == "effect_pursuer" then
                effect.current_level = GetUnitTalentLevel(source, "talent_pursuer")
            end

        if UnitHasEffect(source, "FRBD") then
            if leveled_effect.attribute and (leveled_effect.power or leveled_effect.attack_percent_bonus) and leveled_effect.attribute == FIRE_ATTRIBUTE then
                leveled_effect.power = leveled_effect.power * 1.35
            end
        end

        if UnitHasEffect(source, "EOTS") then
            if effect.id == "EDSC" then leveled_effect.power = leveled_effect.power * 1.15 end
        end


        if HasTag(effect.tags, "talent_overflow") and leveled_effect.attribute and leveled_effect.attribute == FIRE_ATTRIBUTE then
            leveled_effect.power = leveled_effect.power * (1 + 0.3 * GetUnitTalentLevel(source, "talent_overflow"))
        end

        if HasTag(effect.tags, "talent_heating_up") and leveled_effect.attribute and leveled_effect.attribute == FIRE_ATTRIBUTE then
            leveled_effect.power = leveled_effect.power * 1.4
        end


        if HasTag(effect.tags, "curved_strike_stacks") and effect.id ~= "effect_curved_strike" and leveled_effect.power and leveled_effect.power > 0 then
            local unit_data = GetUnitData(source)

                if unit_data.curved_strike_stacks and unit_data.curved_strike_stacks > 0 then
                    leveled_effect.power = leveled_effect.power * (1. + (unit_data.curved_strike_stacks * 0.5))
                    print("boosted by curved_strike_stacks")
                end

        end

        if HasTag(effect.tags, "curved_strike_stacks1") or HasTag(effect.tags, "curved_strike_stacks2") or HasTag(effect.tags, "curved_strike_stacks3") then
            if HasTag(effect.tags, "curved_strike_stacks1") then leveled_effect.power = leveled_effect.power * 1.5
            elseif HasTag(effect.tags, "curved_strike_stacks2") then leveled_effect.power = leveled_effect.power * 2.
            elseif HasTag(effect.tags, "curved_strike_stacks3") then leveled_effect.power = leveled_effect.power * 2.5 end
        end

        if (HasTag(effect.tags, "talent_arc_discharge1") or HasTag(effect.tags, "talent_arc_discharge2") or HasTag(effect.tags, "talent_arc_discharge3")) and (leveled_effect.attribute and leveled_effect.attribute == LIGHTNING_ATTRIBUTE) then
            local unit_data = GetUnitData(source)
            local boost_level = 1

                if HasTag(effect.tags, "talent_arc_discharge2") then boost_level = 2
                elseif HasTag(effect.tags, "talent_arc_discharge3") then boost_level = 3 end

                if leveled_effect.power and leveled_effect.power > 0 then
                    leveled_effect.power = leveled_effect.power * (1. + (0.1 * boost_level))
                elseif leveled_effect.attack_percent_bonus then
                    leveled_effect.attack_percent_bonus = leveled_effect.attack_percent_bonus * (1. + (0.1 * boost_level))
                elseif leveled_effect.weapon_damage_percent_bonus then
                    leveled_effect.weapon_damage_percent_bonus = leveled_effect.weapon_damage_percent_bonus * (1. + (0.1 * boost_level))
                end

        end

        if GetUnitTalentLevel(source, "talent_sharpened_blade") > 0 and HasTag(effect.tags, "talent_sharpened_blade") and leveled_effect.is_direct then
            local unit_data = GetUnitData(source)

            if unit_data.sharpened_blade_counter > 0 and (leveled_effect.power > 0 or leveled_effect.attack_percent_bonus > 0. or leveled_effect.weapon_damage_percent_bonus > 0.) then
                local bonus = 1.02 + GetUnitTalentLevel(source, "talent_sharpened_blade") * 0.02

                if leveled_effect.power > 0 then
                    leveled_effect.power = leveled_effect.power * bonus
                elseif leveled_effect.attack_percent_bonus > 0. then
                    leveled_effect.attack_percent_bonus = leveled_effect.attack_percent_bonus * bonus
                elseif leveled_effect.weapon_damage_percent_bonus > 0. then
                    leveled_effect.weapon_damage_percent_bonus = leveled_effect.weapon_damage_percent_bonus * bonus
                end

            end

        end


    end


    ---@param source unit
    ---@param target unit
    ---@param effect table
    function OnEffectApply(source, target, effect)

        if effect.id == 'EUPP' then
            PushUnit(source, target, AngleBetweenUnits(source,target), 215., 1., effect.id)
        elseif effect.id == 'EBCH' then
            local unit_data = GetUnitData(source)
            local buff_data = GetBuffDataFromUnit(target, 'A013')

            if buff_data ~= nil and buff_data.buff_source == source then
                GroupAddUnit(unit_data.chain.group, target)
            end
        elseif effect.id == 'EMTR' then
            PushUnit(source, target, AngleBetweenUnitXY(target, effect.effect_x, effect.effect_y) + 180., 200., 1.25, "smeteor")
        elseif UnitHasEffect(source, "rot_and_disease_Legendary") and (effect.id == "ENBS" or effect.id == "ENBB" or effect.id == "ENBK" or effect.id == "ENRP") then
            ApplyBuff(source, target, "A00E", 1)
        end

    end


    function OnEffectTrigger(source, target, x, y, effect, lvl)
        local leveled_effect = effect.level[effect.current_level]

            if GetUnitTalentLevel(source, "talent_napalm") > 0 and leveled_effect.attribute == FIRE_ATTRIBUTE and leveled_effect.area_of_effect > 0. and leveled_effect.is_direct then
                if Chance(GetUnitParameterValue(source, CRIT_CHANCE)) then
                    NapalmTalentEffect(source, effect.effect_x, effect.effect_y, effect)
                end
            end

    end


    ---@param source unit
    ---@param new_source unit
    ---@param target unit
    ---@param buff table
    function OnBuffSourceChange(source, new_source, target, buff)

        if BuffHasTag(buff.id) == "curse" and source ~= new_source then
            if GetUnitTalentLevel(source, "talent_vile_malediction") > 0 then
                VileMaledictionStack(source, target, false)
            end
        end

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffExpire(source, target, buff)

            if buff.id == "A01S" and buff.current_level == 15 then
                local unit_data = GetUnitData(target)
                    unit_data.hp_vector = true
                    UpdateUnitParameter(target, HP_REGEN)
            end


            if GetUnitTalentLevel(target, "talent_pain_killer") > 0 then
                DelayAction(0., function()
                    if not GetBuffsWithTag(target, "skill") then
                    --GetUnitAbilityLevel(target, FourCC("A00V")) == 0 and GetUnitAbilityLevel(target, FourCC("ANRD")) == 0 and GetUnitAbilityLevel(target, FourCC("A01N")) == 0 and GetUnitAbilityLevel(target, FourCC("BBRC")) == 0 then
                        RemoveBuff(target, "ATPK")
                    end
                end)
            end

            if GetUnitTalentLevel(source, "talent_disorientation") > 0 and buff.level[buff.current_level].negative_state == STATE_STUN then
                ApplyBuff(source, target, "ATDS", GetUnitTalentLevel(source, "talent_disorientation"))
            end

        if GetUnitTalentLevel(source, "talent_insanity") > 0 then
            DelayAction(0., function()
                local duration = GetMaxDurationFear(source, target)
                if duration > 0. then ApplyBuff(source, target, "AINS", GetUnitTalentLevel(source, "talent_insanity")) end
            end)
        end

        if BuffHasTag(buff.id, "curse")  then
                --buff.id == "ABWK" or buff.id == "ABDC" or buff.id == "A0PB"
            if GetUnitTalentLevel(source, "talent_vile_malediction") > 0 then
                VileMaledictionStack(source, target, false)
            end

            DelayAction(0., function()
                local duration = GetMaxDurationCurse(source, target)

                if duration > 0 then

                    if GetUnitTalentLevel(source, "talent_frailty") > 0 then
                        ApplyBuff(source, target, "AFRL", GetUnitTalentLevel(source, "talent_frailty"))
                        SetBuffExpirationTime(target, "AFRL", duration)
                    end

                    if GetUnitTalentLevel(source, "talent_amplify_damage") > 0 then
                        ApplyBuff(source, target, "AAMD", GetUnitTalentLevel(source, "talent_amplify_damage"))
                        SetBuffExpirationTime(target, "AAMD", duration)
                    end

                end
            end)

        end

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffOverTimeTrigger(source, target, buff)

    end

    function OnBuffLevelChange(source, target, buff, max_level)
        if buff.id == "A01P" then
            SetBuffExpirationTime(target, "A01P", -1)
        elseif buff.id == "A01S" then
            if buff.current_level == 15 then
                local unit_data = GetUnitData(target)
                unit_data.hp_vector = false
                UpdateUnitParameter(target, HP_REGEN)
            else
                SetBuffExpirationTime(target, "A01S", -1)
            end
        elseif buff.id == "ABBS" then
            if buff.current_level < 7 then
                SetBuffExpirationTime(target, "ABBS", -1)
            end
        end
    end

    ---@param source unit
    ---@param buff table
    function OnBuffApply(source, target, buff)

        if GetUnitTalentLevel(source, "talent_deep_freeze") > 0 and buff.attribute == ICE_ATTRIBUTE and buff.buff_type == NEGATIVE_BUFF then
            buff.expiration_time = buff.expiration_time * (1. + GetUnitTalentLevel(source, "talent_deep_freeze") * 0.5)
        end

        if GetUnitTalentLevel(source, "talent_heat_transfer") > 0 and buff.level[buff.current_level].negative_state == STATE_FREEZE then
            ApplyBuff(source, source, "ATHE", GetUnitTalentLevel(source, "talent_heat_transfer"))
        end

        if GetUnitTalentLevel(source, "talent_pain_killer") > 0 then
            if BuffHasTag(buff.id, "skill") and buff.buff_source == source then
                --buff_id == "A00V" or buff_id == "ANRD" or buff_id == "A01N" or buff_id == "BBRC"
                ApplyBuff(source, source, "ATPK", 1)
            end
        end

        if GetUnitTalentLevel(source, "talent_inevitability") > 0 and buff.buff_type == NEGATIVE_BUFF then
            buff.expiration_time = buff.expiration_time * (1.05 + GetUnitTalentLevel(source, "talent_inevitability") * 0.05)
        end

        if GetUnitTalentLevel(source, "talent_intimidation") > 0 and buff.id == 'A00Y' then
            if Chance(35.) then
                ApplyBuff(source, target, "ATIT", GetUnitTalentLevel(source, "talent_intimidation"))
            end
        end

        if UnitHasEffect(source, "rot_and_disease_Legendary") and buff.id == "A0PB" then
            ApplyBuff(source, target, "A00E", 1)
        end

        if BuffHasTag(buff.id, "curse") then

            if GetUnitTalentLevel(source, "talent_vile_malediction") > 0 then
                VileMaledictionStack(source, target, true)
            end

            if GetUnitTalentLevel(source, "talent_sudden_death") > 0 then
                local unit_data = GetUnitData(target)
                    if unit_data.classification == MONSTER_RANK_COMMON then
                        if GetUnitState(target, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(target) < 0.2 and Chance(30.) then
                            KillUnit(target)
                        end
                    end
            end

            if GetUnitTalentLevel(source, "talent_persistent_curse") > 0 then
                SetBuffExpirationTime(target, buff.id, GetBuffExpirationTime(target, buff.id) + (GetUnitTalentLevel(source, "talent_persistent_curse") * 1))
            end

            if GetUnitTalentLevel(source, "talent_frailty") > 0 then
                ApplyBuff(source, target, "AFRL", GetUnitTalentLevel(source, "talent_frailty"))
                SetBuffExpirationTime(target, "AFRL", GetBuffExpirationTime(target, buff.id))
            end

            if GetUnitTalentLevel(source, "talent_amplify_damage") > 0 then
                ApplyBuff(source, target, "AAMD", GetUnitTalentLevel(source, "talent_amplify_damage"))
                SetBuffExpirationTime(target, "AAMD", GetBuffExpirationTime(target, buff.id))
            end

            if GetUnitTalentLevel(source, "talent_face_of_death") > 0 and Chance(25.) then
                ApplyBuff(source, target, "AFOD", GetUnitTalentLevel(source, "talent_face_of_death"))
            end


        end

        if GetUnitTalentLevel(source, "talent_insanity") > 0 then
            if buff.level[buff.current_level].negative_state == STATE_FEAR then
                ApplyBuff(source, target, "AINS", GetUnitTalentLevel(source, "talent_insanity"))
                SetBuffExpirationTime(target, "AINS", GetBuffExpirationTime(target, buff.id))
            end
        end

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffPrecast(source, target, buff)

    end



    ---@param source unit
    ---@param target unit
    ---@param damage_data table
    ---@param damage real
    function OnDamage_End(source, target, damage, damage_data)

        if damage_data.effect and damage_data.effect.eff and damage_data.effect.eff.id == "EEXC" then
            local ability_level = UnitGetAbilityLevel(source, "A020")

                if GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then

                    if ability_level >= 10 then
                        ApplyBuff(source, source, "ANRD", ability_level)
                    end

                    if UnitHasEffect(source, "executioner_Legendary") then
                        ApplyEffect(source, source, 0,0, "executioner_heal", 1)
                        DelayAction(0.1, function() BlzEndUnitAbilityCooldown(source, GetKeybindKeyAbility(FourCC("A020"), GetPlayerId(GetOwningPlayer(source))+1)) end)
                    end
                end
        end

        if UnitHasEffect(target, "trait_lightning") and damage_data.is_direct then
            TraitLightningEffect(target)
        end

        if UnitHasEffect(target, "trait_toxic") then
            TraitToxicEffect(target)
        end

        if GetUnitTalentLevel(source, "talent_ignite") > 0 and damage_data.attribute == FIRE_ATTRIBUTE and damage_data.is_direct then
            if Chance(35.) then
                ApplyBuff(source, target, "ATIG", GetUnitTalentLevel(source, "talent_ignite"))
            end
        end

        if GetUnitTalentLevel(target, "talent_hell_flames") > 0 and damage_data.attack_type == RANGE_ATTACK and damage_data.is_direct then
            local unit_data = GetUnitData(target)
            if Chance(35.) and not unit_data.hell_flames_cooldown then
                unit_data.hell_flames_cooldown = true
                HellFlamesTalentEffect(target)
                DelayAction(7., function() unit_data.hell_flames_cooldown = nil end)
            end
        end


        if GetUnitTalentLevel(source, "talent_lightning_rod") > 0 and (damage_data.is_direct or (damage_data.effect and damage_data.effect.eff.id == "ELBL")) and damage_data.attribute == LIGHTNING_ATTRIBUTE then
            if Chance(30.) then
                LightningRodTalentEffect(source, target)
            end
        end

        if GetUnitTalentLevel(source, "talent_negative_charge") > 0 and damage_data.attribute == LIGHTNING_ATTRIBUTE then
            ApplyBuff(source, target, "ATNC", GetUnitTalentLevel(source, "talent_negative_charge"))
        end

        if GetUnitTalentLevel(source, "talent_extra_charge") > 0 and damage_data.attribute == LIGHTNING_ATTRIBUTE then
            ExtraChargeTalentEffect(source, damage)
        end

        if GetUnitTalentLevel(source, "talent_shock") > 0 and damage_data.attribute == LIGHTNING_ATTRIBUTE then
            if Chance(15.) then
                ShockTalentEffect(source, target)
            end
        end

        if GetUnitTalentLevel(source, "talent_remorseless") > 0 and damage_data.attribute == ICE_ATTRIBUTE then
            ApplyBuff(source, target, "ATRM", GetUnitTalentLevel(source, "talent_remorseless"))
        end

        if GetUnitTalentLevel(target, "talent_glaciation") > 0 and damage_data.is_direct and damage_data.damage_type == DAMAGE_TYPE_PHYSICAL then
            local unit_data = GetUnitData(target)

                unit_data.glaciation_charge = unit_data.glaciation_charge - 1

                if unit_data.glaciation_charge <= 0 then
                    unit_data.glaciation_charge = 0
                    RemoveBuff(target, "ATGL")
                    ResumeTimer(unit_data.glaciation_charge_timer)
                    unit_data.glaciation_charge_time = 3.
                else
                    SetBuffLevel(target, "ATGL", unit_data.glaciation_charge)
                    SetBuffExpirationTime(target, "ATGL", -1.)
                    ResumeTimer(unit_data.glaciation_charge_timer)
                    unit_data.glaciation_charge_time = 3.
                end

        end


        if GetUnitTalentLevel(target, "talent_anger_impulse") > 0 and damage_data.is_direct and (damage_data.attack_status == ATTACK_STATUS_CRITICAL or damage_data.attack_status == ATTACK_STATUS_CRITICAL_BLOCKED) then
            ApplyBuff(target, target, "ATRI", GetUnitTalentLevel(target, "talent_anger_impulse"))
        end

        if GetUnitTalentLevel(target, "talent_adrenaline") > 0 then
            local unit_data = GetUnitData(target)
            if not unit_data.talent_adrenaline_cooldown then
                if GetUnitState(target, UNIT_STATE_LIFE) < BlzGetUnitMaxHP(target) * 0.5 then
                    ApplyBuff(target, target, "ATAR", GetUnitTalentLevel(target, "talent_adrenaline"))
                    unit_data.talent_adrenaline_cooldown = true
                    DelayAction(40., function() unit_data.talent_adrenaline_cooldown = nil end)
                end
            end
        end


        if GetUnitTalentLevel(source, "talent_pressure_point") > 0 and (damage_data.attack_status == ATTACK_STATUS_CRITICAL or damage_data.attack_status == ATTACK_STATUS_CRITICAL_BLOCKED) then
            local max = 1 + GetUnitTalentLevel(source, "talent_pressure_point")
            local current = GetBuffLevel(source, "ATPP") + 1

            if current > max then current = max end

            ApplyBuff(source, source, "ATPP", current)
        end

    end

    ---@param source unit
    ---@param damage table
    function OnDamage_PreHit(source, target, damage, damage_data)

        if GetUnitTalentLevel(target, "talent_ice_enduring") > 0 and damage >= GetUnitState(target, UNIT_STATE_LIFE) then
            local unit_data = GetUnitData(target)
                if not unit_data.ice_enduring_cooldown then
                    ApplyEffect(target, target, 0.,0., "ice_enduring_effect", 1)
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + damage + BlzGetUnitMaxHP(target) * 0.25)
                    unit_data.ice_enduring_cooldown = true
                    DelayAction(120., function() unit_data.ice_enduring_cooldown = nil end)
                end
        end

        if GetUnitTalentLevel(target, "talent_lining_armor") > 0 and damage_data.is_direct then
            local unit_data = GetUnitData(target)
            if not unit_data.lining_armor_cooldown and damage >= BlzGetUnitMaxHP(target) * 0.1 then
                local mod = GetUnitTalentLevel(target, "talent_lining_armor") == 1 and 0.7 or 0.5
                damage_data.damage = damage * mod
                unit_data.lining_armor_cooldown = true
                DelayAction(9., function() unit_data.lining_armor_cooldown = nil end)
            end
        end

        if GetUnitTalentLevel(target, "talent_second_wind") > 0 and damage >= GetUnitState(target, UNIT_STATE_LIFE) then
            local unit_data = GetUnitData(target)
                if not unit_data.second_wind_cooldown then
                    local percent = GetUnitState(target, UNIT_STATE_MANA) / BlzGetUnitMaxMana(target)
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + (BlzGetUnitMaxHP(target) * percent) + damage)
                    SetUnitState(target, UNIT_STATE_MANA, 0.)
                    ApplyBuff(target, target, "ATSW", 1)
                    unit_data.second_wind_cooldown = true
                    RemoveBuffsByType(target, NEGATIVE_BUFF)
                    DelayAction(120., function() unit_data.second_wind_cooldown = nil end)
                end
        end

        if GetUnitTalentLevel(target, "talent_cheat_death") > 0 and damage >= GetUnitState(target, UNIT_STATE_LIFE) then
            local unit_data = GetUnitData(target)

                if not unit_data.cheat_death_cooldown then
                    DestroyEffect(AddSpecialEffectTarget("Effect\\blue-guangzhu-linghun.mdx", target, "origin"))
                    SetUnitState(target, UNIT_STATE_LIFE, GetUnitState(target, UNIT_STATE_LIFE) + damage + BlzGetUnitMaxHP(target) * 0.35)
                    ApplyBuff(target, target, "ACHD", 1)
                    unit_data.cheat_death_cooldown = true
                    DelayAction(180., function() unit_data.cheat_death_cooldown = nil end)
                end

        end

    end


    function OnDamageStart(source, target, damage_data)

        if GetUnitTalentLevel(source, "talent_fragility") > 0 then
            if FragilityBuffTalentCheck(target) then
                damage_data.damage = damage_data.damage * (1. + GetUnitTalentLevel(source, "talent_fragility") * 0.1)
            end
        end

        if GetUnitTalentLevel(source, "talent_sweeping_strikes") > 0 and (not damage_data.effect or damage_data.effect.regular_attack) then
            if GetUnitTalentLevel(source, "talent_sweeping_strikes") < 3 then
                local unit_data = GetUnitData(source)
                if unit_data.sweeping_strikes_main_target and unit_data.sweeping_strikes_main_target ~= target then
                    damage_data.damage = damage_data.damage * (math.floor(33. * GetUnitTalentLevel(source, "talent_sweeping_strikes") + 0.5) / 100)
                end
            end
        end

        if GetUnitTalentLevel(source, "talent_opportunity") > 0 then
            if HasNegativeState(target, STATE_STUN) then
                damage_data.bonus_critical = damage_data.bonus_critical + 5. + (GetUnitTalentLevel(source, "talent_opportunity") * 5.)
            end
        end

        if GetUnitTalentLevel(source, "talent_bigger_they_are") > 0 then
            local unit_data = GetUnitData(target)

            if unit_data.classification == MONSTER_RANK_ADVANCED or unit_data.classification == MONSTER_RANK_BOSS or unit_data.classification == MONSTER_RANK_ELITE then
                local bonus = GetUnitTalentLevel(source, "talent_bigger_they_are") == 1 and 1.06 or 1.1
                damage_data.damage = damage_data.damage * bonus
            end
        end

        if UnitHasEffect(source, "unity_Legendary") then
            local attacker = GetUnitData(source)
            local b = GetUnitParameterValue(source, GetAttributeBonusParam(damage_data.attribute))

                damage_data.attribute_bonus = attacker.equip_point[WEAPON_POINT].ATTRIBUTE ~= damage_data.attribute and attacker.equip_point[WEAPON_POINT].ATTRIBUTE_BONUS or 0
                for i = PHYSICAL_BONUS, HOLY_BONUS do damage_data.attribute_bonus = damage_data.attribute_bonus + GetUnitParameterValue(source, i) end
                damage_data.attribute_bonus = damage_data.attribute_bonus - b

        end

        return damage_data
    end




    ---@param source unit
    ---@param target unit
    function OnAttackEnd(source, target)

    end

    ---@param source unit
    ---@param target unit
    function OnMyAttack(source, target, attack_data)
        --local attacker_data = GetUnitData(source)

            if UnitHasEffect(source, "ECRA") then
                if GetUnitAbilityLevel(target, FourCC("A01P")) == 0 then ApplyBuff(source, target, "A01P", 1)
                else SetBuffLevel(target, "A01P", GetBuffLevel(target, "A01P") + 1) end
            end

            if UnitHasEffect(source, "MOFE") then
                if attack_data.attribute == ICE_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEI", 1)
                elseif attack_data.attribute == FIRE_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEF", 1)
                elseif attack_data.attribute == LIGHTNING_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEL", 1) end
            end

            if UnitHasEffect(source, "RDAG") then ApplyEffect(source, source, 0, 0, "ERIT", 1) end
            if UnitHasEffect(source, "EBBS") then ApplyEffect(source, target, 0.,0., "EBBS", 1) end
            if UnitHasEffect(target, "ECBG") then if Chance(15.) then ApplyEffect(target, target, 0, 0, "ECBG", 1) end end

            if UnitHasEffect(source, "weap_poison_phys") and Chance(7.) then ApplyBuff(source, target, "AWPP", 1) end
            if UnitHasEffect(source, "weap_poison_mag") and Chance(7.) then ApplyBuff(source, target, "AWPM", 1) end
            if UnitHasEffect(source, "weap_fire_mag") and Chance(7.) then ApplyBuff(source, target, "AWFM", 1) end
            if UnitHasEffect(source, "weap_bleed") and Chance(7.) then ApplyBuff(source, target, "AWBP", 1) end

            if UnitHasEffect(target, "item_fortify") and Chance(10.) then ApplyBuff(target, target, "AIFT", 1) end

            if UnitHasEffect(target, "item_enrage") and Chance(5.) then ApplyBuff(target, target, "AIEN", 1) end
            if UnitHasEffect(target, "item_conduction") and Chance(5.) then ApplyBuff(target, target, "AICN", 1) end
            if UnitHasEffect(source, "item_enrage") and not UnitHasEffectProc(source, "item_enrage") then
                if Chance(5.) then ApplyBuff(source, source, "AIEN", 1) end
                UnitAddEffectProc(source, "item_enrage")
            end
            if UnitHasEffect(source, "item_conduction") and Chance(5.) then ApplyBuff(source, source, "AICN", 1) end

            if UnitHasEffect(source, "EHOR") then
                if Chance(20.) then ApplyEffect(source, target, 0, 0, "EHOR", 1) end
            end

            if UnitHasEffect(target, "greta_revenge_Legendary") and Chance(12.) then
                GretaRevengeLegendaryEffect(target)
            end


            if GetUnitClass(source) == BARBARIAN_CLASS then
                if UnitHasEffect(source, "everlasting_madness_Legendary") and GetUnitAbilityLevel(source, FourCC("A00V")) == 0 then
                    if Chance(20.) then
                        ApplyBuff(source, source, "A00V", UnitGetAbilityLevel(source, "A00Q") or 1)
                        SetBuffExpirationTime(source, "A00V", 3.)
                    end
                elseif UnitHasEffect(target, "everlasting_madness_Legendary") and GetUnitAbilityLevel(target, FourCC("A00V")) == 0 then
                    if Chance(20.) then
                        ApplyBuff(target, target, "A00V", UnitGetAbilityLevel(target, "A00Q") or 1)
                        SetBuffExpirationTime(target, "A00V", 3.)
                    end
                end
            end


            --attack_data.effect.proc_list["item_enrage"] = true
            if GetUnitAbilityLevel(source, FourCC("ABTT")) > 0 then
                local buff = GetBuffDataFromUnit(source, "ABTT")
                ApplyEffect(buff.buff_source, source, 0.,0., "torture_damage_effect", 1)
                ApplyEffect(buff.buff_source, target, 0, 0, "torture_heal_effect", 1)
            end


            if GetUnitAbilityLevel(target, FourCC("ADTL")) > 0 then 
                local buff = GetBuffData("ADTL")
                if buff.buff_source == source or GetUnitClass(source) == ASSASSIN_CLASS then ApplyBuff(source, source, "ABTL", UnitGetAbilityLevel(source, "AATL")) end
            end


            if GetUnitClass(source) == ASSASSIN_CLASS and IsAbilityKeybinded(FourCC("AABD"), GetPlayerId(GetOwningPlayer(source))+1) and not attack_data.proc_list["blade_of_darkness"] then
                StackBladeOfDarkness(source)
                attack_data.proc_list["blade_of_darkness"] = true
                --UnitAddEffectProc(source, "blade_of_darkness")
                print("stacking")
            end


            if UnitHasEffect(source, "trait_chill") then
                local unit_data = GetUnitData(source)
                if not unit_data.trait_chill_cooldown and Chance(35.) then
                    ApplyBuff(source, target, "ATCH", 1)
                    unit_data.trait_chill_cooldown = true
                    DelayAction(6., function() unit_data.trait_chill_cooldown = nil end)
                end
            elseif UnitHasEffect(source, "trait_overpower") then
                local unit_data = GetUnitData(source)
                if not unit_data.trait_overpower_cooldown and Chance(35.) then
                    PushUnit(source, target, AngleBetweenUnits(source,target), 250., 1.35, "trait_overpower")
                    unit_data.trait_overpower_cooldown = true
                    DelayAction(6., function() unit_data.trait_overpower_cooldown = nil end)
                end
            end

            if GetUnitTalentLevel(source, "talent_heat") > 0 then
                ApplyBuff(source, target, "ATHT", GetUnitTalentLevel(source, "talent_heat"))
            end

            if GetUnitTalentLevel(source, "talent_positive_charge") > 0 and attack_data.attack_status == ATTACK_STATUS_CRITICAL and attack_data.attribute == LIGHTNING_ATTRIBUTE then
                local mp = math.floor((BlzGetUnitMaxMana(source) * (0.03 * GetUnitTalentLevel(source, "talent_positive_charge"))) + 0.5)
                SetUnitState(source, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA) + mp)
                CreateHitnumber(mp, source, source, RESOURCE_STATUS)
            end

            if GetUnitTalentLevel(source, "talent_voltage") > 0 and attack_data.attribute == LIGHTNING_ATTRIBUTE and attack_data.attack_status == ATTACK_STATUS_CRITICAL then
                ApplyBuff(source, source, "ATAD", GetUnitTalentLevel(source, "talent_voltage"))
            end

            if GetUnitTalentLevel(source, "talent_induction") > 0 and attack_data.attribute == LIGHTNING_ATTRIBUTE and attack_data.attack_status == ATTACK_STATUS_CRITICAL then
               InductionTalentEffect(source)
            end

            if GetUnitTalentLevel(target, "talent_extra_charge") > 0 and attack_data.attack_type == MELEE_ATTACK then
                ExtraChargeShockTalentEffect(source, target)
            end


            if GetUnitTalentLevel(source, "talent_arc_discharge") > 0 and attack_data.attack_status == ATTACK_STATUS_CRITICAL and not AbilityInstanceHasEffect(attack_data, "talent_arc_discharge") then
                local lvl = GetUnitTalentLevel(source, "talent_arc_discharge")

                    if (lvl == 1 and Chance(25.)) or (lvl == 2 and Chance(30.)) or (lvl == 3 and Chance(35.)) then
                        ArcDischargeCharge(source)
                        AbilityInstanceAddEffectProc(attack_data, "talent_arc_discharge")
                    end

            end

            if GetUnitTalentLevel(source, "talent_disintegration") > 0 then
                DisintegrationTalentEffect(source, target)
            end

            if GetUnitTalentLevel(source, "talent_breath_of_frost") > 0 and attack_data.attribute == ICE_ATTRIBUTE then
                if Chance(17.) then
                    BreathOfFrostTalentEffect(source, target)
                end
            end

            if GetUnitTalentLevel(target, "talent_reflexes") > 0 and attack_data.attack_type == RANGE_ATTACK and attack_data.damage_type == DAMAGE_TYPE_PHYSICAL then
                if ReflexesTalentEffect(target) then
                    local modificator = GetUnitTalentLevel(target, "talent_reflexes") == 1 and 0.5 or 0.2
                    attack_data.damage = attack_data.damage * modificator
                    DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\SpellShieldAmulet\\SpellShieldCaster.mdx", "origin", target))
                end
            end

            if GetUnitTalentLevel(source, "talent_breaking_defence") > 0 then
                if Chance(20.) then
                    ApplyBuff(source, target, "ATBD", GetUnitTalentLevel(source, "talent_breaking_defence"))
                end
            end

            if GetUnitTalentLevel(source, "talent_carnage") > 0 then
                SetBuffExpirationTime(source, "ATCR", -1.)
            end

            if GetUnitTalentLevel(target, "talent_herbs") > 0 then
                local unit_data = GetUnitData(target)
                unit_data.herbs_charge_time = 7.
            end

            if GetUnitTalentLevel(source, "talent_elbow_strike") > 0 and attack_data.attack_type == MELEE_ATTACK then
                local chance = GetUnitTalentLevel(source, "talent_elbow_strike") == 1 and 13. or 17.
                if Chance(chance) then
                    PushUnit(source, target, AngleBetweenUnits(source, target), 75, 0.5, "talent_elbow_strike")
                end
            end

            if GetUnitTalentLevel(source, "talent_fracture") > 0 then
                if Chance(15.) then
                    ApplyBuff(source, target, "ATFR", GetUnitTalentLevel(source, "talent_fracture"))
                end
            end

            if GetUnitTalentLevel(source, "talent_vulnerability") > 0 and (attack_data.attack_status == ATTACK_STATUS_CRITICAL or attack_data.attack_status == ATTACK_STATUS_CRITICAL_BLOCKED) then
                ApplyBuff(source, target, "ATVL", GetUnitTalentLevel(source, "talent_vulnerability"))
            end

            if GetUnitTalentLevel(source, "talent_pursuer") > 0 and attack_data.effect and attack_data.effect.eff.id ~= "effect_pursuer" then
                if Chance(17.) then LaunchPursuer(source) end
            end

            if GetUnitTalentLevel(source, "talent_tenacity_of_undead") > 0 and not IsAHero(source) then
                if Chance(17.) then ApplyBuff(source, source, "ATOD", GetUnitTalentLevel(source, "talent_tenacity_of_undead")) end
            end

            if GetUnitTalentLevel(source, "talent_life_steal") > 0 and (attack_data.attack_status == ATTACK_STATUS_CRITICAL or attack_data.attack_status == ATTACK_STATUS_CRITICAL_BLOCKED) then
                ApplyBuff(source, source, "ANLS", GetUnitTalentLevel(source, "talent_life_steal"))
            end

            if GetUnitTalentLevel(source, "talent_lesion") > 0 and attack_data.attribute == POISON_ATTRIBUTE and (attack_data.attack_status == ATTACK_STATUS_CRITICAL or attack_data.attack_status == ATTACK_STATUS_CRITICAL_BLOCKED) then
                AddSoundVolume("Sounds\\Spells\\poison".. GetRandomInt(1,4) ..".wav")
                ApplyBuff(source, target, "ATLS", GetUnitTalentLevel(source, "talent_lesion"))
            end

            if GetUnitTalentLevel(source, "talent_blood_pact") > 0 then
                if Chance(18.) and GetUnitState(source, UNIT_STATE_LIFE) / BlzGetUnitMaxHP(source) < 100 then BloodPactTalent(source) end
            end

            if GetUnitAbilityLevel(source, FourCC("A007")) > 0 then
                if Chance(35.) then ApplyBuff(source, target, "A006", Current_Wave) end
            end

            if GetUnitAbilityLevel(source, FourCC("A00L")) > 0 and attack_data.is_direct and attack_data.attack_type == MELEE_ATTACK then
                if Chance(40.) then
                    AddSoundVolume("Sounds\\Spells\\poison".. GetRandomInt(1,4).. ".wav", GetUnitX(target), GetUnitY(target), 128, 1600., 4000)
                    ApplyBuff(source, target, "A00K", 1)
                end
            end

            if IsHexActive("I03S") and IsUnitMonsterPlayer(source) and Chance(25.) then
                if GetUnitAbilityLevel(source, FourCC("A00A")) == 0 then
                    ApplyBuff(source, source, "A00A", 1)
                else
                    SetBuffLevel(source, "A00A", GetBuffLevel(source, "A00A") + 1)
                    SetBuffExpirationTime(source, "A00A", -1)
                end

            end

        AI_AttackReaction(source, target)

        return attack_data
    end

    ---@param source unit
    ---@param target unit
    ---@return table
    function OnAttackStart(source, target, attack_data)

        if GetUnitTalentLevel(source, "talent_sweeping_strikes") > 0 then
            local unit_data = GetUnitData(source)

                if IsWeaponTypeTwohanded(unit_data.equip_point[WEAPON_POINT].SUBTYPE) then
                    unit_data.sweeping_strikes_main_target = target
                    attack_data.max_targets = 300
                else
                    unit_data.sweeping_strikes_main_target = nil
                end

        end

        if GetUnitTalentLevel(source, "talent_sharpened_blade") > 0 then
            local unit_data = GetUnitData(source)
            local bonus = 1.02 + GetUnitTalentLevel(source, "talent_sharpened_blade") * 0.02

                unit_data.sharpened_blade_counter = unit_data.sharpened_blade_counter - 1
                attack_data.damage = attack_data.damage * bonus
                if unit_data.sharpened_blade_counter <= 0 then RemoveBuff(source, "ATSB") end

                unit_data.sharpened_blade_charge_time = 15.
                ResumeTimer(unit_data.sharpened_blade_charge_timer)
        end

        if GetUnitTypeId(source) == FourCC("shdr") then
            local unit_data = GetUnitData(source)
            local angle = AngleBetweenUnits(source, target)

                if unit_data.powerlevel >= 2 then
                    ThrowMissile(source, target, nil, nil, GetUnitX(source) + Rx(60.,angle - 90.), GetUnitY(source) + Ry(60.,angle - 90.), GetUnitX(target), GetUnitY(target), 0, false)
                end

                if unit_data.powerlevel == 3 then
                    ThrowMissile(source, target, nil, nil, GetUnitX(source) + Rx(60.,angle + 90.), GetUnitY(source) + Ry(60.,angle + 90.), GetUnitX(target), GetUnitY(target), 0, false)
                end

        end

        if IsUnitMonsterPlayer(source) then
            local unit_data = GetUnitData(source)

                ModifyStat(source, ATTACK_SPEED, -unit_data.attack_speed_deviation, STRAIGHT_BONUS, false)
                unit_data.attack_speed_deviation = GetRandomInt(0, 25)
                ModifyStat(source, ATTACK_SPEED, -unit_data.attack_speed_deviation, STRAIGHT_BONUS, true)

        end


        return attack_data
    end


    ---@param source unit
    ---@param target unit
    ---@param point_x real
    ---@param point_y real
    ---@param action_id string
    ---@param ability_instance table
    function OnActionEnd(source, target, point_x, point_y, action_id, ability_instance)

        if action_id == "shuriken_throw" then
            local angle = target and AngleBetweenUnits(source, target) or AngleBetweenUnitXY(source, point_x, point_y)
            local unit_data = GetUnitData(source)
            local tags = nil

                unit_data.shuriken_amount = unit_data.shuriken_amount - 1
                ThrowMissile(source, target, "shuriken_missile", { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), point_x, point_y, angle + GetRandomReal(-4., 4.), true)

                if unit_data.shuriken_amount > 0 then DoAction(source, target, "shuriken_throw", point_x, point_y, ability_instance) end
        elseif action_id == "eviscerate_action_1" then
                ModifyAbilityInstance(ability_instance, "power_multiplier", 2, 0.25, MULTIPLY_BONUS)
                DoAction(source, target, "eviscerate_action_2", point_x + Rx(30., GetUnitFacing(source)), point_y + Ry(30., GetUnitFacing(source)), ability_instance)
        end

    end


    ---@param source unit
    ---@param victim unit
    ---@param additional_data table
    ---@param ability_instance table
    ---@return table
    function OnAction(source, victim, additional_data, ability_instance)



        return additional_data
    end


    ---@param source unit
    ---@param target unit
    ---@param skill table
    ---@param x real
    ---@param y real
    ---@param ability_instance table
    function OnSkillCastEnd(source, target, x, y, skill, ability_level, ability_instance)
        local id = skill.Id
        local class = GetUnitClass(source)


            if class == BARBARIAN_CLASS then
                if id == 'A00O' then
                    MakeUnitJump(source, AngleBetweenUnitXY(source, x, y), x, y, 920., 0.6, 'A00O')
                    ModifyStat(source, CONTROL_REDUCTION, 200, STRAIGHT_BONUS, true)
                elseif id == 'A010' then WhirlwindActivate(source, ability_instance)
                elseif id == 'ABUP' then
                    local effect = AddSpecialEffect("Spell\\DetroitSmash_Effect.mdx", GetUnitX(source) + Rx(50., GetUnitFacing(source)), GetUnitY(source) + Ry(50., GetUnitFacing(source)))
                    BlzSetSpecialEffectOrientation(effect, GetUnitFacing(source) * bj_DEGTORAD, 0., 0.)
                    BlzSetSpecialEffectZ(effect, GetUnitZ(source) + 60.)
                    BlzSetSpecialEffectScale(effect, 0.7)
                    DestroyEffect(effect)
                elseif id == "A006" then CuttingSlashEffect(source, target, x, y)
                elseif id == "ABRC" then
                    if GetUnitTalentLevel(source, "talent_intimidation") > 0 then
                        if Chance(35.) then ApplyEffect(source, nil, 0., 0., "effect_intimidation", GetUnitTalentLevel(source, "talent_intimidation"), nil) end
                    end
                elseif id == "ADBS" then
                    local unit_data = GetUnitData(source)
                    unit_data.attack_instances["effect_double_strike"] = nil
                    DestroyTimer(ability_instance.attack_timer)
                    ability_instance.proc_list = nil
                    ability_instance.proc_list = {}
                    ability_instance.is_attack = false
                    DoAction(source, target, "double_swing", x, y)
                elseif id == "ABRV" then RavageCast(source, ability_instance)
                elseif id == "A00A" then HarpoonCast(source, target, x, y)
                elseif id == "ABCA" then CallOfTheAncientsCast(source)
                end


                if skill.classification == SKILL_CLASS_ATTACK and GetUnitTalentLevel(source, "talent_rage") > 0 then RageTalentEffect(source) end

                if GetUnitTalentLevel(source, "talent_sharpened_blade") > 0 and skill.classification == SKILL_CLASS_ATTACK then
                    local unit_data = GetUnitData(source)

                    if unit_data.sharpened_blade_counter > 0 then
                        unit_data.sharpened_blade_counter = unit_data.sharpened_blade_counter - 1

                        if unit_data.sharpened_blade_counter <= 0 then
                            RemoveBuff(source, "ATSB")
                        end
                    end

                    unit_data.sharpened_blade_charge_time = 15.
                    ResumeTimer(unit_data.sharpened_blade_charge_timer)
                end


            elseif class == SORCERESS_CLASS then
                if id == 'A00L' then CastSorceressBlink(source, x, y, skill)
                elseif id == 'A00I' then SummonHydra(source, x, y)
                elseif id == "A001" then FrostNovaVisual(source)
                elseif id == "A003" and UnitHasEffect(source, "ITCH") then
                    skill.level[ability_level].missile = "MFRB"
                    CastFrostbolt_Legendary(source, target, x, y, ability_instance)
                elseif id == "AMLT" then CastMeltdown(source, ability_instance)
                elseif id == "ABLZ" then CastBlizzard(source, ability_instance)
                elseif id == "A019" then ChainLightningCast(source, target, ability_instance)
                elseif id == "ASIR" then IcicleRainCast(source, x, y, ability_instance)
                elseif id == "AFRW" then FireWaveCast(source, x, y, ability_instance)
                elseif id == "AFWL" then FireWallCast(source, x, y, ability_instance)
                elseif id == 'A00J' then
                    if UnitHasEffect(source,"EOTS") then SparkCast_Legendary(source, ability_instance)
                    else SparkCast(source, target, x, y, ability_instance) end
                end

                if skill.category == SKILL_CATEGORY_FIRE and GetUnitTalentLevel(source, "talent_heating_up") > 0 then StackHeatingUp(source) end
                if skill.category == SKILL_CATEGORY_LIGHTNING and skill.classification == SKILL_CLASS_ATTACK and GetUnitTalentLevel(source, "talent_arc_discharge") > 0 then ArcDischargeRemoveCharge(source) end

            elseif class == NECROMANCER_CLASS then
                 if id == "ANRD" then RaiseSkeletonSkill(source)
                 elseif id == "ANLR" then RaiseLichCast(source)
                 elseif id == "ANBB" then BoneBarrage(source, x, y, ability_instance)
                 elseif id == "ANPB" then PoisonBlast(source, ability_instance)
                 elseif id == "ANDV" then DevourSkill(source)
                 elseif id == "ANCE" then CorpseExplosionCast(source, x, y, ability_instance)
                 elseif id == "ANUL" then UndeadLandCast(source, ability_instance)
                 elseif id == "ANGS" then GrowSpikesCast(source)
                 elseif id == "ANDR" then DarkReignCast(source)
                 elseif id == "ANUC" then UnholyCommandCast(source)
                 elseif id == "ANBR" then RipBonesCast(source, ability_instance)
                 elseif id == "ANBK" then BoneSpikesCast(source, x, y, target, ability_instance)
                 elseif id == "ANFD" then ForcedDecayCast(source, target, ability_instance)
                 elseif id == "ANTT" then TortureCast(x, y)
                 elseif id == "ANDF" then DecrepifyCast(x, y)
                 elseif id == "ANWK" then WeakenCast(x, y)
                 elseif id == "ANWS" and UnitHasEffect(source, "death_cry_Legendary") then
                     local angle = target and AngleBetweenUnits(source, target) or AngleBetweenUnitXY(source, x, y)
                     ThrowMissile(source, nil, "MNWS", { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), x, y, angle - 15., true)
                     ThrowMissile(source, nil, "MNWS", { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), x, y, angle + 15., true)
                 end

                if GetUnitTalentLevel(source, "talent_abyss_awakens") > 0 then AbyssAwakensTalent(source) end
                if GetUnitTalentLevel(source, "talent_death_march") > 0 then ApplyBuff(source, source, "ADEM", GetUnitTalentLevel(source, "talent_death_march")) end

            elseif class == ASSASSIN_CLASS then
                if id == "AACS" then CurvedStrikeEffect(source)
                elseif id == "AABR" then BreakthroughEffect(source, target, x, y, ability_instance)
                elseif id == "AASH" then
                    local unit_data = GetUnitData(source)
                    local angle = target and AngleBetweenUnits(source, target) or AngleBetweenUnitXY(source, x, y)

                        unit_data.shuriken_amount = 2
                        ThrowMissile(source, target, "shuriken_missile", { ability_instance = ability_instance }, GetUnitX(source), GetUnitY(source), x, y, angle + GetRandomReal(-4., 4.), true)
                        DoAction(source, target, "shuriken_throw", x, y, ability_instance)

                elseif id == "AAEV" then
                        ModifyAbilityInstance(ability_instance, "power_multiplier", 1, 0.25, MULTIPLY_BONUS)
                        DoAction(source, target, "eviscerate_action_1", x + Rx(30., GetUnitFacing(source)), y + Ry(30., GetUnitFacing(source)), ability_instance)
                elseif id == "AABF" then
                    local sfx = AddSpecialEffect("Abilities\\Spells\\NightElf\\FanOfKnives\\FanOfKnivesCaster.mdx", GetUnitX(source), GetUnitY(source))

                        BlzSetSpecialEffectYaw(sfx, 45.)
                        DelayAction(1.6, function()  DestroyEffect(sfx) end)
                elseif id == "AALL" then LockedAndLoadedEffect(source)
                elseif id == "AANS" then NightShroudEffect(source)
                elseif id == "AABD" then
                    local unit_data = GetUnitData(source)
                    unit_data.blade_of_darkness_stacks = nil
                    print("reset blade of darkness stacks")
                elseif id == "AAST" then ShadowstepEffect(source, target)
                elseif id == "AADB" then
                    ThrowMissile(source, target, "dancingblade_missile", { ability_instance = ability_instance, geo_arc_side = 1. }, GetUnitX(source), GetUnitY(source), x, y, 0., true)
                    ThrowMissile(source, target, "dancingblade_missile", { ability_instance = ability_instance, geo_arc_side = -1. }, GetUnitX(source), GetUnitY(source), x, y, 0., true)
                elseif id == "AACT" then CaltropsEffect(source, ability_instance)
                elseif id == "AASC" then ShockingTrapEffect(source, ability_instance)
                elseif id == "AABT" then BladeTrapEffect(source, ability_instance)
                end

                local unit_data = GetUnitData(source)
                if skill.classification == SKILL_CLASS_ATTACK and id ~= "AACS" and unit_data.curved_strike_stacks and unit_data.curved_strike_stacks > 0 then
                    unit_data.curved_strike_stacks = 0
                    print("reset cureved strike stacks")
                end

            else
                if id == "ASQT" then SpiderQueen_WebTrap(source)
                elseif id == "ASQS" then SpiderQueen_SpawnBrood(source)
                elseif id == "ABCH" then ChargeUnit(source, 750., 600., GetUnitFacing(source), 1, 100., nil, "abch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" },  { index = 0, timescale = 2. } )
                elseif id == "AACH" then ChargeUnit(source, 500., 500., GetUnitFacing(source), 1, 100., nil, "aach", { effect = "Spell\\Valiant Charge Fel.mdx", point = "origin" }, { index = 1, timescale = 2. } )
                elseif id == "AAPN" then CreatePoisonNova(source)
                elseif id == "ASSM" then SpawnSkeletons(source)
                elseif id == "AMLN" then LightningNovaBoss(source)
                elseif id == "AQBC" then ChargeUnit(source, 600., 350., GetUnitFacing(source), 1, 75., nil, "brch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" }, { index = 0, timescale = 2. } )
                elseif id == "AWRG" then ApplyBuff(source, target, "AWRB", 1)
                elseif id == "AVDS" then CastVoidDisc(source, x, y)
                elseif id == "AVDR" then CreateVoidRain(source, x, y, 550., 3.5)
                elseif id == "AFRR" then CreateFireRain(source, x, y, 600., 4.5)
                elseif id == "ANRA" then CastReanimate(source)
                elseif id == "AAPB" then PoisonBarrage(source, x, y)
                elseif id == "AAHF" then AndarielHellfireCast(source)
                elseif id == "ABSS" then SummonTentacle(source, x, y)
                elseif id == "ABFN" then BaalNovaCast(source)
                elseif id == "ASBL" then SatyrBlinkCast(source)
                elseif id == "AWWO" then ApplyBuff(source, source, "ABWO", 1)
                elseif id == "AFBB" then IceBlastCast(source, x, y)
                elseif id == "AARB" then AstralBarrageCast(source)
                elseif id == "ABRR" then BloodRavenReviveCast(source)
                elseif id == "ABRA" then ApplyBuff(source, target, "A00J", 1)
                elseif id == "ABBC" then
                    ModifyStat(source, CONTROL_REDUCTION, 1000, STRAIGHT_BONUS, true)
                    ChargeUnit(source, 800., 800., GetUnitFacing(source), 1, 100., nil, "butcher_charge", { effect = "Spell\\Valiant Charge.mdx", point = "origin" }, { index = 10, timescale = 2. })
                elseif id == "ARNA" then ReanimatedArrowBarrage(source, x, y)
                elseif id == "A00B" then PitlordDarknessBarrageCast(source, x, y)
                elseif id == "A00C" then PitlordMeteorsCast(source)
                elseif id == "ADLB" then DiabloLightningBreath(source, x, y)
                elseif id == "ADFS" then DiabloFireStomp(source, x, y)
                elseif id == "ADCH" then ChargeUnit(source, 750., 800., GetUnitFacing(source), 1, 100., "walk channel", "diach", { effect = "Spell\\Valiant Charge.mdx", point = "origin" })
                elseif id == "ADAP" then DiabloApoc(source)
                end
            end


    end


    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param skill table
    ---@param ability_instance table
    function OnSkillCast(source, target, x, y, skill, ability_level, ability_instance)

        if UnitHasEffect(source, "EWTM") then
            if skill.type == SKILL_MAGICAL then
                if GetUnitState(source, UNIT_STATE_LIFE) / GetUnitState(source, UNIT_STATE_MAX_LIFE) > 0.05 then
                    ApplyEffect(source, source, 0, 0, "EWTM", 1)
                    SetUnitState(source, UNIT_STATE_LIFE, GetUnitState(source, UNIT_STATE_LIFE) - (BlzGetUnitMaxHP(source) * 0.05))
                end
            end
        elseif skill.Id == "AMLT" then
            SetUnitFacing(source, AngleBetweenUnitXY(source, PlayerMousePosition[GetPlayerId(GetOwningPlayer(source)) + 1].x or 0., PlayerMousePosition[GetPlayerId(GetOwningPlayer(source)) + 1].y or 0.))
        elseif skill.Id == "A003" and UnitHasEffect(source, "ITCH") then
            skill.level[ability_level].missile = nil
        end

        if GetUnitTalentLevel(source, "talent_grave_cold") > 0 and (skill.classification == SKILL_CLASS_SUPPORT or skill.classification == SKILL_CLASS_ATTACK) then
            ToggleAuraOnUnit(source, "grave_cold_aura", 1, true)
        end

        if GetUnitTalentLevel(source, "talent_reinforce") > 0 and skill.classification == SKILL_CLASS_SUPPORT then
            ApplyBuff(source, source, "A009", GetUnitTalentLevel(source, "talent_reinforce"))
        end

    end


    ---@param source unit
    ---@param target unit
    ---@param skill table
    ---@param level integer
    ---@param ability_instance table
    function OnSkillPrecast(source, target, skill, level, ability_instance)
        local unit_data = GetUnitData(source)


            if skill.Id == "A00B" then
                local effect = {}
                local starting_angle = -25.

                    for i = 1, 3 do
                        effect[i] = AddSpecialEffect("Effect\\effect_yujingzhi.mdx", GetUnitX(source), GetUnitY(source))
                        BlzSetSpecialEffectYaw(effect[i], math.rad(GetUnitFacing(source) + starting_angle))
                        starting_angle = starting_angle + 25.
                        BlzSetSpecialEffectTimeScale(effect[i], 2.5)
                        DelayAction(0.85, function() DestroyEffect(effect[i]) end)
                    end

            end


            if GetUnitTalentLevel(source, "talent_overflow") > 0 and skill.category == SKILL_CATEGORY_FIRE and skill.classification == SKILL_CLASS_ATTACK then
                if GetUnitState(source, UNIT_STATE_MANA) / BlzGetUnitMaxMana(source) >= 0.6 then
                    local talent_level = GetUnitTalentLevel(source, "talent_overflow")
                    ModifyAbilityInstance(ability_instance, "power_multiplier", talent_level, 0.3, MULTIPLY_BONUS)
                    ability_instance.manacost = talent_level == 1 and ability_instance.manacost * 1.5 or ability_instance.manacost * 2.
                end
            end

            if unit_data.heating_up_boost then
                ModifyAbilityInstance(ability_instance, "power_multiplier", 1, 0.4, MULTIPLY_BONUS)
            end

            if skill.category == SKILL_CATEGORY_LIGHTNING and skill.classification == SKILL_CLASS_ATTACK and unit_data.arc_discharge_boost then
                ModifyAbilityInstance(ability_instance, "power_multiplier", unit_data.arc_discharge_boost, 0.1, MULTIPLY_BONUS)
                --ability_instance.tags[#ability_instance.tags+1] = "talent_arc_discharge" .. unit_data.arc_discharge_boost
            end

            if GetUnitTalentLevel(source, "talent_sharpened_blade") > 0 then
                local unit_data = GetUnitData(source)

                if unit_data.sharpened_blade_counter > 0 then
                    ability_instance.tags[#ability_instance.tags+1] = "talent_sharpened_blade"
                end

            end

            if skill.Id ~= "AACS" and unit_data.curved_strike_stacks and unit_data.curved_strike_stacks > 0 then
                ModifyAbilityInstance(ability_instance, "power_multiplier", unit_data.curved_strike_stacks, 0.5, MULTIPLY_BONUS)
                --ability_instance.power_multiplier = (ability_instance.power_multiplier or 0.)  + (0.5 * unit_data.curved_strike_stacks)
                print("prepare to boost")
            end


    end



    function OnItemUse(source, item, target)
        local id = GetItemTypeId(item)

            if id == FourCC(ITEM_POTION_HEALTH_WEAK) then ApplyEffect(source, nil, 0.,0., "PHWK", 1)
            elseif id == FourCC(ITEM_POTION_MANA_WEAK) then ApplyEffect(source, source, 0.,0., "PMWK", 1)
            elseif id == FourCC(ITEM_POTION_HEALTH_HALF) then ApplyEffect(source, source, 0.,0., "PHWK", 2)
            elseif id == FourCC(ITEM_POTION_MANA_HALF) then ApplyEffect(source, source, 0.,0., "PMWK", 2)
            elseif id == FourCC(ITEM_POTION_HEALTH_STRONG) then ApplyEffect(source, source, 0.,0., "PHWK", 3)
            elseif id == FourCC(ITEM_POTION_MANA_STRONG) then ApplyEffect(source, source, 0.,0., "PMWK", 3)
            elseif id == FourCC(ITEM_POTION_MIX_WEAK) then ApplyEffect(source, source, 0.,0., "PHUN", 1)
            elseif id == FourCC(ITEM_POTION_MIX_HALF) then ApplyEffect(source, source, 0.,0., "PHUN", 2)
            elseif id == FourCC(ITEM_POTION_MIX_STRONG) then ApplyEffect(source, source, 0.,0., "PHUN", 3)
            elseif id == FourCC(ITEM_POTION_ANTIDOTE) then ApplyEffect(source, source, 0.,0., "PANT", 1)
            elseif id == FourCC(ITEM_POTION_ADRENALINE) then ApplyEffect(source, source, 0.,0., "PADR", 1)
            elseif id == FourCC(ITEM_SCROLL_OF_PROTECTION) then ApplyEffect(source, source, 0.,0., "SOTP", 1)
            elseif id == FourCC(ITEM_SCROLL_OF_PETRI) then ApplyEffect(source, source, 0.,0., "SOPT", 1)
            elseif id == FourCC(ITEM_FOOD) then ApplyEffect(source, source, 0.,0., "food_effect", 1)
            elseif id == FourCC(ITEM_DRINKS) then ApplyEffect(source, source, 0.,0., "drinks_effect", 1)
            elseif id == FourCC(ITEM_SCROLL_OF_TOWN_PORTAL) then
                local x = GetUnitX(source); local y = GetUnitY(source)
                local portal = AddSpecialEffect("Spell\\D2Portal.mdx", x + 50., y + 50.)
                local rect = Rect((x + 50.) - 50., (y + 50.) - 25., (x + 50.) + 50., (y + 50.) + 25.)
                local region = CreateRegion()
                local trg = CreateTrigger()

                    RegionAddRect(region, rect)
                    BlzSetSpecialEffectScale(portal, 1.6)
                    AddSoundVolume("Sound\\portalcast.wav", x + 50., y + 50., 128, 1900.)

                    TriggerRegisterEnterRegion(trg, region, nil)
                    TriggerAddAction(trg, function()
                        if IsAHero(GetTriggerUnit()) then
                            AddSoundVolume("Sound\\portalenter.wav",GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit()), 125, 1500.)
                            SetUnitPosition(GetTriggerUnit(), GetRectCenterX(gg_rct_portal_location), GetRectCenterY(gg_rct_portal_location))
                            local minions = GetAllUnitSummonUnits(PlayerHero[GetPlayerId(GetOwningPlayer(GetTriggerUnit()))+1])

                            x = GetRectCenterX(gg_rct_portal_location); y = GetRectCenterY(gg_rct_portal_location)
                            ForGroup(minions, function()
                                local angle = GetRandomReal(0., 360.)
                                local distance = GetMaxAvailableDistance(x, y, angle, GetRandomReal(150., 450.))
                                SetUnitX(GetEnumUnit(), x + Rx(distance, angle))
                                SetUnitY(GetEnumUnit(), y + Ry(distance, angle))
                            end)

                            DestroyGroup(minions)
                        end
                    end)

                    DelayAction(15., function()
                        DestroyEffect(portal)
                        RemoveRect(rect)
                        RemoveRegion(region)
                        DestroyTrigger(trg)
                    end)
            elseif id == FourCC("I027") then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdx", source, "chest"))
                AddSoundVolume("Sound\\speed_potion.wav",GetUnitX(source),GetUnitY(source), 120, 1500.)
                ResetPlayerTalents(GetPlayerId(GetOwningPlayer(source))+1)
            elseif id == FourCC("I02H") then
                local x, y = GetUnitX(source) + GetRandomReal(-75., 75.), GetUnitY(source) + GetRandomReal(-75., 75.)
                local box = AddSpecialEffect("Item\\Lootbox_Vault.mdx", x, y)
                BlzSetSpecialEffectScale(box, 0.8)
                DestroyEffect(box)
                DelayAction(1.91, function() DropDroplistForPlayer(GetPlayerId(GetOwningPlayer(source))+1, x, y, 75., 150., GetDropList("supply_crate"))  end)
            elseif id == FourCC("I02M") then
                QuartermeisterScoutQuest_MapActivated(GetPlayerId(GetOwningPlayer(source))+1)
            elseif id == FourCC("I038") then
                if IsUnitInQuestArea(source, test_area) then
                    print("fuck yeah")
                end
            elseif id == FourCC("I03K") then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdx" ,source, "origin"))
                ModifyStat(source, EXP_BONUS, 10, STRAIGHT_BONUS, true)
                DelayAction(1800., function() ModifyStat(source, EXP_BONUS, 10, STRAIGHT_BONUS, false) end)
            elseif id == FourCC("I03L") then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdx" ,source, "origin"))
                ModifyStat(source, EXP_BONUS, 20, STRAIGHT_BONUS, true)
                DelayAction(1800., function() ModifyStat(source, EXP_BONUS, 20, STRAIGHT_BONUS, false) end)
            elseif id == FourCC("I03M") then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdx" ,source, "origin"))
                ModifyStat(source, EXP_BONUS, 30, STRAIGHT_BONUS, true)
                DelayAction(1800., function() ModifyStat(source, EXP_BONUS, 30, STRAIGHT_BONUS, false) end)
            elseif id == FourCC("I03N") then
                DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdx" ,source, "origin"))
                ModifyStat(source, EXP_BONUS, 40, STRAIGHT_BONUS, true)
                DelayAction(1800., function() ModifyStat(source, EXP_BONUS, 40, STRAIGHT_BONUS, false) end)
            elseif id == FourCC("I03Q") then
                AddSoundVolume("Sound\\strengh_potion.wav", GetUnitX(source), GetUnitY(source), 125, 1500.)
                ApplyBuff(source, source, "APEI", 1)
            elseif id == FourCC("I03P") then

                for i = 1, 2 do
                    DelayAction(0.2 * i, function()
                        local angle = GetRandomReal(0., 360.)
                        local range = GetMaxAvailableDistance(GetUnitX(source), GetUnitY(source), angle,  GetRandomReal(150., 400.))
                        local x,y = GetUnitX(source) + Rx(range, angle), GetUnitY(source) + Ry(range, angle)

                            CreateNecromancerCorpse(GetOwningPlayer(source), x, y)
                            DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdx",  x, y))

                    end)

                end

            end


    end

    
    
    function OnItemEquip(unit, item, disarmed_item, flag)

        if item and GetUnitTalentLevel(unit, "talent_blade_dance") > 0 and IsItemType(item, ITEM_TYPE_WEAPON) then
            BladeDanceTalentEffect(unit)
        end

        if item and GetUnitTalentLevel(unit, "talent_momentum") > 0 and IsItemType(item, ITEM_TYPE_WEAPON) then
            MomentumTalentEffect(unit)
        end
        
    end


    function OnItemDrop(unit, item)

    end

    function OnItemPickUp(unit, item)

        if GetItemTypeId(item) == FourCC("I01O") then
            if not HasJournalEntryLabel(GetPlayerId(GetOwningPlayer(unit))+1, "shrine_journal", "shrine_journal_stone_aquired") and not HasJournalEntryLabel(GetPlayerId(GetOwningPlayer(unit))+1, "shrine_journal", "shrine_journal_stone_aquired_first") then
                local player = GetPlayerId(GetOwningPlayer(unit))+1

                    if HasJournalEntryLabel(player, "shrine_journal", "shrine_journal_stone_seek") then
                        AddJournalEntryText(player, "shrine_journal",
                                GetLocalString(ParseStringHeroGender(unit, "Я @Mнашел!Fнашла# что-то похожее на то о чем говорил Анар. Нужно показать ему этот самоцвет."),
                                        "Looks like I have got something what Anar is spoken about. I shall show it to him."), true)
                        AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_stone_aquired")
                        LockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_2", player)
                        UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_3", player)
                    else
                        AddJournalEntry(player, "shrine_journal", "GUI\\BTNRuby.blp", GetLocalString("Камень Ненависти", "The Shard of Hate"), 200, false)
                        AddJournalEntryText(player, "shrine_journal",
                            GetLocalString(ParseStringHeroGender(unit, "Я @Mнашел!Fнашла# необычный самоцвет. Нужно порасспрашивать о нем, может кто-то знает что это."),
                                    "I have found an unusual gem. I shall ask people about it, may be someone knows something."), true)
                        --SetPlayerLabel(player, "shrine_label", "shrine_stone_aquired_first")
                        AddJournalEntryLabel(player, "shrine_journal", "shrine_journal_stone_aquired_first")
                        UnlockInteractiveOptionIdPlayer(gg_unit_n029_0022, "anar_altar_conv_stone_before", player)
                    end

            end
        end

        if GetItemType(item) == ITEM_TYPE_PERMANENT then
            local player = GetPlayerId(GetOwningPlayer(unit))+1

                if not HasJournalEntry(player, "librarian_journal") then
                    local item_data = GetItemData(item)

                    if item_data.improving_skill and item_data.restricted_to ~= GetUnitClass(unit) then
                        AddJournalEntry(player, "librarian_journal", "Journal\\BTNMagocracy2.blp", GetLocalString("Библиотекарь", "The Librarian"), 75, false)
                        AddJournalEntryText(player, "librarian_journal",
                            GetLocalString(ParseStringHeroGender(unit, "Я @Mнашел!Fнашла# книгу которую не могу прочитать. Нужно найти библиотекаря в замке."),
                                    "I have found a book that I can't read. I should find a librarian within a castle."), true)
                        EnableJournalTrackingButton(player, "librarian_journal", gg_unit_n01V_0110)
                        UnlockInteractiveOptionIdPlayer(gg_unit_n01V_0110, "librarian_new_book", player)
                    end
                end


        end
        
    end

    function OnTeleportPadUsed(player)

        if HasJournalEntry(player, "quest_anar_supplies") then
            DisableJournalTrackingButton(player, "quest_anar_supplies")
        end

    end


end



