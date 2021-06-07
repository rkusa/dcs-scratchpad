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
    local kybHidden = false

    --local mouseCurs = getMouseCursorColumnRow(x, y)

    local getCoordsLua =
        [[
        -- thanks MIST! https://github.com/mrSkortch/MissionScriptingTools/blob/master/mist.lua

        local round = function (num, idp)
            local mult = 10^(idp or 0)
            return math.floor(num * mult + 0.5) / mult
        end

        local tostringLL = function (lat, lon, acc, DMS)
            local latHemi, lonHemi
            if lat > 0 then
                latHemi = 'N'
            else
                latHemi = 'S'
            end

            if lon > 0 then
                lonHemi = 'E'
            else
                lonHemi = 'W'
            end

            lat = math.abs(lat)
            lon = math.abs(lon)

            local latDeg = math.floor(lat)
            local latMin = (lat - latDeg)*60

            local lonDeg = math.floor(lon)
            local lonMin = (lon - lonDeg)*60

            if DMS then	-- degrees, minutes, and seconds.
                local oldLatMin = latMin
                latMin = math.floor(latMin)
                local latSec = round((oldLatMin - latMin)*60, acc)

                local oldLonMin = lonMin
                lonMin = math.floor(lonMin)
                local lonSec = round((oldLonMin - lonMin)*60, acc)

                if latSec == 60 then
                    latSec = 0
                    latMin = latMin + 1
                end

                if lonSec == 60 then
                    lonSec = 0
                    lonMin = lonMin + 1
                end

                local secFrmtStr -- create the formatting string for the seconds place
                if acc <= 0 then	-- no decimal place.
                    secFrmtStr = '%02d'
                else
                    local width = 3 + acc	-- 01.310 - that's a width of 6, for example.
                    secFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
                end

                return string.format('%02d', latDeg) .. ' ' .. string.format('%02d', latMin) .. '\' ' .. string.format(secFrmtStr, latSec) .. '"' .. latHemi .. '	 '
                .. string.format('%02d', lonDeg) .. ' ' .. string.format('%02d', lonMin) .. '\' ' .. string.format(secFrmtStr, lonSec) .. '"' .. lonHemi

            else	-- degrees, decimal minutes.
                latMin = round(latMin, acc)
                lonMin = round(lonMin, acc)

                if latMin == 60 then
                    latMin = 0
                    latDeg = latDeg + 1
                end

                if lonMin == 60 then
                    lonMin = 0
                    lonDeg = lonDeg + 1
                end

                local minFrmtStr -- create the formatting string for the minutes place
                if acc <= 0 then	-- no decimal place.
                    minFrmtStr = '%02d'
                else
                    local width = 3 + acc	-- 01.310 - that's a width of 6, for example.
                    minFrmtStr = '%0' .. width .. '.' .. acc .. 'f'
                end

                return string.format('%02d', latDeg) .. ' ' .. string.format(minFrmtStr, latMin) .. '\'' .. latHemi .. '	 '
                .. string.format('%02d', lonDeg) .. ' ' .. string.format(minFrmtStr, lonMin) .. '\'' .. lonHemi

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
            local alt = round(land.getHeight({
                x = mark.pos.x,
                y = mark.pos.z
            }), 0)
            result = result .. "\n" .. tostringLL(lat, lon, 2, true) .. "\n" .. tostring(alt) .. "m, " .. mark.text .. "\n"
        end
        return result
    ]]


------------------------------------------------------------

-----------------------------------------------------------


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




-----Window Close X



