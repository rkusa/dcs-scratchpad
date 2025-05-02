--[[ working functions:
    start - starts heli

    night - set night lighting
--]]

ft = {}
ft.order = {'start', 'setup', 'night'}

wpseq({ cur = 1, diff = 1, route = 't', })

--#################################
-- setup v0.1
-- cockpit config after autostart
--[[

--]]
ft['setup'] = function(arg)

--Navigation Lights 10%/30%/100%; disable
ttn('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_4})
ttf('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_4})
--Formation Lights; disble
ttn('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_2})
ttf('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_2})

ttf('Tip Lights')
ttf('Anticollision Light')
ttn('Manual/Auto weapon system control switch')
ttn('Master Arm')
tt('Dangerous RALT set rotary',{value=-1})

end                             -- end setup


--#################################
-- start v0.1
-- todo: handle external fuel tanks
--[[

--]]
ft['start'] = function(arg)
    local valid = {reng='reng', leng='leng', posteng='posteng', apudown='apudown'}
    arg = valid[arg] or ''

    local dbl = 0
    if arg == '' then
        ft['T1'] = DCS.getRealTime()

--front panel next to abris
ttn('ABRIS Power')

--close Door handle
ttn('',{device=devices.CPT_MECH, action=device_commands.Button_18})

--batteries and inverter; forward right wall
ttn('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_4})
ttn('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_3})
ttf('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_4})
ttn('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_6})
ttn('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_5})
ttf('',{device=devices.ELEC_INTERFACE, action=device_commands.Button_6})
ttn('DC/AC inverter')

--right wall
--[[
ttn('Intercom')
ttn('VHF-1 (R828) power switch')
ttn('VHF-2 (R-800) power switch')
ttn('R-800 (VHF-1) Radio channel selector')
ttn('Radio equipment datalink TLK power switch')
ttn('Radio equipment datalink UHF TLK power switch')
ttn('Radio equipment datalink SA-TLF power switch')
--]]
ttf('',{device=devices.CPT_MECH, action=device_commands.Button_2}) --EKRAN, hydraulics
ttf('',{device=devices.CPT_MECH, action=device_commands.Button_3}) --right rear wall
ttn('K-041 Targeting-navigation system power switch')  --front left console
ttn('INU Heater switch')
ttn('INU Power switch')
--[[
ttn('Helmet-mounted sight system power switch')
ttf('Laser standby ON/OFF switch')


ttn('',{device=devices.FIRE_EXTING_INTERFACE, action=device_commands.Button_6}) --fire extng oper
ttf('',{device=devices.FIRE_EXTING_INTERFACE, action=device_commands.Button_7}) --right wall
ttn('Standby Attitude Indicator power switch')
ttn('Navigation system power')
ttn('Ejecting system power')
ttf('Ejecting system power 1')
ttf('Ejecting system power 2')
ttf('Ejecting system power 3')
ttf('Ejecting system power')
--]]

--fuel pumps; right wall
ttn('Forward fuel tank pumps')
ttn('Rear fuel tank pumps')
ttn('Inner external fuel tanks pumps')
ttn('Outer external fuel tanks pumps')
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_8}) --left shutoff
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_8})
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_9})
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_6}) --right shutoff
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_6})
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_7})
ttn('Fuelmeter power')
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_10}) --APU shutoff
ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_10})
--ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_11})
--ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_12}) --xfeed
--ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_12})
--ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_13})
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_1}) --Left EEG
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_1})
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_2})
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_3}) --Right EEG
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_3})
ttn('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_4})

-- Left side seat
ttf('Rotor brake')--brake off(down)
Export.LoSetCommand(2004, 0) --throttle to auto(up)

ttf('Engine Startup/Crank/False Start selector') --engine start
tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0.3}) --Engine select APU
tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0}) --requires cycling
ttn('Start-up selected engine button')
--delay(20)

--start left engine
tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0.1})
ttn('Start-up selected engine button')

    ft['start']('leng')
    elseif arg == 'leng' then
        
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

        if rpm.left <= 15 then
            loglocal('Left engine apu spool', dbl)
            tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0.1})
            ttn('Start-up selected engine button')
            press('',{delay=1,fn=ft['start'], arg='leng'})
            return
        else
            if rpm.left <= 25 then
                loglocal('Left engine cut-off valve', dbl)
--            ttf('Start-up selected engine button')
                ttn('Left engine cut-off valve')
                press('',{delay=1,fn=ft['start'], arg='leng'})
                return
            else
                loglocal('left eng spool done '..rpm.left, dbl)
            end
        end
        ft['T2'] = DCS.getRealTime()

ttt('ABRIS Pushbutton 5')        
ttn('Intercom')
ttn('VHF-1 (R828) power switch')
ttn('VHF-2 (R-800) power switch')
ttn('R-800 (VHF-1) Radio channel selector')
ttn('Radio equipment datalink TLK power switch')
ttn('Radio equipment datalink UHF TLK power switch')
ttn('Radio equipment datalink SA-TLF power switch')
tt('Dangerous RALT set rotary',{value=-1})

