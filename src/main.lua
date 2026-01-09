local szene4 = require("erde")

function love.load()
    love.window.setMode(800, 600)
    szene4.load()
end

function love.update(dt)
    szene4.update(dt)
end

function love.draw()
    szene4.draw()
end