local function insertX()
    local keyPress = "X"
    if isHidden == true then
        unlockKeyboardInput(false)
        textarea:setFocused(true)
        window:setHasCursor(true)
        window:setSkin(windowDefaultSkin)

        insertOneBtn:setVisible(true)
        insertTwoBtn:setVisible(true)
        insertThreeBtn:setVisible(true)
        insertFourBtn:setVisible(true)
        insertFiveBtn:setVisible(true)
        insertSixBtn:setVisible(true)
        insertSevenBtn:setVisible(true)
        insertEightBtn:setVisible(true)
        insertNineBtn:setVisible(true)
        insertZeroBtn:setVisible(true)
        insertNBtn:setVisible(true)
        insertEBtn:setVisible(true)
        insertWBtn:setVisible(true)
        insertSpaceBtn:setVisible(true)
        insertClearBtn:setVisible(true)
        insertEnterBtn:setVisible(true)
        insertCleanBtn:setVisible(true)

        textarea:setVisible(true)
        prevButton:setVisible(true)
        nextButton:setVisible(true)
        insertCoordsBtn:setVisible(true)
        insertKybBtn:setVisible(true)

        insertDotiBtn:setVisible(true)

        isHidden = false

    else
        window:setSkin(windowSkinHidden)

        insertKybBtn:setVisible(false)
        insertOneBtn:setVisible(false)
        insertTwoBtn:setVisible(false)
        insertThreeBtn:setVisible(false)
        insertFourBtn:setVisible(false)
        insertFiveBtn:setVisible(false)
        insertSixBtn:setVisible(false)
        insertSevenBtn:setVisible(false)
        insertEightBtn:setVisible(false)
        insertNineBtn:setVisible(false)
        insertZeroBtn:setVisible(false)
        insertNBtn:setVisible(false)
        insertEBtn:setVisible(false)
        insertWBtn:setVisible(false)
        insertSpaceBtn:setVisible(false)
        insertClearBtn:setVisible(false)
        insertEnterBtn:setVisible(false)
        insertCleanBtn:setVisible(false)
        textarea:setVisible(false)
        prevButton:setVisible(false)
        nextButton:setVisible(false)
        insertCoordsBtn:setVisible(false)

        insertQBtn:setVisible(false)
        insertWWBtn:setVisible(false)
        insertEEBtn:setVisible(false)
        insertRBtn:setVisible(false)
        insertTBtn:setVisible(false)
        insertYBtn:setVisible(false)
        insertUBtn:setVisible(false)
        insertIBtn:setVisible(false)
        insertOBtn:setVisible(false)
        insertPBtn:setVisible(false)

        insertABtn:setVisible(false)
        insertSBtn:setVisible(false)
        insertDBtn:setVisible(false)
        insertFBtn:setVisible(false)
        insertGBtn:setVisible(false)
        insertHBtn:setVisible(false)
        insertJBtn:setVisible(false)
        insertKBtn:setVisible(false)
        insertLBtn:setVisible(false)

        insertZBtn:setVisible(false)
        insertXXBtn:setVisible(false)
        insertCBtn:setVisible(false)
        insertVBtn:setVisible(false)
        insertBBtn:setVisible(false)
        insertNNBtn:setVisible(false)
        insertMBtn:setVisible(false)

        insertSpace2Btn:setVisible(false)
        insertEnter2Btn:setVisible(false)
        insertClear2Btn:setVisible(false)

        insertDotiBtn:setVisible(false)

        isHidden = true
    end


end

-----------------------------------------------------------------------
---KYB

