local physics = require("physics")
local options = require("options")
local video = require("video")

local function remap_looped(value, min_in, max_in, min_out, max_out)
    local range_in = max_in - min_in
    local range_out = max_out - min_out
    -- Wrap the input value to the input range
    value = (value - min_in) % range_in
    -- Scale to output range
    return min_out + (value / range_in) * range_out
end

local data = {}

local frame = 1
local x = 0
local y = 0
local done_frame = false
local done_video = false
local scale_x = (options.right - options.left) / options.resolution
local scale_y = (options.bottom - options.top) / options.resolution

function _draw()
    if done_frame then return end
    if done_video then return end


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
        done_frame = true
    end

    if not done_frame then return end

    print(frame .. "/" .. options.frames)

    video.frames[frame] = data
    print(video.frames[frame][5][5][1])
    frame = frame + 1

    options.update_values()
    done_frame = false
    x = 0
    y = 0
    data = {}
    scale_x = (options.right - options.left) / options.resolution
    scale_y = (options.bottom - options.top) / options.resolution

    if frame >= options.frames then
        done_video = true
    end
end

function _update(delta)
    if done_video then video._update(delta) return end
end

function calculate_pendulum(pendulum, time)
    local step = options.DELTA_STEP
    local timer = 0
    while timer < time do
        pendulum = physics.UPDATE_PENDULUM(pendulum, step)
        timer = timer + step
    end
    return pendulum
end
