local stages = require("stages")
local draw = require("draw")

function love.load()
    love.window.setTitle("Space Journey 2.0")
    love.window.setMode(800, 600)
    stages.load()
end

function love.update(dt)
    stages.update(dt)
end

function love.draw()
    draw.render()
end
