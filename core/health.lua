
local Health = {}
Health.__index = Health

function Health:new(maxHp)
    local obj = setmetatable({}, self)
    obj.max = maxHp or 100
    obj.current = obj.max
    return obj
end

function Health:take(amount)
    self.current = math.max(0, self.current - amount)
end

function Health:heal(amount)
    self.current = math.min(self.max, self.current + amount)
end

function Health:isDead()
    return self.current <= 0
end

function Health:draw(x, y, width, height)
    width = width or 40
    height = height or 5

    local percent = self.current / self.max
    Love.graphics.setColor(1, 0, 0)
    Love.graphics.rectangle("fill", x, y, width, height)
    Love.graphics.setColor(0, 1, 0)
    Love.graphics.rectangle("fill", x, y, width * percent, height)
    Love.graphics.setColor(1, 1, 1)
end

return Health
