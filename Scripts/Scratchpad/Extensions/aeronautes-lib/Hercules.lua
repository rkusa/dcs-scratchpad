--[[ working functions:

    Prerequisite:
    https://github.com/aeronautes/Hercules-6.8.2-macrofix/archive/refs/heads/main.zip
    You will need to install this macrofix to enable the Anubis Herc
    mod to use the macro interface. Unzip it's contents into the
    location of your Herc mod, ie: "Saved
    Games\DCS\Mods\aircraft\Hercules ver 6.8.2" directory. Note "DCS"
    directory might be slightly different on your system such as
    DCS.openbeta.

    start - Recommend you do this before any other action also right
    click mouse APU switch to RUN position.

    Currently uses ground elec/air and APU, so timing cant clash with
    other ground orders. Just make sure you start engines before doing
    anything else like rearming or fueling. This is not completely
    hands off so you'll need to click right mouse button(RMB)click
    each of the Engine Start dials. You can start an engine once the
    Bleed Air Pressure gauge reads 40.0. You will need to hold RMB
    until the green light next to the engine start dial
    illuminates. You may release once the light is on. Engines need to
    start in reverse numerical order, primarily engine 1 or 2 needs to
    be last to start. The start script will request air/power
    disconnect once both engines 1 and 2 reach 5 rpm. 

    Just know this will allow 4 engines to be cranking if you start an
    engine as soon as sufficient bleed pressure is available. The
    onboard APU bleed air won't sustain 4 engines cranking so just
    wait for 2 engines to be cranking (engine is boxed in Engine
    Display on HDD 2), before starting the last. You should be able to
    crank all engines within 1 minute of startup using this method.

    takeoff - set pilot CNI TOLD INDEX to takeoff data; markers
    indicated in HUD; 

    landing - set pilot CNI TOLD INDEX to landing data; markers
    indicated in HUD; TOLD Index flap setting at 100%

    night - set lighting for night flying

    pivot - display in game chat and log to Scratchpad.log the
    required speed for current altitude to do pivot turn
--]]

-- module specific configuration
wpseq({cur=1, diff = 1, })

local ft = {}
ft.order = {'start', 'takeoff', 'landing', 'night', 'pivot'}

--#################################
-- pivot v0.1
-- log to Scratchpad.log the required speed for current altitude to do pivot turn

ft['pivot'] = function()
    local agl = Export.LoGetAltitudeAboveGroundLevel() * 3.28
    net.recv_chat(math.sqrt(agl*11.3))
    loglocal('agl(ft): '..agl..', kts: '..math.sqrt(agl*11.3))
end                             -- pivot

--[[
    ICommandMenuItem1 966
    ICommandMenuItemPrev 1886
    iCommandToggleCommandMenu 179
    iCommand_UILayer_MouseLeftButton 2501
    iCommand_UILayer_MouseRightButton 2502
    iCommandCockpitClickModeOnOff 363

--]]

--#################################
-- night v0.1
-- sets internal and external lighting for night flying

ft['night'] = function()
    
ttf('Left Landing Lights Extend/Hold/Retract')
ttf('Right Landing Lights Extend/Hold/Retract')
tt('Left Landing Lights On/Off',{value=-1})
tt('Right Landing Lights On/Off',{value=-1})
tt('Taxi Lights On/Off',{value=-1})
--unshade HUD
tt('Display Master Brighness Control',{device=devices.Radios_control,action=devaction.PILOT_hud_contrast_control,value=1})

for i = 1,15 do                 -- reset to dimmest value
ttn('',{device=devices.Radios_control,action=devaction.Pilot_Display_Master_Brighness_Control})
ttn('Display Master Brighness Control')
end

for i=1,6 do                    -- set night brightness
ttf('',{device=devices.Radios_control,action=devaction.Pilot_Display_Master_Brighness_Control})
ttf('Display Master Brighness Control')

