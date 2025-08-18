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
        lerpSpeed = 1 -- velocidade de suavização
    }
    setmetatable(cam, Camera)
    return cam
end

function Camera:update(dt, W_map, H_map)
    -- posição desejada da câmera (centralizando o alvo)
    self.screenWidth,self.screenHeight = love.graphics.getDimensions()

    local targetX = self.target.x - self.screenWidth / 2
    local targetY = self.target.y - self.screenHeight / 2

    -- limita a câmera para não sair do mapa
    W_map = W_map or 0
    H_map = H_map or 0
    targetX = math.max(0, math.min(targetX, W_map - self.screenWidth))
    targetY = math.max(0, math.min(targetY, H_map - self.screenHeight))
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