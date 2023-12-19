-- v 231016A
local TICKS = 1 -- To slow down processing, increase this number
--==================================================================================
do -- A QUERTY'ish Keyboard by Draken35
  local keyMatrix = {
    { "@<#>","Load Wpts" },
    { "~","!", "@", "#", "$", "%", "^", "&", "*", "(", ")","_","+","|", "⌫" ,"7","8","9"},
    { "`","1", "2", "3", "4", "5", "6", "7", "8", "9", "0","-","=", ";", "'", ",","4","5","6"},
    { "[","]","Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "{","}","\\",".","1","2","3" },
    { "CAPS","A", "S", "D", "F", "G", "H", "J", "K", "L", ":","\"","/", "↩", "00","⌫X"},
    { "Shift","Z", "X", "C", "V", "B", "N", "M", "<", ">", "?","°","␣"  },

   
  } 
  local width = 30
  local height = 30
  local capsOn = false
  local shift = false

  addButton(0, 0, 50, 30, "CLR", function(text)
    text:setText("")
  end)


  local y = 30
  for _, r in pairs(keyMatrix) do
    local x = 0
    for k, v in pairs(r) do
      local title = v
      local char = v
      if type(v) == "table" then
        title, char = pairs(v)(v)
      end
      local onClick = function(text)
        text:insert(char)
      end
      if string.byte(char) >= 65 and string.byte(char) <= 90 then
        onClick = function(text)
          if capsOn or shift then
            text:insert(char)
            if shift then
              shift = false
            end
          else
            text:insert(string.char(string.byte(char)+32))
          end
        end
      end
    
      if v == "⌫" then
        onClick = function(text)
          text:deleteBackward()
        end
        width = 60
      elseif v == "⌫X" then
        onClick = function(text)
          text:deleteBackward()
        end
         title = "⌫"
        width = 30      
      elseif v == "↩" then
        onClick = function(text)
           text:insert("\n")
          end
        width = 60
      elseif v == "CLR" then
        onClick = function(text)
          text:setText("")
        end
        width = 60
      elseif v == "␣" then
        onClick = function(text)
          text:insert(" ")
        end
        width = 180--480   
      elseif v == "CAPS" then
        onClick = function(text)
            capsOn = not capsOn
          end
        width = 60     
      elseif v == "Shift" then
        onClick = function(text)
            shift = not shift
          end
        width = 60     
      elseif v == "00" then
        title = "0"
        onClick = function(text)
            text:insert("0")
          end
        width = 60     
      elseif v == "@<#>" then
        onClick = function(text)
            text:insert("@<#>")
          end
        width = 60        
      elseif v == "@[#]" then
        onClick = function(text)
            text:insert("@<#>")
          end
        width = 60        
     elseif v == "Load Wpts" then
        onClick = function(text)
          insertCoords(text)
        end
        width = 180--480      
        x = 390
      else
        width = 30
    end
    
      addButton(x, y, width, height, title, onClick)

      x = x + width
    end
    if width > 30 then
      width = 30
    end
    y = y + width
  end


end -- keyboard
--==================================================================================
 -- Coordinates loading... the magic happens here
local tick_counter = 0
local doLoadCoords = false 
local inputBuffer = {}
local dataIndex = 1
local counterFrame = 0
local doDepress = false
local debugOn = true

local handler = {}
function handler.onSimulationFrame()
  tick_counter = tick_counter + 1
  if tick_counter == TICKS then
    tick_counter = 0
    if doLoadCoords == true then 
        ProcessInputBuffer()
    end
  end
end -- function

DCS.setUserCallbacks(handler)
--==================================================================================
addCoordinateListener(
  function (text, lat, lon, alt, mgrs, types)

    local ac = DCS.getPlayerUnitType()
    local insert = ""
    log('Adding coordinates for '..ac) 
    if ac == "FA-18C_hornet" then
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."|"
		elseif (ac == "UH-60L" or ac == "SH60B" or ac == "MH-60R") then -- Add new branches for UH-60L, SH60B, and MH-60R aircraft with DDM format
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."||" -- Format the coordinates in DDM for these H-60 variations
      log('H 60 Coord found are ' .. lat .. ' ' .. lon)
	elseif ac == "F-16C_50"  then
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."|" 
    elseif ac == "M-2000C"  then
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."|" 
    elseif ac == "AV8BNA" then
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."|"   
    elseif ac == "F-15ESE" then 
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."|"  
    elseif ac == "AH-64D_BLK_II" then
      insert = "@|#|"..formatCoord("MGRS", nil, mgrs, types.MGRS) .. "|" ..string.format("%.0f", alt*3.28084).."||"  
    elseif ac == "A-10C_2" or ac == "A-10C" then  
      insert = "@|#|"..formatCoord("DDM", true, lat, types.DDM) .. "|" .. formatCoord("DDM", false, lon, types.DDM).."|"..string.format("%.0f", alt*3.28084).."||"  
    end
    
    text:insertBelow(insert)
  end -- function
) --addCoordinateListener
--==================================================================================
function insertCoords(text)
  local StartWaypoint = 1
  local Waypoints = {}
  local wpi = 0 
  local lc = 0
  local ac = DCS.getPlayerUnitType()
  local role = DCS.getUnitProperty(DCS.getPlayerUnit(),DCS.UNIT_ROLE)
  log('insertCoords --> '..ac..' / '..role)     
  --local ExtraDelay = 0
  
  for LINE in string.gmatch(text:getText(),"([^\n]*)\n?") do    
    local line = LINE:gsub("^%s*(.-)%s*$", "%1"):upper()
    local L = string.len(line)
    local tokens = {}
    local lineType = 'WP'
    local separator = '|'
    local ti = 0
    lc = lc + 1
    if (string.sub(line,1,2) == "@<" or string.sub(line,1,2) == "@|") and L > 2 then
      if string.sub(line,1,2) == "@<" then
        lineType = 'SWP'
        separator = '>'    
     --   log('Found @<')
      end
      if string.sub(line,1,2) == "@[" then
        lineType = 'DEL'
        separator = ']'         
    --    log('Found @[')        
      end
      local temp = ''
      for i = 3,L do
        local c = string.sub(line,i,i)
        if c ~= separator then
          temp = temp..c
        end
        if (i == L or c == separator) and  temp ~= '' then
          ti = ti + 1
          tokens[ti] = temp
          temp = ''
        end
      end   -- for i = 3,L do      
      if lineType == 'DEL' and #tokens == 1 then
        TICKS = tokens[1]
    --    log('TICKS set to: '.. tokens[1])
      end
      if lineType == 'SWP' and #tokens == 1 then
        StartWaypoint = tokens[1]
      end
	    if lineType == 'WP' and (#tokens == 3 or #tokens == 4) and (ac == 'UH-60L' or ac == 'SH60B' or ac == 'MH-60R') then -- Additional branch for H-60 aircraft variants 
        wpi = wpi + 1
        if #tokens == 4 then -- Extracting waypoint data for H60
			    Waypoints[wpi] = {des = tokens[1], lat = tokens[2], lon = tokens[3], name = tokens[4]}
		    else
			    Waypoints[wpi] = {des = tokens[1], lat = tokens[2], lon = tokens[3], name = ''}
		    end
      end
      if lineType == 'WP' and #tokens == 4 and ac ~= 'AH-64D_BLK_II' and  ac ~= "A-10C_2" and ac ~= "A-10C" and (ac ~= "UH-60L" or ac == 'SH60B' or ac == 'MH-60R') then
        wpi = wpi + 1
        Waypoints[wpi] = {des = tokens[1], lat = tokens[2], lon = tokens[3], alt = tokens[4] }
      end
      if lineType == 'WP' and  (#tokens == 3 or #tokens == 4) and ac == 'AH-64D_BLK_II' then
        wpi = wpi + 1
        if #tokens == 4 then
          Waypoints[wpi] = {des = tokens[1], mgrs = tokens[2], alt = tokens[3], free = tokens[4]}
        else       
          Waypoints[wpi] = {des = tokens[1], mgrs = tokens[2], alt = tokens[3], free = ''}         
        end
      end
      if lineType == 'WP' and  (#tokens == 4 or #tokens == 5) and (ac == "A-10C_2" or ac == "A-10C") then
        wpi = wpi + 1
        if #tokens == 5 then
          log(ac..' 5 tokens') 
          Waypoints[wpi] = {des = tokens[1], lat = tokens[2], lon = tokens[3], alt = tokens[4], name = tokens[5]}
        else      
          log(ac..' 4 tokens') 
          Waypoints[wpi] = {des = tokens[1], lat = tokens[2], lon = tokens[3], alt = tokens[4], name = ''}         
        end
      end      

    end -- if (string.sub(line,1,2) == "@<" or string.sub(line,1,2) == "@<") and L > 2 then
  end --   for line in string.gmatch(text:getText(),"([^\n]*)\n?") do
  if wpi > 0 then
    loadCoordinates(StartWaypoint,Waypoints)
  end
 return true
end -- function
--==================================================================================    
function loadCoordinates(StartWaypoint,Waypoints)--, ExtraDelay)
   -- ExtraDelay = ExtraDelay
    local ac = DCS.getPlayerUnitType()
    local role = DCS.getUnitProperty(DCS.getPlayerUnit(),DCS.UNIT_ROLE)
    log('loadCoordinates --> '..ac..' ('..role..')')   
  
    if ac == "AV8BNA" then
      loadInAV8B(StartWaypoint,Waypoints)
    elseif (ac == "UH-60L" or ac == "SH60B" or ac == "MH-60R") then -- Add a conditional branch for H-60 variants
      log('loadCoordinates found H60')
      loadInH60(Waypoints) -- Call the loadInH60 function for H-60 aircraft variants
    elseif ac == "F-15ESE"  then
        local device = 57
      if role == 'pilot' then
        device = 56
      end
      loadInF15E(StartWaypoint,Waypoints,device)
    elseif ac == "A-10C_2" or ac == "A-10C" then
      loadInA10(StartWaypoint,Waypoints)
    elseif ac == "FA-18C_hornet"  then
      loadInF18(StartWaypoint,Waypoints) 
    elseif ac == "M-2000C" then
      loadInM2000(StartWaypoint,Waypoints)
    elseif ac == "F-16C_50" then
      loadInF16(StartWaypoint,Waypoints)
    elseif  ac == 'AH-64D_BLK_II' then
        local seat = 'CPG'
      if role == 'pilot' then
        seat = 'PLT'
      end
      loadInApache(StartWaypoint,Waypoints,seat)
    end
  end -- function
--==================================================================================
-- the new version takes into account delay in ms, not in frames
function clicOn(device, code, delay, position )
  delay = delay or 250
  position = position or 1
  -- Convert delay from milliseconds to frames
  local delayInFrames = delay / (LoGetFrameTime() * 1000)
  local datas ={device, code, delayInFrames, position} --this should make it so the delay is in milliseconds, not frames, to make the duration of a keypress more predictable
  table.insert(inputBuffer,datas)
  log('clicOn('..device..','.. code..','.. delay..','.. position..')')
end -- function

--[[ function clicOn(device, code, delay, position ) --commented out until tested, will need to be removed once the new function is proven
  delay = delay or 0 --delay here is expressed in frames
  position = position or 1
  local datas ={device, code, delay, position}
  table.insert(inputBuffer,datas)
  log('clicOn('..device..','.. code..','.. delay..','.. position..')')
end -- function ]]
--==================================================================================
function ProcessInputBuffer()  
  for i = dataIndex, #inputBuffer do
      if not doDepress then 
          Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],inputBuffer[i][4])
          if inputBuffer[i][3] > 0 then 
              doDepress = true
          else 
              if inputBuffer[i][4] == 1 or inputBuffer[i][4] == -1 then 
                  Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],0)
              end
              dataIndex = dataIndex+1
          end
      else
          -- Compare counterFrame to the frame-based delay
          if counterFrame >= tonumber(inputBuffer[i][3]) then 
              dataIndex = dataIndex+1
              counterFrame = 0
              if inputBuffer[i][4] == 1 or inputBuffer[i][4] == -1 then 
                  Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],0)
              end
              doDepress = false
          else 
              counterFrame = counterFrame+1
          end
      end

      break
  end

  if dataIndex == table.getn(inputBuffer)+1 then
      doLoadCoords = false
      dataIndex=1
      counterFrame =0
      doDepress =false
  en

