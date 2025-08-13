local Dash = {}
Dash.__index = Dash

function Dash:new()
    local dash = {
        distance = 100,
        duration = 0.2,
        timeSinceLastDash = 0,
        cooldown = 3,
        dashing = false,
        dashTimer = 0,
        dashDirection = { x = 0, y = 0 }
    }
    return setmetatable(dash, Dash)
end

function Dash:update(dt, entity)
    self.timeSinceLastDash = self.timeSinceLastDash + dt

    if self.dashing then
        local dashSpeed = self.distance / self.duration
        entity.x = entity.x + self.dashDirection.x * dashSpeed * dt
        entity.y = entity.y + self.dashDirection.y * dashSpeed * dt

        self.dashTimer = self.dashTimer - dt
        if self.dashTimer <= 0 then
            self.dashing = false
        end
    end
end

function Dash:canDash()
    return not self.dashing and self.timeSinceLastDash >= self.cooldown
end

function Dash:startDash(entity)
    if self:canDash() then
        self.dashing = true
        self.dashTimer = self.duration
        self.timeSinceLastDash = 0

        self.dashDirection.x = math.cos(entity.aimAngle)
        self.dashDirection.y = math.sin(entity.aimAngle)
    end
end

return Dash
