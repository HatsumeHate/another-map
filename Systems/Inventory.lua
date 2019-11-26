do

    local GAME_UI
    local WORLD_FRAME

    MainInventoryWindow = nil
    EquipSlotsFrame = {}


    function ShowInventory()
        BlzFrameSetVisible(MainInventoryWindow.main_frame_parent, not BlzFrameIsVisible(MainInventoryWindow.main_frame_parent))


        if GetLocalPlayer() == GetTriggerPlayer() then
             BlzFrameSetEnable(BlzGetTriggerFrame(), false)
             BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        end

    end




    function InventoryInit()
        GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
        BlzLoadTOCFile("war3mapimported\\BoxedText.toc")



        MainInventoryWindow = {
            main_frame_parent = nil,
            backdrop = nil,

            EquipSlotsWindow =  {
                frame = nil,
                backdrop = nil,
                equip_slots = {}
            },

            InventoryWindow = {
                backdrop = nil,
                slots = {}
            }
        }

        MainInventoryWindow.main_frame_parent = BlzCreateFrameByType('FRAME', '', GAME_UI, '', 0)
        MainInventoryWindow.backdrop = BlzCreateFrame('EscMenuBackdrop', MainInventoryWindow.main_frame_parent, 0, 0)

        BlzFrameSetPoint(MainInventoryWindow.backdrop, FRAMEPOINT_TOPRIGHT, GAME_UI, FRAMEPOINT_TOPRIGHT, 0., -0.05)
        BlzFrameSetSize(MainInventoryWindow.backdrop, 0.4, 0.38)
        BlzFrameSetParent(MainInventoryWindow.backdrop, MainInventoryWindow.main_frame_parent)



        MainInventoryWindow.EquipSlotsWindow.frame = BlzCreateFrameByType('FRAME', '', MainInventoryWindow.backdrop, '', 0)
        MainInventoryWindow.EquipSlotsWindow.backdrop = BlzCreateFrame('EscMenuBackdrop', MainInventoryWindow.backdrop, 0, 0)

        BlzFrameSetPoint(MainInventoryWindow.EquipSlotsWindow.backdrop, FRAMEPOINT_TOPLEFT, MainInventoryWindow.backdrop, FRAMEPOINT_TOPLEFT, 0.02, -0.02)
        BlzFrameSetSize(MainInventoryWindow.EquipSlotsWindow.backdrop, 0.36, 0.14)
        BlzFrameSetParent(MainInventoryWindow.EquipSlotsWindow.backdrop, MainInventoryWindow.main_frame_parent)


        MainInventoryWindow.InventoryWindow.backdrop = BlzCreateFrame('EscMenuBackdrop', MainInventoryWindow.backdrop, 0, 0)
        BlzFrameSetPoint(MainInventoryWindow.InventoryWindow.backdrop, FRAMEPOINT_BOTTOMLEFT, MainInventoryWindow.backdrop, FRAMEPOINT_BOTTOMLEFT, 0.02, 0.02)
        BlzFrameSetParent(MainInventoryWindow.InventoryWindow.backdrop, MainInventoryWindow.main_frame_parent)
        BlzFrameSetSize(MainInventoryWindow.InventoryWindow.backdrop, 0.36, 0.195)

        BlzFrameSetVisible(MainInventoryWindow.main_frame_parent, false)
        
        --TODO everything else. optimize it



        local inv_button_backdrop = BlzCreateFrameByType("BACKDROP", "inventory button backdrop", GAME_UI, "", 0)
        local inv_button_tooltip = BlzCreateFrame("BoxedText", inv_button_backdrop, 150, 0)
        local inv_button_btn = BlzCreateFrameByType("GLUEBUTTON", "inventory button btn", inv_button_backdrop, "HeroSelectorButton", 0)


        BlzFrameSetAbsPoint(inv_button_backdrop, FRAMEPOINT_CENTER, 0.15, 0.2)
        BlzFrameSetAllPoints(inv_button_btn, inv_button_backdrop)

        BlzFrameSetTooltip(inv_button_btn, inv_button_tooltip)
        BlzFrameSetPoint(inv_button_tooltip, FRAMEPOINT_TOPLEFT, inv_button_backdrop, FRAMEPOINT_CENTER, 0, 0)
        BlzFrameSetSize(inv_button_tooltip, 0.11, 0.05)
        BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), "Содержит все ваши вещи и экипировку")--BoxedText has a child showing the text, set that childs Text.
        BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), "Инвентарь")--BoxedText has a child showing the Title-text, set that childs Text.


        BlzFrameSetSize(inv_button_backdrop, 0.04, 0.04)
        BlzFrameSetTexture(inv_button_backdrop, "ReplaceableTextures\\CommandButtons\\BTNDustOfAppearance.blp", 0, true)


        local trg = CreateTrigger()
        BlzTriggerRegisterFrameEvent(trg, inv_button_btn, FRAMEEVENT_CONTROL_CLICK)
        TriggerAddAction(trg, ShowInventory)


        local coords = { x = 0.02, y = -0.02 }
        --local manipulated_frame = MainInventoryFrame[1]


        local update = function ()
            BlzFrameSetPoint(MainInventoryWindow.EquipSlotsWindow.backdrop, FRAMEPOINT_TOPLEFT, MainInventoryWindow.backdrop, FRAMEPOINT_TOPLEFT, coords.x , coords.y)
            --BlzFrameSetSize(MainInventoryWindow.EquipSlotsWindow.backdrop, coords.x, coords.y)
            print(coords.x .. "/" .. coords.y)
        end

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_DOWN_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y - 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_UP_DOWN)
        TriggerAddAction(trg, function()
            coords.y = coords.y + 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_LEFT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x - 0.01
            update()
        end)

        trg = CreateTrigger()
        TriggerRegisterPlayerEvent(trg, Player(0), EVENT_PLAYER_ARROW_RIGHT_DOWN)
        TriggerAddAction(trg, function()
            coords.x = coords.x + 0.01
            update()
        end)

    end

end




