---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 01.09.2021 0:39
---
do

    local MonsterTraitsData
    MONSTER_TRAIT_ELECTRIFIED = 1
    MONSTER_TRAIT_ENRAGED = 2
    MONSTER_TRAIT_UNSTOPPABLE = 3
    MONSTER_TRAIT_TOXIC = 4
    MONSTER_TRAIT_SPIKY = 5
    MONSTER_TRAIT_BURNING = 6
    MONSTER_TRAIT_CHILLING = 7
    MONSTER_TRAIT_BULKY = 8
    MONSTER_TRAIT_DEFIER = 9
    MONSTER_TRAIT_STURDY = 10
    MONSTER_TRAIT_AGILE = 11
    MONSTER_TRAIT_OVERPOWERING = 12
    MONSTER_TRAIT_ARCANE = 13



    function GetRandomMonsterTrait()
        return GetRandomInt(1, #MonsterTraitsData)
    end

    ---@param unit unit
    function UnitHasAnyTrait(unit)
        local unit_data = GetUnitData(unit)
        return unit_data.traits or #unit_data.traits > 0
    end


    ---@param unit unit
    ---@param trait number
    function UnitHasTrait(unit, trait)
        local unit_data = GetUnitData(unit)

            for i = 1, #unit_data.traits do
                if unit_data.traits[i].trait_id == trait then return true end
            end

        return false
    end

    function AddSpecialEffectTargetEx(effect, unit, point)
        local effect = AddSpecialEffectTarget(effect, unit, point or "origin")
        local trigger = CreateTrigger()
        TriggerRegisterDeathEvent(trigger, unit)
        TriggerAddAction(trigger, function() DestroyEffect(effect); DestroyTrigger(trigger) end)
    end

    ---@param unit unit
    ---@param trait number
    function ApplyMonsterTrait(unit, trait)

        if MonsterTraitsData[trait] then
            local unit_data = GetUnitData(unit)

            MonsterTraitsData[trait].trait_id = trait
            trait = MonsterTraitsData[trait]

            if unit_data.traits then
                for i = 1, #unit_data.traits do
                    if unit_data.traits[i].excludes then
                        for k = 1, #unit_data.traits[i].excludes do
                            if unit_data.traits[i].excludes[k] == trait.trait_id then return false end
                        end
                    elseif trait.trait_id == unit_data.traits[i].trait_id then
                        return false
                    end
                end
            else
                unit_data.traits = {}
            end

            if UnitHasTrait(unit, trait.trait_id) then return false end

            unit_data.traits[#unit_data.traits+1] = trait


            if trait.affix then
                BlzSetUnitName(unit, trait.affix[unit_data.proper_declension] .. GetUnitName(unit))
            elseif trait.suffix then
                BlzSetUnitName(unit, GetUnitName(unit) .. trait.suffix[unit_data.proper_declension])
            end


            if trait.modified_parameters then
                for i = 1, #trait.modified_parameters do
                    ModifyStat(unit, trait.modified_parameters[i].param, trait.modified_parameters[i].value, trait.modified_parameters[i].method, true)
                end
            end

            if trait.applied_effects then
                for i = 1, #trait.applied_effects do
                    UnitAddEffect(unit, trait.applied_effects[i])
                end
            end

            if trait.color then

                unit_data.colours.r = trait.color.r or 255; unit_data.colours.g = trait.color.g or 255; unit_data.colours.b = trait.color.b or 255; unit_data.colours.a = trait.color.a or 255;
                SetUnitVertexColor(unit, trait.color.r or 255, trait.color.g or 255, trait.color.b or 255, trait.color.a or 255)
            end

            if trait.apply_func then
                trait.apply_func(unit)
            end

            if trait.modified_scale then
                --unit_data.scale = unit_data.scale + trait.modified_scale
                --print(BlzGetUnitRealField(unit, UNIT_RF_SCALING_VALUE))
                local new_scale = BlzGetUnitRealField(unit, UNIT_RF_SCALING_VALUE) + trait.modified_scale
                SetUnitScale(unit, new_scale, new_scale, new_scale)
                unit_data.height = unit_data.height * (1. + trait.modified_scale)
            end

            return true

        end

    end


    function InitMonsterTraits()

        MonsterTraitsData = {
            [MONSTER_TRAIT_ELECTRIFIED] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_ELECTRIFIED],
                excludes = { MONSTER_TRAIT_CHILLING, MONSTER_TRAIT_BURNING, MONSTER_TRAIT_TOXIC },
                modified_parameters = {
                    { param = LIGHTNING_RESIST, value = 25, method = STRAIGHT_BONUS },
                    { param = LIGHTNING_BONUS, value = 20, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS },
                },
                color = { r = 125, g = 125, b = 255 },
                applied_effects = { "trait_lightning" },
                apply_func = function(unit)
                    local unit_data = GetUnitData(unit)
                    unit_data.equip_point[WEAPON_POINT].ATTRIBUTE = LIGHTNING_ATTRIBUTE
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Orc\\LightningShield\\LightningShieldTarget.mdx", unit, "origin")
                end
            },
            [MONSTER_TRAIT_TOXIC] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_TOXIC],
                excludes = { MONSTER_TRAIT_CHILLING, MONSTER_TRAIT_BURNING, MONSTER_TRAIT_ELECTRIFIED, MONSTER_TRAIT_ARCANE },
                modified_parameters = {
                    { param = POISON_RESIST, value = 20, method = STRAIGHT_BONUS },
                    { param = POISON_BONUS, value = 20, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS },
                },
                applied_effects = { "trait_toxic" },
                color = { r = 125, g = 255, b = 125 },
                apply_func = function(unit)
                    local unit_data = GetUnitData(unit)
                    unit_data.equip_point[WEAPON_POINT].ATTRIBUTE = POISON_ATTRIBUTE
                    AddSpecialEffectTargetEx("Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdx", unit, "chest")
                end
            },
            [MONSTER_TRAIT_ARCANE] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_ARCANE],
                excludes = { MONSTER_TRAIT_CHILLING, MONSTER_TRAIT_BURNING, MONSTER_TRAIT_ELECTRIFIED, MONSTER_TRAIT_TOXIC },
                modified_parameters = {
                    { param = ARCANE_RESIST, value = 20, method = STRAIGHT_BONUS },
                    { param = ARCANE_BONUS, value = 20, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS },
                },
                applied_effects = { "trait_arcane" },
                color = { r = 185, g = 139, b = 195 },
                apply_func = function(unit)
                    local unit_data = GetUnitData(unit)
                    unit_data.equip_point[WEAPON_POINT].ATTRIBUTE = ARCANE_ATTRIBUTE
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Undead\\VampiricAura\\VampiricAura.mdx", unit, "origin")
                    TraitArcaneEffect(unit)
                end
            },
            [MONSTER_TRAIT_ENRAGED] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_ENRAGED],
                modified_parameters = {
                    { param = PHYSICAL_ATTACK, value = 1.5, method = MULTIPLY_BONUS },
                    { param = MAGICAL_ATTACK, value = 1.5, method = MULTIPLY_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS },
                },
                color = { g = 125, b = 125 },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdx", unit, "hand right")
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdx", unit, "hand left")
                end
            },
            [MONSTER_TRAIT_UNSTOPPABLE] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_UNSTOPPABLE],
                modified_parameters = {
                    { param = HP_VALUE, value = 1.5, method = MULTIPLY_BONUS },
                    { param = CONTROL_REDUCTION, value = 40, method = STRAIGHT_BONUS }
                },
                modified_scale = 0.2,
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdx", unit, "overhead")
                end
            },
            [MONSTER_TRAIT_SPIKY] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_SPIKY],
                modified_parameters = {
                    { param = REFLECT_DAMAGE, value = 200, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS }
                },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\NightElf\\ThornsAura\\ThornsAura.mdx", unit, "origin")
                end
            },
            [MONSTER_TRAIT_BURNING] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_BURNING],
                excludes = { MONSTER_TRAIT_CHILLING, MONSTER_TRAIT_ELECTRIFIED, MONSTER_TRAIT_TOXIC, MONSTER_TRAIT_ARCANE },
                modified_parameters = {
                    { param = FIRE_RESIST, value = 20, method = STRAIGHT_BONUS },
                    { param = FIRE_BONUS, value = 20, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS }
                },
                color = { r = 255, g = 125, b = 125 },
                --applied_effects = { { effect_id = "hwat" } },
                apply_func = function(unit)
                    local unit_data = GetUnitData(unit)
                    unit_data.equip_point[WEAPON_POINT].ATTRIBUTE = FIRE_ATTRIBUTE
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedTarget.mdx", unit, "chest")
                    TraitBurningEffect(unit)
                end
            },
            [MONSTER_TRAIT_CHILLING] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_CHILLING],
                excludes = { MONSTER_TRAIT_BURNING, MONSTER_TRAIT_ELECTRIFIED, MONSTER_TRAIT_TOXIC, MONSTER_TRAIT_ARCANE, MONSTER_TRAIT_OVERPOWERING },
                modified_parameters = {
                    { param = ICE_RESIST, value = 20, method = STRAIGHT_BONUS },
                    { param = ICE_BONUS, value = 20, method = STRAIGHT_BONUS },
                    { param = HP_VALUE, value = 1.25, method = MULTIPLY_BONUS }
                },
                color = { r = 200, g = 200, b = 220 },
                applied_effects = { "trait_chill" },
                apply_func = function(unit)
                    local unit_data = GetUnitData(unit)
                    unit_data.equip_point[WEAPON_POINT].ATTRIBUTE = ICE_ATTRIBUTE
                end
            },
            [MONSTER_TRAIT_BULKY] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_BULKY],
                excludes = { MONSTER_TRAIT_AGILE },
                modified_parameters = {
                    { param = HP_VALUE, value = 2.5, method = MULTIPLY_BONUS },
                    { param = MOVING_SPEED, value = 0.7, method = MULTIPLY_BONUS },
                },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Items\\VampiricPotion\\VampPotionCaster.mdx", unit, "origin")
                end,
                modified_scale = 0.4
            },
            [MONSTER_TRAIT_DEFIER] = {
                suffix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_DEFIER],
                modified_parameters = {
                    { param = MAGICAL_SUPPRESSION, value = 1.5, method = MULTIPLY_BONUS }
                },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Undead\\AntiMagicShell\\AntiMagicShell.mdx", unit, "overhead")
                end
            },
            [MONSTER_TRAIT_STURDY] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_STURDY],
                modified_parameters = {
                    { param = PHYSICAL_DEFENCE, value = 1.5, method = MULTIPLY_BONUS }
                },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Human\\DevotionAura\\DevotionAura.mdx", unit, "origin")
                end
            },
            [MONSTER_TRAIT_AGILE] = {
                suffix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_AGILE],
                excludes = { MONSTER_TRAIT_BULKY },
                modified_parameters = {
                    { param = ATTACK_SPEED, value = 35, method = STRAIGHT_BONUS },
                    { param = CAST_SPEED, value = 35, method = STRAIGHT_BONUS },
                    { param = MOVING_SPEED, value = 55, method = STRAIGHT_BONUS }
                },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Orc\\CommandAura\\CommandAura.mdx", unit, "origin")
                end
            },
            [MONSTER_TRAIT_OVERPOWERING] = {
                affix = LOCALE_LIST[my_locale].MONSTER_TRAITS[MONSTER_TRAIT_OVERPOWERING],
                excludes = { MONSTER_TRAIT_CHILLING },
                applied_effects = {  "trait_overpower" },
                apply_func = function(unit)
                    AddSpecialEffectTargetEx("Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdx", unit, "origin")
                end
            },
        }

    end

end