local intro = {}

local held = require("junge1")
local dieb = require("junge2")

local timer = 0
local phase = "titel"
local yOffset = 600
local titleZoom = 0

-- Координаты
local heroX = 100
local diebX = 900
local hasFlasche = false

function intro.load()
    timer = 0
    phase = "titel"
    yOffset = 600
    heroX = 100
    diebX = 900
    hasFlasche = false
    titleZoom = 0
end

function intro.update(dt)
    timer = timer + dt

    if phase == "titel" then
        titleZoom = titleZoom + 1.5 * dt
        if timer > 3 then
            phase = "aufgang"
        end

    elseif phase == "aufgang" then
        yOffset = yOffset - 200 * dt
        if yOffset <= 0 then
            yOffset = 0
            phase = "story"
            timer = 0
        end

    elseif phase == "story" then
        -- Сюжет с кражей
        if timer > 1.5 and timer < 2.5 then
            diebX = diebX - 400 * dt
        elseif timer >= 2.5 and timer < 4.0 then
            hasFlasche = true
            diebX = diebX + 450 * dt
        end

        if timer > 4.5 then
            heroX = heroX + 350 * dt
        end

        if timer > 7 then
            phase = "ende"
        end
    end
end

function intro.draw()
    -- Фон и текст
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    love.graphics.setColor(1, 1, 1)
    local text = "SUPER GAME"
    local font = love.graphics.getFont()
    local scale = 4 + titleZoom
    love.graphics.print(text, 400, 300, 0, scale, scale, font:getWidth(text)/2, font:getHeight()/2)

    -- Всплывающий город
    love.graphics.push()
    love.graphics.translate(0, yOffset)

    -- Небо
    love.graphics.setColor(0.4, 0.6, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 400)

    -- Здания
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 50, 150, 60, 250)   -- Здание 1
    love.graphics.rectangle("fill", 150, 100, 80, 300)  -- Здание 2
    love.graphics.rectangle("fill", 600, 180, 50, 220)  -- Здание 3

    -- === ОКНА (Теперь как в paradise) ===
    love.graphics.setColor(1, 1, 0)

    -- Окна Здания 1
    for winY = 160, 380, 40 do
        love.graphics.rectangle("fill", 60, winY, 15, 25)
        love.graphics.rectangle("fill", 85, winY, 15, 25)
    end

    -- Окна Здания 2
    for winY = 110, 380, 50 do
        love.graphics.rectangle("fill", 160, winY, 25, 35)
        love.graphics.rectangle("fill", 195, winY, 25, 35)
    end

    -- Окна Здания 3
    for winY = 190, 380, 35 do
        love.graphics.rectangle("fill", 615, winY, 20, 25)
    end

    -- Трава и Дорога
    love.graphics.setColor(0.1, 0.8, 0.1)
    love.graphics.rectangle("fill", 0, 400, 800, 200)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 0, 480, 800, 120)

    -- Бутылка
    if hasFlasche == false then
        love.graphics.setColor(0, 0, 1)
        love.graphics.rectangle("fill", 450, 490, 10, 20)
    end

    if phase == "story" then
        -- Вор
        local diebMoving = (timer > 1.5 and timer < 4.0)
        dieb.zeichne(diebX, 460, diebMoving)

        if hasFlasche then
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle("fill", diebX + 20, 460 + 10, 5)
        end
    end

    -- Герой
    local blick = "rechts"
    local heroMoving = false

    if phase == "story" then
        if timer > 2.0 and timer < 3.5 then
            blick = "links"
        else
            blick = "rechts"
        end
        if timer > 4.5 then
            heroMoving = true
        end
    end

    held.zeichne(heroX, 460, blick, heroMoving)

    love.graphics.pop()
end

function intro.isFinished()
    return phase == "ende"
end

return intro