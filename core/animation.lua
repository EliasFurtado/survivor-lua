local Animation = {}
Animation.__index = Animation

-- imagePath: caminho da imagem
-- frameWidth: largura de cada quadro (se nil, calcula dividindo largura total pela quantidade de frames)
-- frameHeight: altura de cada quadro
-- totalFrames: número de frames (opcional, se nil calcula automático pela largura da imagem e frameWidth)
-- frameTime: tempo por frame (default 0.1)
function Animation:new(imagePath, frameWidth, frameHeight, totalFrames, frameTime)
    local image = love.graphics.newImage(imagePath)
    local iw, ih = image:getDimensions()

    -- Se frameHeight não definido, usa altura da imagem inteira
    frameHeight = frameHeight or ih

    local frames = {}
    for i = 1, totalFrames  do
        table.insert(frames, love.graphics.newQuad((i - 1) * frameWidth, 0,frameWidth, frameHeight,iw , ih))
    end

    local this = {
        image = image,
        frames = frames,
        currentFrame = 1,
        totalFrames = totalFrames,
        frameTime = frameTime or 0.1,
        timer = 0,
        frameWidth = frameWidth,
        frameHeight = frameHeight
    }

    return setmetatable(this, Animation)
end

function Animation:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.frameTime then
        self.timer = self.timer - self.frameTime
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > self.totalFrames then
            self.currentFrame = 1
        end
    end
end

-- x,y = posição para desenhar
-- drawDebug = boolean que desenha o retângulo de debug
function Animation:draw(player, drawDebug, flip)

    local _, _, quadWidth, quadHeight = self.frames[self.currentFrame]:getViewport()
    local ox = quadWidth / 2
    local oy = quadHeight / 2

    local sx = flip and -1 or 1

    love.graphics.draw(
        self.image,
        self.frames[self.currentFrame],
        player.x + ox,       -- posição X + origem X
        player.y + oy,       -- posição Y + origem Y
        0,                   -- rotação
        flip and -1 or 1,    -- scale X (flip)
        1,                   -- scale Y
        ox,                  -- offset X (origem central)
        oy                   -- offset Y (origem central)
    )
    if drawDebug then
        love.graphics.setColor(0, 1, 1, 0.5)
        love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
        love.graphics.circle("line",player.x + player.width/2, player.y + player.height/2, 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Animation

