---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MSI.
--- DateTime: 10.06.2022 22:56
---
do

    local ceil = 8.


    function DestroyVisual(pack)
        if pack then
            for i = 1, #pack.images do DestroyImage(pack.images[i]) end
            if pack.arrow then BlzSetSpecialEffectAlpha(pack.arrow, 0); DestroyEffect(pack.arrow) end
            DestroyTimer(pack.timer)
        end
    end


    ---@param range real
    ---@param unit unit
    ---@return table
    function CreateRadiusVisual(range, unit)
        local x, y = GetUnitX(unit), GetUnitY(unit)
        local z = GetZ(x, y)
        local r = range
        range = range * 2.
        local visualizer = { images = {}}
        local image = CreateImage("RangeIndicator.blp", range, range, range, x - r, y - r, z, 0., 0., 0., 2)

            visualizer.images[1] = image
            SetImageColor(image, 100, 100, 255, 128)
            SetImageRenderAlways(image, true)
            ShowImage(image, GetLocalPlayer() == GetOwningPlayer(unit))

            visualizer.timer = CreateTimer()
            TimerStart(visualizer.timer, 0.03, true, function()
                x, y = GetUnitX(unit), GetUnitY(unit)
                SetImagePosition(visualizer.images[1], x - r, y - r, z - r)
            end)

        return visualizer
    end



    ---@param range real
    ---@param unit unit
    ---@param angle_window real
    ---@param facing_angle real
    ---@return table
    function CreateArcAreaVisual(range, unit, angle_window)
        local x, y = GetUnitX(unit), GetUnitY(unit)
        local facing_angle = GetUnitFacing(unit)
        range = range * 1.05
        local half_angle = angle_window / 2.
        local step = math.floor((range / ceil) + 0.5)
        local visualizer = { images = {}}
        local l_angle = facing_angle+half_angle
        local r_angle = facing_angle-half_angle
        local scale = ceil * 2.

            for i = 1, step do
                local pointx, pointy = x + Rx(ceil*(i), r_angle), y + Ry(ceil*(i), r_angle)
                local pointz = GetZ(pointx, pointy)

                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)

                    pointx, pointy = x + Rx(ceil*(i), l_angle), y + Ry(ceil*(i), l_angle)
                    pointz = GetZ(pointx, pointy)
                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)
            end

            l_angle = l_angle + 360.
            r_angle = r_angle + 360.

            local current_arc = r_angle
            local arc_images = 0

            while(current_arc < l_angle)do
                local pointx, pointy = x + Rx(range, current_arc), y + Ry(range, current_arc)
                local pointz = GetZ(pointx, pointy)
                visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)
                current_arc = current_arc + 2.
                arc_images = arc_images + 1
            end

        for i = 1, #visualizer.images do
            SetImageColor(visualizer.images[i], 0, 255, 0, 128)
            SetImageRenderAlways(visualizer.images[i], true)
            ShowImage(visualizer.images[i], GetLocalPlayer() == GetOwningPlayer(unit))
        end

        visualizer.timer = CreateTimer()
        local num = #visualizer.images - arc_images
        TimerStart(visualizer.timer, 0.03, true, function()
            x, y = GetUnitX(unit), GetUnitY(unit)
            facing_angle = GetUnitFacing(unit)
            l_angle = facing_angle+half_angle
            r_angle = facing_angle-half_angle

            for i = 1, step do
                local pointx, pointy = x + Rx(ceil*(i), r_angle), y + Ry(ceil*(i), r_angle)
                local pointz = GetZ(pointx, pointy)

                    SetImagePosition(visualizer.images[i], pointx - ceil, pointy - ceil, pointz - ceil)

                    pointx, pointy = x + Rx(ceil*(i), l_angle), y + Ry(ceil*(i), l_angle)
                    pointz = GetZ(pointx, pointy)
                    SetImagePosition(visualizer.images[num-(i-1)], pointx - ceil, pointy - ceil, pointz - ceil)
            end

            current_arc = r_angle
            for i = 1, arc_images do
                local pointx, pointy = x + Rx(range, current_arc), y + Ry(range, current_arc)
                local pointz = GetZ(pointx, pointy)

                    SetImagePosition(visualizer.images[num+i], pointx - ceil, pointy - ceil, pointz - ceil)
                    current_arc = current_arc + 2.
            end
        end)

        return visualizer
    end



    ---@param range real
    ---@param unit unit
    ---@param width real
    ---@param facing_angle real
    ---@return table
    function CreateStraightVisual(range, unit, width, facing_angle)
        local x, y = GetUnitX(unit), GetUnitY(unit)
        local scale = ceil * 2.
        local step = math.floor((range / ceil) + 0.5) - 3
        local visualizer = { images = {}}
        width = width / 2.
        local lx, ly = x + Rx(width, facing_angle + 90.), y + Ry(width, facing_angle + 90.)
        local rx, ry = x + Rx(width, facing_angle - 90.), y + Ry(width, facing_angle - 90.)
        local last_x_l, last_y_l, last_x_r, last_y_r


            for i = 1, step do
                local pointx, pointy = lx + Rx(ceil*(i), facing_angle), ly + Ry(ceil*(i), facing_angle)
                local pointz = GetZ(pointx, pointy)

                    last_x_l, last_y_l = pointx, pointy
                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)

                    pointx, pointy = rx + Rx(ceil*(i), facing_angle), ry + Ry(ceil*(i), facing_angle)
                    pointz = GetZ(pointx, pointy)
                    last_x_r, last_y_r = pointx, pointy

                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)
            end

            local stick_num = step * 2
            local arr_num = math.floor(width/ceil + 0.5)+2
            local l_shift = facing_angle - 45
            local r_shift = facing_angle + 45

            for i = 1, arr_num do
                local pointx, pointy = last_x_l + Rx(ceil*(i), l_shift), last_y_l + Ry(ceil*(i), l_shift)
                local pointz = GetZ(pointx, pointy)

                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)

                    pointx, pointy = last_x_r + Rx(ceil*(i), r_shift), last_y_r + Ry(ceil*(i), r_shift)
                    pointz = GetZ(pointx, pointy)

                    visualizer.images[#visualizer.images+1] = CreateImage("pointerORIG.dds", scale, scale, 0., pointx - ceil, pointy - ceil, pointz - ceil, 0., 0., pointz, 2)
            end

        local arr_total = arr_num * 2

        for i = 1, #visualizer.images do
            SetImageColor(visualizer.images[i], 0, 255, 0, 128)
            SetImageRenderAlways(visualizer.images[i], true)
            ShowImage(visualizer.images[i], GetLocalPlayer() == GetOwningPlayer(unit))
        end

        visualizer.timer = CreateTimer()
        local num = stick_num

        TimerStart(visualizer.timer, 0.03, true, function()
            local pointx, pointy, pointz

                x, y = GetUnitX(unit), GetUnitY(unit)
                facing_angle = GetUnitFacing(unit)
                l_shift = facing_angle - 45
                r_shift = facing_angle + 45
                lx, ly = x + Rx(width, facing_angle + 90.), y + Ry(width, facing_angle + 90.)
                rx, ry = x + Rx(width, facing_angle - 90.), y + Ry(width, facing_angle - 90.)


                    for i = 1, step do
                        pointx, pointy = lx + Rx(ceil*(i), facing_angle), ly + Ry(ceil*(i), facing_angle)
                        pointz = GetZ(pointx, pointy)
                        last_x_l, last_y_l = pointx, pointy
                        SetImagePosition(visualizer.images[i], pointx - ceil, pointy - ceil, pointz - ceil)

                        pointx, pointy = rx + Rx(ceil*(i), facing_angle), ry + Ry(ceil*(i), facing_angle)
                        pointz = GetZ(pointx, pointy)
                        last_x_r, last_y_r = pointx, pointy
                        SetImagePosition(visualizer.images[num-(i-1)], pointx - ceil, pointy - ceil, pointz - ceil)
                    end

                    for i = 1, arr_num do
                        pointx, pointy = last_x_l + Rx(ceil*(i-1), l_shift), last_y_l + Ry(ceil*(i-1), l_shift)
                        pointz = GetZ(pointx, pointy)
                        SetImagePosition(visualizer.images[num+i], pointx - ceil, pointy - ceil, pointz - ceil)

                        pointx, pointy = last_x_r + Rx(ceil*(i-1), r_shift), last_y_r + Ry(ceil*(i-1), r_shift)
                        pointz = GetZ(pointx, pointy)
                        SetImagePosition(visualizer.images[num+arr_total-(i-1)], pointx - ceil, pointy - ceil, pointz - ceil)
                    end


        end)


        return visualizer
    end


end