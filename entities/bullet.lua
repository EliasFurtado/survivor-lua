-- entities/bullet.lua
local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y, angle, range)
    local obj = setmetatable({}, self)
    obj.x = x
    obj.y = y
    obj.angle = angle
    obj.range = range
    obj.radius = 4
    obj.speed = 400
    obj.inititalX = x
    obj.inititalY = y
    obj.alive = true
    obj.distanceTraveled = 0
    return obj
end

function Bullet:update(dt)
    if not self.alive then return end

    local dx = math.cos(self.angle) * self.speed * dt
    local dy = math.sin(self.angle) * self.speed * dt
    local dist = math.sqrt(dx * dx + dy * dy)

    self.x = self.x + dx
    self.y = self.y + dy
    self.distanceTraveled = self.distanceTraveled + dist

    if self.distanceTraveled >= self.range or 
        self.x < 0 or self.x > Love.graphics.getWidth() or
        self.y < 0 or self.y > Love.graphics.getHeight() then
        self.alive = false
    end
end

function Bullet:draw()
    Love.graphics.setColor(1, 1, 1)
    Love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Bullet
