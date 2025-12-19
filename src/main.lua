-- Hauptvariablen
local scene = "INTRO"
local timer = 0
local gameTime = 0
local cameraScroll = 0

-- Charakter-Konfiguration
local boy1 = {
    x = 500, y = 400, color = {0, 0.6, 1},
    hasBottle = true, state = "idle", dir = -1,
    jumpY = 0, throwTimer = 0, rotation = 0
}
local boy2 = {
    x = -100, y = 400, color = {1, 0.5, 0},
    state = "idle", dir = 1,
    jumpY = 0, hitTimer = 0, rotation = 0
}

-- Listen für Objekte
local obstacles = {}   -- Hindernisse
local projectiles = {} -- Wurfgeschosse
local particles = {}   -- Krümel/Effekte
local clouds = {}      -- Deko-Wolken
local fartGas = {}     -- Pups-Wolken

function love.load()
    love.window.setTitle("Die gestohlene Flasche - 67 Edition")
    love.window.setMode(800, 600)

    -- Deko-Wolken initialisieren
    for i=1, 6 do
        table.insert(clouds, {x = love.math.random(0, 800), y = love.math.random(50, 200), scale = love.math.random(0.8, 1.2)})
    end
end

function love.update(dt)
    timer = timer + dt
    gameTime = gameTime + dt

    -- --- SZENEN LOGIK ---

    if scene == "INTRO" then
        if timer > 3 then switchScene("PEACE") end

    elseif scene == "PEACE" then
        -- Boy 2 (Orange) schleicht sich an
        boy2.state = "walk"
        boy2.x = boy2.x + 100 * dt
        if boy2.x >= boy1.x - 50 then switchScene("STEAL") end

    elseif scene == "STEAL" then
        boy2.state = "idle"
        if timer > 0.5 then
            boy1.hasBottle = false
            boy1.dir = 1
            boy2.dir = 1
            switchScene("CHASE_PARK")
        end

    elseif string.find(scene, "CHASE") then
        updateChase(dt)

        -- Szenenwechsel
        if scene == "CHASE_PARK" and timer > 8 then switchScene("CHASE_HEAVEN") end
        if scene == "CHASE_HEAVEN" and timer > 8 then switchScene("CHASE_HELL") end
        if scene == "CHASE_HELL" and timer > 8 then switchScene("FINALE") end

    elseif scene == "FINALE" then
        -- PHASE 1: Reset & Trinken
        if timer < 0.1 then
            boy1.x = 200; boy1.y = 400; boy1.dir = 1; boy1.hasBottle = true; boy1.jumpY = 0
            boy2.x = 500; boy2.y = 400; boy2.dir = -1; boy2.hasBottle = false; boy2.jumpY = 0
            boy1.state = "idle"
            boy2.state = "idle"
        end

        if timer > 1 and timer < 3 then
            boy1.state = "drink" -- Blau trinkt
        elseif timer >= 3 and timer < 4 then
            boy1.state = "charge" -- Blau dreht sich um
            boy1.dir = -1
        elseif timer >= 4 and timer < 7 then
            boy1.state = "fart" -- Pupsen
            spawnFart(boy1.x + 40, boy1.y - 30)
            if timer > 4.5 then boy2.state = "faint" end -- Orange fällt um

        elseif timer >= 7 and timer < 10 then
            -- HIER PASSIERT DAS "67" MEME
            boy1.state = "meme"
            -- Orange liegt weiterhin ohnmächtig da
            boy2.state = "faint"

        elseif timer >= 10 then
            switchScene("OUTRO")
        end

        updateFart(dt)

    elseif scene == "OUTRO" then
        -- Ende
    end
end

-- --- HILFSFUNKTIONEN ---

function updateChase(dt)
    local speed = 250
    if scene == "CHASE_HELL" then speed = 350 end
    cameraScroll = cameraScroll + speed * dt

    boy1.state = "run"
    boy2.state = "run"

    local targetX1 = 200
    local targetX2 = 600

    if boy2.hitTimer > 0 then
        boy2.hitTimer = boy2.hitTimer - dt
        boy2.color = {1, 1, 1}
        targetX2 = 400
    else
        boy2.color = {1, 0.5, 0}
    end

    boy1.x = boy1.x + (targetX1 - boy1.x) * 2 * dt
    boy2.x = boy2.x + (targetX2 - boy2.x) * 2 * dt

    updateObstacles(dt, speed)
    updateThrowing(dt)
    updateProjectiles(dt)
