function card2num(result)
   result = string.gsub(result, "N ", "2")
   result = string.gsub(result, "E ", "6")
   result = string.gsub(result, "W ", "4")
   result = string.gsub(result, "S ", "8")
   return result
end


function kpload(unit)
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
	 d = {{MDI_commands.MDI_PB_5, 1, 0.25, devices.MDI_LEFT},
	    {MDI_commands.MDI_PB_5, 0, 0.25, devices.MDI_LEFT},},
	 ['_'] = {{0, 99, delay, 0}},
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
   end
end

function f18convert(result)
   result = string.gsub(result, "[°'\"]", "")
   result = string.gsub(result, "([NEWS]) ", "%1")
   result = string.gsub(result, "[.]", " ")
   return result
end

   
function ltload()
   return {	-- per module customization for convenience api
      ["F-16C_50"] = {
	 ['coordsType'] = {format = 'DDM', lonDegreesWidth = 3},
	 ['wpentry'] = 'r4ddLATedLONedALTeuum', --llconvert = card2num
	 --prewp = function() press('r4dd') end,
	 midwp = function(result) return result end,
	 --postwp = function() press('euum') end,
	 llconvert =function(result)
	    result = string.gsub(result, "[°'.\"]", "")
	    return card2num(result)
	 end
      },
      ["FA-18C_hornet"] = {
	 --['coordsType'] = {format = 'DDM', precision = 4},
	 --['wpentry'] = 'daLAT LON cALT ',
	 ['coordsType'] = {format = 'DDM', precision = 4},
	 ['wpentry'] = 'daLAT LON cALT ',
	 prewp = function() return end,
	 midwp = function(result) return result end,
	 postwp = function() return end,
	 llconvert = f18convert,
      },
      ['Ka-50'] = {
	 ['coordsType'] = {format = 'DDM', precision = 1,
			   lonDegreesWidth = 3, showNegative = true},
	 ['wpentry'] = 'nw10LATe0LONeo',
--	 prewp = function() press('nw1') end,
	 midwp = function(result) return result end,
--	 postwp = function() press('o') end,
      },
      ['Hercules'] = {
	 ['coordsType'] = {format = 'DDM', precision = 3, lonDegreesWidth = 3},
	 ['wpentry'] = 'wLATeLONf',
--	 prewp = function() press('w') end,
	 midwp = function(result) return result end,
	 postwp = function() return end,
      },
   }
end

local a = ltload()
if a["FA-18C_hornet"].llconvert then
   print('llconver found')
end
