--[[ working functions:

    start - start systems and engines, will need to manually set INS
    knob to IFA when alignment done

    night - setup night lighting

    stores - steps thru 4 pylons and sets TOO mode, then sets QTY
    all 4 pylons
--]]

-- F18 can't select WP by number so disable starting number(cur) and
-- default to incrementing to next WP
wpseq({ cur = -1,
        diff = 1,
})

local ft ={}
ft['bingo'] = 2000              -- bingo value in pounds(Lbs)
ft.order = {'start', 'night', 'stores'}

--#################################
-- stores v.1
-- configure stores; currently checks pylons

ft['stores'] = function (indev)
    local dev = devices.MDI_LEFT -- MPD to use for input
    if type(indev) == 'number' then
        dev = indev
        loglocal('ft[stores] device override to: '..dev)
    end

    local button={}             -- mdi osb buttons
    local i = 1
    for j=MDI_commands.MDI_PB_1, MDI_commands.MDI_PB_20 do
        button[i] = j
        i = i + 1
    end

    local pylon = {2, 3, 5, 7, 8} -- A/G capable pylon number
    local pyl2osb = {[2] = 6, [3] = 7, [5] = 8, [7] = 9, [8] = 10}
    local PL = Export.LoGetPayloadInfo().Stations -- current payload by station
    if not PL then
        loglocal('ft[stores] LoGetPayloadInfo returned nil')
        return
    end

    function setTOO()
        local TOOweapon = {}
        TOOweapon['AGM-84D'] = 1
        TOOweapon['AGM-84E SLAM'] = 2
        TOOweapon['AGM-84H'] = 3
        TOOweapon['AGM-154A'] = 4
        TOOweapon['AGM-154 JSOW'] = 5
        TOOweapon['GBU-38(V)1/B'] = 6
        TOOweapon['GBU-31(V)1/B'] = 7
        TOOweapon['GBU-31(V)2/B'] = 7
        TOOweapon['GBU-31(V)3/B'] = 8
        TOOweapon['GBU-31(V)4/B'] = 8
        TOOweapon['GBU-32(V)2/B'] = 9

        local wtpyl = {}        -- aggregate weapon type on pylons
        local toosb = {}        -- osb6-10 with too weapon
        local osbctr = 0        -- TGP isnt recognized in OSB menu
        for i,j in pairs(pylon) do
            if #PL[j].CLSID > 0 then
                local wname = Export.LoGetNameByType(PL[j].weapon.level1,
                                                     PL[j].weapon.level2,
                                                     PL[j].weapon.level3,
                                                     PL[j].weapon.level4)
                loglocal('stores wname: '..wname..' CLSID: '.. PL[j].CLSID)
                osbctr = osbctr + 1
                local wt = TOOweapon[wname]
                if wt then      --munition is TOO capable
                    if wtpyl[wt] then
                        wtpyl[wt].count = wtpyl[wt].count + 1
                        toosb[wtpyl[wt].osb] = toosb[wtpyl[wt].osb] + 1
                    else
                        wtpyl[wt] = {
                            ['name'] = wname,
                            ['count'] = 1,
                            ['osb'] = osbctr,}
                        toosb[osbctr] = 1
                    end
                elseif wname == 'AN/AAQ-28 LITENING' then
                    osbctr = osbctr - 1
                else            -- non TOO weapon
                end
            end
        end
        loglocal('wtpyl: '..net.lua2json(wtpyl))
        for i,j in pairs(toosb) do
            loglocal('toosb: '..i..': '..j)
        end
        for i,j in pairs(toosb) do
            local b = button[5] + i
            ttt('',{device=dev, action=b})
            for k=1, j do
                ttt('Left MDI PB 5')
                ttt('Left MDI PB 13')
            end
        end
    end
    
    setTOO()
--[[    ttn('Master Arm Switch, ARM/SAFE')
    ttt('Left MDI PB 11') --jdam display is in 2 different positions, 11/12
    ttt('Left MDI PB 15')
--]]



