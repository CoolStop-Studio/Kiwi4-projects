local cube = require("cube")
local particles = require("particles")
local circle = require("circle")

local myfont = Load.loadFont("projects/showcase/o.ttf", 11)


function _update(delta)
    circle._update(delta)
    cube._update(delta)
    particles._update(delta)
end

function _draw()
    Draw.drawRect(Vector(0, 0), Vector(Config.window.width, Config.window.height), Color(0, 0, 0, 5))
    circle._draw()
    cube._draw()
    particles._draw()
    Draw.drawText("Welcome to the game!", Vector(1, 0), Color(255, 255, 255), myfont)
end