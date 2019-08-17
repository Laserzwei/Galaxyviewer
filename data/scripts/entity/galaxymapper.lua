package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include ("utility")
include ("callable")
local SCANGATES = true
local seed
if onServer() then seed = Server().seed end

local SectorSpecifics = require ("sectorspecifics")
local specs = SectorSpecifics()
local GatesMap = require ("gatesmap")
local gateMap

local t, t2 = Timer(), Timer()
local gMin, gMax = -499, 500
local currentX, currentY = gMin, gMax

local list
-- [sectorY] = {{x = x, type = state, factionIndex = factionIndex}, ...}
-- "sectorY|,x;type;factionIndex,x;..."
local factionList
-- [factionIndex] = factioName
-- ",factionIndex:factioName,factionIndex:factionName,..."
local gateList
-- [index] = {from:{x,y}, to:{{a,b}, ...} }
-- ",x:y-a:b-a:b-...,x:y-a:b-..."

--client only
local sectorString = ""
local dataToProcess = false

function initialize()
    if onServer() then
        gateMap = GatesMap(seed)
        list, factionList, gateList = {}, {}, {}
        print("started")
        t2:start()

    end
end

local updateCount = 0
function updateServer(timestep)
    if currentY < gMin -1 then return end
    if currentY == gMin -1 then
        currentY = currentY - 1
        dataGenerated()
        return
    end
    updateCount = updateCount + 1
    t:reset()
    t:start()
    if not list[currentY] then list[currentY] = {} end
    while t.milliseconds < 48 and currentY >= gMin do   -- don't calculate for more than 50ms
        for offset= 0, 19 do
            setSectorInfo(currentX, currentY, offset)
        end

        currentX = currentX + 20
        if currentX > gMax then
            currentY = currentY - 1
            currentX = gMin
            list[currentY] = {}
        end
    end
    if updateCount % 20 == 0 then print("At Sector Y: ", currentY) end  -- give notification of current progress every second
    t:stop()
end

function setSectorInfo(x, y, offset)
    x = x + offset
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
        local factionIndex = faction.index
        table.insert(list[y], {x = x, type = state, factionIndex = factionIndex})
        if not factionList[factionIndex] then factionList[factionIndex] = faction.name end
        if SCANGATES == true then
            local gatesTo = gateMap:getConnectedSectors({x = x, y = y})
            if next(gatesTo) then
                table.insert(gateList, {from = {x=x, y=y}, to = gatesTo})
            end
        end
    end
end

function dataGenerated()
    t2:stop()
    print("Data generated:", t2.milliseconds.."ms")

    broadcastInvokeClientFunction("receiveData", Server().seed:__tostring(), list, factionList, gateList)
end

function receiveData(seed, data, pFactionList, pGateList)
    t2:start()
    list = data
    factionList = pFactionList
    gateList = pGateList
    dataToProcess = true
    sectorString = ""
    --statics
    sectorString = sectorString..seed .. "\n".. concatenateFactions() .. "\n" .. concatenateGates()
    print("received", t2.milliseconds.."ms")
    print("gates", concatenateGates())

end

function updateClient(timestep)
    if dataToProcess == false or currentY < gMin -1 then return end
    if currentY == gMin -1 then
        currentY = currentY - 1
        dataToProcess = false

        save(sectorString)
        t2:stop()
        print("save", t2.milliseconds.."ms")
        return
    end
    updateCount = updateCount + 1
    t:reset()
    t:start()

    while t.milliseconds < 50 and currentY >= gMin do   -- don't calculate for more than 50ms
        concatenateRow()
        if currentY % 100 == 0 then
            --print("Concatenated:", currentY)
        end
        currentY = currentY - 1
    end
    if updateCount % 20 == 0 then print("Concatenate at Sector Y: ", currentY) end  -- give notification of current progress every second
    t:stop()
end

function term()
    terminate()
end
callable(nil, "term")

function concatenateRow()
    local rowString = "\n"..currentY.."|"
    for _,s in ipairs(list[currentY]) do
        rowString = rowString..","..s.x..";"..s.type..";"..s.factionIndex
    end
    sectorString = sectorString..rowString
end

function concatenateFactions()
    local str = ""
    for index, name in pairs(factionList) do
        str = str .. "," .. index .. ":" .. name
    end
    return str
end

function concatenateGates()
    local str = ""
    for _,gates in pairs(gateList) do
        local from = gates.from
        local fromstr = ""
        for _, to in pairs(gates.to) do
            fromstr = fromstr .. ";" .. to.x .. ":" .. to.y
        end
        str = str .. "," .. from.x .. ":" .. from.y .. fromstr
    end

    return str
end

function save(data_In)
    t:reset()
    t:start()
    local file,err = io.open( "moddata/galaxymapper/galaxymap.txt", "wb" )
    if err then
        print("A", err)
        displayChatMessage("Could not save galaxymap.txt: \n"..err, "Galaxymapper", 0)
        return false
    end
    file:write(data_In)
    file:close()
    t:stop()
    displayChatMessage("saved successful to ../Appdata/Roaming/Avorion/moddata/galaxymapper/galaxymap.txt in "..t.milliseconds.."ms", "Galaxymapper", 0)
    invokeServerFunction("term")
    return true
end