tt('',{device=devices.Radios_control,action=devaction.Fwd_Cargo_Lighting_Dome_Brightness_Control, value=-1})
tt('',{device=devices.Radios_control,action=devaction.Aft_Cargo_Lighting_Dome_Brightness_Control, value=-1})
tt('',{device=devices.Radios_control,action=devaction.Aft_Cargo_Lighting_Ramp_Dome_Brightness_Control, value=-1})
end

tt('Jump Platform Light',{value=-1})
tt('Ramp Loading Light',{value=-1})

end                             -- end night

--#################################
-- start v0.11
-- currently uses ground elec/air, so timing cant clash with other ground orders; engines
-- need to start in reverse numerical order, primarily engine 1 or 2 needs to be last to start

ft['start'] = function(action)
    local valid = {engspool='engspool', posteng='posteng'}
    action = valid[action] or ''

    if action == '' then

        -- Beginning of start procedure

--ground crew elec/air on
tt('External power / APU',{value=-1})
Export.LoSetCommand(179)--comm menu
Export.LoSetCommand(973)--f8
Export.LoSetCommand(967)--f2 power
Export.LoSetCommand(966)--f1
Export.LoSetCommand(179)--comm menu
Export.LoSetCommand(973)--f8
Export.LoSetCommand(969)--f4 air
Export.LoSetCommand(966)--f1

ttn('Battery')
ttn('APU Stop/Run/Start')       -- should click APU Run before starting

tt('Aux Hydraulic pump',{value=-1})
ttn('Flightdeck Window Open/Close',{action=devaction.Flightdeck_Windows_Toggle})
ttn('Crew Entrance Door Open/Close')
ttn('',{device=devices.Radios_control,action=devaction.Paratroop_Doors_Toggle})
tt('Flap Lever',{value=-1})
tt('Flap Lever',{value=-1, len=10})
--[[
ttn('Engine 1 Motor/Stop/Run/Start')
ttn('Engine 2 Motor/Stop/Run/Start')
ttn('Engine 3 Motor/Stop/Run/Start')
ttn('Engine 4 Motor/Stop/Run/Start',{len=10})
--]]
tt('HUD Combiner Latch',{action=devaction.PILOT_hud_combiner_latch,value=-1})
ttn('Hud Press Contrast Rotate Brighness',{action=devaction.PILOT_hud_contrast_control})

--put RWR on HDD1
ttn('AMU SelectKey 5',{action=devaction.pilot_AMU001_SelectKey_005})
ttn('AMU SelectKey 7',{action=devaction.pilot_AMU001_SelectKey_007})
ttn('AMU SelectKey 1',{action=devaction.pilot_AMU002_SelectKey_001})
ttn('AMU SelectKey 6',{action=devaction.pilot_AMU001_SelectKey_006})
ttn('AMU SelectKey 6',{action=devaction.pilot_AMU002_SelectKey_006})

press('w') -- set copilot CNI to NAV

-- set pilot CNI to INDEX T/O
ttn('CNI MU INDEX Select',{action=devaction.pilot_CNI_MU_INDEX})
ttn('CNI MU SelectKey 2',{action=devaction.pilot_CNI_MU_SelectKey_002})
ttn('CNI MU SelectKey 12',{action=devaction.pilot_CNI_MU_SelectKey_012})

--ttn('CNI MU NAV CTRL Select',{action=devaction.pilot_CNI_MU_NAV_CTRL})
--press('w')
--[[ set wp to #10 for less buggy behavior
for i=1,9 do
    press('g')
end
--]]

-- AC130 battle station setup
tt('Battle Station Power',{action=devaction.Battle_Station_Power,value=-1})
tt('Guard Master Arm Switch',{action=devaction.Master_Arm_Switch_Guard, value=-1})
tt('Master Arm Switch',{action=devaction.Master_Arm_Switch, value=-1})
tt('Select Cannon Station',{action=devaction.Cannon_Station_Select, value=-1})

