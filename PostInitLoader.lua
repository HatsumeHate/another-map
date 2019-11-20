do
	local InitGlobalsOrigin = InitGlobals
	
	function InitGlobals()
		InitGlobalsOrigin()
		
		DefineSkillsData()
		DefineEffectsData()
        DefineItemsData()
		
		-- заворачиваем всё в таймер, чтоб сообщения попали в Журнал (F12)
        --[[
		TimerStart(CreateTimer(), 0, false, function()

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
		]]


		print(GetUnitName(gg_unit_HBRB_0005))
        print("crit chance? " .. ITEM_TEMPLATE_DATA[FourCC('0000')].CRIT_CHANCE)

		NewUnitData(gg_unit_HBRB_0005, BARBARIAN_CLASS,
				{
				 	health = 2900,
				},
				{
                    ATTACK_SPEED = 5.
				}
		)

        --UpdateParameters(UnitsData[GetHandleId(gg_unit_HBRB_0005)])

		print(UnitsData[GetHandleId(gg_unit_HBRB_0005)].base_stats.HP)

	end
end