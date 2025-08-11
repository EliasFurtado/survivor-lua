---@diagnostic disable: duplicate-set-field
local BaseWeapon = require("core.baseWeapon")
local Bullet = require("entities.bullet")
local Shotgun = setmetatable({}, {__index = BaseWeapon})
Shotgun.__index = Shotgun

function Shotgun:new()
    local weapon = BaseWeapon:new({
        damage = 30,
        cooldown = 0.6,
        knockback = 5
    })
    setmetatable(weapon, Shotgun)
    return weapon
end

function Shotgun:shoot(x, y, angle, bullets)
    if self:canShoot() then
        self.timeSinceLastShot = self.cooldown
        local spread = math.rad(30) 
        local count = 5              
        local range = 100            
        local step = spread / (count - 1)
        local startAngle = angle - spread / 2
    
        for i = 0, count - 1 do
            local bulletAngle = startAngle + i * step
            local bullet = Bullet:new(x, y, bulletAngle, range)
            table.insert(bullets, bullet)
        end    
    end
end

return Shotgun