end                             -- end stores

--#################################
-- toopylon v.5
-- toopylon is used to set all 4 pylons to TOO. This requires you are
-- at the STORES page with the munition selected. It will also set QTY
-- to all 4 pylons

--ft['toopylon'] = function ()
function f18deprecate()
    ttn('Master Arm Switch, ARM/SAFE')
    --[[ reset mfd
    tt('Left MDI PB 18')
    delay(.2)
    tt('Left MDI PB 5')
        delay(.2)
    --]]
  ttt('Left MDI PB 5')
delay(.2)
  ttt('Left MDI PB 13')
delay(.2)
  ttt('Left MDI PB 5')
delay(.2)
  ttt('Left MDI PB 13')
delay(.2)
  ttt('Left MDI PB 5')
delay(.2)
  ttt('Left MDI PB 13')
delay(.2)
  ttt('Left MDI PB 5')
delay(.2)
  ttt('Left MDI PB 13')
delay(.2)

ttt('Left MDI PB 12')
delay(.2)
ttt('Left MDI PB 15')
delay(.4)
ttt('Left MDI PB 11')
delay(.2)
ttt('Left MDI PB 12')
delay(.2)
ttt('Left MDI PB 13')
delay(.2)
ttt('Left MDI PB 14')
delay(.2)
ttt('Left MDI PB 15')
delay(.2)
ttt('Left MDI PB 6')
end

--#################################
--start v.7
-- This start will start engines and setup pit with assorted initial
-- setings.
-- Requirement: you will need to move INS alignment knob to IFA once
-- aligned OK

local ctr = 1
ft['start'] = function (action)
    local valid = {reng='reng', postreng='postreng',leng='leng', postleng='postleng',}
    action = valid[action] or ''

    if action == '' then
-- Beginning of start procedure

tt('Ejection Seat SAFE/ARMED Handle, SAFE/ARMED',{value=-1})
tt('Battery Switch, ON/OFF/ORIDE')
ttn('APU Control Switch, ON/OFF')
--delay(1)
--ttf('APU Control Switch, ON/OFF')

tt('Canopy Control Switch, OPEN/HOLD/CLOSE',{value=-1})
--delay(10)

