------------------------------------------------------------
-- Simple 3D cube with camera controls (Lua)
-- Uses:
--   Input.isKeyPressed(key)
--   Vector(x, y)                 -- 2D screen point
--   Draw.drawTriangle(p1,p2,p3,color)
--   Color(r, g, b, a)
-- Optional: Draw.clearScreen(Color(...)) if you have it.
------------------------------------------------------------

-- ====== Tweak these to your window size if needed ======
local SCREEN_WIDTH  = 256
local SCREEN_HEIGHT = 256

-- ====== Math helpers (Vec3) ======
local function Vec3(x, y, z) return {x = x, y = y, z = z} end

local function add(a, b) return Vec3(a.x + b.x, a.y + b.y, a.z + b.z) end
local function sub(a, b) return Vec3(a.x - b.x, a.y - b.y, a.z - b.z) end
local function mul(a, s) return Vec3(a.x * s, a.y * s, a.z * s) end
local function dot(a, b) return a.x*b.x + a.y*b.y + a.z*b.z end
local function cross(a, b)
    return Vec3(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    )
end
local function length(a) return math.sqrt(dot(a, a)) end
local function norm(a)
    local l = length(a)
    if l == 0 then return Vec3(0,0,0) end
    return Vec3(a.x/l, a.y/l, a.z/l)
end

-- ====== Camera ======
local camPos   = Vec3(0, 0, -5)   -- start a bit “back” so cube is in front
local camYaw   = 0.0              -- left/right
local camPitch = 0.0              -- up/down

local moveSpeed = 4.0             -- world units per second
local lookSpeed = 1.6             -- radians per second

-- ====== Projection (simple perspective) ======
local fov_deg = 75
local fov     = fov_deg * math.pi / 180
local focal   = (0.5 * SCREEN_HEIGHT) / math.tan(fov * 0.5)
local cx, cy  = SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5
local nearZ   = 0.05

local function worldToCamera(p)
    -- Build camera basis from yaw/pitch (no roll)
    local cosY, sinY = math.cos(camYaw), math.sin(camYaw)
    local cosP, sinP = math.cos(camPitch), math.sin(camPitch)
    -- Forward points toward -Z in camera space by convention; we’ll define:
    local forward = Vec3( sinY*cosP, -sinP, -cosY*cosP )
    local right   = Vec3( cosY,      0,     sinY )
    local up      = cross(right, forward)

    -- Translate into camera space
    local d = sub(p, camPos)
    return Vec3(
        dot(d, right),
        dot(d, up),
        dot(d, mul(forward, -1))   -- camera looks along +Z; flip so forward is +Z
    )
end

local function project(camP)
    -- Perspective divide
    if camP.z <= nearZ then return nil end
    local x = (camP.x * focal) / camP.z + cx
    local y = (camP.y * focal) / camP.z + cy
    return Vector(x, y)
end

-- ====== Cube geometry (centered at origin) ======
local cubeVerts = {
    Vec3(-1, -1, -1), Vec3( 1, -1, -1),
    Vec3( 1,  1, -1), Vec3(-1,  1, -1),
    Vec3(-1, -1,  1), Vec3( 1, -1,  1),
    Vec3( 1,  1,  1), Vec3(-1,  1,  1),
}
-- Faces as triangles (indices into cubeVerts)
local faces = {
    -- back (-Z)
    {1,2,3}, {1,3,4},
    -- front (+Z)
    {5,7,6}, {5,8,7},
    -- left (-X)
    {1,4,8}, {1,8,5},
    -- right (+X)
    {2,6,7}, {2,7,3},
    -- bottom (-Y)
    {1,5,6}, {1,6,2},
    -- top (+Y)
    {4,3,7}, {4,7,8},
}
-- Per-face colors (repeat or tweak as you like)
local faceColors = {
    Color(255, 60, 60, 255),
    Color(255, 90, 60, 255),
    Color(60, 255, 60, 255),
    Color(60, 255, 120, 255),
    Color(60, 60, 255, 255),
    Color(120, 60, 255, 255),
    Color(255, 255, 60, 255),
    Color(255, 200, 60, 255),
    Color(60, 255, 255, 255),
    Color(60, 200, 255, 255),
    Color(255, 60, 200, 255),
    Color(255, 120, 200, 255),
}

-- ====== Input helpers ======
local function key(k) return Input.isKeyPressed(k) end

local function handleCameraMovement(delta)
    local move = Vec3(0,0,0)
    -- Construct basis again for movement
    local cosY, sinY = math.cos(camYaw), math.sin(camYaw)
    local cosP, sinP = math.cos(camPitch), math.sin(camPitch)
    local forward = Vec3( sinY*cosP, -sinP, -cosY*cosP )
    local right   = Vec3( cosY,      0,     sinY )
    local up      = Vec3( 0, 1, 0 )

    if key("w") then move = add(move, forward) end
    if key("s") then move = sub(move, forward) end
    if key("a") then move = sub(move, right)   end
    if key("d") then move = add(move, right)   end
    if key("space") then move = add(move, up)  end
    if key("left shift") then move = sub(move, up) end

    if length(move) > 0 then
        camPos = add(camPos, mul(norm(move), moveSpeed * delta))
    end
end

local function handleCameraLook(delta)
    if key("left")  then camYaw   = camYaw   - lookSpeed * delta end
    if key("right") then camYaw   = camYaw   + lookSpeed * delta end
    if key("up")    then camPitch = camPitch - lookSpeed * delta end
    if key("down")  then camPitch = camPitch + lookSpeed * delta end
    -- Clamp pitch to avoid flipping
    local limit = math.rad(89)
    if camPitch >  limit then camPitch =  limit end
    if camPitch < -limit then camPitch = -limit end
end

-- ====== Render ======
local function drawCube()
    -- Transform all vertices once
    local camVerts = {}
    for i,v in ipairs(cubeVerts) do
        camVerts[i] = worldToCamera(v)
    end

    -- Build drawable triangles with backface culling and depth
    local tris = {}
    for fi, f in ipairs(faces) do
        local a, b, c = camVerts[f[1]], camVerts[f[2]], camVerts[f[3]]

        -- Backface check in camera space
        local ab = sub(b, a)
        local ac = sub(c, a)
        local n  = cross(ab, ac)                 -- face normal (camera space)
        -- If normal.z <= 0, it's facing camera (right-handed with our setup)
        if n.z < 0 then
            -- Project
            local p1 = project(a)
            local p2 = project(b)
            local p3 = project(c)
            if p1 and p2 and p3 then
                local avgZ = (a.z + b.z + c.z) / 3
                table.insert(tris, {
                    z = avgZ,
                    color = faceColors[((fi - 1) % #faceColors) + 1],
                    p1 = p1, p2 = p2, p3 = p3
                })
            end
        end
    end

    -- Painter’s algorithm (farther first)
    table.sort(tris, function(t1, t2) return t1.z > t2.z end)

    -- Draw
    for _,t in ipairs(tris) do
        local position1, position2, position3 = t.p1, t.p2, t.p3
        Draw.drawTriangle(position1, position2, position3, t.color)
    end
end

-- ====== Public callbacks ======
function _update(delta)
    handleCameraLook(delta)
    handleCameraMovement(delta)
end

function _draw()
    if Draw.clearScreen then
        Draw.clearScreen(Color(20, 20, 24, 255))
    end
    drawCube()
end
