local paradise = {}

local held = require("junge1")
local dieb = require("junge2")

local phase = "stadt"
local timer = 0

-- Координаты
local groundY = 460
local heroY = groundY
local diebY = groundY
local heroX = 100
local diebX = 400

-- Физика
local heroVelocityY = 0
local diebVelocityY = 0
local gravity = 1000
local heroJumping = false
local diebJumping = false

-- Анимация мира
local worldOffset = 0
local targetOffset = 800
local clouds = {}
local lightnings = {}
local spawnTimer = 0

function paradise.load()
    phase = "stadt"
    timer = 0
    heroY = groundY
    diebY = groundY
    heroX = 100
    diebX = 400
    worldOffset = 0
    clouds = {}
    lightnings = {}
    heroVelocityY = 0
    diebVelocityY = 0
    heroJumping = false
    diebJumping = false

    -- Генерируем облака выше экрана
    for i=1, 8 do
        table.insert(clouds, {
            x = math.random(0, 900),
            y = math.random(-500, -200),
            size = math.random(30, 60)
        })
    end
end

function paradise.update(dt)
    timer = timer + dt

    -- === ФАЗА 1: ГОРОД ===
    if phase == "stadt" then
        heroX = heroX + 150 * dt
        diebX = diebX + 160 * dt

        if timer > 2 then
            phase = "sprung"
            heroVelocityY = -600
            diebVelocityY = -600
        end

        -- === ФАЗА 2: ВЗЛЕТ ===
    elseif phase == "sprung" then
        if worldOffset < targetOffset then
            worldOffset = worldOffset + 500 * dt
        else
            worldOffset = targetOffset
            phase = "himmel"

            heroY = 400
            diebY = 400
            heroVelocityY = 0
            diebVelocityY = 0
            lightnings = {}
        end

        if heroY > 400 then heroY = heroY - 100 * dt end
        if diebY > 400 then diebY = diebY - 100 * dt end

        -- === ФАЗА 3: РАЙ (МОЛНИИ) ===
    elseif phase == "himmel" then
        spawnTimer = spawnTimer + dt
        if spawnTimer > 2.5 then
            spawnTimer = 0
            table.insert(lightnings, {x = 900, y = -370}) -- Молния на уровне облаков
        end

        -- Облака
        for i, c in ipairs(clouds) do
            c.x = c.x - 100 * dt
            if c.x < -100 then c.x = 900 end
        end

        -- Молнии и Прыжки (AI)
        for i, l in ipairs(lightnings) do
            l.x = l.x - 350 * dt

            if not heroJumping then
                local dist = l.x - heroX
                if dist > 0 and dist < 120 then
                    heroJumping = true
                    heroVelocityY = -650
                end
            end
            if not diebJumping then
                local dist = l.x - diebX
                if dist > 0 and dist < 120 then
                    diebJumping = true
                    diebVelocityY = -650
                end
            end
        end

        -- Физика
        if heroJumping then
            heroY = heroY + heroVelocityY * dt
            heroVelocityY = heroVelocityY + gravity * dt
            if heroY >= 400 then heroY = 400; heroJumping = false; heroVelocityY = 0 end
        end

        if diebJumping then
            diebY = diebY + diebVelocityY * dt
            diebVelocityY = diebVelocityY + gravity * dt
            if diebY >= 400 then diebY = 400; diebJumping = false; diebVelocityY = 0 end
        else
            diebY = 400 + math.sin(love.timer.getTime() * 20) * 2
        end
    end
end

function paradise.draw()
    love.graphics.setBackgroundColor(0.4, 0.6, 1)

    love.graphics.push()
    love.graphics.translate(0, worldOffset)

    -- ГОРОД (ВНИЗУ)
    love.graphics.setColor(0.1, 0.8, 0.1)
    love.graphics.rectangle("fill", 0, 400, 800, 200)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 0, 480, 800, 120)

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 50, 150, 60, 250)
    love.graphics.rectangle("fill", 150, 100, 80, 300)
    love.graphics.rectangle("fill", 600, 180, 50, 220)

    love.graphics.setColor(1, 1, 0)
    for winY = 160, 380, 40 do love.graphics.rectangle("fill", 60, winY, 15, 25); love.graphics.rectangle("fill", 85, winY, 15, 25) end
    for winY = 110, 380, 50 do love.graphics.rectangle("fill", 160, winY, 25, 35); love.graphics.rectangle("fill", 195, winY, 25, 35) end
    for winY = 190, 380, 35 do love.graphics.rectangle("fill", 615, winY, 20, 25) end

    -- РАЙ (ВВЕРХУ)
    love.graphics.setColor(1, 1, 1)
    for _, c in ipairs(clouds) do
        love.graphics.circle("fill", c.x, c.y, c.size)
        love.graphics.circle("fill", c.x+20, c.y+10, c.size*0.9)
    end

    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.rectangle("fill", 0, -350, 800, 150) -- Пол облаков

    love.graphics.setColor(1, 1, 0)
    love.graphics.setLineWidth(4)
    for _, l in ipairs(lightnings) do
        love.graphics.line(l.x, l.y, l.x-15, l.y+20, l.x+10, l.y+40, l.x-5, l.y+70)
    end
    love.graphics.setLineWidth(1)

    love.graphics.pop()

    local isMoving = true
    dieb.zeichne(diebX, diebY, isMoving)
    held.zeichne(heroX, heroY, "rechts", isMoving)
end

function paradise.isFinished()
    return timer > 12 -- Уровень длится 12 секунд, потом выход
end

return paradise