end

function updateObstacles(dt, speed)
    if love.math.random() < 0.015 then
        local type = "rock"
        if scene == "CHASE_HEAVEN" then type = "cloud" end
        if scene == "CHASE_HELL" then type = "fire" end
        table.insert(obstacles, {x = 900, y = 440, w = 40, h = 40, type = type})
    end

    for i = #obstacles, 1, -1 do
        local o = obstacles[i]
        o.x = o.x - speed * dt
        checkJump(boy1, o)
        checkJump(boy2, o)
        if o.x < -100 then table.remove(obstacles, i) end
    end
    applyGravity(boy1, dt)
    applyGravity(boy2, dt)
end

function checkJump(char, obs)
    if char.jumpY == 0 and obs.x > char.x and obs.x < char.x + 100 then
        char.velocityY = -500
    end
end

function applyGravity(char, dt)
    if char.velocityY then
        char.jumpY = char.jumpY + char.velocityY * dt
        char.velocityY = char.velocityY + 1500 * dt
        if char.jumpY >= 0 then char.jumpY = 0; char.velocityY = nil end
    end
end

function updateThrowing(dt)
    boy1.throwTimer = boy1.throwTimer + dt
    if boy1.throwTimer > 2.5 and boy1.jumpY == 0 then
        boy1.state = "pickup"
        if boy1.throwTimer > 3 then
            local pType = "stone"
            if scene == "CHASE_HEAVEN" then pType = "star" end
            if scene == "CHASE_HELL" then pType = "ember" end
            table.insert(projectiles, {x = boy1.x + 20, y = boy1.y - 20, vx = 600, vy = -400, type = pType})
            boy1.throwTimer = 0; boy1.state = "run"
        end
    end
end

function updateProjectiles(dt)
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 1000 * dt

        if p.x > boy2.x and p.x < boy2.x + 40 and p.y > boy2.y + boy2.jumpY - 60 and p.y < boy2.y + boy2.jumpY then
            local chance = love.math.random()
            if chance > 0.5 then
                if boy2.jumpY == 0 then boy2.velocityY = -600 end
                table.remove(projectiles, i)
            else
                boy2.hitTimer = 1.0
                spawnCrumbs(p.x, p.y, {1, 1, 0})
                table.remove(projectiles, i)
            end
        elseif p.y > 500 then
            table.remove(projectiles, i)
        end
    end
end

function spawnFart(x, y)
    for i=1, 3 do
        table.insert(fartGas, {
            x = x, y = y + love.math.random(-10, 10),
            vx = 200 + love.math.random(0, 100),
            vy = love.math.random(-20, 20),
            size = love.math.random(5, 15), life = 2
        })
    end
end

function updateFart(dt)
    for i = #fartGas, 1, -1 do
        local f = fartGas[i]
        f.x = f.x + f.vx * dt
        f.y = f.y + f.vy * dt
        f.size = f.size + 10 * dt
        f.life = f.life - dt
        if f.life <= 0 then table.remove(fartGas, i) end
    end
    -- Umfall-Animation Orange
    if boy2.state == "faint" then
        if boy2.rotation < 1.57 then boy2.rotation = boy2.rotation + 5 * dt end
        if boy2.y < 440 then boy2.y = boy2.y + 100 * dt end
    end
end


function switchScene(newScene)
    scene = newScene
    timer = 0
    obstacles = {}
    projectiles = {}
    particles = {}
    fartGas = {}
    boy1.x = 100; boy2.x = 400
end

-- --- ZEICHEN FUNKTIONEN ---

function love.draw()
    drawBackground()

    if scene ~= "INTRO" and scene ~= "OUTRO" and scene ~= "CHASE_HEAVEN" then
        love.graphics.setColor(0.1, 0.4, 0.1)
        love.graphics.rectangle("fill", 0, 460, 800, 140)
    end

    if string.find(scene, "CHASE") then
        for _, o in ipairs(obstacles) do drawObstacle(o) end
        for _, p in ipairs(projectiles) do drawProjectile(p) end
    end

    if scene ~= "INTRO" and scene ~= "OUTRO" then
        drawCharacter(boy1)
        drawCharacter(boy2)
    end

    -- Pups-Gas
    for _, f in ipairs(fartGas) do
        love.graphics.setColor(0.2, 0.8, 0.1, 0.6)
        love.graphics.circle("fill", f.x, f.y, f.size)
    end

    drawUI()
    drawParticles()
