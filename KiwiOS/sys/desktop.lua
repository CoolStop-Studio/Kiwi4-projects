local self = {}

local font = Load.loadFont("/sys/font/aurora-24.ttf", 9)

local layers = {
    Load.loadImage("/sys/wallpaper/green/mountains_green5.png"),
    Load.loadImage("/sys/wallpaper/green/mountains_green4.png"),
    Load.loadImage("/sys/wallpaper/green/mountains_green3.png"),
    Load.loadImage("/sys/wallpaper/green/mountains_green2.png"),
    Load.loadImage("/sys/wallpaper/green/mountains_green1.png")
}

-- local layers = {
--     Load.loadImage("/sys/wallpaper/red/mountains_red5.png"),
--     Load.loadImage("/sys/wallpaper/red/mountains_red4.png"),
--     Load.loadImage("/sys/wallpaper/red/mountains_red3.png"),
--     Load.loadImage("/sys/wallpaper/red/mountains_red2.png"),
--     Load.loadImage("/sys/wallpaper/red/mountains_red1.png")
-- }

local img_size = Vector(320, 180)

local scroll_multiplier = Vector(1, 1)

local scroll = {
    0.0,
    0.0,
    0.05,
    0.1,
    0.15
}

local offset = {
    Vector(-80, -45),
    Vector(-80, -45),
    Vector(-80, -45),
    Vector(-80, -45),
    Vector(-80, -45)
}

local pos = {}


function self._update()
    pos = {}
    for i = 1, #layers do
        pos[i] = Vector(0, 0) - (Input.getMousePosition() - Vector(Config.window.width / 2, Config.window.height / 2)) * scroll[i] * scroll_multiplier
    end
end

function self._draw()
    for i = 1, #layers do
        Draw.drawImage(pos[i] + offset[i], pos[i] + offset[i] + img_size, layers[i])
        if i == 2 then
            local center = Vector(Config.window.width / 2, Config.window.height / 2)
            Draw.drawText("8:22", center + Vector(-14, 0), PALETTE[2], font)
            Draw.drawText(string.sub(Time.getDay(), 1, 3), center + Vector(-6, 14), PALETTE[2])
            Draw.drawImage(pos[i], pos[i], Config.window.width / 2, Vector(7, 7), Color.WHITE)
        end
    end
end

return self