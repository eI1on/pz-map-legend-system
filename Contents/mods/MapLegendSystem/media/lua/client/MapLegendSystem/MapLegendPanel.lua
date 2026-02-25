local MapLegendClient = require("MapLegendSystem/Client")
local Settings = require("MapLegendSystem/Settings")
local MapLegendShared = require("MapLegendSystem/Shared")
local MapLegendPanel = ISPanel:derive("MapLegendPanel")

local MapLegendEditor = ISPanel:derive("MapLegendEditor")

function MapLegendEditor:new(x, y, width, height)
    local o = ISPanel.new(self, x, y, width, height)
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.title = "Map Legend Editor"
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.7 }
    o.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 }
    o.padding = 10
    o.modifiedContent = false
    return o
end

function MapLegendEditor:initialise()
    ISPanel.initialise(self)

    local Utils = MapLegendShared.Utils
    local CONFIG = MapLegendShared.CONFIG

    local contentY = 30
    local buttonHeight = 25
    local contentHeight = self.height - contentY - self.padding - buttonHeight - 15

    self.textBox = ISTextEntryBox:new("", self.padding, contentY, self.width - (self.padding * 2), contentHeight)
    self.textBox:initialise();
    self.textBox:instantiate();
    self.textBox:setMultipleLine(true)
    self.textBox:setEditable(true)
    self:addChild(self.textBox)

    local buttonWidth = 80
    local buttonY = self.height - self.padding - buttonHeight
    local totalButtonWidth = (buttonWidth * 2) + 10
    local startX = (self.width - totalButtonWidth) / 2

    self.saveButton = ISButton:new(startX, buttonY, buttonWidth, buttonHeight, "Save", self,
        MapLegendEditor.onSaveClick)
    self:addChild(self.saveButton)

    self.cancelButton = ISButton:new(startX + buttonWidth + 10, buttonY, buttonWidth, buttonHeight, "Cancel", self,
        MapLegendEditor.onCancelClick)
    self:addChild(self.cancelButton)

    if MapLegendClient.isSinglePlayer then
        self:loadLocalContent()
    else
        self:requestServerContent()
    end
end

function MapLegendEditor:loadLocalContent()
    local Utils = MapLegendShared.Utils
    local CONFIG = MapLegendShared.CONFIG

    local fileContent = ""
    local file = Utils.safeReadFile(CONFIG.MAP_LEGEND_FILE)
    if file then
        local lines = {}
        local line = file:readLine()
        while line do
            table.insert(lines, line)
            line = file:readLine()
        end
        fileContent = table.concat(lines, "\r\n")
        file:close()
    end
    self.textBox:setText(fileContent)
end

function MapLegendEditor:requestServerContent()
    MapLegendClient.requestEditContent(function(content)
        self.textBox:setText(content)
    end)
end

function MapLegendEditor:onSaveClick()
    local content = self.textBox:getText()
    local Utils = MapLegendShared.Utils
    local CONFIG = MapLegendShared.CONFIG

    if MapLegendClient.isSinglePlayer then
        local file = Utils.safeWriteFile(CONFIG.MAP_LEGEND_FILE)
        if file then
            file:write(content)
            file:close()
            MapLegendClient.loadMessages()
            self:close()
        end
    else
        MapLegendClient.saveEditContent(content)
        self:close()
    end
end

function MapLegendEditor:onCancelClick()
    self:close()
end

function MapLegendEditor:update()
    ISPanel.update(self)
end

function MapLegendEditor:render()
    ISPanel.render(self)
end

function MapLegendPanel:new(x, y, width, height)
    local o = ISPanel.new(self, x, y, width, height)
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    o.originalHeight = height
    o.originalWidth = width
    o.baseWidth = 300
    o.baseHeight = 350
    o.sizeScale = 1.0
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.7 }
    o.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 }
    o.padding = 5
    o.isCollapsed = false
    o.currentPosition = "topLeft"
    return o
end