end

function drawObstacle(o)
    if o.type == "rock" then
        love.graphics.setColor(0.4, 0.4, 0.4); love.graphics.circle("fill", o.x + 20, o.y + 20, 20)
    elseif o.type == "cloud" then
        love.graphics.setColor(1, 1, 1, 0.8); love.graphics.circle("fill", o.x + 20, o.y + 20, 25)
    elseif o.type == "fire" then
        love.graphics.setColor(1, 0.2, 0); love.graphics.polygon("fill", o.x, o.y+40, o.x+20, o.y, o.x+40, o.y+40)
    end
end

function drawProjectile(p)
    if p.type == "stone" then love.graphics.setColor(0.3, 0.3, 0.3); love.graphics.circle("fill", p.x, p.y, 5)
    elseif p.type == "star" then love.graphics.setColor(1, 1, 0); love.graphics.circle("fill", p.x, p.y, 8)
    elseif p.type == "ember" then love.graphics.setColor(1, 0.5, 0); love.graphics.rectangle("fill", p.x, p.y, 6, 6)
    end
end

function drawCharacter(c)
    love.graphics.setColor(c.color)
    love.graphics.setLineWidth(5)

    local cx, cy = c.x, c.y + c.jumpY
    local bodyW, bodyH = 40, 60

    local legAngle = 0
    local armAngle = 0

    if c.state == "run" then
        legAngle = math.sin(gameTime * 20) * 0.8
        armAngle = math.sin(gameTime * 20) * 0.8
    elseif c.state == "pickup" then
        cy = cy + 20; armAngle = 2
    elseif c.state == "hit" then
        armAngle = 3
    elseif c.state == "fart" then
        cx = cx + love.math.random(-2, 2)
    end

    love.graphics.push()

    -- Rotation für Umfallen
    if c.rotation ~= 0 then
        love.graphics.translate(cx, cy)
        love.graphics.rotate(c.rotation)
        love.graphics.translate(-cx, -cy)
    end

    -- Körper & Kopf
    love.graphics.rectangle("fill", cx - bodyW/2, cy - bodyH, bodyW, bodyH)
    love.graphics.circle("fill", cx, cy - bodyH - 15, 20)

    -- Augen
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", cx - 5 + c.dir*5, cy - bodyH - 20, 5)
    love.graphics.circle("fill", cx + 5 + c.dir*5, cy - bodyH - 20, 5)
    love.graphics.setColor(0,0,0)
    love.graphics.circle("fill", cx - 5 + c.dir*7, cy - bodyH - 20, 2)
    love.graphics.circle("fill", cx + 5 + c.dir*7, cy - bodyH - 20, 2)

    love.graphics.setColor(c.color)

    -- BEINE
    local lLegX = cx + math.sin(legAngle) * 20
    local lLegY = cy + math.cos(legAngle) * 30
    love.graphics.line(cx - 10, cy, lLegX - 10, lLegY)
    love.graphics.line(cx + 10, cy, cx + math.sin(-legAngle)*20 + 10, cy + math.cos(-legAngle)*30)

    -- ARME (Logik für Pups-Finale & 67)
    local shoulderY = cy - bodyH + 10

    if c.state == "drink" then
        love.graphics.line(cx - 15, shoulderY, cx + 5, cy - bodyH - 5)
        love.graphics.line(cx + 15, shoulderY, cx + 5, cy - bodyH - 5)
        drawBottle(cx, cy - bodyH - 10, 120)

    elseif c.state == "fart" then
        love.graphics.line(cx - 20, shoulderY, cx - 20, cy - 20)
        love.graphics.line(cx + 20, shoulderY, cx + 20, cy - 20)

    elseif c.state == "meme" then
        -- DIE 67 BEWEGUNG: Arme vor dem Körper hoch und runter
        local armWave = math.sin(gameTime * 25) * 20 -- Schnelle Bewegung
        -- Beide Arme parallel nach vorne und hoch/runter
        love.graphics.line(cx - 20, shoulderY, cx + 20, shoulderY + 20 + armWave)
        love.graphics.line(cx + 20, shoulderY, cx + 20, shoulderY + 20 + armWave)

        -- Optional: Er hüpft dabei leicht
        if c == boy1 then love.graphics.translate(0, math.sin(gameTime*25)*2) end

    elseif c.state == "faint" then
        love.graphics.line(cx - 20, shoulderY, cx - 30, shoulderY - 20)
        love.graphics.line(cx + 20, shoulderY, cx + 30, shoulderY - 20)

    elseif c.state == "pickup" then
        love.graphics.line(cx, shoulderY, cx + 20*c.dir, cy)

    else
        -- Normales Rennen / Werfen
        local rArmAngle = armAngle
        if c == boy1 and c.state == "run" and c.throwTimer > 2.8 then rArmAngle = -3 end

        local lArmX = cx + math.sin(-armAngle) * 20
        local lArmY = shoulderY + 25 + math.cos(-armAngle) * 5
        love.graphics.line(cx - 20, shoulderY, lArmX - 20, lArmY)

        local rArmX = cx + math.sin(rArmAngle) * 20
        local rArmY = shoulderY + 25 + math.cos(rArmAngle) * 5
        love.graphics.line(cx + 20, shoulderY, rArmX + 20, rArmY)

        if (c == boy1 and boy1.hasBottle) or (c == boy2 and not boy1.hasBottle) then
            if c.state ~= "drink" and c.state ~= "meme" then drawBottle(rArmX + 20, rArmY, armAngle) end
        elseif c == boy1 and c.state == "run" and c.throwTimer > 2.8 then
            love.graphics.setColor(0.3, 0.3, 0.3); love.graphics.circle("fill", rArmX + 20, rArmY, 5)
        end
    end

    love.graphics.pop()
