local Mapa = {}
Mapa.__index = Mapa

local TERRA = 1
local GRAMA = 2
local AGUA  = 3

function Mapa:new(width, height, tileSize)
    local obj = {
        width = width,
        height = height,
        tileSize = tileSize or 32, -- garante valor padrão
        tiles = {},
        tileImages = {}
    }
    setmetatable(obj, Mapa)
    return obj
end

function Mapa:carregarTileset(tilesetImage, tileSize)
    self.tileSize = tileSize or self.tileSize
    local image = Love.graphics.newImage(tilesetImage)
    local tilesetW, tilesetH = image:getWidth(), image:getHeight()
    local tilesX, tilesY = tilesetW / self.tileSize, tilesetH / self.tileSize

    for y = 0, tilesY - 1 do
        for x = 0, tilesX - 1 do
            local quad = Love.graphics.newQuad(
                x * self.tileSize, y * self.tileSize,
                self.tileSize, self.tileSize,
                tilesetW, tilesetH
            )
            table.insert(self.tileImages, { image = image, quad = quad })
        end
    end
end

function Mapa:gerar()
    for y = 1, self.height do
        self.tiles[y] = {}
        for x = 1, self.width do
            self.tiles[y][x] = Love.math.random(TERRA, GRAMA)
        end
    end
end

function Mapa:update(dt)
    -- vazio por enquanto
end

function Mapa:draw()
    for y = 1, self.height do
        for x = 1, self.width do
            local tileIndex = self.tiles[y][x]
            if self.tileImages[tileIndex] then
                Love.graphics.draw(
                    self.tileImages[tileIndex].image,
                    self.tileImages[tileIndex].quad,
                    (x - 1) * self.tileSize,
                    (y - 1) * self.tileSize
                )
            end
        end
    end
end

return Mapa