--[[ function ProcessInputBuffer()  
  for i = dataIndex, #inputBuffer do
      if not doDepress then 
          Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],inputBuffer[i][4])
          if inputBuffer[i][3] >0 then 
              doDepress = true
          else 
              if inputBuffer[i][4] == 1 or inputBuffer[i][4] == -1 then 
                  Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],0)
               --   log('pos: '..inputBuffer[i][4] )
              end
              dataIndex = dataIndex+1
          end
      else
          if counterFrame >= tonumber(inputBuffer[i][3]) then 
              dataIndex = dataIndex+1
              counterFrame = 0
              if inputBuffer[i][4] == 1 or inputBuffer[i][4] == -1 then 
                  Export.GetDevice(inputBuffer[i][1]):performClickableAction(inputBuffer[i][2],0)
              end
              doDepress =false
          else 
              counterFrame = counterFrame+1
              
          end
      end

      break
  end

  if dataIndex == table.getn(inputBuffer)+1 then
      doLoadCoords = false
      dataIndex=1
      counterFrame =0
      doDepress =false
  end

end -- function ]]
--================================================================================================================
--  H-60 logic
--================================================================================================================
function loadInH60(waypoints)
  local status, err = pcall(function()
    inputbuffer = {}
    log('called LoadinH60')
    local device = 23
    local delay = 350
    local compliantName = ''

      local keys = {
      ['1']=			{LTR= nil,  KEY='3242'},-- AN/ASN-128B Btn 1
      ['2']=			{LTR= nil,  KEY='3243'},-- AN/ASN-128B Btn 2
      ['3']=			{LTR= nil,  KEY='3244'},-- AN/ASN-128B Btn 3
      ['4']=			{LTR= nil,  KEY='3246'},-- AN/ASN-128B Btn 4
      ['5']=			{LTR= nil,  KEY='3247'},-- AN/ASN-128B Btn 5
      ['6']=			{LTR= nil,  KEY='3248'},-- AN/ASN-128B Btn 6
      ['7']=			{LTR= nil,  KEY='3250'},-- AN/ASN-128B Btn 7
      ['8']=			{LTR= nil,  KEY='3251'},-- AN/ASN-128B Btn 8
      ['9']=			{LTR= nil,  KEY='3252'},-- AN/ASN-128B Btn 9
      ['0']=			{LTR= nil,  KEY='3255'},-- AN/ASN-128B Btn 0
      
      ['DispSel']={LTR= nil,  KEY='3236'}, -- AN/ASN-128B Display Selector
      ['ModSel']=	{LTR= nil,  KEY='3235'}, -- AN/ASN-128B Mode Selector
      ['KYBD']=		{LTR= nil,  KEY='3237'}, -- AN/ASN-128B Btn KYBD
      ['LTR_L']=	{LTR= nil,  KEY='3238'}, -- AN/ASN-128B Btn LTR LEFT
      ['LTR_M']=	{LTR= nil,  KEY='3239'}, -- AN/ASN-128B Btn LTR MID
      ['LTR_R']=	{LTR= nil,  KEY='3240'}, -- AN/ASN-128B Btn LTR RIGHT
      ['F1']=			{LTR= nil,  KEY='506'}, -- AN/ASN-128B Btn F1
      ['TGT_S']=	{LTR= nil,  KEY='510'}, -- AN/ASN-128B Btn TGT STR
      ['INC']=		{LTR= nil,  KEY='3249'}, -- AN/ASN-128B Btn INC
      ['DEC']=		{LTR= nil,  KEY='3253'}, -- AN/ASN-128B Btn DEC
      ['CLR']=		{LTR= nil,  KEY='3254'}, -- AN/ASN-128B Btn CLR
      ['ENT']=		{LTR= nil,  KEY='3256'}, -- AN/ASN-128B Btn ENT
      
      ['A']=			{LTR='3238', KEY='3242'}, --1 LTR L Keys
      ['D']=			{LTR='3238', KEY='3243'}, --2 LTR L Keys
      ['G']=			{LTR='3238', KEY='3244'}, --3 LTR L Keys
      ['J']=			{LTR='3238', KEY='3246'}, --4 LTR L Keys
      ['M']=			{LTR='3238', KEY='3247'}, --5 LTR L Keys
      ['P']=			{LTR='3238', KEY='3248'}, --6 LTR L Keys
      ['S']=			{LTR='3238', KEY='3250'}, --7 LTR L Keys
      ['W']=			{LTR='3238', KEY='3251'}, --8 LTR L Keys
      ['Z']=			{LTR='3238', KEY='3252'}, --9 LTR L Keys
      
      ['B']=			{LTR='3239', KEY='3242'}, --1 LTR M keys
      ['E']=			{LTR='3239', KEY='3243'}, --2 LTR M keys
      ['H']=			{LTR='3239', KEY='3244'}, --3 LTR M keys
      ['K']=			{LTR='3239', KEY='3246'}, --4 LTR M keys
      ['N']=			{LTR='3239', KEY='3247'}, --5 LTR M keys
      ['Q']=			{LTR='3239', KEY='3248'}, --6 LTR M keys
      ['T']=			{LTR='3239', KEY='3250'}, --7 LTR M keys
      ['V']=			{LTR='3239', KEY='3251'}, --8 LTR M keys
      ['*']=			{LTR='3239', KEY='3252'}, --9 LTR M keys
      
      ['C']=			{LTR='3240', KEY='3242'}, --1 LTR R Keys
      ['F']=			{LTR='3240', KEY='3243'}, --2 LTR R Keys
      ['I']=			{LTR='3240', KEY='3244'}, --3 LTR R Keys
      ['L']=			{LTR='3240', KEY='3246'}, --4 LTR R Keys
      ['O']=			{LTR='3240', KEY='3247'}, --5 LTR R Keys
      ['R']=			{LTR='3240', KEY='3248'}, --6 LTR R Keys
      ['U']=			{LTR='3240', KEY='3250'}, --7 LTR R Keys
      ['Y']=			{LTR='3240', KEY='3251'}, --8 LTR R Keys
      ['#']=			{LTR='3240', KEY='3252'}, --9 LTR R Keys
      }

      local function Typevalue(keytopress)
        if keys[keytopress] then
          if keys[keytopress].LTR ~='' then  --checks if the pressed key has a .LTR attribute. This works
            log('   Doing the letter thing') --tells me that it is typing a letter (so it will use both .LTR and .KEY attributes to do two keypresses, LTR_R/M/L first and the corresponding number key code after)
            clicOn(device, keys[keytopress].LTR, delay) --actually press the LTR_R/M/L button
            log('   DTLT clicked key '.. keys[keytopress].LTR) --tell me which one you've pressed
            clicOn(device, keys[keytopress].KEY, delay) --actually press the number button onthe keypad
            log('   DTLT clicked key '.. keys[keytopress].KEY) --tell me which you have pressed
          elseif (keys[keytopress].LTR =='' or keys[keytopress].LTR == nil) then --this did not work and caused the script to break (but resume happily). Changed to elseif to see if anything changes
            log('   Doing the NUMBER thing') 
            clicOn(device, keys[keytopress].KEY, delay)
            log('   ONLY clicked key '.. keys[keytopress].KEY)
          else
            log('   ...no joy, boss')
          end
        else
          log('Key ' .. keytopress .. ' does not exist in keys table')
        end
      end
  
    clicOn(device, 3236, delay, 0.05) -- set Display Sel to WP/TGT
    clicOn(device, 3235, delay, 0.04) -- set Mode Sel to LAT LON
    log('   initial DISP SEL and MODE SEL presses')
    --clicOn(device, keys['INC'].KEY, delay)  -- Select the next waypoint on the AN/ASN 128B
    --log('   initial INC press')

    for _,v in pairs(waypoints) do -- log the whole waypoint as read
      for i,iv in pairs(v) do
        log('   ' .. tostring(i) .. ": " .. tostring(iv))
      end

      clicOn(device, keys['INC'].KEY, delay)  -- Select the next waypoint on the AN/ASN 128B
      log('   initial INC press')

      -- WAYPOINT NAME - don't even know why I included this. 
      if v.name:len() > 0 then -- check if a name exists
        if (v.name:len() > 0 and v.name:len() <= 13) then compliantName=v.name
        elseif v.name:len() > 13 then -- check if the name is more than 13 digits
          compliantName=v.name:sub(1, 13) --shortens it to 13
        end
        log('   v.name: '..v.name) -- log the full name as taken from the scratchpad
        log('   13char name: '..compliantName) -- log the shortened stirng (so it fits on the display, I have a feeling the -60 would accept it anyways)
        clicOn(device, keys['KYBD'].KEY, delay)  -- Select the next field on the AN/ASN 128B -- Should be Name
        log('   clicked KYBD for name') --yeah please tell me wht you're doing
        for i = 1, compliantName:len() do --types the whole name, starting by iterating the string
          vv = compliantName:sub(i,i)   --iterates compliantName-s characters, one by one
          log('   vv '.. vv)  --tell me what are you reading?
          local k = string.upper(vv)  --converts what has been read to uppercase, otherwise it won't have a correspondence in the keys{} table
          log('   K ' .. k)   --shows the uppercase converted letter in the log
          Typevalue(k)  --calls the Typevalue function, which will press the corresponding key on the AN/ASN 128B
        end
        
        clicOn(device, keys['KYBD'].KEY, delay)  -- Select the next field on the AN/ASN 128B -- Should be Northing
        log('   clicked KYBD for northing')
        -- LAT (N/S) handling - refactor from A10 (maybe MGRS would be easier?)
        clicOn(device, keys['KYBD'].KEY, delay)  -- Select the next field on the AN/ASN 128B -- Should be Easting
        log('   clicked KYBD for easting')
        -- LON (E/W) handling refactor from A10 (maybe MGRS would be easier?)
        clicOn(device, keys['ENT'].KEY, delay)  -- Select the next field on the AN/ASN 128B -- Should be Out to the next
        log('   clicked ENT for saving pvt Ryan')

      end
    end
    doLoadCoords = true
  end)
  if not status then
      log("An error occurred: " .. err)
  end
