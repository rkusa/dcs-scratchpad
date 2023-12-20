--[[ working functions: start, mpd
--]]

ft ={}
ft.run={'start'}
--ft['test'] = function () loglocal('my test') end

--#################################
-- mpd v0.1
screens = {}
screens[devices.MPD_FLEFT] = {
    {'TEWS' ,'NAV'},
    {'A/G RDR' ,'A/G'},
    {'A/A RDR','A/A'}
}
screens[devices.MPCD_FCENTER] = {
    {'TSD' ,'NAV'}
}
screens[devices.MPD_FRIGHT] = {
    {'SMRT WPNS','A/G'},
    {'TPOD','NAV'},
    {'HSI' ,'A/A'}
}

---[[
screens[devices.MPCD_RLEFT] = {
    {'ADI' ,'NAV'},
    {'ARMT','A/G'},
    {'HSI' ,'A/A'}
}
screens[devices.MPD_RLEFT] = {
    {'ADI' ,'NAV'},
    {'ARMT','A/G'},
    {'HSI' ,'A/A'}
}
screens[devices.MPD_RRIGHT] = {
    {'ADI' ,'NAV'},
    {'ARMT','A/G'},
    {'HSI' ,'A/A'}
}
screens[devices.MPCD_RRIGHT] = {
    {'ADI' ,'NAV'},
    {'ARMT','A/G'},
    {'HSI' ,'A/A'}
}
--]]
ft.screens = screens

