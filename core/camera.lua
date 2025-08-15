-- camera.lua
Camera = {}
Camera.__index = Camera

function Camera:new(target, screenWidth, screenHeight)
    local cam = {
        x = 0,
        y = 0,
        target = target, -- objeto que a câmera vai seguir
        screenWidth = screenWidth,
        screenHeight = screenHeight,
        lerpSpeed = 0.1 -- velocidade de suavização
    }
    setmetatable(cam, Camera)
    return cam
end

function Camera:update(dt)
    -- posição desejada da câmera (centralizando o alvo)
    local targetX = self.target.x - self.screenWidth / 2
    local targetY = self.target.y - self.screenHeight / 2

    -- suavização com LERP
    self.x = self.x + (targetX - self.x) * self.lerpSpeed
    self.y = self.y + (targetY - self.y) * self.lerpSpeed
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end

return Camera