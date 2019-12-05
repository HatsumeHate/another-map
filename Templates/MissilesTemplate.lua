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

            effect_on_target_point = "",
            effect_on_target = "",
            effect_on_loc = "",

            sound_on_hit = {},
            sound_on_launch = {},

            radius = 0.,
            max_distance = 0.,
            full_distance = false,
            speed = 0.,
            scale = 1.,

            max_targets = 1,

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
            start_z = 65.,
            end_z = 65.,
            arc = 0.1,
            ignore_terrain = true,
            full_distance = true,
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
            full_distance = true
        })
        
    end

end
