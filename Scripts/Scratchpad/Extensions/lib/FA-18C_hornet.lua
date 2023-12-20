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


end  --end of fence()



--#################################
--start v.5

ft['lengspool'] = function()
    rpm = Export.LoGetEngineInfo().RPM
    loglocal('lengspool rpm: '..rpm.left..' : '..rpm.right)
    local dbl = 0

    if rpm.left == 0 then
        tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw, value=-1})
        delay(5)
        ttf('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw})
        press('',{delay=1,fn=ft['lengspool']})
    else
        if rpm.left < 15 then
            press('',{delay=1,fn=ft['lengspool']})
        else
            Export.LoSetCommand(311)
        end
    end
end                             -- end of lengspool()

ft['start-1'] = function()

tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.3})
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=0})
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.1})
delay(.25)
tt('Bleed Air Knob, R OFF/NORM/L OFF/OFF',{value=.2})

--opt set radar altimeter
push_start_command(0, {device = devices.RADAR, action = RADAR_commands.RADAR_SwitchChange, value = 0.1})

ttf('FLAP Switch, AUTO/HALF/FULL')

tt('Attitude Selector Switch, INS/AUTO/STBY',{value=0})
ttn('OBOGS Control Switch, ON/OFF')

--tt('Altitude Switch, BARO/RDR',{value=-1})
tt('IR Cooling Switch, ORIDE/NORM/OFF',{value=.1})
tt('DISPENSER Switch, BYPASS/ON/OFF',{value=.1})
tt('ECM Mode Switch, XMIT/REC/BIT/STBY/OFF',{value=.1})
ttn('ALR-67 POWER Pushbutton')
ttf('FLIR Switch, ON/STBY/OFF')


ttt('UFC Function Selector Pushbutton, IFF')
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

ttt('Right MDI PB 10') --BIT STOP
ttn('FCS RESET Button')
delay(1)
ttf('FCS RESET Button')
ttt('T/O TRIM Button')

--INS alignment
push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.2})
tt('AMPCD PB 19')
--delay(100)
--push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.4})


ft['lengspool']()

end                             --end of start-1()

ft['rengspool'] = function()
    rpm = Export.LoGetEngineInfo().RPM
    loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
    local dbl = 0

    if rpm.right == 0 then
        tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw, value=1})
        delay(5)
        ttf('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw})
        press('',{delay=1,fn=ft['rengspool']})
        return
    else
        if rpm.right < 15 then
            loglocal('rengspool 1 true '..DCS.getRealTime(), dbl)
            press('',{delay=1,fn=ft['rengspool']})
            return
        else
            if rpm.right < 50 then
                loglocal('rengspool 2 true ', dbl)
                Export.LoSetCommand(312)
                press('',{delay=1,fn=ft['rengspool']})
                return
            else
                loglocal('rengspool 3 true ', dbl)
            end
        end
    end

    ft['start-1']()
end                             -- end of rengspool()

ft['start'] = function ()

tt('Ejection Seat SAFE/ARMED Handle, SAFE/ARMED',{value=-1})
tt('Battery Switch, ON/OFF/ORIDE')
ttn('APU Control Switch, ON/OFF')
--delay(1)
--ttf('APU Control Switch, ON/OFF')

tt('Canopy Control Switch, OPEN/HOLD/CLOSE',{value=-1})
delay(10)

tt('Left MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('Right MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('UFC Brightness Control Knob',{value=.9})
tt('HUD Symbology Brightness Control Knob',{value=.9})
tt('AMPCD Off/Brightness Control Knob',{value=.9})
tt('UFC COMM 1 Volume Control Knob',{value=.9})
tt('UFC COMM 2 Volume Control Knob',{value=.9})
tt('HMD OFF/BRT Knob',{value=.9})

delay(3)

ft['rengspool']()
end                             -- end of start


return ft
