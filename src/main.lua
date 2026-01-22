local szeneIntro = require("intro")
local szeneParadise = require("paradise")
local szeneErde = require("erde")
local szeneHell = require("hell")
local szeneEnde = require("ende") -- <--- НОВОЕ

local aktuelleSzene = "intro"

function love.load()
    love.window.setMode(800, 600)
    szeneIntro.load()
    szeneParadise.load()
    szeneErde.load()
    szeneHell.load()
    szeneEnde.load() -- <--- НОВОЕ
end

function love.update(dt)
    if aktuelleSzene == "intro" then
        szeneIntro.update(dt)
        if szeneIntro.isFinished() then
            aktuelleSzene = "paradise"
        end

    elseif aktuelleSzene == "paradise" then
        szeneParadise.update(dt)
        if szeneParadise.isFinished() then
            aktuelleSzene = "erde"
        end

    elseif aktuelleSzene == "erde" then
        szeneErde.update(dt)
        if szeneErde.isFinished() then
            aktuelleSzene = "hell"
        end

    elseif aktuelleSzene == "hell" then
        szeneHell.update(dt)
        -- Переход в КОНЦОВКУ
        if szeneHell.isFinished() then
            aktuelleSzene = "ende"
        end

    elseif aktuelleSzene == "ende" then -- <--- НОВОЕ
        szeneEnde.update(dt)
    end
end

function love.draw()
    if aktuelleSzene == "intro" then
        szeneIntro.draw()
    elseif aktuelleSzene == "paradise" then
        szeneParadise.draw()
    elseif aktuelleSzene == "erde" then
        szeneErde.draw()
    elseif aktuelleSzene == "hell" then
        szeneHell.draw()
    elseif aktuelleSzene == "ende" then -- <--- НОВОЕ
        szeneEnde.draw()
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if key == "return" then
        if aktuelleSzene == "intro" then aktuelleSzene = "paradise"
        elseif aktuelleSzene == "paradise" then aktuelleSzene = "erde"
        elseif aktuelleSzene == "erde" then aktuelleSzene = "hell"
        elseif aktuelleSzene == "hell" then aktuelleSzene = "ende" end
    end
end