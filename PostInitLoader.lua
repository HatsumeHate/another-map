do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
		
		-- заворачиваем всё в таймер, чтоб сообщения попали в Журнал (F12)
		TimerStart(CreateTimer(), 0, false, function()
			--[[
			print('Проверяем эффекты')
			print('=================')
			local raw  = 'I000'
			local DATA = ITEM_TEMPLATE_DATA[FourCC(raw)]
			if DATA == nil then
				print('ОШИБКА: ', raw)
				return
			else
				print('РАБОТАЕТ: ', raw)
				print('=================')
			end
			
			for k, v in pairs(DATA) do
				print(k, v)
			end
			print('=================')
			print('БОНУСОВ', #DATA.BONUS)
			for i = 1, #DATA.BONUS do
				for name, value in pairs(DATA.BONUS[i]) do
					print(name, value)
				end
			end
			]]
			print('=================')
			print("ЭФФЕКТЫ")
			print(EffectsData[1].name)
			print(EffectsData[1].level[1].Power)
			print(GetParameterName(EffectsData[1].level[1].Attribute))
			print('=================')
			print("ПРЕДМЕТЫ")
			print(ITEM_TEMPLATE_DATA[FourCC('I000')].NAME)
			print('=================')
			local my_item = CreateCustomItem('I000', GetRectCenterX(gg_rct_test), GetRectCenterY(gg_rct_test))
			
			print(ITEM_DATA[GetHandleId(my_item)].NAME)
		end)
	end
end