end

function drawBottle(x, y, rotation)
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

function drawBackground()
    if scene == "INTRO" then
        love.graphics.clear(0, 0, 0)
    elseif scene == "CHASE_HEAVEN" then
        love.graphics.clear(0.4, 0.7, 1)
        love.graphics.setColor(1, 1, 1, 0.8)
        for _, cl in ipairs(clouds) do
            local dx = (cl.x - cameraScroll * 0.5) % 900 - 50
            love.graphics.circle("fill", dx, cl.y, 30 * cl.scale)
            love.graphics.circle("fill", dx+20, cl.y+5, 25 * cl.scale)
        end
    elseif scene == "CHASE_HELL" then
        love.graphics.clear(0.3, 0, 0)
        love.graphics.setColor(1, 0.2, 0)
        for i=0, 800, 40 do
            love.graphics.polygon("fill", i, 600, i+20, 500 + math.sin(gameTime*20 + i)*20, i+40, 600)
        end
    else
        love.graphics.clear(0.5, 0.8, 0.9)
    end
end

function drawUI()
    love.graphics.setColor(1, 1, 1)

    if scene == "INTRO" then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("DIE GESTOHLENE FLASCHE\n(67 Edition)", 0, 250, 800, "center")

    elseif scene == "FINALE" then
        if timer > 4 and timer < 7 then
            love.graphics.setFont(love.graphics.newFont(20))
            love.graphics.printf("*PUUUUUUPS*", 0, 100, 800, "center")
        elseif boy1.state == "meme" then
            -- GROSSES 67
            love.graphics.setFont(love.graphics.newFont(60))
            love.graphics.print("67", boy1.x - 20, boy1.y - 120)
        end

    elseif scene == "OUTRO" then
        love.graphics.setFont(love.graphics.newFont(20))
        love.graphics.printf("ENDE", 0, 250, 800, "center")
    end
end

-- Krümel / Effekte
function spawnCrumbs(x, y, color)
    for i=1, 5 do
        table.insert(particles, {x=x, y=y, vx=love.math.random(-100,100), vy=love.math.random(-200,-50), life=0.5, color=color})
    end
end
function updateParticles(dt)
    for i=#particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt; p.y = p.y + p.vy * dt; p.vy = p.vy + 400 * dt; p.life = p.life - dt
        if p.life <= 0 then table.remove(particles, i) end
    end
end
function drawParticles()
    for _,p in ipairs(particles) do
        love.graphics.setColor(p.color)
        love.graphics.rectangle("fill", p.x, p.y, 4, 4)
    end
end