end

--==================================================================================
function loadInAV8B(start,waypoints)
    inputBuffer = {}
    local isWP = true
    --                        0      1      2       3      4     5       6      7      8      9 
    local correspondance = {'3315','3302','3303','3304','3306','3307','3308','3310','3311','3312'}
    local delay = 350
    --[[
        L18 main menu
        L2 EHSD
        L2 DATA
        ODU-1 WPT
        UFC @wp_counter
        UFC ENTER
        ODU-2 POS
        UFC loop (ends on enter)
        ODU-3 ELEV
        alt loop (ends on enter)
        L2 DATA
    --]]
    log('>>>>>>>>>>>>> AV8B Load Start <<<<<<<<<<<<<<')
    clicOn(26,"3217",delay)   -- MCPD L18 - Main Menu
    log('[MCPD L18 - Main Menu]')
    clicOn(26,"3201",delay)   -- MCPD L2 -  EHSD
    log('[MCPD L2 -  EHSD]')
    clicOn(26,"3201",delay)   -- MCPD L2 -  DATA
    log('[MCPD L2 -  DATA]')
    local wpn = start - 1
    for i, v in ipairs(waypoints) do
      local swpn = ''
      if v.des == '#' then
        wpn = wpn + 1 
        swpn =  tostring(wpn)
        isWP = true
       log(string.format('>>>>> Using WP counter#: %s',swpn))
      else
        if string.sub(v.des,1,1) == 'T' then
          isWP = false
          swpn =  tostring(string.sub(v.des,2,string.len(v.des)))
          log(string.format('>>>>> Using WP des#: %s',swpn))      
        else
          isWP = true
          swpn =  tostring(v.des)
          log(string.format('>>>>> Using WP des#: %s',swpn))
        end
      end
      
      --log(string.format('>>>>> Load coords in WP#:%s',swpn))
      if not isWP then -- it is a targetPoint
        clicOn(24,"3250",delay)   --  ODU-1 WPT
        log('[ODU-1]')
        clicOn(24,"3250",delay)   --  ODU-1 WPT
        log('[ODU-1]')
      end
      
      for k = 1, swpn:len() do
        local ci = tonumber(swpn:sub(k,k))+1
        local btn =  correspondance[ci]
        clicOn(23,btn,delay) -- UFC number
        log(string.format('[UFC number: %s]',ci))
      end
      clicOn(23,"3314",delay) -- UFC ENTER
      log('[UFC ENTER]')
      clicOn(24,"3251",delay)   --  ODU-2 POS
      log('[ODU-2 POS]')

      for iii, digits in ipairs({v.lat,v.lon}) do
        for ii = 1,string.len(digits) do 
            local vv = string.sub(digits,ii,ii)
            if vv == "N" then 
                clicOn(23,"3303",delay)
                log('[UFC number: 2|N]')
            elseif  vv == "S" then 
                clicOn(23,"3311",delay)
                log('[UFC number: 8|S]')
            elseif vv == "E" then 
                clicOn(23,"3308",delay)
                log('[UFC number: 6|E]')
            elseif vv == "W" then                 
                clicOn(23,"3306",delay)
                log('[UFC number: 4|W]')
            elseif vv == "." then                 
                clicOn(23,"3316",delay)
                log('[UFC dot')                
            elseif ( vv == "'"  or vv == '"' or vv == "°"  or vv == " ") then 
              -- ignore
            else            
                local position = tonumber(vv)
                if position ~=nil then 
                    position = position+1
                    if (correspondance[position] ~= nil) then 
                        clicOn(23,correspondance[position],delay)
                        log(string.format('[UFC number: %s]',vv))
                    end
                end
            end
        end
          clicOn(23,"3314",delay) -- UFC ENTER
          log('[UFC ENTER]')
        end

        clicOn(24,"3252",delay)   --  ODU-3 ALT
        log('[ODU-3 ALT]')
        for ii = 1,string.len(v.alt) do 
            local vv = string.sub(v.alt,ii,ii)
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                  clicOn(23,correspondance[position],delay)
                  log(string.format('[UFC number: %s]',vv))
                end
            end
        end
        clicOn(23,"3314",delay) -- UFC ENTER
        log('[UFC ENTER]')

        clicOn(24,"3250",delay)   --  ODU-1 WPT
        log('[ODU-1]')
        if not isWP then -- it is a targetPoint
          clicOn(24,"3250",delay)   --  ODU-1 WPT
          log('[ODU-1')
        end
  

    end
    clicOn(26,"3201",delay)   -- MCPD L2 -  DATA
  --  log('[MCPD L2 -  DATA]')

    doLoadCoords = true
    --log('>>>>>>>>>>>>> AV8B Load END <<<<<<<<<<<<<<')
  end
