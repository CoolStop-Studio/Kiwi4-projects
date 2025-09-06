local self = {}

function self._draw()
    Draw.drawTriangleGPU(Vector(1, 1), Vector(126, 1), Input.getMousePosition(), Color.WHITE)
end

return self