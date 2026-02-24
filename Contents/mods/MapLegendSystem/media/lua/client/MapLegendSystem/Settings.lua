local Settings = {}

Settings.DEFAULTS = {
    opacity = 0.8,
    positionX = 20,
    positionY = 20,
    position = "topLeft",
    sizeScale = 1.0
}

Settings.MOD_DATA_KEY = "MapLegendSettings"

function Settings.load()
    local settings = ModData.getOrCreate(Settings.MOD_DATA_KEY)

    settings.opacity = settings.opacity or Settings.DEFAULTS.opacity
    settings.positionX = settings.positionX or Settings.DEFAULTS.positionX
    settings.positionY = settings.positionY or Settings.DEFAULTS.positionY
    settings.position = settings.position or Settings.DEFAULTS.position
    settings.sizeScale = settings.sizeScale or Settings.DEFAULTS.sizeScale

    return settings
end

function Settings.save(newSettings)
    local settings = ModData.getOrCreate(Settings.MOD_DATA_KEY)
    settings = newSettings
end

function Settings.update(key, value)
    local settings = Settings.load()
    settings[key] = value
    Settings.save(settings)
    return settings
end

function Settings.updateMultiple(updates)
    local settings = Settings.load()
    for key, value in pairs(updates) do
        settings[key] = value
    end
    Settings.save(settings)
    return settings
end

function Settings.get(key, default)
    local settings = Settings.load()
    local value = settings[key]
    if value == nil then
        return default or Settings.DEFAULTS[key]
    end
    return value
end

function Settings.getAll()
    return Settings.load()
end

--[[
local Settings = require("MapLegendSystem/Settings")
Settings.reset()
--]]
function Settings.reset()
    local settings = ModData.getOrCreate(Settings.MOD_DATA_KEY)
    settings = {
        opacity = Settings.DEFAULTS.opacity,
        positionX = Settings.DEFAULTS.positionX,
        positionY = Settings.DEFAULTS.positionY,
        position = Settings.DEFAULTS.position,
        sizeScale = Settings.DEFAULTS.sizeScale
    }
    Settings.save(settings)
    return Settings.getAll()
end

return Settings
