local font = nil

local Menu = {}
Menu.__index = Menu

function DebugAction(tipo)
    return function()
        if tipo == "fps" then
            DEBUG_FPS = not DEBUG_FPS
        end

        if tipo == "inimigos" then
            DESATIVA_INIMIGOS = not DESATIVA_INIMIGOS
        end
    end
end

function Menu:novoEstrutura(titulo,func,tipo,cor,altura,largura)
    return {
        titulo = titulo,
        func = func,
        now = false,
        last = false,
        tipo = tipo,
        cor = cor or {0.4, 0.4, 0.5, 1},
        altura = altura or 0.8,
        largura = largura or 0.6
    } 
end

function TrocaTela(tela,pausado)
    return function()
        TELA_ATUAL = tela
        PAUSADO = pausado or false
    end
end

local tela_menu = {
    Menu:novoEstrutura("Iniciar Jogo", TrocaTela("game", false),"botao"),
    Menu:novoEstrutura("Configuração", TrocaTela("config", false),"botao"),
    Menu:novoEstrutura("Sair", Love.event.quit,"botao")
}

local tela_pausa = {
    Menu:novoEstrutura("Continuar", TrocaTela("game", false),"botao"),
    Menu:novoEstrutura("Configuração", TrocaTela("config", false),"botao"),
    Menu:novoEstrutura("Menu principal", TrocaTela("menu", false),"botao"),
}

local tela_config = {
    Menu:novoEstrutura("", function() end,"parede",{1,0,0, 1}),
    Menu:novoEstrutura("", function() end,"parede",{0,1,0, 1},0.75,0.55),
    Menu:novoEstrutura("Mostrar Fps", DebugAction("fps"),"botao"),
    Menu:novoEstrutura(function ()
        local status = "SIM"
        if DESATIVA_INIMIGOS then
            status = "NÃO"
        end
        return "Inimigos ? "..status
    end, DebugAction("inimigos"),"botao"),
    Menu:novoEstrutura("Voltar", TrocaTela("menu", PAUSADO),"botao"),
}

function Menu:load()
    font = Love.graphics.newFont(32)

    SomInicio = Love.audio.newSource("utils/audio/game-start.ogg", "static")
end

function Menu:draw()
    SomDeath:stop()
    SomMusic:stop()

    TELA_ANTERIOR = "menu"

    local telas = tela_menu

    if PAUSADO or TELA_ATUAL == "config" then
        telas = tela_pausa
        local texto = "PAUSADO"
        if(TELA_ATUAL == "config") then
            telas = tela_config
            texto = "Configuração"
        end
    
        -- desenha um retângulo escuro semi-transparente por cima da tela
        Love.graphics.setColor(0, 0, 0, 0.5)
        Love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        Love.graphics.setColor(0.4, 0.4, 0.5, 1)
     
        Love.graphics.print(
            texto,
            font,
            (WINDOW_WIDTH * 0.5) - (font:getWidth(texto) * 0.5),
            WINDOW_HEIGHT * 0.2
        )
    end

    ParedeDraw(telas)
    BtnDraw(telas)
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end

    local telas = tela_menu
    if PAUSADO then
        telas = tela_pausa
    end

    if TELA_ATUAL == "config" then
        telas = tela_config
    end

    local w_botao = WINDOW_WIDTH * (1/3)
    local margem = 16
    local espaco = 0
    local altura_total = #telas * (64 + margem)
    local xb = (WINDOW_WIDTH * 0.5) - (w_botao * 0.5)
    local yb = (WINDOW_HEIGHT * 0.5) - (altura_total * 0.5)

    for _, botao in ipairs(telas) do
        if botao.tipo ~= "botao" then
            goto continue
        end
        if x >= xb and x <= xb + w_botao and y >= yb + espaco and y <= yb + espaco + 64 then
            botao.func()
            break 
        end
        espaco = espaco + 64 + margem
        ::continue::
    end
end

function BtnDraw(tableBtn)
    local w_botao = WINDOW_WIDTH * (1/3)

    local margem = 16

    local espaco = 0

    local altura_total = #tableBtn * (64 + margem)

    local xb = (WINDOW_WIDTH * 0.5) - (w_botao * 0.5)

    local yb = (WINDOW_HEIGHT * 0.5) - (altura_total * 0.5)
    
    local mx, my = Love.mouse.getPosition()
    for _, botao in ipairs(tableBtn) do
        if botao.tipo ~= "botao" then
            goto continue
        end
        botao.last = botao.now
        local titulo = type(botao.titulo) == "function" and botao.titulo() or botao.titulo

        local w_texto = font:getWidth(titulo)
        local h_texto = font:getHeight(titulo)
        local color = {0.4, 0.4, 0.5, 1}

        if mx >= xb and mx <= xb + w_botao and my >= (yb + espaco) and my <= (yb + espaco) + 64 then
            color = {0.8, 0.8, 0.9, 1}
        end
        
        Love.graphics.setColor(unpack(color))
        Love.graphics.rectangle(
            "fill", 
            xb,
            (yb + espaco),
            w_botao,
            64)
        Love.graphics.setColor(0, 0, 0, 1)

        Love.graphics.print(
            titulo, 
            font, 
            xb + (w_botao * 0.5) - (w_texto * 0.5), 
            (yb + espaco) + (64 * 0.5) - (h_texto * 0.5)
        )

        espaco = espaco + 64 + margem
        ::continue::
    end
end

function ParedeDraw(tableParede)
    
    for _, parede in ipairs(tableParede) do
        if parede.tipo ~= "parede" then
            goto continue
        end
        
        local largura = WINDOW_WIDTH * parede.largura
        local altura  = WINDOW_HEIGHT * parede.altura

        local x = (WINDOW_WIDTH - largura) / 2
        local y = (WINDOW_HEIGHT - altura) / 2

        Love.graphics.setColor(unpack(parede.cor))
    
        Love.graphics.rectangle("fill", x, y, largura, altura)
    
        Love.graphics.setColor(0, 0, 0, 1)
        ::continue::
    end
end


return setmetatable({}, Menu)