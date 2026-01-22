local hell = {}

local held = require("junge1")
local dieb = require("junge2")

-- Фазы: "tunnel_end", "fall_hell", "hell_run"
local phase = "tunnel_end"
local timer = 0

local heroX = 100
local heroY = 350
local diebX = 400
local diebY = 350

local heroVelocityY = 0
local diebVelocityY = 0
local gravity = 1000
local isJumpingHero = false
local isJumpingDieb = false

local cameraY = 0
local obstacles = {}
local spawnTimer = 0

local holeX = 700

function hell.load()
    phase = "tunnel_end"
    timer = 0
    heroX = 100
    heroY = 350
    diebX = 400
    diebY = 350
    heroVelocityY = 0
    diebVelocityY = 0
    isJumpingHero = false
    isJumpingDieb = false
    cameraY = 0
    obstacles = {}
    spawnTimer = 0
end

function hell.update(dt)
    timer = timer + dt

    if phase == "tunnel_end" then
        heroX = heroX + 200 * dt
        diebX = diebX + 210 * dt

        if heroX > holeX then
            phase = "fall_hell"
            heroVelocityY = 150
            diebVelocityY = 150
        end

    elseif phase == "fall_hell" then
        heroVelocityY = heroVelocityY + gravity * dt
        diebVelocityY = diebVelocityY + gravity * dt
        heroY = heroY + heroVelocityY * dt
        diebY = diebY + diebVelocityY * dt

        local speedX = 150
        if heroX < holeX then heroX = heroX + speedX * dt end
        if diebX < holeX then diebX = diebX + speedX * dt end

        cameraY = heroY - 300

        if heroY > 1500 then
            phase = "hell_run"
            heroY = 400
            diebY = 400
            heroX = 100
            diebX = 400
            heroVelocityY = 0
            diebVelocityY = 0
            isJumpingHero = false
            isJumpingDieb = false
            obstacles = {}
        end

    elseif phase == "hell_run" then
        spawnTimer = spawnTimer + dt
        if spawnTimer > 1.8 then
            spawnTimer = 0
            table.insert(obstacles, {x = 850, y = 450})
        end

        for i, o in ipairs(obstacles) do
            o.x = o.x - 350 * dt
        end

        if not isJumpingHero then
            for _, o in ipairs(obstacles) do
                if (o.x - heroX) > 0 and (o.x - heroX) < 140 then
                    isJumpingHero = true; heroVelocityY = -650
                end
            end
        end

        if not isJumpingDieb then
            for _, o in ipairs(obstacles) do
                if (o.x - diebX) > 0 and (o.x - diebX) < 140 then
                    isJumpingDieb = true; diebVelocityY = -650
                end
            end
        end

        if isJumpingHero then
            heroY = heroY + heroVelocityY * dt
            heroVelocityY = heroVelocityY + gravity * dt
            if heroY >= 400 then heroY = 400; isJumpingHero = false; heroVelocityY = 0 end
        end

        if isJumpingDieb then
            diebY = diebY + diebVelocityY * dt
            diebVelocityY = diebVelocityY + gravity * dt
            if diebY >= 400 then diebY = 400; isJumpingDieb = false; diebVelocityY = 0 end
        else
            diebY = 400 + math.sin(love.timer.getTime() * 25) * 3
        end
    end
end

function hell.draw()
    if phase == "tunnel_end" or phase == "fall_hell" then
        love.graphics.setBackgroundColor(0, 0, 0)

        love.graphics.push()
        love.graphics.translate(0, -cameraY)

        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.rectangle("fill", -100, 150, 850, 300)

        love.graphics.setColor(0.25, 0.1, 0.05)
        love.graphics.rectangle("fill", -100, 0, 900, 150)
        love.graphics.rectangle("fill", -100, 450, 800, 150)
        love.graphics.rectangle("fill", 800, 450, 100, 150)

        love.graphics.setColor(0.3, 0, 0)
        love.graphics.rectangle("fill", -500, 1300, 3000, 1000)

        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(0, -cameraY)
        local isMoving = true
        dieb.zeichne(diebX, diebY, isMoving)
        held.zeichne(heroX, heroY, "rechts", isMoving)
        love.graphics.pop()
    end

    if phase == "hell_run" then
        love.graphics.setBackgroundColor(0.2, 0, 0)

        love.graphics.setColor(0.4, 0, 0)
        love.graphics.rectangle("fill", 0, 0, 800, 150)
        love.graphics.rectangle("fill", 0, 500, 800, 100)

        love.graphics.setColor(0.5, 0.1, 0.1)
        love.graphics.rectangle("fill", 0, 150, 800, 350)

        love.graphics.setColor(0.6, 0, 0.2)
        for _, o in ipairs(obstacles) do
            love.graphics.polygon("fill", o.x, o.y, o.x + 20, o.y - 60, o.x + 40, o.y)
        end

        local isMoving = true
        dieb.zeichne(diebX, diebY, isMoving)
        held.zeichne(heroX, heroY, "rechts", isMoving)
    end
end

-- === ВАЖНО: ТАЙМЕР ДЛЯ ОКОНЧАНИЯ ===
function hell.isFinished()
    return timer > 15 -- Через 15 секунд переходим к ENDE
end

return hell