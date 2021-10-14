function scratchpad_load()
    package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

    local lfs = require("lfs")
    local U = require("me_utilities")
    local Skin = require("Skin")
    local DialogLoader = require("DialogLoader")
    local Tools = require("tools")
    local Input = require("Input")

    local isHidden = true
    local keyboardLocked = false
    local window = nil
    local windowDefaultSkin = nil
    local windowSkinHidden = Skin.windowSkinChatMin()
    local panel = nil
    local textarea = nil

    local getCoordsLua =
        [[
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

            local marks = world.getMarkPanels()
            local result = ""
            for _, mark in pairs(marks) do
                local lat, lon = coord.LOtoLL({
                    x = mark.pos.x,
                    y = 0,
                    z = mark.pos.z
                })
                local alt = land.getHeight({
                    x = mark.pos.x,
                    y = mark.pos.z
                })
                result = result .. "\n"
                result = result .. formatCoord("DMS", true, lat) .. ", " .. formatCoord("DMS", false, lon) .. "\n"
                result = result .. formatCoord("DDM", true, lat) .. ", " .. formatCoord("DDM", false, lon) .. "\n"
                result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft, " .. mark.text .. "\n"
            end
            return result
        ]]

    local scratchpad = {
        logFile = io.open(lfs.writedir() .. [[Logs\Scratchpad.log]], "w")
    }

    local dirPath = lfs.writedir() .. [[Scratchpad\]]
    local currentPage = nil
    local pagesCount = 0
    local pages = {}

    local function loadPage(page)
        scratchpad.log("loading page " .. page.path)
        file, err = io.open(page.path, "r")
        if err then
            scratchpad.log("Error reading file: " .. page.path)
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
        scratchpad.log("saving page " .. path)
        lfs.mkdir(lfs.writedir() .. [[Scratchpad\]])
        local mode = "a"
        if override then
            mode = "w"
        end
        file, err = io.open(path, mode)
        if err then
            scratchpad.log("Error writing file: " .. path)
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

    function scratchpad.loadConfiguration()
        scratchpad.log("Loading config file...")
        local tbl = Tools.safeDoFile(lfs.writedir() .. "Config/ScratchpadConfig.lua", false)
        if (tbl and tbl.config) then
            scratchpad.log("Configuration exists...")
            scratchpad.config = tbl.config

            -- config migration

            -- add default fontSize config
            if scratchpad.config.fontSize == nil then
                scratchpad.config.fontSize = 14
                scratchpad.saveConfiguration()
            end

            -- move content into text file
            if scratchpad.config.content ~= nil then
                savePage(dirPath .. [[0000.txt]], scratchpad.config.content, false)
                scratchpad.config.content = nil
                scratchpad.saveConfiguration()
            end
        else
            scratchpad.log("Configuration not found, creating defaults...")
            scratchpad.config = {
                hotkey = "Ctrl+Shift+x",
                windowPosition = {x = 200, y = 200},
                windowSize = {w = 350, h = 150},
                fontSize = 14
            }
            scratchpad.saveConfiguration()
        end

        -- scan scratchpad dir for pages
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            scratchpad.log(path)
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".txt" then
                    scratchpad.log("Ignoring file " .. name .. ", because of it doesn't seem to be a text file (.txt)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    scratchpad.log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    scratchpad.log("found page " .. path)
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
            scratchpad.log("creating page " .. path)
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

    function scratchpad.saveConfiguration()
        U.saveInFile(scratchpad.config, "config", lfs.writedir() .. "Config/ScratchpadConfig.lua")
    end

    function scratchpad.log(str)
        if not str then
            return
        end

        if scratchpad.logFile then
            scratchpad.logFile:write("[" .. os.date("%H:%M:%S") .. "] " .. str .. "\r\n")
            scratchpad.logFile:flush()
        end
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

    local function insertCoordinates()
        local coords = net.dostring_in("server", getCoordsLua)
        local lineCountBefore = textarea:getLineCount()

        if coords == "" then
            textarea:setText(textarea:getText() .. "\nNo marks found\n")
        else
            textarea:setText(textarea:getText() .. coords .. "\n")
        end

        -- scroll to the bottom of the textarea
        local lastLine = textarea:getLineCount() - 1
        local lastLineChar = textarea:getLineTextLength(lastLine)
        textarea:setSelectionNew(lastLine, 0, lastLine, lastLineLen)
        savePage(currentPage, textarea:getText(), true)
    end

    function scratchpad.createWindow()
        window = DialogLoader.spawnDialogFromFile(lfs.writedir() .. "Scripts\\Scratchpad\\ScratchpadWindow.dlg", cdata)
        windowDefaultSkin = window:getSkin()
        panel = window.Box
        textarea = panel.ScratchpadEditBox
        insertCoordsBtn = panel.ScratchpadInsertCoordsButton
        prevButton = panel.ScratchpadPrevButton
        nextButton = panel.ScratchpadNextButton

        -- setup textarea
        local skin = textarea:getSkin()
        skin.skinData.states.released[1].text.fontSize = scratchpad.config.fontSize
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

        -- setup button callbacks
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
        insertCoordsBtn:addMouseDownCallback(
            function(self)
                insertCoordinates()
            end
        )

        -- setup window
        window:setBounds(
            scratchpad.config.windowPosition.x,
            scratchpad.config.windowPosition.y,
            scratchpad.config.windowSize.w,
            scratchpad.config.windowSize.h
        )
        scratchpad.handleResize(window)

        window:addHotKeyCallback(
            scratchpad.config.hotkey,
            function()
                if isHidden == true then
                    scratchpad.show()
                else
                    scratchpad.hide()
                end
            end
        )
        window:addSizeCallback(scratchpad.handleResize)
        window:addPositionCallback(scratchpad.handleMove)

        window:setVisible(true)
        nextPage()

        scratchpad.hide()
        scratchpad.log("Scratchpad Window created")
    end

    function scratchpad.setVisible(b)
        window:setVisible(b)
    end

    function scratchpad.handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 20 - 20)
        prevButton:setBounds(0, h - 40, 50, 20)
        nextButton:setBounds(55, h - 40, 50, 20)

        if pagesCount > 1 then
            insertCoordsBtn:setBounds(120, h - 40, 50, 20)
        else
            insertCoordsBtn:setBounds(0, h - 40, 50, 20)
        end

        scratchpad.config.windowSize = {w = w, h = h}
        scratchpad.saveConfiguration()
    end

    function scratchpad.handleMove(self)
        local x, y = self:getPosition()
        scratchpad.config.windowPosition = {x = x, y = y}
        scratchpad.saveConfiguration()
    end

    function scratchpad.show()
        if window == nil then
            local status, err = pcall(scratchpad.createWindow)
            if not status then
                net.log("[Scratchpad] Error creating window: " .. tostring(err))
            end
        end

        window:setVisible(true)
        window:setSkin(windowDefaultSkin)
        panel:setVisible(true)
        window:setHasCursor(true)

        -- insert coords only works if the client is the server, so hide the button otherwise
        if DCS.isServer() then
            insertCoordsBtn:setVisible(true)
        else
            insertCoordsBtn:setVisible(false)
        end

        -- show prev/next buttons only if we have more than one page
        if pagesCount > 1 then
            prevButton:setVisible(true)
            nextButton:setVisible(true)
        else
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end

        isHidden = false
    end

    function scratchpad.hide()
        window:setSkin(windowSkinHidden)
        panel:setVisible(false)
        textarea:setFocused(false)
        window:setHasCursor(false)
        -- window.setVisible(false) -- if you make the window invisible, its destroyed
        unlockKeyboardInput(true)

        isHidden = true
    end

    function scratchpad.onSimulationFrame()
        if scratchpad.config == nil then
            scratchpad.loadConfiguration()
        end

        if not window then
            scratchpad.log("Creating Scratchpad window hidden...")
            scratchpad.createWindow()
        end
    end

    DCS.setUserCallbacks(scratchpad)

    net.log("[Scratchpad] Loaded ...")
end

local status, err = pcall(scratchpad_load)
if not status then
    net.log("[Scratchpad] Load Error: " .. tostring(err))
end