--==================================================================================
function loadInF15E(start,waypoints,device)
  local deviceF15 = device --56
  local F15TimePress = 8 -- 15

  --log("in f15")

  local correspondances = {  --0 to 9
      '3036','3020','3021','3022','3025','3026','3027','3030','3031','3032'
  }
  
  local textCorrepondance = {  
      ['A'] = "3020",
      ['B'] = "3022",
      ['C'] = "3032",
      ['M'] = "3036",
      
}

  local commande = {
      ['accessSTR'] = "3010",
      ['shift'] = "3033", 
      ["changeWPT"] = "3001",
      ["addToLat"] = "3002",
      ["addToLong"] = "3003",
      ["addToAlt"] = "3007",
      ["north"] = "3021",
      ["south"] = "3031",
      ["east"] = "3027",
      ["west"] = "3025",
      ["CLR"] = "3035",
      ["Menu"] = "3038",
  }

  inputBuffer = {} 

  f15route = 'A'
  local l = string.len(start)
  local r = string.sub(start,l,l)
  if r == 'A' or r == 'B' or r == 'C' then
    f15route = r
    if l == 1 then
      start = 1
    else
      start = string.sub(start,1,l-1)
    end
  end
  
  f15Number = start - 1

  clicOn(deviceF15, commande.CLR, F15TimePress)
  clicOn(deviceF15, commande.CLR, F15TimePress)
  clicOn(deviceF15, commande.Menu, F15TimePress)

  clicOn(deviceF15, commande.accessSTR, F15TimePress)

  for i, v in ipairs(waypoints) do
      local wptPosition = ''
      if v.des == '#' then
        f15Number = f15Number + 1 
        wptPosition =  tostring(f15Number)..f15route
      --  log(string.format('>>>>> Using WP counter#: %s',wptPosition))
      elseif v.des == '#.' then
        f15Number = f15Number + 1 
        wptPosition =  tostring(f15Number)..'.'..f15route
      else
        wptPosition =  tostring(v.des)
    --    log(string.format('>>>>> Using WP des#: %s',wptPosition))
      end
   
      for ii = 1,string.len(wptPosition) do
          local vv = string.sub(wptPosition,ii,ii)
          if (vv == ".") then 
              clicOn(deviceF15, "3029",F15TimePress) -- targetpoint (dot)
          elseif (vv == "A") then 
            clicOn(deviceF15, commande.shift,F15TimePress)
            clicOn(deviceF15, textCorrepondance["A"],F15TimePress)        
          elseif (vv == "B") then 
            clicOn(deviceF15, commande.shift,F15TimePress)
            clicOn(deviceF15, textCorrepondance["B"],F15TimePress)  
          elseif (vv == "C") then 
            clicOn(deviceF15, commande.shift,F15TimePress)
            clicOn(deviceF15, textCorrepondance["C"],F15TimePress)      
          elseif (vv == "M") then 
            clicOn(deviceF15, commande.shift,F15TimePress)
            clicOn(deviceF15, textCorrepondance["M"],F15TimePress)               
          else 
              local position = tonumber(vv)
              if position ~=nil then 
                  position = position+1
                  if (correspondances[position] ~= nil) then 
                      clicOn(deviceF15,correspondances[position],F15TimePress)
                  end
              end
          end
      end

      clicOn(deviceF15, commande.changeWPT, F15TimePress)

      for iii, keys in ipairs({v.lat,v.lon,v.alt}) do
          for ii = 1, string.len(keys) do 
              local vv = string.sub(keys,ii,ii)
              if vv == "N" then 
                  clicOn(deviceF15, commande.shift,F15TimePress)
                  clicOn(deviceF15, commande.north,F15TimePress)
               --   log('>>>>> press N')
              elseif  vv == "S" then 
                  clicOn(deviceF15, commande.shift,F15TimePress)
                  clicOn(deviceF15, commande.south,F15TimePress)
              --    log('>>>>> press S')                    
              elseif vv == "E" then 
                  clicOn(deviceF15, commande.shift,F15TimePress)
                  clicOn(deviceF15, commande.east,F15TimePress)
               --   log('>>>>> press E')                    
              elseif vv == "W" then 
                  clicOn(deviceF15, commande.shift,F15TimePress)
                  clicOn(deviceF15, commande.west,F15TimePress)
               --   log('>>>>> press W')                    
              elseif(vv == "." or vv == "'"  or vv == '"' or vv == "°"  or vv == " ")  then 
              --    log('>>>>> ignored')
              else            
                  local position = tonumber(vv)
                  if position ~=nil then 
                      position = position+1
                      if (correspondances[position] ~= nil) then 
                          clicOn(deviceF15,correspondances[position],F15TimePress)
                 --         log('>>>>> press '..vv)
                      end
                  end
              end
          end
          if (iii == 1) then 
              clicOn(deviceF15, commande.addToLat,F15TimePress)
            --  log('>>>>> press LAT')
          elseif (iii == 2)  then 
              clicOn(deviceF15, commande.addToLong,F15TimePress)
            --  log('>>>>> press LONG')
          else 
              clicOn(deviceF15, commande.addToAlt,F15TimePress)
           --   log('>>>>> press ALT')
          end
      end
  end

  doLoadCoords = true
  
