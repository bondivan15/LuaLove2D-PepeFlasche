local stars = { list = {} }

function stars.generate()
    for i = 1, 150 do
        table.insert(stars.list, {
            x = math.random(0, 800),
            y = math.random(0, 600),
            s = math.random(1, 2),
            o = math.random()
        })
    end
end
function stars.update(dt)
    for _, s in ipairs(stars.list) do
        s.y = (s.y + 500 * dt) % 600
    end
end
return stars