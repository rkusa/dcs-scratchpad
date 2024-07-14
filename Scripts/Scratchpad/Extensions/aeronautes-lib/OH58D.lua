--[[ working functions:
    setup - misc things
--]]

local ft = {}

--#################################
-- setup v0.1
-- misc setup after default autostart

ft['setup'] = function()

Export.LoSetCommand(7)                                           --cockpit view
ttn('',{device=devices.COMMON, action=device_commands.Button_2}) --copilot seat
ttn('',{device=devices.COMMON, action=device_commands.Button_5}) --mask
ttn('',{device=devices.COMMON, action=device_commands.Button_1}) --pilot seat
ttn('',{device=devices.COMMON, action=device_commands.Button_5}) --mask

end

return ft

--[[ random bits of code
    
ttn('',{device=devices.AI, action=device_commands.Button_44}) --500ft
ttn('',{device=devices.AI, action=device_commands.Button_30}) --100kt
ttn('',{device=devices.AI, action=device_commands.Button_6}) --baro level
ttn('',{device=devices.AI, action=device_commands.Button_15}) --follow route
ttn('',{device=devices.AI, action=device_commands.Button_33}) --30ft
    
--]]
