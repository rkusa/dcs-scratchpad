--[[ F16 Fence in v1.0
--]]

wpseq({menus = 'r4',
       cur = -1,
       diff = 1,
})

ft = {}
--#################################
-- start v0.1
-- This will start engine and initiate a stored heading
-- alignment. Once alignment is finished you will need to move INS
-- knob to NAV

ft['start'] = function(action)
    if type(action) == 'table' then

        -- Beginning of start procedure

ttn('MAIN PWR Switch, MAIN PWR/BATT/OFF')
tt('JFS Switch, START 1/OFF/START 2',{value=-1})
tt('Canopy Switch, OPEN/HOLD/CLOSE(momentarily)',{value=-1})
delay(5)
ttf('Canopy Switch, OPEN/HOLD/CLOSE(momentarily)')
ttn('Canopy Handle, UP/DOWN')
tt('Ejection Safety Lever, ARMED/LOCKED')

ttn('LEFT HDPT Switch, ON/OFF')
ttn('RIGHT HDPT Switch, ON/OFF')
ttn('FCR Switch, FCR/OFF')
--ttf('RDR ALT Switch, RDR ALT/STBY/OFF',{value=1} )
tt('MMC Switch, MMC/OFF')
tt('ST STA Switch, ST STA/OFF')
tt('MFD Switch, MFD/OFF')
tt('UFC Switch, UFC/OFF')
tt('GPS Switch, GPS/OFF')
tt('MIDS LVT Knob, ZERO/OFF/ON',{value=1})

    ft['start']('engspool')
    elseif action == 'engspool' then
        rpm = Export.LoGetEngineInfo().RPM
        loglocal('engspool rpm: '..rpm.left..' : '..rpm.right)

        if rpm.left < 21 then
            loglocal('engspool 1 true '..DCS.getRealTime(), 4)
            press('',{delay=1,fn=ft['start'],arg='engspool'})
        else
            Export.LoSetCommand(311)
            ft['start']('posteng')
        end
    elseif action == 'posteng' then
        tt('INS Knob, OFF/STOR HDG/NORM/NAV/CAL/INFLT ALIGN/ATT', {value=.1})
        tt('ICP HUD Symbology Intensity Knob',{value=1})
    end
end                             -- end of start

--#################################
-- fence v0.6
-- This is a follow up to the 'start' function above. Once alignment
-- is done you can fence to do complete cockpit setup

ft['fence'] = function()
tt('ICP HUD Symbology Intensity Knob',{value=1})
dt = 0
dt_mto = 0
function set_mfd_page(mfd, osb)
    push_stop_command(dt, {device = mfd, action = osb, value = 1.0})
    push_stop_command(dt, {device = mfd, action = osb, value = 1.0})
end

function clear_mfd_page(mfd, osb)
    set_mfd_page(mfd, osb)
    push_stop_command(dt, {device = mfd, action = mfd_commands.OSB_1, value = 1.0})
end

function press_rel(dev, button)
    push_stop_command(dt, {device = devices.UFC,     action = button, value = 1.0})
    push_stop_command(dt, {device = devices.UFC,     action = button, value = -1.0})
end

-- Stop sequence
push_stop_command(2.0,    {message = _("FENCE IN IS RUNNING"), message_timeout = start_sequence_time})
--
-- IFF on
push_stop_command(dt,{message = _("- IFF MASTER KNOB"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.IFF_CONTROL_PANEL,    action = iff_commands.MasterKnob,value = 0.3})

-- External lights
push_stop_command(dt,{message = _("- External lights covert"),message_timeout = dt_mto})
push_stop_command(dt,{device = devices.EXTLIGHTS_SYSTEM,action = extlights_commands.Master,value = 0.1})

-- Enable ECM
push_stop_command(dt, {message = _("- ENABLE ECM"), message_timeout = 1 + dt_mto})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.PwrSw, value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.XmitSw, value = -1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.OneBtn, value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.TwoBtn, value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.ThreeBtn,     value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.FourBtn, value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.FiveBtn, value = 1.0})
push_stop_command(dt, {device = devices.ECM_INTERFACE, action = ecm_commands.SixBtn, value = 1.0})

-- Enable RWR and CMDS
push_stop_command(dt, {message = _("- ENABLE RWR AND CMDS"),    message_timeout = 1 + dt_mto})
push_stop_command(dt, {device = devices.RWR,     action = rwr_commands.Power, value = 1.0})
push_stop_command(dt,{device = devices.RWR,    action = rwr_commands.Search,value = 1.0})
push_stop_command(dt,{device = devices.RWR,    action = rwr_commands.Mode,value = 1.0})
push_stop_command(dt,{device = devices.CMDS,    action = cmds_commands.RwrSrc,value = 1.0})
push_stop_command(dt,{device = devices.CMDS,    action = cmds_commands.JmrSrc,value = 1.0})
push_stop_command(dt,{device = devices.CMDS,    action = cmds_commands.ChExp,value = 1.0})
push_stop_command(dt,{device = devices.CMDS,    action = cmds_commands.FlExp,value = 1.0})
push_stop_command(dt,{device = devices.CMDS,    action = cmds_commands.Mode, value = 0.2})

