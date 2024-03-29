---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hatsu.
--- DateTime: 18.05.2023 21:08
---
do


    GiftList = nil


    function GetGiftEffectData(id)
        return GiftList[id]
    end

    function NewGiftEffect(template)
        GiftList[template.id] = template
    end



    function InitGifts()
        GiftList = {}

        NewGiftEffect({
            id = "screaming_mask_gift",
            max_level = 3,
            waves_duration = 4,
            activation_effect = ScreamingMaskActivationEffect,
            deactivation_effect = ScreamingMaskDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "bonechimes_gift",
            max_level = 3,
            waves_duration = 5,
            activation_effect = BoneChimesActivationEffect,
            deactivation_effect = BoneChimesDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "demonic_horn_gift",
            max_level = 3,
            waves_duration = 2,
            activation_effect = DemonicHornActivationEffect,
            deactivation_effect = DemonicHornDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "hearth_of_ghor_gift",
            max_level = 3,
            waves_duration = 3,
            activation_effect = HearthGhorActivationEffect,
            deactivation_effect = HearthGhorDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "moon_stone_gift",
            max_level = 3,
            waves_duration = 2,
            activation_effect = MoonStoneActivationEffect,
            deactivation_effect = MoonStoneDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "sword_of_a_hero_gift",
            max_level = 3,
            waves_duration = 2,
            activation_effect = SwordofaHeroActivationEffect,
            deactivation_effect = SwordofaHeroDeactivationEffect
        })
        --==================================================================
        NewGiftEffect({
            id = "forest_ward_gift",
            max_level = 3,
            waves_duration = 2,
            activation_effect = ForestWardActivationEffect,
            deactivation_effect = ForestWardDeactivationEffect
        })
    end
    
end 