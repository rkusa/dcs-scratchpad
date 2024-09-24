--[[ working functions:
    night
--]]

ft = {}
ft.order = {'night', 'drop', 'load'}

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

--#################################
-- drop v0.1
ft['drop'] = function()
Export.LoSetCommand(179)--comm
Export.LoSetCommand(975)--f10
Export.LoSetCommand(966)--f1
Export.LoSetCommand(971)--f6
Export.LoSetCommand(968)--f3

end                             -- end drop

--#################################
-- load v0.1
ft['load'] = function()
Export.LoSetCommand(179)--comm
Export.LoSetCommand(975)--f10
Export.LoSetCommand(966)--f1
Export.LoSetCommand(971)--f6
Export.LoSetCommand(966)--f1
end                             -- end load

return ft

--[[ other code bits

--]]
