---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 14.02.2021 17:38
---
do

    PlayerQuartermeisterFrame = nil


    
    ---@param player number
    function DrawQuartermeisterFrames(player)
        if true then return end
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            --print("player number is " .. player)
            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOP, GAME_UI, FRAMEPOINT_TOP, 0., -0.06)
            BlzFrameSetSize(main_frame, 0.56, 0.35)
            --RegisterConstructor(main_frame, 0.4, 0.38)


            PlayerQuartermeisterFrame[player] = main_frame
            BlzFrameSetVisible(PlayerQuartermeisterFrame[player], false)


            RegisterTestCommand("Gt", function ()
                BlzFrameSetVisible(PlayerQuartermeisterFrame[1], true)
            end)

            RegisterTestCommand("Gf", function ()
                BlzFrameSetVisible(PlayerQuartermeisterFrame[1], false)
            end)

    end




end




