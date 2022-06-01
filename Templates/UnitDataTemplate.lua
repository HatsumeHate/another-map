do

    UnitsData       = 0
    UnitsList       = 0

    BARBARIAN_CLASS     = 1
    SORCERESS_CLASS     = 2
    PALADIN_CLASS       = 3
    ASSASSIN_CLASS      = 4
    AMAZON_CLASS        = 5
    NECROMANCER_CLASS   = 6
    DRUID_CLASS         = 7
    SPECIAL_CLASS       = 8

    MONSTER_RANK_COMMON = 1
    MONSTER_RANK_ADVANCED = 2
    MONSTER_RANK_ELITE = 3
    MONSTER_RANK_BOSS = 4
    NPC = 5

    TRAIT_DEMON = 1
    TRAIT_UNDEAD = 2
    TRAIT_BEAST = 3
    TRAIT_HUMAN = 4

    NO_CLASS = 0

    WEAPON_POINT    = 1
    OFFHAND_POINT   = 2
    HEAD_POINT      = 3
    CHEST_POINT     = 4
    LEGS_POINT      = 5
    BELT_POINT      = 6
    HANDS_POINT     = 7
    RING_1_POINT    = 8
    RING_2_POINT    = 9
    NECKLACE_POINT  = 10


    BASE_HEALTH = 150.
    BASE_MANA = 100.
    BASE_MOVING_SPEED = 285.
    BASE_HEALTH_REGEN = 0.3
    BASE_MANA_REGEN = 0.2


    local BASE_STATS = 0



    function GetUnitPointItem(unit, point)
        local unit_data = GetUnitData(unit)

            if unit_data.equip_point[point] then
                return unit_data.equip_point[point].item or nil
            end

        return nil
    end

    ---@param source unit function
    function GetUnitData(source)
        return UnitsList[GetHandleId(source)]
    end


    ---@param unit unit
    function GetUnitClass(unit)
        return UnitsList[GetHandleId(unit)].unit_class or NO_CLASS
    end



    ---@param effect string
    ---@param unit unit
    ---@return boolean
    function UnitHasEffect(unit, effect)
        local unit_data = GetUnitData(unit)
        return unit_data.effects[effect]
    end

    ---@param effect string
    ---@param unit unit
    function UnitAddEffect(unit, effect)
        local unit_data = GetUnitData(unit)

            if unit_data.effects[effect] then unit_data.effects[effect] = unit_data.effects[effect] + 1
            else unit_data.effects[effect] = 1 end

            OnUnitEffectApply(unit, effect)

    end

    ---@param effect string
    ---@param unit unit
    function UnitRemoveEffect(unit, effect)
        local unit_data = GetUnitData(unit)

            if unit_data.effects[effect] then
                unit_data.effects[effect] = unit_data.effects[effect] - 1
                if unit_data.effects[effect] <= 0 then
                    unit_data.effects[effect] = nil
                    OnUnitEffectEnd(unit, effect)
                end
            end

    end



    ---@param source unit
    ---@param reference_data table
    function NewUnitByTemplate(source, reference_data)
        local class_base_stats = BASE_STATS[reference_data.unit_class or NO_CLASS]
        local data                 = {
            Owner        = source,
            unit_class   = reference_data.unit_class or NO_CLASS,

            base_stats = {
                strength = class_base_stats[1], vitality = class_base_stats[2], agility = class_base_stats[3], intellect = class_base_stats[4],
                health = reference_data.base_stats.health or BASE_HEALTH, mana = reference_data.base_stats.mana or BASE_MANA,
                hp_regen = reference_data.base_stats.hp_regen or BASE_HEALTH_REGEN, mp_regen = reference_data.base_stats.mp_regen or BASE_MANA_REGEN,
                moving_speed = reference_data.base_stats.moving_speed or BASE_MOVING_SPEED,
                death_time = BlzGetUnitRealField(source, UNIT_RF_DEATH_TIME)
            },

            action_timer = CreateTimer(),
            attack_timer = CreateTimer(),

            is_hp_static = reference_data.is_hp_static or false,
            hp_vector = reference_data.hp_vector or true,
            has_mp = reference_data.has_mp or false,
            is_mp_static = reference_data.is_mp_static or false,
            mp_vector = reference_data.mp_vector or true,
            time_before_remove = reference_data.time_before_remove or 25.,
            proper_declension = reference_data.proper_declension or DECL_HE,
            hide_body = reference_data.hide_body or false,

            cast_skill = 0,
            cast_skill_level = 0,
            cast_effect = nil,

            --scale = reference_data.scale or 1.,
            classification = reference_data.classification or nil,
            unit_trait = reference_data.unit_trait or nil,
            xp = reference_data.xp or 15,

            default_weapon = nil,
            equip_point = {},
            stats = {},
            buff_list = {},
            skill_list = {},
            effects = {}
        }

        data.default_weapon = CreateDefaultWeapon()
        data.equip_point[WEAPON_POINT] = data.default_weapon
        --BlzSetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_RANGE, 1, (data.equip_point[WEAPON_POINT].RANGE or 90.))
        data.equip_point[OFFHAND_POINT] = reference_data.offhand and MergeTables(CreateDefaultShieldOffhand(), reference_data.offhand) or nil
        data.stats = CreateParametersData()
        data.colours = { r = 255, g = 255, b = 255, a = 255 }

        if reference_data.colours ~= nil then MergeTables(data.colours, reference_data.colours) end

        TimerStart(data.attack_timer, 0., false, nil)

        --if reference_data.base_stats ~= nil then MergeTables(data.base_stats, reference_data.base_stats) end

        if reference_data.weapon then MergeTables(data.default_weapon, reference_data.weapon) end
        if reference_data.chest then data.equip_point[CHEST_POINT] = MergeTables({}, reference_data.chest) end
        if reference_data.necklace then data.equip_point[NECKLACE_POINT] = MergeTables({}, reference_data.necklace) end
        --if reference_data.offhand then data.equip_point[OFFHAND_POINT] = MergeTables(data.equip_point[OFFHAND_POINT], reference_data.offhand) end

        if reference_data.missile_eject_range then data.missile_eject_range = reference_data.missile_eject_range end
        if reference_data.missile_eject_z then data.missile_eject_z = reference_data.missile_eject_z end
        if reference_data.missile_eject_angle then data.missile_eject_angle = reference_data.missile_eject_angle end
        if reference_data.height then data.height = reference_data.height or 120. end
        if reference_data.classic_model then data.classic_model = true end

        if reference_data.death_sound then
            data.death_sound = MergeTables({}, reference_data.death_sound)
        end

        UnitsList[GetHandleId(source)] = data

        if reference_data.skill_list then
            for i = 1, #reference_data.skill_list do
                UnitAddMyAbility(source, reference_data.skill_list[i])
            end
        end

        if reference_data.effect_list then
            for i = 1, #reference_data.effect_list do
                data.effects[reference_data.effect_list[i]] = true
            end
        end

        UpdateParameters(data)

        if reference_data.bonus_parameters ~= nil then
            for i = 1, #reference_data.bonus_parameters do
                ModifyStat(source, reference_data.bonus_parameters[i].param, reference_data.bonus_parameters[i].value, reference_data.bonus_parameters[i].method, true)
            end
        end

        return data
    end


    function NewUnitTemplate(id, reference)
        local new_data = { }

        MergeTables(new_data, reference)


        if new_data.unit_class == nil then new_data.unit_class = NO_CLASS end
        if new_data.is_hp_static == nil then new_data.is_hp_static = false end
        if new_data.has_mp == nil then new_data.has_mp = true end
        if new_data.is_mp_static == nil then new_data.is_mp_static = false end

        if not new_data.scale then new_data.scale = 1. end


        if new_data.base_stats == nil then
            new_data.base_stats = {health = BASE_HEALTH, mana = BASE_MANA, hp_regen = BASE_HEALTH_REGEN, mp_regen = BASE_MANA_REGEN, moving_speed = BASE_MOVING_SPEED}
        else
            if new_data.base_stats.health == nil then new_data.base_stats.health = BASE_HEALTH end
            if new_data.base_stats.mana == nil then new_data.base_stats.mana = BASE_MANA end
            if new_data.base_stats.hp_regen == nil then new_data.base_stats.hp_regen = BASE_HEALTH_REGEN end
            if new_data.base_stats.mp_regen == nil then new_data.base_stats.mp_regen = BASE_MANA_REGEN end
            if new_data.base_stats.moving_speed == nil then new_data.base_stats.moving_speed = BASE_MOVING_SPEED end
        end


        UnitsData[FourCC(id)] = new_data
    end




    function InitUnitsDataOnMap()
        local group = CreateGroup()

            GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, nil)

            ForGroup(group, function ()
                local handle = GetUnitTypeId(GetEnumUnit())

                    if UnitsData[handle] then
                        NewUnitByTemplate(GetEnumUnit(), UnitsData[handle])
                        if UnitsData[handle].name then BlzSetUnitName(GetEnumUnit(), UnitsData[handle].name) end
                        OnUnitCreated(GetEnumUnit())
                    end

                    if GetUnitTypeId(GetEnumUnit()) == FourCC("n00N") then
                        OnUnitCreated(GetEnumUnit())
                    end

            end)

        DestroyGroup(group)
    end







    function UnitDataInit()

        UnitsData       = { }
        UnitsList       = { }

        BASE_STATS = {
            [BARBARIAN_CLASS]   = { 10, 9, 6, 5 },
            [SORCERESS_CLASS]   = { 5, 6, 5, 10 },
            [PALADIN_CLASS]     = { 8, 11, 6, 5 },
            [ASSASSIN_CLASS]    = { 6, 6, 10, 6 },
            [AMAZON_CLASS]      = { 6, 8, 7, 5 },
            [NECROMANCER_CLASS] = { 5, 6, 7, 8 },
            [DRUID_CLASS]       = { 5, 9, 5, 9 },
            [SPECIAL_CLASS]     = { 20, 20, 20, 20 },
            [NO_CLASS]          = { 10, 10, 10, 10 }
        }

        --captain
        NewUnitTemplate('h000', {
            name = GetLocalString("Капитан", "Captain"),
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 3000., hp_regen = 5. },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 250, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 25, method = STRAIGHT_BONUS }
            },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_BASH }
        })
        --footman
        NewUnitTemplate('h005', {
            name = GetLocalString("Пехотинец", "Footman"),
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 500., hp_regen = 3. },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 150, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            weapon = { DAMAGE = 18, CRIT_CHANCE = 11., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE }
        })
        --spearman
        NewUnitTemplate('h006', {
            name = GetLocalString("Копейщик", "Spearman"),
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 450., hp_regen = 3. },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 70, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            weapon = { DAMAGE = 12, CRIT_CHANCE = 23., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_STAB }
        })
        --hunter
        NewUnitTemplate('h007', {
            name = GetLocalString("Лучник", "Archer"),
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 240., hp_regen = 3. },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 12., RANGE = 700., missile = "MSKA" }
        })
        --chaplain
        NewUnitTemplate('h008', {
            name = GetLocalString("Священник", "Chaplain"),
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 200., hp_regen = 3. },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE }
        })

        NewUnitTemplate('HBRB', {
            unit_class = BARBARIAN_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            base_stats = { health = 225., moving_speed = 335 },
            missile_eject_range = 50.,
            collision = 28
        })

        NewUnitTemplate('HSRC', {
            unit_class = SORCERESS_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
            collision = 28
        })

        NewUnitTemplate('HNCR', {
            unit_class = NECROMANCER_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
        })

        NewUnitTemplate('HPAL', {
            unit_class = PALADIN_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
            classic_model = true,
        })

        NewUnitTemplate('HASS', {
            unit_class = ASSASSIN_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
            classic_model = true,
        })

        NewUnitTemplate('HAMA', {
            unit_class = AMAZON_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
            classic_model = true,
        })

        NewUnitTemplate('HDRU', {
            unit_class = DRUID_CLASS,
            has_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            base_stats = { health = 225., moving_speed = 335 },
            classic_model = true,
        })

        -- illusion
        NewUnitTemplate('srci', {
            unit_class = SORCERESS_CLASS,
            has_mp = true,
            time_before_remove = 25.,
            missile_eject_range = 50.,
            colours = { r = 100, g = 100, b = 255 },
            base_stats = { health = 225., moving_speed = 335 },
        })


        -- leech
        NewUnitTemplate('u00T', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 1000., hp_regen = 0.26, moving_speed = 305. },
            weapon = { ATTACK_SPEED = 1.2, DAMAGE = 2, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            height = 120.,
            has_mp = false,
        })

        --==========================================================--
        -- summoned skeleton
        NewUnitTemplate('u00Q', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 120., hp_regen = 0.26, moving_speed = 315. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 3, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 15., BLOCK_RATE = 30. },
            height = 120.,
            has_mp = false,
            hide_body = true
        })

        --==========================================================--
        -- summoned skeleton mage
        NewUnitTemplate('u00R', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_MAGE_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 90., hp_regen = 0.26, moving_speed = 315. },
            weapon = { ATTACK_SPEED = 1.86, DAMAGE = 6, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSKM" },
            skill_list = { "ASKC" },
            has_mp = false,
            height = 145.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true
        })

        --==========================================================--
        -- summoned skeleton archer
        NewUnitTemplate('n027', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_ARCHER_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 105., hp_regen = 0.26, moving_speed = 315. },
            weapon = { ATTACK_SPEED = 2., DAMAGE = 4, CRIT_CHANCE = 11., missile = "MSKA" },
            has_mp = false,
            height = 125.,
            hide_body = true
        })

        --==========================================================--
        -- summoned lich
        NewUnitTemplate('u00S', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_LICH_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 150., hp_regen = 0.26, moving_speed = 300. },
            weapon = { ATTACK_SPEED = 1.86, DAMAGE = 11, CRIT_CHANCE = 15., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MNLH" },
            has_mp = false,
            height = 165.,
            xp = 0,
            hide_body = true,
        })

        --==========================================================--
        -- summoned ghost
        NewUnitTemplate('u00U', {
            name = LOCALE_LIST[my_locale].NAME_SKELETON_GHOST_SUMMONED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 250., hp_regen = 0.26, moving_speed = 300. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 18, CRIT_CHANCE = 15., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 5, missile = "summoned_ghost_missile", MAX_TARGETS = 300, damage_range = 120. },
            has_mp = false,
            height = 165.,
            xp = 0,
            hide_body = true,
        })

        -- dummy
        NewUnitTemplate('dmmy', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 15000., hp_regen = 5., moving_speed = 0. },
            --weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            has_mp = false,
            xp = 35,
        })

        -- altar
        NewUnitTemplate('h001', {
            unit_class = NO_CLASS,
            time_before_remove = 25.,
            base_stats = { health = 10000., hp_regen = 5., moving_speed = 0. },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 250, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 25, method = STRAIGHT_BONUS }
            },
            --weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            has_mp = false,
        })


        -- HYDRA
        NewUnitTemplate('shdr', {
            unit_class = NO_CLASS,
            time_before_remove = 25.,
            base_stats = { health = 125., hp_regen = 0.4, moving_speed = 0. },
            weapon = { ATTACK_SPEED = 1., DAMAGE = 1, CRIT_CHANCE = 1., missile = "SRHD" },
            has_mp = false,
        })


        -- fiend
        NewUnitTemplate('u007', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_FIEND,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            --trait = TRAIT_DEMON,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 125., hp_regen = 0.4, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
        })

        -- scavenger
        NewUnitTemplate('u00P', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SCAVENGER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            --trait = TRAIT_DEMON,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 103., hp_regen = 0.36, moving_speed = 295. },
            weapon = { ATTACK_SPEED = 1.27, DAMAGE = 3, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            has_mp = false,
            height = 115.,
            drop_offset_min = 14., drop_offset_max = 42.,
            xp = 27,
        })

        -- ghoul of nightmare
        NewUnitTemplate('u00J', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GHOUL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 155., hp_regen = 0.4, moving_speed = 262. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 5, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            skill_list = { "AGHS" },
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 37,
        })

        -- armored scele
        NewUnitTemplate('u00B', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARMORED_SKELETON,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 220., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 4, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            effect_list = { "ECBG" },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS }
            },
            scale = 1.2,
            has_mp = false,
            height = 140.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true
        })

        -- zombie
        NewUnitTemplate('n00C', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ZOMBIE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 370., hp_regen = 0.7, moving_speed = 170. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 3, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS }
            },
            colours = { r = 255, g = 150, b = 150 },
            scale = 1.15,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            has_mp = false,
            xp = 20,
        })

        -- zombie of nightmare
        NewUnitTemplate('n01G', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ZOMBIE_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 370., hp_regen = 0.83, moving_speed = 176. },
            weapon = { ATTACK_SPEED = 1.85, DAMAGE = 6, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            colours = { r = 255, g = 150, b = 150 },
            scale = 1.15,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            has_mp = false,
            xp = 24,
        })
        --==========================================================--
        -- skeleton
        NewUnitTemplate('u00D', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 180., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 22., BLOCK_RATE = 30. },
            effect_list = { "ECBG" },
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            has_mp = false,
            xp = 25,
            hide_body = true
        })
        --==========================================================--
        -- skeleton of nightmare
        NewUnitTemplate('u00O', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 194., hp_regen = 0.6, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 27., BLOCK_RATE = 35. },
            effect_list = { "ECBG" },
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 45.,
            height = 120.,
            xp = 27,
            hide_body = true
        })
        --==========================================================--
        -- skeleton archer
        NewUnitTemplate('n005', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_ARCHER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 150., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 4, CRIT_CHANCE = 11., missile = "MSKA" },
            has_mp = false,
            height = 125.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 30,
            hide_body = true
        })
        --==========================================================--
        -- skeleton archer of nightmare
        NewUnitTemplate('n01P', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_ARCHER_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 157., hp_regen = 0.44, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 6, CRIT_CHANCE = 16., missile = "MSKA" },
            has_mp = false,
            height = 125.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true
        })
        --==========================================================--
        -- skeleton mage
        NewUnitTemplate('u00E', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_MAGE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 140., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 5, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSKM" },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS }
            },
            skill_list = { "ASKC" },
            has_mp = false,
            height = 145.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true
        })
        --==========================================================--
        -- skeleton improved
        NewUnitTemplate('n00D', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_IMPROVED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 50, method = STRAIGHT_BONUS }
            },
            scale = 1.1,
            height = 135.,
            drop_offset_min = 15., drop_offset_max = 45.,
            has_mp = false,
            xp = 35,
            hide_body = true
        })
        --==========================================================--
        -- necromancer
        NewUnitTemplate('u00F', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_NECROMANCER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_HUMAN },
            --trait = TRAIT_HUMAN,
            time_before_remove = 25.,
            base_stats = { health = 215., hp_regen = 0.4, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 6, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MNCR" },
            skill_list = { "ANRA" },
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 45.,
            height = 125.,
            xp = 45,
        })
        --==========================================================--
        -- necromancer of nightmare
        NewUnitTemplate('u00L', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_NECROMANCER_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_HUMAN, TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 235., hp_regen = 0.47, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 9, CRIT_CHANCE = 16., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 14, missile = "MNCR" },
            bonus_parameters = {
                { param = ICE_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            skill_list = { "ANRA" },
            has_mp = false,
            height = 125.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 45,
        })
        --==========================================================--
        -- sorceress of nightmare
        NewUnitTemplate('h002', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SORCERESS_NIGHTMARE,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_HUMAN, TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 235., hp_regen = 0.43, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 8, CRIT_CHANCE = 16., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MSSM" },
            skill_list = { "AFRR", "ACNF" },
            has_mp = false,
            height = 155.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 48,
        })
        --==========================================================--
        -- bloodsucker
        NewUnitTemplate('n01O', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BLOODSUCKER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 170., hp_regen = 0.4, moving_speed = 277. },
            weapon = { ATTACK_SPEED = 1.53, DAMAGE = 6, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 5 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 16, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 5, method = STRAIGHT_BONUS }
            },
            scale = 1.2,
            height = 130.,
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 37,
            hide_body = true,
        })
        --==========================================================--
        -- vampire
        NewUnitTemplate('u00N', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_VAMPIRE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 220., hp_regen = 0.47, moving_speed = 277. },
            weapon = { ATTACK_SPEED = 1.37, DAMAGE = 8, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 5 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 32, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 7, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 150.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 42,
            hide_body = true,
        })
        --==========================================================--
        -- banshee
        NewUnitTemplate('u00C', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BANSHEE,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 190., hp_regen = 0.4, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 7, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MBNS" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS }
            },
            effect_list = { "EHOR" },
            height = 140.,
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true,
        })
        --==========================================================--
        -- banshee of nightmare
        NewUnitTemplate('u00K', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BANSHEE_NIGHTMARE,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 210., hp_regen = 0.4, moving_speed = 276. },
            weapon = { ATTACK_SPEED = 1.66, DAMAGE = 9, CRIT_CHANCE = 22., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 11, missile = "MBON" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS }
            },
            height = 140.,
            has_mp = false,
            drop_offset_min = 35., drop_offset_max = 55.,
            xp = 37,
            hide_body = true,
        })
        --==========================================================--
        -- succubus improved
        NewUnitTemplate('n00B', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SUCCUBUS_IMPROVED,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 227., hp_regen = 0.55, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 2.2, DAMAGE = 12, CRIT_CHANCE = 10., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSCB" },
            has_mp = false,
            scale = 1.2,
            height = 140.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 36,
        })
        --==========================================================--
        -- Hell succubus
            NewUnitTemplate('n025', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_HELL_SUCCUBUS,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 205., hp_regen = 0.52, moving_speed = 285. },
            weapon = { ATTACK_SPEED = 2.24, DAMAGE = 13, CRIT_CHANCE = 12., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 12, missile = "MSCB" },
            has_mp = false,
            scale = 1.18,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 36,
        })
        --==========================================================--
        -- succubus
        NewUnitTemplate('n002', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SUCCUBUS,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 210., hp_regen = 0.6, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 50.,
            xp = 30,
        })
        --==========================================================--
        -- blood succubus
        NewUnitTemplate('n01Q', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BLOOD_SUCCUBUS,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 253., hp_regen = 0.65, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.61, DAMAGE = 7, CRIT_CHANCE = 11., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            has_mp = false,
            scale = 1.18,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 39,
        })
        --==========================================================--
        -- void walker small
        NewUnitTemplate('n00A', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_VOID_WALKER_SMALL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 2., DAMAGE = 6, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 5, missile = "MVWS" },
            has_mp = false,
            scale = 0.75,
            height = 180.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 25,
            hide_body = true,
        })
        --==========================================================--
        -- void walker normal
        NewUnitTemplate('n008', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_VOID_WALKER_NORMAL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 225., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 9, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MVWM" },
            skill_list = { "AVDS" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            scale = 1.15,
            has_mp = false,
            height = 190.,
            drop_offset_min = 15., drop_offset_max = 50.,
            xp = 35,
            hide_body = true,
        })
        --==========================================================--
        -- void walker big
        NewUnitTemplate('n009', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_VOID_WALKER_BIG,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 270., hp_regen = 0.4, moving_speed = 225. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 14, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MVWB" },
            skill_list = { "AVDS", "AVDR" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            scale = 1.3,
            has_mp = false,
            height = 270.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 45,
            hide_body = true,
        })
        --==========================================================--
        -- ghost
        NewUnitTemplate('n006', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GHOST,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 213., hp_regen = 0.4, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.74, DAMAGE = 11, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MGHO" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            skill_list = { "AFRD" },
            scale = 1.4,
            has_mp = false,
            height = 140.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
            hide_body = true,
        })
        --==========================================================--
        -- zombie big
        NewUnitTemplate('n00E', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ZOMBIE_BIG,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 680., hp_regen = 1.2, moving_speed = 180. },
            weapon = { ATTACK_SPEED = 2.3, DAMAGE = 6, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 4, method = STRAIGHT_BONUS }
            },
            scale = 1.75,
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 55.,
            height = 145.,
            xp = 50,
        })
        --==========================================================--
        -- meat golem
        NewUnitTemplate('e000', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_MEAT_GOLEM,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON, TRAIT_UNDEAD },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 963., hp_regen = 1.2, moving_speed = 210. },
            weapon = { ATTACK_SPEED = 2.43, DAMAGE = 16, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_HEAVY_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 17, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 167, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 33, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 240.,
            drop_offset_min = 25., drop_offset_max = 65.,
            xp = 79,
        })
        --==========================================================--
        -- abomination
        NewUnitTemplate('u00M', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ABOMINATION,
            proper_declension = DECL_IT,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON, TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 736., hp_regen = 1., moving_speed = 243. },
            weapon = { ATTACK_SPEED = 2.21, DAMAGE = 13, CRIT_CHANCE = 11., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 12, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 7, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 224, method = STRAIGHT_BONUS },
            },
            has_mp = false,
            drop_offset_min = 25., drop_offset_max = 65.,
            height = 220.,
            xp = 66,
        })
        --==========================================================--
        -- hell beast
        NewUnitTemplate('n01T', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_HELL_BEAST,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON, TRAIT_BEAST },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 159., hp_regen = 0.3, moving_speed = 285. },
            weapon = { ATTACK_SPEED = 1.41, DAMAGE = 6, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 189, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            scale = 0.9,
            skill_list = { "AHBA" },
            has_mp = false,
            height = 120.,
            drop_offset_min = 25., drop_offset_max = 55.,
            xp = 33,
        })
        --==========================================================--
        -- quillbeast
        NewUnitTemplate('n01N', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_QUILLBEAST,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD, TRAIT_BEAST },
            --trait = TRAIT_BEAST,
            time_before_remove = 25.,
            base_stats = { health = 137., hp_regen = 0.3, moving_speed = 267. },
            weapon = { ATTACK_SPEED = 1.36, DAMAGE = 6, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 55, method = STRAIGHT_BONUS },
            },
            scale = 1.3,
            skill_list = { "AQBC" },
            has_mp = false,
            height = 120.,
            drop_offset_min = 25., drop_offset_max = 55.,
            xp = 33,
        })
        --==========================================================--
        -- wolf
        NewUnitTemplate('n01J', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_WOLF,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_UNDEAD, TRAIT_BEAST },
            --trait = TRAIT_BEAST,
            time_before_remove = 25.,
            base_stats = { health = 143., hp_regen = 0.3, moving_speed = 267. },
            weapon = { ATTACK_SPEED = 1.28, DAMAGE = 7, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            scale = 0.75,
            skill_list = { "AWRG" },
            has_mp = false,
            height = 120.,
            drop_offset_min = 25., drop_offset_max = 55.,
            xp = 33,
        })
        -- insect
        NewUnitTemplate('n023', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_INSECT,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            --trait = TRAIT_BEAST,
            time_before_remove = 25.,
            base_stats = { health = 120., hp_regen = 0.3, moving_speed = 288. },
            weapon = { ATTACK_SPEED = 1.41, DAMAGE = 5, CRIT_CHANCE = 16., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_SLICE },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            scale = 0.6,
            has_mp = false,
            height = 160.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 27,
        })
        --==========================================================--
        -- satyr
        NewUnitTemplate('n01K', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SATYR,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            --trait = TRAIT_BEAST,
            time_before_remove = 25.,
            base_stats = { health = 178., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 6, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 7, method = STRAIGHT_BONUS },
            },
            scale = 1.15,
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 33,
        })
        --==========================================================--
        -- satyr trickster
        NewUnitTemplate('n01L', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SATYR_TRICKSTER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 153., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.48, DAMAGE = 8, CRIT_CHANCE = 14., missile = "MSTR", ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 14, method = STRAIGHT_BONUS },
            },
            skill_list = { "ASBL" },
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 33,
        })
        --==========================================================--
        -- hell satyr
        NewUnitTemplate('n01M', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SATYR_HELL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 245., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.37, DAMAGE = 10, CRIT_CHANCE = 16., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_SLICE },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 18, method = STRAIGHT_BONUS },
            },
            skill_list = { "ASRL" },
            scale = 1.05,
            height = 210.,
            drop_offset_min = 20., drop_offset_max = 55.,
            has_mp = false,
            xp = 42,
        })
        --==========================================================--
        -- revenant
        NewUnitTemplate('n01U', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_REVENANT,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 175., hp_regen = 0.2, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            skill_list = { "ARLR" },
            offhand = { BLOCK = 20., BLOCK_RATE = 30. },
            has_mp = false,
            height = 235.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 33,
        })
        --==========================================================--
        -- cold revenant
        NewUnitTemplate('n028', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_FROST_REVENANT,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 187., hp_regen = 0.2, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.66, DAMAGE = 6, CRIT_CHANCE = 10., ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            skill_list = { "AFBB" },
            offhand = { BLOCK = 30., BLOCK_RATE = 30. },
            has_mp = false,
            height = 238.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 33,
            hide_body = true
        })
        --==========================================================--
        -- revenant horror
        NewUnitTemplate('n01I', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_REVENANT_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            --trait = TRAIT_DEMON,
            time_before_remove = 25.,
            base_stats = { health = 200., hp_regen = 0.2, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 7, CRIT_CHANCE = 14., ranged = true, LIGHTNING = { id = "RENL", fade = 0.65, bonus_z = 135., range = 45., angle = 50. } , ATTRIBUTE = LIGHTNING_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 78, method = STRAIGHT_BONUS },
            },
            skill_list = { "ARLR" },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            has_mp = false,
            height = 235.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 33,
        })
        --==========================================================--
        -- skeleton hell archer
        NewUnitTemplate('n004', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_HELL_ARCHER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 8, CRIT_CHANCE = 11., ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKH" },
            bonus_parameters = {
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 155.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 35,
            hide_body = true,
        })
        --==========================================================--
        -- skeleton frost archer
        NewUnitTemplate('n007', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_FROST_ARCHER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 240., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.95, DAMAGE = 7, CRIT_CHANCE = 11., ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKF" },
            bonus_parameters = {
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 155.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 35,
            hide_body = true,
        })
        --==========================================================--
        -- hell wizard
        NewUnitTemplate('n003', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_HELL_WIZARD,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 270., hp_regen = 0.7, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.63, DAMAGE = 9, CRIT_CHANCE = 11., ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MDWZ" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 8, method = STRAIGHT_BONUS }
            },
            scale = 1.55,
            has_mp = false,
            height = 180.,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 37,
        })
        --==========================================================--
        -- demon assassin
        NewUnitTemplate('u009', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_DEMON_ASSASSIN,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 310., hp_regen = 1.7, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 12, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_LIGHT_SLICE },
            has_mp = false,
            scale = 0.9,
            height = 135.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 40,
        })

        -- fallen angel
        NewUnitTemplate('u008', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_FALLEN_ANGEL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            time_before_remove = 25.,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            base_stats = { health = 375., hp_regen = 2.1, moving_speed = 280. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 9, ATTRIBUTE = HOLY_ATTRIBUTE, ATTRIBUTE_BONUS = 15, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = 15, method = STRAIGHT_BONUS },
            },
            scale = 0.9,
            has_mp = false,
            height = 170.,
            drop_offset_min = 20., drop_offset_max = 60.,
            xp = 40,
        })

        -- hells guardian
        NewUnitTemplate('u00A', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_HELLS_GUARDIAN,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 290., hp_regen = 1.4, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 7, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_SLICE },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            scale = 1.3,
            has_mp = false,
            height = 160.,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 35,
        })

        -- faceless
        NewUnitTemplate(MONSTER_ID_FACELESS, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_FACELESS,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 270., hp_regen = 1.36, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 7, ATTRIBUTE_BONUS = 10, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_HEAVY_BASH },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 100, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = CRIT_MULTIPLIER, value = 0.2, method = STRAIGHT_BONUS },
            },
            skill_list = { "AFSM" },
            scale = 1.4,
            colours = { r = 180, g = 180, b = 180 },
            has_mp = false,
            height = 160.,
            drop_offset_min = 35., drop_offset_max = 65.,
            xp = 32,
        })


        --==========================================================--
        -- gnoll
        NewUnitTemplate('n02F', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 114., hp_regen = 0.4, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 6, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_BASH },
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
        })

        --==========================================================--
        -- brute
        NewUnitTemplate('n02G', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL_BRUTE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 146., hp_regen = 0.47, moving_speed = 270. },
            colours = { r = 255, g = 140, b = 140 },
            weapon = { ATTACK_SPEED = 1.55, DAMAGE = 14, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_BASH },
            has_mp = false,
            height = 135.,
            drop_offset_min = 20., drop_offset_max = 45.,
            xp = 42,
        })

        --==========================================================--
        -- overseer
        NewUnitTemplate('n02I', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL_OVERSEER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 256., hp_regen = 0.54, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.75, DAMAGE = 20, CRIT_CHANCE = 12., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_BASH },
            has_mp = false,
            height = 155.,
            drop_offset_min = 35., drop_offset_max = 65.,
            xp = 57,
        })

        --==========================================================--
        -- poacher
        NewUnitTemplate('n02J', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL_POACHER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 100., hp_regen = 0.37, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.55, DAMAGE = 6, CRIT_CHANCE = 7., missile = "MSKA" },
            skill_list = { "AGEN" },
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 35,
        })

        --==========================================================--
        -- gnoll assassin
        NewUnitTemplate('n02K', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL_ASSASSIN,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 120., hp_regen = 0.39, moving_speed = 275. },
            colours = { r = 100, g = 100, b = 255 },
            weapon = { ATTACK_SPEED = 1.57, DAMAGE = 12, CRIT_CHANCE = 7., missile = "MSKA" },
            skill_list = { "AGEN" },
            has_mp = false,
            height = 135.,
            drop_offset_min = 20., drop_offset_max = 45.,
            xp = 42,
        })

        --==========================================================--
        -- warden
        NewUnitTemplate('n02H', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_GNOLL_WARDEN,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 120., hp_regen = 0.39, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 10, CRIT_CHANCE = 7., missile = "MGNL", DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = LIGHTNING_ATTRIBUTE, ATTRIBUTE_BONUS = 15 },
            has_mp = false,
            height = 145.,
            drop_offset_min = 25., drop_offset_max = 55.,
            xp = 49,
        })

        --==========================================================--
        -- arachnid
        NewUnitTemplate('n00P', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARACHNID,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 195., hp_regen = 0.46, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            scale = 0.65,
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 25,
        })
        --==========================================================--
        -- arachnid thrower
        NewUnitTemplate('n00O', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARACHNID_THROWER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 165., hp_regen = 0.46, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.77, DAMAGE = 6, CRIT_CHANCE = 11., missile = "MSAT", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            scale = 0.65,
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 30,
        })
        --==========================================================--
        -- arachnid warrior
        NewUnitTemplate('n00Q', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARACHNID_WARRIOR,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 195., hp_regen = 0.49, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 8, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            scale = 0.9,
            has_mp = false,
            height = 130.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 45,
        })
        --==========================================================--
        -- arachnid burrower
        NewUnitTemplate('n00R', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARACHNID_BURROWER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 165., hp_regen = 0.49, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 12, CRIT_CHANCE = 9., missile = "MSAT", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 12 },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 130.,
            drop_offset_min = 20., drop_offset_max = 55.,
            xp = 40,
        })
        --==========================================================--
        -- arachnid boss
        NewUnitTemplate('n00S', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ARACHNID_BOSS,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 1500., hp_regen = 0.74, moving_speed = 280. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 22, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 150, method = STRAIGHT_BONUS },
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = MAGICAL_ATTACK, value = 100, method = STRAIGHT_BONUS }
            },
            scale = 1.2,
            skill_list = { "AACL", "AAPN", "AACH" },
            respawn_rect = gg_rct_arachnid_boss,
            respawn_time = 20.,
            has_mp = false,
            drop_offset_min = 25., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- spider
        NewUnitTemplate('n00Y', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 121., hp_regen = 0.46, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.55, DAMAGE = 8, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            scale = 0.6,
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 25,
        })
        --==========================================================--
        -- black spider
        NewUnitTemplate('n00Z', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER_BLACK,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 207., hp_regen = 0.46, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 13, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 125.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 45,
        })
        --==========================================================--
        -- black spider of nightmare
        NewUnitTemplate('n01H', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER_BLACK_NIGHTMARE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 265., hp_regen = 0.46, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 16, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 125.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 55,
        })
        --==========================================================--
        -- spider hunter
        NewUnitTemplate('n010', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER_HUNTER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 191., hp_regen = 0.49, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.75, DAMAGE = 12, CRIT_CHANCE = 9., missile = "MSSP", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 37,
        })
        --==========================================================--
        -- gigantic spider
        NewUnitTemplate('n011', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER_GIGANTIC,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 246., hp_regen = 0.49, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 16, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 11.5, WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            scale = 1.25,
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 40,
        })
        --==========================================================--
        -- spider boss
        NewUnitTemplate('n012', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SPIDER_BOSS,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 1500., hp_regen = 0.86, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 27, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 50, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
            },
            scale = 1.5,
            skill_list = { "ASQB", "ASQT", "ASQS", "ASQC" },
            respawn_rect = gg_rct_spider_boss,
            respawn_time = 20.,
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- bandit
        NewUnitTemplate('n00T', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BANDIT,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 195., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 25,
        })
        --==========================================================--
        -- robber
        NewUnitTemplate('n00U', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ROBBER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            unit_trait = { TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 155., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 8, CRIT_CHANCE = 12., missile = "MSBN" },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = CRIT_MULTIPLIER, value = 0.3, method = STRAIGHT_BONUS },
            },
            scale = 1.1,
            has_mp = false,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 30,
        })
        --==========================================================--
        -- rogue
        NewUnitTemplate('n00V', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ROGUE,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 225., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 13, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 10, method = STRAIGHT_BONUS }
            },
            scale = 1.3,
            has_mp = false,
            height = 130.,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 45,
        })
        --==========================================================--
        -- assassin
        NewUnitTemplate('n00W', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ASSASSIN,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            unit_trait = { TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 187., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 15, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 14., missile = "MSBN" },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = CRIT_MULTIPLIER, value = 0.3, method = STRAIGHT_BONUS },
            },
            scale = 1.3,
            height = 130.,
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 45.,
            xp = 42,
        })
        --==========================================================--
        -- bandit's boss
        NewUnitTemplate('n00X', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BANDIT_BOSS,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 25, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
            },
            skill_list = { "ABCH" },
            effect_list = { "EBBS" },
            respawn_rect = gg_rct_bandit_boss,
            respawn_time = 20.,
            scale = 1.3,
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- Skeleton King
        NewUnitTemplate('n015', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON_KING,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 27, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "ASSM", "ASBN" },
            --respawn_rect = gg_rct_bandit_boss,
            --respawn_time = 20.,
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- skeleton summoned
        NewUnitTemplate('u00G', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 66., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.66, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            has_mp = false,
            height = 120.,
            xp = 0,
        })
        --==========================================================--
        -- meph ghost summoned
        NewUnitTemplate('u00H', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_SKELETON,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 66., hp_regen = 0.4, moving_speed = 0. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 15, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            has_mp = false,
            xp = 0,
        })
         --==========================================================--
        -- MEPH
        NewUnitTemplate(MONSTER_ID_MEPHISTO, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_MEPHISTO,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1370., hp_regen = 0.4, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.75, DAMAGE = 15, CRIT_CHANCE = 13., ranged = true, LIGHTNING = { id = "YENL", fade = 0.65 }, DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = LIGHTNING_ATTRIBUTE, ATTRIBUTE_BONUS = 15 },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 200, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = MAGICAL_ATTACK, value = 125, method = STRAIGHT_BONUS }
            },
            death_sound = { pack = { "Sounds\\Monsters\\mephisto_death.wav" }, volume = 110, cutoff = 1700. },
            skill_list = { "AMLN", "AMFB" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- baal
        NewUnitTemplate(MONSTER_ID_BAAL, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BAAL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.51, DAMAGE = 25, CRIT_CHANCE = 13., missile = "MBAL", DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15 },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 450, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "ABSS" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- underworld queen
        NewUnitTemplate(MONSTER_ID_UNDERWORLD_QUEEN, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_UNDERWORLD_QUEEN,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1520., hp_regen = 0.47, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 33, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 450, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "AARB" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- butcher
        NewUnitTemplate(MONSTER_ID_BUTCHER, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BUTCHER,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1720., hp_regen = 0.49, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 40, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 650, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 150, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 65, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 5, method = STRAIGHT_BONUS },
            },
            skill_list = { "ABCC" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- ANDARIEL
        NewUnitTemplate("n022", {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_ANDARIEL,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1570., hp_regen = 0.44, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 27, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE, ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 650, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 150, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -35, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 35, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            death_sound = { pack = { "Sounds\\Monsters\\andariel_death.wav" }, volume = 110, cutoff = 1700. },
            skill_list = { "AAPB" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- REANIMATED
        NewUnitTemplate(MONSTER_ID_REANIMATED, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_REANIMATED,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_UNDEAD },
            time_before_remove = 25.,
            base_stats = { health = 1325., hp_regen = 0.41, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.61, DAMAGE = 27, CRIT_CHANCE = 12., missile = "MREA" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 35, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "ARNA" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- BLOOD RAVEN
        NewUnitTemplate('n026', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_BLOOD_RAVEN,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_UNDEAD, TRAIT_HUMAN },
            time_before_remove = 25.,
            base_stats = { health = 1220., hp_regen = 0.41, moving_speed = 280. },
            weapon = { ATTACK_SPEED = 1.53, DAMAGE = 26, CRIT_CHANCE = 12., missile = "MREA", ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            missile_eject_z = 60.,
            missile_eject_range = 50.,
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 35, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "ABRR" },
            death_sound = { pack = { "Sounds\\Monsters\\blood_raven_death.wav" }, volume = 110, cutoff = 1700. },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        -- zombie summon
        NewUnitTemplate('n02M', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_HUNGRY_DEAD,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_UNDEAD },
            --trait = TRAIT_UNDEAD,
            time_before_remove = 25.,
            base_stats = { health = 320., hp_regen = 0.83, moving_speed = 176. },
            weapon = { ATTACK_SPEED = 1.85, DAMAGE = 6, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 7, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 4, method = STRAIGHT_BONUS }
            },
            colours = { r = 150, g = 150, b = 150 },
            scale = 1.15,
            height = 120.,
            drop_offset_min = 15., drop_offset_max = 45.,
            has_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- DEMON LORD
        NewUnitTemplate(MONSTER_ID_DEMONKING, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_DEMON_LORD,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1145., hp_regen = 0.41, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 25, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 300, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = REFLECT_MELEE_DAMAGE, value = 150, method = STRAIGHT_BONUS }
            },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- demoness
        NewUnitTemplate(MONSTER_ID_DEMONESS, {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_DEMONESS,
            proper_declension = DECL_SHE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 1445., hp_regen = 0.44, moving_speed = 264. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 27, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 150, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 45, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            skill_list = { "ADME" },
            has_mp = false,
            drop_offset_min = 20., drop_offset_max = 65.,
            xp = 700,
        })
        --==========================================================--
        -- DIABLO
        NewUnitTemplate("uDBL", {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_DIABLO,
            proper_declension = DECL_HE,
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 3570., hp_regen = 0.44, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 48, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_WOOD_HEAVY_BASH, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 750, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 450, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 55, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 35, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 35, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = 5, method = STRAIGHT_BONUS },
            },
            death_sound = { pack = { "Sounds\\Monsters\\Diablo_Death.wav" }, volume = 115, cutoff = 1700. },
            skill_list = { "ADLB", "ADFS", "ADCH", "ADAP" },
            has_mp = false,
            drop_offset_min = 40., drop_offset_max = 85.,
            xp = 700,
        })
        --==========================================================--
        -- spider egg 1
        NewUnitTemplate('speb', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_EGG,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 300., hp_regen = 0.2, moving_speed = 0. },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
            },
            height = 120.,
            has_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- spider egg 2
        NewUnitTemplate('speg', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_EGG,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 300., hp_regen = 0.2, moving_speed = 0. },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
            },
            height = 120.,
            has_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- tentacle summoned
        NewUnitTemplate('u00I', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_TENTACLE,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 92., hp_regen = 0.2, moving_speed = 0. },
            weapon = { ATTACK_SPEED = 1.44, DAMAGE = 7, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
            },
            height = 170.,
            has_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- curse totem
        NewUnitTemplate('o000', {
            name = GetLocalString("Проклятый Тотем", "Cursed Totem"),
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            time_before_remove = 25.,
            base_stats = { health = 1100., hp_regen = 0.21, moving_speed = 0. },
            bonus_parameters = {
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
            },
            height = 180.,
            has_mp = false,
            drop_offset_min = 15., drop_offset_max = 55.,
            xp = 5,
        })
        --==========================================================--
        -- Lilith
        NewUnitTemplate('n017', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_LILITH,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_DEMON },
            time_before_remove = 25.,
            base_stats = { health = 662., hp_regen = 0.55, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 17, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSCB" },
            has_mp = false,
            colours = { r = 255, g = 120, b = 190, a = 255 },
            height = 140.,
            xp = 10,
        })

        -- Forest Guard
        NewUnitTemplate('n01X', {
            name = LOCALE_LIST[my_locale].MONSTER_NAME_FOREST_GUARD,
            unit_class = NO_CLASS,
            classification = 0,
            unit_trait = { TRAIT_BEAST },
            time_before_remove = 25.,
            base_stats = { health = 962., hp_regen = 0.75, moving_speed = 285. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 22, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            has_mp = false,
            colours = { r = 255, g = 255, b = 255, a = 255 },
            height = 140.,
            xp = 10,
        })


        local trg = CreateTrigger()
        TriggerRegisterEnterRectSimple(trg, bj_mapInitialPlayableArea)
        TriggerAddAction(trg, function ()

            local unit = GetTriggerUnit()

                if UnitsList[GetHandleId(unit)] == nil and UnitsData[GetUnitTypeId(unit)] then
                    NewUnitByTemplate(unit, UnitsData[GetUnitTypeId(unit)])
                    if UnitsData[GetUnitTypeId(unit)].name then BlzSetUnitName(unit, UnitsData[GetUnitTypeId(unit)].name) end
                    OnUnitCreated(unit)
                end

            if GetUnitTypeId(unit) == FourCC("n00N") then
                OnUnitCreated(unit)
            end

        end)

        trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddAction(trg, function ()
            local unit_data = GetUnitData(GetTriggerUnit())

                if unit_data then
                    ResetUnitSpellCast(unit_data.Owner)
                    TimerStart(unit_data.action_timer, 0., false, nil)
                    TimerStart(unit_data.attack_timer, 0., false, nil)

                    if unit_data.death_sound then
                        AddSoundVolume(unit_data.death_sound.pack[GetRandomInt(1, #unit_data.death_sound.pack)], GetUnitX(unit_data.Owner), GetUnitY(unit_data.Owner), unit_data.death_sound.volume, unit_data.death_sound.cutoff)
                    end

                    if unit_data.minimap_icon then DestroyMinimapIcon(unit_data.minimap_icon) end

                    if unit_data.hide_body then
                        DelayAction(unit_data.base_stats.death_time, function() ShowUnit(unit_data.Owner) end)
                    end

                    if unit_data.time_before_remove > 0. then
                        local handle = GetHandleId(unit_data.Owner)

                            local timer = CreateTimer()
                            TimerStart(timer, unit_data.time_before_remove, false, function ()
                                DestroyTimer(unit_data.action_timer)
                                DestroyTimer(unit_data.attack_timer)
                                UnitsList[handle] = nil
                                DestroyTimer(timer)
                            end)

                    end

                end

                OnUnitDeath(GetTriggerUnit(), GetKillingUnit())

        end)



        RegisterTestCommand("t1", function()
            print("dummy spawned")
                        CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy1), GetRectCenterY(gg_rct_dummy1), 135.)
            local d2 =  CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy2), GetRectCenterY(gg_rct_dummy2), 135.)
            local d3 =  CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy3), GetRectCenterY(gg_rct_dummy3), 135.)


            DelayAction(0.01, function()
                --ApplyMonsterTrait(d3, MONSTER_TRAIT_BURNING)
                ModifyStat(d2, PHYSICAL_DEFENCE, 250, STRAIGHT_BONUS, true)
                ModifyStat(d3, PHYSICAL_DEFENCE, 500, STRAIGHT_BONUS, true)
            end)


        end)

        RegisterTestCommand("ic", function()
            IceBlastCast(PlayerHero[1], GetUnitX(PlayerHero[1]), GetUnitY(PlayerHero[1]))
        end)

        RegisterTestCommand("ab", function()
            AstralBarrageCast(PlayerHero[1])
        end)

    end

end