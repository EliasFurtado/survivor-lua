Love = require("love")
Game = require("core.game")
local SM = require("core.SM")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

local fullscreen = false

DEBUG_FPS = false
DESATIVA_INIMIGOS = false


function Love.load()
    -- Configuração do ScreenManager
    SM.configure({
        showTitle = true,
        titleAlign = "center",
        backgroundColor = {0.15, 0.15, 0.18, 1}
    })

    -- Tela Menu
    SM.register("menu", {
        title = "Menu Inicial",
        draw = function(self)
            local w, h = love.graphics.getDimensions()
            love.graphics.printf(
                "Clique para iniciar o jogo",
                0, h/2, w, "center"
            )
        end,
        mousepressed = function(self, x, y, button)
            if button == 1 then -- Botão esquerdo
                SM.set("game")
            end
        end
    })

    -- Tela Jogowwww
    SM.register("game", {
        title = "Tela do Jogo",
        enter = function(self, previousScreenName)  
            if previousScreenName == "menu" then
                Game:load()
            end
        end,
        draw = function(self)
            Game:draw()
        end,
        mousepressed = function (self, x, y, button)
            Game:mousepressed(x, y, button)
        end,
        update = function(self, dt)
            Game:update(dt)
        end,
        keypressed = function(self, key)
            if key == "escape" then
                SM.set("menu")
            end
        end
    })

    -- Começa no menu
    SM.set("menu")
end

function Love.update(dt)
    SM.update(dt)
end

function Love.draw()
   SM.draw()
   DrawFPS()
end

function Love.keypressed(key, sc, rep)
    SM.keypressed(key, sc, rep)
end

function Love.mousepressed(x, y, button,istouch, presses)
    SM.mousepressed(x, y, button, istouch, presses)
end

function Love.wheelmoved(x, y) SM.wheelmoved(x, y) end
function Love.textinput(t) SM.textinput(t) end
function Love.resize(w, h) SM.resize(w, h) end

function DrawFPS()
    if not DEBUG_FPS then return end

    local fps = Love.timer.getFPS()
    Love.graphics.setColor(0, 1, 0, 1) -- Verde
    Love.graphics.print(fps, WINDOW_WIDTH - 80, 10)
    Love.graphics.setColor(1, 1, 1, 1) -- Volta pra cor padrão (branco)
end