local function insertKyb()
    local keyPress = "1"
    if kybHidden == true then

        insertQBtn:setVisible(true)
        insertEEBtn:setVisible(true)
        insertWWBtn:setVisible(true)
        insertRBtn:setVisible(true)
        insertTBtn:setVisible(true)
        insertYBtn:setVisible(true)
        insertUBtn:setVisible(true)
        insertIBtn:setVisible(true)
        insertOBtn:setVisible(true)
        insertPBtn:setVisible(true)

        insertABtn:setVisible(true)
        insertSBtn:setVisible(true)
        insertDBtn:setVisible(true)
        insertFBtn:setVisible(true)
        insertGBtn:setVisible(true)
        insertHBtn:setVisible(true)
        insertJBtn:setVisible(true)
        insertKBtn:setVisible(true)
        insertLBtn:setVisible(true)

        insertZBtn:setVisible(true)
        insertXXBtn:setVisible(true)
        insertCBtn:setVisible(true)
        insertVBtn:setVisible(true)
        insertBBtn:setVisible(true)
        insertNNBtn:setVisible(true)
        insertMBtn:setVisible(true)

        insertSpace2Btn:setVisible(true)
        insertEnter2Btn:setVisible(true)
        insertClear2Btn:setVisible(true)

        kybHidden = false

    else
        insertQBtn:setVisible(false)
        insertEEBtn:setVisible(false)
        insertWWBtn:setVisible(false)
        insertRBtn:setVisible(false)
        insertTBtn:setVisible(false)
        insertYBtn:setVisible(false)
        insertUBtn:setVisible(false)
        insertIBtn:setVisible(false)
        insertOBtn:setVisible(false)
        insertPBtn:setVisible(false)

        insertABtn:setVisible(false)
        insertSBtn:setVisible(false)
        insertDBtn:setVisible(false)
        insertFBtn:setVisible(false)
        insertGBtn:setVisible(false)
        insertHBtn:setVisible(false)
        insertJBtn:setVisible(false)
        insertKBtn:setVisible(false)
        insertLBtn:setVisible(false)

        insertZBtn:setVisible(false)
        insertXXBtn:setVisible(false)
        insertCBtn:setVisible(false)
        insertVBtn:setVisible(false)
        insertBBtn:setVisible(false)
        insertNNBtn:setVisible(false)
        insertMBtn:setVisible(false)


        insertSpace2Btn:setVisible(false)
        insertEnter2Btn:setVisible(false)
        insertClear2Btn:setVisible(false)

        kybHidden = true
    end
end

---------------------------------------------------------------------
function findCaret()
		text = textarea:getText():gsub("|", "")
		return text
end

---------------------------------------------------------------------


function splitText(text, lineBegin, indexBegin)
    local found = 1
    local index = 0
    local linesCount = 0
    local notFound = true
    local temp = string.find(text, "\n")
    local prevLineLen = 0

    if temp ~= nil then
        prevLineLen = temp - 1
    end

    found = string.find(text, "\n", index)
    text = textarea:getText()

    if lineBegin > 0 then
        while notFound == true and found ~= nil do
            index = found + 1
            linesCount = linesCount + 1

            if linesCount == lineBegin then
                index = index + indexBegin - 1
                notFound = false
            else
                found = string.find(text, "\n", index)
                prevLineLen = found - index
            end
        end
    else
        index = index + indexBegin
    end

    return index, prevLineLen
end

function removeString()
    local text = textarea:getText()
    local lineBegin, indexBegin, lineEnd, indexEnd = textarea:getSelectionNew()
    text = findCaret()
    if lineBegin == 0 and indexBegin == 0 then
        return
    end

    local index, prevLineLen = splitText(text, lineBegin, indexBegin)

    local first = text:sub(0, index - 1)
    local second = text:sub(index + 1)

    local enterDeleted = text:sub(index, index) == "\n"
    text = first .. second

    textarea:setText(text)

    if enterDeleted then
        textarea:setSelectionNew(lineBegin - 1, prevLineLen, lineEnd - 1, prevLineLen)
    else
        textarea:setSelectionNew(lineBegin, indexBegin - 1, lineEnd, indexEnd - 1)
    end

end

function addString(textToAdd)
    local text = textarea:getText()
    local lineBegin, indexBegin, lineEnd, indexEnd = textarea:getSelectionNew()
    text = findCaret()

    local index = splitText(text, lineBegin, indexBegin)

    local first = text:sub(0, index)
    local second = text:sub(index + 1)
    text = first .. textToAdd .. second

    textarea:setText(text)
    textarea:setSelectionNew(lineBegin, indexBegin + 1, lineEnd, indexEnd + 1)

end

