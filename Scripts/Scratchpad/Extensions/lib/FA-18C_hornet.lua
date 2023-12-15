--[[ working functions: start, mpd, toopylon
--]]

local ft ={}

--#################################
-- toopylon
ft['toopylon'] = function ()
  tt('Left MDI PB 5')
delay(.2)
  tt('Left MDI PB 13')
delay(.2)
  tt('Left MDI PB 5')
delay(.2)
  tt('Left MDI PB 13')
delay(.2)
  tt('Left MDI PB 5')
delay(.2)
  tt('Left MDI PB 13')
delay(.2)
  tt('Left MDI PB 5')
delay(.2)
  tt('Left MDI PB 13')
delay(.2)

tt('Left MDI PB 11')
delay(.2)
tt('Left MDI PB 15')
delay(.4)
tt('Left MDI PB 11')
delay(.2)
tt('Left MDI PB 12')
delay(.2)
tt('Left MDI PB 13')
delay(.2)
tt('Left MDI PB 14')
delay(.2)
tt('Left MDI PB 15')
delay(.2)
tt('Left MDI PB 6')
end

--#################################
--fence
ft['fence'] = function ()

tt('FLIR Switch, ON/STBY/OFF', {value=0})

--tt('ALR-67 POWER Pushbutton')
tt('UFC Function Selector Pushbutton, IFF')
tt('UFC Function Selector Pushbutton, ON/OFF')
delay(.5)
tt('UFC Function Selector Pushbutton, D/L')
tt('UFC Function Selector Pushbutton, ON/OFF')
delay(.5)
tt('UFC Function Selector Pushbutton, D/L')
tt('UFC Function Selector Pushbutton, ON/OFF')
--tt('Altitude Switch, BARO/RDR')

--disable moving map
tt('AMPCD PB 3')
tt('AMPCD PB 3')
tt('Right MDI PB 10')

--setup SA page

tt('HUD Symbology Brightness Control Knob', {value=1})
tt('AMPCD Off/Brightness Control Knob',{value=1})

end  --end of fence()



--#################################
--start
ft['start'] = function ()
tt('Ejection Seat SAFE/ARMED Handle, SAFE/ARMED',{value=-1})
tt('Battery Switch, ON/OFF/ORIDE')
ttn('APU Control Switch, ON/OFF')
delay(1)
ttf('APU Control Switch, ON/OFF')
tt('Canopy Control Switch, OPEN/HOLD/CLOSE',{value=-1})

delay(10)
tt('Left MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('Right MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('UFC Brightness Control Knob',{value=.9})
tt('HUD Symbology Brightness Control Knob',{value=.9})
tt('AMPCD Off/Brightness Control Knob',{value=.9})
tt('UFC COMM 1 Volume Control Knob',{value=.9})
tt('UFC COMM 2 Volume Control Knob',{value=.9})
 
delay(4)
--right engine, throttle off
tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw, value=1})
delay(5)
tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw, value=0})
--right throttle idle RSHFT HOME %15

tt('HMD OFF/BRT Knob',{value=.9})
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.3})
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=0})
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.1})
delay(.25)
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.2})

--opt set radar altimeter

push_start_command(0, {device = devices.RADAR, action = RADAR_commands.RADAR_SwitchChange, value = 0.1})

ttf('FLAP Switch, AUTO/HALF/FULL')

tt('Attitude Selector Switch, INS/AUTO/STBY',{value=-1})
tt('Attitude Selector Switch, INS/AUTO/STBY',{value=0})
ttn('OBOGS Control Switch, ON/OFF')

--tt('Altitude Switch, BARO/RDR',{value=-1})
tt('IR Cooling Switch, ORIDE/NORM/OFF',{value=.1})
tt('DISPENSER Switch, BYPASS/ON/OFF',{value=.1})
tt('ECM Mode Switch, XMIT/REC/BIT/STBY/OFF',{value=.1})
ttn('ALR-67 POWER Pushbutton')
ttf('FLIR Switch, ON/STBY/OFF')

delay(30)
--left engine, throttle off
tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw, value=-1})
delay(5)
ttf('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw})
--Left throttle idle RALT HOME %15

ttt('Right MDI PB 10') --BIT STOP
ttn('FCS RESET Button')
delay(1)
ttf('FCS RESET Button')
ttt('T/O TRIM Button')

push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.2})
--[[
delay(5)
ttt('AMPCD PB 10')
delay(80)
ttt('AMPCD PB 3')
ttt('AMPCD PB 3')
delay(20)
push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.4})

--]]
--tt('INS Switch, OFF/CV/GND/NAV/IFA/GYRO/GB/TEST',{value=0})

end --end of start()

return ft
