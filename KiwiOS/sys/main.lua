local taskbar = require("sys.taskbar")
local desktop = require("sys.desktop")
local fps = require("sys.fps")
local app = require("sys.app")

PALETTE = {
    Color.hex("#2f3e46"),
    Color.hex("#354f52"),
    Color.hex("#52796f"),
    Color.hex("#84a98c"),
    Color.hex("#cad2c5")
}

RUNNING_APPS = {}
ACTIVE_APP = nil

function _init()
    app.newApp("apps.color.main")
end

function _update(delta)
    desktop._update()
    taskbar._update()
    fps._update(delta)
end

function _draw()
    Draw.clearScreen(Color.BLACK)
    desktop._draw()
    taskbar._draw()
    fps._draw()
end