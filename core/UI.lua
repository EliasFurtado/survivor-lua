-- UIManager.lua
local UI = {}
UI.elements = {}

UI.default = {
    font = Love.graphics.newFont(25),
    buttonColor = {0.2, 0.2, 0.2, 1},
    buttonHoverColor = {0.3, 0.3, 0.3, 1},
    textColor = {1, 1, 1, 1},
    padding = 8
}

function UI.clear()
    UI.elements = {}
end

function UI.addButton(id, x, y, w, h, text, onClick)
    table.insert(UI.elements, {
        type = "button",
        id = id,
        x = x, y = y,
        w = w, h = h,
        text = text,
        onClick = onClick
    })
end

function UI.addLabel(id, x, y, text)
    table.insert(UI.elements, {
        type = "label",
        id = id,
        x = x, y = y,
        text = text
    })
end

function UI.addCheckbox(x, y, size, label, default, onChange)
    table.insert(UI.elements, {
        type = "checkbox",
        x = x, y = y,
        size = size or 20,
        label = label or "",
        checked = default or false,
        onChange = onChange or function() end
    })
end

function UI.addPanel(id, x, y, w, h, opts)
    table.insert(UI.elements, {
        type = "panel",
        id = id,
        x = x, y = y,
        w = w, h = h,
        color = opts and opts.color or {0, 0, 0, 0.5}, -- cor com opacidade
        image = opts and opts.image or nil,            -- imagem opcional
        mode  = opts and opts.mode or "fit"            -- "fit", "stretch" ou "tile"
    })
end

function UI.update(dt)
    -- Atualização de estado (hover)
    local mx, my = Love.mouse.getPosition()
    for _, e in ipairs(UI.elements) do
        if e.type == "button" then
            e.isHover = mx >= e.x and mx <= e.x + e.w and my >= e.y and my <= e.y + e.h
        elseif e.type == "checkbox" then
            e.isHover = mx >= e.x and mx <= e.x + e.size and my >= e.y and my <= e.y + e.size
        end
    end
end

function UI.draw()
    local fontanterior = Love.graphics.getFont()
    Love.graphics.setFont(UI.default.font)
    for _, e in ipairs(UI.elements) do
        if e.type == "button" then
            -- cor de fundo
            if e.isHover then
                Love.graphics.setColor(UI.default.buttonHoverColor)
            else
                Love.graphics.setColor(UI.default.buttonColor)
            end
            Love.graphics.rectangle("fill", e.x, e.y, e.w, e.h, 4, 4)
            
            -- texto
            Love.graphics.setColor(UI.default.textColor)
            local tw = UI.default.font:getWidth(e.text)
            local th = UI.default.font:getHeight()
            Love.graphics.print(e.text, e.x + (e.w - tw)/2, e.y + (e.h - th)/2)
        
        elseif e.type == "label" then
            Love.graphics.setColor(UI.default.textColor)
            Love.graphics.print(e.text, e.x, e.y)
        elseif e.type == "checkbox" then
             -- borda da caixinha
            Love.graphics.setColor(1, 1, 1)
            Love.graphics.rectangle("line", e.x, e.y, e.size, e.size)

            -- se marcado, desenha preenchido
            if e.checked then
                Love.graphics.setColor(0, 1, 0) -- verde
                Love.graphics.rectangle("fill", e.x + 3, e.y + 3, e.size - 6, e.size - 6)
            end

            -- label
            Love.graphics.setColor(1, 1, 1)
            Love.graphics.print(e.label, e.x + e.size + 8, e.y - 5)
        elseif e.type == "panel" then
            if e.image then
                local imgW, imgH = e.image:getDimensions()
                
                if e.mode == "stretch" then
                    Love.graphics.setColor(1, 1, 1, 1)
                    Love.graphics.draw(e.image, e.x, e.y, 0, e.w / imgW, e.h / imgH)

                elseif e.mode == "fit" then
                    local scale = math.min(e.w / imgW, e.h / imgH)
                    local offsetX = (e.w - imgW * scale) / 2
                    local offsetY = (e.h - imgH * scale) / 2
                    Love.graphics.setColor(1, 1, 1, 1)
                    Love.graphics.draw(e.image, e.x + offsetX, e.y + offsetY, 0, scale, scale)

                elseif e.mode == "tile" then
                    Love.graphics.setColor(1, 1, 1, 1)
                    for ix = e.x, e.x + e.w, imgW do
                        for iy = e.y, e.y + e.h, imgH do
                            Love.graphics.draw(e.image, ix, iy)
                        end
                    end
                end
            else
                -- painel apenas colorido
                Love.graphics.setColor(e.color)
                Love.graphics.rectangle("fill", e.x, e.y, e.w, e.h, 6, 6)
            end
        end
    end
    Love.graphics.setFont(fontanterior) -- reseta fonte
end

function UI.mousepressed(x, y, button)
    if button == 1 then
        for _, e in ipairs(UI.elements) do
            if e.type == "button" and e.isHover and e.onClick then
                e.onClick(e.id)
            elseif e.type == "checkbox" and e.isHover then
                e.checked = not e.checked
                e.onChange(e.checked)
            end
        end
    end
end

return UI
