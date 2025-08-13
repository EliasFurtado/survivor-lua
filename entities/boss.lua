Boss = {}
local Health = require("core.health")
local Experience = require("entities.experience")

Boss.__index = Boss

local Tempo_Tela = 0

function Boss:new(x, y)
    local obj = {}

    font = Love.graphics.newFont(28)
    setmetatable(obj, Boss)
    obj.x = x
    obj.y = y
    obj.width = 80
    obj.height = 80
    obj.radius = 12
    obj.speed = 100
    obj.target = nil

    obj.health = Health:new(500)

    obj.spawnTime = 10

    obj.timeToSpawn = 0

    return obj
end

function Boss:update(dt)
    -- If we have a target (the player), move towards it
    local speedBoost = 5

    if HAS_BOSS then
        Tempo_Tela = Tempo_Tela + dt
    end

    if self.target then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y

        local distance = math.sqrt(dx * dx + dy * dy)
        
        -- Normalize direction vector
        if distance > 0 then
            dx = dx / distance
            dy = dy / distance
        end
        
        -- Move towards the target
        if Tempo_Tela >= 7 then
            self.x = self.x + dx * (self.speed * speedBoost) * dt
            self.y = self.y + dy * (self.speed * speedBoost) * dt
        end
    end
end

function Boss:setTarget(target)
    self.target = target
end

function Boss:draw()
    if Tempo_Tela >= 3 then
        if Tempo_Tela >= 5 then
            Love.graphics.setColor(1, 0, 0)  -- Red color for Boss
            Love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        end

        Love.graphics.setColor(1, 1, 1)  -- Reset color

        Love.graphics.print(
            "Rodosvaldo: o grande pixel !", 
            font, 
            (WINDOW_WIDTH * 0.5) - (font:getWidth("Rodosvaldo: o grande pixel !") * 0.5), 
            10
        )

        self.health:draw(WINDOW_WIDTH * 0.25, 40, 400,20)
    end
end

function Boss:takeDamage(amount)
    self.health:take(amount)
end

function Boss:heal(amount)
    self.health:heal(amount)
end

function Boss:isDead()
    return self.health:isDead()
end

function Boss:knockback(angle, distance)
    local dx = math.cos(angle) * distance
    local dy = math.sin(angle) * distance
    self.x = self.x + dx
    self.y = self.y + dy
end

function Boss:dropExperience(lootTable)
    local experience = Experience:new(self.x, self.y, 10)
    table.insert(lootTable, experience)
end


return Boss