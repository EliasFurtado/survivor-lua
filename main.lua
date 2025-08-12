Love = require("love")
Game = require("core.game")
Menu = require("core.menu")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

TELA_ATUAL = "menu"

PAUSADO = false

SLOW_FACTOR = 1  -- começa normal
SLOW_RATE = 0

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
    if TELA_ATUAL == "menu" then
        Menu:draw()
    elseif TELA_ATUAL == "game" then
        Game:draw()
        if PAUSADO then
            Menu:draw()
        end
    end
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
    if (TELA_ATUAL == "menu" or PAUSADO) and button == 1 then
        Menu:mousepressed(x, y, button) 
    elseif TELA_ATUAL == "game" and not PAUSADO then
        Game:mousepressed(x, y, button)
    end
end


