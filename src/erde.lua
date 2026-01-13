local erde = {}
local figur = require("junge1")
local jungeX = 50 local jungeY = 300 local dieb1 = 400 local steine = {}
function erde.load()
    for _ = 1, 50 do
        local stein = {}
        stein.x = math.random(0, 800) stein.y = math.random(0, 600)
        stein.breite = math.random(5, 15)
        table.insert(steine, stein) end
end
function erde.update(dt) jungeX = jungeX + 150 * dt
    dieb1 = dieb1 + 160 * dt
end
function erde.draw()
    love.graphics.setColor(0.55, 0.27, 0.07) love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, s in ipairs(steine) do
        love.graphics.rectangle("fill", s.x, s.y, s.breite, s.breite)
    end
    love.graphics.setColor(0, 0, 0) love.graphics.rectangle("fill", 0, 200, 800, 200)
    love.graphics.setColor(0, 0, 0) love.graphics.rectangle("fill", , 280, 30, 60)
    figur.zeichne(diebx,dieby)
    figur.zeichne(jungeX, jungeY)
end
return erde