-- engspool waits for engine 1 & 2 to spin up and will then disconnect
-- externals. should start engine 1 & 2 after 3 & 4
ft['start']('engspool')
    elseif action == 'engspool' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)
        ttt('Bleed Air Switch APU')

        if not (rpm.left > 5 and rpm.right > 5) then
            loglocal('engspool 1 true '..DCS.getRealTime(), 4)
            press('',{delay=1,fn=ft['start'],arg='engspool'})
        else
            ft['start']('posteng')
        end
    elseif action == 'posteng' then
        
--ground crew elec/air off
tt('External power / APU',{value=1})
Export.LoSetCommand(179)--comm menu
Export.LoSetCommand(973)--f8
Export.LoSetCommand(967)--f2 power
Export.LoSetCommand(967)--f2
Export.LoSetCommand(179)--comm menu
Export.LoSetCommand(973)--f8
Export.LoSetCommand(969)--f4 air
Export.LoSetCommand(967)--f2

    end                             -- end elseif posteng
end                             -- start

ft['takeoff'] = function(action)
    
ttn('CNI MU INDEX Select',{action=devaction.pilot_CNI_MU_INDEX})
ttn('CNI MU SelectKey 2',{action=devaction.pilot_CNI_MU_SelectKey_002})
ttn('CNI MU SelectKey 12',{action=devaction.pilot_CNI_MU_SelectKey_012})
    
end

ft['landing'] = function(action)
    
ttn('CNI MU INDEX Select',{action=devaction.pilot_CNI_MU_INDEX})
ttn('CNI MU SelectKey 3',{action=devaction.pilot_CNI_MU_SelectKey_003})
ttn('CNI MU SelectKey 12',{action=devaction.pilot_CNI_MU_SelectKey_012})
ttn('CNI MU SelectKey 12',{action=devaction.pilot_CNI_MU_SelectKey_010})
ttn('CNI MU SelectKey 12',{action=devaction.pilot_CNI_MU_SelectKey_010})

end




function mapgoto(new) --argument position vector
    local a = Export.LoGetCameraPosition()

    a.p.x = new.x
    a.p.z = new.z
    Export.LoSetCameraPosition(a)
end

function findbase(base)
    Export.LoSetCommand(15)
    bases = Export.LoGetWorldObjects('airdromes')
    local k = {}
    for i,_ in pairs(bases) do
        table.insert(k,i)
    end
    table.sort(k)

    if type(base) == 'number' then
        if bases[k[base]] then
            --loglocal(net.lua2json(bases[k[base]]))
            return bases[k[base]]
        end

        j=base
        while (bases[k[j]].Name == 'woRunWay') do j = j + 1 end
        loglocal('RWY: '..bases[k[j]].Name)

    elseif type(base) == 'string' then
        for  i,j in pairs(bases) do
            if j.Name == base then
                loglocal('found base: '..base)
                loglocal(net.lua2json(bases[i]))
                return bases[i-1]
            end
        end
    end

end --findbase

function L2DDM(L)
    
end

function showpos()
    local a = Export.LoGetCameraPosition()
    local b = Export.LoLoCoordinatesToGeoCoordinates(a.x,a.z) --terrain.convertMetersToLatLon(a.x,a.z) 
    loglocal(net.lua2json(formatCoord({format='DDM', lonDegreeWidth=3}, false, b.longitude, '')))
end

--showpos()
--loglocal(table_dump(DCS))

function dumptable(Tab, opt)
    loglocal('TABLE: ')
    local t = {}
    for  i,j in pairs(Tab) do
        if opt and type(j) == opt then
            table.insert(t, i)
        else
            table.insert(t, i)
        end
    end
    table.sort(t)
    return(t)
end 

--for i,j in pairs(dumptable(Gui)) do
--   loglocal(j)
--end
--loglocal(net.lua2json(dumptable(DCS, 'function')))

--loglocal()

--mapgoto(findbase('Muwaffaq Salti').Position)

return ft
