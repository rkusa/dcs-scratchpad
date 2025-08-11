--[[ working functions:
    start - starts jet; requires final Master Caution
    setup - cockpit settings post autostart
    maptoggle - toggles moving map on EHSD
    night - cockpit lighting for night
--]]

-- module specific configuration
wpseq({cur=1,
       diff = 1,
})

ft ={}
ft.order={'start', 'setup', 'maptoggle', 'night'}

--#################################
-- maptoggle v0.1
-- toggles moving map on EHSD
ft['maptoggle'] = function()

--tt('MPCD Left Off/Brightness Control',{value=0.5, action=mpcd_l_commands.Knob_OFF_BRT, device=devices.MPCD_LEFT})
ttn('MPCD Left Button 18')
ttn('MPCD Left Button 2')
ttn('MPCD Left Button 3')
ttn('MPCD Left Button 12')
ttn('MPCD Left Button 3')

end

--#################################
-- start v0.2
-- start the jet; Master Caution will engage after this finishes
ft['firstspool'] = true
ft['start'] = function(action)
    local valid = {engspool='engspool', posteng='posteng'}
    action = valid[action] or ''

    if action == '' then

        -- Beginning of start procedure
        net.recv_chat('AV8 start, throttle off')
ttn('Canopy Handle')
ttn('Oxygen Switch',{})
tt('Battery Switch')
tt('Throttle Cutoff Lever')
Export.LoSetCommand(2004,1)     --throttle off

--set by axis tt('Nozzle Control Lever', {value=.10})
tt('Fuel Shutoff Lever')
tt('DECS Switch')
--fix tt('APU Generator Switch', {value=1})
tt('Master Caution')
tt('MPCD Left Off/Brightness Control')
tt('MPCD Right Off/Brightness Control')
ttt('MPCD Right Button 11')
tt('Engine Start Switch')

    ft['start']('engspool')
    elseif action == 'engspool' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

        if rpm.left < 5 then
            loglocal('engspool 1 true '..DCS.getRealTime(), 4)
            press('',{delay=1,fn=ft['start'],arg='engspool'})
        else
            if rpm.left < 10 then
                if ft['firstspool'] then
                    Export.LoSetCommand(2004,-1) --full
                    ft['firstspool'] = false
                else
                    Export.LoSetCommand(2004, 1) --idle
                end
                press('',{delay=1,fn=ft['start'],arg='engspool'})
            else
                ft['start']('posteng')
            end
        end
    elseif action == 'posteng' then

tt('Seat Ground Safety Lever')
tt('Flaps Power Switch',{value=.5})
tt('RWR Power/Volume Button',{value=.5})
tt('Decoy Dispenser Control',{value=.4})
tt('Jammer Control',{value=.2})

ttt('MPCD Left Button 2')
tt('Display Brightness Control',{value=.9})
tt('HUD Off/Brightness Control',{value=.5})
tt('Parking Brake Lever')
tt('STO Stop Lever',{value=.65})

tt('Comm 1 Volume Control', {value=.7})
tt('Comm 2 Volume Control', {value=.7})
tt('Master Arm Switch')
tt('DMT Toggle On/Off')

--INS align
tt('INS Mode Knob',{value=.4})
    end                             -- posteng

tt('Master Caution')
end                             -- end of start

--#################################
-- setup v0.1
-- cockpit setup that can be used after startup or module autostart
ft['setup'] = function(input)

ttn('FLIR Power Switch')

end                         -- end setup

--#################################
-- night v0.1
-- turn on cockpit lights and NW light
ft['night'] = function(input)

tt('EDP Brightness Control', {value=.3})
ttn('MPCD Left Display NIGHT Mode')
ttn('MPCD Right Display NIGHT Mode')
tt('Instruments Lights',{value=.3})
tt('Console Lights',{value=.3})
tt('Annunciator Lights',{value=.3})
ttn('External Auxiliary Lights Switch')

end                             -- end night

return ft
