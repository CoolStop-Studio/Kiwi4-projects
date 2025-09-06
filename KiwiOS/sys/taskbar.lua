local self = {}

local Button = require("sys.button")

local startButton = Button.newButton(
    Load.loadImage("/sys/icons/start/start.png"),
    Load.loadImage("/sys/icons/start/start.png"),
    Load.loadImage("/sys/icons/start/start_pressed.png"),
    Vector(1, Config.window.height - 7 + 1),
    Vector(6, Config.window.height - 1)
)




function self._update()
    startButton:update()
    if startButton.clicked then
        print("Start button clicked")
    end
end

function self._draw()
    Draw.drawRect(Vector(0, Config.window.height), Vector(Config.window.width, Config.window.height - 7), Color(0, 0, 0, 200))

    startButton:draw()
end

return self