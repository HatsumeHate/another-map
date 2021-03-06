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


        ---@param unit unit
        function GetUnitClass(unit)
            return UnitsList[GetHandleId(unit)].unit_class or NO_CLASS
        end



    ---@param effect string
    ---@param unit unit
    function UnitHasEffect(unit, effect)
        local unit_data = GetUnitData(unit)
        return unit_data.effects[effect]
    end

    function UnitAddEffect(unit, effect)
        local unit_data = GetUnitData(unit)

        if unit_data.effects[effect] then unit_data.effects[effect] = unit_data.effects[effect] + 1
        else unit_data.effects[effect] = 1 end

        --unit_data.effects[effect] = true
    end

    function UnitRemoveEffect(unit, effect)
        local unit_data = GetUnitData(unit)

        if unit_data.effects[effect] then
            unit_data.effects[effect] = unit_data.effects[effect] - 1
            if unit_data.effects[effect] <= 0 then unit_data.effects[effect] = nil end
        end


        --unit_data.effects[effect] = nil
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
                moving_speed = reference_data.base_stats.moving_speed or BASE_MOVING_SPEED
            },

            action_timer = CreateTimer(),
            attack_timer = CreateTimer(),

            is_hp_static = reference_data.is_hp_static or false,
            hp_vector = reference_data.hp_vector or true,
            have_mp = reference_data.have_mp or false,
            is_mp_static = reference_data.is_mp_static or false,
            mp_vector = reference_data.mp_vector or true,
            time_before_remove = reference_data.time_before_remove or 10.,

            cast_skill = 0,
            cast_skill_level = 0,
            cast_effect = nil,

            classification = reference_data.classification or nil,
            trait = reference_data.trait or nil,
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
        data.equip_point[OFFHAND_POINT] = reference_data.offhand and MergeTables(CreateDefaultShieldOffhand(), reference_data.offhand) or nil
        data.stats = CreateParametersData()
        data.colours = { r = 255, g = 255, b = 255, a = 255 }

        if reference_data.colours ~= nil then MergeTables(data.colours, reference_data.colours) end

        TimerStart(data.attack_timer, 0., false, nil)

        --if reference_data.base_stats ~= nil then MergeTables(data.base_stats, reference_data.base_stats) end

        if reference_data.weapon then MergeTables(data.default_weapon, reference_data.weapon) end
        if reference_data.chest then data.equip_point[CHEST_POINT] = MergeTables({}, reference_data.chest) end
        if reference_data.necklace then data.equip_point[NECKLACE_POINT] = MergeTables({}, reference_data.necklace) end
        if reference_data.offhand then data.equip_point[OFFHAND_POINT] = MergeTables({}, reference_data.offhand) end

        if reference_data.missile_eject_range then data.missile_eject_range = reference_data.missile_eject_range end
        if reference_data.missile_eject_angle then data.missile_eject_angle = reference_data.missile_eject_angle end

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
        if new_data.have_mp == nil then new_data.have_mp = true end
        if new_data.is_mp_static == nil then new_data.is_mp_static = false end


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







    function UnitDataInit()

        NewUnitTemplate('h000', {
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 3000., hp_regen = 5. },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE }
        })

        NewUnitTemplate('HBRB', {
            unit_class = BARBARIAN_CLASS,
            have_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            --weapon = { ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15. }
        })

        NewUnitTemplate('HSRC', {
            unit_class = SORCERESS_CLASS,
            have_mp = true,
            time_before_remove = 0.,
            missile_eject_range = 50.,
            --base_stats = { health = 3000., hp_regen = 30. },
        })


        -- dummy
        NewUnitTemplate('dmmy', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            --trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 15000., hp_regen = 5., moving_speed = 0. },
            --weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            have_mp = false,
            xp = 35,
        })

        -- altar
        NewUnitTemplate('h001', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 10000., hp_regen = 5., moving_speed = 0. },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 250, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 250, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 25, method = STRAIGHT_BONUS }
            },
            --weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            have_mp = false,
        })


        -- HYDRA
        NewUnitTemplate('shdr', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 125., hp_regen = 0.4, moving_speed = 0. },
            weapon = { ATTACK_SPEED = 1., DAMAGE = 1, CRIT_CHANCE = 1., missile = "SRHD" },
            have_mp = false,
        })


        -- fiend
        NewUnitTemplate('u007', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 125., hp_regen = 0.4, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            have_mp = false,
            xp = 35,
        })

        -- ghoul of nightmare
        NewUnitTemplate('u00J', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 155., hp_regen = 0.4, moving_speed = 262. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 5, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            skill_list = { "AGHS" },
            have_mp = false,
            xp = 37,
        })

        -- armored scele
        NewUnitTemplate('u00B', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 220., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 4, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            effect_list = { "ECBG" },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })

        -- zombie
        NewUnitTemplate('n00C', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 370., hp_regen = 0.7, moving_speed = 170. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 3, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 20,
        })

        -- zombie of nightmare
        NewUnitTemplate('n01G', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 370., hp_regen = 0.83, moving_speed = 176. },
            weapon = { ATTACK_SPEED = 1.85, DAMAGE = 6, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            colours = { r = 255, g = 150, b = 150 },
            have_mp = false,
            xp = 24,
        })
        --==========================================================--
        -- skeleton
        NewUnitTemplate('u00D', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 180., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 22., BLOCK_RATE = 30. },
            effect_list = { "ECBG" },
            have_mp = false,
            xp = 25,
        })
        --==========================================================--
        -- skeleton of nightmare
        NewUnitTemplate('u00O', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 194., hp_regen = 0.6, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            offhand = { BLOCK = 27., BLOCK_RATE = 35. },
            effect_list = { "ECBG" },
            have_mp = false,
            xp = 27,
        })
        --==========================================================--
        -- skeleton archer
        NewUnitTemplate('n005', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 150., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 4, CRIT_CHANCE = 11., missile = "MSKA" },
            have_mp = false,
            xp = 30,
        })
        --==========================================================--
        -- skeleton archer of nightmare
        NewUnitTemplate('n01P', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 157., hp_regen = 0.44, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 6, CRIT_CHANCE = 16., missile = "MSKA" },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- skeleton mage
        NewUnitTemplate('u00E', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 140., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 4, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSKM" },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- skeleton improved
        NewUnitTemplate('n00D', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 6, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = PHYSICAL_DEFENCE, value = 50, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- necromancer
        NewUnitTemplate('u00F', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 215., hp_regen = 0.4, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 9, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MNCR" },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- necromancer of nightmare
        NewUnitTemplate('u00L', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 235., hp_regen = 0.47, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 10, CRIT_CHANCE = 16., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ARCANE_ATTRIBUTE, ATTRIBUTE_BONUS = 14, missile = "MNCR" },
            bonus_parameters = {
                { param = ICE_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- sorceress of nightmare
        NewUnitTemplate('h002', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 235., hp_regen = 0.43, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.9, DAMAGE = 10, CRIT_CHANCE = 16., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MSSM" },
            have_mp = false,
            xp = 48,
        })
        --==========================================================--
        -- bloodsucker
        NewUnitTemplate('n01O', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 170., hp_regen = 0.4, moving_speed = 277. },
            weapon = { ATTACK_SPEED = 1.53, DAMAGE = 7, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 5 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 16, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 5, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 37,
        })
        --==========================================================--
        -- vampire
        NewUnitTemplate('u00N', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 220., hp_regen = 0.47, moving_speed = 277. },
            weapon = { ATTACK_SPEED = 1.37, DAMAGE = 10, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 5 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 32, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 7, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 42,
        })
        --==========================================================--
        -- banshee
        NewUnitTemplate('u00C', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 190., hp_regen = 0.4, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 7, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MBNS" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS }
            },
            effect_list = { "EHOR" },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- banshee of nightmare
        NewUnitTemplate('u00K', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 210., hp_regen = 0.4, moving_speed = 276. },
            weapon = { ATTACK_SPEED = 1.66, DAMAGE = 9, CRIT_CHANCE = 22., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 11, missile = "MBON" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 8, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 37,
        })
        --==========================================================--
        -- succubus improved
        NewUnitTemplate('n00B', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 227., hp_regen = 0.55, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 2.2, DAMAGE = 15, CRIT_CHANCE = 10., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSCB" },
            have_mp = false,
            xp = 36,
        })
        --==========================================================--
        -- succubus
        NewUnitTemplate('n002', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 210., hp_regen = 0.6, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.65, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            have_mp = false,
            xp = 30,
        })
        --==========================================================--
        -- blood succubus
        NewUnitTemplate('n01Q', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 253., hp_regen = 0.65, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.61, DAMAGE = 7, CRIT_CHANCE = 11., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            have_mp = false,
            xp = 39,
        })
        --==========================================================--
        -- void walker small
        NewUnitTemplate('n00A', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 2., DAMAGE = 8, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 5, missile = "MVWS" },
            have_mp = false,
            xp = 25,
        })
        --==========================================================--
        -- void walker normal
        NewUnitTemplate('n008', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 225., hp_regen = 0.4, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 12, CRIT_CHANCE = 11., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MVWM" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- void walker big
        NewUnitTemplate('n009', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 0.4, moving_speed = 225. },
            weapon = { ATTACK_SPEED = 2.1, DAMAGE = 16, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MVWB" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- ghost
        NewUnitTemplate('n006', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 213., hp_regen = 0.4, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.74, DAMAGE = 12, CRIT_CHANCE = 17., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 10, missile = "MGHO" },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- zombie big
        NewUnitTemplate('n00E', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 680., hp_regen = 1.2, moving_speed = 180. },
            weapon = { ATTACK_SPEED = 2.3, DAMAGE = 6, CRIT_CHANCE = 5., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 11, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 4, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 50,
        })
        --==========================================================--
        -- meat golem
        NewUnitTemplate('e000', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 963., hp_regen = 1.2, moving_speed = 210. },
            weapon = { ATTACK_SPEED = 2.43, DAMAGE = 16, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_HEAVY_BASH },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 17, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 167, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 33, method = STRAIGHT_BONUS },
                { param = ALL_RESIST, value = 6, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 79,
        })
        --==========================================================--
        -- abomination
        NewUnitTemplate('u00M', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 736., hp_regen = 1., moving_speed = 243. },
            weapon = { ATTACK_SPEED = 2.21, DAMAGE = 13, CRIT_CHANCE = 11., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = MELEE_DAMAGE_REDUCTION, value = 12, method = STRAIGHT_BONUS },
                { param = RANGE_DAMAGE_REDUCTION, value = 7, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 15, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 224, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 66,
        })
        --==========================================================--
        -- hell beast
        NewUnitTemplate('n01T', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 159., hp_regen = 0.3, moving_speed = 285. },
            weapon = { ATTACK_SPEED = 1.41, DAMAGE = 6, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 189, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            skill_list = { "AHBA" },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- quillbeast
        NewUnitTemplate('n01N', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 137., hp_regen = 0.3, moving_speed = 267. },
            weapon = { ATTACK_SPEED = 1.36, DAMAGE = 6, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 55, method = STRAIGHT_BONUS },
            },
            skill_list = { "AQBC" },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- wolf
        NewUnitTemplate('n01J', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 143., hp_regen = 0.3, moving_speed = 267. },
            weapon = { ATTACK_SPEED = 1.28, DAMAGE = 8, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
            },
            skill_list = { "AWRG" },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- satyr
        NewUnitTemplate('n01K', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 178., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 6, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 7, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- satyr trickster
        NewUnitTemplate('n01L', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 153., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.48, DAMAGE = 8, CRIT_CHANCE = 14., missile = "MSTR", ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 14, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- hell satyr
        NewUnitTemplate('n01M', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 245., hp_regen = 0.3, moving_speed = 252. },
            weapon = { ATTACK_SPEED = 1.37, DAMAGE = 10, CRIT_CHANCE = 16., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_SLICE },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 18, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 42,
        })
        --==========================================================--
        -- revenant
        NewUnitTemplate('n01U', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 175., hp_regen = 0.2, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 6, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            bonus_parameters = {
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            offhand = { BLOCK = 20., BLOCK_RATE = 30. },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- revenant horror
        NewUnitTemplate('n01I', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.2, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 8, CRIT_CHANCE = 14., ranged = true, LIGHTNING = { id = "RENL", fade = 0.65, bonus_z = 135., range = 45., angle = 50. } , ATTRIBUTE = LIGHTNING_ATTRIBUTE, ATTRIBUTE_BONUS = 10 },
            bonus_parameters = {
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 78, method = STRAIGHT_BONUS },
            },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            have_mp = false,
            xp = 33,
        })
        --==========================================================--
        -- skeleton hell archer
        NewUnitTemplate('n004', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 200., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 9, CRIT_CHANCE = 11., ATTRIBUTE = FIRE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKH" },
            bonus_parameters = {
                { param = FIRE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- skeleton frost archer
        NewUnitTemplate('n007', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 240., hp_regen = 0.4, moving_speed = 230. },
            weapon = { ATTACK_SPEED = 1.95, DAMAGE = 8, CRIT_CHANCE = 11., ATTRIBUTE = ICE_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MSKF" },
            bonus_parameters = {
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 35,
        })
        --==========================================================--
        -- hell wizard
        NewUnitTemplate('n003', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 0.7, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.63, DAMAGE = 11, CRIT_CHANCE = 11., ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15, missile = "MDWZ" },
            bonus_parameters = {
                { param = ALL_RESIST, value = 8, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 37,
        })
        --==========================================================--
        -- demon assassin
        NewUnitTemplate('u009', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 310., hp_regen = 1.7, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 13, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_LIGHT_SLICE },
            have_mp = false,
            xp = 40,
        })

        -- fallen angel
        NewUnitTemplate('u008', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            base_stats = { health = 375., hp_regen = 2.1, moving_speed = 280. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 11, ATTRIBUTE = HOLY_ATTRIBUTE, ATTRIBUTE_BONUS = 15, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = 15, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 40,
        })

        -- hells guardian
        NewUnitTemplate('u00A', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 1.4, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 8, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 10, CRIT_CHANCE = 10., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_SLICE },
            bonus_parameters = {
                { param = ALL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 70, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 50, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 35,
        })

        --==========================================================--
        -- arachnid
        NewUnitTemplate('n00P', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 195., hp_regen = 0.46, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 7, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 25,
        })
        --==========================================================--
        -- arachnid thrower
        NewUnitTemplate('n00O', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 165., hp_regen = 0.46, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.77, DAMAGE = 7, CRIT_CHANCE = 11., missile = "MSAT", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            bonus_parameters = {
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 30,
        })
        --==========================================================--
        -- arachnid warrior
        NewUnitTemplate('n00Q', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 195., hp_regen = 0.49, moving_speed = 270. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 10, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- arachnid burrower
        NewUnitTemplate('n00R', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 165., hp_regen = 0.49, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.7, DAMAGE = 15, CRIT_CHANCE = 9., missile = "MSAT", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 12 },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 40,
        })
        --==========================================================--
        -- arachnid boss
        NewUnitTemplate('n00S', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
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
            skill_list = { "AACL", "AAPN", "AACH" },
            respawn_rect = gg_rct_arachnid_boss,
            respawn_time = 20.,
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- spider
        NewUnitTemplate('n00Y', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 121., hp_regen = 0.46, moving_speed = 240. },
            weapon = { ATTACK_SPEED = 1.55, DAMAGE = 10, CRIT_CHANCE = 7., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 25,
        })
        --==========================================================--
        -- black spider
        NewUnitTemplate('n00Z', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 207., hp_regen = 0.46, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 17, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- black spider of nightmare
        NewUnitTemplate('n01H', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 265., hp_regen = 0.46, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 22, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 55,
        })
        --==========================================================--
        -- spider hunter
        NewUnitTemplate('n010', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 191., hp_regen = 0.49, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.75, DAMAGE = 16, CRIT_CHANCE = 9., missile = "MSSP", ATTRIBUTE = POISON_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            bonus_parameters = {
                { param = POISON_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 37,
        })
        --==========================================================--
        -- gigantic spider
        NewUnitTemplate('n011', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 246., hp_regen = 0.49, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 24, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 11.5, WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
            bonus_parameters = {
                { param = POISON_RESIST, value = 25, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_BONUS, value = 15, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 40,
        })
        --==========================================================--
        -- spider boss
        NewUnitTemplate('n012', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 1500., hp_regen = 0.86, moving_speed = 265. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 33, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_WOOD_LIGHT_BASH },
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
            skill_list = { "ASQB", "ASQT", "ASQS", "ASQC" },
            respawn_rect = gg_rct_spider_boss,
            respawn_time = 20.,
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- bandit
        NewUnitTemplate('n00T', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 195., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.35, DAMAGE = 10, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 5, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 25,
        })
        --==========================================================--
        -- robber
        NewUnitTemplate('n00U', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_COMMON,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 155., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 10, CRIT_CHANCE = 12., missile = "MSBN" },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 5, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 5, method = STRAIGHT_BONUS },
                { param = CRIT_MULTIPLIER, value = 0.3, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 30,
        })
        --==========================================================--
        -- rogue
        NewUnitTemplate('n00V', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 225., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 16, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 10, method = STRAIGHT_BONUS }
            },
            have_mp = false,
            xp = 45,
        })
        --==========================================================--
        -- assassin
        NewUnitTemplate('n00W', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_ADVANCED,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 187., hp_regen = 0.3, moving_speed = 245. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 17, ATTRIBUTE = POISON_ATTRIBUTE, CRIT_CHANCE = 14., missile = "MSBN" },
            offhand = { BLOCK = 25., BLOCK_RATE = 35. },
            bonus_parameters = {
                { param = RANGE_DAMAGE_REDUCTION, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = CRIT_MULTIPLIER, value = 0.3, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 42,
        })
        --==========================================================--
        -- bandit's boss
        NewUnitTemplate('n00X', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_HUMAN,
            time_before_remove = 10.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 32, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- Skeleton King
        NewUnitTemplate('n015', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.45, DAMAGE = 35, CRIT_CHANCE = 13., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- skeleton summoned
        NewUnitTemplate('u00G', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 66., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.66, DAMAGE = 5, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
            have_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- meph ghost summoned
        NewUnitTemplate('u00H', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 66., hp_regen = 0.4, moving_speed = 0. },
            weapon = { ATTACK_SPEED = 1.33, DAMAGE = 7, CRIT_CHANCE = 9., WEAPON_SOUND = WEAPON_TYPE_WOOD_MEDIUM_BASH },
            have_mp = false,
            xp = 0,
        })
         --==========================================================--
        -- MEPH
        NewUnitTemplate('U000', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
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
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = MAGICAL_ATTACK, value = 125, method = STRAIGHT_BONUS }
            },
            skill_list = { "AMLN" },
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- baal
        NewUnitTemplate('U001', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 1750., hp_regen = 0.4, moving_speed = 255. },
            weapon = { ATTACK_SPEED = 1.51, DAMAGE = 35, CRIT_CHANCE = 13., missile = "MBAL", DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 15 },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- underworld queen
        NewUnitTemplate('U002', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 1520., hp_regen = 0.47, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 43, CRIT_CHANCE = 15., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_CHOP },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- butcher
        NewUnitTemplate('U003', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 1720., hp_regen = 0.49, moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.43, DAMAGE = 55, CRIT_CHANCE = 17., WEAPON_SOUND = WEAPON_TYPE_METAL_HEAVY_CHOP },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 650, method = STRAIGHT_BONUS },
                { param = MAGICAL_SUPPRESSION, value = 150, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 75, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = LIGHTNING_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = DARKNESS_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = ICE_RESIST, value = 15, method = STRAIGHT_BONUS },
                { param = HOLY_RESIST, value = -15, method = STRAIGHT_BONUS },
                { param = HP_PER_HIT, value = 5, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- REANIMATED
        NewUnitTemplate('U004', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_UNDEAD,
            time_before_remove = 10.,
            base_stats = { health = 1325., hp_regen = 0.41, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 31, CRIT_CHANCE = 12., missile = "MREA" },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- DEMON LORD
        NewUnitTemplate('U005', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 1145., hp_regen = 0.41, moving_speed = 250. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 33, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- demoness
        NewUnitTemplate('U006', {
            unit_class = NO_CLASS,
            classification = MONSTER_RANK_BOSS,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 1445., hp_regen = 0.44, moving_speed = 264. },
            weapon = { ATTACK_SPEED = 1.46, DAMAGE = 36, CRIT_CHANCE = 14., WEAPON_SOUND = WEAPON_TYPE_METAL_MEDIUM_SLICE },
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
            have_mp = false,
            xp = 700,
        })
        --==========================================================--
        -- spider egg 1
        NewUnitTemplate('speb', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 300., hp_regen = 0.2, moving_speed = 0. },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- spider egg 2
        NewUnitTemplate('speg', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 300., hp_regen = 0.2, moving_speed = 0. },
            bonus_parameters = {
                { param = ALL_RESIST, value = 10, method = STRAIGHT_BONUS },
                { param = PHYSICAL_DEFENCE, value = 350, method = STRAIGHT_BONUS },
                { param = CONTROL_REDUCTION, value = 100, method = STRAIGHT_BONUS },
                { param = FIRE_RESIST, value = -25, method = STRAIGHT_BONUS },
                { param = POISON_RESIST, value = 45, method = STRAIGHT_BONUS },
            },
            have_mp = false,
            xp = 0,
        })
        --==========================================================--
        -- Lilith
        NewUnitTemplate('n017', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_DEMON,
            time_before_remove = 10.,
            base_stats = { health = 662., hp_regen = 0.55, moving_speed = 275. },
            weapon = { ATTACK_SPEED = 1.6, DAMAGE = 17, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_MAGICAL, ATTRIBUTE = DARKNESS_ATTRIBUTE, ATTRIBUTE_BONUS = 7, missile = "MSCB" },
            have_mp = false,
            colours = { r = 255, g = 120, b = 190, a = 255 },
            xp = 10,
        })

        -- Forest Guard
        NewUnitTemplate('n01X', {
            unit_class = NO_CLASS,
            classification = 0,
            trait = TRAIT_BEAST,
            time_before_remove = 10.,
            base_stats = { health = 962., hp_regen = 0.75, moving_speed = 285. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 22, CRIT_CHANCE = 14., DAMAGE_TYPE = DAMAGE_TYPE_PHYSICAL, ATTRIBUTE = PHYSICAL_ATTRIBUTE, ATTRIBUTE_BONUS = 7 },
            have_mp = false,
            colours = { r = 255, g = 255, b = 255, a = 255 },
            xp = 10,
        })


        local group = CreateGroup()

            GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, nil)

            ForGroup(group, function ()
                local handle = GetUnitTypeId(GetEnumUnit())

                    if UnitsData[handle] then
                        NewUnitByTemplate(GetEnumUnit(), UnitsData[handle])
                        OnUnitCreated(GetEnumUnit())
                    end

            end)

        DestroyGroup(group)

        local trg = CreateTrigger()
        TriggerRegisterEnterRectSimple(trg, bj_mapInitialPlayableArea)
        TriggerAddAction(trg, function ()

            local unit = GetTriggerUnit()

                if UnitsList[GetHandleId(unit)] == nil and UnitsData[GetUnitTypeId(unit)] then
                    NewUnitByTemplate(unit, UnitsData[GetUnitTypeId(unit)])
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
                    --PauseTimer(unit_data.action_timer)
                    --PauseTimer(unit_data.attack_timer)

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


        RegisterTestCommand("t1", function()
        print("dummy spawned")

                    CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy1), GetRectCenterY(gg_rct_dummy1), 135.)
        local d2 =  CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy2), GetRectCenterY(gg_rct_dummy2), 135.)
        local d3 =  CreateUnit(Player(10), FourCC("dmmy"), GetRectCenterX(gg_rct_dummy3), GetRectCenterY(gg_rct_dummy3), 135.)

        DelayAction(0.01, function()
            ModifyStat(d2, PHYSICAL_DEFENCE, 250, STRAIGHT_BONUS, true)
            ModifyStat(d3, PHYSICAL_DEFENCE, 500, STRAIGHT_BONUS, true)
        end)
    end)

    end

end