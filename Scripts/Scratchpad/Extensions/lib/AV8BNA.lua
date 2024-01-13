ft = {}
ft['run'] = {'start'}

ft['disablemap'] = function()
   ttn('MPCD Left Button 3')
   ttn('MPCD Left Button 12')
end

ft['start'] = function()

ttn('Canopy Handle')
ttn('Oxygen Switch',{})
tt('Battery Switch')
tt('Throttle Cutoff Lever')
--throttle off

--set by axis tt('Nozzle Control Lever', {value=.10})
tt('Fuel Shutoff Lever')
tt('DECS Switch')
--fix tt('APU Generator Switch', {value=1})
tt('Master Caution')
tt('MPCD Left Off/Brightness Control')
tt('MPCD Right Off/Brightness Control')
ttt('MPCD Right Button 11')
tt('Engine Start Switch')
--throttle to idle
delay(20)

tt('Seat Ground Safety Lever')
tt('Flaps Power Switch',{value=.5})
tt('RWR Power/Volume Button',{value=.5})
tt('Decoy Dispenser Control',{value=.4})
tt('Jammer Control',{value=.2})

tt('Master Caution')

ttt('MPCD Left Button 2')
tt('Display Brightness Control',{value=.9})
tt('HUD Off/Brightness Control',{value=.5})
tt('Parking Brake Lever')
tt('STO Stop Lever',{value=.65})

tt('Comm 1 Volume Control', {value=.7})
tt('Comm 2 Volume Control', {value=.7})
tt('Master Arm Switch')
--tt('AG Master Mode Selector')
tt('DMT Toggle On/Off')

--INS align
tt('INS Mode Knob',{value=.4})
ft.disablemap()

end                             -- end of start

return ft
