local version=.10
local readme = [=[
# aeronautes msghist

This scratchpad extension saves each of the 3 types of DCS messages into their own buffers and displays them on command. The message low only be displayed if the name of the current scratchpad buffer is aeronautes-msghist.txt. Updates only occur on presses of the scratchpad UI buttons. You will need to scroll to the bottom of the buffer to see newest messages.

]=]

local lfs = require('lfs')

local Scratchdir = lfs.writedir() .. [[Scratchpad\]]
local Scratchpadfn = 'aeronautes-msghist.txt'
local TA = nil
local handler = {}

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
        log('aeronautespit setupfiles() open fail; ' .. res)
        return(nil)
    end
    infile:close()

end                             -- end setupfiles

setupfiles()

local hist = {}
hist.trigger = {enable = true, buf = '', idx = 0}
hist.chat = {enable = true, buf = '', idx = 0}
hist.radio = {enable = true, buf = '', idx = 0}
hist.active = nil

local function bufradd(arg, msg)
    local date = os.date('*t')
    local dateStr = string.format('[%i:%02i:%02i] ', date.hour, date.min, date.sec)
    arg.idx = arg.idx + 1
    arg.buf = arg.buf .. dateStr .. msg .. '\n'
end

local function msgupdate(bufnm)
    if switchPage(Scratchdir..Scratchpadfn) then
        TA:setText('')
        -- hardcoded 1MB file limit from scratchpad
        local buflen = string.len(hist[bufnm].buf)
        local txt = string.sub(hist[bufnm].buf, buflen - (1024*1024))
        TA:setText(bufnm..'\n'..txt)
        TA:insertBottom('')
        
        --[[    if switchPage(Scratchdir..Scratchpadfn) then
            TA:setText('')
        -- hardcoded 1MB file limit from scratchpad
        local buflen = string.len(bufr.buf)
        local txt = string.sub(bufr.buf, buflen - (1024*1024))
        TA:setText(txt)
        TA:insertBottom('')
--]]    
--        TA:setSelection(buflen)
--       DCS.unlockKeyboardInput(true)
    end
end

function handler.onChatMessage(message, from)
    local name = net.get_name(from)
    if name then
        message = name ..': '..message
    else
        message = 'nil name: '..message
    end
    
    bufradd(hist.chat, message)
--    msgupdate(hist.chat)
end

function handler.onTriggerMessage(message, duration, clearView)
    bufradd(hist.trigger, message)
--    msgupdate(hist.trigger)
end

function handler.onRadioMessage(message, duration)
    bufradd(hist.radio, message)
--    msgupdate(hist.radio)
end

function checkarg(a)
    if type(a) then
        return net.lua2json(a)
    else
        return 'nil'
    end
end

res = DCS.setUserCallbacks(handler)
log('setcallback '..type(res))

addButton(00, 00, 50, 30, 'chat', function(text)
              TA = text
              msgupdate('chat')
end)

addButton(60, 00, 50, 30, 'radio', function(text)
              TA = text
              msgupdate('radio')
end)

addButton(120, 00, 50, 30, 'trigger', function(text)
              TA = text
              msgupdate('trigger')
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
