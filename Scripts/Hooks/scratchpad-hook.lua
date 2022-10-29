local function loadScratchpad()
    package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

    local DialogLoader = require("DialogLoader")
    local dxgui = require('dxgui')
    local Input = require("Input")
    local lfs = require("lfs")
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

    local panel = nil
    local textarea = nil
    local crosshairCheckbox = nil
    local insertCoordsBtn = nil

    -- State
    local isHidden = true
    local keyboardLocked = false
    local inMission = false

    -- Pages State
    local dirPath = lfs.writedir() .. [[Scratchpad\]]
    local currentPage = nil
    local pagesCount = 0
    local pages = {}

    -- Crosshair resources
    local crosshairWindow = nil

    local function log(str)
        if not str then
            return
        end

        if logFile then
            logFile:write("[" .. os.date("%H:%M:%S") .. "] " .. str .. "\r\n")
            logFile:flush()
        end
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

        -- scan scratchpad dir for pages
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            log(path)
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

    local function saveConfiguration()
        U.saveInFile(config, "config", lfs.writedir() .. "Config/ScratchpadConfig.lua")
    end

    local function unlockKeyboardInput(releaseKeyboardKeys)
        if keyboardLocked then
            DCS.unlockKeyboardInput(releaseKeyboardKeys)
            keyboardLocked = false
        end
    end

    local function lockKeyboardInput()
        if keyboardLocked then
            return
        end

        local keyboardEvents = Input.getDeviceKeys(Input.getKeyboardDeviceName())
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

        if format == "DMS" then -- Degree Minutes Seconds
            m = math.floor(m)
            local s = d * 3600 - g * 3600 - m * 60
            s = math.floor(s * 100) / 100
            return string.format('%s %2d°%.2d\'%05.2f"', h, g, m, s)
        elseif format == "DDM" then -- Degree Decimal Minutes
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
        elseif ac == "A-10C_2" or ac == "A-10C" or ac == "AV-8B" then
            return {DDM = true, MGRS = true}
        elseif ac == "F-14B" or ac == "F-14A-135-GR" then
            return {DMS = true}
        elseif ac == "M-2000C" then
            return {DDM = true}
        elseif ac == "F-16C_50" then
            return {DDM = {lonDegreesWidth = 3}, MGRS = true}
        elseif ac == "AH-64D_BLK_II" then
            return {DDM = {precision = 2, lonDegreesWidth = 3}, MGRS = true}
        elseif ac == "Ka-50" then
            return {DDM = {precision = 1, lonDegreesWidth = 3, showNegative = true}}
        elseif ac == "SA342M" or ac == "SA342L" or ac == "SA342Mistral" or ac == "SA342Minigun" then
            return {DDM = {precision = 1}}
        else
            return {NS430 = true, DMS = true, DDM = true, MGRS = true}
        end
    end

    local function insertCoordinates()
        local pos = Export.LoGetCameraPosition().p
        local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
        local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
        local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
        local type = coordsType()

        local result = "\n\n"
        if type.DMS then
            result = result .. formatCoord("DMS", true, lat, type.DMS) .. ", " .. formatCoord("DMS", false, lon, type.DMS) .. "\n"
        end
        if type.DDM then
            result = result .. formatCoord("DDM", true, lat, type.DDM) .. ", " .. formatCoord("DDM", false, lon, type.DDM) .. "\n"
        end
        if type.MGRS then
            result = result .. mgrs .. "\n"
        end
        if  type.NS430 then -- Degree Decimal formated to be used in NS430 navaid.dat file for flight planning purposes. Just edit the %PlaceHolderName
            result = result .. "FIX;" .. formatCoord("DD", true, lon, type.NS430) .. ";" .. formatCoord("DD", false, lat, type.NS430)  .. ";%PlaceHolderName\n"
        end
        result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft\n\n"

        local text = textarea:getText()
        local lineCountBefore = textarea:getLineCount()
        local _lineBegin, _indexBegin, lineEnd, _indexEnd = textarea:getSelectionNew()

        -- find offset into string after the line the cursor is in
        local offset = 0
        for i = 0, lineEnd do
            offset = string.find(text, "\n", offset + 1, true)
            if offset == nil then
                offset = string.len(text)
                break
            end
        end

        -- insert the coordinates after the line the cursor is in
        textarea:setText(string.sub(text, 1, offset - 1) .. result .. string.sub(text, offset + 1, string.len(text)))

        -- place cursor after inserted text
        local lineCountAdded = textarea:getLineCount() - lineCountBefore
        local line = lineEnd + lineCountAdded - 1
        textarea:setSelectionNew(line, 0, line, 0)
    end

    local function setVisible(b)
        window:setVisible(b)
    end

    local function handleResize(self)
        local w, h = self:getSize()

        -- prevent too small size that cannot be properly interacted with anymore
        if w < 10 then
            w = 50
        end
        if h < 10 then
            h = 30
        end

        local panelY = 20 + 20 -- panel height + window title bar height
        local windowTitleBarHeight = 20
        textarea:setBounds(0, 0, w, h - panelY)
        panel:setBounds(0, h - panelY, w, 20)

        self:setSize(w, h)
        config.windowSize = {w = w, h = h}
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
        unlockKeyboardInput(true)
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
        panel:setVisible(true)
        window:setHasCursor(true)

        updateCoordsMode()

        isHidden = false
    end

    local function hide()
        -- Cannot simply hide the window, as this would destroy it
        -- window.setVisible(false)

        window:setSkin(windowSkinHidden)
        textarea:setVisible(false)
        panel:setVisible(false)
        window:setHasCursor(false)
        blur()

        crosshairWindow:setVisible(false)

        isHidden = true
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
        panel = window.Box
        crosshairCheckbox = panel.ScratchpadCrosshairCheckBox
        insertCoordsBtn = panel.ScratchpadInsertCoordsButton
        local prevButton = panel.ScratchpadPrevButton
        local nextButton = panel.ScratchpadNextButton

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
        insertCoordsBtn:addMouseDownCallback(
            function(self)
                insertCoordinates()
            end
        )

        -- setup window
        window:setBounds(
            config.windowPosition.x,
            config.windowPosition.y,
            config.windowSize.w,
            config.windowSize.h
        )
        handleResize(window)
        handleMove(window)

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

        -- setup prev/next buttons
        if pagesCount > 1 then
            prevButton:addMouseDownCallback(
                function(self)
                    prevPage()
                end
            )
            nextButton:addMouseDownCallback(
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
            -- move inserts coord checkbox and button to the left
            crosshairCheckbox:setPosition(0, 1)
            insertCoordsBtn:setPosition(25, 0)
            -- hide prev/next buttons
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end

        window:setVisible(true)
        nextPage()

        hide()
        log("Scratchpad window created")
    end

    local handler = {}
    function handler.onSimulationFrame()
        if config == nil then
            loadConfiguration()
        end

        if not window then
            log("Creating Scratchpad window hidden...")
            createScratchpadWindow()
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
