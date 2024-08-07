do

    MissileList = 0

    function GetMissileData(id)
        return MissileList[id] or nil
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

        MissileList[id] = new_missile
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
            speed = 325.,
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
            model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdx",
            max_distance = 750.,
            radius = 60.,
            speed = 1050.,
            start_z = 90.,
            sound_on_launch = {
                pack = { "Sounds\\Missiles\\Hydra_Shoot_1.wav", "Sounds\\Missiles\\Hydra_Shoot_2.wav", "Sounds\\Missiles\\Hydra_Shoot_3.wav" },
                volume = 128,
                cutoff = 1700.,
            },
            end_z = 90.,
            scale = 1.,
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
            arc = 0.1,
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
            speed = 1200.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.12,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })

        --==============================================--
        NewMissileTemplate('MGNL', {
            name = "gnoll warden",
            model = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdx",
            max_distance = 700.,
            radius = 50.,
            speed = 650.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.1,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('MNLH', {
            name = "summoned lich",
            model = "Abilities\\Weapons\\GargoyleMissile\\GargoyleMissile.mdx",
            max_distance = 900.,
            radius = 55.,
            speed = 700.,
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
            speed = 1200.,
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
        NewMissileTemplate('missile_skeletal_mage_fire', {
            name = "skeleton mage",
            model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdч",
            max_distance = 1000.,
            radius = 55.,
            speed = 1100.,
            start_z = 60.,
            end_z = 60.,
            arc = 0.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('missile_skeletal_mage_cold', {
            name = "skeleton mage",
            model = "Abilities\\Spells\\Other\\FrostBolt\\FrostBoltMissile.mdx",
            max_distance = 1000.,
            radius = 55.,
            speed = 1000.,
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
            speed = 925.,
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
            speed = 550.,
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
            radius = 65.,
            speed = 670.,
            start_z = 65.,
            end_z = 60.,
            arc = 0.,
            scale = 1.2,
            sound_on_launch = {
                pack = { "Sounds\\Monsters\\baal_attack.wav" },
                volume = 115,
                cutoff = 1600.,
            },
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('meph_frost_blast_missile', {
            name = "meph missile",
            model = "Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 425.,
            start_z = 120.,
            end_z = 120.,
            arc = 0.,
            scale = 1.,
            effect_on_hit = "meph_frost_blast_effect",
            ignore_terrain = true,
            penetrate = true,
            full_distance = true,
            max_targets = 300,
        })
        --==============================================--
        NewMissileTemplate('MREA', {
            name = "reanimated boss",
            model = "Abilities\\Weapons\\SearingArrow\\SearingArrowMissile.mdx",
            max_distance = 900.,
            radius = 53.,
            speed = 1200.,
            start_z = 60.,
            end_z = 30.,
            arc = 0.07,
            scale = 1.1,
            ignore_terrain = false,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('reanimated_arrow_barrage_missile', {
            name = "reanimated arrow barrage",
            model = "Missile\\BonefireArrow1.mdx",
            max_distance = 900.,
            radius = 20.,
            speed = 1000.,
            start_z = 1000.,
            end_z = 0.,
            scale = 1.,
            only_on_impact = true,
            effect_on_impact = "reanimated_arrow_barrage_effect",
            ignore_terrain = false,
        })
        --==============================================--
        NewMissileTemplate('demoness_evolt_missile', {
            name = "evolt missile",
            model = "Effect\\Evolt-8.mdx",
            max_distance = 1000.,
            radius = 120.,
            speed = 305.,
            start_z = 100.,
            end_z = 100.,
            arc = 0.,
            geo_arc = 45.,
            geo_arc_length = 175.,
            geo_arc_randomize_angle = true,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\evolt_loop.wav" },
                volume = 100,
                cutoff = 1600.,
                looping = true
            },
            sound_on_launch = {
                pack = { "Sounds\\Spells\\evolt_launch_1.wav", "Sounds\\Spells\\evolt_launch_2.wav" },
                volume = 140,
                cutoff = 1700.,
            },
            scale = 0.5,
            effect_on_hit = "demoness_evolt_missile_effect",
            ignore_terrain = true,
            penetrate = true,
            full_distance = true,
            max_targets = 300,
        })
        --==============================================--
        NewMissileTemplate('MSAT', {
            name = "arachnid thrower missile",
            model = "Abilities\\Weapons\\HarpyMissile\\HarpyMissile.mdx",
            max_distance = 600.,
            radius = 57.,
            speed = 850.,
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
            speed = 1200.,
            start_z = 65.,
            end_z = 65.,
            arc = 0.1,
            scale = 1.,
            ignore_terrain = true,
            penetrate = false,
            full_distance = true
        })
        --==============================================--
        NewMissileTemplate('bandit_arcane_missile', {
            name = "bandit arcane missile",
            model = "Missile\\ArcaneMissileComplete.mdx",
            max_distance = 700.,
            radius = 57.,
            speed = 1000.,
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
            speed = 650.,
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
            ignore_terrain = false,
            can_enum = false
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
            penetrate = true,
            full_distance = true,
            max_targets = 300
        })
        --==============================================--
        NewMissileTemplate('MFRB', {
            name = "frostbolt missile",
            model = "Missile\\FrostBoltV1.mdx", --"Spell\\Blizzard II Missile.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 1200.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 0.85,
            effect_on_hit = 'EFRB',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\FrostBolt_Loop_1.wav", "Sounds\\Spells\\FrostBolt_Loop_2.wav" },
                volume = 120,
                cutoff = 1700.,
                looping = true
            },
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
            model = "Spell\\Firebolt Classic.mdx",
            max_distance = 1000.,
            radius = 100.,
            speed = 1300.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 1.1,
            effect_on_hit = 'EGFB',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\Fireball_Loop_1.wav", "Sounds\\Spells\\Fireball_Loop_2.wav" },
                volume = 128,
                cutoff = 1700.,
                looping = true
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
            speed = 525.,
            start_z = 75.,
            end_z = 75.,
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
            speed = 500.,
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
            model = "Spell\\AZ_DD021.mdx",
            max_distance = 800.,
            radius = 400.,
            speed = 165.,
            start_z = 70.,
            end_z = 70.,
            arc = 0.,
            scale = 0.65,
            hit_once_in = 0.7,
            effect_on_hit = 'ELBL',
            sound_on_hit = {
                pack = { "Sounds\\Spells\\CracklingEnergy_Cast_Arc_1.wav", "Sounds\\Spells\\CracklingEnergy_Cast_Arc_2.wav", "Sounds\\Spells\\CracklingEnergy_Cast_Arc_3.wav", "Sounds\\Spells\\CracklingEnergy_Cast_Arc_4.wav" },
                volume = 135,
                cutoff = 1600.,
            },
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
        NewMissileTemplate('lightning_spear_missile', {
            name = "lightning_spear_missile",
            model = "Missile\\Lightning Missile.mdx",
            max_distance = 1200.,
            radius = 100.,
            speed = 1400.,
            start_z = 80.,
            end_z = 80.,
            scale = 1.,
            effect_on_hit = 'lightning_spear_effect',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\lightning_loop_7.wav", "Sounds\\Spells\\lightning_loop_6.wav"},
                volume = 100,
                cutoff = 1700.,
                looping = true
            },
            hit_once_in = 1.,
            max_targets = 500,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
        })
        --===============================================--
        NewMissileTemplate('arcane_barrage_missile', {
            name = "arcane barrage missile",
            model = "Missile\\ArcaneMissileComplete.mdx",
            max_distance = 1000.,
            radius = 80.,
            speed = 1100.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            sound_on_launch = {
                pack = { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav" },
                volume = 110,
                cutoff = 1500.
            },
            effect_on_hit = 'effect_arcane_missile',
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --===============================================--
        NewMissileTemplate('arcane_barrage_missile_side', {
            name = "arcane barrage missile",
            model = "Missile\\ArcaneMissileComplete.mdx", --"Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdx",
            max_distance = 1000.,
            radius = 80.,
            speed = 1100.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 1.,
            geo_arc = 45.,
            geo_arc_randomize_angle = false,
            sound_on_launch = {
                pack = { "Sounds\\Spells\\cast_large_1.wav", "Sounds\\Spells\\cast_large_2.wav", "Sounds\\Spells\\cast_large_3.wav" },
                volume = 110,
                cutoff = 1500.
            },
            effect_on_hit = 'effect_arcane_missile',
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --===============================================--
        NewMissileTemplate('fire_wall_missile', {
            name = "fire wall missile",
            model = "Effect\\fire3.mdx",
            max_distance = 700.,
            radius = 100.,
            speed = 1000.,
            start_z = 0.,
            end_z = 0.,
            scale = 1.15,
            effect_on_hit = 'fire_wave_effect',
            max_targets = 500,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
        })
        --===============================================--
        NewMissileTemplate('MTHK', {
            name = "knife missile",
            model = "Spell\\SpinningKnife.mdx",
            max_distance = 700.,
            radius = 75.,
            speed = 900.,
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
            sound_on_fly = {
                pack = { "Sounds\\Spells\\Bone_Spear_Travel_1.wav", "Sounds\\Spells\\Bone_Spear_Travel_2.wav", "Sounds\\Spells\\Bone_Spear_Travel_3.wav", },
                volume = 155,
                cutoff = 1600.
            },
            radius = 75.,
            speed = 1000.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            max_targets = 1,
            hit_once_in = 3.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            can_enum = true
        })
        --===============================================--
        NewMissileTemplate('splitter_missile', {
            name = "bone spear missile",
            model = "Abilities\\Weapons\\BristleBackMissile\\BristleBackMissile.mdl",
            max_distance = 275.,
            effect_on_hit = 'splitter_effect',
            radius = 55.,
            speed = 1200.,
            start_z = 70.,
            end_z = 70.,
            max_targets = 300,
            hit_once_in = 3.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            can_enum = true
        })
        --===============================================--
        NewMissileTemplate('MNPS', {
            name = "toxic substance missile",
            model = "Missile\\WidowPoison.mdx",--"Spell\\OrbOfVenom.mdx",
            max_distance = 1000.,
            effect_on_hit = 'ENTS',
            radius = 75.,
            speed = 800.,
            start_z = 85.,
            end_z = 85.,
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
                volume = 135,
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
        --===============================================--
        NewMissileTemplate('MNWS', {
            name = "wandering missile",
            model = "Effect\\PeeKay's Bonespirit.mdx",
            max_distance = 1000.,
            effect_on_hit = 'ENWS',
            sound_on_destroy = {
                pack = { "Sounds\\Spells\\Bone_Spirit_Imp_1.wav", "Sounds\\Spells\\Bone_Spirit_Imp_2.wav", "Sounds\\Spells\\Bone_Spirit_Imp_3.wav" },
                volume = 95,
                cutoff = 1600.,
            },
            radius = 80.,
            speed = 500.,
            start_z = 80.,
            end_z = 80.,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\Bone_Spirit_Travel_Loop_1.wav", "Sounds\\Spells\\Bone_Spirit_Travel_Loop_2.wav" },
                volume = 145,
                cutoff = 1600.,
                looping = true
            },
            arc = 0.,
            geo_arc = 50,
            geo_arc_length = 225.,
            geo_arc_randomize_angle = true,
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            can_enum = true
        })

        --===============================================--
        NewMissileTemplate('reaper_missile', {
            name = "reaper missile",
            model = "",
            max_distance = 650.,
            radius = 100.,
            speed = 1100.,
            start_z = 50.,
            end_z = 50.,
            arc = 0.,
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            can_enum = true
        })

        NewMissileTemplate('shuriken_missile', {
            name = "shuriken missile",
            model = "Effect\\Shuriken.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 1000.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 0.6,
            effect_on_hit = 'effect_shuriken',
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('dancingblade_missile', {
            name = "dancing blade missile",
            model = "Missile\\GlaiveMissileUpg2.mdx", --"Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdx",
            max_distance = 1000.,
            radius = 80.,
            speed = 500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 1.,
            geo_arc = 45,
            geo_arc_length = 300.,
            geo_arc_randomize_angle = false,
            effect_on_hit = 'effect_dancing_blade',
            max_targets = 3000,
            hit_once_in = 3.,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
        })

        NewMissileTemplate('incendiary_grenade_missile', {
            name = "incendiary grenade missile",
            model = "Missile\\Molotov Coctail(ByPrinceOFFame).mdx",
            max_distance = 500.,
            radius = 80.,
            speed = 900.,
            start_z = 60.,
            end_z = 0.,
            arc = 0.5,
            scale = 1.,
            effect_on_expire = 'incendiary_grenade_effect',
            max_targets = 1,
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('smoke_bomb_missile', {
            name = "smoke bomb missile",
            model = "Abilities\\Spells\\Other\\StrongDrink\\BrewmasterMissile.mdx",
            max_distance = 800.,
            radius = 80.,
            speed = 900.,
            start_z = 60.,
            end_z = 0.,
            arc = 0.5,
            scale = 1.,
            --effect_on_target = 'incendiary_grenade_effect',
            effect_on_expire = 'smoke_bomb_effect',
            max_targets = 1,
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('rocket_missile', {
            name = "rocket missile",
            model = "Missile\\Rocket.mdx",
            max_distance = 1000.,
            radius = 80.,
            speed = 1200.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 1.,
            --effect_on_hit = 'effect_rocket',
            effect_on_expire = 'effect_rocket',
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        --==============================================--
        NewMissileTemplate('precision_arrow', {
            name = "precision salvo arrow missile",
            model = "Missile\\Bloodstone Arrow.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'precision_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('precision_arrow_cold', {
            name = "precision salvo arrow missile",
            model = "Missile\\Bloodstone Arrow_Cold.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'precision_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('precision_arrow_poison', {
            name = "precision salvo arrow missile",
            model = "Missile\\Bloodstone Arrow_Poison.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'precision_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('cluster_arrow', {
            name = "cluster arrow missile",
            model = "Missile\\ExplosiveBolt.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.75,
            effect_on_hit = 'main_cluster_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('cluster_arrow_cold', {
            name = "cluster arrow missile",
            model = "Missile\\ExplosiveBolt_Cold.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.75,
            effect_on_hit = 'main_cluster_arrow_effect',
            effect_on_expire = 'sub_cluster_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('cluster_arrow_poison', {
            name = "cluster arrow missile",
            model = "Missile\\ExplosiveBolt_Poison.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.75,
            effect_on_hit = 'main_cluster_arrow_effect',
            effect_on_expire = 'sub_cluster_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('cluster_sub_arrow', {
            name = "cluster sub arrow missile",
            model = "Missile\\ExplosiveBolt.mdx",
            max_distance = 1000.,
            radius = 100.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.75,
            --effect_on_hit = 'EGFB',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('charged_arrow', {
            name = "charged arrow missile",
            model = "Missile\\ElectricalArrow.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'charged_shot_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('frost_arrow', {
            name = "frost arrow missile",
            model = "Missile\\Azul Arrow.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'frost_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('poison_arrow', {
            name = "poison arrow missile",
            model = "Abilities\\Weapons\\PoisonArrow\\PoisonArrowMissile.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 1.,
            effect_on_hit = 'poison_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('expose_arrow', {
            name = "expose missile",
            model = "Missile\\Daemonic Arrow Classic.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.7,
            effect_on_hit = 'expose_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('expose_arrow_cold', {
            name = "expose missile",
            model = "Missile\\Daemonic Arrow Classic_Cold.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.7,
            effect_on_hit = 'expose_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('expose_arrow_poison', {
            name = "expose missile",
            model = "Missile\\Daemonic Arrow Classic_Poison.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.7,
            effect_on_hit = 'expose_arrow_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('steel_rain_arrow', {
            name = "steel rain arrow missile",
            model = ".mdx",
            max_distance = 1000.,
            radius = 100.,
            speed = 800.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 1.,
            sound_on_fly = {
                pack = { "Sounds\\Spells\\SteelRain_Impacts_1.wav", "Sounds\\Spells\\SteelRain_Impacts_2.wav" },
                volume = 145,
                cutoff = 1600.,
                looping = true
            },
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            max_targets = 3000,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('steel_rain_cast_arrow', {
            name = "steel rain impact arrow missile",
            model = "Missile\\ArrowMissileSoundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 80.,
            end_z = 700.,
            arc = 0.,
            scale = 1.,
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = false
        })
        --==============================================--
        NewMissileTemplate('steel_rain_cast_arrow_poison', {
            name = "steel rain impact arrow missile",
            model = "Missile\\PoisonArrowMissileSoundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 80.,
            end_z = 700.,
            arc = 0.,
            scale = 1.,
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = false
        })
        --==============================================--
        NewMissileTemplate('steel_rain_cast_arrow_cold', {
            name = "steel rain impact arrow missile",
            model = "Missile\\Azul Arrow Soundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 80.,
            end_z = 700.,
            arc = 0.,
            scale = 1.,
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = false
        })
        --==============================================--
        NewMissileTemplate('steel_rain_impact_arrow', {
            name = "steel rain impact arrow missile",
            model = "Missile\\ArrowMissileSoundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 700.,
            end_z = 0.,
            arc = 0.,
            scale = 1.,
            effect_on_impact = "steel_rain_effect",
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = true
        })
        --==============================================--
        NewMissileTemplate('steel_rain_impact_arrow_cold', {
            name = "steel rain impact arrow missile",
            model = "Missile\\Azul Arrow Soundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 700.,
            end_z = 0.,
            arc = 0.,
            scale = 1.,
            effect_on_impact = "steel_rain_effect",
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = true
        })
        --==============================================--
        NewMissileTemplate('steel_rain_impact_arrow_poison', {
            name = "steel rain impact arrow missile",
            model = "Missile\\PoisonArrowMissileSoundless.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1650.,
            start_z = 700.,
            end_z = 0.,
            arc = 0.,
            scale = 1.,
            effect_on_impact = "steel_rain_effect",
            ignore_terrain = false,
            full_distance = false,
            penetrate = false,
            trackable = false,
            only_on_impact = true
        })
        --==============================================--
        NewMissileTemplate('suppression_fire_arrow', {
            name = "supp arrow missile",
            model = "Missile\\SpiritArrow_ByEpsilon.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.9,
            effect_on_hit = 'supp_fire_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('suppression_fire_cold_arrow', {
            name = "supp arrow missile",
            model = "Missile\\SpiritArrow_ByEpsilon_Cold.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.9,
            effect_on_hit = 'supp_fire_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })
        --==============================================--
        NewMissileTemplate('suppression_fire_poison_arrow', {
            name = "supp arrow missile",
            model = "Missile\\SpiritArrow_ByEpsilon_Poison.mdx",
            max_distance = 1000.,
            radius = 75.,
            speed = 1500.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.07,
            scale = 0.9,
            effect_on_hit = 'supp_fire_effect',
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
            trackable = false
        })

        NewMissileTemplate('shuriken_talent_missile', {
            name = "shuriken missile",
            model = "Effect\\Shuriken.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 1000.,
            start_z = 95.,
            end_z = 95.,
            arc = 0.,
            scale = 0.6,
            effect_on_hit = 'effect_talent_shuriken',
            max_targets = 1,
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
            ignore_terrain = false,
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
        NewMissileTemplate('baal_hoarfrost_missile', {
            name = "baal hoarfrost missile",
            model = "Missile\\WindMissle.mdx",
            max_distance = 1000.,
            radius = 100.,
            speed = 1100.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 1.,
            effect_on_hit = 'baal_hoarfrost',
            sound_on_fly = {
                pack = { "Sounds\\Spells\\missile1.wav", "Sounds\\Spells\\missile2.wav", "Sounds\\Spells\\missile3.wav" },
                volume = 128,
                cutoff = 1700.,
                looping = false
            },
            max_targets = 300,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
        })
        NewMissileTemplate('andariel_fire_missile', {
            name = "andariel hellfire missile",
            model = "Effect\\Flame of Darkness.mdx",
            max_distance = 1500.,
            radius = 70.,
            speed = 800.,
            start_z = 10.,
            end_z = 10.,
            arc = 0.,
            scale = 1.,
            max_targets = 300,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
        })
        NewMissileTemplate('baal_nova_missile', {
            name = "baal nova missile",
            model = "Missile\\Firebolt Medium.mdx",
            max_distance = 1000.,
            radius = 80.,
            speed = 900.,
            start_z = 75.,
            end_z = 75.,
            arc = 0.,
            scale = 1.,
            effect_on_hit = 'baal_nova',
            max_targets = 300,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
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
            max_targets = 399,
            can_enum = false,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            only_on_impact = false
        })
        --===============================================--
        NewMissileTemplate('ensnare_missile', {
            name = "snare missile",
            model = "Abilities\\Spells\\Orc\\Ensnare\\EnsnareMissile.mdx",
            max_distance = 600.,
            radius = 75.,
            speed = 900.,
            start_z = 60.,
            end_z = 60.,
            arc = 0.1,
            effect_on_hit = 'gnoll_snare_effect',
            max_targets = 1,
            ignore_terrain = true,
            full_distance = true,
            penetrate = false,
        })
        --===============================================--
        NewMissileTemplate('lightning_breath_missile', {
            name = "lightning_breath_missile",
            model = "",
            max_distance = 800.,
            radius = 100.,
            speed = 900.,
            start_z = 0.,
            end_z = 0.,
            effect_on_hit = 'lightning_breath_effect',
            max_targets = 500,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
        })
        --==============================================--
        NewMissileTemplate('flying_rune', {
            name = "rune missile",
            model = "Objects\\InventoryItems\\runicobject\\runicobject.mdx",
            speed = 725.,
            start_z = 85.,
            end_z = 0.,
            arc = 0.4,
            scale = 1.,
            only_on_impact = true,
            ignore_terrain = false,
            can_enum = false
        })
        --==============================================--
        NewMissileTemplate('flying_rune_mp', {
            name = "rune missile",
            model = "Objects\\InventoryItems\\runicobject\\runicobject.mdx",
            speed = 725.,
            start_z = 85.,
            end_z = 0.,
            arc = 0.4,
            scale = 1.,
            only_on_impact = true,
            ignore_terrain = false,
            can_enum = false
        })
        --===============================================--
        NewMissileTemplate('pitlord_darkness_missile', {
            name = "pitlord darkness missile",
            model = "Missile\\DarknessBomb.mdx",
            max_distance = 1200.,
            radius = 70.,
            speed = 900.,
            start_z = 70.,
            end_z = 70.,
            effect_on_hit = "pitlord_darkness_bolt",
            max_targets = 300,
            hit_once_in = 0.25,
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            can_enum = false
        })
    end

end
