local self = {}

local fps_history = {}
local frame_count = 0

function self._update(delta)
    local fps = 1 / delta
    table.insert(fps_history, fps)
    frame_count = frame_count + 1
    if frame_count >= 50 then
        local sum = 0
        for _, v in ipairs(fps_history) do
            sum = sum + v
        end
        local avg = sum / #fps_history
        output_fps = math.floor(avg)

        -- reset for the next 100 frames
        fps_history = {}
        frame_count = 0
    end
end

function self._draw()
    Draw.drawText(output_fps, Vector(0, 0), Color.WHITE)
end

return self