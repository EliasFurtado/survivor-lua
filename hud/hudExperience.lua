local HudExperience = {}

function HudExperience.draw(x, y, playerExperience)
    Love.graphics.setColor(1, 1, 1)
    Love.graphics.rectangle("line", x, y, 100, 10)
    
    Love.graphics.setColor(0, 1, 0)
    local fill = playerExperience:getProgress() * 100
    Love.graphics.rectangle("fill", x, y, fill, 10)

    Love.graphics.setColor(1, 1, 1)
    Love.graphics.print("XP: " .. playerExperience:getCurrent() .. "/" .. playerExperience:getNextLevel() ..
                        " Lv: " .. playerExperience:getLevel(), x, y + 12)
end

return HudExperience