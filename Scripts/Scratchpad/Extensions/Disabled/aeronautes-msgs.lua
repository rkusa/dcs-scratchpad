local version=.12
local readme = [=[
# aeronautes-msgs (amsgs) https://github.com/aeronautes/dcs-scratchpad

This scratchpad extension saves each of the 3 types of DCS messages
into their own buffers and displays them on command. The current
scratchpad buffer will switch to aeronautes-msgs.txt and the messages
will be displayed. Updates only occur on presses of the UI
buttons. The buffer will be scrolled to the bottom. When new messages
arrive the UI button will be updated with a * to indicate unread
messages. The indicator is cleared when the particular buffer is
displayed. The 'reset' button will clear all 3 types of message
buffers and clear the scratchpad for amsgs. The messages will be
cleared on mission load, so any messages from before joining
mission/server will be lost.

]=]

local lfs = require('lfs')

local Scratchdir = lfs.writedir() .. [[Scratchpad\]]
local Scratchpadfn = 'aeronautes-msgs.txt'
local TA = nil
local handler = {}
local dbglvl = 1

Loggr = {
    enable = true,
    linenum = 0,
    buf = '',
    add = function(self, msg)
        local date = os.date('*t')
        local dateStr = string.format("%i:%02i:%02i ", date.hour, date.min, date.sec)
        if not msg then
            msg = '""'
        end
        self.buf = self.buf .. dateStr  .. msg .. '\n'
        self.linenum = self.linenum + 1
        return
    end,
}

local function loglocal(str, lvl)
    if not lvl then
        lvl = 0
    else
        if type(lvl) == 'table' then
            if type(lvl.debug) == 'number' then
                log('loglocal() setting lvl '..dbglvl..'; '..lvl.debug)
                dbglvl = lvl.debug
                return
            end
        elseif type(lvl) ~= 'number' then
            log('loglocal() lvl not number; str: '..str)
            return
        end
    end

    if dbglvl > lvl then
        --        log(debug.getinfo(1,'n').name ..' '..str)
        log(str)
        Loggr.add(Loggr, str)
    end
end

function setupfiles()
    local fqfn = Scratchdir..Scratchpadfn
    local atr = lfs.attributes(fqfn)
    if atr and atr.mode == 'file' then
        return
    end
    log('apit setupfiles() creating '..Scratchpadfn)
    local infile, res
    infile, res = io.open(fqfn, 'w')
    if not infile then
        log('aeronautes-msgs setupfiles() open fail; ' .. res)
        return(nil)
    end
    infile:close()

end                             -- end setupfiles

setupfiles()

local hist = {}
function hist.init()
    hist.trigger = {enable = true, buf = '', idx = 0, button = nil}
    hist.chat =    {enable = true, buf = '', idx = 0, button = nil}
    hist.radio =   {enable = true, buf = '', idx = 0, button = nil}
    hist.active = nil
end
hist.init()
hist.currentbuf = nil


local function bufradd(arg, msg)
    local date = os.date('*t')
    local dateStr = string.format('[%i:%02i:%02i] ', date.hour, date.min, date.sec)
    arg.idx = arg.idx + 1
    arg.buf = arg.buf .. dateStr .. msg .. '\n'
    arg.panel.button:setText(string.upper(arg.panel.title))
end

local function showbuf(bufnm)
    if switchPage(Scratchdir..Scratchpadfn) then
        if bufnm and hist[bufnm] then
            local h = hist[bufnm]
            TA:setText('')
            -- hardcoded 1MB file limit from scratchpad
            local buflen = string.len(h.buf)
            local txt = string.sub(h.buf, buflen - (1024*1024))
            TA:setText(bufnm..'\n'..txt)
            TA:insertBottom('')
            hist.currentbuf = bufnm
            h.panel.button:setText(string.lower(h.panel.title))
        end
    end
end

function handler.onChatMessage(message, from)
    local name = net.get_name(from)
    if name then
        message = name ..': '..message
    end
    
    bufradd(hist.chat, message)
end

function handler.onTriggerMessage(message, duration, clearView)
    bufradd(hist.trigger, message)
end

function handler.onRadioMessage(message, duration)
    bufradd(hist.radio, message)
end

function handler.onMissionLoadEnd()
    hist.init()
    for i,j in pairs(panel) do
        hist[j.title].panel = j
    end
end

function checkarg(a)
    if type(a) then
        return net.lua2json(a)
    else
        return 'nil'
    end
end

res = DCS.setUserCallbacks(handler)

addButton(00, 00, 50, 30, 'chat', function(text)
              TA = text
              showbuf('chat')
end)

addButton(50, 00, 50, 30, 'radio', function(text)
              TA = text
              showbuf('radio')
end)