function MapLegendPanel:initialise()
    ISPanel.initialise(self)

    self.collapseButton = ISButton:new(self.padding, self.padding, 20, 20, "", self, MapLegendPanel
        .onCollapseButtonClick)
    self.collapseButton.anchorRight = false
    self.collapseButton.anchorLeft = true
    self.collapseButton.anchorTop = true
    self.collapseButton.backgroundColor.a = 0;
    self.collapseButton:setImage(getTexture("media/ui/Panel_Icon_Collapse_Side.png"));
    self:addChild(self.collapseButton)

    -- if (isClient() and isAdmin()) then
    if isDebugEnabled() or (isClient() and isAdmin()) then
        self.editorButton = ISButton:new(self.width - self.padding - 40, self.padding, 20, 20, "", self,
            MapLegendPanel.onEditorButtonClick)
        self.editorButton.anchorRight = false
        self.editorButton.anchorLeft = true
        self.editorButton.anchorTop = true
        self.editorButton.backgroundColor = { r = 1, g = 0, b = 0, a = 0.5 };
        self.editorButton:setImage(getTexture("media/ui/Panel_Icon_Legend_Editor.png"));
        self:addChild(self.editorButton)
    end

    self.settingsButton = ISButton:new(self.width - self.padding - 20, self.padding, 20, 20, "", self,
        MapLegendPanel.onSettingsButtonClick)
    self.settingsButton.anchorRight = false
    self.settingsButton.anchorLeft = true
    self.settingsButton.anchorTop = true
    self.settingsButton.backgroundColor.a = 0;
    self.settingsButton:setImage(getTexture("media/ui/Panel_Icon_Gear.png"));
    self:addChild(self.settingsButton)

    local contentY = 20 + (self.padding * 2)
    local contentHeight = self.height - contentY - self.padding

    self.richTextPanel = ISRichTextPanel:new(self.padding, contentY, self.width - (self.padding * 2), contentHeight)
    self.richTextPanel:initialise()
    self.richTextPanel:setAnchorTop(true)
    self.richTextPanel:setAnchorRight(true)
    self.richTextPanel:setAnchorLeft(true)
    self.richTextPanel:setAnchorBottom(true)
    self.richTextPanel.autosetheight = false
    self.richTextPanel:addScrollBars()
    self.richTextPanel.vscroll:setVisible(true)
    self.richTextPanel.vscroll.backgroundColor.a = 0.25
    self.richTextPanel:ignoreHeightChange()
    self.richTextPanel.defaultFont = UIFont.Medium
    self.richTextPanel.text = ""
    self.richTextPanel.clip = true
    self.richTextPanel.marginTop = 10
    self.richTextPanel.marginBottom = 10
    self.richTextPanel.marginLeft = 5
    self.richTextPanel.marginRight = 15
    self.richTextPanel.drawMargins = true
    self.richTextPanel.backgroundColor.a = 0;
    self:addChild(self.richTextPanel)
end

function MapLegendPanel:createChildren()
    ISPanel.createChildren(self)
end

function MapLegendPanel:updateContent(messages)
    if messages and #messages > 0 then
        self.richTextPanel.text = table.concat(messages, "\r\n")
        self.richTextPanel:paginate()
    end
end

function MapLegendPanel:onCollapseButtonClick()
    if self.isCollapsed then
        self.isCollapsed = false
        self:setWidth(self.originalWidth)
        self:setHeight(self.originalHeight)
        self.collapseButton:setImage(getTexture("media/ui/Panel_Icon_Collapse_Side.png"))
        if self.editorButton then
            self.editorButton:setX(self.width - 2 * self.padding - 40)
            self.editorButton:setVisible(true)
        end
        self.settingsButton:setX(self.width - self.padding - 20)
        self.settingsButton:setVisible(true)
        self.richTextPanel:setVisible(true)

        if self.currentPosition == "bottomLeft" then
            local screenHeight = getCore():getScreenHeight()
            self:setY(screenHeight - self:getHeight() - 20)
        end
        Settings.update("collapsed", false)
    else
        self.isCollapsed = true
        local collapsedWidth = (self.editorButton and 3 or 2) * 20 + (self.padding * (self.editorButton and 4 or 3))
        local collapsedHeight = 20 + (self.padding * 2)
        self:setWidth(collapsedWidth)
        self:setHeight(collapsedHeight)
        self.collapseButton:setImage(getTexture("media/ui/Panel_Icon_Expand_Side.png"))
        if self.editorButton then
            self.editorButton:setX((self.padding * 2) + 20)
            self.editorButton:setVisible(true)
        end
        self.settingsButton:setX((self.padding * (self.editorButton and 3 or 2)) + (self.editorButton and 40 or 20))
        self.settingsButton:setVisible(true)

        self.richTextPanel:setVisible(false)

        if self.currentPosition == "bottomLeft" then
            local screenHeight = getCore():getScreenHeight()
            self:setY(screenHeight - collapsedHeight - 20)
        end
        Settings.update("collapsed", true)
    end
end

function MapLegendPanel:setSizeScale(scale)
    scale = math.max(0.5, math.min(2.0, scale))
    self.sizeScale = scale

    local newWidth = math.floor(self.baseWidth * scale)
    local newHeight = math.floor(self.baseHeight * scale)

    self.originalWidth = newWidth
    self.originalHeight = newHeight

    if not self.isCollapsed then
        self:setWidth(newWidth)
        self:setHeight(newHeight)
        if self.editorButton then
            self.editorButton:setX(self.width - 2 * self.padding - 40)
        end
        self.settingsButton:setX(self.width - self.padding - 20)
        self.richTextPanel:paginate()

        if self.currentPosition == "bottomLeft" then
            local screenHeight = getCore():getScreenHeight()
            local newY = screenHeight - newHeight - 20
            if newY < 0 then newY = 0 end
            self:setY(newY)
        end
    end

    Settings.update("sizeScale", scale)
