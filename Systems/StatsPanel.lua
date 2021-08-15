do

    STAT_PANEL_UPDATE = 0.3
    PlayerStatsFrame = 0
    StatsList = 0
    PlayerHero = 0
    MainStatButtons = 0
    CharButton = 0


    function StatPanelUpdate()
        for i = 1, 6 do
            if PlayerHero[i] then
                local data = GetUnitData(PlayerHero[i])
                BlzFrameSetText(StatsList[i][STR_STAT], LOCALE_LIST[my_locale].STAT_PANEL_STR.. data.stats[STR_STAT].value)
                BlzFrameSetText(StatsList[i][INT_STAT], LOCALE_LIST[my_locale].STAT_PANEL_INT.. data.stats[INT_STAT].value)
                BlzFrameSetText(StatsList[i][VIT_STAT], LOCALE_LIST[my_locale].STAT_PANEL_VIT.. data.stats[VIT_STAT].value)
                BlzFrameSetText(StatsList[i][AGI_STAT], LOCALE_LIST[my_locale].STAT_PANEL_AGI.. data.stats[AGI_STAT].value)

                BlzFrameSetText(StatsList[i][PHYSICAL_ATTACK], LOCALE_LIST[my_locale].STAT_PANEL_PHYS_ATTACK.. R2I(data.stats[PHYSICAL_ATTACK].value))
                BlzFrameSetText(StatsList[i][PHYSICAL_DEFENCE], LOCALE_LIST[my_locale].STAT_PANEL_PHYS_DEFENCE.. R2I(data.stats[PHYSICAL_DEFENCE].value))
                BlzFrameSetText(StatsList[i][MAGICAL_ATTACK], LOCALE_LIST[my_locale].STAT_PANEL_MAG_ATTACK.. R2I(data.stats[MAGICAL_ATTACK].value))
                BlzFrameSetText(StatsList[i][MAGICAL_SUPPRESSION], LOCALE_LIST[my_locale].STAT_PANEL_MAG_DEFENCE.. R2I(data.stats[MAGICAL_SUPPRESSION].value))
                BlzFrameSetText(StatsList[i][ATTACK_SPEED], LOCALE_LIST[my_locale].STAT_PANEL_ATTACK_SPEED.. string.format('%%.2f', data.stats[ATTACK_SPEED].value))
                BlzFrameSetText(StatsList[i][CRIT_CHANCE], LOCALE_LIST[my_locale].STAT_PANEL_CRIT_CHANCE..  math.floor(ParamToPercent(data.stats[CRIT_CHANCE].value, CRIT_CHANCE)) .. "%%")

                BlzFrameSetText(StatsList[i][PHYSICAL_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_PHYSICAL.. data.stats[PHYSICAL_RESIST].value)
                BlzFrameSetText(StatsList[i][FIRE_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_FIRE.. data.stats[FIRE_RESIST].value)
                BlzFrameSetText(StatsList[i][ICE_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_ICE.. data.stats[ICE_RESIST].value)
                BlzFrameSetText(StatsList[i][LIGHTNING_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_LIGHTNING.. data.stats[LIGHTNING_RESIST].value)
                BlzFrameSetText(StatsList[i][DARKNESS_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_DARKNESS.. data.stats[DARKNESS_RESIST].value)
                BlzFrameSetText(StatsList[i][HOLY_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_HOLY.. data.stats[HOLY_RESIST].value)
                BlzFrameSetText(StatsList[i][POISON_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_POISON.. data.stats[POISON_RESIST].value)
                BlzFrameSetText(StatsList[i][ARCANE_RESIST], LOCALE_LIST[my_locale].STAT_PANEL_ARCANE.. data.stats[ARCANE_RESIST].value)
            end
        end
    end


    function AddToPanel(u, player)
        PlayerHero[player] = u
    end


    local function CreateTextBox(text, stat, size_x, size_y, scale, relative_frame, from, to, offset_x, offset_y, owning_frame, player)
        local new_frame = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', owning_frame, 0, 0)
            BlzFrameSetPoint(new_frame, from, relative_frame, to, offset_x, offset_y)
            BlzFrameSetSize(new_frame, size_x, size_y)

            StatsList[player][stat] = BlzCreateFrameByType("TEXT", "text", new_frame, "", 0)
            BlzFrameSetPoint(StatsList[player][stat], FRAMEPOINT_LEFT, new_frame, FRAMEPOINT_LEFT, 0.01, 0.)
            --BlzFrameSetPoint(StatsList[player][stat], FRAMEPOINT_RIGHT, new_frame, FRAMEPOINT_RIGHT, 0., 0.)
            --BlzFrameSetAllPoints(StatsList[player][stat], new_frame)
            BlzFrameSetSize(StatsList[player][stat], 0.08, 0.03)
            BlzFrameSetText(StatsList[player][stat], text)
            BlzFrameSetTextAlignment(StatsList[player][stat], TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_LEFT )
            BlzFrameSetScale(StatsList[player][stat], scale)
        return new_frame
    end


    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    local function NewStatData(player, stat, trg, button)
        MainStatButtons[player].frames[button] = {}
        MainStatButtons[player].frames[stat] = button
        MainStatButtons[player].frames[button].stat = stat
        MainStatButtons[player].frames[button].allocated = 0
        BlzTriggerRegisterFrameEvent(trg, button, FRAMEEVENT_CONTROL_CLICK)
    end



    local function StatButtonClick()
        local id = GetPlayerId(GetTriggerPlayer())+ 1
        local button = BlzGetTriggerFrame()


            if MainStatButtons[id].points > 0 then
                ModifyStat(PlayerHero[id], MainStatButtons[id].frames[button].stat, 1, STRAIGHT_BONUS, true)
                MainStatButtons[id].frames[button].allocated = MainStatButtons[id].frames[button].allocated + 1
                MainStatButtons[id].points = MainStatButtons[id].points - 1
                BlzFrameSetText(MainStatButtons[id].points_text_frame, MainStatButtons[id].points)

                    if MainStatButtons[id].points <= 0 then
                        BlzFrameSetVisible(MainStatButtons[id].glow_frame, false)
                        MainStatButtons[id].points = 0
                        for i = STR_STAT, VIT_STAT do
                            BlzFrameSetVisible(MainStatButtons[id].frames[i], false)
                            --BlzFrameSetEnable(MainStatButtons[id].frames[i], false)
                            BlzFrameSetVisible(MainStatButtons[id].points_frame, false)
                        end
                    end
            end

    end


    ---@param player integer
    ---@param count integer
    function AddPointsToPlayer(player, count)

        if PlayerHero[player] then
            MainStatButtons[player].points = math.ceil(MainStatButtons[player].points) + math.ceil(count)

            for i = STR_STAT, VIT_STAT do
                if GetLocalPlayer() == Player(player-1) then BlzFrameSetVisible(MainStatButtons[player].frames[i], true) end
                --BlzFrameSetEnable(MainStatButtons[player].frames[i], true)
            end

            if GetLocalPlayer() == Player(player-1) then
                BlzFrameSetVisible(MainStatButtons[player].glow_frame, true)
                BlzFrameSetVisible(MainStatButtons[player].points_frame, true)
            end

            BlzFrameSetText(MainStatButtons[player].points_text_frame, MainStatButtons[player].points)
        end

    end


    function DrawStatsPanelInterface(player)
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


            --local new_FrameGlow = BlzCreateFrameByType("BACKDROP", "ButtonCharges", GlobalButton[player].char_panel_button, "", 0)
            --BlzFrameSetPoint(new_FrameGlow, FRAMEPOINT_BOTTOMLEFT, GlobalButton[player].char_panel_button, FRAMEPOINT_BOTTOMLEFT, 0.002, 0.002)
            --BlzFrameSetSize(new_FrameGlow, 0.012, 0.012)
            --BlzFrameSetTexture(new_FrameGlow, "GUI\\ChargesTexture.blp", 0, true)
            MainStatButtons[player].glow_frame = CreateSprite("UI\\Buttons\\HeroLevel\\HeroLevel.mdx", 0.8, GlobalButton[player].char_panel_button, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.,0., GlobalButton[player].char_panel_button)
            --BlzFrameSetPoint(MainStatButtons[player].glow_frame, FRAMEPOINT_TOPRIGHT, GlobalButton[player].char_panel_button, FRAMEPOINT_TOPRIGHT, 0., 0.)
            BlzFrameSetVisible(MainStatButtons[player].glow_frame, false)

            local new_FrameCharges = BlzCreateFrameByType("BACKDROP", "ButtonCharges", GlobalButton[player].char_panel_button, "", 0)
            BlzFrameSetPoint(new_FrameCharges, FRAMEPOINT_BOTTOMLEFT, GlobalButton[player].char_panel_button, FRAMEPOINT_BOTTOMLEFT, 0.002, 0.002)
            BlzFrameSetSize(new_FrameCharges, 0.012, 0.012)
            BlzFrameSetTexture(new_FrameCharges, "GUI\\ChargesTexture.blp", 0, true)
            MainStatButtons[player].points_frame = new_FrameCharges


            local new_FrameChargesText = BlzCreateFrameByType("TEXT", "ButtonChargesText", new_FrameCharges, "", 0)
            BlzFrameSetAllPoints(new_FrameChargesText, new_FrameCharges)
            BlzFrameSetTextAlignment(new_FrameChargesText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
            BlzFrameSetText(new_FrameChargesText, "")
            --BlzFrameSetSize(new_FrameChargesText, text_size, text_size)
            BlzFrameSetScale(new_FrameCharges, 0.9)
            BlzFrameSetScale(new_FrameChargesText, 0.9)
            MainStatButtons[player].points_text_frame = new_FrameChargesText
            BlzFrameSetVisible(new_FrameCharges, false)

            StatsList[player] = {}

            new_frame = CreateTextBox("Интеллект:", INT_STAT, 0.085, 0.03, 0.97, main_frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_INT_DESC, StatsList[player][INT_STAT], 0.14, 0.1)
            local button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, INT_STAT, trg, button)


            new_frame = CreateTextBox("Стойкость:", VIT_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_VIT_DESC, StatsList[player][VIT_STAT], 0.1, 0.06)
            button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, VIT_STAT, trg, button)


            new_frame = CreateTextBox("Ловкость:", AGI_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_AGI_DESC, StatsList[player][AGI_STAT], 0.1, 0.06)
            button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, AGI_STAT, trg, button)


            new_frame = CreateTextBox("Сила:", STR_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_STR_DESC, StatsList[player][STR_STAT], 0.1, 0.06)
            button = NewButton("ReplaceableTextures\\CommandButtons\\BTNStatUp.blp", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, STR_STAT, trg, button)




            new_frame = CreateTextBox("Физ. урон: 1234", PHYSICAL_ATTACK, 0.1, 0.03, 1., main_frame, FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, 0.025, -0.022, main_frame, player)

            new_subframe = CreateTextBox("Защита: 1234", PHYSICAL_DEFENCE, 0.1, 0.03, 1., main_frame, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPRIGHT, -0.025, -0.022, main_frame, player)
            --RegisterConstructor(new_subframe, 0.1, 0.03)

            new_frame = CreateTextBox("Маг. урон: 1234", MAGICAL_ATTACK, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Подавление: 1234", MAGICAL_SUPPRESSION, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Крит. шанс: 100%%", CRIT_CHANCE, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Атак в сек.: 1234", ATTACK_SPEED, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)



            new_frame = CreateTextBox("Тьма: 100", DARKNESS_RESIST, 0.07, 0.02, 1., main_frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02, main_frame, player)
            new_subframe = CreateTextBox("Свет: 100", HOLY_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Яд: 100", POISON_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Тайное: 100", ARCANE_RESIST, 0.07, 0.02, 0.99, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Лед: 100", ICE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Молния: 100", LIGHTNING_RESIST, 0.07, 0.02, 0.96, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Физ: 100", PHYSICAL_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Огонь: 100", FIRE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)



        --RegisterConstructor(main_frame, 0.29, 0.33)
        PlayerStatsFrame[player] = main_frame
        BlzFrameSetVisible(PlayerStatsFrame[player], false)
    end


    local FirstTime_Data = 0


    function SetStatsPanelState(player, state)

        BlzFrameSetVisible(PlayerStatsFrame[player], state)
        if GetLocalPlayer() ~= Player(player-1) then BlzFrameSetVisible(PlayerStatsFrame[player], false) end

        --BlzFrameSetVisible(PlayerStatsFrame[player], state)
        --BlzFrameSetVisible(SkillPanelFrame[player].main_frame, state)

            if FirstTime_Data[GetPlayerId(GetTriggerPlayer()) + 1].first_time then
                ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_STATS_1, player-1)
                FirstTime_Data[GetPlayerId(GetTriggerPlayer()) + 1].first_time = false
            end

        return state
    end


    function StatsPanelInit()

        PlayerStatsFrame = {}
        StatsList = {}
        PlayerHero = {}
        MainStatButtons = {}

        FirstTime_Data = {
            [1] = { first_time = true },
            [2] = { first_time = true },
            [3] = { first_time = true },
            [4] = { first_time = true },
            [5] = { first_time = true },
            [6] = { first_time = true }
        }

        local timer = CreateTimer()
        TimerStart(timer, STAT_PANEL_UPDATE, true, StatPanelUpdate)


        RegisterTestCommand("stat", function()
            AddPointsToPlayer(1, 5)
            AddPointsToPlayer(2, 5)
        end)

    end

end

