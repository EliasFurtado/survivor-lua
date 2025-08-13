local Health = require("core.health")
local Pistol = require("entities.weapons.pistol")
local Shotgun = require("entities.weapons.shotgun")
local PlayerExperience = require("entities.playerExperience")
local Animation = require("core.animation")
local Dash = require("core.dash")

Player = {}
Player.__index = Player

function Player:new(x, y)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 64
    self.flip = false
    self.speed = 100
    self.radius = 12
    self.health = Health:new(100)

    self.animation = Animation:new( --animaçao  walking
        "assets/dummy_player.png", -- caminho da imagem
        32,                  -- largura do frame
        46,                  -- altura do frame (exemplo)
        4,                   -- número de frames
        0.1                  -- tempo por frame
    )

    self.aimX = x
    self.aimY = y
    self.aimAngle = 0

    self.weapons = {
        Pistol:new(),
        Shotgun:new()
    }
    self.currentWeaponIndex = 1
    self.weapon = self.weapons[self.currentWeaponIndex]

    self.dash = Dash:new()

    self.experience = PlayerExperience:new(function()
        self:improveWeapon()
    end)

    return self
end

function Player:update(dt)
    local moveX, moveY = 0, 0
    if love.keyboard.isDown("w") or Love.keyboard.isDown("up") then moveY = -1 self.animation:update(dt) end
    if love.keyboard.isDown("s") or Love.keyboard.isDown("down") then moveY = 1 self.animation:update(dt) end
    if love.keyboard.isDown("a") or Love.keyboard.isDown("left") then moveX = -1 self.animation:update(dt) end
    if love.keyboard.isDown("d") or Love.keyboard.isDown("right") then moveX = 1 self.animation:update(dt) end

    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then
        self.x = self.x + (moveX / len) * self.speed * dt
        self.y = self.y + (moveY / len) * self.speed * dt
    end

    local mx, my = love.mouse.getPosition()
    local dx = mx - self.x
    local dy = my - self.y
    local angle = math.atan2(dy, dx)

    self.aimX = self.x + self.width/2 + math.cos(angle)
    self.aimY = self.y + self.height/2 + math.sin(angle)

    if dx >= 0 then
        self.flip = false
    else
        self.flip = true
    end

   -- print("Player flip?", self.flip)
   -- print("mouse angle:", angle)
   

    self.aimAngle = angle

    self.weapon:update(dt)
    self.dash:update(dt, self)
end

function Player:draw()
    self.animation:draw(self, true, self.flip)

    self.health:draw(self.x + self.width / 2 - 20, self.y + self.height / 2 + 45, 40)
    self.weapon:draw(self.x + self.width / 2 - 20, self.y + self.height / 2 + 40, 40)
end

function Player:takeDamage(amount)
    self.health:take(amount)

    if self.health:isDead() then
        SomMusic:stop()
        SomMusicBoss:stop()
        SomDeath:play()
    end
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

function Player:startDash()
    self.dash:startDash(self)
end

return Player