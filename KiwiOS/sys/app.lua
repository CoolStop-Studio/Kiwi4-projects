local self = {}

function self.newApp(path)
    local script = require(path)

    local app = {
        pos1        = Vector(0, 0),
        pos2        = Vector(160, 90),
        active      = false,
    }
    local function setActivation(active)
        app.active = active
        if active then
            ACTIVE_APP = app
        end       
    end

    function app.update()
        if ACTIVE_APP == self then
            app.active = true
        end
        if app.active then
            script.APP.size = Vector(app.pos2.x - app.pos1.x, app.pos2.y - app.pos1.y)
            script._update()
        end
        if Input.isMouseInRect(app.pos1, app.pos2, true) then
            setActivation(true)
        else
            setActivation(false)
        end
    end

    function app.draw()
        if app.active then
            Draw.drawRect(app.pos1 - Vector(1, 1), app.pos2 + Vector(1, 1), PALETTE[2])
            script._draw()
        else
            Draw.drawRect(app.pos1 - Vector(1, 1), app.pos2 + Vector(1, 1), PALETTE[4])
        end
    end

    return app
end

return self
