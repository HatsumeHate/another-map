do



    local function ConfigureSound(sound, volume, cutoff)
        SetSoundChannel(sound, 5)
        SetSoundVolume(sound, volume or 128)
        SetSoundPitch(sound, 1)
        SetSoundDistances(sound, 600., 10000.)
        SetSoundDistanceCutoff(sound, 99999999999999999.)
        TimerStart(CreateTimer(), 0.000, false, function()
            SetSoundDistanceCutoff(sound, cutoff or 2100.)
            DestroyTimer(GetExpiredTimer())
        end)
        SetSoundConeAngles(sound, 0.0, 0.0, 127)
        SetSoundConeOrientation(sound, 0.0, 0.0, 0.0)
    end


    ---@param name string
    ---@param x real
    ---@param y real
    ---@param z real
    ---@param volume integer
    ---@param cutoff real
    function CreateNew3DSound(name, x, y, z, volume, cutoff, loop)
        local snd = CreateSound(name, loop or false, true, false, 100, 100, "CombatSoundsEAX")

            ConfigureSound(snd, volume, cutoff)
            SetSoundPosition(snd, x, y, z)

        return snd
    end


    ---@param name string
    ---@param player_id integer
    function PlayLocalSound(name, player_id, volume)
        local snd = CreateSound(name, false, false, false, 10, 10, "")

            SetSoundChannel(snd, 5)
            if GetLocalPlayer() ~= Player(player_id) then SetSoundVolume(snd, 0) else SetSoundVolume(snd, volume or 128) end
            SetSoundPitch(snd, 1)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end


    ---@param name string
    ---@param volume integer
    function Play2DSound(name, volume)
        local snd = CreateSound(name, false, false, false, 10, 10, "")

            SetSoundChannel(snd, 5)
            SetSoundVolume(snd, volume or 128)
            SetSoundPitch(snd, 1)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end


    ---@param soundpack table
    ---@param fadetime real
    function DestroyLoopingSound(soundpack, fadetime)

        if soundpack.fading ~= nil or soundpack == nil then return
        else soundpack.fading = true end

        if fadetime <= 0. then soundpack.current_volume = 0. end

        fadetime = fadetime / 0.025

            TimerStart(CreateTimer(), 0.025, true, function()
                soundpack.current_volume = soundpack.current_volume - (soundpack.volume_max / fadetime)

                    if soundpack.current_volume <= 0 then
                        DestroyTimer(soundpack.loop_timer)
                        DestroyTimer(soundpack.fadeout_timer)
                        DestroyTimer(GetExpiredTimer())
                        StopSound(soundpack.current_sound, true, true)
                    end

                SetSoundVolume(soundpack.current_sound, soundpack.current_volume)
            end)

    end



    local function FadeSound(sound, soundpack, fadetime, vector)
        local step = soundpack.volume_max / (fadetime / 0.025)
        if not vector then step = -step end
        local volume = vector and 0 or soundpack.current_volume


            TimerStart(CreateTimer(), 0.025, true, function()
                volume = volume + step

                    if volume <= 0 and not vector then
                        DestroyTimer(GetExpiredTimer())
                        volume = 0
                        StopSound(sound, true, true)
                    elseif volume >= soundpack.current_volume and vector or soundpack.fading ~= nil then
                        volume = soundpack.current_volume
                        DestroyTimer(GetExpiredTimer())
                    end

                SetSoundVolume(sound, R2I(volume))
            end)

    end

    ---@param soundpack table
    ---@param volume integer
    ---@param cutoff real
    ---@param fadein_offset integer
    ---@param fadeout_offset integer
    ---@param delay real
    ---@param target unit
    function AddLoopingSoundOnUnit(soundpack, target, fadein_offset, fadeout_offset, delay, volume, cutoff)
        soundpack.loop_timer = CreateTimer()

        soundpack.volume_max = volume
        soundpack.current_volume = volume
        fadein_offset  = fadein_offset * 0.001
        fadeout_offset  = fadeout_offset * 0.001

            local function loop_sound()
                local sound_file

                    if #soundpack == 1 then sound_file = soundpack[1]
                    else sound_file = soundpack[GetRandomInt(1, #soundpack)] end


                soundpack.current_sound = CreateSound(sound_file, false, true, false, 150, 150, "CombatSoundsEAX")
                ConfigureSound(soundpack.current_sound, 1, cutoff)
                if fadein_offset > 0 then SetSoundVolume(soundpack.current_sound, 0)
                else SetSoundVolume(soundpack.current_sound, soundpack.current_volume) end


                AttachSoundToUnit(soundpack.current_sound, target)
                StartSound(soundpack.current_sound)

                FadeSound(soundpack.current_sound, soundpack, fadein_offset, true)


                local sound_duration = (GetSoundDuration(soundpack.current_sound) * 0.001)

                local mysound = soundpack.current_sound
                soundpack.fadeout_timer = CreateTimer()
                TimerStart(soundpack.fadeout_timer, sound_duration - fadeout_offset, false, function()
                    FadeSound(mysound, soundpack, fadeout_offset, false)
                    DestroyTimer(soundpack.fadeout_timer)
                end)

                TimerStart(soundpack.loop_timer, sound_duration + delay, false, loop_sound)
            end


        loop_sound()
        return soundpack
    end

    ---@param soundpack table
    ---@param x real
    ---@param y real
    ---@param z real
    ---@param volume integer
    ---@param cutoff real
    ---@param fadein_offset integer
    ---@param fadeout_offset integer
    ---@param delay real
    function AddLoopingSound(soundpack, x, y, z, fadein_offset, fadeout_offset, delay, volume, cutoff)
        soundpack.loop_timer = CreateTimer()

        soundpack.volume_max = volume
        soundpack.current_volume = volume
        fadein_offset  = fadein_offset * 0.001
        fadeout_offset  = fadeout_offset * 0.001


            local function loop_sound()
                local sound_file

                if #soundpack == 1 then sound_file = soundpack[1]
                else sound_file = soundpack[GetRandomInt(1, #soundpack)] end


                soundpack.current_sound = CreateSound(sound_file, false, true, false, 150, 150, "CombatSoundsEAX")
                ConfigureSound(soundpack.current_sound, 1, cutoff)
                if fadein_offset > 0 then SetSoundVolume(soundpack.current_sound, 0)
                else SetSoundVolume(soundpack.current_sound, soundpack.current_volume) end

                SetSoundPosition(soundpack.current_sound, x, y, z)
                StartSound(soundpack.current_sound)

                FadeSound(soundpack.current_sound, soundpack, fadein_offset, true)


                local sound_duration = (GetSoundDuration(soundpack.current_sound) * 0.001)

                local mysound = soundpack.current_sound
                soundpack.fadeout_timer = CreateTimer()
                TimerStart(soundpack.fadeout_timer, sound_duration - fadeout_offset, false, function()
                    FadeSound(mysound, soundpack, fadeout_offset, false)
                    DestroyTimer(soundpack.fadeout_timer)
                end)

                TimerStart(soundpack.loop_timer, sound_duration + delay, false, loop_sound)
            end


        loop_sound()
        return soundpack
    end


    ---@param s string
    ---@param x real
    ---@param y real
    function AddSound(s, x, y)
        local snd = CreateSound(s, false, true, true, 10, 10, "CombatSoundsEAX")

            ConfigureSound(snd, 128, 2100.)
            SetSoundPosition(snd, x, y, 35.)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end

    ---@param s string
    ---@param x real
    ---@param y real
    ---@param vol integer
    ---@param cutoff real
    function AddSoundVolume(s, x, y, vol, cutoff)
        local snd = CreateSound(s, false, true, true, 10, 10, "CombatSoundsEAX")

            ConfigureSound(snd, vol or 128, cutoff or 2100.)
            SetSoundPosition(snd, x, y, 35.)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end

    ---@param s string
    ---@param x real
    ---@param y real
    ---@param z real
    ---@param vol integer
    ---@param cutoff real
    function AddSoundVolumeZ(s, x, y, z, vol, cutoff)
        local snd = CreateSound(s, false, true, false, 10, 10, "CombatSoundsEAX") --CombatSoundsEAX

            ConfigureSound(snd, vol or 128, cutoff or 2100.)
            SetSoundPosition(snd, x, y, z)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end

    ---@param s string
    ---@param x real
    ---@param y real
    ---@param z real
    ---@param vol integer
    ---@param cutoff real
    ---@param player integer
    function AddSoundForPlayerVolumeZ(s, x, y, z, vol, cutoff, player)
        local snd = CreateSound(s, false, true, false, 10, 10, "CombatSoundsEAX") --CombatSoundsEAX

            SetSoundChannel(snd, 5)
            if GetLocalPlayer() == Player(player) then SetSoundVolume(snd, vol or 128) else SetSoundVolume(snd, 0) end
            SetSoundPitch(snd, 1)
            SetSoundDistances(snd, 600., 10000.)
            SetSoundDistanceCutoff(snd, cutoff or 2100.)
            SetSoundConeAngles(snd, 0.0, 0.0, 127)
            SetSoundConeOrientation(snd, 0.0, 0.0, 0.0)
            SetSoundPosition(snd, x, y, z)
            StartSound(snd)
            KillSoundWhenDone(snd)

        return snd
    end



end