local self = {}

local cursorPos = Vector(0, 0)

local selected_hue = 0
local selected_sat = 1
local selected_val = 1

local changing_grid = false
local changing_hue = false

local function clamp(v, min, max)
    return math.min(math.max(v, min), max)
end

local function int_to_degree(i)
    return i * 360 / 64
end

local function degree_to_int(d)
    return math.floor(d * 64 / 360)
end

function self._update(delta)
end

function self._draw()
    Draw.clearScreen(Color.BLACK)

    for y = 0, 63 do
        local v = (63 - y) / 63
        for x = 0, 63 do
            local s = x / 63
            Draw.drawPixel(Vector(x, y), Color.hsv(selected_hue, s, v))
        end
    end

    --Draw.drawLine(Vector(0, 63), Vector(63, 63), Color.WHITE)

    for x = 0, 63 do
        local y = 64
        Draw.drawPixel(Vector(x, y), Color.hsv(int_to_degree(x), selected_sat, selected_val))
    end

    Draw.drawPixel(cursorPos, Color.WHITE)
    Draw.drawPixel(Vector(degree_to_int(selected_hue), 65), Color.WHITE)

    if Input.isMouseJustPressed("left") then
        if Input.isMouseInRect(Vector(0, 0), Vector(64, 62), true) then
            changing_grid = true
        elseif Input.isMouseInRect(Vector(0, 63), Vector(64, 65), true) then
            changing_hue = true
        end
    end
    if Input.isMouseJustReleased("left") then
        changing_grid = false
        changing_hue = false
    end
    if changing_grid then
        cursorPos.x = clamp(Input.getMousePosition().x, 0, 63)
        cursorPos.y = clamp(Input.getMousePosition().y, 0, 63)
    elseif changing_hue then
        selected_hue = int_to_degree(clamp(Input.getMousePosition().x, 0, 63))
    end
    selected_sat = cursorPos.x / 63
    selected_val = (63 - cursorPos.y) / 63
end

return self