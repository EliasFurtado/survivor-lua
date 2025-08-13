Enemy = {}
local Health = require("core.health")
local Experience = require("entities.experience")

Enemy.__index = Enemy

function Enemy:new(x, y)
    local obj = {}
    setmetatable(obj, Enemy)
    obj.x = x
    obj.y = y
    obj.width = 10
    obj.height = 10
    obj.radius = 12
    obj.speed = 30
    obj.target = nil

    obj.health = Health:new(100)

    return obj
end

function Enemy:update(dt, run)
    -- If we have a target (the player), move towards it
    local run = run or false
    local speedBoost = 1

    if self.target then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y

        -- Se run for true, inverte a direção (fugir do player)
        if run then
            dx = -dx
            dy = -dy
            speedBoost = 10
        end

        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- Normalize direction vector
        if distance > 0 then
            dx = dx / distance
            dy = dy / distance
        end
        
        -- Move towards the target
        self.x = self.x + dx * (self.speed * speedBoost) * dt
        self.y = self.y + dy * (self.speed * speedBoost) * dt
    end
end

function Enemy:setTarget(target)
    self.target = target
end

function Enemy:draw()
    Love.graphics.setColor(1, 0, 0)  -- Red color for enemy
    Love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    Love.graphics.setColor(1, 1, 1)  -- Reset color
    if HAS_BOSS then
        Love.graphics.print("!", (self.x + self.width / 2) - 2, self.y + self.height / 2 - 25)
    else  
        self.health:draw(self.x + self.width / 2 - 20, self.y + self.height / 2 - 25, 40)
    end
end

function Enemy:takeDamage(amount)
    self.health:take(amount)
end

function Enemy:heal(amount)
    self.health:heal(amount)
end

function Enemy:isDead()
    return self.health:isDead()
end

function Enemy:knockback(angle, distance)
    local dx = math.cos(angle) * distance
    local dy = math.sin(angle) * distance
    self.x = self.x + dx
    self.y = self.y + dy
end

function Enemy:dropExperience(lootTable)
    local experience = Experience:new(self.x, self.y, 10)
    table.insert(lootTable, experience)
end


return Enemy