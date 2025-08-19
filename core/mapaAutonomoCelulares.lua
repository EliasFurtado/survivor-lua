-- core/mapaAutonomoCelulares.lua
local MapaAC = {}
MapaAC.__index = MapaAC

-- Tipos de tile
local TERRA = 1
local GRAMA = 2
local AGUA  = 3

function MapaAC:new(width, height, fillProb, tileSize)
    local obj = {
        width = width,
        height = height,
        tileSize = tileSize or 32,
        tiles = {},
        fillProb = fillProb or 0.45,
        tileImages = {} -- para armazenar quads do tileset
    }
    setmetatable(obj, MapaAC)

    -- Inicializa o mapa aleatoriamente
    for y = 1, height do
        obj.tiles[y] = {}
        for x = 1, width do
            if math.random() < obj.fillProb then
                obj.tiles[y][x] = TERRA
            else
                obj.tiles[y][x] = GRAMA
            end
        end
    end

    return obj
end

-- Carrega o tileset PNG
function MapaAC:carregarTileset(tilesetImage, tileSize)
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

-- Conta vizinhos do tipo TERRA
function MapaAC:countNeighbors(x, y)
    local count = 0
    for dy = -1, 1 do
        for dx = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local nx, ny = x + dx, y + dy
                if nx < 1 or ny < 1 or nx > self.width or ny > self.height then
                    count = count + 1
                elseif self.tiles[ny][nx] == TERRA then
                    count = count + 1
                end
            end
        end
    end
    return count
end

-- Aplica uma iteração do autômato celular
function MapaAC:step()
    local newTiles = {}
    for y = 1, self.height do
        newTiles[y] = {}
        for x = 1, self.width do
            local neighbors = self:countNeighbors(x, y)
            if self.tiles[y][x] == TERRA then
                newTiles[y][x] = neighbors < 4 and GRAMA or TERRA
            else
                newTiles[y][x] = neighbors >= 5 and TERRA or GRAMA
            end
        end
    end
    self.tiles = newTiles
end

-- Desenha o mapa usando os tiles do PNG
function MapaAC:draw()
    for y = 1, self.height do
        for x = 1, self.width do
            local tileIndex = self.tiles[y][x] -- 1=TERRA, 2=GRAMA, 3=AGUA
            if self.tileImages[tileIndex] then
                Love.graphics.draw(
                    self.tileImages[tileIndex].image,
                    self.tileImages[tileIndex].quad,
                    (x-1) * self.tileSize,
                    (y-1) * self.tileSize
                )
            end
        end
    end
end

function MapaAC:getCenter()
    local centroX = math.floor(self.width / 2)
    local centroY = math.floor(self.height / 2)

    return {
        x = centroX,
        y = centroY,
        tile = {
            x = (centroX - 1) * self.tileSize + self.tileSize / 2,
            y = (centroY - 1) * self.tileSize + self.tileSize / 2
        }
    }
end

return MapaAC
