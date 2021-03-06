---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 05.07.2021 22:01
---
do



    local Locations = {}
    local PlayerLocation = {}
    LOCATION_CASTLE = 1
    LOCATION_MAINROAD = 2



    ---@param region region
    function GetNewLocation(region)
        for i = 1, #Locations do
            for k = 1, #Locations[i].regions do
                if Locations[i].regions[k] == region then
                    return i
                end
            end
        end
        return 0
    end


    function EnterLocFilter()
        return IsAHero(GetTriggerUnit())
    end

    function InitLocations()
        local LocationChangeTrigger = CreateTrigger()

        for i = 1, 6 do
            PlayerLocation[i] = {
                location = 0,
                timer = CreateTimer(),
                frame = BlzCreateFrameByType("BACKDROP", "loc name", GAME_UI, "", 0)
            }
            BlzFrameSetVisible(PlayerLocation[i].frame, false)
            BlzFrameSetAbsPoint(PlayerLocation[i].frame, FRAMEPOINT_CENTER, 0.4, 0.5)
            BlzFrameSetSize(PlayerLocation[i].frame, 0.8, 0.44)
            BlzFrameSetScale(PlayerLocation[i].frame, 0.57)
        end

        Locations[1] = {
            rects = { gg_rct_loc_castle_1, gg_rct_loc_castle_2, gg_rct_loc_castle_3, gg_rct_loc_castle_4, gg_rct_loc_castle_5, gg_rct_loc_castle_6, gg_rct_loc_castle_7, gg_rct_loc_castle_8, gg_rct_loc_castle_9 },
            regions = {},
            name = LOCALE_LIST[my_locale].CASTLE_LOCATION_TEXTURE
        }
        Locations[2] = {
            rects = { gg_rct_loc_mainroad_1, gg_rct_loc_mainroad_2, gg_rct_loc_mainroad_3, gg_rct_loc_mainroad_4, gg_rct_loc_mainroad_5, },
            regions = {},
            name = LOCALE_LIST[my_locale].MAINROAD_LOCATION_TEXTURE
        }
        Locations[3] = {
            rects = { gg_rct_loc_wild_forest_1, gg_rct_loc_wild_forest_2, gg_rct_loc_wild_forest_3 },
            regions = {},
            name = LOCALE_LIST[my_locale].WILDFOREST_LOCATION_TEXTURE
        }
        Locations[4] = {
            rects = { gg_rct_loc_narrowpass_1, gg_rct_loc_narrowpass_2, gg_rct_loc_narrowpass_3, gg_rct_loc_narrowpass_4 },
            regions = {},
            name = LOCALE_LIST[my_locale].NARROWPASS_LOCATION_TEXTURE
        }
        Locations[5] = {
            rects = { gg_rct_loc_outskirts_1, gg_rct_loc_outskirts_2, gg_rct_loc_outskirts_3, gg_rct_loc_outskirts_4, gg_rct_loc_outskirts_5 },
            regions = {},
            name = LOCALE_LIST[my_locale].OUTSKIRTS_LOCATION_TEXTURE
        }
        Locations[6] = {
            rects = { gg_rct_loc_sacredgrove_1 },
            regions = {},
            name = LOCALE_LIST[my_locale].SACREDGROVE_LOCATION_TEXTURE
        }
        Locations[7] = {
            rects = { gg_rct_loc_meadows_1, gg_rct_loc_meadows_2, gg_rct_loc_meadows_3, gg_rct_loc_meadows_4, gg_rct_loc_meadows_5 },
            regions = {},
            name = LOCALE_LIST[my_locale].MEADOWS_LOCATION_TEXTURE
        }


        for i = 1, #Locations do
            for k = 1, #Locations[i].rects do
                Locations[i].regions[k] = CreateRegion()
                RegionAddRect(Locations[i].regions[k], Locations[i].rects[k])
                TriggerRegisterEnterRegion(LocationChangeTrigger, Locations[i].regions[k], nil)
            end
        end


        TriggerAddAction(LocationChangeTrigger, function()
            if IsAHero(GetTriggerUnit()) then
                local player = GetOwningPlayer(GetTriggerUnit())
                local new_location = GetNewLocation(GetTriggeringRegion())
                local player_location = PlayerLocation[GetPlayerId(GetOwningPlayer(GetTriggerUnit())) + 1]

                    if player_location.location ~= new_location then
                        player_location.location = new_location
                        BlzFrameSetAlpha(player_location.frame, 255)
                        BlzFrameSetVisible(player_location.frame, GetLocalPlayer() == player)
                        BlzFrameSetTexture(player_location.frame, Locations[new_location].name, 0, true)
                        --BlzFrameSetText(player_location.frame, Locations[new_location].name)
                        PlayLocalSound("Sound\\quest_done_3.wav", GetPlayerId(GetOwningPlayer(GetTriggerUnit())), 110)
                        local alpha = 255
                        local delta = math.floor(255 / (3 / 0.05))
                        TimerStart(player_location.timer, 3., false, function()
                            TimerStart(player_location.timer, 0.05, true, function()
                                alpha = alpha - delta
                                BlzFrameSetAlpha(player_location.frame, alpha)
                                if alpha < 0 then
                                    TimerStart(player_location.timer, 0., false, nil)
                                    BlzFrameSetVisible(player_location.frame, false)
                                end
                            end)
                        end)
                    end

            end
        end)

    end

end