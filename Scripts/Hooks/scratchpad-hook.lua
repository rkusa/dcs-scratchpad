local function loadScratchpad()
    package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

    local Button = require('Button')
    local DialogLoader = require("DialogLoader")
    local dxgui = require('dxgui')
    local Input = require("Input")
    local lfs = require("lfs")
    local Panel = require('Panel')
    local Skin = require("Skin")
    local Terrain = require('terrain')
    local Tools = require("tools")
    local U = require("me_utilities")

    -- Scratchpad resources
    local window = nil
    local windowDefaultSkin = nil
    local windowSkinHidden = Skin.windowSkinChatMin()
    local logFile = io.open(lfs.writedir() .. [[Logs\Scratchpad.log]], "w")
    local config = nil

    local panels = {}
    local textarea = nil
    local crosshairCheckbox = nil
    local insertCoordsBtn = nil

    -- State
    local isHidden = true
    local keyboardLocked = false
    local inMission = false

    -- Pages State
    local currentPage = nil
    local pagesCount = 0
    local pages = {}

    -- Crosshair resources
    local crosshairWindow = nil

    -- Extensions
    local extensions = {}
    local coordListeners = {}

    local function log(str)
        if not str then
            return
        end

        if logFile then
            logFile:write("[" .. os.date("%H:%M:%S") .. "] " .. str .. "\r\n")
            logFile:flush()
        end
    end

    -- Type given to extensions to manipulate the Scratchpad's content

    local Text = {}
    function Text.new()
        local c = {}
        setmetatable(c, {__index = Text})
        return c
    end

    function Text:getText()
        return textarea:getText()
    end

    function Text:setText(text)
        textarea:setText(text)
        textarea:setSelectionNew(0, 0, 0, 0)
        textarea:setFocused(true)
    end

    local function strLen(str)
        local skip = 0
        local len = 0
        for i = 1, #str do
            if skip == 0 then
                local b = str:byte(i)
                len = len + 1
                if b < 128 then
                    -- one byte char
                elseif  b < 224 then
                    -- two byte char
                    skip = 1
                elseif  b < 240 then
                    -- two byte char
                    skip = 2
                elseif  b < 248 then
                    -- two byte char
                    skip = 3
                end
            else
                skip = skip - 1
            end
        end
        return len
    end

    -- Returns the start end end offsets of the current selection
    function getSelection()
        local text = textarea:getText()
        local lineStart, indexStart, lineEnd, indexEnd = textarea:getSelectionNew()

        -- Swap backwards selection to forward selection
        if lineEnd < lineStart or (lineEnd == lineStart and indexEnd < indexStart) then
            lineStart, indexStart, lineEnd, indexEnd = lineEnd, indexEnd, lineStart, indexStart
        end

        -- DCS has no API to get the cursor offset relative to the text start, so there is quite
        -- some extra work necessary to calculate that based on what DCS provides.
        local start = 0
        local startByte = 0
        for i = 0, lineStart - 1 do
            start = start + textarea:getLineTextLength(i) + 1
            startByte = string.find(text, "\n", startByte + 1, true)
        end

        local end_ = start
        local endByte = startByte

        start = start + indexStart
        for i = 1, indexStart do
            local b = text:byte(startByte + 1)
            if b < 128 then
                -- one byte char
                startByte = startByte + 1
            elseif  b < 224 then
                -- two byte char
                startByte = startByte + 2
            elseif  b < 240 then
                -- two byte char
                startByte = startByte + 3
            elseif  b < 248 then
                -- two byte char
                startByte = startByte + 4
            end
        end

        local remainder = 0
        if lineEnd > lineStart then
            for i = lineStart, lineEnd - 1 do
                end_ = end_ + textarea:getLineTextLength(i) + 1
                endByte = string.find(text, "\n", endByte + 1, true)
            end
            remainder = indexEnd
        else
            end_ = start
            endByte = startByte
            remainder = (indexEnd - indexStart)
        end


        end_ = end_ + remainder
        for i = 1, remainder do
            local b = text:byte(endByte + 1)
            if b < 128 then
                -- one byte char
                endByte = endByte + 1
            elseif  b < 224 then
                -- two byte char
                endByte = endByte + 2
            elseif  b < 240 then
                -- two byte char
                endByte = endByte + 3
            elseif  b < 248 then
                -- two byte char
                endByte = endByte + 4
            end
        end

        return start, end_, startByte, endByte
    end

    -- Set the cursor to the specified position and optional length (defaults to 0)
    function setSelection(pos, len)
        local text = textarea:getText()
        local lineStart = 0
        local indexStart = 0
        local nl = string.byte("\n")
        local textLen = strLen(text)
        local to = math.min(pos, textLen)
        local offset = 0
        for i = 1, to do
            local b = text:byte(i + offset)
            if b == nl then
                lineStart = lineStart + 1
                indexStart = 0
            else
                indexStart = indexStart + 1
                if b < 128 then
                    -- one byte char
                elseif  b < 224 then
                    -- two byte char
                    offset = offset + 1
                elseif  b < 240 then
                    -- two byte char
                    offset = offset + 2
                elseif  b < 248 then
                    -- two byte char
                    offset = offset + 3
                end
            end
        end

        -- determine end
        local lineEnd = lineStart
        local indexEnd = indexStart
        if len and len > 0 then
            local from = to
            local to = math.min(pos + len, textLen)
            for i = from + 1, to do
                local b = text:byte(i + offset)
                if b == nl then
                    lineEnd = lineEnd + 1
                    indexEnd = 0
                else
                    indexEnd = indexEnd + 1

                    -- very basic utf8 handling
                    if b < 128 then
                        -- one byte char
                    elseif  b < 224 then
                        -- two byte char
                        offset = offset + 1
                    elseif  b < 240 then
                        -- two byte char
                        offset = offset + 2
                    elseif  b < 248 then
                        -- two byte char
                        offset = offset + 3
                    end
                end
            end
        end

        textarea:setSelectionNew(lineStart, indexStart, lineEnd, indexEnd)
    end

    function Text:insert(newText)
        if type(newText) ~= "string" then
            return
        end

        local text = textarea:getText()
        local start, end_, startByte, endByte = getSelection()

        -- replace the selection with the text
        textarea:setText(
            string.sub(text, 1, startByte)..
            newText..
            string.sub(text, endByte + 1, #text)
        )

        -- place cursor after the inserted text
        setSelection(start + strLen(newText))
        textarea:setFocused(true)
    end

    function Text:insertBelow(newText)
        -- place cursor at the end of the current line (before the newline if there is any)
        local text = textarea:getText()
        local start, end_, startByte, endByte = getSelection()
        local newPos = end_
        local nl = string.byte("\n")
        local skip = 0
        for i = endByte + 1, #text do
            if skip == 0 then
                local b = text:byte(i)
                if b == nl then
                    break
                else
                    newPos = newPos + 1

                    -- very basic utf8 handling
                    if b < 128 then
                        -- one byte char
                    elseif  b < 224 then
                        -- two byte char
                        skip = 1
                    elseif  b < 240 then
                        -- two byte char
                        skip = 2
                    elseif  b < 248 then
                        -- two byte char
                        skip = 3
                    end
                end
            else
                skip = skip - 1
            end
        end

        setSelection(newPos)

        newText = "\n"..newText
        self:insert(newText)
    end

    function Text:insertTop(newText)
        if type(newText) ~= "string" then
            return
        end

        setSelection(0)
        self:insert(newText .. "\n\n")
    end

    function Text:insertBottom(newText)
        if type(newText) ~= "string" then
            return
        end

        local text = self:getText()
        setSelection(#text)
        if #newText > 0 then
            self:insert("\n\n" .. newText .. "\n")
        end
    end

    function Text:deleteBackward()
        local start, end_ = getSelection()

        -- if there is no selection, select the character just before the cursor; otherwise delete
        -- the selected text
        if start == end_ then
            setSelection(start - 1, 1)
        end

        self:insert("")
    end

    local function loadPage(page)
        log("loading page " .. page.path)
        file, err = io.open(page.path, "r")
        if err then
            log("Error reading file: " .. page.path)
            return ""
        else
            local content = file:read("*all")
            file:close()
            textarea:setText(content)

            -- update title
            window:setText(page.name)
        end
    end

    local function savePage(path, content, override)
        if path == nil then
            return
        end

        log("saving page " .. path)
        lfs.mkdir(lfs.writedir() .. [[Scratchpad\]])
        local mode = "a"
        if override then
            mode = "w"
        end
        file, err = io.open(path, mode)
        if err then
            log("Error writing file: " .. path)
        else
            file:write(content)
            file:flush()
            file:close()
        end
    end

    local function nextPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for _, page in pairs(pages) do
            if currentPage == nil or (lastPage ~= nil and lastPage.path == currentPage) then
                loadPage(page)
                currentPage = page.path
                return
            end
            lastPage = page
        end

        -- restart at the beginning
        loadPage(pages[1])
        currentPage = pages[1].path
    end

    local function prevPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for i, page in pairs(pages) do
            if currentPage == nil or (page.path == currentPage and i ~= 1) then
                loadPage(lastPage)
                currentPage = lastPage.path
                return
            end
            lastPage = page
        end

        -- restart at the end
        loadPage(pages[pagesCount])
        currentPage = pages[pagesCount].path
    end

    local function loadConfiguration()
        log("Loading config file...")

        local dirPath = lfs.writedir() .. [[Scratchpad\]]

        local tbl = Tools.safeDoFile(lfs.writedir() .. "Config/ScratchpadConfig.lua", false)
        if (tbl and tbl.config) then
            log("Configuration exists...")
            config = tbl.config

            -- config migration

            -- add default fontSize config
            if config.fontSize == nil then
                config.fontSize = 14
                saveConfiguration()
            end

            -- move content into text file
            if config.content ~= nil then
                savePage(dirPath .. [[0000.txt]], config.content, false)
                config.content = nil
                saveConfiguration()
            end
        else
            log("Configuration not found, creating defaults...")
            config = {
                hotkey = "Ctrl+Shift+x",
                windowPosition = {x = 200, y = 200},
                windowSize = {w = 350, h = 150},
                fontSize = 14
            }
            saveConfiguration()
        end
    end

    local function saveConfiguration()
        U.saveInFile(config, "config", lfs.writedir() .. "Config/ScratchpadConfig.lua")
    end


    local function loadPages()
        log("Loading pages ...")

        pages = {}
        local dirPath = lfs.writedir() .. [[Scratchpad\]]

        -- scan scratchpad dir for pages
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".txt" then
                    log("Ignoring file " .. name .. ", because of it doesn't seem to be a text file (.txt)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    log("found page " .. path)
                    table.insert(
                        pages,
                        {
                            name = name:sub(1, -5),
                            path = path
                        }
                    )
                    pagesCount = pagesCount + 1
                end
            end
        end

        -- there are no pages yet, create one
        if pagesCount == 0 then
            path = dirPath .. [[0000.txt]]
            log("creating page " .. path)
            table.insert(
                pages,
                {
                    name = "0000",
                    path = path
                }
            )
            pagesCount = pagesCount + 1
        end
    end

    local function unlockKeyboardInput()
        if keyboardLocked then
            DCS.unlockKeyboardInput(true)
            keyboardLocked = false
        end
    end

    local function lockKeyboardInput()
        if keyboardLocked then
            return
        end

        local keyboardEvents = Input.getDeviceKeys(Input.getKeyboardDeviceName())
        local inputActions = Input.getEnvTable().Actions

        -- do not lock chat related hotkeys to prevent a mix of chat and Scratchpad causing a deadlock
        -- in which the chat cannot be closed and thus most keyboard inputs don't work anymore
        -- (code copied from `mul_chat.lua`)
        local removeCommandEvents = function(commandEvents)
            for i, commandEvent in ipairs(commandEvents) do
                for j = #keyboardEvents, 1, -1 do
                    if keyboardEvents[j] == commandEvent then
                        table.remove(keyboardEvents, j)
                        break
                    end
                end
            end 
        end
        
        removeCommandEvents(Input.getUiLayerCommandKeyboardKeys(inputActions.iCommandChat))
        removeCommandEvents(Input.getUiLayerCommandKeyboardKeys(inputActions.iCommandAllChat))
        removeCommandEvents(Input.getUiLayerCommandKeyboardKeys(inputActions.iCommandFriendlyChat))
        removeCommandEvents(Input.getUiLayerCommandKeyboardKeys(inputActions.iCommandChatShowHide))

        DCS.lockKeyboardInput(keyboardEvents)
        keyboardLocked = true
    end

    function formatCoord(format, isLat, d, opts)
        local function showNegative(d, h)
            if h == "S" or h == "W" then
                d = -d
            end
            return d, ""
        end

        if type(opts) ~= "table" then
            opts = {}
        end

        local h
        if isLat then
            if d < 0 then
                h = 'S'
                d = -d
            else
                h = 'N'
            end
        else
            if d < 0 then
                h = 'W'
                d = -d
            else
                h = 'E'
            end
        end

        local g = math.floor(d)
        local m = d * 60 - g * 60

        local precision = 3
        if opts.precision ~= nil then
            precision = opts.precision
        end
        if opts.showNegative ~= nil then
            g, h = showNegative(g, h)
        end
        local degreesWidth = 2
        if opts.lonDegreesWidth ~= nil and not isLat then
            degreesWidth = opts.lonDegreesWidth
            if opts.showNegative ~= nil and g < 0 then
                degreesWidth = degreesWidth + 1
            end
        end

        if format == "DMS" then -- Degree Minutes Seconds
            m = math.floor(m)
            local s = d * 3600 - g * 3600 - m * 60
            s = math.floor(s * 100) / 100
            return string.format('%s %0'..degreesWidth..'d°%.2d\'%0'..(precision+2)..'.'..precision..'f', h, g, m, s)

        elseif format == "DDM" then -- Degree Decimal Minutes
            return string.format('%s %0'..degreesWidth..'d°%0'..(precision+3)..'.'..precision..'f\'', h, g, m)
        else -- Decimal Degrees
            return  string.format('%f', showNegative(d, h))
        end
    end

    local function coordsType()
        -- DDM options and their defaults:
        --   precision = 3: the count of minute decimal places
        --   lonDegreesWidth = 2: the min. width of the longitude degrees padded with zeroes

        local ac = DCS.getPlayerUnitType()
        if ac == "FA-18C_hornet" then
            return {DMS = true, DDM = {precision = 4}, MGRS = true}
        elseif string.sub(ac, 1, 5) == "A-10C" then
            return {DDM = true, MGRS = true}
        elseif ac == "AV8BNA" then
            return {DMS = {precision = 0, lonDegreesWidth = 3}, MGRS = true}
        elseif string.sub(ac, 1, 4) == "F-14" then
            return {DDM = {precision = 1}}
        elseif ac == "F-15ESE" or ac == 'CH-47Fbl1' then
            return {DDM = {precision = 3, lonDegreesWidth = 3}, MGRS = true}
        elseif ac == "M-2000C" then
            return {DDM = {precision = 1, lonDegreesWidth = 3}}
        elseif ac == "F-16C_50" then
            return {DDM = {lonDegreesWidth = 3}, MGRS = true}
        elseif ac == "AH-64D_BLK_II" then
            return {DDM = {precision = 2, lonDegreesWidth = 3}, MGRS = true}
        elseif string.sub(ac, 1, 5) == "Ka-50" then
            return {DDM = {precision = 1, lonDegreesWidth = 3, showNegative = true}}
        elseif string.sub(ac, 1, 5) == "SA342" then
            return {DDM = {precision = 1}}
        elseif ac == "Hercules" then
            return {DDM = {precision = 3, lonDegreesWidth = 3}}
        elseif ac == "OH58D" then
            return {DDM = {precision = 2, lonDegreesWidth = 3}, MGRS = true}
        else
            return {DMS = true, DDM = true, MGRS = true}
        end
    end

    local function insertCoordinates()
        local pos = Export.LoGetCameraPosition().p
        local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
        local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
        local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
        local types = coordsType()

        local result = "\n\n"
        if types.DMS then
            result = result .. formatCoord("DMS", true, lat, types.DMS) .. ", " .. formatCoord("DMS", false, lon, types.DMS) .. "\n"
        end
        if types.DDM then
            result = result .. formatCoord("DDM", true, lat, types.DDM) .. ", " .. formatCoord("DDM", false, lon, types.DDM) .. "\n"
        end
        if types.MGRS then
            result = result .. mgrs .. "\n"
        end
        result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft\n\n"

        local text = Text.new()
        text:insertBelow(result)

        for _, listener in pairs(coordListeners) do
            if type(listener) == "function" then
                listener(text, lat, lon, alt)
            end
        end
    end

    local function setVisible(b)
        window:setVisible(b)
    end

    local function handleResize(self)
        local newWidth, newHeight = self:getSize()

        -- prevent too small size that cannot be properly interacted with anymore
        if newWidth < 10 then
            newWidth = 50
        end

        local panelsHeight = 0
        for _, panel in pairs(panels) do
            local w, h = panel:getSize()
            panelsHeight = panelsHeight + h
            if newWidth < w then
                newWidth = w
            end
        end

        local minHeight = 10 + panelsHeight
        if newHeight < minHeight then
            newHeight = minHeight
        end

        local y = newHeight - panelsHeight - 20 -- window title height
        textarea:setSize(newWidth, y)

        for _, panel in pairs(panels) do
            local w, h = panel:getSize()
            panel:setPosition(0, y)
            y = y + h
        end

        self:setSize(newWidth, newHeight)
        config.windowSize = {w = newWidth, h = newHeight}
        saveConfiguration()
    end

    local function handleMove(self)
        local x, y = self:getPosition()
        local w, h = self:getSize()
        local screenWidth, screenHeigt = dxgui.GetScreenSize()

        -- prevent moving the Scratchpad out of the viewport
        if x < 0 then
            x = 0
        end
        if y < 0 then
            y = 0
        end
        if x + w > screenWidth then
            x = screenWidth - w
        end
        if y + h > screenHeigt then
            y = screenHeigt - h
        end

        self:setPosition(x, y)
        config.windowPosition = {x = x, y = y}
        saveConfiguration()
    end

    local function updateCoordsMode()
        -- insert coords only works if the client is the server, so hide the button otherwise
        crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
        crosshairWindow:setVisible(inMission and crosshairCheckbox:getState())
        insertCoordsBtn:setVisible(inMission and crosshairCheckbox:getState())
    end

    local function blur()
        textarea:setFocused(false)
        unlockKeyboardInput()
        savePage(currentPage, textarea:getText(), true)
    end

    local function show()
        if window == nil then
            local status, err = pcall(createScratchpadWindow)
            if not status then
                net.log("[Scratchpad] Error creating window: " .. tostring(err))
            end
        end

        window:setVisible(true)
        window:setSkin(windowDefaultSkin)
        textarea:setVisible(true)
        window:setHasCursor(true)
        for _, panel in pairs(panels) do
            panel:setVisible(true)
        end

        updateCoordsMode()

        isHidden = false
    end

    local function hide()
        -- Cannot simply hide the window, as this would destroy it
        -- window.setVisible(false)

        window:setSkin(windowSkinHidden)
        textarea:setVisible(false)
        window:setHasCursor(false)
        for _, panel in pairs(panels) do
            panel:setVisible(false)
        end

        blur()

        crosshairWindow:setVisible(false)

        isHidden = true
    end

    local function loadExtensions()
        log("Loading extensions ...")

        local function loadExtension(path)
            local f, err = loadfile(path)
            if not f then
                log("Error reading file `"..path.."`: "..err)
                return { }
            end

            -- prepare extension panel
            local children = {}
            table.insert(extensions, {children = children})

            -- create extension env
            local extEnv = {
                addButton = function(x, y, w, h, title, onClick)
                    table.insert(children, {
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        title = title,
                        onClick = onClick
                    })
                end,
                addCoordinateListener = function(listener)
                    table.insert(coordListeners, listener)
                end,
                formatCoord = formatCoord,
                log = log
            }
            setmetatable(extEnv, {__index = _G})
            setfenv(f, extEnv)

            local ok, res = pcall(f)
            if not ok then
                log("Error executing extension `"..path.."`: "..res)
                return
            end
        end

        -- scan `DCS\Scripts\Scratchpad\Extensions` dir for lua files
        local extensionsPath = lfs.writedir() .. [[Scripts\Scratchpad\Extensions\]]
        for name in lfs.dir(extensionsPath) do
            local path = extensionsPath .. name
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".lua" then
                    log("Ignoring file " .. name .. ", because of it doesn't seem to be an extension (.lua)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    log("found extension " .. path)
                    loadExtension(path)
                end
            end
        end

        log("Extensions loaded.")
    end

    local function createCrosshairWindow()
        if crosshairWindow ~= nil then
            return
        end

        crosshairWindow = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\Scratchpad\\CrosshairWindow.dlg"
        )

        local screenWidth, screenHeigt = dxgui.GetScreenSize()
        local x = screenWidth/2 - 4
        local y = screenHeigt/2 - 4
        crosshairWindow:setBounds(math.floor(x), math.floor(y), 8, 8)

        log("Crosshair window created")
    end

    local function createScratchpadWindow()
        if window ~= nil then
            return
        end

        createCrosshairWindow()

        window = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\Scratchpad\\ScratchpadWindow.dlg"
        )

        windowDefaultSkin = window:getSkin()
        textarea = window.ScratchpadEditBox
        table.insert(panels, window.Box)
        crosshairCheckbox = window.Box.ScratchpadCrosshairCheckBox
        insertCoordsBtn = window.Box.ScratchpadInsertCoordsButton
        local prevButton = window.Box.ScratchpadPrevButton
        local nextButton = window.Box.ScratchpadNextButton

        -- setup textarea
        local skin = textarea:getSkin()
        skin.skinData.states.released[1].text.fontSize = config.fontSize
        textarea:setSkin(skin)

        textarea:addFocusCallback(
            function(self)
                if self:getFocused() then
                    lockKeyboardInput()
                else
                    blur()
                end
            end
        )
        textarea:addKeyDownCallback(
            function(self, keyName, unicode)
                if keyName == "escape" then
                    blur()
                end
            end
        )

        -- setup button and checkbox callbacks
        crosshairCheckbox:addChangeCallback(
            function(self)
                local checked = self:getState()
                insertCoordsBtn:setVisible(checked)
                crosshairWindow:setVisible(checked)
            end
        )
        insertCoordsBtn:addMouseUpCallback(
            function(self)
                insertCoordinates()
            end
        )

        -- setup prev/next buttons
        if pagesCount > 1 then
            prevButton:addMouseUpCallback(
                function(self)
                    prevPage()
                end
            )
            nextButton:addMouseUpCallback(
                function(self)
                    nextPage()
                end
            )

            -- add previous page hotkey
            if config.hotkeyPrevPage then
                window:addHotKeyCallback(
                    config.hotkeyPrevPage,
                    function()
                        if isHidden == false then
                            prevPage()
                        end
                    end
                )
            end

            -- add next page hotkey
            if config.hotkeyNextPage then
                window:addHotKeyCallback(
                    config.hotkeyNextPage,
                    function()
                        if isHidden == false then
                            nextPage()
                        end
                    end
                )
            end
        else
            -- move insert coord checkbox and button to the left
            crosshairCheckbox:setPosition(0, 1)
            insertCoordsBtn:setPosition(25, 0)
            -- hide prev/next buttons
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end

        -- add extensions
        local buttonSkin = prevButton:getSkin()
        for _, container in pairs(extensions) do
            local panel = Panel.new()
            local panelWidth = 0
            local panelHeight = 0
            for _, child in pairs(container.children) do
                if child.x + child.w > panelWidth then
                    panelWidth = child.x + child.w
                end
                if child.y + child.h > panelHeight then
                    panelHeight = child.y + child.h
                end

                local button = Button.new(child.title)
                button:setBounds(child.x, child.y, child.w, child.h)
                button:setSkin(buttonSkin)
                -- Needs to be mouse up for the refocus of the textarea to work
                button:addMouseUpCallback(function(self)
                    child.onClick(Text.new())
                end)
                panel:insertWidget(button)
            end
            panel:setBounds(0, 0, panelWidth, panelHeight)
            window:insertWidget(panel)
            table.insert(panels, panel)
        end

        -- add open/close hotkey
        window:addHotKeyCallback(
            config.hotkey,
            function()
                if isHidden == true then
                    show()
                else
                    hide()
                end
            end
        )

        -- add insert coordinates hotkey
        if config.hotkeyInsertCoordinates then
            window:addHotKeyCallback(
                config.hotkeyInsertCoordinates,
                function()
                    if isHidden == false and inMission and crosshairCheckbox:getState() then
                        insertCoordinates()
                    end
                end
            )
        end

        -- add reload pages hotkey
        if config.hotkeyReloadPages then
            window:addHotKeyCallback(
                config.hotkeyReloadPages,
                function()
                    loadPages()
                    if currentPage ~= nil then
                        for _, page in pairs(pages) do
                            if page.path == currentPage then
                                loadPage(page)
                                return
                            end
                        end
                    end

                    -- file not found anymore restart at the beginning
                    currentPage = nil
                    nextPage()
                end
            )
        end

        window:addSizeCallback(handleResize)
        window:addPositionCallback(handleMove)

        -- remove the focus from the textare when clicking outside of the Scratchpad
        dxgui.AddMouseCallback("down", function(x, y)
            if not isHidden then
                local winX, winY, winW, winH = window:getBounds()
                if x < winX or x > (winX + winW) or y < winY or y > (winY + winH) then
                    blur()
                end
            end
        end)

        -- setup window
        window:setBounds(
            config.windowPosition.x,
            config.windowPosition.y,
            config.windowSize.w,
            config.windowSize.h
        )
        window:setVisible(true)
        handleResize(window)
        handleMove(window)
        nextPage()
        hide()

        log("Scratchpad window created")
    end

    local handler = {}
    function handler.onSimulationFrame()
        if config == nil then
            loadConfiguration()
            loadPages()
            loadExtensions()
        end

        if not window then
            log("Creating Scratchpad window hidden...")
            local ok, err = pcall(createScratchpadWindow)
            if not ok then
                net.log("[Scratchpad] Failed to create window: " .. tostring(err))
            end
        end
    end
    function handler.onMissionLoadEnd()
        inMission = true
        updateCoordsMode()
    end
    function handler.onSimulationStop()
        inMission = false
        crosshairCheckbox:setState(false)
        hide()
    end
    DCS.setUserCallbacks(handler)

    net.log("[Scratchpad] Loaded ...")
end

local status, err = pcall(loadScratchpad)
if not status then
    net.log("[Scratchpad] Load Error: " .. tostring(err))
end
