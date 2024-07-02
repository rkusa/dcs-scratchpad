local version=.63
local readme = [=[
# aeronautes-pit (Apit)

This is an extension to github.com/rkusa/scratchpad for DCS. At a high
level it provides the ability to configure your aircraft, assist with
mission planning and other automation tasks. There are some features
for specific capabilities, such as single button latlong input, as
well as a generalized environment for cockpit customization. At a low
level this extension provides a system to create, modify and execute
Lua code and access DCS's Lua client API. Some convenience features
provided on top of DCS's macro system let's you interact with all the
buttons, dials, switches and control in the cockpit without having to
look up the macro details. You can use this without any knowledge of
Lua or typing in any commands using it's base functionality available
as button clicks. If you want to do more, then modifying or creating
Lua code is an option.

## Installation

Unzip the github download into your Windows user `Saved Game`
directory. In order to enable an extension in scratchpad, the
extensions Lua file must be present in `Saved
Game\DCS.openbeta\Scripts\Scratchpad\Extensions\`. Copy the
aeronautes-pit.lua file from `Scripts\Scratchpad\Extensions\Disabled\`
directory to the parent `Scripts\Scratchpad\Extensions\' directory.

- Required file - aeronautes-pit.lua is necessary for base
  functionality. This needs to be copied from
  Scripts\Scratchpad\Extensions\Disabled\ to the parent Extensions\
  directory. On the next start of DCS you should see the apit menu
  buttons when scratchpad window is open. This is how scratchpad enables
  extensions.

- Optional files - For each DCS module an optional customization file,
  such as F-16C_50.lua, is searched for when slotting into the
  aircraft. Generally these are input commands that are grouped into
  functions. Examples of functions include 'start' to start the
  aircraft or 'mfd' to configure MFD pages. If no file is found the,
  base apit functionality is still available. These files are searched
  for in `Scripts\Scratchpad\Extensions\aeronautes-lib`

- Scratchpad page aeronautes-pit.txt is created in <Saved Games>\DCS\Scratchpad
  if it does not exist on DCS startup. Because the extension creates
  the file after scratchpad starts you will need to reload pages using
  the scratchpad reload key bind (ctrl-shift-r). If the file already
  exists you won't need the reload.
  This page is used when Apit needs to display text. For example when
  the user clicks on buttons such as log or mod, the content of those
  overwrite the aeronautes-pit page. You should not put anything onto
  this page that you want to keep around. That said the last contents
  of this page are saved to file when scratchpad switches to another
  page. You can go into the Scratchpad\ directory and copy that file
  if it hsa something you want to keep.

## Feature/Module matrix

This matrix shows apit features and the amount of DCS modules
supported by each.

                |    Module    |
                |   support    |
|    Feature    | All | Subset | Note |
|---------------|-----|--------|------|
| DCS macros    | X   |        |    1 |
| Convenience   | X   |        |    2 |
| Lua/DCS API   | X   |        |    3 |
| Waypoint      |     | X      |    4 |
| Customization |     | X      |    5 |

- 1. Automatic detection and configuration of devices[] and
  device.actions[] defined in the modules Cockpit\Scripts
  directory. Specifically API calls push_start_command() and
  push_stop_command() and their necessary arguments. These are
  automatically handled for any full fidelity module installed without
  need for user configuration.
  * All modules supported.

- 2. Convenience functions allow access to the cockpit devices without
  having to look up the codes in Lua. Instead you can use the tool
  tips to refer to the buttons and switches. These API calls include
  tt(), ttt(), etc. It's automatically configured based on the
  module's Cockpit\Scripts\clickabledata.lua.
  * All modules supported, paid or community provided the module includes
    a working clickabledata.lua.

- 3. DCS APIs as defined in DCS World OpenBeta\API\DCS_ControlAPI.html
  are available. The level of functionality and support is entirely up
  to ED. Lua is executed in a scratchpad page with `Buf` or `Sel` buttons.
  * All modules supported

- 4. Waypoint functions provide the ability input latlong and certain
  other input without having to know or program which specific buttons
  to press. These have been adapted for specific aircraft as each one
  has it's own particular sequence of input. The API for this includes
  wp(), wpseq(), press() and UI buttons `LL` and `wp`.
  * Waypoint input is currently supported for A-10C, AV8,
  F-15E, F-16C, FA-18C, Hercules, Ka-50/3, OH-58

- 5. Customizations are higher level capabilities that utilize any
  combination of the above features. These are separated per module in
  the Scripts\Scratchpad\Extensions\aeronautes-lib\ directory. The level of
  support and functions vary by module as apit updates are made. You
  can modify these yourself to make your own customizations for your
  aircraft. They can be utilized by clicking on the function buttons,
  `1`, `2`, ...
  * Customizations are provided for A-10C, AV8, F-15E, F-16C, FA-18C,
  Hercules, Ka-50/3, Mi-8, Mi-24.

## Installed File - Functionality map

'''
\Saved Game\DCS.openbeta\
        \Scratchpad\
        \Scripts\
                \Hooks\
                |        |(scratchpad-hook.lua)
                |
                \Scratchpad\
                        \Extensions\
                                |       |[aeronautes-pit.lua] - File copy from Disabled\
                                |
                                \Disabled\
                                |       |[aeronautes-pit.lua] - Core macro and convenience functionality
                                |
                                \aeronautes-lib\   - Optional module files for custom functions
                                        |[AV8NA.lua]
                                        |[F-15ESE.lua]
                                        |[F-16C_50.lua]
                                        |[FA-18C_hornet.lua]
                                        |[Mi-8MT.lua]
                                        |[kp.lua]
                                        |...
'''

## UI:

    The UI is comprised of the scratchpad buffer with the same name as
    the extension, aeronautes-pit. This buffer is used to display
    information such as module specific notes and custom lua or to
    show the help information. Anything in this buffer should not be
    considered permanent as the contents can be overwritten. If you
    want to save anything then place it in one of the other
    buffers. The UI also includes several rows of buttons. The first
    row contain buttons that interact with the cockpit or execute lua
    directly. The second row of buttons may output to the scratchpad
    buffer but dont affect the cockpit systems. The third and forth
    row of buttons are module specific functionality. The current
    module that you're slotted as is labeled as the left most button
    of the third row. Generically this is the 'mod' button but can be
    for example Hercules or F-16C_50. The forth row are dynamic
    buttons that are each associated with a module specific
    function. These functions are defined in the module customization
    file. The contents of the file can be viewed by pressing the 'mod'
    button.  Whenever apit is processing some lua the 'mod' will
    display a progress spinner. The progress spinner will indicate the
    current state of system input with the following symbols:

    - `-\|/` any instance of the lines to represent a rotating bar
      indicates the system is processing some input

    - `D` capital D indicates delay() was called. Once the amount of
      time requested for delay has passed the spinner should change to
      one of the previous indicators.

    Button labels that are capitalized will cause some type of input
    to the cockpit, `LatLon`, `Sel`, 'Buf', 'Cancel'. Those without
    capitalization do not cause cockpit input.

- `LatLon` - Using the camera's current location, the latlong is
  entered into the aircrafts coordinate input system. In F10 map view
  this is the location at center of the screen. In any other view,
  cockpit or external, it is the 3d location of the camera
  position. Some aircraft may have prerequisites before using
  `LatLon`. For example, F-18 currently requires Precise coordinates
  enabled. Per module notes should describe these requires and is
  viewable by pressing the button labeled with the name of the module,
  eg Hercules, F-16C_50. The default behavior upon click is for the
  sequencer to increment the current waypoint and enter latlong. The
  next click will carry out the same steps. You can modify this
  behavior using the wpseq() function(see below). You can also disable
  wpseq() to prevent any waypoint number change, leaving it up to you
  to set the correct number.

- `Sel` - This will take the current text selection as Lua. If no text
  is selected, then the current line the cursor is on is
  executed. This is a convenience feature to handle single line
  commands without the need to carefully highlight the line.

  This also has an added feature of detecting if the current line or
  selection matchs a DDM coordinate and will automatically enter the
  latlong into the aircrafts input panel if available. The format of
  the coordinate must be L NN°NN.NNN', L NNN°NN.NNN'. L = letter, N =
  number, single quote is optional, degree symbol can be replaced with
  one or more spaces. Altitude is not currently supported since the
  scratchpad `+L/L` is not the same across all modules. The format
  varies among the aircraft.

- `Buf` - This will attempt to execute everything in the current
  scratchpad page as a Lua script.

- `Cancel` - If the system is processing a series of cockpit inputs,
  this will stop and cancel any outstanding inputs remaining. If you
  reslot in the middle of a sequence, it will be canceled.

- `wp` - This works similarly to LL, but instead of directly entering
  the latlong, instead it will print the equivalent wp() command at
  the current cursor location in scratchpad. This is useful for
  building a mission plan that can be reused or passed along.

- `mod` - scratchpad will switch to the page named aeronautes-pit and

  overwrites the page with a copy of the module customization
  file. This is useful to see the module specific aeronautes-pit
  documentation as well as the code for the customization. This is
  useful if you want to see the startup sequence in checklist form,
  for example. The name of this button will change based on which
  module you've slotted into. Also this button will show a progress
  spinner when the extension is processing commands.

- `modload` - Convenience and customization code for the current
  aircraft are immediately reloaded and made available. This is useful
  if you are modifying or adding apit Customization files
  (Extensions\aeronautes-lib), or if you've messed up some certain values from a
  scratchpad page and want to reset using Customization file values.

- `log` - aeronautes-pit keeps a log of it's execution in a buffer.
  Clicking this button switches to the scratchpad page aeronautes-pit
  and overwrites it with the log.

- `loglvl` - This is used to increase the debug level of apit
  logging. Each click change the button label to indicate the level
  with a rollover to zero after 9.

- `help` - This will overwrite the aeronautes-pit scatchpad page with
  copy of the help section from the start of the aeronautes-pit.lua file.

- `1`, `2`,... - These dynamic function buttons provide one-click
  access to functions defined in the per module customization files in
  Scratchpad\Extensions\aeronautes-lib\<module>.lua. 

## apit API
    The Lua functions provided by apit are as follows:

    - push_start_command(int, {table}), push_stop_command() these
      calls are exactly the same format as those defined by ED and
      used in Macro_sequences.lua (the autostart/stop) for each
      aircraft. It doesn't matter which you use, start or stop. They
      perform the same. Apit currently supports a subset of the
      capability, devices, actions, delays, enough to in manipulate
      cockpit elements. It does not support conditionals that are
      defined in module DLL. Any supported calls are ignored. This
      means you should be able to take the modules Macro_sequences.lua
      and use them directly in apit. The F-16 apit customization
      function fence is built this way.

      Example for F16:

        push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.PwrSw, value = 1.0})
        push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.XmitSw, value = -1.0})

    - wp('string') enters a latlong into the modules keypad interface if
      available. It takes a string comprised of characters the
      correlate to device/actions used in push_stop_command(). The
      character mapping can be seen in the kp[] table.

      Example for F16:
        --janatabad
        wp('N 2814775edE 05638257ed3569')
        wp('N 3015749edE 05657384ed5746') --kerman rwy

    - wpseq({table}) interface for setting the next steerpoint number
      param is table with any number of following members. Default
      values in parens (). Generally the default behavior upon click
      of `LL` button is to increment the current waypoint, input
      latlong and stop. The next click will do the same,
      increment/enter LL/stop.

        * initialize = true/false (false) -- boolean that causes seq
          to default values

        * enable = true/false (true) -- disables sequencing while
          inputting latlongs

        * diff = number (1) -- the value to increment, can be negative
          or positive number. Zero will prevent any change of waypoint
          number while inputing. Zero value is useful if you want to
          manage the assignment of waypoint number yourself

        * cur = number (-1) -- this sets the starting waypoint number
          when wpseq() is executed. After that will be changed by the
          value of diff member if nonzero. Negative one, -1, will
          prevent wp() from attempting to set the starting wp, but
          will apply diff each time. You can set this to any value
          that is valid for the aircraft you are slotted in (F15 max
          99, F16 max 699) Behavior is determined in the LT[] table.

        * route = string ('') -- if the aircraft has a route naming
         aside from waypoint number, this member can be used to add
         the curr to indicate the waypoint and route you want to start
         at and increment/decrement next. Valid values are taken from
         the kp[] table for the particular DCS module(unittype). For
         example F15 has A,B,C,D.

        * menus = string ('') -- if you want to add extra inputs in
          the UFC/ICP of the aircraft you're in before the latlong
          entry. The values are derived from kp[] table and the same
          as those used for press()

      Example:
        wpseq({initialize=true}) -- reset values to default
        wpseq({enable=false})   -- disables any seqencing of subsequent waypoints

        sets the next instance of `LL` or wp() to set the waypoint to
        3.A, enter the latlong. After that next next wypt will be
        incremented and entered(4.A):

                wpseq({cur=3, diff=1, route='.A'})

    - press('string') lets you press an arbitrary sequence of buttons
      as defined in the kp table. press() can also be used to schedule
      functions during the input of controls. This is useful when
      combined with DCS api library to create conditional
      behavior. See Extensions\aeronautes-lib\F-15ESE customization to see how
      engines are spooled up using this.

      Example:

        enters 7.A in F15 scratchpad followed by push of UFC button 1:

                press('7.Aa')

        schedules the Customization function 'start' to run with
        argument 'engspool' after 1 second. This applies to F15E

                press('',{delay=1,fn=ft['start'],arg='engspool'})

    - tt('string') interface to cockpit interface associated with a tool tip

    - ttn('string') tool tip on, equivalent to tt(,{value=1})

    - ttf('string') tool tip off, equivalent to tt(,{value=0})

    - ttt('string') tool tip toggle, equivalent to ttn() ttf()

    - delay(number) delay in input for the scheduled sequence

    - loglocal('string', [number]) log message to the Logs\Scratchpad.log file

    - switchPage(pagename) When no argument is passed, returns a page
      record of current page of scratchpad. Otherwise pagename is the
      full path and filename of the scratchpad page you want to load,
      <Saved Game>\DCS\Scratchpad\<name>.txt. Returns nil on failure.

    - setitval(number) sets the base time interval in seconds between
      cockpit inputs. If you find some of your inputs are getting lost
      then you can start by extending this time until all your inputs
      are received. This time applies to all inputs. Some inputs can
      have extra time added per the kp[] table. Default .1 seconds

        Example:
        setitval(.2)
        loglocal(itval)  -- to see value of itval in Scratchpad.log

    - unittab[]

