Love = require("love")
Game = require("core.game")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

local fullscreen = false

DEBUG_FPS = false
DESATIVA_INIMIGOS = false


function Love.load()
    Game:load()
end

function Love.update(dt)
    Game:update(dt)
end

function Love.draw()
   Game:draw()

   DrawFPS()
end

function Love.keypressed(key)
    Game:keypressed(key)

    if key == "f11" then
        fullscreen = not fullscreen
        Love.window.setFullscreen(fullscreen)

        WINDOW_WIDTH  = Love.graphics.getWidth() or 800
        WINDOW_HEIGHT = Love.graphics.getHeight() or 600
    end
end

function Love.mousepressed(x, y, button)
    Game:mousepressed(x, y, button)
end

function DrawFPS()
    if not DEBUG_FPS then return end

    local fps = Love.timer.getFPS()
    Love.graphics.setColor(0, 1, 0, 1) -- Verde
    Love.graphics.print(fps, WINDOW_WIDTH - 80, 10)
    Love.graphics.setColor(1, 1, 1, 1) -- Volta pra cor padrão (branco)
end