addButton(100, 00, 50, 30, 'trigger', function(text)
              TA = text
              showbuf('trigger')
end)

addButton(150, 00, 50, 30, 'help', function(text)
              TA = text
              if switchPage(Scratchdir..Scratchpadfn) then
                  TA:setText('')
                  -- hardcoded 1MB file limit from scratchpad
                  local buflen = string.len(readme)
                  if buflen > (1024 * 1024) then
                      loglocal('amsgs help buflen > 1MB: '..buflen)
                  end
                  local txt = 'version: '..version..'\n'..readme..'\nEOF'
                  txt = string.sub(txt, buflen - (1024*1024))
                  TA:setText(txt)
              end
end)

addButton(200, 00, 50, 30, 'reset', function(text)
              hist.init()
              if switchPage() == Scratchdir..Scratchpadfn then
                  TA:setText('')
              end
end)

--####################################################
          function oldcode()
addButton(00, 00, 50, 30, "JTAC", function(text)

              local fullfn = lfs.writedir() .. [[Logs\]] .. "msghist.log"
              local file = assert(io.open(fullfn, 'r'))
              local list = {}
              local outstr = ''
              local time, unit

              
              if not file then
                  log('DTC: open file fail; ' .. fullfn)
                  return(nil)
              end

              local line = file:read('*line')
              if not line then
                  log('DTC: read file fail; ' .. fullfn)
                  return(nil)
              end

              function matchpos(line)
                  local pat = '@ (%d%d %d%d%.%d%d%d)\'(%u)%s+(%d%d %d%d%.%d%d%d)\'(%u)'
                  return string.match(line, pat)
              end

              function cjtfmsg(line)
                  local tid, lat, north, lon, east
                  local newpat = '.+lasing new target, (.+%. CODE:.+). POSITION: '
                  local lostpat = '.+, target lost.$'
                  
                  tid = string.match(line, newpat)
                  lat, north, lon, east = matchpos(line)
                  if tid then
                      list[unit] = {time, tid, north, lat, east, lon}
                  elseif string.match(line, lostpat) then
                      if list[unit] then
                          local i,j
                          --	 print('looking for '..unit..' , '..list[unit][2])
                          for i, j in pairs(list) do
                              print('i: '..i..'j: '..type(j)) 
                              if i == unit then
                                  --	       print('remove found '..i..unit)
                                  break
                              end
                          end
                          table.remove(list, i)
                          --[[	 if list[unit] then
                              print('still there '..list[unit][1]..', '..list[unit][2])
                              end
                          --]]
                      end
                  else
                      log('cjtfmsg unhandled msg')
                  end
              end

              function jtacstat()
                  local pat = '^(cjtf_%w+),[^,]+,(.+)@'
                  local unit, tid, lat, north, lon, east
                  
                  print('jtacstat')
                  time = string.match(line, '^%[(%d+:%d+:%d+)%]')
                  line = file:read('*line')	-- skip empty line
                  line = file:read('*line')	-- read first jtac
                  while #line >0 do		-- until closing empty line
                      --      print(line)
                      local prefix = string.sub(line, 1, 5)
                      if prefix == 'cjtf_' then
                          unit, tid = string.match(line, pat)
                          if unit then
                              lat, north, lon, east = matchpos(line)
                              list[unit] = {time, tid, north, lat, east, lon}
                          else
                              log('jacstat failed to find unit')
                          end
                      elseif prefix == 'Visua' then
                          print(line)
                      end
                      line = file:read('*line')
                  end
                  print()
              end

              while line do
                  time, unit = string.match(line, '^%[(%d+:%d+:%d+)%] (cjtf_%w+),')
                  if unit then
                      cjtfmsg(line)
                  else
                      time = string.match(line, '^%[(%d+:%d+:%d+)%] JTAC STATUS:')
                      if time then
                          jtacstat()
                      end
                  end
                  
                  line = file:read('*line')
              end

              file:close()
              
              for i, j in pairs(list) do
                  outstr = outstr .. string.format('%s, %s, %s, %s %s, %s %s\n', i, j[1], j[2], j[3], j[4], j[5], j[6], j[7])
              end

              text:setText("")
              text:setText(outstr)
end)

addButton(60, 00, 50, 30, "LOG", function(text)
              local fullfn = lfs.writedir() .. [[Logs\]] .. "msghist.log"
              local file = assert(io.open(fullfn, 'r'))

              local lines = file:read('*a')
              text:setText("")
              -- hardcoded 1MB file limit from scratchpad
              text:setText(string.sub(lines, string.len(lines) - (1024*1024)))

              file:close()

end)

addButton(120, 00, 50, 30, "RSTLOG", function(text)
              local fullfn = lfs.writedir() .. [[Logs\]] .. "msghist.log"
              os.remove(fullfn)	
end)
end
