local font = nil

local Menu = {}
Menu.__index = Menu

function Menu:novoBotao(titulo,func)
    return {
        titulo = titulo,
        func = func,
        now = false,
        last = false
    } 
end

local botoes_menu = {
    Menu:novoBotao("Iniciar Jogo", function()
        TELA_ATUAL = "game"
        PAUSADO = false
    end),
    Menu:novoBotao("Sair", Love.event.quit)
}

local botoes_pausa = {
    Menu:novoBotao("Continuar", function()
        TELA_ATUAL = "game"
        PAUSADO = false
    end),
    Menu:novoBotao("Menu principal", function()
        TELA_ATUAL = "menu"
        PAUSADO = false
    end),
}

function Menu:load()
    font = Love.graphics.newFont(32)
end

function Menu:draw()
    local botoes = botoes_menu

    if PAUSADO then
        botoes = botoes_pausa
        local texto_pausa = "PAUSADO"
        -- desenha um retângulo escuro semi-transparente por cima da tela
        Love.graphics.setColor(0, 0, 0, 0.5)
        Love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        Love.graphics.setColor(0.4, 0.4, 0.5, 1)
     
        Love.graphics.print(
            texto_pausa, 
            font, 
            (WINDOW_WIDTH * 0.5) - (font:getWidth(texto_pausa) * 0.5), 
            WINDOW_HEIGHT * 0.2 
        )
    end
    local w_botao = WINDOW_WIDTH * (1/3)

    local margem = 16

    local espaco = 0

    local altura_total = #botoes * (64 + margem)

    local xb = (WINDOW_WIDTH * 0.5) - (w_botao * 0.5)

    local yb = (WINDOW_HEIGHT * 0.5) - (altura_total * 0.5)
    
    local mx, my = Love.mouse.getPosition()
    for i, botao in ipairs(botoes) do
        botao.last = botao.now
        local w_texto = font:getWidth(botao.titulo)
        local h_texto = font:getHeight(botao.titulo)
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
            botao.titulo, 
            font, 
            xb + (w_botao * 0.5) - (w_texto * 0.5), 
            (yb + espaco) + (64 * 0.5) - (h_texto * 0.5)
        )

        espaco = espaco + 64 + margem
    end
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end

    local botoes = botoes_menu
    if PAUSADO then
        botoes = botoes_pausa
    end

    local w_botao = WINDOW_WIDTH * (1/3)
    local margem = 16
    local espaco = 0
    local altura_total = #botoes * (64 + margem)
    local xb = (WINDOW_WIDTH * 0.5) - (w_botao * 0.5)
    local yb = (WINDOW_HEIGHT * 0.5) - (altura_total * 0.5)

    for i, botao in ipairs(botoes) do
        if x >= xb and x <= xb + w_botao and y >= yb + espaco and y <= yb + espaco + 64 then
            botao.func()
            break 
        end
        espaco = espaco + 64 + margem
    end
end

return setmetatable({}, Menu)