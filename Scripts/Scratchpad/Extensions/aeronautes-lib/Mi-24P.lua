--[[ working functions:
    start - starts heli
--]]

ft = {}

--#################################
-- start v0.2
-- todo: handle external fuel tanks
--[[
04:26:01] total time: 130.4600423
[04:26:01] eng1 time: 76.0892894
[04:26:01] posteng time: 54.3704036
--]]
ft['start'] = function(arg)
    local valid = {reng='reng', leng='leng', posteng='posteng'}
    arg = valid[arg] or ''

    if arg == '' then
        ft['T1'] = DCS.getRealTime()
    
ttf('Pilot Door Safety Lock, OPEN/CLOSE')

-- Right Console, electric
ttn('Right Battery switch, ON/OFF')
ttn('Left Battery switch, ON/OFF')
tt('DC Voltmeter knob', {value=.2})
ttn('Inverter PO-750A Cover, UP/DOWN')
ttn('Inverter PO-750A, ON/OFF')
ttt('All Left CBs ON')
ttt('All Right CBs ON')
ttn('Network to Batteries cover, UP/DOWN')
ttn('Network to Batteries, ON/OFF')

--[[ does nothing
ttn('Main/Auxiliary Hydraulic Switch Cover, UP/DOWN')
ttn('Main/Auxiliary Hydraulic Switch, MAIN/AUXILIARY', {value=1})
ttf('Main/Auxiliary Hydraulic Switch Cover, UP/DOWN')
--]]

ttf('Sealing, OPEN/CLOSE')

--Left forward wall
ttn('Feed Tank 1 Valve Switch, OPEN/CLOSE')
ttn('Feed Tank 2 Valve Switch, OPEN/CLOSE')
ttn('Left Engine Fire Valve Cover, UP/DOWN')
ttn('Left Engine Fire Valve, OPEN/CLOSE')
ttf('Left Engine Fire Valve Cover, UP/DOWN')
ttn('Right Engine Fire Valve Cover, UP/DOWN')
ttn('Right Engine Fire Valve, OPEN/CLOSE')
ttf('Right Engine Fire Valve Cover, UP/DOWN')
ttn('Tank 4 Pump, ON/OFF')
ttn('Tank 5 Pump, ON/OFF')
ttn('Tank 1 Pump, ON/OFF')
ttn('Tank 2 Pump, ON/OFF')

-- Left Console, levers
ttf('Left Engine Stop')
ttf('Right Engine Stop')
ttf('Rotor Brake')
--Export.LoSetCommand(2004,1)  --throttle

-- Left rear wall, apu
tt('APU Launch Method START/CRANK/FALSE', {value=-1})
ttt('APU Start')
delay(23)
tt('Engine Launch Method START/CRANK', {value=-1})
ttn('Engine Select RIGHT/LEFT')
ttt('Engine Start')

    ft['start']('leng')
    elseif arg == 'leng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        local dbl = 0

        if rpm.left == 0 then
            ttt('Engine Start')
            press('',{delay=1,fn=ft['start'], arg='leng'})
            return
        elseif rpm.left < 77 then
            ft['T2'] = DCS.getRealTime()
            loglocal('leng 2 true ', dbl)
            press('',{delay=1,fn=ft['start'], arg='leng'})
            return
        else
            loglocal('left eng spooled up ', dbl)
        end

ttf('Engine Select RIGHT/LEFT')
ttt('Engine Start')

    ft['start']('reng')
    elseif arg == 'reng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        local dbl = 0

        if rpm.right == 0 then
            ttt('Engine Start')
            press('',{delay=1,fn=ft['start'], arg='reng'})
            return
        elseif rpm.right < 40 then
            loglocal('reng 2 true ', dbl)
            press('',{delay=1,fn=ft['start'], arg='reng'})
            return
        else
            loglocal('right eng spooled up ', dbl)
        end

    ft['start']('posteng')
    elseif arg == 'posteng' then
        ft['T3'] = DCS.getRealTime()
--collective throttle up
-- Right Power Console
ttn('Cabin Unseal Switch, ON/OFF')
ttn('Blowdown Conditioning Switch, CONDITIONING/OFF/BLOWDOWN')

ttn('Fire Extinguisher Power ON/OFF')
ttn('Extinguisher Control Switch EXING/CNTRL')
        
-- Right console, electric
ttn('Right Generator switch, ON/OFF')
ttn('Left Generator switch, ON/OFF')
ttn('AC Transformer 115v, MAIN/AUTO/BACKUP')
ttn('AC Transformer 36v, MAIN/AUTO/BACKUP')
ttn('Left Rectifier switch, ON/OFF')
ttn('Right Rectifier switch, ON/OFF')

--anti-ice knob mislabeled AC Voltmeter as well
tt('AC Voltmeter knob', {device=devices.ELEC_INTERFACE, action=elec_commands.ACGangSwitcher, value=.6})  

-- Left wall
ttn('Switch SPU-8 NET-2 ON/OFF')
ttn('Switch SPU-8 NET-1 ON/OFF')
ttn('R-863 ON/OFF')
ttn('Jadro-1I ON/OFF')
ttn('R-828 ON/OFF')
ttn('RV-5 ON/OFF')
ttn('DISS-15D ON/OFF')
ttn('Gyro 1 Power, ON/OFF')
ttn('Gyro 2 Power, ON/OFF')
ttn("Greben' ON/OFF")
ttn('RWR Power')
--ttn('RWR Signal')
ttn('Blinker Switch, ON/OFF')
ttn('IFF Transponder Power Switch, ON/OFF')
ttn('ARC-U2 switcher On/Off')

--Front console
ttt('Cage Gyro 1')
ttt('Cage Gyro 2')

--Left wall
--tt('ARC-15 mode OFF/COMPASS/ANT/FRAME',{value=.5})  --not working

ttn('SPUU Power ON/OFF')
ttt('Autopilot K Channel ON')
ttt('Autopilot T Channel ON')

tt('DISS select mode IDK/IDK/IDK/MEM/OPER',{value=1})
ttn('Map Power ON/OFF')
ttn('Armament Panel Red Lights Switch, ON/OFF')

--Center console
ttn('Sight Power ON/OFF')
tt('Burst Length SHORT/MED/LONG',{action=weapon_commands.Pilot_NPU_CHAIN, value=-1})
ttn('Sight distance MANUAL/AUTO')
ttn('Weapon Control ON/OFF')
ttn('Cannon Fire Rate SLOW/FAST', {action=weapon_commands.Pilot_TEMP_NPU30})
ttn('Sight mode MANUAL/AUTO')
ttn('Sight mode SYNC/ASYNC')

-- Right console, electric
ttf('Inverter PO-750A Cover, UP/DOWN')
ttf('Network to Batteries cover, UP/DOWN')

-- Left rear wall, apu
ttt('APU Stop')

-- Radar altimeter adjust and test; set to 0
push_stop_command(0, {device=devices.RADAR_ALTIMETER, action=ralt_commands.ROTARY, value=-1})
push_stop_command(0, {device=devices.RADAR_ALTIMETER, action=ralt_commands.ROTARY, value=-1})

loglocal('total time: '..DCS.getRealTime() - ft['T1'])
loglocal('leng time: '..ft['T2'] - ft['T1'])
loglocal('reng time: '..ft['T3'] - ft['T2'])
loglocal('post time: '..DCS.getRealTime() - ft['T3'])
    end -- end arg
end                             -- end of start

return ft