function addEnter()
    local text = textarea:getText()
    local lineBegin, indexBegin, lineEnd, indexEnd = textarea:getSelectionNew()
    text = findCaret()

    local index = splitText(text, lineBegin, indexBegin)

    local first = text:sub(0, index)
    local second = text:sub(index + 1)
    text = first .. "\n|" .. second


    textarea:setText(text)

    textarea:setSelectionNew(lineBegin + 1, 0, lineEnd + 1, 0)

end

---ENTER

local function insertEnter()
    addEnter()
    savePage(currentPage, textarea:getText(), true)
end

---1
 local function insertOne()
	addString("1|")
	savePage(currentPage, textarea:getText(), true)
end

---2
 local function insertTwo()
    addString("2|")
    savePage(currentPage, textarea:getText(), true)
end

---3
 local function insertThree()
    addString("3|")
    savePage(currentPage, textarea:getText(), true)
end

---4
local function insertFour()
    addString("4|")
    savePage(currentPage, textarea:getText(), true)
end

---5
local function insertFive()
    addString("5|")
    savePage(currentPage, textarea:getText(), true)
end

---6
local function insertSix()
    addString("6|")
    savePage(currentPage, textarea:getText(), true)
end

---7
local function insertSeven()
    addString("7|")
    savePage(currentPage, textarea:getText(), true)
end

---8
local function insertEight()
    addString("8|")
    savePage(currentPage, textarea:getText(), true)
end

---9
local function insertNine()
    addString("9|")
    savePage(currentPage, textarea:getText(), true)
end

---0
local function insertZero()
    addString("0|")
    savePage(currentPage, textarea:getText(), true)
end

---N
local function insertN()
    addString("N|")
    savePage(currentPage, textarea:getText(), true)
end

---E
local function insertE()
    addString("E|")
    savePage(currentPage, textarea:getText(), true)
end

---W
local function insertW()
    addString("W|")
    savePage(currentPage, textarea:getText(), true)
end

---Space
local function insertSpace()
    addString(" |")
    savePage(currentPage, textarea:getText(), true)
end

---Clear
local function insertClear()
    removeString()

    savePage(currentPage, textarea:getText(), true)
end

--clean
local function insertClean()
    local keyPress = "\b"
    textarea:setText("")
    savePage(currentPage, textarea:getText(), true)
end

---------keyboard
local function insertQ()
    addString("Q|")
    savePage(currentPage, textarea:getText(), true)
end

local function insertR()
    addString("R|")
    savePage(currentPage, textarea:getText(), true)
end

