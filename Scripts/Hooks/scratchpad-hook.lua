local function loadScratchpad()
    package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

    local lfs = require("lfs")
    local U = require("me_utilities")
    local Skin = require("Skin")
    local DialogLoader = require("DialogLoader")
    local Tools = require("tools")
    local Input = require("Input")
    local dxgui = require('dxgui')

    -- Scratchpad resources
    local window = nil
    local windowDefaultSkin = nil
    local windowSkinHidden = Skin.windowSkinChatMin()
    local panel = nil
    local textarea = nil
    local logFile = io.open(lfs.writedir() .. [[Logs\Scratchpad.log]], "w")
    local config = nil

    local panel = nil
    local textarea = nil
    local crosshairCheckbox = nil
    local insertCoordsBtn = nil
    local prevButton = nil
    local nextButton = nil

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

    function formatCoord(type, isLat, d)
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
        local m = math.floor(d * 60 - g * 60)
        local s = d * 3600 - g * 3600 - m * 60

        if type == "DMS" then -- Degree Minutes Seconds
            s = math.floor(s * 100) / 100
            return string.format('%s %2d°%.2d\'%2.2f"', h, g, m, s)
        elseif type == "DDM" then -- Degree Decimal Minutes
            s = math.floor(s / 60 * 1000)
            return string.format('%s %2d°%2d.%3.3d\'', h, g, m, s)
        else -- Decimal Degrees
            return string.format('%f',d)
        end
    end

    local function coordsType()
        local ac = DCS.getPlayerUnitType()
        if ac == "FA-18C_hornet" or ac == "A-10C_2" then
            return "DMS", true
        elseif ac == "F-16C_50" or ac == "M-2000C" then
            return "DDM", false
        else
            return nil, false
        end
    end

    local function insertCoordinates()
        local pos = Export.LoGetCameraPosition().p
        local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
        local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
        local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
        local type, includeMgrs = coordsType()

        local result = ""
        if type == nil or type == "DMS" then
            result = result .. formatCoord("DMS", true, lat) .. ", " .. formatCoord("DMS", false, lon) .. "\n"
        end
        if type == nil or type == "DDM" then
            result = result .. formatCoord("DDM", true, lat) .. ", " .. formatCoord("DDM", false, lon) .. "\n"
        end
        if type == nil or includeMgrs then
            result = result .. mgrs .. "\n"
        end
        result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft\n"

        local lineCountBefore = textarea:getLineCount()
        textarea:setText(textarea:getText() .. result .. "\n")

        -- scroll to the bottom of the textarea
        local lastLine = textarea:getLineCount() - 1
        local lastLineChar = textarea:getLineTextLength(lastLine)
        textarea:setSelectionNew(lastLine, 0, lastLine, lastLineLen)
        savePage(currentPage, textarea:getText(), true)
    end

    local function setVisible(b)
        window:setVisible(b)
    end

    local function handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 20 - 20)
        prevButton:setBounds(0, h - 40, 50, 20)
        nextButton:setBounds(55, h - 40, 50, 20)
        crosshairCheckbox:setBounds(120, h - 39, 20, 20)

        if pagesCount > 1 then
            insertCoordsBtn:setBounds(145, h - 40, 50, 20)
        else
            insertCoordsBtn:setBounds(0, h - 40, 50, 20)
        end

        config.windowSize = {w = w, h = h}
        saveConfiguration()
    end

    local function handleMove(self)
        local x, y = self:getPosition()
        config.windowPosition = {x = x, y = y}
        saveConfiguration()
    end

    local function updateCoordsMode()
        -- insert coords only works if the client is the server, so hide the button otherwise
        crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
        crosshairWindow:setVisible(inMission and crosshairCheckbox:getState())
        insertCoordsBtn:setVisible(inMission and crosshairCheckbox:getState())
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
        panel:setVisible(true)
        window:setHasCursor(true)

        -- show prev/next buttons only if we have more than one page
        if pagesCount > 1 then
            prevButton:setVisible(true)
            nextButton:setVisible(true)
        else
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end

        updateCoordsMode()

        isHidden = false
    end

    local function hide()
        window:setSkin(windowSkinHidden)
        panel:setVisible(false)
        textarea:setFocused(false)
        window:setHasCursor(false)
        -- window.setVisible(false) -- if you make the window invisible, its destroyed
        unlockKeyboardInput(true)

        crosshairWindow:setVisible(false)

        isHidden = true
    end

    local function createCrosshairWindow()
        if crosshairWindow ~= nil then
            return
        end

        crosshairWindow = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\Scratchpad\\CrosshairWindow.dlg",
            cdata
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
            lfs.writedir() .. "Scripts\\Scratchpad\\ScratchpadWindow.dlg",
            cdata
        )

        windowDefaultSkin = window:getSkin()
        panel = window.Box
        textarea = panel.ScratchpadEditBox
        crosshairCheckbox = panel.ScratchpadCrosshairCheckBox
        insertCoordsBtn = panel.ScratchpadInsertCoordsButton
        prevButton = panel.ScratchpadPrevButton
        nextButton = panel.ScratchpadNextButton

        -- setup textarea
        local skin = textarea:getSkin()
        skin.skinData.states.released[1].text.fontSize = config.fontSize
        textarea:setSkin(skin)

        textarea:addChangeCallback(
            function(self)
                savePage(currentPage, self:getText(), true)
            end
        )
        textarea:addFocusCallback(
            function(self)
                if self:getFocused() then
                    lockKeyboardInput()
                else
                    unlockKeyboardInput(true)
                end
            end
        )
        textarea:addKeyDownCallback(
            function(self, keyName, unicode)
                if keyName == "escape" then
                    self:setFocused(false)
                    unlockKeyboardInput(true)
                end
            end
        )

        -- setup button and checkbox callbacks
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
        window:addSizeCallback(handleResize)
        window:addPositionCallback(handleMove)

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
