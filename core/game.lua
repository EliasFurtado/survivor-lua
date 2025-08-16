local Player = require("entities.player")
local Enemy = require("entities.enemy")
local Collision = require("core.collision")
local HudExperience = require("hud.hudExperience")
local MapaAC = require("core.mapaAutonomoCelulares")
local Camera = require("core.camera")

local Game = {}
Game.__index = Game

-- Constantes dos tipos de tile
local MAPA_VILA = 1

function Game:load()
    self.player = Player:new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.cam = Camera:new(self.player, love.graphics.getWidth(), love.graphics.getHeight())

     math.randomseed(os.time())

    self.mapa = MapaAC:new(100, 100, 0.45, 32) -- largura, altura, probabilidade inicial
    self.mapa:carregarTileset("assets/tiles.png", 32)
    -- aplica 4-5 iterações para suavizar cavernas
    for i = 1, 5 do
       self. mapa:step()
    end

    self.hudExperience = HudExperience
    self.enemies = {}
    self:spawnEnemies(20)
    self.bullets = {}
    self.lootTable = {}
    self.timeSinceLastEnemySpawn = 0
end

function Game:update(dt)
    self.player:update(dt)
    self.cam:update(dt)
    self.hudExperience.update(WINDOW_WIDTH * 0.01, WINDOW_HEIGHT * 0.01, self.player.experience)
    
    if not DESATIVA_INIMIGOS then
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt)
    
            if Collision.checkAABB(self.player, enemy) then
                self.player:takeDamage(1)
            end
            if enemy:isDead() then
                enemy:dropExperience(self.lootTable)
                table.remove(self.enemies, i)
            end
        end
    end

    for bi = #self.bullets, 1, -1 do
        local bullet = self.bullets[bi]
        bullet:update(dt)
    
        for ei = #self.enemies, 1, -1 do
            local enemy = self.enemies[ei]
    
            if Collision.checkCollisionCircle(bullet, enemy) and not enemy.health:isDead() then
                enemy.health:take(self.player.weapon.damage)
                if self.player.weapon.knockback > 0 then
                    enemy:knockback(bullet.angle, self.player.weapon.knockback)
                end
                table.remove(self.bullets, bi)
    
                if enemy.health:isDead() then
                    enemy:dropExperience(self.lootTable)
                    table.remove(self.enemies, ei)
                end
    
                break
            end
        end

        if not bullet.alive then
            table.remove(self.bullets, bi)
        end
    end

    for li = #self.lootTable, 1, -1 do
        local drop = self.lootTable[li]
        local gained = drop:update(dt, self.player)
        if gained > 0 then
            self.player.experience:add(gained)
        end
        if not drop.alive then
            table.remove(self.lootTable, li)
        end
    end
    
    if self.timeSinceLastEnemySpawn >= 5 then
        self:spawnEnemies(10)
        self.timeSinceLastEnemySpawn = 0
    end

    if Player:isDead() then
        Love.event.quit()
    end
end

function Game:draw()
    self.cam:apply()
    self.mapa:draw(10) -- tamanho do tile = 10 pixels
    self.player:draw()

    for li = #self.lootTable, 1, -1 do
        local loot = self.lootTable[li]
        loot:draw()
    end
    for ei = #self.enemies, 1, -1 do
        local enemy = self.enemies[ei]
        enemy:draw()
    end

    for bi = #self.bullets, 1, -1 do
        local bullet = self.bullets[bi]
        bullet:draw()
    end
    self.cam:clear()

    self.hudExperience.draw(WINDOW_WIDTH * 0.01, WINDOW_HEIGHT * 0.01, self.player.experience)
end



function Game:keypressed(key)
    if self.player:isDead() then return end

    if key == "q" then
        self.player:switchWeapon()
    end

    if key == "space" then
        self.player:startDash()
    end
end

function Game:mousepressed(x, y, button)
    if self.player:isDead() then return end

    if button == 1 then
        self.player:shootTowards(self.bullets)
    end
end

function Game:spawnEnemies(n)
    if not DESATIVA_INIMIGOS then
        local radius = 400
        for i = 1, n do
            local angle = math.random() * 2 * math.pi
            local x = self.player.x + math.cos(angle) * radius
            local y = self.player.y + math.sin(angle) * radius

                local enemy = Enemy:new(x, y)
                enemy:setTarget(self.player)
                table.insert(self.enemies, enemy)
                self.timeSinceLastEnemySpawn = 0
        end
    end
end

return setmetatable({}, Game)
