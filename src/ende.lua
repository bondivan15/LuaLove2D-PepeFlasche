local ende = {}

local held = require("junge1") -- Оранжевый
local dieb = require("junge2") -- Вор

local timer = 0
local heroX = 200
local heroY = 400
local diebX = 500
local diebY = 400

local heroRotation = 0
local diebAction = "hold"
local fartGas = {}

function ende.load()
    timer = 0
    heroX = 200
    heroY = 400
    diebX = 500
    diebY = 400
    heroRotation = 0
    diebAction = "hold"
    fartGas = {}
end

local function spawnFart(x, y)
    for i=1, 3 do
        table.insert(fartGas, {
            x = x,
            y = y + love.math.random(-10, 10),
            vx = 200 + love.math.random(0, 100),
            vy = love.math.random(-20, 20),
            size = love.math.random(5, 15),
            life = 2
        })
    end
end

function ende.update(dt)
    timer = timer + dt

    if timer > 1 and timer < 3 then
        diebAction = "drink" -- Пьет

    elseif timer >= 3 and timer < 4 then
        diebAction = "hold" -- Пауза

    elseif timer >= 4 and timer < 7 then
        diebAction = "fart" -- Пердит
        spawnFart(diebX - 20, diebY + 30)

        if timer > 4.5 then
            -- Оранжевый падает в обморок
            if heroRotation < 1.57 then heroRotation = heroRotation + 5 * dt end
            if heroY < 440 then heroY = heroY + 100 * dt end
        end

    elseif timer >= 7 and timer < 10 then
        diebAction = "meme" -- 67
    end

    -- Обновляем газ
    for i = #fartGas, 1, -1 do
        local f = fartGas[i]
        f.x = f.x - f.vx * dt
        f.y = f.y + f.vy * dt
        f.size = f.size + 10 * dt
        f.life = f.life - dt
        if f.life <= 0 then table.remove(fartGas, i) end
    end
end

function ende.draw()
    -- === ФОН АДА ===
    love.graphics.setBackgroundColor(0.2, 0, 0) -- Темно-красный фон

    -- Пол Ада
    love.graphics.setColor(0.4, 0, 0)
    love.graphics.rectangle("fill", 0, 460, 800, 140)

    -- Декор Ада (Шипы на заднем плане)
    love.graphics.setColor(0.3, 0, 0)
    love.graphics.polygon("fill", 100, 460, 150, 300, 200, 460)
    love.graphics.polygon("fill", 600, 460, 650, 350, 700, 460)
    love.graphics.polygon("fill", 350, 460, 400, 380, 450, 460)

    -- === ПЕРСОНАЖИ ===
    held.zeichne(heroX, heroY, "rechts", false, heroRotation)
    dieb.zeichne(diebX, diebY, false, diebAction)

    -- Газ (зеленый)
    for _, f in ipairs(fartGas) do
        love.graphics.setColor(0.2, 0.8, 0.1, 0.6)
        love.graphics.circle("fill", f.x, f.y, f.size)
    end

    -- Текст
    love.graphics.setColor(1, 1, 1)
    if timer > 4 and timer < 7 then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("*PUUUUUUPS*", 0, 100, 800, "center")
    elseif diebAction == "meme" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(60))
        love.graphics.print("67", diebX - 100, diebY - 150)
    end
end

return ende