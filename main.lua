Love = require("love")
Game = require("core.game")
Menu = require("core.menu")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

TELA_ATUAL = "menu"
TELA_ANTERIOR = "menu"

PAUSADO = false
DEBUG_FPS = false
DESATIVA_INIMIGOS = false

SLOW_FACTOR = 1  -- começa normal
SLOW_RATE = 0


Telas = {
    menu = function() Menu:draw() end,
    game = function() Game:draw() end,
    config = function() Menu:draw() end
}

function Love.load()
    Game:load()
    Menu:load()
end

function Love.update(dt)

    if SLOW_RATE > 0 then
        SLOW_FACTOR = SLOW_FACTOR - SLOW_RATE * dt
        if SLOW_FACTOR < 0 then
            SLOW_FACTOR = 0
        end
    end

    if TELA_ATUAL == "game" and not PAUSADO  then
        Game:update(SLOW_FACTOR * dt)
    end
end

function Love.draw()
    (Telas[TELA_ATUAL] or function() print("Inválida") end)()

    if PAUSADO then
        (Telas["menu"] or function() print("Inválida") end)()
    end
    DrawFPS()
end

function Love.keypressed(key)
    if key == "escape" and TELA_ATUAL ~= "menu" and not Player:isDead() then
        PAUSADO = not PAUSADO -- alterna entre PAUSADO e rodando
    end

    if not PAUSADO then
        Game:keypressed(key)
    end
end

function Love.mousepressed(x, y, button)
    if (TELA_ATUAL == "menu" or PAUSADO or TELA_ATUAL == "config") and button == 1 then
        Menu:mousepressed(x, y, button) 
    elseif TELA_ATUAL == "game" and not PAUSADO then
        Game:mousepressed(x, y, button)
    end
end

function DrawFPS()
    if not DEBUG_FPS then return end

    local fps = Love.timer.getFPS()
    Love.graphics.setColor(0, 1, 0, 1) -- Verde
    Love.graphics.print(fps, WINDOW_WIDTH - 80, 10)
    Love.graphics.setColor(1, 1, 1, 1) -- Volta pra cor padrão (branco)
end



