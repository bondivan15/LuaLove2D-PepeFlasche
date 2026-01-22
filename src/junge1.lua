local junge1 = {}

-- Универсальная функция: работает и для бега, и для падения в обморок
function junge1.zeichne(x, y, blick, isMoving, rotation)
    love.graphics.setColor(1, 0.5, 0) -- Оранжевый

    -- Если вращение не передали, пусть будет 0
    local angle = rotation or 0

    local anim = 0
    -- Анимация бега только если isMoving == true
    if isMoving and type(isMoving) == "boolean" then
        anim = math.sin(love.timer.getTime() * 15) * 10
    end

    love.graphics.push()

    -- Точка вращения (ноги)
    love.graphics.translate(x, y + 80)
    love.graphics.rotate(angle)
    love.graphics.translate(-x, -(y + 80))

    -- Голова
    love.graphics.circle("fill", x, y, 15)

    -- Глаза
    love.graphics.setColor(0, 0, 0)
    if blick == "links" then
        love.graphics.circle("fill", x - 5, y - 5, 2)
    else
        love.graphics.circle("fill", x + 5, y - 5, 2)
    end

    love.graphics.setColor(1, 0.5, 0)

    -- Тело
    love.graphics.line(x, y, x, y + 50)

    -- Руки (если падаем - руки вверх, иначе - бегут)
    if angle > 0.1 then
        -- Руки при падении
        love.graphics.line(x, y + 20, x - 30, y - 20)
        love.graphics.line(x, y + 20, x + 30, y - 20)
    else
        -- Обычные руки
        love.graphics.line(x, y + 20, x - 20 - anim, y + 20 + anim)
        love.graphics.line(x, y + 20, x + 20 - anim, y + 20 - anim)
    end

    -- Ноги
    love.graphics.line(x, y + 50, x - 15 + anim, y + 80)
    love.graphics.line(x, y + 50, x + 15 - anim, y + 80)

    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)
end

return junge1