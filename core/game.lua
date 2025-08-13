local Player = require("entities.player")
local Enemy = require("entities.enemy")
local Collision = require("core.collision")
local HudExperience = require("hud.hudExperience")
local Boss = require("entities.boss")


HAS_BOSS = false

local Game = {}
Game.__index = Game

function Game:load()
    self.player = Player:new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.hudExperience = HudExperience
    self.enemies = {}
    self.boss = {}
    self:spawnEnemies(20)
    self.bullets = {}
    self.lootTable = {}
    self.timeSinceLastEnemySpawn = 0
    self.timeForBoss = 0

    SomMusic = Love.audio.newSource("utils/audio/game-music.ogg", "static")
    SomDeath = Love.audio.newSource("utils/audio/game-death.ogg", "static")
    SomMusicBoss = Love.audio.newSource("utils/audio/boss-music.ogg", "static")
end

function Game:spawnEnemies(n)
    if not DESATIVA_INIMIGOS or not HAS_BOSS then
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
end

function Game:update(dt)
    self.player:update(dt)
    SomMusic:play()
    if self.player:isDead() then
        SLOW_RATE = 0.5
        if not SomDeath:isPlaying() and not SomTerminou then
            SomTerminou = true
            TELA_ATUAL = "menu"
            PAUSADO = false
            SLOW_RATE = 0
            SLOW_FACTOR = 1
        end
    end

    self.timeForBoss = self.timeForBoss + dt

    if self.timeForBoss >= 3 and HAS_BOSS then
        SomMusic:stop()
        SomMusicBoss:play()
    end
    
    if not DESATIVA_INIMIGOS then
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            local run = false
            if HAS_BOSS then
                run = true
                if self.timeForBoss >= 2 then
                    enemy:update(dt, run)
                end
            else
                enemy:update(dt, run)
            end
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

    if self.timeForBoss >= 10 and not HAS_BOSS then
        self.timeForBoss = 0
        -- Spawn a boss enemy
        HAS_BOSS = true
        local boss = Boss:new(WINDOW_WIDTH * 0.5, 60)
        boss:setTarget(self.player)
        table.insert(self.boss, boss)
    end
    
    if self.timeSinceLastEnemySpawn >= 5 and not HAS_BOSS then
        self:spawnEnemies(10)
        self.timeSinceLastEnemySpawn = 0
    end
        
    for i = #self.boss, 1, -1 do
            local boss = self.boss[i]
            boss:update(dt)

            if Collision.checkAABB(self.player, boss) then
                self.player:takeDamage(5000)
            end
            if boss:isDead() then
                boss:dropExperience(self.lootTable)
                table.remove(self.enemies, i)
            end
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

    for ei = #self.boss, 1, -1 do
        local boss = self.boss[ei]
        if boss.timeToSpawn <= boss.spawnTime then
            boss.timeToSpawn = boss.timeToSpawn + 1
        else
            boss:draw()
        end
    end

end



function Game:keypressed(key)
    if self.player:isDead() then return end

    if key == "q" then
        self.player:switchWeapon()
    end
end

function Game:mousepressed(x, y, button)
    if self.player:isDead() then return end

    if button == 1 then
        self.player:shootTowards(self.bullets)
    end
end


return setmetatable({}, Game)
