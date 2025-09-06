local self = {}

local output_fps = 0
local fps_history = {}
local time_count = 0

function self._update(delta)
    local fps = 1 / delta
    table.insert(fps_history, fps)
    time_count = time_count + delta
    if time_count >= 0.3 then
        local sum = 0
        for _, v in ipairs(fps_history) do
            sum = sum + v
        end
        local avg = sum / #fps_history
        output_fps = math.floor(avg)

        -- reset for the next 100 frames
        fps_history = {}
        time_count = 0 + (0.3 - time_count)
    end
end

function self._draw()
    Draw.drawText(output_fps, Vector(0, 76), Color.WHITE)
end

return self