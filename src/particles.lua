local particles = { list = {} }
function particles.create(x, y, type)
    table.insert(particles.list, {
        x = x, y = y,
        vx = math.random(-20, 20), vy = (type == "smoke") and math.random(-50, -10) or math.random(100, 200),
        life = 1, type = type
    })
end
function particles.update(dt) for i = #particles.list, 1, -1 do
        local p = particles.list[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt * (p.type == "smoke" and 0.5 or 2)
        if p.life <= 0 then table.remove(particles.list, i) end
    end
end
return particles
