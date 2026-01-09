local figur = require("junge1")

local jungeX = 50
local jungeY = 300
local diebX = 400

function love.load()
    love.window.setTitle("Szene 4")
    love.window.setMode(800, 600)
end

function love.update(dt)
    jungeX = jungeX + 150 * dt
    diebX = diebX + 160 * dt
end

function love.draw()
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill",40,50,10,20)

    love.graphics.setColor(0.55, 0.27, 0.07)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    love.graphics.setColor(0.82, 0.71, 0.55)
    love.graphics.rectangle("fill", 0, 200, 800, 200)

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", diebX, 280, 30, 60)

    figur.zeichne(jungeX, jungeY)
end