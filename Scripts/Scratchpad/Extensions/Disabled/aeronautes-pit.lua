lfs = require('lfs')
--UC = require('utils_common')

local domacro = {
   flag = true,
   idx = 1,
   ctr = 0,
   inp = {},
   listeneradded = false,
}

function card2num(result)
   result = string.gsub(result, "N ", "2")
   result = string.gsub(result, "E ", "6")
   result = string.gsub(result, "W ", "4")
   result = string.gsub(result, "S ", "8")
   return result
end

local debug = 2
local function loglocal(str)
   if debug > 1 then
      log(str)
   end
end

local kpfile = lfs.writedir() .. '\\kp.lua'
local unittype = ''
local kp = {}	-- keypad table for wp(), press() api
local ttlist = {} --tool tips from clicabledata.lua
local LT = {	-- per module customization for convenience api
   ['AV8BNA'] = {
      ['coordsType'] = {format = 'DMS', lonDegreesWidth = 3},
      ['wpentry'] = 'LATe$LONe',
      prewp = function() press('') end,
      midwp = function(result) return result end,
      postwp = function() press('') end,
   },
   ["F-16C_50"] = {
      ['coordsType'] = {format = 'DDM', lonDegreesWidth = 3},
      ['wpentry'] = 'LATedLONedALT', --llconvert = card2num,
      prewp = function() press('r4dd') end,
      midwp = function(result) return result end,
      postwp = function() press('euum') end,
   },
   ["FA-18C_hornet"] = {
      ['coordsType'] = {format = 'DDM', precision = 4},
      ['wpentry'] = 'daLAT LON cALT ',
      prewp = function() return end,
      midwp = function(result) return result end,
      postwp = function() return end,
   },
   ['Hercules'] = {
      ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
      ['wpentry'] = 'LATeLONf',
      prewp = function() press('w') end,
      midwp = function(result) return result end,
      postwp = function() return end,
   },
   ['Ka-50'] = {
      --      ['coordsType'] = {format = 'DDM', precision = 1, lonDegreesWidth = 3, showNegative = true},
      ['coordsType'] = {format = 'DDM', precision = 1, lonDegreesWidth = 3},
      ['wpentry'] = 'LATeLONe',
      prewp = function() press('nw1') end,
      midwp = function(result) return result end,
      postwp = function() press('o') end,
   },
}

LT['Ka-50_3'] = LT['Ka-50']