## Supported API
    Other APIs provided through apit:

    - scratchpad

    - DCS Lua environment -
        See C:\Program Files\Eagle Dynamics\DCS World OpenBeta\API

## Howto/FAQ

- Where are apit logging messages? Apit sends messages to the
  scratchpad log located in `Saved
  Games\DCS.openbeta\Logs\Scratchpad.log`. You can monitor this file
  by opening a powershell window, cd into the Logs directory and run
  this command, "Get-Content .\Scratchpad.log -wait". This will update
  as the file is written to.

- How to change log level? You can press the `log9` button to set
  the logging level to 9. This is intended for users who are not able
  to run the loglevel() function. Or you can run this command in a
  scratchpad page: "loglocal('',{debug=5})" while setting the 5 to any
  number you want. Generally zero 0 up to 9 for increasing verbosity
  is typical.

- How can I see the wpseq() settings? The waypoint sequencer values
  can be viewed when setting a value. If you just want to see current
  settings, invode wpseq() with no members, "wpseq({})". The results
  will be logged to Scratchpad.log.

## Acknowledgements

- https://github.com/rkusa for building a great platform and making it open source
- https://www.twitch.tv/aurora_juutilainen for early testing and feedback
- https://github.com/aronCiucu/DCSTheWay for insight into performClickableAction()
- hoggit #scripting discord a useful resource for any one developing for DCS
- https://github.com/asherao bailey's example of using setText() for panel widgets

]=]

local socket = require('socket')
lfs = require('lfs')

local domacro = {
    flag = true,
    idx = 1,
    ctr = 0,
    inp = {},
    listeneradded = false,
}

local Scratchdir = lfs.writedir() .. [[Scratchpad\]]
local Scratchpadfn = 'aeronautes-pit.txt'
local Apitlibsubdir = [[Scripts\Scratchpad\Extensions\aeronautes-lib\]]
local Apitlibdir = lfs.writedir() .. Apitlibsubdir

