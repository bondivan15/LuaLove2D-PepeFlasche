local particles = require("particles")

local objects = {}

objects.car = { x = -150, y = 510, speed = 180 }
objects.rocket = { x = 400, y = 430, vy = 0, engine = 0 }
objects.rover = { x = 400, y = 510, speed = 60 }

function objects.load() end

function objects.updateDrive(dt, stages)
    local car = objects.car
    if car.x < 330 then
        car.x = car.x + car.speed * dt
        if math.floor(stages.timer * 10) % 2 == 0 then
            particles.create(car.x, car.y + 20, "smoke")
        end
    elseif stages.timer > 4 then
        stages.stage = "LAUNCH"
        stages.timer = 0
    end
end

function objects.updateLaunch(dt, stages)
    local r = objects.rocket
    r.engine = math.min(r.engine + dt, 1)
    stages.shake = r.engine * 3
    if stages.timer > 1 then
        r.vy = r.vy - 300 * dt
        r.y = r.y + r.vy * dt
        for i = 1, 5 do
            particles.create(r.x + math.random(-10,10), r.y + 70, "fire")
        end
    end
    if r.y < -300 then
        stages.stage = "SPACE"
        stages.timer = 0
        r.y = 800
    end
end

function objects.updateMoon(dt)
    local r = objects.rocket
    if r.y > 430 then
        r.y = r.y - 150 * dt
        for i = 1, 2 do
            particles.create(r.x + math.random(-5,5), r.y + 70, "fire")
        end
    end
end

function objects.updateRover(dt)
    objects.rover.x = objects.rover.x + objects.rover.speed * dt
end

return objects