local erde = {}

local held = require("junge1")
local dieb = require("junge2")

-- Фазы: "sky_run" -> "fall" -> "tunnel"
local phase = "sky_run"
local timer = 0

-- Координаты
local heroX = 50
local heroY = 400
local diebX = 300
local diebY = 400

-- ДЫРА БУДЕТ СПРАВА
local holeX = 700

-- Физика
local heroVelocityY = 0
local diebVelocityY = 0
local gravity = 1000
local isJumpingHero = false
local isJumpingDieb = false

local cameraY = 0
local clouds = {}
local stones = {}
local spawnTimer = 0

function erde.load()
    phase = "sky_run"
    timer = 0
    heroX = 50
    heroY = 400
    diebX = 300
    diebY = 400
    heroVelocityY = 0
    diebVelocityY = 0
    isJumpingHero = false
    isJumpingDieb = false
    cameraY = 0
    stones = {}
    spawnTimer = 0

    clouds = {}
    for i=0, 5 do
        table.insert(clouds, {x = i * 160, y = math.random(380, 420), size = 50})
    end
end

function erde.update(dt)
    timer = timer + dt

    -- === ФАЗА 1: БЕГ ПО ОБЛАКАМ ===
    if phase == "sky_run" then
        heroX = heroX + 200 * dt
        diebX = diebX + 210 * dt

        -- Бежим к дыре
        if heroX > holeX then
            phase = "fall"
            heroVelocityY = 150
            diebVelocityY = 150
        end

        -- === ФАЗА 2: ПАДЕНИЕ В ДЫРУ ===
    elseif phase == "fall" then
        heroVelocityY = heroVelocityY + gravity * dt
        diebVelocityY = diebVelocityY + gravity * dt

        heroY = heroY + heroVelocityY * dt
        diebY = diebY + diebVelocityY * dt

        -- СИНХРОНИЗАЦИЯ: Оба героя летят к центру дыры (holeX)
        -- Используем более жесткую привязку, чтобы они не разлетались
        local speedX = 150

        if heroX < holeX then heroX = heroX + speedX * dt end
        if diebX < holeX then diebX = diebX + speedX * dt end

        -- Если кто-то перелетел, возвращаем чуть назад
        if heroX > holeX + 20 then heroX = heroX - speedX * dt end
        if diebX > holeX + 20 then diebX = diebX - speedX * dt end

        cameraY = heroY - 300

        -- Приземление в туннеле
        if heroY > 2000 then
            phase = "tunnel"
            heroY = 350
            diebY = 350
            heroX = 100
            diebX = 400
            heroVelocityY = 0
            diebVelocityY = 0
            isJumpingHero = false
            isJumpingDieb = false
            stones = {}
        end

        -- === ФАЗА 3: ТУННЕЛЬ (КРУГЛЫЕ КАМНИ) ===
    elseif phase == "tunnel" then
        spawnTimer = spawnTimer + dt
        if spawnTimer > 2.0 then
            spawnTimer = 0
            -- Радиус камня = 25
            table.insert(stones, {x = 850, y = 400, r = 25})
        end

        for i, s in ipairs(stones) do
            s.x = s.x - 300 * dt
        end

        -- AI Прыжков
        if not isJumpingHero then
            for _, s in ipairs(stones) do
                if (s.x - heroX) > 0 and (s.x - heroX) < 130 then
                    isJumpingHero = true; heroVelocityY = -600
                end
            end
        end

        if not isJumpingDieb then
            for _, s in ipairs(stones) do
                if (s.x - diebX) > 0 and (s.x - diebX) < 130 then
                    isJumpingDieb = true; diebVelocityY = -600
                end
            end
        end

        -- Физика
        if isJumpingHero then
            heroY = heroY + heroVelocityY * dt
            heroVelocityY = heroVelocityY + gravity * dt
            if heroY >= 350 then heroY = 350; isJumpingHero = false; heroVelocityY = 0 end
        end

        if isJumpingDieb then
            diebY = diebY + diebVelocityY * dt
            diebVelocityY = diebVelocityY + gravity * dt
            if diebY >= 350 then diebY = 350; isJumpingDieb = false; diebVelocityY = 0 end
        else
            diebY = 350 + math.sin(love.timer.getTime() * 20) * 2
        end
    end
end

function erde.draw()
    if phase == "sky_run" or phase == "fall" then
        love.graphics.setBackgroundColor(0.4, 0.6, 1)

        love.graphics.push()
        love.graphics.translate(0, -cameraY)

        -- ОБЛАКА (ТЕПЕРЬ ПРОЗРАЧНЫЕ)
        love.graphics.setColor(1, 1, 1)
        for _, c in ipairs(clouds) do
            love.graphics.circle("fill", c.x, c.y, c.size)
            love.graphics.circle("fill", c.x+30, c.y+10, c.size)
        end

        -- Пол из облаков (Прозрачность 0.7)
        love.graphics.setColor(1, 1, 1, 0.7)
        love.graphics.rectangle("fill", -100, 420, 750, 100)

        -- ГОРОД (ВНИЗУ)
        local cityY = 1000

        love.graphics.setColor(0.1, 0.8, 0.1)
        love.graphics.rectangle("fill", 0, cityY+400, 800, 200)

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", 0, cityY+480, 650, 120)
        love.graphics.rectangle("fill", 750, cityY+480, 50, 120)

        -- Здания
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", 50, cityY+150, 60, 250)
        love.graphics.rectangle("fill", 150, cityY+100, 80, 300)
        love.graphics.rectangle("fill", 600, cityY+180, 50, 220)

        -- Окна
        love.graphics.setColor(1, 1, 0)
        for winY = 160, 380, 40 do love.graphics.rectangle("fill", 60, cityY+winY, 15, 25); love.graphics.rectangle("fill", 85, cityY+winY, 15, 25) end
        for winY = 110, 380, 50 do love.graphics.rectangle("fill", 160, cityY+winY, 25, 35); love.graphics.rectangle("fill", 195, cityY+winY, 25, 35) end

        -- ЗЕМЛЯ (Вход в туннель)
        love.graphics.setColor(0.25, 0.1, 0.05)
        love.graphics.rectangle("fill", -500, 1900, 3000, 600)

        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", 700, 2000, 100)

        love.graphics.pop()

        love.graphics.push()
        love.graphics.translate(0, -cameraY)
        local isMoving = true
        dieb.zeichne(diebX, diebY, isMoving)
        held.zeichne(heroX, heroY, "rechts", isMoving)
        love.graphics.pop()
    end

    if phase == "tunnel" then
        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.setColor(0.25, 0.1, 0.05)
        love.graphics.rectangle("fill", 0, 0, 800, 150)
        love.graphics.rectangle("fill", 0, 450, 800, 150)
        love.graphics.setColor(0.4, 0.25, 0.1)
        love.graphics.rectangle("fill", 0, 150, 800, 300)

        -- КРУГЛЫЕ КАМНИ
        love.graphics.setColor(0.5, 0.5, 0.5) -- Серые
        for _, s in ipairs(stones) do
            love.graphics.circle("fill", s.x, s.y, s.r)
        end

        local isMoving = true
        dieb.zeichne(diebX, diebY, isMoving)
        held.zeichne(heroX, heroY, "rechts", isMoving)
    end
end

function erde.isFinished()
    -- Если таймер > 15 секунд, переходим в Hell
    return timer > 15
end

return erde