local function assignKP() 
   loglocal('assignKP begin')
   local function getTypeKP(unit)
      loglocal('getTypeKP begin')

      if unit == 'AV8BNA' then
	 return {
	    ['1'] = {ufc_commands.Button_1, 1, 1, devices.UFCCONTROL},
	    ['2'] = {ufc_commands.Button_2, 1, 1, devices.UFCCONTROL},
	    ['3'] = {ufc_commands.Button_3, 1, 1, devices.UFCCONTROL},
	    ['4'] = {ufc_commands.Button_4, 1, 1, devices.UFCCONTROL},
	    ['5'] = {ufc_commands.Button_5, 1, 1, devices.UFCCONTROL},
	    ['6'] = {ufc_commands.Button_6, 1, 1, devices.UFCCONTROL},
	    ['7'] = {ufc_commands.Button_7, 1, 1, devices.UFCCONTROL},
	    ['8'] = {ufc_commands.Button_8, 1, 1, devices.UFCCONTROL},
	    ['9'] = {ufc_commands.Button_9, 1, 1, devices.UFCCONTROL},
	    ['0'] = {ufc_commands.Button_0, 1, 1, devices.UFCCONTROL},
	    ['e'] = {ufc_commands.Button_ENT, 1, 1, devices.UFCCONTROL},
	    ['$'] = {ufc_commands.Button_4, 1, 1, devices.ODUCONTROL},
	    ['N'] = {ufc_commands.Button_2, 1, 1, devices.UFCCONTROL},
	    ['E'] = {ufc_commands.Button_6, 1, 1, devices.UFCCONTROL},
	    ['W'] = {ufc_commands.Button_4, 1, 1, devices.UFCCONTROL},
	    ['S'] = {ufc_commands.Button_8, 1, 1, devices.UFCCONTROL},
	 }
      elseif unit == 'F-16C_50' then
	 return {
	    ['0'] = {ufc_commands.DIG0_M_SEL, 1, 1, devices.UFC},
	    ['1'] = {ufc_commands.DIG1_T_ILS, 1, 1, devices.UFC},
	    ['2'] = {ufc_commands.DIG2_ALOW, 1, 1, devices.UFC},
	    ['3'] = {ufc_commands.DIG3, 1, 1, devices.UFC},
	    ['4'] = {ufc_commands.DIG4_STPT, 1, 1, devices.UFC},
	    ['5'] = {ufc_commands.DIG5_CRUS, 1, 1, devices.UFC},
	    ['6'] = {ufc_commands.DIG6_TIME, 1, 1, devices.UFC},
	    ['7'] = {ufc_commands.DIG7_MARK, 1, 1, devices.UFC},
	    ['8'] = {ufc_commands.DIG8_FIX, 1, 1, devices.UFC},
	    ['9'] = {ufc_commands.DIG9_A_CAL, 1, 1, devices.UFC},
	    ['N'] = {ufc_commands.DIG2_ALOW, 1, 1, devices.UFC},
	    ['E'] = {ufc_commands.DIG6_TIME, 1, 1, devices.UFC},
	    ['W'] = {ufc_commands.DIG4_STPT, 1, 1, devices.UFC},
	    ['S'] = {ufc_commands.DIG8_FIX, 1, 1, devices.UFC},
	    e = {ufc_commands.ENTR, 1, 1, devices.UFC},
	    p = {ufc_commands.DED_INC, 1, 1, devices.UFC},
	    m = {ufc_commands.DED_DEC, 1, 1, devices.UFC},
	    r = {ufc_commands.DCS_RTN, -1, 3, devices.UFC},
	    s = {ufc_commands.DCS_SEQ, -1, 3, devices.UFC},
	    u = {{ufc_commands.DCS_UP, 1, 3, devices.UFC},
	       {ufc_commands.DCS_UP, 0, 1, devices.UFC}},
	    d = {{ufc_commands.DCS_DOWN, -1, 3, devices.UFC}, 
	       {ufc_commands.DCS_DOWN, 0, 1, devices.UFC}}, 
	 }
      elseif unit == 'FA-18C_hornet' then
	 return {
	    ['0'] = {{UFC_commands.KbdSw0, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw0, 0, 10, devices.UFC},},
	    ['1'] = {{UFC_commands.KbdSw1, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw1, 0, 10, devices.UFC},},
	    ['2'] = {{UFC_commands.KbdSw2, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw2, 0, 10, devices.UFC},},
	    ['3'] = {{UFC_commands.KbdSw3, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw3, 0, 10, devices.UFC},},
	    ['4'] = {{UFC_commands.KbdSw4, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw4, 0, 20, devices.UFC},},
	    ['5'] = {{UFC_commands.KbdSw5, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw5, 0, 10, devices.UFC},},
	    ['6'] = {{UFC_commands.KbdSw6, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw6, 0, 10, devices.UFC},},
	    ['7'] = {{UFC_commands.KbdSw7, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw7, 0, 10, devices.UFC},},
	    ['8'] = {{UFC_commands.KbdSw8, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw8, 0, 10, devices.UFC},},
	    ['9'] = {{UFC_commands.KbdSw9, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw9, 0, 10, devices.UFC},},
	    ['N'] = {{UFC_commands.KbdSw2, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw2, 0, 10, devices.UFC},},
	    ['E'] = {{UFC_commands.KbdSw6, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw6, 0, 10, devices.UFC},},
	    ['W'] = {{UFC_commands.KbdSw4, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw4, 0, 10, devices.UFC},},
	    ['S'] = {{UFC_commands.KbdSw8, 1, 10, devices.UFC},
	       {UFC_commands.KbdSw8, 0, 10, devices.UFC},},
	    [' '] = {{UFC_commands.KbdSwENT, 1, 5, devices.UFC},
	       {UFC_commands.KbdSwENT, 0, 5, devices.UFC},},
	    a = {{UFC_commands.OptSw1, 1, 5, devices.UFC},
	       {UFC_commands.OptSw1, 0, 1, devices.UFC},},
	    b = {{UFC_commands.OptSw2, 1, 5, devices.UFC},
	       {UFC_commands.OptSw2, 0, 1, devices.UFC},},
	    c = {{UFC_commands.OptSw3, 1, 5, devices.UFC},
	       {UFC_commands.OptSw3, 0, 1, devices.UFC},},
	    d = {{UFC_commands.OptSw4, 1, 5, devices.UFC},
	       {UFC_commands.OptSw4, 0, 1, devices.UFC},x},
	    e = {{UFC_commands.OptSw5, 1, 5, devices.UFC},
	       {UFC_commands.OptSw5, 0, 1, devices.UFC},},
	    d = {{MDI_commands.MDI_PB_5, 1, 5, devices.MDI_LEFT},
	       {MDI_commands.MDI_PB_5, 0, 5, devices.MDI_LEFT},},
	 }
      elseif unit == 'Ka-50' or unit == 'Ka-50_3' then
	 return {
	    ['0'] = {device_commands.Button_1, 1, 1, devices.PVI},
	    ['1'] = {device_commands.Button_2, 1, 1, devices.PVI},
	    ['2'] = {device_commands.Button_3, 1, 1, devices.PVI},
	    ['3'] = {device_commands.Button_4, 1, 1, devices.PVI},
	    ['4'] = {device_commands.Button_5, 1, 1, devices.PVI},
	    ['5'] = {device_commands.Button_6, 1, 1, devices.PVI},
	    ['6'] = {device_commands.Button_7, 1, 1, devices.PVI},
	    ['7'] = {device_commands.Button_8, 1, 1, devices.PVI},
	    ['8'] = {device_commands.Button_9, 1, 1, devices.PVI},
	    ['9'] = {device_commands.Button_10, 1, 1, devices.PVI},
	    ['N'] = {device_commands.Button_1, 1, 1, devices.PVI},
	    ['E'] = {device_commands.Button_1, 1, 1, devices.PVI},
	    ['W'] = {device_commands.Button_2, 1, 1, devices.PVI},
	    ['S'] = {device_commands.Button_2, 1, 1, devices.PVI},
	    e = {device_commands.Button_18, 1, 1, devices.PVI}, --NAV Enter
	    w = {device_commands.Button_11, 1, 1, devices.PVI}, --NAV Waypoints
	    t = {device_commands.Button_17, 1, 1, devices.PVI}, --NAV Targets
	    n = {device_commands.Button_26, 0.2, 2, devices.PVI}, --NAV Master mode ent
	    o = {device_commands.Button_26, 0.3, 2, devices.PVI}, --NAV Master mode oper
	 }
      elseif unit == 'Hercules' then
	 return {
	    ['0'] = {CNI_MU.pilot_CNI_MU_KBD_0, 1, 3, devices.General},
	    ['1'] = {CNI_MU.pilot_CNI_MU_KBD_1, 1, 3, devices.General},
	    ['2'] = {CNI_MU.pilot_CNI_MU_KBD_2, 1, 3, devices.General},
	    ['3'] = {CNI_MU.pilot_CNI_MU_KBD_3, 1, 3, devices.General},
	    ['4'] = {CNI_MU.pilot_CNI_MU_KBD_4, 1, 3, devices.General},
	    ['5'] = {CNI_MU.pilot_CNI_MU_KBD_5, 1, 3, devices.General},
	    ['6'] = {CNI_MU.pilot_CNI_MU_KBD_6, 1, 3, devices.General},
	    ['7'] = {CNI_MU.pilot_CNI_MU_KBD_7, 1, 3, devices.General},
	    ['8'] = {CNI_MU.pilot_CNI_MU_KBD_8, 1, 3, devices.General},
	    ['9'] = {CNI_MU.pilot_CNI_MU_KBD_9, 1, 3, devices.General},
	    ['E'] = {CNI_MU.pilot_CNI_MU_KBD_E, 1, 3, devices.General},
	    ['N'] = {CNI_MU.pilot_CNI_MU_KBD_N, 1, 3, devices.General},
	    ['S'] = {CNI_MU.pilot_CNI_MU_KBD_S, 1, 3, devices.General},
	    ['W'] = {CNI_MU.pilot_CNI_MU_KBD_W, 1, 3, devices.General},
	    a = {CNI_MU.pilot_CNI_MU_SelectKey_001, 1, 3, devices.General}, --SelectKey 1; wp #
	    b = {CNI_MU.pilot_CNI_MU_SelectKey_002, 1, 3, devices.General}, --SelectKey 2; wp name
	    e = {CNI_MU.pilot_CNI_MU_SelectKey_005, 1, 3, devices.General}, --SelectKey 5; lat
	    f = {CNI_MU.pilot_CNI_MU_SelectKey_006, 1, 3, devices.General}, --SelectKey 6; lon
	    g = {CNI_MU.pilot_CNI_MU_SelectKey_007, 1, 3, devices.General}, --SelectKey 7; inc
	    h = {CNI_MU.pilot_CNI_MU_SelectKey_008, 1, 3, devices.General}, --SelectKey 8; dec
	    w = {CNI_MU.pilot_CNI_MU_NAV_CTRL, 1, 3, devices.General}, --NAV CTRL
	 }
      else
	 loglocal('assignKP unknown unit: '..unit)
	 return 
      end
   end

   local kpfile = lfs.writedir() .. 'Scripts\\Scratchpad\\Extensions\\lib\\kp.lua'
   local kpfun = ''
   local atr = lfs.attributes(kpfile)
   if atr and atr.mode == 'file' then
      loglocal('BAH: using kpfile '..kpfile)
      --[[
	 local kpfun, err = loadfile(kpfile)
	 if not kpfun then
	 loglocal("Error reading file `"..kpfile.."`: "..err)
	 return { }
	 end
      --]]
      --		kp = dofile(kpfile)
      assert(loadfile(kpfile))()
      loglocal('upload2 assignKP calling kpload() '..unittype)
      kp = kpload(unittype)
      loglocal('upload2 assignKP calling ltload() ')
      table.insert(LT, ltload())
      loglocal('BAH: done kpfile '..type(kp)..'; '..type(kpfun))
   else
      loglocal('BAH using builtin kp')
      kpfun = getTypeKP
      kp = kpfun(unittype)
   end
   loglocal('assignKP: done '..unittype..', '..type(kp))
   loglocal(net.lua2json(kp))
   loglocal(net.lua2json(LT))
