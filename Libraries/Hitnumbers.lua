do

    HITNUMBERS = 0
    local HitnumbersPool = 0

    local UPDATE = 0.04
    local DURATION = 1.
    local UNFADE = 0.17 --in
    local FADEPOINT = 0.65  --out
    local CONSTANT_TEXT_SIZE =  (9. * 0.023) / 10

    local UNFADE_MOD = UNFADE / UPDATE
    local STEP_MOD = DURATION / UPDATE


    local ATTACK_STATUS_COLOR = 0
    local ATTACK_STATUS_COLOR_EX = 0
    local STATUS_OFFSET = 0

    local TexttagMap



    function ShrineText(x, y, text)
        local tag = CreateTextTag()

            SetTextTagText(tag, "|c008252FF+" .. text .. "|r", CONSTANT_TEXT_SIZE)
            SetTextTagPos(tag, x, y, 15.)
            SetTextTagColor(tag, 255, 255, 255, 255)
            SetTextTagPermanent(tag, false)
            SetTextTagLifespan(tag, 3.)
            SetTextTagFadepoint(tag, 1.5)
            SetTextTagVelocity(tag, 0., 0.012)

    end

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

    local function NewHitnumber(victim, status)
        local tag = CreateTextTag()
        local time = 0.
        local size = 6.4
        local size_parabola = 1.1
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
        local end_y = y
        local step = 10.5 / STEP_MOD
        local alpha = 0.
        local alpha_transition = 255 / UNFADE_MOD



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
        elseif status == ATTACK_STATUS_MISS then
            text = LOCALE_LIST[my_locale].MISS_TEXT
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
        local alpha_transition = 255 / UNFADE_MOD
        local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max)
        local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
        local step = 10.5 / STEP_MOD
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

                if GetLocalPlayer() ~= GetOwningPlayer(source) and GetLocalPlayer() ~= GetOwningPlayer(victim) then
                    SetTextTagVisibility(tag, false)
                end

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

            if not HitnumbersPool[source][tag_id] then
                HitnumbersPool[source][tag_id] = {}
            end

            HitnumbersPool[source][tag_id][victim] = {
                timer = CreateTimer(),
                tag = CreateTextTag(),
                damage = text,
                x = x, y = y
            }

            tag = HitnumbersPool[source][tag_id][victim].tag
            SetupTexttag(tag, text, size, x, y)
            text = ColorizeText(text, status)

            if GetLocalPlayer() ~= GetOwningPlayer(source) and GetLocalPlayer() ~= GetOwningPlayer(victim) then
                SetTextTagVisibility(tag, false)
            end

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


    local HitnumberModelOffset = 16.5
    local TexttagFacing = 270.* bj_DEGTORAD


    ---@param text integer
    ---@param source unit
    ---@param victim unit
    ---@param attribute integer
    ---@param status integer
    ---@param tag_id string
    function CreateHitnumberSpecialStacked(text, source, victim, tag_id, attribute, status)

        if status == ATTACK_STATUS_MISS then
            CreateHitnumber(text, source, victim, status)
        else

            if not HitnumbersPool[source] then HitnumbersPool[source] = { } end

            if tag_id and HitnumbersPool[source][tag_id] and HitnumbersPool[source][tag_id][victim] then
                local pool = HitnumbersPool[source][tag_id][victim]

                    pool.damage = pool.damage + text
                    text = I2S(pool.damage)
                    BlzPlaySpecialEffect(pool.attribute_sfx, TexttagMap[attribute].main)
                    BlzSetSpecialEffectTimeScale(pool.attribute_sfx, 3.)

                    for i = 1, #pool.pack do
                        local element = string.sub(text, i, i)
                        BlzSpecialEffectClearSubAnimations(pool.pack[i])
                        if TexttagMap[element].sub then BlzSpecialEffectAddSubAnimation(pool.pack[i], TexttagMap[element].sub) end
                        BlzPlaySpecialEffect(pool.pack[i], TexttagMap[element].main)
                        BlzSetSpecialEffectTimeScale(pool.pack[i], 3.)
                    end


                    if #text > #pool.pack then
                        local model = ""
                        local local_source = GetLocalPlayer() == GetOwningPlayer(source)
                        local local_victim = GetLocalPlayer() == GetOwningPlayer(victim)

                            if local_source or local_victim then
                                model = "Other\\NumberTexttag4.mdx"
                            end

                            for i = #pool.pack+1, #text do
                                local element = string.sub(text, i, i)
                                pool.pack[i] = AddSpecialEffect(model, pool.x, pool.y)
                                BlzSetSpecialEffectZ(pool.pack[i], pool.z)
                                pool.x = pool.x + pool.offset
                                if TexttagMap[element].sub then BlzSpecialEffectAddSubAnimation(pool.pack[i], TexttagMap[element].sub) end
                                BlzPlaySpecialEffect(pool.pack[i], TexttagMap[element].main)
                                BlzSetSpecialEffectTimeScale(pool.pack[i], 3.)
                                BlzSetSpecialEffectScale(pool.pack[i], pool.scale)
                                BlzSetSpecialEffectYaw(pool.pack[i], TexttagFacing)
                                if local_source then BlzSetSpecialEffectColor(pool.pack[i], ATTACK_STATUS_COLOR_EX[pool.status].r, ATTACK_STATUS_COLOR_EX[pool.status].g, ATTACK_STATUS_COLOR_EX[pool.status].b)
                                elseif local_victim then BlzSetSpecialEffectColor(pool.pack[i], 255, 0, 0) end
                            end

                    end

                    if pool.special then
                        BlzSetSpecialEffectX(pool.special, pool.x)
                        BlzSetSpecialEffectY(pool.special, pool.y)
                        BlzSetSpecialEffectZ(pool.special, pool.z)
                        BlzPlaySpecialEffect(pool.special, ANIM_TYPE_SLEEP)
                        BlzSetSpecialEffectTimeScale(pool.special, 3.)
                    end

                    if not pool.special and (status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED) then
                        local model = ""
                        local local_source = GetLocalPlayer() == GetOwningPlayer(source)
                        local local_victim = GetLocalPlayer() == GetOwningPlayer(victim)
                        if local_source or local_victim then model = "Other\\NumberTexttag4.mdx" end
                        local special = AddSpecialEffect(model, pool.x, pool.y)

                            BlzSetSpecialEffectZ(special, pool.z)
                            BlzSpecialEffectAddSubAnimation(special, SUBANIM_TYPE_LUMBER)
                            BlzPlaySpecialEffect(special, ANIM_TYPE_SLEEP)
                            BlzSetSpecialEffectScale(special, pool.scale)
                            BlzSetSpecialEffectYaw(special, TexttagFacing)

                                if local_source then
                                    BlzSetSpecialEffectColor(pool.attribute_sfx, ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                                    BlzSetSpecialEffectColor(special, ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                                elseif local_victim then
                                    BlzSetSpecialEffectColor(pool.attribute_sfx, 255, 0, 0)
                                    BlzSetSpecialEffectColor(special, 255, 0, 0)
                                end

                            pool.special =  special
                            pool.status = status
                            for i = 1, #pool.pack do
                                if local_source then BlzSetSpecialEffectColor(pool.pack[i], ATTACK_STATUS_COLOR_EX[pool.status].r, ATTACK_STATUS_COLOR_EX[pool.status].g, ATTACK_STATUS_COLOR_EX[pool.status].b)
                                elseif local_victim then BlzSetSpecialEffectColor(pool.pack[i], 255, 0, 0) end
                            end
                    end

                    TimerStart(pool.timer, 0.056, false, function()

                        BlzSetSpecialEffectTimeScale(pool.attribute_sfx, 1.)
                        for i = 1, #pool.pack do BlzSetSpecialEffectTimeScale(pool.pack[i], 1.) end
                        if pool.special then BlzSetSpecialEffectTimeScale(pool.special, 1.) end

                        TimerStart(pool.timer, 0.830, false, function()
                            DestroyTimer(HitnumbersPool[source][tag_id][victim].timer)
                            HitnumbersPool[source][tag_id][victim] = nil
                            DestroyEffect(pool.attribute_sfx)
                            for i = 1, #pool.pack do DestroyEffect(pool.pack[i]) end
                            if pool.special then DestroyEffect(pool.special) end
                        end)


                    end)

            elseif tag_id and (not HitnumbersPool[source][tag_id] or not HitnumbersPool[source][tag_id][victim]) then
                local damage = text
                text = I2S(text)
                local initial_offset = 7.
                local megascale = 1.45
                local offset = HitnumberModelOffset
                if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                    megascale = 1.85
                    offset = 21.
                    initial_offset = 11.
                end
                local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max) - ((#text * offset) * 0.5)
                local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
                local z = GetUnitZ(victim) + 90.
                local pack = {}
                local model = ""
                local attribute_sfx
                local local_source = GetLocalPlayer() == GetOwningPlayer(source)
                local local_victim = GetLocalPlayer() == GetOwningPlayer(victim)

                if not HitnumbersPool[source][tag_id] then
                    HitnumbersPool[source][tag_id] = {}
                end

                HitnumbersPool[source][tag_id][victim] = {
                    timer = CreateTimer(),
                    pack = pack,
                    damage = damage,
                    x = x, y = y, z = z,
                    scale = megascale,
                    offset = offset,
                    status = status,
                    special = false
                }


                if local_source or local_victim then
                    model = "Other\\NumberTexttag4.mdx"
                end

                attribute_sfx = AddSpecialEffect(model, x, y)
                HitnumbersPool[source][tag_id][victim].attribute_sfx = attribute_sfx
                BlzSetSpecialEffectZ(attribute_sfx, z)
                if TexttagMap[attribute].sub then BlzSpecialEffectAddSubAnimation(attribute_sfx, TexttagMap[attribute].sub) end
                BlzPlaySpecialEffect(attribute_sfx, TexttagMap[attribute].main)
                BlzSetSpecialEffectScale(attribute_sfx, megascale * TexttagMap[attribute].scale)
                BlzSetSpecialEffectYaw(attribute_sfx, TexttagFacing)
                x = x + offset + initial_offset

                if status == ATTACK_STATUS_BLOCKED or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                    local block_sfx = AddSpecialEffect(model, x - (offset * 3), y)
                    BlzSetSpecialEffectZ(block_sfx, z)
                    BlzSpecialEffectAddSubAnimation(block_sfx, SUBANIM_TYPE_VICTORY)
                    BlzPlaySpecialEffect(block_sfx, ANIM_TYPE_SLEEP)
                    BlzSetSpecialEffectScale(block_sfx, megascale)
                    BlzSetSpecialEffectYaw(block_sfx, TexttagFacing)
                end


                if local_source then BlzSetSpecialEffectColor(attribute_sfx, ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                elseif local_victim then BlzSetSpecialEffectColor(attribute_sfx, 255, 0, 0) end


                for i = 1, #text do
                    local element = string.sub(text, i, i)
                    pack[i] = AddSpecialEffect(model, x, y)
                    BlzSetSpecialEffectZ(pack[i], z)
                    x = x + offset
                    if TexttagMap[element].sub then BlzSpecialEffectAddSubAnimation(pack[i], TexttagMap[element].sub) end
                    BlzPlaySpecialEffect(pack[i], TexttagMap[element].main)
                    BlzSetSpecialEffectScale(pack[i], megascale)
                    BlzSetSpecialEffectYaw(pack[i], TexttagFacing)
                    if local_source then BlzSetSpecialEffectColor(pack[i], ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                    elseif local_victim then BlzSetSpecialEffectColor(pack[i], 255, 0, 0) end
                end

                if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                    local special = AddSpecialEffect(model, x, y)
                    BlzSetSpecialEffectZ(special, z)
                    BlzSpecialEffectAddSubAnimation(special, SUBANIM_TYPE_LUMBER)
                    BlzPlaySpecialEffect(special, ANIM_TYPE_SLEEP)
                    BlzSetSpecialEffectScale(special, megascale)
                    BlzSetSpecialEffectYaw(special, TexttagFacing)
                    if local_source then BlzSetSpecialEffectColor(special, ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                    elseif local_victim then BlzSetSpecialEffectColor(special, 255, 0, 0) end
                    HitnumbersPool[source][tag_id][victim].special =  special
                end

                TimerStart(HitnumbersPool[source][tag_id][victim].timer, 1., false, function()
                    DestroyTimer(HitnumbersPool[source][tag_id][victim].timer)
                    HitnumbersPool[source][tag_id][victim] = nil
                    DestroyEffect(attribute_sfx)
                    for i = 1, #pack do DestroyEffect(pack[i]) end
                end)

                HitnumbersPool[source][tag_id][victim].x = x


            end


        end

    end


    ---@param text integer
    ---@param source unit
    ---@param victim unit
    ---@param attribute integer
    ---@param status integer
    function CreateHitnumberSpecial(text, source, victim, attribute, status)

        if status == ATTACK_STATUS_MISS then
            CreateHitnumber(text, source, victim, status)
        else
            text = I2S(text)
            local initial_offset = 7.
            local megascale = 1.45
            local offset = HitnumberModelOffset
            if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                megascale = 1.85
                offset = 21.
                initial_offset = 11.
            end
            local x = GetUnitX(victim) + GetRandomReal(STATUS_OFFSET[status].x.min, STATUS_OFFSET[status].x.max) - ((#text * offset) * 0.5)
            local y = GetUnitY(victim) + GetRandomReal(STATUS_OFFSET[status].y.min, STATUS_OFFSET[status].y.max)
            local z = GetUnitZ(victim) + 90.
            local pack = {}
            local model = ""
            local attribute_sfx
            local local_source = GetLocalPlayer() == GetOwningPlayer(source)
            local local_victim = GetLocalPlayer() == GetOwningPlayer(victim)


            if local_source or local_victim then
                model = "Other\\NumberTexttag4.mdx"
            end

                attribute_sfx = AddSpecialEffect(model, x, y)
                BlzSetSpecialEffectZ(attribute_sfx, z)
                if TexttagMap[attribute].sub then BlzSpecialEffectAddSubAnimation(attribute_sfx, TexttagMap[attribute].sub) end
                BlzPlaySpecialEffect(attribute_sfx, TexttagMap[attribute].main)
                BlzSetSpecialEffectScale(attribute_sfx, megascale * TexttagMap[attribute].scale)
                BlzSetSpecialEffectYaw(attribute_sfx, TexttagFacing)
                x = x + offset + initial_offset

                if status == ATTACK_STATUS_BLOCKED or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                    local block_sfx = AddSpecialEffect(model, x - (offset * 3), y)
                    BlzSetSpecialEffectZ(block_sfx, z)
                    BlzSpecialEffectAddSubAnimation(block_sfx, SUBANIM_TYPE_VICTORY)
                    BlzPlaySpecialEffect(block_sfx, ANIM_TYPE_SLEEP)
                    BlzSetSpecialEffectScale(block_sfx, megascale)
                    BlzSetSpecialEffectYaw(block_sfx, TexttagFacing)
                end


                if local_source then BlzSetSpecialEffectColor(attribute_sfx, ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                elseif local_victim then BlzSetSpecialEffectColor(attribute_sfx, 255, 0, 0) end


                for i = 1, #text do
                    local element = string.sub(text, i, i)
                    pack[i] = AddSpecialEffect(model, x, y)
                    BlzSetSpecialEffectZ(pack[i], z)
                    x = x + offset
                    if TexttagMap[element].sub then BlzSpecialEffectAddSubAnimation(pack[i], TexttagMap[element].sub) end
                    BlzPlaySpecialEffect(pack[i], TexttagMap[element].main)
                    BlzSetSpecialEffectScale(pack[i], megascale)
                    BlzSetSpecialEffectYaw(pack[i], TexttagFacing)
                    if local_source then BlzSetSpecialEffectColor(pack[i], ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                    elseif local_victim then BlzSetSpecialEffectColor(pack[i], 255, 0, 0) end
                end

                if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
                    local num = #pack + 1
                    pack[num] = AddSpecialEffect(model, x, y)
                    BlzSetSpecialEffectZ(pack[num], z)
                    x = x + offset
                    BlzSpecialEffectAddSubAnimation(pack[num], SUBANIM_TYPE_LUMBER)
                    BlzPlaySpecialEffect(pack[num], ANIM_TYPE_SLEEP)
                    BlzSetSpecialEffectScale(pack[num], megascale)
                    BlzSetSpecialEffectYaw(pack[num], TexttagFacing)
                    if local_source then BlzSetSpecialEffectColor(pack[num], ATTACK_STATUS_COLOR_EX[status].r, ATTACK_STATUS_COLOR_EX[status].g, ATTACK_STATUS_COLOR_EX[status].b)
                    elseif local_victim then BlzSetSpecialEffectColor(pack[num], 255, 0, 0) end
                end

                DelayAction(1., function()
                    DestroyEffect(attribute_sfx)
                    for i = 1, #pack do DestroyEffect(pack[i]) end
                end)

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
        local step = 10.5 / STEP_MOD
        local alpha = 0.
        local alpha_transition = 255 / UNFADE_MOD


        text = ATTACK_STATUS_COLOR[status] .. text .. '|r'

        if status == ATTACK_STATUS_CRITICAL or status == ATTACK_STATUS_CRITICAL_BLOCKED then
            text = text .. '!'
        elseif status == ATTACK_STATUS_BLOCKED then
            text = LOCALE_LIST[my_locale].BLOCK_TEXT .. text
        elseif status == ATTACK_STATUS_MISS then
            text = LOCALE_LIST[my_locale].MISS_TEXT
        end

        SetTextTagText(tag, text, (size * 0.023) / 10)
        SetTextTagPos(tag, x, y, 15.)
        SetTextTagColor(tag, 255, 255, 255, 0)
        SetTextTagPermanent(tag, false)
        SetTextTagLifespan(tag, DURATION)
        SetTextTagFadepoint(tag, FADEPOINT)

        if GetLocalPlayer() ~= GetOwningPlayer(source) and GetLocalPlayer() ~= GetOwningPlayer(victim) then
            SetTextTagVisibility(tag, false)
        end

            local timer = CreateTimer()
            TimerStart(timer, UPDATE, true, function()

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


    function HitnumbersInit()

        HITNUMBERS = {}
        HitnumbersPool = {}

        ATTACK_STATUS_COLOR = {
            [ATTACK_STATUS_USUAL]    = '|c00FF0000',
            [ATTACK_STATUS_CRITICAL] = '|c00FFFF00',
            [ATTACK_STATUS_CRITICAL_BLOCKED] = '|c00FFFF00',
            [ATTACK_STATUS_BLOCKED] = '|c00FFFFFF',
            [ATTACK_STATUS_EVADE] = '|c00FFFFFF',
            [ATTACK_STATUS_MISS] = '|c00FFFFFF',
            [HEAL_STATUS] = '|c0000FF00',
            [RESOURCE_STATUS] = '|c00008BFF',
            [REFLECT_STATUS] = "|c008800FF",
            [ATTACK_STATUS_SHIELD] = "|c00FF6400"
        }

         STATUS_OFFSET = {
            [ATTACK_STATUS_USUAL]               = { x = { min = 40., max = 55. },   y = { min = 40., max = 55. }, },
            [ATTACK_STATUS_CRITICAL]            = { x = { min = 55., max = 75. },   y = { min = 55., max = 75. }, },
            [ATTACK_STATUS_CRITICAL_BLOCKED]    = { x = { min = 40., max = 55. },   y = { min = 40., max = 55. }, },
            [ATTACK_STATUS_BLOCKED]             = { x = { min = 55., max = 75. },   y = { min = 55., max = 75. }, },
            [ATTACK_STATUS_EVADE]               = { x = { min = 55., max = 75. },   y = { min = 55., max = 75. }, },
            [ATTACK_STATUS_MISS]               = { x = { min = 55., max = 75. },   y = { min = 55., max = 75. }, },
            [HEAL_STATUS]                       = { x = { min = -10., max = 20. },  y = { min = 0., max = -40. }, },
            [RESOURCE_STATUS]                   = { x = { min = -10., max = 20. },  y = { min = 20., max = -70. }, },
            [REFLECT_STATUS]                    = { x = { min = -50., max = -30. },  y = { min = 20., max = -70. }, },
            [ATTACK_STATUS_SHIELD]               = { x = { min = 40., max = 55. },   y = { min = 40., max = 55. }, },
        }

        TexttagMap = {
            ["1"] = { main = ANIM_TYPE_STAND },
            ["2"] = { main = ANIM_TYPE_SPELL },
            ["3"] = { main = ANIM_TYPE_SLEEP },
            ["4"] = { main = ANIM_TYPE_ATTACK },
            ["5"] = { main = ANIM_TYPE_STAND, sub = SUBANIM_TYPE_HIT },
            ["6"] = { main = ANIM_TYPE_STAND, sub = SUBANIM_TYPE_GOLD },
            ["7"] = { main = ANIM_TYPE_ATTACK, sub = SUBANIM_TYPE_GOLD },
            ["8"] = { main = ANIM_TYPE_SLEEP, sub = SUBANIM_TYPE_GOLD },
            ["9"] = { main = ANIM_TYPE_ATTACK, sub = SUBANIM_TYPE_LUMBER },
            ["0"] = { main = ANIM_TYPE_STAND, sub = SUBANIM_TYPE_LUMBER },
            ["!"] = { main = ANIM_TYPE_SLEEP, sub = SUBANIM_TYPE_LUMBER },
            [FIRE_ATTRIBUTE] = { main = ANIM_TYPE_SLEEP, sub = SUBANIM_TYPE_HIT, scale = 1. },
            [PHYSICAL_ATTRIBUTE] = { main = ANIM_TYPE_SPELL, sub = SUBANIM_TYPE_GOLD, scale = 1. },
            [LIGHTNING_ATTRIBUTE] = { main = ANIM_TYPE_SPELL, sub = SUBANIM_TYPE_LUMBER, scale = 1.1 },
            [ICE_ATTRIBUTE] = { main = ANIM_TYPE_ATTACK, sub = SUBANIM_TYPE_HIT, scale = 1. },
            [DARKNESS_ATTRIBUTE] = { main = ANIM_TYPE_SPELL, sub = SUBANIM_TYPE_VICTORY, scale = 1.1 },
            [HOLY_ATTRIBUTE] = { main = ANIM_TYPE_STAND, sub = SUBANIM_TYPE_VICTORY, scale = 1.1 },
            [POISON_ATTRIBUTE] = { main = ANIM_TYPE_ATTACK, sub = SUBANIM_TYPE_VICTORY, scale = 1.1 },
            [ARCANE_ATTRIBUTE] = { main = ANIM_TYPE_SPELL, sub = SUBANIM_TYPE_HIT, scale = 1.1 },
        }

        ATTACK_STATUS_COLOR_EX = {
            [ATTACK_STATUS_USUAL]    = { r = 255, g = 118, b = 0 },
            [ATTACK_STATUS_CRITICAL] = { r = 255, g = 255, b = 0 },
            [ATTACK_STATUS_CRITICAL_BLOCKED] = { r = 255, g = 255, b = 0 },
            [ATTACK_STATUS_BLOCKED] = { r = 255, g = 255, b = 255 },
            [ATTACK_STATUS_EVADE] = { r = 255, g = 255, b = 255 },
            [ATTACK_STATUS_MISS] = { r = 255, g = 255, b = 255 },
            [HEAL_STATUS] = { r = 0, g = 255, b = 0 },
            [RESOURCE_STATUS] = { r = 0, g = 139, b = 255 },
            [REFLECT_STATUS] = { r = 136, g = 0, b = 255 },
            [ATTACK_STATUS_SHIELD] = { r = 255, g = 100, b = 0 },
        }

    end


end

