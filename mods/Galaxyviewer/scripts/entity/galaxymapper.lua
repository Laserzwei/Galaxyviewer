package.path = package.path .. ";data/scripts/?.lua"

local SectorSpecifics = require ("sectorspecifics")
local specs = SectorSpecifics()

local currentY, currentX
if onServer() then  seed = Server().seed end
local t = HighResolutionTimer()

local list = {}
function initialize()
    if onServer() then
        currentX, currentY = -499, 500
    end
end

function updateServer(timestep)
    if currentY >= -499 then
        t:start()
        generatePreviewLine(currentY)
        t:stop()
        print("At y="..currentY, "time: ", t.milliseconds.."ms")
        t:restart()
        currentY = currentY - 1
    end
    if currentY == -500 then
        currentY = currentY - 1
        broadcastInvokeClientFunction("save", list, seed:__tostring())
    end
end

function generatePreviewLine(y)
    if y > 500 then print("y to high") return end
    if y < -499 then print("y too low") return end

    list[y] = {}

    for x=-499, 500 do
        local state = 0 -- nothing
        local regular, offgrid, blocked, home = specs:determineContent(x, y, seed)
        if blocked then
            state = 1   --space rift
        elseif home then
            state = 2   -- home sector (also regular)
        elseif regular then
            if offgrid then
                state = 3   -- dunno, never seen
            else
                state = 4   -- green blib, not faction home
            end
        elseif offgrid then
            if regular == false then
                state = 5   -- orange blip
            else
                state = 6 -- should not happen
            end
        end
        if state ~= 0 then
            local faction = Galaxy():getLocalFaction(x, y) or Galaxy():getNearestFaction(x, y)
            table.insert(list[y], {x = x, type = state, factionIndex = faction.index})
        end
    end
end

function generatePreviewBox(top, bottom)
    if top.x > bottom.x then print("top x too high") return end
    if top.y < bottom.y then print("top y too high") return end


    str = ""

    for i=1000-top.y, 1000-bottom.y do
        str = str.."\n"
        for j=top.x, bottom.x do
            local state = 0 -- nothing
            local regular, offgrid, blocked, home = specs:determineContent(j, (i-1000)*-1, Server().seed)
            if blocked then
                state = 1   --space rift
            elseif home then
                state = 2   -- home sector (also regular)
            elseif regular then
                if offgrid then
                    state = 3   -- dunno
                else
                    state = 4   -- green blib, not faction home
                end
            elseif offgrid then
                if regular == false then
                    state = 5   -- orange blip
                else
                    state = 6 -- should not happen
                end
            end
            if state ~= 0 then
                str = str.." ("..j..":"..((i-1000)*-1)..")"..state
            end
        end
    end
    print(str)
end

function save(list, seed)
    t:start()
    print("saving")

    local str = ""..seed
    for y=500, -499, -1 do
        str = str.."\n"..y.."|"
        for _,s in ipairs(list[y]) do
            str = str..","..s.x..";"..s.type..";"..s.factionIndex
        end
    end
    print("needed:", t.milliseconds, "ms to concatenate strings")

    local file,err = io.open( "galaxymap.txt", "wb" )
    if err then print(err) return err end
    file:write(str)
    file:close()
    t:stop()
    displayChatMessage("saved successful to ../Appdata/Roaming/Avorion/galaxymap.txt in "..t.milliseconds.."ms", "Galaxymapper", 0)
    return true
end
