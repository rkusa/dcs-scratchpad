function scratchpad_load()

    package.path  = package.path..";.\\LuaSocket\\?.lua;"..'.\\Scripts\\?.lua;'.. '.\\Scripts\\UI\\?.lua;'
    package.cpath = package.cpath..";.\\LuaSocket\\?.dll;"

    local JSON = loadfile("Scripts\\JSON.lua")()
    local lfs               = require('lfs')
    local U                 = require('me_utilities')
    local Skin              = require('Skin')
    local DialogLoader      = require('DialogLoader')
    local Tools             = require('tools')
    local Input             = require('Input')

    local isHidden = true
    local keyboardLocked = false
    local window = nil
    local windowDefaultSkin = nil
    local windowSkinHidden = Skin.windowSkinChatMin()
    local panel = nil
    local textarea = nil

    local scratchpad = {
        logFile = io.open(lfs.writedir()..[[Logs\Scratchpad.log]], "w")
    }

    function scratchpad.loadConfiguration()
        scratchpad.log("Loading config file...")
        local tbl = Tools.safeDoFile(lfs.writedir() .. 'Config/ScratchpadConfig.lua', false)
        if (tbl and tbl.config) then
            scratchpad.log("Configuration exists...")
            scratchpad.config = tbl.config
        else
            scratchpad.log("Configuration not found, creating defaults...")
            scratchpad.config = { 
                hotkey = "Ctrl+Shift+x",
                windowPosition = { x = 200, y = 200 },
                windowSize = { w = 350, h = 150 },
                content = "Start writing here ...",
            }
            scratchpad.saveConfiguration()
        end  
    end

    function scratchpad.saveConfiguration()
        U.saveInFile(scratchpad.config, 'config', lfs.writedir() .. 'Config/ScratchpadConfig.lua')
    end

    function scratchpad.log(str)
        if not str then 
            return
        end

        if scratchpad.logFile then
            scratchpad.logFile:write("["..os.date("%H:%M:%S").."] "..str.."\r\n")
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

    function scratchpad.createWindow()
        window = DialogLoader.spawnDialogFromFile(lfs.writedir() .. 'Scripts\\Scratchpad\\ScratchpadWindow.dlg', cdata)
        windowDefaultSkin = window:getSkin()
        panel = window.Box
        textarea = panel.ScratchpadEditBox
        
        -- setup textarea
        textarea:setText(scratchpad.config.content)
        textarea:addChangeCallback(function(self)
            scratchpad.config.content = self:getText()
            scratchpad.saveConfiguration()
        end)
        textarea:addFocusCallback(function(self)
            if self:getFocused() then
                lockKeyboardInput()
            else
                unlockKeyboardInput(true)
            end
        end)
        textarea:addKeyDownCallback(function(self, keyName, unicode)
            if keyName == 'escape' then
                self:setFocused(false)
                unlockKeyboardInput(true)
            end
        end)
        
        -- setup window
        window:setBounds(
            scratchpad.config.windowPosition.x,
            scratchpad.config.windowPosition.y,
            scratchpad.config.windowSize.w,
            scratchpad.config.windowSize.h
        )
        scratchpad.handleResize(window)

        window:addHotKeyCallback(scratchpad.config.hotkey, function()
            if isHidden == true then
                scratchpad.show()
            else
                scratchpad.hide()
            end
        end)
        window:addSizeCallback(scratchpad.handleResize)
        window:addPositionCallback(scratchpad.handleMove)

        window:setVisible(true)
        scratchpad.hide()  
        scratchpad.log("Scratchpad Window created")
    end

    function scratchpad.setVisible(b)
        window:setVisible(b)
    end

    function scratchpad.handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 20)

        scratchpad.config.windowSize = { w = w, h = h }
        scratchpad.saveConfiguration()
    end

    function scratchpad.handleMove(self)
        local x, y = self:getPosition()
        scratchpad.config.windowPosition = { x = x, y = y }
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