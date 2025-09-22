local self = {}

local zoom = 0.1
self.left = -math.pi * zoom
self.right = math.pi * zoom
self.top = -math.pi * zoom
self.bottom = math.pi * zoom
self.resolution = 256

self.TIME_OFFSET = 3.0 -- how far forward in time to calculate
self.DELTA_STEP = 1 / 45

self.STARTING_PENDULUM = {
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

self.hue_min, self.hue_max = 150, 300       -- degrees
self.sat_min, self.sat_max = 0.0, 0.0       -- 0-1
self.val_min, self.val_max = 0.0, 1.0       -- 0-1
return self