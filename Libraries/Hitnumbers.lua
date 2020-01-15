do

    HITNUMBERS = {}

    local UPDATE = 0.04
    local DURATION = 1.
    local UNFADE = 0.17 --in
    local FADEPOINT = 0.65  --out
    local RANDOM_OFFSETM_MIN = 45.
    local RANDOM_OFFSET_MAX = 65.


    local ATTACK_STATUS_COLOR = {
        [ATTACK_STATUS_USUAL]    = '|c00FF0000',
        [ATTACK_STATUS_CRITICAL] = '|c00FFFF00',
        [ATTACK_STATUS_CRITICAL_BLOCKED] = '|c00FFFF00',
        [ATTACK_STATUS_BLOCKED] = '|c00FFFFFF',
        [ATTACK_STATUS_EVADE] = '|c00FFFFFF',
        [HEAL_STATUS] = '|c0000FF00',
        [RESOURCE_STATUS] = '|c00008BFF'
    }

    local STATUS_OFFSET = {
        [ATTACK_STATUS_USUAL]               = { x = { min = 35., max = 45. },   y = { min = 35., max = 45. }, },
        [ATTACK_STATUS_CRITICAL]            = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [ATTACK_STATUS_CRITICAL_BLOCKED]    = { x = { min = 35., max = 45. },   y = { min = 35., max = 45. }, },
        [ATTACK_STATUS_BLOCKED]             = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [ATTACK_STATUS_EVADE]               = { x = { min = 55., max = 65. },   y = { min = 55., max = 65. }, },
        [HEAL_STATUS]                       = { x = { min = -10., max = 10. },  y = { min = 0., max = -30. }, },
        [RESOURCE_STATUS]                   = { x = { min = -10., max = 10. },  y = { min = 20., max = -60. }, },
    }


    ---@param text number
    ---@param victim unit
    ---@param status integer
    function CreateHitnumber(text, source, victim, status)
        local tag = CreateTextTag()
        local time = 0.
        local size = 6.
        local size_parabola = 1.1
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
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

                --if size > END_SIZE then size = END_SIZE end

                SetTextTagText(tag, text, ((size * size_parabola) * 0.023) / 10)
                if time <= UNFADE then
                    size_parabola = size_parabola + 0.105
                elseif time >= FADEPOINT then
                    size_parabola = size_parabola - 0.03
                end


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

