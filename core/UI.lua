-- UIManager.lua
local UI = {}
UI.elements = {}

UI.default = {
    font = love.graphics.newFont(14),
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

function UI.update(dt)
    -- Atualização de estado (hover)
    local mx, my = love.mouse.getPosition()
    for _, e in ipairs(UI.elements) do
        if e.type == "button" then
            e.isHover = mx >= e.x and mx <= e.x + e.w and my >= e.y and my <= e.y + e.h
        end
    end
end

function UI.draw()
    love.graphics.setFont(UI.default.font)
    for _, e in ipairs(UI.elements) do
        if e.type == "button" then
            -- cor de fundo
            if e.isHover then
                love.graphics.setColor(UI.default.buttonHoverColor)
            else
                love.graphics.setColor(UI.default.buttonColor)
            end
            love.graphics.rectangle("fill", e.x, e.y, e.w, e.h, 4, 4)
            
            -- texto
            love.graphics.setColor(UI.default.textColor)
            local tw = UI.default.font:getWidth(e.text)
            local th = UI.default.font:getHeight()
            love.graphics.print(e.text, e.x + (e.w - tw)/2, e.y + (e.h - th)/2)
        
        elseif e.type == "label" then
            love.graphics.setColor(UI.default.textColor)
            love.graphics.print(e.text, e.x, e.y)
        end
    end
end

function UI.mousepressed(x, y, button)
    if button == 1 then
        for _, e in ipairs(UI.elements) do
            if e.type == "button" and e.isHover and e.onClick then
                e.onClick(e.id)
            end
        end
    end
end

return UI
