local APP = {}

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
    return i * 360 / 32
end

local function degree_to_int(d)
    return math.floor(d * 32 / 360)
end

function APP._update(delta)
end

function APP._draw()
    APP.Draw.clearScreen(Color.BLACK)

    for y = 0, 31 do
        local v = (31 - y) / 31
        for x = 0, 31 do
            local s = x / 31
            APP.Draw.drawPixel(Vector(x, y), Color.hsv(selected_hue, s, v))
        end
    end

    for x = 0, 31 do
        local y = 32
        APP.Draw.drawPixel(Vector(x, y), Color.hsv(int_to_degree(x), selected_sat, selected_val))
    end

    APP.Draw.drawPixel(cursorPos, Color.WHITE)
    APP.Draw.drawPixel(Vector(degree_to_int(selected_hue), 33), Color.WHITE)

    if Input.isMouseJustPressed("left") then
        if APP.Input.isMouseInRect(Vector(0, 0), Vector(32, 30), true) then
            changing_grid = true
        elseif APP.Input.isMouseInRect(Vector(0, 31), Vector(32, 33), true) then
            changing_hue = true
        end
    end
    if Input.isMouseJustReleased("left") then
        changing_grid = false
        changing_hue = false
    end
    if changing_grid then
        cursorPos.x = clamp(APP.Input.getMousePosition().x, 0, 31)
        cursorPos.y = clamp(APP.Input.getMousePosition().y, 0, 31)
    elseif changing_hue then
        selected_hue = int_to_degree(clamp(APP.Input.getMousePosition().x, 0, 31))
    end
    selected_sat = cursorPos.x / 31
    selected_val = (31 - cursorPos.y) / 31
end

return APP