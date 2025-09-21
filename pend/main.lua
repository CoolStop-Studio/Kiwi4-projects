local physics = require("physics")

local pend1 = {
    arm1 = {
        alpha = 0, -- derivative of omega
        omega = 0, -- derivative of theta
        theta = math.pi / 2, -- rotation
        length = 20,
        damping = 0.0
    },
    arm2 = {
        alpha = 0, -- derivative of omega
        omega = 0, -- derivative of theta
        theta = math.pi / 2, -- rotation
        length = 20,
        damping = 0.0
    },
}

function _update(delta)
    pend1 = physics.UPDATE_PENDULUM(pend1, delta)

    --print(pend1.arm1.theta)
end

function _draw()
    Draw.clearScreen(Color.BLACK)
    local x1 = pend1.arm1.length * math.sin(pend1.arm1.theta)
    local y1 = -pend1.arm1.length * math.cos(pend1.arm1.theta)
    local x2 = pend1.arm2.length * math.sin(pend1.arm2.theta) + x1
    local y2 = -pend1.arm2.length * math.cos(pend1.arm2.theta) + y1

    Draw.drawLine(Vector(64, 64), Vector(x1 + 64, y1 + 64), Color.RED)
    Draw.drawLine(Vector(x1 + 64, y1 + 64), Vector(x2 + 64, y2 + 64), Color.WHITE)
end