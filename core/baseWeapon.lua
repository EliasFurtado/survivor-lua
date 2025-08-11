local BaseWeapon = {}
BaseWeapon.__index = BaseWeapon

function BaseWeapon:new(params)
    params = params or {}
    local weapon = {
        damage = params.damage or 10,
        cooldown = params.cooldown or 0.5,
        knockback = params.knockback or 0,
        timeSinceLastShot = 0
    }
    setmetatable(weapon, self)
    return weapon
end

function BaseWeapon:update(dt)
    if self.timeSinceLastShot and self.timeSinceLastShot > 0 then
        self.timeSinceLastShot = self.timeSinceLastShot - dt
    end
end

function BaseWeapon:canShoot()
    return self.timeSinceLastShot <= 0
end

function BaseWeapon:shoot()
    if self:canShoot() then
        self.timeSinceLastShot = self.cooldown
    end
end

function BaseWeapon:draw(x, y, width)
    Love.graphics.setColor(0, 0, 0)
    Love.graphics.rectangle("fill", x, y, width, 5)
    Love.graphics.setColor(1, 1, 1)
    Love.graphics.rectangle("fill", x, y, width * ((self.timeSinceLastShot / self.cooldown) or 0), 5)
end

return BaseWeapon
