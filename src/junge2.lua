local junge2 = {}

-- Рисование бутылки
local function drawBottle(x, y, rotation)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(rotation)
    love.graphics.setColor(0.9, 0.9, 1, 0.8)
    love.graphics.rectangle("fill", -5, -10, 10, 20)
    love.graphics.rectangle("fill", -2, -15, 4, 5)
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.rectangle("fill", -4, -5, 8, 14)
    love.graphics.pop()
end

function junge2.zeichne(x, y, isMoving, action)
    love.graphics.setColor(0.4, 0, 0.4) -- Фиолетовый

    -- Дрожание при пердеже
    local drawX = x
    if action == "fart" then
        drawX = x + love.math.random(-2, 2)
    end

    local anim = 0
    -- Анимация бега, если isMoving - это правда (boolean)
    if isMoving == true then
        anim = math.sin(love.timer.getTime() * 20) * 15
    end

    -- Голова
    love.graphics.circle("fill", drawX, y, 15)

    -- Тело
    love.graphics.line(drawX, y, drawX, y + 50)

    -- Ноги
    love.graphics.line(drawX, y + 50, drawX - 15 + anim, y + 80)
    love.graphics.line(drawX, y + 50, drawX + 15 - anim, y + 80)

    -- === РУКИ ===
    local shoulderY = y + 20

    if action == "drink" then
        -- Пьет
        love.graphics.line(drawX + 15, shoulderY, drawX + 5, y - 5)
        love.graphics.line(drawX - 15, shoulderY, drawX + 5, y - 5)
        drawBottle(drawX, y - 10, 2.1)

    elseif action == "meme" then
        -- Машет руками 67
        local armWave = math.sin(love.timer.getTime() * 25) * 20
        love.graphics.line(drawX - 20, shoulderY, drawX + 20, shoulderY + 20 + armWave)
        love.graphics.line(drawX + 20, shoulderY, drawX + 20, shoulderY + 20 + armWave)

    elseif action == "fart" then
        -- Руки по швам
        love.graphics.line(drawX - 20, shoulderY, drawX - 20, y + 50)
        love.graphics.line(drawX + 20, shoulderY, drawX + 20, y + 50)

    else
        -- Обычный бег
        love.graphics.line(drawX, shoulderY, drawX - 20 - anim, shoulderY + 20 + anim)
        love.graphics.line(drawX, shoulderY, drawX + 20 - anim, shoulderY + 20 - anim)

        -- Если просто стоит с бутылкой (hold)
        if action == "hold" then
            drawBottle(drawX + 20, shoulderY + 20, 0)
        end
    end

    love.graphics.setColor(1, 1, 1)
end

return junge2