-- HMCS on
push_stop_command(dt,{message = _("- HMCS SYMBOLOGY INT POWER KNOB - INT"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.HMCS,    action = hmcs_commands.IntKnob,    value = 0.8})

-- HMCS on
push_stop_command(dt,{message = _("- LANDING LIGHTS"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.EXTLIGHTS_SYSTEM,    action = extlights_commands.LandingTaxi,    value = 1.0})

-- ILS vol off
push_stop_command(dt,{message = _("- ILS VOL OFF"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.INTERCOM, action = intercom_commands.ILS_PowerKnob,    value = 0.0})

-- TACAN vol off
push_stop_command(dt,{message = _("- TACAN VOL OFF"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.INTERCOM, action = intercom_commands.TACAN_Knob,    value = 0.0})

-- Master,Laser, RF arm
push_stop_command(dt,{message = _("- ARMAMENT SWITCH"),    message_timeout = dt_mto})
push_stop_command(dt,{device = devices.MMC,    action = mmc_commands.MasterArmSw,value = 1.0})
push_stop_command(dt,{device = devices.SMS,    action = sms_commands.LaserSw,    value = 1.0})
push_stop_command(dt,{device = devices.UFC,    action = ufc_commands.RF_Sw,    value = 1.0})

-- Set Up MFDs
push_stop_command(dt, {message = _("- SET UP MFDS"), message_timeout = 1 + dt_mto})
-- Dogfight override
push_stop_command(dt, {device = devices.HOTAS, action = hotas_commands.THROTTLE_DOG_FIGHT, value = 1.0})
-- add HSD
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
--set_mfd_page(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_7, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_2, value = 1.0})
-- XMT L16
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_6, value = 1.0})
-- add TGP
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
--set_mfd_page(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_19, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})

-- Missle override
push_stop_command(dt, {device = devices.HOTAS, action = hotas_commands.THROTTLE_DOG_FIGHT,  value = -1.0})
-- add HSD
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
--set_mfd_page(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_7, value = 1.0})
-- add TGP
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
--set_mfd_page(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_19, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT,     action = mfd_commands.OSB_13, value = 1.0})
--set az/range
push_stop_command(dt, {device = devices.MFD_LEFT,     action = mfd_commands.OSB_18, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT,     action = mfd_commands.OSB_20, value = 1.0})

-- exit overrides
push_stop_command(dt, {device = devices.HOTAS, action = hotas_commands.THROTTLE_DOG_FIGHT, value = 0.0})

push_stop_command(dt, {message = _("- CLEAR NAV MFD"), message_timeout = 1 + dt_mto})
-- clear pages on nav
clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_12)
clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_13)
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_14, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_18, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_20, value = 1.0})

push_stop_command(dt, {message = _("- CLEAR AA MFD"), message_timeout = 1 + dt_mto})
-- clear pages on AA
press_rel(devices.UFC, ufc_commands.AA)
clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_12)
clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_13)
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_14, value = 1.0})

push_stop_command(dt, {message = _("- CLEAR AG MFD"), message_timeout = 1 + dt_mto})
-- clear pages on AG
press_rel(devices.UFC, ufc_commands.AG)
--clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_12)
--clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_13)
--clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_14)

push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_14, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_14, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_1, value = 1.0})

push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_2, value = 1.0})

push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_19, value = 1.0})

--[[set_mfd_page(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_19, value = 1.0})
set_mfd_page(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_13, value = 1.0})
push_stop_command(dt, {device = devices.MFD_LEFT, action = mfd_commands.OSB_2, value = 1.0})
clear_mfd_page(devices.MFD_LEFT, mfd_commands.OSB_14)
--
set_mfd_page(dt, {device = devices.MFD_RIGHT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT, action = mfd_commands.OSB_18, value = 1.0})
--]]
-- WPN page
push_stop_command(dt, {device = devices.MFD_RIGHT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT, action = mfd_commands.OSB_12, value = 1.0})
push_stop_command(dt, {device = devices.MFD_RIGHT, action = mfd_commands.OSB_18, value = 1.0})

press_rel(devices.UFC, ufc_commands.AG)

-- bullseye enable
push_stop_command(dt, {message = _("- ENABLE BULLSEYE"), message_timeout = 1 + dt_mto})
--press_rel(devices.UFC, ufc_commands.LIST)
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.LIST, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DIG0_M_SEL, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DIG8_FIX, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DIG0_M_SEL, value = 1.0})

-- hmcs in pit enable
push_stop_command(dt, {message = _("- DISABLE HMCS PIT BLANK "), message_timeout = 1 + dt_mto})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.LIST, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DIG0_M_SEL, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.RCL, value = 1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DCS_DOWN, value = -1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DIG0_M_SEL, value = 1.0})

-- return ICP
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DCS_RTN, value = -1.0})
push_stop_command(dt, {device = devices.UFC,     action = ufc_commands.DCS_RTN, value = 0.0})

-- Power intake hardpoints and FCR
push_stop_command(dt, {message = _("- POWER INTAKE HARDPOINTS"), message_timeout = 1 + dt_mto})
push_stop_command(dt,{device = devices.SMS,    action = sms_commands.LeftHDPT,    value = 1.0})
push_stop_command(dt,{device = devices.SMS,    action = sms_commands.RightHDPT,value = 1.0})
push_stop_command(dt,{device = devices.FCR,    action = fcr_commands.PwrSw,    value = 1.0})

-- Fuel Qty sel centerline
push_stop_command(dt, {message = _("- CENTERLINE FUEL GAUGE"), message_timeout = 1 + dt_mto})
push_stop_command(dt,{device = devices.FUEL_INTERFACE,    action = fuel_commands.FuelQtySelSw,value = 0.5})


push_stop_command(dt,{device = devices.CPT_MECH,    action = cpt_commands.StickHide,    value = 1.0})
--
push_stop_command(dt,    {message = _("FENCE IN COMPLETE"),message_timeout = std_message_timeout})

end                             -- end fence


return ft