tt('Left MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('Right MDI Brightness Selector Knob, OFF/NIGHT/DAY')
tt('UFC Brightness Control Knob',{value=.9})
tt('HUD Symbology Brightness Control Knob',{value=.9})
tt('AMPCD Off/Brightness Control Knob',{value=.9})
tt('UFC COMM 1 Volume Control Knob',{value=.9})
tt('UFC COMM 2 Volume Control Knob',{value=.9})
tt('HMD OFF/BRT Knob',{value=.7}) --higher than .7 moves knob past max

--delay(3)

    ft['start']('reng')
    elseif action == 'reng' then

        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        local dbl = 0

        if rpm.right == 0 then
            tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw, value=1})
            delay(5)
            ttf('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankRSw})
            press('',{delay=1,fn=ft['start'], arg='reng'}) 
            return
        else
            if rpm.right < 15 then
                loglocal('rengspool 1 true '..DCS.getRealTime(), dbl)
                press('',{delay=1,fn=ft['start'], arg='reng'})
                return
            else
                if rpm.right < 50 then
                    loglocal('rengspool 2 true ', dbl)
                    Export.LoSetCommand(312) -- throttle idle
                    press('',{delay=1,fn=ft['start'], arg='reng'})
                    return
                else
                    loglocal('rengspool 3 true ', dbl)
                end
            end
        end

    ft['start']('postreng')
    elseif action == 'postreng' then

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

tt('HMD OFF/BRT Knob', {value=1})

--tt('Altitude Switch, BARO/RDR',{value=-1})
tt('IR Cooling Switch, ORIDE/NORM/OFF',{value=.1})
tt('DISPENSER Switch, BYPASS/ON/OFF',{value=.1})
tt('ECM Mode Switch, XMIT/REC/BIT/STBY/OFF',{value=.1})
ttn('ALR-67 POWER Pushbutton')
ttf('FLIR Switch, ON/STBY/OFF')


ttt('UFC Function Selector Pushbutton, IFF')
tt('UFC Function Selector Pushbutton, ON/OFF')
delay(.5)
ttt('UFC Function Selector Pushbutton, D/L')
ttt('UFC Function Selector Pushbutton, ON/OFF')
delay(.5)
ttt('UFC Function Selector Pushbutton, D/L')
ttt('UFC Function Selector Pushbutton, ON/OFF')
--tt('Altitude Switch, BARO/RDR')

tt('HUD Symbology Brightness Control Knob', {value=1})
tt('AMPCD Off/Brightness Control Knob',{value=1})

ttt('Right MDI PB 10')          -- stop bit blink

for i=1,ft['bingo']/100 do
    ttt('IFEI Up Arrow Button')
end

ttn('FCS RESET Button')
delay(1)
ttf('FCS RESET Button')
ttt('T/O TRIM Button')

--INS alignment
push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.2})
tt('AMPCD PB 19')
--delay(100)
--push_start_command(0, {device=devices.INS, action=INS_commands.INS_SwitchChange, value = 0.4})

    ft['start']('leng')
    elseif action == 'leng' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('lengspool rpm: '..rpm.left..' : '..rpm.right)
        local dbl = 0

        if rpm.left == 0 then
            tt('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw, value=-1})
            delay(5)
            ttf('Engine Crank Switch, LEFT/OFF/RIGHT',{action=engines_commands.EngineCrankLSw})
            press('',{delay=1,fn=ft['start'], arg='leng'})
            return
        else
            if rpm.left < 15 then
                press('',{delay=1,fn=ft['start'], arg='leng'})
                return
            else
                Export.LoSetCommand(311)
                -- fall thru to start(postleng)
            end
        end

        ft['start']('postleng')
    elseif action == 'postleng' then

--setup SA page
ttt('Right MDI PB 18')
ttt('Right MDI PB 13')
ttt('Right MDI PB 5')
--ttt('Right MDI PB 7')
ttt('Right MDI PB 7')
ttt('Right MDI PB 8')
ttt('Right MDI PB 8')
ttt('Right MDI PB 10')
ttt('Right MDI PB 8')
ttt('Right MDI PB 8')
ttt('Right MDI PB 8')
ttt('Right MDI PB 8')

--external lights
tt('FORMATION Lights Dimmer Control',{value=1})
tt('POSITION Lights Dimmer Control',{value=1})
ttn('LDG/TAXI LIGHT Switch, ON/OFF')

--disable moving map
ttt('AMPCD PB 3')
ttt('AMPCD PB 3')

--precise latlong
ttt('AMPCD PB 10')
ttt('AMPCD PB 19')
ttt('AMPCD PB 10')

    end                         -- end elseif action
end                             -- end of start()

ft['night'] = function(briteval)
    if type(briteval) ~= 'number' then
        briteval = .4
    end

ttf('HUD Symbology Brightness Selector Knob, DAY/NIGHT')
tt('HMD OFF/BRT Knob', {value=.3})
tt('UFC Brightness Control Knob', {value=briteval})
tt('Left MDI Brightness Selector Knob, OFF/NIGHT/DAY',{value=.1})
tt('Right MDI Brightness Selector Knob, OFF/NIGHT/DAY',{value=.1})
ttt('AMPCD Night/Day Brightness Selector, NGT',{onvalue=-1})
tt('IFEI Brightness Control Knob', {value=briteval})
tt('CONSOLES Lights Dimmer Control', {value=briteval})
tt('INST PNL Dimmer Control', {value=briteval})
ttf('MODE Switch, NVG/NITE/DAY')
ttn('POSITION Lights Dimmer Control')
ttn('FORMATION Lights Dimmer Control')

end                             -- end of night

return ft
