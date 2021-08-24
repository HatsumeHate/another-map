do




    function OnUnitCreated(new_unit)
        if GetOwningPlayer(new_unit) == SECOND_MONSTER_PLAYER or GetOwningPlayer(new_unit) == MONSTER_PLAYER then
            ScaleMonsterUnit(new_unit, Current_Wave)
        end

        if GetUnitTypeId(new_unit) == FourCC("U000") then
            MephistoSouls(new_unit)
        end

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
            local abil_level = UnitGetAbilityLevel(target, "A00A")
            if abil_level >= 10 then
                --ApplyBuff(source, target, "", abil_level)
            end
            RemoveBuff(source, "A013")
        end
    end


    function OnPushExpire(source, data)
        if data.sign == 'EUPP' then
            ApplyBuff(data.source, source, 'A012', UnitGetAbilityLevel(source, "A00B"))
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
            elseif UnitHasEffect(source, "FRBD") then
                if leveled_effect.attribute and (leveled_effect.power or leveled_effect.attack_percent_bonus) and leveled_effect.attribute == FIRE_ATTRIBUTE then
                    leveled_effect.power = leveled_effect.power * 1.35
                end
            elseif UnitHasEffect(source, "PNEC") then
                if effect.id == "ECSP" then
                    leveled_effect.can_crit = true
                    leveled_effect.bonus_crit_chance = 25.
                end
            elseif effect.id == "EBLZ" then
                local unit_data = GetUnitData(source)

                    effect.level[effect.current_level].area_of_effect = 200. * (1. + unit_data.blz_scale)

            elseif UnitHasEffect(source, "EOTS") then
                if effect.id == "EDSC" then
                    leveled_effect.power = leveled_effect.power * 1.15
                end
            elseif effect.id == "ESQB" or effect.id == "ECSC" or effect.id == "EAPN" then
                effect.current_level = Current_Wave
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



    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffExpire(source, target, buff)
        if buff.id == "A01S" and buff.current_level == 15 then
            local unit_data = GetUnitData(target)
                unit_data.hp_vector = true
                UpdateUnitParameter(target, HP_REGEN)
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

    end

    ---@param source unit
    ---@param target unit
    ---@param buff table
    function OnBuffPrecast(source, target, buff)

    end



    ---@param source unit
    ---@param target unit
    ---@param damage table
    function OnDamage_End(source, target, damage, damage_data)
        if damage_data.effect and damage_data.effect.id == "EEXC" then
            local ability_level = UnitGetAbilityLevel(source, "A020")
            if ability_level >= 10 and GetUnitState(target, UNIT_STATE_LIFE) < 0.045 then
                ApplyBuff(source, source, "ANRD", ability_level)
            end
        end
    end

    ---@param source unit
    ---@param damage table
    function OnDamage_PreHit(source, target, damage, damage_data)

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
            elseif UnitHasEffect(source, "MOFE") then

                if attack_data.attribute == ICE_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEI", 1)
                elseif attack_data.attribute == FIRE_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEF", 1)
                elseif attack_data.attribute == LIGHTNING_ATTRIBUTE then ApplyEffect(source, target, 0,0, "EMEL", 1) end

            elseif UnitHasEffect(source, "RDAG") then ApplyEffect(source, source, 0, 0, "ERIT", 1)
            elseif UnitHasEffect(source, "EBBS") then ApplyEffect(source, target, 0.,0., "EBBS", 1)
            elseif UnitHasEffect(target, "ECBG") then
                if Chance(15.) then ApplyEffect(target, target, 0, 0, "ECBG", 1) end
            elseif UnitHasEffect(source, "EHOR") then
                if Chance(20.) then ApplyEffect(source, target, 0, 0, "EHOR", 1) end
            end

        AI_AttackReaction(source, target)

        attack_data = nil
    end

    ---@param source unit
    ---@param target unit
    function OnAttackStart(source, target)

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
                        DestroyTimer(GetExpiredTimer())
                    end
                    time = time - 0.025
                end)

        elseif id == "ASQT" then SpiderQueen_WebTrap(source)
        elseif id == "ASQS" then SpiderQueen_SpawnBrood(source)
        elseif id == "ABCH" then ChargeUnit(source, 750., 600., GetUnitFacing(source), 1, 100., "walk", "abch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" } )
        elseif id == "AACH" then ChargeUnit(source, 500., 500., GetUnitFacing(source), 1, 100., "walk", "aach", { effect = "Spell\\Valiant Charge Fel.mdx", point = "origin" } )
        elseif id == "AAPN" then CreatePoisonNova(source)
        elseif id == "ASSM" then SpawnSkeletons(source)
        elseif id == "AMLN" then LightningNovaBoss(source)
        elseif id == "AQBC" then ChargeUnit(source, 600., 350., GetUnitFacing(source), 1, 75., "walk", "brch", { effect = "Spell\\Valiant Charge.mdx", point = "origin" } )
        elseif id == "AWRG" then ApplyBuff(source, target, "AWRB", 1)
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
                            PlayLocalSound("Sound\\portalenter.wav", GetPlayerId(GetOwningPlayer(GetTriggerUnit())), 125)
                            SetUnitPosition(GetTriggerUnit(), GetRectCenterX(gg_rct_portal_location), GetRectCenterY(gg_rct_portal_location))
                        end
                    end)

                    DelayAction(15., function()
                        DestroyEffect(portal)
                        RemoveRect(rect)
                        RemoveRegion(region)
                        DestroyTrigger(trg)
                    end)
            end

    end


end