end
--==================================================================================
function loadInF18(start,waypoints)

    local indexCoords = {
        "lat","long"
    }
    inputBuffer = {}
    local correspondance = {'3018','3019','3020','3021','3022','3023','3024','3025','3026','3027'}
    clicOn(37,"3028",40) 
    clicOn(37,"3028",0)
    clicOn(37,"3012",0)
    clicOn(37,"3020",0)
   -- clicOn(37,"3022",20)
    for i, v in ipairs(waypoints) do
       -- clicOn(37,"3022",20)
        -- if firstInsertion then 
            -- clicOn(37,"3022",20)
            -- firstInsertion = false
        -- end

        clicOn(37,"3015",50)
        clicOn(25,"3010",50)
      
        for iii, digits in ipairs({v.lat,v.lon}) do
          for ii = 1,string.len(digits) do 
                local vv = string.sub(digits,ii,ii)
                if vv == "N" then 
                    clicOn(25,"3020",0)
                elseif  vv == "S" then 
                    clicOn(25,"3026",0)
                elseif vv == "E" then 
                    clicOn(25,"3024",0)
                elseif vv == "W" then 
                    clicOn(25,"3022",0)
                elseif (vv == "." or vv == "'") then 
                    clicOn(25,"3029",50)
                elseif (vv == '"' or vv == "°"  or vv == " ") then
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(25,correspondance[position],0)
                        end
                    end
                end
            end
        end

        clicOn(25,"3012",50)
        clicOn(25,"3010",50)
        for ii = 1,string.len(v.alt) do 
            local vv = string.sub(v.alt,ii,ii)
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(25,correspondance[position],0)
                end
            end
        end
        clicOn(25,"3029",40)

       clicOn(37,"3022",20)
    end
     clicOn(37,"3020",0)
    doLoadCoords = true
