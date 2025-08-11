Love = require("love")
Game = require("core.game")

function Love.load()
    Game:load()
end

function Love.update(dt)
    Game:update(dt)
end

function Love.draw()
    Game:draw()
end

function Love.keypressed(key)
    Game:keypressed(key)
end

function Love.mousepressed(x, y, button)
    Game:mousepressed(x, y, button)
end


