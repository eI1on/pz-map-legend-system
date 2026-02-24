local MapLegendShared = require("MapLegendSystem/Shared")

local MapLegendClient = {}
local CONFIG = MapLegendShared.CONFIG
local COMMANDS = MapLegendShared.COMMANDS
local Utils = MapLegendShared.Utils

MapLegendClient.messages = {}
MapLegendClient.version = nil
MapLegendClient.lastCheckTime = 0
MapLegendClient.callbacks = {}
MapLegendClient.initialized = false
MapLegendClient.isSinglePlayer = MapLegendShared.isSinglePlayer()

MapLegendClient.loadMessages = function()
    local file = Utils.safeReadFile(CONFIG.MAP_LEGEND_FILE)
    if file then
        local version = file:readLine()
        local messages = {}

        if version ~= MapLegendClient.version then
            MapLegendClient.version = version

            local line = file:readLine()
            while line do
                if line:trim() ~= "" then
                    table.insert(messages, line)
                end
                line = file:readLine()
            end
            MapLegendClient.messages = messages
            MapLegendClient.notifyCallbacks()
        end

        file:close()
    else
        if Utils.createDefaultFile(CONFIG.MAP_LEGEND_FILE) then
            MapLegendClient.loadMessages()
        end
    end
end

MapLegendClient.checkForUpdates = function()
    if not MapLegendClient.isSinglePlayer then return end

    local currentTime = getTimeInMillis()
    if currentTime - MapLegendClient.lastCheckTime > CONFIG.UPDATE_CHECK_INTERVAL then
        MapLegendClient.lastCheckTime = currentTime
        MapLegendClient.loadMessages()
    end
end

MapLegendClient.requestMessages = function()
    if MapLegendClient.isSinglePlayer then return end

    local player = getSpecificPlayer(0)
    if player then
        sendClientCommand(player, CONFIG.MODULE_NAME, COMMANDS.REQUEST_MESSAGES, {})
    end
end

MapLegendClient.onServerCommand = function(module, command, args)
    if module ~= CONFIG.MODULE_NAME then return end

    if command == COMMANDS.RECEIVE_MESSAGES then
        if args and args.messages then
            MapLegendClient.messages = args.messages
            MapLegendClient.version = args.version
            MapLegendClient.notifyCallbacks()
        end
    elseif command == COMMANDS.UPDATE_AVAILABLE then
        MapLegendClient.requestMessages()
    end
end

MapLegendClient.addCallback = function(callback)
    table.insert(MapLegendClient.callbacks, callback)
    if #MapLegendClient.messages > 0 then
        callback(MapLegendClient.messages)
    end
end

MapLegendClient.notifyCallbacks = function()
    for _, callback in ipairs(MapLegendClient.callbacks) do
        callback(MapLegendClient.messages)
    end
end

MapLegendClient.init = function()
    if MapLegendClient.initialized then return end
    MapLegendClient.initialized = true

    if MapLegendClient.isSinglePlayer then
        MapLegendClient.loadMessages()
        Events.EveryOneMinute.Add(MapLegendClient.checkForUpdates)
    else
        Events.OnServerCommand.Add(MapLegendClient.onServerCommand)
        MapLegendClient.requestMessages()
    end
end

local doCommand = false;
local function sendCommand()
    if doCommand then
        MapLegendClient.init();
        Events.OnTick.Remove(sendCommand);
    end
    doCommand = true;
end
Events.OnTick.Add(sendCommand);

MapLegendShared.MapLegendClient = MapLegendClient
return MapLegendClient
