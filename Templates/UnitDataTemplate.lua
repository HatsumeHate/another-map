do

    UnitsData       = { }
    UnitsList       = { }

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
    HANDS_POINT     = 6
    RING_1_POINT    = 7
    RING_2_POINT    = 8
    NECKLACE_POINT  = 9




        -- STR_STAT, VIT_STAT, AGI_STAT, INT_STAT
        local BASE_STATS = {
            [BARBARIAN_CLASS]   = { 10, 9, 6, 5 },
            [SORCERESS_CLASS]   = { 5, 6, 5, 10 },
            [PALADIN_CLASS]     = { 8, 11, 6, 5 },
            [ASSASSIN_CLASS]    = { 6, 6, 10, 6 },
            [AMAZON_CLASS]      = { 6, 8, 7, 5 },
            [NECROMANCER_CLASS] = { 5, 6, 5, 10 },
            [DRUID_CLASS]       = { 5, 9, 5, 9 },
            [SPECIAL_CLASS]     = { 20, 20, 20, 20 },
            [NO_CLASS]          = { 10, 10, 10, 10 }
        }


        ---@param source unit
        function GetUnitData(source)
            return UnitsList[GetHandleId(source)]
        end


        function GetUnitClass(unit)
            return UnitsList[GetHandleId(unit)].unit_class or NO_CLASS
        end


    ---@param source unit
    function NewUnitByTemplate(source, reference_data)
        local class_base_stats = BASE_STATS[reference_data.unit_class or NO_CLASS]
        local data                 = {
            Owner        = source,
            unit_class   = reference_data.unit_class or NO_CLASS,

            base_stats = {
                strength = class_base_stats[1], vitality = class_base_stats[2], agility = class_base_stats[3], intellect = class_base_stats[4],
                health = reference_data.base_stats.health or 100., mana = reference_data.base_stats.mana or 100.,
                hp_regen = reference_data.base_stats.hp_regen or 0.2, mp_regen = reference_data.base_stats.mp_regen or 0.2,
                moving_speed = reference_data.base_stats.moving_speed or 245.
            },

            action_timer = CreateTimer(),
            attack_timer = CreateTimer(),

            is_hp_static = reference_data.is_hp_static or false,
            have_mp = reference_data.have_mp or false,
            is_mp_static = reference_data.is_mp_static or false,
            time_before_remove = reference_data.time_before_remove or 10.,

            cast_skill = 0,
            cast_skill_level = 0,
            cast_effect = nil,

            classification = reference_data.classification or nil,
            trait = reference_data.trait or nil,

            default_weapon = nil,
            equip_point = {},
            stats = {},
            buff_list = {},
            skill_list = {}
        }
        data.default_weapon = CreateDefaultWeapon()
        data.equip_point[WEAPON_POINT] = data.default_weapon
        data.stats = CreateParametersData()


        TimerStart(data.attack_timer, 0., false, nil)

        --if reference_data.base_stats ~= nil then MergeTables(data.base_stats, reference_data.base_stats) end

        if reference_data.weapon ~= nil then MergeTables(data.default_weapon, reference_data.weapon) end
        if reference_data.chest ~= nil then data.equip_point[CHEST_POINT] = MergeTables({}, reference_data.chest) end
        if reference_data.necklace ~= nil then data.equip_point[NECKLACE_POINT] = MergeTables({}, reference_data.necklace) end
        if reference_data.offhand ~= nil then data.equip_point[OFFHAND_POINT] = MergeTables({}, reference_data.offhand) end


        UnitsList[GetHandleId(source)] = data

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


        if new_data.unit_class == nil then
            new_data.unit_class = NO_CLASS
        end

        if new_data.is_hp_static == nil then
            new_data.is_hp_static = false
        end

        if new_data.have_mp == nil then
            new_data.have_mp = true
        end

        if new_data.is_mp_static == nil then
            new_data.is_mp_static = false
        end

        if new_data.base_stats == nil then
            new_data.base_stats = {health = 100, mana = 100, hp_regen = 1., mp_regen = 1., moving_speed = 245}
        else
            if new_data.base_stats.health == nil then new_data.base_stats.health = 100 end
            if new_data.base_stats.mana == nil then new_data.base_stats.mana = 100 end
            if new_data.base_stats.hp_regen == nil then new_data.base_stats.hp_regen = 0.2 end
            if new_data.base_stats.mp_regen == nil then new_data.base_stats.mp_regen = 0.2 end
            if new_data.base_stats.moving_speed == nil then new_data.base_stats.moving_speed = 245 end
        end


        UnitsData[FourCC(id)] = new_data
    end



    function UnitDataInit()

        NewUnitTemplate('h000', {
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 3000., hp_regen = 5. },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE }
        })

        NewUnitTemplate('HBRB', {
            unit_class = BARBARIAN_CLASS,
            have_mp = true,
            time_before_remove = 0.
            --weapon = { ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15. }
        })

        NewUnitTemplate('HSRC', {
            unit_class = SORCERESS_CLASS,
            have_mp = true,
            time_before_remove = 0.
            --base_stats = { health = 3000., hp_regen = 30. },
        })


        -- fiend
        NewUnitTemplate('u007', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 125., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            have_mp = false
        })

        -- armored scele
        NewUnitTemplate('u00B', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 220., hp_regen = 0.4, moving_speed = 225. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 4, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })

        -- zombie
        NewUnitTemplate('n00C', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 370., hp_regen = 0.7, moving_speed = 160. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 3, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- skeleton
        NewUnitTemplate('u00D', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 180., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            have_mp = false
        })
        --==========================================================--
        -- skeleton archer
        NewUnitTemplate('n005', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 150., hp_regen = 0.4, moving_speed = 220. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 7, CRIT_CHANCE = 9., missile = "MSKA", ranged = true },
            have_mp = false
        })
        --==========================================================--
        -- skeleton mage
        NewUnitTemplate('u00E', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 140., hp_regen = 0.4, moving_speed = 220. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 8, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSKM", ranged = true },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- skeleton improved
        NewUnitTemplate('n00D', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 50, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- necromancer
        NewUnitTemplate('u00F', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 215., hp_regen = 0.4, moving_speed = 215. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 15, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MNCR", ranged = true },
            have_mp = false
        })
        --==========================================================--
        -- banshee
        NewUnitTemplate('u00C', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 190., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 7, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MBNS", ranged = true },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- succubus improved
        NewUnitTemplate('n00B', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 227., hp_regen = 0.55, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 2.2, DAMAGE = 20, CRIT_CHANCE = 10., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSCB", ranged = true },
            have_mp = false
        })
        --==========================================================--
        -- succubus
        NewUnitTemplate('n002', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 210., hp_regen = 0.6, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            have_mp = false
        })
        --==========================================================--
        -- void walker small
        NewUnitTemplate('n00A', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 220. },
            weapon = { ATTACK_SPEED = 2., DAMAGE = 10, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 5, missile = "MVWS", ranged = true },
            have_mp = false
        })
        --==========================================================--
        -- void walker normal
        NewUnitTemplate('n008', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 225., hp_regen = 0.4, moving_speed = 220. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 15, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MVWM", ranged = true },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- void walker big
        NewUnitTemplate('n009', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 0.4, moving_speed = 200. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 20, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MVWB", ranged = true },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- ghost
        NewUnitTemplate('n006', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 213., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.74, DAMAGE = 14, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MGHO", ranged = true },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- zombie big
        NewUnitTemplate('u00E', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 680., hp_regen = 1.2, moving_speed = 160. },
            weapon = { ATTACK_SPEED = 2.3, DAMAGE = 6, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 4, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- skeleton hell archer
        NewUnitTemplate('n004', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 210. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 10, CRIT_CHANCE = 11., ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKH", ranged = true },
            bonus_parameters = {
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- skeleton frost archer
        NewUnitTemplate('n007', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 240., hp_regen = 0.4, moving_speed = 210. },
            weapon = { ATTACK_SPEED = 1.95, DAMAGE = 10, CRIT_CHANCE = 11., ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKF", ranged = true },
            bonus_parameters = {
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- hell wizard
        NewUnitTemplate('n003', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 0.7, moving_speed = 220. },
            weapon = { ATTACK_SPEED = 1.63, DAMAGE = 12, CRIT_CHANCE = 11., ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MDWZ", ranged = true },
            bonus_parameters = {
                { param = ALL_RESIST, value = 8, method = STRAIGHT_BONUS }
            },
            have_mp = false
        })
        --==========================================================--
        -- demon assassin
        NewUnitTemplate('u009', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 310., hp_regen = 1.7, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 15, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_LIGHT_SLICE },
            have_mp = false
        })

        -- fallen angel
        NewUnitTemplate('u008', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            base_stats = { health = 375., hp_regen = 2.1, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 12, ATTRIBUTE = HOLY_ATTRIBUTE, ATTRIBUTE_BONUS = 15, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = 15, method = STRAIGHT_BONUS },
            },
            have_mp = false
        })

        -- hells guardian
        NewUnitTemplate('u00A', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 1.4, moving_speed = 225. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 8, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_SLICE },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            have_mp = false
        })



        local group = CreateGroup()

            GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, nil)

            ForGroup(group, function ()
                local handle = GetUnitTypeId(GetEnumUnit())

                    if UnitsData[handle] ~= nil then
                        NewUnitByTemplate(GetEnumUnit(), UnitsData[handle])
                        OnUnitCreated(GetEnumUnit())
                    end

            end)

        DestroyGroup(group)

        local trg = CreateTrigger()
        TriggerRegisterEnterRectSimple(trg, bj_mapInitialPlayableArea)
        TriggerAddAction(trg, function ()

            local unit = GetTriggerUnit()

                if UnitsList[GetHandleId(unit)] == nil and UnitsData[GetUnitTypeId(unit)] ~= nil then
                    NewUnitByTemplate(unit, UnitsData[GetUnitTypeId(unit)])
                    OnUnitCreated(unit)
                end

        end)

        trg = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DEATH)
        TriggerAddAction(trg, function ()
            local unit_data = GetUnitData(GetTriggerUnit())

                if unit_data ~= nil then
                    PauseTimer(unit_data.action_timer)
                    PauseTimer(unit_data.attack_timer)

                    if unit_data.time_before_remove > 0. then
                        local handle = GetHandleId(unit_data.Owner)

                            TimerStart(CreateTimer(), unit_data.time_before_remove, false, function ()
                                DestroyTimer(unit_data.action_timer)
                                DestroyTimer(unit_data.attack_timer)
                                UnitsList[handle] = nil
                                DestroyTimer(GetExpiredTimer())
                            end)

                    end

                end

        end)

    end

end