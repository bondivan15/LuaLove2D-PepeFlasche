local objects = require("objects")
local particles = require("particles")
local stars = require("stars")
local stages = {
    stage = "DRIVE",
    timer = 0,
    shake = 0
}
function stages.load()
    objects.load()
    stars.generate()
end
function stages.update(dt)
    stages.timer = stages.timer + dt
    particles.update(dt)

    if stages.stage == "DRIVE" then
        objects.updateDrive(dt, stages)
    elseif stages.stage == "LAUNCH" then
        objects.updateLaunch(dt, stages)
    elseif stages.stage == "SPACE" then
        stages.shake = 0
        stars.update(dt)
        if stages.timer > 7 then
            stages.stage = "MOON"
            stages.timer = 0
        end
    elseif stages.stage == "MOON" then
        objects.updateMoon(dt)
        if objects.rocket.y <= 430 then
            stages.stage = "ROVER"
        end
    elseif stages.stage == "ROVER" then
        objects.updateRover(dt)
    end
end

return stages