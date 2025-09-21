local function object(pos1, pos2, color)
    return {
        pos1 = pos1,
        pos2 = pos2,
        color = color
    }
end

CLAMP = function(value, min, max)
    return math.min(math.max(value, min), max)
end

local WORLD = {
    object(Vector(0, 100), Vector(128, 128), Color(100, 0, 100, 255)),
    object(Vector(0, 50), Vector(50, 128), Color(100, 0, 100, 255))
}

local player = {
    position = Vector(0, 0),
    size = Vector(5, 5),
    velocity = Vector(0, 0),
    gravity = Vector(0, 600),
    SPEED = 500,
    MAX_SPEED = Vector(75, 150),
    JUMP_VELOCITY = -125,
    update = function (self, delta)
        if Input.isKeyPressed("left") then
            if self.velocity.x > 0 then
                self.velocity.x = 0
            end
            self.velocity.x = self.velocity.x - self.SPEED * delta
        end
        if Input.isKeyPressed("right") then
            if self.velocity.x < 0 then
                self.velocity.x = 0
            end
            self.velocity.x = self.velocity.x + self.SPEED * delta
        end
        if not Input.isKeyPressed("left") and not Input.isKeyPressed("right") then
            self.velocity.x = self.velocity.x * 0.5
        end
        if Input.isKeyJustPressed("up") then
           self.velocity.y = self.JUMP_VELOCITY
        end
        if self.velocity.x > self.MAX_SPEED.x then
            self.velocity.x = self.MAX_SPEED.x
        elseif self.velocity.x < -self.MAX_SPEED.x then
            self.velocity.x = -self.MAX_SPEED.x
        end
        if self.velocity.y > self.MAX_SPEED.y then
            self.velocity.y = self.MAX_SPEED.y
        elseif self.velocity.y < -self.MAX_SPEED.y then
            self.velocity.y = -self.MAX_SPEED.y
        end
        self.velocity = self.velocity + self.gravity * delta
        self.position = self.position + self.velocity * delta
        for i, o in ipairs(WORLD) do
            if self.velocity.y > 0 then
                if o.pos1.y < self.position.y + self.size.y + 1
                and o.pos2.y > self.position.y
                and o.pos1.x < self.position.x + self.size.x
                and o.pos2.x > self.position.x then
                    self.velocity.y = 0
                    self.position.y = o.pos1.y - self.size.y - 1
                end
            elseif self.velocity.y < 0 then
                if o.pos1.y > self.position.y
                and o.pos2.y < self.position.y + self.size.y
                and o.pos1.x < self.position.x + self.size.x
                and o.pos2.x > self.position.x then
                    self.velocity.y = 0
                    self.position.y = o.pos1.y
                end
            end
            if self.velocity.x > 0 then
                if o.pos1.x < self.position.x + self.size.x + 1
                and o.pos2.x > self.position.x
                and o.pos1.y < self.position.y + self.size.y
                and o.pos2.y > self.position.y then
                    self.velocity.x = 0
                    self.position.x = o.pos1.x - self.size.x - 1
                end
            elseif self.velocity.x < 0 then
                if o.pos2.x > self.position.x - 1
                and o.pos1.x < self.position.x + self.size.x
                and o.pos1.y < self.position.y + self.size.y
                and o.pos2.y > self.position.y then
                    self.velocity.x = 0
                    self.position.x = o.pos2.x + 1
                end
            end
        end
    end
}


function _update(delta)
    player:update(delta)
end

function _draw(delta)
    Draw.clearScreen(Color(20, 20, 24, 255))
    for i, o in ipairs(WORLD) do
        Draw.drawRect(o.pos1, o.pos2, o.color)
        local highlight_shift = -25
        local highlight_color = Color(CLAMP(o.color.r + highlight_shift, 0, 255), CLAMP(o.color.g + highlight_shift, 0, 255), CLAMP(o.color.b + highlight_shift, 0, 255), 255)
        Draw.drawLine(o.pos1, Vector(o.pos2.x, o.pos1.y), highlight_color)
    end

    Draw.drawRect(player.position, player.position + player.size, Color(200, 200, 200, 255))
end