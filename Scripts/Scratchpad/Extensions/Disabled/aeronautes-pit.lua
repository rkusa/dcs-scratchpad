local version=.6
--[[
local readme = "
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
  wp(), wpseq(), press() and UI buttons `ULLL` and `WPLL`.

  * Waypoint input is currently supported for AV8, F-15E, F-16C, FA-18C,
  Blackshark 2&3.

- 5. Customizations are higher level capabilities that utilize any
  combination of the above features. These are separated per module in
  the Scripts\Scratchpad\Extensions\lib\ directory. The level of
  support and functions vary by module as apit updates are made. You
  can modify these yourself to make your own customizations for your
  aircraft. They can be utilized by clicking on the function buttons,
  `1`, `2`, ...  or executing the function name in a scratchpad page
  with `ULbuf` or `ULsel` buttons.

  * Customizations are currently supported for AV8, F-15E, F-16C, FA-18C,
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

## UI buttons:

- ULbuf - This will attempt to execute everything in the current
  scratchpad page as a Lua script.

- `ULsel` - This will take the current text selection as Lua. If no
  text is selected, then the current line the cursor is on is
  executed. This is a convenience feature to handle single line
  commands without the need to carefully highlight the line. This
  also has an added feature of detecting if the line matchs a JTAC
  provided coordinate and will automatically enter the latlong into
  the aircrafts input panel if available. The format of the coordinate
  must be ***

- `ULLL` - Using the camera's current location, the latlong is entered
  into the aircrafts coordinate input system. In F10 map view this is
  the location at center of the screen. In any other view cockpit or
  external view it is the 3d location of the camera view.

- `WPLL` - This works similarly to ULLL, but instead of directly
  entering the latlong, instead it will print the equivalent wp()
  command at the current cursor location in scratchpad. This is useful
  for building a mission plan that can be reused or passed along.

- `CANCEL` - If the system is processing a series of cockpit inputs,
  this will stop and cancel any outstanding inputs remaining.

- `RELOAD` - Convenience and customization code for the current
  aircraft are immediately reloaded and made available. This is only
  useful if you are modifying or adding apit code.

- `1`, `2`,... - These dynamic function buttons provide one-click
  access to functions defined in the per module customization files in
  Scratchpad\Extensions\lib\. The particular function names associated
  with each button are display on the title bar of the scratchpad
  window just to the right of the page name. Each function is prefaced
  with the corresponding button number.



## apit API
    The Lua functions provided by apit are as follows:

    - push_start_command(), push_stop_command()

    - prewp()

    - wp()

    - wpseq()

    - press()

    - tt()

    - ttn()

    - ttf()

    - ttt()

    - delay()

    - loglocal()

    - setPageNotice()

    - getcurrentPage()

    - unittab[]()


## Supported API
    Other APIs provided through apit:

    - scratchpad

    - DCS Lua environment



## Howto

"
--]]

local socket = require('socket')
lfs = require('lfs')

local domacro = {
    flag = true,
    idx = 1,
    ctr = 0,
    inp = {},
    listeneradded = false,
}

local debug = 1
local function loglocal(str, lvl)
    if not lvl then
        lvl = 0
    else
        if type(lvl) == 'table' then
            if type(lvl.debug) == 'number' then
                debug = lvl.debug
            end
        end
    end

    if debug > lvl then
        log(str)
    end
end

