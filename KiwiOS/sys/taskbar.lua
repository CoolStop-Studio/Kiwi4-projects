local self = {}

local Button = require("sys.button")

local startButton = Button.newButton(
    Load.loadImage("/sys/icons/start/start.png"),
    Load.loadImage("/sys/icons/start/start.png"),
    Load.loadImage("/sys/icons/start/start_pressed.png"),
    Vector(1, Config.window.height - 7 + 1),
    Vector(6, Config.window.height - 1)
)

local buttons = {}

function self._update()
    startButton:update()

    for i = 1, #buttons, 1 do
        buttons[i]:update()
    end

    if startButton.justPressed then
        APP.newApp("projects/KiwiOS/apps/showcase.lua", Vector(math.random(1, Config.window.width - 50), math.random(5, Config.window.height - 70)), Vector(math.random(50, Config.window.width), math.random(70, Config.window.height)))
    end
end

function self._draw()
    Draw.drawRect(Vector(0, Config.window.height), Vector(Config.window.width, Config.window.height - 7), Color(0, 0, 0, 200))

    for i = 1, #buttons, 1 do
        buttons[i]:draw()
    end

    startButton:draw()
end

function UPDATE_TASKBAR()
    buttons = {}
    for i = 1, #RUNNING_APPS, 1 do
        buttons[i] = Button.newButton(
            Load.loadImage("/sys/icons/app/app.png"),
            Load.loadImage("/sys/icons/app/app.png"),
            Load.loadImage("/sys/icons/app/app_pressed.png"),
            Vector(i * 7 + 10, Config.window.height - 7 + 1),
            Vector(i * 7 + 15, Config.window.height - 1)
        )
        
    end
end

return self