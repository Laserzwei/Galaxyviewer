--[[
local function new(seed)

    local obj = setmetatable({
                        factionRange = 100,
                        }, FactionsMap)

    obj:initialize(seed, -499, 500, 100)

    return obj
end
]]
