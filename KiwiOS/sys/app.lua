local self = {}

function self.newApp(path, app_pos1, app_pos2)
    local app = {
        id          = #RUNNING_APPS + 1,
        time_to_close = 0.1,
        closing     = false,
        scaling     = false,
        moving      = false,
        move_offset = Vector(0, 0),
        move_size   = Vector(0, 0),
        script      = dofile(path),
        pos1        = app_pos1,
        pos2        = app_pos2,
        active      = false,
        uptime      = 0
    }

    local window = {
        pos1 = app.pos1,
        pos2 = app.pos2
    }
    local left = app.pos1.x
    local top = app.pos1.y
    local right = app.pos2.x
    local bottom = app.pos2.y

    local function update_scales()
        left = app.pos1.x
        top = app.pos1.y
        right = app.pos2.x
        bottom = app.pos2.y
        app.script.pos1 = app.pos1
        app.script.pos2 = app.pos2
        window.pos1 = app.pos1 - Vector(1, 4)
        window.pos2 = app.pos2 + Vector(1, 1)
    end

    update_scales()
    
    app.script.Draw = {
        drawPixel = function(pos, color)
            local l = Vector(
                CLAMP(pos.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawPixel(l + app.pos1, color)
        end,

        drawLine = function(pos1, pos2, color)
            local l1 = Vector(
                CLAMP(pos1.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos1.y, 0, app.pos2.y - app.pos1.y)
            )
            local l2 = Vector(
                CLAMP(pos2.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos2.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawLine(l1 + app.pos1, l2 + app.pos1, color)
        end,

        drawRect = function(pos1, pos2, color)
            local l1 = Vector(
                CLAMP(pos1.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos1.y, 0, app.pos2.y - app.pos1.y)
            )
            local l2 = Vector(
                CLAMP(pos2.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos2.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawRect(l1 + app.pos1, l2 + app.pos1, color)
        end,

        drawImage = function(pos1, pos2, image)
            local l1 = Vector(
                CLAMP(pos1.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos1.y, 0, app.pos2.y - app.pos1.y)
            )
            local l2 = Vector(
                CLAMP(pos2.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos2.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawImage(l1 + app.pos1, l2 + app.pos1, image)
        end,

        drawText = function(text, pos, color, font)
            local l = Vector(
                CLAMP(pos.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawText(text, l + app.pos1, color, font)
        end,

        drawTriangle = function(pos1, pos2, pos3, color)
            local l1 = Vector(
                CLAMP(pos1.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos1.y, 0, app.pos2.y - app.pos1.y)
            )
            local l2 = Vector(
                CLAMP(pos2.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos2.y, 0, app.pos2.y - app.pos1.y)
            )
            local l3 = Vector(
                CLAMP(pos3.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos3.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawTriangle(l1 + app.pos1, l2 + app.pos1, l3 + app.pos1, color)
        end,

        drawTriangleGPU = function(pos1, pos2, pos3, color)
            local l1 = Vector(
                CLAMP(pos1.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos1.y, 0, app.pos2.y - app.pos1.y)
            )
            local l2 = Vector(
                CLAMP(pos2.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos2.y, 0, app.pos2.y - app.pos1.y)
            )
            local l3 = Vector(
                CLAMP(pos3.x, 0, app.pos2.x - app.pos1.x),
                CLAMP(pos3.y, 0, app.pos2.y - app.pos1.y)
            )
            Draw.drawTriangleGPU(l1 + app.pos1, l2 + app.pos1, l3 + app.pos1, color)
        end,

        clearScreen = function(color)
            Draw.drawRect(app.pos1, app.pos2, color)
        end
    }

    app.script.Input = {
        isMouseInRect = function(pos1, pos2, inside)
            return Input.isMouseInRect(pos1 + app.pos1, pos2 + app.pos1, inside)
        end,
        getMousePosition = function()
            return Input.getMousePosition() - app.pos1
        end
    }

    function app.update(delta)
        app.uptime = app.uptime + delta
        if app.closing then
            app.time_to_close = app.time_to_close - delta
            if app.time_to_close <= 0 then
                app._close()
            end
            return
        end

        if ACTIVE_APP == app.id then
            app.active = true
        else
            app.active = false
        end
        app.script._update(delta)
        if Input.isMouseInRect(window.pos1, window.pos2, true) then
            ACTIVE_APP = app.id
        end
    end

    function app.draw()
        if app.active then
            Draw.drawRect(window.pos1, window.pos2, PALETTE[2])
        else
            Draw.drawRect(window.pos1, window.pos2, PALETTE[1])
        end
        if app.closing then return end
        if Input.isMouseInRect(app.pos2, app.pos2 + Vector(1, 1), true) then
            if Input.isMouseJustPressed() then
                app.scaling = true
            end
            Draw.drawRect(app.pos2, app.pos2 + Vector(1, 1), PALETTE[5])
        else
            Draw.drawRect(app.pos2, app.pos2 + Vector(1, 1), PALETTE[4])
        end
        if Input.isMouseInRect(window.pos1, Vector(window.pos2.x, window.pos1.y + 3), true) then
            if Input.isMouseJustPressed() then
                app.moving = true
                app.move_size = app.pos2 - app.pos1
                app.move_offset = app.pos1 - Input.getMousePosition()
            end
        end

        if app.scaling then
            app.pos2 = Input.getMousePosition()
            app.pos2.x = CLAMP(app.pos2.x, app.pos1.x + 4, Config.window.width - 2)
            app.pos2.y = CLAMP(app.pos2.y, app.pos1.y + 4, Config.window.height - 9)
            update_scales()
            if Input.isMouseJustReleased() then
                app.scaling = false
            end
        end
        if app.moving then
            app.pos1 = Input.getMousePosition() + app.move_offset

            -- Work out the window size from move_size (not pos2 - pos1)
            local win_w = app.move_size.x
            local win_h = app.move_size.y

            -- Clamp pos1 so it never leaves screen
            app.pos1.x = CLAMP(app.pos1.x, 1, Config.window.width  - win_w - 2)
            app.pos1.y = CLAMP(app.pos1.y, 4, Config.window.height - win_h - 9)

            -- Recompute pos2 correctly
            app.pos2 = app.pos1 + app.move_size
            update_scales()
            if Input.isMouseJustReleased() then
                app.moving = false
            end
        end
        if Input.isMouseInRect(window.pos1 + Vector(1, 1), window.pos1 + Vector(2, 2), true) then
            Draw.drawRect(window.pos1 + Vector(1, 1), window.pos1 + Vector(2, 2), PALETTE[5])
            if Input.isMouseJustPressed() then
                app.start_close()
            end
        else
            Draw.drawRect(window.pos1 + Vector(1, 1), window.pos1 + Vector(2, 2), PALETTE[4])
        end

        app.script._draw()
    end

    function app.start_close()
        app.time_to_close = 0.1
        app.closing = true
    end

    function app._close()
        for i = 1, #RUNNING_APPS do
            if RUNNING_APPS[i] == app.id then

                table.remove(RUNNING_APPS, i)
                break
            end
        end

        APPS_INDEX[app.id] = nil

        UPDATE_TASKBAR()
    end

    table.insert(RUNNING_APPS, app.id)
    table.insert(APPS_INDEX, app.id, app)

    UPDATE_TASKBAR()
    return app
end

return self