local function insertT()
    addString("T|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertY()
    addString("Y|")
    savePage(currentPage, textarea:getText(), true)
end

local function insertU()
    addString("U|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertI()
    addString("I|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertO()
    addString("O|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertP()
    addString("P|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertA()
    addString("A|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertS()
    addString("S|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertD()
    addString("D|")
    savePage(currentPage, textarea:getText(), true)
end

local function insertF()
    addString("F|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertG()
    addString("G|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertH()
    addString("H|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertJ()
    addString("J|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertK()
    addString("K|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertL()
    addString("L|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertZ()
    addString("Z|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertXX()
    addString("X|")
    savePage(currentPage, textarea:getText(), true)
end

local function insertC()
    addString("C|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertV()
    addString("V|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertB()
    addString("B|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertM()
    addString("M|")
    savePage(currentPage, textarea:getText(), true)
end


local function insertDoti()
   addString(".|")
   savePage(currentPage, textarea:getText(), true)
end


    -----functii panel!!!!!!!!!!!!!!!!!!!
    function scratchpad.createWindow()
        window = DialogLoader.spawnDialogFromFile(lfs.writedir() .. "Scripts\\Scratchpad\\ScratchpadWindow.dlg", cdata)
        windowDefaultSkin = window:getSkin()
        panel = window.Box
        textarea = panel.ScratchpadEditBox
        insertCoordsBtn = panel.ScratchpadInsertCoordsButton


        prevButton = panel.ScratchpadPrevButton
        nextButton = panel.ScratchpadNextButton

        insertEnterBtn = panel.ScratchpadInsertENTER
        insertOneBtn = panel.ScratchpadInsertONE
        insertTwoBtn = panel.ScratchpadInsertTWO
        insertThreeBtn = panel.ScratchpadInsertTHREE
        insertFourBtn = panel.ScratchpadInsertFOUR
        insertFiveBtn = panel.ScratchpadInsertFIVE
        insertSixBtn = panel.ScratchpadInsertSIX
        insertSevenBtn = panel.ScratchpadInsertSEVEN
        insertEightBtn = panel.ScratchpadInsertEIGHT
        insertNineBtn = panel.ScratchpadInsertNINE
        insertZeroBtn = panel.ScratchpadInsertZERO
        insertNBtn = panel.ScratchpadInsertN
        insertEBtn = panel.ScratchpadInsertE
        insertWBtn = panel.ScratchpadInsertW
        insertSpaceBtn = panel.ScratchpadInsertSPACE
        insertClearBtn = panel.ScratchpadInsertCLEAR
        insertClear2Btn = panel.ScratchpadInsertCLEAR2
        insertCleanBtn = panel.ScratchpadInsertCLEAN
        insertXBtn = panel.ScratchpadInsertX
        insertKybBtn = panel.ScratchpadInsertKYB


    ----keyboard



        insertQBtn = panel.ScratchpadInsertQ
        insertWWBtn = panel.ScratchpadInsertWW
        insertEEBtn = panel.ScratchpadInsertEE
        insertRBtn = panel.ScratchpadInsertR
        insertTBtn = panel.ScratchpadInsertT
        insertYBtn = panel.ScratchpadInsertY
        insertUBtn = panel.ScratchpadInsertU
        insertIBtn = panel.ScratchpadInsertI
        insertOBtn = panel.ScratchpadInsertO
        insertPBtn = panel.ScratchpadInsertP

        insertABtn = panel.ScratchpadInsertA
        insertSBtn = panel.ScratchpadInsertS
        insertDBtn = panel.ScratchpadInsertD
        insertFBtn = panel.ScratchpadInsertF
        insertGBtn = panel.ScratchpadInsertG
        insertHBtn = panel.ScratchpadInsertH
        insertJBtn = panel.ScratchpadInsertJ
        insertKBtn = panel.ScratchpadInsertK
        insertLBtn = panel.ScratchpadInsertL

        insertZBtn = panel.ScratchpadInsertZ
        insertXXBtn = panel.ScratchpadInsertXX
        insertCBtn = panel.ScratchpadInsertC
        insertVBtn = panel.ScratchpadInsertV
        insertBBtn = panel.ScratchpadInsertB
        insertNNBtn = panel.ScratchpadInsertNN
        insertMBtn = panel.ScratchpadInsertM

        insertSpace2Btn = panel.ScratchpadInsertSPACE2
        insertEnter2Btn = panel.ScratchpadInsertENTER2

        insertDotiBtn = panel.ScratchpadInsertDOTI

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

        -- setup button callbacks   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        -----silviu
        insertXBtn:addMouseDownCallback(
            function(self)
                insertX()
            end
        )


        insertCleanBtn:addMouseDownCallback(
            function(self)
                insertClean()
            end
        )


        insertTwoBtn:addMouseDownCallback(
            function(self)
                insertTwo()
            end
        )

        insertThreeBtn:addMouseDownCallback(
            function(self)
                insertThree()
            end
        )


        insertFourBtn:addMouseDownCallback(
            function(self)
                insertFour()
            end
        )


        insertFiveBtn:addMouseDownCallback(
            function(self)
                insertFive()
            end
        )


        insertSixBtn:addMouseDownCallback(
            function(self)
                insertSix()
            end
        )


        insertSevenBtn:addMouseDownCallback(
            function(self)
                insertSeven()
            end
        )


        insertEightBtn:addMouseDownCallback(
            function(self)
                insertEight()
            end
        )


        insertNineBtn:addMouseDownCallback(
            function(self)
                insertNine()
            end
        )


        insertZeroBtn:addMouseDownCallback(
            function(self)
                insertZero()
            end
        )


        insertNBtn:addMouseDownCallback(
            function(self)
                insertN()
            end
        )


        insertEBtn:addMouseDownCallback(
            function(self)
                insertE()
            end
        )


        insertSpaceBtn:addMouseDownCallback(
            function(self)
                insertSpace()
            end
        )

        insertWBtn:addMouseDownCallback(
            function(self)
                insertW()
            end
        )


        insertClearBtn:addMouseDownCallback(
            function(self)
                insertClear()
            end
        )

        insertClear2Btn:addMouseDownCallback(
            function(self)
                insertClear()
            end
        )

        insertEnterBtn:addMouseDownCallback(
            function(self)
                insertEnter()
            end
        )

        insertOneBtn:addMouseDownCallback(
            function(self)
                insertOne()
            end
        )

        ---keyboard

        insertQBtn:addMouseDownCallback(
            function(self)
                insertQ()
            end
        )


        insertWWBtn:addMouseDownCallback(
            function(self)
                insertW()
            end
        )

        insertEEBtn:addMouseDownCallback(
            function(self)
                insertE()
            end
        )

        insertRBtn:addMouseDownCallback(
            function(self)
                insertR()
            end
        )

        insertTBtn:addMouseDownCallback(
            function(self)
                insertT()
            end
        )

        insertYBtn:addMouseDownCallback(
            function(self)
                insertY()
            end
        )


        insertUBtn:addMouseDownCallback(
            function(self)
                insertU()
            end
        )


        insertIBtn:addMouseDownCallback(
            function(self)
                insertI()
            end
        )

        insertOBtn:addMouseDownCallback(
            function(self)
                insertO()
            end
        )


        insertPBtn:addMouseDownCallback(
            function(self)
                insertP()
            end
        )

        insertABtn:addMouseDownCallback(
            function(self)
                insertA()
            end
        )


        insertSBtn:addMouseDownCallback(
            function(self)
                insertS()
            end
        )


        insertDBtn:addMouseDownCallback(
            function(self)
                insertD()
            end
        )

        insertFBtn:addMouseDownCallback(
            function(self)
                insertF()
            end
        )


        insertGBtn:addMouseDownCallback(
            function(self)
                insertG()
            end
        )


        insertHBtn:addMouseDownCallback(
            function(self)
                insertH()
            end
        )

        insertJBtn:addMouseDownCallback(
            function(self)
                insertJ()
            end
        )


        insertKBtn:addMouseDownCallback(
            function(self)
                insertK()
            end
        )


        insertLBtn:addMouseDownCallback(
            function(self)
                insertL()
            end
        )


        insertZBtn:addMouseDownCallback(
            function(self)
                insertZ()
            end
        )

        insertXXBtn:addMouseDownCallback(
            function(self)
                insertXX()
            end
        )

        insertCBtn:addMouseDownCallback(
            function(self)
                insertC()
            end
        )

        insertVBtn:addMouseDownCallback(
            function(self)
                insertV()
            end
        )

        insertBBtn:addMouseDownCallback(
            function(self)
                insertB()
            end
        )

        insertNNBtn:addMouseDownCallback(
            function(self)
                insertN()
            end
        )

        insertMBtn:addMouseDownCallback(
            function(self)
                insertM()
            end
        )


        insertSpace2Btn:addMouseDownCallback(
            function(self)
                insertSpace()
            end
        )

        insertEnter2Btn:addMouseDownCallback(
            function(self)
                insertEnter()
            end
        )

        insertKybBtn:addMouseDownCallback(
            function(self)
                insertKyb()
            end
        )


        insertDotiBtn:addMouseDownCallback(
            function(self)
                insertDoti()
            end
        )


        ----SILVIU


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

        --scratchpad.hide()    sa apara ascuns
        scratchpad.log("Scratchpad Window created")
    end

    function scratchpad.setVisible(b)
        window:setVisible(b)
    end


------bounds    !!!!!!!!!!!!!!!!!!!!!!



    function scratchpad.handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        textarea:setBounds(0, 0, w, h - 40 - 20 - 60- 120)
        prevButton:setBounds(220, h - 220, 50, 20)
        nextButton:setBounds(275, h - 220, 50, 20)

        insertOneBtn:setBounds(0, h - 220, 50, 20)
        insertTwoBtn:setBounds(55, h - 220, 50, 20)
        insertThreeBtn:setBounds(110, h - 220, 50, 20)
        insertFourBtn:setBounds(0, h - 200, 50, 20)
        insertFiveBtn:setBounds(55, h - 200, 50, 20)
        insertSixBtn:setBounds(110, h - 200, 50, 20)
        insertSevenBtn:setBounds(0, h - 180, 50, 20)
        insertEightBtn:setBounds(55, h - 180, 50, 20)
        insertNineBtn:setBounds(110, h - 180, 50, 20)
        insertZeroBtn:setBounds(55, h - 160, 50, 20)
        insertNBtn:setBounds(165, h - 220, 50, 20)
        insertEBtn:setBounds(165, h - 200, 50, 20)
        insertWBtn:setBounds(165, h - 180, 50, 20)
        insertSpaceBtn:setBounds(165, h - 160, 50, 20)
        insertClearBtn:setBounds(0, h - 160, 50, 20)
        insertEnterBtn:setBounds(110, h - 160, 50, 20)
        insertCleanBtn:setBounds(275, h - 180, 50, 20)
        insertXBtn:setBounds(0, h - 240, 20, 20)

        insertKybBtn:setBounds(220, h - 160, 50, 20)

----------------keyboard

        insertQBtn:setBounds(0, h - 140, 28, 20)
        insertWWBtn:setBounds(33, h - 140, 28, 20)
        insertEEBtn:setBounds(66, h - 140, 28, 20)
        insertRBtn:setBounds(99, h - 140, 28, 20)
        insertTBtn:setBounds(132, h - 140, 28, 20)
        insertYBtn:setBounds(165, h - 140, 28, 20)
        insertUBtn:setBounds(198, h - 140, 28, 20)
        insertIBtn:setBounds(231, h - 140, 28, 20)
        insertOBtn:setBounds(264, h - 140, 28, 20)
        insertPBtn:setBounds(297, h - 140, 28, 20)

        insertABtn:setBounds(16, h - 120, 28, 20)
        insertSBtn:setBounds(49, h - 120, 28, 20)
        insertDBtn:setBounds(82, h - 120, 28, 20)
        insertFBtn:setBounds(115, h - 120, 28, 20)
        insertGBtn:setBounds(148, h - 120, 28, 20)
        insertHBtn:setBounds(181, h - 120, 28, 20)
        insertJBtn:setBounds(214, h - 120, 28, 20)
        insertKBtn:setBounds(247, h - 120, 28, 20)
        insertLBtn:setBounds(280, h - 120, 28, 20)

        insertZBtn:setBounds(49, h - 100, 28, 20)
        insertXXBtn:setBounds(82, h - 100, 28, 20)
        insertCBtn:setBounds(115, h - 100, 28, 20)
        insertVBtn:setBounds(148, h - 100, 28, 20)
        insertBBtn:setBounds(181, h - 100, 28, 20)
        insertNNBtn:setBounds(214, h - 100, 28, 20)
        insertMBtn:setBounds(247, h - 100, 28, 20)

        insertSpace2Btn:setBounds(82, h - 80, 160, 20)
        insertEnter2Btn:setBounds(247, h - 80, 78, 20)
        insertClear2Btn:setBounds(287, h - 100, 38, 20)


        insertDotiBtn:setBounds(220, h - 180, 50, 20)




        if pagesCount > 1 then
            insertCoordsBtn:setBounds(220, h - 200, 50, 20)
        else
            insertCoordsBtn:setBounds(220, h - 200, 50, 20)
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
