local APP = {}

local circle = {}
local cube = {}
local particles = {}

function APP._update(delta)
    circle._update(delta)
    cube._update(delta)
    particles._update(delta)
end

function APP._draw()
    APP.Draw.clearScreen(Color.BLACK)
    circle._draw()
    cube._draw()
    particles._draw()
end



local all_particles = {}
local GRAVITY = Vector(20, 20)
local delay = 0.02
local delayLeft = delay

function particles._update(delta)
    delayLeft = delayLeft - delta
    if delayLeft <= 0 then
        if math.random(0, 1) == 0 then
            table.insert(all_particles, { position = Vector(math.random(0, 64), 0), velocity = Vector(math.random(-10, 20), math.random(10, 20)) })
        else
            table.insert(all_particles, { position = Vector(0, math.random(0, 64)), velocity = Vector(math.random(10, 20), -math.random(10, 20)) })
        end
        delayLeft = delay + delayLeft
    end

    for i = 1, #all_particles do
        local particle = all_particles[i]
        if not particle then
            break
        end
        particle.position.x = particle.position.x + particle.velocity.x * delta
        particle.position.y = particle.position.y + particle.velocity.y * delta

        if particle.position.x < 0 or particle.position.x > 64 or particle.position.y < 0 or particle.position.y > 64 then
            table.remove(all_particles, i)
        end

        particle.velocity = particle.velocity + GRAVITY * delta
    end
end

function particles._draw()
    for i = 1, #all_particles do
        local particle = all_particles[i]
        APP.Draw.drawPixel(particle.position, Color.WHITE)
    end
end


function Vector3(x, y, z)
    return { x = x, y = y, z = z }
end

local s = 20
local speed = 2
local angle = Vector3(0, 0, 0)
local scale = 20
local time = 0

local cube3 = {
    Vector3(-s, -s, -s),
    Vector3(s, -s, -s),
    Vector3(s, s, -s),
    Vector3(-s, s, -s),

    Vector3(-s, -s, s),
    Vector3(s, -s, s),
    Vector3(s, s, s),
    Vector3(-s, s, s)
}

local cube2 = {
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
    Vector(0, 0),
}

local function rotate3D(v)
    local x, y, z = v.x, v.y, v.z

    -- Rotate around X
    local cosX, sinX = math.cos(angle.x), math.sin(angle.x)
    local y1 = y * cosX - z * sinX
    local z1 = y * sinX + z * cosX
    local x1 = x

    -- Rotate around Y
    local cosY, sinY = math.cos(angle.y), math.sin(angle.y)
    local x2 = x1 * cosY + z1 * sinY
    local z2 = -x1 * sinY + z1 * cosY
    local y2 = y1

    -- Rotate around Z
    local cosZ, sinZ = math.cos(angle.z), math.sin(angle.z)
    local x3 = x2 * cosZ - y2 * sinZ
    local y3 = x2 * sinZ + y2 * cosZ
    local z3 = z2

    return {x = x3, y = y3, z = z3}
end

function cube._update(delta)
    time = time + delta * speed
    scale = 25 + 50 * math.sin(time)

    angle.x = angle.x + delta * speed
    angle.y = angle.y + delta * speed
    angle.z = angle.z + delta * speed

    for i = 1, #cube3 do
        local rotated = rotate3D(cube3[i])
        local x1, y1, z1 = rotated.x, rotated.y, rotated.z

        -- project to 2D
        cube2[i].x = (x1 / (z1 + 100)) * scale + 64 / 2
        cube2[i].y = (y1 / (z1 + 100)) * scale + 64 / 2
    end
end

local hue = 0

function cube._draw()

    -- draw edges of cube
    local edges = {
        {1,2}, {2,3}, {3,4}, {4,1}, -- back square
        {5,6}, {6,7}, {7,8}, {8,5}, -- front square
        {1,5}, {2,6}, {3,7}, {4,8}, -- connecting edges
    }

    for _, e in ipairs(edges) do
        APP.Draw.drawLine(cube2[e[1]], cube2[e[2]], Color.hsv(hue, 1.0, 1))
    end
    hue = hue + 1
    if hue > 360 then hue = hue - 360 end
end






local rot = 0

function circle._update(delta)
    rot = rot + delta
    if rot > math.pi * 2 then
        rot = rot - math.pi * 2
    end

end

local function polar_to_cartesian(r, theta)
    return Vector(r * math.cos(theta), r * math.sin(theta))
end

function radians_to_degrees(radians)
    local degrees = radians * 180 / math.pi
    return degrees % 360
end


function circle._draw()
    local center = Vector(64 / 2, 64 / 2)
    APP.Draw.drawTriangle(center, center + polar_to_cartesian(100, rot), (center + polar_to_cartesian(100, rot)) * 2, Color.hsv(radians_to_degrees(rot), 1, 1))
    APP.Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi), (center + polar_to_cartesian(100, rot + math.pi)) * 2, Color.hsv(radians_to_degrees(rot + math.pi), 1, 1))
    APP.Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi / 2), (center + polar_to_cartesian(100, rot + math.pi / 2)) * 2, Color.hsv(radians_to_degrees(rot + math.pi / 2), 1, 1))
    APP.Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi * 1.5), (center + polar_to_cartesian(100, rot + math.pi * 1.5)) * 2, Color.hsv(radians_to_degrees(rot + math.pi * 1.5), 1, 1))
end























return APP