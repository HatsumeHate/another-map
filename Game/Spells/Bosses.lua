---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 30.05.2021 15:47
---
do


    SpiderQueenTrapCount = 0
    local BroodRegions = 0
    local WebRegions = 0


    function SummonTentacle(caster, x, y)
        local angle = GetRandomReal(0., 359.)
        local range = GetRandomReal(50., 250.)
        local max_range = GetMaxAvailableDistance(x, y, angle, range)

            local tentacle = CreateUnit(SECOND_MONSTER_PLAYER, FourCC("u00I"), x + Rx(max_range, angle), y + Ry(max_range, angle), GetRandomReal(0., 359.))
            SetUnitAnimation(tentacle, "birth")
            SafePauseUnit(tentacle, true)
            DelayAction(0.667, function()
                SafePauseUnit(tentacle, false)
                UnitApplyTimedLife(tentacle, 0, 15.)
            end)

    end


    function PoisonBarrage(caster, x, y)
        local timer = CreateTimer()
        local missile_amount = 4
        local angle_delta = 40. / missile_amount
        local throw_angle = AngleBetweenUnitXY(caster, x, y) - 40.


        ThrowMissile(caster, nil, "poison_barrage_missile", nil, GetUnitX(caster), GetUnitY(caster), 0.,0., throw_angle)

            TimerStart(timer, 0.17, true, function()
                if missile_amount > 0 then
                    throw_angle = throw_angle + angle_delta
                    ThrowMissile(caster, nil, "poison_barrage_missile", nil, GetUnitX(caster), GetUnitY(caster), 0.,0., throw_angle)
                    missile_amount = missile_amount - 1
                else
                    DestroyTimer(timer)
                end
            end)

    end


    function SpiderQueen_SpawnBrood(boss)
        --local rect = BroodRegions[GetRandomInt(1, #BroodRegions)]
        local x = GetUnitX(boss); local y = GetUnitY(boss)
        local total_egg_count = GetRandomInt(1, 3)
        --local distance = GetRandomInt(200, 400)


           -- if GetRandomInt(1,2) == 1 then distance = distance * -1 end

            for i = 1, total_egg_count do
                local angle = GetRandomReal(0., 359.)
                local max_range = GetMaxAvailableDistance(x, y, angle, GetRandomInt(250, 500))
                local egg = CreateUnit(SECOND_MONSTER_PLAYER, GetRandomInt(1,2) == 1 and FourCC("speg") or FourCC("speb"), x + Rx(max_range, angle), x + Ry(max_range, angle), GetRandomReal(0., 359.))

                    DelayAction(17., function()
                        if GetUnitState(egg, UNIT_STATE_LIFE) > 0.045 then
                            KillUnit(egg)
                            local spider = CreateUnit(SECOND_MONSTER_PLAYER, FourCC("n00Y"), GetUnitX(egg), GetUnitY(egg), RndAng())
                            DelayAction(0.001, function()
                                local unit_data = GetUnitData(spider)
                                unit_data.classification = 0
                                --ScaleMonsterUnit(spider)
                            end)
                        end
                    end)

            end


    end


    function SpiderQueen_WebTrap(boss)
        local rect = Rect(-16., -16., 16., 16)
        local angle = GetRandomReal(0., 359.)
        local max_range = GetMaxAvailableDistance(GetUnitX(boss), GetUnitY(boss), angle, GetRandomInt(200, 400))

            SpiderQueenTrapCount = SpiderQueenTrapCount + 1

            local x = GetUnitX(boss) + Rx(max_range, angle)
            local y = GetUnitY(boss) + Ry(max_range, angle)

            MoveRectTo(rect, x, y)
            local web_effect = AddSpecialEffect("Abilities\\Spells\\Undead\\Web\\WebTarget.mdx", x, y)
            BlzSetSpecialEffectHeight(web_effect, 84.)
            BlzSetSpecialEffectScale(web_effect, 1.1)

            local trg = CreateTrigger()
            local region = CreateRegion()
            RegionAddRect(region, rect)
            TriggerRegisterEnterRegion(trg, region, nil)
            TriggerAddAction(trg, function()
                if IsUnitEnemy(GetTriggerUnit(), MONSTER_PLAYER) and GetUnitAbilityLevel(GetTriggerUnit(), FourCC("Avul")) == 0 then
                    ApplyBuff(boss, GetTriggerUnit(), "A01T", 1)
                    RemoveRegion(region)
                    RemoveRect(rect)
                    DestroyTrigger(trg)
                    DestroyEffect(web_effect)
                    SpiderQueenTrapCount = SpiderQueenTrapCount - 1
                    trg = nil
                end
            end)

        DelayAction(35., function()
            if trg then
                RemoveRegion(region)
                RemoveRect(rect)
                DestroyTrigger(trg)
                DestroyEffect(web_effect)
                SpiderQueenTrapCount = SpiderQueenTrapCount - 1
            end
        end)

    end


    function CreatePoisonNova(boss)
        local missiles = 9
        local angle = 360. / missiles
        local current_angle = 0.01

            for i = 1, missiles do
                ThrowMissile(boss, nil, 'MAPN', nil, GetUnitX(boss), GetUnitY(boss), 0, 0, current_angle)
                current_angle = current_angle + angle
            end

    end


    function SpawnSkeletons(boss)
        local amount = 5
        local x = GetUnitX(boss); local y = GetUnitY(boss)
        local delay = 0.

        for i = 1, amount do
            local angle = GetRandomReal(0., 359.)
            local max_range = GetMaxAvailableDistance(x, y, angle, GetRandomInt(350, 625))

            DelayAction(delay, function()
                ThrowMissile(boss, nil, 'MSSK', nil, x, y, x + Rx(max_range, angle), y + Ry(max_range, angle), angle)
            end)
            delay = delay + 0.14
        end


    end


    function LightningNovaBoss(boss)
        local amount = 14
        local angle = 360. / amount
        local current_angle = 0.01
        local x = GetUnitX(boss); local y = GetUnitY(boss)

        for i = 1, amount do
            local missile = ThrowMissile(boss, nil, 'MMLN', nil, x, y, 0., 0., current_angle)
            local timer = CreateTimer()
            local timeout = GetRandomReal(0.09, 0.18)
            local missile_angle = current_angle

                TimerStart(timer, 0.025, true, function()
                    if missile.time > 0. then

                        if timeout <= 0. then
                            --print(missile.time)
                            missile_angle = missile_angle + GetRandomReal(-37., 37.)
                            RedirectMissile_Deg(missile, missile_angle)
                            timeout = GetRandomReal(0.09, 0.18)
                            --print("a2")
                        end

                        timeout = timeout - 0.025
                    else
                        DestroyTimer(timer)
                    end
                end)

            current_angle = current_angle + angle
        end


    end


    function SummonCurse(missile)

        DelayAction(4., function()
            if missile and missile.time > 0. then
                missile.time = 0.
            end
        end)

    end

    function MephistoSouls(boss)
        local enemies = CreateGroup()

        local timer = CreateTimer()
        TimerStart(timer, 6., true, function()

            if GetUnitState(boss, UNIT_STATE_LIFE) > 0.045 then

                GroupClear(enemies)
                GroupEnumUnitsInRange(enemies, GetUnitX(boss), GetUnitY(boss), 450., nil)

                for index = BlzGroupGetSize(enemies) - 1, 0, -1 do
                    local picked = BlzGroupUnitAt(enemies, index)
                    if not IsUnitEnemy(picked, MONSTER_PLAYER) or GetUnitState(picked, UNIT_STATE_LIFE) <= 0.045 or GetUnitAbilityLevel(picked, FourCC("Avul")) > 0 then
                        GroupRemoveUnit(enemies, picked)
                    end
                end

                if BlzGroupGetSize(enemies) > 0 then
                    local target = RandomFromGroup(enemies)
                    local ghost = CreateUnit(MONSTER_PLAYER, FourCC("u00H"), GetUnitX(target) + GetRandomReal(-250., 250.), GetUnitY(target) + GetRandomReal(-250., 250.), GetRandomReal(0., 359.))

                    SetUnitVertexColor(ghost, 59, 155, 255, 125)
                    DelayAction(2., function()
                        KillUnit(ghost)
                        ShowUnit(ghost, false)
                    end)

                end
            else
                DestroyGroup(enemies)
                DestroyTimer(GetExpiredTimer())
            end

        end)

    end


    function InitSpiderQueenData()
        BroodRegions = {
            gg_rct_sq_brood_1,
            gg_rct_sq_brood_2,
            gg_rct_sq_brood_3,
        }



        InitMyAI()

    end

    --[[
    - паук
        - плевок ядом по прямой
        - паутина, обездвиживание
        - ловушка паутины
        - укус
        - выводок, призыв
    - бандит
        - чардж, стан
        - боевой кураж, стаки, скорость атаки
        - финт, уменьшение атаки противника
        -
    - арахнид
        - клац, стан
        - волна яда
        - чардж с отталкиванием

    ]]

end

