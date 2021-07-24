do

    Weather_Current = 0
    WEATHER_WIND_LIGHT = 1
    WEATHER_WIND_HEAVY = 2
    WEATHER_RAIN_LIGHT = 3
    WEATHER_RAIN_HEAVY = 4
    WEATHER_MOONLIGHT = 5
    WEATHER_SUNLIGHT = 6

    WeatherList = {
        [WEATHER_WIND_LIGHT]    = { id = 'WOlw', min_time = 15., max_time = 55., key = 75 },
        [WEATHER_WIND_HEAVY]    = { id = 'WOcw', min_time = 15., max_time = 45., key = 95 },
        [WEATHER_RAIN_LIGHT]    = { id = 'RAlr', min_time = 15., max_time = 85., key = 65, volume = 40 },
        [WEATHER_RAIN_HEAVY]    = { id = 'RLhr', min_time = 15., max_time = 85., key = 45, volume = 65 },
        [WEATHER_MOONLIGHT]     = { id = 'LRma', min_time = 12., max_time = 27., key = 45 },
        [WEATHER_SUNLIGHT]      = { id = 'LRaa', min_time = 15., max_time = 45., key = 55 }
    }

    local MAX_PLAYERS = 6
    local LIGHTNING_KEY = 50
    local RainSound
    local LIGHTNING_MODEL = "Weather Lightnings.mdx"
    local GENERATOR_BLOCK_VALUE = 1536.
    local CREATION_UPDATE = 0.03
    local AREA
    local DurationTimer
    local CreationTimer
    local SpecialTimer
    local RectList = {}
    local Showed = {}



    local function PreloadSound(s)
        local snd = CreateSound(s,false,true,true,10,10,"CombatSoundsEAX")
            SetSoundChannel(snd,5)
            SetSoundVolume(snd, 0)
            SetSoundPitch(snd, 1)
            SetSoundDistances(snd,999999,99999)
            SetSoundDistanceCutoff(snd,99999)
            SetSoundConeAngles(snd,0.0,0.0,127)
            SetSoundConeOrientation(snd,0.0,0.0,0.0)
            SetSoundPosition(snd,0.0,0.0,50.0)
            StartSound(snd)
            KillSoundWhenDone(snd)
        snd = nil
    end

    local function AddSound(s, x, y)
        local snd = CreateSound(s, false, true, true, 10, 10, "CombatSoundsEAX")
            SetSoundChannel(snd, 5)
            SetSoundVolume(snd, 127)
            --local timer = CreateTimer()
            --TimerStart(timer, GetSoundDuration() * 0.001, false, function()
               --StopSound(snd, true, false)
                --DestroyTimer(GetExpiredTimer())
           -- end)
            SetSoundPitch(snd, 1)
            SetSoundDistances(snd, 600., 10000.)
            SetSoundDistanceCutoff(snd, 2100.)
            SetSoundConeAngles(snd, 0.0, 0.0, 127)
            SetSoundConeOrientation(snd, 0.0, 0.0, 0.0)
            SetSoundPosition(snd, x, y, 50.)
            StartSound(snd)
            KillSoundWhenDone(snd)
        snd = nil
    end





    local function StartLocalSound(volume)
        StartSound(RainSound)
        SetSoundVolume(RainSound, volume)
    end


    local function Visibility(weather)
        for i = 0, MAX_PLAYERS do
            if GetLocalPlayer() == Player(i) then
                EnableWeatherEffect(weather, Showed[i])
            end
        end
    end


    local CurrentWeatherRectIndex = 0
    local function WeatherRectGeneration()

        CurrentWeatherRectIndex = CurrentWeatherRectIndex + 1

            if RectList[CurrentWeatherRectIndex].weather ~= nil then
                RemoveWeatherEffect(RectList[CurrentWeatherRectIndex].weather)
            end

            RectList[CurrentWeatherRectIndex].weather = AddWeatherEffect(RectList[CurrentWeatherRectIndex].rect, FourCC(WeatherList[Weather_Current].id))
            EnableWeatherEffect(RectList[CurrentWeatherRectIndex].weather, true)
            --Visibility(RectList[CurrentWeatherRectIndex].weather)
            --EnableWeatherEffect(RectList[CurrentWeatherRectIndex].weather, true)

        if CurrentWeatherRectIndex == #RectList then
            TimerStart(CreationTimer, 0., false, nil)
        end
    end


    local function DestroyWeatherOnRects()
        EnableWeatherEffect(RectList[CurrentWeatherRectIndex].weather, false)
        RemoveWeatherEffect(RectList[CurrentWeatherRectIndex].weather)
        RectList[CurrentWeatherRectIndex].weather = nil
        CurrentWeatherRectIndex = CurrentWeatherRectIndex - 1

        if CurrentWeatherRectIndex == 0 then
            TimerStart(CreationTimer, 0., false, nil)
            --PauseTimer(CreationTimer)
            Weather_Current = 0
        end

    end



    function ToggleForPlayer(player, show)
        Showed[player] = show

        local is_local_player = GetLocalPlayer() == Player(player)

            for k = 1, #RectList do
                if is_local_player then
                    EnableWeatherEffect(RectList[k].weather, show)
                end
            end

        if WeatherList[Weather_Current].volume ~= nil then
            if show then
                if is_local_player then
                    StartSound(RainSound)
                    SetSoundVolume(RainSound, WeatherList[Weather_Current].volume)
                end
            else
                if is_local_player then
                    StopSound(RainSound, false, true)
                end
            end
        end

    end


    function StopWeather()
        --Weather_Current = 0
        --PauseTimer(CreationTimer)
       -- PauseTimer(SpecialTimer)
        TimerStart(CreationTimer, 0., false, nil)
        TimerStart(SpecialTimer, 0., false, nil)
        StopSound(RainSound, false, true)
        TimerStart(CreationTimer, CREATION_UPDATE, true, DestroyWeatherOnRects)
    end


    local function LightningEffectUpdate()
        local key = GetRandomInt(1, LIGHTNING_KEY)
            if key <= 3 then
                local x = GetRandomReal(GetRectMinX(AREA) ,GetRectMaxX(AREA))
                local y = GetRandomReal(GetRectMinY(AREA), GetRectMaxY(AREA))

                if key == 1 then
                    --GetPlayersInRange(x, y, 1900.)
                    --LightningFilter(0.5, 170)
                    AddSound("Thunder Low.wav", x, y)
                elseif key == 2 then
                    --GetPlayersInRange(x, y, 1900.)
                    --LightningFilter(0.75, 205)
                    AddSound("Thunder Normal.wav", x, y)
                elseif key == 3 then
                    --GetPlayersInRange(x, y, 1900.)
                    --LightningFilter(1., 235)
                    bj_lastCreatedEffect = AddSpecialEffect(LIGHTNING_MODEL, x, y)
                    BlzPlaySpecialEffect(bj_lastCreatedEffect, ANIM_TYPE_STAND)
                    DestroyEffect(bj_lastCreatedEffect)
                    AddSound("Thunder High.wav", x, y)
                end

            end
    end

    function StartWeather(weather_id)
        Weather_Current = weather_id
        TimerStart(DurationTimer, GetRandomReal(WeatherList[weather_id].min_time + 3., WeatherList[weather_id].max_time), false, StopWeather)

        if WeatherList[weather_id].volume then
            TimerStart(SpecialTimer, 0.05, true, LightningEffectUpdate)
        end

        TimerStart(CreationTimer, 0., false, nil)
        CurrentWeatherRectIndex = 0
        TimerStart(CreationTimer, CREATION_UPDATE, true, WeatherRectGeneration)
    end


    local function WeatherUpdate()
        local daytime = GetFloatGameState(GAME_STATE_TIME_OF_DAY)

        if Weather_Current == WEATHER_SUNLIGHT then
            if daytime < 9. or daytime > 18. then StopWeather() end
        elseif Weather_Current == WEATHER_MOONLIGHT then
            if daytime < 21. and daytime > 4. then StopWeather() end
        end

        if Weather_Current == 0 then
            for i = 1, #WeatherList do
                if GetRandomInt(1, WeatherList[i].key) == 1 then
                    if i == WEATHER_MOONLIGHT and (daytime >= 21. and daytime <= 4.) then
                        StartWeather(i)
                    elseif i == WEATHER_SUNLIGHT and (daytime >= 9. or daytime <= 18.) then
                        StartWeather(i)
                    else
                        StartWeather(i)

                            if WeatherList[i].volume then
                                StartSound(RainSound)
                                SetSoundVolume(RainSound, WeatherList[i].volume)
                                --StartLocalSound(WeatherList[i].volume)
                            end

                    end
                    break
                end
            end
        end

    end





    local X_BLOCKS
    local Y_BLOCKS
    local TOTAL_Y_BLOCKS


    function InitWeather(area)

        --if true then return end

        RainSound = CreateSound("rain.wav", true, false, false, 100, 100, "")
        DurationTimer = CreateTimer()
        CreationTimer = CreateTimer()
        SpecialTimer = CreateTimer()
        AREA = area
        X_BLOCKS = R2I((GetRectMaxX(AREA) - GetRectMinX(AREA)) / GENERATOR_BLOCK_VALUE) + 1
        Y_BLOCKS = R2I((GetRectMaxY(AREA) - GetRectMinY(AREA)) / GENERATOR_BLOCK_VALUE) + 1
        TOTAL_Y_BLOCKS = Y_BLOCKS

        for i = 0, MAX_PLAYERS do
            Showed[i] = true
        end

        local timer = CreateTimer()
        TimerStart(timer, CREATION_UPDATE, true, function()
            local start_x = GetRectMinX(AREA)
            local start_y = GetRectMaxY(AREA)
            local x = 0
            local max_rect_x
            local max_rect_y
            local min_rect_y


                while (x <= X_BLOCKS) do

                    max_rect_x = start_x + (GENERATOR_BLOCK_VALUE * x)
                    max_rect_y = start_y - (GENERATOR_BLOCK_VALUE * (TOTAL_Y_BLOCKS - Y_BLOCKS))
                    min_rect_y = max_rect_y - GENERATOR_BLOCK_VALUE

                    if max_rect_x > GetRectMaxX(AREA) then max_rect_x = GetRectMaxX(AREA) end
                    if min_rect_y < GetRectMinY(AREA) then min_rect_y = GetRectMinY(AREA) end


                    if not (max_rect_x <= max_rect_x - GENERATOR_BLOCK_VALUE or min_rect_y >= max_rect_y) then
                        RectList[#RectList + 1] = {}
                        RectList[#RectList].rect = Rect(max_rect_x - GENERATOR_BLOCK_VALUE, min_rect_y, max_rect_x, max_rect_y)
                    end

                    x = x + 1
                end

            --PreloadSound("Thunder High.wav")
            --PreloadSound("Thunder Normal.wav.wav")
            --PreloadSound("Thunder Low.wav")

            Y_BLOCKS = Y_BLOCKS - 1
            if Y_BLOCKS <= 0 then
                DestroyTimer(GetExpiredTimer())
            end

        end)

        local timer = CreateTimer()
        TimerStart(timer, 1., true, WeatherUpdate)
    end

end