ft['mpd'] = function ()
    local button={}
    local i = 1
    for j=mfdg_commands.Button_01, mfdg_commands.Button_20 do
        button[i] = j
        i = i + 1
    end

    local menu = {}
    menu.ADI = {1}; menu.ARMT = {2}; menu.HSI = {3}; menu.TF = {4}
    menu.TSD = {5}; menu.SIT = {8}; menu.TPOD = {12}; menu.TEWS = {13}
    menu['A/G RDR'] = {14}; menu['A/A RDR'] = {15}; menu.VTRS = {16}
    menu.HUD = {17}; menu.ENG = {18}; menu.EVENT = {19}; menu.BIT = {20}
    menu['WIND MODEL'] = {6,11,1,6}; menu['A/G DLVRY'] = {6,11,2,6}; menu.IFF = {6,11,3,6}
    menu['DATA FRAME'] = {6,11,5,6}; menu.JTIDS = {6,11,13,6}; menu['SMRT WPNS'] = {11,14}
    menu['HUD PROG'] = {6,11,17,6}; menu['MC DTM'] = {6,11,19,6}; menu['SNSR MGMT'] = {6,11,11,1,6}
    menu['HMD-P'] = {6,11,11,8,6}; menu['HMD-W'] = {6,11,11,9,6}; menu['SP ENTRY'] = {6,11,11,13,6}
    menu['WDL COMM'] = {6,11,11,14,6}; menu['VID 8'] = {6,11,11,16,6}
    menu['VID RC'] = {6,11,11,17,6}; menu['VID 5'] = {6,6,11,11,18,6}
    menu['VID LC'] = {6,11,11,19,6}; menu['VID 2'] = {6,11,11,20,6}

    local menu2 = {}
    menu2['A/A'] = {7}; menu2['A/G'] = {7, 7}; menu2.NAV = {7,7,7}

    local debug=nil
    for dev=devices.MPD_FLEFT, devices.MPCD_RRIGHT+1 do
        if screens[dev] then
            screen = screens[dev]
            for x,y in pairs(screen) do
                if debug then loglocal('PROG: 6')
                else ttt('Power Switch',{device=dev, action=button[6]}) end

                for i,j in pairs(menu[y[1]]) do
                    if debug then loglocal('PAGE: '..y[1]..'='..y[2]..'j: '..j)
                    else ttt('Power Switch',{device=dev, action=button[j]}) end
                end

                if type(y[2]) == 'string' and #y[2] == 3 then
                    for k=1, #menu2[y[2]] do
                        if debug then loglocal('MM: '..menu2[y[2]][k])
                        else ttt('Power Switch',{device=dev, action=button[menu2[y[2]][k]]}) end
                    end
                    if debug then loglocal('MM SET: '..menu[y[1]][#menu[y[1]]])
                    else ttt('Power Switch',{device=dev, action=button[menu[y[1]][#menu[y[1]]]]}) end
                    if debug then loglocal('MM3 finalize:2x 6')
                    else ttt('Power Switch',{device=dev, action=button[6]}) end
                end  -- if type
            end --for x,y
        end --if screens
    end --for tmp

    if not debug then ttt('Power Switch',{device=de, action=button[6]}) end

end --end of mpd()

--#################################
-- start v0.5
-- You will need to set INS knob to NAV when OK
ft['firstspool'] = true
ft['engspool'] = function()
    rpm = Export.LoGetEngineInfo().RPM
    loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

    if rpm.right < 21 then
        loglocal('engspool 1 true '..DCS.getRealTime(), 4)
        press('',{delay=1,fn=ft['engspool']})
    else
        if rpm.right < 50 then
            loglocal('engspool 2 true ', 4)
            if ft['firstspool'] then
                Export.LoSetCommand(2006, -1)
                ft['firstspool'] = false
            else
                Export.LoSetCommand(2006, 1)
            end
            press('',{delay=1,fn=ft['engspool']})
        else
            if rpm.left == 0 then
                ttt('Left Throttle Finger Lift')
                press('',{delay=1,fn=ft['engspool']})
                ft['firstspool'] = true
            else
                if rpm.left < 21 then
                    press('',{delay=1,fn=ft['engspool']})
                else
                    Export.LoSetCommand(2005, -1)
                end
            end
        end
    end
end

ft['start'] = function ()

tt('Oxygen Supply/Mode Control Switch',{action=oxyctrl_commands.oxy_pbg_on_off_sw,value=.5})
tt('Left Generator')
tt('Right Generator')
tt('Left Engine Control Switch')
tt('Right Engine Control Switch')
tt('Left Engine Master Switch Cover')
delay(.1)
tt('Left Engine Master Switch')
ttf('Left Engine Master Switch Cover')
tt('Right Engine Master Switch Cover')
delay(.1)
tt('Right Engine Master Switch')
ttf('Right Engine Master Switch Cover')
tt('Jet Starter')

tt('Air Conditiong Auto/Manual/Off') --TT is misspelled for this switch
tt('Air Conditiong Max/Norm/Min',{value=-1})

ttf('Fuel Control: Conformal Tanks')
ttf('Left Inlet Ramp Switch')
ttf('Right Inlet Ramp Switch')
tt('Yaw CAS Switch, when ON (LMB) RESET/(RMB) OFF')
tt('Roll CAS Switch, when ON (LMB) RESET/(RMB) OFF')
tt('Pitch CAS Switch, when ON (LMB) RESET/(RMB) OFF')
tt('JFS Control Handle, (LMB)PULL/(RMB)ROTATE')

--WSO
tt('Oxygen Supply/Mode Control Switch',{action=oxyctrl_commands.wso_oxy_PBG_on_off_sw,value=.5})
ttn('ICS ON/OFF Switch')
ttn('RWR ON/OFF Switch')
ttn('EWWS ON/OFF Switch')
tt('CMD Operational Mode OFF/STBY/MAN/SEMI/AUTO',{value=.6})
tt('TGP Power Switch OFF/STBY/ON',{value=1})
tt('TGP Laser Switch SAFE/ARM')
tt('RWR/ICS Mode Switch COMBAT/TRNG')
tt('ECM PODS Mode Switch XMIT/STBY')
tt('ICS Operational Mode Switch STBY/AUTO/MAN')
ttn('Seat Arm Handle',{action=misc_commands.seat_arm_handle_rc})
-- end WSO

ttn('Seat Arm Handle',{action=misc_commands.seat_arm_handle})
tt('Canopy Handle',{value=.5})

-- Turn on all MFDs
tt('Power Switch',{device=devices.MPD_FLEFT, value=-1})
tt('Power Switch',{device=devices.MPD_FLEFT, value=0})
tt('Power Switch',{device=devices.MPD_FRIGHT, value=-1})
tt('Power Switch',{device=devices.MPD_FRIGHT, value=0})
tt('Power Switch',{device=devices.MPCD_FCENTER, value=-1})
tt('Power Switch',{device=devices.MPCD_FCENTER, value=0})
tt('Power Switch',{device=devices.MPD_FLEFT, value=-1})
tt('Power Switch',{device=devices.MPD_FLEFT, value=0})

tt('Power Switch',{device=devices.MPCD_RLEFT, value=-1})
tt('Power Switch',{device=devices.MPCD_RLEFT, value=0})
tt('Power Switch',{device=devices.MPD_RLEFT, value=-1})
tt('Power Switch',{device=devices.MPD_RLEFT, value=0})
tt('Power Switch',{device=devices.MPD_RRIGHT, value=-1})
tt('Power Switch',{device=devices.MPD_RRIGHT, value=0})
tt('Power Switch',{device=devices.MPcD_RRIGHT, value=-1})
tt('Power Switch',{device=devices.MPCD_RRIGHT, value=0})

ttn('UFC LCD Brightness',{device=devices.UFCCTRL_FRONT})
ttn('UFC LCD Brightness',{device=devices.UFCCTRL_REAR})
ttt('Left UHF Preset Channel Selector', {device=devices.UFCCTRL_FRONT}) --check these 2
ttn('Right UHF Preset Channel Selector', {device=devices.UFCCTRL_FRONT})
ttn('HUD Brightness Control')

tt('Terrain Follow Radar Switch',{value=.5})
ttn('Radar Altitude Switch')
tt('INS Knob',{value=.25})
tt('Radar Mode Selector',{value=.25})
tt('Nav FLIR Switch',{value=.5})
tt('Fuel Totalizer Selector')

for i=1, 20 do                  -- bingo at 2k lb
  ttn('Bingo Selection')
end

ttt('T/O Trim Button')

ttn('Canopy Handle')

ttt('Right Throttle Finger Lift') --idle at 21%
ft['engspool']()

end                             -- end of start1()

return ft
