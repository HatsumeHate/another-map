do


local FramePack


function ReloadUI()
		DelayAction(0., function()
			GAME_UI     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        WORLD_FRAME = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
			CrtFrm()
		end)
	end


function NewFrame(path, pointx, pointy, offsetx, offsety, scale)
        local button = BlzCreateFrame('ScriptDialogButton', GAME_UI, 0, 0)
        BlzFrameSetAbsPoint(button, FRAMEPOINT_CENTER, pointx, pointy)
        BlzFrameSetSize(button, 0.0435, 0.0435)

        local new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", GAME_UI, "",0)
                BlzFrameSetAllPoints(new_Frame, button)
                BlzFrameSetTexture(new_Frame, "ReplaceableTextures\\CommandButtons\\BTNFootman.blp", 0, true)
                FramePack.frame = new_Frame

        local sprite = BlzCreateFrameByType("SPRITE", "justAName", new_Frame, "WarCraftIIILogo", 0)
            BlzFrameClearAllPoints(sprite)
            --BlzFrameSetAllPoints(sprite, new_Frame)
            BlzFrameSetPoint(sprite, FRAMEPOINT_BOTTOMLEFT, new_Frame, FRAMEPOINT_BOTTOMLEFT, offsetx, offsety)
            BlzFrameSetSize(sprite, 1., 1.)
            BlzFrameSetScale(sprite, scale)
            BlzFrameSetModel(sprite, path, 0)

	end


function CrtFrm()
    local button = BlzCreateFrame('ScriptDialogButton', GAME_UI, 0, 0)
    BlzFrameSetAbsPoint(button, FRAMEPOINT_CENTER, 0.3, 0.4)
    BlzFrameSetSize(button, 0.0435, 0.0435)

    local new_Frame = BlzCreateFrameByType('BACKDROP', "PORTRAIT", GAME_UI, "",0)
			BlzFrameSetAllPoints(new_Frame, button)
			BlzFrameSetTexture(new_Frame, "ReplaceableTextures\\CommandButtons\\BTNFootman.blp", 0, true)
			FramePack.frame = new_Frame

		local sprite = BlzCreateFrameByType("SPRITE", "justAName", new_Frame, "WarCraftIIILogo", 0)
        BlzFrameClearAllPoints(sprite)
        --BlzFrameSetAllPoints(sprite, new_Frame)
       	--BlzFrameSetPoint(sprite, FRAMEPOINT_BOTTOMLEFT, new_Frame, FRAMEPOINT_BOTTOMLEFT, -0.0052, -0.0052)
       	BlzFrameSetSize(sprite, 1., 1.)
       	BlzFrameSetScale(sprite, 0.8)
       	BlzFrameSetModel(sprite, "war3mapImported\\blue_energy_sprite.mdx", 0)

	end


local InitGlobalsOrigin = InitGlobals

	function InitGlobals()
		InitGlobalsOrigin()

		BasicFramesInit()
		UtilsInit()

		FramePack = {}



		local LoadTrigger = CreateTrigger()
        	TriggerRegisterGameEvent(LoadTrigger, EVENT_GAME_LOADED)
        	TriggerAddAction(LoadTrigger, ReloadUI)


		RegisterTestCommand("frm", function()
			--NewFrame("war3mapImported\\aganim_sprite.mdx", 0.12, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\blizzard_sprite.mdx", 0.18, 0.4, 0., 0., 0.68)
			--NewFrame("war3mapImported\\violet_border_sprite.mdx", 0.24, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\blue_energy_sprite.mdx", 0.30, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\crystallid_sprite.mdx", 0.36, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\cyber_call_sprite.mdx", 0.42, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\damned_sprite.mdx", 0.48, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\exploder_sprite.mdx", 0.54, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\flame_border_sprite.mdx", 0.60, 0.4, -0.0044, -0.001, 0.8)
			--NewFrame("war3mapImported\\frozen_sprite.mdx", 0.66, 0.4, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\gold_sprite.mdx", 0.72, 0.4, 0., 0., 0.68)
			--NewFrame("war3mapImported\\hearts_sprite.mdx", 0.12, 0.3, 0., 0., 0.68)
			--NewFrame("war3mapImported\\holylight_sprite.mdx", 0.18, 0.3, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\inner_fire_and_smoke_sprite.mdx", 0.242, 0.3, 0., 0., 0.68)
			--NewFrame("war3mapImported\\inner_flame_border_sprite.mdx", 0.30, 0.3, 0., 0., 0.68)
			--NewFrame("war3mapImported\\necrotic_circle_sprite.mdx", 0.36, 0.3, -0.004, -0.004, 0.8)
			--NewFrame("war3mapImported\\neon_sprite.mdx", 0.42, 0.3, -0.0052, -0.0048, 0.8)
			--NewFrame("war3mapImported\\smoke_sprite.mdx", 0.48, 0.3, 0., 0., 0.68)
			--NewFrame("war3mapImported\\undead_circle_sprite.mdx", 0.54, 0.3, -0.004, -0.004, 0.8)
			--NewFrame("war3mapImported\\vampirism_sprite.mdx", 0.60, 0.3, -0.0052, -0.0052, 0.8)
			NewFrame("war3mapImported\\LexiumCrystal.mdx", 0.60, 0.3, -0.0052, -0.0052, 0.001)
			--BlzFrameSetTexture(FramePack.frame, "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp", 0, true)
		end)
end

end