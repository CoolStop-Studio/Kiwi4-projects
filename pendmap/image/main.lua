local physics = require("physics")
local options = require("options")

local function remap_looped(value, min_in, max_in, min_out, max_out)
    local range_in = max_in - min_in
    local range_out = max_out - min_out
    -- Wrap the input value to the input range
    value = (value - min_in) % range_in
    -- Scale to output range
    return min_out + (value / range_in) * range_out
end

local data = {}

local time = 0
local i = 0
local x = 0
local y = 0
local done = false
local scale_x = (options.right - options.left) / options.resolution
local scale_y = (options.bottom - options.top) / options.resolution

function draw_full()
    for drawx = 0, #data do
        for drawy = 0, #data[0] do
            local theta1 = data[drawx][drawy][1]
            local theta2 = data[drawx][drawy][2]

            local hue = remap_looped(theta2 - theta1, 0, 2*math.pi, options.hue_min, options.hue_max)
            local sat = remap_looped(theta1 + theta2, 0, 2*math.pi, options.sat_min, options.sat_max)
            local val = remap_looped(theta1, 0, 2*math.pi, options.val_min, options.val_max)

            local color = Color.hsv(hue, sat, val)
            Draw.drawPixel(Vector(drawx, drawy), color)
        end
    end
end

function _draw()
    if done then return end

    i = i + 1

    local theta1 = options.left + (x + 0.5) * scale_x   -- +0.5 centers the pixel
    local theta2 = options.top  + (y + 0.5) * scale_y

    local pend = {
        arm1 = {
            alpha = options.STARTING_PENDULUM.arm1.alpha,
            omega = options.STARTING_PENDULUM.arm1.omega,
            theta = theta1,
            length = options.STARTING_PENDULUM.arm1.length,
            damping = options.STARTING_PENDULUM.arm1.damping
        },
        arm2 = {
            alpha = options.STARTING_PENDULUM.arm2.alpha,
            omega = options.STARTING_PENDULUM.arm2.omega,
            theta = theta2,
            length = options.STARTING_PENDULUM.arm2.length,
            damping = options.STARTING_PENDULUM.arm2.damping
        },
    }

    pend = calculate_pendulum(pend, options.TIME_OFFSET)
    local progress = (i  / (options.resolution * options.resolution))
    print(string.sub(progress * 100, 1, 5) .. "%" .. "          -           " .. "Time left: " .. (time / progress) * (1 - progress) .. "s")
    data[x] = data[x] or {}
    data[x][y] = {pend.arm1.theta, pend.arm2.theta, theta1, theta2}

    local theta1_val = data[x][y][1]
    local theta2_val = data[x][y][2]

    local hue = remap_looped(theta1_val - theta2_val, 0, 2*math.pi, options.hue_min, options.hue_max)
    local sat = remap_looped(theta1_val, 0, 2*math.pi, options.sat_min, options.sat_max)
    local val = remap_looped(theta2_val, 0, 2*math.pi, options.val_min, options.val_max)

    local color = Color.hsv(hue, sat, val)
    Draw.drawPixel(Vector(x, y), color)

    x = x + 1

    if x >= Config.window.width then
        x = 0
        y = y + 1
    end
    if y >= Config.window.height then
        done = true
    end

    if not done then return end


    print("Render done in " .. time .. "s")

    draw_full()
end

function _update(delta)
    time = time + delta
    if Input.isMouseJustPressed() then
        if Input.getMousePosition().x < 0 or Input.getMousePosition().y < 0 then
            return
        end
        print("Rotation Top: " .. data[Input.getMousePosition().x][Input.getMousePosition().y][1], "Rotation Bottom: " .. data[Input.getMousePosition().x][Input.getMousePosition().y][2])
        print("Start Rot: " .. data[Input.getMousePosition().x][Input.getMousePosition().y][3], "Start Rot " .. data[Input.getMousePosition().x][Input.getMousePosition().y][4])
    end
end

function calculate_pendulum(pendulum, forward_time)
    local step = options.DELTA_STEP
    local timer = 0
    while timer < forward_time do
        pendulum = physics.UPDATE_PENDULUM(pendulum, step)
        timer = timer + step
    end
    return pendulum
end
