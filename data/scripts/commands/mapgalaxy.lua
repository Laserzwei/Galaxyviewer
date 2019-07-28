function execute(sender, commandName, pIndex, ...)
    local player = Player(sender)
    player.craft:addScriptOnce("data/scripts/entity/galaxymapper.lua")

    return 0, "", ""
end

function getDescription()
    return "Maps Galaxy"
end

function getHelp()
    return "You already typed \"/mapgalaxy\" nothing else needs to be done!"
end
