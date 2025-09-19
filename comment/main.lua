local function object(pos1, pos2, color)
    return {
        pos1 = pos1,
        pos2 = pos2,
        color = color
    }
end

local function item(pos1, pos2, tex, move, type, timer)
    return {
        pos1 = pos1,
        pos2 = pos2,
        tex = tex,
        move = move,
        type = type,
        timer = timer
    }
end

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

local function normalize(v)
    local length = math.sqrt(v.x * v.x + v.y * v.y)
    if length ~= 0 then
        return Vector(v.x / length, v.y / length)
    else
        return Vector(0, 0) -- can’t normalize zero vector
    end
end

PLAYER = {
    pos = Vector(50, 0),
    vel = Vector(0, 0),
    color = Color.hex("#ffffff"),
    size = Vector(5, 5),
    ACCEL = 300,
    MAX_SPEED = 50,
    JUMP_SPEED = 200,
    TEXTURE = Load.loadImage("projects/comment/assets/player.png"),
    HAT = Load.loadImage("projects/comment/assets/hat.png")
}

CAMERA = {
    pos = Vector(0, 0),
}

GRAVITY = Vector(0, 600)

local BG = Load.loadImage("projects/comment/assets/bg.png")
local MG = Load.loadImage("projects/comment/assets/mg.png")

GUN = {
    gun_right = Load.loadImage("projects/comment/assets/gun/gun_right.png"),
    gun_left = Load.loadImage("projects/comment/assets/gun/gun_left.png"),
    gun_shoot_right = Load.loadImage("projects/comment/assets/gun/gun_shoot_right.png"),
    gun_shoot_left = Load.loadImage("projects/comment/assets/gun/gun_shoot_left.png")
}

local shooting =false
local shoot_timer = 0
local dead = false
local death_message = ""
local right = false
local time = 0
local next_frog = 0
local next_bee = 0
local score = 0

WORLD = {
    object(Vector(0, 110), Vector(60, 120), Color.hex("#ff6f61")),
    object(Vector(90, 100), Vector(150, 110), Color.hex("#6a5acd")),
    object(Vector(180, 85), Vector(240, 95), Color.hex("#ffb347")),
    object(Vector(50, 70), Vector(100, 80), Color.hex("#77dd77")),
    object(Vector(140, 65), Vector(200, 75), Color.hex("#ff6961")),
    object(Vector(20, 50), Vector(70, 60), Color.hex("#aec6cf")),
    object(Vector(110, 45), Vector(160, 55), Color.hex("#f49ac2")),
    object(Vector(200, 40), Vector(260, 50), Color.hex("#cb99c9")),
    object(Vector(70, 25), Vector(130, 35), Color.hex("#ffcc99")),
    object(Vector(0, 20), Vector(40, 30), Color.hex("#c23b22")),
    object(Vector(160, 20), Vector(210, 30), Color.hex("#03c03c")),
    object(Vector(90, 10), Vector(140, 20), Color.hex("#779ecb")),
    object(Vector(230, 15), Vector(280, 25), Color.hex("#fdfd96")),
    object(Vector(40, -5), Vector(90, 5), Color.hex("#ffb7ce")),
    object(Vector(120, -10), Vector(180, 0), Color.hex("#966fd6")),
    object(Vector(200, -20), Vector(250, -10), Color.hex("#ff7f50")),
    object(Vector(20, -35), Vector(70, -25), Color.hex("#89cff0")),
    object(Vector(150, -40), Vector(210, -30), Color.hex("#ffbf00")),
    object(Vector(260, -45), Vector(310, -35), Color.hex("#b19cd9")),
    object(Vector(80, -60), Vector(140, -50), Color.hex("#50c878"))
}


ITEMS = {
    --item(Vector(100, 40), Vector(105, 45), Load.loadImage("projects/comment/assets/cigarette.png"), Vector(0, 0), "cigarette"),
    item(Vector(0, 0), Vector(3, 2), Load.loadImage("projects/comment/assets/bee.png"), Vector(5, 0), "bee", 0),
    item(Vector(130, 85), Vector(135, 90), Load.loadImage("projects/comment/assets/frog.png"), Vector(0, 0), "frog", 0),
    --item(Vector(130, 85), Vector(135, 90), Load.loadImage("projects/comment/assets/orange.png"), Vector(0, 0), "orange"),

}

local FPS = require("fps")

function die(msg)
    dead = true
    death_message = msg
end

local bee_tex = Load.loadImage("projects/comment/assets/bee.png")
local frog_tex = Load.loadImage("projects/comment/assets/frog.png")
local dead_frog_tex = Load.loadImage("projects/comment/assets/dead_frog.png")
local lose_tex = Load.loadImage("projects/comment/assets/lose.png")

