local APP = {}


function Vector3(x, y, z)
    return { x = x, y = y, z = z }
end

local size = 15
local speed = 2
local angle = Vector3(0, 0, 0)
local scale = 20
local time = 0
local offset = Vector(32 / 2, 32 / 2)

local cube3 = {
    Vector3(-size, -size, -size),
    Vector3(size, -size, -size),
    Vector3(size, size, -size),
    Vector3(-size, size, -size),

    Vector3(-size, -size, size),
    Vector3(size, -size, size),
    Vector3(size, size, size),
    Vector3(-size, size, size)
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

function APP._update(delta)
    time = time + delta * speed
    scale = 25 + 50 * math.sin(time)

    angle.x = angle.x + delta * speed
    angle.y = angle.y + delta * speed
    angle.z = angle.z + delta * speed

    for i = 1, #cube3 do
        local rotated = rotate3D(cube3[i])
        local x1, y1, z1 = rotated.x, rotated.y, rotated.z

        -- project to 2D
        cube2[i].x = (x1 / (z1 + 100)) * scale + offset.x
        cube2[i].y = (y1 / (z1 + 100)) * scale + offset.y
    end
end

function APP._draw()
    APP.Draw.clearScreen(Color.BLACK)
    
    local edges = {
        {1,2}, {2,3}, {3,4}, {4,1}, -- back square
        {5,6}, {6,7}, {7,8}, {8,5}, -- front square
        {1,5}, {2,6}, {3,7}, {4,8}, -- connecting edges
    }

    for _, e in ipairs(edges) do
        APP.Draw.drawLine(cube2[e[1]], cube2[e[2]], Color.WHITE)
    end
end














return APP