end

function MapLegendPanel:onSettingsButtonClick()
    local context = ISContextMenu.get(0, self:getAbsoluteX() + self:getWidth(),
        self:getAbsoluteY() + self.settingsButton:getY())

    local opacityOption = context:addOption("Opacity", self)
    local opacitySubMenu = context:getNew(context)
    context:addSubMenu(opacityOption, opacitySubMenu)

    local opacityLevels = { 0.10, 0.15, 0.25, 0.35, 0.50, 0.65, 0.75, 0.85, 1.0 }
    for i = 1, #opacityLevels do
        local opacity = opacityLevels[i]
        local option = opacitySubMenu:addOption((opacity * 100) .. "%", self, function(obj)
            obj.backgroundColor.a = opacity
            Settings.update("opacity", opacity)
        end)
        if math.abs(self.backgroundColor.a - opacity) < 0.01 then
            opacitySubMenu:setOptionChecked(option, true)
        end
    end

    local sizeOption = context:addOption("Size", self)
    local sizeSubMenu = context:getNew(context)
    context:addSubMenu(sizeOption, sizeSubMenu)

    local sizeScales = { 0.5, 0.65, 0.75, 0.85, 1, 1.10, 1.25, 1.5, 1.75, 2 }
    for i = 1, #sizeScales do
        local scale = sizeScales[i]
        local option = sizeSubMenu:addOption(math.floor(scale * 100) .. "%", self, function(obj)
            obj:setSizeScale(scale)
        end)
        if math.abs(self.sizeScale - scale) < 0.01 then
            sizeSubMenu:setOptionChecked(option, true)
        end
    end

    local positionOption = context:addOption("Position", self)
    local positionSubMenu = context:getNew(context)
    context:addSubMenu(positionOption, positionSubMenu)

    local topLeftOption = positionSubMenu:addOption("Top Left", self, function(obj)
        obj:setX(20)
        obj:setY(20)
        obj.currentPosition = "topLeft"
        Settings.updateMultiple({
            positionX = 20,
            positionY = 20,
            position = "topLeft"
        })
    end)

    local bottomLeftOption = positionSubMenu:addOption("Bottom Left", self, function(obj)
        obj:setX(20)
        local screenHeight = getCore():getScreenHeight()
        local newY = screenHeight - obj:getHeight() - 20
        obj:setY(newY)
        obj.currentPosition = "bottomLeft"
        Settings.updateMultiple({
            positionX = 20,
            positionY = newY,
            position = "bottomLeft"
        })
    end)

    if self.currentPosition == "topLeft" then
        positionSubMenu:setOptionChecked(topLeftOption, true)
    elseif self.currentPosition == "bottomLeft" then
        positionSubMenu:setOptionChecked(bottomLeftOption, true)
    end
end

function MapLegendPanel:onEditorButtonClick()
    local editorWidth = 800
    local editorHeight = 500
    local screenWidth = getCore():getScreenWidth()
    local screenHeight = getCore():getScreenHeight()
    local editorX = (screenWidth - editorWidth) / 2
    local editorY = (screenHeight - editorHeight) / 2

    local editor = MapLegendEditor:new(editorX, editorY, editorWidth, editorHeight)
    editor:initialise()
    editor:addToUIManager()
    editor:setAlwaysOnTop(true)
end

function MapLegendPanel:update()
    ISPanel.update(self)
end

function MapLegendPanel:render()
    ISPanel.render(self)
end

local old_ISWorldMap_createChildren = ISWorldMap.createChildren
function ISWorldMap:createChildren()
    old_ISWorldMap_createChildren(self)

    local settings = Settings.getAll()
    local baseWidth = 300
    local baseHeight = 350
    local panelX = settings.positionX or 20
    local panelY = settings.positionY or 20
    local positionType = settings.position or "topLeft"

    self.mapLegendPanel = MapLegendPanel:new(panelX, panelY, baseWidth, baseHeight)
    self.mapLegendPanel:initialise()
    self.mapLegendPanel:setAnchorRight(false)
    self.mapLegendPanel:setAnchorLeft(true)
    self:addChild(self.mapLegendPanel)

    self.mapLegendPanel.backgroundColor.a = settings.opacity
    self.mapLegendPanel.currentPosition = positionType

    self.mapLegendPanel:setSizeScale(settings.sizeScale)

    if settings.collapsed then
        self.mapLegendPanel:onCollapseButtonClick()
    end

    MapLegendClient.addCallback(function(messages)
        self.mapLegendPanel:updateContent(messages)
    end)
end

return MapLegendPanel
