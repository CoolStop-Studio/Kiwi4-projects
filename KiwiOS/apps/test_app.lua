local APP = {}

local width = 100
local time = 0

function APP._init()
    
end

function APP._update(delta)
    time = time + delta
end

function APP._draw()
    for i = 0, width, 1 do 
        local hue = (time * 30) + (i / width * 360 * 3)
        APP.Draw.drawLine(Vector(i, 0), Vector(i, 100), Color.hsv(hue % 360, 1, 1))
    end
end

return APP