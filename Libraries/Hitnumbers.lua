do

    HITNUMBERS = {}

    local UPDATE = 0.04
    local DURATION = 1.
    local UNFADE = 0.17 --in
    local FADEPOINT = 0.65  --out


    local ATTACK_STATUS_COLOR = {
        [ATTACK_STATUS_USUAL]    = '|c00FF0000',
        [ATTACK_STATUS_CRITICAL] = '|c00FFFF00',
        [ATTACK_STATUS_CRITICAL_BLOCKED] = '|c00FFFF00',
        [ATTACK_STATUS_BLOCKED] = '|c00FFFFFF',
        [ATTACK_STATUS_EVADE] = '|c00FFFFFF',
        [HEAL_STATUS] = '|c0000FF00',
        [RESOURCE_STATUS] = '|c00008BFF',
        [REFLECT_STATUS] = "|c008800FF"
    }

    local STATUS_OFFSET = {
        [ATTACK_STATUS_USUAL]               = { x = { min = 35., max = 45. },   y = { min = 35., max = 45. }, },
        [ATTACK_STATUS_CRITICAL]            = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [ATTACK_STATUS_CRITICAL_BLOCKED]    = { x = { min = 35., max = 45. },   y = { min = 35., max = 45. }, },
        [ATTACK_STATUS_BLOCKED]             = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [ATTACK_STATUS_EVADE]               = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [HEAL_STATUS]                       = { x = { min = -10., max = 10. },  y = { min = 0., max = -30. }, },
        [RESOURCE_STATUS]                   = { x = { min = -10., max = 10. },  y = { min = 20., max = -60. }, },
        [REFLECT_STATUS]                    = { x = { min = -50., max = -20. },  y = { min = 20., max = -60. }, },
    }


    local CONSTANT_TEXT_SIZE =  (9. * 0.023) / 10

    function GoldText(x, y, amount)
        local tag = CreateTextTag()

            SetTextTagText(tag, "|c00FFFF00+" .. amount .. "|r", CONSTANT_TEXT_SIZE)
            SetTextTagPos(tag, x, y, 15.)
            SetTextTagColor(tag, 255, 255, 255, 255)
            SetTextTagPermanent(tag, false)
            SetTextTagLifespan(tag, 1.)
            SetTextTagFadepoint(tag, 0.5)
            SetTextTagVelocity(tag, 0., 0.025)

    end


    local HitnumbersPool = {}


    local function NewHitnumber(victim, status)
        local tag = CreateTextTag()
        local time = 0.
        local size = 6.4
        local size_parabola = 1.1
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
        local end_y = y
        local step = 10.5 / (DURATION / UPDATE)
        local alpha = 0.
        local alpha_transition = 255 / (UNFADE / UPDATE)



        return tag
    end


    local function SetupTexttag(tag, text, size, x, y)
        SetTextTagText(tag, text, (size * 0.023) / 10)
        SetTextTagPos(tag, x, y, 15.)
        SetTextTagColor(tag, 255, 255, 255, 0)
        SetTextTagPermanent(tag, false)
        SetTextTagLifespan(tag, DURATION)
        SetTextTagFadepoint(tag, FADEPOINT)
    end

    local function ColorizeText(text, status)
        text = ATTACK_STATUS_COLOR[status] .. text .. '|r'

        if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
            text = text .. '!'
        elseif status == ATTACK_STATUS_BLOCKED then
            text = LOCALE_LIST[my_locale].BLOCK_TEXT .. text
        end

        return text
    end

    ---@param text number
    ---@param victim unit
    ---@param status integer
    function CreateHitnumber2(text, source, victim, status, tag_id)
        local tag
        local time = 0.
        local size = 6.4
        local size_parabola = 1.1
        local alpha = 0.
        local alpha_transition = 255 / (UNFADE / UPDATE)
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
        local step = 10.5 / (DURATION / UPDATE)
        local end_y = y

        if not HitnumbersPool[source] then HitnumbersPool[source] = { } end



        if tag_id and HitnumbersPool[source][tag_id] and HitnumbersPool[source][tag_id][victim] then
            local hitnm = HitnumbersPool[source][tag_id][victim]

                DestroyTextTag(hitnm.tag)
                tag = CreateTextTag()
                hitnm.tag = tag
                text = text + hitnm.damage
                hitnm.damage = text
                text = ColorizeText(text, status)
                SetupTexttag(tag, text, 9.6, HitnumbersPool[source][tag_id][victim].x, HitnumbersPool[source][tag_id][victim].y)

                SetTextTagColor(tag, 255, 255, 255, 255)
                alpha = 255

                TimerStart(hitnm.timer, UPDATE, true, function()
                    time = time + UPDATE
                    --print(time)

                    SetTextTagText(tag, text, (9.6 * 0.023) / 10)
                    if time >= FADEPOINT then size_parabola = size_parabola - 0.03 end

                    alpha = alpha + alpha_transition
                    if alpha > 255 then alpha = 255 end

                    y = y - step
                    SetTextTagPos(tag, x, y, 15.)
                    SetTextTagColor(tag, 255, 255, 255, alpha)

                    if time > DURATION then
                        --print("destroyed")
                        DestroyTimer(GetExpiredTimer())
                        HitnumbersPool[source][tag_id][victim] = nil
                    end
                end)

        elseif tag_id and (not HitnumbersPool[source][tag_id] or not HitnumbersPool[source][tag_id][victim]) then
            HitnumbersPool[source][tag_id] = {}
            HitnumbersPool[source][tag_id][victim] = {
                timer = CreateTimer(),
                tag = CreateTextTag(),
                damage = text,
                x = x, y = y
            }
            tag = HitnumbersPool[source][tag_id][victim].tag
            SetupTexttag(tag, text, size, x, y)
            text = ColorizeText(text, status)

            TimerStart(HitnumbersPool[source][tag_id][victim].timer, UPDATE, true, function()
                time = time + UPDATE

                SetTextTagText(tag, text, ((size * size_parabola) * 0.023) / 10)
                if time <= UNFADE then size_parabola = size_parabola + 0.105
                elseif time >= FADEPOINT then size_parabola = size_parabola - 0.03 end


                alpha = alpha + alpha_transition
                if alpha > 255 then alpha = 255 end

                y = y - step
                SetTextTagPos(tag, x, y, 15.)
                SetTextTagColor(tag, 255, 255, 255, alpha)

                if time > DURATION then
                    DestroyTimer(GetExpiredTimer())
                    HitnumbersPool[source][tag_id][victim] = nil
                end
            end)
        else
            CreateHitnumber(text, source, victim, status)
            --HitnumbersPool[source][tag_id].number = HitnumbersPool[source][tag_id].number + 1
        end


    end


    ---@param text number
    ---@param victim unit
    ---@param status integer
    function CreateHitnumber(text, source, victim, status)
        local tag = CreateTextTag()
        local time = 0.
        local size = 6.4
        local size_parabola = 1.1
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
        local end_y = y
        local step = 10.5 / (DURATION / UPDATE)
        local alpha = 0.
        local alpha_transition = 255 / (UNFADE / UPDATE)


        text = ATTACK_STATUS_COLOR[status] .. text .. '|r'

        if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
            text = text .. '!'
        elseif status == ATTACK_STATUS_BLOCKED then
            text = LOCALE_LIST[my_locale].BLOCK_TEXT .. text
        end

        SetTextTagText(tag, text, (size * 0.023) / 10)
        SetTextTagPos(tag, x, y, 15.)
        SetTextTagColor(tag, 255, 255, 255, 0)
        SetTextTagPermanent(tag, false)
        SetTextTagLifespan(tag, DURATION)
        SetTextTagFadepoint(tag, FADEPOINT)

            TimerStart(CreateTimer(), UPDATE, true, function()

                time = time + UPDATE

                SetTextTagText(tag, text, ((size * size_parabola) * 0.023) / 10)
                if time <= UNFADE then size_parabola = size_parabola + 0.105
                elseif time >= FADEPOINT then size_parabola = size_parabola - 0.03 end


                alpha = alpha + alpha_transition
                if alpha > 255 then alpha = 255 end

                y = y - step
                SetTextTagPos(tag, x, y, 15.)
                SetTextTagColor(tag, 255, 255, 255, alpha)

                if time > DURATION then
                    DestroyTimer(GetExpiredTimer())
                end

            end)


    end


end

