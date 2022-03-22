do

    MissileList = 0

    function GetMissileData(id)
        return MissileList[FourCC(id)] or nil
    end


    function NewMissileTemplate(id, missile_reference)
        local new_missile = {

            name = "",
            id = id,
            model = "",
            decay = 0,

            effect_on_target_scale = 1.,
            effect_on_target_point = "",
            effect_on_target = "",
            effect_on_loc = "",

            sound_on_hit = nil,
            sound_on_launch = nil,
            sound_on_destroy = nil,
            sound_on_fly = nil,

            effect_on_impact = nil,
            effect_on_hit = nil,
            effect_on_expire = nil,
            effect_get_level_from_skill = nil,

            radius = 0.,
            max_distance = 0.,
            speed = 0.,
            scale = 1.,

            lightning_id = nil,
            lightning_length = 0.,

            max_targets = 1,
            hit_once_in = 0.,

            start_z = 0.,
            end_z = 0.,
            arc = 0.,

            revert = false,
            trackable = false,
            can_enum = true,

            full_distance = false,
            only_on_target = false,
            only_on_impact = false,
            penetrate = false,
            ignore_terrain = false

        }

        --real MissileOffset


        MergeTables(new_missile, missile_reference)

        if new_missile.full_distance == nil then
            new_missile.full_distance = false
        end

        if new_missile.only_on_target == nil then
            new_missile.only_on_target = false
        end

        if new_missile.only_on_impact == nil then
            new_missile.only_on_impact = false
        end

        if new_missile.ignore_terrain == nil then
            new_missile.ignore_terrain = false
        end

        if new_missile.penetrate == nil then
            new_missile.penetrate = false
        end

        if new_missile.scale == nil then
            new_missile.scale = 1.
        end

        if new_missile.max_targets == nil then
            new_missile.max_targets = 1
        end

        MissileList[FourCC(id)] = new_missile
    end


    function DefineMissilesData()
        MissileList = {}
        NewMissileTemplate('M001', {
            name = "test missile",
            model = ".mdx",
            max_distance = 1000.,
            radius = 50.,
            speed = 400.,
            start_z = 65.,
            lightning_id = 'CHIM',
            lightning_length = 125.,
            end_z = 65.,
            arc = 0.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('M002', {
            name = "test straight missile",
            model = "Abilities\\Weapons\\Arrow\\ArrowMissile.mdx",
            max_distance = 1000.,
            radius = 50.,
            speed = 800.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.2,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })

        --===============================================--
        NewMissileTemplate('MLtrait', {
            name = "discharge trait missile",
            model = "Spell\\LightningSpark.mdx",
            max_distance = 800.,
            radius = 65.,
            speed = 275.,
            start_z = 15.,
            end_z = 15.,
            arc = 0.,
            max_targets = 1,
            effect_on_hit = 'ELtrait',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_wave_loop_1.wav" },
                volume = 25,
                cutoff = 1600.,
                looping = true
            },
            ignore_terrain = true,
            full_distance = true,
        })

        --==============================================--
        NewMissileTemplate('SRHD', {
            name = "hydra missile",
            model = "Spell\\GreatElderHydraMoltenBreath.mdx",
            max_distance = 750.,
            radius = 52.,
            speed = 870.,
            start_z = 50.,
            end_z = 50.,
            arc = 0.05,
            scale = 0.55,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })

        --==============================================--
        NewMissileTemplate('MSTA', {
            name = "standart bow attack",
            model = "Abilities\\Weapons\\Arrow\\ArrowMissile.mdx",
            max_distance = 900.,
            radius = 50.,
            speed = 950.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.11,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })

        --==============================================--
        NewMissileTemplate('MSKA', {
            name = "skeleton archer",
            model = "Abilities\\Weapons\\Arrow\\ArrowMissile.mdx",
            max_distance = 900.,
            radius = 50.,
            speed = 800.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.15,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MNLH', {
            name = "summoned lich",
            model = "Abilities\\Weapons\\GargoyleMissile\\GargoyleMissile.mdx",
            max_distance = 900.,
            radius = 55.,
            speed = 600.,
            start_z = 73.,
            end_z = 73.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSKH', {
            name = "skeleton hell archer",
            model = "Abilities\\Weapons\\SearingArrow\\SearingArrowMissile.mdx",
            max_distance = 900.,
            radius = 50.,
            speed = 800.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.15,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSKF', {
            name = "skeleton frost archer",
            model = "Abilities\\Weapons\\ColdArrow\\ColdArrowMissile.mdx",
            max_distance = 900.,
            radius = 50.,
            speed = 800.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.15,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSKM', {
            name = "skeleton mage",
            model = "Abilities\\Weapons\\SkeletalMageMissile\\SkeletalMageMissile.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 600.,
            start_z = 60.,
            end_z = 60.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSSM', {
            name = "sorceress nightmare",
            model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 725.,
            start_z = 60.,
            end_z = 60.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MVWS', {
            name = "void walker small",
            model = "Effect\\Voidball Minor.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 600.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            scale = 0.85,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MVWM', {
            name = "void walker normal",
            model = "Effect\\Voidball Minor.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 600.,
            start_z = 85.,
            end_z = 85.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MVWB', {
            name = "void walker big",
            model = "Effect\\Voidball Medium.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 550.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MDWZ', {
            name = "hell wizard",
            model = "Abilities\\Weapons\\DemonHunterMissile\\DemonHunterMissile.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 620.,
            start_z = 85.,
            end_z = 85.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MNCR', {
            name = "necromancer missile",
            model = "Abilities\\Weapons\\NecromancerMissile\\NecromancerMissile.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 750.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MBNS', {
            name = "bashee minor missile",
            model = "Abilities\\Weapons\\BansheeMissile\\BansheeMissile.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 670.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MGHO', {
            name = "ghost missile",
            model = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl",
            max_distance = 1000.,
            radius = 55.,
            speed = 480.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MBON', {
            name = "banshee n missile",
            model = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl",
            max_distance = 1000.,
            radius = 55.,
            speed = 780.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSTR', {
            name = "satyr missile",
            model = "Abilities\\Weapons\\NecromancerMissile\\NecromancerMissile.mdx",
            max_distance = 1000.,
            radius = 52.,
            speed = 550.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            scale = 0.7,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSCB', {
            name = "succubus missile",
            model = "Abilities\\Weapons\\VengeanceMissile\\VengeanceMissile.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 370.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            scale = 1.1,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MBAL', {
            name = "BAAL missile",
            model = "Abilities\\Weapons\\GargoyleMissile\\GargoyleMissile.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 670.,
            start_z = 65.,
            end_z = 60.,
            arc = 0.,
            scale = 1.2,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MREA', {
            name = "reanimated boss",
            model = "Abilities\\Weapons\\SearingArrow\\SearingArrowMissile.mdx",
            max_distance = 900.,
            radius = 53.,
            speed = 900.,
            start_z = 60.,
            end_z = 60.,
            arc = 0.2,
            scale = 1.1,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSAT', {
            name = "arachnid thrower missile",
            model = "Abilities\\Weapons\\HarpyMissile\\HarpyMissile.mdx",
            max_distance = 600.,
            radius = 57.,
            speed = 450.,
            start_z = 45.,
            end_z = 45.,
            arc = 0.1,
            scale = 0.8,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSQB', {
            name = "spider queen venom bile missile",
            model = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdx",
            max_distance = 750.,
            radius = 62.,
            speed = 600.,
            start_z = 35.,
            end_z = 45.,
            arc = 0.07,
            scale = 1.27,
            effect_on_hit = "ESQM",
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSBN', {
            name = "bandit missile",
            model = "Abilities\\Weapons\\Banditmissile\\Banditmissile.mdx",
            max_distance = 700.,
            radius = 57.,
            speed = 470.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.1,
            scale = 1.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSSP', {
            name = "arachno missile",
            model = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdx",
            max_distance = 750.,
            radius = 57.,
            speed = 450.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.1,
            scale = 1.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MAPN', {
            name = "arachno poison nova missile",
            model = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdx",
            max_distance = 850.,
            radius = 60.,
            speed = 370.,
            start_z = 45.,
            end_z = 45.,
            arc = 0.,
            scale = 1.35,
            effect_on_hit = "EAPN",
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MSSK', {
            name = "summon skele missile",
            model = "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissile.mdx",
            speed = 330.,
            start_z = 100.,
            end_z = 0.,
            arc = 0.35,
            scale = 1.,
            only_on_impact = true,
            ignore_terrain = false
        })
        --==============================================--
        NewMissileTemplate('MSCN', {
            name = "summon curse missile",
            model = "Abilities\\Spells\\Undead\\Possession\\PossessionMissile.mdx",
            speed = 250.,
            start_z = 60.,
            end_z = 60.,
            scale = 1.,
            trackable = true,
            ignore_terrain = true,
            only_on_target = true
        })
        --==============================================--
        NewMissileTemplate('MMLN', {
            name = "meph lightning missile",
            model = ".mdx",
            max_distance = 800.,
            radius = 50.,
            speed = 500.,
            start_z = 25.,
            end_z = 25.,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_wave_loop_1.wav" },
                volume = 25,
                cutoff = 1700.
            },
            lightning_id = "YENL",
            lightning_length = 175.,
            effect_on_hit = "EALN",
            scale = 1.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MFRB', {
            name = "frostbolt missile",
            model = "Spell\\Blizzard II Missile.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 800.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 0.75,
            effect_on_hit = 'EFRB',
            --sound_on_launch = { "Sounds\\Spells\\frosbolt_launch_1.wav", "Sounds\\Spells\\frosbolt_launch_2.wav" },
            sound_on_launch = {
                pack = { "Sounds\\Spells\\frosbolt_launch_1.wav", "Sounds\\Spells\\frosbolt_launch_2.wav" },
                volume = 125,
                cutoff = 1600.,
            },
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        NewMissileTemplate('MGFB', {
            name = "firebolt missile",
            model = "Spell\\Fireball Medium.mdx",
            max_distance = 1000.,
            radius = 100.,
            speed = 625.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 0.8,
            effect_on_hit = 'EGFB',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\fire_launch_1.wav", "Sounds\\Spells\\fire_launch_2.wav", "Sounds\\Spells\\fire_launch_3.wav" },
                volume = 100,
                cutoff = 1700.
            },
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('MPRS', {
            name = "pursuer missile",
            model = "Effect\\Pursuer.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 270.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 1.,
            effect_on_hit = 'effect_pursuer',
            sound_on_launch = {
                pack = { "Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissileLaunch1.wav" },
                volume = 124,
                cutoff = 1700.
            },
            max_targets = 300,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = true,
        })

        --==============================================--
        NewMissileTemplate('MMLT', {
            name = "meltdown missile",
            model = "Spell\\Fire Spear.mdx",
            max_distance = 750.,
            radius = 55.,
            speed = 1750.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 1.,
            effect_on_hit = 'EMLT',
            --sound_on_launch = { "Sounds\\Spells\\fire_light_launch_1.wav", "Sounds\\Spells\\fire_light_launch_2.wav", "Sounds\\Spells\\fire_light_launch_3.wav" },
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('MFRO', {
            name = "frost orb missile",
            model = "Spell\\FrozenOrb.mdx",
            max_distance = 600.,
            radius = 125.,
            speed = 625.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.,
            scale = 1.45,
            max_targets = 300,
            hit_once_in = 0.25,
            effect_on_expire = 'EFRO',
            effect_on_hit = 'EFOA',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\frost_orb_launch_1.wav", "Sounds\\Spells\\frost_orb_launch_2.wav" },
                volume = 125,
                cutoff = 1700.
            },
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
        })
        --===============================================--
        NewMissileTemplate('MMTR', {
            name = "meteor missile",
            model = "war3mapImported\\Rain of Fire.mdx",
            max_distance = 600.,
            radius = 25.,
            speed = 75.,
            start_z = 325.,
            end_z = 0.,
            arc = 0.,
            scale = 1.25,
            max_targets = 300,
            effect_on_impact = 'EMTR',
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = true
        })
        --===============================================--
        NewMissileTemplate('MDSC', {
            name = "discharge missile",
            model = "Spell\\LightningSpark.mdx",
            max_distance = 800.,
            radius = 65.,
            speed = 375.,
            start_z = 15.,
            end_z = 15.,
            arc = 0.,
            max_targets = 1,
            effect_on_hit = 'EDSC',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_wave_loop_1.wav" },
                volume = 25,
                cutoff = 1600.,
                looping = true
            },
            ignore_terrain = true,
            full_distance = true,
        })
        --===============================================--
        NewMissileTemplate('MBLB', {
            name = "lightning orb missile",
            model = "Spell\\AZ_DD021.mdx",--"Spell\\LightningSphere_FX.mdx",
            max_distance = 800.,
            radius = 400.,
            speed = 165.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            scale = 0.65,
            hit_once_in = 0.7,
            effect_on_hit = 'ELBL',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_loop_1.wav", "Sounds\\Spells\\lightning_loop_3.wav", "Sounds\\Spells\\lightning_loop_4.wav"},
                volume = 100,
                cutoff = 1700.,
                looping = true
            },
            max_targets = 300,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true
        })
        --===============================================--
        NewMissileTemplate('MTHK', {
            name = "knife missile",
            model = "Spell\\SpinningKnife.mdx",
            max_distance = 700.,
            radius = 75.,
            speed = 740.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.1,
            effect_on_hit = 'ETHK',
            max_targets = 1,
            ignore_terrain = false,
            full_distance = true,
            penetrate = false,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\throw_whirl_1.wav", "Sounds\\Spells\\throw_whirl_2.wav", "Sounds\\Spells\\throw_whirl_3.wav" },
                volume = 100,
                cutoff = 1700.
            },
        })
        --===============================================--
        NewMissileTemplate('MBCH', {
            name = "chain missile",
            model = ".mdx",
            max_distance = 600.,
            effect_on_hit = 'EBCH',
            radius = 75.,
            speed = 1200.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            can_enum = false,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\chain_launch_1.wav", "Sounds\\Spells\\chain_launch_2.wav", "Sounds\\Spells\\chain_launch_3.wav", "Sounds\\Spells\\chain_launch_4.wav", "Sounds\\Spells\\chain_launch_5.wav" },
                volume = 100,
                cutoff = 1700.
            },
        })
        --===============================================--
        NewMissileTemplate('MSHG', {
            name = "shatter ground missile",
            model = ".mdx",
            max_distance = 400.,
            effect_on_hit = 'ESHG',
            angle_window = 90.,
            radius = 100.,
            speed = 800.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            hit_once_in = 5.,
            max_targets = 300,
            can_enum = false,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
        })
        --===============================================--
        NewMissileTemplate('MNBS', {
            name = "bone spear missile",
            model = "Effect\\PeeKay's BoneSpear.mdx",
            max_distance = 1000.,
            effect_on_hit = 'ENBS',
            sound_on_destroy = {
                pack = { "Sounds\\Spells\\bone_heavy_hit_1.wav", "Sounds\\Spells\\bone_heavy_hit_2.wav", "Sounds\\Spells\\bone_heavy_hit_3.wav", "Sounds\\Spells\\bone_heavy_hit_4.wav", "Sounds\\Spells\\bone_heavy_hit_5.wav" },
                volume = 123,
                cutoff = 1600.,
            },
            radius = 75.,
            speed = 900.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            max_targets = 1,
            hit_once_in = 3.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            can_enum = true
        })
        --===============================================--
        NewMissileTemplate('MNPS', {
            name = "toxic substance missile",
            model = "Spell\\OrbOfVenom.mdx",
            max_distance = 1000.,
            effect_on_hit = 'ENTS',
            --sound_on_launch = {
               -- pack = { "Sounds\\Spells\\poison_cast_1.wav", "Sounds\\Spells\\poison_cast_2.wav", "Sounds\\Spells\\poison_cast_3.wav" },
                --volume = 125,
                --cutoff = 1600.,
            --},
            radius = 75.,
            speed = 700.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            max_targets = 1,
            hit_once_in = 3.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            can_enum = true
        })
        --===============================================--
        NewMissileTemplate('MNDV', {
            name = "devour missile",
            model = "Effect\\CorpseBomb.mdx",
            max_distance = 1000.,
            effect_on_hit = 'ENDV',
            sound_on_hit = {
                pack = { "Abilities\\Spells\\Human\\Heal\\HealTarget.wav" },
                volume = 120,
                cutoff = 1600.,
            },
            sound_on_launch = {
                pack = { "Sounds\\Spells\\devour_1.wav", "Sounds\\Spells\\devour_2.wav", "Sounds\\Spells\\devour_3.wav", "Sounds\\Spells\\devour_4.wav", "Sounds\\Spells\\devour_5.wav" },
                volume = 125,
                cutoff = 1600.,
            },
            radius = 75.,
            speed = 600.,
            start_z = 0.,
            end_z = 70.,
            arc = 0.,
            only_on_target = true,
            ignore_terrain = true,
            full_distance = false,
            penetrate = false,
            can_enum = false,
            trackable = true,
        })
        --===============================================--
        NewMissileTemplate('MNLS', {
            name = "lich res soul",
            model = "Abilities\\Weapons\\ZigguratMissile\\ZigguratMissile.mdx",
            max_distance = 1250.,
            radius = 75.,
            speed = 740.,
            start_z = 10.,
            end_z = 10.,
            arc = 0.5,
            ignore_terrain = true,
            full_distance = false,
            penetrate = true,
            trackable = false,
        })
        --==============================================--
        NewMissileTemplate('summoned_ghost_missile', {
            name = "necro ghost missile",
            model = "Effect\\Soulfire Missile.mdx",
            max_distance = 1000.,
            radius = 60.,
            speed = 525.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 1.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('void_rain_missile', {
            name = "void rain",
            model = "Effect\\Void Rain Missile.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 1100.,
            start_z = 900.,
            end_z = 0.,
            arc = 0.,
            effect_on_expire = "EVDR",
            can_enum = false,
            ignore_terrain = true,
            --penetrate = false,
            only_on_impact = true
        })
        --==============================================--
        NewMissileTemplate('fire_rain_missile', {
            name = "fire rain",
            model = "Effect\\Rain of Fire Vol. II Missile.mdx",
            max_distance = 1000.,
            radius = 57.,
            speed = 1100.,
            start_z = 900.,
            end_z = 0.,
            arc = 0.,
            effect_on_expire = "fire_rain_effect",
            ignore_terrain = true,
            can_enum = false,
            --penetrate = false,
            only_on_impact = true
        })
        --==============================================--
        NewMissileTemplate('poison_barrage_missile', {
            name = "andariel missile",
            model = "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdx",
            max_distance = 750.,
            radius = 57.,
            speed = 1000.,
            start_z = 95.,
            end_z = 95.,
            scale = 1.,
            effect_on_hit = "poison_barrage_effect",
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --===============================================--
        NewMissileTemplate('MRLR', {
            name = "revenant lightning missile",
            model = "Spell\\Accelerator Gate Red.mdx",
            max_distance = 700.,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_loop_7.wav", "Sounds\\Spells\\lightning_loop_2.wav" },
                volume = 30,
                cutoff = 1600.,
                looping = true
            },
            --effect_on_hit = 'revenant_lightning_effect',
            radius = 100.,
            speed = 175.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            can_enum = false,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            only_on_impact = true
        })
    end

end
