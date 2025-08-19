Love = require("love")
Game = require("core.game")
local SM = require("core.SM")
local UI = require("core.UI")

WINDOW_WIDTH  = Love.graphics.getWidth() or 800
WINDOW_HEIGHT = Love.graphics.getHeight() or 600

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
        update = function(self, dt)
            UI.clear()
            local bx = (WINDOW_WIDTH * 0.2) - (200/2)
            local by = (WINDOW_HEIGHT * 0.5)
            UI.addButton("start", bx, by , 200, 50, "Iniciar Jogo", function()
                SM.set("game")
            end)
            UI.addButton("config", bx, by + 70 , 200, 50, "Configuração", function()
                SM.set("config")
            end)
            UI.addButton("exit", bx, by + 140, 200, 50, "Sair", function()
                Love.event.quit()
            end)

            local bx = (WINDOW_WIDTH * 0.8) - (300/2)
            UI.addButton("git",bx , by - 80, 300, 50, "Acesse a pagina do git!", function()
                Love.system.openURL("https://github.com/EliasFurtado/survivor-lua")
            end)
            -- painel com imagem em "fit" (centralizada e proporcional)
            local bx = (WINDOW_WIDTH * 0.8) - (400/2)
            local img = Love.graphics.newImage("assets/contribuidores.png")
            UI.addPanel("painelgit", bx, by, 400, 300, {
                image = img,
                mode = "fit"
            })
            UI.update(dt)
        end,
        draw = function(self) UI.draw() end,
        mousepressed = function(self, x, y, b) UI.mousepressed(x, y, b) end
    })

    -- Tela Pause
    SM.register("pause", {
        title = "Pause",
        nobackground = true,
        update = function(self, dt)
            UI.clear()
            UI.addButton("continuar", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) , 200, 50, "Continuar", function()
                SM.set("game")
            end)
            UI.addButton("config", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 70 , 200, 50, "Configuração", function()
                SM.set("config")
            end)
            UI.addButton("princ", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 140, 200, 50, "Menu Principal", function()
                SM.set("menu")
            end)
            UI.update(dt)
        end,
        draw = function(self)
            Game:draw() -- desenha o jogo como fundo
            Love.graphics.setColor(0, 0, 0, 0.5) -- preto com 50% opacidade
            Love.graphics.rectangle("fill", 0, 0, Love.graphics.getWidth(), Love.graphics.getHeight())
            Love.graphics.setColor(1, 1, 1, 1) -- reseta cor   

            UI.draw() 
        end,
        mousepressed = function(self, x, y, b) UI.mousepressed(x, y, b) end
    })

    -- Tela Configuração
    SM.register("config", {
        title = "Configurações",
        enter = function(self, previousScreenName)  
            self.previousScreenName = previousScreenName or "menu"
        end,
        update = function(self, dt)
            UI.clear()
            UI.addCheckbox((WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) - 100, 20, "fullscreen", Love.window.getFullscreen(), function(checked)
                SM.toggleFullscreen()
            end)
            UI.addCheckbox((WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) - 50, 20, "Ativar Fps", DEBUG_FPS, function(checked)
                DEBUG_FPS = checked
            end)
            UI.addCheckbox((WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5), 20, "Desativar inimigos", DESATIVA_INIMIGOS, function(checked)
                DESATIVA_INIMIGOS = checked
            end)
            UI.addButton("voltar", (WINDOW_WIDTH * 0.5) - (200/2), (WINDOW_HEIGHT * 0.5) + 140, 200, 50, "Voltar", function()
                SM.set(self.previousScreenName or "menu")
            end)

            UI.update(dt)
        end,
        draw = function(self) UI.draw() end,
        mousepressed = function(self, x, y, b) UI.mousepressed(x, y, b) end
    })

    -- Tela Jogo
    SM.register("game", {
        showTitle = false,
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
                SM.set("pause")
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



