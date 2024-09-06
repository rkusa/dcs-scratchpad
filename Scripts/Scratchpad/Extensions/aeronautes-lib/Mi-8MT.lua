--[[ working functions:
    start
--]]

--#################################
-- Mi8 Startup v0.92
-- This start will crank engines hands off. Heli will be ready
-- to fly once both engines have spooled up to 80% rpm.
-- Requires engine throttle axis set to full before starting.

ft = {}
ft['start'] = function (action)
    if type(action) == 'table' then
-- Beginning of start procedure

        net.recv_chat('Starting Mi-8')
ttn('Radio/ICS Switch',{action=device_commands.Button_4})

ttn('Battery 1 Switch, ON/OFF')
ttn('Battery 2 Switch, ON/OFF')
tt('115V Inverter Switch, MANUAL/OFF/AUTO',{value=-1})
tt('36V Inverter Switch, MANUAL/OFF/AUTO',{value=-1})
ttt('CB Group 4 ON')
ttt('CB Group 5 ON')
ttt('CB Group 6 ON')
ttt('CB Group 7 ON')
ttt('CB Group 8 ON')
ttt('CB Group 9 ON')
ttn('Fire Detector Test Switch')

net.recv_chat('Start APU')
ttn('APU Start Mode Switch, START/COLD CRANKING/FALSE START')
ttn('APU Start Button - Push to start APU')
ttn('Left Shutoff Valve Switch Cover, OPEN/CLOSE')
ttn('Right Shutoff Valve Switch Cover, OPEN/CLOSE')
ttn('Left Shutoff Valve Switch, ON/OFF')
ttn('Right Shutoff Valve Switch, ON/OFF')
ttf('Left Shutoff Valve Switch Cover, OPEN/CLOSE')
ttf('Right Shutoff Valve Switch Cover, OPEN/CLOSE')
ttn('Right Tank Pump Switch, ON/OFF')
ttn('Left Tank Pump Switch, ON/OFF')
ttn('Feed Tank Pump Switch, ON/OFF')
ttf('Rotor Brake Handle, UP/DOWN')
net.recv_chat('Start left engine')
tt('Engine Selector Switch, LEFT/OFF/RIGHT', {value=-1})
ttn('Engine Start Mode Switch, START/OFF/COLD CRANKING')
ttf('Engine Start Button - Push to start engine')
ttn('Engine Start Button - Push to start engine')
ttn('Left Engine Stop Lever')

--delay(1)
ttn('Left Blister, OPEN/CLOSE')
ttn('Left Attitude Indicator Power Switch, ON/OFF')
ttn('VK-53 Power Switch, ON/OFF')
ttn('SPUU-52 Power Switch, ON/OFF')
ttn('RI-65 Power Switch, ON/OFF')
ttn('Radar Altimeter Power Switch, ON/OFF')
tt('Fuel Meter Switch, OFF/SUM/LEFT/RIGHT/FEED/ADDITIONAL', {value=0.1})
ttn('Doppler Navigator Power Switch, ON/OFF')
ttn('Jadro 1A, Power Switch, ON/OFF')
ttn('GMC Power Switch, ON/OFF')
ttn('5.5V Lights Switch, ON/OFF')
tt('Left Red Lights Brightness Group 1 Rheostat',{value=1})
tt('Left Red Lights Brightness Group 2 Rheostat',{value=1})
tt('Right Red Lights Brightness Group 2 Rheostat',{value=1})
tt('Right Red Lights Brightness Group 2 Rheostat',{value=1})
tt('5.5V Lights Brightness Rheostat',{value=1})
ttn('Right Attitude Indicator Power Switch, ON/OFF')
ttn('R-828, Power Switch, ON/OFF')
ttn('CMD Power Switch, ON/OFF')
tt('CMD Board Flares Dispensers Switch, LEFT/BOTH/RIGHT',{value=.5})
push_stop_command(0,{device=devices.RADAR_ALTIMETER, action=device_commands.Button_1, value=-1})
push_stop_command(0,{device=devices.RADAR_ALTIMETER, action=device_commands.Button_1, value=-1})

        ft['start']('leng')
    elseif action == 'leng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('leng rpm: '..rpm.left..' : '..rpm.right)

        if rpm.left == 0 then
            ttf('Engine Start Button - Push to start engine')
            ttn('Engine Start Button - Push to start engine')
            press('',{delay=1,fn=ft['start'], arg='leng'})
            return
        else
            if rpm.left < 60 then
                press('',{delay=1,fn=ft['start'], arg='leng'})
                return
            end
        end
        ft['start']('postleng')
    elseif action == 'postleng' then

        net.recv_chat('Start right engine')
tt('Engine Selector Switch, LEFT/OFF/RIGHT', {value=1})
ttf('Engine Start Button - Push to start engine')
ttn('Engine Start Button - Push to start engine')
ttn('Right Engine Stop Lever')

        ft['start']('reng')
    elseif action == 'reng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('reng rpm: '..rpm.left..' : '..rpm.right)

        if rpm.right == 0 then
            ttf('Engine Start Button - Push to start engine')
            ttn('Engine Start Button - Push to start engine')
            press('',{delay=1,fn=ft['start'], arg='reng'})
            return
        else
            if rpm.right < 60 then
                press('',{delay=1,fn=ft['start'], arg='reng'})
                return
            end
        end
        ft['start']('postreng')
    elseif action == 'postreng' then

        net.recv_chat('Apu off')
ttt('APU Stop Button - Push to stop APU')
ttn('Generator 1 Switch, ON/OFF')
ttn('Generator 2 Switch, ON/OFF')
ttn('Rectifier 1 Switch, ON/OFF')
ttn('Rectifier 2 Switch, ON/OFF')
ttn('Rectifier 3 Switch, ON/OFF')
ttn('Autopilot Pitch/Roll ON Button/Lamp Intensity Knob. Rotate mouse wheel to set lamp intensity')

    end                         -- end of action

    net.recv_chat('Start finished')
end  -- end of start

return ft
