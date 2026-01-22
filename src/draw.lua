local stages = require("stages")
local objects = require("objects")
local particles = require("particles")
local stars = require("stars")
local draw = {}

function draw.render()
    love.graphics.push()

    if stages.shake > 0 then
        love.graphics.translate(
                math.random(-stages.shake, stages.shake),
                math.random(-stages.shake, stages.shake)
        )
    end
    if stages.stage == "DRIVE" or stages.stage == "LAUNCH" then
        love.graphics.clear(0.15, 0.4, 0.8)
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("fill", 0, 530, 800, 70)
    else
        love.graphics.clear(0, 0, 0)
        for _, s in ipairs(stars.list) do
            love.graphics.setColor(1,1,1,s.o)
            love.graphics.circle("fill", s.x, s.y, s.s)
        end
        -- Рисуем серую поверхность и для Луны, и для Лунохода
        if stages.stage == "MOON" or stages.stage == "ROVER" then
            love.graphics.setColor(0.6,0.6,0.6)
            love.graphics.rectangle("fill", 0, 530, 800, 70)
        end
    end
    for _, p in ipairs(particles.list) do
        if p.type == "smoke" then
            love.graphics.setColor(1,1,1,p.life * 0.5)
        else
            love.graphics.setColor(1,0.5,0,p.life)
        end
        love.graphics.circle("fill", p.x, p.y, p.life * 10)
    end
    if stages.stage == "DRIVE" then
        drawCar(objects.car)
    end

    if stages.stage ~= "SPACE" or stages.timer < 7 then
        drawRocket(objects.rocket.x,
                stages.stage == "SPACE" and 300 or objects.rocket.y)
    end

    -- Рисуем Луноход
    if stages.stage == "ROVER" then
        drawRover(objects.rover)
    end

    love.graphics.pop()
    love.graphics.setColor(1,1,1)
    love.graphics.print("Stage: "..stages.stage, 10, 10)
end

function drawCar(car)
    love.graphics.setColor(0.8,0.2,0.2)
    love.graphics.rectangle("fill", car.x, car.y, 80, 25, 5)
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.rectangle("fill", car.x + 10, car.y - 15, 40, 20, 5)
    love.graphics.setColor(0,0,0)
    love.graphics.circle("fill", car.x + 15, car.y + 25, 10)
    love.graphics.circle("fill", car.x + 65, car.y + 25, 10)
end

function drawRocket(x, y)
    love.graphics.setColor(0.9,0.9,0.9)
    love.graphics.rectangle("fill", x-20, y, 40, 70, 10)

    love.graphics.setColor(0.8,0.2,0.2)
    love.graphics.polygon("fill", x-20, y, x+20, y, x, y-30)

    love.graphics.setColor(0.2,0.6,1)
    love.graphics.circle("fill", x, y+20, 10)

    love.graphics.setColor(0.8,0.2,0.2)
    love.graphics.polygon("fill", x-20, y+40, x-40, y+70, x-20, y+70)
    love.graphics.polygon("fill", x+20, y+40, x+40, y+70, x+20, y+70)
end

function drawRover(rover)
    love.graphics.setColor(0.7, 0.8, 0.9)
    love.graphics.rectangle("fill", rover.x, rover.y, 45, 20, 5)

    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", rover.x + 10, rover.y + 20, 6)
    love.graphics.circle("fill", rover.x + 35, rover.y + 20, 6)

    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.line(rover.x + 10, rover.y, rover.x + 5, rover.y - 10)
    love.graphics.circle("fill", rover.x + 5, rover.y - 10, 2)
end

return draw