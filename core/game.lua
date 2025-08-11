local Player = require("entities.player")
local Enemy = require("entities.enemy")
local Collision = require("core.collision")
local HudExperience = require("hud.hudExperience")

local Game = {}
Game.__index = Game

function Game:load()
    self.player = Player:new(Love.graphics.getWidth() / 2, Love.graphics.getHeight() / 2)
    self.hudExperience = HudExperience
    self.enemies = {}
    self:spawnEnemies(20)
    self.bullets = {}
    self.lootTable = {}
    self.timeSinceLastEnemySpawn = 0
end

function Game:spawnEnemies(n)
    local radius = 200
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

function Game:update(dt)
    self.player:update(dt)
    if self.player:isDead() then
        Love.event.quit()
    end

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
    
    self.timeSinceLastEnemySpawn = self.timeSinceLastEnemySpawn + dt
    if self.timeSinceLastEnemySpawn >= 5 then
        self:spawnEnemies(10)
        self.timeSinceLastEnemySpawn = 0
    end
end

function Game:draw()
    self.player:draw()
    self.hudExperience.draw(10, 10, self.player.experience)

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

end



function Game:keypressed(key)
    if key == "escape" then
        Love.event.quit()
    end

    if key == "q" then
        self.player:switchWeapon()
    end
end

function Game:mousepressed(x, y, button)
    if button == 1 then
        self.player:shootTowards(self.bullets)
    end
end


return setmetatable({}, Game)
