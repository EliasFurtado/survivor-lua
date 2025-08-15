Love = require("love")
Game = require("core.game")
local SM = require("core.SM")
local UI = require("core.UI")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

DEBUG_FPS = true
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
        enter = function(self)
            UI.clear()
            UI.addButton("start", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) , 200, 50, "Iniciar Jogo", function()
                SM.set("game")
            end)
            UI.addButton("config", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 70 , 200, 50, "Configuração", function()
                SM.set("config")
            end)
            UI.addButton("exit", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 140, 200, 50, "Sair", function()
                Love.event.quit()
            end)
        end,
        update = function(self, dt)
            UI.clear()
            UI.addButton("start", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) , 200, 50, "Iniciar Jogo", function()
                SM.set("game")
            end)
            UI.addButton("config", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 70 , 200, 50, "Configuração", function()
                SM.set("config")
            end)
            UI.addButton("exit", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 140, 200, 50, "Sair", function()
                Love.event.quit()
            end)
            UI.update(dt)
        end,
        draw = function(self) UI.draw() end,
        mousepressed = function(self, x, y, b) UI.mousepressed(x, y, b) end
    })

    -- Tela Configuração
    SM.register("config", {
        title = "Configurações",
        enter = function(self,previousScreenName)
            UI.clear()
            UI.addButton("voltar", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 140, 200, 50, "Voltar", function()
                SM.set(previousScreenName)
            end)
        end,
        update = function(self, dt)
            UI.update(dt)
        end,
        draw = function(self) UI.draw() end,
        mousepressed = function(self, x, y, b) UI.mousepressed(x, y, b) end
    })

    -- Tela Jogo
    SM.register("game", {
        title = "Tela do Jogo",
        bgColor = {0.2, 0.1, 0.1, 1},
        enter = function(self, previousScreenName)  
            if previousScreenName == "menu" then
                Game:load()
            end
        end,
        draw = function(self)
            if self.bgColor then
                love.graphics.clear(self.bgColor)
            end
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
                SM.set("config")
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
   WINDOW_WIDTH  = Love.graphics.getWidth() or 800
   WINDOW_HEIGHT = Love.graphics.getHeight() or 600
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



