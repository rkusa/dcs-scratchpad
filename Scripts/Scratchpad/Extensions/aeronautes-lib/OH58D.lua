--[[ working functions:
    setup - misc things
--]]
-- module specific configuration
wpseq({enable=true, cur=1, diff = 1,})

local ft = {}
ft.order={'start', 'setup'}

--#################################
-- setup v0.1
-- misc setup after default autostart

ft['setup'] = function()

ttf('MMS Laser Power Switch')
ttf('Master Switch')
tt('MMS Mode Selector', {value=.6}) -- prept
tt('Transmit Selector Switch', {value=.3}) -- cpg radio 2
tt('Radio Select Switch 2/4', {value=.2})  -- pilot radio 2
ttn('Select Switch')                       -- fuel qty/eng trq
ttn('Select Switch')
ttn('Select Switch')
tt('Line Address Key B2')       -- cpg HSD
tt('Line Address Key B1',{device=devices.RMFD} )     -- pilot HVR


Export.LoSetCommand(7)                                           --cockpit view
ttn('',{device=devices.COMMON, action=device_commands.Button_2}) --copilot seat
ttn('',{device=devices.COMMON, action=device_commands.Button_5}) --mask
ttn('',{device=devices.COMMON, action=device_commands.Button_1}) --pilot seat
ttn('',{device=devices.COMMON, action=device_commands.Button_5}) --mask

end

--#################################
-- start v0.1
-- If you have throttle bound to axis, set axis to max
ft['start'] = function(action)
    local valid = {engspool='engspool', posteng='posteng'}
    action = valid[action] or ''

    if action == '' then
        net.recv_chat('Begin start')
        -- Beginning of start procedure

ttf('Essential Bus Run/Start Switch')
ttn('FADEC Circuit Breaker Switch')
ttn('Ignition Circuit Breaker Switch')
ttn('Ignition Keylock Switch')
ttn('Battery 1 Switch')
ttt('Acknowledge/Recall Switch',{onvalue=-1})
--ttn('FADEC Auto/Manual Switch')

-- throttle to idle
ttn('',{device=devices.FUEL, action=device_commands.Button_5})
ttn('Start Switch')

    ft['start']('engspool')
    elseif action == 'engspool' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

        if rpm.left < 63 then
            loglocal('engspool 1 true '..DCS.getRealTime(), 4)
            if rpm.left > 1 then
                ttf('Start Switch')
                ttn('',{device=devices.FUEL, action=device_commands.Button_6})
            end
            ttt('Acknowledge/Recall Switch',{onvalue=-1})
            press('',{delay=1,fn=ft['start'],arg='engspool'})
        else
            ft['start']('posteng')
        end
    elseif action == 'posteng' then

ttn('DC Generator Switch')
ttn('AC Generator Switch')
ttn('Essential Bus Run/Start Switch')
ttn('Fuel Boost Switch')
--ttn('Particle Separator Circuit Breaker')
--SCAS
ttn('Power Switch')
ttn('Pitch/Roll Engage Switch')
ttn('Yaw Engage Switch')
ttn('BIT/Reset Switch') --MPD reset
ttn('Radar Warning Circuit Breaker Switch')
ttn('CMWS Circuit Breaker Switch')
--CI/CMWS
ttn('On/Off/Test Knob')
ttn('Arm/Safe Switch')
ttn('Auto/Bypass Switch')

        ft['setup']()
        net.recv_chat('End start. Wait for NAV align')
    end                         -- end of elseif action
end                             -- end of start

return ft

--[[ random bits of code
    
ttn('',{device=devices.AI, action=device_commands.Button_44}) --500ft
ttn('',{device=devices.AI, action=device_commands.Button_30}) --100kt
ttn('',{device=devices.AI, action=device_commands.Button_6}) --baro level
ttn('',{device=devices.AI, action=device_commands.Button_15}) --follow route
ttn('',{device=devices.AI, action=device_commands.Button_33}) --30ft
    
--]]
