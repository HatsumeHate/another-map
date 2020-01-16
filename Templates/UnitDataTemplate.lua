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


        ---@param source unit
        ---@param class integer
        ---@param reference_base table
        ---@param reference_weapon table
        function NewUnitData(source, class, reference_base, reference_weapon)
            local class_base_stats = BASE_STATS[class]
            local data                 = {
                Owner        = source,
                unit_class   = class,

                base_stats = {
                    strength = class_base_stats[1], vitality = class_base_stats[2], agility = class_base_stats[3], intellect = class_base_stats[4],
                    health = 100, mana = 100, hp_regen = 1., mp_regen = 1., moving_speed = 300
                },

                action_timer = CreateTimer(),
                attack_timer = CreateTimer(),

                is_hp_static = false,
                have_mp = true,
                is_mp_static = false,

                cast_skill = 0,
                cast_skill_level = 0,
                cast_effect = nil,

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

            if reference_base ~= nil then MergeTables(data.base_stats, reference_base) end
            if reference_weapon ~= nil then MergeTables(data.equip_point[WEAPON_POINT], reference_weapon) end

            UpdateParameters(data)
            UnitsList[GetHandleId(source)] = data
            return data
        end


    ---@param source unit
    function NewUnitByTemplate(source, reference_data)
        local class_base_stats = BASE_STATS[reference_data.unit_class]
        local data                 = {
            Owner        = source,
            unit_class   = reference_data.unit_class,

            base_stats = {
                strength = class_base_stats[1], vitality = class_base_stats[2], agility = class_base_stats[3], intellect = class_base_stats[4],
                health = reference_data.base_stats.health, mana = reference_data.base_stats.mana,
                hp_regen = reference_data.base_stats.hp_regen, mp_regen = reference_data.base_stats.mp_regen,
                moving_speed = reference_data.base_stats.moving_speed
            },

            action_timer = CreateTimer(),
            attack_timer = CreateTimer(),

            is_hp_static = reference_data.is_hp_static,
            have_mp = reference_data.have_mp,
            is_mp_static = reference_data.is_mp_static,
            time_before_remove = reference_data.time_before_remove or 10.,

            cast_skill = 0,
            cast_skill_level = 0,
            cast_effect = nil,

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

        UpdateParameters(data)
        UnitsList[GetHandleId(source)] = data
        return data
    end


    function NewUnitTemplate(id, reference)
        local new_data = { }

        MergeTables(new_data, reference)


        if new_data.unit_class == nil then
            new_data.unit_class = BARBARIAN_CLASS
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
            new_data.base_stats = {health = 100, mana = 100, hp_regen = 1., mp_regen = 1., moving_speed = 300}
        else
            if new_data.base_stats.health == nil then new_data.base_stats.health = 100 end
            if new_data.base_stats.mana == nil then new_data.base_stats.mana = 100 end
            if new_data.base_stats.hp_regen == nil then new_data.base_stats.hp_regen = 1. end
            if new_data.base_stats.mp_regen == nil then new_data.base_stats.mp_regen = 1. end
            if new_data.base_stats.moving_speed == nil then new_data.base_stats.moving_speed = 300 end
        end

        UnitsData[FourCC(id)] = new_data
    end







    function UnitDataInit()

        NewUnitTemplate('h000', {
            unit_class = SPECIAL_CLASS,
            base_stats = { health = 3000., hp_regen = 5. },
            weapon = { DAMAGE = 25, CRIT_CHANCE = 15. }
        })

        NewUnitTemplate('HBRB', {
            unit_class = BARBARIAN_CLASS,
            time_before_remove = 0.
            --weapon = { ATTACK_SPEED = 0.4, DAMAGE = 15, CRIT_CHANCE = 15. }
        })

        NewUnitTemplate('HSRC', {
            unit_class = SORCERESS_CLASS,
            time_before_remove = 0.
            --base_stats = { health = 3000., hp_regen = 30. },
        })


        -- fiend
        NewUnitTemplate('u007', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 125., hp_regen = 1., moving_speed = 330. },
            weapon = { ATTACK_SPEED = 1.4, DAMAGE = 5, CRIT_CHANCE = 10. },
            have_mp = false
        })

        -- armored scele
        NewUnitTemplate('u00B', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 220., hp_regen = 1., moving_speed = 260. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 4, CRIT_CHANCE = 7. },
            have_mp = false
        })

        -- demon assassin
        NewUnitTemplate('u009', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 310., hp_regen = 1.7, moving_speed = 300. },
            weapon = { ATTACK_SPEED = 1.5, DAMAGE = 15, CRIT_CHANCE = 14. },
            have_mp = false
        })

        -- fallen angel
        NewUnitTemplate('u008', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 375., hp_regen = 2.1, moving_speed = 300. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 12, ATTRIBUTE = HOLY_ATTRIBUTE, CRIT_CHANCE = 15. },
            have_mp = false
        })

        -- hells guardian
        NewUnitTemplate('u00A', {
            unit_class = NO_CLASS,
            time_before_remove = 10.,
            base_stats = { health = 270., hp_regen = 1.4, moving_speed = 280. },
            weapon = { ATTACK_SPEED = 1.8, DAMAGE = 8, ATTRIBUTE = DARKNESS_ATTRIBUTE, CRIT_CHANCE = 10. },
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