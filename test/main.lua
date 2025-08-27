
function _init()

end

function _update(delta)
end

function _draw()
    Draw.clearScreen(Color.BLACK)
    Draw.drawImage(Vector(0, 0), Input.getMousePosition())
    Draw.drawText("Hello World!", Vector(0, 0))
end