end
--==================================================================================
function loadInM2000(start,waypoints)
    inputBuffer = {}
    --local d35firstIns = true
    local correspondance = {'3593',     '3584','3585','3586','3587','3588','3589','3590','3591','3592'}
    log('>>>>>>>>>>>>> M-2000C Load Start <<<<<<<<<<<<<<')
    for i, v in ipairs(waypoints) do
        clicOn(9,"3574",10,0.4) -- INS_PARAM_SEL 3
        clicOn(9,"3570",10)
        clicOn(9,"3570",10)
        clicOn(9,"3584",10)
        for iii, digits in ipairs({v.lat,v.lon}) do
          for ii = 1,string.len(digits) do 
                local vv = string.sub(digits,ii,ii)
                if vv == "N" then 
                    clicOn(9,"3585",10)
                elseif vv == "E" then
                    clicOn(9,"3589",10)
                elseif vv == "S" then
                    clicOn(9,"3591",10)
                elseif vv == "W" then
                    clicOn(9,"3587",10)
                elseif vv == "'" then 
                    clicOn(9,"3596",10)
                    if iii == 1 then -- LAT
                        clicOn(9,"3586",10)
                    end
                elseif (vv == "."  or vv == '"' or vv == "°"  or vv == " " or vv == "'") then 
                else
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(9,correspondance[position],10)
                        end
                    end
                end
            end
        end
        clicOn(9,"3574",10,0.3)
        clicOn(9,"3584",10)
        clicOn(9,"3584",10)
        for ii = 1,string.len(v.alt) do 
            local vv = string.sub(v.alt,ii,ii)
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(9,correspondance[position],10)
                end
            end
        end
        clicOn(9,"3596",10)
        clicOn(9,"3110",10)   -- INS_NEXT_WP_BTN
    end 
    clicOn(9,"3574",10,0.4)
    
    doLoadCoords = true
