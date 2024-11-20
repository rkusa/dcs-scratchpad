--[[ working functions:
    night
--]]

ft = {}
ft.order = {'setup', 'night'}

--#################################
-- Setup v0.1
-- settings used after a start or autostart
ft['setup'] = function()

press([[!#~]])                  -- power RWR/CMWS

    --ASE panel; arm and bypass
ttn('',{device=devices.AN_ALE47, action=device_commands.Button_5})
ttn('',{device=devices.AN_ALE47, action=device_commands.Button_7})

end                         -- end setup

--#################################
-- Night v0.1
ft['night'] = function()

local mfds = {devices.MFD_COPILOT_OUTBOARD, devices.MFD_COPILOT_INBOARD, devices.MFD_CENTER, devices.MFD_PILOT_INBOARD, devices.MFD_PILOT_OUTBOARD}
for _,dev in pairs(mfds) do
tt('',{device=dev, action=device_commands.Button_33, value=1})
tt('',{device=dev, action=device_commands.Button_33, value=.5})
end

tt('',{device=devices.CANTED_CONSOLE, action=device_commands.Button_38, value=.2})
tt('',{device=devices.CANTED_CONSOLE, action=device_commands.Button_41, value=.2})

end                             -- end night

return ft
