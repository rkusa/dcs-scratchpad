--[[ working functions:
    start
--]]

--#################################
-- Mi8 Startup v0.91
-- This start will crank engines hands off. Currently implemented with
-- delays, could be updated to use GetEngineInfo(). Heli will be ready
-- to fly once both engines have spooled up to 80% rpm.

ft = {}
ft['start'] = function ()

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
tt('Engine Selector Switch, LEFT/OFF/RIGHT', {value=-1})
ttn('Engine Start Mode Switch, START/OFF/COLD CRANKING')
ttf('Engine Start Button - Push to start engine')
ttn('Engine Start Button - Push to start engine')
ttn('Left Engine Stop Lever')

delay(1)
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
ttn('Right Attitude Indicator Power Switch, ON/OFF')
ttn('R-828, Power Switch, ON/OFF')
ttn('CMD Power Switch, ON/OFF')

delay(95)

tt('Engine Selector Switch, LEFT/OFF/RIGHT', {value=1})
ttf('Engine Start Button - Push to start engine')
ttn('Engine Start Button - Push to start engine')
ttn('Right Engine Stop Lever')
ttn('Generator 1 Switch, ON/OFF')
ttn('Generator 2 Switch, ON/OFF')
ttn('Rectifier 1 Switch, ON/OFF')
ttn('Rectifier 2 Switch, ON/OFF')
ttn('Rectifier 3 Switch, ON/OFF')
ttn('Autopilot Pitch/Roll ON Button/Lamp Intensity Knob. Rotate mouse wheel to set lamp intensity')

tt('Dangerous RALT Knob',{value=-1})

end  -- end of start

return ft