--Weapon control system
ttn('',{device=devices.WEAP_INTERFACE, action=device_commands.Button_19})
ttn('',{device=devices.WEAP_INTERFACE, action=device_commands.Button_18})
ttf('',{device=devices.WEAP_INTERFACE, action=device_commands.Button_19})


--ttn('Helmet-mounted sight system power switch')
ttf('Laser standby ON/OFF switch')
ttn('',{device=devices.FIRE_EXTING_INTERFACE, action=device_commands.Button_6}) --fire extng oper
ttf('',{device=devices.FIRE_EXTING_INTERFACE, action=device_commands.Button_7}) --right wall
--Standby Attitude Indicator power switch
tt('',{device=devices.STBY_ADI, action=device_commands.Button_3, value=-1})
tt('',{device=devices.STBY_ADI, action=device_commands.Button_3, value=.06})
ttn('Navigation system power')
ttn('Ejecting system power')
ttf('Ejecting system power 1')
ttf('Ejecting system power 2')
ttf('Ejecting system power 3')
ttf('Ejecting system power')

--right wall
ttn('AC left generator')
ttn('AC right generator')
ttn('',{device=devices.IFF, action=device_commands.Button_1}) --IFF
ttn('',{device=devices.IFF, action=device_commands.Button_1})
ttn('',{device=devices.IFF, action=device_commands.Button_2})

--right rear wall
ttn('',{device=devices.UV_26, action=device_commands.Button_10}) --CMS on
ttn('',{device=devices.UV_26, action=device_commands.Button_10})
ttn('',{device=devices.UV_26, action=device_commands.Button_12})
ttn('LWS Power switch')


tt('Datalink Master mode', {value=.8})
ttn('NAV Datalink power')

ttn('HUD Filter')
ttn('Manual/Auto weapon system control switch')
ttn('Master Arm')
tt('NAV Master modes',{value=.3})


        -- start right engine
    ft['start']('reng')
    elseif arg == 'reng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        local dbl = 0
        
        if rpm.left < 60 then   -- wait for left to finish spooling
            press('',{delay=1,fn=ft['start'], arg='reng'})
            return
        end
        
        if rpm.right < 15 then
            loglocal('Right engine apu spool', dbl)
            tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0.2})
            ttt('Start-up selected engine button',{len=1})
            press('',{delay=1,fn=ft['start'], arg='reng'})
            return
        else
            loglocal('Right engine cut-off valve', dbl)
            ttf('Start-up selected engine button')
            ttn('Right engine cut-off valve')
            loglocal('Right eng spooled up ', dbl)
        end

    ft['start']('posteng')
    elseif arg == 'posteng' then
        ft['T3'] = DCS.getRealTime()


    ft['start']('apudown')
    elseif arg == 'apudown' then
        ft['T4'] = DCS.getRealTime()

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        if rpm.left < 60 or rpm.right < 60 then -- wait for both engines to spool up
            press('',{delay=1,fn=ft['start'], arg='apudown'})
            return
        else
            loglocal('Apu shutdown', dbl)
            ttt('Stop APU button')
            ttf('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_10})
            ttn('',{device=devices.FUELSYS_INTERFACE, action=device_commands.Button_11})
            tt('',{device=devices.ENGINE_INTERFACE, action=device_commands.Button_8, value=0})
        end

--right console
ttt('Autopilot Pitch hold')
ttt('Autopilot Bank hold')
ttt('Autopilot Heading hold')
ft['setup']()

        loglocal('total time: '..DCS.getRealTime() - ft['T1'])
        loglocal('leng time: '..ft['T2'] - ft['T1'])
        loglocal('reng time: '..ft['T3'] - ft['T2'])
        loglocal('post time: '..DCS.getRealTime() - ft['T3'])

    end                         -- end if start
end                             -- end start

--#################################
-- night v0.1
-- 

ft['night'] = function()

ttn('Lighting cockpit panel switch')
ttn('Lighting night vision cockpit switch')
ttn('Lighting ADI and SAI switch')
tt('HUD Modes Reticle/Night/Day', {value=-1})

ttf('Tip Lights')
ttf('Anticollision Light')

tt('Lighting night vision cockpit brightness knob', {value=.3})
tt('Lighting HSI and ADI brightness knob', {value=.3})
tt('Lighting cockpit panel brightness knob', {value=.3})
tt('ABRIS Brightness', {value=.2})
tt('NAV Brightness',{value=.2})

ttn('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_4}) --Navigation Lights 10%/30%/100%
ttf('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_4})
ttn('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_2}) --Formation Lights
ttf('', {device=devices.NAVLIGHT_SYSTEM, action=device_commands.Button_2})

end                             -- end night

return ft
