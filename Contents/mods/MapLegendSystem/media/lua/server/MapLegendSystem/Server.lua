local MapLegendShared = require("MapLegendSystem/Shared")

local MapLegendServer = {}
local CONFIG = MapLegendShared.CONFIG
local COMMANDS = MapLegendShared.COMMANDS
local Utils = MapLegendShared.Utils

MapLegendServer.version = "VERSION = 1.0"
MapLegendServer.messages = {}
MapLegendServer.lastCheckTime = 0

MapLegendServer.loadMessages = function()
    local file = Utils.safeReadFile(CONFIG.MAP_LEGEND_FILE)
    if file then
        MapLegendServer.version = file:readLine()
        MapLegendServer.messages = {}

        local line = file:readLine()
        while line do
            if line:trim() ~= "" then
                table.insert(MapLegendServer.messages, line)
            end
            line = file:readLine()
        end

        file:close()
    else
        if Utils.createDefaultFile(CONFIG.MAP_LEGEND_FILE) then
            MapLegendServer.loadMessages()
        end
    end
end

MapLegendServer.checkForUpdates = function()
    local currentTime = getTimeInMillis()
    if currentTime - MapLegendServer.lastCheckTime > CONFIG.UPDATE_CHECK_INTERVAL then
        MapLegendServer.lastCheckTime = currentTime

        local file = Utils.safeReadFile(CONFIG.MAP_LEGEND_FILE)
        if file then
            local version = file:readLine()
            file:close()

            if version ~= MapLegendServer.version then
                MapLegendServer.loadMessages()
                MapLegendServer.notifyClientsOfUpdate()
            end
        end
    end
end

MapLegendServer.notifyClientsOfUpdate = function()
    sendServerCommand(CONFIG.MODULE_NAME, COMMANDS.UPDATE_AVAILABLE, {})
end

MapLegendServer.sendMessagesToClient = function(player)
    local data = {
        version = MapLegendServer.version,
        messages = MapLegendServer.messages
    }

    sendServerCommand(player, CONFIG.MODULE_NAME, COMMANDS.RECEIVE_MESSAGES, data)
end

MapLegendServer.onClientCommand = function(module, command, player, args)
    if module ~= CONFIG.MODULE_NAME then return end

    if command == COMMANDS.REQUEST_MESSAGES then
        MapLegendServer.sendMessagesToClient(player)
    end
end

MapLegendServer.init = function()
    MapLegendServer.loadMessages()

    Events.EveryTenMinutes.Add(MapLegendServer.checkForUpdates)

    Events.OnClientCommand.Add(MapLegendServer.onClientCommand)
end

if isServer() then
    Events.OnServerStarted.Add(MapLegendServer.init)
end

MapLegendShared.MapLegendServer = MapLegendServer
return MapLegendServer