local dbglvl = 1
Hist = {
    enable = true,
    linenum = 0,
    buf = '',
    add = function(self, msg)
        local date = os.date('*t')
        local dateStr = string.format("%i:%02i:%02i ", date.hour, date.min, date.sec)
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
        Hist.add(Hist, str)
    end
end

local scratchpadver = 0         -- todo api framework versioning
local itval = 0.1               -- default input delay
local unittype = ''             -- DCS name for current module
local unittab = {}              -- table of module specific functions
local kp = {}                   -- keypad table for wp(), press() api
local ttlist = {}               -- tool tips from clicabledata.lua

-- butt vars below control the apit UI buttons created in scratchpad
local butts = {}
local buttfn = {} -- indirection funcs to bind to onClick by vary with assignCustom()
local buttfnamt = 10            -- number of assignable custom function buttons
local buttw = 50
local butth = 30
local panelbytitle = {}

local noticestr = ''
Spinr = {
    frames = {'/','|','\\','-'},
    idx = 1,
    buf = '',
    setPageNotice = function(str)
        if not str then
            str = 'UNSET'
        end

        if panelbytitle['mod'] then
            panelbytitle['mod'].button:setText(str)
        else
            loglocal('setPageNotice() no panel "mod"', 2)
        end
    end,
    run = function(self)
        if self.idx <= 1 then
            self.idx = #self.frames
        else
            self.idx = self.idx - 1
        end
        self.setPageNotice(self.frames[self.idx])
    end,
    rest = function(self)
        idx = 1
        if not unittype then
            self.setPageNotice('NO UNIT')
        else
            self.setPageNotice(string.sub(unittype, 1, 8))
        end
    end,
    delay = function(self)
        self.setPageNotice('D')
    end,
}

local function copytable(src)
    dst = {}
    for i, j in pairs(src) do
        dst[i] = j
    end
    return dst
end

-- wps vars control the waypoint input features
local wpsdefaults = {
    initialize = false,   --reset all values to defaults
    enable = true,        --disable STR number assignment
    diff = 1,             --next value of STR number relative to cur
    cur = -1,             --STR number to switch to before entering LL
    route = '',           --optional route can be any character from kp[]
    menus = '',  --optional menu keys to press() before any data entry
}
local wps = copytable(wpsdefaults) --waypoint sequence used by wp(); also initialized in uploadinit()

-- LT is the per module table for various configuration and wp specialization values/funcs
local LT = {           -- per module customization for convenience api
    ['A-10C'] = {
        ['notes'] = [[Waypoint input requires WAYPT menu, L/L mode. Default to LSK 7 to increment wp number]],
        ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
        ['wpentry'] = 'LAT#LON$ALT@',
        prewp = function()
            if wps.enable then
                if wps.diff ~= 0 then
                    press('&')
                end
            end
        end,
        postwp = function()
            if wps.enable and wps.cur ~= -1 then
                wps.cur = wps.cur + wps.diff
                if wps.cur < 1 then wps.cur = 2050 end -- rollover doesnt take modulus into account
                if wps.cur > 2050 then wps.cur = 1 end
                return
            end
        end,
        llconvert = function(result)
            result = string.gsub(result, '[°\'" .]', '')
            result = string.lower(result)
            return result
        end,
    },
    ['AV8BNA'] = {
        ['notes'] = [[Waypoint input requires DATA page. Adds new wp to the list.(wp #77)]],
        ['coordsType'] = {format = 'DMS', precision = 0, lonDegreesWidth = 3},
        ['wpentry'] = 'LATeLONe#ALTe',
        prewp = function()      -- currently only supporting incrementing or editing current wp
            if wps.enable then
                press('P77e@')
            end
        end,
    },
    ["F-15ESE"] = {
        ['notes'] = [[Waypoint input requires UFC be in point data submenu. WP sequncing supported.]],
        ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
        ['wpentry'] = 'LATbLONcALTg',
        prewp = function()
            if wps.enable then
                if wps.menus ~= '' then
                    loglocal('F15 prewp(): menus press() '..wps.menus, 3)
                    press(wps.menus)
                end
                if wps.cur > 0 then
                    local tmp = tostring(wps.cur)
                    if wps.route then
                        tmp = tmp .. wps.route..'a'
                    end
                    loglocal('F15 prewp(): cur press() '..tmp, 3)
                    press(tmp)
                else
                    loglocal('F15 prewp(): cur < 0 ',3)
                end
            end
            return
        end,
        postwp = function()
            if wps.enable and wps.cur ~= -1 then
                wps.cur = wps.cur + wps.diff
                if wps.cur < 1 then wps.cur = 99 end
                if wps.cur > 99 then wps.cur = 1 end
                return
            end
        end,
        llconvert = function(result)
            result = string.gsub(result, "[°'\".]", "")
            result = string.gsub(result, "([NEWS]) ", "%1")
            return result
        end,
    },
    ["F-16C_50"] = {
        ['notes'] = [[Waypoint input ]],
        ['coordsType'] = {format = 'DDM', lonDegreesWidth = 3},
        ['menus'] = 'r4',
        ['wpentry'] = 'LATedLONedALTe',
        prewp = function()
	    if wps.enable then
                if wps.menu ~= '' then
                    loglocal('F16 prewp(): menus press() '..wps.menus, 3)
                    press(wps.menus)
                end
		if wps.cur > 0 then
		    local tmp = tostring(wps.cur)
		    press(tmp..'edd')
		else -- cur is neg but diff is nonzero, hit up/down
		    if wps.diff > 0 then
			press('pdd')
		    elseif wps.diff < 0 then
			press('mdd')
		    end
		end
	    end
	end,
        postwp = function()
            press('dd')
	    if wps.enable and wps.cur ~= -1 then
                wps.cur = wps.cur + wps.diff
                if wps.cur < 1 then wps.cur = 699 end
                if wps.cur > 699 then wps.cur = 1 end
                return
            end
	end,
    },
    ["FA-18C_hornet"] = {
        ['notes'] = [[Waypoint input requires HSI DATA menu with precise. Default increments from the current waypoint. Increment or decrement controlled with wpseq({diff=})]],
        ['coordsType'] = {format = 'DDM', precision = 4},
        ['wpentry'] = 'faLAT LON caALT ',
        -- f18 can't select wpt by number, only cycle with arrows
        prewp = function()
            if wps.enable then
                if wps.diff > 0 then
                    press('g')
                elseif wps.diff < 0 then
                    press('h')
                end
            end
        end,
        postwp = function() return end,
        llconvert =function(result)
            result = string.gsub(result, "[°'\"]", "")
            result = string.gsub(result, "([NEWS]) ", "%1")
            result = string.gsub(result, "[.]", " ")
            return result
        end,
    },
    ['Hercules'] = {
        ['notes'] = [[Waypoint input sets the current point. No sequencing implented.]],
        ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
        ['wpentry'] = 'LATeLONfgh', -- inc/dec to activate in AFCS
        prewp = function() press('w') end,
        postload = function()   -- remap for community herc cockpit lua interface
            for i,j in pairs(ttlist) do
                ttlist[i].device=devices.Radios_control
                local act=string.gsub(j.action_nm, '([^%.]+%.)','')
                ttlist[i].action=devaction[act]
            end
        end,
    },
    ['Ka-50'] = {
        ['notes'] = [[Waypoint input starts at target 1 and increments. The WP type can be changed with wpseq({route=})]],
        ['coordsType'] = {format = 'DDM', precision = 1, lonDegreesWidth = 3},
        ['wpentry'] = 'LATeLONe',
        prewp = function(input)
            if wps.enable and string.sub(input,1,1) ~= 'n' then
                if wps.cur > -1 then
                    press('n'..wps.route..wps.cur)
                else
                    loglocal('Ka-50 prewp() invalid wps.cur: ',net.lua2json(wps))
                    return
                end
            end
        end,
        postwp = function()
            press('o')
            if wps.enable and wps.cur ~= -1 then -- increment even if prewp() gets specified wp('n')
                wps.cur = wps.cur + wps.diff
                if wps.cur < 1 then wps.cur = 9 end
                if wps.cur > 9 then wps.cur = 1 end
            end
        end,
    },
    ['OH58D'] = {
        ['notes'] = [[Waypoint input requires the New WP page and LatLon mode. Store MFD button automatically increments current wp number.]],
        ['coordsType'] = {format = 'DDM', precision = 2, lonDegreesWidth = 3},
        ['wpentry'] = '@~LAT_#~LON_$~ALT_)',
    },
} --end LT{}
LT['Ka-50_3'] = LT['Ka-50']

local function assignKP()
    loglocal('assignKP begin')
    local function getTypeKP(unit)
        loglocal('getTypeKP begin', 6)

--########## SNIP BEGIN for <Apitlibsubdir>\kp.lua
--function kpload(unit)
        local diffiv = 0
        if unit == 'A-10C' then
            return {
                ['1'] = {
                    {device_commands.Button_15, 1, diffiv, devices.CDU},
                    {device_commands.Button_15, 0, diffiv, devices.CDU}},
                ['2'] = {
                    {device_commands.Button_16, 1, diffiv, devices.CDU},
                    {device_commands.Button_16, 0, diffiv, devices.CDU}},
                ['3'] = {
                    {device_commands.Button_17, 1, diffiv, devices.CDU},
                    {device_commands.Button_17, 0, diffiv, devices.CDU}},
                ['4'] = {
                    {device_commands.Button_18, 1, diffiv, devices.CDU},
                    {device_commands.Button_18, 0, diffiv, devices.CDU}},
                ['5'] = {
                    {device_commands.Button_19, 1, diffiv, devices.CDU},
                    {device_commands.Button_19, 0, diffiv, devices.CDU}},
                ['6'] = {
                    {device_commands.Button_20, 1, diffiv, devices.CDU},
                    {device_commands.Button_20, 0, diffiv, devices.CDU}},
                ['7'] = {
                    {device_commands.Button_21, 1, diffiv, devices.CDU},
                    {device_commands.Button_21, 0, diffiv, devices.CDU}},
                ['8'] = {
                    {device_commands.Button_22, 1, diffiv, devices.CDU},
                    {device_commands.Button_22, 0, diffiv, devices.CDU}},
                ['9'] = {
                    {device_commands.Button_23, 1, diffiv, devices.CDU},
                    {device_commands.Button_23, 0, diffiv, devices.CDU}},
                ['0'] = {
                    {device_commands.Button_24, 1, diffiv, devices.CDU},
                    {device_commands.Button_24, 0, diffiv, devices.CDU}},
                ['a'] = {
                    {device_commands.Button_27, 1, diffiv, devices.CDU},
                    {device_commands.Button_27, 0, diffiv, devices.CDU}},
                ['b'] = {
                    {device_commands.Button_28, 1, diffiv, devices.CDU},
                    {device_commands.Button_28, 0, diffiv, devices.CDU}},
                ['c'] = {
                    {device_commands.Button_29, 1, diffiv, devices.CDU},
                    {device_commands.Button_29, 0, diffiv, devices.CDU}},
                ['d'] = {
                    {device_commands.Button_30, 1, diffiv, devices.CDU},
                    {device_commands.Button_30, 0, diffiv, devices.CDU}},
                ['e'] = {
                    {device_commands.Button_31, 1, diffiv, devices.CDU},
                    {device_commands.Button_31, 0, diffiv, devices.CDU}},
                ['f'] = {
                    {device_commands.Button_32, 1, diffiv, devices.CDU},
                    {device_commands.Button_32, 0, diffiv, devices.CDU}},
                ['g'] = {
                    {device_commands.Button_33, 1, diffiv, devices.CDU},
                    {device_commands.Button_33, 0, diffiv, devices.CDU}},
                ['h'] = {
                    {device_commands.Button_34, 1, diffiv, devices.CDU},
                    {device_commands.Button_34, 0, diffiv, devices.CDU}},
                ['i'] = {
                    {device_commands.Button_35, 1, diffiv, devices.CDU},
                    {device_commands.Button_35, 0, diffiv, devices.CDU}},
                ['j'] = {
                    {device_commands.Button_36, 1, diffiv, devices.CDU},
                    {device_commands.Button_36, 0, diffiv, devices.CDU}},
                ['k'] = {
                    {device_commands.Button_37, 1, diffiv, devices.CDU},
                    {device_commands.Button_37, 0, diffiv, devices.CDU}},
                ['l'] = {
                    {device_commands.Button_38, 1, diffiv, devices.CDU},
                    {device_commands.Button_38, 0, diffiv, devices.CDU}},
                ['m'] = {
                    {device_commands.Button_39, 1, diffiv, devices.CDU},
                    {device_commands.Button_39, 0, diffiv, devices.CDU}},
                ['n'] = {
                    {device_commands.Button_40, 1, diffiv, devices.CDU},
                    {device_commands.Button_40, 0, diffiv, devices.CDU}},
                ['o'] = {
                    {device_commands.Button_41, 1, diffiv, devices.CDU},
                    {device_commands.Button_41, 0, diffiv, devices.CDU}},
                ['p'] = {
                    {device_commands.Button_42, 1, diffiv, devices.CDU},
                    {device_commands.Button_42, 0, diffiv, devices.CDU}},
                ['q'] = {
                    {device_commands.Button_43, 1, diffiv, devices.CDU},
                    {device_commands.Button_43, 0, diffiv, devices.CDU}},
                ['r'] = {
                    {device_commands.Button_44, 1, diffiv, devices.CDU},
                    {device_commands.Button_44, 0, diffiv, devices.CDU}},
                ['s'] = {
                    {device_commands.Button_45, 1, diffiv, devices.CDU},
                    {device_commands.Button_45, 0, diffiv, devices.CDU}},
                ['t'] = {
                    {device_commands.Button_46, 1, diffiv, devices.CDU},
                    {device_commands.Button_46, 0, diffiv, devices.CDU}},
                ['u'] = {
                    {device_commands.Button_47, 1, diffiv, devices.CDU},
                    {device_commands.Button_47, 0, diffiv, devices.CDU}},
                ['v'] = {
                    {device_commands.Button_48, 1, diffiv, devices.CDU},
                    {device_commands.Button_48, 0, diffiv, devices.CDU}},
                ['w'] = {
                    {device_commands.Button_49, 1, diffiv, devices.CDU},
                    {device_commands.Button_49, 0, diffiv, devices.CDU}},
                ['x'] = {
                    {device_commands.Button_50, 1, diffiv, devices.CDU},
                    {device_commands.Button_50, 0, diffiv, devices.CDU}},
                ['y'] = {
                    {device_commands.Button_51, 1, diffiv, devices.CDU},
                    {device_commands.Button_51, 0, diffiv, devices.CDU}},
                ['z'] = {
                    {device_commands.Button_52, 1, diffiv, devices.CDU},
                    {device_commands.Button_52, 0, diffiv, devices.CDU}},
                ['!'] = {
                    {device_commands.Button_1, 1, diffiv, devices.CDU}, -- following 8 keys are LSK
                    {device_commands.Button_1, 0, diffiv, devices.CDU}},
                ['@'] = {
                    {device_commands.Button_2, 1, diffiv, devices.CDU},
                    {device_commands.Button_2, 0, diffiv, devices.CDU}},
                ['#'] = {
                    {device_commands.Button_3, 1, diffiv, devices.CDU},
                    {device_commands.Button_3, 0, diffiv, devices.CDU}},
                ['$'] = {
                    {device_commands.Button_4, 1, diffiv, devices.CDU},
                    {device_commands.Button_4, 0, diffiv, devices.CDU}},
                ['%'] = {
                    {device_commands.Button_5, 1, diffiv, devices.CDU},
                    {device_commands.Button_5, 0, diffiv, devices.CDU}},
                ['^'] = {
                    {device_commands.Button_6, 1, diffiv, devices.CDU},
                    {device_commands.Button_6, 0, diffiv, devices.CDU}},
                ['&'] = {
                    {device_commands.Button_7, 1, diffiv, devices.CDU},
                    {device_commands.Button_7, 0, diffiv, devices.CDU}},
                ['*'] = {
                    {device_commands.Button_8, 1, diffiv, devices.CDU},
                    {device_commands.Button_8, 0, diffiv, devices.CDU}},
            }
        elseif unit == 'AV8BNA' then
            return {
                ['1'] = {ufc_commands.Button_1, 1, diffiv, devices.UFCCONTROL},
                ['2'] = {ufc_commands.Button_2, 1, diffiv, devices.UFCCONTROL},
                ['3'] = {ufc_commands.Button_3, 1, diffiv, devices.UFCCONTROL},
                ['4'] = {ufc_commands.Button_4, 1, diffiv, devices.UFCCONTROL},
                ['5'] = {ufc_commands.Button_5, 1, diffiv, devices.UFCCONTROL},
                ['6'] = {ufc_commands.Button_6, 1, diffiv, devices.UFCCONTROL},
                ['7'] = {ufc_commands.Button_7, 1, diffiv, devices.UFCCONTROL},
                ['8'] = {ufc_commands.Button_8, 1, diffiv, devices.UFCCONTROL},
                ['9'] = {ufc_commands.Button_9, 1, diffiv, devices.UFCCONTROL},
                ['0'] = {ufc_commands.Button_0, 1, diffiv, devices.UFCCONTROL},
                ['e'] = {ufc_commands.Button_ENT, 1, diffiv, devices.UFCCONTROL},
                ['N'] = {ufc_commands.Button_2, 1, diffiv, devices.UFCCONTROL},
                ['E'] = {ufc_commands.Button_6, 1, diffiv, devices.UFCCONTROL},
                ['W'] = {ufc_commands.Button_4, 1, diffiv, devices.UFCCONTROL},
                ['S'] = {ufc_commands.Button_8, 1, diffiv, devices.UFCCONTROL},
                ['P'] = {mpcd_l_commands.Button_19, 1, diffiv, devices.MPCD_LEFT},
                ['!'] = {odu_commands.Button_1, 1, .25, devices.ODUCONTROL},
                ['@'] = {odu_commands.Button_2, 1, .25, devices.ODUCONTROL},
                ['#'] = {odu_commands.Button_3, 1, .25, devices.ODUCONTROL},
                ['$'] = {odu_commands.Button_4, 1, .25, devices.ODUCONTROL},
                ['%'] = {odu_commands.Button_5, 1, .25, devices.ODUCONTROL},
            }
        elseif unit == 'F-15ESE' then
            return {
                ['0'] = {
                    {ufc_commands.UFC_KEY__0, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY__0, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['1'] = {
                    {ufc_commands.UFC_KEY_A1, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['2'] = {
                    {ufc_commands.UFC_KEY_N2, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['3'] = {
                    {ufc_commands.UFC_KEY_B3, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['4'] = {
                    {ufc_commands.UFC_KEY_W4, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['5'] = {
                    {ufc_commands.UFC_KEY_M5, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['6'] = {
                    {ufc_commands.UFC_KEY_E6, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['7'] = {
                    {ufc_commands.UFC_KEY__7, 1, 0.20, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY__7, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['8'] = {
                    {ufc_commands.UFC_KEY_S8, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['9'] = {
                    {ufc_commands.UFC_KEY_C9, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['N'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['E'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['W'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['S'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['A'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['B'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['C'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['M'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 0, diffiv, devices.UFCCTRL_FRONT},},
                [' '] = {0, 0, diffiv, devices.UFCCTRL_FRONT},
                a = {
                    {ufc_commands.UFC_PB_1, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_1, 0, diffiv, devices.UFCCTRL_FRONT},},
                b = {
                    {ufc_commands.UFC_PB_2, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_2, 0, diffiv, devices.UFCCTRL_FRONT},},
                c = {
                    {ufc_commands.UFC_PB_3, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_3, 0, diffiv, devices.UFCCTRL_FRONT},},
                d = {
                    {ufc_commands.UFC_PB_4, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_4, 0, diffiv, devices.UFCCTRL_FRONT},},
                e = {
                    {ufc_commands.UFC_PB_5, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_5, 0, diffiv, devices.UFCCTRL_FRONT},},
                f = {
                    {ufc_commands.UFC_PB_6, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_6, 0, diffiv, devices.UFCCTRL_FRONT},},
                g = {
                    {ufc_commands.UFC_PB_7, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_7, 0, diffiv, devices.UFCCTRL_FRONT},},
                h = {
                    {ufc_commands.UFC_PB_8, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_8, 0, diffiv, devices.UFCCTRL_FRONT},},
                i = {
                    {ufc_commands.UFC_PB_9, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_9, 0, diffiv, devices.UFCCTRL_FRONT},},
                j = {
                    {ufc_commands.UFC_PB_0, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_0, 0, diffiv, devices.UFCCTRL_FRONT},},
                m = {
                    {ufc_commands.UFC_MENU, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_MENU, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['^'] = {
                    {ufc_commands.UFC_SHF, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['.'] = {
                    {ufc_commands.UFC_DOT, 1, diffiv, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_DOT, 0, diffiv, devices.UFCCTRL_FRONT},},
                ['_'] = {{0, 99, diffiv, 0}},
            }
        elseif unit == 'F-16C_50' then
            return {
                ['0'] = {ufc_commands.DIG0_M_SEL, 1, diffiv, devices.UFC},
                ['1'] = {ufc_commands.DIG1_T_ILS, 1, diffiv, devices.UFC},
                ['2'] = {ufc_commands.DIG2_ALOW, 1, diffiv, devices.UFC},
                ['3'] = {ufc_commands.DIG3, 1, diffiv, devices.UFC},
                ['4'] = {ufc_commands.DIG4_STPT, 1, diffiv, devices.UFC},
                ['5'] = {ufc_commands.DIG5_CRUS, 1, diffiv, devices.UFC},
                ['6'] = {ufc_commands.DIG6_TIME, 1, diffiv, devices.UFC},
                ['7'] = {ufc_commands.DIG7_MARK, 1, diffiv, devices.UFC},
                ['8'] = {ufc_commands.DIG8_FIX, 1, diffiv, devices.UFC},
                ['9'] = {ufc_commands.DIG9_A_CAL, 1, diffiv, devices.UFC},
                ['N'] = {ufc_commands.DIG2_ALOW, 1, diffiv, devices.UFC},
                ['E'] = {ufc_commands.DIG6_TIME, 1, diffiv, devices.UFC},
                ['W'] = {ufc_commands.DIG4_STPT, 1, diffiv, devices.UFC},
                ['S'] = {ufc_commands.DIG8_FIX, 1, diffiv, devices.UFC},
                ['L'] = {ufc_commands.LIST, 1, diffiv, devices.UFC},
                e = {ufc_commands.ENTR, 1, diffiv, devices.UFC},
                c = {ufc_commands.RCL, 1, diffiv, devices.UFC},
                p = {ufc_commands.DED_INC, 1, diffiv, devices.UFC},
                m = {ufc_commands.DED_DEC, 1, diffiv, devices.UFC},
                r = {
                    {ufc_commands.DCS_RTN, -1, diffiv, devices.UFC},
                    {ufc_commands.DCS_RTN, 0, diffiv, devices.UFC}},
                s = {
                    {ufc_commands.DCS_SEQ, -1, diffiv, devices.UFC},
                    {ufc_commands.DCS_SEQ, 0, diffiv, devices.UFC}},
                u = {
                    {ufc_commands.DCS_UP, 1, diffiv, devices.UFC},
                    {ufc_commands.DCS_UP, 0, 0, devices.UFC}},
                d = {
                    {ufc_commands.DCS_DOWN, -1, diffiv, devices.UFC},
                    {ufc_commands.DCS_DOWN, 0, 0, devices.UFC}},
            }
        elseif unit == 'FA-18C_hornet' then
            return {
                ['0'] = {
                    {UFC_commands.KbdSw0, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw0, 0, diffiv, devices.UFC},},
                ['1'] = {
                    {UFC_commands.KbdSw1, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw1, 0, diffiv, devices.UFC},},
                ['2'] = {
                    {UFC_commands.KbdSw2, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw2, 0, diffiv, devices.UFC},},
                ['3'] = {
                    {UFC_commands.KbdSw3, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw3, 0, diffiv, devices.UFC},},
                ['4'] = {
                    {UFC_commands.KbdSw4, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw4, 0, diffiv, devices.UFC},},
                ['5'] = {
                    {UFC_commands.KbdSw5, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw5, 0, diffiv, devices.UFC},},
                ['6'] = {
                    {UFC_commands.KbdSw6, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw6, 0, diffiv, devices.UFC},},
                ['7'] = {
                    {UFC_commands.KbdSw7, 1, 0.20, devices.UFC},
                    {UFC_commands.KbdSw7, 0, diffiv, devices.UFC},},
                ['8'] = {
                    {UFC_commands.KbdSw8, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw8, 0, diffiv, devices.UFC},},
                ['9'] = {
                    {UFC_commands.KbdSw9, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw9, 0, diffiv, devices.UFC},},
                ['N'] = {
                    {UFC_commands.KbdSw2, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw2, 0, diffiv, devices.UFC},},
                ['E'] = {
                    {UFC_commands.KbdSw6, 1, 1, devices.UFC},
                    {UFC_commands.KbdSw6, 0, 1, devices.UFC},},
                ['W'] = {
                    {UFC_commands.KbdSw4, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw4, 0, diffiv, devices.UFC},},
                ['S'] = {
                    {UFC_commands.KbdSw8, 1, diffiv, devices.UFC},
                    {UFC_commands.KbdSw8, 0, diffiv, devices.UFC},},
                [' '] = {
                    {UFC_commands.KbdSwENT, 1, 0.5, devices.UFC},
                    {UFC_commands.KbdSwENT, 0, 0.25, devices.UFC},},
                a = {
                    {UFC_commands.OptSw1, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw1, 0, 0.25, devices.UFC},},
                b = {
                    {UFC_commands.OptSw2, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw2, 0, 0.25, devices.UFC},},
                c = {
                    {UFC_commands.OptSw3, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw3, 0, 0.25, devices.UFC},},
                d = {
                    {UFC_commands.OptSw4, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw4, 0, 0.25, devices.UFC},},
                e = {
                    {UFC_commands.OptSw5, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw5, 0, 0.25, devices.UFC},},
                f = {
                    {AMPCD_commands.AMPCD_PB_5, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_5, 0, 0.25, devices.AMPCD},},
                g = {
                    {AMPCD_commands.AMPCD_PB_12, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_12, 0, 0.25, devices.AMPCD},},
                h = {
                    {AMPCD_commands.AMPCD_PB_13, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_13, 0, 0.25, devices.AMPCD},},
                ['_'] = {{0, 99, 1, 0}},
            }
        elseif unit == 'Ka-50' or unit == 'Ka-50_3' then
            diffiv = 0
            return {
                ['0'] = {
                    {device_commands.Button_1, 1, diffiv, devices.PVI},
                    {device_commands.Button_1, 0, diffiv, devices.PVI}},
                ['1'] = {
                    {device_commands.Button_2, 1, diffiv, devices.PVI},
                    {device_commands.Button_2, 0, diffiv, devices.PVI}},
                ['2'] = {
                    {device_commands.Button_3, 1, diffiv, devices.PVI},
                    {device_commands.Button_3, 0, diffiv, devices.PVI}},
                ['3'] = {
                    {device_commands.Button_4, 1, diffiv, devices.PVI},
                    {device_commands.Button_4, 0, diffiv, devices.PVI}},
                ['4'] = {
                    {device_commands.Button_5, 1, diffiv, devices.PVI},
                    {device_commands.Button_5, 0, diffiv, devices.PVI}},
                ['5'] = {
                    {device_commands.Button_6, 1, diffiv, devices.PVI},
                    {device_commands.Button_6, 0, diffiv, devices.PVI}},
                ['6'] = {
                    {device_commands.Button_7, 1, diffiv, devices.PVI},
                    {device_commands.Button_7, 0, diffiv, devices.PVI}},
                ['7'] = {
                    {device_commands.Button_8, 1, diffiv, devices.PVI},
                    {device_commands.Button_8, 0, diffiv, devices.PVI}},
                ['8'] = {
                    {device_commands.Button_9, 1, diffiv, devices.PVI},
                    {device_commands.Button_9, 0, diffiv, devices.PVI}},
                ['9'] = {
                    {device_commands.Button_10, 1, diffiv, devices.PVI},
                    {device_commands.Button_10, 0, diffiv, devices.PVI}},
                ['N'] = {
                    {device_commands.Button_1, 1, diffiv, devices.PVI},
                    {device_commands.Button_1, 0, diffiv, devices.PVI}},
                ['E'] = {
                    {device_commands.Button_1, 1, diffiv, devices.PVI},
                    {device_commands.Button_1, 0, diffiv, devices.PVI}},
                ['W'] = {
                    {device_commands.Button_2, 1, diffiv, devices.PVI},
                    {device_commands.Button_2, 0, diffiv, devices.PVI}},
                ['S'] = {
                    {device_commands.Button_2, 1, diffiv, devices.PVI},
                    {device_commands.Button_2, 0, diffiv, devices.PVI}},
                e = {
                    {device_commands.Button_18, 1, diffiv, devices.PVI}, --NAV Enter
                    {device_commands.Button_18, 0, diffiv, devices.PVI}},
                w = {
                    {device_commands.Button_11, 1, diffiv, devices.PVI}, --NAV Waypoints
                    {device_commands.Button_11, 0, diffiv, devices.PVI}},
                f = {
                    {device_commands.Button_13, 1, diffiv, devices.PVI}, --NAV Fixpnt
                    {device_commands.Button_13, 0, diffiv, devices.PVI}},
                a = {
                    {device_commands.Button_15, 1, diffiv, devices.PVI}, --NAV Airfield
                    {device_commands.Button_15, 0, diffiv, devices.PVI}},
                t = {
                    {device_commands.Button_17, 1, diffiv, devices.PVI}, --NAV Targets
                    {device_commands.Button_17, 0, diffiv, devices.PVI}},
                n = {
                    {device_commands.Button_26, 0.2, diffiv, devices.PVI}, --NAV Master mode ent
                    {device_commands.Button_26, 0.2, diffiv, devices.PVI}},
                o = {
                    {device_commands.Button_26, 0.3, diffiv, devices.PVI}, --NAV Master mode oper
                    {device_commands.Button_26, 0.3, diffiv, devices.PVI}},
            }
        elseif unit == 'Hercules' then
            return {
                ['0'] = {devaction.copilot_CNI_MU_KBD_0, 1, diffiv, devices.Radios_control},
                ['1'] = {devaction.copilot_CNI_MU_KBD_1, 1, diffiv, devices.Radios_control},
                ['2'] = {devaction.copilot_CNI_MU_KBD_2, 1, diffiv, devices.Radios_control},
                ['3'] = {devaction.copilot_CNI_MU_KBD_3, 1, diffiv, devices.Radios_control},
                ['4'] = {devaction.copilot_CNI_MU_KBD_4, 1, diffiv, devices.Radios_control},
                ['5'] = {devaction.copilot_CNI_MU_KBD_5, 1, diffiv, devices.Radios_control},
                ['6'] = {devaction.copilot_CNI_MU_KBD_6, 1, diffiv, devices.Radios_control},
                ['7'] = {devaction.copilot_CNI_MU_KBD_7, 1, diffiv, devices.Radios_control},
                ['8'] = {devaction.copilot_CNI_MU_KBD_8, 1, diffiv, devices.Radios_control},
                ['9'] = {devaction.copilot_CNI_MU_KBD_9, 1, diffiv, devices.Radios_control},
                ['E'] = {devaction.copilot_CNI_MU_KBD_E, 1, diffiv, devices.Radios_control},
                ['N'] = {devaction.copilot_CNI_MU_KBD_N, 1, diffiv, devices.Radios_control},
                ['S'] = {devaction.copilot_CNI_MU_KBD_S, 1, diffiv, devices.Radios_control},
                ['W'] = {devaction.copilot_CNI_MU_KBD_W, 1, diffiv, devices.Radios_control},
                a = {devaction.copilot_CNI_MU_SelectKey_001, 1, diffiv, devices.Radios_control}, --SelectKey 1 wp#
                b = {devaction.copilot_CNI_MU_SelectKey_diffiv, 1, diffiv, devices.Radios_control}, --SelectKey 2 name
                e = {devaction.copilot_CNI_MU_SelectKey_005, 1, diffiv, devices.Radios_control}, --SelectKey 5 lat
                f = {devaction.copilot_CNI_MU_SelectKey_006, 1, diffiv, devices.Radios_control}, --SelectKey 6 lon
                g = {devaction.copilot_CNI_MU_SelectKey_007, 1, diffiv, devices.Radios_control}, --SelectKey 7 inc
                h = {devaction.copilot_CNI_MU_SelectKey_008, 1, diffiv, devices.Radios_control}, --SelectKey 8 dec
                l = {devaction.copilot_CNI_MU_SelectKey_012, 1, diffiv, devices.Radios_control}, --SelectKey 12
                w = {devaction.copilot_CNI_MU_NAV_CTRL, 1, diffiv, devices.Radios_control}, --NAV CTRL
                x = {devaction.copilot_CNI_MU_INDEX, 1, diffiv, devices.Radios_control}, --INDEX
            }
        elseif unit == 'OH58D' then
            return {
                ['1'] = {
                    {device_commands.Button_6, 1, diffiv, devices.MFK},
                    {device_commands.Button_6, 0, diffiv, devices.MFK}},
                ['2'] = {
                    {device_commands.Button_7, 1, diffiv, devices.MFK},
                    {device_commands.Button_7, 0, diffiv, devices.MFK}},
                ['3'] = {
                    {device_commands.Button_8, 1, diffiv, devices.MFK},
                    {device_commands.Button_8, 0, diffiv, devices.MFK}},
                ['4'] = {
                    {device_commands.Button_9, 1, diffiv, devices.MFK},
                    {device_commands.Button_9, 0, diffiv, devices.MFK}},
                ['5'] = {
                    {device_commands.Button_10, 1, diffiv, devices.MFK},
                    {device_commands.Button_10, 0, diffiv, devices.MFK}},
                ['6'] = {
                    {device_commands.Button_11, 1, diffiv, devices.MFK},
                    {device_commands.Button_11, 0, diffiv, devices.MFK}},
                ['7'] = {
                    {device_commands.Button_12, 1, diffiv, devices.MFK},
                    {device_commands.Button_12, 0, diffiv, devices.MFK}},
                ['8'] = {
                    {device_commands.Button_13, 1, diffiv, devices.MFK},
                    {device_commands.Button_13, 0, diffiv, devices.MFK}},
                ['9'] = {
                    {device_commands.Button_14, 1, diffiv, devices.MFK},
                    {device_commands.Button_14, 0, diffiv, devices.MFK}},
                ['0'] = {
                    {device_commands.Button_15, 1, diffiv, devices.MFK},
                    {device_commands.Button_15, 0, diffiv, devices.MFK}},
                ['~'] = {
                    {device_commands.Button_17, 1, diffiv, devices.MFK}, -- clear
                    {device_commands.Button_17, 0, diffiv, devices.MFK}},
                ['_'] = {
                    {device_commands.Button_23, 1, diffiv, devices.MFK}, -- enter
                    {device_commands.Button_23, 0, diffiv, devices.MFK}},
                ['A'] = {
                    {device_commands.Button_25, 1, diffiv, devices.MFK},
                    {device_commands.Button_25, 0, diffiv, devices.MFK}},
                ['B'] = {
                    {device_commands.Button_26, 1, diffiv, devices.MFK},
                    {device_commands.Button_26, 0, diffiv, devices.MFK}},
                ['C'] = {
                    {device_commands.Button_27, 1, diffiv, devices.MFK},
                    {device_commands.Button_27, 0, diffiv, devices.MFK}},
                ['D'] = {
                    {device_commands.Button_28, 1, diffiv, devices.MFK},
                    {device_commands.Button_28, 0, diffiv, devices.MFK}},
                ['E'] = {
                    {device_commands.Button_29, 1, diffiv, devices.MFK},
                    {device_commands.Button_29, 0, diffiv, devices.MFK}},
                ['F'] = {
                    {device_commands.Button_30, 1, diffiv, devices.MFK},
                    {device_commands.Button_30, 0, diffiv, devices.MFK}},
                ['G'] = {
                    {device_commands.Button_31, 1, diffiv, devices.MFK},
                    {device_commands.Button_31, 0, diffiv, devices.MFK}},
                ['H'] = {
                    {device_commands.Button_32, 1, diffiv, devices.MFK},
                    {device_commands.Button_32, 0, diffiv, devices.MFK}},
                ['I'] = {
                    {device_commands.Button_33, 1, diffiv, devices.MFK},
                    {device_commands.Button_33, 0, diffiv, devices.MFK}},
                ['J'] = {
                    {device_commands.Button_34, 1, diffiv, devices.MFK},
                    {device_commands.Button_34, 0, diffiv, devices.MFK}},
                ['K'] = {
                    {device_commands.Button_35, 1, diffiv, devices.MFK},
                    {device_commands.Button_35, 0, diffiv, devices.MFK}},
                ['L'] = {
                    {device_commands.Button_36, 1, diffiv, devices.MFK},
                    {device_commands.Button_36, 0, diffiv, devices.MFK}},
                ['M'] = {
                    {device_commands.Button_37, 1, diffiv, devices.MFK},
                    {device_commands.Button_37, 0, diffiv, devices.MFK}},
                ['N'] = {
                    {device_commands.Button_38, 1, diffiv, devices.MFK},
                    {device_commands.Button_38, 0, diffiv, devices.MFK}},
                ['O'] = {
                    {device_commands.Button_39, 1, diffiv, devices.MFK},
                    {device_commands.Button_39, 0, diffiv, devices.MFK}},
                ['P'] = {
                    {device_commands.Button_40, 1, diffiv, devices.MFK},
                    {device_commands.Button_40, 0, diffiv, devices.MFK}},
                ['Q'] = {
                    {device_commands.Button_41, 1, diffiv, devices.MFK},
                    {device_commands.Button_41, 0, diffiv, devices.MFK}},
                ['R'] = {
                    {device_commands.Button_42, 1, diffiv, devices.MFK},
                    {device_commands.Button_42, 0, diffiv, devices.MFK}},
                ['S'] = {
                    {device_commands.Button_43, 1, diffiv, devices.MFK},
                    {device_commands.Button_43, 0, diffiv, devices.MFK}},
                ['T'] = {
                    {device_commands.Button_44, 1, diffiv, devices.MFK},
                    {device_commands.Button_44, 0, diffiv, devices.MFK}},
                ['U'] = {
                    {device_commands.Button_45, 1, diffiv, devices.MFK},
                    {device_commands.Button_45, 0, diffiv, devices.MFK}},
                ['V'] = {
                    {device_commands.Button_46, 1, diffiv, devices.MFK},
                    {device_commands.Button_46, 0, diffiv, devices.MFK}},
                ['W'] = {
                    {device_commands.Button_47, 1, diffiv, devices.MFK},
                    {device_commands.Button_47, 0, diffiv, devices.MFK}},
                ['X'] = {
                    {device_commands.Button_48, 1, diffiv, devices.MFK},
                    {device_commands.Button_48, 0, diffiv, devices.MFK}},
                ['Y'] = {
                    {device_commands.Button_49, 1, diffiv, devices.MFK},
                    {device_commands.Button_49, 0, diffiv, devices.MFK}},
                ['Z'] = {
                    {device_commands.Button_50, 1, diffiv, devices.MFK},
                    {device_commands.Button_50, 0, diffiv, devices.MFK}},
                ['!'] = {
                    {device_commands.Button_1, 1, diffiv, devices.RMFD}, -- these are pilot mfd L/R
                    {device_commands.Button_1, 0, diffiv, devices.RMFD}},
                ['@'] = {
                    {device_commands.Button_2, 1, diffiv, devices.RMFD},
                    {device_commands.Button_2, 0, diffiv, devices.RMFD}},
                ['#'] = {
                    {device_commands.Button_3, 1, diffiv, devices.RMFD},
                    {device_commands.Button_3, 0, diffiv, devices.RMFD}},
                ['$'] = {
                    {device_commands.Button_4, 1, diffiv, devices.RMFD},
                    {device_commands.Button_4, 0, diffiv, devices.RMFD}},
                ['%'] = {
                    {device_commands.Button_5, 1, diffiv, devices.RMFD},
                    {device_commands.Button_5, 0, diffiv, devices.RMFD}},
                ['^'] = {
                    {device_commands.Button_13, 1, diffiv, devices.RMFD}, --LAK R1
                    {device_commands.Button_13, 0, diffiv, devices.RMFD}},
                ['&'] = {
                    {device_commands.Button_14, 1, diffiv, devices.RMFD},
                    {device_commands.Button_14, 0, diffiv, devices.RMFD}},
                ['*'] = {
                    {device_commands.Button_15, 1, diffiv, devices.RMFD},
                    {device_commands.Button_15, 0, diffiv, devices.RMFD}},
                ['('] = {
                    {device_commands.Button_16, 1, diffiv, devices.RMFD},
                    {device_commands.Button_16, 0, diffiv, devices.RMFD}},
                [')'] = {
                    {device_commands.Button_17, 1, diffiv, devices.RMFD},
                    {device_commands.Button_17, 0, diffiv, devices.RMFD}},
            }
--########## SNIP END for kp.lua
        else
            loglocal('assignKP unknown unit: '..unit)
            return
        end
    end --end getTypeKP()

    -- support for optional kp.lua file used for adding or modifying wp for a DCS module
    local kpfile = Apitlibdir .. 'kp.lua'
    local kpfun = ''
    local atr = lfs.attributes(kpfile)
    if atr and atr.mode == 'file' then
        loglocal('aeronautespit: using kpfile '..kpfile)
        assert(loadfile(kpfile))()
        loglocal('aeronautespit assignKP calling kpload() '..unittype)
        kp = kpload(unittype)
        loglocal('aeronautespit assignKP calling ltload() ')
        table.insert(LT, ltload())
        loglocal('aeronautespit: done kpfile '..type(kp)..'; '..type(kpfun))
    else
        loglocal('aeronautespit using builtin kp')
        kpfun = getTypeKP
        kp = kpfun(unittype)
    end
    loglocal('assignKP() done '..unittype..', '..type(kp), 2)
    loglocal('assignKP() kp: '..net.lua2json(kp), 2)
    loglocal('assignKP() LT: '..net.lua2json(LT), 2)
end

function cancelmacro()
    loglocal('cancelmacro')
    domacro.inp = {}
    domacro.idx = 1
    domacro.flag = false
    Spinr:rest()
end

local modname2dir = {}
function searchmodules()
    local moddir2name = {}

    function scandir(dir)
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
    end                         -- end of scandir()

    local scandirtot = 0
    scandirtot = scandir(lfs.currentdir()..'Mods\\aircraft\\') --DCS install dir modules
    scandirtot = scandirtot + scandir(lfs.writedir()..'Mods\\aircraft\\')        --Saved Games modules

    local modnametot = 0
    for i,j in pairs(moddir2name) do
        local fp, res
        fp, res = io.open(j.dir..'\\entry.lua')
        if fp then
            for l in fp:lines() do
                ut = string.match(l, [[^%w+_flyable[(]['"]([^'"]+)]])
                if ut then
                    modname2dir[ut] = moddir2name[i]
                    modnametot = modnametot + 1
                    loglocal('aeronautespit searchmodules: added '..ut, 2)
                end
            end
        else
            loglocal('aeronautes-pit searchmodules open error: '.. res)
        end
    end

    loglocal('aeronautespit searchmodules found: '..scandirtot..' named: '..modnametot)
end                             -- end of searchmodules()

-- Begin main
loglocal('aeronautes-pit extension version: '..version)
loglocal('detected scratchpad version: '..scratchpadver)

function setupfiles()
    local fqfn = Scratchdir..Scratchpadfn
    local atr = lfs.attributes(fqfn)
    if atr and atr.mode == 'file' then
        return
    end
    loglocal('apit setupfiles() creating '..Scratchpadfn)
    local infile, res
    infile, res = io.open(fqfn, 'w')
    if not infile then
        loglocal('aeronautespit setupfiles() open fail; ' .. res)
        return(nil)
    end
    infile:close()

end                             -- end setupfiles

setupfiles()
searchmodules()
for i,j in pairs(modname2dir) do

    if not LT[i] then
        LT[i] = {}
    end
    LT[i].dirname = j.dir
    loglocal('aeronautespit cycle LT.dirname: '..i..' = '..LT[i].dirname, 2)
end

function press(inp, param)
    loglocal('press(): '..inp, 5)
    if type(inp) ~= 'string' then
        loglocal('aeronautespit press: non string type, '..type(inp))
        return
    end

    if param and param.fn then
        loglocal('press() fn '..DCS.getRealTime())
        table.insert(domacro.inp, {-1, -1, param.delay, -1, nil})
        table.insert(domacro.inp, {-1, -1, param.delay, -1, param.fn, param.arg})
    end
    for key in string.gmatch(inp, '.') do
        if kp[key] == nil then
            loglocal('upload: press() nil ' .. key, 6)
            return ''
        end
        if type(kp[key][1]) == 'table' then
            a = kp[key]
            local ctr = 0
            for i,j in pairs(a) do
                loglocal('press(): insert1 '..a[i][1]..', '..a[i][2], 5)
                table.insert(domacro.inp, a[i])
                ctr = ctr + 1
            end
        else
            loglocal('press(): insert2 key '..key, 5)
            table.insert(domacro.inp, kp[key])
        end
    end
    loglocal('press(): exit', 5)
end                             -- end of press()

function push_stop_command(itval, c)
    loglocal('aeronautespit: push_stop_command() start '..net.lua2json(c), 2)
    if c.device and c.action and c.value then
        loglocal('push_stop_command: device '..c.device ..', action '.. c.action ..', value '.. c.value..' fn '..type(c.fn)..' arg: '..type(c.arg), 2)
        if not c.len then c.len = itval end -- default to switch itval
        if not c.fn then c.fn = nil end
        table.insert(domacro.inp, {c.action, c.value, c.len, c.device, c.fn, c.arg})
    end
end                             -- end of push_stop_command()

-- TTtoDA() tool tip to device action lookup; merges parms with predfined ttlist
function TTtoDA(name, parms)
    local tmp = parms or {value = 1.0}

    loglocal('aeronautespit TTtoDA name: #'..name..'#'..net.lua2json(tmp), 4)
    if type(ttlist[name]) == 'table' then
        for i, j in pairs(ttlist[name]) do
            if not tmp[i] then
                tmp[i] = j
            end
        end
        return tmp
    end

    loglocal('aeronautespit TTtoDA not found: '..name)
    return nil
end                             -- end of TTtoDA()

-- tt() interface to cockpit interface associated with a tool tip; if
-- name is zero length or nil then assume usage without tooltip, all
-- params provided by caller
function tt(name, params)
    local tmp = params or {value = 1.0}

    if name and #name > 0 then
        tmp = TTtoDA(name, tmp)
        if not tmp then
            loglocal('tt() unknown name: '..name)
            return
        end
    end

    loglocal('tt table: '..net.lua2json(tmp), 4)
    push_stop_command(itval, tmp)

end

-- ttn() tool tip on, equivalent to tt(,{value=1})
function ttn(name, params)
    local tmp = params or {}
    tmp.value = 1
    tt(name, tmp)
end

-- ttf() tool tip off, equivalent to tt(,{value=0})
function ttf(name, params)
    local tmp = params or {}
    tmp.value = 0
    tt(name, tmp)
end

--ttt() tool tip toggle, equivalent to ttn() ttf()
function ttt(name, params)
    local tmp = params or {}

    tmp.value = tmp.onvalue or 1
    tt(name, tmp)

    tmp.value =  tmp.offvalue or 0
    tt(name, tmp)
end

-- delay() delay in input for the scheduled sequence
function delay(seconds)
    loglocal('delay: '..seconds)
    push_stop_command(0, {device = -1, action = -1, value = 0, len = seconds,
                          fn = function() Spinr:delay() end
    })
end

-- prewp() input sequence before entering latlong
function prewp(input)
    loglocal('prewp() unittype: '..unittype, 3)
    if LT[unittype].prewp then
        LT[unittype].prewp(input)
    end
    loglocal('prewp 2: ', 3)
end

-- midwp() input sequence during middle of latlong
function midwp(wpstr)
    loglocal('midwp: ', 6)
    if LT[unittype].midwp then
        return LT[unittype].midwp(wpstr)
    end
    loglocal('midwp 2: not defined', 6)
    return wpstr
end

--postwp() input sequence after latlong entered
function postwp()
    loglocal('postwp: ', 3)
    if LT[unittype].postwp then
        return LT[unittype].postwp()
    end
    loglocal('postwp 2: not defined', 6)
    return 
end

-- wpseq() interface for setting the next steerpoint number
function wpseq(param)
    loglocal('wpseq: '..net.lua2json(param), 3)
    for i, j in pairs(param) do
        if type(wps[i]) ~= nil then
            if type(wps[i]) == type(param[i]) then
                loglocal('wpseq set: '..i, 5)
                wps[i] = param[i]
            else
                loglocal('wpseq type mismatch: '..i..'-'..type(wps[i])..'-'..type(param[i]))
            end
        else
            loglocal('wpseq wps key not found: '..i)
        end
    end
    if wps.initialize then
        wps = copytable(wpsdefaults)
    end
    loglocal('wpseq end: '..net.lua2json(wps))
end

-- wp() interface for entering in a latlong for a particular aircraft
function wp(LLA, data)
    loglocal('wp: '..LLA, 3)
    prewp(LLA)

    local result = convertformatCoords(LLA)
    result = midwp(result)
    result = string.gsub(result, ".", press)

    postwp()

    return result .. "\n"
end

function apcall(p)     -- common pcall() for loadDTCBuffer and assignCustom
    local f, err
    loglocal('enter apcall', 4)
    if p.fn then
        local atr = lfs.attributes(p.fn)
        if atr and atr.mode == 'file' then
            f, err = loadfile(p.fn)
            if not f then
                loglocal('apcall() loadfile failed: '..err)
                return nil, err
            end
        else
            loglocal('apcall() not a file '..p.fn)
            return nil, err
        end
    elseif p.str then
        f, err = loadstring(p.str)
        if not f then
            loglocal('apcall() loadstring failed: '..err)
            return nil, err
        end
    else
        loglocal('apcall() unknown input p: '..type(p))
        return nil, err
    end

    local env = {}
    if not p.env then
        loglocal('apcall() p.env nil, default symbols')
        env = {push_stop_command = push_stop_command,
               push_start_command = push_stop_command,
               prewp = prewp,
               wp = wp,
               wpseq = wpseq,
               press = press,
               tt = tt,
               ttn = ttn,
               ttf = ttf,
               ttt = ttt,
               delay = delay,
               loglocal = loglocal,
               getSelection = getSelection,
               switchPage = switchPage,
        }
        setmetatable(env, {__index = _G})
    else
        env = p.env
    end
    setfenv(f, env)

    local ok, res = pcall(f)

    if not ok then
        loglocal('apcall() pcall error '..res)
        if p.str then
            loglocal("Error executing macro[first 40]: " .. string.sub(p.str, 1, 40))
        end
    end

    return ok, res

end                             -- end apcall

function loadDTCBuffer(text)
    loglocal('loaddtcbuffer text len:'..string.len(text))

    local env = {push_stop_command = push_stop_command,
           push_start_command = push_stop_command,
           prewp = prewp,
           wp = wp,
           wpseq = wpseq,
           press = press,
           tt = tt,
           ttn = ttn,
           ttf = ttf,
           ttt = ttt,
           delay = delay,
           setitval = function(newval)
               if type(newval) == 'number' then
                   itval = newval
               end
           end,
           itval = itval,
           dbglvl = dbgvlvl,
           kp = kp,
           loglocal = loglocal,
           unittab = unittab,
           ttlist = ttlist,
           panel = panel,
    }
    setmetatable(env, {__index = _G}) --needed to pickup all the
                                      --module macro definitions like
                                      --device/action

    local ok, res = apcall({str=text, env=env})
    if not ok then
        loglocal('loadDTCBuffer() fail pcall')
        return nil
    end

    domacro.flag = true
end                             -- end of loadDTCBuffer()

function assignCustom()
    local infn = Apitlibdir ..unittype..'.lua'
    loglocal('aeronautespit: using customfile '..infn, 1)
    for i,j in pairs(panel) do
        if string.match(j.title, '^%d+$') then
            j.button:setText(j.title)
            j.button:setVisible(false)
        end
        if not panelbytitle[j.title] then
            panelbytitle[j.title] = j
        end
    end

    local env = {push_stop_command = push_stop_command,
               push_start_command = push_stop_command,
               prewp = prew,
               wp = wp,
               wpseq = wpseq,
               press = press,
               tt = tt,
               ttn = ttn,
               ttf = ttf,
               ttt = ttt,
               delay = delay,
               loglocal = loglocal,
    }
    setmetatable(env, {__index = _G})     --needed to pickup all the
                                          --module macro definitions
                                          --like device/action
    local ok, res = apcall({fn=infn, env = env})

    if ok and res then
        unittab = res
        for i,j in pairs(buttfn) do
            buttfn[i] = nil
        end
        local idx = 0

        if not unittab then
            loglocal('assignCustom() res/unittab nil ')
            return
        end

        noticestr = ''
        for i,j in pairs(unittab) do
            if type(j) == 'function' then
                idx = idx + 1
                buttfn[idx] = j
                panelbytitle[tostring(idx)].button:setText(i)
                panelbytitle[tostring(idx)].button:setVisible(true)
            end
        end
        loglocal('assignCustom #unittab: '..#unittab ..': '.. unittype)
        Spinr:rest()

        if unittab['init'] and type(unittab['init']) == 'string' then
            loglocal('assignCustom() running unit init', 4)
            loadDTCBuffer(unittab['init'])
        end
    else
        loglocal('assignCustom apcall fail, res: '..type(res))
    end
end                             -- end of assignCustom()

function uploadinit()
    cancelmacro()               -- cancel if macro is in progress
    loglocal('uploadinit(): begin', 6)

    local newunittype = DCS.getPlayerUnitType()
    if newunittype == unittype then
        if not unittype then
            loglocal('uploadinit(): unittype already nil')
        else
            loglocal('uploadinit(): unittype already same, '..unittype)
            assignCustom()
        end
        return
    end

    Spinr:rest()
    if unittype then
        loglocal('uploadinit() type '..unittype)
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
        loglocal('uploadinit() getPlayerUnitType nil, ')
        return
    end


    loglocal('cycle thru modules,')
    for i,j in pairs(LT) do
        if LT[i].dirname then
            loglocal('uploadinit() cycle dir: '..LT[i].dirname)
        else
            loglocal('uplaodinit() cycle missing dir: '..i)
        end
    end

    if not unittype then
        loglocal('aeronautespit uploadinit() unittype nil')
        return
    end

    if not LT[unittype].dirname then
        loglocal('aeronautespit uploadinit() LT[].dirname undefined for '..unittype)
        return
    end
    local dirname = LT[unittype].dirname

    function checkfile(fn)
        atr = lfs.attributes(fn)
        if not atr then
            loglocal('aeronautespit uploadinit() checkfile attributes nil, '..fn)
            return
        end
        return true
    end

    --[[
        sources for macro defined variables: devices table in devices.lua
        _commands tables in command_defs.lua
        association of device and _commands in clickabledata.lua
    --]]

    --[[
        checkcockpitfile() is a workaround because the second arg to make_flyable() in
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
    local infn = checkcockpitfile(dirname, 'command_defs.lua')
    if not infn then
        loglocal('aeronautespit uploadinit() file not available, '.. infn)
        return
    end
    dofile(infn)

    infn = checkcockpitfile(dirname, 'devices.lua')
    if not infn then
        loglocal('aeronautespit uploadinit() file not available, '.. infn)
        return
    end
    dofile(infn)

    infn = checkcockpitfile(dirname, 'clickabledata.lua')
    if not infn then
        loglocal('aeronautespit uploadinit() file not available, '.. infn)
        return
    end

    local infile, res
    infile, res = io.open(infn)
    if not infile then
        loglocal('aeronautespit uploadinit() open file fail; ' .. res)
        return(nil)
    end

    local line = infile:read('*line')
    if not line then
        loglocal('aeronautespit uploadinit() read file fail; ' .. infn)
        return(nil)
    end

    --[[
    local function getval(cmd)
        loglocal('getval() '..cmd)
        local tmp = assert(loadstring('return '..cmd))
        if tmp then
            loglocal('getval tmp: '..tmp)
            return tmp
        else
            loglocal('getval() fail: '..cmd)
            return nil
        end
    end
    --]]

    local tt, dev, butn
    --TODO revise this temp code
    if unittype == 'Hercules' then -- temp accomodation for Herc which uses single device for all actions
        ttlist = {}
        while line do
            tt, butn = string.match(line, '^elements%[".+"%]%s*=.+%("(.+)"%s*,%s*([^, )]+)')
            if tt then
                local tstr, istr = string.match(butn,'([^.]+)\.(.+)')
                if not _G[tstr] or not _G[tstr][istr] then
                    loglocal('uploadinit herc _G not found '..tstr..' : '..istr)
                    return
                end
                ttlist[tt] = {device = devices['General'],
                              action = _G[tstr][istr],
                              device_nm = 'devices.General',
                              action_nm = butn,
                }
            end
            line = infile:read('*line')
        end
    else
        ttlist = {}
        while line do
            tt, dev, butn = string.match(line, '^elements%[".+"%]%s*=.+%("(.+)"%)%s*,%s*([^,]+),%s*([^,]+)')
            if tt then
                local tstr, istr -- table and index names
                tstr = string.match(dev,'[^.]+\.(.+)')

                if not devices[tstr] then
                    loglocal('uploadinit couldnt find device: '..line..' dev: '..dev.. ' type: '..type(dev))
                end
                ttlist[tt] = {device_nm = dev, action_nm = butn}
                ttlist[tt]['device'] = devices[tstr]

                local tstr, istr = string.match(butn,'([^.]+)\.(.+)')
                if not _G[tstr] or not  _G[tstr][istr] then
                    loglocal('uploadinit _G fail: '..tstr..' : '..istr)
                else
                    ttlist[tt]['action'] = _G[tstr][istr]
                end
            end
            line = infile:read('*line')
        end
    end
    infile:close()

    loglocal('uploadinit() before postload: '..net.lua2json(ttlist), 2)
    if type(LT[unittype].postload) == 'function' then
        loglocal('uploadinit() calling postload')
        LT[unittype].postload()
        loglocal('uploadinit() calling postload done')
    end
    loglocal('uploadinit() ttlist: '..net.lua2json(ttlist), 6)

    assignKP()
    wps = copytable(wpsdefaults)
    assignCustom()
    if panelbytitle['mod'] then
        panelbytitle['mod'].button:setText(string.sub(unittype,1, 8))
    end
    if not isHidden() then
        if switchPage() == Scratchdir..Scratchpadfn then
            showCustom(getTextarea())
        end
    end

    return unittype
end                             -- end of uploadinit()

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
end                             -- end of getCurrentLineOffsets()

local function handleSelection(TA)
        local text = TA:getText()
        local startp, endp, start, eos = getSelection()

        loglocal('handleSelection() sp: '..startp..' ep: '..endp..' start: '..start..' eos: '..eos)
        if start == eos then    -- if nothing is highlighted use the current line of cursor
            start, eos = getCurrentLineOffsets(text, eos)
        end

        sel = string.sub(text, start, eos)

        loglocal('Sel len: '..string.len(sel)..' start: '..start..' end: '..eos..': #'..sel..'#')

        local jtest = sel
        jtest = string.gsub(jtest, "[']", '')
        jtest = string.gsub(jtest, '°', ' ')
        local lat, lon = string.match(jtest, '(%u %d%d +%d%d%.%d+), (%u %d+ +%d%d%.%d+)')
        local altm, altft = string.match(jtest, '(%d+)m, +(%d+)ft')

        --for highlighted jtac coords
        if lon then
            loglocal('Sel: jtac position detected')
            local cType = coordsType(unittype)
            if cType then
                if cType.precision then
                    local delta = 3 - cType.precision
                    loglocal('Sel jtac delta: '.. delta)
                    if delta > 0 then
                        loglocal('Sel jtac precision: '..#lat)
                        lat = string.sub(lat, 1, #lat - delta)
                        lon = string.sub(lon, 1, #lon - delta)
                        loglocal('Sel jtac precision2: '..#lat..' lat: '..lat)
                    end
                end
                if cType.lonDegreesWidth then
                    local east, londeg, lonmin = string.match(lon, '(%u) (%d+).(%d+%.%d+)')
                    local fmtstr = '%s %.'.. cType.lonDegreesWidth ..'d %s'
                    local newlon = string.format(fmtstr, east, londeg, lonmin)
                    loglocal(string.format('Sel fmtstr: %s east: %s londeg: %s lonmin: %s, newlon: %s', fmtstr, east, londeg, lonmin, newlon))
                    lon = newlon
                end
            end
            lat = string.gsub(lat, '[ .]', '')
            lon = string.gsub(lon, '[ .]', '')
            if not altft then
                altft = '0'
            end

            local newstr = "wp('"..LLtoAC(lat, lon, altft) .. "')"
            loglocal('handleSelection() Sel jtac: LL: '..lat ..' , '..lon..' alt: '..altft..' , '..newstr)
            sel = newstr
        end

        loglocal('addButton Sel: '..sel)
        loadDTCBuffer(sel)
end                             -- end of handleSelection()

-- WP getting/setting section

function convertformatCoords(result)
    if LT[unittype].llconvert then
        result = LT[unittype].llconvert(result)
        loglocal('convertformatCoords: llconvert '.. result, 6)
    else
        result = string.gsub(result, "[Â°'%.\"]", "")
        loglocal('convertformatCoords: no llconvert '..result, 6)
    end
    return result
end

function coordsType(unit)
    if LT[unit] and LT[unit].coordsType then
        return LT[unit].coordsType
    end

    loglocal('aeronautespit coordsType: not found in LT, '..unit)
end

function formatCoordConv(format, isLat, d, opts)
    local str = ''
    str = convertformatCoords(formatCoord(format, isLat, d, opts))
    loglocal('formatCoordConv: '..str)
    return str
end

function LLtoAC(lat, lon, alt)
    local wpfmt = LT[unittype].wpentry
    loglocal('LLtoAC '..wpfmt..' lat: '..lat, 6)
    str = string.gsub(wpfmt, 'LAT', lat)
    str = string.gsub(str, 'LON', lon)
    str = string.gsub(str, 'ALT', alt)
    str = convertformatCoords(str)
    loglocal('LLtoAC str: '..str, 6)
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

function showCustom(TA)
    if switchPage(Scratchdir..Scratchpadfn) then
        local txt = ''
        local readtxt = ''
        if LT[unittype].notes then
            txt = LT[unittype].notes
        end
        if not TA then
            TA = getTextarea()
        end

        local infn = Apitlibdir..unittype..'.lua'
        local infile, res
        infile, res = io.open(infn,'r')
        if not infile then
            txt = txt .. '\nThis module, '..unittype..', has no custom file in '..Apitlibsubdir
            loglocal('aeronautespit mod open file fail; non critical' .. res)
        else
            readtxt = infile:read('*all')
            infile:close()
            if not readtxt then
                loglocal('aeronautespit mod read error; ' .. infn)
            else
                txt = txt .. '\n\n-- COPY of '..Apitlibsubdir..unittype..'.lua\n'..readtxt
            end
        end

        TA:setText('')
        -- hardcoded 1MB file limit from scratchpad
        local buflen = string.len(txt)
        if buflen > (1024 * 1024) then
            txt = string.sub(txt, 0, (1024*1024)-80) --limit 1 MB worth
            txt = txt ..'<<< File too big for scratchpad. Displaying truncated to 1MB >>>'
            loglocal('apit mod buflen > 1MB: '..buflen)
        end

        TA:setText(txt)
    end
end                             -- end showCustom()

function createbuttons()
    local numbutts = 10
    local rowh = 0

    local buttx = 0
    for i=1, 4 do             -- first row are macro execution related
        butts[i] = {buttx, rowh, buttw, butth}
        buttx = buttx + buttw
    end

    rowh = rowh + butth
    buttx = 0
    for i=5, 8 do -- second row modify Scratchpadfn buffer or other function
        butts[i] = {buttx, rowh, buttw, butth}
        buttx = buttx + buttw
    end

    rowh = rowh + butth
    buttx = 0
    buttw = buttw + 20
    for i=9, 10 do              -- third row
        butts[i] = {buttx, rowh, buttw, butth}
        buttx = buttx + buttw
    end

    butts[1][5] = 'LatLon'
    butts[1][6] = function()
        str = getloc()
        loglocal('aeronautespit: button LL: '..str)
        wp(str)
        domacro.flag = true
    end

    butts[2][5] = 'Sel'
    butts[2][6] = function(TA)
        handleSelection(TA)
    end

    butts[3][5] = 'Buf'
    butts[3][6] = function(TA)
        loadDTCBuffer(TA:getText())
    end

    butts[4][5] = 'Cancel'
    butts[4][6] = cancelmacro

    butts[5][5] = 'wp'
    butts[5][6] = function(TA)
        TA:insertBelow("wp('" .. getloc() .. "')")
    end
    butts[6][5] = 'log'
    butts[6][6] = function(TA)
        if switchPage(Scratchdir..Scratchpadfn) then
            TA:setText('')
            -- hardcoded 1MB file limit from scratchpad
            local buflen = string.len(Hist.buf)
            if buflen > (1024 * 1024) then
                loglocal('apit log buflen > 1MB: '..buflen)
            end

            local txt = string.sub(Hist.buf, buflen - (1024*1024))
            TA:setText(txt)
            TA:insertBottom('')
        end
    end

    butts[7][5] = 'loglvl'
    butts[7][6] = function()
        dbglvl = dbglvl + 1
        if dbglvl > 9 then
            dbglvl = 0
        end
        loglocal('aeronautespit: debug level set: '..dbglvl)
        panelbytitle['loglvl'].button:setText('log:'..tostring(dbglvl))
    end

    butts[8][5] = 'help'
    butts[8][6] = function(TA)
        if switchPage(Scratchdir..Scratchpadfn) then
            TA:setText('')
            -- hardcoded 1MB file limit from scratchpad
            local buflen = string.len(readme)
            if buflen > (1024 * 1024) then
                loglocal('apit help buflen > 1MB: '..buflen)
            end
            local txt = 'version: '..version..'\n'..readme..'\nEOF'
            txt = string.sub(txt, buflen - (1024*1024))
            TA:setText(txt)
        end
    end

    butts[9][5] = 'mod'
    butts[9][6] = showCustom

    butts[10][5] = 'modload'
    butts[10][6] = function()
        loglocal('aeronautespit: reload click '..#LT)
        assignKP()
        assignCustom()
    end

    --start row of "dynamic" buttons after static buttons above
    rowh = rowh + butth
    buttw = buttw + 20
    for i=1,buttfnamt do
        butts[numbutts+i] = {((i-1)*buttw)+10, rowh, buttw, butth, tostring(i)}
        butts[numbutts+i][6] = function(text) if buttfn[i] then buttfn[i](text); domacro.flag = true end end
        --[[ attempt at runtime generation of indirection func table for dynamic function buttons
            local str = 'function a'..i..'(text) if buttfn['..i..'] then buttfn['..i..'](text) end end'
            local fn
            local res
            fn, res = loadstring(str)
            if not fn then
            loglocal('aeronautes button butts fns : '..res)
            end
        --]]
    end

    for i,j in pairs(butts) do      -- create all buttons
        addButton(j[1], j[2], j[3], j[4], j[5], j[6])
    end
end                             -- end createbuttons

createbuttons()

-- addFrameListener is used for scheduling and inputing of cockpit commands
addFrameListener(function()
        if domacro.flag == true then
            now = socket.gettime()
            if now < domacro.ctr then
                return
            end
            if #domacro.inp == 0 then
                domacro.flag = false
                return
            end

            local i = domacro.idx
            loglocal('addFrameListener domacro.inp: '..net.lua2json(domacro.inp[i]), 6)
            local command = domacro.inp[i][1]
            local val = domacro.inp[i][2]
            local device = domacro.inp[i][4]
            loglocal('addFrameListener loop: '..i..":"..device..":" .. command ..":".. val..' '..socket.gettime(), 6)
            Spinr:run()
            if command == -1 and device == -1 then
                loglocal('addFrameListener potential fn '..DCS.getRealTime()..' '..net.lua2json(domacro.inp[i]), 6)
                if domacro.inp[i][5] then
                    loglocal('addFrameListener [5] ' ..DCS.getRealTime(), 6)
                    if type(domacro.inp[i][5]) == 'function' then
                        loglocal('addFrameListener [5] fn '..type(domacro.inp[i][5])..' '..type(domacro.inp[i][6]), 6)
                        domacro.inp[i][5](domacro.inp[i][6])
                    end
                end
            else
                loglocal('performClickableAction: '..device..' : '..command..' : '..val, 6)

                if not Export.GetDevice(device):performClickableAction(command, val) then
                    loglocal('performClickableAction: fail')
                end
            end

            domacro.ctr = socket.gettime() + itval + domacro.inp[i][3]
            loglocal('addFrameListener: time tick '..domacro.ctr, 6)
            i = i + 1
            if i > #domacro.inp then
                domacro.inp = {}
                domacro.idx = 1
                domacro.flag = false
                Spinr:rest()
                loglocal('addFrameListener: finished macro ul')
            else
                domacro.idx = i
            end
            loglocal('addFrameListener loop2: i: '..i, 6)
        end
end)                            -- end of addFrameListener()
domacro.listeneradded = true

-- addmissionLoadEndListener is to handle initializing when slotting into an aircraft
addMissionLoadEndListener(function()
        loglocal('missionLoadEndListener start', 3)
        if DCS.isMultiplayer() then
            loglocal('missionLoadEndListener MP', 3)
            local myid = net.get_my_player_id()
            local handler = {}
            function handler.onPlayerChangeSlot(id)
                if id == myid then
                    uploadinit()
                end
            end
            DCS.setUserCallbacks(handler)
        else
            loglocal('missionLoadEndListener SP', 3)
            if not uploadinit() then
                local handler = {}
                function handler.onSimulationResume()
                    uploadinit()
                end
                DCS.setUserCallbacks(handler)
            end
        end
end)                            -- end of addmissionLoadEndListener()
