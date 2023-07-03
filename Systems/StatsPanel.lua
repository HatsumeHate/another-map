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
                BlzFrameSetText(StatsList[i][ATTACK_SPEED], LOCALE_LIST[my_locale].STAT_PANEL_ATTACK_SPEED.. math.floor(data.stats[ATTACK_SPEED].actual_bonus + 0.5) .. "%%")
                BlzFrameSetText(StatsList[i]["ATTACK_SPEED_spec"], LOCALE_LIST[my_locale].STAT_PANEL_ATTACK_SPEED_PERIOD.. string.format('%%.2f', data.stats[ATTACK_SPEED].value))
                BlzFrameSetText(StatsList[i][CAST_SPEED], LOCALE_LIST[my_locale].STAT_PANEL_CAST_SPEED.. math.floor(data.stats[CAST_SPEED].value + 0.5) .. "%%")
                BlzFrameSetText(StatsList[i][CRIT_CHANCE], LOCALE_LIST[my_locale].STAT_PANEL_CRIT_CHANCE..  math.floor(ParamToPercent(data.stats[CRIT_CHANCE].value, CRIT_CHANCE) + 0.5) .. "%%")

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
        local unit_data = GetUnitData(u)
        local portrait = ""

        PlayerHero[player] = u

            if unit_data.unit_class == BARBARIAN_CLASS then portrait = "ReplaceableTextures\\CommandButtons\\BTNBandit.blp"
            elseif unit_data.unit_class == SORCERESS_CLASS then portrait = "war3mapImported\\BTNSorceress.blp"
            elseif unit_data.unit_class == NECROMANCER_CLASS then portrait = "ReplaceableTextures\\CommandButtons\\BTNLichVersion2.blp"
            elseif unit_data.unit_class == ASSASSIN_CLASS then portrait = "ReplaceableTextures\\CommandButtons\\BTNAssassin.blp"
            end

        BlzFrameSetTexture(MainStatButtons[player].portrait, portrait, 0, true)
        BlzFrameSetText(MainStatButtons[player].hero_name, GetHeroProperName(u))
        BlzFrameSetText(MainStatButtons[player].hero_class, GetUnitName(u))
        BlzFrameSetText(MainStatButtons[player].hero_level, "Level 1")

    end

    function StatsPanelUpdateHeroLevel(player)
        BlzFrameSetText(MainStatButtons[player].hero_level, LOCALE_LIST[my_locale].UI_TEXT_LEVEL .. GetHeroLevel(PlayerHero[player]))
    end


    local function CreateTextBox(text, stat, size_x, size_y, scale, relative_frame, from, to, offset_x, offset_y, owning_frame, player)
        local new_frame = BlzCreateFrame('ScoreScreenButtonBackdropTemplate', owning_frame, 0, 0)
            BlzFrameSetPoint(new_frame, from, relative_frame, to, offset_x, offset_y)
            BlzFrameSetSize(new_frame, size_x, size_y)

            StatsList[player][stat] = BlzCreateFrameByType("TEXT", "text", new_frame, "MyTextTemplate", 0)
            BlzFrameSetPoint(StatsList[player][stat], FRAMEPOINT_LEFT, new_frame, FRAMEPOINT_LEFT, 0.01, 0.)
            --BlzFrameSetPoint(StatsList[player][stat], FRAMEPOINT_RIGHT, new_frame, FRAMEPOINT_RIGHT, 0., 0.)
            --BlzFrameSetAllPoints(StatsList[player][stat], new_frame)
            BlzFrameSetSize(StatsList[player][stat], 0.08, 0.03)
            BlzFrameSetText(StatsList[player][stat], text)
            BlzFrameSetTextAlignment(StatsList[player][stat], TEXT_JUSTIFY_MIDDLE , TEXT_JUSTIFY_LEFT )
            BlzFrameSetScale(StatsList[player][stat], scale-0.2)
        return new_frame
    end


    local function NewButton(texture, size_x, size_y, relative_frame, frame_point_from, frame_point_to, offset_x, offset_y, parent_frame)
        local new_Frame = BlzCreateFrame('ScriptDialogButton', parent_frame, 0, 0)
        local new_FrameImage = BlzCreateFrameByType("BACKDROP", "ButtonIcon", new_Frame, "", 0)

            ButtonList[new_Frame] = {
                frame = new_Frame, image = new_FrameImage
            }

            FrameRegisterNoFocus(new_Frame)
            BlzFrameSetPoint(new_Frame, frame_point_from, relative_frame, frame_point_to, offset_x, offset_y)
            BlzFrameSetSize(new_Frame, size_x, size_y)
            BlzFrameSetTexture(new_FrameImage, texture, 0, true)
            FrameRegisterClick(new_Frame, texture)
            BlzFrameSetAllPoints(new_FrameImage, new_Frame)

        return new_Frame
    end


    local function NewStatData(player, stat, button)
        --MainStatButtons[player].main_stat = { }
        --MainStatButtons[player].main_stat[stat] = { allocated = 0 }
        MainStatButtons[player].frames[button] = stat
        MainStatButtons[player].main_stat[stat].button = button
        --MainStatButtons[player].frames[stat] = button
        --MainStatButtons[player].frames[button].stat = stat
        --MainStatButtons[player].frames[button].allocated = 0
        BlzTriggerRegisterFrameEvent(MainStatButtons[player].stat_button_trigger, button, FRAMEEVENT_CONTROL_CLICK)
    end



    local function StatButtonClick()
        local id = GetPlayerId(GetTriggerPlayer())+ 1
        local button = BlzGetTriggerFrame()


            if MainStatButtons[id].points > 0 then
                local stat = MainStatButtons[id].frames[button]
                ModifyStat(PlayerHero[id], stat, 1, STRAIGHT_BONUS, true)
                MainStatButtons[id].main_stat[stat].allocated = MainStatButtons[id].main_stat[stat].allocated + 1
                --MainStatButtons[id].frames[button].allocated = MainStatButtons[id].frames[button].allocated + 1
                MainStatButtons[id].points = MainStatButtons[id].points - 1
                BlzFrameSetText(MainStatButtons[id].points_text_frame, MainStatButtons[id].points)

                    if MainStatButtons[id].points <= 0 then
                        BlzFrameSetVisible(MainStatButtons[id].glow_frame, false)
                        MainStatButtons[id].points = 0
                        for i = STR_STAT, VIT_STAT do
                            BlzFrameSetVisible(MainStatButtons[id].main_stat[i].button, false)
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
                if GetLocalPlayer() == Player(player-1) then
                    BlzFrameSetVisible(MainStatButtons[player].main_stat[i].button, true)
                end
            end

            if GetLocalPlayer() == Player(player-1) then
                BlzFrameSetVisible(MainStatButtons[player].glow_frame, true)
                BlzFrameSetVisible(MainStatButtons[player].points_frame, true)
            end

            BlzFrameSetText(MainStatButtons[player].hero_level, GetLocalString("Уровень ", "Level ") .. GetHeroLevel(PlayerHero[player]))
            BlzFrameSetText(MainStatButtons[player].points_text_frame, MainStatButtons[player].points)
        end

    end


    function ReloadStatsFrames()
        for player = 1, 6 do
            if PlayerHero[player] then

                local new_frame
                local new_subframe
                local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

                    BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.05)
                    BlzFrameSetSize(main_frame, 0.29, 0.36)


                    MainStatButtons[player].description_border = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
                    MainStatButtons[player].portrait_border = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)


                    new_frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", MainStatButtons[player].portrait_border, "",0)
                    BlzFrameSetPoint(new_frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.035, -0.035)
                    BlzFrameSetSize(new_frame, 0.05, 0.05)
                    MainStatButtons[player].portrait = new_frame

                    new_frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT BORDER", MainStatButtons[player].portrait_border, "",0)
                    BlzFrameSetTexture(new_frame, "DiabolicUI_Button_50x50_BorderHighlight.tga", 0, true)
                    BlzFrameSetPoint(new_frame, FRAMEPOINT_TOPRIGHT, MainStatButtons[player].portrait, FRAMEPOINT_TOPRIGHT, 0.009, 0.009)
                    BlzFrameSetPoint(new_frame, FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait, FRAMEPOINT_BOTTOMLEFT, -0.009, -0.009)

                    new_frame = BlzCreateFrameByType("TEXT", "hero name", MainStatButtons[player].portrait_border, "MyTextTemplate", 0)
                    BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    MainStatButtons[player].hero_name = new_frame

                    new_frame = BlzCreateFrameByType("TEXT", "hero class", MainStatButtons[player].portrait_border, "MyTextTemplate", 0)
                    BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    MainStatButtons[player].hero_class = new_frame

                    new_frame = BlzCreateFrameByType("TEXT", "hero level", MainStatButtons[player].description_border, "MyTextTemplate", 0)
                    BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
                    MainStatButtons[player].hero_level = new_frame

                    BlzFrameSetPoint(MainStatButtons[player].portrait_border , FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait, FRAMEPOINT_TOPLEFT, -0.02, 0.02)
                    BlzFrameSetPoint(MainStatButtons[player].portrait_border , FRAMEPOINT_BOTTOMRIGHT, MainStatButtons[player].portrait, FRAMEPOINT_BOTTOMRIGHT, 0.02, -0.02)

                    BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_TOPLEFT, 0., 0.)
                    BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_BOTTOMRIGHT, .0, 0.)

                    BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_RIGHT, main_frame, FRAMEPOINT_RIGHT, -0.015, 0.)


                    BlzFrameSetPoint(MainStatButtons[player].hero_name, FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_TOPRIGHT, 0.005, -0.02)
                    BlzFrameSetPoint(MainStatButtons[player].hero_name, FRAMEPOINT_TOPRIGHT, MainStatButtons[player].description_border, FRAMEPOINT_TOPRIGHT, -0.02, -0.02)
                    BlzFrameSetPoint(MainStatButtons[player].hero_class, FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.02)
                    BlzFrameSetPoint(MainStatButtons[player].hero_level, FRAMEPOINT_BOTTOMRIGHT, MainStatButtons[player].description_border, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02)
                    BlzFrameSetScale(MainStatButtons[player].hero_name, 1.15)



                    MainStatButtons[player].glow_frame = CreateSprite("UI\\Buttons\\HeroLevel\\HeroLevel.mdx", 0.88, GlobalButton[player].char_panel_button, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.,0., GlobalButton[player].char_panel_button)
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
                    BlzFrameSetScale(new_FrameCharges, 0.9)
                    BlzFrameSetScale(new_FrameChargesText, 0.9)
                    MainStatButtons[player].points_text_frame = new_FrameChargesText
                    BlzFrameSetVisible(new_FrameCharges, false)


                    new_frame = CreateTextBox("Интеллект:", INT_STAT, 0.085, 0.03, 0.97, main_frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_INT_DESC, StatsList[player][INT_STAT], 0.14, 0.12)
                    local button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
                    NewStatData(player, INT_STAT, button)
                    --MainStatButtons[player].frames[button] = button
                    --BlzTriggerRegisterFrameEvent(MainStatButtons[player].stat_button_trigger, button, FRAMEEVENT_CONTROL_CLICK)


                    new_frame = CreateTextBox("Стойкость:", VIT_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_VIT_DESC, StatsList[player][VIT_STAT], 0.14, 0.07)
                    button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
                    NewStatData(player, VIT_STAT, button)
                    --MainStatButtons[player].frames[button] = button
                    --BlzTriggerRegisterFrameEvent(MainStatButtons[player].stat_button_trigger, button, FRAMEEVENT_CONTROL_CLICK)


                    new_frame = CreateTextBox("Ловкость:", AGI_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_AGI_DESC, StatsList[player][AGI_STAT], 0.14, 0.12)
                    button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
                    NewStatData(player, AGI_STAT, button)
                    --MainStatButtons[player].frames[button] = button
                    --BlzTriggerRegisterFrameEvent(MainStatButtons[player].stat_button_trigger, button, FRAMEEVENT_CONTROL_CLICK)


                    new_frame = CreateTextBox("Сила:", STR_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_STR_DESC, StatsList[player][STR_STAT], 0.12, 0.1)
                    button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
                    NewStatData(player, STR_STAT, button)
                    --MainStatButtons[player].frames[button] = button
                    --BlzTriggerRegisterFrameEvent(MainStatButtons[player].stat_button_trigger, button, FRAMEEVENT_CONTROL_CLICK)



                    new_frame = CreateTextBox("Физ. урон: 1234", PHYSICAL_ATTACK, 0.1, 0.03, 1., MainStatButtons[player].description_border, FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0.002, 0.0024, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_PHYSICAL_ATTACK_DESC, StatsList[player][PHYSICAL_ATTACK], 0.14, 0.08)

                    new_subframe = CreateTextBox("Защита: 1234", PHYSICAL_DEFENCE, 0.1, 0.03, 1., MainStatButtons[player].description_border, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.0024, main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_PHYSICAL_DEFENCE_DESC, StatsList[player][PHYSICAL_DEFENCE], 0.14, 0.08)

                    new_frame = CreateTextBox("Маг. урон: 1234", MAGICAL_ATTACK, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_MAGICAL_ATTACK_DESC, StatsList[player][MAGICAL_ATTACK], 0.14, 0.08)
                    new_subframe = CreateTextBox("Подавление: 1234", MAGICAL_SUPPRESSION, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
                    CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_MAGICAL_SUPPRESSION_DESC, StatsList[player][MAGICAL_SUPPRESSION], 0.14, 0.09)

                    new_frame = CreateTextBox("Крит. шанс: 100%%", CRIT_CHANCE, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
                    new_frame = CreateTextBox("", ATTACK_SPEED, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
                    new_subframe = CreateTextBox("Атак в сек.: 1234", "ATTACK_SPEED_spec", 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
                    new_frame = CreateTextBox("Атак в сек.: 1234", CAST_SPEED, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)



                    new_frame = CreateTextBox("Тьма: 100", DARKNESS_RESIST, 0.07, 0.02, 1., main_frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02, main_frame, player)
                    new_subframe = CreateTextBox("Свет: 100", HOLY_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

                    new_frame = CreateTextBox("Яд: 100", POISON_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
                    new_subframe = CreateTextBox("Тайное: 100", ARCANE_RESIST, 0.07, 0.02, 0.99, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

                    new_frame = CreateTextBox("Лед: 100", ICE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
                    new_subframe = CreateTextBox("Молния: 100", LIGHTNING_RESIST, 0.07, 0.02, 0.96, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

                    new_frame = CreateTextBox("Физ: 100", PHYSICAL_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
                    new_subframe = CreateTextBox("Огонь: 100", FIRE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)



                PlayerStatsFrame[player] = main_frame
                BlzFrameSetVisible(PlayerStatsFrame[player], false)

                AddToPanel(PlayerHero[player], player)

                if MainStatButtons[player].points > 0 then
                    AddPointsToPlayer(player, 0)
                else
                    StatsPanelUpdateHeroLevel(player)
                end

            end
        end
    end


    function DrawStatsPanelInterface(player)
        local new_frame
        local new_subframe
        local main_frame = BlzCreateFrame('EscMenuBackdrop', GAME_UI, 0, 0)

            BlzFrameSetPoint(main_frame, FRAMEPOINT_TOPLEFT, GAME_UI, FRAMEPOINT_TOPLEFT, 0., -0.05)
            BlzFrameSetSize(main_frame, 0.29, 0.36)


            MainStatButtons[player] = {
                frames = {stat = 0, allocated = 0},
                main_stat = {
                    [STR_STAT] = { allocated = 0, button = nil },
                    [AGI_STAT] = { allocated = 0, button = nil },
                    [VIT_STAT] = { allocated = 0, button = nil },
                    [INT_STAT] = { allocated = 0, button = nil }
                },
                points = 4,
                stat_button_trigger = CreateTrigger()
            }

            --MainStatButtons[player].stat_button_trigger = CreateTrigger()
            TriggerAddAction(MainStatButtons[player].stat_button_trigger, StatButtonClick)

            MainStatButtons[player].description_border = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)
            MainStatButtons[player].portrait_border = BlzCreateFrame('EscMenuBackdrop', main_frame, 0, 0)



            new_frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", MainStatButtons[player].portrait_border, "",0)
            BlzFrameSetPoint(new_frame, FRAMEPOINT_TOPLEFT, main_frame, FRAMEPOINT_TOPLEFT, 0.035, -0.035)
            BlzFrameSetSize(new_frame, 0.05, 0.05)
            MainStatButtons[player].portrait = new_frame

            new_frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT BORDER", MainStatButtons[player].portrait_border, "",0)
            BlzFrameSetTexture(new_frame, "DiabolicUI_Button_50x50_BorderHighlight.tga", 0, true)
            BlzFrameSetPoint(new_frame, FRAMEPOINT_TOPRIGHT, MainStatButtons[player].portrait, FRAMEPOINT_TOPRIGHT, 0.009, 0.009)
            BlzFrameSetPoint(new_frame, FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait, FRAMEPOINT_BOTTOMLEFT, -0.009, -0.009)

            new_frame = BlzCreateFrameByType("TEXT", "hero name", MainStatButtons[player].portrait_border, "MyTextTemplate", 0)
            BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            MainStatButtons[player].hero_name = new_frame

            new_frame = BlzCreateFrameByType("TEXT", "hero class", MainStatButtons[player].portrait_border, "MyTextTemplate", 0)
            BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            MainStatButtons[player].hero_class = new_frame

            new_frame = BlzCreateFrameByType("TEXT", "hero level", MainStatButtons[player].description_border, "MyTextTemplate", 0)
            BlzFrameSetTextAlignment(new_frame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
            MainStatButtons[player].hero_level = new_frame

            BlzFrameSetPoint(MainStatButtons[player].portrait_border , FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait, FRAMEPOINT_TOPLEFT, -0.02, 0.02)
            BlzFrameSetPoint(MainStatButtons[player].portrait_border , FRAMEPOINT_BOTTOMRIGHT, MainStatButtons[player].portrait, FRAMEPOINT_BOTTOMRIGHT, 0.02, -0.02)

            BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_TOPLEFT, 0., 0.)
            BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_BOTTOMRIGHT, .0, 0.)

            BlzFrameSetPoint(MainStatButtons[player].description_border , FRAMEPOINT_RIGHT, main_frame, FRAMEPOINT_RIGHT, -0.015, 0.)


            BlzFrameSetPoint(MainStatButtons[player].hero_name, FRAMEPOINT_TOPLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_TOPRIGHT, 0.005, -0.02)
            BlzFrameSetPoint(MainStatButtons[player].hero_name, FRAMEPOINT_TOPRIGHT, MainStatButtons[player].description_border, FRAMEPOINT_TOPRIGHT, -0.02, -0.02)
            BlzFrameSetPoint(MainStatButtons[player].hero_class, FRAMEPOINT_BOTTOMLEFT, MainStatButtons[player].portrait_border, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.02)
            BlzFrameSetPoint(MainStatButtons[player].hero_level, FRAMEPOINT_BOTTOMRIGHT, MainStatButtons[player].description_border, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02)
            BlzFrameSetScale(MainStatButtons[player].hero_name, 1.15)



            MainStatButtons[player].glow_frame = CreateSprite("UI\\Buttons\\HeroLevel\\HeroLevel.mdx", 0.88, GlobalButton[player].char_panel_button, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.,0., GlobalButton[player].char_panel_button)
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
            BlzFrameSetScale(new_FrameCharges, 0.9)
            BlzFrameSetScale(new_FrameChargesText, 0.9)
            MainStatButtons[player].points_text_frame = new_FrameChargesText
            BlzFrameSetVisible(new_FrameCharges, false)

            StatsList[player] = {}

            new_frame = CreateTextBox("Интеллект:", INT_STAT, 0.085, 0.03, 0.97, main_frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_INT_DESC, StatsList[player][INT_STAT], 0.14, 0.12)
            local button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, INT_STAT, button)


            new_frame = CreateTextBox("Стойкость:", VIT_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_VIT_DESC, StatsList[player][VIT_STAT], 0.14, 0.07)
            button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, VIT_STAT, button)


            new_frame = CreateTextBox("Ловкость:", AGI_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_AGI_DESC, StatsList[player][AGI_STAT], 0.14, 0.12)
            button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, AGI_STAT, button)


            new_frame = CreateTextBox("Сила:", STR_STAT, 0.085, 0.03, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., -0.002, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MAIN_STAT, LOCALE_LIST[my_locale].STAT_PANEL_STR_DESC, StatsList[player][STR_STAT], 0.12, 0.1)
            button = NewButton("DiabolicUI_Button_51x51_Pushed.tga", 0.022, 0.022, new_frame, FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0.0, 0, new_frame)
            NewStatData(player, STR_STAT, button)




            new_frame = CreateTextBox("Физ. урон: 1234", PHYSICAL_ATTACK, 0.1, 0.03, 1., MainStatButtons[player].description_border, FRAMEPOINT_TOPLEFT, FRAMEPOINT_BOTTOMLEFT, 0.002, 0.0024, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_PHYSICAL_ATTACK_DESC, StatsList[player][PHYSICAL_ATTACK], 0.14, 0.08)

            new_subframe = CreateTextBox("Защита: 1234", PHYSICAL_DEFENCE, 0.1, 0.03, 1., MainStatButtons[player].description_border, FRAMEPOINT_TOPRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.002, 0.0024, main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_PHYSICAL_DEFENCE_DESC, StatsList[player][PHYSICAL_DEFENCE], 0.14, 0.08)
            --RegisterConstructor(new_subframe, 0.1, 0.03)

            new_frame = CreateTextBox("Маг. урон: 1234", MAGICAL_ATTACK, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_MAGICAL_ATTACK_DESC, StatsList[player][MAGICAL_ATTACK], 0.14, 0.08)
            new_subframe = CreateTextBox("Подавление: 1234", MAGICAL_SUPPRESSION, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            CreateTooltip(LOCALE_LIST[my_locale].STAT_PANEL_MINOR_STAT, LOCALE_LIST[my_locale].STAT_PANEL_MAGICAL_SUPPRESSION_DESC, StatsList[player][MAGICAL_SUPPRESSION], 0.14, 0.09)

            new_frame = CreateTextBox("Крит. шанс: 100%%", CRIT_CHANCE, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            new_frame = CreateTextBox("", ATTACK_SPEED, 0.1, 0.03, 1., new_frame, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Атак в сек.: 1234", "ATTACK_SPEED_spec", 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)
            new_frame = CreateTextBox("Атак в сек.: 1234", CAST_SPEED, 0.1, 0.03, 1., new_subframe, FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0., 0., main_frame, player)



            new_frame = CreateTextBox("Тьма: 100", DARKNESS_RESIST, 0.07, 0.02, 1., main_frame, FRAMEPOINT_BOTTOMRIGHT, FRAMEPOINT_BOTTOMRIGHT, -0.02, 0.02, main_frame, player)
            new_subframe = CreateTextBox("Свет: 100", HOLY_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Яд: 100", POISON_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Тайное: 100", ARCANE_RESIST, 0.07, 0.02, 0.99, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Лед: 100", ICE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Молния: 100", LIGHTNING_RESIST, 0.07, 0.02, 0.96, new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)

            new_frame = CreateTextBox("Физ: 100", PHYSICAL_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0., 0., main_frame, player)
            new_subframe = CreateTextBox("Огонь: 100", FIRE_RESIST, 0.07, 0.02, 1., new_frame, FRAMEPOINT_RIGHT, FRAMEPOINT_LEFT, 0., 0., main_frame, player)



        PlayerStatsFrame[player] = main_frame
        BlzFrameSetVisible(PlayerStatsFrame[player], false)
    end


    local FirstTime_Data = 0


    function SetStatsPanelState(player, state)

        BlzFrameSetVisible(PlayerStatsFrame[player], state)
        if GetLocalPlayer() ~= Player(player-1) then BlzFrameSetVisible(PlayerStatsFrame[player], false) end

        if state then
            if FirstTime_Data[GetPlayerId(GetTriggerPlayer()) + 1].first_time then
                ShowQuestHintForPlayer(LOCALE_LIST[my_locale].HINT_STATS_1, player-1)
                FirstTime_Data[GetPlayerId(GetTriggerPlayer()) + 1].first_time = false
                AddJournalEntry(player, "hints", "UI\\BTNLeatherbound_TomeI.blp", GetLocalString("Подсказки", "Hints and Tips"), 1000)
                AddJournalEntryText(player, "hints", QUEST_HINT_STRING .. LOCALE_LIST[my_locale].HINT_STATS_1, true)
            end
        end

        return state
    end


    function StatsPanelInit()

        PlayerStatsFrame = {}
        StatsList = {}
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


    end

end

