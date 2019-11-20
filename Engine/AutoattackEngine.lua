do



    function AutoattackInit()
        local trg = CreateTrigger()



            TriggerRegisterAnyUnitEventBJ(trg, EVENT_PLAYER_UNIT_DAMAGED)
            TriggerAddAction(trg, function()

                if BlzGetEventAttackType() == ATTACK_TYPE_MELEE and GetEventDamage() > 0. then
                    local attacker = GetUnitData(GetEventDamageSource())
                    local victim = GetUnitData(GetTriggerUnit())

                        BlzSetEventDamage(0.)


                end

             end)


    end


end






