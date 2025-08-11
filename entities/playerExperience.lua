PlayerExperience = {}
PlayerExperience.__index = PlayerExperience

function PlayerExperience:new(onLevelUp)
    local obj = setmetatable({}, self)
    obj.current = 0
    obj.nextLevel = 100
    obj.level = 1
    obj.onLevelUp = onLevelUp or function() end
    return obj
end

function PlayerExperience:add(amount)
    self.current = self.current + amount
    if self.current >= self.nextLevel then
        self.current = self.current - self.nextLevel
        self.nextLevel = self.nextLevel * 2
        self.level = self.level + 1
        self.onLevelUp()
    end
end

function PlayerExperience:getLevel()
    return self.level
end

function PlayerExperience:getProgress()
    return self.current / self.nextLevel
end

function PlayerExperience:getCurrent()
    return self.current
end

function PlayerExperience:getNextLevel()
    return self.nextLevel
end

return PlayerExperience
