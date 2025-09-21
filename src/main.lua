-- <- So wird eine Zeile auskommentiert (d.h. der Code/Text danach wird bei "Run" ignoriert.)
--[[ Will man über mehrere Zeilen auskommentieren, so verwendet man
     zusätzlich eckige Klammern.
]]--

-- Dies ist eine Methode, die dauerhaft aufgerufen wird - ca. 60 mal pro Sekunde.
function love.draw()
    love.graphics.setBackgroundColor(100/255,0,0)              --Farbewerte sind Anteile von 255. Entspricht also rgb(100,0,0)
    love.graphics.setColor(1,0,0)
    love.graphics.rectangle("fill",400,100,75,25)    --Ein Rechteck, dessen linke obere Ecke bei den Koordinaten (400|100) ist. Es ist 75x25 Pixel groß.
    love.graphics.setColor(0,1,0)
    love.graphics.circle("line",0,0,50)                     --Ein Kreis, dessen Mittelpunkt bei den Koordinaten (0|0) ist. Er hat einen Radius von 50Pixel.
end