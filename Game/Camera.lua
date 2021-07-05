---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Stasik.
--- DateTime: 01.04.2020 7:40
---
do



    PlayerCameraState = {}
    PlayerCameraSetup = {}





    function LockCameraForPlayer(player_id)
        PlayerCameraState[player_id] = true
        CameraSetupSetDestPosition(PlayerCameraSetup[player_id], GetUnitX(PlayerHero[player_id]) + Rx(150., GetUnitFacing(PlayerHero[player_id])), GetUnitY(PlayerHero[player_id]) + Ry(150., GetUnitFacing(PlayerHero[player_id])), 0.01)
    end


    function InitPlayerCamera()

        for i = 1, 6 do
            PlayerCameraSetup[i] = CreateCameraSetup()
            CameraSetupSetField(PlayerCameraSetup[i], CAMERA_FIELD_ANGLE_OF_ATTACK, 304., 0.)
            CameraSetupSetField(PlayerCameraSetup[i], CAMERA_FIELD_TARGET_DISTANCE, 1650., 0.)
            CameraSetupSetField(PlayerCameraSetup[i], CAMERA_FIELD_ROTATION, 90., 0.)
            CameraSetupSetField(PlayerCameraSetup[i], CAMERA_FIELD_FIELD_OF_VIEW, 70., 0.)
            CameraSetupSetField(PlayerCameraSetup[i], CAMERA_FIELD_FARZ, 5000., 0.)
        end


        TimerStart(CreateTimer(), 0.03, true, function ()

            for i = 1, 6 do
                if PlayerCameraState[i] then
                    CameraSetupSetDestPosition(PlayerCameraSetup[i], GetUnitX(PlayerHero[i]) + Rx(90., GetUnitFacing(PlayerHero[i])), GetUnitY(PlayerHero[i]) + Ry(90., GetUnitFacing(PlayerHero[i])), 0.12)
                    if GetLocalPlayer() == Player(i-1) then
                        BlzCameraSetupApplyForceDurationSmooth(PlayerCameraSetup[i], true, 0.12, 2.46, 2.46, 1.25)
                    end
                end
            end

        end)

        RegisterTestCommand("cam", function ()
            PlayerCameraState[1] = false
        end)

    end

end