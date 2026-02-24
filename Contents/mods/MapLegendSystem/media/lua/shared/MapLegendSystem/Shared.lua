local MapLegendShared = {}

MapLegendShared.CONFIG = {
    MAP_LEGEND_FILE = "MapLegendSystem/MapLegendSystem.txt",
    UPDATE_CHECK_INTERVAL = 10000,
    MODULE_NAME = "MapLegendSystem"
}

MapLegendShared.COMMANDS = {
    REQUEST_MESSAGES = "requestMessages",
    RECEIVE_MESSAGES = "receiveMessages",
    UPDATE_AVAILABLE = "updateAvailable"
}

MapLegendShared.Utils = {}

MapLegendShared.Utils.safeReadFile = function(filePath)
    local success, file = pcall(getFileReader, filePath, false)
    if success and file then
        return file
    end
    return nil
end

MapLegendShared.Utils.safeWriteFile = function(filePath)
    local success, file = pcall(getFileWriter, filePath, true, false)
    if success and file then
        return file
    end
    return nil
end

MapLegendShared.Utils.createDefaultFile = function(filePath)
    local file = MapLegendShared.Utils.safeWriteFile(filePath)
    if not file then return false end

    file:write("VERSION = 1.0\r\n")

    file:write("<H1><CENTRE> Map Legend TEST <TEXT> <BR>\r\n")
    file:write("<IMAGE:media/textures/Foraging/pinIconAnimals.png,30,45> <SPACE> <GREEN> Active Marker <SPACE> <RGB:1,1,1> Custom location set by admins or events. <LINE>\r\n")
    file:write("<IMAGE:media/textures/Foraging/pinIconUnknown.png,30,45> <SPACE> <ORANGE> Unexplored / Mystery <SPACE> <RGB:1,1,1> Location contains unknown or hidden information. <LINE>\r\n")
    file:write("<INDENT:24><RGB:0.8,0.8,0.8>Visit the area to uncover details or trigger events. <INDENT:0> <BR>\r\n")
    file:write("<IMAGE:media/textures/Foraging/pinIconStones.png,30,45> <SPACE> <RED> Airdrop Zone <SPACE> <RGB:1,1,1> Supply crate has landed at this location. <LINE>\r\n")
    file:write("<INDENT:24> <RGB:0.8,0.8,0.8> High player activity expected. Approach with caution. <INDENT:0> <BR>\r\n")
    file:write("<H2> Event Areas <TEXT> <LINE>\r\n")
    file:write("<INDENT:16> <GREEN> Green Zones <SPACE> <RGB:1,1,1> Safe gathering or social areas. <LINE>\r\n")
    file:write("<INDENT:16> <RED> Red Zones <SPACE> <RGB:1,1,1> High-risk combat or PvP enabled areas. <LINE>\r\n")
    file:write("<INDENT:16> <ORANGE> Orange Zones <SPACE> <RGB:1,1,1> Temporary event objectives. <INDENT:0> <BR>\r\n")
    file:write("<H2> Territories <TEXT> <LINE>\r\n")
    file:write("<INDENT:16> <RGB:0.6,0.8,1> Blue Markers <SPACE> <RGB:1,1,1> Faction-controlled territory. <LINE>\r\n")
    file:write("<INDENT:16> <RGB:1,0.6,0.6> Pink Markers <SPACE> <RGB:1,1,1> Community or public projects. <INDENT:0> <BR>\r\n")
    file:write("<H2> Notes <TEXT> <LINE>\r\n")
    file:write("<INDENT:16> Markers may only appear at certain zoom levels. <LINE>\r\n")
    file:write("<INDENT:16> Check this panel during events for updated objectives.\r\n")

    file:close()
    return true
end

MapLegendShared.isSinglePlayer = function()
    return not isServer() and not isClient()
end

MapLegendShared.MapLegendClient = {}

return MapLegendShared
