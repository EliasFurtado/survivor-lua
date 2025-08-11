local Health = require("core.health")
local Pistol = require("entities.weapons.pistol")
local Shotgun = require("entities.weapons.shotgun")
local PlayerExperience = require("entities.playerExperience")

Player = {}
Player.__index = Player

function Player:new(x, y)
    self.x = x
    self.y = y
    self.width = 10
    self.height = 10
    self.speed = 100
    self.radius = 12
    self.health = Health:new(100)

    self.aimX = x
    self.aimY = y
    self.aimAngle = 0

    self.weapons = {
        Pistol:new(),
        Shotgun:new()
    }
    self.currentWeaponIndex = 1
    self.weapon = self.weapons[self.currentWeaponIndex]

    self.experience = PlayerExperience:new(function()
        self:improveWeapon()
    end)

    return self
end

function Player:update(dt)
    local moveX, moveY = 0, 0
    if Love.keyboard.isDown("w") or Love.keyboard.isDown("up") then moveY = -1 end
    if Love.keyboard.isDown("s") or Love.keyboard.isDown("down") then moveY = 1 end
    if Love.keyboard.isDown("a") or Love.keyboard.isDown("left") then moveX = -1 end
    if Love.keyboard.isDown("d") or Love.keyboard.isDown("right") then moveX = 1 end

    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then
        self.x = self.x + (moveX / len) * self.speed * dt
        self.y = self.y + (moveY / len) * self.speed * dt
    end

    local mx, my = Love.mouse.getPosition()
    local dx = mx - self.x
    local dy = my - self.y
    local angle = math.atan2(dy, dx)

    self.aimX = self.x + self.width/2 + math.cos(angle)
    self.aimY = self.y + self.height/2 + math.sin(angle)

    self.aimAngle = angle

    self.weapon:update(dt)
end

function Player:draw()
    Love.graphics.setColor(1, 1, 1)
    Love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    self.health:draw(self.x + self.width / 2 - 20, self.y + self.height / 2 - 25, 40)
    self.weapon:draw(self.x + self.width / 2 - 20, self.y + self.height / 2 - 20, 40)
end

function Player:takeDamage(amount)
    self.health:take(amount)
end

function Player:heal(amount)
    self.health:heal(amount)
end

function Player:isDead()
    return self.health:isDead()
end

function Player:shootTowards(bullets)
    self.weapon:shoot(self.x, self.y, self.aimAngle, bullets)
end

function Player:switchWeapon()
    self.currentWeaponIndex = self.currentWeaponIndex + 1

    if self.currentWeaponIndex > #self.weapons then
        self.currentWeaponIndex = 1
    end

    self.weapon = self.weapons[self.currentWeaponIndex]
end

function Player:improveWeapon()
    for wi = 1, #self.weapons do
        self.weapons[wi].damage = self.weapons[wi].damage + 50 * self.experience:getLevel()
    end
end

return Player