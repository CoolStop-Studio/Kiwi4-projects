local self = {}

function self.newButton(default_tex, hover_tex, pressed_tex, pos1, pos2)
    local btn = {
        default_tex = default_tex,
        hover_tex   = hover_tex,
        pressed_tex = pressed_tex,
        pos1        = pos1,
        pos2        = pos2,
        active      = false, -- true if mouse down started inside
        clicked     = false  -- true for one frame after release inside
    }

    -- expand clickable area by 1 pixel
    local hover_pos1 = Vector(pos1.x - 1, pos1.y - 1)
    local hover_pos2 = Vector(pos2.x, pos2.y)

    function btn:update()
        self.clicked = false

        -- mouse press started on button
        if Input.isMouseJustPressed() then
            self.active = Input.isMouseInRect(hover_pos1, hover_pos2, true)
        end

        -- mouse release after valid press
        if Input.isMouseJustReleased() then
            if self.active and Input.isMouseInRect(hover_pos1, hover_pos2, true) then
                self.clicked = true
            end
            self.active = false
        end
    end

    function btn:draw()
        local inside = Input.isMouseInRect(hover_pos1, hover_pos2, true)

        if self.active then
            Draw.drawRect(hover_pos1, hover_pos2, Color(255, 255, 255, 20))
            if Input.isMousePressed() then
                -- held down
                Draw.drawImage(self.pos1, self.pos2, self.pressed_tex or self.default_tex)
            else
                -- just released, draw hover state until next frame
                Draw.drawImage(self.pos1, self.pos2, self.hover_tex or self.default_tex)
            end
        else
            -- only show hover state if NOT pressed anywhere else
            if inside and not Input.isMousePressed() then
                Draw.drawRect(hover_pos1, hover_pos2, Color(255, 255, 255, 20))
                Draw.drawImage(self.pos1, self.pos2, self.hover_tex or self.default_tex)
            else
                Draw.drawImage(self.pos1, self.pos2, self.default_tex)
            end
        end
    end

    return btn
end

return self
