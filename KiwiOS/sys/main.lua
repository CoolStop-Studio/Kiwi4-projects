local taskbar = require("sys.taskbar")
local desktop = require("sys.desktop")
local fps = require("sys.fps")
APP = require("sys.app")

PALETTE = {
    Color.hex("#2f3e46"),
    Color.hex("#354f52"),
    Color.hex("#52796f"),
    Color.hex("#84a98c"),
    Color.hex("#cad2c5")
}

-- PALETTE = {
--     Color.hex("#003049"),
--     Color.hex("#d62828"),
--     Color.hex("#f77f00"),
--     Color.hex("#fcbf49"),
--     Color.hex("#eae2b7")
-- }


RUNNING_APPS = {}
APPS_INDEX = {}

ACTIVE_APP = nil

function CLAMP(v, min, max)
    return math.min(math.max(v, min), max)
end

function _init()
    --app.newApp("apps.color.main", Vector(40, 30), Vector(120, 60))
    APP.newApp("projects/KiwiOS/apps/cube.lua", Vector(10, 50), Vector(50, 70))
end

function _update(delta)
    desktop._update()
    taskbar._update()
    fps._update(delta)
    for i = 1, #RUNNING_APPS, 1 do
        APPS_INDEX[RUNNING_APPS[i]].update(delta)
    end
end

function _draw()
    Draw.clearScreen(Color.BLACK)
    desktop._draw()
    for i = 1, #RUNNING_APPS, 1 do
        if APPS_INDEX[RUNNING_APPS[i]] then
            APPS_INDEX[RUNNING_APPS[i]].draw()
        end
    end
    taskbar._draw()
    fps._draw()
end