end
--==================================================================================
function loadInF16(start,waypoints)
    inputBuffer = {}

    local correspondance = {'3002','3003','3004','3005','3006','3007','3008','3009','3010','3011','3027'}

    clicOn(17,"3032",20, -1)--ICP_DATA_RTN_SEQ_SW 0
    clicOn(17,"3006",10) --ICP_BTN_4
    local wpn = start - 1
    for i, v in ipairs(waypoints) do
        -- select wp
        local swpn = ''
        if v.des == '#' then
          wpn = wpn + 1 
          swpn =  tostring(wpn)
         log(string.format('>>>>> Using WP counter#: %s',swpn))
        else
           swpn =  tostring(v.des)
          log(string.format('>>>>> Using WP des#: %s',swpn))         
        end
        -- enter the wpn number
        for k = 1, swpn:len() do
          local ci = tonumber(swpn:sub(k,k))+1
          local btn =  correspondance[ci]
          clicOn(17,btn,10) -- UFC number
          log(string.format('[UFC number: %s]',ci))
        end
        clicOn(17,"3016",10) -- ENTER
        
        -- enter the coords
        clicOn(17,"3035",20,-1) -- ICP_DATA_UP_DN_SW 0
        clicOn(17,"3035",20,-1) -- ICP_DATA_UP_DN_SW 0

        for iii, digits in ipairs({v.lat,v.lon}) do
          for ii = 1,string.len(digits) do 
                local vv = string.sub(digits,ii,ii)
                if vv == "N" then 
                    clicOn(17,"3004",10)
                elseif  vv == "S" then 
                    clicOn(17,"3010",10)
                elseif vv == "E" then 
                    clicOn(17,"3008",10)
                elseif vv == "W" then 
                    clicOn(17,"3006",10)
                elseif (vv == "." or vv == "'"  or vv == '"' or vv == "°"  or vv == " ") then 
                else            
                    local position = tonumber(vv)
                    if position ~=nil then 
                        position = position+1
                        if (correspondance[position] ~= nil) then 
                            clicOn(17,correspondance[position],10)
                        end
                    end
                end
            end
            clicOn(17,"3016",10) -- ENTER
            clicOn(17,"3035",20,-1)
        end

        for ii = 1,string.len(v.alt) do 
            local vv = string.sub(v.alt,ii,ii)
            local position = tonumber(vv)
            if position ~=nil then 
                position = position+1
                if (correspondance[position] ~= nil) then 
                    clicOn(17,correspondance[position],10)
                end
            end
        end
        clicOn(17,"3016",10)
        clicOn(17,"3034",20)
        clicOn(17,"3034",20)
        clicOn(17,"3034",20)
        clicOn(17,"3034",20)

    end


    clicOn(17,"3032",20,-1)
    doLoadCoords = true

end
--==================================================================================
function loadInA10(start,waypoints)
    inputBuffer = {}

    local correspondances = {
        ['0']='3024',
        ['1']='3015',
        ['2']='3016',
        ['3']='3017',
        ['4']='3018',
        ['5']='3019',
        ['6']='3020',
        ['7']='3021',
        ['8']='3022',
        ['9']='3023',
        ['a']='3027',
        ['b']='3028',
        ['c']='3029',
        ['d']='3030',
        ['e']='3031',
        ['f']='3032',
        ['g']='3033',
        ['h']='3034',
        ['i']='3035',
        ['j']='3036',
        ['k']='3037',
        ['l']='3038',
        ['m']='3039',
        ['n']='3040',
        ['o']='3041',
        ['p']='3042',
        ['q']='3043',
        ['r']='3044',
        ['s']='3045',
        ['t']='3046',
        ['u']='3047',
        ['v']='3048',
        ['w']='3049',
        ['x']='3050',
        ['y']='3051',
        ['z']='3052',
    }

    -- go to the CDU screen, WPT Page
    for _, v in ipairs(waypoints) do
      if v.des ~= '#' then
        log('v.des: '..v.des) 
        for k = 1, v.des:len() do 
          clicOn(9,correspondances[v.des:sub(k,k)])
        end
        clicOn(9,'3001') --CDU_LSK_3L
      else
        log('No v.des')         
        clicOn(9,'3007')  -- CDU_LSK_7R        
      end

      if v.name:len()  > 0 then
        log('v.name: '..v.name) 
        for i = 1, v.name:len()  do 
          vv = v.name:sub(i,i)
          local value = string.lower(vv)
          clicOn(9,correspondances[value])
        end
        clicOn(9,'3005') -- CDU_LSK_3R"
      end

        for iii, digits in ipairs({v.lat,v.lon,v.alt}) do
          if iii == 1 then --lat
            log('v.lat: '..v.lat) 
          elseif iii == 2 then
            log('v.lon: '..v.lon) 
          else
            log('v.alt: '..v.alt)            
          end       

        
        for ii = 1,string.len(digits) do 
            local vv = string.sub(digits,ii,ii)
            if vv == "N" then 
                clicOn(9,'3040')
            elseif  vv == "S" then 
                clicOn(9,'3045')
            elseif  vv == "E" then
                clicOn(9,'3031')
            elseif  vv == "W" then
                clicOn(9,'3049')
            elseif (vv == '"' or vv == "°"  or vv == " " or vv == "." or vv == "'") then
            else
                local position = tonumber(vv)
                if position ~=nil then 
                    if (correspondances[tostring(position)] ~= nil) then 
                        clicOn(9,correspondances[tostring(position)])
                    end
                end
            end 
        end
        if iii == 1 then --lat
          clicOn(9,'3003') --CDU_LSK_7L
        elseif iii == 2 then --lon
          clicOn(9,'3004')--CDU_LSK_9L
        else -- alt
          clicOn(9,'3002')--CDU_LSK_5L            
        end
      end
      -- alt!
    end
    doLoadCoords = true

