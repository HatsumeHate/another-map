---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 09.05.2021 17:37
---
do


    local CitizenGroup
    local CitizenZones = {}

    function SpawnCitizens(rect, min, max)
        for i = 1, GetRandomInt(min, max) do
            if Chance(65.) then
                if Chance(50.) then
                    bj_lastCreatedUnit = CreateUnit(Player(8), FourCC('n00H'), GetRandomRectX(rect), GetRandomRectY(rect), GetRandomReal(0, 360.))
                    GroupAddUnit(CitizenGroup, bj_lastCreatedUnit)
                else
                    bj_lastCreatedUnit = CreateUnit(Player(8), FourCC('n00G'), GetRandomRectX(rect), GetRandomRectY(rect), GetRandomReal(0, 360.))
                    GroupAddUnit(CitizenGroup, bj_lastCreatedUnit)
                end
            else
                bj_lastCreatedUnit = CreateUnit(Player(8), FourCC('n00F'), GetRandomRectX(rect), GetRandomRectY(rect), GetRandomReal(0, 360.))
                GroupAddUnit(CitizenGroup, bj_lastCreatedUnit)
            end
        end
    end


    local function GetRandomRect(region_index)
        return CitizenZones[region_index][GetRandomInt(1, #CitizenZones[region_index])]
    end


    local function MapRegion(index)
        CitizenZones[index].region = CreateRegion()
        for i = 1, #CitizenZones[index] do
            RegionAddRect(CitizenZones[index].region, CitizenZones[index][i])
        end
    end


    function ToggleCitizens(state)
        ForGroup(CitizenGroup, function()
            ShowUnit(GetEnumUnit(), state)
        end)
    end


    function InitVillageData()
        local timer = CreateTimer()
        TimerStart(timer,1.,false, function()
            CitizenGroup = CreateGroup()

            --print("group yep")
            CitizenZones[1] = {
                [1] = gg_rct_citizen_bottom_1,
                [2] = gg_rct_citizen_bottom_2,
                [3] = gg_rct_citizen_bottom_3
            }

            MapRegion(1)
            SpawnCitizens(gg_rct_citizen_bottom_1, 3, 5)

            --################################################################
            CitizenZones[2] = {
                [1] = gg_rct_citizen_center_1,
                [2] = gg_rct_citizen_center_2,
                [3] = gg_rct_citizen_center_3,
                [4] = gg_rct_citizen_center_4,
                [5] = gg_rct_citizen_center_5
            }

            MapRegion(2)
            SpawnCitizens(gg_rct_citizen_center_1, 4, 5)

            --################################################################
            CitizenZones[3] = {
                [1] = gg_rct_citizen_ruins_1,
                [2] = gg_rct_citizen_ruins_2,
                [3] = gg_rct_citizen_ruins_3,
                [4] = gg_rct_citizen_ruins_4,
                [5] = gg_rct_citizen_ruins_5,
                [6] = gg_rct_citizen_ruins_6,
                [7] = gg_rct_citizen_ruins_7,
                [8] = gg_rct_citizen_ruins_8
            }

            MapRegion(3)
            SpawnCitizens(gg_rct_citizen_ruins_1, 2, 4)

            --################################################################

            local timer = CreateTimer()
            TimerStart(timer, 1.5, true, function()

                ForGroup(CitizenGroup, function()
                    if Chance(12.) and GetUnitCurrentOrder(GetEnumUnit()) == 0 and not IsUnitHidden(GetEnumUnit()) then
                        for i = 1, #CitizenZones do
                            if IsUnitInRegion(CitizenZones[i].region, GetEnumUnit()) then
                                local my_rect = GetRandomRect(i)
                                IssuePointOrderById(GetEnumUnit(), order_move, GetRandomRectX(my_rect), GetRandomRectY(my_rect))
                                my_rect = nil
                            end
                        end
                    end
                end)
            end)

            DestroyTimer(GetExpiredTimer())
        end)
    end

end