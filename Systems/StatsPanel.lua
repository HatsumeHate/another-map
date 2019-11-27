do

    local UPDATE = 0.33
    PlayerStatsFrame = {}
    StatsList = {}
    PlayerHero = {}
    MainStatButtons = {}
    CharButton = nil


    local function Update()
        for i = 1, 6 do
            if PlayerHero[i] ~= nil then
                local data = GetUnitData(PlayerHero[i])
                BlzFrameSetText(StatsList[STR_STAT], "Сила: ".. data.stats[STR_STAT].value)
                BlzFrameSetText(StatsList[INT_STAT], "Интеллект: ".. data.stats[INT_STAT].value)
                BlzFrameSetText(StatsList[VIT_STAT], "Стойкость: ".. data.stats[VIT_STAT].value)
                BlzFrameSetText(StatsList[AGI_STAT], "Ловкость: ".. data.stats[AGI_STAT].value)

                BlzFrameSetText(StatsList[PHYSICAL_ATTACK], "Физ. урон: ".. R2I(data.stats[PHYSICAL_ATTACK].value + data.equip_point[WEAPON_POINT].DAMAGE))
                BlzFrameSetText(StatsList[PHYSICAL_DEFENCE], "Защита: ".. R2I(data.stats[PHYSICAL_DEFENCE].value))
                BlzFrameSetText(StatsList[MAGICAL_ATTACK], "Маг. урон: ".. R2I(data.stats[MAGICAL_ATTACK].value + data.equip_point[WEAPON_POINT].DAMAGE))
                BlzFrameSetText(StatsList[MAGICAL_SUPPRESSION], "Подавление: ".. R2I(data.stats[MAGICAL_SUPPRESSION].value))
                BlzFrameSetText(StatsList[ATTACK_SPEED], "Атак в сек.: ".. string.format('%%.2f', data.stats[ATTACK_SPEED].value))
                BlzFrameSetText(StatsList[CRIT_CHANCE], "Крит. Шанс: "..  R2I(data.stats[CRIT_CHANCE].value) .. "%%")

                BlzFrameSetText(StatsList[PHYSICAL_RESIST], "Физ.: ".. data.stats[PHYSICAL_RESIST].value)
                BlzFrameSetText(StatsList[FIRE_RESIST], "Огонь: ".. data.stats[FIRE_RESIST].value)
                BlzFrameSetText(StatsList[ICE_RESIST], "Лед: ".. data.stats[ICE_RESIST].value)
                BlzFrameSetText(StatsList[LIGHTNING_RESIST], "Молния: ".. data.stats[LIGHTNING_RESIST].value)
                BlzFrameSetText(StatsList[DARKNESS_RESIST], "Тьма: ".. data.stats[DARKNESS_RESIST].value)
                BlzFrameSetText(StatsList[HOLY_RESIST], "Свет: ".. data.stats[HOLY_RESIST].value)
                BlzFrameSetText(StatsList[POISON_RESIST], "Яд: ".. data.stats[POISON_RESIST].value)
                BlzFrameSetText(StatsList[ARCANE_RESIST], "Тайное: ".. data.stats[ARCANE_RESIST].value)
            end
        end
    end


    function AddToPanel(u, player)
        PlayerHero[player] = u
    end


    local function CreateTooltip(header, context, frame, size_x, size_y)
        local tooltip = BlzCreateFrame("BoxedText", frame, 0, 1)
        BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetTooltip(frame, tooltip)
        BlzFrameSetSize(tooltip, size_x, size_y)
        BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 1), context)
        BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 1), header)
    end


    local function CreateTextBox(text, stat, size_x, size_y, scale, relative_frame, from, to, offset_x, offset_y, owning_frame)
        local new_frame = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', owning_frame, 0, 0)
        BlzFrameSetPoint(new_frame, from, relative_frame, to, offset_x, offset_y)
        BlzFrameSetSize(new_frame, size_x, size_y)

        StatsList[stat] = BlzCreateFrameByType("TEXT", "text", new_frame, "", 0)
        BlzFrameSetPoint(StatsList[stat], FRAMEPOINT_LEFT, new_frame, FRAMEPOINT_LEFT, 0.01, 0.)
        --BlzFrameSetPoint(StatsList[stat], FRAMEPOINT_RIGHT, new_frame, FRAMEPOINT_RIGHT, 0., 0.)
        --BlzFrameSetAllPoints(StatsList[stat], new_frame)
        BlzFrameSetSize(StatsList[stat], 0.08, 0.03)
        BlzFrameSetText(StatsList[stat], text)
        BlzFrameSetTextAlignment(StatsList[stat], TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_LEFT )
        BlzFrameSetScale(StatsList[stat], scale)
        return new_frame
    end


    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    local function NewStatData(player, stat, trg, button)
        MainStatButtons[player].frames[GetHandleId(button)] = {}
        MainStatButtons[player].frames[stat] = button
        MainStatButtons[player].frames[GetHandleId(button)].stat = stat
        MainStatButtons[player].frames[GetHandleId(button)].allocated = 0
        BlzTriggerRegisterFrameEvent(trg, button, FRAMEEVENT_CONTROL_CLICK)
    end



    local function StatButtonClick()
        local id = GetPlayerId(GetTriggerPlayer())+ 1
        local button = BlzGetTriggerFrame()
        local h = GetHandleId(button)

        ModifyStat(PlayerHero[id], MainStatButtons[id].frames[h].stat, 1, STRAIGHT_BONUS, true)
        MainStatButtons[id].frames[h].allocated = MainStatButtons[id].frames[h].allocated + 1
        MainStatButtons[id].points = MainStatButtons[id].points - 1
        if MainStatButtons[id].points <= 0 then
            for i = STR_STAT, VIT_STAT do
                BlzFrameSetVisible(MainStatButtons[id].frames[i], false)
                BlzFrameSetEnable(MainStatButtons[id].frames[i], false)
            end
        end
    end


    function AddPointsToPlayer(player, count)
        MainStatButtons[player].points = MainStatButtons[player].points + count
        for i = STR_STAT, VIT_STAT do
            BlzFrameSetVisible(MainStatButtons[player].frames[i], true)
            BlzFrameSetEnable(MainStatButtons[player].frames[i], true)
        end
    end


    local function DrawInterface(player)
        local new_frame
        local new_subframe
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

        BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.05)
        BlzFrameSetSize(main_frame, 0.29, 0.33)


        local trg = CreateTrigger()
        TriggerAddAction(trg, StatButtonClick)


        MainStatButtons[player] = {
            frames = {stat = 0, allocated = 0},
            points = 4
        }

        new_frame = CreateTextBox("Интеллект:", INT_STAT, 0.085, 0.03, 0.97, main_frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, main_frame)
        CreateTooltip("Основная характеристика", "Каждая еденица повышает магическое подавление на 1, влияет на магический урон а так же количество и восстановление магии если вы используете ману.", StatsList[INT_STAT], 0.14, 0.1)
        local button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
        NewStatData(player, INT_STAT, trg, button)


        new_frame = CreateTextBox("Стойкость:", VIT_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        CreateTooltip("Основная характеристика", "Повышает здоровье и ее восстановление.", StatsList[VIT_STAT], 0.1, 0.08)
        button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
        NewStatData(player, VIT_STAT, trg, button)


        new_frame = CreateTextBox("Ловкость:", AGI_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        CreateTooltip("Основная характеристика", "Каждая еденица повышает защиту на 2.", StatsList[AGI_STAT], 0.1, 0.06)
        button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
        NewStatData(player, AGI_STAT, trg, button)


        new_frame = CreateTextBox("Сила:", STR_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        CreateTooltip("Основная характеристика", "Влияет на силу физических атак.", StatsList[STR_STAT], 0.1, 0.06)
        button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
        NewStatData(player, STR_STAT, trg, button)




        new_frame = CreateTextBox("Физ. урон: 1234", PHYSICAL_ATTACK, 0.1, 0.03, 1., main_frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.025, -0.022, main_frame)

        new_subframe = CreateTextBox("Защита: 1234", PHYSICAL_DEFENCE, 0.1, 0.03, 1., main_frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.025, -0.022, main_frame)
        --RegisterConstructor(new_subframe, 0.1, 0.03)

        new_frame = CreateTextBox("Маг. урон: 1234", MAGICAL_ATTACK, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame)
        new_subframe = CreateTextBox("Подавление: 1234", MAGICAL_SUPPRESSION, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame)

        new_frame = CreateTextBox("Крит. шанс: 100%%", CRIT_CHANCE, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame)
        new_subframe = CreateTextBox("Атак в сек.: 1234", ATTACK_SPEED, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame)



        new_frame = CreateTextBox("Тьма: 100", DARKNESS_RESIST, 0.07, 0.02, 1., main_frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02, main_frame)
        new_subframe = CreateTextBox("Свет: 100", HOLY_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame)

        new_frame = CreateTextBox("Яд: 100", POISON_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        new_subframe = CreateTextBox("Тайное: 100", ARCANE_RESIST, 0.07, 0.02, 0.99, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame)

        new_frame = CreateTextBox("Лед: 100", ICE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        new_subframe = CreateTextBox("Молния: 100", LIGHTNING_RESIST, 0.07, 0.02, 0.96, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame)

        new_frame = CreateTextBox("Физ: 100", PHYSICAL_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame)
        new_subframe = CreateTextBox("Огонь: 100", FIRE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame)







        --RegisterConstructor(main_frame, 0.29, 0.33)
        BlzFrameSetVisible(main_frame, false)
        PlayerStatsFrame[player] = main_frame
    end



    function StatsPanelInit()


        DrawInterface(1)

        CharButton = NewButton("ReplaceableTextures\\CommandButtons\\BTNTomeRed.blp", 0.03, 0.03, GAME_UI, FRAMEPOINT_LEFT, FRAMEPOINT_LEFT, 0., -0.12, GAME_UI)

        CreateTooltip("Характеристики", "Повышение и отслеживание характеристик", CharButton, 0.14, 0.06)

        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, CharButton, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, function()

            BlzFrameSetVisible(PlayerStatsFrame[GetPlayerId(GetTriggerPlayer()) + 1], not BlzFrameIsVisible(PlayerStatsFrame[GetPlayerId(GetTriggerPlayer()) + 1]))

        end)

        TimerStart(CreateTimer(), UPDATE, true, Update)
        --RegisterConstructor(PlayerStatsFrame[1], 0.2, 0.2)

    end

end

