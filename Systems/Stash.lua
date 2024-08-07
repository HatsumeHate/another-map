---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 28.08.2021 22:22
---
do


    local EffectTable
    StashFrame = nil
    local ClickTrigger; local EnterTrigger; local LeaveTrigger
    local DoubleClickTimer; local CachedItems
    local last_EnteredFrame
    local last_EnteredFrameTimer



    ---@param texture string
    ---@param size_x real
    ---@param size_y real
    ---@param relative_frame framehandle
    ---@param frame_point_from framepointtype
    ---@param frame_point_to framepointtype
    ---@param offset_x real
    ---@param offset_y real
    ---@param parent_frame framehandle
    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)


            ButtonList[new_Frame] = {
                item = nil,
                button = new_Frame,
                image = new_FrameImage,
                original_texture = texture,
            }

            FrameRegisterNoFocus(new_Frame)
            FrameRegisterClick(new_Frame, texture)

            BlzTriggerRegisterFrameEvent(ClickTrigger, new_Frame, FRAMEEVENT_CONTROL_CLICK)
            BlzTriggerRegisterFrameEvent(EnterTrigger, new_Frame, FRAMEEVENT_MOUSE_ENTER)
            --BlzTriggerRegisterFrameEvent(LeaveTrigger, new_Frame, FRAMEEVENT_MOUSE_LEAVE)

            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end





    ---@param item item
    function ParseItem(item)
        local result = ""
        local item_data = GetItemData(item)

            result = result .. "-a" .. item_data.raw .. "-d" .. item_data.QUALITY .. "-g" .. R2I(item_data.stat_modificator * 100.)

            if item_data.TYPE == ITEM_TYPE_WEAPON then
                result = result .. "-u" .. item_data.ATTRIBUTE .. "-b" .. item_data.ATTRIBUTE_BONUS .. "-f" .. item_data.DAMAGE_TYPE
            end

            result = result .. "-h" .. #item_data.BONUS

            for i = 1, #item_data.BONUS do
                local value = item_data.BONUS[i].VALUE

                --print("value before " .. value)
                if item_data.BONUS[i].METHOD == MULTIPLY_BONUS or (item_data.BONUS[i].PARAM == CRIT_MULTIPLIER or item_data.BONUS[i].PARAM == HP_REGEN or item_data.BONUS[i].PARAM == MP_REGEN) then value = R2I(math.floor((value * 100.)+0.5)) end
                --print("value after " .. value)

                result = result .. "-q" .. i .. R2I(item_data.BONUS[i].PARAM) .. "-w" .. i .. value .. "-e" .. i .. R2I(item_data.BONUS[i].METHOD) .. "-k" .. i .. (item_data.BONUS[i].base or value) .. "-y" .. i .. (item_data.BONUS[i].delta or 0) .. "-c" .. i .. (item_data.BONUS[i].delta_level or 0) .. "-z" .. i .. (item_data.BONUS[i].delta_level_max or 0)
            end


        if item_data.SKILL_BONUS then

            result = result .. "-s" .. #item_data.SKILL_BONUS

            for i = 1, #item_data.SKILL_BONUS do
                if item_data.SKILL_BONUS[i].id and GetSkillData(FourCC(item_data.SKILL_BONUS[i].id)) then result = result .. "-i" .. i .. item_data.SKILL_BONUS[i].bonus_levels .. "-o" .. i .. item_data.SKILL_BONUS[i].id
                else result = result .. "-i" .. i .. item_data.SKILL_BONUS[i].bonus_levels .. "-p" .. i .. item_data.SKILL_BONUS[i].category end
            end

        else
            result = result .. "-s" .. 0
        end

        if item_data.effect_bonus and #item_data.effect_bonus > 0 then
            result = result .. "-m" .. #item_data.effect_bonus

            for i = 1, #item_data.effect_bonus do
                result = result .. "-l" .. i .. GetEffectNumber(item_data.effect_bonus[i])
            end
        else
            result = result .. "-m0"
        end

        if item_data.STONE_SLOTS then
            result = result .. "-x" .. #item_data.STONE_SLOTS
            for i = 1, #item_data.STONE_SLOTS do
                if item_data.STONE_SLOTS[i] then
                    result = result .. "-v" .. i .. item_data.STONE_SLOTS[i].raw
                end
            end
        else
            result = result .. "-x" .. 0
        end


        result = result .. "-r" .. item_data.MAX_SLOTS

        if item_data.item_variation then
            result = result .. "-t" .. item_data.item_variation .. "-af" .. item_data.affix .. "-sf" .. item_data.suffix
        else
            result = result .. "-t0"
        end

        --print("parse result "..result)
        result = result .. "-n" .. item_data.NAME .. "-enditem"


        return result
    end


    function ParseData(data, tag)
        local first_index = (string.find(data, "-"..tag, 0) or 0) + #tag + 1
        if not first_index then return "0" end
        local second_index = (string.find(data, "-", first_index) or 0) -1
        if not second_index then return "0" end
        --print(tag .. " = "..string.sub(data, first_index, second_index))
        return string.sub(data, first_index or 0, second_index or 0) or "0"
    end


    function LoadItem(code, player, slot)
        local id = ParseData(code, "a")

        local item = CreateCustomItem(id, 0.,0., false, player)
        if item == nil then return end


            local item_data = GetItemData(item)

            if item_data.TYPE == ITEM_TYPE_WEAPON then
                --item_data.DAMAGE = S2I(ParseData(code, "c"))
                item_data.ATTRIBUTE = S2I(ParseData(code, "u"))
                item_data.ATTRIBUTE_BONUS = S2I(ParseData(code, "b"))
                item_data.DAMAGE_TYPE = S2I(ParseData(code, "f"))
            end

            item_data.QUALITY = S2I(ParseData(code, "d"))
            local color_table = GetQualityEffectColor(item_data.QUALITY)
            BlzSetSpecialEffectColor(item_data.quality_effect, color_table.r, color_table.g, color_table.b)
            BlzSetSpecialEffectScale(item_data.quality_effect, ITEMSUBTYPES_EFFECT_SCALE[item_data.SUBTYPE])
            BlzSetSpecialEffectAlpha(item_data.quality_effect, 0)
            item_data.stat_modificator = S2R(ParseData(code, "g")) / 100.
            item_data.MAX_SLOTS =  S2I(ParseData(code, "r"))

            local bonuses = S2I(ParseData(code, "h"))

            if bonuses > 0 then
                 for i = 1, bonuses do

                     item_data.BONUS[i] = {}
                     item_data.BONUS[i].METHOD = S2I(ParseData(code, "e"..i))
                     --print("loaded method " .. item_data.BONUS[i].METHOD)
                     item_data.BONUS[i].VALUE = S2R(ParseData(code, "w"..i))
                     item_data.BONUS[i].PARAM = S2I(ParseData(code, "q"..i))

                     if item_data.BONUS[i].METHOD == MULTIPLY_BONUS or (item_data.BONUS[i].PARAM == CRIT_MULTIPLIER or item_data.BONUS[i].PARAM == HP_REGEN or item_data.BONUS[i].PARAM == MP_REGEN) then item_data.BONUS[i].VALUE = item_data.BONUS[i].VALUE / 100.
                     else item_data.BONUS[i].VALUE = R2I(item_data.BONUS[i].VALUE) end

                     item_data.BONUS[i].base = S2I(ParseData(code, "k"..i))

                     local delta = S2I(ParseData(code, "y"..i))

                     if delta > 0 then
                         item_data.BONUS[i].delta = delta
                         item_data.BONUS[i].delta_level = S2I(ParseData(code, "c"..i))
                         item_data.BONUS[i].delta_level_max = S2I(ParseData(code, "z"..i))
                     end
                     --print("loaded value " .. item_data.BONUS[i].VALUE)

                end
            end

            bonuses = S2I(ParseData(code, "s"))

            if bonuses > 0 then
                for i = 1, bonuses do
                    item_data.SKILL_BONUS[i] = { bonus_levels = S2I(ParseData(code, "i"..i)) }
                    local str = ParseData(code, "o"..i) or "0"
                    if GetSkillData(FourCC(str)) then item_data.SKILL_BONUS[i].id = str
                    else item_data.SKILL_BONUS[i].category = S2I(ParseData(code, "p"..i)) end
                end
            end

            bonuses = S2I(ParseData(code, "x"))
            if bonuses > 0 then
                for i = 1, bonuses do
                    local stone = CreateCustomItem(ParseData(code, "v"..i), 0.,0.)
                    DelayAction(0., function() item_data.STONE_SLOTS[i] = GetItemData(stone); RemoveCustomItem(stone) end)
                    SetItemVisible(stone, false)
                end
            end

            DelayAction(0.001, function()
                if item_data.MAX_SLOTS > 2 then
                    local runeword = GetRunewordId(item_data.STONE_SLOTS)
                    local runeword_data = GetRunewordData(runeword)
                    if runeword and runeword_data[item_data.TYPE] then
                        item_data.runeword = runeword
                    end
                end
            end)


            bonuses = S2I(ParseData(code, "m"))
            if bonuses > 0 then
                item_data.effect_bonus = {}
                for i = 1, bonuses do
                    item_data.effect_bonus[i] = GetEffectStr(S2I(ParseData(code, "l"..i)))
                end
            end

            --print("vars")
            local var = ParseData(code, "t") or 0

            if S2I(var) > 0 then
                local item_preset = QUALITY_ITEM_LIST[item_data.QUALITY][item_data.SUBTYPE][S2I(var)]
                item_data.NAME = ITEM_AFFIX_NAME_LIST[S2I(ParseData(code, "af"))][item_preset.decl] .. item_preset.name .. ITEM_SUFFIX_LIST[S2I(ParseData(code, "sf"))].name
                item_data.item_variation = var
                item_data.frame_texture = item_preset.icon
                item_data.soundpack = item_preset.soundpack
                item_data.stat_modificator = item_preset.modificator
                item_data.model = item_preset.model or nil
                item_data.texture = item_preset.texture or nil
            end


            --item_data.NAME = ParseData(code, "n")
            item_data.actual_name = GetQualityColor(item_data.QUALITY) .. item_data.NAME .. '|r'
            BlzSetItemName(item, item_data.actual_name)
            GenerateItemLevel(item, 1)
            GenerateItemCost(item, 1)

            SetItemVisible(item, false)
            AddToStash(player, item, true, slot)

    end


    function GetItemCodeTable(code)
        local table = {}
        local last_index = 0

            while(true) do
                local item_index = string.find(code, "-a", last_index)
                if item_index then
                    last_index = string.find(code, "-enditem", item_index) + #"-enditem"
                    table[#table+1] = string.sub(code, item_index - 1, last_index)
                else
                    break
                end
            end

        return table
    end

    ---@param code string
    ---@param player number
    function LoadStash(code, player)
        --print("stash code is "..code)
        local itemtable = GetItemCodeTable(code)

            for i = 1, #itemtable do
                LoadItem(itemtable[i], player)
            end

    end


    function UpdateStashWindow(player)
        for i = 1, 5 do
            local button = ButtonList[StashFrame[player].slots[i]]

                if button.item then
                    local item_data = GetItemData(button.item)
                    BlzFrameSetTexture(button.image, item_data.frame_texture, 0, true)
                    FrameChangeTexture(button.button, item_data.frame_texture)

                    if not CachedItems[player][i] or CachedItems[player][i].item ~= button.item then
                        CachedItems[player][i] = {}
                        CachedItems[player][i].item = button.item
                        DelayAction(0., function()
                            CachedItems[player][i].parse_data = ParseItem(button.item)
                            AddToBuffer(CachedItems[player][i].parse_data)
                            FileWrite(player - 1, "CastleRevival\\slot".. i ..".txt", "slot")
                        end)
                    end

                else
                    BlzFrameSetTexture(button.image, button.original_texture, 0, true)
                    FrameChangeTexture(button.button, button.original_texture)
                    BlzFrameSetText(button.charges_text_frame, "")
                    StashFrame[player].itemdata[i] = nil
                    if CachedItems[player][i] then FileOverwrite(player-1, "CastleRevival\\slot".. i ..".txt", "0") end
                    CachedItems[player][i] = nil
                end

        end
    end


    local function GetFirstFreeStashButton(player)
        for i = 1, 5 do

            if ButtonList[StashFrame[player].slots[i]].item == nil then
                return ButtonList[StashFrame[player].slots[i]]
            end

        end
        return nil
    end


    function CountFreeStashSlots(player)
        local count = 0

            for i = 1, 5 do
                if StashFrame[player].slots[i] ~= nil then
                    if ButtonList[StashFrame[player].slots[i]].item == nil then
                        count = count + 1
                    end
                end
            end

        return count
    end

    ---@param item item
    ---@param player integer
    ---@param silent boolean
    ---@param slot number
    ---@return boolean
    function AddToStash(player, item, silent, slot)

        if GetItemData(item) == nil then return false end

        local item_data = GetItemData(item)

        if CountFreeStashSlots(player) <= 0 then
            Feedback_InventoryNoSpace(player)
            return false
        end


        local free_slot = ButtonList[StashFrame[player].slots[slot]] or GetFirstFreeStashButton(player)

        if free_slot ~= nil then
            free_slot.item = item
            if not silent and item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
            UpdateStashWindow(player)
            return true
        end


        return false
    end

    function ReloadStashFrames()
        for player = 1, 6 do
            if PlayerHero[player] then
                local new_Frame
                local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

                    BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.11, -0.1)
                    BlzFrameSetSize(main_frame, 0.27, 0.15)


                    new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
                    BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
                    StashFrame[player].portrait = new_Frame

                    new_Frame = BlzCreateFrameByType("TEXT", "shop name", StashFrame[player].portrait, "", 0)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, StashFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
                    BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
                    BlzFrameSetScale(new_Frame, 1.35)
                    StashFrame[player].name = new_Frame


                    new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                    --BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, PrivateChestFrame[player].portrait, FRAMEPOINT_ЕЩЗLEFT, 0.015, 0.015)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
                    BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
                    BlzFrameSetSize(new_Frame, 0.15, 0.07)
                    -- РЯДЫ - 0.035 5 КОЛОННЫ - 0.045 8
                    StashFrame[player].border = new_Frame

                    StashFrame[player].slots = { [1] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, new_Frame) }

                    for i = 2, 5 do
                        StashFrame[player].slots[i] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, StashFrame[player].slots[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., new_Frame)
                    end


                    StashFrame[player].tooltip = NewTooltip(StashFrame[player].slots[5])
                    local tooltip = GetTooltip(StashFrame[player].tooltip)
                    tooltip.is_sell_penalty = true
                    StashFrame[player].main_frame = main_frame
                    BlzFrameSetVisible(StashFrame[player].main_frame, false)
                    BlzFrameSetTexture(StashFrame[player].portrait, "UI\\BTNTreasureChest2.blp", 0, true)
                    BlzFrameSetText(StashFrame[player].name, GetUnitName(gg_unit_n01Z_0030))

            end
        end
    end


    ---@param player integer
    function DrawStashFrames(player)
        local new_Frame
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            StashFrame[player] = {}
            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0.11, -0.1)
            BlzFrameSetSize(main_frame, 0.27, 0.15)


            new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", main_frame, "",0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
            BlzFrameSetSize(new_Frame, 0.0435, 0.0435)
            StashFrame[player].portrait = new_Frame

            new_Frame = BlzCreateFrameByType("TEXT", "shop name", StashFrame[player].portrait, "", 0)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_LEFT, StashFrame[player].portrait, FRAMEPOINT_RIGHT, 0.011, 0.)
            BlzFrameSetTextAlignment(new_Frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            BlzFrameSetScale(new_Frame, 1.35)
            StashFrame[player].name = new_Frame


            new_Frame = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            --BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, PrivateChestFrame[player].portrait, FRAMEPOINT_ЕЩЗLEFT, 0.015, 0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMLEFT, main_frame, FRAMEPOINT_BOTTOMLEFT, 0.015, 0.015)
            BlzFrameSetPoint(new_Frame, FRAMEPOINT_BOTTOMRIGHT, main_frame, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.015)
            BlzFrameSetSize(new_Frame, 0.15, 0.07)
            -- РЯДЫ - 0.035 5 КОЛОННЫ - 0.045 8
            StashFrame[player].border = new_Frame
            --RegisterConstructor(new_Frame, 0.15, 0.07)


            StashFrame[player].slots = { [1] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, new_Frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.02, -0.017, new_Frame) }

            for i = 2, 5 do
                StashFrame[player].slots[i] = NewButton("GUI\\inventory_slot.blp", 0.04, 0.04, StashFrame[player].slots[i - 1], FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPRIGHT, 0., 0., new_Frame)
            end


            StashFrame[player].itemdata = {}
            StashFrame[player].tooltip = NewTooltip(StashFrame[player].slots[5])
            local tooltip = GetTooltip(StashFrame[player].tooltip)
            tooltip.is_sell_penalty = true
            StashFrame[player].main_frame = main_frame
            BlzFrameSetVisible(StashFrame[player].main_frame, false)

    end


    function GetEffectStr(num)
        return EffectTable[num]
    end

    function GetEffectNumber(eff)
        for i = 1, #EffectTable do
            if eff == EffectTable[i] then
                return i
            end
        end
        return 0
    end



    local FirstTime_Data

    function InitPrivateStash()

        StashFrame = {}

        last_EnteredFrame = {}
        last_EnteredFrameTimer = {}

        for i = 1, 6 do
            last_EnteredFrameTimer[i] = CreateTimer()
        end


        EffectTable = {
            [1] = "weap_poison_mag",
            [2] = "item_enrage",
            [3] = "weap_bleed",
            [4] = "weap_fire_mag",
            [5] = "item_conduction",
            [6] = "item_fortify",
            [7] = "weap_poison_phys",
        }

        --ShowUnit(gg_unit_n01Z_0030, false)
        local trg = CreateTrigger()
        TriggerRegisterUnitInRangeSimple(trg, 250., gg_unit_n01Z_0030)
        TriggerAddAction(trg, function()
            local id = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
            local player = id + 1

                if id <= 5 then
                    local hero = GetTriggerUnit()

                        StashFrame[player].state = true

                        if FirstTime_Data[player].first_time then
                            ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_STASH, id)
                            FirstTime_Data[player].first_time = false
                            AddJournalEntry(player, "hints", "UI\\BTNLeatherbound_TomeI.blp", GetLocalString("Подсказки", "Hints and Tips"), 1000)
                            AddJournalEntryText(player, "hints", QUEST_HINT_STRING .. LOCALE_LIST[my_locale].HINT_STASH, true)
                        end

                        if GetLocalPlayer() == Player(id) then
                            BlzFrameSetVisible(StashFrame[player].main_frame, true)
                            SetUnitAnimation(gg_unit_n01Z_0030, "Morph")
                        end

                        --UpdateStashWindow(player)

                        local timer = CreateTimer()
                            TimerStart(timer, 0.1, true, function()
                                if not IsUnitInRange(hero, gg_unit_n01Z_0030, 251.) then
                                    DestroyContextMenu(player)
                                    RemoveTooltip(player)
                                    StashFrame[player].state = false
                                    TimerStart(last_EnteredFrameTimer[player], 0., false, nil)

                                        if GetLocalPlayer() == Player(id) then
                                            BlzFrameSetVisible(StashFrame[player].main_frame, false)
                                            SetUnitAnimation(gg_unit_n01Z_0030, "Morph Alternate")
                                        end

                                    DestroyTimer(GetExpiredTimer())
                                end

                            end)
                end

        end)



        LeaveTrigger = CreateTrigger()
        TriggerAddAction(LeaveTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1

                if button.item then
                    RemoveTooltip(player)
                end

        end)

        EnterTrigger = CreateTrigger()
        TriggerAddAction(EnterTrigger, function()
            local button = GetButtonData(BlzGetTriggerFrame())
            local player = GetPlayerId(GetTriggerPlayer()) + 1


                TimerStart(last_EnteredFrameTimer[player], GLOBAL_TOOLTIP_FADE_TIME, false, function()
                    RemoveTooltip(player)
                    last_EnteredFrame[player] = nil
                    --print("remove timed")
                end)


                if last_EnteredFrame[player] == BlzGetTriggerFrame() then
                    --print("same frame")
                    return
                else
                    RemoveTooltip(player)
                    --print("remove")
                end

            last_EnteredFrame[player] = BlzGetTriggerFrame()

                if button.item then
                    local proper_tooltip = StashFrame[player].tooltip

                    if PlayerInventoryFrameState[player] then proper_tooltip = InventoryTooltip[player] end

                    ShowItemTooltip(button.item, proper_tooltip, button, player, FRAMEPOINT_RIGHT, GetTooltip(InventoryTooltip[player]))
                else
                    RemoveTooltip(player)
                end

        end)


        DoubleClickTimer = { [1] = { timer = CreateTimer() }, [2] = { timer = CreateTimer() }, [3] = { timer = CreateTimer() }, [4] = { timer = CreateTimer() }, [5] = { timer = CreateTimer() }, [6] = { timer = CreateTimer() } }


        ClickTrigger = CreateTrigger()
        TriggerAddAction(ClickTrigger, function()
            local player = GetPlayerId(GetTriggerPlayer()) + 1
            local button = GetButtonData(BlzGetTriggerFrame())
            local item_data = GetItemData(button.item) or nil


                if TimerGetRemaining(DoubleClickTimer[player].timer) > 0. then

                    if item_data then
                        RemoveTooltip(player)
                        DestroyContextMenu(player)

                        if AddToInventory(player, button.item) then
                            if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                            button.item = nil
                            UpdateStashWindow(player)
                        else
                            Feedback_InventoryNoSpace(player)
                        end

                        TimerStart(DoubleClickTimer[player].timer, 0., false, nil)
                    end

                else

                    TimerStart(DoubleClickTimer[player].timer, 0.25, false, function()

                        if item_data then
                            CreatePlayerContextMenu(player, button.button, FRAMEPOINT_RIGHT, StashFrame[player].slots[5])
                            AddContextOption(player, LOCALE_LIST[my_locale].UI_TEXT_FROM_STASH, function()
                                if AddToInventory(player, button.item) then
                                    if item_data.soundpack and item_data.soundpack.drop then PlayLocalSound(item_data.soundpack.drop, player - 1) end
                                    button.item = nil
                                    UpdateStashWindow(player)
                                else
                                    Feedback_InventoryNoSpace(player)
                                end
                            end)

                        end

                    end)

                end


        end)


        BlzSetUnitName(gg_unit_n01Z_0030, GetLocalString("Заначка", "Stash"))
        CachedItems = {}
        for i = 1, 6 do
            CachedItems[i] = {}
            DrawStashFrames(i)
            BlzFrameSetTexture(StashFrame[i].portrait, "UI\\BTNTreasureChest2.blp", 0, true)
            BlzFrameSetText(StashFrame[i].name, GetUnitName(gg_unit_n01Z_0030))
            StashFrame[i].itemdata = {}
        end


        FirstTime_Data = {
            [1] = { first_time = true },
            [2] = { first_time = true },
            [3] = { first_time = true },
            [4] = { first_time = true },
            [5] = { first_time = true },
            [6] = { first_time = true }
        }

        DelayAction(10., function()
            FileLoad("CastleRevival\\slot1.txt")
            FileLoad("CastleRevival\\slot2.txt")
            FileLoad("CastleRevival\\slot3.txt")
            FileLoad("CastleRevival\\slot4.txt")
            FileLoad("CastleRevival\\slot5.txt")
        end)


    end

end