local scratchpadver = 0         --
local delay = 0.1               -- default input delay
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
    cur = 2,              --STR number to switch to before entering LL
    route = 'A',          --optional route can be one of ''.ABC
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
                if wps.menus ~= "" then
                    loglocal('F15 prewp(): menus press() '..tmp, 3)
                    press(wps.menus)
                end
                local tmp = tostring(wps.cur)
                if wps.route then
                    tmp = tmp .. wps.route..'a'
                end
                loglocal('F15 prewp(): cur press() '..tmp, 3)
                press(tmp)
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
		if wps.cur > 0 then
		    local tmp = tostring(wps.cur)
		    press('r4'..tmp..'edd')
		else -- cur==-1 but diff is incremental, hit up/down
		    if wps.diff > 0 then
			press('u')
		    elseif wps.diff < 0 then
			press('d')
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
                    press('u')
                elseif wps.diff < 0 then
                    press('d')
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
        local delay = 0.1
        if unit == 'AV8BNA' then
            return {
                ['1'] = {ufc_commands.Button_1, 1, delay, devices.UFCCONTROL},
                ['2'] = {ufc_commands.Button_2, 1, delay, devices.UFCCONTROL},
                ['3'] = {ufc_commands.Button_3, 1, delay, devices.UFCCONTROL},
                ['4'] = {ufc_commands.Button_4, 1, delay, devices.UFCCONTROL},
                ['5'] = {ufc_commands.Button_5, 1, delay, devices.UFCCONTROL},
                ['6'] = {ufc_commands.Button_6, 1, delay, devices.UFCCONTROL},
                ['7'] = {ufc_commands.Button_7, 1, delay, devices.UFCCONTROL},
                ['8'] = {ufc_commands.Button_8, 1, delay, devices.UFCCONTROL},
                ['9'] = {ufc_commands.Button_9, 1, delay, devices.UFCCONTROL},
                ['0'] = {ufc_commands.Button_0, 1, delay, devices.UFCCONTROL},
                ['e'] = {ufc_commands.Button_ENT, 1, delay, devices.UFCCONTROL},
                ['$'] = {ufc_commands.Button_4, 1, delay, devices.ODUCONTROL},
                ['N'] = {ufc_commands.Button_2, 1, delay, devices.UFCCONTROL},
                ['E'] = {ufc_commands.Button_6, 1, delay, devices.UFCCONTROL},
                ['W'] = {ufc_commands.Button_4, 1, delay, devices.UFCCONTROL},
                ['S'] = {ufc_commands.Button_8, 1, delay, devices.UFCCONTROL},
            }
        elseif unit == 'F-15ESE' then
            return {
                ['0'] = {{ufc_commands.UFC_KEY__0, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY__0, 0, delay, devices.UFCCTRL_FRONT},},
                ['1'] = {{ufc_commands.UFC_KEY_A1, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 0, delay, devices.UFCCTRL_FRONT},},
                ['2'] = {{ufc_commands.UFC_KEY_N2, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 0, delay, devices.UFCCTRL_FRONT},},
                ['3'] = {{ufc_commands.UFC_KEY_B3, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 0, delay, devices.UFCCTRL_FRONT},},
                ['4'] = {{ufc_commands.UFC_KEY_W4, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 0, delay, devices.UFCCTRL_FRONT},},
                ['5'] = {{ufc_commands.UFC_KEY_M5, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 0, delay, devices.UFCCTRL_FRONT},},
                ['6'] = {{ufc_commands.UFC_KEY_E6, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 0, delay, devices.UFCCTRL_FRONT},},
                ['7'] = {{ufc_commands.UFC_KEY__7, 1, 0.20, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY__7, 0, delay, devices.UFCCTRL_FRONT},},
                ['8'] = {{ufc_commands.UFC_KEY_S8, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 0, delay, devices.UFCCTRL_FRONT},},
                ['9'] = {{ufc_commands.UFC_KEY_C9, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 0, delay, devices.UFCCTRL_FRONT},},
                ['N'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_N2, 0, delay, devices.UFCCTRL_FRONT},},
                ['E'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_E6, 0, delay, devices.UFCCTRL_FRONT},},
                ['W'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_W4, 0, delay, devices.UFCCTRL_FRONT},},
                ['S'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_S8, 0, delay, devices.UFCCTRL_FRONT},},
                ['A'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_A1, 0, delay, devices.UFCCTRL_FRONT},},
                ['B'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_B3, 0, delay, devices.UFCCTRL_FRONT},},
                ['C'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_C9, 0, delay, devices.UFCCTRL_FRONT},},
                ['M'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_KEY_M5, 0, delay, devices.UFCCTRL_FRONT},},
                [' '] = {0, 0, delay, devices.UFCCTRL_FRONT},
                a = {{ufc_commands.UFC_PB_1, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_1, 0, delay, devices.UFCCTRL_FRONT},},
                b = {{ufc_commands.UFC_PB_2, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_2, 0, delay, devices.UFCCTRL_FRONT},},
                c = {{ufc_commands.UFC_PB_3, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_3, 0, delay, devices.UFCCTRL_FRONT},},
                d = {{ufc_commands.UFC_PB_4, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_4, 0, delay, devices.UFCCTRL_FRONT},},
                e = {{ufc_commands.UFC_PB_5, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_5, 0, delay, devices.UFCCTRL_FRONT},},
                f = {{ufc_commands.UFC_PB_6, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_6, 0, delay, devices.UFCCTRL_FRONT},},
                g = {{ufc_commands.UFC_PB_7, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_7, 0, delay, devices.UFCCTRL_FRONT},},
                h = {{ufc_commands.UFC_PB_8, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_8, 0, delay, devices.UFCCTRL_FRONT},},
                i = {{ufc_commands.UFC_PB_9, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_9, 0, delay, devices.UFCCTRL_FRONT},},
                j = {{ufc_commands.UFC_PB_0, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_PB_0, 0, delay, devices.UFCCTRL_FRONT},},
                m = {{ufc_commands.UFC_MENU, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_MENU, 0, delay, devices.UFCCTRL_FRONT},},
                ['^'] = {{ufc_commands.UFC_SHF, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_SHF, 0, delay, devices.UFCCTRL_FRONT},},
                ['.'] = {{ufc_commands.UFC_DOT, 1, delay, devices.UFCCTRL_FRONT},
                    {ufc_commands.UFC_DOT, 0, delay, devices.UFCCTRL_FRONT},},
                ['_'] = {{0, 99, delay, 0}},
            }
        elseif unit == 'F-16C_50' then
            return {
                ['0'] = {ufc_commands.DIG0_M_SEL, 1, delay, devices.UFC},
                ['1'] = {ufc_commands.DIG1_T_ILS, 1, delay, devices.UFC},
                ['2'] = {ufc_commands.DIG2_ALOW, 1, delay, devices.UFC},
                ['3'] = {ufc_commands.DIG3, 1, delay, devices.UFC},
                ['4'] = {ufc_commands.DIG4_STPT, 1, delay, devices.UFC},
                ['5'] = {ufc_commands.DIG5_CRUS, 1, delay, devices.UFC},
                ['6'] = {ufc_commands.DIG6_TIME, 1, delay, devices.UFC},
                ['7'] = {ufc_commands.DIG7_MARK, 1, delay, devices.UFC},
                ['8'] = {ufc_commands.DIG8_FIX, 1, delay, devices.UFC},
                ['9'] = {ufc_commands.DIG9_A_CAL, 1, delay, devices.UFC},
                ['N'] = {ufc_commands.DIG2_ALOW, 1, delay, devices.UFC},
                ['E'] = {ufc_commands.DIG6_TIME, 1, delay, devices.UFC},
                ['W'] = {ufc_commands.DIG4_STPT, 1, delay, devices.UFC},
                ['S'] = {ufc_commands.DIG8_FIX, 1, delay, devices.UFC},
                e = {ufc_commands.ENTR, 1, delay, devices.UFC},
                p = {ufc_commands.DED_INC, 1, delay, devices.UFC},
                m = {ufc_commands.DED_DEC, 1, delay, devices.UFC},
                r = {ufc_commands.DCS_RTN, -1, delay, devices.UFC},
                s = {ufc_commands.DCS_SEQ, -1, delay, devices.UFC},
                u = {{ufc_commands.DCS_UP, 1, delay, devices.UFC},
                    {ufc_commands.DCS_UP, 0, 0, devices.UFC}},
                d = {{ufc_commands.DCS_DOWN, -1, delay, devices.UFC},
                    {ufc_commands.DCS_DOWN, 0, 0, devices.UFC}},
            }
        elseif unit == 'FA-18C_hornet' then
            return {
                ['0'] = {{UFC_commands.KbdSw0, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw0, 0, delay, devices.UFC},},
                ['1'] = {{UFC_commands.KbdSw1, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw1, 0, delay, devices.UFC},},
                ['2'] = {{UFC_commands.KbdSw2, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw2, 0, delay, devices.UFC},},
                ['3'] = {{UFC_commands.KbdSw3, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw3, 0, delay, devices.UFC},},
                ['4'] = {{UFC_commands.KbdSw4, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw4, 0, delay, devices.UFC},},
                ['5'] = {{UFC_commands.KbdSw5, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw5, 0, delay, devices.UFC},},
                ['6'] = {{UFC_commands.KbdSw6, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw6, 0, delay, devices.UFC},},
                ['7'] = {{UFC_commands.KbdSw7, 1, 0.20, devices.UFC},
                    {UFC_commands.KbdSw7, 0, delay, devices.UFC},},
                ['8'] = {{UFC_commands.KbdSw8, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw8, 0, delay, devices.UFC},},
                ['9'] = {{UFC_commands.KbdSw9, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw9, 0, delay, devices.UFC},},
                ['N'] = {{UFC_commands.KbdSw2, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw2, 0, delay, devices.UFC},},
                ['E'] = {{UFC_commands.KbdSw6, 1, 1, devices.UFC},
                    {UFC_commands.KbdSw6, 0, 1, devices.UFC},},
                ['W'] = {{UFC_commands.KbdSw4, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw4, 0, delay, devices.UFC},},
                ['S'] = {{UFC_commands.KbdSw8, 1, delay, devices.UFC},
                    {UFC_commands.KbdSw8, 0, delay, devices.UFC},},
                [' '] = {{UFC_commands.KbdSwENT, 1, 0.5, devices.UFC},
                    {UFC_commands.KbdSwENT, 0, 0.25, devices.UFC},},
                a = {{UFC_commands.OptSw1, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw1, 0, 0.25, devices.UFC},},
                b = {{UFC_commands.OptSw2, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw2, 0, 0.25, devices.UFC},},
                c = {{UFC_commands.OptSw3, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw3, 0, 0.25, devices.UFC},},
                d = {{UFC_commands.OptSw4, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw4, 0, 0.25, devices.UFC},x},
                e = {{UFC_commands.OptSw5, 1, 0.25, devices.UFC},
                    {UFC_commands.OptSw5, 0, 0.25, devices.UFC},},
                f = {{AMPCD_commands.AMPCD_PB_5, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_5, 0, 0.25, devices.AMPCD},},
                g = {{AMPCD_commands.AMPCD_PB_12, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_12, 0, 0.25, devices.AMPCD},},
                h = {{AMPCD_commands.AMPCD_PB_13, 1, 0.25, devices.AMPCD},
                    {AMPCD_commands.AMPCD_PB_13, 0, 0.25, devices.AMPCD},},
                ['_'] = {{0, 99, 1, 0}},
            }
        elseif unit == 'Ka-50' or unit == 'Ka-50_3' then
            return {
                ['0'] = {device_commands.Button_1, 1, delay, devices.PVI},
                ['1'] = {device_commands.Button_2, 1, delay, devices.PVI},
                ['2'] = {device_commands.Button_3, 1, delay, devices.PVI},
                ['3'] = {device_commands.Button_4, 1, delay, devices.PVI},
                ['4'] = {device_commands.Button_5, 1, delay, devices.PVI},
                ['5'] = {device_commands.Button_6, 1, delay, devices.PVI},
                ['6'] = {device_commands.Button_7, 1, delay, devices.PVI},
                ['7'] = {device_commands.Button_8, 1, delay, devices.PVI},
                ['8'] = {device_commands.Button_9, 1, delay, devices.PVI},
                ['9'] = {device_commands.Button_10, 1, delay, devices.PVI},
                ['N'] = {device_commands.Button_1, 1, delay, devices.PVI},
                ['E'] = {device_commands.Button_1, 1, delay, devices.PVI},
                ['W'] = {device_commands.Button_2, 1, delay, devices.PVI},
                ['S'] = {device_commands.Button_2, 1, delay, devices.PVI},
                e = {device_commands.Button_18, 1, delay, devices.PVI}, --NAV Enter
                w = {device_commands.Button_11, 1, delay, devices.PVI}, --NAV Waypoints
                t = {device_commands.Button_17, 1, delay, devices.PVI}, --NAV Targets
                n = {device_commands.Button_26, 0.2, delay, devices.PVI}, --NAV Master mode ent
                o = {device_commands.Button_26, 0.3, delay, devices.PVI}, --NAV Master mode oper
            }
        elseif unit == 'Hercules' then
            return {
                ['0'] = {CNI_MU.pilot_CNI_MU_KBD_0, 1, delay, devices.General},
                ['1'] = {CNI_MU.pilot_CNI_MU_KBD_1, 1, delay, devices.General},
                ['2'] = {CNI_MU.pilot_CNI_MU_KBD_2, 1, delay, devices.General},
                ['3'] = {CNI_MU.pilot_CNI_MU_KBD_3, 1, delay, devices.General},
                ['4'] = {CNI_MU.pilot_CNI_MU_KBD_4, 1, delay, devices.General},
                ['5'] = {CNI_MU.pilot_CNI_MU_KBD_5, 1, delay, devices.General},
                ['6'] = {CNI_MU.pilot_CNI_MU_KBD_6, 1, delay, devices.General},
                ['7'] = {CNI_MU.pilot_CNI_MU_KBD_7, 1, delay, devices.General},
                ['8'] = {CNI_MU.pilot_CNI_MU_KBD_8, 1, delay, devices.General},
                ['9'] = {CNI_MU.pilot_CNI_MU_KBD_9, 1, delay, devices.General},
                ['E'] = {CNI_MU.pilot_CNI_MU_KBD_E, 1, delay, devices.General},
                ['N'] = {CNI_MU.pilot_CNI_MU_KBD_N, 1, delay, devices.General},
                ['S'] = {CNI_MU.pilot_CNI_MU_KBD_S, 1, delay, devices.General},
                ['W'] = {CNI_MU.pilot_CNI_MU_KBD_W, 1, delay, devices.General},
                a = {CNI_MU.pilot_CNI_MU_SelectKey_001, 1, delay, devices.General}, --SelectKey 1; wp #
                b = {CNI_MU.pilot_CNI_MU_SelectKey_delay, 1, delay, devices.General}, --SelectKey 2; wp name
                e = {CNI_MU.pilot_CNI_MU_SelectKey_005, 1, delay, devices.General}, --SelectKey 5; lat
                f = {CNI_MU.pilot_CNI_MU_SelectKey_006, 1, delay, devices.General}, --SelectKey 6; lon
                g = {CNI_MU.pilot_CNI_MU_SelectKey_007, 1, delay, devices.General}, --SelectKey 7; inc
                h = {CNI_MU.pilot_CNI_MU_SelectKey_008, 1, delay, devices.General}, --SelectKey 8; dec
                w = {CNI_MU.pilot_CNI_MU_NAV_CTRL, 1, delay, devices.General}, --NAV CTRL
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
        local fp = io.open(j.dir..'\\entry.lua')
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
            loglocal('entry.lua not found, '.. j.dir)
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
        table.insert(domacro.inp, {-1, -1, param.delay, -1, param.fn})
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

domacro.idx = 1
domacro.inp = {}

function push_stop_command(delay, c)
    loglocal('aeronautespit: push_stop_command() start '..net.lua2json(c))
    if c.device and c.action and c.value then
        loglocal('push_stop_command: dev '..c.device ..', action '.. c.action ..', val '.. c.value)
        if not c.len then
            c.len = delay               -- default switch delay
        end
        table.insert(domacro.inp, {c.action, c.value, c.len, c.device})
    end
end                             -- end of push_stop_command()

-- TTtoDA() tool tip to device action lookup
function TTtoDA(name, parms)
    local tmp = parms or {value = 1.0}

    loglocal('aeronautespit TTtoDA name: #'..name..'#'..net.lua2json(tmp), 4)
    if type(ttlist[name]) == 'table' then
        for i, j in pairs(ttlist[name]) do
            if not tmp[i] then
                local getval = loadstring("return " .. j)
                tmp[i] = getval()
            end
        end
        return tmp
    end

    loglocal('aeronautespit TTtoDA not found')
    return nil
end                             -- end of TTtoDA()

-- tt() tool tip instantiation
function tt(name, params)
    local tmp = params or {value = 1.0}
    tmp = TTtoDA(name, tmp)

    if tmp then
        loglocal('tt table: '..net.lua2json(tmp))
        push_stop_command(0.1, tmp)
    end
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
    push_stop_command(0, {device = 0, action = 0, value = 0, len = seconds})
end

-- prewp() input sequence before entering latlong
function prewp(num)
    loglocal('prewp: ')
    if LT[unittype].prewp then
        LT[unittype].prewp()
    end
    loglocal('prewp 2: ')
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
    loglocal('postwp: ')
    if LT[unittype].postwp then
        LT[unittype].postwp()
    end
    loglocal('postwp 2: ')
end

-- wpseq() interface for setting the next steerpoint number
function wpseq(param)
    loglocal('wpseq: '..net.lua2json(param))
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
    loglocal('wp: '..LLA)
--        waypointUFCMacro(LLA)
    prewp()

    local result = convertformatCoords(LLA)
    result = midwp(result)
    result = string.gsub(result, ".", press)

    postwp()

    return result .. "\n"
end

function apcall(chunk, env)     -- common pcall() for loadDTCBuffer and assignCustom
    return nil
end                             -- end apcall

function loadDTCBuffer(text)
    loglocal('loaddtcbuffer text len:'..string.len(text))
    local inf = loadstring(text)
    if not inf then
        loglocal('loadDTCBuffer loadstring failed: first 40 chars:' .. string.sub(text, 1, 40))
        loglocal('loadDTCBuffer loadstring failed: ret: ')
        if inf == LUA_ERRRUN then loglocal('loadDTCBuffer: LUA_ERRRUN')
        elseif inf == LUA_ERRMEM then loglocal('loadDTCBuffer: LUA_ERRMEM')
        elseif inf == LUA_ERRERR then loglocal('loadDTCBuffer: LUA_ERRERR')
        elseif inf == LUA_ERRGCMM then loglocal('loadDTCBuffer: LUA_ERRGCMM')
        end
        return nil
    end

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
           unittab = unittab,
           setPageNotice = setPageNotice,
           getcurrentPage = getcurrentPage,
    }
    setmetatable(env, {__index = _G})
    setfenv(inf, env)

    local ok, res = pcall(inf)
    if not ok then
        loglocal("Error executing mac: " .. string.sub(text, 1, 40))
        loglocal(res)
        return nil
    end

    domacro.flag = true
