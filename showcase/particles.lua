local self = {}

local particles = {}
local GRAVITY = Vector(20, 20)
local delay = 0.02
local delayLeft = delay

function self._update(delta)
    delayLeft = delayLeft - delta
    if delayLeft <= 0 then
        if math.random(0, 1) == 0 then
            table.insert(particles, { position = Vector(math.random(0, Config.window.width), 0), velocity = Vector(math.random(-10, 20), math.random(10, 20)) })
        else
            table.insert(particles, { position = Vector(0, math.random(0, Config.window.height)), velocity = Vector(math.random(10, 20), -math.random(10, 20)) })
        end
        delayLeft = delay + delayLeft
    end

    for i = 1, #particles do
        local particle = particles[i]
        if not particle then
            break
        end
        particle.position.x = particle.position.x + particle.velocity.x * delta
        particle.position.y = particle.position.y + particle.velocity.y * delta

        if particle.position.x < 0 or particle.position.x > Config.window.width or particle.position.y < 0 or particle.position.y > Config.window.height then
            table.remove(particles, i)
        end

        particle.velocity = particle.velocity + GRAVITY * delta
    end
end

function self._draw()
    for i = 1, #particles do
        local particle = particles[i]
        Draw.drawPixel(particle.position, Color.WHITE)
    end
end

return self