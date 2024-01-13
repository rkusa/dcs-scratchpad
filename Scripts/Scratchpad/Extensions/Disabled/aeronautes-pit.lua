local version=.61
local readme = [=[
# aeronautes-pit

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

- Prerequisite - scratchpad-hook.lua rel XX or higher should be
  installed under the Saved Game directory structure.

- Required file - aeronautes-pit.lua is necessary for base
  functionality. This needs copied from
  Scripts\Scratchpad\Extensions\Disabled\ to the parent Extensions\
  directory. On the next start of DCS you should see the apit menu
  buttons when scratchpad window is open.

- Optional files - For each DCS module an optional customization file,
  such as F-16C_50.lua, is searched for when slotting into the
  aircraft. Generally these are input commands that are grouped into
  functions. Examples of functions include 'start' to start the
  aircraft or 'mfd' to configure MFD pages. If no file is found the,
  base apit functionality is still available.

## Feature/Module matrix

This matrix shows apit features and the amount of DCS modules
supported by each.

                |    Module    |
                |   support    |
|    Feature    | All | Subset | Note |
|---------------|-----|--------|------|
| DCS macros    | X   |        |    1 |
| Convenience   | X   |        |    2 |
| DCS API       | X   |        |    3 |
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
  * All modules supported

- 3. DCS APIs as defined in DCS World OpenBeta\API\DCS_ControlAPI.html
  are available. The level of functionality and support is entirely up
  to ED.
  * All modules supported

- 4. Waypoint functions provide the ability input latlong and certain
  other input without having to know or program which specific buttons
  to press. These have been adapted for specific aircraft as each one
  has it's own particular sequence of input. The API for this includes
  wp(), wpseq(), press() and UI buttons `LL` and `wp`.

  * Abbreviated waypoint input is currently supported for AV8, F-15E,
  F-16C, FA-18C, Blackshark 2&3.

- 5. Customizations are higher level capabilities that utilize any
  combination of the above features. These are separated per module in
  the Scripts\Scratchpad\Extensions\lib\ directory. The level of
  support and functions vary by module as apit updates are made. You
  can modify these yourself to make your own customizations for your
  aircraft. They can be utilized by clicking on the function buttons,
  `1`, `2`, ...  or executing the function name in a scratchpad page
  with `Buf` or `Sel` buttons.

  * Customizations are provided for AV8, F-15E, F-16C, FA-18C,
  Mi-8.

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
                                \lib\   - Optional module files for custom functions
                                        |[AV8NA.lua]
                                        |[F-15ESE.lua]
                                        |[F-16C_50.lua]
                                        |[FA-18C_hornet.lua]
                                        |[Mi-8MT.lua]
                                        |[kp.lua]
                                        |...
'''

## UI:

    The scratchpad title bar will show from left to right the name of
    the current page, a static vertical separator, a progress spinner
    and a list of available customization functions if available. The
    numbers of the functions correspond to the numbered buttons below
    the scratchpad window. The progress spinner will indicate the
    current state of system input with the following symbols:

    `0000 | * 1.start 2.`

    - `*` astericks indicates the system is ready

    - `-\|/` any instance of the lines to represent a rotating bar
      indicates the system is processing some input

    - `D` capital D indicates delay() was called. Once the amount of
      time requested for delay has passed the spinner should change to
      one of the previous indicators.

    Button labels that are capitalized will cause some type of input
    to the cockpit, such as `LL` or `Sel`. Those without
    capitalization do not cause input.

- `LL` - Using the camera's current location, the latlong is entered
  into the aircrafts coordinate input system. In F10 map view this is
  the location at center of the screen. In any other view, cockpit or
  external, it is the 3d location of the camera position. Some
  aircraft may have prerequisites before using `LL`. For example, F-18
  currently requires Precise coordinates enabled. The default behavior
  upon click is to increment the current waypoint, enter latlong and
  stop. The next click will carry out the same steps. You can modify
  this behavior using the wpseq() function(see below). You can also
  use wpseq() to disable any waypoint number change, leaving it up to
  you to set the correct number.

- `Sel` - This will take the current text selection as Lua. If no
  text is selected, then the current line the cursor is on is
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
  this will stop and cancel any outstanding inputs remaining.

- `wp` - This works similarly to LL, but instead of directly
  entering the latlong, instead it will print the equivalent wp()
  command at the current cursor location in scratchpad. This is useful
  for building a mission plan that can be reused or passed along.

- `reload` - Convenience and customization code for the current
  aircraft are immediately reloaded and made available. This is useful
  if you are modifying or adding apit Customization
  files(Extensions\lib), or if you've messed up some certain values
  from a scratchpad page and want to reset using Customization file
  values.

- `dbglog` - This is used to increase the debug level of apit
  logging. It is equivalent to `loglocal('',{debug=6})

- `help` - This will create a file called help-aeronautes-pit.txt in
  the scratchpad directory if it doesn't exist. If one already exists
  it will overwrite it. If you change your help file and don't want to
  lose the it, rename it to some other file name. After clicking on
  the help button, you'll need to refresh the pages with the Reload
  Page hotkey to see it immediately. See scratchpad instruction on how
  to assign the hotkey if you have not already. Otherwise scratchpad
  will not recognize it until the next time you start DCS.

- `1`, `2`,... - These dynamic function buttons provide one-click
  access to functions defined in the per module customization files in
  Scratchpad\Extensions\lib\. The particular function names associated
  with each button are display on the title bar of the scratchpad
  window just to the right of the page name. Each function is prefaced
  with the corresponding button number.

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
      behavior. See Extensions\lib\F-15ESE customization to see how
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

    - getCurrentPage() returns string with name of current page of
      scratchpad. For extensions to take specific action based on the
      active page.

    - setitval(number) sets the base time interval in seconds between
      cockpit inputs. If you find some of your inputs are getting lost
      then you can start by extending this time until all your inputs
      are received. This time applies to all inputs. Some inputs can
      have extra time added per the kp[] table. Default .1 seconds

        Example:
        setitval(.2)
        loglocal(itval)  -- to see value of itval in Scratchpad.log

    - unittab[]()

## Supported API
    Other APIs provided through apit:

    - scratchpad

    - DCS Lua environment

## Howto/FAQ

- Where are apit logging messages? Apit sends messages to the
  scratchpad log located in `Saved
  Games\DCS.openbeta\Logs\Scratchpad.log`. You can monitor this file
  by opening a powershell window, cd into the Logs directory and run
  this command, "Get-Content .\Scratchpad.log -wait". This will update
  as the file is written to.

- How to change log level? You can press the `dbglog` button to set
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

local dbglvl = 1
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
local buttfnamt = 6
local buttw = 50
local butth = 30

local noticestr = ''
Spinr = {
    frames = {'/','|','\\','-'},
    idx = 1,
    run = function(self)
        if self.idx <= 1 then
            self.idx = #self.frames
        else
            self.idx = self.idx - 1
        end
        return self.frames[self.idx]
    end,
    rest = function(self)
        idx = 1
        return '*'
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
    ['AV8BNA'] = {
        ['coordsType'] = {format = 'DMS', lonDegreesWidth = 3},
        ['wpentry'] = 'LATe$LONe',
        prewp = function() press('') end,
        midwp = function(result) return result end,
        postwp = function() press('') end,
    },
    ["F-15ESE"] = {
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
        midwp = function(result) return result end,
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
        ['coordsType'] = {format = 'DDM', lonDegreesWidth = 3},
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

        midwp = function(result) return result end,
        postwp = function() --press('euum') end,
	    if wps.enable and wps.cur ~= -1 then
                wps.cur = wps.cur + wps.diff
                if wps.cur < 1 then wps.cur = 699 end
                if wps.cur > 699 then wps.cur = 1 end
                return
            end
	end,
    },
    ["FA-18C_hornet"] = {
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
        midwp = function(result) return result end,
        postwp = function() return end,
        llconvert =function(result)
            result = string.gsub(result, "[°'\"]", "")
            result = string.gsub(result, "([NEWS]) ", "%1")
            result = string.gsub(result, "[.]", " ")
            return result
        end,
    },
    ['Hercules'] = {
        ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
        ['wpentry'] = 'LATeLONf',
        prewp = function() press('w') end,
        midwp = function(result) return result end,
        postwp = function() return end,
    },
    ['Ka-50'] = {
        ['coordsType'] = {format = 'DDM', precision = 1, lonDegreesWidth = 3},
        ['wpentry'] = 'LATeLONe',
        prewp = function() return end, -- press('nw1') end,
        midwp = function(result) return result end,
        postwp = function() press('o') end,
    },
} --end LT{}
LT['Ka-50_3'] = LT['Ka-50']

local function assignKP()
    loglocal('assignKP begin')
    local function getTypeKP(unit)
        loglocal('getTypeKP begin')

--########## SNIP BEGIN for Scripts\Scratchpad\Extensions\lib\kp.lua
--function kpload(unit)
        local diffiv = 0
        if unit == 'AV8BNA' then
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
                ['$'] = {ufc_commands.Button_4, 1, diffiv, devices.ODUCONTROL},
                ['N'] = {ufc_commands.Button_2, 1, diffiv, devices.UFCCONTROL},
                ['E'] = {ufc_commands.Button_6, 1, diffiv, devices.UFCCONTROL},
                ['W'] = {ufc_commands.Button_4, 1, diffiv, devices.UFCCONTROL},
                ['S'] = {ufc_commands.Button_8, 1, diffiv, devices.UFCCONTROL},
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
                e = {ufc_commands.ENTR, 1, diffiv, devices.UFC},
                p = {ufc_commands.DED_INC, 1, diffiv, devices.UFC},
                m = {ufc_commands.DED_DEC, 1, diffiv, devices.UFC},
                r = {ufc_commands.DCS_RTN, -1, diffiv, devices.UFC},
                s = {ufc_commands.DCS_SEQ, -1, diffiv, devices.UFC},
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
            return {
                ['0'] = {device_commands.Button_1, 1, diffiv, devices.PVI},
                ['1'] = {device_commands.Button_2, 1, diffiv, devices.PVI},
                ['2'] = {device_commands.Button_3, 1, diffiv, devices.PVI},
                ['3'] = {device_commands.Button_4, 1, diffiv, devices.PVI},
                ['4'] = {device_commands.Button_5, 1, diffiv, devices.PVI},
                ['5'] = {device_commands.Button_6, 1, diffiv, devices.PVI},
                ['6'] = {device_commands.Button_7, 1, diffiv, devices.PVI},
                ['7'] = {device_commands.Button_8, 1, diffiv, devices.PVI},
                ['8'] = {device_commands.Button_9, 1, diffiv, devices.PVI},
                ['9'] = {device_commands.Button_10, 1, diffiv, devices.PVI},
                ['N'] = {device_commands.Button_1, 1, diffiv, devices.PVI},
                ['E'] = {device_commands.Button_1, 1, diffiv, devices.PVI},
                ['W'] = {device_commands.Button_2, 1, diffiv, devices.PVI},
                ['S'] = {device_commands.Button_2, 1, diffiv, devices.PVI},
                e = {device_commands.Button_18, 1, diffiv, devices.PVI}, --NAV Enter
                w = {device_commands.Button_11, 1, diffiv, devices.PVI}, --NAV Waypoints
                t = {device_commands.Button_17, 1, diffiv, devices.PVI}, --NAV Targets
                n = {device_commands.Button_26, 0.2, diffiv, devices.PVI}, --NAV Master mode ent
                o = {device_commands.Button_26, 0.3, diffiv, devices.PVI}, --NAV Master mode oper
            }
        elseif unit == 'Hercules' then
            return {
                ['0'] = {CNI_MU.pilot_CNI_MU_KBD_0, 1, diffiv, devices.General},
                ['1'] = {CNI_MU.pilot_CNI_MU_KBD_1, 1, diffiv, devices.General},
                ['2'] = {CNI_MU.pilot_CNI_MU_KBD_2, 1, diffiv, devices.General},
                ['3'] = {CNI_MU.pilot_CNI_MU_KBD_3, 1, diffiv, devices.General},
                ['4'] = {CNI_MU.pilot_CNI_MU_KBD_4, 1, diffiv, devices.General},
                ['5'] = {CNI_MU.pilot_CNI_MU_KBD_5, 1, diffiv, devices.General},
                ['6'] = {CNI_MU.pilot_CNI_MU_KBD_6, 1, diffiv, devices.General},
                ['7'] = {CNI_MU.pilot_CNI_MU_KBD_7, 1, diffiv, devices.General},
                ['8'] = {CNI_MU.pilot_CNI_MU_KBD_8, 1, diffiv, devices.General},
                ['9'] = {CNI_MU.pilot_CNI_MU_KBD_9, 1, diffiv, devices.General},
                ['E'] = {CNI_MU.pilot_CNI_MU_KBD_E, 1, diffiv, devices.General},
                ['N'] = {CNI_MU.pilot_CNI_MU_KBD_N, 1, diffiv, devices.General},
                ['S'] = {CNI_MU.pilot_CNI_MU_KBD_S, 1, diffiv, devices.General},
                ['W'] = {CNI_MU.pilot_CNI_MU_KBD_W, 1, diffiv, devices.General},
                a = {CNI_MU.pilot_CNI_MU_SelectKey_001, 1, diffiv, devices.General}, --SelectKey 1; wp #
                b = {CNI_MU.pilot_CNI_MU_SelectKey_diffiv, 1, diffiv, devices.General}, --SelectKey 2; wp name
                e = {CNI_MU.pilot_CNI_MU_SelectKey_005, 1, diffiv, devices.General}, --SelectKey 5; lat
                f = {CNI_MU.pilot_CNI_MU_SelectKey_006, 1, diffiv, devices.General}, --SelectKey 6; lon
                g = {CNI_MU.pilot_CNI_MU_SelectKey_007, 1, diffiv, devices.General}, --SelectKey 7; inc
                h = {CNI_MU.pilot_CNI_MU_SelectKey_008, 1, diffiv, devices.General}, --SelectKey 8; dec
                w = {CNI_MU.pilot_CNI_MU_NAV_CTRL, 1, diffiv, devices.General}, --NAV CTRL
            }

--    end
--end
--########## SNIP END for kp.lua
        else
            loglocal('assignKP unknown unit: '..unit)
            return
        end
    end --end getTypeKP()

    -- support for optional kp.lua file used for adding or modifying wp for a DCS module
    local kpfile = lfs.writedir() .. 'Scripts\\Scratchpad\\Extensions\\lib\\kp.lua'
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
    loglocal('assignKP: done '..unittype..', '..type(kp))
    loglocal(net.lua2json(kp))
    loglocal(net.lua2json(LT))
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
                    loglocal('aeronautespit searchmodules: added '..ut)
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

searchmodules()
for i,j in pairs(modname2dir) do

    if not LT[i] then
        LT[i] = {}
    end
    LT[i].dirname = j.dir
    loglocal('aeronautespit cycle LT.dirname: '..i..' = '..LT[i].dirname)
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
            loglocal("upload: press() nil " .. key, 0)
            return ""
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
    loglocal('aeronautespit: push_stop_command() start '..net.lua2json(c))
    if c.device and c.action and c.value then
        loglocal('push_stop_command: device '..c.device ..', action '.. c.action ..', value '.. c.value..' fn '..type(c.fn)..' arg: '..type(c.arg))
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
                          fn = function() setPageNotice('D'..noticestr) end
    })
end

-- prewp() input sequence before entering latlong
function prewp(num)
    loglocal('prewp() unittype: '..unittype, 3)
    if LT[unittype].prewp then
        LT[unittype].prewp()
    end
    loglocal('prewp 2: ', 3)
end

-- midwp() input sequence during middle of latlong
function midwp(wpstr)
    loglocal('midwp: ')
    if LT[unittype].midwp then
        return LT[unittype].midwp(wpstr)
    end
    loglocal('midwp 2: no midwp defined')
    return wpstr
end

--postwp() input sequence after latlong entered
function postwp()
    loglocal('postwp: ', 3)
    if LT[unittype].postwp then
        LT[unittype].postwp()
    end
    loglocal('postwp 2: ', 3)
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
function wp(LLA)
    loglocal('wp: '..LLA, 3)
    prewp()

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
                return nil
            end
        else
            loglocal('apcall() not a file '..p.fn)
            return nil
        end
    elseif p.str then
        f, err = loadstring(p.str)
        if not f then
            loglocal('apcall() loadstring failed: '..err)
            return nil
        end
    else
        loglocal('apcall() unknown input p: '..type(p))
        return nil
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
        }
        setmetatable(env, {__index = _G})
    else
        env = p.env
    end
    setfenv(f, env)

    local ok, res = pcall(f)

    if not ok then
        if p.str then
            loglocal("Error executing macro[first 40]: " .. string.sub(p.str, 1, 40))
        end
        loglocal('apcall() pcall error '..res)
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
           dbglvl = dbgvlv,
           kp = kp,
           loglocal = loglocal,
           unittab = unittab,
           ttlist = ttlist,
           setPageNotice = setPageNotice,
           getCurrentPage = getCurrentPage,
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
    local infn = lfs.writedir() .. 'Scripts\\Scratchpad\\Extensions\\lib\\'..unittype..'.lua'
    loglocal('aeronautespit: using customfile '..infn)
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
        local x = 0

        if not unittab then
            loglocal('assignCustom() res/unittab nil ')
            return
        end

        noticestr = ''
        for i,j in pairs(unittab) do
            if type(j) == 'function' then
                x = x + 1
                buttfn[x] = j
                noticestr = noticestr ..' '..x..':'..i..'  '
            end
        end
        loglocal('assignCustom #unittab: '..#unittab ..': '.. unittype)
        setPageNotice(Spinr:rest()..noticestr)

        if unittab['init'] and type(unittab['init']) == 'string' then
            loglocal('assignCustom() running unit init', 4)
            loadDTCBuffer(unittab['init'])
        end
    else
        loglocal('assignCustom apcall fail, not ok, res: '..type(res))
    end
end                             -- end of assignCustom()

function uploadinit()
    loglocal('uploadinit(): begin')
    wps = copytable(wpsdefaults)
    local newunittype = DCS.getPlayerUnitType()
    if newunittype == unittype then
        if not unittype then
            loglocal('uploadinit(): unittype already nil')
        else
            loglocal('uploadinit(): unittype already same, '..unittype)
        end
        return
    end

    setPageNotice('')
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

    loglocal('uploadinit() ttlist: '..net.lua2json(ttlist), 6)

    assignKP()
    assignCustom()

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

local function handleSelection(textarea)
        local text = textarea:getText()
        --        local start, eos, sbyte, ebyte = getSelection()
        local startp, endp, start, eos = getSelection()

        loglocal('handleSelection() sp: '..startp..' ep: '..endp..' start: '..start..' eos: '..eos)
        if start == eos then    -- if nothing is highlighted use the current line of cursor
            start, eos = getCurrentLineOffsets(text, eos)
--        else
--            start = start
        end

        sel = string.sub(text, start, eos)

        loglocal('Sel len: '..string.len(sel)..' start: '..start..' end: '..eos..': #'..sel..'#')

        local jtest = sel
        jtest = string.gsub(jtest, "[']", '')
        jtest = string.gsub(jtest, '°', ' ')
        local lat, lon = string.match(jtest, '(%u %d%d +%d%d%.%d+), (%u %d+ +%d%d%.%d+)')
        local altm, altft = string.match(jtest, '(%d+)m, +(%d+)ft')

--        local prec =
        --for jtac coords
        if lon then
            loglocal('Sel: jtac position detected')
            local cType = coordsType(unittype)
            if cType then
                if cType.precision then
                    delta = 3 - cType.precision
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

-- first row buttons
local rown = 8
for i=1,rown do                 -- initialize locations and size
    butts[i] = {((i-1)*buttw), 0, buttw, butth}
end

butts[1][5] = "LL"
butts[1][6] = function(text)
    str = getloc()
    loglocal('aeronautespit: button LL: '..str)
    wp(str)
    domacro.flag = true
end

butts[2][5] = "Sel"
butts[2][6] = handleSelection

butts[3][5] = "Buf"
butts[3][6] = function(textarea)
    loadDTCBuffer(textarea:getText())
end

butts[4][5] = "Cancel"
butts[4][6] = function(textarea)
    domacro.inp = {}
    domacro.idx = 1
    domacro.flag = false
    setPageNotice(Spinr:rest()..noticestr)
end

butts[5][5] = "wp"
butts[5][6] = function(text)
    text:insertBelow("wp('" .. getloc() .. "')")
end

butts[6][5] = "reload"
butts[6][6] = function(text)
    loglocal('aeronautespit: reload click '..#LT)
    assignKP()
    assignCustom()
end

butts[7][5] = "dbglog"
butts[7][6] = function(text)
    loglocal('aeronautespit: debug level set 9')
    loglocal('',{debug=9})
end

butts[8][5] = "help"
butts[8][6] = function(text)
    local helpfn = lfs.writedir()..'Scratchpad\\help-aeronautes-pit.txt'
    loglocal('aeronautespit: help click '..helpfn)
    local fp, res
    fp, res = io.open(helpfn, 'w+')
    if not fp then
        loglocal('aeronautespit: help click error open: '..res)
    end
    fp:write('version: '..version..'\n'..readme)
    fp:close()
    noticestr = noticestr .. 'help file created. reload pages'
    setPageNotice(Spinr:rest()..noticestr)
end

--start second row buttons
for i=1,buttfnamt do
    butts[i+rown] = {((i-1)*buttw)+10, butth, buttw, butth, tostring(i)}
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

butts[rown+1][6] = function(text) if buttfn[1] then buttfn[1](text); domacro.flag = true end end
butts[rown+2][6] = function(text) if buttfn[2] then buttfn[2](text); domacro.flag = true end end
butts[rown+3][6] = function(text) if buttfn[3] then buttfn[3](text); domacro.flag = true end end
butts[rown+4][6] = function(text) if buttfn[4] then buttfn[4](text); domacro.flag = true end end
butts[rown+5][6] = function(text) if buttfn[5] then buttfn[5](text); domacro.flag = true end end
butts[rown+6][6] = function(text) if buttfn[6] then buttfn[6](text); domacro.flag = true end end

for i,j in pairs(butts) do      -- create all buttons
    addButton(j[1], j[2], j[3], j[4], j[5], j[6])
end

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
            loglocal('addFrameListener domacro.inp: '..net.lua2json(domacro.inp[i]))
            local command = domacro.inp[i][1]
            local val = domacro.inp[i][2]
            local device = domacro.inp[i][4]
            loglocal('addFrameListener loop: '..i..":"..device..":" .. command ..":".. val..' '..socket.gettime(), 6)
            setPageNotice(Spinr:run()..noticestr)
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
                loglocal('performClickableAction: '..device..' : '..command..' : '..val)
                if not assert(Export.GetDevice(device):performClickableAction(command, val)) then
                    loglocal('performClickableAction failed')
                end
            end

            domacro.ctr = socket.gettime() + itval + domacro.inp[i][3]
            loglocal('addFrameListener: time tick '..domacro.ctr, 6)
            i = i + 1
            if i > #domacro.inp then
                domacro.inp = {}
                domacro.idx = 1
                domacro.flag = false
                setPageNotice(Spinr:rest()..noticestr)
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
