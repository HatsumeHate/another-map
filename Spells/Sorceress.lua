do




     function SparkMovement (missile, angle, timer)
        if missile ~= nil then
            print("REDIRECT START")
            print(missile.name)
            print(angle)
            print(timer)
            print("=========")
            print(missile.current_x)
            print(missile.current_y)
            print(missile.current_z)
            print("=========")
            RedirectMissile_Deg(missile, angle + GetRandomReal(-15., 15.))
            print("REDIRECT ????")
            TimerStart(timer, GetRandomReal(0.25, 0.55), false, SparkMovement)
            print("REDIRECT END")
        else
            DestroyTimer(timer)
        end
    end


end


