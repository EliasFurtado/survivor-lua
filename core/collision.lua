local Collision = {}

function Collision.checkAABB(a, b)
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end

function Collision.checkCollisionCircle(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < (a.radius + b.radius)
end


return Collision