end
--==================================================================================       
function loadInApache(StartWaypoint,Waypoints,Seat)
  log('Apache 1')
  inputBuffer = {}  
  local devices = {}
  local keys = {}
  local MPD = Seat..'_LMPD'
  local KU = Seat..'_KU'

  do -- mapping
    devices['PLT_LMPD'] = 42
    devices['CPG_LMPD'] = 44
    devices['PLT_KU'] = 29
    devices['CPG_KU'] = 30

    keys['TSD'] = {code = '3029', delay = 500}
    keys['B6'] 	= {code = '3013', delay = 500}
    keys['L1'] 	= {code = '3024', delay = 500}
    keys['L2'] 	= {code = '3023', delay = 500}
    keys['L3'] 	= {code = '3022', delay = 500}
    keys['L4'] 	= {code = '3021', delay = 500}
    keys['L5'] 	= {code = '3020', delay = 500}
    keys['L6'] 	= {code = '3019', delay = 500}

    keys['A'] 		= {code = '3007', delay = 500}
    keys['B'] 		= {code = '3008', delay = 500}
    keys['C'] 		= {code = '3009', delay = 500}
    keys['D'] 		= {code = '3010', delay = 500}
    keys['E'] 		= {code = '3011', delay = 500}
    keys['F'] 		= {code = '3012', delay = 500}
    keys['G'] 		= {code = '3013', delay = 500}
    keys['H'] 		= {code = '3014', delay = 500}
    keys['I'] 		= {code = '3015', delay = 500}
    keys['J'] 		= {code = '3016', delay = 500}
    keys['K'] 		= {code = '3017', delay = 500}
    keys['L'] 		= {code = '3018', delay = 500}
    keys['M'] 		= {code = '3019', delay = 500}
    keys['N'] 		= {code = '3020', delay = 500}
    keys['O'] 		= {code = '3021', delay = 500}
    keys['P'] 		= {code = '3022', delay = 500}
    keys['Q'] 		= {code = '3023', delay = 500}
    keys['R'] 		= {code = '3024', delay = 500}
    keys['S'] 		= {code = '3025', delay = 500}
    keys['T'] 		= {code = '3026', delay = 500}
    keys['U'] 		= {code = '3027', delay = 500}
    keys['V'] 		= {code = '3028', delay = 500}
    keys['W'] 		= {code = '3029', delay = 500}
    keys['X'] 		= {code = '3030', delay = 500}
    keys['Y'] 		= {code = '3031', delay = 500}
    keys['Z'] 		= {code = '3032', delay = 500}
    keys['0'] 		= {code = '3043', delay = 500}
    keys['1'] 		= {code = '3033', delay = 500}
    keys['2'] 		= {code = '3034', delay = 500}
    keys['3'] 		= {code = '3035', delay = 500}
    keys['4'] 		= {code = '3036', delay = 500}
    keys['5'] 		= {code = '3037', delay = 500}
    keys['6'] 		= {code = '3038', delay = 500}
    keys['7'] 		= {code = '3039', delay = 500}
    keys['8'] 		= {code = '3040', delay = 500}
    keys['9'] 		= {code = '3041', delay = 500}
    keys['-'] 		= {code = '3047', delay = 500}   
    keys['CLR'] 	= {code = '3001', delay = 500}
    keys['ENTER'] = {code = '3006', delay = 500}  
    keys[' ']     = {code = '3003', delay = 500} 
    keys['.'] 		= {code = '3042', delay = 500}         
  end -- maping
  
  --set Right MPD
  clicOn(devices[MPD],keys['TSD'].code ,keys['TSD'].delay)  
  clicOn(devices[MPD],keys['B6'].code ,keys['B6'].delay)  
  -- Process waypoints
  log('Apache 2')
  for _,v in pairs(Waypoints) do
    clicOn(devices[MPD],keys['L2'].code ,keys['L2'].delay)  -- ADD
    local identType = 'W'
    local ident = 'WP'
    if string.upper(v.des) == '#' or string.upper(v.des) == 'W' then
      ident = 'WP'
      identType = 'W'
    elseif string.upper(v.des) == 'T' then
      ident = 'TG'     
      identType = 'T'
    elseif string.upper(v.des) == 'C' then
      ident = 'CP'   
      identType = 'C'
    elseif string.upper(v.des) == 'H' then
      ident = 'TU'  
      identType = 'H'
    end
     if string.len(v.des) == 2  then
      ident = string.upper(v.des)
      identType = 'W'
    end   
    if string.len(v.des) >= 3 then
      ident = string.sub(string.upper(v.des),2,3)
      identType = string.sub(string.upper(v.des),1,1)
    end

  if identType == 'W' then
     clicOn(devices[MPD],keys['L3'].code ,keys['L3'].delay)  -- IDENT
  elseif identType == 'H' then
     clicOn(devices[MPD],keys['L4'].code ,keys['L4'].delay)  -- IDENT
  elseif identType == 'C' then  
     clicOn(devices[MPD],keys['L5'].code ,keys['L5'].delay)  -- IDENT
  elseif identType == 'T' then
    clicOn(devices[MPD],keys['L6'].code ,keys['L6'].delay)  -- IDENT
  end

    clicOn(devices[MPD],keys['L1'].code ,keys['L1'].delay)  -- IDENT
    for i = 1,string.len(ident) do
      local K = string.sub(ident,i,i)
      clicOn(devices[KU],keys[K].code ,keys[K].delay)    
    end
    clicOn(devices[KU],keys['ENTER'].code ,keys['ENTER'].delay) -- for ident
    log('v.free:<'..v.free..'>')
    if v.free ~='' then
      for i = 1,string.len(v.free ) do
        local K = string.upper(string.sub(v.free,i,i))
        if keys[K] then
          clicOn(devices[KU],keys[K].code ,keys[K].delay)    
        else
          log('Apache key:"'..K..'" ignored')
        end
      end
    end
    clicOn(devices[KU],keys['ENTER'].code ,keys['ENTER'].delay) -- for free
    clicOn(devices[KU],keys['CLR'].code ,keys['CLR'].delay) -- clear UTM
    for i = 1,string.len(v.mgrs) do
      local K = string.upper(string.sub(v.mgrs,i,i))
      clicOn(devices[KU],keys[K].code ,keys[K].delay)    
    end
    clicOn(devices[KU],keys['ENTER'].code ,keys['ENTER'].delay) -- for UTM
    clicOn(devices[KU],keys['CLR'].code ,keys['CLR'].delay) -- clear ALT 
    for i = 1,string.len(v.alt) do
      local K = string.upper(string.sub(v.alt,i,i))
      clicOn(devices[KU],keys[K].code ,keys[K].delay)    
    end   
     clicOn(devices[KU],keys['ENTER'].code ,keys['ENTER'].delay) -- for ALT   
  end --for i,v in pairs(waypoints) do
  doLoadCoords = true
end -- function loadInApache

--==================================================================================

