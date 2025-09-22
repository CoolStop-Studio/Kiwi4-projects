local self = {}
local options = require("options")

self.frames = {}
local time = 0
local last_frame = 0
local frame = 1

local function remap_looped(value, min_in, max_in, min_out, max_out)
    local range_in = max_in - min_in
    local range_out = max_out - min_out
    -- Wrap the input value to the input range
    value = (value - min_in) % range_in
    -- Scale to output range
    return min_out + (value / range_in) * range_out
end

local function draw_full(frame_number)
    Draw.clearScreen(Color.BLACK)

    print("playing frame " .. frame_number .. "/" .. #self.frames)
    local data = self.frames[frame_number]
    for drawx = 0, #data do
        for drawy = 0, #data[0] do
            local theta1 = data[drawx][drawy][1]
            local theta2 = data[drawx][drawy][2]

            local hue = remap_looped(theta1 - theta2, 0, 2*math.pi, options.hue_min, options.hue_max)
            local sat = remap_looped(theta1, 0, 2*math.pi, options.sat_min, options.sat_max)
            local val = remap_looped(theta2, 0, 2*math.pi, options.val_min, options.val_max)

            local color = Color.hsv(hue, sat, val)
            Draw.drawPixel(Vector(drawx, drawy), color)
        end
    end
end

function self._update(delta)
    if Input.isKeyJustPressed("space") then
        frame = frame + 1
        if frame > #self.frames then
            frame = 1
        end
        draw_full(frame)
    end
end

return self