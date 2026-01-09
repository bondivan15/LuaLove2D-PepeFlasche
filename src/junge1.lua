local junge1 = {}

function junge1.zeichne(x, y)
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.circle("fill", x, y, 15)
    love.graphics.line(x, y, x, y + 50)
    love.graphics.line(x - 20, y + 20, x + 20, y + 20)
    love.graphics.line(x, y + 50, x - 15, y + 80)
    love.graphics.line(x, y + 50, x + 15, y + 80)
    love.graphics.setColor(1, 1, 1)
end

return junge1