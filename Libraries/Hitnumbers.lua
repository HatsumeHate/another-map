do

    HITNUMBERS = {}

    local UPDATE = 0.04
    local END_SIZE = 9.2
    local STARTING_SIZE = 6.
    local DURATION = 1.
    local UNFADE = 0.17 --in
    local FADEPOINT = 0.65  --out
    local RANDOM_OFFSETM_MIN = 45.
    local RANDOM_OFFSET_MAX = 65.
    local VELOCITY = 9.5


    local ATTACK_STATUS_COLOR = {
        [ATTACK_STATUS_USUAL]    = '|c00FFFFFF',
        [ATTACK_STATUS_CRITICAL] = '|c00FFFF00'
    }


    function CreateHitnumber(text, source, victim, status)
        local tag = CreateTextTag()
        local time = 0.
        local size = STARTING_SIZE
        local size_parabola = 1.1
        local x = GetUnitX(victim) + GetRandomReal(RANDOM_OFFSETM_MIN, RANDOM_OFFSET_MAX)
        local y = GetUnitY(victim) + GetRandomReal(RANDOM_OFFSETM_MIN, RANDOM_OFFSET_MAX)
        local step = VELOCITY / (DURATION / UPDATE)
        local alpha = 0.
        local alpha_transition = 255 / (UNFADE / UPDATE)

        text = ATTACK_STATUS_COLOR[status] .. text .. '|r'

        if status == ATTACK_STATUS_CRITICAL then
            text = text .. '!'
        end

        SetTextTagText(tag, R2I(text), (size * 0.023) / 10)
        SetTextTagPos(tag, x, y, 15.)
        SetTextTagColor(tag, 255, 255, 255, 0)
        SetTextTagPermanent(tag, false)
        SetTextTagLifespan(tag, DURATION)
        SetTextTagFadepoint(tag, FADEPOINT)

            TimerStart(CreateTimer(), UPDATE, true, function()
                time = time + UPDATE


                if size > END_SIZE then size = END_SIZE end

                SetTextTagText(tag, R2I(text), ((size * size_parabola) * 0.023) / 10)
                if time <= UNFADE then
                    size_parabola = size_parabola + 0.11
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