function _update(delta)
    if dead then
        return
    end
    time = time + delta
    next_bee = next_bee - delta
    next_frog = next_frog - delta

    if next_bee <= 0 then
        local pos = math.random(-50, 100)
        ITEMS[#ITEMS + 1] = item(Vector(-20, pos), Vector(-17, pos + 2), bee_tex, Vector(5, 0), "bee")
        next_bee = 2
    end

    if next_frog <= 0 then
        local pos = math.random(0, 200)
        ITEMS[#ITEMS + 1] = item(Vector(pos, 125), Vector(pos + 5, 130), frog_tex, Vector(0, 0), "frog")
        next_frog = 2
    end


    FPS._update(delta)
    local is_on_ground = false

    PLAYER.pos = PLAYER.pos + (PLAYER.vel * delta)
    if Input.isKeyPressed("left") then
        PLAYER.vel.x = clamp(PLAYER.vel.x - (PLAYER.ACCEL * delta), -PLAYER.MAX_SPEED, PLAYER.MAX_SPEED)
        right = false
    end

    if Input.isKeyPressed("right") then
        PLAYER.vel.x = clamp(PLAYER.vel.x + (PLAYER.ACCEL * delta), -PLAYER.MAX_SPEED, PLAYER.MAX_SPEED)
        right = true
    end

    if not (Input.isKeyPressed("left") or Input.isKeyPressed("right")) then
        PLAYER.vel.x = clamp(PLAYER.vel.x * 0.8 * delta, -PLAYER.MAX_SPEED, PLAYER.MAX_SPEED)
    end

    for _, o in ipairs(WORLD) do
        -- Ground (standing on top of block)
        if (PLAYER.vel.y >= 0) and
        (PLAYER.pos.y + PLAYER.size.y + 1 > o.pos1.y) and
        (PLAYER.pos.y < o.pos1.y) and
        (PLAYER.pos.x + PLAYER.size.x > o.pos1.x) and
        (PLAYER.pos.x < o.pos2.x) then
            PLAYER.pos.y = o.pos1.y - PLAYER.size.y - 1
            PLAYER.vel.y = 0
            is_on_ground = true
        end

        -- Ceiling (hitting head)
        if (PLAYER.vel.y < 0) and
        (PLAYER.pos.y < o.pos2.y) and
        (PLAYER.pos.y + PLAYER.size.y > o.pos2.y) and
        (PLAYER.pos.x + PLAYER.size.x > o.pos1.x) and
        (PLAYER.pos.x < o.pos2.x) then
            PLAYER.pos.y = o.pos2.y + 1
            PLAYER.vel.y = 0
        end

        -- Left wall (running into block’s left side)
        if (PLAYER.vel.x > 0) and
        (PLAYER.pos.x + PLAYER.size.x > o.pos1.x) and
        (PLAYER.pos.x < o.pos1.x) and
        (PLAYER.pos.y + PLAYER.size.y > o.pos1.y) and
        (PLAYER.pos.y < o.pos2.y) then
            PLAYER.pos.x = o.pos1.x - PLAYER.size.x - 1
            PLAYER.vel.x = 0
        end

        -- Right wall (running into block’s right side)
        if (PLAYER.vel.x < 0) and
        (PLAYER.pos.x < o.pos2.x) and
        (PLAYER.pos.x + PLAYER.size.x > o.pos2.x) and
        (PLAYER.pos.y + PLAYER.size.y > o.pos1.y) and
        (PLAYER.pos.y < o.pos2.y) then
            PLAYER.pos.x = o.pos2.x + 1
            PLAYER.vel.x = 0
        end
    end

    for i, o in ipairs(ITEMS) do
        if o.type == "skip" then
            goto continue
        end
        if o.type == "dead_frog" then
            o.timer = o.timer - delta
            if o.timer <= 0 then
                ITEMS[i].type = "skip"
            end
            goto continue
        end
        if o.type == "frog" then
            o.move = normalize(PLAYER.pos - o.pos1) * 20
            if shooting then
                if right then
                    if (PLAYER.pos.x + 100 > o.pos1.x) and
                    (PLAYER.pos.x < o.pos2.x) and
                    (PLAYER.pos.y + PLAYER.size.y > o.pos1.y) and
                    (PLAYER.pos.y < o.pos2.y) then
                        ITEMS[i].type = "dead_frog"
                        ITEMS[i].timer = 0.2
                        ITEMS[i].tex = dead_frog_tex
                        score = score + 3
                    end
                else
                    if (PLAYER.pos.x > o.pos1.x) and
                    (PLAYER.pos.x - 100 < o.pos2.x) and
                    (PLAYER.pos.y + PLAYER.size.y > o.pos1.y) and
                    (PLAYER.pos.y < o.pos2.y) then
                        ITEMS[i].type = "dead_frog"
                        ITEMS[i].timer = 0.2
                        ITEMS[i].tex = dead_frog_tex
                        score = score + 3
                    end
                end
                
            end
        end
        ITEMS[i].pos1 = ITEMS[i].pos1 + ITEMS[i].move * delta
        ITEMS[i].pos2 = ITEMS[i].pos2 + ITEMS[i].move * delta
        if (PLAYER.pos.x + PLAYER.size.x > o.pos1.x) and
        (PLAYER.pos.x < o.pos2.x) and
        (PLAYER.pos.y + PLAYER.size.y > o.pos1.y) and
        (PLAYER.pos.y < o.pos2.y) then
            ITEMS[i] = nil
            if o.type == "cigarette" then
                die("You died from smoking a cigarette")
            elseif o.type == "bee" then
                die("According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground. The bee, of course, flies anyway because bees dont care what humans think is impossible. Yellow, black. Yellow, black. Yellow, black. Yellow, black. Ooh, black and yellow! Lets shake it up a little.")
            elseif o.type == "frog" then
                die("frog")
            end
        end
        ::continue::
    end

    if Input.isKeyJustPressed("space") and not shooting then
        shoot_timer = 0.2
    else
        shoot_timer = shoot_timer - delta

    end
    if shoot_timer <= 0 then
        shooting = false
    else
        shooting = true
    end

    if Input.isKeyJustPressed("up") then
            PLAYER.vel.y = -PLAYER.JUMP_SPEED
    end
    if not is_on_ground then
        PLAYER.vel = PLAYER.vel + (GRAVITY * delta)
    end

    CAMERA.pos = PLAYER.pos - Vector(Config.window.width / 2, Config.window.height / 2) + (PLAYER.size / 2) - Vector(1, 1)
end

function _draw()
    if dead then
        Draw.clearScreen(Color.BLACK)
        Draw.drawImage(Vector(0, 0), Vector(29, 21), lose_tex)
        Draw.drawText("YOU DIED", Vector(30, 40), Color.WHITE)
        Draw.drawText(death_message, Vector(20, 60), Color.WHITE)
        Draw.drawText("SCORE: " .. score + time, Vector(20, 20), Color.WHITE)
        return
    end

    Draw.clearScreen(Color(20, 20, 24, 255))

    Draw.drawImage(Vector(0, 0) - (CAMERA.pos * 0.05) - Vector(64, 64), (Vector(Config.window.width, Config.window.height) * 2 - (CAMERA.pos * 0.05)) - Vector(64, 64), BG)
    Draw.drawImage(Vector(0, 0) - (CAMERA.pos * 0.1) - Vector(32, 64), (Vector(Config.window.width, Config.window.height) * 2 - (CAMERA.pos * 0.1)) - Vector(32, 64), MG)

    Draw.drawRect(Vector(0, 0), Vector(Config.window.width, Config.window.height), Color(0, 0, 0, 100))
    for _, o in ipairs(WORLD) do
        Draw.drawRect(o.pos1 - CAMERA.pos, o.pos2 - CAMERA.pos, o.color)
        local highlight_shift = -20
        Draw.drawLine(o.pos1 - CAMERA.pos, Vector(o.pos2.x - CAMERA.pos.x, o.pos1.y - CAMERA.pos.y), Color(o.color.r + highlight_shift, o.color.g + highlight_shift, o.color.b + highlight_shift, 255))
    end

    for _, o in ipairs(ITEMS) do
        if o.type == "skip" then
            goto continue
        end
        Draw.drawImage(o.pos1 - CAMERA.pos, o.pos2 - CAMERA.pos, o.tex)
        ::continue::
    end

    --Draw.drawRect(PLAYER.pos - CAMERA.pos, PLAYER.pos + PLAYER.size - CAMERA.pos, PLAYER.color)
    Draw.drawImage(PLAYER.pos - CAMERA.pos, PLAYER.pos + PLAYER.size - CAMERA.pos, PLAYER.TEXTURE)
    Draw.drawImage(PLAYER.pos - CAMERA.pos - Vector(0, 20), PLAYER.pos + PLAYER.size - CAMERA.pos - Vector(0, 5), PLAYER.HAT)

    local pos1, pos2, img
    if right then
        pos1 = Vector(5, 0)
        pos2 = Vector(15, 5)
        if shooting then
            img = GUN.gun_shoot_right
        else
            img = GUN.gun_right
        end
    else
        pos1 = Vector(-10, 0)
        pos2 = Vector(0, 5)
        if shooting then
            img = GUN.gun_shoot_left
        else
            img = GUN.gun_left
        end
    end
    Draw.drawImage(PLAYER.pos - CAMERA.pos + pos1, PLAYER.pos - CAMERA.pos + pos2, img)

    

    --FPS._draw()
    Draw.drawText("SCORE: " .. math.floor(score + time), Vector(2, 2), Color.WHITE)
end