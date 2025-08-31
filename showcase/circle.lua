local self = {}

rot = 0

function self._update(delta)
    rot = rot + delta
    if rot > math.pi * 2 then
        rot = rot - math.pi * 2
    end

end

function polar_to_cartesian(r, theta)
    return Vector(r * math.cos(theta), r * math.sin(theta))
end

function radians_to_degrees(radians)
    local degrees = radians * 180 / math.pi
    return degrees % 360
end


function self._draw()
    center = Vector(Config.window.width / 2, Config.window.height / 2)
    Draw.drawTriangle(center, center + polar_to_cartesian(100, rot), (center + polar_to_cartesian(100, rot)) * 2, Color.hsv(radians_to_degrees(rot), 1, 1))
    Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi), (center + polar_to_cartesian(100, rot + math.pi)) * 2, Color.hsv(radians_to_degrees(rot + math.pi), 1, 1))
    Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi / 2), (center + polar_to_cartesian(100, rot + math.pi / 2)) * 2, Color.hsv(radians_to_degrees(rot + math.pi / 2), 1, 1))
    Draw.drawTriangle(center, center + polar_to_cartesian(100, rot + math.pi * 1.5), (center + polar_to_cartesian(100, rot + math.pi * 1.5)) * 2, Color.hsv(radians_to_degrees(rot + math.pi * 1.5), 1, 1))

end

return self