end

local modname2dir = {}
function searchmodules()
   local moddir2name = {}

   function scandir(dir)
      --	loglocal('dir: '..dir)
      local total = 0
      for i,j in lfs.dir(dir) do
	 atr = lfs.attributes(dir..i)
	 if atr and atr.mode == 'directory' and 
	    i ~= '.' and i ~= '..' and i ~= 'Flaming Cliffs' then
	    moddir2name[i] = {['dir'] = dir..i}
	    total = total + 1
	 end
      end
      return total
   end

   local scandirtot = 0
   scandirtot = scandir(lfs.currentdir()..'Mods\\aircraft\\') --DCS install dir modules
   scandirtot = scandirtot + scandir(lfs.writedir()..'Mods\\aircraft\\')	 --Saved Games modules

   local modnametot = 0
   for i,j in pairs(moddir2name) do
      local fp = io.open(j.dir..'\\entry.lua')
      if fp then
	 for l in fp:lines() do
	    ut = string.match(l, [[^%w+_flyable[(]['"]([^'"]+)]]) 
	    if ut then
	       modname2dir[ut] = moddir2name[i]
	       modnametot = modnametot + 1
	       loglocal('upload2 searchmodules: added '..ut)
	    end
	 end
      else
	 loglocal('entry.lua not found, '.. j.dir)
      end
   end

   loglocal('upload2 searchmodules found: '..scandirtot..' named: '..modnametot)
end

searchmodules()
for i,j in pairs(modname2dir) do

   if not LT[i] then
      LT[i] = {}
   end
   LT[i].dirname = j.dir
   loglocal('upload2 cycle LT.dirname: '..i..' = '..LT[i].dirname)
end

function uploadinit()
   loglocal('init: begin')
   local newunittype = DCS.getPlayerUnitType()
   if newunittype == unittype then
      if not unittype then
	 loglocal('uploadinit: unittype already nil')
      else
	 loglocal('uploadinit: unittype already same, '..unittype)
      end
      return 
   end

   if unittype then
      loglocal('uploadinit type '..unittype)
   else
      loglocal('uploadinit nil')
   end
   if newunittype then
      loglocal('newunittype '..newunittype)
   else
      loglocal('newunittype nil')
   end
   unittype = newunittype
   if not unittype then
      loglocal('upload getPlayerUnitType nil, ')
      return
   end

   loglocal('cycle thru dirs,')
   for i,j in pairs(LT) do
      if LT[i].dirname then
	 loglocal('cycle dir: '..LT[i].dirname)
      else
	 loglocal('cycle missing dir: '..i)
      end
   end

   if not unittype then
      loglocal('upload2 init unittype nil')
      return
   end
   
   if not LT[unittype].dirname then 
      loglocal('upload2 init LT[].dirname undefined for '..unittype)
      return
   end
   local dirname = LT[unittype].dirname
   
   function checkfile(fn)
      atr = lfs.attributes(fn)
      if not atr then
	 loglocal('upload2 checkfile attributes nil, '..fn)
	 return
      end 	
      return true
   end

   --[[ 
      devices table in devices.lua
      _commands tables in command_defs.lua
      association of device and _commands in clickabledata.lua
   --]]

   --[[
      checkcockpitfile() is a kludge because the second arg to make_flyable() in
      entry.lua, should be parsed and the device files are not always defined to be in
      Cockpit/Scripts dir.
   --]]
   function checkcockpitfile(moddir, fn)
      local infn = moddir .."\\Cockpit\\Scripts\\" .. fn
      if not checkfile(infn) then
	 infn = moddir .."\\Cockpit\\" .. fn
	 if not checkfile(infn) then
	    return nil
	 else
	    return infn
	 end
      end
      return infn
   end
   
   local infn = dirname .."\\Cockpit\\Scripts\\command_defs.lua"
   --   if not checkfile(infn) then
   local infn = checkcockpitfile(dirname, 'command_defs.lua')
   if not infn then
      loglocal('upload2 init file not available, '.. infn)
      return
   end
   dofile(infn)
   
   --   infn = dirname .."\\Cockpit\\Scripts\\devices.lua"
   --   if not checkfile(infn) then
   infn = checkcockpitfile(dirname, 'devices.lua')
   if not infn then
      loglocal('upload2 init file not available, '.. infn)
      return
   end
   dofile(infn)

   -- parse clickabledata for tool tip names of cockpit controls
   --   infn = dirname .."\\Cockpit\\Scripts\\clickabledata.lua"
   --   if not checkfile(infn) then
   infn = checkcockpitfile(dirname, 'clickabledata.lua')
   if not infn then
      loglocal('upload2 init file not available, '.. infn)
      return
   end

   local infile = io.open(infn)
   if not infile then
      loglocal('upload2: open file fail; ' .. infn)
      return(nil)
   end

   local line = infile:read('*line')
   if not line then
      loglocal('upload2: read file fail; ' .. infn)
      return(nil)
   end

   local tt, dev, butn
   while line do
      tt, dev, butn = string.match(line, '^elements%[".+"%]%s*=.+%("(.+)"%)%s*,%s*([^,]+),%s*([^,]+)')
      if tt then
	 --	 loglocal(string.format('found a tt: %s, dev: %s, button: %s',tt, dev, butn))
	 ttlist[tt] = {device = dev, action = butn}
      end
      line = infile:read('*line')
   end
   infile:close()

   local ctr = 1
   for i,j in pairs(ttlist) do
      ctr = ctr + 1
   end
   
   assignKP()

   return unittype
end

function press(inp)
   if type(inp) ~= 'string' then
      loglocal('upload2 press: non string type, '..type(inp))
      return
   end
   
   for key in string.gmatch(inp, '.') do
      if kp[key] == nil then
	 loglocal("upload: press() nil " .. key)
	 return ""
      end
      if type(kp[key][1]) == 'table' then
	 a = kp[key]
	 for i,j in pairs(a) do
	    --loglocal('press: insert1 '..a[i][1]..', '..a[i][2])
	    table.insert(domacro.inp, a[i])
	 end
      else    
	 table.insert(domacro.inp, kp[key])
	 --loglocal('press: insert2 key '..key )
      end
   end
end

function waypointUFCMacro(result)
   result = convertformatCoords(result)
   --result = string.gsub(result, " ", "ed")
   result = midwp(result)
   --result = string.gsub(result, "[0123456789ed]", press)
   result = string.gsub(result, ".", press)

   postwp()
   return result .. "\n"
end

domacro.idx = 1
domacro.inp = {}

function push_stop_command(delay, c)
   loglocal('upload2: push_stop_command() start '..type(c))
   if c.device and c.action and c.value then
      loglocal('push_stop_command: dev '..c.device ..', action '.. c.action ..', val '.. c.value)
      if not c.len then
	 c.len = 10
      end
      table.insert(domacro.inp, {c.action, c.value, c.len, c.device})
   end
end

function TTtoDA(name, parms)
   parms = parms or {value = 1.0}
   
   loglocal('upload2 TTtoDA name: #'..name..'#')
   if type(ttlist[name]) == 'table' then

      for i, j in pairs(ttlist[name]) do
	 local getval = loadstring("return " .. j)
	 parms[i] = getval()
      end
      return parms
   end

   loglocal('upload2 TTtoDA not found')
   return nil
end

function tt(name, parms)
   local parms = parms or {value = 1.0}
   
   parms = TTtoDA(name, parms)
   if parms then
      loglocal('tt table: '..net.lua2json(parms))
      push_stop_command(0.1, parms)
   end
end

function ttn(name)
   tt(name, {value=1})
end
function ttf(name)
   tt(name)
   tt(name, {value=0})
end
function ttt(name)
   ttn(name)
   ttf(name)
end


function prewp(num)
   loglocal('prewp: ')
   if LT[unittype].prewp then
      LT[unittype].prewp()
   end
   loglocal('prewp 2: ')
end

function midwp(wpstr)
   loglocal('midwp: ')
   if LT[unittype].midwp then
      return LT[unittype].midwp(wpstr)
   end
   loglocal('midwp 2: ')
end

function postwp()
   loglocal('postwp: ')
   if LT[unittype].postwp then
      LT[unittype].postwp()
   end
   loglocal('postwp 2: ')
end

function wp(LLA)
   loglocal('wp: '..LLA)
   waypointUFCMacro(LLA)
end

function loadDTCBuffer(text)
   loglocal('loaddtcbuffer text len:'..string.len(text))
   local inf = loadstring(text)
   if not inf then
      loglocal('MAC loadstring failed: ' .. string.sub(text, 1, 40))
      return nil
   end

   env = {push_stop_command = push_stop_command,
	  push_start_command = push_stop_command,
	  prewp = prewp,
	  wp = wp,
	  press = press,
	  tt = tt,
	  ttn = ttn,
	  ttf = ttf,
	  ttt = ttt,
	  loglocal = loglocal,
   }
   setmetatable(env, {__index = _G})
   setfenv(inf, env)

   local ok, res = pcall(inf)
   if not ok then
      loglocal("Error executing mac: " .. string.sub(text, 1, 40))
      return nil
   end

   domacro.flag = true
end

addButton(0, 00, 50, 30, "ULbuf", function(textarea)
	     --	     local text = textarea:getText()
	     --	     loadDTCBuffer(text)
	     loadDTCBuffer(textarea:getText())
end)

function getCurrentLineOffsets(text, cur)

   local linestart = cur
   local lineend = cur
   local nl = string.byte("\n")

   for i = cur, 0, -1 do
      if text:byte(i) == nl then
	 break
      end
      linestart = linestart - 1
      if linestart == 0 then
	 break
      end
   end
   
   for i = cur + 1, #text do
      if text:byte(i) == nl then
	 break
      end
      lineend = lineend + 1
   end

   return linestart, lineend
end

addButton(60, 00, 50, 30, "ULsel", function(textarea)
	     local text = textarea:getText()
	     local start, end_ = getSelection()

	     if start == end_ then
		start, end_ = getCurrentLineOffsets(text, end_)
	     end
	     
	     sel = string.sub(text, start, end_)
	     
	     loglocal('ULsel len '..string.len(sel)..': #'..sel..'#')

	     local jtest = sel
	     jtest = string.gsub(jtest, "[']", '')
	     jtest = string.gsub(jtest, '°', ' ')
	     local lat, lon = string.match(jtest, '(%u %d%d +%d%d%.%d%d%d), (%u %d+ +%d%d%.%d%d%d)')

	     --for jtac coords
	     if lon then
		loglocal('ULsel: jtac position detected')
		local cType = coordsType(unittype)
		if cType then
		   if cType.precision then
		      delta = 3 - cType.precision
		      loglocal('ULsel jtac delta: '.. delta)
		      if delta > 0 then
			 loglocal('ULsel jtac precision: '..#lat)
			 lat = string.sub(lat, 1, #lat - delta)
			 lon = string.sub(lon, 1, #lon - delta)
			 loglocal('ULsel jtac precision2: '..#lat..' lat: '..lat)
		      end
		   end
		   if cType.lonDegreesWidth then
		      local east, londeg, lonmin = string.match(lon, '(%u) (%d+).(%d+%.%d+)')
		      local fmtstr = '%s %.'.. cType.lonDegreesWidth ..'d %s'
		      local newlon = string.format(fmtstr, east, londeg, lonmin)
		      loglocal(string.format('ULsel fmtstr: %s east: %s londeg: %s lonmin: %s, newlon: %s', fmtstr, east, londeg, lonmin, newlon))
		      lon = newlon
		   end
		end
		lat = string.gsub(lat, '[ .]', '')
		lon = string.gsub(lon, '[ .]', '')

		local newstr = "wp('"..LLtoAC(lat, lon, '0') .. "')"
		loglocal('ULsel jtac: '..lat ..' , '..lon..' , '..newstr)
		sel = newstr
	     end
	     
	     loglocal('glub2: '..sel)
	     loadDTCBuffer(sel)
end)

addButton(120, 00, 50, 30, "CANCEL", function(textarea)
	     domacro.inp = {}
	     domacro.idx = 1
	     domacro.flag = false
end)


-- WP getting/setting section
function convertformatCoords(result)
   if LT[unittype].llconvert then
      result = LT[unittype].llconvert(result)
      loglocal('convertformatCoords: llconvert '.. result)
   else
      result = string.gsub(result, "[Â°'%.\"]", "")
      loglocal('convertformatCoords: no llconvert '..result)
   end
   return result
end

function coordsType(unit)
   if LT[unit] and LT[unit].coordsType then
      return LT[unit].coordsType
   end

   loglocal('upload2 coordsType: not found in LT, '..unit)
end

function formatCoordConv(format, isLat, d, opts)
   local str = ''
   str = convertformatCoords(formatCoord(format, isLat, d, opts))
   --TH commentd for hornet   str = string.gsub(str, '%s+', '')	
   loglocal('formatCoordConv: '..str)
   return str
end

function LLtoAC(lat, lon, alt)
   local wpfmt = LT[unittype].wpentry
   loglocal('LLtoAC '..wpfmt..' lat: '..lat)
   str = string.gsub(wpfmt, 'LAT', lat)
   --   loglocal('ba: '..str)
   str = string.gsub(str, 'LON', lon)
   --   loglocal('ba2: '..str)
   str = string.gsub(str, 'ALT', alt)
   --   loglocal('ba3: '..str)
   str = convertformatCoords(str)
   loglocal('LLtoAC str: '..str)
   return str
end

function getloc()
   local Terrain = require('terrain')
   local pos = Export.LoGetCameraPosition().p
   local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
   local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
   --local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
   local ac = DCS.getPlayerUnitType()
   local types = coordsType(ac)
   
   LLtoAC(formatCoordConv(types.format, true, lat, types),
	  formatCoordConv(types.format, false, lon, types),
	  string.format("%.0f", alt*3.28084))
   
   return str
end

--start second row button
addButton(10, 30, 50, 30, "ULLL", function(text)
	     str = getloc()
	     loglocal('ULLL: '..str)

	     prewp()
	     wp(str)
	     domacro.flag = true
end)

addButton(70, 30, 50, 30, "WPLL", function(text)
	     text:insertBelow("wp('" .. getloc() .. "')")
end)

addButton(130, 30, 50, 30, "RELOAD", function(text)
	     loglocal('upload2: RELOAD click '..#LT)
	     assignKP()
end)

addFrameListener(function()
      if domacro.flag == true then
	 if domacro.ctr > 0 then
            domacro.ctr = domacro.ctr - 1
            return
	 end
	 if #domacro.inp == 0 then
            domacro.flag = false
            return
	 end
	 --[[
	    loglocal('addFrameListener: '..domacro.idx.."/"..#domacro.inp..'ctr: '..domacro.ctr)
	    --        loglocal('clock: '..os.clock())
	 --]]

	 i = domacro.idx
	 key = domacro.inp[i][1]
	 val = domacro.inp[i][2]
	 domacro.ctr = domacro.inp[i][3] 
	 device = domacro.inp[i][4]
	 loglocal('handler loop: '..i..":"..device..":" .. key ..":".. val..' #domacro.inp: '..#domacro.inp)
	 assert(Export.GetDevice(device):performClickableAction(key, val))
	 i = i + 1
	 if i > #domacro.inp then
	    domacro.inp = {}
	    domacro.idx = 1
	    domacro.flag = false
	 else
            domacro.idx = i
	 end
	 loglocal('handler loop2: i: '..i)
      end
end)
domacro.listeneradded = true    

addmissionLoadEndListener(function()
      loglocal('missionLoadEndListener start')
      if DCS.isMultiplayer() then
	 loglocal('MP')
	 local myid = net.get_my_player_id()
	 local handler = {}
	 function handler.onPlayerChangeSlot(id)
	    if id == myid then
	       uploadinit()
	    end
	 end
	 DCS.setUserCallbacks(handler)
      else
	 loglocal('SP')
	 if not uploadinit() then
	    local handler = {}
	    function handler.onSimulationResume()
	       uploadinit()
	    end
	    DCS.setUserCallbacks(handler)
	 end
      end
end)