end                             -- end of loadDTCBuffer()

function assignCustom()
    local infn = lfs.writedir() .. 'Scripts\\Scratchpad\\Extensions\\lib\\'..unittype..'.lua'
    loglocal('aeronautespit: using customfile '..infn)
    local atr = lfs.attributes(infn)
    if atr and atr.mode == 'file' then
        local customfn = loadfile(infn)
        if not customfn then
            loglocal('assignCustom loadstring failed: ret: ')
            if inf == LUA_ERRRUN then loglocal('assignCustom: LUA_ERRRUN')
            elseif inf == LUA_ERRMEM then loglocal('assignCustom: LUA_ERRMEM')
            elseif inf == LUA_ERRERR then loglocal('assignCustom: LUA_ERRERR')
            elseif inf == LUA_ERRGCMM then loglocal('assignCustom: LUA_ERRGCMM')
            end
            return nil
        end

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
        setmetatable(env, {__index = _G}) --needed to pickup all the module macro definitions like devices
        setfenv(customfn, env)

        local ok, res = pcall(customfn)
        if not ok then
            loglocal('Error '..res)
            return nil
        end
        unittab = res
        for i,j in pairs(buttfn) do
            buttfn[i] = nil
        end
        local x = 0
        local noticestr = ''
        for i,j in pairs(unittab) do
            if type(j) == 'function' then
                x = x + 1
                buttfn[x] = j
                noticestr = noticestr ..' '..x..':'..i..'  '
            end
        end
        setPageNotice(noticestr)
    end
