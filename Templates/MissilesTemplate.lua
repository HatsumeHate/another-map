do

    MissileList = {}

    function GetMissileData(id)
        return MissileList[FourCC(id)]
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

            sound_on_hit = {},
            sound_on_launch = {},
            sound_on_destroy = {},

            effect_on_impact = nil,
            effect_on_hit = nil,
            effect_on_expire = nil,

            radius = 0.,
            max_distance = 0.,
            full_distance = false,
            speed = 0.,
            scale = 1.,

            max_targets = 1,
            hit_once_in = 0.,

            start_z = 0.,
            end_z = 0.,
            arc = 0.,

            revert = false,
            trackable = false,

            only_on_target = false,
            only_on_impact = false,
            penetrate = false,
            ignore_terrain = false

        }

        --real MissileOffset


        MergeTables(new_missile, missile_reference)
        MissileList[FourCC(id)] = new_missile
    end
    
    
    function DefineMissilesData()
        
        NewMissileTemplate('M001', {
            name = "test missile",
            model = "Abilities\\Spells\\Other\\FrostBolt\\FrostBoltMissile.mdx",
            max_distance = 1000.,
            radius = 50.,
            speed = 400.,
            start_z = 35.,
            end_z = 35.,
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

        NewMissileTemplate('MFRB', {
            name = "frostbolt missile",
            model = "Spell\\Blizzard II Missile.mdx",
            max_distance = 1000.,
            radius = 70.,
            speed = 800.,
            start_z = 35.,
            end_z = 35.,
            arc = 0.,
            scale = 0.8,
            effect_on_hit = 'EFRB',
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
            start_z = 35.,
            end_z = 35.,
            arc = 0.,
            scale = 0.8,
            effect_on_hit = 'EGFB',
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
            start_z = 35.,
            end_z = 35.,
            arc = 0.,
            scale = 1.45,
            max_targets = 300,
            hit_once_in = 0.25,
            effect_on_expire = 'EFRO',
            effect_on_hit = 'EFOA',
            ignore_terrain = true,
            full_distance = true,
            penetrate = true,
            trackable = false
        })

    end

end
