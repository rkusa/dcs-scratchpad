--[[ working functions:
    start - starts jet and engines
    mpd - configures pages and modes. Modify screens{} table to configure values
    A/Gload - programs the A/G Combat Weapon Load menu with munitions that are loaded on jet
    night - night lighting
--]]

-- module specific configuration
wpseq({cur=1, diff = 1, route = '.B'})

ft ={}
ft.order={'start', 'mpd', 'A/Gload', 'night', 'day'}

--#################################
-- mpd v0.10
-- This is setup to run immediately after startup. Edit the table
-- below to configure the screens as you desire

screens = {}
screens[devices.MPD_FLEFT] = {
    {'TEWS' ,'NAV'},
    {'A/G RDR' ,'A/G'},
    {'A/A RDR','A/A'}
}
screens[devices.MPCD_FCENTER] = {
    {'TSD' ,'NAV'},
    {'HSI','A/G'},
}
screens[devices.MPD_FRIGHT] = {
    {'HSI','NAV'},
    {'SMRT WPNS','A/G'},
    {'TPOD' ,'A/A'}
}
---[[change this to block comment to prevent setting WSO MPCDs
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
    menu['ADI'] = {1}; menu['ARMT'] = {2}; menu['HSI'] = {3}; menu['TF'] = {4}
    menu['TSD'] = {5}; menu['SIT'] = {8}; menu['TPOD'] = {12}; menu['TEWS'] = {13}
    menu['A/G RDR'] = {14}; menu['A/A RDR'] = {15}; menu['VTRS'] = {16}
    menu['HUD'] = {17}; menu['ENG'] = {18}; menu['EVENT'] = {19}; menu['BIT'] = {20}
    menu['WIND MODEL'] = {6,11,1,6}; menu['A/G DLVRY'] = {6,11,2,6}; menu['IFF'] = {6,11,3,6}
    menu['DATA FRAME'] = {6,11,5,6}; menu['JTIDS'] = {6,11,13,6}; menu['SMRT WPNS'] = {11,14}
    menu['HUD PROG'] = {6,11,17,6}; menu['MC DTM'] = {6,11,19,6}; menu['SNSR MGMT'] = {6,11,11,1,6}
    menu['HMD-P'] = {6,11,11,8,6}; menu['HMD-W'] = {6,11,11,9,6}; menu['SP ENTRY'] = {6,11,11,13,6}
    menu['WDL COMM'] = {6,11,11,14,6}; menu['VID 8'] = {6,11,11,16,6}
    menu['VID RC'] = {6,11,11,17,6}; menu['VID 5'] = {6,6,11,11,18,6}
    menu['VID LC'] = {6,11,11,19,6}; menu['VID 2'] = {6,11,11,20,6}

    local menu2 = {}
    menu2['A/A'] = {7}; menu2['A/G'] = {7, 7}; menu2['NAV'] = {7,7,7}

    local debug=nil
    for dev=devices.MPD_FLEFT, devices.MPCD_RRIGHT+1 do
        if screens[dev] then
            screen = screens[dev]
            ttt('Power Switch', {device=dev})
            ttt('Power Switch', {device=dev, onvalue=-1})
            for x,y in pairs(screen) do
                if debug then
                    loglocal('PROG: 6')
                else
                    ttt('Power Switch',{device=dev, action=button[6]})
                end

                for i,j in pairs(menu[y[1]]) do
                    if debug then loglocal('PAGE: '..y[1]..'='..y[2]..' j: '..j)
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
-- start v0.6
-- You will need to set INS knob to NAV when OK on HUD, after engine
-- has started.

ft['firstspool'] = true
ft['start'] = function (action)
    local valid = {engspool='engspool', posteng='posteng'}
    action = valid[action] or ''

    if action == '' then
        ft['T1'] = DCS.getRealTime()

        -- Beginning of start procedure

ttn('Parking Break Switch')
tt('MIC Switch', {action=micsctrl_commands.mic_sw, value=.5})
tt('MIC Switch', {value=.5})
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
tt('UHF Radio 1 Volume', {value=1})
tt('UHF Radio 2 Volume', {value=1})

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

ttn('Flaps Control Switch')

ttt('Right Throttle Finger Lift') --idle at 21%

    ft['start']('engspool')
    elseif action == 'engspool' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

        if rpm.right < 21 then
            loglocal('engspool 1 true '..DCS.getRealTime(), 4)
            press('',{delay=1,fn=ft['start'],arg='engspool'})
        else
            if rpm.right < 50 then
                loglocal('engspool 2 true ', 4)
                if ft['firstspool'] then
                    Export.LoSetCommand(2006, -1)
                    ft['firstspool'] = false
                else
                    Export.LoSetCommand(2006, 1)
                end
                press('',{delay=1,fn=ft['start'],arg='engspool'})
            else
                if rpm.left == 0 then
                    ttt('Left Throttle Finger Lift')
                    press('',{delay=1,fn=ft['start'],arg='engspool'})
                    ft['firstspool'] = true
                else
                    if rpm.left < 21 then
                        press('',{delay=1,fn=ft['start'],arg='engspool'})
                    else
                        if rpm.left < 50 then
                            if ft['firstspool'] then
                                Export.LoSetCommand(2005, -1)
                                ft['firstspool'] = false
                            else
                                Export.LoSetCommand(2005, 1)
                            end
                            press('',{delay=1,fn=ft['start'],arg='engspool'})
                        else
                            press('',{delay=1,fn=ft['start'],arg='posteng'})
                        end
                    end
                end
            end
        end
    elseif action == 'posteng' then
        ttt('Data Key',{device=devices.UFCCTRL_FRONT})
        ttt('NAV Master Mode Selector')
        --[[
            loglocal('total time: '..DCS.getRealTime() - ft['T1'])
            loglocal('leng time: '..ft['T2'] - ft['T1'])
            loglocal('reng time: '..ft['T3'] - ft['T2'])
            loglocal('post time: '..DCS.getRealTime() - ft['T3'])
        --]]
    end                         -- end of elseif action
end                             -- end of start()


-- used during devel to show CLSID of loaded munitions
function showpayload()
    local sta = {2,4,8,12,14}
    pl=Export.LoGetPayloadInfo().Stations --;loglocal(net.lua2json(pl))
    for i=1,#pl do --for _,i in pairs(sta) do
        if #pl[i].CLSID > 0 then
            local wt=pl[i].weapon
            local wname = Export.LoGetNameByType(wt.level1,wt.level2,wt.level3,wt.level4)
            loglocal('clsid: '..pl[i].CLSID..' name: '..wname)
        end
    end
end

--#################################
-- A/G Load programming v0.11
-- This will look at the aircrafts currently loaded pylons and program
-- the PACS A/G Load. Defaults to use front left mpd, can be changed as
-- local dev or argument indev.
ft['A/Gload'] = function(indev)
    local dev = devices.MPD_FRIGHT -- MPD to use for input
    if type(indev) == 'number' then
        dev = indev
        loglocal('ft[A/Gload] device override to: '..dev)
    end

    local button={}             -- mpd osb buttons
    local i = 1
    for j=mfdg_commands.Button_01, mfdg_commands.Button_20 do
        button[i] = j
        i = i + 1
    end

    local menu = {}             -- table of each weapon type {a/gload page, osb}
    menu['MXU-648'] = {1, 5}    -- travel pod
    menu['CBU-87'] = {3, 1}
    menu['Mk20 Rockeye'] = {3, 3}
    menu['CBU-97'] = {3, 4}

    menu['Mk-82 SnakeEye'] = {4, 1}
    menu['Mk-82'] = {4, 2}
    menu['BDU-50LD'] = menu['Mk-82']
    menu['Mk-84'] = {4, 3}
    menu.Mk_84AIR_TP = {4, 12}
    menu.Mk_84AIR_GP = menu.Mk_84AIR_TP
    menu.Mk_82AIR_T = {4, 13}
    menu['Mk-82AIR'] = menu.Mk_82AIR_T
    menu['BDU-50HD'] = menu.Mk_82AIR_T
    menu.Durandal = {4, 14}     -- BLU107

    menu['GBU-12'] = {5, 1}
    menu['LGB-50LGB'] = menu['GBU-12']
    menu['GBU-10'] = {5, 3}
    menu['GBU-24A/B Paveway III'] = {5, 13}

    menu['AGM-65D Maverick'] = {6, 1}
    menu['AGM-65H Maverick'] = {6, 2}
    menu['AGM-65G Maverick'] = {6, 3}
    menu['AGM-65K Maverick'] = {6, 4}

    local pyl = {2, 4, 8, 12, 14} -- A/G capable pylon number
    local pyl2osb = {[2] = 20, [4] = 19,
        [8] = 18, [12] = 17, [14] = 16} -- Pylon num to osb mapping
    local pl = Export.LoGetPayloadInfo().Stations -- current payload by station
    if not pl then
        loglocal('ft[a/gload] LoGetPayloadInfo returned nil')
        return
    end

    -- reset MPD with power cycle
    ttt('Power Switch', {device=dev})
    ttt('Power Switch', {device=dev, onvalue=-1})
    ttt('Push Button 2', {device=dev})
    ttt('Push Button 11', {device=dev})
    ttt('Push Button 7', {device=dev})

    local station = {}
    for _,i in pairs(pyl) do
        if #pl[i].CLSID > 0 then
            local wt = pl[i].weapon
            local wname = Export.LoGetNameByType(wt.level1, wt.level2, wt.level3, wt.level4)
            local page = 0
            loglocal('ft[a/gload] wname: '..wname..' CLSID: '.. pl[i].CLSID)

            if menu[wname] then
                page = menu[wname][1]
                if not station[page] then
                    station[page] = {{wname, menu[wname][2], pyl2osb[i]}}
                else
                    table.insert(station[page],{wname, menu[wname][2], pyl2osb[i]})
                end
            else
                loglocal('ft[a/gload] possible unsupported type: '
                         ..wname..' pl: '..net.lua2json(pl))
            end
        end
    end

    for i=1,5 do                -- step thru menu pages
        loglocal('ft[a/gload] menu page: '..i, 5)
        if station[i] then
            for j=1,#station[i] do
                local act = station[i][#station[i]]
                loglocal('ft[a/gload] stat len: '..net.lua2json(act), 5)
                ttt(nil, {device=dev, action=button[act[2]]})
                ttt(nil, {device=dev, action=button[act[3]]})
                loglocal('ft[a/gload] PRESSED: '..button[act[2]]..' button: '..button[act[3]], 5)
                table.remove(station[i])
            end
            loglocal('ft[a/gload page station done: '..#station[i], 5)
            if #station[i] == 0 then
                table.remove(station[i])
            end
        end
        ttt('Push Button 10', {device=dev}) -- step page
    end
    ttt('Push Button 10', {device=dev}) -- step page

    if #station then
        loglocal('ft[A/Gload]() unprocessed stations: '..net.lua2json(station))
    end
end                             -- end of A/Gload

--#################################
-- Night v0.10
-- 
ft['night'] = function()
    
tt('Console Lights', {action=intlt_commands.console_lt_knob, value=.5})
ttf('Day/Night Mode Selector')
tt('UFC LCD Brightness', {device=devices.UFCCTRL_FRONT, value=.3})
ttf('HUD DAY/AUTO/NIGHT Mode Selector')
tt('HUD Brightness Control', {value=.3})
ttn('Landing/Taxi Light Switch')
ttn('Nav FLIR Switch')
tt('HUD Contrast Control', {value=.83})
tt('HUD Video Brightness Control', {value=.3})

end                             -- end night

--#################################
-- Day v0.10
-- Day lighting settings. Just the reverse of night.
ft['day'] = function()
    
tt('Console Lights', {action=intlt_commands.console_lt_knob, value=0})
ttn('Day/Night Mode Selector')
tt('UFC LCD Brightness', {device=devices.UFCCTRL_FRONT, value=1})
ttn('HUD DAY/AUTO/NIGHT Mode Selector')
tt('HUD Brightness Control', {value=1})
ttf('Landing/Taxi Light Switch')
ttf('Nav FLIR Switch')
tt('HUD Contrast Control', {value=0})
tt('HUD Video Brightness Control', {value=0})

end                             -- end day

return ft
