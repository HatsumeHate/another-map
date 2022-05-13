do




    function OnUnitCreated(new_unit)
        local unit_data = GetUnitData(new_unit)


        if GetUnitTypeId(new_unit) == FourCC("n00N") then
            SetDropList(new_unit, "chest")
        elseif GetUnitTypeId(new_unit) == FourCC("U000") then
            MephistoSouls(new_unit)
        end


        if unit_data.classification and unit_data.classification == MONSTER_RANK_BOSS  then
            unit_data.minimap_icon = CreateMinimapIconOnUnit(new_unit, 255, 255, 255, "Marker\\MarkBoss.mdx", FOG_OF_WAR_VISIBLE)
        end

        if GetOwningPlayer(new_unit) == SECOND_MONSTER_PLAYER or GetOwningPlayer(new_unit) == MONSTER_PLAYER or GetOwningPlayer(new_unit) == Player(12) then
            ScaleMonsterUnit(new_unit, Current_Wave)
            GroupAddUnit(ScaleMonstersGroup, new_unit)
            if not unit_data.classification or unit_data.classification ~= MONSTER_RANK_BOSS and GetUnitAbilityLevel(new_unit, FourCC("Avul")) == 0 then
                CreateBarOnUnit(new_unit)
            end

            if unit_data.classification then
                if unit_data.classification == MONSTER_RANK_COMMON then SetDropList(new_unit, "common_enemy")
                elseif unit_data.classification == MONSTER_RANK_ADVANCED then SetDropList(new_unit, "adv_enemy")
                elseif unit_data.classification == MONSTER_RANK_BOSS then SetDropList(new_unit, "boss_enemy") end
            end
        end


    end


    function OnUnitDeath(unit, killer)

        if killer then

            if GetUnitTalentLevel(killer, "talent_incinerate") > 0 then
                ApplyBuff(killer, killer, "ATIN", GetUnitTalentLevel(killer, "talent_incinerate"))
            end

            if GetUnitTalentLevel(killer, "talent_crystallization") > 0 and HasNegativeState(unit, STATE_FREEZE) then
                ApplyEffect(killer, nil, GetUnitX(unit), GetUnitY(unit), "crystallization_effect", GetUnitTalentLevel(killer, "talent_crystallization"))
            end

            if GetUnitTalentLevel(killer, "talent_carnage") > 0 then
                ApplyBuff(killer, killer, "ATCR", GetBuffLevel(killer, "ATCR") + 1)
            end

            if GetUnitTalentLevel(killer, "talent_leeches") > 0 then
                for i = 1, GetUnitTalentLevel(killer, "talent_leeches") do
                    local leech = CreateUnit(GetOwningPlayer(killer), FourCC("u00T"), GetUnitX(unit) + GetRandomReal(-50., 50.), GetUnitY(unit) + GetRandomReal(-50., 50.), GetRandomReal(0.,360.))
                    UnitApplyTimedLife(leech, 0, 5.)
                    DelayAction(0., function()
                        local unit_data = GetUnitData(leech)
                        ModifyStat(leech, PHYSICAL_ATTACK, Current_Wave, STRAIGHT_BONUS, true)
                    end)
                end
            end

            if GetUnitTalentLevel(killer, "talent_ritual") > 0 then
                ApplyBuff(killer, killer, "ARTL", GetUnitTalentLevel(killer, "talent_ritual"))
            end


            local unit_data = GetUnitData(killer)
            local dead_unit_data = GetUnitData(unit)

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
                OnUnitDeath(unit, unit_data.minion_owner)
            end

        end

    end


    function OnUnitEffectApply(unit, effect_id)

    end

    function OnUnitEffectEnd(unit, effect_id)

    end


    function OnChargeEnd(source, targets_hit, sign, negative_state)


    end


    function OnChargeHit(source, target, sign)
        if sign == "abch" then
            ApplyEffect(source, target, 0.,0., "EBCS", Current_Wave)
        elseif sign == "aach" then
            ApplyEffect(source, target, 0.,0., "EACH", Current_Wave)
            PushUnit(source, target, AngleBetweenUnits(source,target), 150., 0.7, "aach")
        elseif sign == "brch" then
            ApplyBuff(source, target, "ABRS", 1)
        end
        return false
    end


    function OnJumpExpire(target, sign)
        if sign == "A00O" then
            if UnitHasEffect(target, "BSTR") then
                ApplyEffect(target, nil, 0., 0., "ELBS", 1)
            end
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
            ApplyBuff(data.source, target, 'A012', UnitGetAbilityLevel(data.source, "A00B"))
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
            DelayAction(2.33, function()
                SafePauseUnit(reanimated, false)
            end)
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
        end
    end


    ---@param missile table
    ---@param source unit
    ---@param target unit
    function OnMissileLaunch(source, target, missile)

        if missile.id == 'M001' then
            local timer = CreateTimer()
            TimerStart(timer, 0.25, true, function ()
                RedirectMissile_Deg(missile, GetRandomReal(0., 359.))
                if missile == nil then
                    DestroyTimer(GetExpiredTimer())
                end
            end)
        elseif missile.id == "MBCH" then
            BuildChain(source, missile)
        elseif missile.id == "MSHG" then
            CastShatterGround(source, missile)
        elseif missile.id == "MSCN" then
            SummonCurse(missile)
        elseif missile.id == "MRLR" then
            RevenantLaserMissile(source, missile)
        elseif missile.id == "MNBS" then
            BoneSpearCast(source, missile)
        end

        if GetUnitTalentLevel(source, "talent_penetration") > 0 and missile.can_enum then
            missile.penetrate = true
            missile.hit_once_in = 5.
            missile.max_targets = 300
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
                if GetUnitState(target, UNIT_STATE_LIFE) / GetUnitState(target, UNIT_STATE_MAX_LIFE) <= 0.2  then
                    leveled_effect.power = R2I(leveled_effect.power * 3)
                    leveled_effect.bonus_crit_chance = 20.
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
            elseif UnitHasEffect(source, "PNEC") then
                if effect.id == "ECSP" then
                    leveled_effect.can_crit = true
                    leveled_effect.bonus_crit_chance = 25.
                end
            elseif effect.id == "EBLZ" then
                local unit_data = GetUnitData(source)
                effect.level[effect.current_level].area_of_effect = 200. * (1. + unit_data.blz_scale)
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
            leveled_effect.power = leveled_effect.power * (1 + 0.1 * GetUnitTalentLevel(source, "talent_overflow"))
        end

        if HasTag(effect.tags, "talent_heating_up") and leveled_effect.attribute and leveled_effect.attribute == FIRE_ATTRIBUTE then
            leveled_effect.power = leveled_effect.power * 1.4
        end

        if HasTag(effect.tags, "talent_arc_discharge1") or HasTag(effect.tags, "talent_arc_discharge2") or HasTag(effect.tags, "talent_arc_discharge3") then
            local unit_data = GetUnitData(source)
            local boost_level = 1


            if HasTag(effect.tags, "talent_arc_discharge2") then boost_level = 2
            elseif HasTag(effect.tags, "talent_arc_discharge3") then boost_level = 3 end

            leveled_effect.power = leveled_effect.power * (1. + (0.1 * boost_level))
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

        if effect.id == "effect_pursuer" then
            effect.current_level = GetUnitTalentLevel(source, "talent_pursuer")
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
    ---@param target unit
    ---@param buff table
    function OnBuffExpire(source, target, buff)

            if buff.id == "A01S" and buff.current_level == 15 then
                local unit_data = GetUnitData(target)
                    unit_data.hp_vector = true
                    UpdateUnitParameter(target, HP_REGEN)
            end


            if GetUnitTalentLevel(target, "talent_pain_killer") > 0 then
                local buff_id = buff.id
                DelayAction(0., function()
                    if GetUnitAbilityLevel(target, FourCC("A00V")) == 0 and GetUnitAbilityLevel(target, FourCC("ANRD")) == 0 and GetUnitAbilityLevel(target, FourCC("A01N")) == 0 then
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

        if buff.id == "ABWK" or buff.id == "ABDC" then

            if GetUnitTalentLevel(source, "talent_vile_malediction") > 0 then
                VileMaledictionStack(source, target, false)
            end

            DelayAction(0., function()
                local duration = GetMaxDurationCurse(source, target)

                if duration > 0. then

                    if GetUnitTalentLevel(source, "talent_frailty") > 0 then
                        ApplyBuff(source, target, "AFRL", GetUnitTalentLevel(source, "talent_frailty"))
                        local newbuff = GetBuffDataFromUnit(target, "AAMD")
                        newbuff.expiration_time = duration
                    end

                    if GetUnitTalentLevel(source, "talent_amplify_damage") > 0 then
                        ApplyBuff(source, target, "AAMD", GetUnitTalentLevel(source, "talent_amplify_damage"))
                        local newbuff = GetBuffDataFromUnit(target, "AAMD")
                    newbuff.expiration_time = duration
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
            local buff_id = buff.id
            if buff_id == "A00V" or buff_id == "ANRD" or buff_id == "A01N" then
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

        if buff.id == "ABWK" or buff.id == "ABDC" then

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


            if GetUnitTalentLevel(source, "talent_frailty") > 0 then
                ApplyBuff(source, target, "AFRL", GetUnitTalentLevel(source, "talent_frailty"))
                local newbuff = GetBuffDataFromUnit(target, "AFRL")
                newbuff.expiration_time = buff.expiration_time
            end

            if GetUnitTalentLevel(source, "talent_amplify_damage") > 0 then
                ApplyBuff(source, target, "AAMD", GetUnitTalentLevel(source, "talent_amplify_damage"))
                local newbuff = GetBuffDataFromUnit(target, "AAMD")
                newbuff.expiration_time = buff.expiration_time
            end

            if GetUnitTalentLevel(source, "talent_face_of_death") > 0 then
                ApplyBuff(source, target, "AFOD", GetUnitTalentLevel(source, "talent_face_of_death"))
            end

            if GetUnitTalentLevel(source, "talent_persistent_curse") > 0 then
               buff.expiration_time = buff.expiration_time + (GetUnitTalentLevel(source, "talent_persistent_curse") * 1)
            end
        end

        if GetUnitTalentLevel(source, "talent_insanity") > 0 then
            if buff.level[buff.current_level].negative_state == STATE_FEAR then
                ApplyBuff(source, target, "AINS", GetUnitTalentLevel(source, "talent_insanity"))
                local newbuff = GetBuffDataFromUnit(target, "AINS")
                newbuff.expiration_time = buff.expiration_time
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

        if damage_data.effect and damage_data.effect.id == "EEXC" then
            local ability_level = UnitGetAbilityLevel(source, "A020")
            if ability_level >= 10 and GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                ApplyBuff(source, source, "ANRD", ability_level)
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

        if GetUnitTalentLevel(source, "talent_sweeping_strikes") > 0 and (not damage_data.effect or damage_data.effect.eff.id == "critical_strike_effect") then
            if GetUnitTalentLevel(source, "talent_sweeping_strikes") < 3 then
                local unit_data = GetUnitData(source)
                if unit_data.sweeping_strikes_main_target and unit_data.sweeping_strikes_main_target ~= target then
                    damage_data.damage = damage_data.damage * (math.floor(33. * GetUnitTalentLevel(source, "talent_sweeping_strikes") + 0.5) * 0.01)
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
            if UnitHasEffect(source, "item_enrage") and Chance(5.) then ApplyBuff(source, source, "AIEN", 1) end
            if UnitHasEffect(source, "item_conduction") and Chance(5.) then ApplyBuff(source, source, "AICN", 1) end

            if UnitHasEffect(source, "EHOR") then
                if Chance(20.) then ApplyEffect(source, target, 0, 0, "EHOR", 1) end
            end

            if UnitHasEffect(source, "trait_chill") then
                if Chance(35.) then ApplyBuff(source, target, "ATCH", 1) end
            elseif UnitHasEffect(source, "trait_overpower") then
                if Chance(35.) then PushUnit(source, target, AngleBetweenUnits(source,target), 250., 1.35, "trait_overpower") end
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

            if GetUnitTalentLevel(source, "talent_pursuer") > 0 and attack_data.myeffect and attack_data.myeffect.id ~= "effect_pursuer" then
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


        return attack_data
    end


    ---@param source unit
    ---@param target unit
    ---@param skill table
    ---@param x real
    ---@param y real
    function OnSkillCastEnd(source, target, x, y, skill, ability_level)
        local id = skill.Id

        if id == 'A00L' then CastSorceressBlink(source, x, y, skill)
        elseif id == 'A00I' then SummonHydra(source, x, y)
        elseif id == "A003" and UnitHasEffect(source, "ITCH") then
            skill.level[ability_level].missile = "MFRB"
            CastFrostbolt_Legendary(source, target, x, y)
        elseif id == "AMLT" then CastMeltdown(source)
        elseif id == "ABLZ" then CastBlizzard(source)
        elseif id == "ASIR" then IcicleRainCast(source, x, y)
        elseif id == "AFRW" then FireWallCast(source, x, y)
        elseif id == 'A00J' then
            if UnitHasEffect(source,"EOTS") then SparkCast_Legendary(source)
            else SparkCast(source, target, x, y) end
        elseif id == "A019" then ChainLightningCast(source, target)
        elseif id == 'A00O' then MakeUnitJump(source, AngleBetweenUnitXY(source, x, y), x, y, 920., 0.6, 'A00O', { effect = "Spell\\Valiant Charge.mdx", point = "origin" })
        elseif id == 'A010' then WhirlwindActivate(source)
        elseif id == 'A00B' then
            local effect = AddSpecialEffect("Spell\\DetroitSmash_Effect.mdx", GetUnitX(source) + Rx(50., GetUnitFacing(source)), GetUnitY(source) + Ry(50., GetUnitFacing(source)))
            BlzSetSpecialEffectOrientation(effect, GetUnitFacing(source) * bj_DEGTORAD, 0., 0.)
            BlzSetSpecialEffectZ(effect, GetUnitZ(source) + 40.)
            BlzSetSpecialEffectScale(effect, 0.7)
            DestroyEffect(effect)
        elseif id == "A006" then
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
        elseif id == "ANRD" then RaiseSkeletonSkill(source)
        elseif id == "ANLR" then RaiseLichCast(source)
        elseif id == "ANBB" then BoneBarrage(source, x, y)
        elseif id == "ANPB" then PoisonBlast(source)
        elseif id == "ANDV" then DevourSkill(source)
        elseif id == "ANCE" then CorpseExplosionCast(source, x, y)
        elseif id == "ANUL" then UndeadLandCast(source)
        elseif id == "ANGS" then GrowSpikesCast(source)
        elseif id == "ANDR" then DarkReignCast(source)
        elseif id == "ANUC" then UnholyCommandCast(source)
        elseif id == "ANBR" then RipBonesCast(source)
        elseif id == "ASQT" then SpiderQueen_WebTrap(source)
        elseif id == "ASQS" then SpiderQueen_SpawnBrood(source)
        elseif id == "ABCH" then ChargeUnit(source, 750., 600., GetUnitFacing(source), 1, 100., "walk", "abch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" } )
        elseif id == "AACH" then ChargeUnit(source, 500., 500., GetUnitFacing(source), 1, 100., "walk", "aach", { effect = "Spell\\Valiant Charge Fel.mdx", point = "origin" } )
        elseif id == "AAPN" then CreatePoisonNova(source)
        elseif id == "ASSM" then SpawnSkeletons(source)
        elseif id == "AMLN" then LightningNovaBoss(source)
        elseif id == "AQBC" then ChargeUnit(source, 600., 350., GetUnitFacing(source), 1, 75., "walk", "brch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" } )
        elseif id == "AWRG" then ApplyBuff(source, target, "AWRB", 1)
        elseif id == "AVDS" then CastVoidDisc(source, x, y)
        elseif id == "AVDR" then CreateVoidRain(source, x, y, 550., 3.5)
        elseif id == "AFRR" then CreateFireRain(source, x, y, 600., 4.5)
        elseif id == "ANRA" then CastReanimate(source)
        elseif id == "AAPB" then PoisonBarrage(source, x, y)
        elseif id == "ABSS" then SummonTentacle(source, x, y)
        elseif id == "ASBL" then SatyrBlinkCast(source)
        elseif id == "AFBB" then IceBlastCast(source, x, y)
        elseif id == "AARB" then AstralBarrageCast(source)
        elseif id == "ABRR" then BloodRavenReviveCast(source)
        end


        if skill.category == SKILL_CATEGORY_FIRE and GetUnitTalentLevel(source, "talent_heating_up") > 0 then
            StackHeatingUp(source)
        end

        if GetUnitTalentLevel(source, "talent_arc_discharge") > 0 then
            local unit_data = GetUnitData(source)
                if unit_data.arc_discharge_boost and skill.category == SKILL_CATEGORY_LIGHTNING then
                    unit_data.arc_discharge_boost = 0
                    DestroyEffect(unit_data.arc_discharge_boost_effect)
                    unit_data.arc_discharge_boost_effect = nil
                    ResumeTimer(unit_data.arc_discharge_boost_timer)
                end
        end

        if skill.classification == SKILL_CLASS_ATTACK then
            if GetUnitTalentLevel(source, "talent_rage") > 0 then
                RageTalentEffect(source)
            end
        end

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

        if GetUnitTalentLevel(source, "talent_abyss_awakens") > 0 then
            AbyssAwakensTalent(source)
        end

        if GetUnitTalentLevel(source, "talent_death_march") > 0 then
            ApplyBuff(source, source, "ADEM", GetUnitTalentLevel(source, "talent_death_march"))
        end



    end


    ---@param source unit
    ---@param target unit
    ---@param x real
    ---@param y real
    ---@param skill table
    function OnSkillCast(source, target, x, y, skill, ability_level)

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

    end


    ---@param source unit
    ---@param target unit
    ---@param skill table
    ---@param level integer
    ---@param skill_data table
    function OnSkillPrecast(source, target, skill, level, skill_data)
        local unit_data = GetUnitData(source)

            if GetUnitTalentLevel(source, "talent_overflow") > 0 and skill.category == SKILL_CATEGORY_FIRE then
                if GetUnitState(source, UNIT_STATE_MANA) / BlzGetUnitMaxMana(source) >= 0.6 then

                    skill_data.tags[#skill_data.tags+1] = "talent_overflow"

                    if skill.Id == "AMLT" or skill.Id == "A00I" then
                        unit_data.boost_overflow = true
                    end

                    if GetUnitTalentLevel(source, "talent_overflow") == 1 then skill_data.manacost = skill_data.manacost * 1.5
                    else skill_data.manacost = skill_data.manacost * 2. end
                end
            end

            if unit_data.heating_up_boost then
                skill_data.tags[#skill_data.tags+1] = "talent_heating_up"
            end

        if unit_data.arc_discharge_boost then
            skill_data.tags[#skill_data.tags+1] = "talent_arc_discharge" .. unit_data.arc_discharge_boost
        end

        if GetUnitTalentLevel(source, "talent_sharpened_blade") > 0 then
            local unit_data = GetUnitData(source)

            if unit_data.sharpened_blade_counter > 0 then
                skill_data.tags[#skill_data.tags+1] = "talent_sharpened_blade"
            end

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
                            local minions = GetAllUnitSummonUnits(PlayerHero[player])

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
        
    end


end