end                             -- end of assignCustom()

function uploadinit()
    loglocal('init: begin')
    wps = copytable(wpsdefaults)
    local newunittype = DCS.getPlayerUnitType()
    if newunittype == unittype then
        if not unittype then
            loglocal('uploadinit: unittype already nil')
        else
            loglocal('uploadinit: unittype already same, '..unittype)
        end
        return
    end

    setPageNotice('')
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

    loglocal('cycle thru modules,')
    for i,j in pairs(LT) do
        if LT[i].dirname then
            loglocal('cycle dir: '..LT[i].dirname)
        else
            loglocal('cycle missing dir: '..i)
        end
    end

    if not unittype then
        loglocal('aeronautespit init unittype nil')
        return
    end

    if not LT[unittype].dirname then
        loglocal('aeronautespit init LT[].dirname undefined for '..unittype)
        return
    end
    local dirname = LT[unittype].dirname

    function checkfile(fn)
        atr = lfs.attributes(fn)
        if not atr then
            loglocal('aeronautespit checkfile attributes nil, '..fn)
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
        loglocal('aeronautespit init file not available, '.. infn)
        return
    end
    dofile(infn)

    infn = checkcockpitfile(dirname, 'devices.lua')
    if not infn then
        loglocal('aeronautespit init file not available, '.. infn)
        return
    end
    dofile(infn)

    infn = checkcockpitfile(dirname, 'clickabledata.lua')
    if not infn then
        loglocal('aeronautespit init file not available, '.. infn)
        return
    end

    local infile = io.open(infn)
    if not infile then
        loglocal('aeronautespit: open file fail; ' .. infn)
        return(nil)
    end

    local line = infile:read('*line')
    if not line then
        loglocal('aeronautespit: read file fail; ' .. infn)
        return(nil)
    end

    local tt, dev, butn
    while line do
        tt, dev, butn = string.match(line, '^elements%[".+"%]%s*=.+%("(.+)"%)%s*,%s*([^,]+),%s*([^,]+)')
        if tt then
            ttlist[tt] = {device = dev, action = butn}
        end
        line = infile:read('*line')
    end
    infile:close()

    --???
    local ctr = 1
    for i,j in pairs(ttlist) do
        ctr = ctr + 1
    end

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
        local start, eos = getSelection()

        if start == eos then    -- if nothing is highlighted use the current line of cursor
            start, eos = getCurrentLineOffsets(text, eos)
        else
            start = start
        end

        sel = string.sub(text, start, eos)

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

        loglocal('addButton ULsel: '..sel)
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
for i=1,6 do                    -- initialize locations and size
    butts[i] = {((i-1)*buttw), 0, buttw, butth}
