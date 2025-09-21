local self = {}

local function length(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

function self.UPDATE_PENDULUM(pendulum, delta)
    local g = -500 -- positive Y is down
    local L1, L2 = pendulum.arm1.length, pendulum.arm2.length
    local th1, th2 = pendulum.arm1.theta, pendulum.arm2.theta
    local w1, w2   = pendulum.arm1.omega, pendulum.arm2.omega
    local d1, d2   = pendulum.arm1.damping, pendulum.arm2.damping

    local diff = th1 - th2
    local denom = 2 - math.cos(2*diff)

    local a1 = (-g*(2*math.sin(th1) + math.sin(th1 - 2*th2))
                - 2*math.sin(diff)*(w2^2*L2 + w1^2*L1*math.cos(diff))) / (L1*denom)

    local a2 = (2*math.sin(diff)*(w1^2*L1 + g*math.cos(th1) + w2^2*L2*math.cos(diff))) / (L2*denom)

    -- Semi-implicit Euler
    w1 = w1 + (a1 - d1*w1) * delta
    w2 = w2 + (a2 - d2*w2) * delta
    th1 = th1 + w1 * delta
    th2 = th2 + w2 * delta

    return {
        arm1 = {
            alpha = a1,
            omega = w1,
            theta = th1,
            length = L1,
            damping = d1
        },
        arm2 = {
            alpha = a2,
            omega = w2,
            theta = th2,
            length = L2,
            damping = d2
        }
    }
end

return self
