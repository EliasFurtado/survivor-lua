---@diagnostic disable: duplicate-set-field
local BaseWeapon = require("core.baseWeapon")
local Bullet = require("entities.bullet")
local Pistol = setmetatable({}, {__index = BaseWeapon})
Pistol.__index = Pistol

function Pistol:new()
    local weapon = BaseWeapon:new({
        damage = 15,
        cooldown = 0.2
    })
    setmetatable(weapon, Pistol)
    return weapon
end

function Pistol:shoot(x, y, angle, bullets)
    if self:canShoot() then
        self.timeSinceLastShot = self.cooldown
        table.insert(bullets, Bullet:new(x, y, angle, 500))
    end
end

return Pistol
