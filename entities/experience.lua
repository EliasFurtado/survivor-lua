Experience = {}
Experience.__index = Experience

function Experience:new(x, y, amount)
    local obj = setmetatable({}, self)
    obj.x = x
    obj.y = y
    obj.alive = true
    obj.amount = amount
    obj.radius = 4
    return obj
end

function Experience:update(dt, player)
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist < 20 then
        self.x = self.x + dx * dt * 50
        self.y = self.y + dy * dt * 50
    end

    if dist < 5 then
        self.alive = false
        return self.amount
    end

    return 0
end

    
function Experience:draw()
    Love.graphics.setColor(0, 0, 1)
    Love.graphics.circle("fill", self.x, self.y, self.radius)
end
    

return Experience