end

butts[1][5] = "LL"
butts[1][6] = function(text)
    str = getloc()
    loglocal('aeronautespit: button LL: '..str)
    wp(str)
    domacro.flag = true
end

butts[2][5] = "wp"
butts[2][6] = function(text)
    text:insertBelow("wp('" .. getloc() .. "')")
end

butts[3][5] = "Sel"
butts[3][6] = handleSelection

butts[4][5] = "Buf"
butts[4][6] = function(textarea)
    loadDTCBuffer(textarea:getText())
end

butts[5][5] = "Cancel"
butts[5][6] = function(textarea)
        domacro.inp = {}
        domacro.idx = 1
        domacro.flag = false
end

butts[6][5] = "Reload"
butts[6][6] = function(text)
        loglocal('aeronautespit: RELOAD click '..#LT)
        assignKP()
        assignCustom()
end

--start second row buttons
for i=1,buttfnamt do
    --[[ attempt at runtime generation of indirection func table for dynamic function buttons
    local str = 'function a'..i..'(text) if buttfn['..i..'] then buttfn['..i..'](text) end end'
    local fn
    local res
    fn, res = loadstring(str)
    if not fn then
        loglocal('aeronautes button butts fns : '..res)
        end
    --]]
    butts[i+6] = {((i-1)*buttw)+10, butth, buttw, butth, tostring(i)}
end

butts[7][6] = function(text) if buttfn[1] then buttfn[1](text); domacro.flag = true end end
butts[8][6] = function(text) if buttfn[2] then buttfn[2](text); domacro.flag = true end end
butts[9][6] = function(text) if buttfn[3] then buttfn[3](text); domacro.flag = true end end
butts[10][6] = function(text) if buttfn[4] then buttfn[4](text); domacro.flag = true end end
butts[11][6] = function(text) if buttfn[5] then buttfn[5](text); domacro.flag = true end end
butts[12][6] = function(text) if buttfn[6] then buttfn[6](text); domacro.flag = true end end

for i,j in pairs(butts) do      -- create all buttons
    addButton(j[1], j[2], j[3], j[4], j[5], j[6])
end

-- addFrameListener is used for scheduling and inputing of cockpit commands
addFrameListener('aeronautes-pit', function()
        if domacro.flag == true then
            now = socket.gettime()
            if now < domacro.ctr then
                return
            end
            if #domacro.inp == 0 then
                domacro.flag = false
                return
            end

            i = domacro.idx
            command = domacro.inp[i][1]
            val = domacro.inp[i][2]
            device = domacro.inp[i][4]
            loglocal('addFrameListener loop: '..i..":"..device..":" .. command ..":".. val..' '..socket.gettime(), 6)
            if command == -1 and device == -1 then
                loglocal('addFrameListener potential fn '..DCS.getRealTime()..' '..net.lua2json(domacro.inp[i]))
                if domacro.inp[i][5] then
                    loglocal('addFrameListener [5] ' ..DCS.getRealTime())
                    if type(domacro.inp[i][5]) == 'function' then
                        loglocal('addFrameListener [5] fn '..type(domacro.inp[i][5])..' '..DCS.getRealTime())
                        domacro.inp[i][5]()
                    end
                end
            else
                assert(Export.GetDevice(device):performClickableAction(command, val))
            end
            domacro.ctr = socket.gettime() + domacro.inp[i][3]
            loglocal('addFrameListener: time tick '..domacro.ctr, 6)
            i = i + 1
            if i > #domacro.inp then
                domacro.inp = {}
                domacro.idx = 1
                domacro.flag = false
                loglocal('addFrameListener: finished macro ul')
            else
                domacro.idx = i
            end
            loglocal('addFrameListener loop2: i: '..i, 6)
        end
end)                            -- end of addFrameListener()
domacro.listeneradded = true

-- addmissionLoadEndListener is to handle initializing when slotting into an aircraft
addmissionLoadEndListener(function()
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
